class Box < ApplicationRecord

  belongs_to :user, class_name: 'User', inverse_of: :boxes
  has_many :posts, class_name: 'Post', inverse_of: :box
  has_many :followings, class_name: 'Following'
  has_many :followed_users, through: :followings, class_name: 'User', source: :user
  has_one :recommend, class_name: 'Recommend', inverse_of: :box
  has_many :orders, class_name: 'Order', inverse_of: :box

  scope :with_includes, -> { includes(:user) }

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

    after_transition any => :achieved do |box, transition|
      LOG_DEBUG("box #{box.title} achieved.")
    end

  end

  def image
    s = super
    if s.present? && !(s =~ /^https?:\/\//)
      s = "#{DRAFT_CONFIG['qiniu_cname']}/#{s.gsub(/^https?:\/\/.*?\//, '')}"
    end
    return s
  end

  def is_mine(user)
    user.try(:id) == self.user_id
  end

  def can_supply?(quantity = 1)
    self.available? && 
    self.posts.count > 0 && 
    (self.count_on_hand >= quantity || !self.tracking_inventory)
  end

  def create_order!(user)
    self.orders.create!(
      buyer_id: user.id,
      seller_id: self.user_id,
      quantity: 1,
      price: self.price,
    )
  end

  def order_finalize!(order)
    self.sales = self.sales + order.quantity
    self.count_on_hand = self.count_on_hand - order.quantity
    self.save!
  end

  def generate_and_upload_qrcode
    url = "https://tips.worthmore.cn/mp/box?number=#{self.number}"
    png = Draft::Qrcode.generate_png(url)
    code, res = Draft::Qiniu.upload(png, "qrcode/#{self.number}")
    if code == 200
      self.image = "#{DRAFT_CONFIG['qiniu_cname']}/#{res["key"]}"
    end
  end

  def make_count_on_hand_not_nil
    if self.count_on_hand.nil? || self.count_on_hand < 0
      self.count_on_hand = 0
    end
  end

end
