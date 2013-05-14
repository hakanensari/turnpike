require 'forwardable'
require 'msgpack'
require 'redis'

module Turnpike
  class Base
    extend Forwardable

    def_delegator :Redis, :current, :redis
    def_delegators :MessagePack, :pack, :unpack

    attr :name

    def initialize(name)
      @name = "turnpike:#{name}"
    end

    def clear
      redis.del(name)
    end

    def empty?
      size == 0
    end

    def pop(*); raise NotImplementedError; end
    def push(*); raise NotImplementedError; end
    def size; raise NotImplementedError; end
    def unshift(*); raise NotImplementedError; end
  end
end
