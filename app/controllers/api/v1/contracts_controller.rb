module Api
  module V1
    class ContractsController < ApplicationController
      before_action :set_contract, only: [:show, :update]
      before_action(only: [:create, :update]) { require_role!(:ceo, :diretor, :assistente_comercial) }

      def index
        q = Contract.includes(:enrollment, :student, :course).ransack(params[:q])
        q.sorts = "created_at desc" if q.sorts.empty?
        @contracts = q.result(distinct: true)
        render json: @contracts, each_serializer: ContractSerializer
      end

      def show
        render json: @contract, serializer: ContractSerializer
      end

      def create
        @contract = Contract.new(contract_params)
        if @contract.save
          render json: @contract, serializer: ContractSerializer, status: :created
        else
          render json: { errors: @contract.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @contract.update(contract_params)
          render json: @contract, serializer: ContractSerializer
        else
          render json: { errors: @contract.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_contract
        @contract = Contract.find(params[:id])
      end

      def contract_params
        params.permit(:enrollment_id, :student_id, :course_id, :version,
                      :contract_text, :signed_at, :status, :pdf_url)
      end
    end
  end
end
