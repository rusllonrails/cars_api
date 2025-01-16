require 'rails_helper'

describe Api::Cars::IndexContract do
  subject(:contract) { described_class.new }

  describe '#call' do
    subject(:validation_result) { contract.call(**params) }

    let(:params) { valid_params }
    let(:valid_params) do
      {
        query: 'Volvo',
        price_min: 25_000,
        price_max: 50_000
      }
    end

    it "returns success for valid input" do
      expect(validation_result).to be_success
    end

    describe 'failures' do
      shared_examples 'returns failure with error' do |field_name, error_message|
        it "returns failure for #{field_name}" do
          expect(validation_result).to be_failure
          expect(validation_result.errors[field_name]).to contain_exactly(error_message)
        end
      end

      context 'when price_min is not integer' do
        let(:params) do
          valid_params.merge(price_min: '2fake3')
        end

        it_behaves_like 'returns failure with error', :price_min, 'must be an integer'
      end

      context 'when price_max is not integer' do
        let(:params) do
          valid_params.merge(price_max: 'MadMax')
        end

        it_behaves_like 'returns failure with error', :price_max, 'must be an integer'
      end

      context 'when price_max is less than price_min' do
        let(:params) do
          valid_params.merge(price_max: 24_999)
        end

        it_behaves_like 'returns failure with error', :price_max, 'cannot be less than or equal to price_min'
      end

      context 'when price_max is equal to price_min' do
        let(:params) do
          valid_params.merge(price_max: 25_000)
        end

        it_behaves_like 'returns failure with error', :price_max, 'cannot be less than or equal to price_min'
      end
    end
  end
end
