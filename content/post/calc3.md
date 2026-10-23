+++
date = "2026-06-22T15:14:00+02:00"
draft = false
title = "EDN and the Challenge of Making Complex Data Readable"
tags = ["clojure", "clojurescript", "spreadsheet", "scittle", "lisp"]
categories = ["programming", "clojure"]
socialsharing = true
+++

# EDN and the Challenge of Making Complex Data Readable

## Introduction

EDN (Extensible Data Notation) is a data representation format used in the Clojure ecosystem. It is compact, flexible, and remarkably good at representing complex structures using maps, vectors, lists, sets, and atomic values.

Unfortunately, being easy for a program to process doesn't automatically make something easy for a human to read. Computers are perfectly happy with deeply nested structures. Humans tend to lose track of the closing parentheses somewhere around the third level.

Consider this example:

```clojure
{:name "Garden"
 :budget [1200 3400 1200]
 :status :active
 :team {:lead "Alice"
        :members ["Bob" "Carol"]}}
```

For a small structure, the textual representation works well. As the data grows, however, understanding it requires mentally reconstructing the relationships between properties, values, and nested collections. At some point, reading the data starts to feel less like inspecting information and more like navigating a very small jungle.

The problem isn't EDN itself. It's expecting one representation to serve every purpose.

## One structure, multiple views

A natural solution is an interactive tree.

Maps become expandable nodes, vectors become ordered collections, and atomic values are displayed directly. Instead of confronting the entire structure at once, we can explore only the branches that matter.

But trees aren't universally useful. Suppose we want to compare the budgets and statuses of dozens of projects. A table is probably a better choice. If we want to transform the data with Clojure functions, the textual representation may be more convenient.

Each representation answers a different question:

- **Tree:** How is this structure organized?
- **Table:** How do these records compare?
- **Text:** What exactly is the underlying data?

Trying to force all three tasks into one interface would be rather like insisting that every document must be read as a filesystem tree. Technically possible, perhaps, but not a particularly persuasive user experience.

## One model, no competing copies

The important design decision is to keep EDN as the canonical data model while allowing different interfaces to present and modify it.

An interactive tree could make nested structures easier to explore. A tabular view could expose selected records and fields for comparison. A text editor could provide direct access to the original representation.

These shouldn't be separate copies of the data. Editing a value in one view should update the same underlying structure, with the other views reflecting the change.

That sounds obvious, but maintaining consistency becomes more challenging when views support different operations. A table may expose only selected fields, while a tree reveals the full hierarchy. The interface must preserve information that isn't currently visible and handle edits without accidentally destroying unrelated data.

In other words, the presentation can change, but the data must remain trustworthy.

## Beyond a data viewer

The idea becomes more interesting when EDN lives in a programmable environment.

Imagine a cell containing a map, another extracting its budget, and a third calculating an aggregate. The same structure can be inspected visually, edited as text, and manipulated through ClojureScript expressions.

The interface is no longer just a viewer. It becomes a way to move between understanding data and working with it.

This is where the distinction between data and presentation matters most. The underlying model remains consistent, while the interface adapts to the task. ClojureScript supplies the means to transform the data; the user interface determines how comfortably people can explore and understand it.

The goal isn't to make EDN less expressive or hide its structure behind layers of abstraction. It's to make that structure accessible without forcing users to read every nested map as if they were debugging a production incident.

**EDN should define the data, not dictate how humans must look at it.**
