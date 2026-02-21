# Maintenance Tasks UI

A modern, polished UI for the [Maintenance Tasks](https://github.com/Shopify/maintenance_tasks) gem. Provides a beautiful, customizable interface with CSS variables for easy theming.

## Features

- 🎨 Modern, clean design
- 🌓 Dark mode support (automatic based on system preferences)
- 🎯 Easy customization via CSS variables
- 📱 Responsive design
- 📊 Table view with pagination for task listing
- ⚡ Lightweight CSS-only solution (no JavaScript framework dependencies)
- 🔧 Easy to override and extend

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'maintenance_tasks_ui'
```

Then run:

```bash
$ bundle install
```

No generator is required. The UI is applied automatically to all Maintenance Tasks views.

## Usage

Visit `/maintenance_tasks` in your Rails application to see the themed interface.

## How does Maintenance Tasks let you “customize” the UI?

The [Maintenance Tasks README](https://github.com/Shopify/maintenance_tasks) mentions customizing the UI and “admin UI”, which can be confusing. Here’s what it actually covers:

- **`MaintenanceTasks.parent_controller`** – The only built-in “customization” documented is setting a **parent controller** for the engine’s controllers. That is for **auth and app logic** (e.g. “use my `ApplicationController` so the Maintenance Tasks pages use my authentication”). It does **not** change the look of the UI (no views, no CSS).
- **“Rails admin UIs” / “custom admin UIs”** – In the “Should I use Maintenance Tasks?” section, the gem suggests that for **recurring** tasks you might use something else, e.g. “custom rails_admin UIs”. That refers to **other tools** (like [rails_admin](https://github.com/railsadmin/rails_admin) or similar) as **alternatives** for recurring jobs. It is not a way to restyle Maintenance Tasks itself.

So the gem does **not** document how to make the default UI prettier. To change the **look** of the UI you have to **override the engine’s views and assets** yourself:

1. **View path override** – In your app (or in a gem like this one), you call `MaintenanceTasks::ApplicationController.prepend_view_path(...)` with a path that contains your own `app/views/maintenance_tasks/...`. Rails will then use your templates instead of the engine’s (same file path = override).
2. **Layout and styles** – Override the layout (e.g. `layouts/maintenance_tasks/application.html.erb`) and add your own stylesheet so the pages use your design instead of the default Bulma-based one.

**Maintenance Tasks UI** does exactly that: it’s a gem that prepends its view path and provides a full set of overridden views plus a modern stylesheet, so you get a nicer UI without writing the overrides yourself. You can still use `MaintenanceTasks.parent_controller` in your app for auth; the UI gem only replaces the look and structure of the pages.

## Customization

The theme works out of the box. To customize colors and spacing, use the options below.

### Overriding CSS variables

Create `app/assets/stylesheets/maintenance_tasks_ui_overrides.css` (or `.scss`) in your app to override the UI:

```css
:root {
  /* Primary color */
  --mt-primary: #your-color;
  --mt-primary-dark: #darker-shade;
  --mt-primary-light: #lighter-shade;
  
  /* Background colors */
  --mt-bg-primary: #ffffff;
  --mt-bg-secondary: #f8fafc;
  
  /* Text colors */
  --mt-text-primary: #0f172a;
  --mt-text-secondary: #475569;
  
  /* Border radius */
  --mt-radius: 0.5rem;
  
  /* And more... */
}
```

Make sure to include this file in your asset pipeline:

```ruby
# config/application.rb or config/initializers/assets.rb
Rails.application.config.assets.precompile += %w[maintenance_tasks_ui_overrides.css]
```

### Available CSS Variables

The theme uses CSS variables for easy customization. Here are the main ones:

**Colors:**
- `--mt-primary`, `--mt-primary-dark`, `--mt-primary-light`
- `--mt-secondary`, `--mt-secondary-dark`, `--mt-secondary-light`
- `--mt-success`, `--mt-warning`, `--mt-error`, `--mt-info`

**Backgrounds:**
- `--mt-bg-primary`, `--mt-bg-secondary`, `--mt-bg-tertiary`, `--mt-bg-hover`

**Text:**
- `--mt-text-primary`, `--mt-text-secondary`, `--mt-text-muted`, `--mt-text-inverse`

**Borders:**
- `--mt-border`, `--mt-border-light`, `--mt-border-dark`

**Shadows:**
- `--mt-shadow-sm`, `--mt-shadow`, `--mt-shadow-md`, `--mt-shadow-lg`

**Spacing:**
- `--mt-radius`, `--mt-radius-sm`, `--mt-radius-lg`

## Testing Locally

To test the theme locally:

1. **Create a test Rails app** (or use an existing one):

```bash
rails new test_app
cd test_app
```

2. **Add the gems to Gemfile**:

```ruby
gem 'maintenance_tasks'
gem 'maintenance_tasks_ui', path: '../maintenance_tasks_ui'
```

3. **Install and setup**:

```bash
bundle install
rails generate maintenance_tasks:install
rails db:migrate
```

4. **Create a test task**:

```bash
rails generate maintenance_tasks:task test_task
```

5. **Start the server and visit**:

```bash
rails server
# Visit http://localhost:3000/maintenance_tasks
```

### Using Bundler's Local Path

If you're developing the gem, you can use a local path in your test app's Gemfile:

```ruby
gem 'maintenance_tasks_ui', path: '../maintenance_tasks_ui'
```

Then run `bundle install` and restart your Rails server.

## Deploy the dummy app to Fly.io (free)

Deploy the dummy app to [Fly.io](https://fly.io) using the root Dockerfile and `fly.toml` (free tier: apps can scale to zero when idle).

1. **Install the Fly CLI**: [fly.io/docs/hands-on/install-flyctl](https://fly.io/docs/hands-on/install-flyctl)

2. **Log in and launch** (from the repo root):
   ```bash
   fly auth login
   fly launch --no-deploy
   ```
   When prompted, pick an app name (e.g. `maintenance-tasks-ui-dummy`) and a region. Use `--no-deploy` so you can set the secret first.

3. **Set the Rails secret** (required for production):
   ```bash
   fly secrets set SECRET_KEY_BASE=$(openssl rand -hex 64)
   ```

4. **Deploy**:
   ```bash
   fly deploy
   ```

5. **Open the app**:  
   `https://<your-app-name>.fly.dev/maintenance_tasks`

The app uses Fly’s free allowance (e.g. 3 shared VMs, 3 GB storage). With `min_machines_running = 0` it scales to zero when idle; the first request after that may take a few seconds to start. The dummy app uses **SQLite** (no separate database to add). By default the SQLite DB lives on ephemeral disk, so it resets on each deploy or restart.

**Optional — persist SQLite:** Fly gives 3 GB free volume storage. To keep the DB across deploys: create a volume (`fly volumes create rails_storage --region <your-region> --size 1`), then in `fly.toml` uncomment the `[mounts]` section and run `fly deploy`. The app must stay in a single region when using a volume.

## Development

After checking out the repo, run `bundle install` to install dependencies.

### Running Tests

The gem uses RSpec for testing with a dummy Rails app (similar to how ArcticAdmin tests with ActiveAdmin).

#### First-time Setup

Set up the dummy app by following the steps in `spec/dummy/README.md` (install dependencies, run the Maintenance Tasks generator, run migrations).

#### Running the Test Suite

```bash
bundle exec rspec
```

To run specific test files:

```bash
bundle exec rspec spec/maintenance_tasks_ui/engine_spec.rb
bundle exec rspec spec/maintenance_tasks_ui/view_helpers_spec.rb
```

#### Manual Testing with the Dummy App

You can also manually test the theme using the dummy app:

```bash
cd spec/dummy
bundle exec rails server
```

Then visit http://localhost:3000/maintenance_tasks

See `spec/README.md` for more details on the test suite.

### Manual Testing

To test the gem manually in a Rails application:

1. Create a test Rails application
2. Add `maintenance_tasks` and `maintenance_tasks_ui` (via path) to the Gemfile
3. Run `rails generate maintenance_tasks:install` and `rails db:migrate`
4. Create some test tasks
5. Visit `/maintenance_tasks` to see the UI in action

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yourusername/maintenance_tasks_ui.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).