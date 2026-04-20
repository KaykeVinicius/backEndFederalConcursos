require "net/http"
require "json"

class NupayService
  SANDBOX_URL = "https://sandbox-api.spinpay.com.br/v1/checkouts/payments"
  PROD_URL    = "https://api.spinpay.com.br/v1/checkouts/payments"

  def initialize
    @merchant_key   = ENV.fetch("NUPAY_MERCHANT_KEY", "")
    @merchant_token = ENV.fetch("NUPAY_MERCHANT_TOKEN", "")
    @sandbox        = ENV.fetch("NUPAY_SANDBOX", "true") == "true"
    @base_url       = @sandbox ? SANDBOX_URL : PROD_URL
    @callback_url   = ENV.fetch("NUPAY_CALLBACK_URL", "#{ENV.fetch('BACKEND_URL', 'http://localhost:3001')}/api/v1/webhooks/nupay")
  end

  def create_payment(checkout_session:, course:)
    customer = checkout_session.customer_data
    phone    = customer["whatsapp"].to_s.gsub(/\D/, "")

    body = {
      merchantOrderReference: checkout_session.merchant_order_reference,
      referenceId:            checkout_session.reference_id,
      amount: {
        currency: "BRL",
        value:    checkout_session.amount_cents
      },
      shopper: {
        reference:    checkout_session.reference_id,
        firstName:    customer["name"].to_s.split.first,
        lastName:     customer["name"].to_s.split[1..].join(" "),
        document:     customer["cpf"].to_s.gsub(/\D/, ""),
        documentType: "CPF",
        email:        customer["email"],
        phone: {
          country: "55",
          number:  phone.length >= 11 ? phone[2..] : phone
        },
        locale: "pt-BR"
      },
      billingAddress: {
        country:      "BRA",
        street:       customer["street"],
        number:       customer["number"],
        complement:   customer["complement"].presence || "",
        neighborhood: customer["neighborhood"],
        postalCode:   customer["postal_code"].to_s.gsub(/\D/, ""),
        city:         customer["city"],
        state:        customer["state"]
      },
      items: [
        {
          id:          course.id.to_s,
          description: course.title,
          quantity:    1,
          amountEach:  checkout_session.amount_cents
        }
      ],
      paymentMethod: { type: "nupay" },
      callbackUrl:   @callback_url,
      delayToAutoCancel: 30
    }

    response = post(@base_url, body)
    response
  end

  def get_status(psp_reference_id)
    url = "#{@base_url}/#{psp_reference_id}/status"
    get(url)
  end

  private

  def headers
    {
      "Content-Type"     => "application/json",
      "X-Merchant-Key"   => @merchant_key,
      "X-Merchant-Token" => @merchant_token
    }
  end

  def post(url, body)
    uri  = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    req = Net::HTTP::Post.new(uri.path, headers)
    req.body = body.to_json
    parse(http.request(req))
  end

  def get(url)
    uri  = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    req = Net::HTTP::Get.new(uri.path, headers)
    parse(http.request(req))
  end

  def parse(response)
    body = JSON.parse(response.body) rescue {}
    { status: response.code.to_i, body: body }
  end
end
