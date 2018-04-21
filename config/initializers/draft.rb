DRAFT_CONFIG = Rails.application.config_for :draft
RESPONSE_CODES = Rails.application.config_for :response_codes
def CACHE_JWT(id)
   "CACHE_JWT_#{id}"
end
# logger
def LOG_DEBUG(message, *tags)
  Rails.logger.tagged('== DEBUG ==', Time.now, tags) {Rails.logger.debug {message}}
end

def LOG_ERROR(message, *tags)
  Rails.logger.tagged('== ERROR ==', Time.now, tags) {Rails.logger.error {message}}
end