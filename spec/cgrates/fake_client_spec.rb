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

    def build_client(**)
      FakeClient.new(**)
    end
  end
end
