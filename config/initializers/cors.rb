Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "https://federalcursos.com.br",
            "https://www.federalcursos.com.br",
            "https://poc.federalcursos.com.br"

    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ["Authorization"]
  end
end
