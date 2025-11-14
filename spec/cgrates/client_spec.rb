require "base64"

module CGRateS
  RSpec.describe Client do
    describe "#ping" do
      it "returns pong" do
        client = build_client(host: "http://localhost:2080", username: "username", password: "password")
        stub_api_request(host: "http://localhost:2080", result: "Pong")

        response = client.ping

        expect(response).to have_attributes(result: "Pong")
        expect(WebMock).to have_requested_api_method("APIerSv2.Ping", host: "http://localhost:2080")
        expect(WebMock).to have_requested(:post, "http://localhost:2080/jsonrpc").with(
          headers: {
            "Authorization" => "Basic #{Base64.strict_encode64("username:password")}"
          }
        )
      end
    end

    describe "#set_tp_destination" do
      it "executes the request" do
        client = build_client

        stub_api_request(result: "OK")

        response = client.set_tp_destination(
          tp_id: "cgrates_client_test",
          id: "Cambodia_Mobile",
          prefixes: [ "85510", "85512", "85597" ]
        )

        expect(response).to have_attributes(result: "OK")
        expect(WebMock).to have_requested_api_method("APIerSv2.SetTPDestination")

        stub_api_request(
          result: {
            "TPid" => "cgrates_client_test",
            "ID" => "Cambodia_Mobile",
            "Prefixes" => [ "85510", "85512", "85597" ]
          }
        )

        response = client.get_tp_destination(
          tp_id: "cgrates_client_test",
          id: "Cambodia_Mobile"
        )

        expect(response).to have_attributes(
          result: hash_including(
            "Prefixes" => [ "85510", "85512", "85597" ]
          )
        )
        expect(WebMock).to have_requested_api_method("APIerSv1.GetTPDestination")
      end
    end

    describe "#set_tp_rate" do
      it "executes the request" do
        client = build_client

        stub_api_request(result: "OK")

        response = client.set_tp_rate(
          tp_id: "cgrates_client_test",
          id: "Cambodia_Mobile_Rate",
          rate_slots: [
            {
              connect_fee: 0.0,
              rate: 0.05,
              rate_unit: "60s",
              rate_increment: "60s",
              group_interval_start: "0s"
            }
          ]
        )

        expect(response).to have_attributes(result: "OK")
        expect(WebMock).to have_requested_api_method("APIerSv1.SetTPRate")

        stub_api_request(
          result: {
            "RateSlots" => [
              {
                "ConnectFee" => 0,
                "Rate" => 0.05,
                "RateUnit" => "60s",
                "RateIncrement" => "60s",
                "GroupIntervalStart" => "0s"
              }
            ]
          }
        )

        response = client.get_tp_rate(
          tp_id: "cgrates_client_test",
          id: "Cambodia_Mobile_Rate"
        )

        expect(response).to have_attributes(
          result: hash_including(
            "RateSlots" => [
              {
                "ConnectFee" => 0,
                "Rate" => 0.05,
                "RateUnit" => "60s",
                "RateIncrement" => "60s",
                "GroupIntervalStart" => "0s"
              }
            ]
          )
        )
        expect(WebMock).to have_requested_api_method("APIerSv1.GetTPRate")
      end
    end

    describe "#set_tp_destination_rate" do
      it "executes the request" do
        client = build_client

        stub_api_request(result: "OK")
        client.set_tp_destination(
          tp_id: "cgrates_client_test",
          id: "Cambodia_Mobile",
          prefixes: [ "85510" ]
        )

        stub_api_request(result: "OK")
        client.set_tp_rate(
          tp_id: "cgrates_client_test",
          id: "Cambodia_Mobile_Rate",
          rate_slots: [
            {
              rate: 0.05,
              rate_unit: "60s",
              rate_increment: "60s"
            }
          ]
        )

        stub_api_request(result: "OK")
        response = client.set_tp_destination_rate(
          tp_id: "cgrates_client_test",
          id: "Cambodia_Mobile_Destination_Rate",
          destination_rates: [
            {
              rounding_decimals: 4,
              rate_id: "Cambodia_Mobile_Rate",
              destination_id: "Cambodia_Mobile",
              max_cost: 0,
              max_cost_strategy: nil,
              rounding_method: "*up"
            }
          ]
        )

        expect(response).to have_attributes(result: "OK")
        expect(WebMock).to have_requested_api_method("APIerSv1.SetTPDestinationRate")

        stub_api_request(
          result: {
            "DestinationRates" => [
              {
                "DestinationId" => "Cambodia_Mobile",
                "RateId" => "Cambodia_Mobile_Rate",
                "Rate" => nil,
                "RoundingMethod" => "*up",
                "RoundingDecimals" => 4,
                "MaxCost" => 0,
                "MaxCostStrategy" => ""
              }
            ]
          }
        )
        response = client.get_tp_destination_rate(
          tp_id: "cgrates_client_test",
          id: "Cambodia_Mobile_Destination_Rate"
        )

        expect(response).to have_attributes(
          result: hash_including(
            "DestinationRates" => [
              hash_including(
                "DestinationId" => "Cambodia_Mobile",
                "RateId" => "Cambodia_Mobile_Rate",
                "RoundingDecimals" => 4,
                "MaxCost" => 0,
                "RoundingMethod" => "*up"
              )
            ]
          )
        )
        expect(WebMock).to have_requested_api_method("APIerSv1.GetTPDestinationRate")
      end
    end

    it "handles invalid http responses" do
      client = build_client
      stub_api_request(status: 500)

      expect { client.ping }.to raise_error(CGRateS::Client::APIError, /HTTP ERROR: 500/)
    end

    it "handles error responses from the API" do
      client = build_client
      stub_api_request(result: nil, error: "NOT_FOUND")

      expect { client.get_tp_destination(tp_id: "non_existent", id: "non_existent") }.to raise_error(
        CGRateS::Client::APIError, /NOT_FOUND/
      )
    end

    def build_client(**options)
      Client.new(host: "http://localhost:2080", **options)
    end

    def stub_api_request(**options)
      return if WebMock::Config.instance.allow_net_connect

      host = options.fetch(:host, "http://localhost:2080")
      path = options.fetch(:path, "jsonrpc")
      status = options.fetch(:status, 200)
      body = status == 200 ?  options.fetch(:body) { { result: options.fetch(:result), error: options[:error] } } : {}

      stub_request(:post, "#{host}/#{path}").to_return ->(request) {
        {
          status:,
          body: JSON.parse(request.body).slice("id").merge(body).to_json,
          headers: { "Content-Type" => "application/json" }
        }
      }
    end

    def have_requested_api_method(method, **options)
      host = options.fetch(:host, "http://localhost:2080")
      path = options.fetch(:path, "jsonrpc")
      have_requested(:post, "#{host}/#{path}").with(
        body: hash_including("method" => method)
      )
    end
  end
end
