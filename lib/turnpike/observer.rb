module Turnpike
  class Observer
    def initialize(name, *items)
      @timeout      = items.last.is_a?(Hash) ? items.pop[:timeout] : 10
      @name, @items = name, items
    end

    def observe
      if reactor_running?
        timer = EM.add_timer(@timeout) { unsubscribe }
        subscribe && EM.cancel_timer(timer)
      else
        thr = Thread.new { subscribe }
        !!thr.join(@timeout)
      end
    end

    private

    def reactor_running?
      defined?(EM) && EM.reactor_running?
    end

    def subscribe
      redis.subscribe(@name) do |on|
        on.message do |channel, message|
          message.split('|').each { |item| @items.delete(item) }
          unsubscribe if @items.empty?
        end
      end

      @items.empty?
    end

    def redis
      @redis ||= Redis.connect(Turnpike.options)
    end

    def unsubscribe
      redis.unsubscribe
    end
  end
end
