require "webmock/rspec"

WebMock.disable_net_connect!

RSpec.configure do |config|
  config.around(allow_net_connect: true) do |example|
    WebMock.allow_net_connect!
    example.run
    WebMock.disable_net_connect!
  end
end
