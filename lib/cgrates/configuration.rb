module CGRateS
  class Configuration
    attr_accessor :host, :username, :password, :jsonrpc_endpoint

    def initialize
      @jsonrpc_endpoint = "/jsonrpc"
    end
  end
end
