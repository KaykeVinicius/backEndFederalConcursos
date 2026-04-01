module Api
  module V1
    class LessonPdfsController < ApplicationController
      before_action :set_lesson_pdf, only: [:destroy]

      def index
        @pdfs = LessonPdf.where(lesson_id: params[:lesson_id])
        render json: @pdfs, each_serializer: LessonPdfSerializer
      end

      def create
        @pdf = LessonPdf.new(pdf_params)
        if @pdf.save
          render json: @pdf, serializer: LessonPdfSerializer, status: :created
        else
          render json: { errors: @pdf.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @pdf.destroy
        head :no_content
      end

      private

      def set_lesson_pdf
        @pdf = LessonPdf.find(params[:id])
      end

      def pdf_params
        params.permit(:lesson_id, :name, :file_size, :file_url)
      end
    end
  end
end
