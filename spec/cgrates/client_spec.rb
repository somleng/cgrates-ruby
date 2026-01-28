require "spec_helper"
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

    describe "#set_charger_profile" do
      it "executes the request" do
        client = build_client

        stub_api_request(result: "OK")

        response = client.set_charger_profile(
          id: "Test_Charger_Profile",
          tenant: "cgrates.org"
        )

        expect(response).to have_attributes(result: "OK")
        expect(WebMock).to have_requested_api_method("APIerSv1.SetChargerProfile")

        stub_api_request(
          result: {
            "ID" => "Test_Charger_Profile",
            "Tenant" => "cgrates.org"
          }
        )

        response = client.get_charger_profile(
          id: "Test_Charger_Profile",
          tenant: "cgrates.org"
        )

        expect(response).to have_attributes(
          result: hash_including(
            "Tenant" => "cgrates.org",
            "ID" => "Test_Charger_Profile"
          )
        )

        expect(WebMock).to have_requested_api_method("APIerSv1.GetChargerProfile")

        stub_api_request(result: "OK")

        response = client.remove_charger_profile(
          id: "Test_Charger_Profile",
          tenant: "cgrates.org"
        )

        expect(response).to have_attributes(result: "OK")
        expect(WebMock).to have_requested_api_method("APIerSv1.RemoveChargerProfile")
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

        stub_api_request(result: "OK")
        response = client.remove_tp_rate(
          tp_id: "cgrates_client_test",
          id: "Cambodia_Mobile_Rate"
        )

        expect(response).to have_attributes(result: "OK")
        expect(WebMock).to have_requested_api_method("APIerSv1.RemoveTPRate")
      end
    end

    describe "#set_tp_destination_rate" do
      it "executes the request" do
        client = build_client
        set_tp_destination(client, tp_id: "cgrates_client_test", id: "Cambodia_Mobile")
        set_tp_rate(client, tp_id: "cgrates_client_test", id: "Cambodia_Mobile_Rate")

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

        stub_api_request(result: "OK")
        response = client.remove_tp_destination_rate(
          tp_id: "cgrates_client_test",
          id: "Cambodia_Mobile_Destination_Rate"
        )

        expect(response).to have_attributes(result: "OK")
        expect(WebMock).to have_requested_api_method("APIerSv1.RemoveTPDestinationRate")
      end
    end

    describe "#set_tp_rating_plan" do
      it "executes the request" do
        client = build_client
        set_tp_destination_rate(client, tp_id: "cgrates_client_test", id: "Cambodia_Mobile_Destination_Rate")

        stub_api_request(result: "OK")
        response = client.set_tp_rating_plan(
          tp_id: "cgrates_client_test",
          id: "Test_Rating_Plan",
          rating_plan_bindings: [
            {
              timing_id: "*any",
              weight: 10,
              destination_rates_id: "Cambodia_Mobile_Destination_Rate"
            }
          ]
        )
        expect(response).to have_attributes(result: "OK")
        expect(WebMock).to have_requested_api_method("APIerSv1.SetTPRatingPlan")

        stub_api_request(
          result: {
            "RatingPlanBindings" => [
              {
                "TimingId" => "*any",
                "Weight" => 10,
                "DestinationRatesId" => "Cambodia_Mobile_Destination_Rate"
              }
            ]
          }
        )

        response = client.get_tp_rating_plan(
          tp_id: "cgrates_client_test",
          id: "Test_Rating_Plan"
        )

        expect(response).to have_attributes(
          result: hash_including(
            "RatingPlanBindings" => [
              hash_including(
                "TimingId" => "*any",
                "Weight" => 10,
                "DestinationRatesId" => "Cambodia_Mobile_Destination_Rate"
              )
            ]
          )
        )
        expect(WebMock).to have_requested_api_method("APIerSv1.GetTPRatingPlan")

        stub_api_request(result: "OK")
        response = client.remove_tp_rating_plan(
          tp_id: "cgrates_client_test",
          id: "Test_Rating_Plan"
        )

        expect(response).to have_attributes(result: "OK")
        expect(WebMock).to have_requested_api_method("APIerSv1.RemoveTPRatingPlan")
      end
    end

    describe "#set_tp_rating_profile" do
      it "executes the request" do
        client = build_client
        set_tp_rating_plan(client, tp_id: "cgrates_client_test", id: "Test_Rating_Plan")

        stub_api_request(result: "OK")
        response = client.set_tp_rating_profile(
          tp_id: "cgrates_client_test",
          id: "Test_Rating_Profile",
          load_id: "TEST",
          category: "call",
          tenant: "cgrates.org",
          subject: "my-account",
          rating_plan_activations: [
            {
              activation_time: "2025-12-03T19:55:23+07:00",
              fallback_subjects: "foobar",
              rating_plan_id: "Test_Rating_Plan"
            }
          ]
        )
        expect(response).to have_attributes(result: "OK")
        expect(WebMock).to have_requested_api_method("APIerSv1.SetTPRatingProfile")

        stub_api_request(
          result: {
            "LoadId" => "TEST",
            "Tenant" => "cgrates.org",
            "Category" => "call",
            "Subject" => "my-account",
            "RatingPlanActivations" => [
              {
                "ActivationTime" => "2025-12-03T19:55:23+07:00",
                "FallbackSubjects" => "foobar",
                "RatingPlanId" => "Test_Rating_Plan"
              }
            ]
          }
        )

        response = client.get_tp_rating_profile(
          tp_id: "cgrates_client_test",
          load_id: "TEST",
          tenant: "cgrates.org",
          category: "call",
          subject: "my-account"
        )

        expect(response).to have_attributes(
          result: hash_including(
            "LoadId" => "TEST",
            "Tenant" => "cgrates.org",
            "Category" => "call",
            "Subject" => "my-account",
            "RatingPlanActivations" => [
              hash_including(
                "ActivationTime" =>"2025-12-03T19:55:23+07:00",
                "FallbackSubjects" => "foobar",
                "RatingPlanId" => "Test_Rating_Plan"
              )
            ]
          )
        )
        expect(WebMock).to have_requested_api_method("APIerSv1.GetTPRatingProfile")

        stub_api_request(result: "OK")
        response = client.remove_tp_rating_profile(
          tp_id: "cgrates_client_test",
          load_id: "TEST",
          tenant: "cgrates.org",
          category: "call",
          subject: "my-account"
        )

        expect(response).to have_attributes(result: "OK")
        expect(WebMock).to have_requested_api_method("APIerSv1.RemoveTPRatingProfile")
      end
    end

    describe "#set_account" do
      it "executes the request" do
        client = build_client

        stub_api_request(result: "OK")
        response = client.set_account(account: "sample-account-sid", tenant: "cgrates.org")

        expect(response).to have_attributes(result: "OK")
        expect(WebMock).to have_requested_api_method("APIerSv2.SetAccount")

        stub_api_request(
          result: {
            "ID" => "cgrates.org:sample-account-sid",
            "BalanceMap" => nil,
            "UnitCounters" => nil,
            "ActionTriggers" => nil,
            "AllowNegative" => false,
            "Disabled" => false,
            "UpdateTime" => "2026-01-08T11:49:44.172931119Z"
          }
        )

        response = client.get_account(
          tenant: "cgrates.org",
          account: "sample-account-sid"
        )

        expect(response).to have_attributes(
          result: hash_including(
            "ID" => "cgrates.org:sample-account-sid",
          )
        )
        expect(WebMock).to have_requested_api_method("APIerSv2.GetAccount")

        stub_api_request(result: "OK")
        response = client.remove_account(
          account: "sample-account-sid",
          tenant: "cgrates.org"
        )

        expect(response).to have_attributes(result: "OK")
        expect(WebMock).to have_requested_api_method("APIerSv1.RemoveAccount")
      end
    end

    describe "#load_tariff_plan_from_stor_db" do
      it "executes the request" do
        client = build_client

        stub_api_request(result: "OK")
        response = client.load_tariff_plan_from_stor_db(tp_id: "cgrates_client_test")

        expect(response).to have_attributes(result: "OK")
        expect(WebMock).to have_requested_api_method("APIerSv1.LoadTariffPlanFromStorDb")
      end
    end

    describe "#add_balance" do
      it "executes the request" do
        client = build_client

        stub_api_request(result: "OK")
        response = client.add_balance(account: "sample-account-sid", tenant: "cgrates.org", balance_type: "credit", value: 100, balance: { uuid: "123", id: "456" })

        expect(response).to have_attributes(result: "OK")
        expect(WebMock).to have_requested_api_method("APIerSv1.AddBalance")
      end
    end

    describe "#debit_balance" do
      it "executes the request" do
        client = build_client

        stub_api_request(result: "OK")
        response = client.debit_balance(account: "sample-account-sid", tenant: "cgrates.org", balance_type: "credit", value: 100, balance: { uuid: "123", id: "456" })

        expect(response).to have_attributes(result: "OK")
        expect(WebMock).to have_requested_api_method("APIerSv1.DebitBalance")
      end
    end

    describe "#get_cdrs" do
      it "executes the request" do
        client = build_client

        stub_api_request(result: [])
        response = client.get_cdrs(
          tenants: [ "cgrates.org" ],
          not_costs: [ -1 ],
          origin_ids: [ "origin-id-1" ],
          order_by: "OrderID",
          extra_args: { "OrderIDStart" => 1 },
          limit: 2
        )

        expect(response).to have_attributes(result: a_kind_of(Array))
        expect(WebMock).to have_requested_api_method("APIerSv2.GetCDRs")
      end
    end

    describe "#process_external_cdr" do
      it "executes the request" do
        client = build_client

        stub_api_request(result: "OK")
        response = client.process_external_cdr(
          account: "sample-account-sid",
          tenant: "cgrates.org",
          category: "call",
          request_type: "*prepaid",
          tor: "*message",
          destination: "85510",
          answer_time: "2025-12-03T19:55:23+07:00",
          setup_time: "2025-12-03T19:55:23+07:00",
          usage: "100",
          origin_id: SecureRandom.uuid
        )

        expect(response).to have_attributes(result: "OK")
        expect(WebMock).to have_requested_api_method("CDRsV1.ProcessExternalCDR")
      end
    end

    describe "#get_cost" do
      it "executes the request" do
        client = build_client

        stub_api_request(result: {})
        response = client.get_cost(
          tenant: "cgrates.org",
          account: "sample-account-sid",
          subject: "my-account",
          category: "call",
          destination: "85510",
          usage: "100"
        )

        expect(response).to have_attributes(result: a_kind_of(Hash))
        expect(WebMock).to have_requested_api_method("APIerSv1.GetCost")
      end

      it "handles error responses from the API" do
        client = build_client
        stub_api_request(result: nil, error: "SERVER_ERROR: MAX_USAGE_EXCEEDED")

        expect {
          client.get_cost(
            tenant: "cgrates.org",
            subject: "sample-account-sid",
            category: "call",
            destination: "85510",
            usage: "60s"
          )
        }.to raise_error do |error|
          expect(error).to be_a(CGRateS::Client::MaxUsageExceededError)
          expect(error.response).to include(
            "error" => "SERVER_ERROR: MAX_USAGE_EXCEEDED"
          )
        end
      end
    end

    describe "#get_max_session_time" do
      it "executes the request" do
        client = build_client

        stub_api_request(result: 100)
        response = client.get_max_session_time(
          tenant: "cgrates.org",
          account: "sample-account-sid",
          category: "call",
          destination: "85510",
          time_start: "0001-01-01T00:00:00Z",
          time_end: "0001-01-01T03:00:01Z"
        )

        expect(response).to have_attributes(result: a_kind_of(Integer))
        expect(WebMock).to have_requested_api_method("Responder.GetMaxSessionTime")
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

      expect { client.get_tp_destination(tp_id: "non_existent", id: "non_existent") }.to raise_error do |error|
        expect(error).to be_a(CGRateS::Client::NotFoundError)
        expect(error.response).to include(
          "error" => "NOT_FOUND"
        )
      end
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

    def set_tp_destination(client, **params)
      stub_api_request(result: "OK")
      client.set_tp_destination(
        tp_id: "cgrates_client_test",
        id: "Cambodia_Mobile",
        prefixes: [ "85510" ],
        **params
      )
    end

    def set_tp_rate(client, **params)
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
        ],
        **params
      )
    end

    def set_tp_destination_rate(client, **params)
      set_tp_destination(client, tp_id: "cgrates_client_test", id: "Cambodia_Mobile")
      set_tp_rate(client, tp_id: "cgrates_client_test", id: "Cambodia_Mobile_Rate")

      stub_api_request(result: "OK")
      client.set_tp_destination_rate(
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
        ],
        **params
      )
    end

    def set_tp_rating_plan(client, **params)
      set_tp_destination_rate(client, tp_id: "cgrates_client_test", id: "Cambodia_Mobile_Destination_Rate")
      stub_api_request(result: "OK")
      client.set_tp_rating_plan(
        tp_id: "cgrates_client_test",
        id: "Test_Rating_Plan",
        rating_plan_bindings: [
          {
            timing_id: "*any",
            weight: 10,
            destination_rates_id: "Cambodia_Mobile_Destination_Rate"
          }
        ],
        **params
      )
    end
  end
end
