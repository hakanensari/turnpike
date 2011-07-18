require 'rubygems'
require 'bundler/setup'

require 'test/unit'

require File.expand_path('../lib/turnpike', File.dirname(__FILE__))

class TestTurnpike < Test::Unit::TestCase
  def setup
    Redis.current.flushall
  end

  def time_out_in(seconds, &block)
    original_timeout = Turnpike.timeout
    Turnpike.configure { |c| c.timeout = seconds }
    block.call
    Turnpike.configure { |c| c.timeout = original_timeout }
  end

  def test_emptiness
    queue = Turnpike.new
    assert(queue.empty?)

    queue << 1
    assert(!queue.empty?)

    queue.clear
    assert(queue.empty?)
  end

  def test_pushing_items
    queue = Turnpike.new
    queue.push(1)
    assert_equal(1, queue.length)

    queue.push(2, 3)
    assert_equal(3, queue.length)
    assert_equal(['1', '2', '3'], queue.peek(0, 3))
  end

  def test_unshifting_items
    queue = Turnpike.new
    queue.unshift(1)
    assert_equal(1, queue.length)

    queue.unshift(2, 3)
    assert_equal(3, queue.length)
    assert_equal(['3', '2', '1'], queue.peek(0, 3))
  end

  def test_popping_items
    queue = Turnpike.new
    queue.push(1, 2)
    assert_equal('2', queue.pop)
    assert_equal('1', queue.pop)
    assert_equal(nil, queue.pop)
  end

  def test_shifting_items
    queue = Turnpike.new
    queue.push(1, 2)
    assert_equal('1', queue.shift)
    assert_equal('2', queue.shift)
    assert_equal(nil, queue.shift)
  end

  def test_enumeration
    queue = Turnpike.new
    queue.push(1, 2)
    items = []
    queue.each { |item| items << item }
    assert_equal(['1', '2'], items)

    queue.push(1, 2, 3, 4)
    slices = []
    queue.each_slice(3) { |slice| slices << slice }
    assert_equal([['1', '2', '3'], ['4']], slices)

    queue.push(1, 2)
    slices = []
    queue.each_slice(2) { |slice| slices << slice }
    assert_equal([['1', '2']], slices)
  end

  def test_aliases
    queue = Turnpike.new
    queue << 1
    assert_equal(1, queue.size)
  end

  def test_multiple_queues
    queue1 = Turnpike.new("foo")
    queue2 = Turnpike.new("bar")

    queue1.push(1)
    queue2.push(2, 3)

    assert_equal(1, queue1.length)
    assert_equal(2, queue2.length)
  end

  def test_blocking_pop
    queue = Turnpike.new
    started_at = Time.now.to_i
    Thread.new do
      sleep(1)
      queue.push(1)
    end
    assert_equal(0, queue.length)
    assert_equal('1', queue.pop(true))
    assert_equal(1, Time.now.to_i - started_at)
  end

  def test_blocking_shift
    queue = Turnpike.new
    started_at = Time.now.to_i
    Thread.new do
      sleep(1)
      queue.push(1)
    end
    assert_equal(0, queue.length)
    assert_equal('1', queue.shift(true))
    assert_equal(1, Time.now.to_i - started_at)
  end

  def test_timeout
    time_out_in 1 do
      queue = Turnpike.new
      thread = Thread.new do
        sleep(2)
        queue.push(1)
      end
      assert_equal(0, queue.length)
      assert_equal(nil, queue.shift(true))

      thread.join
      assert_equal(1, queue.length)
    end
  end
end
