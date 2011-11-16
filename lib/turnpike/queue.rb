module Turnpike
  # A Redis-backed queue
  class Queue
    # @return [String] queue name
    attr :name

    # Creates a new queue
    # @param [#to_s] name
    def initialize(name = 'queue')
      @name = "turnpike:#{name}"
    end

    # Removes all items from the queue
    def clear
      redis.del(name)
    end

    # @return [Boolean] whether the queue is empty
    def empty?
      size == 0
    end

    # Returns some or all queued items
    # @param [Integer] start the start offset
    # @param [Integer] count number of items to return
    # @note When specifying the offset, 0 is the first queued item. A
    # negative integer indicates the offset from the end, -1 being the
    # last queued item.
    def peek(start, count)
      redis.lrange(name, start, count)
    end

    # Retrieves one or more items from the queue
    # @param [Integer] n number of items to retrieve
    # @return [Array, String, nil] retrieved items
    def pop(n = 1)
      items = []
      n.times do
        break unless item = redis.lpop(name)
        items << item
      end

      n == 1 ? items.first : items
    end

    # Pushes items to the end of the queue
    # @param [Array] items splat of items
    def push(*items)
      items.each { |item| redis.rpush(name, item) }
      # if redis_version >= '2.4'
      #   redis.rpush(name, *items)
      # else
      #   items.each { |item| redis.rpush(name, item) }
      # end
    end

    # Alias of push
    alias << push

    # @return [Integer] the size of the queue
    def size
      redis.llen(name)
    end

    # Pushes items to the front of the queue
    # @param [Array] items splat of items
    def unshift(*items)
      # if redis_version >= '2.4'
      #   redis.lpush(name, *items)
      # else
      #   items.each { |item| redis.lpush(name, item) }
      # end
      items.each { |item| redis.lpush(name, item) }
    end

    private

    def redis
      Redis.current ||= Redis.connect(Turnpike.options)
    end

    # def redis_version
    #   @redis_version ||= redis.info['redis_version']
    # end
  end
end
