module Api
  module V1
    class CarsController < ApplicationController
      before_action :set_user, only: [ :index ]

      def index
        result = Api::Cars::IndexInteractor.new(@user, allowed_params.to_h).call

        if result.success?
          render json: serialize_collection(result.value!),
                 status: :ok
        else
          render json: result.failure,
                 status: :unprocessable_entity
        end
      end

      private

      def set_user
        @user ||= User.find(params[:user_id])
      end

      def serialize_collection(cars)
        cars.flat_map { |car| Api::Cars::IndexSerializer.new(car) }
      end

      def allowed_params
        params.permit(
          :query,
          :price_min,
          :price_max,
          :page
        )
      end
    end
  end
end
