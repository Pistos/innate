module Innate
  # A Hash-alike LRU cache that provides fine-grained control over content
  # restrictions.
  #
  # It allows you to set:
  # * a maximum number of elements
  # * the maximum amount of memory used for all elements
  # * the allowed memory-size per element
  # * time to live
  #
  # Differences to the original implementation include:
  # * The Cache is now a Struct for speed
  #
  # Copyright (C) 2002  Yoshinori K. Okuji <okuji@enbug.org>
  # Copyright (c) 2009  Michael Fellinger  <manveru@rubyists.com>
  #
  # You may redistribute it and/or modify it under the same terms as Ruby.
  class LRUHash < Struct.new(:max_count, :expiration, :hook, :objs, :list)
    CacheObject = Struct.new(:content, :size, :atime)

    # On 1.8 we raise IndexError, on 1.9 we raise KeyError
    KeyError = Module.const_defined?(:KeyError) ? KeyError : IndexError

    include Enumerable

    def initialize(options = {}, &hook)
      self.max_count = options[:max_count]
      self.expiration = options[:expiration]
      self.hook = hook
      self.objs = {}
      self.list = []
    end

    def delete(key)
      return unless objs.key?(key)
      obj = objs[key]

      hook.call(key, obj.content) if hook
      objs.delete key

      list.delete_if{|list_key| key == list_key }

      obj.content
    end

    def clear
      objs.each{|key, obj| hook.call(key, obj) } if hook
      objs.clear
      list.clear
    end
    alias invalidate_all clear

    def expire
      return unless expiration
      now = Time.now.to_i

      list.each_with_index do |key, index|
        break unless (objs[key].atime + expiration) <= now
        delete key
      end
    end

    def [](key)
      expire

      return unless objs.key?(key)

      obj = objs[key]
      obj.atime = Time.now.to_i

      list.delete_if{|list_key| key == list_key }
      list << key

      obj.content
    end

    def []=(key, obj)
      expire

      delete key if objs.key?(key)

      delete list.first if max_count && max_count == list.size

      objs[key] = CacheObject.new(obj, size, Time.now.to_i)
      list << key

      obj
    end
  end
end
