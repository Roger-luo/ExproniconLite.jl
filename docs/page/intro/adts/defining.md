# Defining algebra data types

`ExproniconLite` provides a macro `@adt` to define the algebra data types (ADT).
The syntax and semantic is very similar to rust's `enum` type. 

## A glance of the syntax

The simplest syntax of `@adt` is:

```julia
@adt <name> begin
    <variant1>
    <variant2>
    ...
end
```

where `<name>` should be a valid identifier, and can optionally
take a supertype as `<name> <: <supertype>`. `<variant>` is one of the following:

```julia
<name> # variant with no field
<name>(<field1>, <field2>, ...) # variant with annoymous fields
struct <name>
    <field1>
    <field2>
    ...
end # variant with named fields
```

## Singleton variants

The singleton variants are similar to an enum. It only requires a name
and no fields. For example:

```julia
@adt Food begin
    Apple
    Orange
    Banana
end
```

## Variants with annoymous fields

It is sometimes useful to define a variant with annoymous fields.
So you can save a few minites for figuring out a good name for the fields.
To declare a variant with annoymous fields, you can use the following syntax:

```julia
@adt Message begin
    Info(::String)
    Warning(::String)
    Error(::String)
end
```

and you can construct the corresponding variant with the following syntax:

```julia
Info("hello")
Warning("hello")
Error("hello")
```

## Variants with named fields

It is also possible to define a variant with named fields. This syntax
is the same as a keyword structure definition in Julia
(the syntax of `Base.@kwdef` or `Configurations.@option`). For example:

```julia
@adt Animal begin
    struct Cat
        name::String = "Tom"
        age::Int = 3
    end
    struct Dog
        name::String = "Jack"
        age::Int = 5
    end
end
```

and you can construct the corresponding variant with the following syntax:

```julia
Cat(; name="Tom", age=3)
Dog(; name="Jack", age=5)
```

Or you can also just construct normally:

```julia
Cat("Tom", 3)
Dog("Jack", 5)
```
