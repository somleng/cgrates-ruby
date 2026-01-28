require "faraday"
require "json"

module CGRateS
  class Client
    class APIError < StandardError
      attr_reader :response

      def initialize(message, response:)
        super(message)
        @response = response
      end
    end

    class NotFoundError < APIError; end
    class MaxUsageExceededError < APIError; end

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
      tp_resource_request("APIerSv1.GetTPDestination", **)
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
      tp_resource_request("APIerSv1.GetTPRate", **)
    end

    def remove_tp_rate(**)
      tp_resource_request("APIerSv1.RemoveTPRate", **)
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
      tp_resource_request("APIerSv1.GetTPDestinationRate", **)
    end

    def remove_tp_destination_rate(**)
      tp_resource_request("APIerSv1.RemoveTPDestinationRate", **)
    end

    def set_tp_rating_plan(rating_plan_bindings:, **)
      set_tp_resource("APIerSv1.SetTPRatingPlan", **) do
        {
          "RatingPlanBindings" => rating_plan_bindings.map do
            {
              "TimingId" => it[:timing_id],
              "Weight" => it[:weight],
              "DestinationRatesId" => it[:destination_rates_id]
            }
          end
        }
      end
    end

    def get_tp_rating_plan(**)
      tp_resource_request("APIerSv1.GetTPRatingPlan", **)
    end

    def remove_tp_rating_plan(**)
      tp_resource_request("APIerSv1.RemoveTPRatingPlan", **)
    end

    def set_tp_rating_profile(rating_plan_activations:, load_id:, category:, subject:, tenant: nil, **)
      set_tp_resource("APIerSv1.SetTPRatingProfile", id: nil, **) do
        {
          "RatingPlanActivations" => rating_plan_activations.map do
            {
              "ActivationTime" => it[:activation_time],
              "FallbackSubjects" => it[:fallback_subjects],
              "RatingPlanId" => it[:rating_plan_id]
            }
          end,
          "LoadId" => load_id,
          "Category" => category,
          "Subject" => subject,
          "Tenant" => tenant
        }
      end
    end

    def get_tp_rating_profile(tp_id:, load_id:, tenant:, category:, subject:)
      tp_resource_request(
        "APIerSv1.GetTPRatingProfile",
        tp_id:,
        id: [ load_id, tenant, category, subject ].join(":"),
        id_key: "RatingProfileId"
      )
    end

    def remove_tp_rating_profile(tp_id:, load_id:, tenant:, category:, subject:)
      tp_resource_request(
        "APIerSv1.RemoveTPRatingProfile",
        tp_id:,
        id: [ load_id, tenant, category, subject ].join(":"),
        id_key: "RatingProfileId"
      )
    end

    def set_account(account:, tenant: nil, **)
      api_request(
        "APIerSv2.SetAccount",
        {
          "Tenant" => tenant,
          "Account" => account,
          **
        }
      )
    end

    def get_account(account:, tenant: nil, **)
      api_request(
        "APIerSv2.GetAccount",
        {
          "Tenant" => tenant,
          "Account" => account,
          **
        }
      )
    end

    def remove_account(account:, tenant: nil, **)
      api_request(
        "APIerSv1.RemoveAccount",
        {
          "Tenant" => tenant,
          "Account" => account,
          **
        }
      )
    end

    def load_tariff_plan_from_stor_db(tp_id:, dry_run: false, validate: true, **)
      api_request(
        "APIerSv1.LoadTariffPlanFromStorDb",
        "TPid" => tp_id,
        "DryRun" => dry_run,
        "Validate" => validate,
        **
      )
    end

    def add_balance(**)
      balance_request("APIerSv1.AddBalance", **)
    end

    def debit_balance(**)
      balance_request("APIerSv1.DebitBalance", **)
    end

    def get_cdrs(tenants: [], origin_ids: [], not_costs: [], order_by: "OrderID", extra_args: {}, limit: nil, **)
      api_request(
        "APIerSv2.GetCDRs",
        "Tenants" => tenants,
        "OrderBy" => order_by,
        "ExtraArgs" => extra_args,
        "Limit" => limit,
        "OriginIDs" => origin_ids,
        "NotCosts" => not_costs,
        **
      )
    end

    def process_external_cdr(category:, request_type:, tor:, tenant:, account:, subject: nil, destination:, answer_time:, setup_time:, usage:, origin_id:, **)
      api_request(
        "CDRsV1.ProcessExternalCDR",
        "Category" => category,
        "RequestType" => request_type,
        "ToR" => tor,
        "Tenant" => tenant,
        "Account" => account,
        "Subject" => subject,
        "Destination" => destination,
        "AnswerTime" => answer_time,
        "SetupTime" => setup_time,
        "Usage" => usage,
        "OriginId" => origin_id,
        **
      )
    end

    def set_charger_profile(id:, tenant:, **)
      api_request(
        "APIerSv1.SetChargerProfile",
        "ID" => id,
        "Tenant" => tenant,
        **
      )
    end

    def get_charger_profile(id:, tenant:, **)
        api_request(
        "APIerSv1.GetChargerProfile",
        "ID" => id,
        "Tenant" => tenant,
        **
      )
    end

    def remove_charger_profile(id:, tenant:, **)
      api_request(
        "APIerSv1.RemoveChargerProfile",
        "ID" => id,
        "Tenant" => tenant,
        **
      )
    end

    def get_cost(tenant:, subject:, category:, destination:, usage:, **)
      api_request(
        "APIerSv1.GetCost",
        "Tenant" => tenant,
        "Subject" => subject,
        "Category" => category,
        "Destination" => destination,
        "Usage" => usage,
        **
      )
    end

    def get_max_session_time(tenant:, account:, category:, destination:, time_start:, time_end:, **)
      api_request(
        "Responder.GetMaxSessionTime",
        "Tenant" => tenant,
        "Account" => account,
        "Category" => category,
        "Destination" => destination,
        "TimeStart" => time_start,
        "TimeEnd" => time_end,
        **
      )
    end

    private

    def balance_request(method, account:, tenant:, balance_type:, value:, balance:, overwrite: false, action_extra_data: {}, cdrlog: false, **)
      api_request(
        method,
        {
          "Account" => account,
          "Tenant" => tenant,
          "BalanceType" => balance_type,
          "Value" => value,
          "Balance" => {
            "ID" => balance[:id],
            "ExpiryTime" => balance.fetch(:expiry_time, "*unlimited"),
            "RatingSubject" => balance[:rating_subject],
            "Categories" => balance[:categories],
            "DestinationIDs" => balance.fetch(:destination_ids, "*any"),
            "TimingIDs" => balance[:timing_ids],
            "Weight" => balance.fetch(:weight, 10),
            "SharedGroups" => balance[:shared_groups],
            "Blocker" => balance.fetch(:blocker, false),
            "Disabled" => balance.fetch(:disabled, false)
          },
          "ActionExtraData" => action_extra_data,
          "Overwrite" => overwrite,
          "Cdrlog" => cdrlog,
          **
        }
      )
    end

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
        raise(
          error_class_from(error_message).new(
            "Invalid response from CGRateS API: #{error_message}",
            response: response.body
          )
        )
      end

      Response.new(
        id: response.body.fetch("id"),
        result: response.body.fetch("result")
      )
    end

    def error_class_from(error_message)
      case error_message
      when "NOT_FOUND"
        NotFoundError
      when /MAX_USAGE_EXCEEDED/
        MaxUsageExceededError
      else
        APIError
      end
    end

    def set_tp_resource(method, tp_id:, id:, &)
      api_request(method, { "TPid" => tp_id, "ID" => id }.merge(yield))
    end

    def tp_resource_request(method, tp_id:, id:, id_key: "ID")
      api_request(method, { "TPid" => tp_id, id_key => id })
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
