require 'openssl'
require 'base64'
require 'start_exam_client/client'

module StartExamClient
  extend self

  BASE_API_URL = 'https://api.startexam.com/v1'
  HEADER_DATE_FORMAT = '%a, %d %b %Y %H:%M:%S GMT'

  def build_headers(params = {})
    time = Time.now.utc
    body = params[:body]
    {
      'Accept'         => 'application/json; charset=utf-8',
      'Content-Length' => content_length(body).to_s,
      'Date'           => date_header(time),
      'Authorization'  => authorization_header(params[:account_id], params[:secret_key], params[:method], params[:path], time, body)
    }
  end

  def date_header(time)
    time.strftime HEADER_DATE_FORMAT
  end

  def authorization_header(account_id, secret_key, method, path, time, body)
    method = method.to_s.upcase
    string_to_sign = [method, path, date_header(time), content_length(body)].join ' '
    signature = Base64.encode64(OpenSSL::HMAC.digest('sha256', secret_key, string_to_sign)).strip
    "SharedKey #{ account_id }:#{ signature }"
  end

  def content_length(body)
    body.to_s.bytesize
  end
end
