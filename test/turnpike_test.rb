require 'bundler/setup'
require 'test/unit'

require File.expand_path('../lib/turnpike', File.dirname(__FILE__))

class TestTurnpike < Test::Unit::TestCase
  def setup
    Redis.current.flushall
  end

  def test_bracket
    queue = Turnpike['foo']
    assert_kind_of Turnpike::Queue, queue
    assert_equal 'turnpike:foo', queue.name
  end

  def test_emptiness
    queue = Turnpike::Queue.new
    assert queue.empty?

    queue << 1
    assert !queue.empty?

    queue.clear
    assert queue.empty?
  end

  def test_push
    queue = Turnpike::Queue.new
    queue.push 1
    assert_equal 1, queue.size

    queue.push 2, 3
    assert_equal 3, queue.size
    assert_equal ['1', '2', '3'], queue.peek
  end

  def test_unshift
    queue = Turnpike::Queue.new
    queue.unshift 1
    assert_equal 1, queue.size

    queue.unshift 2, 3
    assert_equal 3, queue.size
    assert_equal ['3', '2', '1'], queue.peek
  end

  def test_pop
    queue = Turnpike::Queue.new
    queue.push 1, 2
    assert_equal '1', queue.pop
    assert_equal '2', queue.pop
    assert_equal nil, queue.pop
  end

  def test_pop_many
    queue = Turnpike::Queue.new
    queue.push 1, 2, 3
    assert_equal ['1', '2'], queue.pop(2)
    assert_equal ['3'], queue.pop(2)
    assert_equal [], queue.pop(2)
  end

  def test_order
    queue = Turnpike::Queue.new
    queue.push 1, 2
    queue.unshift 3
    assert_equal '3', queue.pop
    assert_equal '1', queue.pop
    assert_equal '2', queue.pop
  end

  def test_multiple_queues
    queue1 = Turnpike::Queue.new("foo")
    queue2 = Turnpike::Queue.new("bar")

    queue1.push 1
    queue2.push 2, 3

    assert_equal 1, queue1.size
    assert_equal 2, queue2.size
  end

  def test_peek
    queue = Turnpike::Queue.new
    assert_equal [], queue.peek
    queue << 1
    assert_equal ['1'], queue.peek
  end
end
