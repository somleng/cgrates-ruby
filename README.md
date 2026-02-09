# CGRateS Ruby Client

[![Build](https://github.com/somleng/cgrates-ruby/actions/workflows/build.yml/badge.svg)](https://github.com/somleng/cgrates-ruby/actions/workflows/build.yml)

`cgrates` is a lightweight Ruby client for the [CGRateS](https://github.com/cgrates/cgrates) real-time charging and rating engine. It provides a simple, idiomatic interface for interacting with the CGRateS JSON-RPC API.

---

## Features

- Simple Ruby interface for CGRateS API calls
- JSON-RPC client support
- Easy configuration
- Minimal dependencies

---

## Installation

Install the gem and add to the application's Gemfile by executing:

```ruby
bundle add "cgrates"
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install cgrates
```

## Usage

```ruby
client = CGRateS::Client.new(host: "http://localhost:2080")
client.ping
# => #<data CGRateS::Response id="90ca9f67-0fc3-43a3-8856-7ce9209c668b", result="Pong">

client.set_tp_destination(tp_id: "cgrates_client_test", id: "Cambodia_Mobile", prefixes: ["85510", "85512", "85597"])
# => #<data CGRateS::Response id="875efcee-b480-4268-a41f-b5946d68597b", result="OK">

client.get_tp_destination(tp_id: "cgrates_client_test", id: "Cambodia_Mobile")
# => #<data CGRateS::Response id="3dccb2d6-8020-4891-bc21-ff954425bb0d", result={"TPid" => "cgrates_client_test", "ID" => "Cambodia_Mobile", "Prefixes" => ["85510", "85512", "85597"]}>

client.set_tp_rate(tp_id: "cgrates_client_test", id: "Cambodia_Mobile", rate_slots: [{ rate: 0.05, rate_unit: "60s", rate_increment: "60s" }])
# => #<data CGRateS::Response id="0ae676c9-b12b-4da3-a2e2-bd7ae7c941da", result="OK">

client.get_tp_rate(tp_id: "cgrates_client_test", id: "Cambodia_Mobile")
# =>
# #<data CGRateS::Response
# #  id="10091598-fddb-4d55-8914-5e693a731dc5",
# #  result={"TPid" => "cgrates_client_test", "ID" => "Cambodia_Mobile", "RateSlots" => [{"ConnectFee" => 0, "Rate" => 0.05, "RateUnit" => "60s", "RateIncrement" => "60s", "GroupIntervalStart" => ""}]}>

client.set_tp_destination_rate(tp_id: "cgrates_client_test", id: "Cambodia_Mobile", destination_rates: [{rounding_decimals: 4, rate_id: "Cambodia_Mobile", destination_id: "Cambodia_Mobile", rounding_method: "*up" }])
# => #<data CGRateS::Response id="b3c02025-d2d3-430f-981f-cc4065a278e5", result="OK">

client.get_tp_destination_rate(tp_id: "cgrates_client_test", id: "Cambodia_Mobile")
#<data CGRateS::Response
#  id="67c7972f-e059-43c3-8cd8-c61471c2c624",
#  result=
#   {"TPid" => "cgrates_client_test",
#    "ID" => "Cambodia_Mobile",
#    "DestinationRates" => [{"DestinationId" => "Cambodia_Mobile", "RateId" => "Cambodia_Mobile", "Rate" => nil, "RoundingMethod" => "*up", "RoundingDecimals" => 4, "MaxCost" => 0, "MaxCostStrategy" => ""}]}>
client.set_tp_rating_plan(tp_id: "cgrates_client_test", id: "Test_Rating_Plan", rating_plan_bindings: [{ weight: 10, timing_id: "*any", destination_rates_id: "Cambodia_Mobile" }])
# => #<data CGRateS::Response id="f7e9232d-1c5a-42e8-bfb6-072ae1124698", result="OK">

client.get_tp_rating_plan(tp_id: "cgrates_client_test", id: "Test_Rating_Plan")
# => <data CGRateS::Response
# id="ee134421-01dd-4a6b-b7a4-ee9980dc466e",
# result={"TPid" => "cgrates_client_test", "ID" => "Test_Rating_Plan", "RatingPlanBindings" => [{"DestinationRatesId" => "Cambodia_Mobile", "TimingId" => "*any", "Weight" => 10}]}>

client.set_tp_rating_profile(
  tp_id: "cgrates_client_test",
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
#=> #<data CGRateS::Response id="4827cf6e-54e2-4699-8801-d73b34b8331e", result="OK">

client.get_tp_rating_profile(
  tp_id: "cgrates_client_test",
  load_id: "TEST",
  tenant: "cgrates.org",
  category: "call",
  subject: "my-account"
)
# => #<data CGRateS::Response
# id="210b6cc6-e7be-4a3f-b657-0c5e5f0666b2",
# result=
#  {"TPid" => "cgrates_client_test",
#   "LoadId" => "TEST",
#   "Tenant" => "cgrates.org",
#   "Category" => "call",
#   "Subject" => "my-account",
#   "RatingPlanActivations" => [{"ActivationTime" => "2025-12-03T19:55:23+07:00", "RatingPlanId" => "Test_Rating_Plan", "FallbackSubjects" => "foobar"}]}>
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/somleng/cgrates-ruby.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
