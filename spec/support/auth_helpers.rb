module Spec
  module AuthHelpers
    extend self

    def authorization_header(account_id, secret_key, method, path, body, time)
      date           = time.utc.strftime '%a, %d %b %Y %H:%M:%S GMT'
      content_length = body.to_s.bytesize.to_s
      string_to_sign = [method, path, date, content_length].join ' '
      signature      = Base64.encode64(OpenSSL::HMAC.digest('sha256', secret_key, string_to_sign)).strip
      "SharedKey #{ account_id }:#{ signature }"
    end
  end
end
