require 'rails_helper'

describe Api::Cars::BrandSerializer do
  subject(:serializer) { described_class.new(brand_ops) }

  let(:brand_ops) do
    {
      id: 2,
      name: 'Toyota'
    }
  end

  describe '#attributes' do
    it { is_expected.to have_attributes(brand_ops) }
  end
end
