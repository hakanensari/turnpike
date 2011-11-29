require 'redis'
require 'turnpike/queue'

# = Turnpike
#
# A Redis-backed first-in-first-out queue
module Turnpike
  class << self
    # Returns a queue
    # @param [#to_s] queue
    def [](queue)
      Queue.new(queue)
    end

    # Sets Redis connection options
    # @param [Hash] options
    def connect(options)
      @options = options
    end

    # @return [Hash] Redis connection options
    def options
      @options ||= {}
    end
  end
end
