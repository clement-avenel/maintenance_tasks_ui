# frozen_string_literal: true

module MaintenanceTasksUi
  module ViewHelpers
    THEME_STATUS_TAG_CLASSES = {
      "new" => ["is-secondary"],
      "enqueued" => ["is-primary", "is-light"],
      "running" => ["is-primary"],
      "interrupted" => ["is-primary", "is-light"],
      "pausing" => ["is-primary", "is-light"],
      "paused" => ["is-primary", "is-light"],
      "succeeded" => ["is-success"],
      "cancelling" => ["is-primary", "is-light"],
      "cancelled" => ["is-dark"],
      "errored" => ["is-danger"],
    }.freeze

    TASK_TABLE_COLUMNS = [
      { key: :name, label: "Task Name", sort_key: "name", sortable: true, cell_class: "task-name-cell", min_width: "200px" },
      { key: :items_processed, label: "Items", sortable: false, cell_class: "items-processed-cell", min_width: "60px", align: "right" },
      { key: :last_run, label: "Last Run", sort_key: "last_run", sortable: true, cell_class: "date-cell", min_width: "40px" },
      { key: :progress, label: "Progress", sort_key: "progress", sortable: true, cell_class: "progress-cell", width: "400px", min_width: "340px" },
      { key: :status, label: "Status", sort_key: "status", sortable: true, cell_class: "status-cell", width: "120px" },
      { key: :go, label: nil, sortable: false, cell_class: "table-cell-go", header_aria_label: "Open" },
    ].freeze

    def theme_status_classes(status)
      THEME_STATUS_TAG_CLASSES[status.to_s] || ["is-light"]
    end

    def maintenance_tasks_ui_app_name
      Rails.application.class.module_parent_name
    end

    def theme_template_exists?(path)
      lookup_context.template_exists?(path, [], true)
    end

    def status_tag(status)
      tag.span(status.to_s.capitalize, class: %w[tag has-text-weight-medium pr-2 mr-4] + theme_status_classes(status))
    end

    def progress_bar_only(run)
      return unless run.respond_to?(:started?) && run.started?

      value = run.respond_to?(:tick_count) ? run.tick_count&.to_i : nil
      total = run.respond_to?(:tick_total) ? run.tick_total&.to_i : nil
      max = total.to_i.positive? ? [total, value.to_i].max : value
      status_classes = run.respond_to?(:status) ? theme_status_classes(run.status) : ["is-light"]

      if value.present? && max.present? && max.positive?
        max_i = [max, 1].max
        value_i = [value, max_i].min
        pct = (100.0 * value_i / max_i).round(0)
        bar = tag.progress(value: value_i, max: max_i, class: ["progress", "mt-0"] + status_classes)
        content_tag(:div, bar + content_tag(:span, "#{pct}%", class: "progress-percent"), class: "progress-cell-inner")
      else
        tag.progress(value: nil, max: nil, class: ["progress", "progress--indeterminate", "mt-0"] + status_classes)
      end
    end

    def items_processed_display(run)
      return nil unless run.respond_to?(:tick_count)

      count = run.tick_count.to_i
      total = run.respond_to?(:tick_total) ? run.tick_total.to_i : 0
      total.positive? && count <= total ? "#{number_with_delimiter(count)} / #{number_with_delimiter(total)}" : number_with_delimiter(count)
    end

    def task_table_columns
      TASK_TABLE_COLUMNS
    end

    def show_empty_state?
      return false if @search_query.present? || (@status_filter.present? && @status_filter != "all")

      MaintenanceTasks::TaskDataIndex.available_tasks.count.zero?
    rescue StandardError
      @tasks.empty?
    end

    def task_table_th_class(col)
      [col[:cell_class].to_s, ("sortable" if col[:sortable]), ("sorted-#{@sort_direction}" if col[:sortable] && col[:sort_key].to_s == @sort_column)].compact.join(" ")
    end

    def task_table_th_style(col)
      [col[:width].present? && "width: #{col[:width]}", col[:min_width].present? && "min-width: #{col[:min_width]}", col[:align].present? && "text-align: #{col[:align]}"].compact.join("; ")
    end

    def task_table_cell_content(column_key, task, run)
      case column_key.to_sym
      when :name
        content_tag(:div, class: "task-name") { link_to task.name, task_path(task.name), class: "task-link" }
      when :progress
        (run && progress_bar_only(run)) || content_tag(:span, "—", class: "text-muted")
      when :items_processed
        (run && (text = items_processed_display(run))) ? text : content_tag(:span, "—", class: "text-muted")
      when :last_run
        run ? content_tag(:time, "#{time_ago_in_words(run.created_at)} ago", datetime: run.created_at.iso8601, class: "date-time") + content_tag(:div, run.created_at.strftime("%b %d, %Y at %I:%M %p"), class: "date-full") : content_tag(:span, "—", class: "text-muted")
      when :status
        status_tag(task.status)
      when :go
        link_to task_path(task.name), class: "table-go-link", "aria-label": "View #{task.name}" do
          content_tag(:span, "›", class: "table-go-icon", "aria-hidden": "true")
        end
      else
        content_tag(:span, "—", class: "text-muted")
      end
    end

    def maintenance_tasks_ui_stylesheet_link_tag
      stylesheet_link_tag "maintenance_tasks_ui/base", media: :all
    end

    def tasks_index_back_url
      return tasks_path if request.referer.blank?
      path = URI.parse(request.referer).path
      path == tasks_path ? request.referer : tasks_path
    rescue URI::InvalidURIError
      tasks_path
    end

    def sort_link(column, label, search_query: nil, status_filter: nil, sort_column: nil, sort_direction: nil)
      new_direction = (sort_column == column && sort_direction == "asc") ? "desc" : "asc"
      link_to tasks_path(search: search_query, status: status_filter, sort: column, direction: new_direction), class: "sort-link" do
        content_tag(:span, label, class: "sort-label") + content_tag(:span, "", class: "sort-indicator")
      end
    end
  end
end
