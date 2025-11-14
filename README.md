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
=> #<data Response id="90ca9f67-0fc3-43a3-8856-7ce9209c668b", result="Pong">

client.set_tp_destination(tp_id: "cgrates_client_test", id: "Cambodia_Mobile", prefixes: ["85510", "85512", "85597"])
=> #<data Response id="875efcee-b480-4268-a41f-b5946d68597b", result="OK">

client.get_tp_destination(tp_id: "cgrates_client_test", id: "Cambodia_Mobile")
=> #<data Response id="3dccb2d6-8020-4891-bc21-ff954425bb0d", result={"TPid" => "cgrates_client_test", "ID" => "Cambodia_Mobile", "Prefixes" => ["85510", "85512", "85597"]}>
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/somleng/cgrates-ruby.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
