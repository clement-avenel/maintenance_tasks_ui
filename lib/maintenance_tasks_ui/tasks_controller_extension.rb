# frozen_string_literal: true

module MaintenanceTasksUi
  module TasksControllerExtension
    SORT_STATUS_PRIORITY = {
      "running" => 0, "pausing" => 1, "paused" => 2, "enqueued" => 3,
      "succeeded" => 4, "errored" => 5, "cancelling" => 6, "cancelled" => 7, "interrupted" => 8
    }.freeze

    def index
      all_tasks = MaintenanceTasks::TaskDataIndex.available_tasks.to_a

      @search_query = params[:search]
      @status_filter = params[:status] || "all"
      @sort_column = params[:sort] || "last_run"
      @sort_direction = params[:direction] || "desc"

      all_tasks = all_tasks.select { |t| t.name.downcase.include?(@search_query.downcase) } if @search_query.present?
      all_tasks = all_tasks.select { |t| t.category.to_s == @status_filter } if @status_filter.present? && @status_filter != "all"
      all_tasks = sort_tasks(all_tasks, @sort_column, @sort_direction)

      @tasks = defined?(Kaminari) ? Kaminari.paginate_array(all_tasks).page(params[:page]).per(10) : all_tasks
      @available_tasks = all_tasks.group_by(&:category)
    end

    private

    def sort_tasks(tasks, column, direction)
      sorted = tasks.sort { |a, b| sort_compare(a, b, column) }
      direction == "desc" ? sorted.reverse : sorted
    end

    def sort_compare(a, b, column)
      case column
      when "name" then a.name <=> b.name
      when "status"
        (a.category.to_s <=> b.category.to_s).nonzero? || (a.status.to_s <=> b.status.to_s)
      when "last_run"
        (a.related_run&.created_at || Time.at(0)) <=> (b.related_run&.created_at || Time.at(0))
      when "progress" then progress_compare(a.related_run, b.related_run)
      else a.name <=> b.name
      end
    end

    def progress_compare(a_run, b_run)
      return 0 if a_run.nil? && b_run.nil?
      return 1 if a_run.nil?
      return -1 if b_run.nil?

      cmp = (SORT_STATUS_PRIORITY[a_run.status.to_s] || 9) <=> (SORT_STATUS_PRIORITY[b_run.status.to_s] || 9)
      return cmp if cmp != 0

      progress_value(a_run) <=> progress_value(b_run)
    end

    def progress_value(run)
      run.tick_total.to_i.positive? ? (run.tick_count.to_f / run.tick_total) : 0
    end
  end
end
