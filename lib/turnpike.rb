require 'redis'
require 'turnpike/queue'

# A Redis-backed queue.
module Turnpike
  # Returns a Queue.
  #
  # name - A queue name that responds to to_s.
  def self.[](name)
    Queue.new(name)
  end
end
