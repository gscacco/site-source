+++
date = "2015-06-15T14:31:23+02:00"
draft = true
title = "Project Euler - Problem 66"
slug = "project-euler-problema-66"
description = "A draft exploration of Pell's equation and Project Euler problem 66."
topics = ["programming-languages"]
series = ["project-euler"]
author = " G.Scacco"
tags = ["clojure", "project euler"]
categories = ["programming", "clojure"]
socialsharing = true
+++

## Problem statement 🧩

The [problem](https://projecteuler.net/problem=66) is stated as follows:

> Consider the quadratic Diophantine equations of the form:
> $$x^2-D\cdot y^2 = 1$$
> For example, when \\(D=13\\), the minimal solution in \\(x\\) is \\(649^2 – 13\cdot 180^2 = 1\\).
> 
> It can be assumed that there are no solutions in positive integers when \\(D\\) is a square.
> 
> By finding the minimal solutions in \\(x\\) for \\(D = \\{ 2, 3, 5, 6, 7 \\}\\), we get:
>
> * \\(3^2 – 2\cdot 2^2 = 1\\)
> * \\(2^2 – 3\cdot 2^2 = 1\\)
> * \\(\color{red}9^2 – 5\cdot 4^2 = 1\\)
> * \\(5^2 – 6\cdot 2^2 = 1\\)
> * \\(8^2 – 7\cdot 3^2 = 1\\)

> Therefore, by considering the minimal solutions in \\(x\\) for \\(D \leq 7\\), the largest \\(x\\) is obtained when \\(D=5\\).

> Find the value of \\(D \leq 1000\\) for which the minimal solution in \\(x\\) is largest.

## References 🔗

- [Project Euler problem 66](https://projecteuler.net/problem=66)
- [Pell's equation](https://en.wikipedia.org/wiki/Pell%27s_equation)
