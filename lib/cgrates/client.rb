require "faraday"
require "json"
require "pry"

module CGRateS
  class Client
    class InvalidResponseError < StandardError; end

    attr_reader :host, :http_client, :jsonrpc_endpoint

    def initialize(**options)
      @host = options.fetch(:host) { CGRateS.configuration.host }
      @jsonrpc_endpoint = options.fetch(:jsonrpc_endpoint) { CGRateS.configuration.jsonrpc_endpoint }
      @http_client = options.fetch(:http_client) do
        default_http_client(
          host,
          username: options.fetch(:username) { CGRateS.configuration.username },
          password: options.fetch(:password) { CGRateS.configuration.password }
        )
      end
    end

    def ping
      api_request("APIerSv2.Ping")
    end

    def set_tp_destination(tp_id:, id:, prefixes:)
      api_request(
        "APIerSv2.SetTPDestination",
        {
          "TPid" => tp_id,
          "ID" => id,
          "Prefixes" => prefixes
        }
      )
    end

    def get_tp_destination(tp_id:, id:)
      api_request(
        "APIerSv1.GetTPDestination",
        {
          "TPid" => tp_id,
          "ID" => id
        }
      )
    end

    private

    def api_request(method, *params)
      response = http_client.post(
        jsonrpc_endpoint,
        {
          jsonrpc: "2.0",
          id: SecureRandom.uuid,
          method: method,
          params: params
        }
      )

      error_message = if !response.success?
        "HTTP ERROR: #{response.status}"
      elsif response.body["error"]
        response.body.fetch("error")
      end

      if error_message
        raise(InvalidResponseError, "Invalid response from CGRateS API: #{error_message}")
      end

      Response.new(
        id: response.body.fetch("id"),
        result: response.body.fetch("result")
      )
    end

    def default_http_client(host, username:, password:)
      Faraday.new(url: host) do |conn|
        conn.request :json
        conn.response :json

        conn.adapter Faraday.default_adapter

        conn.request(
          :authorization,
          :basic,
          username,
          password
        )
      end
    end
  end
end
