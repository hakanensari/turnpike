require 'turnpike/queue'
require 'turnpike/unique_queue'

module Turnpike
  def self.call(name = 'default', unique: false)
    (unique ? UniqueQueue : Queue).new(name)
  end
end
