require 'redis'
require 'turnpike/queue'

# A Redis-backed queue.
module Turnpike
  class << self
    # Returns a Queue.
    #
    # name - A queue name that responds to to_s.
    def [](name)
      Queue.new name
    end

    # Set Redis connection options.
    #
    # hsh - A Hash of options.
    #
    # Returns nothing.
    def connect(hsh)
      @options = hsh
    end

    # Internal: Returns a Hash of Redis connection options.
    def options
      @options ||= {}
    end
  end
end
