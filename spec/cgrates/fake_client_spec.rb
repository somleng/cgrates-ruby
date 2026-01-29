require "spec_helper"

module CGRateS
  RSpec.describe FakeClient do
    describe "#ping" do
      it "returns a fake response" do
        client = build_client

        response = client.ping

        expect(response).to have_attributes(
          id: a_kind_of(String),
          result: "OK"
        )
      end
    end

    describe "#get_account" do
      it "returns a fake response" do
        client = build_client

        response = client.get_account

        expect(response).to have_attributes(
          result: hash_including(
            "BalanceMap" => nil
          )
        )
      end
    end

    describe "#get_cdrs" do
      it "returns a fake response" do
        client = build_client

        response = client.get_cdrs

        expect(response).to have_attributes(
          result: contain_exactly(
            hash_including(
              "OrderID" => a_kind_of(Integer),
              "Account" => a_kind_of(String),
              "Cost" => a_kind_of(Integer),
            )
          )
        )
      end
    end

    describe "#get_cost" do
      it "returns a fake response" do
        client = build_client

        response = client.get_cost(
          tenant: "cgrates.org",
          subject: "my-account",
          category: "call",
          destination: "85510",
          usage: "100"
        )

        expect(response).to have_attributes(
          result: hash_including(
            "Usage" => a_kind_of(Integer),
            "Cost" => a_kind_of(Integer),
          )
        )
      end
    end

    describe "#get_max_session_time" do
      it "returns a fake response" do
        client = build_client

        response = client.get_max_session_time(
          tenant: "cgrates.org",
          account: "sample-account-sid",
          category: "call",
          destination: "85510",
          time_start: "0001-01-01T00:00:00Z",
          time_end: "0001-01-01T03:00:01Z"
        )

        expect(response).to have_attributes(
          result: a_kind_of(Integer)
        )
      end
    end

    def build_client(**)
      FakeClient.new(**)
    end
  end
end
