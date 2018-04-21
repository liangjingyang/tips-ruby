require 'bcrypt'

module Draft 
  module Encryptor
    def self.digest(klass, password)
      password = "#{password}#{DRAFT_CONFIG['encryptor_pepper']}"
      ::BCrypt::Password.create(password, cost: DRAFT_CONFIG['encryptor_stretches']).to_s
    end

    def self.compare(klass, hashed_password, password)
      return false if hashed_password.blank?
      bcrypt   = ::BCrypt::Password.new(hashed_password)
      password = "#{password}#{DRAFT_CONFIG['encryptor_pepper']}"
      password = ::BCrypt::Engine.hash_secret(password, bcrypt.salt)
      self.secure_compare(password, hashed_password)
    end

    def self.secure_compare(a, b)
      return false if a.blank? || b.blank? || a.bytesize != b.bytesize
      l = a.unpack "C#{a.bytesize}"

      res = 0
      b.each_byte { |byte| res |= byte ^ l.shift }
      res == 0
    end
  end
end