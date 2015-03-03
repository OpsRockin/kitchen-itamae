$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rspec'

RSpec.configure do |config|
  config.tty = true
  config.color = true
end
