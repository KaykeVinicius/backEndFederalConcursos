module Api
  module V1
    module Professor
      class SubjectsController < ApplicationController
        before_action :require_professor!

        def index
          @subjects = Subject.where(professor_id: current_user.id).order(:name)
          render json: @subjects.map { |s| { id: s.id, name: s.name, professor_id: s.professor_id, course_id: s.course_id } }
        end
      end
    end
  end
end
