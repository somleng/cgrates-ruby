require "base64"

module CGRateS
  RSpec.describe Client do
    describe "#ping" do
      it "returns pong" do
        client = build_client(host: "http://localhost:2080", username: "username", password: "password")
        stub_api_request(host: "http://localhost:2080", result: "Pong")

        response = client.ping

        expect(response).to have_attributes(result: "Pong")
        expect(WebMock).to have_requested(:post, "http://localhost:2080/jsonrpc").with(
          body: hash_including("method" => "APIerSv2.Ping"),
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
          result: {
            "TPid" => "cgrates_client_test",
            "ID" => "Cambodia_Mobile",
            "Prefixes" => [ "85510", "85512", "85597" ]
          }
        )
      end
    end

    it "handles invalid http responses" do
      client = build_client
      stub_api_request(status: 500)

      expect { client.ping }.to raise_error(CGRateS::Client::InvalidResponseError, /HTTP ERROR: 500/)
    end

    def build_client(**options)
      Client.new(host: "http://localhost:2080", **options)
    end

    def stub_api_request(**options)
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
  end
end
