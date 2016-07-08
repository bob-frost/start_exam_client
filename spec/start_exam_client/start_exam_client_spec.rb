require 'spec_helper'

describe StartExamClient do
  describe '#authorization_header' do
    it 'builds header' do
      account_id = rand 1..100
      secret_key = SecureRandom.hex
      method = :get
      path = SecureRandom.hex
      time = Time.now
      body = SecureRandom.hex
      
      string_to_sign = [
        method.to_s.upcase,
        path,
        time.utc.strftime('%a, %d %b %Y %H:%M:%S GMT'),
        body.bytesize
      ].join ' '
      signature = Base64.encode64(OpenSSL::HMAC.digest('sha256', secret_key, string_to_sign)).strip

      expected = "SharedKey #{ account_id }:#{ signature }"
      received = StartExamClient.authorization_header account_id, secret_key, method, path, time, body

      expect(received).to eq(expected)
    end
  end

  describe '#date_header' do
    it 'returns date in UTC/RFC1123' do
      time = Time.now
      expected = time.utc.strftime '%a, %d %b %Y %H:%M:%S GMT'
      expect(StartExamClient.date_header(time)).to eq(expected)
    end
  end
end