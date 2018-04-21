json.data do
  json.prepay_id @prepay_id
  json.mch_id DRAFT_CONFIG['wx_mch_id']
  json.secret DRAFT_CONFIG['wx_pay_secret']
  json.nonce_str @nonce_str
end