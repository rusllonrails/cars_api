require 'rails_helper'

RSpec.describe Api::Cars::Finder do
  include RecommendedCarsVcrHelper

  subject(:finder) { Api::Cars::Finder.new(user, attributes) }

  include_context 'with base cars API data'

  describe '#call' do
    subject(:finder_call) { finder.call }

    context 'success' do
      shared_examples 'returns data and has success state' do
        specify do
          VCR.use_cassette('api/cars/index/valid_response', match_requests_on:) do
            expect(finder_call).to match_array(expected_data)
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
  end
end
