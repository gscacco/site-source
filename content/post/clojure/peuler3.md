+++
date = "2015-06-08T14:31:23+02:00"
draft = false
title = "Project Euler - Problem 3"
slug = "project-euler-problema-3"
description = "A straightforward primality test and a Clojure solution to Project Euler problem 3."
topics = ["programming-languages"]
series = ["project-euler"]
author = " G.Scacco"
tags = ["clojure", "project euler"]
categories = ["programming", "clojure"]
socialsharing = true
+++

## Problem statement 🧩

The number 600851475143 looks large enough to require a sophisticated algorithm. A naive primality test is enough, as long as we use it carefully.

The problem is:

> The prime factors of 13195 are 5, 7, 13 and 29.
> 
> What is the largest prime factor of the number 600851475143 ?

## Checking for primality 🔍

*A number is prime if and only if it is divisible only by 1 and itself.*

Many primality tests exist (see [primality test](https://en.wikipedia.org/wiki/Primality_test)); some are efficient but considerably more complex to implement. I will use a simple, inefficient method: given `n`, perform the following steps:

1. List every number between 2 and \\(\sqrt{n}\\).
1. Calculate the remainder of integer division by `n`.
1. Check that every remainder is non-zero.

The check stops at the square root because, if `n` had a larger divisor, it would necessarily have a smaller one as well. This is a reasonable trade-off for the problem, but it remains a trial-division test: the `(> n 1)` guard excludes `1`, `0`, and negative numbers, and the cost grows quickly for much larger inputs.

### Clojure implementation

```clojure
(defn prime? [n]
  (and (> n 1)
       (let [max (int (Math/sqrt n))
             divisors (range 2 (inc max))]
         (every? #(pos? (rem n %)) divisors))))
```

We can verify this in the REPL:

```sh
user=> (prime? 12)
false
user=> (prime? 2)
true
user=> (prime? 167)
true
user=> (prime? 123)
false
```

`123` is divisible by `3`, so it is not prime. The example is also a reminder that a primality test must do more than find divisors: it must return `false` as soon as it finds one.

## Solution 🎯

We now apply the `prime?` predicate. The process is:

1. Define a constant for the problem's number.
1. Calculate its square root.
1. Create a descending range.
1. Keep only the prime divisors.
1. Take the first one.

```clojure
(def p3-number 600851475143)
(def sq-p3-number (int (Math/sqrt p3-number)))

(def p3-solution (->> (range sq-p3-number 1 -1)
                      (filter #(and (prime? %) (zero? (rem p3-number %))))
                      first))
```

The lower bound `1` is excluded by `range`, so the last candidate included is `2`. The result is:

```clojure
user=> p3-solution
6857
```

## References 🔗

- [Project Euler problem 3](https://projecteuler.net/problem=3)
- [Primality test](https://en.wikipedia.org/wiki/Primality_test)
- [Clojure `every?`](https://clojuredocs.org/clojure.core/every_q)
- [Clojure `range`](https://clojuredocs.org/clojure.core/range)
