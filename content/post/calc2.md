+++
date = "2026-06-20T13:23:00+02:00"
draft = false
title = "From Spreadsheet Tables to Programmable Data"
tags = ["clojure", "clojurescript", "spreadsheet", "scittle", "lisp"]
categories = ["programming", "clojure"]
socialsharing = true
+++
# From Spreadsheet Tables to Programmable Data

Spreadsheets are excellent at organizing information into rows and columns. But once data is represented as a collection of structured objects, something interesting happens: we can stop thinking in terms of cells and start thinking in terms of data and computations.

Consider a familiar spreadsheet:

| Name | Category | Budget | Status |
|---|---|---:|---|
| Urban Gardens | Environment | 17,300 | active |
| Local Library | Education | 10,200 | completed |
| Cycle Paths | Mobility | 50,000 | active |
| Summer Festival | Culture | 15,300 | active |

A conventional spreadsheet encourages us to manipulate this information through cell references, formulas and built-in functions.

But what if we could turn the table into a ClojureScript data structure?

## One table, one transformation

The first row provides the field names. Each subsequent row becomes a map, and the entire table becomes a vector of maps.

We can define a reusable function to perform this transformation:

```clojure
(defn rows->maps [data]
  (let [headers (mapv keyword (first data))]
    (mapv (fn [row]
            (zipmap headers row))
          (rest data))))
```

The function takes a sequence of rows, converts the first row into keyword keys, and combines each remaining row with those keys using `zipmap`.

Suppose the spreadsheet range `A1:D5` contains the table above. We can transform it into structured data:

```clojure
(def projects
  (rows->maps A1:D5))
```

The result is:

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

Instead of referring to column C or row 7, we can now refer to `:budget` or `:status`.

## Ask questions directly

Which projects are active?

```clojure
(filter #(= "active" (:status %)) projects)
```

Which projects have a budget greater than 20,000?

```clojure
(filter #(> (:budget %) 20000) projects)
```

What is the total budget for Environment projects?

```clojure
(->> projects
     (filter #(= "Environment" (:category %)))
     (map :budget)
     (reduce +))
```

The result is `17300`.

We can also group projects by category:

```clojure
(group-by :category projects)
```

Or produce a compact summary:

```clojure
(->> projects
     (group-by :category)
     (map (fn [[category items]]
            {:category category
             :count (count items)
             :budget (reduce + (map :budget items))})))
```

No special query language is needed. Filtering, grouping, sorting and aggregation are simply functions operating on data.

## Cells become programmable

A cell could contain a value, a structured object or an expression that operates on other cells. One cell might hold the original table; another might filter its records; a third might calculate a summary.

For example:

```clojure
(->> C2
     (filter #(= "active" (:status %)))
     (map :budget)
     (reduce +))
```

Here, `C2` represents a cell containing the vector of maps. The expression calculates the total budget of active projects.

The important shift is conceptual: **the spreadsheet becomes a place where data is not only stored, but also programmed.**

## A small change with broader implications

This does not require replacing the spreadsheet with a database or building a large analytics platform. A familiar grid can remain the interface for entering and inspecting information, while ClojureScript provides a compact and composable language for working with it.

Tables remain useful. But they no longer have to dictate how we think about the data.

Instead of learning another collection of spreadsheet-specific functions, users gain access to a general-purpose programming language, structured data and reusable transformations.

The grid provides the data. The language provides the power.
