# Turnpike

[![travis](https://secure.travis-ci.org/papercavalier/turnpike.png)](http://travis-ci.org/papercavalier/turnpike)

Turnpike is a Redis-backed processing queue.

# Usage

Set up:

```ruby
require "turnpike"

queue = Turnpike.new(:processing_queue)
```

Queue:

```ruby
queue << "unit of work"
```

Process:

```ruby
queue.each do |work|
  # create value
end

# alternatively
queue.each_slice(10) do |slice)
  # create value
end
```
