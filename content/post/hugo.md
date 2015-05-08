+++
date = "2015-05-04T12:35:03+02:00"
draft = false
title = "hugo - Static Site Generator"
author = " G.Scacco"
lang = "it"
tags = ["hugo", "web"]
categories = ["web"]
+++

## Introduzione

I *Content Management Systems* (CMS) comunemente utilizzati dai bloggers sono applicazioni web basate su un db (generalmente MySql) ed implementate in un linguaggio di programmazione di alto livello: php, java, c#, etc.

Il db rappresenta la base dati dentro la quale vengono inseriti gli articoli, le pagine e le altre informazioni necessarie al funzionamento del CMS.

Quando un utente accede tramite il suo browser al sito web, il web server esegue esegue i seguenti passi elementari:

1. analisi della richiesta
2. accesso e query al db
3. generazione di una pagina html
4. invio della pagina generata

Tutto questo ha un costo non banale in termini di cpu, ram ed io: al crescere del numero degli utenti connessi devono di conseguenza crescere le risorse impiegate.

Il mercato ha dato un prezzo a questa necessità e i vari providers (aruba, hostgator, etc.) richiedono il pagamento di un abbonamento annuale a costo crescente in base alle performances richieste.

Ma tutte queste performances servono *veramente* ?

Generare ogni volta al volo le pagine html degli articoli è veramente necessario o si potrebbero generare una volta per tutte staticamente ?

La risposta sono gli *Static Site Generators*.

## La soluzione hugo

[hugo](http://gohugo.io) è uno Static Site Generator scritto in go. Le sue caratteristiche fondamentali sono le seguenti:

* Velocità nel rendering statico delle pagine
* Semplicità di utilizzo
* Portabilità (gira praticamente su tutte le piattaforme)
* Flessibilità

Ma soprattutto è open source (SimPL-2.0).

Su arch esiste un pacchetto AUR e quindi per istallarlo basta eseguire:

    $ yaourt hugo

A questo punto creare un blog è molto semplice:

    $ mkdir my-blog
    $ cd my-blog
    $ hugo new site .

All'interno della cartella my-blog sarà presente un file di configurazione del sito web: config.toml. Questo file va modificato in accordo alle esigenze del caso. Il contenuto del file è abbastanza semplice ed autoesplicativo:

    baseurl = "http://yourSiteHere/"
    languageCode = "en-us"
    title = "My New Hugo Site"

A questo punto possiamo aggiungere il primo post del blog con il seguente comando:

    $ hugo new post/primoarticolo.md

Il comando produrrà il seguente file markdown:

    +++
    date = "2015-05-05T11:44:32+02:00"
    draft = true
    title = "prova"

    +++

L'unico parametro *funzionale* dell'intestazione è *draft*: se true hugo non lo inserirà nel sito generato. Il contenuto dell'articolo dovrà essere inserito dopo l'intestazione e quindi dopo l'ultimo +++.

hugo è skinnable con diversi temi disponibili su github. Per utilizzarli basta eseguire il seguente comando:

    $ git clone --recursive https://github.com/spf13/hugoThemes themes

L'applicazione fornisce un piccolo server web che consente la preview del sito. Per attivarlo basta eseguire:

    $ hugo server --theme=shiori --buildDrafts

L'opzione theme consente di scegliere il tema mentre buildDrafts dice a hugo di presentare anche gli articoli con il parametro draft impostato a true.

Una volta completato l'articolo si può generare il sito web definitivo con il comando:

    $ hugo -t shiori

Dopo questo comando la cartella public conterrà i files pronti per essere pubblicati.

