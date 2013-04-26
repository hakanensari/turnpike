module Turnpike
  # A queue.
  class Queue
    # Returns a String name.
    attr :name

    # Create a new queue.
    #
    # name - A queue name that responds to to_s.
    def initialize(name = 'queue')
      @name = "turnpike:#{name}"
    end

    # Remove all items from the queue.
    #
    # Returns Integer number of items that were removed.
    def clear
      redis.del(name)
    end

    # Returns whether the queue is empty.
    def empty?
      size == 0
    end

    # Pop one or more items from the front of the queue.
    #
    # n - Integer number of items to pop.
    #
    # Returns a String item, an Array of items, or nil if the queue is empty.
    def pop(n = 1)
      items = []
      n.times do
        break unless item = redis.lpop(name)
        items << Marshal.load(item)
      end

      n == 1 ? items.first : items
    end

    # Push items to the end of the queue.
    #
    # items - A splat Array of items.
    #
    # Returns the Integer size of the queue after the operation.
    def push(*items)
      redis.rpush(name, items.map { |i| Marshal.dump(i) })
    end

    # Syntactic sugar.
    alias << push

    # Returns the Integer size of the queue.
    def size
      redis.llen(name)
    end

    # Push items to the front of the queue.
    #
    # items - A splat Array of items.
    #
    # Returns the Integer size of the queue after the operation.
    def unshift(*items)
      redis.lpush(name, items.map { |i| Marshal.dump(i) })
    end

    private

    def redis
      Redis.current
    end
  end
end
