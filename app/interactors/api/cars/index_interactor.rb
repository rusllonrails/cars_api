module Api
  module Cars
    class IndexInteractor < ApplicationInteractor
      param :user
      param :attributes

      def call
        yield validate_contract

        Success(
          Api::Cars::Finder.new(user, attributes).call
        )
      end

      private

      def validate_contract
        result = Api::Cars::IndexContract.new.call(attributes)
        return Success() if result.success?

        Failure(errors: result.errors.to_h)
      end
    end
  end
end
