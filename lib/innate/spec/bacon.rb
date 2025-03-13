require 'bacon'
require 'rack/test'
require File.expand_path('../../', __FILE__) unless defined?(Innate)

Bacon.summary_on_exit

ENV['RACK_ENV'] = 'TEST'

Innate.middleware(:spec) { run Innate.core }

Innate.options.started = true
Innate.options.mode    = :spec

shared :rack_test do
  Innate.setup_dependencies
  extend Rack::Test::Methods

  def app; Innate; end
end
