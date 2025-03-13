module Innate
  module Helper
    ##
    # The Aspect helper allows you to execute hooks before or after a number of
    # actions.
    #
    # See {Innate::Helper::Aspect::SingletonMethods} for more details on the
    # various hooks available.
    #
    # @example Querying a database before a number of actions.
    #  class Posts
    #    include Innate::Node
    #
    #    map    '/'
    #    helper :aspect
    #
    #    before(:index, :other) do
    #      @posts = Post.all
    #    end
    #
    #    def index
    #      return @posts
    #    end
    #
    #    def other
    #      return @posts[0]
    #    end
    #  end
    #
    # This helper is essential for proper working of {Action#render}.
    #
    module Aspect
      ##
      # Hash containing the various hooks to call for certain actions.
      #
      AOP = Hash.new { |h,k| h[k] = Hash.new { |hh,kk| hh[kk] = {} } }

      ##
      # Called whenever this helper is included into a class.
      #
      # @param [Class] into The class the module was included into.
      #
      def self.included(into)
        into.extend(SingletonMethods)
        into.add_action_wrapper(5.0, :aspect_wrap)
      end

      # Consider objects that have Aspect included
      def self.ancestral_aop(from)
        aop = {}

        from.ancestors.reverse.each do |anc|
          aop.merge!(AOP[anc]) if anc < Aspect
        end

        aop
      end

      ##
      # Calls the aspect for a given position and name.
      #
      # @param [#to_sym] position The position of the hook, e.g. :before_all.
      # @param [#to_sym] name The name of the method for which to call the hook.
      #
      def aspect_call(position, name)
        return unless aop = Aspect.ancestral_aop(self.class)
        return unless block = at_position = aop[position]

        block = at_position[name.to_sym] unless at_position.is_a?(Proc)

        instance_eval(&block) if block
      end

      ##
      # Wraps the specified action between various hooks.
      #
      # @param [Innate::Action] action The action to wrap.
      #
      def aspect_wrap(action)
        return yield unless method = action.name

        aspect_call(:before_all, method)
        aspect_call(:before, method)
        result = yield
        aspect_call(:after, method)
        aspect_call(:after_all, method)

        result
      end

      ##
      # This awesome piece of hackery implements action AOP.
      #
      # The so-called aspects are simply methods that may yield the next aspect
      # in the chain, this is similar to racks concept of middleware, but
      # instead of initializing with an app we simply pass a block that may be
      # yielded with the action being processed.
      #
      # This gives us things like logging, caching, aspects, authentication,
      # etc.
      #
      # Add the name of your method to the trait[:wrap] to add your own method
      # to the wrap_action_call chain.
      #
      # @example adding your method
      #   class MyNode
      #     Innate.node '/'
      #
      #     private
      #
      #     def wrap_logging(action)
      #       Innate::Log.info("Executing #{action.name}")
      #       yield
      #     end
      #
      #     trait[:wrap]
      #   end
      #
      #
      # methods may register themself in the trait[:wrap] and will be called in
      # left-to-right order, each being passed the action instance and a block
      # that they have to yield to continue the chain.
      #
      # @param [Action] action instance that is being passed to every registered
      #  method
      # @param [Proc] block contains the instructions to call the action method
      #  if any
      # @see Action#render
      # @author manveru
      #
      def wrap_action_call(action, &block)
        return yield if action.options[:is_layout]
        wrap = SortedSet.new
        action.node.ancestral_trait_values(:wrap).each{|sset| wrap.merge(sset) }
        head, *tail = wrap.map{|k,v| v }
        tail.reverse!
        combined = tail.inject(block){|s,v| lambda{ __send__(v, action, &s) } }
        __send__(head, action, &combined)
      end

      ##
      # Module containing various methods that will be made available as class
      # methods to the class that included {Innate::Helper::Aspect}.
      #
      module SingletonMethods
        include Traited

        ##
        # Hook that is called before all the actions in a node.
        #
        # @example
        #  class MainController
        #    include Innate::Node
        #
        #    map '/'
        #
        #    helper :aspect
        #
        #    before_all do
        #      puts 'Executed before all actions'
        #    end
        #
        #    def index
        #      return 'Hello, Innate!'
        #    end
        #  end
        #
        def before_all(&block)
          AOP[self][:before_all] = block
        end

        ##
        # Hook that is called before a specific list of actions.
        #
        # @example
        #  class MainController
        #    include Innate::Node
        #
        #    map '/'
        #
        #    helper :aspect
        #
        #    before(:index, :other) do
        #      puts 'Executed before specific actions only.'
        #    end
        #
        #    def index
        #      return 'Hello, Innate!'
        #    end
        #
        #    def other
        #      return 'Other method'
        #    end
        #  end
        #
        def before(*names, &block)
          names.each{|name| AOP[self][:before][name] = block }
        end

        ##
        # Hook that is called after all the actions in a node.
        #
        # @example
        #  class MainController
        #    include Innate::Node
        #
        #    map '/'
        #
        #    helper :aspect
        #
        #    after_all do
        #      puts 'Executed after all actions'
        #    end
        #
        #    def index
        #      return 'Hello, Innate!'
        #    end
        #  end
        #
        def after_all(&block)
          AOP[self][:after_all] = block
        end

        ##
        # Hook that is called after a specific list of actions.
        #
        # @example
        #  class MainController
        #    include Innate::Node
        #
        #    map '/'
        #
        #    helper :aspect
        #
        #    after(:index, :other) do
        #      puts 'Executed after specific actions only.'
        #    end
        #
        #    def index
        #      return 'Hello, Innate!'
        #    end
        #
        #    def other
        #      return 'Other method'
        #    end
        #  end
        #
        def after(*names, &block)
          names.each{|name| AOP[self][:after][name] = block }
        end

        ##
        # Wraps the block around the list of actions resulting in the block
        # being called both before and after each action.
        #
        # @example
        #  class MainController
        #    include Innate::Node
        #
        #    map '/'
        #
        #    helper :aspect
        #
        #    wrap(:index) do
        #      puts 'Wrapped around the index method'
        #    end
        #
        #    def index
        #      return 'Hello, Innate!'
        #    end
        #
        #    def other
        #      return 'Other method'
        #    end
        #  end
        #
        def wrap(*names, &block)
          before(*names, &block)
          after(*names, &block)
        end

        def add_action_wrapper(order, method_name)
          if wrap = trait[:wrap]
            wrap.merge(SortedSet[[order, method_name.to_s]])
          else
            trait :wrap => SortedSet[[order, method_name.to_s]]
          end
        end
      end # SingletonMethods
    end # Aspect
  end # Helper
end # Innate
