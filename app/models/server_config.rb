class ServerConfig
  attr_reader :ads_counter_interval_for_thanks
  attr_reader :ads_counter_max_count_for_thanks
  attr_reader :ads_counter_pay_interval_for_thanks
  attr_reader :notice
  attr_reader :ads_counter_max_count_for_post

  def initialize
    @ads_counter_interval_for_thanks = 86400
    @ads_counter_max_count_for_thanks = 30
    @ads_counter_pay_interval_for_thanks = 259200
    @ads_counter_max_count_for_post = 30
  end
end