+++
date = "2015-05-12T14:31:23+02:00"
draft = false
title = "Project Euler - Problema 1"
author = " G.Scacco"
lang = "it"
tags = ["clojure", "project euler"]
categories = ["programming", "clojure"]
+++

# Project Euler

[Project Euler](https://projecteuler.net/) è un interessantissimo sito web contenente una raccolta di problemi. Si tratta di sfide matematiche ed informatiche da risolvere tramite l'uso di un linguaggio di programmazione a scelta. Molti sono gli utenti registrati che si sono impegnati nelle varie soluzioni e nei più disparati linguaggi: si va dal lingiaggio macchia a Java, dal c++ al lisp, etc.

Vorrei proporvi in questo post (e spero in altri) le mie soluzioni in clojure.


Darò per scontata una conoscenza base del linguaggio [clojure](http://clojure.org/) e la conoscenza del tool [Leingen](http://leiningen.org/)

## Multipli di 3 e 5

Il [problema](https://projecteuler.net/problem=1) è così definito:

> If we list all the natural numbers below 10 that are multiples of 3 or 5, we get 3, 5, 6 and 9. The sum of these multiples is 23.
> Find the sum of all the multiples of 3 or 5 below 1000.

In italiano:

> Se elenchiamo tutti i numeri naturali inferiori a 10 che sono multipli di 3 o di 5 otteniamo 3, 5, 6 e 9. La somma di questi multipli è 23.
> Trova la somma di tutti i multipli di 3 e 5 inferiori a 1000.

Lanciamo la consolle repl di clojure tramite il comando:

    $ lein repl

Possiamo verificare se un numero è multiplo di un altro in clojure utilizzando la funzione *rem* (resto della divisione intera).

    user=> (rem 15 5)
    0
    user=> (rem 15 6)
    3

Nel primo caso essendo 15 multiplo di 5 il risultato è 0; nel secondo 15 non è multiplo di 6 ed il risultato è 3 (il resto della divisione intera tra 15 e 6).

In clojure esiste il predicato *zero?* che torna true solo se il suo argomento è 0, false altrimenti:

    user=> (zero? 0)
    true
    user=> (zero? 9)
    false

A questo punto possiamo definire la nostra prima funzione:

    user=> (defn multiplo? [n d] (zero? (rem n d)))
    user=> (multiplo? 15 5)
    true
    user=> (multiplo? 15 6)
    false

E per concludere:

    user=> (defn multiplo-di-tre-o-cinque? [n] (or (multiplo? n 3) (multiplo? n 5)))
    user=> (multiplo-di-tre-o-cinque? 6)
    true
    user=> (multiplo-di-tre-o-cinque? 10)
    true
Possiamo generare la lista dei numeri interi utilizzando la funzione *range*:

    user=> (range 2 10)
    (2 3 4 5 6 7 8 9)

e filtrare in base al nostro predicato *multiplo-di-tre-o-cinque?*:

    user=> (filter multiplo-di-tre-o-cinque? (range 2 10))
    (3 5 6 9)

fare la somma di una lista è semplice:

    user=> (reduce + (filter multiplo-di-tre-o-cinque? (range 2 10)))
    23

In questo modo abbiamo riottenuto il valore proposto nel caso semplice nella definizione del problema. Meglio definire, una funzione:

    user=> (defn eulero-p1 [max] (reduce + (filter multiplo-di-tre-o-cinque? (range 2 max))))

Siamo arrivati alla fine:

    user=> (eulero-p1 1000)
    233168

Quindi, in sintesi:

``` clojure
(defn- multiplo? [n d]
  (zero? (rem n d)))

(defn- multiplo-di-tre-o-cinque? [n]
  (or
   (multiplo? n 3)
   (multiplo? n 5)))

(defn eulero-p1 [max]
  (reduce + (filter multiplo-di-tre-o-cinque? (range 2 max))))

(eulero-p1 1000)
```
