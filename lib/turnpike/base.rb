require 'forwardable'
require 'msgpack'
require 'redis'

module Turnpike
  class Base
    extend Forwardable

    def_delegators :MessagePack, :pack, :unpack

    attr :name, :redis

    def initialize(name, redis: Redis.current)
      @name = "#{Turnpike.namespace}:#{name}"
      @redis = redis
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
