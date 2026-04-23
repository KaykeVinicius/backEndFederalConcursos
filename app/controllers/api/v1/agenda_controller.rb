module Api
  module V1
    # GET /api/v1/agenda?start=YYYY-MM-DD&end=YYYY-MM-DD
    # Retorna eventos unificados: aulas presenciais e eventos (aulões/simulados)
    # O resultado é filtrado conforme o papel do usuário autenticado:
    #   - CEO / Diretor / Equipe Pedagógica → tudo
    #   - Professor  → apenas class_days das suas turmas (professor_id ou turma.professor_id)
    #   - Aluno      → apenas class_days das turmas em que está matriculado (ativo)
    class AgendaController < ApplicationController
      def index
        start_date = parse_date(params[:start]) || Date.current.beginning_of_month
        end_date   = parse_date(params[:end])   || Date.current.end_of_month

        items = []

        # 1. Eventos (aulões e simulados) — visíveis para todos
        Event.where(date: start_date..end_date)
             .includes(:course)
             .each do |ev|
          items << {
            id:               "event_#{ev.id}",
            type:             "event",
            event_type:       ev.event_type,
            title:            ev.title,
            date:             ev.date,
            start_time:       ev.start_time,
            end_time:         ev.end_time,
            location:         ev.location,
            status:           ev.status,
            course_name:      ev.course&.title,
            is_free:          ev.is_free,
            registered_count: ev.registered_count,
            max_participants: ev.max_participants,
          }
        end

        # 2. Aulas presenciais — filtradas por papel
        class_days_scope(start_date, end_date).each do |cd|
          prof = cd.effective_professor
          items << {
            id:           "class_day_#{cd.id}",
            type:         "class_day",
            title:        cd.title.presence || "#{cd.subject&.name} — #{cd.turma&.name}",
            date:         cd.date,
            start_time:   cd.start_time&.strftime("%H:%M"),
            end_time:     cd.end_time&.strftime("%H:%M"),
            location:     nil,
            turma_name:   cd.turma&.name,
            course_name:  cd.turma&.course&.title,
            subject_name: cd.subject&.name,
            professor_id:   prof&.id,
            professor_name: prof&.name,
            description:  cd.description,
          }
        end

        # Ordena por data e hora
        items.sort_by! { |i| [i[:date].to_s, i[:start_time].to_s] }

        render json: items
      end

      private

      def class_days_scope(start_date, end_date)
        base = TurmaClassDay.where(date: start_date..end_date)
                            .includes(:subject, :professor, turma: [:course, :professor])

        case current_user.role
        when "professor"
          # ?all=true → professor vê todas as aulas (visão geral da semana)
          return base if params[:all] == "true"

          # Padrão: apenas as aulas do próprio professor
          # 3 formas de vínculo: diretamente na aula, via turma, ou via matéria
          prof_subject_ids = ProfessorSubject.where(professor_id: current_user.id).pluck(:subject_id)
          base.joins(:turma).left_joins(:subject).where(
            "(turma_class_days.professor_id = :uid) OR " \
            "(turma_class_days.professor_id IS NULL AND turmas.professor_id = :uid) OR " \
            "(turma_class_days.professor_id IS NULL AND subjects.id IN (:sids))",
            uid: current_user.id, sids: prof_subject_ids.presence || [0]
          )

        when "aluno"
          # Turmas em que o aluno tem matrícula ativa (suporte a múltiplos student records)
          student_ids = Student.where(user_id: current_user.id).pluck(:id)
          return TurmaClassDay.none if student_ids.empty?

          turma_ids = Enrollment.where(student_id: student_ids, status: :active)
                                .where.not(turma_id: nil)
                                .pluck(:turma_id)
          base.where(turma_id: turma_ids)

        else
          # CEO, Diretor, Equipe Pedagógica — tudo
          base
        end
      end

      def parse_date(str)
        Date.parse(str) rescue nil
      end
    end
  end
end
