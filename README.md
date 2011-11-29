# Turnpike

[![travis](https://secure.travis-ci.org/hakanensari/turnpike.png)](http://travis-ci.org/hakanensari/turnpike)

Turnpike is a Redis-backed FIFO queue.

# Usage

Set up a queue:

    queue = Turnpike["jobs"]

Push items to end of the queue:

    queue << "foo", "bar"

Prioritise by pushing an item to the front of the queue:

    queue.unshift "baz"

Pop items from the queue:

    queue.pop # "baz"
    queue.pop(2) # ["foo", "bar"]
