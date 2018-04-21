module ResponseCode
  def response_sym_to_code(sym)
    RESPONSE_CODES.maybe[sym.to_s]['code'].just || 500001
  end

  def response_sym_to_message(sym)
    RESPONSE_CODES.maybe[sym.to_s]['message'].just || 
    "Response code undefined: #{sym}" 
  end

  def response_sym_to_status(sym)
    RESPONSE_CODES.maybe[sym.to_s]['status'].just || 500
  end

  def response_sym_to_hash(sym, message = nil)
    res = RESPONSE_CODES.maybe[sym.to_s].just || {
      status: 500,
      code: 500001, 
      message: "Response code undefined: #{sym}",
    }
    res[:message] = message if message.present?
    res
  end
end