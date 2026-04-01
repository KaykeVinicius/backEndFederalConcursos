class QuestionSerializer < ActiveModel::Serializer
  attributes :id, :text, :video_moment, :status, :answer,
             :answered_at, :created_at, :student_id, :professor_id,
             :lesson_id, :subject_id

  belongs_to :student,   serializer: StudentSerializer
  belongs_to :professor, serializer: UserSerializer
  belongs_to :lesson,    serializer: LessonSerializer
  belongs_to :subject,   serializer: SubjectSerializer
end