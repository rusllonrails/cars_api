module Api
  module Cars
    class FinderSql
      DEFAULT_OFFSET = 0
      DEFAULT_CURRENT_PAGE = 1
      DEFAULT_LIMIT = 20

      def initialize(filter_params)
        @brand_name_q = filter_params[:query].to_s.strip
        @price_min = filter_params[:price_min]
        @price_max = filter_params[:price_max]
        @current_page = filter_params[:page] || DEFAULT_CURRENT_PAGE
      end

      def call
        <<-SQL.squish
          WITH recommended_cars_data AS (
            SELECT *
            FROM json_populate_recordset(
              null::recommended_cars_json_type, :recommended_cars
            )
          ),
          preloaded_cars_data AS (
            SELECT cars.id,
                   brands.id AS brand_id,
                   brands.name AS brand_name,
                   cars.price,
                   cars.model,
                   recommended_cars_data.rank_score AS rank_score,
                   CASE
                     WHEN cars.brand_id IN (:preferred_brand_ids) AND
                          cars.price BETWEEN :preferred_price_range_min AND :preferred_price_range_max
                          THEN 'perfect_match'
                     WHEN cars.brand_id IN (:preferred_brand_ids)
                          THEN 'good_match'
                     ELSE null
                   END AS label
            FROM cars
            INNER JOIN brands
              ON brands.id = cars.brand_id
              #{brand_name_q_sql}
            LEFT OUTER JOIN recommended_cars_data
              ON recommended_cars_data.car_id = cars.id
            #{price_between_sql}
          )
          SELECT *
          FROM preloaded_cars_data
          ORDER BY
            CASE label
              WHEN 'perfect_match' THEN 1
              WHEN 'good_match' THEN 2
              ELSE 3
            END,
            rank_score DESC NULLS LAST,
            price ASC
          LIMIT #{DEFAULT_LIMIT}
          OFFSET #{offset}
        SQL
      end

      private

      attr_reader :brand_name_q, :price_min, :price_max, :current_page

      def brand_name_q_sql
        return '' if brand_name_q.blank?

        <<-SQL.squish
          AND name ILIKE CONCAT('%', :brand_name_q, '%')
        SQL
      end

      def price_between_sql
        return '' unless price_min || price_max

        rule = if price_min && price_max
          'BETWEEN :price_min AND :price_max'
        elsif price_min
          '>= :price_min'
        elsif price_max
          '<= :price_max'
        end

        <<-SQL.squish
          WHERE price #{rule}
        SQL
      end

      def offset
        return DEFAULT_OFFSET unless current_page

        (current_page - 1) * DEFAULT_LIMIT
      end
    end
  end
end
