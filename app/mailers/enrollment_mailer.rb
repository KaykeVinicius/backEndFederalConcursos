class EnrollmentMailer < ApplicationMailer
  default from: "Federal Concursos <noreply@federalconcursos.com.br>"

  def confirmation(enrollment, setup_token: nil, contract: nil)
    @enrollment  = enrollment
    @student     = enrollment.student
    @course      = enrollment.course
    @setup_token = setup_token
    @contract    = contract
    @frontend_url = ENV.fetch("FRONTEND_URL", "http://localhost:3000")
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
