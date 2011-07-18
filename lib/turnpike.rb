require 'redis'

# A Redis-backed queue.
class Turnpike
  class << self
    # Timeout, in seconds, for blocking `pop` or `shift`.
    attr_accessor :timeout

    def configure(&block)
      yield self
    end
  end

  # The name of the queue.
  attr :name

  # Creates a new queue.
  #
  # Takes an optional name.
  def initialize(name = 'default')
    @name = "turnpike:#{name}"
  end

  # Removes all queued items.
  def clear
    redis.del(name)
  end

  # Calls block once for each queued item.
  #
  # Takes an optional boolean argument to specify if the command should block
  # the connection when the queue is empty. This argument defaults to false.
  def each(blocking = false, &block)
    while item = shift(blocking)
      block.call(item)
    end
  end

  # Iterates the given block for each slice of `n` queued items.
  #
  # Takes an optional boolean argument to specify if the command should block
  # the connection when the queue is empty. This argument defaults to false.
  def each_slice(n, blocking = false, &block)
    slice = []

    each(blocking) do |item|
      slice << item
      if slice.size == n
        yield slice
        slice = []
      end
    end

    yield slice unless slice.empty?
  end

  # Returns `true` if the queue is empty.
  def empty?
    length == 0
  end

  # Returns the length of the queue.
  def length
    redis.llen(name)
  end
  alias size length

  # Returns an array of items currently queued.
  #
  # `start` is an integer and indicates the start offset, 0 being the first
  # queued item. If negative, it indicates the offset from the end, -1 being
  # the last queued item.
  #
  # `count` is also an integer and indicates the number of items to return.
  def peek(start, count)
    redis.lrange(name, start, count)
  end

  # Retrieves the last queued item.
  #
  # Takes an optional boolean argument to specify if the command should block
  # the connection when the queue is empty. This argument defaults to false.
  def pop(blocking = false)
    if blocking
      redis.brpop(name, timeout)[1] rescue nil
    else
      redis.rpop(name)
    end
  end

  # Pushes items to the end of the queue.
  def push(*items)
    items.each { |item| redis.rpush(name, item) }
  end
  alias << push

  # Retrieves the first queued item.
  #
  # Takes an optional boolean argument to specify if the command should block
  # the connection when the queue is empty. This argument defaults to false.
  def shift(blocking = false)
    if blocking
      redis.blpop(name, timeout)[1] rescue nil
    else
      redis.lpop(name)
    end
  end

  # Pushes items to the front of the queue.
  def unshift(*items)
    items.each { |item| redis.lpush(name, item) }
  end

  private

  def redis
    Redis.current
  end

  def timeout
    # Timeout will default to 0, which blocks indefinitely.
    self.class.timeout.to_i
  end
end
