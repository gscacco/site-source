+++
date = "2026-06-22T15:14:00+02:00"
draft = false
title = "EDN and the Challenge of Making Complex Data Readable"
tags = ["clojure", "clojurescript", "spreadsheet", "scittle", "lisp"]
categories = ["programming", "clojure"]
socialsharing = true
+++

# Introduction

EDN (Extensible Data Notation) is a data representation format used in the Clojure ecosystem. Its strength lies in its simplicity and flexibility: maps, vectors, lists, sets, and atomic values can be combined to represent complex structures.

However, a structure that is easy for a program to process is not necessarily easy for a human to understand.

Consider the following example:

```clojure
{:name "Garden"
 :budget [1200 3400 1200]
 :status :active
 :team {:lead "Alice"
        :members ["Bob" "Carol"]}}
```

The textual representation is compact and precise. Yet as structures grow in size and depth, nested collections become harder to follow. Readers must mentally reconstruct the relationships between properties and values.

## One Structure, Multiple Views

A natural solution is to represent EDN data as an interactive tree. Maps become expandable nodes, vectors become ordered collections, and atomic values are displayed directly.

This makes the hierarchical structure easier to explore, but a tree is not always the best representation.

Suppose we want to compare the budgets and statuses of dozens of projects. A table would probably be more effective. If we want to transform the data using Clojure functions, the textual representation may be more convenient.

Each view highlights certain aspects of the underlying structure while making others less visible. There is no universally optimal representation: the most useful view depends on the task.

## Separating Data from Presentation

A promising approach is to keep EDN as the canonical data model while providing multiple views of the same content.

An interactive tree supports exploration. A tabular view facilitates comparison and aggregation. A text editor provides direct access to the original EDN representation.

Ideally, these views should remain synchronized. Changes made through one representation should be reflected in the others without creating competing versions of the data.

This separation becomes even more interesting when EDN is used alongside Clojure expressions. A cell in a computational environment might contain a map, another cell might extract one of its properties, and a third might calculate an aggregate value.

The interface must then do more than display data. It must support exploration, transformation, and computation.

## From Data Viewer to Interactive Environment

The challenge is to balance the expressive power of EDN with the readability required for effective human interaction.

There is no need to abandon the original data structure to make it accessible. Instead, the textual representation can be treated as one interface to the underlying model, rather than the only possible one.

An environment built with ClojureScript can take advantage of this separation. The data model remains consistent, while the interface adapts its presentation to the operation being performed.

The goal is not to simplify EDN itself, but to make complex data easier to understand and manipulate without sacrificing its expressive power.
