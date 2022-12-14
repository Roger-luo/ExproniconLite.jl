# API Reference

## Syntax Types

Convenient types for storing analysis results of a given Julia `Expr`, or for creating
certain Julia objects easily. These types define some common syntax one would manipulate
in Julia meta programming.

```@docs
JLFunction
JLStruct
JLKwStruct
JLIfElse
JLMatch
JLFor
JLField
JLKwField
NoDefault
no_default
JLExpr
```

## Analysis

Functions for analysing a given Julia `Expr`, e.g splitting Julia function/struct definitions etc.

```@autodocs
Modules = [ExproniconLite]
Pages = ["analysis/analysis.jl"]
```

## Transform

Some common transformations for Julia `Expr`, these functions takes an `Expr` and returns an `Expr`.

```@autodocs
Modules = [ExproniconLite]
Pages = ["transform.jl"]
```

## CodeGen

Code generators, functions that generates Julia `Expr` from given arguments, `ExproniconLite` types. 

```@autodocs
Modules = [ExproniconLite]
Pages = ["codegen.jl"]
```

## Printings

Pretty printing functions.

```@autodocs
Modules = [ExproniconLite]
Pages = ["printing.jl"]
```

## Algebra Data Type

Algebra data type

```@autodocs
Modules = [ExproniconLite.ADT]
Pages = ["adt/adt.jl"]
```
