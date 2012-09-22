# Turnpike

[![travis][1]][2]

Turnpike is a Redis-backed queue that wraps a [List][4] and speaks Ruby
colloquial.

![turnpike][3]

# Usage

```ruby
queue = Turnpike['foo']

queue << 1, 2, 3
queue.pop # => 1
queue.peek # => [2, 3]

queue << 4
queue.peek # => [2, 3, 4]

queue.unshift 1
queue.peek # => [1, 2, 3, 4]
```

[Read the API] [5].

[1]: https://secure.travis-ci.org/hakanensari/turnpike.png
[2]: http://travis-ci.org/hakanensari/turnpike
[3]: http://f.cl.ly/items/33242X323P3M1t1G400H/turnpike.jpg
[4]: http://redis.io/topics/data-types
[5]: https://github.com/hakanensari/turnpike/blob/master/lib/turnpike/queue.rb
