module Innate
  $LOAD_PATH.unshift File.dirname(File.expand_path(__FILE__))
  $LOAD_PATH.uniq!
  ROOT = File.expand_path(File.dirname(__FILE__))
end

# stdlib
require 'pp'
require 'set'

# 3rd party
begin; require 'rubygems'; rescue LoadError; end
require 'rack'

module Rack
  autoload 'Profile', 'rack/profile'
end

# innate
require 'innate/core_compatibility/string'
require 'innate/core_compatibility/basic_object'

require 'innate/option'
require 'innate/log'
require 'innate/state'
require 'innate/trinity'
require 'innate/current'
require 'innate/mock'
require 'innate/adapter'
require 'innate/action'
require 'innate/helper'
require 'innate/node'
require 'innate/view'
require 'innate/session'
require 'innate/dynamap'

require 'rack/reloader'
require 'rack/middleware_compiler'

module Innate
  extend Trinity

  @config = Options.for(:innate){|innate|
    innate.root = Innate::ROOT
    innate.started = false

    innate.port = 7000
    innate.host = '0.0.0.0'
    innate.adapter = :webrick

    innate.header = {
      'Content-Type' => 'text/html',
      # 'Accept-Charset' => 'utf-8',
    }

    innate.redirect_status = 302

    innate.app do |app|
      app.root = '/'
      app.view = 'view'
      app.layout = 'layout'
    end

    innate.session do |session|
      session.key = 'innate.sid'
      session.domain = false
      session.path = '/'
      session.secure = false

      # The current value is a time at:
      #   2038-01-19 03:14:07 UTC
      # Let's hope that by then we get a better ruby with a better Time class
      session.expires = Time.at(2147483647)
    end
  }

  def self.start(options = {})
    return if @config.started
    setup_middleware

    config.app.root = go_figure_root(options, caller)
    config.started = true
    config.adapter = (options[:adapter] || @config.adapter).to_s

    trap('INT'){ stop }

    Adapter.start(middleware(:innate), config)
  end

  def self.stop(wait = 0)
    Log.info "Shutdown Innate"
    exit!
  end

  def self.config
    @config
  end

  def self.middleware(name, &block)
    Rack::MiddlewareCompiler.build(name, &block)
  end

  def self.middleware!(name, &block)
    Rack::MiddlewareCompiler.build!(name, &block)
  end

  def self.setup_middleware
    middleware :innate do |m|
      # m.use Rack::CommonLogger # usually fast, depending on the output
      m.use Rack::ShowExceptions # fast
      m.use Rack::ShowStatus     # fast
      m.use Rack::Reloader       # reasonably fast depending on settings
      # m.use Rack::Lint         # slow, use only while developing
      # m.use Rack::Profile      # slow, use only for debugging or tuning
      m.use Innate::Current      # necessary

      m.cascade Rack::File.new('public'), Innate::DynaMap
    end
  end

  def self.call(env)
    this_file = File.expand_path(__FILE__)
    count = 0
    caller_lines{|f, l, m| count += 1 if f == this_file }

    raise RuntimeError, "Recursive loop in Innate::call" if count > 10

    middleware.call(env)
  end

  def self.go_figure_root(options, backtrace)
    if file = options[:file]
      return File.dirname(file)
    elsif root = options[:root]
      return root
    end

    pwd = Dir.pwd

    return pwd if File.file?(File.join(pwd, 'start.rb'))

    caller_lines(backtrace) do |file, line, method|
      dir, file = File.split(File.expand_path(file))
      return dir if file == "start.rb"
    end

    return nil
  end

  # yields +file+, +line+, +method+
  def self.caller_lines(backtrace)
    backtrace.each do |line|
      if line =~ /^(.*?):(\d+):in `(.*)'$/
        file, line, method = $1, $2.to_i, $3
      elsif line =~ /^(.*?):(\d+)$/
        file, line, method = $1, $2.to_i, nil
      end

      yield(File.expand_path(file), line, method) if file and File.file?(file)
    end
  end
end
