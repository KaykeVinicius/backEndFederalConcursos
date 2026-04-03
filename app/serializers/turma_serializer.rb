class TurmaSerializer < ActiveModel::Serializer
  attributes :id, :name, :shift, :start_date, :end_date, :schedule,
             :max_students, :status, :modalidade, :course_id, :professor_id, :created_at

  attribute :enrolled_count
  belongs_to :course,    serializer: CourseSerializer
  belongs_to :professor, serializer: UserSerializer
end