require 'rails_helper'

describe Api::Cars::RecommendedService do
  include RecommendedCarsVcrHelper

  subject(:action) { described_class.new(user.id) }

  let(:user) { create(:user) }

  describe '#call' do
    subject { action.call }

    let(:expected_array) do
      [
        {"car_id"=>179, "rank_score"=>0.945},
        {"car_id"=>5, "rank_score"=>0.4552},
        {"car_id"=>13, "rank_score"=>0.567},
        {"car_id"=>97, "rank_score"=>0.9489},
        {"car_id"=>32, "rank_score"=>0.0967},
        {"car_id"=>176, "rank_score"=>0.0353},
        {"car_id"=>177, "rank_score"=>0.1657},
        {"car_id"=>36, "rank_score"=>0.7068},
        {"car_id"=>103, "rank_score"=>0.4729}
      ]
    end
    let(:cache_key) { "#{described_class::CACHE_KEY_PREFIX}#{user.id}" }
    let(:cache_store) { ActiveSupport::Cache::MemoryStore.new }

    before do
      # Specs have NullStore by default, we change that for this spec
      allow(Rails).to receive(:cache).and_return(cache_store)
    end

    context 'when API endpoint is healthy' do
      it 'does request to API and caches returned data for 1 hour' do
        VCR.use_cassette('api/cars/index/valid_response', match_requests_on:) do
          expect(Rails.cache).to receive(:write)
            .once.with(cache_key, expected_array, expires_in: 1.hour)

          expect(subject).to match_array(expected_array)
        end
      end

      context 'when data was already requested less than 1 hour ago' do
        before do
          Rails.cache.write(cache_key, expected_array)
        end

        it 'does not make another request to API and returns cached data' do
          expect(Rails.cache).not_to receive(:write)

          expect(subject).to match_array(expected_array)
        end
      end
    end

    context 'when API endpoint is unavailable' do
      let(:api_endpoint) do
        "#{Settings.recommendations_api.base_uri}/recomended_cars.json?user_id=#{user.id}"
      end

      before do
        WebMock.stub_request(:get, api_endpoint)
          .to_return(status: :internal_server_error, body: {}.to_json)
      end

      it 'does not cache failed response and returns fallback value' do
        expect(Rails.cache).not_to receive(:write)

        expect(subject).to match_array(described_class::FALLBACK_VALUE)
      end
    end
  end
end
