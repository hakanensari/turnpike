require 'turnpike/queue'

# A Redis-backed queue.
module Turnpike
  # Create a queue.
  #
  # name - A queue name that responds to to_s.
  #
  # Returns a Turnpike::Queue.
  def self.[](name)
    Queue.new(name)
  end
end
