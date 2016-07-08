# -*- encoding : utf-8 -*-
require 'httparty'
require 'nokogiri'
require 'start_exam_client/util'

module StartExamClient
  class Client
    DEFAULT_TIMEOUT = 20

    attr_reader :account_id, :secret_key, :timeout

    def initialize(options = {})
      @account_id = options[:account_id]
      @secret_key = options[:secret_key]
      @timeout = options[:timeout] || DEFAULT_TIMEOUT
    end

    def participant_results(params = {})
      params = normalize_request_params params
      params[:participant_id] ||= params.delete(:participant_ids).join(',') if params[:participant_ids].is_a?(Array)
      response = json_request :get, 'participants', params
    end

    def register_participants(params = {})
      params = normalize_request_params params
      xml = register_participants_xml params
      response = xml_request :post, 'participants', xml
    end

    private

    def normalize_request_params(params)
      case params
      when Hash
        params.inject({}) { |result, (k, v)| result.merge k.to_sym => normalize_request_params(v) }
      when Array
        params.map { |v| normalize_request_params v }
      when Date, Time
        params.utc.iso8601
      else
        params
      end
    end

    def json_request(method, path, params = {})
      uri = build_uri path
      headers = build_headers method: method, path: uri.path
      HTTParty.send method, uri.to_s, query: params, headers: headers, timeout: timeout
    end

    def xml_request(method, path, xml)
      uri = build_uri path
      headers = build_headers method: method, path: uri.path, body: xml
      HTTParty.send method, uri.to_s, body: xml, headers: headers, timeout: timeout
    end

    def build_headers(params)
      params = params.merge account_id: account_id, secret_key: secret_key
      StartExamClient.build_headers params
    end

    def build_uri(path)
      URI "#{ StartExamClient::BASE_API_URL }/#{ path }"
    end

    def register_participants_xml(params)
      xml = Nokogiri::XML::Builder.new do |xml|
        xml.RegisterParticipantsQuery(xmlns: 'https://api.startexam.com/v1/xml') {
          xml.Center    params[:center]
          xml.ValidFrom params[:valid_from]
          xml.ValidTill params[:valid_till]
          Util.array_wrap(params[:tests] || params[:test]).each do |test|
            xml.Test test
          end
          Util.array_wrap(params[:participants] || params[:participant]).each do |participant|
            xml.Participant {
              participant.each do |key, value|
                xml.Data key: key, value: value
              end
            }
          end
        }
      end.to_xml
    end
  end
end
