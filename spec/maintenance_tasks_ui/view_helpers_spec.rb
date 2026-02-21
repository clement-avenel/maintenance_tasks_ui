# frozen_string_literal: true

require "rails_helper"

RSpec.describe MaintenanceTasksUi::ViewHelpers, type: :helper do
  describe "#maintenance_tasks_ui_stylesheet_link_tag" do
    it "returns a stylesheet link tag for the UI" do
      result = helper.maintenance_tasks_ui_stylesheet_link_tag
      expect(result).to include("maintenance_tasks_ui/base")
      expect(result).to include('media="all"')
    end

    it "includes the correct asset path" do
      result = helper.maintenance_tasks_ui_stylesheet_link_tag
      expect(result).to match(/maintenance_tasks_ui\/base/)
    end

    it "returns an HTML link tag" do
      result = helper.maintenance_tasks_ui_stylesheet_link_tag
      expect(result).to match(/<link/)
      expect(result).to match(/rel=["']stylesheet["']/)
    end
  end
end
