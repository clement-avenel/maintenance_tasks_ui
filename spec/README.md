# RSpec Test Suite

This directory contains the RSpec test suite for the Maintenance Tasks UI gem.

## Running Tests

Run all tests:
```bash
bundle exec rspec
```

Run a specific test file:
```bash
bundle exec rspec spec/maintenance_tasks_ui/engine_spec.rb
```

Run tests with documentation format:
```bash
bundle exec rspec --format documentation
```

## Test Structure

- `spec/maintenance_tasks_ui/` - Tests for the main gem components
  - `engine_spec.rb` - Tests for the Rails Engine initialization
  - `view_helpers_spec.rb` - Tests for view helper methods

- `spec/views/` - Tests for view templates
  - `layouts/maintenance_tasks/application_spec.rb` - Tests for the main layout

- `spec/support/` - Support files and shared examples

## Dummy app

The dummy app (`spec/dummy`) is set up so the Maintenance Tasks UI dashboard chart works with Chart.js: the content security policy allows scripts from `https://cdn.jsdelivr.net` (where Chart.js is loaded). Host apps that use the UI should allow this origin for `script-src-elem` if they want the interactive dashboard chart.

## Setup

Before running tests, make sure you have:

1. Installed dependencies:
   ```bash
   bundle install
   ```

2. Set up the dummy Rails app by following the steps in `spec/dummy/README.md` (from the project root: `cd spec/dummy`, then `bundle install`, `rails generate maintenance_tasks:install`, `rails db:create db:migrate`).

   The dummy app provides a real Rails environment to test the UI integration.

## Running maintenance tasks in the dummy app

When you click **Run** on a task in the UI, Maintenance Tasks **enqueues a background job**. For the task to actually run, a **job worker** must be processing the queue.

The dummy app uses **Solid Queue** (see `spec/dummy/Gemfile`). You have two options:

### Option A: Run the web server with Solid Queue inside Puma (easiest)

From the **project root**:

```bash
cd spec/dummy
SOLID_QUEUE_IN_PUMA=1 bundle exec rails server
```

This starts Puma with the Solid Queue plugin, so jobs are processed in the same process. The task will move from “Enqueued” to “Running” and then “Succeeded” (or “Errored” if it fails).

### Option B: Run Solid Queue in a separate process

1. **Install Solid Queue** in the dummy app (if not already done):

   ```bash
   cd spec/dummy
   bundle exec rails solid_queue:install
   bundle exec rails db:prepare   # or db:migrate if you use migrations for the queue
   ```

2. **Start the web server** (in one terminal):

   ```bash
   cd spec/dummy
   bundle exec rails server
   ```

3. **Start the job worker** (in another terminal):

   ```bash
   cd spec/dummy
   bundle exec rails solid_queue:start
   # or: bundle exec ./bin/jobs   # if the install added bin/jobs
   ```

Then run a task from the UI; the worker will process it.

### If a task stays “Running” forever

- Ensure a worker is running (Option A or B above).
- The sample task `Maintenance::MyTask` uses `sleep 1` per item (10 items), so it should finish in about 10 seconds. If you changed it to `sleep 1000`, each item would take 1000 seconds and the task would appear stuck.

## Writing New Tests

When adding new functionality:

1. Create corresponding spec files in the appropriate directory
2. Follow RSpec conventions and best practices
3. Use `rails_helper.rb` for tests that need Rails functionality
4. Use `spec_helper.rb` for unit tests that don't need Rails
