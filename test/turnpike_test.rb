require File.expand_path('helper.rb', File.dirname(__FILE__))

class TestTurnpike < Test::Unit::TestCase
  def setup
    Redis.current.flushall
  end

  def time_out_in(queue, seconds, &block)
    original_timeout = queue.timeout
    queue.timeout = seconds
    block.call
    queue.timeout = original_timeout
  end

  def test_bracket_method
    assert_equal 'turnpike:foo', Turnpike['foo'].name
    assert Turnpike['foo'] == Turnpike["foo"]
  end

  def test_emptiness
    queue = Turnpike::Queue.new
    assert queue.empty?

    queue << 1
    assert !queue.empty?

    queue.clear
    assert queue.empty?
  end

  def test_pushing_items
    queue = Turnpike::Queue.new
    queue.push 1
    assert_equal 1, queue.length

    queue.push 2, 3
    assert_equal 3, queue.length
    assert_equal ['1', '2', '3'], queue.peek(0, 3)
  end

  def test_unshifting_items
    queue = Turnpike::Queue.new
    queue.unshift 1
    assert_equal 1, queue.length

    queue.unshift 2, 3
    assert_equal 3, queue.length
    assert_equal ['3', '2', '1'], queue.peek(0, 3)
  end

  def test_popping_items
    queue = Turnpike::Queue.new
    queue.push 1, 2
    assert_equal '2', queue.pop
    assert_equal '1', queue.pop
    assert_equal nil, queue.pop
  end

  def test_shifting_items
    queue = Turnpike::Queue.new
    queue.push 1, 2
    assert_equal '1', queue.shift
    assert_equal '2', queue.shift
    assert_equal nil, queue.shift
  end

  def test_enumeration
    queue = Turnpike::Queue.new
    queue.push 1, 2
    items = []
    queue.each { |item| items << item }
    assert_equal ['1', '2'], items

    queue.push 1, 2, 3, 4
    slices = []
    queue.each_slice(3) { |slice| slices << slice }
    assert_equal [['1', '2', '3'], ['4']], slices

    queue.push(1, 2)
    slices = []
    queue.each_slice(2) { |slice| slices << slice }
    assert_equal [['1', '2']], slices
  end

  def test_aliases
    queue = Turnpike::Queue.new
    queue << 1
    assert_equal 1, queue.size
  end

  def test_multiple_queues
    queue1 = Turnpike::Queue.new("foo")
    queue2 = Turnpike::Queue.new("bar")

    queue1.push 1
    queue2.push 2, 3

    assert_equal 1, queue1.length
    assert_equal 2, queue2.length
  end

  def test_blocking_pop
    queue = Turnpike::Queue.new
    started_at = Time.now.to_i
    Thread.new do
      sleep 1
      queue.push 1
    end
    assert_equal 0, queue.length
    assert_equal '1', queue.pop(true)
    assert Time.now.to_i - started_at > 0
  end

  def test_blocking_shift
    queue = Turnpike::Queue.new
    started_at = Time.now.to_i
    Thread.new do
      sleep 1
      queue.push 1
    end
    assert_equal 0, queue.length
    assert_equal '1', queue.shift(true)
    assert Time.now.to_i - started_at > 0
  end

  def test_timeout
    queue = Turnpike::Queue.new
    time_out_in queue, 1 do
      thr = Thread.new do
        sleep 3
        queue.push 1
      end
      assert_equal 0, queue.length
      assert_equal nil, queue.shift(true)

      thr.join
      assert_equal 1, queue.length
    end
  end

  def test_observer
    items = ['foo', 'bar']
    queue = Turnpike::Queue.new
    Thread.new do
      sleep 1
      queue.notify *items
    end

    assert queue.observe *items

    started_at = Time.now
    items << { :timeout => 1 }
    assert !queue.observe(*items)
    assert Time.now - started_at < 1.25
  end
end
