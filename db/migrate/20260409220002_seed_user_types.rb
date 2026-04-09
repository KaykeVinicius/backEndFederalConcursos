class SeedUserTypes < ActiveRecord::Migration[8.0]
  TYPES = [
    { name: "CEO",                  slug: "ceo",                   description: "Acesso total ao sistema",                          position: 0 },
    { name: "Diretor",              slug: "diretor",               description: "Gestão e relatórios gerais",                       position: 1 },
    { name: "Equipe Pedagógica",    slug: "equipe_pedagogica",     description: "Gestão de eventos, cursos e conteúdo",             position: 2 },
    { name: "Assistente Comercial", slug: "assistente_comercial",  description: "Vendas, matrículas e atendimento ao aluno",        position: 3 },
    { name: "Professor",            slug: "professor",             description: "Upload de materiais, resposta de dúvidas",         position: 4 },
    { name: "Aluno",                slug: "aluno",                 description: "Acesso ao conteúdo e eventos inscritos",           position: 5 },
  ].freeze

  def up
    TYPES.each do |t|
      ut = UserType.create!(t)
      # Relaciona usuários existentes com seu user_type
      User.where(role: t[:slug]).update_all(user_type_id: ut.id)
    end
  end

  def down
    UserType.delete_all
    User.update_all(user_type_id: nil)
  end
end
