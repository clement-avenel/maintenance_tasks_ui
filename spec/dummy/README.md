# Dummy Rails App

This is a minimal Rails application used for testing the Maintenance Tasks UI gem.

## Setup

To set up the dummy app:

```bash
cd spec/dummy
bundle install
bundle exec rails generate maintenance_tasks:install
bundle exec rails db:create db:migrate
```

**Important:** If you get an error about missing `maintenance_tasks_runs` table, run:

```bash
bundle exec rake maintenance_tasks:install:migrations
bundle exec rails db:migrate
```

## Running the Server

To manually test the theme:

```bash
cd spec/dummy
bundle exec rails server
```

Then visit http://localhost:3000/maintenance_tasks

## Creating Test Tasks

You can create test tasks using the Maintenance Tasks generator:

```bash
cd spec/dummy
bundle exec rails generate maintenance_tasks:task sample_task
```

This dummy app is automatically used by RSpec when running the test suite.

## Deploy to Fly.io

Deploy from the **repo root** (not from `spec/dummy`). The Dockerfile at the repo root is used so the build includes the gem:

```bash
fly deploy . -c spec/dummy/fly.toml -a maintenance-tasks-ui
```

## Troubleshooting

### Missing maintenance_tasks_runs table

If you see `Could not find table 'maintenance_tasks_runs'`, the migrations haven't been run:

```bash
bundle exec rake maintenance_tasks:install:migrations
bundle exec rails db:migrate
```

### SQLite3 version conflicts

If you get sqlite3 version errors:

```bash
bundle update sqlite3
bundle exec rails db:migrate
```
