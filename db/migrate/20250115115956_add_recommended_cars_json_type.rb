class AddRecommendedCarsJsonType < ActiveRecord::Migration[8.0]
  def change
    safety_assured do
      execute <<~SQL.squish
        CREATE TYPE recommended_cars_json_type AS (
          car_id int, rank_score float8
        )
      SQL
    end
  end
end
