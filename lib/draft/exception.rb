module Draft
  module Exception
    class UserUnauthorized < StandardError; end
    class AdminUnauthorized < StandardError; end
    class StockError < StandardError; end
  end
end