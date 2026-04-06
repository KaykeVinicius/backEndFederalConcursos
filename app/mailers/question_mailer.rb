class QuestionMailer < ApplicationMailer
  default from: "Federal Concursos <noreply@federalconcursos.com.br>"

  # Notifica o professor que uma nova dúvida foi enviada
  def new_question(question)
    @question  = question
    @professor = question.professor
    @student   = question.student
    @lesson    = question.lesson
    @subject   = question.subject

    mail(
      to:      @professor.email,
      subject: "[Federal Concursos] Nova dúvida — #{@subject.name}"
    )
  end

  # Notifica o aluno que sua dúvida foi respondida
  def question_answered(question)
    @question  = question
    @professor = question.professor
    @student   = question.student
    @lesson    = question.lesson
    @subject   = question.subject

    mail(
      to:      @student.email,
      subject: "[Federal Concursos] Sua dúvida foi respondida — #{@subject.name}"
    )
  end
end
