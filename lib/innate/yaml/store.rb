require 'yaml/store'

module Innate
  module YAML
    # Just to allow some permitted_classes, because this list of classes
    # is hard-coded in stdlib ::YAML::Store
    class Store < ::YAML::Store
      def initialize(*o)
        @permitted_classes = [Symbol]  # Default in stdlib
        @use_permitted_classes = ::YAML.respond_to?(:safe_load)

        if o.last.is_a? Hash
          other_permitted_classes = Array(o.last[:other_permitted_classes])

          if ! @use_permitted_classes && other_permitted_classes.any?
            raise ArgumentError.new("::YAML module does not support permitted_classes")
          else
            @permitted_classes += other_permitted_classes
          end
        end

        super(*o)
      end

      # Based on Ruby 3.4.2 lib/ruby/3.4.0/yaml/store.rb
      def load(content)
        table =  if @use_permitted_classes
          if Psych::VERSION >= "3.1"
            ::YAML.safe_load(content, permitted_classes: @permitted_classes)
          else
            ::YAML.safe_load(content, @permitted_classes)
          end
        else
          ::YAML.load(content)
        end

        if table == false || table == nil
          {}
        else
          table
        end
      end
    end
  end
end
