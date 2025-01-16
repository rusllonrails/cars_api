RSpec.shared_context 'with recommended cars VCR setup' do
  def match_requests_on
    [
      :method,
      VCR.request_matchers.uri_without_params('user_id')
    ]
  end
end
