class User < ApplicationRecord

  acts_as_paranoid
  has_many :action_logs, class_name: 'ActionLog'
  has_many :boxes, class_name: 'Box', inverse_of: :user
  has_many :posts, class_name: 'Post', inverse_of: :user
  has_many :followings, class_name: 'Following'
  has_many :following_boxes, through: :followings, class_name: 'Box', source: :box
  has_one :balance, class_name: 'Balance', inverse_of: :user
  has_many :withdraws, class_name: 'Withdraw', inverse_of: :user
  has_many :buy_orders, class_name: 'Order', inverse_of: :buyer, foreign_key: :buyer_id
  has_many :sell_orders, class_name: 'Order', inverse_of: :seller, foreign_key: :seller_id

  after_create :create_balance

  def admin?
    self.role == 'admin'
  end
  
  def image
    s = super
    if s.present? && !(s =~ /^https?:\/\//)
      s = "#{DRAFT_CONFIG['qiniu_cname']}/#{s.gsub(/^https?:\/\/.*?\//, '')}"
    end
    return s
  end

  def self.from_token_request(permited_params)
    return if permited_params[:js_code].blank?
    session_res = Draft::WX.get_session_key(permited_params[:js_code])
    LOG_DEBUG("session_res: #{session_res}")
    openid = session_res['openid']
    session_key = session_res['session_key']
    user = User.find_by(
      openid: openid, 
    )
    unless user.present?
      user = User.create!(openid: openid)
    end
    user.openid = openid
    user.session_key = session_key
    user.app_id = permited_params[:app_id]
    user.save!
    return user
  end

  # for jwt, gem knock
  def authenticate(password)
    true
  end

  # for jwt, gem knock
  def to_token_payload
    {
      sub: self.id,
      openid: self.openid,
      name: self.name,
    }
  end

  def create_balance
    Balance.create!(user_id: self.id, fee_rate: 50)
  end
end
