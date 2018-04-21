class UriParser
  attr_reader :user, :uri, :code, :message, :uri_type
  def initialize(user, uri)
    @user = user
    uri = uri || ''
    @uri = URI.parse(URI.unescape(uri))
    @code = 0
  end

  def parse
    if follow_box_uri?
      parse_follow_box_uri
    else
      @code = 101
      @message = '解析失败'
    end
  end

  def parse_follow_box_uri
    begin
      @uri_type = "follow_box"
      query_params = parse_params
      qrcode_token = query_params['qrcode_token']
      box = Box.find_by(qrcode_token: qrcode_token)
      if box.user_id != @user.id
        box_follower = BoxFollower.find_by(user_id: @user.id, box_id: box.id)
        if box_follower.present?
          if !box_follower.allowed
            @code = 104
            @message = '已关注, 但没有权限查看该产品册, 请联系册主'
          else
            @code = 105
            @message = '已关注'
          end
        else
          BoxFollower.create!(user_id: @user.id, box_id: box.id)
          @code = 0
          @message = '关注成功'
        end
      else
        @code = 103
        @message = '不能关注自己的产品册'
      end
      
    rescue
      @code = 102
      @message = '关注失败'
    end
  end

  def follow_box_uri?
    scheme_and_host? && 
    @uri.path == '/uri/follow_box' && 
    @uri.query.present?
  end

  def parse_params
    query_params = URI.decode_www_form(@uri.query)
    Hash[query_params]
  end 

  def scheme_and_host?
    @uri.scheme == 'https' && @uri.host == DRAFT_CONFIG['server_host']
  end
end
