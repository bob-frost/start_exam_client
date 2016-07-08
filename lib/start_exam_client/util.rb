module StartExamClient
  module Util
    extend self

    def array_wrap(value)
      value.is_a?(Hash) ? [value] : Array(value)
    end
  end
end
