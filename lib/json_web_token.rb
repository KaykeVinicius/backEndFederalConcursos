module JsonWebToken
  SECRET_KEY = ENV.fetch("JWT_SECRET", "federal_concursos_dev_secret")
  EXPIRATION = ENV.fetch("JWT_EXPIRATION_HOURS", "168").to_i.hours

  def self.encode(payload)
    payload[:exp] = EXPIRATION.from_now.to_i
    JWT.encode(payload, SECRET_KEY, "HS256")
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: "HS256" })
    HashWithIndifferentAccess.new(decoded[0])
  rescue JWT::DecodeError => e
    raise e
  end
end