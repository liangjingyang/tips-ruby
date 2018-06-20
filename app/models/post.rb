class Post < ApplicationRecord

  belongs_to :box, touch: true, class_name: 'Box', inverse_of: :posts
  scope :with_includes, -> { includes(:box) }

  def images
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

end
