module Turnpike
  # A Redis pubsub subscription.
  class Subscription
    def initialize(name)
      @name = name
    end

    def subscribe(*items)
      redis.subscribe(@name) do |on|
        on.message do |channel, message|
          message.split('|').each { |item| items.delete(item) }
          unsubscribe if items.empty?
        end
      end
      items.empty?
    end

    def unsubscribe
      redis.unsubscribe
    end

    private

    def redis
      @redis ||= Redis.connect(Turnpike.options)
    end
  end
end
