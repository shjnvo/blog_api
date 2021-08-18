class JwtService
  HMAC_SECRET = Rails.application.secrets.secret_key_base
  HASH_ALGORITHM = 'HS256'
  EXPIRATION = 24.hours

  class << self
    def encode payload
      payload[:exp] ||= EXPIRATION.from_now.to_i
      JWT.encode(payload, HMAC_SECRET, HASH_ALGORITHM)
    rescue => e
      Rails.logger.error e.message
      nil
    end

    def decode token
      body = JWT.decode(token, HMAC_SECRET, true, { algorithm: 'HS256' }).first
      HashWithIndifferentAccess.new body
    rescue => e
      Rails.logger.error e.message
      {}
    end
  end
end