class Box < ApplicationRecord

  belongs_to :user, class_name: 'User', inverse_of: :boxes
  has_many :posts, class_name: 'Post', inverse_of: :box
  has_many :followings, class_name: 'Following'
  has_many :followed_users, -> { distinct }, through: :followings, class_name: 'User', source: :user
  has_one :recommend, class_name: 'Recommend', inverse_of: :box
  has_many :orders, class_name: 'Order', inverse_of: :box

  validates :price, numericality: { greater_than_or_equal_to: 0 }  

  scope :with_includes, -> { includes(:user) }
  scope :can_display, -> { where(state: [:available]) }
  scope :unapproved, -> { where(approved: false).where.not(state: [:available, :created, :paused]) }

  include NumberGenerator
  def generate_number(options = {})
    options[:prefix] ||= NumberGenerator::PREFIX_BOX
    super(options)
  end

  before_create :generate_and_upload_qrcode
  after_create :start!
  before_save :make_count_on_hand_not_nil

  # :initaial -> :unavailable -> available <-> paused -> achieved
  state_machine :state, initial: :created do
    
    event :achieve do
      transition all - [:achieved] => :achieved
    end

    event :pause do
      transition :available => :paused
    end

    event :resume do
      transition :paused => :available
    end

    event :start do
      transition :created => :available
    end

    event :forbid do
      transition all - [:achieved, :forbidden] => :forbidden
    end

    after_transition any => :achieved do |box, transition|
      LOG_DEBUG("box #{box.title} achieved.")
    end

  end

  def recommended?
    self.recommend.present?
  end

  def display_state
    h = {
      'created' => '已创建',
      'available' => '售卖中',
      'paused' => '暂停中',
      'forbidden' => '审核未通过',
      'achieved' => '已归档',
    }
    h[self.state]
  end

  def image
    s = super
    if s.present? && !(s =~ /^https:\/\//)
      s = "#{DRAFT_CONFIG['qiniu_cname']}/#{s.gsub(/^https?:\/\/.*?\//, '')}"
    end
    return s
  end

  def qrcode_image
    s = super
    if s.present? && !(s =~ /^https:\/\//)
      s = "#{DRAFT_CONFIG['qiniu_cname']}/#{s.gsub(/^https?:\/\/.*?\//, '')}"
    end
    return s
  end

  def blur_images
    s = super || []
    ss = s.map do |i|
      if !(i =~ /^https:\/\//)
        "#{DRAFT_CONFIG['qiniu_cname']}/#{i.gsub(/^https?:\/\/.*?\//, '')}"
      else
        i
      end
    end
    return ss
  end

  def is_mine?(user)
    user.try(:id) == self.user_id
  end

  def is_free
    self.price == 0
  end

  def can_access?(user)
    return false if user.nil?
    return true if user.id == self.user_id
    following = Following.where(user_id: user.id, box_id: self.id).order('followings.created_at desc').first
    return false unless following.present?
    return following.can_access?
  end

  def can_supply?(quantity = 1)
    self.available? && 
    self.posts.count > 0 && 
    (self.count_on_hand >= quantity || !self.tracking_inventory)
  end

  def create_order!(user)
    self.orders.create!(
      buyer_id: user.id,
      buyer_name: user.name,
      buyer_image: user.image,
      seller_id: self.user_id,
      seller_name: self.user_name,
      seller_image: self.user_image,
      box_title: self.title,
      quantity: 1,
      price: self.price,
    )
  end

  def order_finalize!(order)
    self.sales = self.sales + order.quantity
    self.count_on_hand = self.count_on_hand - order.quantity if self.tracking_inventory
    self.save!
  end

  def generate_and_upload_qrcode
    url = "https://tips.worthmore.cn/mp/box?number=#{self.number}"
    png = Draft::Qrcode.generate_png(url)
    code, res = Draft::Qiniu.upload(png, "qrcode/#{self.number}")
    if code == 200
      self.qrcode_image = res["key"]
    end
  end

  # called when create box
  def composite_main_image
    file = Draft::Imagemagick.generate_box_image(self)
    if file.present?
      code, res = Draft::Qiniu.upload(File.read(file), "composite_image/#{self.number}")
      if code == 200
        self.update_column(:image, res["key"])
      end
    end
  end

  # called when recommend
  def blur_post_images
    image_files = Draft::Imagemagick.blur_post_images(self)
    if image_files.present?
      blur_images = []
      image_files.map do |file|
        code, res = Draft::Qiniu.upload(File.read(file), "composite_image/#{self.number}")
        if code == 200
          blur_images << res["key"]
        end
      end
      self.update_column(:blur_images, blur_images) if blur_images.present?
    end
  end

  def make_count_on_hand_not_nil
    if self.count_on_hand.nil? || self.count_on_hand < 0
      self.count_on_hand = 0
    end
  end

end
