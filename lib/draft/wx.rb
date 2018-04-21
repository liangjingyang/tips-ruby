# encoding: utf-8
require 'uri'
require 'net/http'
require 'net/https'
require 'openssl'
require 'base64'
require 'json'

module Draft
  class WX
    class << self
      def get_access_token(code)
        url = "#{DRAFT_CONFIG['wx_api_endpoint']}/sns/oauth2/access_token" +
          "?appid=#{DRAFT_CONFIG['wx_app_id']}" +
          "&secret=#{DRAFT_CONFIG['wx_secret']}" +
          "&code=#{code}" +
          "&grant_type=authorization_code"
        request_get(url)
      end

      def get_user_info(access_token, open_id)
        url = "#{DRAFT_CONFIG['wx_api_endpoint']}/sns/userinfo" +
          "?access_token=#{access_token}" +
          "&openid=#{open_id}"
        request_get(url)
      end

      def get_session_key(js_code)
        url = "#{DRAFT_CONFIG['wx_api_endpoint']}/sns/jscode2session" +
          "?appid=#{DRAFT_CONFIG['wx_app_id']}" +
          "&secret=#{DRAFT_CONFIG['wx_secret']}" +
          "&js_code=#{js_code}" +
          "&grant_type=authorization_code"
        Rails.logger.debug("url: #{url}")
        request_get(url)
      end

      def unified_order(user, order, ip)
        nonce_str = self.random_string
        url = "#{DRAFT_CONFIG['wx_pay_api_endpoint']}/pay/unifiedorder"
        body = {
          'appid' => DRAFT_CONFIG['wx_app_id'],
          'attach' => order.number,
          'mch_id' => DRAFT_CONFIG['wx_mch_id'],
          'openid' => user.openid,
          'nonce_str' => nonce_str,
          'body' => "#{DRAFT_CONFIG['project_name_cn']}-#{DRAFT_CONFIG['product_name_cn']}",
          'out_trade_no' => "#{DRAFT_CONFIG['project_name']}-#{order.number}",
          'total_fee' => order.payment_total,
          'spbill_create_ip' => ip,
          'notify_url' => "https://#{DRAFT_CONFIG['server_host']}#{DRAFT_CONFIG['wx_pay_notify_path']}",
          'trade_type' => 'JSAPI'
        }
        body['sign'] = sign(body)
        puts body
        request_post_xml(url, body)
      end

      def random_string
        [('0'..'9'), ('A'..'Z')].map(&:to_a).flatten.shuffle[0, 16].join
      end

      def decrypt(encrypted_data, iv, user)
        session_key = Base64.decode64(user.session_key)
        encrypted_data= Base64.decode64(encrypted_data)
        iv = Base64.decode64(iv)

        cipher = OpenSSL::Cipher::AES128.new(:CBC)
        cipher.decrypt
        cipher.key = session_key
        cipher.iv = iv
        cipher.padding = 0

        decrypted_plain_text = cipher.update(encrypted_data) + cipher.final
        decrypted = JSON.parse(decrypted_plain_text.strip.gsub(/\u000f|\u0010/, ''))
        # raise('Invalid Buffer') if decrypted['watermark']['appid'] != @app_id

        decrypted
      end

      def check_sign(xml)
        doc = Nokogiri::XML(xml)
        sign_hash = {'check_sign' => false}
        sign1 = ""
        return_code = ''
        doc.xpath('//xml').first.children.each do |arg|
          if arg.name == 'sign'
            sign1 = arg.content
          else
            sign_hash[arg.name] = arg.content if arg.class.name == "Nokogiri::XML::Element"
          end
        end
        if sign_hash['return_code'] == 'SUCCESS'
          sign2 = sign(sign_hash)
          Rails.logger.debug("check sign: sign1: #{sign1}, sign2: #{sign2}")
          sign_hash['check_sign'] = (sign1 == sign2)
        end
        return sign_hash
      end

      private
      def sign(h)
        h = h.sort.to_h
        s = []
        h.each do |key, value|
          s << "#{key}=#{value}"
        end
        s = "#{s.join('&')}&key=#{DRAFT_CONFIG['wx_pay_secret']}"
        puts s
        md5 = Digest::MD5.hexdigest s
        md5.upcase
      end


      def request_get(url)
        uri = URI.parse(url)
        https = Net::HTTP.new(uri.host, uri.port)
        https.use_ssl = true
        https.ssl_timeout = 5
        https.read_timeout = 30
        req = Net::HTTP::Get.new(uri)
        response = https.request(req)
        if !response.present?
          raise StandardError, 'no response'
        elsif response.code != '200'
          raise StandardError, "response #{response.code}"
        end
        res = JSON.parse(response.body)
        if res['errcode'].present?
          raise StandardError, res['errmsg']
        else
          res
        end
      end

      def request_post_xml(url, body)
        uri = URI.parse(url)
        https = Net::HTTP.new(uri.host, uri.port)
        https.use_ssl = true
        https.ssl_timeout = 5
        https.read_timeout = 30
        req = Net::HTTP::Post.new(uri)
        req.body = body.to_xml(root: 'xml', dasherize: false)
        puts req.body
        response = https.request(req)
        if !response.present?
          raise StandardError, 'no response'
        elsif response.code != '200'
          raise StandardError, "response #{response.code}"
        end
        res = Hash.from_xml(response.body)
        if res['xml']['result_code'] == 'FAIL'
          raise StandardError, res['xml']['err_code_des']
        else
          res
        end
      end

      
    end
  end
end