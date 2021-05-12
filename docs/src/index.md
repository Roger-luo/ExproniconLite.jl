```@setup jlfn
using ANSIColoredPrinters
function show_ascii(x)
    buf = IOBuffer()
    print(buf, x)
    HTMLPrinter(buf, root_class="terminal-output")
end
```

# ExproniconLite

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://Roger-luo.github.io/ExproniconLite.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://Roger-luo.github.io/ExproniconLite.jl/dev)
[![Build Status](https://github.com/Roger-luo/ExproniconLite.jl/workflows/CI/badge.svg)](https://github.com/Roger-luo/ExproniconLite.jl/actions)
[![Coverage](https://codecov.io/gh/Roger-luo/ExproniconLite.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/Roger-luo/ExproniconLite.jl)
[![Downstream](https://github.com/Roger-luo/ExproniconLite.jl/actions/workflows/Downstream.yml/badge.svg)](https://github.com/Roger-luo/ExproniconLite.jl/actions/workflows/Downstream.yml)


Collective tools for metaprogramming on Julia Expr, the meta programming
standard library for [MLStyle](https://thautwarm.github.io/MLStyle.jl/latest/).

Meta programming in general can be decomposed into three steps:

1. analyse the given expression
2. transform the given expression to:
    - another target expression
    - a convenient intermediate representation (IR) that is easy to further manipulate/analyse
3. generate the target code, the target code can be:
    - most commonly the Julia `Expr`
    - another language's abstract/concrete syntax tree
    - a lower-level IR

The package `ExproniconLite` is thus written to assist you writing meta programs in the above manner.


## Builtin Syntax Types

One of the most important tool in `ExproniconLite` is the **syntax types**, these are types
describing a specific Julia syntax, e.g `JLFunction` describes Julia's function definition
syntax. The syntax type uses a canonical data structure to represent various syntax that has the
same semantic, which is convenient when one wants to manipulate, generate such objects.

They will allow you to:

1. easily analysis a given Julia `Expr` by converting it to the syntax type
2. easily manipulate a given Julia `Expr` with data structure designed for easier manipulation
3. easily generate a Julia `Expr` using [`codegen_ast`](@ref).

Let's take `JLFunction` as our example again, in Julia, function can be declared in many different ways:

You can define a function using the short form

```julia
f(x) = x
```

or you can declare the same function using the `function` keyword

```julia
function f(x)
    return x
end
```

If we look at their expression object, we will find they actually have quite different
expression structure:

```@example jlfn
using ExproniconLite # hide
ex1 = @expr f(x) = x
```

```@example jlfn
ex2 = @expr function f(x)
    return x
end
```

here we use a convenient tool to obtain the Julia expression object
provided by `ExproniconLite`, the [`@expr`](@ref) macro.

Now if we convert them to the `JLFunction` type

```@example jlfn
jl1 = JLFunction(ex1)
show_ascii(jl1)# hide
```

```@example jlfn
jl2 = JLFunction(ex2)
show_ascii(jl2)# hide
```

we can see they have the same structure under the representation of [`JLFunction`](@ref).

```@example jlfn
dump(jl1)
```

```@example jlfn
dump(jl2)
```

we can easily access to some important information of this function by accessing the fields

```@repl jlfn
jl1.name
jl1.args
jl1.body
```

This is the same for other syntax types, e.g we can get the corresponding syntax type instance
of a struct definition

```@example jlfn
def = @expr JLStruct struct Foo{T} <: AbstractType
    x::Int
    y::T
end
show_ascii(def) # hide
```

we again use [`@expr`](@ref) for convenience, however you can also just convert the expression to
`JLStruct` manually

```@example jlfn
ex = quote
    struct Foo{T} <: AbstractType
        x::Int
        y::T
    end
end
def = JLStruct(ex.args[2])
show_ascii(def) # hide
```

once you have the corresponding `JLStruct` object, you can access many useful information directly

```@repl jlfn
def.name
def.typevars
def.supertype
typeof(def.fields[1])
def.fields[1].name
def.fields[1].type
```

Some syntax types are defined for easy manipulation such as [`JLIfElse`](@ref), Julia's representation
of `if ... elseif ... else ... end` statement is a recursive tree in `Expr`, which sometimes is not very
convenient to manipulate or analysis, for example, it is not easy to access all the conditions in a long
`ifelse` statement

```@example jlfn
ex = @expr if x > 100
    x + 1
elseif x > 90
    x + 2
elseif x > 80
    x + 3
else
    error("some error msg")
end
```

we can find each condition

```@repl jlfn
ex.args[1]
ex.args[3].args[1]
ex.args[3].args[3].args[1]
ex.args[3].args[3].args[3]
```

imagine how would you construct such expression from scratch, or how would you
access all the conditions. Thus [`JLIfElse`](@ref) allows you to access/manipulate
`ifelse` statements directly as a dict-like object

```@repl jlfn
jl = JLIfElse(ex);
jl
jl.otherwise
```

you can access to each condition and its action using the condition as your key

```@repl jlfn
jl[:(x > 100)]
```

similarly, we can easily construct a `JLIfElse`

```@example jlfn
jl = JLIfElse()
jl[:(x > 100)] = :(x + 1)
jl[:(x > 80)] = :(x + 2)
jl.otherwise = :(error("some error msg"))
jl
show_ascii(jl) # hide
```

now let's generate back to `Expr` so that we can give Julia back some executable expression

```@repl jlfn
codegen_ast(jl)
```

You can find available syntax types in [Syntax Types](@ref)

## Pattern Matching

Since `ExproniconLite` serves as the meta programming stdlib for MLStyle, you can
also use the syntax types along with MLStyle, e.g


```@example match
using MLStyle
using ExproniconLite

f = @λ begin
   JLFunction(;name=:foo, args) => (args, )
   JLFunction(;name=:boo, args) => (args, )
   _ => nothing
end

ex_foo = @expr function foo(x::Int, y::T) where {T <: Real}
    x + y
end

ex_boo = @expr function foo(x::Int)
    x
end
nothing # hide
```

then we can check if our match function gives the right result

```@repl match
f(ex_foo)
f(ex_boo)
```

You can use **any** syntax types builtin as your expression
template to match using MLStyle. If you define your own
syntax type, you can also support pattern matching via
[`@syntax_pattern`](@ref).

```@docs
@syntax_pattern
```


## Analysis Functions

`ExproniconLite` provides a lot common analysis functions, you can find the list
of them in [Analysis](@ref). you can use them
to check if the expression satisfy certain property, e.g you can check
if a given object is a struct definition via [`is_struct`](@ref), or check
if a given function definition supports keyword arguments via [`is_kw_function`](@ref).

## Transform Functions

You can find the list of them in [Transform](@ref).

Transform functions usually takes an expression and returns an expression e.g
sometimes you only want the name symbol of your function arguments

```@example jlfn
def = @expr JLFunction function foo(x::Int, y::Real=2)
end
nothing # hide
```

```@repl jlfn
def.args
name_only.(def.args)
```

## Code Generation Functions

The code generation functions help you generate other target expressions, e.g [`codegen_ast`](@ref)
generates the Julia AST object `Expr`. All the syntax type can use [`codegen_ast`](@ref) to generate
the corresponding `Expr`, there are also some other functions start with name `codegen` in
[CodeGen](@ref) you may find useful.

## Pretty Printing

Sometimes, when you define your own intermediate representation, you may want to pretty print
your expression with colors and indents. `ExproniconLite` also provide some tools for this in
[Printings](@ref).

## Common Gotchas

Use `&` operator inside the pattern if you are referring a specific value, e.g

```julia
stmt = Expr(:call, GlobalRef(Base, :sin), QuoteNode(1))
@match stmt begin
    Expr(:call, GlobalRef(Core, name), args...) => true
    _ => false
end # true
```

without `&`, `@match` may treat `Core` as a variable, thus the first pattern
matches and return `true`, which is incorrect, if we add `&`, we have the expected
behaviour

```julia
@match stmt begin
    Expr(:call, GlobalRef(&Core, name), args...) => true
    _ => false
end # false
```
