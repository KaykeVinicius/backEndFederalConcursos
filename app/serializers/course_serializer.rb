class CourseSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :price, :status, :access_type,
             :duration_in_days, :start_date, :end_date, :created_at, :career_id, :online_url

  belongs_to :career, serializer: CareerSerializer, optional: true
end