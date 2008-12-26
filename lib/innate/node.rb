require 'set'

module Innate

  # The nervous system of Innate, so you can relax.
  #
  # Node may be included into any class to make it a valid responder to
  # requests.
  #
  # The major difference between this and the Ramaze controller is that every
  # Node acts as a standalone application with its own dispatcher.
  #
  # What's also an important difference is the fact that Node is a module, so
  # we don't have to spend a lot of time designing the perfect subclassing
  # scheme.
  #
  # This makes dispatching more fun, avoids a lot of processing that is done by
  # Rack anyway and lets you tailor your application down to the last action
  # exactly the way you want without worrying about side-effects to other
  # nodes.
  #
  # Upon inclusion, it will also include Innate::Trinity and Innate::Helper to
  # provide you with request/response objects, a session and all the standard
  # helper methods as well as the ability to simply add other helpers.
  #
  # NOTE:
  #   * Although I tried to minimize the amount of code in here there is still
  #     quite a number of methods left in order to do ramaze-style lookups.
  #     Those methods, and all other methods occurring in the ancestors after
  #     Innate::Node will not be considered valid action methods and will be
  #     ignored.
  #   * This also means that method_missing will not see any of the requests
  #     coming in.
  #   * If you want an action to act as a catch-all, use `def index(*args)`.

  module Node

    # Upon inclusion we make ourselves comfortable.

    def self.included(obj)
      obj.__send__(:include, Helper)
      obj.extend(Trinity, self)
      obj.provide(:html => :none) # provide .html with no interpolation
    end

    # Shortcut to map or remap this Node

    def map(location)
      Innate.map(location, self)
    end

    # This little piece of nasty looking code enables you to provide different
    # content from a single action.
    #
    # Usage:
    #
    #   class Feeds
    #     include Innate::Node
    #     map '/feed'
    #
    #     provide :html => :haml, :rss => :haml, :atom => :haml
    #
    #     def index
    #       @feed = build_some_feed
    #     end
    #   end
    #
    # This will do following to these requests:
    #
    # /feed      # => call Feeds#index with template /view/feed/index.haml
    # /feed.atom # => call Feeds#index with template /view/feed/index.atom.haml
    # /feed.rss  # => call Feeds#index with template /view/feed/index.rss.haml
    #
    # If index.atom.haml isn't available we fall back to /view/feed/index.haml
    #
    # So it's really easy to add your own content representation.
    # The correct Content-Type for the response will be retrieved from
    # Rack::Mime and can be manually overwritten in the controller by e.g.
    #
    #   action.content_type = 'text/css'
    #
    # If no matching provider is found for the given extension it will fall
    # back to the one specified for html.
    #
    # The correct templating engine is selected by matching the last extension
    # of the template itself to the one set in Innate::View.
    #
    # If you don't want that your response is passed through a templating
    # engine, use :none like:
    #
    #   provide :txt => :none
    #
    # So a request to
    #
    # /feed.txt # => call Feeds#index with template /view/feed/index.txt.haml

    def provide(formats = {})
      @provide ||= {}

      if formats.respond_to?(:each_pair)
        formats.each_pair{|k,v| @provide[k.to_s] = v }
      elsif formats.respond_to?(:to_sym)
        formats[formats.to_sym.to_s] = formats
      elsif formats.respond_to?(:to_str)
        formats[formats.to_str] = formats
      else
        raise(ArgumentError, "provide(%p) is invalid parameter" % formats)
      end

      @provide
    end

    # This makes the Node a valid application for Rack.
    # +env+ is the environment hash passed from the Rack::Handler
    #
    # We rely on correct PATH_INFO.
    #
    # As defined by the Rack spec, PATH_INFO may be empty if it wants the root
    # of the application, so we insert '/' to make our dispatcher simple.
    #
    # Innate will not rescue any errors for you or do any error handling, this
    # should be done by an underlying middleware.
    #
    # We do however log errors at some vital points in order to provide you
    # with feedback in your logs.
    #
    # NOTE:
    #   * A lot of functionality in here relies on the fact that call is
    #     executed within Innate::STATE.wrap which populates the variables used
    #     by Trinity.
    #   * If you use the Node directly as a middleware make sure that you #use
    #     Innate::Current as a middleware before it.

    def call(env)
      path = env['PATH_INFO']
      path << '/' if path.empty?

      try_resolve(path)

      response.finish
    rescue Exception => exception
      Log.error(exception)
      raise(exception)
    end

    # Let's try to find some valid action for given +path+.
    # Otherwise we dispatch to action_not_found

    def try_resolve(path)
      if action = resolve(path)
        action_found(action)
      else
        action_not_found(path)
      end
    end

    def action_found(action)
      catch(:respond) do
        catch(:redirect) do
          response.write(action.call)
          response['Content-Type'] ||= action.content_type
        end
      end
    end

    # The default handler in case no action was found, kind of method_missing.
    # Must modify the response in order to have any lasting effect.
    #
    # Reasoning:
    # * We are doing this is in order to avoid tons of special error handling
    #   code that would impact runtime and make the overall API more
    #   complicated.
    # * This cannot be a normal action is that methods defined in Innate::Node
    #   will never be considered for actions.
    # * Also, you should not use #try_resolve to do the dispatching manually,
    #   as this may result in recursion until you get a SystemStackError
    #
    # To use a normal action with template do following:
    #
    #   class Hi
    #     include Innate::Node
    #     map '/'
    #
    #     def action_not_found(path)
    #       # No normal action, runs on bare metal
    #       action_found('/not_found')
    #     end
    #
    #     def not_found
    #       # Normal action
    #       "Sorry, I do not exist"
    #     end
    #   end

    def action_not_found(path)
      response.status = 404
      response['Content-Type'] = 'text/plain'
      response.write("Action not found at: %p" % path)
    end

    # Let's get down to business, first check if we got any wishes regarding
    # the representation from the client, otherwise we will assume he wants
    # html.

    def resolve(path)
      name, *exts = path.split('.')
      wish = exts.last || 'html'

      find_action(name, wish)
    end

    # Now we're talking Action, we try to find a matching template and method,
    # if we can't find either we go to the next pattern, otherwise we answer
    # with an Action with everything we know so far about the demands of the
    # client.

    def find_action(name, wish)
      patterns_for(name){|name, params|
        view = find_view(name, wish, params)
        method = find_method(name, params)

        next unless view or method

        layout = to_layout(@layout).first

        Action.create(:node => self, :params => params, :wish => wish,
                      :method => method, :view => view, :options => {},
                      :variables => {}, :layout => layout)
      }
    end

    # I hope this method talks for itself, we check arity if possible, but will
    # happily dispatch to any method that has default parameters.
    # If you don't want your method to be responsible for messing up a request
    # you should think twice about the arguments you specify due to limitations
    # in Ruby.
    #
    # So if you want your method to take only one parameter which may have a
    # default value following will work fine:
    #
    #   def index(foo = "bar", *rest)
    #
    # But following will respond to /arg1/arg2 and then fail due to ArgumentError:
    #
    #   def index(foo = "bar")
    #
    # Here a glance at how parameters are expressed in arity:
    #
    #   def index(a)                  # => 1
    #   def index(a = :a)             # => -1
    #   def index(a, *r)              # => -2
    #   def index(a = :a, *r)         # => -1
    #
    #   def index(a, b)               # => 2
    #   def index(a, b, *r)           # => -3
    #   def index(a, b = :b)          # => -2
    #   def index(a, b = :b, *r)      # => -2
    #
    #   def index(a = :a, b = :b)     # => -1
    #   def index(a = :a, b = :b, *r) # => -1

    def find_method(name, params)
      expected_arity = params.size

      possible_methods(name) do |arity|
        return name if arity == expected_arity or arity < 0
      end

      return nil
    end

    # Takes a +name+ of the method to find and a block.
    # The block takes the arity of the found method.

    def possible_methods(name)
      [self, *(Helper::EXPOSE & ancestors)].each do |object|
        object.instance_methods(false).each do |im|
          next unless im.to_s == name
          yield object.instance_method(im).arity
        end
      end
    end

    # Try to find the best template for the given basename and wish.
    # Also, having extraordinarily much fun with globs.

    def to_view(file, wish)
      return [] unless file

      app = Options.for('innate:app')
      app_root = app[:root]
      app_view = app[:view]

      path = [app_root, app_view, view_root, file]

      return [] unless path.all?

      path = File.join(*path)
      exts = [@provide[wish], *@provide.keys].flatten.uniq.join(',')

      glob = "#{path}.{#{wish}.,#{wish},}{#{exts},}"

      Dir[glob].uniq
    end

    # This is done to make you feel more at home, pass an absolute path or a
    # path relative to your application root to set it, otherwise you'll get
    # the current mapping.

    def view_root(location = nil)
      if location
        @view_root = location
      else
        @view_root ||= Innate.to(self)
      end
    end

    # All of the above, get first match and lets you know if there's any
    # ambiguity.

    def find_view(name, wish, params)
      possible = to_view(name, wish)

      if possible.size > 1
        interp = [possible.size, name, params, possible]
        Log.warn "%d views found for %s:%p : %p" % interp
      end

      possible.first
    end

    # Like view_root, but for the layouts.
    #
    # You see, layouts will not be taken from the view directories anymore
    # unless you explicitly say so.
    #
    # So your layouts will not be considered normal views anymore and you don't
    # have to worry about anything dispatching to them.
    #
    # FIXME:
    #   This is not used anywhere yet, all layouts are in a flat name-space at
    #   innate:app:layout - determine if there's any demand for this feature.

    def layout_root(location = nil)
      if location
        @layout_root = location
      else
        @layout_root ||= Innate.to(self)
      end
    end

    # Find the best matching file for the layout, if any.

    def to_layout(file)
      return [] unless file

      app = Options.for('innate:app')

      path = [app[:root], app[:layout], file]
      path = File.join(*path)
      Dir["#{path}.*"]
    end

    # Set the +name+ of the layout you want, this takes only the basename
    # without any filename-extension or directory.
    def layout(name = nil)
      @layout = name
    end

    # The innate beauty in Nitro, Ramaze, and Innate.
    #
    # Will yield the name of the action and parameter for the action method in
    # order of significance.
    #
    #   def foo__bar # responds to /foo/bar
    #   def foo(bar) # also responds to /foo/bar
    #
    # But foo__bar takes precedence because it's more explicit.
    #
    # The last fallback will always be the index action with all of the path
    # turned into parameters.
    #
    # Samples:
    #
    #   class Foo; include Innate::Node; map '/'; end
    #
    #   Foo.patterns_for('/'){|action, params| p action => params }
    #   {"index"=>[]}
    #
    #   Foo.patterns_for('/foo/bar'){|action, params| p action => params }
    #   {"foo__bar"=>[]}
    #   {"foo"=>["bar"]}
    #   {"index"=>["foo", "bar"]}
    #
    #   Foo.patterns_for('/foo/bar/baz'){|action, params| p action => params }
    #   {"foo__bar__baz"=>[]}
    #   {"foo__bar"=>["baz"]}
    #   {"foo"=>["bar", "baz"]}
    #   {"index"=>["foo", "bar", "baz"]}

    def patterns_for(path)
      atoms = path.split('/')
      atoms.delete('')
      result = nil

      atoms.size.downto(0) do |len|
        action = atoms[0...len].join('__')
        params = atoms[len..-1]
        action = 'index' if action.empty?

        return result if result = yield(action, params)
      end

      return nil
    end
  end
end
