+++
date = "2015-06-15T14:31:23+02:00"
draft = true
title = "Project Euler - Problema 66"
author = " G.Scacco"
lang = "it"
tags = ["clojure", "project euler"]
categories = ["programming", "clojure"]
socialsharing = true
+++

## Definizione del problema

La traduzione in italiano del [Problema 66] è la seguente:


> Consideriamo le equazioni Diofantine quadratiche della forma:
> $$x^2-D\cdot y^2 = 1$$
> Per esempio, quando \\(D=13\\), la minima soluzione in \\(x\\) è \\(649^2 – 13\cdot 180^2 = 1\\).
> 
> Si può assumere che non esistono soluzioni tra gli interi positivi quando D è un quadrato.
> 
> Cercando le soluzioni minime in \\(x\\) per \\(D = \\{ 2, 3, 5, 6, 7 \\}\\), otteniamo:
>
> * \\(3^2 – 2\cdot 2^2 = 1\\)
> * \\(2^2 – 3\cdot 2^2 = 1\\)
> * \\(\color{red}9^2 – 5\cdot 4^2 = 1\\)
> * \\(5^2 – 6\cdot 2^2 = 1\\)
> * \\(8^2 – 7\cdot 3^2 = 1\\)

> Quindi, considerando le soluzioni minime in \\(x\\) per \\(D \leq 7\\), il più grande \\(x\\) si ottiene quando \\(D=5\\).

> Cercate il valore di \\(D \leq 1000\\) nelle soluzioni minime di \\(x\\) per il quale si ottiene il massimo valore di \\(x\\).

[Problema 66]:https://projecteuler.net/problem=66
