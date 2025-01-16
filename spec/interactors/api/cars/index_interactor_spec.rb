require 'rails_helper'

RSpec.describe Api::Cars::IndexInteractor do
  include RecommendedCarsVcrHelper

  subject(:interactor) { Api::Cars::IndexInteractor.new(user, attributes) }

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
  let!(:car) { create(:car, brand:, model: 'S70', price: 30_000) }

  before do
    api_instance = instance_double(
      Api::Cars::RecommendedService, call: mocked_recommended_cars
    )
    allow(Api::Cars::RecommendedService).to receive(:new).and_return(api_instance)
  end

  describe '#call' do
    subject(:interactor_call) { interactor.call }

    context 'success' do
      let(:result) { interactor_call.value! }
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

      shared_examples 'returns data and has success state' do
        specify do
          VCR.use_cassette('api/cars/index/valid_response', match_requests_on:) do
            expect(interactor_call).to be_success
            expect(result).to match_array(expected_data)
          end
        end
      end

      context 'with valid attributes' do
        it_behaves_like 'returns data and has success state'
      end

      context 'without attributes' do
        let(:params) { {} }

        it_behaves_like 'returns data and has success state'
      end
    end

    describe 'failures' do
      shared_examples 'returns failure' do
        let(:expected_errors) do
          { errors: errors }
        end

        specify do
          VCR.use_cassette('api/cars/index/valid_response', match_requests_on:) do
            expect(interactor_call).to be_failure
            expect(interactor_call.failure).to eq(expected_errors)
          end
        end
      end

      context 'with invalid attributes' do
        context 'when courier working period is invalid' do
          let(:attributes) do
            {
              price_min: '2faKe',
              price_max: 'MadMax'
            }
          end
          let(:errors) do
            {
              price_max: ['must be an integer'],
              price_min: ['must be an integer']
            }
          end

          it_behaves_like 'returns failure'
        end
      end
    end
  end
end
