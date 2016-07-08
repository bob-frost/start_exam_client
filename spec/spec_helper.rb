require 'bundler/setup'
require 'webmock/rspec'
require 'timecop'
Bundler.setup

require 'start_exam_client'

Dir[File.expand_path('support/**/*.rb', File.dirname(__FILE__))].each { |f| require f }

RSpec.configure do |config|
end

WebMock.disable_net_connect!
