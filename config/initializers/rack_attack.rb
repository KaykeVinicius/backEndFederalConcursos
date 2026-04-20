class Rack::Attack
  self.throttled_responder = lambda do |request|
    [
      429,
      { "Content-Type" => "application/json" },
      [{ error: "Muitas tentativas. Aguarde alguns minutos antes de tentar novamente." }.to_json]
    ]
  end

  # Throttle geral: 300 requisições por IP a cada 5 minutos
  throttle("req/ip", limit: 300, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?("/rails/active_storage")
  end

  # Throttle login por IP: 10 tentativas por minuto
  throttle("login/ip", limit: 10, period: 60.seconds) do |req|
    req.ip if req.path == "/api/v1/auth/login" && req.post?
  end

  # Throttle login por e-mail: 15 tentativas por 20 minutos
  throttle("login/email", limit: 15, period: 20.minutes) do |req|
    if req.path == "/api/v1/auth/login" && req.post?
      body = req.body.read
      req.body.rewind
      begin
        params = JSON.parse(body)
        params["email"].to_s.downcase.presence
      rescue
        nil
      end
    end
  end

  # Bloqueia user-agents suspeitos de scanners
  blocklist("block/scanners") do |req|
    req.user_agent.to_s.match?(/sqlmap|nikto|nmap|masscan|zgrab|dirbuster/i)
  end
end
