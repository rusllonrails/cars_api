module Api
  module Cars
    class IndexSerializer < JsonSerializerBase
      attr_accessor :id,
                    :brand_id,
                    :brand_name,
                    :model,
                    :price,
                    :rank_score,
                    :label

      def attributes
        {
          id:,
          brand:,
          model:,
          price:,
          rank_score:,
          label:
        }
      end

      private

      def brand
        Api::Cars::BrandSerializer.new(id: brand_id, name: brand_name)
      end
    end
  end
end
