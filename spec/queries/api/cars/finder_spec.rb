require 'rails_helper'

RSpec.describe Api::Cars::Finder do
  include RecommendedCarsVcrHelper
  include_context 'with mocked response of recommended cars'

  subject(:finder) { Api::Cars::Finder.new(user, attributes) }

  let(:user) do
    record = create(:user, preferred_price_range:)
    record.preferred_brands << brand_volvo
    record.preferred_brands << brand_toyota

    record
  end
  let(:preferred_price_range) { 29000...35000 }

  let(:brand_volvo) { create(:brand, name: 'Volvo') }
  let(:brand_mazda) { create(:brand, name: 'Mazda') }
  let(:brand_toyota) { create(:brand, name: 'Toyota') }
  let(:brand_honda) { create(:brand, name: 'Honda') }

  let!(:car_volvo) { create(:car, brand: brand_volvo, model: 'S70', price: 30_000) }
  let!(:car_mazda) { create(:car, brand: brand_mazda, model: 'MRY', price: 25_000) }
  let!(:car_toyota) { create(:car, brand: brand_toyota, model: 'Camry', price: 36_000) }
  let!(:car_honda) { create(:car, brand: brand_honda, model: 'Accord', price: 40_000) }
  let!(:car_honda_civic) { create(:car, brand: brand_honda, model: 'Civic', price: 23_000) }

  let(:mocked_recommended_cars) do
    [
      { "car_id" => car_volvo.id, "rank_score" => 0.134 },
      { "car_id" => car_toyota.id, "rank_score" => 0.777 },
      { "car_id" => car_mazda.id, "rank_score" => 0.334 },
      { "car_id" => car_honda.id, "rank_score" => 0.431 },
      { "car_id" => car_honda_civic.id, "rank_score" => 0.334 }
    ]
  end

  describe '#call' do
    subject(:finder_call) { finder.call }

    let(:car_volvo_attrs) do
      {
        "id" => car_volvo.id,
        "brand_id" => brand_volvo.id,
        "brand_name" => brand_volvo.name,
        "price" => car_volvo.price,
        "model" => car_volvo.model,
        "rank_score" => 0.134,
        "label" => 'perfect_match'
      }
    end
    let(:car_toyota_attrs) do
      {
        "id" => car_toyota.id,
        "brand_id" => brand_toyota.id,
        "brand_name" => brand_toyota.name,
        "price" => car_toyota.price,
        "model" => car_toyota.model,
        "rank_score" => 0.777,
        "label" => 'good_match'
      }
    end
    let(:car_honda_attrs) do
      {
        "id" => car_honda.id,
        "brand_id" => brand_honda.id,
        "brand_name" => brand_honda.name,
        "price" => car_honda.price,
        "model" => car_honda.model,
        "rank_score" => 0.431,
        "label" => nil
      }
    end
    let(:car_honda_civic_attrs) do
      {
        "id" => car_honda_civic.id,
        "brand_id" => brand_honda.id,
        "brand_name" => brand_honda.name,
        "price" => car_honda_civic.price,
        "model" => car_honda_civic.model,
        "rank_score" => 0.334,
        "label" => nil
      }
    end
    let(:car_mazda_attrs) do
      {
        "id" => car_mazda.id,
        "brand_id" => brand_mazda.id,
        "brand_name" => brand_mazda.name,
        "price" => car_mazda.price,
        "model" => car_mazda.model,
        "rank_score" => 0.334,
        "label" => nil
      }
    end

    shared_examples 'returns properly filtered and sorted data' do
      specify do
        VCR.use_cassette('api/cars/index/valid_response', match_requests_on:) do
          expect(finder_call).to match_array(expected_data)
        end
      end
    end

    context 'with empty filters' do
      let(:attributes) { {} }
      let(:expected_data) do
        [
          car_volvo_attrs,
          car_toyota_attrs,
          car_honda_attrs,
          car_honda_civic_attrs,
          car_mazda_attrs
        ]
      end

      it_behaves_like 'returns properly filtered and sorted data'
    end

    describe 'price filters' do
      context 'with price_min filter' do
        let(:attributes) do
          {
            price_min: 35_000
          }
        end
        let(:expected_data) do
          [
            car_toyota_attrs,
            car_honda_attrs
          ]
        end

        it_behaves_like 'returns properly filtered and sorted data'
      end

      context 'with price_max filter' do
        let(:attributes) do
          {
            price_max: 25_000
          }
        end
        let(:expected_data) do
          [
            car_honda_civic_attrs,
            car_mazda_attrs
          ]
        end

        it_behaves_like 'returns properly filtered and sorted data'
      end

      context 'with price_min and price_max filters' do
        let(:attributes) do
          {
            price_min: 24_000,
            price_max: 31_000
          }
        end
        let(:expected_data) do
          [
            car_volvo_attrs,
            car_mazda_attrs
          ]
        end

        it_behaves_like 'returns properly filtered and sorted data'
      end

      context 'with query, price_min and price_max filters' do
        let(:attributes) do
          {
            query: 'aZd',
            price_min: 24_000,
            price_max: 31_000
          }
        end
        let(:expected_data) do
          [
            car_mazda_attrs
          ]
        end

        it_behaves_like 'returns properly filtered and sorted data'
      end
    end

    describe 'query filter' do
      context 'when query is part of brand name' do
        let(:attributes) do
          {
            query: 'onD'
          }
        end
        let(:expected_data) do
          [
            car_honda_attrs,
            car_honda_civic_attrs
          ]
        end

        it_behaves_like 'returns properly filtered and sorted data'
      end

      context 'when query starts with brand name' do
        let(:attributes) do
          {
            query: 'mAZD'
          }
        end
        let(:expected_data) do
          [
            car_mazda_attrs
          ]
        end

        it_behaves_like 'returns properly filtered and sorted data'
      end

      context 'when query ends with brand name' do
        let(:attributes) do
          {
            query: 'zDA'
          }
        end
        let(:expected_data) do
          [
            car_mazda_attrs
          ]
        end

        it_behaves_like 'returns properly filtered and sorted data'
      end
    end

    describe 'page filter' do
      context 'without filters' do
        around { |spec| set_sql_limit(spec, 3) }

        context 'when page is 1' do
          let(:attributes) do
            {
              page: 1
            }
          end
          let(:expected_data) do
            [
              car_volvo_attrs,
              car_toyota_attrs,
              car_honda_attrs
            ]
          end

          it_behaves_like 'returns properly filtered and sorted data'
        end

        context 'when page is 2' do
          let(:attributes) do
            {
              page: 2
            }
          end
          let(:expected_data) do
            [
              car_honda_civic_attrs,
              car_mazda_attrs
            ]
          end

          it_behaves_like 'returns properly filtered and sorted data'
        end
      end

      context 'with other filters' do
        let(:base_filters) do
          {
            query: 'HonDa',
            price_min: 23_000,
            price_max: 41_000
          }
        end

        around { |spec| set_sql_limit(spec, 1) }

        context 'when page is 1' do
          let(:attributes) do
            base_filters.merge(page: 1)
          end
          let(:expected_data) do
            [
              car_honda_attrs
            ]
          end

          it_behaves_like 'returns properly filtered and sorted data'
        end

        context 'when page is 2' do
          let(:attributes) do
            base_filters.merge(page: 2)
          end
          let(:expected_data) do
            [
              car_honda_civic_attrs
            ]
          end

          it_behaves_like 'returns properly filtered and sorted data'
        end
      end
    end
  end

  private

  def set_sql_limit(spec, value)
    ENV["CARS_API_LIMIT"] = value.to_s
    spec.run
    ENV.delete("CARS_API_LIMIT")
  end
end
