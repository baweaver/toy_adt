# frozen_string_literal: true

require_relative "lib/toy_adt/version"

Gem::Specification.new do |spec|
  spec.name = "toy_adt"
  spec.version = ToyAdt::VERSION
  spec.authors = ["Brandon Weaver"]
  spec.email = ["keystonelemur@gmail.com"]

  spec.summary = "Toy implementation of ADTs in Ruby for the Ruby in FantasyLand series"
  spec.homepage = "https://www.github.com/baweaver/toy_adt"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rspec"
  spec.add_development_dependency "guard-rspec"

  spec.add_dependency "sorbet"
  spec.add_dependency "sorbet-runtime"
end
