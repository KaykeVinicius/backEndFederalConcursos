module Api
  module V1
    module Professor
      class SubjectsController < ApplicationController
        before_action :require_professor!

        def index
          @subjects = current_user.subjects_taught.order(:name)
          render json: @subjects.map { |s| { id: s.id, name: s.name, course_id: s.course_id } }
        end
      end
    end
  end
end
