module Spec
  module Helpers
    extend self

    def content_length_header(body)
      body.to_s.bytesize.to_s
    end

    def date_header(time)
      time.utc.strftime '%a, %d %b %Y %H:%M:%S GMT'
    end

    def authorization_header(account_id, secret_key, method, path, body, time)
      date           = date_header time
      content_length = content_length_header body
      string_to_sign = [method, path, date, content_length].join ' '
      signature      = Base64.encode64(OpenSSL::HMAC.digest('sha256', secret_key, string_to_sign)).strip
      "SharedKey #{ account_id }:#{ signature }"
    end

    def fixture(name)
      path = File.expand_path "../fixtures/#{ name }", File.dirname(__FILE__)
      File.read path
    end
  end
end
