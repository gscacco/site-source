+++
date = "2026-06-20T13:23:00+02:00"
draft = false
title = "From Spreadsheet Tables to Programmable Data"
tags = ["clojure", "clojurescript", "spreadsheet", "scittle", "lisp"]
categories = ["programming", "clojure"]
socialsharing = true
+++

# From Spreadsheet Tables to Programmable Data

## Introduction

Spreadsheets are excellent at organizing information into rows and columns. They are less convincing when a simple question turns into a maze of cell references, nested formulas, and increasingly creative uses of `VLOOKUP`.

Consider a familiar table:

| Name | Category | Budget | Status |
|---|---|---:|---|
| Urban Gardens | Environment | 17,300 | active |
| Local Library | Education | 10,200 | completed |
| Cycle Paths | Mobility | 50,000 | active |
| Summer Festival | Culture | 15,300 | active |

A conventional spreadsheet encourages us to manipulate this information through cell references and built-in functions.

But there's another option: turn the table into structured ClojureScript data and work with the information directly.

## From rows to data

The first row contains the field names. Each subsequent row can become a map, and the entire table a vector of maps.

A small reusable function does the conversion:

```clojure
(defn rows->maps [data]
  (let [headers (mapv keyword (first data))]
    (mapv (fn [row]
            (zipmap headers row))
          (rest data))))
```

Given a spreadsheet range `A1:D5`, we can write:

```clojure
(def projects
  (rows->maps A1:D5))
```

The result is structured data:

```clojure
[{:name "Urban Gardens"
  :category "Environment"
  :budget 17300
  :status "active"}
 {:name "Local Library"
  :category "Education"
  :budget 10200
  :status "completed"}
 {:name "Cycle Paths"
  :category "Mobility"
  :budget 50000
  :status "active"}
 {:name "Summer Festival"
  :category "Culture"
  :budget 15300
  :status "active"}]
```

Now we can refer to `:budget` rather than column C, or `:status` rather than remembering which column we put it in. The data has names that describe what it means, rather than coordinates that describe where it happens to live.

## Ask the data

Which projects are active?

```clojure
(filter #(= "active" (:status %)) projects)
```

Which ones have a budget above 20,000?

```clojure
(filter #(> (:budget %) 20000) projects)
```

And what is the total budget for Environment projects?

```clojure
(->> projects
     (filter #(= "Environment" (:category %)))
     (map :budget)
     (reduce +))
```

The result is `17300`.

We can group projects by category:

```clojure
(group-by :category projects)
```

Or generate a summary containing the number of projects and their combined budgets:

```clojure
(->> projects
     (group-by :category)
     (map (fn [[category items]]
            {:category category
             :count (count items)
             :budget (reduce + (map :budget items))})))
```

Filtering, grouping, and aggregation are ordinary functions operating on ordinary data. No additional query language is needed, and no formula has to be copied down 200 rows while everyone hopes the references behave.

## From data to computation

In a programmable spreadsheet, a cell could hold the original table, another could filter its records, and a third could calculate a summary.

For example, if `C2` contains the vector of project maps, this expression calculates the total budget of active projects:

```clojure
(->> C2
     (filter #(= "active" (:status %)))
     (map :budget)
     (reduce +))
```

The cell isn't restricted to storing a value or invoking a spreadsheet-specific formula. It can evaluate an expression that transforms structured data, using the same language available everywhere else in the environment.

This is a small change in appearance, but a significant change in the computational model.

## The grid is still useful

None of this requires replacing the spreadsheet with a database or an analytics platform. The grid remains a convenient interface for entering and inspecting information; ClojureScript provides a general-purpose language for transforming it.

Tables are still useful. They simply stop dictating every operation we can perform on the information they contain.

The idea isn't to make spreadsheets more complicated by introducing programming for its own sake. It's to remove arbitrary boundaries between storing data, querying it, and defining reusable computations.

**The grid provides the data. The language provides the power. And ideally, neither requires a 47th worksheet named `Summary_Final_v3`.**
