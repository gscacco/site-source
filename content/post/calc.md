+++
date = "2026-06-13T14:00:00+02:00"
draft = false
title = "Rethinking the Spreadsheet as a Programmable Environment"
tags = ["clojure", "clojurescript", "spreadsheet", "scittle", "lisp"]
categories = ["programming", "clojure"]
socialsharing = true
+++

# What If Every Spreadsheet cell were a little Lisp Machine? 🧮

## Introduction

Spreadsheets are among the most successful programming environments ever created. Millions of people use them to organize information, perform calculations, and build small applications. Some even run entire businesses with them. Others use them to calculate the family holiday budget. Both groups are one misplaced cell reference away from an interesting afternoon.

Yet the basic model has barely changed: cells contain values or formulas, and formulas belong to a special-purpose language. A language powerful enough to run a business, but somehow still capable of making a simple calculation feel like an act of faith.

What if every cell could contain an expression in a general-purpose programming language? What if data, calculations, and functions shared the same model? And what if the entire application ran from a single HTML file, without a server or an installation process?

The result would be something familiar in appearance but fundamentally different underneath: a self-contained programming environment built around ClojureScript.

## Cells as expressions

Consider a cell containing a project description:

```clojure
{:name "Community Garden"
 :budget [1200 3500 800]
 :status :active}
```

Another cell could extract its budget:

```clojure
(:budget C2)
```

Or calculate the total:

```clojure
(reduce + (:budget C2))
```

A third could update the project's status:

```clojure
(assoc C2 :status :completed)
```

These are ordinary ClojureScript expressions, not formulas in a separate language. A cell can contain a number, a string, a map, a vector, or a function call. The same language represents data and manipulates it.

No spreadsheet-specific functions are required. No separate formula syntax needs to be learned. And no collection of macros is needed just because a calculation has grown beyond what fits comfortably in a cell.

**A cell becomes a place where a programming-language expression is evaluated and its result explored.**

This doesn't eliminate complexity. It gives complexity a consistent model instead of spreading it across formulas, scripts, and increasingly mysterious worksheets.

## Why ClojureScript?

ClojureScript offers immutable data structures, collection-oriented functions, and a consistent way to express both data and computation.

Its Lisp syntax also creates an opportunity for a more intelligent editor. Expressions have an explicit structure that software can understand, enabling structural navigation, bracket matching, and expression-aware editing rather than treating code as an undifferentiated string.

A reusable budget calculation, for example, could be defined once:

```clojure
(defn total-budget [project]
  (reduce + (:budget project)))
```

Any cell could then invoke it:

```clojure
(total-budget C2)
```

The function editor would provide a place to develop reusable abstractions, while the grid would provide a place to apply them to data. Both would use the same language.

The objective isn't to force every spreadsheet user to become a programmer. That would be an efficient way to lose most of the users. It's to make programming capabilities available through an interface people already understand.

## A self-contained programming environment 🌐

The application would be a standalone HTML document running directly in the browser. The browser wouldn't merely display an interface connected to a remote service; it would be the execution environment.

This offers portability, low operational overhead, and independence from a hosted application. Documents could be copied, archived, and reopened without deploying infrastructure or maintaining a backend.

An important enabling technology is [Scittle](https://github.com/babashka/scittle), created by Michiel Borkent (borkdude). Scittle uses SCI to execute Clojure and ClojureScript code in the browser without requiring the conventional compilation and bundling workflow for the code being interpreted.

It could provide the execution layer for interactive expressions and user-defined functions, without introducing a separate development toolchain.

There is an important architectural distinction, however: **Scittle provides code execution, not the spreadsheet engine itself.** The application would still need to implement cell dependencies, recalculation, error handling, persistence, and the relationship between expressions and their displayed results.

Nor does a single HTML file automatically guarantee offline operation. Required libraries must be bundled or available locally, and collaboration or synchronization would require additional mechanisms.

The goal is simpler: the user's document, rather than a remote service, should be the primary unit of work.

## Beyond the spreadsheet

The ambition isn't to rebuild Excel with parentheses.

It's to explore a different model of interactive computing: a familiar grid backed by a real programming language, distributed as an autonomous document.

There are real challenges. Dependency tracking must be reliable, circular references need defined behaviour, and nested data structures require a sensible visual representation. Most importantly, the expressive power of a programming language must not destroy the immediacy that makes spreadsheets useful.

If calculating a total requires understanding evaluation semantics and reading three chapters of documentation, something has gone wrong.

The interesting part is that the ingredients already exist: Lisp, ClojureScript, browser-based execution, and portable HTML documents. The challenge is combining them into an environment that is coherent, practical, and pleasant to use.

**What if a spreadsheet weren't a special-purpose formula engine, but a small, autonomous programming environment in which every cell was a ClojureScript expression?**

Perhaps the result would be a spreadsheet that does more than calculate numbers. It could become a lightweight environment for exploring data, defining abstractions, and building small applications, without requiring an entire software infrastructure to support it.

And if nothing else, we'd have one fewer reason to name a worksheet `Final_v7_REAL_FINAL`.
