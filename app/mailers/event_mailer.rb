class EventMailer < ApplicationMailer
  default from: "Federal Concursos <noreply@federalconcursos.com.br>"

  def ticket(registration)
    @registration = registration
    @event        = registration.event
    @student      = registration.student
    @token        = registration.ticket_token
    @checkin_url  = "#{ENV.fetch('FRONTEND_URL', 'http://localhost:3000')}/ceo/eventos/checkin/#{@token}"

    # Gera QR code como PNG e anexa inline
    qr_png = RQRCode::QRCode.new(@checkin_url).as_png(
      bit_depth: 1,
      border_modules: 4,
      color_name: :black,
      fill: "white",
      module_px_size: 6
    )
    attachments.inline["qrcode.png"] = qr_png.to_s
    @qr_cid = attachments["qrcode.png"].url

    mail(
      to:      @student.email,
      subject: "[Federal Concursos] Seu ingresso — #{@event.title}"
    )
  end
end
