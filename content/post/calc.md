+++
date = "2026-06-13T14:00:00+02:00"
draft = false
title = "Rethinking the Spreadsheet as a Programmable Environment"
tags = ["clojure", "clojurescript", "spreadsheet", "scittle", "lisp"]
categories = ["programming", "clojure"]
socialsharing = true
+++

# Introduction

Spreadsheets are among the most successful programming environments ever created. Millions of people use them every day to organize information, express relationships, perform calculations, and build small applications without necessarily thinking of themselves as programmers.

Yet the spreadsheet model has a fundamental limitation: it separates data from computation. Cells contain either values or formulas, and formulas belong to a special-purpose language designed specifically for the spreadsheet.

As calculations become more complex, users often resort to macros, scripts, external applications, or increasingly elaborate workarounds.

What if we removed this distinction?

What if every cell contained an expression in a general-purpose programming language? What if data structures, calculations, and function calls were all represented using the same underlying model? And what if the entire environment could be distributed as a single HTML file, without requiring an application server or an installation process?

These questions define the concept explored in this article: a spreadsheet that is also a small, self-contained programming environment.

The goal is not to reproduce an existing spreadsheet application. It is to reconsider the relationship between data, computation, and the interface through which people interact with them.

# A spreadsheet without a formula language

Consider a conventional spreadsheet. One cell contains the number `42`, while another contains a formula such as `=A1+B1`.

The distinction between the two is built into the application. One is a value; the other is an instruction that produces a value.

Now consider an alternative in which both cells contain expressions in ClojureScript.

A cell could contain a literal value:

```clojure
42
```

It could contain a data structure:

```clojure
{:name "Car"
 :budget 12500
 :status :active}
```

It could contain a function invocation:

```clojure
(+ 20 22)
```

Or it could evaluate an expression that refers to another cell:

```clojure
(+ A1 B1)
```

The precise syntax used for cell references would need to be defined as part of the language integration. The underlying principle, however, is straightforward:

**A cell contains a programming-language expression, not a special kind of spreadsheet formula.**

There is no separate formula language to learn. There is no fundamental distinction between a cell that contains data and one that computes data.

A literal number is an expression. A map is an expression. A function call is an expression.

The spreadsheet becomes a grid of expressions whose evaluated results can be inspected and manipulated.

# Cells are values, not just boxes

This approach becomes particularly interesting when cells contain structured data.

Suppose a cell contains a project description:

```clojure
{:name "Car"
 :budget 12500
 :status :active}
```

Another cell could extract the budget:

```clojure
(:budget C2)
```

A third could transform the project description:

```clojure
(assoc C2 :status :completed)
```

Another could construct a smaller representation:

```clojure
(select-keys C2 [:name :status])
```

These operations are not spreadsheet-specific features. They are ordinary operations on ClojureScript values.

A cell can hold a map, a vector, a sequence, a keyword, a string, or a number. The language's normal data manipulation facilities become available wherever an expression can be evaluated.

Consider a project whose budget consists of several components:

```clojure
{:name "Car"
 :budget [12300 34500 12000]
 :status :active}
```

A different cell could calculate the total:

```clojure
(reduce + (:budget C3))
```

No special spreadsheet function is required. The calculation uses ordinary collection and arithmetic functions.

This is the central conceptual shift: **the spreadsheet is no longer a place where data and formulas are stored in different ways. It is a place where expressions and their results can be explored together.**

It also means that the spreadsheet is not restricted to rectangular tables of primitive values. Tables remain useful, but the objects represented by their cells can be arbitrarily richer.

# Why ClojureScript?

ClojureScript offers several properties that make this concept particularly attractive.

First, it has a uniform expression-oriented model. Function calls, collection operations, and literal data fit naturally into the same syntax.

Second, it provides immutable data structures and a rich collection of functions for transforming them. Instead of modifying a collection through a sequence of imperative operations, one can describe a transformation that produces a new value.

Third, its data structures are well suited to interactive exploration. A map can represent a project, a vector can represent a list of budgets, and functions can operate on either without introducing a separate domain-specific language.

Finally, ClojureScript belongs to the Lisp family. Its syntax is explicit and structurally regular. This is useful not only for writing programs but also for building an editor that understands the structure of the code being edited.

The objective is not to make every spreadsheet user learn Lisp. It is to investigate what becomes possible when the spreadsheet is designed around a language that treats data and computation consistently.

# An autonomous web application

The concept also challenges the conventional way web applications are delivered.

Most web applications depend on a remote service. The browser provides the interface, while the application logic, data, or both reside on a server.

This architecture makes collaboration and centralized management easier, but it also introduces dependencies on infrastructure, network connectivity, service availability, and often an external provider.

For many small, personal, or specialized applications, such dependencies are not necessarily justified.

What if the application itself were a document?

The proposed environment would be a self-contained HTML application that could be opened directly in a browser. Its data, expressions, and user-defined functions would belong to the document, allowing the user to work without deploying a server or configuring a backend.

The browser would not merely be a thin client for a remote service. It would be the execution environment.

This approach offers several potential advantages:

- **Portability:** a document could be copied, archived, or shared as a file.
- **Ownership:** users could retain their data without depending on a hosted application service.
- **Simplicity:** the basic workflow would not require an account, a remote backend, or a permanent connection to a server.
- **Longevity:** the document would not inherently depend on the continued availability of a particular online service.
- **Low operational overhead:** there would be no application server or database service to deploy and maintain.

Autonomy does not mean that the application has no dependencies whatsoever. A standalone HTML file still depends on browser capabilities and may rely on JavaScript libraries. External resources would need to be bundled or otherwise made available locally if offline operation were a strict requirement.

Nor does a standalone document automatically solve collaboration, synchronization, access control, or backup. Those are separate problems that should not be introduced into the architecture unless the use cases justify them.

The design principle is to make the local document the primary unit of work, rather than treating it as a temporary interface to a remote service.

# Scittle: bringing Lisp to the browser

An important enabling technology for this concept is [Scittle](https://github.com/babashka/scittle), created by Michiel Borkent, also known as borkdude.

Scittle allows Clojure and ClojureScript code to be executed directly in the browser using SCI, without requiring the conventional ClojureScript compilation and bundling workflow for the code being interpreted.

This capability is particularly relevant to an interactive programming environment.

A user could write an expression, evaluate it, inspect the result, and continue experimenting within the same application. User-defined functions could be evaluated without introducing a separate compilation pipeline for each change.

Scittle would provide the language execution capability, while the spreadsheet environment would be responsible for the document model, cell evaluation, dependency management, and user interface.

This separation of concerns is important. An interpreter does not, by itself, provide spreadsheet semantics. The application would still need to define how cell references work, how dependencies are tracked, how results are displayed, and how errors are handled.

Scittle is therefore an enabling component, not the application architecture itself.

Its existence makes the proposed design more practical by allowing a Lisp-based programming environment to live inside a browser without requiring a conventional server-side runtime.

# The function editor

A programmable spreadsheet needs more than the ability to write short expressions inside cells.

As calculations become more complex, repeating the same code across multiple cells becomes cumbersome. Reusable functions are a natural solution.

Consider a function that calculates a project's total budget:

```clojure
(defn total-budget [project]
  (reduce + (:budget project)))
```

A cell could then invoke it:

```clojure
(total-budget C3)
```

The function editor and the spreadsheet would be complementary parts of the same environment. The editor would provide a place to develop reusable abstractions, while cells would provide a place to apply those abstractions to data.

There would be no need to introduce another language or a separate macro system. Function definitions, parameters, maps, vectors, and function calls would all use the same syntax.

The editor should nevertheless remain focused. The goal is not to reproduce a full integrated development environment inside a spreadsheet. It is to make writing and maintaining functions practical without forcing users to leave the environment in which their data lives.

This implies that editing support is more than a cosmetic concern.

Syntax highlighting, automatic indentation, bracket matching, and structural navigation would be especially valuable in a Lisp-based language. An editor that understands balanced expressions could offer assistance that a conventional plain-text editor cannot provide as naturally.

The deeper principle is that code should be treated as a first-class part of the document, not as an external extension attached to it.

# A reactive computational model

Allowing cells to contain arbitrary expressions raises an important architectural question: how should the application determine what to recalculate when a cell changes?

A conventional spreadsheet maintains dependencies between formulas. If cell D2 depends on C2, changing C2 should cause D2 to be recalculated.

A programmable spreadsheet needs the same basic property, even though its cells contain general expressions rather than a dedicated formula language.

Conceptually, the application must distinguish between two things:

1. The expression stored in a cell.
2. The value obtained by evaluating that expression.

For example, the expression

```clojure
(reduce + (:budget C3))
```

is part of the document, while its evaluated result is a number.

The source expression must remain available for editing and persistence. The evaluated value, on the other hand, is used for display and for subsequent computations.

Cell references establish dependencies. When an expression refers to another cell, the application needs to track that relationship and use it to determine which results may have become stale after an edit.

This is more complicated than it might initially appear. General-purpose expressions introduce questions about evaluation order, errors, circular references, and dependencies that may be difficult to determine through simple static inspection.

The architecture must also distinguish ordinary data transformations from operations with side effects. Unrestricted evaluation can undermine predictable recalculation, so the execution model and the allowed capabilities of user expressions deserve careful consideration.

These are not details that can simply be delegated to the interpreter. They are fundamental design decisions.

The objective is to combine the flexibility of a programming language with the immediate feedback that makes spreadsheets useful.

# Data, computation, and representation

The concept suggests a different relationship between the data model and its visual representation.

A conventional spreadsheet tends to present every cell as a rectangular region containing a scalar value or a short formula. Richer objects are often hidden behind specialized interfaces, external data models, or application-specific conventions.

A spreadsheet built around ClojureScript values could preserve the grid as its primary interface without restricting the underlying model to scalar data.

A map could represent a project. A vector could represent its budget components. A function could transform the project into a report-ready representation. Another cell could aggregate the results of several projects.

The grid would become a way to navigate and inspect a computational structure, rather than merely a table of numbers.

This raises an interesting user-interface problem: how should a cell display a value that is itself a nested data structure?

A map containing a few fields could be rendered compactly. Larger collections might require expandable views or dedicated inspection tools. Editing a nested value might benefit from structural navigation rather than requiring the user to manipulate a long textual representation.

These are opportunities for the interface to reflect the properties of the underlying language.

The goal is not to display every object as raw code at all times. It is to preserve the ability to inspect, edit, and transform the actual value without forcing it into an artificially narrow tabular representation.

# The limits of the idea

The flexibility of a general-purpose programming language does not automatically produce a better spreadsheet.

A conventional formula language is restrictive, but that restriction also makes its behavior relatively easy to understand. Users can often predict which cells will change after an edit and what a formula is intended to calculate.

Introducing general-purpose expressions creates new challenges:

- How should dependencies be discovered and recalculated?
- How should circular references and evaluation errors be represented?
- How should the environment handle expressions with side effects?
- How should nested data structures be displayed and edited?
- How should functions and their dependencies be stored with the document?
- How can the interface remain approachable to users unfamiliar with Lisp?
- How should the application preserve documents as its implementation evolves?

There is also a fundamental distinction between an autonomous document and a collaborative application. A local file is easy to copy and archive, but collaboration, synchronization, and concurrent editing require additional mechanisms.

The design should not attempt to solve every one of these problems at once. The most important first step is to establish a coherent model of cells, expressions, values, and dependencies.

The other decisions can then be evaluated against that model rather than accumulated as isolated features.

# Conclusion

The central proposition is simple: a spreadsheet could be designed as a small, self-contained programming environment in which every cell contains a ClojureScript expression.

Such an environment would combine the familiar spatial organization of a spreadsheet with the expressive power of a general-purpose language. Structured data and calculations would share the same computational model, reusable functions would be part of the document, and the browser would provide the execution environment without necessarily requiring a server.

Scittle offers a practical route to running the language directly in the browser, while a purpose-built function editor could make the programming experience accessible within the same interface.

None of these ideas requires the spreadsheet metaphor to disappear. The grid remains valuable because it gives users a compact, visual way to organize and inspect relationships.

The more interesting possibility is to change what the grid can contain.

Instead of treating the spreadsheet as a specialized calculation tool, we can treat it as an environment for exploring data, expressing computations, and building small applications.

The challenge is to retain the immediacy of a spreadsheet while removing the artificial boundary between the data it contains and the programs that operate on it.
