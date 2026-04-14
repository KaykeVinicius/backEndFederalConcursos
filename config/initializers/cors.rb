#Rails.application.config.middleware.insert_before 0, Rack::Cors do
#  allow do
#    origins "http://localhost:3000", "http://127.0.0.1:3000", "http://10.7.3.70:3000",
#            ENV.fetch("FRONTEND_URL", ""),
#            /https:\/\/.*\.serveousercontent\.com/,
#            /https:\/\/.*\.loca\.lt/,
#            /https:\/\/.*\.trycloudflare\.com/

#    resource "*",
#      headers: :any,
#      methods: [:get, :post, :put, :patch, :delete, :options, :head],
#      expose: ["Authorization"]
#  end
#end

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "http://localhost:3000",
            "http://127.0.0.1:3000",
            "http://10.7.3.70:3000",
            "http://192.168.100.66:3000",
            ENV.fetch("FRONTEND_URL", ""),
            /https:\/\/.*\.serveousercontent\.com/,
            /https:\/\/.*\.loca\.lt/,
            /https:\/\/.*\.trycloudflare\.com/

    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ["Authorization"]
  end
end