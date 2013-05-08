# Turnpike

![turnpike][nj]

Turnpike wraps [Redis][redis], uses [Message Pack][msgpack], and speaks Ruby.

```ruby
queue = Turnpike['foo']
queue << 1, 2, 3
queue.pop # => 1
queue << 4
queue.unshift(1)
queue.pop(4) # => [1, 2, 3, 4]
```

Turnpike requires Redis 2.4 or higher.

[nj]: http://f.cl.ly/items/33242X323P3M1t1G400H/turnpike.jpg
[redis]: http://redis.io/
[msgpack]: http://msgpack.org/
