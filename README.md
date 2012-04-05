# Turnpike

[![travis] [1]] [2]

Turnpike is a Redis-backed queue.

![turnpike] [3]

Less fancily put: Turnike wraps a [Redis List] [4] and speaks Ruby colloquial.

## Installation

```sh
gem install turnpike
```

# Usage

An introspective moment of FIFO.

```ruby
queue = Turnpike['foo']

queue << 1, 2, 3
queue.pop # => 1

queue.peek => [1, 2]
```

[Read the API] [5].

It's really short.

[1]: https://secure.travis-ci.org/hakanensari/turnpike.png
[2]: http://travis-ci.org/hakanensari/turnpike
[3]: http://f.cl.ly/items/33242X323P3M1t1G400H/turnpike.jpg
[4]: http://redis.io/topics/data-types
[5]: https://github.com/hakanensari/turnpike/blob/master/lib/turnpike/queue.rb
