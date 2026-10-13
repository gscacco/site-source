+++
date = "2026-06-13T14:00:00+02:00"
draft = false
title = "Rethinking the Spreadsheet as a Programmable Environment"
tags = ["clojure", "clojurescript", "spreadsheet", "scittle", "lisp"]
categories = ["programming", "clojure"]
socialsharing = true
+++

# Introduction

Spreadsheets are among the most successful programming environments ever created. Millions of people use them to organize information, express relationships, perform calculations, and build small applications.

Yet the spreadsheet model has remained remarkably stable: cells contain either values or formulas, and formulas belong to a special-purpose language.

What if we removed this distinction?

What if every cell contained an expression in a general-purpose programming language? What if data, calculations, and functions shared the same underlying model? And what if the entire environment could be distributed as a single HTML file, without requiring a server or an installation process?

These questions are the starting point for a different vision of the spreadsheet: a self-contained programming environment built around ClojureScript.

# Cells as expressions

Consider a cell containing a project description:

```clojure
{:name "Community Garden"
 :budget 12500
 :status :active}
```

Another cell could extract its budget:

```clojure
(:budget C2)
```

A third could transform the original value:

```clojure
(assoc C2 :status :completed)
```

These are ordinary ClojureScript expressions, not formulas in a separate language.

A cell could contain a number, a string, a map, a vector, or a function call. The same language would be used to represent data and manipulate it.

This is the central idea: **a cell is not merely a box containing a value or a formula. It is a place where a programming-language expression can be evaluated and its result explored.**

Consider a project with a budget composed of several items:

```clojure
{:name "Community Garden"
 :budget [1200 3500 800]
 :status :active}
```

Another cell could calculate the total:

```clojure
(reduce + (:budget C3))
```

No spreadsheet-specific function is needed. The calculation uses the ordinary functions and data structures of ClojureScript.

The grid remains familiar, but the computational model becomes considerably more expressive.

# Why ClojureScript?

ClojureScript provides a consistent way to represent both data and computation. Its immutable data structures and collection-oriented functions make it natural to transform structured values without introducing a separate formula language.

Its Lisp syntax also offers an interesting opportunity for the user interface. Expressions have an explicit structure that an editor can understand, potentially supporting structural navigation, bracket matching, and other editing facilities beyond ordinary text editing.

The objective is not to force every spreadsheet user to become a programmer. It is to explore whether a familiar visual interface can make a programming language useful for everyday data manipulation.

# An autonomous web application

The second principle concerns how the application is delivered.

Instead of depending on a remote service, the application would be a self-contained HTML document that runs directly in the browser. Data, expressions, and user-defined functions would belong to the document itself.

The browser would not simply provide an interface to a server. It would be the execution environment.

This approach offers portability, low operational overhead, and independence from a hosted application service. A document could be copied, archived, and reopened without deploying infrastructure or maintaining a backend.

Autonomy does not necessarily mean zero external dependencies. Libraries would need to be bundled or made available locally to guarantee offline operation. Collaboration and synchronization would also remain separate concerns.

The underlying philosophy is simple: **the user's document, rather than a remote service, should be the primary unit of work.**

# Scittle and the function editor

An important enabling technology is [Scittle](https://github.com/babashka/scittle), created by Michiel Borkent (borkdude).

Scittle makes it possible to execute Clojure and ClojureScript code directly in the browser using SCI, without requiring the conventional compilation and bundling workflow for the code being interpreted.

This makes it a natural candidate for a lightweight, interactive programming environment. Users could evaluate expressions and experiment with functions without introducing a separate development toolchain.

A dedicated function editor would complement the spreadsheet grid. For example, a user could define a reusable budget calculation:

```clojure
(defn total-budget [project]
  (reduce + (:budget project)))
```

A cell could then invoke it:

```clojure
(total-budget C3)
```

The editor would provide a place to develop reusable abstractions, while cells would provide a place to apply them to data. Both would use the same language, without requiring macros or a separate scripting system.

Scittle provides the execution capability; the spreadsheet environment would define how expressions, cells, and their relationships work together.

# Beyond the spreadsheet

The deeper idea is to remove the artificial boundary between data and computation.

In a conventional spreadsheet, increasingly complex calculations often lead to macros, scripts, or external applications. In this model, structured data, transformations, and reusable functions are already part of the same environment.

The spreadsheet becomes a place to explore data, express computations, and build small applications. The grid provides the visual structure, while ClojureScript provides the computational model.

This does not automatically make every task easier. Dependency tracking, circular references, error handling, and the presentation of nested data structures still require careful design. Nor should the expressive power of a programming language come at the expense of the immediacy that makes spreadsheets useful.

These are challenges to explore, not reasons to abandon the idea.

The central proposition remains deliberately simple:

**What if a spreadsheet were not a special-purpose formula engine, but a small, autonomous programming environment in which every cell was a ClojureScript expression?**
