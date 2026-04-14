class AccessLog < ApplicationRecord
  belongs_to :user

  scope :recent, -> { order(created_at: :desc) }

  def self.ransackable_attributes(auth_object = nil)
    %w[action success ip_address device browser created_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[user]
  end

  # Extrai informações básicas do User-Agent
  def self.parse_device(user_agent)
    ua = user_agent.to_s.downcase
    if ua.match?(/mobile|android|iphone|ipad/)
      ua.match?(/ipad/) ? "Tablet" : "Mobile"
    else
      "Desktop"
    end
  end

  def self.parse_browser(user_agent)
    ua = user_agent.to_s
    return "Chrome"  if ua.match?(/Chrome/)  && !ua.match?(/Edg|OPR/)
    return "Firefox" if ua.match?(/Firefox/)
    return "Safari"  if ua.match?(/Safari/)  && !ua.match?(/Chrome/)
    return "Edge"    if ua.match?(/Edg/)
    return "Opera"   if ua.match?(/OPR/)
    "Outro"
  end
end
