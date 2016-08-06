module StartExamClient
  class Error < StandardError; end

  class ResponseError < Error
    attr_reader :response

    def initialize(response)
      @response = response
    end
  end
end
