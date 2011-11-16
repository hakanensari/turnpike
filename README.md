# Turnpike

[![travis](https://secure.travis-ci.org/hakanensari/turnpike.png)](http://travis-ci.org/hakanensari/turnpike)

Turnpike is a Redis-backed queue.

# Usage

Set up a queue:

    queue = Turnpike['foo']

Push some items to the queue:

    queue << 1, 2

Prioritise a third item:

    queue.unshift 3

Pop items from the queue:

    queue.pop # "3"
    queue.pop(2) # ["1", "2"]
