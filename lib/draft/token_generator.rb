require 'openssl'
require 'securerandom'

module Draft 
  class TokenGenerator
    mattr_accessor :key_generator
    @@key_generator ||= ActiveSupport::CachingKeyGenerator.new(
      ActiveSupport::KeyGenerator.new(DRAFT_CONFIG['token_generator_key'])) 

    def initialize(digest = "SHA256")
      @digest = digest
    end

    def digest(klass, column, value)
      value.present? && OpenSSL::HMAC.hexdigest(@digest, key_for(klass, column), value.to_s)
    end

    def generate(klass, column)
      key = key_for(klass, column)

      loop do
        raw = friendly_token
        enc = OpenSSL::HMAC.hexdigest(@digest, key, raw)
        break [raw, enc] unless klass.exists?({ column => enc })
      end
    end

    private

    def key_for(klass, column)
      @@key_generator.generate_key("#{klass.name} #{column}")
    end

    # Generate a friendly string randomly to be used as token.
    # By default, length is 20 characters.
    def friendly_token(length = 20)
        # To calculate real characters, we must perform this operation.
        # See SecureRandom.urlsafe_base64
        rlength = (length * 3) / 4
        SecureRandom.urlsafe_base64(rlength).tr('lIO0', 'sxyz')
    end
  end

  TOKEN_GENERATOR ||= Draft::TokenGenerator.new
end