require 'rackup/handler'
module Innate

  # Lightweight wrapper around Rack::Handler, will apply our options in a
  # unified manner and deal with adapters that don't like to do what we want or
  # where Rack doesn't want to take a stand.
  #
  # Rack handlers as of 2009.03.25:
  # cgi, fastcgi, mongrel, emongrel, smongrel, webrick, lsws, scgi, thin

  module Adapter
    include Optioned

    options.dsl do
      o "IP address or hostname that we respond to - 0.0.0.0 for all",
        :host, "0.0.0.0"

      o "Port for the server",
        :port, 7000

      o "Web server to run on",
        :handler, :webrick
    end

    # Pass given app to the Handler, handler is chosen based on config.adapter
    # option.
    # If there is a method named start_name_of_adapter it will be run instead
    # of the default run method of the handler, this makes it easy to define
    # custom startup of handlers for your server of choice.
    def self.start(app, given_options = nil)
      options.merge!(given_options) if given_options

      handler = options[:handler].to_s.downcase
      config = { :Host => options[:host], :Port => options[:port] }

      Log.debug "Using #{handler}"

      if respond_to?(method = "start_#{handler}")
        send(method, app, config)
      else
        Rackup::Handler.get(handler).run(app, config)
      end
    end

    # Due to buggy autoload on Ruby 1.8 we have to require 'ebb' manually.
    # This most likely happens because autoload doesn't respect the require of
    # rubygems and uses the C require directly.
    def self.start_ebb(app, config)
      require 'ebb'
      # Rack doesn't ship with ebb handler, but it doesn't get picked up under some
      # circumstances, so we do that here.
      # Jruby Rack doesn't have the Handler::register method, so we have to check.
      # This has changed since Rack moved Handler to Rackup.  Not sure about JRuby
      if Rackup::Handler.respond_to?(:register)
        Rackup::Handler.register('ebb', 'Rackup::Handler::Ebb')
      end
      Rackup::Handler.get('ebb').run(app, config)
    end

    # We want webrick to use our logger.
    def self.start_webrick(app, config)
      handler = Rackup::Handler.get('webrick')
      config = {
        :Host => config[:Host],
        :Port => config[:Port],
        :Logger => Log,
      }

      handler.run(app, config)
    end

    # Thin shouldn't give excessive output, especially not to $stdout
    def self.start_thin(app, config)
      handler = Rackup::Handler.get('thin')
      ::Thin::Logging.silent = true
      handler.run(app, config)
    end

    # A simple Unicorn wrapper.
    def self.start_unicorn(app, config)
      require 'unicorn'
      config = {
        :listeners => ["#{config[:Host]}:#{config[:Port]}"]
      }
      ::Unicorn.run(app, config)
    end
  end
end
