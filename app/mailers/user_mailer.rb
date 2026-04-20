class UserMailer < ApplicationMailer
  default from: "Federal Cursos <federall@federalcursos.com.br>"

  def reset_password_email(user, reset_url)
    @user      = user
    @reset_url = reset_url
    mail(to: user.email, subject: "Redefinição de senha — Federal Cursos")
  end
end
