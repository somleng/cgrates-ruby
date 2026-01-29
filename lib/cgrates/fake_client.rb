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
          "ID" => "c7f745f8-d0d4-47f0-bcc3-064ed2bc6ae0:a42f542d-fe7f-4b4f-8192-720fdf084e7f",
          "BalanceMap" => nil,
          "UnitCounters" => nil,
          "ActionTriggers" => nil,
          "AllowNegative" => false,
          "Disabled" => false,
          "UpdateTime" => "2026-01-27T10:38:51.705193699Z"
        }
      )
    end

    def get_cost(...)
      build_response(
        result: {
          "CGRID" => "",
          "RunID" => "",
          "StartTime" => "0001-01-01T00:00:00Z",
          "Usage" => 60000000000,
          "Cost" => 7,
          "Charges" => [
            {
              "RatingID" => "a731d36",
              "Increments" => [
                {
                  "Usage" => 0,
                  "Cost" => 0,
                  "AccountingID" => "",
                  "CompressFactor" => 1
                },
                {
                  "Usage" => 60000000000,
                  "Cost" => 7,
                  "AccountingID" => "",
                  "CompressFactor" => 1
                }
              ],
              "CompressFactor" => 1
            }
          ],
          "AccountSummary" => nil,
          "Rating" => {
            "a731d36" => {
              "ConnectFee" => 0,
              "RoundingMethod" => "*up",
              "RoundingDecimals" => 4,
              "MaxCost" => 0,
              "MaxCostStrategy" => "",
              "TimingID" => "f3b57b4",
              "RatesID" => "c269f2f",
              "RatingFiltersID" => "ed17fd5"
            }
          },
          "Accounting" => {},
          "RatingFilters" => {
            "ed17fd5" => {
              "DestinationID" => "TEST_CATCHALL",
              "DestinationPrefix" => "8",
              "RatingPlanID" => "TEST_CATCHALL",
              "Subject" => "*out:c7f745f8-d0d4-47f0-bcc3-064ed2bc6ae0:call:a42f542d-fe7f-4b4f-8192-720fdf084e7f"
            }
          },
          "Rates" => {
            "c269f2f" => [
              {
                "GroupIntervalStart" => 0,
                "Value" => 7,
                "RateIncrement" => 60000000000,
                "RateUnit" => 60000000000
              }
            ]
          },
          "Timings" => {
            "f3b57b4" => {
              "Years" => [],
              "Months" => [],
              "MonthDays" => [],
              "WeekDays" => [],
              "StartTime" => "00:00:00"
            }
          }
        }
      )
    end

    def get_max_session_time(...)
      build_response(
        result: 100
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
