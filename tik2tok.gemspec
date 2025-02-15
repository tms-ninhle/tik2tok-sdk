# frozen_string_literal: true

require_relative "lib/tik2tok/version"

Gem::Specification.new do |spec|
  spec.name = "tik2tok"
  spec.version = Tik2tok::VERSION
  spec.authors = ["Ninh Lee Tomosia"]
  spec.email = ["ninh.le@tomosia.com"]

  spec.summary = "Tiktok authentication"
  spec.description = "Authentication with Tiktok for Rails application"
  spec.homepage = "https://github.com/tms-ninhle/tik2tok"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/tms-ninhle/tik2tok"
  spec.metadata["changelog_uri"] = "https://github.com/tms-ninhle/tik2tok/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "httparty", "0.22.0"
  spec.add_dependency "mime-types", "3.6.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
