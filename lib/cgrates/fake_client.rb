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

    def method_missing(method_name, *)
      return build_response(result: "OK")  if Client.instance_methods(false).include?(method_name.to_sym)

      super
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
