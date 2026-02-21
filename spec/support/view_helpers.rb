# frozen_string_literal: true

# Helper methods for view specs
module ViewHelpers
  def self.included(base)
    base.let(:view) { ActionView::Base.new }
  end
end

RSpec.configure do |config|
  config.include ViewHelpers, type: :view
end
