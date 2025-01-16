module Api
  module Cars
    class IndexContract < ApplicationContract
      params do
        optional(:query).filled(:string)
        optional(:price_min).filled(:integer, gteq?: 0)
        optional(:price_max).filled(:integer, gteq?: 0)
      end

      rule(:price_max) do
        key.failure(:cannot_be_less_or_equal_to_price_min) if price_max_lte_price_max?(values)
      end

      private

      def price_max_lte_price_max?(values)
        values[:price_min] &&
          values[:price_max] &&
          values[:price_max].to_i <= values[:price_min].to_i
      end
    end
  end
end
