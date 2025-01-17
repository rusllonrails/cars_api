# Technical assessment introduction

https://github.com/Bravado-network/backend_test_assignment/blob/master/README.md

# Proposed Solution

:arrow_right: We are going to use standard REST API approach.

Endpoint: `/api/v1/users/:user_id/cars.json`

:arrow_right: In [Api::V1::CarsController](https://github.com/rusllonrails/cars_api/blob/main/app/controllers/api/v1/cars_controller.rb) level we have [Api::Cars::IndexInteractor](https://github.com/rusllonrails/cars_api/blob/main/app/interactors/api/cars/index_interactor.rb):

```ruby
class IndexInteractor < ApplicationInteractor
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
```

All input params will be validated by [Api::Cars::IndexContract](https://github.com/rusllonrails/cars_api/blob/main/app/contracts/api/cars/index_contract.rb).

:arrow_right: If params are valid - we are performing SQL query without ORM via [Api::Cars::Finder](https://github.com/rusllonrails/cars_api/blob/main/app/queries/api/cars/finder.rb) and [Api::Cars::FinderSql](https://github.com/rusllonrails/cars_api/blob/main/app/queries/api/cars/finder_sql.rb).

**Example of SQL:**
```sql
WITH recommended_cars_data AS (
  SELECT *
  FROM json_populate_recordset(
    null::recommended_cars_json_type,
    '[{"car_id":179,"rank_score":0.945},{"car_id":5,"rank_score":0.4552}]'
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
            WHEN cars.brand_id IN (2,39,40) AND cars.price BETWEEN 35000 AND 39999
              THEN 'perfect_match'
            WHEN cars.brand_id IN (2,39,40)
              THEN 'good_match'
            ELSE null
         END AS label
  FROM cars
  INNER JOIN brands
    ON brands.id = cars.brand_id AND brands.name ILIKE CONCAT('%', 'Chrysler', '%')
  LEFT OUTER JOIN recommended_cars_data
    ON recommended_cars_data.car_id = cars.id
  WHERE price BETWEEN '50000' AND '60000'
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
LIMIT 20
OFFSET 0
```

**Example of Success Request:**

`http://127.0.0.1:3000/api/v1/users/1/cars.json?page=1&price_min=50000&price_max=60000&query=Chrysler`

response:
```
[{"id":52,"brand":{"id":9,"name":"Chrysler"},"model":"Avenger","price":52452,"rank_score":null,"label":null}]
```

**Example of Failed Request:**

`http://127.0.0.1:3000/api/v1/users/1/cars.json?page=1&price_min=fakemin&price_max=fakemax&query=Chrysler`

response:
```
{"errors":{"price_min":["must be an integer"],"price_max":["must be an integer"]}}
```
