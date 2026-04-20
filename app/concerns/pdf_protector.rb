module PdfProtector
  extend ActiveSupport::Concern

  # Retorna um Tempfile com o PDF protegido com senha (CPF) e marca d'água.
  # O caller é responsável por chamar close! no Tempfile após o uso.
  def build_protected_pdf(original_path:, student_name:, student_cpf:)
    password       = student_cpf.gsub(/\D/, "")
    watermark_text = "#{student_name}  |  CPF: #{student_cpf}"

    protected_pdf = Tempfile.new(["pdf_protected", ".pdf"], binmode: true)

    HexaPDF::Document.open(original_path, decryption_opts: { password: "" }) do |doc|
      doc.pages.each do |page|
        media = page.box(:media)
        next unless media

        width  = media.width.to_f
        height = media.height.to_f
        canvas = page.canvas(type: :overlay)

        # ── Cabeçalho centralizado: nome + CPF no topo de cada página ──
        canvas.save_graphics_state do
          font_size = 9
          canvas.font("Helvetica", size: font_size)
          canvas.fill_color(0, 0, 0)
          canvas.opacity(fill_alpha: 0.75)

          # Largura aproximada: Helvetica ~5.2pt por caractere a 9pt
          text_width = watermark_text.length * 5.2
          x = [(width - text_width) / 2.0, 10].max

          canvas.text(watermark_text, at: [x, height - 14])
        end

        # ── Marca d'água diagonal repetida centralizada no fundo ────────
        canvas.save_graphics_state do
          canvas.font("Helvetica", size: 12)
          canvas.fill_color(0, 0, 0)
          canvas.opacity(fill_alpha: 0.07)

          angle = Math::PI / 5   # ~36 graus
          cos_a = Math.cos(angle)
          sin_a = Math.sin(angle)

          step_x = 230
          step_y = 120

          # Centraliza o padrão na página
          cols = (width  / step_x).ceil + 2
          rows = (height / step_y).ceil + 2

          (-(rows / 2 + 1)..(rows / 2 + 1)).each do |row|
            (-(cols / 2 + 1)..(cols / 2 + 1)).each do |col|
              tx = width  / 2.0 + col * step_x
              ty = height / 2.0 + row * step_y

              canvas.save_graphics_state do
                canvas.transform(cos_a, sin_a, -sin_a, cos_a, tx, ty)
                canvas.text(watermark_text, at: [0, 0])
              end
            end
          end
        end
      end

      doc.encrypt(
        owner_password: SecureRandom.hex(16),
        user_password:  password,
        permissions:    [:print],
        algorithm:      :aes,
        key_length:     128
      )
      doc.write(protected_pdf.path, optimize: true)
    end

    protected_pdf
  end
end
