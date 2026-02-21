# frozen_string_literal: true

module Maintenance
  class MyTask < MaintenanceTasks::Task
    def collection
      # Collection to be iterated over
      # Must be Active Record Relation or Array
      [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    end

    def process(element)
      # The work to be done in a single iteration of the task.
      # This should be idempotent, as the same element may be processed more
      # than once if the task is interrupted and resumed.
      sleep 1 # Use a short delay so the task completes when testing (was 1000)
      puts "Processing element: #{element}"
    end

    def count
      # Return the number of items so the run gets tick_total and the progress bar can show 1–99% while running.
      collection.size
      # Return nil if the task is not iterable.
      # Return nil if the task is not iterable.
      # Return nil if the task is not iterable.
      # Return nil if the task is not iterable.
      # Return nil if the task is not iterable.
      # Return nil if the task is not iterable.
      # Return nil if the task is not iterable.
      # Return nil if the task is not iterable.
      # Return nil if the task is not iterable.
      # Return nil if the task is not iterable.
      # Return nil if the task is not iterable.
      # Return nil if the task is not iterable.
      # Return nil if the task is not iterable.
      # Return nil if the task is not iterable.
      # Return nil if the task is not iterable.
      # Return nil if the task is not iterable.
      # Return nil if the task is not iterable.
      # Return nil if the task is not iterable.
      # Return nil if the task is not iterable.
      # Return nil if the task is not iterable.
      # Return nil if the task is not iterable.
      # Return nil if the task is not iterable.
      # Return nil if the task is not iterable.
      # Return nil if the task is not iterable.
      # Return nil if the task is not iterable.
      # Return nil if the task is not iterable.
      # Return nil if the task is not iterable.
      # Return nil if the task is not iterable.
      
    end
  end
end
