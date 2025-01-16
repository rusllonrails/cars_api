require 'rails_helper'

RSpec.describe 'GET /api/v1/users/:user_id/cars', type: :request do
  include RecommendedCarsVcrHelper
  include_context 'with base cars API data'

  subject(:get_request) do
    get("/api/v1/users/#{user.id}/cars", params: attributes)
  end

  describe 'success' do
    let(:expected_data) do
      [
        {
          "id" => car.id,
          "brand" => {
            "id" => brand.id,
            "name" => "Volvo"
          },
          "label" => "perfect_match",
          "model" => "S70",
          "price" => 30000,
          "rank_score" => 0.777
        }
      ]
    end

    specify do
      get_request

      expect(response).to have_http_status(:ok)
      expect(parsed_response).to match(expected_data)
    end
  end

  describe 'failures' do
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
      }.with_indifferent_access
    end

    specify do
      get_request

      expect(response).to have_http_status(:unprocessable_entity)
      expect(parsed_response).to match(
        'errors' => errors
      )
    end
  end

  private

  def parsed_response
    JSON.parse(response.body)
  end
end
