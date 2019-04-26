require 'bundler/setup'
require 'ductwork'
require 'pp'

Client = Ductwork::Client
Server = Ductwork::Server
Pipe = Ductwork::Pipe
TimeoutError = Ductwork::TimeoutError

FIFO_PATH = File.expand_path('./tmp/dw.fifo')
LONG_TIMEOUT = 2000
SHORT_TIMEOUT = 50

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
