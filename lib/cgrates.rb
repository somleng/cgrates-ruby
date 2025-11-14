require_relative "cgrates/version"

module CGRateS
  class << self
    def configure
      yield(configuration)
      configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end

    alias config configuration
  end
end

require_relative "cgrates/configuration"
require_relative "cgrates/client"
require_relative "cgrates/response"
