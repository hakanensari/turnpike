# Turnpike

![turnpike][nj]

Turnpike is a minimal [Redis][red]-backed FIFO queue in Ruby.

## Usage

Push and pop:

```ruby
q = Turnpike.call('queue name')
q.push('foo', 'bar', 'baz', 'qux') # => 4
q.pop # => 'foo'
```

Pop multiple items:

```ruby
q.pop(2) # => ['bar', 'baz']
```

Push payload to the front of the queue:

```ruby
q.unshift('foo') # => 2
q.pop # => 'foo"'
```

Use a queue with set-like properties to ensure uniqueness of queued items:

```ruby
q = Turnpike.call('queue name', unique: true)
q.push('foo', 'bar') # => 2
q.push('bar') # => 2
q.pop(3) # => ['foo', 'bar']
```

Turnpike requires Ruby 2.0 and Redis 2.6 or higher.

[nj]: http://f.cl.ly/items/33242X323P3M1t1G400H/turnpike.jpg
[red]: http://redis.io/
