module Api
  module Cars
    class BrandSerializer < JsonSerializerBase
      attr_accessor :id,
                    :name

      def attributes
        {
          id:,
          name:
        }
      end
    end
  end
end
