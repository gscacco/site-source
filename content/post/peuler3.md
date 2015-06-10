+++
date = "2015-06-08T14:31:23+02:00"
draft = false
title = "Project Euler - Problema 3"
author = " G.Scacco"
lang = "it"
tags = ["clojure", "project euler"]
categories = ["programming", "clojure"]
socialsharing = true
+++

## Definizione del problema

Per prima cosa la definizione del problema è la seguente:

> The prime factors of 13195 are 5, 7, 13 and 29.
> 
> What is the largest prime factor of the number 600851475143 ?

La traduzione in italiano recita:

> I fattori primi di 13195 sono 5, 7, 13 e 29.
>
> Quale è il più grande fattore primo del numero 600851475143 ?

## Verifica di primalità

*Un numero è primo se e solo se è divisibile solo per 1 e per se stesso.*

Sono stati proposti numerosi metodi per verificare la primalità di un numero (vedi [Test Primalità]); alcuni sono efficienti ma molto complessi da implementare.
Io utilizzerò un metodo semplice anche se poco efficiente: dato n il numero di cui si vuole verificare la primalità, si eseguono i seguenti passi

1. si elencano tutti i numeri compresi tra 2 e \\(\sqrt{n}\\)
1. si calcola il resto della divisione intera con n
1. si verifica che tutti i resti siano diversi da zero

### Codifica in clojure

```clojure
(defn prime? [n]
  (let [max (Math/sqrt n)
        v (range 2 (inc max))
        mv (map #(pos? (rem n %)) v)]
    (every? true? mv)))
```

Possiamo verificare in repl:

```sh
user => (prime? 12)
false
user => (prime? 167)
true
user => (prime? 123)
true
```

## Soluzione
A questo punto applichiamo il predicato *prime?* appena definito. Procediamo nel seguente modo:

1. definiamo una costante con il numero del problema
1. calcoliamo la radice quadrata anche per lui
1. creiamo un range decrescente
1. preleviamo solo i numeri primi divisori
1. prendiamo il primo

```clojure
(def p3-number 600851475143)
(def sq-p3-number (int (Math/sqrt p3-number)))

(def p3-solution (->> (range sq-p3-number 2 -1)
                      (filter #(and (prime? %) (zero? (rem p3-number %))))
                      first))
```

[Test Primalità]:http://it.wikipedia.org/wiki/Test_di_primalit%C3%A0
