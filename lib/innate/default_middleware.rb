Innate.middleware(:dev) do
  use Rack::Lint
  use Rack::Head
  use Rack::ContentLength
  use Rack::CommonLogger
  use Rack::ShowExceptions
  use Rack::ShowStatus
  use Rack::ConditionalGet
  use Rack::Reloader, 2

  run Innate.core
end

Innate.middleware(:live) do
  use Rack::Head
  use Rack::ContentLength
  use Rack::CommonLogger
  use Rack::ShowStatus
  use Rack::ConditionalGet

  run Innate.core
end
