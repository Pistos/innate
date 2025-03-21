module Innate
  class Response < Rack::Response
    include Optioned

    options.dsl do
      o "Default headers, will not override headers already set",
        :headers, {'Content-Type' => 'text/html'}
    end

    def self.mime_type
      options[:headers]['Content-Type'] || 'text/html'
    end

    def reset
      self.status = 200
      self.headers.delete('Content-Type')
      body.clear
      self.length = 0
      self
    end

    def finish
      options.headers.each{|key, value| self[key] ||= value }
      Current.session.flush(self)
      super
    end
  end
end
