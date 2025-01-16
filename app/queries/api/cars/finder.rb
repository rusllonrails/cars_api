module Api
  module Cars
    class Finder
      def initialize(user, filter_params)
        @user = user
        @filter_params = filter_params
      end

      def call
        do_query.entries
      end

      delegate :preferred_brand_ids,
               :preferred_price_range, to: :user, private: true

      private

      attr_reader :user, :filter_params

      def do_query
        ActiveRecord::Base.connection.execute(
          ActiveRecord::Base.sanitize_sql_array([
            raw_sql, preferred_brand_ids:,
                     preferred_price_range_min: preferred_price_range.min,
                     preferred_price_range_max: preferred_price_range.max,
                     brand_name_q: filter_params[:query],
                     price_min: filter_params[:price_min],
                     price_max: filter_params[:price_max],
                     recommended_cars:
          ])
        )
      end

      def raw_sql
        Api::Cars::FinderSql.new(filter_params).call
      end

      def recommended_cars
        Api::Cars::RecommendedService.new(user.id).call.to_json
      end
    end
  end
end
