class WxController < ApplicationController
  before_action :authenticate_user, except: [:notify_unified_order]

  def notify_unified_order
    begin
      xml = request.body.read
      Rails.logger.debug("notify_unified_order === , request.body: #{xml}")
      sign_hash = Draft::WX.check_sign(xml)
      if sign_hash['check_sign']
        order_number = sign_hash['attach']
        order = Order.find_by(number: order_number)
        if order.present? && order.payment_total == sign_hash['total_fee']
          order.transaction_id = sign_hash['transaction_id']
          order.next! if order.paying?
          return_code = 'SUCCESS'
          return_msg = 'OK'
        else
          return_code = 'FAIL'
          return_msg = '参数格式校验错误'
        end
      else
        return_code = 'FAIL'
        return_msg = '签名失败'
      end
      @ret = {'return_code' => return_code, 'return_msg' => return_msg}.to_xml(root: 'xml', dasherize: false)
    rescue Exception => e
      @ret = {'return_code' => 'FAIL', 'return_msg' => e.message}.to_xml(root: 'xml', dasherize: false)
    end
    render plain: @ret
  end

end
