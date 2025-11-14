# frozen_string_literal: true

require_relative "lib/cgrates/version"

Gem::Specification.new do |spec|
  spec.name = "cgrates"
  spec.version = CGRateS::VERSION
  spec.authors = [ "David Wilkie" ]
  spec.email = [ "dwilkie@gmail.com" ]

  spec.summary = "Ruby client for the CGRateS real-time charging and rating API."
  spec.description = <<~DESC
    A lightweight Ruby client for the CGRateS charging and rating engine.
    Provides a simple, idiomatic interface to the CGRateS JSON-RPC and HTTP APIs.
  DESC
  spec.homepage = "https://github.com/somleng/cgrates-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.4.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/somleng/cgrates-ruby"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .github/ .rubocop.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = [ "lib" ]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "faraday"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
