# frozen_string_literal: true

require_relative "lib/maintenance_tasks_ui/version"

Gem::Specification.new do |spec|
  spec.name          = "maintenance_tasks_ui"
  spec.version       = MaintenanceTasksUi::VERSION
  spec.authors       = ["Clément Avenel"]

  spec.summary       = "A modern, polished UI for the Maintenance Tasks gem"
  spec.description   = "Provides a beautiful, modern UI for Maintenance Tasks with easy customization via CSS variables"
  spec.homepage      = "https://github.com/clement-avenel/maintenance_tasks_ui"
  spec.license       = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "railties", ">= 7.0"
  spec.add_dependency "maintenance_tasks", ">= 2.0"
  spec.add_dependency "kaminari", ">= 1.0"

  spec.add_development_dependency "bundler", ">= 2.0"
  spec.add_development_dependency "rspec-rails", "~> 6.0"
  spec.add_development_dependency "capybara", "~> 3.0"
  spec.add_development_dependency "sqlite3", "~> 2.9"
end
