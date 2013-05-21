require 'digest/sha1'
require 'turnpike/base'

module Turnpike
  class UniqueQueue < Base
    ZPOP = <<-EOF
      local res = redis.call('zrange', KEYS[1], 0, KEYS[2] - 1)
      redis.pcall('zrem', KEYS[1], unpack(res))
      return res
    EOF

    ZPOP_SHA = Digest::SHA1.hexdigest(ZPOP)

    # Pop one or more items from the queue.
    #
    # n - Integer number of items to pop.
    #
    # Returns an item, an Array of items, or nil if the queue is empty.
    def pop(n = 1)
      items = zpop(n).map { |i| unpack(i) }
      n == 1 ? items.first : items
    end

    # Push items to the end of the queue.
    #
    # items - A splat Array of items.
    #
    # Returns nothing.
    def push(*items, score: Time.now.to_f)
      redis.zadd(name, items.reduce([]) { |ary, i| ary.push(score, pack(i)) })
    end

    alias << push

    # Returns the Integer size of the queue.
    def size
      redis.zcard(name)
    end

    # Push items to the front of the queue.
    #
    # items - A splat Array of items.
    #
    # Returns nothing.
    def unshift(*items)
      _, score = redis.zrange(name, 0, 0, with_scores: true).pop
      score ? push(*items, score: score - 1) : push(*items)
    end

    private

    def zpop(n)
      redis.evalsha(ZPOP_SHA, [name, n])
    rescue Redis::CommandError
      redis.eval(ZPOP, [name, n])
    end
  end
end
