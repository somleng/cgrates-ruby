require "faraday"
require "json"

module CGRateS
  class FakeClient
    def get_cdrs(...)
      build_response(
        result: [
          {
            "OrderID" => 1,
            "Account" => SecureRandom.uuid,
            "Cost" => 100,
            "ExtraFields" => {},
            "ExtraInfo" => nil
          }
        ]
      )
    end

    def get_account(...)
      build_response(
        result: {
          "BalanceMap" => nil
        }
      )
    end

    def method_missing(...)
      build_response(result: "OK")
    end

    private

    def build_response(**)
      Response.new(
        id: SecureRandom.uuid,
        result: "OK",
        **
      )
    end
  end
end
