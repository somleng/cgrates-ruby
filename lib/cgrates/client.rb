require "faraday"
require "json"

module CGRateS
  class Client
    class APIError < StandardError; end

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

    def set_tp_destination(prefixes:, **)
      set_tp_resource("APIerSv2.SetTPDestination", **) do
        { "Prefixes" => prefixes }
      end
    end

    def get_tp_destination(**)
      get_tp_resource("APIerSv1.GetTPDestination", **)
    end

    def set_tp_rate(rate_slots:, **)
      set_tp_resource("APIerSv1.SetTPRate", **) do
        {
          "RateSlots" => rate_slots.map do
            {
              "ConnectFee" => it[:connect_fee],
              "Rate" => it[:rate],
              "RateUnit" => it[:rate_unit],
              "RateIncrement" => it[:rate_increment],
              "GroupIntervalStart" => it[:group_interval_start]
            }
          end
        }
      end
    end

    def get_tp_rate(**)
      get_tp_resource("APIerSv1.GetTPRate", **)
    end

    def set_tp_destination_rate(destination_rates:, **)
      set_tp_resource("APIerSv1.SetTPDestinationRate", **) do
        {
          "DestinationRates" => destination_rates.map do
            {
              "RoundingDecimals" => it[:rounding_decimals],
              "RateId" => it[:rate_id],
              "MaxCost" => it[:max_cost],
              "MaxCostStrategy" => it[:max_cost_strategy],
              "DestinationId" => it[:destination_id],
              "RoundingMethod" => it[:rounding_method]
            }
          end
        }
      end
    end

    def get_tp_destination_rate(**)
      get_tp_resource("APIerSv1.GetTPDestinationRate", **)
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
        raise(APIError, "Invalid response from CGRateS API: #{error_message}")
      end

      Response.new(
        id: response.body.fetch("id"),
        result: response.body.fetch("result")
      )
    end

    def set_tp_resource(method, tp_id:, id:, &)
      api_request(method, { "TPid" => tp_id, "ID" => id }.merge(yield))
    end

    def get_tp_resource(method, tp_id:, id:)
      api_request(method, { "TPid" => tp_id, "ID" => id })
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
