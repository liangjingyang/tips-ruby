module Draft
  class Qiniu
    def self.generate_uptoken(prefix='tmp')
      # 要上传的空间
      bucket = DRAFT_CONFIG['qiniu_bucket']
      # @upkey = "#{current_user.id}/#{@box.id}/"
      # 上传到七牛后保存的文件名
      # 构建上传策略，上传策略的更多参数请参照 http://developer.qiniu.com/article/developer/security/put-policy.html
      put_policy = ::Qiniu::Auth::PutPolicy.new(
          bucket, # 存储空间
          nil,
          300    # token 过期时间，默认为 3600 秒，即 1 小时
      )
      put_policy.is_prefixal_scope = 1
      # put_policy.mime_limit = "image/jpeg;image/png"
      put_policy.save_key = "#{Rails.env}/#{prefix}/$(etag)$(ext)"
      ::Qiniu::Auth.generate_uptoken(put_policy)
    end

    def self.upload(buf, prefix='qrcode')
      bucket = DRAFT_CONFIG['qiniu_bucket']
      uptoken = generate_uptoken
      code, result, response_headers = ::Qiniu::Storage.upload_buffer_with_token(
        uptoken,
        buf,
        nil,
        nil, # 可以接受一个 Hash 作为自定义变量，请参照 http://developer.qiniu.com/article/kodo/kodo-developer/up/vars.html#xvar
        bucket: bucket
      )
      return code, result
    end
  end
end
