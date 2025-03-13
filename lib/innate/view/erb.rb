require 'erb'

module Innate
  module View
    module ERB
      def self.call(action, string)
        erb = View.compile(string){|str| ::ERB.new(str, nil, '%<>') }
        erb.filename = (action.view || action.method).to_s
        erb.result(action.binding)
      end
    end
  end
end
