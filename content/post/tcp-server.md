+++
date = "2015-05-28T15:53:08+02:00"
draft = false
title = "Un server TCP in Clojure"
lang = "it"
tags = ["clojure", "tcp server"]
categories = ["programming", "clojure"]
socialsharing = true
+++

# Scopo
Lo scopo di questo articolo è quello di mostrare l'implementazione un server tcp in clojure mediante l'uso di un agent.
## Agent
Nella documentazione ufficiale ([Clojure Agents]) l'agent viene descritto come segue:

> Agents provide shared access to mutable state

Estrapolando ancora dalla documentazione ufficiale:

>Agents are bound to a single storage location for their lifetime, and only allow mutation of that location (to a new state) to occur as a result of an action.

Traducendo in italiano:

>Gli agents sono legati ad una singola unità di memorizzazione durante tutta la loro vita. Essi permettono il cambiamento di questa unità di memorizzazione (in un nuovo stato) solo come il risultato di una azione.

Le *azioni* sono funzioni asincrone aventi come primo argomento il vecchio stato; il nuovo stato è il ritorno della loro elaborazione.

L'agent è un'entità reattiva (esegue in modalità asincrona le funzioni) ma non autonoma: tutto il suo comportamento viene comandato dall'*esterno*. Vediamo come crearne uno:

```clojure
(def a (agent 0))
```
qui viene creato un agent il cui stato iniziale è il valore 0.

E' possibile, ovviamente, sia leggere che modificare lo stato dell'agent: la lettura avviene tramite la funzione [deref] mentre la modifica avviene tramite il ritorno delle funzioni *inviate* all'agent (vedi [send] e [send-off]).

Ad esempio, definiamo la seguente funzione:

```clojure
(defn f [vecchio-stato]
	(do (Thread/sleep 5000)
	    (inc vecchio-stato)))
```
ed inviamola all'agent a:

```clojure
(send a f)
```
L'esecuzione della funzione send è immediato. Dereferenziando l'agent a (prima della scadenza del timeout di 5 secondi) troveremmo il valore 0. Solo dopo la scadenza del timeout il valore verrebbe incrementato ad 1.


```sh
user => (send a f)
user => @a
0
user => @a
0
# dopo 5 secondi
user => @a
1
```

# Il server TCP
Utilizzeremo al nostro scopo le classi messe a disposizione dalla JDK. In particolare, faremo uso della classe [ServerSocket]. Ma prima di tutto definiamo il nostro agent:

```clojure
(agent {:server nil :socket nil})
```
Si tratta di una mappa composta di due soli elementi: il server ed il socket. Inizialmente entrambi sono valorizzati a nil.

L'idea è di realizzare il tutto all'interno di una funzione ed effettuare i seguenti passi elementari:

1. Creare l'agent con il suo stato iniziale (tutto a nil)
2. Inviare all'agent una funzione che crei il ServerSocket
3. Inviare all'agent una funzione che si fermi in accept
4. Inviare all'agent una fiunzione che stampi a schermo la stringa ricevuta

Le tre funzioni ai punti 2, 3 e 4 devono avere come primo parametro lo stato dell'agent e restituire il nuovo stato. Iniziamo realizzando la prima:

## Implementazione

```clojure
(ns tcp-server
  (:import (java.io InputStreamReader BufferedReader))
  (:import (java.net ServerSocket)))
  
(defn create-server [stato port]
  (let [ss (ServerSocket. port)]
    {:server ss :socket nil}))
```
La definizione della funzione *create-server* fa esattamente quanto detto: crea un server socket sulla porta fornita in input e restituisce il nuovo stato.

Creiamo ora la funzione di cui al punto 3:

```clojure
(defn accept-connection [stato]
  (let [ss (stato :server)
        socket (.accept ss)]
    {:server ss :socket socket}))
```
Anche qui il funzionamento è abbastanza semplice:

* preleviamo l'oggetto ServerSocket dal vecchio stato (essendo una mappa basta riferire la chiave :server)
* invochiamo il metodo *accept*
* restituiamo il nuovo stato con socket valorizzato

L'ultima funzione da realizzare è quella di cui al punto 4:

```clojure
(defn print-string [stato]
  (let [str (->> (stato :socket)
                 (.getInputStream)
                 (InputStreamReader.)
                 (BufferedReader.)
                 (.readLine))]
    (println str)))
```
Questa funzione è un po' più lunga solo perché, per leggere una riga di testo dal socket, dobbiamo utilizzare la classe BufferedReader.

A questo punto manca solo la definizione della funzione principale:

```clojure
(defn tcp-server [port]
  (let [tcp-agent (agent {:server nil :socket nil})
        send-tcp (partial send-off tcp-agent)]
    (do (send-tcp create-server port)
        (send-tcp accept-connection)
        (send-tcp print-string)
        tcp-agent)))
```
Questa funzione ha un solo parametro di input: il numero della porta su cui creare il server tcp. La sua definizione è abbastanza semplice ma vorrei evidenziare alcuni punti:

* all'interno della let ho creato un binding con una funzione parziale *send-tcp* per ridurre il codice necessario
* le funzioni inviate riceveranno in automatico come primo parametro lo stato dell'agent

 Per domande o dubbi vi prego di utilizzare il form disqus sottostante.

[Clojure Agents]:http://clojure.org/agents
[deref]:http://clojuredocs.org/clojure.core/deref
[send]:http://clojuredocs.org/clojure_core/clojure.core/send
[send-off]:http://clojuredocs.org/clojure_core/clojure.core/send-off
[ServerSocket]:http://docs.oracle.com/javase/7/docs/api/java/net/ServerSocket.html

