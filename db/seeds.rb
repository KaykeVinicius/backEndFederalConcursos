puts "Limpando banco de dados..."
AccessLog.destroy_all
LessonCompletion.destroy_all
Question.destroy_all
Material.destroy_all
LessonPdf.destroy_all
Lesson.destroy_all
Topic.destroy_all
Subject.destroy_all
Contract.destroy_all
Enrollment.destroy_all
Event.destroy_all
Turma.destroy_all
Course.destroy_all
Career.destroy_all
Student.destroy_all
User.destroy_all

puts "Criando usuário CEO..."

User.create!(
  name: "Federal Cursos", email: "federal@federalcursos.com",
  password: "Federal@2634", cpf: "55.703.401/0001-08", role: :ceo
)

puts "✅ Pronto!"
puts "  federal@federalcursos.com / Federal@2634"