puts "Limpando banco de dados..."
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

puts "Criando usuários..."

ceo = User.create!(
  name: "CEO", email: "ceo@federalcursos.com.br",
  password: "ceo123", cpf: "123.456.789-00", role: :ceo
)

assistente = User.create!(
  name: "Assistente Comercial", email: "assistente@federalcursos.com.br",
  password: "assistente123", cpf: "987.654.321-00",
  role: :assistente_comercial, commission_percent: 10
)

pedagogica = User.create!(
  name: "Equipe Pedagogica", email: "pedagogico@federalcursos.com.br",
  password: "pedagogico123", cpf: "456.789.123-00", role: :equipe_pedagogica
)

pinheiro = User.create!(
  name: "Prof. Pinheiro Neto", email: "professor@federalcursos.com.br",
  password: "prof123", cpf: "321.654.987-00", role: :professor
)

ana = User.create!(
  name: "Prof. Ana Rocha", email: "ana.rocha@federalcursos.com.br",
  password: "ana123", cpf: "741.852.963-00", role: :professor
)

puts "Criando carreiras..."
career_concursos = Career.create!(name: "Concursos Públicos", description: "Preparação para concursos públicos")
career_oab       = Career.create!(name: "OAB",               description: "Exame da OAB")
career_cfc       = Career.create!(name: "CFC",               description: "Conselho Federal de Contabilidade")

puts "Criando cursos..."
course1 = Course.create!(
  title: "Reta Final - Assembleia Legislativa de Rondonia",
  description: "Curso de Reta Final em Resolucao de Questoes para o Concurso da Assembleia Legislativa de Rondonia, modalidade presencial, materias especificas.",
  price_cents: 45300, status: :published, access_type: :hibrido,
  duration_in_days: 33, start_date: "2026-03-01", end_date: "2026-04-03"
)

course2 = Course.create!(
  title: "Preparatorio OAB - 1a Fase",
  description: "Curso completo de preparacao para a primeira fase do Exame da OAB.",
  price_cents: 89000, status: :published, access_type: :hibrido,
  duration_in_days: 90, start_date: "2026-02-01", end_date: "2026-05-01"
)

course3 = Course.create!(
  title: "CFC - Conselho Federal de Contabilidade",
  description: "Preparatorio completo para o exame do CFC.",
  price_cents: 65000, status: :published, access_type: :online,
  duration_in_days: 60, start_date: "2026-04-01", end_date: "2026-06-01"
)

puts "Criando turmas..."
turma1 = Turma.create!(
  course: course1, professor: pinheiro, name: "Turma A - Manha",
  shift: "Manha", start_date: "2026-01-05", end_date: "2026-02-06",
  schedule: "Seg a Sex, 08h00 as 11h15", max_students: 40, status: :em_andamento
)

turma2 = Turma.create!(
  course: course1, professor: ana, name: "Turma B - Tarde",
  shift: "Tarde", start_date: "2026-01-05", end_date: "2026-02-06",
  schedule: "Seg a Sex, 14h30 as 17h45", max_students: 40, status: :em_andamento
)

turma3 = Turma.create!(
  course: course2, professor: pinheiro, name: "Turma OAB 2026.1",
  shift: "Noite", start_date: "2026-02-10", end_date: "2026-05-10",
  schedule: "Seg a Qui, 19h00 as 22h00", max_students: 50, status: :aberta
)

puts "Criando matérias (subjects)..."
subj_port = Subject.create!(course: course1, professor: pinheiro, name: "Lingua Portuguesa",
                             description: "Interpretacao de texto e gramatica", position: 1)
subj_leg  = Subject.create!(course: course1, professor: pinheiro, name: "Legislacao Especifica",
                             description: "Lei Organica do IPERON", position: 2)
subj_log  = Subject.create!(course: course1, professor: ana,      name: "Raciocinio Logico",
                             description: "Logica proposicional e matematica", position: 3)
subj_hist = Subject.create!(course: course1, professor: ana,      name: "Historia e Geografia de RO",
                             description: "Formacao historica de Rondonia", position: 4)

puts "Criando tópicos e aulas..."
topic1 = Topic.create!(subject: subj_port, title: "Interpretacao e Compreensao de texto", position: 1)
topic2 = Topic.create!(subject: subj_port, title: "Pontuacao e sinais graficos", position: 2)
topic3 = Topic.create!(subject: subj_log,  title: "Logica Proposicional", position: 1)

lesson1 = Lesson.create!(topic: topic1, title: "Introducao ao Curso de Texto",
                          duration: "00:24:47", youtube_id: "Pwm3ZrrMhvs", position: 1, available: true)
lesson2 = Lesson.create!(topic: topic1, title: "Compreensao e Interpretacao",
                          duration: "00:33:01", youtube_id: "Pwm3ZrrMhvs", position: 2, available: true)
lesson3 = Lesson.create!(topic: topic1, title: "Coesao e Coerencia Textual",
                          duration: "00:28:15", youtube_id: "Pwm3ZrrMhvs", position: 3, available: true)
lesson4 = Lesson.create!(topic: topic2, title: "Uso da Virgula",
                          duration: "00:41:00", youtube_id: "Pwm3ZrrMhvs", position: 1, available: true)
lesson5 = Lesson.create!(topic: topic2, title: "Ponto, Ponto e Virgula",
                          duration: "00:22:30", youtube_id: "Pwm3ZrrMhvs", position: 2, available: false)
lesson6 = Lesson.create!(topic: topic3, title: "Proposicoes e Conectivos",
                          duration: "00:35:00", youtube_id: "Pwm3ZrrMhvs", position: 1, available: true)

LessonPdf.create!(lesson: lesson1, name: "Resumo — Interpretacao.pdf",   file_size: "2.1 MB")
LessonPdf.create!(lesson: lesson1, name: "Exercicios Resolvidos.pdf",     file_size: "3.4 MB")
LessonPdf.create!(lesson: lesson3, name: "Mapa Mental — Coesao.pdf",     file_size: "1.2 MB")
LessonPdf.create!(lesson: lesson4, name: "Acordo Ortografico — Resumo.pdf", file_size: "0.9 MB")

puts "Criando alunos..."
user_kayke = User.create!(
  name: "Kayke Vinicius", email: "aluno@federalcursos.com.br",
  password: "aluno123", cpf: "111.222.333-44", role: :aluno
)
student1 = Student.create!(
  user: user_kayke, name: "Kayke Vinicius", email: "kaykevini01@gmail.com",
  whatsapp: "(69) 99263-1691", cpf: "111.222.334-44",
  address: "Rua Ernandes Indio, 7121", internal: true
)

user_maria = User.create!(
  name: "Maria Silva Santos", email: "maria.silva@gmail.com",
  password: "maria123", cpf: "555.666.777-88", role: :aluno
)
student2 = Student.create!(
  user: user_maria, name: "Maria Silva Santos", email: "maria.silva@gmail.com",
  whatsapp: "(69) 98877-5544", cpf: "555.666.777-89",
  address: "Av. Jorge Teixeira, 3500", internal: true
)

puts "Criando matrículas..."
enrollment1 = Enrollment.create!(
  student: student1, course: course1, turma: turma1, career: career_concursos,
  status: :active, started_at: "2026-01-05", expires_at: "2026-04-03",
  enrollment_type: :online, payment_method: "Cartao de Credito a vista",
  total_paid_cents: 45300, contract_signed: true
)
enrollment2 = Enrollment.create!(
  student: student2, course: course2, turma: turma3, career: career_oab,
  status: :active, started_at: "2026-02-10", expires_at: "2026-05-10",
  enrollment_type: :online, payment_method: "PIX",
  total_paid_cents: 89000, contract_signed: false
)

puts "Criando eventos..."
Event.create!(
  title: "Aulao de Vespera - Assembleia Legislativa RO",
  description: "Revisao intensiva de todos os conteudos mais cobrados.",
  event_type: :aulao, date: "2026-04-01", start_time: "08:00", end_time: "18:00",
  location: "Auditorio Principal - Federal Cursos", course: course1,
  max_participants: 120, registered_count: 95, status: :agendado
)
Event.create!(
  title: "Simulado Nacional OAB - 1a Fase",
  description: "Simulado completo nos moldes da prova da OAB.",
  event_type: :simulado, date: "2026-04-15", start_time: "09:00", end_time: "14:00",
  location: "Todas as salas - Federal Cursos", course: course2,
  max_participants: 80, registered_count: 42, status: :agendado
)

puts "Criando materiais do professor..."
Material.create!(
  professor: pinheiro, subject: subj_port, title: "Resumo — Interpretacao de Texto",
  material_type: :pdf, file_name: "resumo-interpretacao.pdf", file_size: "2.1 MB"
)
Material.create!(
  professor: ana, subject: subj_log, title: "Slides — Logica Proposicional",
  material_type: :slide, file_name: "slides-logica.pdf", file_size: "3.5 MB"
)

puts "✅ Seeds criados com sucesso!"
puts "Usuários para teste:"
puts "  ceo@federalcursos.com.br        / ceo123"
puts "  professor@federalcursos.com.br  / prof123"
puts "  ana.rocha@federalcursos.com.br  / ana123"
puts "  aluno@federalcursos.com.br      / aluno123"