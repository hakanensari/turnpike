require 'redis'
require 'turnpike/queue'
require 'turnpike/observer'

# = Turnpike
#
# A Redis-backed messaging queue.
module Turnpike
  class << self
    # Returns a cached or new queue.
    def [](queue)
      @queues[queue] ||= Queue.new(queue)
    end

    # Sets Redis connection options.
    def connect(options)
      @options = options
    end

    # Redis connection options.
    attr :options
  end

  @options, @queues = {}, {}
end
