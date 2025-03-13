require 'rubygems'
require File.expand_path('../../lib/innate', __FILE__)

class Demo
  Innate.node '/'

  def index
    'Hello, World!'
  end

  def empty
    response.status = 405
    ''
  end
end

Innate.options.mode = :dev

Innate.middleware(:dev) do
  # Makes sure all requests and responses conform to Rack protocol
  use Rack::Lint

  # Avoid showing empty failure pages, give information when it happens.
  use Rack::ShowStatus

  # Catch exceptions inside Innate and give nice status info
  use Rack::ShowExceptions

  # Log access
  use Rack::CommonLogger

  # Reload modified files before request
  use Rack::Reloader

  # Start up the application
  run Innate.core
end

Innate.start
