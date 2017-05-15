require 'flagship'

RSpec.configure do |config|
  config.before(:suite) do
    Flagship.clear_state
  end

  config.after(:each) do
    Flagship.clear_state
  end
end
