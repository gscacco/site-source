+++
date = "2026-06-13T14:00:00+02:00"
draft = false
title = "Rethinking the Spreadsheet as a Programmable Environment"
tags = ["clojure", "clojurescript", "spreadsheet", "scittle", "lisp"]
categories = ["programming", "clojure"]
socialsharing = true
+++

# What if every spreadsheet cell were a little lisp machine? 🧮

## Introduction

Spreadsheets are among the most successful programming environments ever created.

Millions of people use them to organize information, express relationships, perform calculations, and build small applications. Some even use them to run entire businesses. Others use them to calculate the family holiday budget. Both groups are one misplaced cell reference away from an interesting afternoon.

And yet, the basic spreadsheet model has remained remarkably stable: cells contain values or formulas, and formulas belong to a special-purpose language. A language that is powerful enough to run a small business, yet somehow still makes summing a column feel like an act of faith.

What if we removed this distinction?

What if every cell contained an expression in a general-purpose programming language? What if data, calculations, and functions all shared the same underlying model? And what if the entire application could be distributed as a single HTML file, without a server, an installer, or an IT department standing between you and your budget?

In other words, what if we stopped pretending that spreadsheets and programming languages were two entirely different things?

This is the starting point for a different kind of spreadsheet: a self-contained programming environment built around ClojureScript.

No, it won't automatically make your quarterly reports enjoyable. We should remain realistic.

## Cells as expressions 🧩

Consider a cell containing a project description:

```clojure
{:name "Community Garden"
 :budget 12500
 :status :active}
```

Nothing particularly frightening here. It's a Clojure map, a data structure that happens to describe a community garden rather than the internal politics of a software project.

Another cell could extract its budget:

```clojure
(:budget C2)
```

A third could transform the original value:

```clojure
(assoc C2 :status :completed)
```

These are ordinary ClojureScript expressions, not formulas in a separate language. No special spreadsheet syntax, no dedicated function wizard, and no need to remember whether this particular operation requires a comma, a semicolon, or a small ritual involving the F4 key.

A cell could contain a number, a string, a map, a vector, or a function call. The same language would represent data and manipulate it.

**A cell is not merely a box containing a value or a formula. It is a place where a programming-language expression can be evaluated and its result explored.**

Let's make the budget a little more interesting:

```clojure
{:name "Community Garden"
 :budget [1200 3500 800]
 :status :active}
```

Another cell calculates the total:

```clojure
(reduce + (:budget C3))
```

The result is `5500`.

No spreadsheet-specific function is needed. No need to consult a list of 400 functions, 70% of which you will never use, while wondering why the one you need has a name that sounds like an obscure tax regulation.

We simply use ordinary ClojureScript functions and data structures.

The grid remains familiar. The computational model becomes considerably more expressive.

And if someone asks whether the budget calculation can be extended to support nested structures, custom validation, or a reusable transformation, the answer is no longer "perhaps with a macro, a script, or an elaborate arrangement of cells."

It's just code.

Naturally, that introduces a different problem: someone now has to write the code. We haven't abolished work. We've merely made the machinery less arbitrary.

## Why ClojureScript?

ClojureScript provides a consistent way to represent both data and computation. Its immutable data structures and collection-oriented functions make it natural to transform structured values without inventing yet another formula language.

It also comes with a rather unusual advantage in a world dominated by punctuation-heavy programming languages: Lisp syntax is structurally explicit.

An expression such as

```clojure
(-> project
    (assoc :status :completed)
    (update :budget #(reduce + %)))
```

isn't just a string of characters with some parentheses sprinkled around for decorative purposes. It has a structure that an editor can understand.

That opens the door to structural navigation, intelligent bracket matching, expression-aware editing, and other features that go beyond the traditional experience of typing into a box and hoping the result turns green.

The objective isn't to force every spreadsheet user to become a programmer. That would be an excellent way to make sure nobody uses the application.

The objective is to explore whether a familiar visual interface can make a programming language useful for everyday data manipulation.

The grid provides the coordinates. ClojureScript provides the semantics. The user provides the occasional questionable assumption, as usual.

## An autonomous web application 🌐

The second principle concerns how the application is delivered.

Instead of depending on a remote service, the application would be a self-contained HTML document that runs directly in the browser.

Data, expressions, and user-defined functions would belong to the document itself. The browser wouldn't simply display an interface connected to a server somewhere in a data centre. It would be the execution environment.

This has some practical advantages:

- **Portability:** copy the file, move it, archive it, or send it to someone else.
- **Low operational overhead:** no backend to deploy, monitor, patch, and explain to management.
- **Independence:** no mandatory subscription service waiting to become more expensive next quarter.
- **Longevity:** a document can remain useful without depending on the continued existence of a particular SaaS provider.

The basic idea is refreshingly boring: open a file, work on it, save it. Computers used to be rather good at this.

There are, naturally, some caveats. A single HTML file isn't automatically a magical box containing the entire internet. Libraries must be bundled or available locally for genuine offline operation. Browser storage and file-handling restrictions need consideration. Collaboration and synchronization require additional mechanisms.

And if the application eventually becomes popular enough to need a distributed collaboration service, we can build one. We just don't need to start by building a small cloud provider to calculate the household electricity bill.

**The user's document, rather than a remote service, should be the primary unit of work.**

## Scittle and the function editor

An important enabling technology is [Scittle](https://github.com/babashka/scittle), created by Michiel Borkent, also known as borkdude.

Scittle makes it possible to execute Clojure and ClojureScript code directly in the browser using SCI, without requiring the conventional compilation and bundling workflow for the code being interpreted.

For this kind of environment, that's a useful property. Users can evaluate expressions and experiment with functions without installing a development toolchain or explaining to their operating system why yet another package manager needs permission to modify everything.

A dedicated function editor would complement the spreadsheet grid.

For example, a user could define a reusable budget calculation:

```clojure
(defn total-budget [project]
  (reduce + (:budget project)))
```

A cell could then invoke it:

```clojure
(total-budget C3)
```

That's the important distinction: the function isn't trapped inside one cell, duplicated across 30 rows, or copied into another worksheet with the subtle confidence that everything will probably keep working.

It's a reusable abstraction defined in the same language as the data it operates on.

The function editor would provide a place to develop those abstractions, while cells would provide a place to apply them. Both would share the same computational model, without requiring macros or a separate scripting system.

Scittle provides the execution capability. The spreadsheet environment would still need to define how cells, expressions, dependencies, and results interact. An interpreter is not a spreadsheet engine, just as an engine block is not an entire car. Although both are capable of producing expensive surprises.

## Beyond the spreadsheet 🚀

The deeper idea is to remove the artificial boundary between data and computation.

In a conventional spreadsheet, increasingly complex calculations often lead to macros, scripts, external applications, or a workbook containing 47 tabs and a mysterious sheet named `Final_v7_REAL_FINAL`.

In this model, structured data, transformations, and reusable functions already belong to the same environment.

The spreadsheet becomes a place to explore data, express computations, and build small applications. The grid provides the visual structure; ClojureScript provides the computational model.

This doesn't mean every task becomes easier.

Dependency tracking still needs careful design. Circular references don't become charming just because they're written in Lisp. Errors must be understandable. Nested data structures need a sensible visual representation. And the system must preserve the immediacy that makes spreadsheets useful in the first place.

If calculating a total requires understanding evaluation semantics, dependency graphs, immutable collections, and three chapters of a programming manual, we've missed the point rather spectacularly.

The programming language should expand what users can do, not turn every small task into an academic exercise.

These are engineering challenges, not reasons to abandon the idea. They also suggest that the user interface matters just as much as the language underneath it.

## The actual question

The ambition isn't to build Excel again, only with parentheses.

It's to explore a different model of interactive computing: a familiar grid backed by a real programming language, packaged as an autonomous document that can be opened and used without a supporting infrastructure.

A place where data is data, functions are functions, and the distinction between a value and an expression isn't enforced by a product designed decades ago.

Perhaps the most interesting part is that none of the individual ingredients is particularly exotic. Lisp has been around for decades. ClojureScript provides a practical language for browser applications. Scittle makes interactive execution possible. HTML documents are about as portable as software gets.

The interesting part is putting them together into something coherent and useful.

So here's the proposition:

**What if a spreadsheet weren't a special-purpose formula engine, but a small, autonomous programming environment in which every cell was a ClojureScript expression?**

At worst, we get a spreadsheet that confuses a few people and delights a few Lisp enthusiasts.

At best, we get something more interesting: a programming environment hiding in plain sight, inside the most familiar grid on the planet.

And perhaps, finally, a spreadsheet that doesn't need a macro to explain why it exists without introducing a separate formula language.

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
