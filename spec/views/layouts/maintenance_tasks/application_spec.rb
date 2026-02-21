# frozen_string_literal: true

require "rails_helper"

RSpec.describe "layouts/maintenance_tasks/application", type: :view do
  before do
    # Mock the navbar partial
    allow(view).to receive(:render).with("layouts/maintenance_tasks/navbar").and_return("<nav>Navbar</nav>")
    allow(view).to receive(:yield).and_return("<div>Content</div>")
  end

  it "renders the layout with correct structure" do
    render template: "layouts/maintenance_tasks/application", layout: false

    expect(rendered).to include("Maintenance Tasks")
    expect(rendered).to include("maintenance_tasks_ui/base")
  end

  it "includes the theme stylesheet" do
    render template: "layouts/maintenance_tasks/application", layout: false

    expect(rendered).to include("maintenance_tasks_ui/base")
  end

  it "includes dark mode CSS variables" do
    render template: "layouts/maintenance_tasks/application", layout: false

    expect(rendered).to include("@media (prefers-color-scheme: dark)")
    expect(rendered).to include("--ruby-comment")
  end


  it "includes the navbar" do
    render template: "layouts/maintenance_tasks/application", layout: false

    expect(rendered).to include("Navbar")
  end
end
