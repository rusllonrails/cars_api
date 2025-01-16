require 'rails_helper'

describe Api::Cars::IndexSerializer do
  subject(:serializer) { described_class.new(car_ops) }

  let(:car_ops) do
    {
      id: 1,
      brand_id: 2,
      brand_name: 'Toyota',
      model: 'Camry',
      price: 34500,
      rank_score: 0.954,
      label: 'perfect_match'
    }
  end

  describe '#attributes' do
    subject { serializer.attributes.to_h }

    let(:expected_attributes) do
      {
        id: 1,
        brand: instance_of(Api::Cars::BrandSerializer),
        model: 'Camry',
        price: 34500,
        rank_score: 0.954,
        label: 'perfect_match'
      }
    end

    it { is_expected.to match(expected_attributes) }
  end
end
