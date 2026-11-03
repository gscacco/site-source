+++
date = "2015-05-12T14:31:23+02:00"
draft = false
title = "Project Euler - Problem 1"
slug = "project-euler-problema-1"
description = "A Clojure solution to the first Project Euler problem, focused on multiples of three and five."
topics = ["programming-languages"]
series = ["project-euler"]
author = " G.Scacco"
tags = ["clojure", "project euler"]
categories = ["programming", "clojure"]
socialsharing = true
+++

[Project Euler](https://projecteuler.net/) is a collection of mathematical and computational problems solved in the programming language of your choice. The first problem is also one of the smallest. The interesting part is not the result: it is seeing how Clojure lets us build a solution from predicates and sequence transformations.

I will assume basic knowledge of [Clojure](https://clojure.org/) and [Leiningen](https://leiningen.org/).

## Multiples, remainders, and a predicate 🧮

The [problem](https://projecteuler.net/problem=1) is defined as follows:

> If we list all the natural numbers below 10 that are multiples of 3 or 5, we get 3, 5, 6 and 9. The sum of these multiples is 23.
> Find the sum of all the multiples of 3 or 5 below 1000.

Start the Clojure REPL with:

    $ lein repl

We can check whether one number is a multiple of another with `rem`, which returns the remainder of integer division:

    user=> (rem 15 5)
    0
    user=> (rem 15 6)
    3

In the first case, 15 is a multiple of 5, so the remainder is 0. In the second, 15 is not a multiple of 6, and the remainder is 3.

Clojure provides the predicate `zero?`, which returns `true` only when its argument is 0:

    user=> (zero? 0)
    true
    user=> (zero? 9)
    false

We can now define the first function:

    user=> (defn multiple? [n d] (zero? (rem n d)))
    user=> (multiple? 15 5)
    true
    user=> (multiple? 15 6)
    false

Now we can combine both predicates:

    user=> (defn multiple-of-three-or-five? [n] (or (multiple? n 3) (multiple? n 5)))
    user=> (multiple-of-three-or-five? 6)
    true
    user=> (multiple-of-three-or-five? 10)
    true

We can generate the sequence of integers with `range`:

    user=> (range 2 10)
    (2 3 4 5 6 7 8 9)

The upper bound is excluded. We start at 2 because 0 and 1 add nothing to the sum; the interesting cases begin with actual multiples.

## Filtering and summing ➕

We filter the sequence with our predicate:

    user=> (filter multiple-of-three-or-five? (range 2 10))
    (3 5 6 9)

Summing a sequence is immediate:

    user=> (reduce + (filter multiple-of-three-or-five? (range 2 10)))
    23

This gives the value from the small example in the problem statement. It is better to wrap the whole expression in a function:

    user=> (defn euler-p1 [max] (reduce + (filter multiple-of-three-or-five? (range 2 max))))

The result for the problem's limit is:

    user=> (euler-p1 1000)
    233168

The solution favors clarity over arithmetic optimization: it filters a lazy sequence and reduces it to a single value. For a limit of 1000, that is more than sufficient, and the code remains easy to verify. The complete version is:

```clojure
(defn- multiple? [n d]
  (zero? (rem n d)))

(defn- multiple-of-three-or-five? [n]
  (or
   (multiple? n 3)
   (multiple? n 5)))

(defn euler-p1 [max]
  (reduce + (filter multiple-of-three-or-five? (range 2 max))))

(euler-p1 1000)
```

## References 🔗

- [Project Euler problem 1](https://projecteuler.net/problem=1)
- [Clojure `rem`](https://clojuredocs.org/clojure.core/rem)
- [Clojure `range`](https://clojuredocs.org/clojure.core/range)
- [Leiningen](https://leiningen.org/)
