# frozen_string_literal: true

require "rails_helper"

RSpec.describe MaintenanceTasksUi::Engine do
  describe "initialization" do
    let(:app) { Rails.application }

    it "adds asset paths to the Rails application" do
      engine = MaintenanceTasksUi::Engine
      stylesheet_path = engine.root.join("app", "assets", "stylesheets").to_s
      javascript_path = engine.root.join("app", "assets", "javascripts").to_s

      expect(app.config.assets.paths).to include(stylesheet_path)
      expect(app.config.assets.paths).to include(javascript_path)
    end

    it "includes view helpers in ActionView" do
      expect(ActionView::Base.included_modules).to include(MaintenanceTasksUi::ViewHelpers)
    end

    it "prepends view path to MaintenanceTasks::ApplicationController" do
      engine = MaintenanceTasksUi::Engine
      view_path = engine.root.join("app", "views").to_s

      # Trigger the to_prepare callback
      Rails.application.config.to_prepare.call

      controller_class = MaintenanceTasks::ApplicationController
      expect(controller_class.view_paths.map(&:to_s)).to include(view_path)
    end
  end
end
