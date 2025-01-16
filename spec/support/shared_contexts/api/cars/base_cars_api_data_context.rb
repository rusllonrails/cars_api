RSpec.shared_context 'with base cars API data' do
  let(:user) do
    record = create(:user, preferred_price_range: 25000...31000)
    record.preferred_brands << brand

    record
  end
  let(:attributes) { valid_attributes }
  let(:valid_attributes) do
    {
      query: 'Volvo',
      price_min: 25_000,
      price_max: 50_000
    }
  end
  let(:mocked_recommended_cars) do
    [
      {"car_id" => car.id, "rank_score" => 0.777}
    ]
  end
  let(:brand) { create(:brand, name: 'Volvo') }
  let(:expected_data) do
    [
      {
        "id" => car.id,
        "brand_id" => brand.id,
        "brand_name" => brand.name,
        "price" => car.price,
        "model" => car.model,
        "rank_score" => 0.777,
        "label" => 'perfect_match'
      }
    ]
  end

  let!(:car) { create(:car, brand:, model: 'S70', price: 30_000) }

  before do
    api_instance = instance_double(
      Api::Cars::RecommendedService, call: mocked_recommended_cars
    )
    allow(Api::Cars::RecommendedService).to receive(:new).and_return(api_instance)
  end
end
