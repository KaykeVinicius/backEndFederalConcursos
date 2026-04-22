class StripeService
  def initialize
    Stripe.api_key = ENV.fetch("STRIPE_SECRET_KEY", "")
  end

  def create_checkout_session(checkout_session:, course:)
    customer = checkout_session.customer_data
    frontend = ENV.fetch("FRONTEND_URL", "https://federalcursos.com.br")

    session = Stripe::Checkout::Session.create({
      payment_method_types: %w[card],
      mode:                 "payment",
      customer_email:       customer["email"],
      client_reference_id:  checkout_session.reference_id,
      metadata: {
        reference_id:  checkout_session.reference_id,
        course_id:     course.id,
        checkout_id:   checkout_session.id,
        customer_name: customer["name"],
        customer_cpf:  customer["cpf"],
        duration_days: checkout_session.duration_days
      },
      line_items: [{
        price_data: {
          currency:     "brl",
          unit_amount:  checkout_session.amount_cents,
          product_data: {
            name:        course.title,
            description: "Federal Cursos — Acesso ao curso #{course.title}"
          }
        },
        quantity: 1
      }],
      success_url: "#{frontend}/pagamento/sucesso?session_id={CHECKOUT_SESSION_ID}",
      cancel_url:  "#{frontend}/pagamento/cancelado"
    })

    { status: 200, url: session.url, stripe_session_id: session.id }
  rescue Stripe::StripeError => e
    Rails.logger.error("Stripe error: #{e.message}")
    { status: 422, error: e.message }
  end
end
