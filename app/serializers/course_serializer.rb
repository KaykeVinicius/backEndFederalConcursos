class CourseSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :price, :status, :access_type,
             :duration_in_days, :start_date, :end_date, :created_at, :career_id,
             :online_url, :workload_hours, :cover_image_url

  belongs_to :career, serializer: CareerSerializer, optional: true

  def cover_image_url
    return nil unless object.cover_image.attached?
    host = ENV.fetch("RAILS_HOST_POC", ENV.fetch("RAILS_HOST", "http://localhost:3003"))
    Rails.application.routes.url_helpers.rails_blob_url(object.cover_image, host: host)
  end
end