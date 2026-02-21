# frozen_string_literal: true

require_relative "tasks_controller_extension"
require_relative "view_helpers"

module MaintenanceTasksUi
  class Engine < ::Rails::Engine
    isolate_namespace MaintenanceTasksUi

    initializer "maintenance_tasks_ui.assets", group: :all do |app|
      return unless app.config.respond_to?(:assets) && app.config.assets

      app.config.assets.paths << root.join("app", "assets", "stylesheets").to_s
      app.config.assets.paths << root.join("app", "assets", "javascripts").to_s
      app.config.assets.precompile += %w[maintenance_tasks_ui/base.css]
    end

    initializer "maintenance_tasks_ui.view_helpers" do
      ActiveSupport.on_load(:action_view) { include MaintenanceTasksUi::ViewHelpers }
    end

    config.to_prepare do
      next unless defined?(MaintenanceTasks) && MaintenanceTasks.const_defined?(:ApplicationController)

      MaintenanceTasks::ApplicationController.prepend_view_path(Engine.root.join("app", "views").to_s)
      MaintenanceTasks::ApplicationController.helper(MaintenanceTasksUi::ViewHelpers)
      MaintenanceTasks::ApplicationController.class_eval do
        content_security_policy do |policy|
          policy.style_src_elem(:self)
        end
      end
      MaintenanceTasks::RunsController.helper(MaintenanceTasksUi::ViewHelpers) if MaintenanceTasks.const_defined?(:RunsController)

      if MaintenanceTasks.const_defined?(:TasksController)
        MaintenanceTasks::TasksController.prepend(MaintenanceTasksUi::TasksControllerExtension)
        MaintenanceTasks::TasksController.class_eval do
          def self.local_prefixes
            ["maintenance_tasks"]
          end
          remove_instance_variable(:@_prefixes) if instance_variable_defined?(:@_prefixes)
        end
      end
    end
  end
end
