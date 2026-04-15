module Api
  module V1
    # GET /api/v1/dashboard
    # Retorna todos os dados agregados para o painel do CEO / Diretor
    class DashboardController < ApplicationController
      def index
        require_role!(:ceo, :diretor, :equipe_pedagogica)

        now        = Time.current
        month_start     = now.beginning_of_month
        quarter_start   = now.beginning_of_quarter
        year_start      = now.beginning_of_year

        # ── Matrículas ────────────────────────────────────────────
        all_enrollments   = Enrollment.includes(:course)
        active_count      = all_enrollments.where(status: :active).count
        total_count       = all_enrollments.count

        revenue_total     = all_enrollments.sum(:total_paid_cents).to_f / 100
        revenue_month     = all_enrollments.where("started_at >= ?", month_start).sum(:total_paid_cents).to_f / 100
        revenue_quarter   = all_enrollments.where("started_at >= ?", quarter_start).sum(:total_paid_cents).to_f / 100
        revenue_year      = all_enrollments.where("started_at >= ?", year_start).sum(:total_paid_cents).to_f / 100

        avg_per_enrollment = total_count > 0 ? (revenue_total / total_count).round(2) : 0

        # Modalidade — usa o enrollment_type da própria matrícula
        modality_presencial = all_enrollments.where(enrollment_type: :presencial).count
        modality_online     = all_enrollments.where(enrollment_type: :online).count
        modality_hibrido    = all_enrollments.where(enrollment_type: :hibrido).count

        # ── Alunos ────────────────────────────────────────────────
        total_students  = Student.count
        active_students = Student.where(active: true).count

        # ── Cursos / Turmas / Eventos ─────────────────────────────
        total_courses  = Course.count
        total_turmas   = Turma.count
        total_events   = Event.count
        upcoming_events = Event.where(status: "agendado").count

        # ── Gráfico: matrículas e receita por curso ───────────────
        courses_chart = Course.left_joins(:enrollments)
          .select(
            "courses.id",
            "courses.title AS name",
            "COUNT(enrollments.id) AS matriculas",
            "COALESCE(SUM(enrollments.total_paid_cents), 0) / 100.0 AS receita"
          )
          .group("courses.id", "courses.title")
          .order("matriculas DESC")
          .map { |r| { id: r.id, name: r.name, matriculas: r.matriculas.to_i, receita: r.receita.to_f.round(2) } }

        # ── Gráfico: matrículas por carreira ──────────────────────
        careers_chart = Career.left_joins(:enrollments)
          .select(
            "careers.id",
            "careers.name",
            "COUNT(enrollments.id) AS matriculas"
          )
          .group("careers.id", "careers.name")
          .order("matriculas DESC")
          .map { |r| { id: r.id, name: r.name, matriculas: r.matriculas.to_i } }

        # ── Matrículas por mês (últimos 12 meses) ─────────────────
        monthly_chart = (11.downto(0)).map do |i|
          month = i.months.ago.beginning_of_month
          label = month.strftime("%b/%y")
          count = all_enrollments.where("started_at >= ? AND started_at < ?", month, month + 1.month).count
          rev   = all_enrollments.where("started_at >= ? AND started_at < ?", month, month + 1.month)
                                 .sum(:total_paid_cents).to_f / 100
          { month: label, matriculas: count, receita: rev.round(2) }
        end

        render json: {
          # KPIs
          revenue: {
            total:    revenue_total.round(2),
            month:    revenue_month.round(2),
            quarter:  revenue_quarter.round(2),
            year:     revenue_year.round(2),
            avg_per_enrollment: avg_per_enrollment,
          },
          enrollments: {
            total:  total_count,
            active: active_count,
          },
          students: {
            total:  total_students,
            active: active_students,
          },
          modality: {
            presencial: modality_presencial,
            online:     modality_online,
            hibrido:    modality_hibrido,
          },
          courses:        total_courses,
          turmas:         total_turmas,
          events:         total_events,
          upcoming_events: upcoming_events,

          # Gráficos
          charts: {
            courses:  courses_chart,
            careers:  careers_chart,
            monthly:  monthly_chart,
          },
        }
      end
    end
  end
end
