require 'turnpike/queue'
require 'turnpike/unique_queue'

module Turnpike
  class << self
    attr_accessor :namespace

    def call(name = 'default', unique: false)
      (unique ? UniqueQueue : Queue).new(name)
    end
    alias [] call
  end

  @namespace = 'turnpike'
end
