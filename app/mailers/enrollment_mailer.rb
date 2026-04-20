class EnrollmentMailer < ApplicationMailer
  default from: "Federal Cursos <federall@federalcursos.com.br>"

  def confirmation(enrollment, setup_token: nil, contract: nil)
    @enrollment  = enrollment
    @student     = enrollment.student
    @course      = enrollment.course
    @setup_token = setup_token
    @contract    = contract
    @frontend_url = Rails.env.development? \
      ? ENV.fetch("FRONTEND_URL_POC", "http://localhost:3000") \
      : ENV.fetch("FRONTEND_URL", "http://localhost:3000")
    @portal_url  = if setup_token
      "#{@frontend_url}/criar-senha?token=#{setup_token}"
    end
    @contract_url = if contract
      "#{@frontend_url}/aluno/meus-cursos"
    end

    mail(
      to:      @student.email,
      subject: "[Federal Concursos] Matrícula confirmada — #{@course.title}"
    )
  end
end
