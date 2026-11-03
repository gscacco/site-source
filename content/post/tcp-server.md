+++
date = "2015-05-28T15:53:08+02:00"
draft = false
title = "A TCP Server in Clojure"
slug = "un-server-tcp-in-clojure"
description = "Building a small TCP server in Clojure with an agent-based concurrency model."
tags = ["clojure", "tcp server"]
categories = ["programming", "clojure"]
socialsharing = true
+++

## One request, three actions 📨

A TCP server usually suggests a loop, a thread pool, and a connection queue. This example starts with something smaller: mutable state and a queue of asynchronous actions. The goal is not a production-ready server, but understanding how a Clojure agent can coordinate `ServerSocket`, `accept`, and reading a line.

## Why an agent? 🤖

The official documentation ([Clojure agents](https://clojure.org/reference/agents)) describes agents as follows:

> Agents provide shared access to mutable state

Further on, the same documentation says:

>Agents are bound to a single storage location for their lifetime, and only allow mutation of that location (to a new state) to occur as a result of an action.

*Actions* are asynchronous functions that receive the old state as their first argument; the new state is the value they return.

An agent is reactive (it executes functions asynchronously) but not autonomous: all of its behaviour is commanded from the outside. Let us create one:

```clojure
(def a (agent 0))
```

Here, the agent is created with an initial state of 0.

We can both read and modify the agent's state: reading happens through [`deref`](https://clojuredocs.org/clojure.core/deref), while modification happens through the return value of functions *sent* to the agent (see [`send`](https://clojuredocs.org/clojure.core/send) and [`send-off`](https://clojuredocs.org/clojure.core/send-off)).

For example, define the following function:

```clojure
(defn f [old-state]
	(do (Thread/sleep 5000)
	    (inc old-state)))
```
and send it to agent `a`:

```clojure
(send a f)
```

`send` returns immediately. If we dereference agent `a` before the five-second delay expires, we still see `0`; only after the delay does the value become `1`.

Choosing the right function matters. `send` is intended for CPU-bound actions; `send-off` is intended for actions that may block, such as I/O. We will use `send-off` because `accept` and `readLine` can wait for a long time.


```sh
user=> (send a f)
user=> @a
0
user=> @a
0
# after 5 seconds
user=> @a
1
```

## The server state 🧱

We will use classes from the JDK, specifically [`ServerSocket`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/net/ServerSocket.html). First, however, let us define the agent:

```clojure
(agent {:server nil :socket nil})
```
It is a map with two elements: the server and the socket. Initially both are `nil`.

The idea is to do everything inside one function, following these steps:

1. Create the agent with its initial state (both values `nil`).
2. Send the agent a function that creates the `ServerSocket`.
3. Send the agent a function that blocks in `accept`.
4. Send the agent a function that prints the received string.

The three functions in steps 2, 3, and 4 must take the agent state as their first argument and return the new state. Actions are queued on the same agent and executed in order; that is what makes the transition from `ServerSocket` to `socket` and then to reading a predictable sequence.

{{< diagram name="tcp-agent" number="1" caption="The three actions share the same agent state. Each action receives the previous result and returns the state passed to the next action." >}}

Let us start with the first one:

## Implementation 🛠️

```clojure
(ns tcp-server
  (:import (java.io InputStreamReader BufferedReader))
  (:import (java.net ServerSocket)))
  
(defn create-server [state port]
  (let [ss (ServerSocket. port)]
    {:server ss :socket nil}))
```
`create-server` does exactly what it says: it creates a server socket on the given port and returns the new state.

Now the function from step 3:

```clojure
(defn accept-connection [state]
  (let [ss (state :server)
        socket (.accept ss)]
    {:server ss :socket socket}))
```
The mechanics are simple:

* Take the `ServerSocket` from the old state using the `:server` key.
* Call `accept`.
* Return the new state with the socket populated.

The last function is the one from step 4:

```clojure
(defn print-string [state]
  (let [line (->> (state :socket)
                 (.getInputStream)
                 (InputStreamReader.)
                 (BufferedReader.)
                 (.readLine))]
    (println line)))
```
This function is longer mainly because reading a line from the socket requires the [`BufferedReader`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/io/BufferedReader.html) class.

Now comes the main function:

```clojure
(defn tcp-server [port]
  (let [tcp-agent (agent {:server nil :socket nil})
        send-tcp (partial send-off tcp-agent)]
    (do (send-tcp create-server port)
        (send-tcp accept-connection)
        (send-tcp print-string)
        tcp-agent)))
```
This function takes one input: the port on which to create the TCP server. Its definition is simple, but two points are worth noting:

* The `let` binds a partial function, `send-tcp`, to reduce the amount of code needed.
* The functions sent to the agent automatically receive the agent state as their first argument.

`send-off` returns immediately, so `tcp-server` does not wait for the socket to be ready: it returns the agent while the actions continue in the background. To try it, evaluate the expression in a REPL and send a line from another terminal:

```clojure
(def server (tcp-server 8080))
```

```sh
$ nc localhost 8080
```

## What is missing 🧩

This is a teaching example, not a complete server. It accepts one connection, reads one line, sends no response, and does not explicitly close its resources. Also, `print-string` returns `nil`, so after printing, the agent state no longer contains the server or the socket.

A real server would need an `accept` loop, explicit connection handling, resource cleanup, and an error policy. This example shows the coordination model; the rest is engineering work, not agent magic.

## References 🔗

- [Clojure agents](https://clojure.org/reference/agents)
- [Clojure `send-off`](https://clojuredocs.org/clojure.core/send-off)
- [Java `ServerSocket`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/net/ServerSocket.html)
- [Java `BufferedReader`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/io/BufferedReader.html)

