require 'innate/options/dsl'

module Innate
  @options = Options.new(:innate)

  def self.options; @options end

  # This has to speak for itself.

  options.dsl do
    o "IP address or hostname that Ramaze will respond to - 0.0.0.0 for all",
      :host, "0.0.0.0", :short => :H

    o "Port for the server",
      :port, 7000, :short => :p

    o "Indicate that calls Innate::start will be ignored",
      :started, false

    o "Web server to run on",
      :adapter, :webrick, :short => :a

    o "Will send ::setup to each element during Innate::start",
      :setup, [Innate::Cache, Innate::Node]

    o "Headers that will be merged into the response before Node::call",
      :header, {'Content-Type' => 'text/html'}

    o "Trap this signal to issue shutdown, nil/false to disable trap",
      :trap, 'SIGINT'

    o "Keep state in Thread or Fiber, fall back to Thread if Fiber not available",
      :state, :Fiber

    sub :log do
      o "Array of parameters for Logger.new, default to stderr for CGI",
        :params, [$stderr]
      o "Use ANSI colors for logging, nil does auto-detection by checking for #tty?",
        :color, nil
    end

    sub :redirect do
      o "Default response HTTP status on redirect",
        :status, 302
    end

    sub :env do
      o "Hostname of this machine",
        :host, ENV['HOSTNAME'] # FIXME: cross-platform
      o "Username executing the application",
        :user, ENV['USER'] # FIXME: cross-platform
    end

    sub :app do
      o "Unique identifier for this application",
        :name, 'pristine'
      o "Root directory containing the application",
        :root, File.dirname($0)
      o "Root directory for view templates, relative to app subdir",
        :view, '/view'
      o "Root directory for layout templates, relative to app subdir",
        :layout, '/layout'
    end

    sub :session do
      o "Key for the session cookie",
        :key, 'innate.sid'
      o "Domain the cookie relates to, unspecified if false",
        :domain, false
      o "Path the cookie relates to",
        :path, '/'
      o "Use secure cookie",
        :secure, false
      o "Time of cookie expiration",
        :expires, Time.at(2147483647)
    end

    sub :cache do
      o "Assign a cache to each of these names on Innate::Cache::setup",
        :names, [:session]

      default "If no option for the cache name exists, fall back to this",
        Innate::Cache::Memory
    end

    sub :action do
      o "wish => Action#method",
        :wish, {'json' => :as_json, 'html' => :as_html, 'yaml' => :as_yaml}
    end
  end
end
