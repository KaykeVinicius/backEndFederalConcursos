class EventSubjectSerializer < ActiveModel::Serializer
  attributes :id, :subject_id, :subject_name

  def subject_name
    object.subject&.name
  end
end
