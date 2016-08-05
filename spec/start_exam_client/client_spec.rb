require 'spec_helper'

describe StartExamClient::Client do
  let(:account_id) { 12345 }
  let(:secret_key) { SecureRandom.hex 32  }
  let(:base_api_url) { 'https://api.startexam.com/v1' }
  let(:client) { StartExamClient::Client.new account_id: account_id, secret_key: secret_key }

  describe '#participant_results' do
    let(:url) { "#{ base_api_url }/participants" }
    let(:center) { SecureRandom.hex }

    before do
      stub_request(:any, url).with(query: hash_including({}))
    end

    it 'sends request to API' do
      client.participant_results

      expect(WebMock).to have_requested(:get, url)
    end

    it 'sends required headers' do
      time = Time.now
      authorization_header = SecureRandom.hex
      expect(StartExamClient).to receive(:authorization_header).and_return(authorization_header)
      expected_headers = {
        'Accept'         => 'application/json; charset=utf-8',
        'Content-Length' => '0',
        'Date'           => time.utc.strftime('%a, %d %b %Y %H:%M:%S GMT'),
        'Authorization'  => authorization_header
      }
      client.participant_results

      Timecop.freeze(time) do
        expect(WebMock).to have_requested(:get, url).with(headers: expected_headers)
      end
    end

    it 'sends query params' do
      center = SecureRandom.hex
      any_param = SecureRandom.hex
      expected_query = { center: center, any_param: any_param }
      client.participant_results center: center, any_param: any_param

      expect(WebMock).to have_requested(:get, url).with(query: expected_query)
    end

    it 'sends single participant_id' do
      participant_id = rand 1..10
      expected_query = { participant_id: participant_id }
      client.participant_results participant_id: participant_id

      expect(WebMock).to have_requested(:get, url).with(query: expected_query)
    end

    it 'sends multiple participant_ids separated by ","' do
      participant_ids = [rand(1..10), rand(1..10)]
      expected_query = { participant_id: participant_ids.join(',') }
      client.participant_results participant_ids: participant_ids

      expect(WebMock).to have_requested(:get, url).with(query: expected_query)
    end

    it 'sends Time objects in required format' do
      from = Time.now
      to = Time.now
      expected_query = { from: from.utc.iso8601, to: to.utc.iso8601 }
      client.participant_results from: from, to: to

      expect(WebMock).to have_requested(:get, url).with(query: expected_query)
    end

    it 'returns HTTParty response' do
      body = Spec::Helpers.fixture('participant_results_response.json')
      stub_request(:get, url).to_return(body: body)
      response = client.participant_results

      expect(response.body).to eq(body)
    end
  end

  describe '#session_report' do
    let(:url) { "#{ base_api_url }/session" }
    let(:session_id) { rand 1..10 }

    before do
      stub_request(:any, url).with(query: hash_including({}))
    end

    it 'sends request to API' do
      expected_query = { sessionId: session_id }
      client.session_report session_id

      expect(WebMock).to have_requested(:get, url).with(query: expected_query)
    end

    it 'returns HTTParty response' do
      body = Spec::Helpers.fixture('session_report_response.json')
      stub_request(:get, url).with(query: { sessionId: session_id }).to_return(body: body)
      response = client.session_report session_id

      expect(response.body).to eq(body)
    end
  end

  describe '#register_participants' do
    let(:url) { "#{ base_api_url }/participants" }

    before do
      stub_request :any, url
    end

    it 'sends request to API' do
      client.register_participants({})

      expect(WebMock).to have_requested(:post, url).with { |request| !request.body.empty? }
    end

    it 'sends required headers' do
      time = Time.now
      authorization_header = SecureRandom.hex
      content_length = rand 1..100
      expect(StartExamClient).to receive(:authorization_header).and_return(authorization_header)
      expect(StartExamClient).to receive(:content_length).and_return(content_length)
      expected_headers = {
        'Accept'         => 'application/json; charset=utf-8',
        'Content-Length' => content_length.to_s,
        'Date'           => time.utc.strftime('%a, %d %b %Y %H:%M:%S GMT'),
        'Authorization'  => authorization_header
      }
      client.register_participants({})

      Timecop.freeze(time) do
        expect(WebMock).to have_requested(:post, url).with { |request| request.headers == expected_headers }
      end
    end

    it 'sends xml body' do
      params = JSON.parse Spec::Helpers.fixture('register_participants_request_params.json')
      expected_body = Spec::Helpers.fixture('register_participants_request_body.xml').gsub(/\n\s*/, '')
      client.register_participants params

      expect(WebMock).to have_requested(:post, url).with { |request| request.body.gsub(/\n\s*/, '') == expected_body }
    end

    it 'sends multiple participants and tests' do
      params = JSON.parse Spec::Helpers.fixture('register_participants_multiple_request_params.json')
      expected_body = Spec::Helpers.fixture('register_participants_multiple_request_body.xml').gsub(/\n\s*/, '')
      client.register_participants params

      expect(WebMock).to have_requested(:post, url).with { |request| request.body.gsub(/\n\s*/, '') == expected_body }
    end

    it 'sends Time objects in required format' do
      valid_from = Time.now
      valid_till = Time.now
      params = { valid_from: valid_from, valid_till: valid_till }
      expected_xml1 = "<ValidFrom>#{ valid_from.utc.iso8601 }</ValidFrom>"
      expected_xml2 = "<ValidTill>#{ valid_till.utc.iso8601 }</ValidTill>"
      client.register_participants params

      expect(WebMock).to have_requested(:post, url)
        .with { |request| request.body.include?(expected_xml1) && request.body.include?(expected_xml2) }
    end

    it 'sends Date objects in required format' do
      birthdate = Date.today
      params = { participants: [{ BirthDate: birthdate }] }
      expected_xml = "<Data key=\"BirthDate\" value=\"#{ birthdate.strftime '%d.%m.%Y' }\"/>"
      client.register_participants params

      expect(WebMock).to have_requested(:post, url).with { |request| request.body.include? expected_xml }
    end

    it 'returns HTTParty response' do
      body = Spec::Helpers.fixture('register_participants_response.json')
      stub_request(:post, url).to_return(body: body)
      response = client.register_participants({})

      expect(response.body).to eq(body)
    end
  end
end
