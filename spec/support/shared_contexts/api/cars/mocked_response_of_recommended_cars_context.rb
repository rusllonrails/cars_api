RSpec.shared_context 'with mocked response of recommended cars' do
  before do
    api_instance = instance_double(
      Api::Cars::RecommendedService, call: mocked_recommended_cars
    )
    allow(Api::Cars::RecommendedService).to receive(:new).and_return(api_instance)
  end
end
