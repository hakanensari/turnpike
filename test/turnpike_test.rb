$: << File.expand_path('../lib', File.dirname(__FILE__))
require 'minitest/autorun'
require 'minitest/benchmark' if ENV['BENCH']
require 'turnpike'

class TestTurnpike < MiniTest::Test
  def test_lambdalike
    assert_kind_of Turnpike::Queue, Turnpike.call
    assert_kind_of Turnpike::Queue, Turnpike.()
    assert_kind_of Turnpike::Queue, Turnpike[]
  end

  def test_unique_call
    assert_kind_of Turnpike::UniqueQueue, Turnpike.call(unique: true)
  end

  def test_queue_name
    queue = Turnpike::Base.new('foo')
    assert_includes queue.name, 'foo'
  end

  def test_namespace
    orig = Turnpike.namespace
    Turnpike.namespace = 'foo'
    queue = Turnpike::Base.new('bar')
    assert_equal queue.name, 'foo:bar'
    Turnpike.namespace = orig
  end

  def test_abstract_class
    queue = Turnpike::Base.new('foo')
    %w(push pop bpop unshift size).each do |mth|
      assert_raises(NotImplementedError) { queue.send(mth) }
    end
  end

  def bench_queue
    queue = Turnpike.call
    assert_performance_linear do |n|
      queue.push(*(1..n).to_a)
      1.upto(n) { queue.pop }
    end
  end

  def bench_unique
    queue = Turnpike.call(unique: true)
    assert_performance_linear do |n|
      queue.push(*(1..n).to_a)
      1.upto(n) { queue.pop }
    end
  end
end

module QueueTests
  def queue
    @queue ||= klass.new('foo')
  end

  def setup
    Redis.current.flushall
  end

  def test_push
    queue.push(1)
    assert_equal 1, queue.size
    queue.push(2, 3)
    assert_equal [1, 2, 3], peek(queue)
  end

  def test_emptiness
    assert queue.empty?
    queue << 1
    assert !queue.empty?
    queue.clear
    assert queue.empty?
  end

  def test_unshift
    queue.push(1)
    queue.unshift(2, 3)
    assert_equal 3, queue.size
    assert_equal 1, peek(queue).last
  end

  def test_pop
    queue.push(1, 2)
    assert_equal 1, queue.pop
    assert_equal 2, queue.pop
    assert_nil queue.pop
  end

  def test_pop_many
    queue.push(1, 2, 3)
    assert_equal [1, 2], queue.pop(2)
    assert_equal [3], queue.pop(2)
    assert_equal [], queue.pop(2)
  end

  def test_order
    queue.push(1, 2)
    queue.unshift(3)
    assert_equal 3, queue.pop
    assert_equal 1, queue.pop
    assert_equal 2, queue.pop
  end

  def test_multiplicity
    q1 = klass.new('foo')
    q2 = klass.new('bar')
    q1.push(1)
    q2.push(2, 3)
    assert_equal 1, q1.size
    assert_equal 2, q2.size
  end
end

class TestQueue < MiniTest::Test
  include QueueTests

  def klass; Turnpike::Queue; end

  def peek(queue)
    queue.redis.lrange(queue.name, 0, -1).map { |i| queue.unpack(i) }
  end

  def test_blocking_pop
    Thread.new {
      sleep 0.1
      klass.new('foo', redis: Redis.new).push(3)
      queue.push(3)
    }
    queue.push(1, 2)
    assert_equal [1, 2], queue.bpop(2)
    assert_equal 3, queue.bpop
  end

  def test_non_blocking_enumeration
    klass.class_eval do
      include Enumerable
      def each(&blk)
        while x = pop
          blk.call(x)
        end
      end
    end
    queue.push(1, 2)
    assert_equal [1, 2], queue.to_a
  end
end

class TestUniqueQueue < MiniTest::Test
  include QueueTests

  def klass; Turnpike::UniqueQueue; end

  def peek(queue)
    queue.redis.zrange(queue.name, 0, -1).map { |i| queue.unpack(i) }
  end

  def test_blocking_pop
    assert_raises(NotImplementedError) { queue.bpop }
  end
end
