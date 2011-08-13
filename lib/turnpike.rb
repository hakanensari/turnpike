require 'redis'
require 'turnpike/queue'

# = Turnpike
#
# A Redis-backed queue.
module Turnpike
  class << self
    def options
      @options ||= {}
    end

    # Timeout for blocking `pop` or `shift`.
    attr_accessor :timeout

    @timeout = 0

    def connect(options)
      @options = options
    end

    # Returns a cached or new queue.
    def [](queue)
      @queues[queue] ||= Queue.new(queue)
    end
  end

  @queues = Hash.new
end
