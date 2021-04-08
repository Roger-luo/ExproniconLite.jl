"""
    @expr <expression>

Return the original expression object.

# Example

```julia
julia> ex = @expr x + 1
:(x + 1)
```
"""
macro expr(ex)
    return QuoteNode(ex)
end

"""
    @test_expr <type> <ex>

Test if the syntax type generates the same expression `ex`. Returns the
corresponding syntax type instance. Requires `using Test` before using
this macro.

# Example

```julia
def = @test_expr JLFunction function (x, y)
    return 2
end
@test is_kw_fn(def) == false
```
"""
macro test_expr(type, ex)
    @gensym def generated_expr original_expr
    quote
        $def = Expronicon.@expr $type $ex
        println($def)
        $generated_expr = $prettify($codegen_ast($def))
        $original_expr = $prettify($(Expr(:quote, ex)))
        @test $compare_expr($generated_expr, $original_expr)
        $def
    end |> esc
end

"""
    @test_expr <expr> == <expr>

Test if two expression is equivalent semantically, this uses `compare_expr`
to decide if they are equivalent, ignores things such as `LineNumberNode`
generated `Symbol` in `Expr(:curly, ...)` or `Expr(:where, ...)`.
"""
macro test_expr(ex::Expr)
    ex.head === :call && ex.args[1] === :(==) || error("expect <expr> == <expr>, got $ex")
    lhs, rhs = ex.args[2], ex.args[3]
    quote
        $__source__
        @test $compare_expr($prettify($lhs), $prettify($rhs))
    end |> esc
end

"""
    @expr <type> <expression>

Return the expression in given type.

# Example

```julia
julia> ex = @expr JLKwStruct struct Foo{N, T}
           x::T = 1
       end
#= kw =# struct Foo{N, T}
    #= /home/roger/code/julia/Expronicon/test/analysis.jl:5 =#
    x::T = 1
end
```
"""
macro expr(type, ex)
    quote
        $type($(Expr(:quote, ex)))
    end |> esc
end

struct AnalysisError <: Exception
    expect::String
    got
end

anlys_error(expect, got) = throw(AnalysisError(expect, got))

function Base.show(io::IO, e::AnalysisError)
    print(io, "expect ", e.expect, " expression, got ", e.got, ".")
end

"""
    compare_expr(lhs, rhs)

Compare two expression of type `Expr` or `Symbol` semantically, which:

1. ignore the detail value `LineNumberNode` in comparision
2. ignore the detailed name of typevars in `Expr(:curly, ...)` or `Expr(:where, ...)`

This gives a way to compare two Julia expression semantically which means
although some details of the expression is different but they should
produce the same lowered code.
"""
function compare_expr(lhs, rhs)
    @sswitch (lhs, rhs) begin
        @case (::Symbol, ::Symbol)
            lhs === rhs
        @case (Expr(:curly, name, lhs_vars...), Expr(:curly, &name, rhs_vars...))
            all(map(compare_vars, lhs_vars, rhs_vars))
        @case (Expr(:where, lbody, lparams...), Expr(:where, rbody, rparams...))
            compare_expr(lbody, rbody) &&
                all(map(compare_vars, lparams, rparams))
        @case (Expr(head, largs...), Expr(&head, rargs...))
                isempty(largs) && isempty(rargs) ||
            (length(largs) == length(rargs) && all(map(compare_expr, largs, rargs)))
        # ignore LineNumberNode
        @case (::LineNumberNode, ::LineNumberNode)
            true
        @case _
            lhs == rhs
    end
end

"""
    compare_vars(lhs, rhs)

Compare two expression by assuming all `Symbol`s are variables,
thus their value doesn't matter, only where they are matters under
this assumption. See also [`compare_expr`](@ref).
"""
function compare_vars(lhs, rhs)
    @sswitch (lhs, rhs) begin
        @case (::Symbol, ::Symbol)
            true
        @case (Expr(head, largs...), Expr(&head, rargs...))
            all(map(compare_vars, largs, rargs))
        # ignore LineNumberNode
        @case (::LineNumberNode, ::LineNumberNode)
            true
        @case _
            lhs == rhs
    end
end

"""
    is_literal(x)

Check if `x` is a literal value.
"""
function is_literal(x)
    !(x isa Expr || x isa Symbol || x isa GlobalRef)
end

"""
    support_default(f)

Check if field type `f` supports default value.
"""
support_default(f) = false
support_default(f::JLKwField) = true

function has_symbol(@nospecialize(ex), name::Symbol)
    ex isa Symbol && return ex === name
    ex isa Expr || return false
    return any(x->has_symbol(x, name), ex.args)
end

"""
    has_kwfn_constructor(def[, name = struct_name_plain(def)])

Check if the struct definition contains keyword function constructor of `name`.
The constructor name to check by default is the plain constructor which does
not infer any type variables and requires user to input all type variables.
See also [`struct_name_plain`](@ref).
"""
function has_kwfn_constructor(def, name = struct_name_plain(def))
    any(def.constructors) do fn::JLFunction
        isempty(fn.args) && fn.name == name
    end
end

"""
    has_plain_constructor(def, name = struct_name_plain(def))

Check if the struct definition contains the plain constructor of `name`.
By default the name is the inferable name [`struct_name_plain`](@ref).

# Example

```julia
def = @expr JLKwStruct struct Foo{T, N}
    x::Int
    y::N

    Foo{T, N}(x, y) where {T, N} = new{T, N}(x, y)
end

has_plain_constructor(def) # true

def = @expr JLKwStruct struct Foo{T, N}
    x::T
    y::N

    Foo(x, y) = new{typeof(x), typeof(y)}(x, y)
end

has_plain_constructor(def) # false
```

the arguments must have no type annotations.

```julia
def = @expr JLKwStruct struct Foo{T, N}
    x::T
    y::N

    Foo{T, N}(x::T, y::N) where {T, N} = new{T, N}(x, y)
end

has_plain_constructor(def) # false
```
"""
function has_plain_constructor(def, name = struct_name_plain(def))
    any(def.constructors) do fn::JLFunction
        fn.name == name || return false
        fn.kwargs === nothing || return false
        length(def.fields) == length(fn.args) || return false
        for (f, x) in zip(def.fields, fn.args)
            f.name === x || return false
        end
        return true
    end
end

"""
    is_function(def)

Check if given object is a function expression.
"""
function is_function(@nospecialize(def))
    @smatch def begin
        ::JLFunction => true
        Expr(:function, _, _) => true
        Expr(:(=), _, _) => true
        Expr(:(->), _, _) => true
        _ => false
    end
end

"""
    is_kw_function(def)

Check if a given function definition supports keyword arguments.
"""
function is_kw_function(@nospecialize(def))
    is_function(def) || return false

    if def isa JLFunction
        return def.kwargs !== nothing
    end

    _, call, _ = split_function(def)
    @smatch call begin
        Expr(:tuple, Expr(:parameters, _...), _...) => true
        Expr(:call, _, Expr(:parameters, _...), _...) => true
        Expr(:block, _, ::LineNumberNode, _) => true
        _ => false
    end
end

@deprecate is_kw_fn(def) is_kw_function(def)
@deprecate is_fn(def) is_function(def)

"""
    is_struct(ex)

Check if `ex` is a struct expression.
"""
function is_struct(@nospecialize(ex))
    ex isa Expr || return false
    return ex.head === :struct
end

"""
    is_struct_not_kw_struct(ex)

Check if `ex` is a struct expression excluding keyword struct syntax.
"""
function is_struct_not_kw_struct(ex)
    is_struct(ex) || return false
    body = ex.args[3]
    body isa Expr && body.head === :block || return false
    any(is_field_default, body.args) && return false
    return true
end

"""
    is_ifelse(ex)

Check if `ex` is an `if ... elseif ... else ... end` expression.
"""
function is_ifelse(@nospecialize(ex))
    ex isa Expr || return false
    return ex.head === :if
end

"""
    is_for(ex)

Check if `ex` is a `for` loop expression.
"""
function is_for(@nospecialize(ex))
    ex isa Expr || return false
    return ex.head === :for
end

"""
    is_field(ex)

Check if `ex` is a valid field expression.
"""
function is_field(@nospecialize(ex))
    @smatch ex begin
        :($name::$type = $default) => false
        :($(name::Symbol) = $default) => false
        name::Symbol => true
        :($name::$type) => true
        _ => false
    end
end

"""
    is_field_default(ex)

Check if `ex` is a `<field expr> = <default expr>` expression.
"""
function is_field_default(@nospecialize(ex))
    @smatch ex begin
        :($name::$type = $default) => true
        :($(name::Symbol) = $default) => true
        _ => false
    end
end

"""
    split_doc(ex::Expr) -> line, doc, expr

Split doc string from given expression.
"""
function split_doc(ex::Expr)
    @smatch ex begin
        Expr(:macrocall, GlobalRef(Core, Symbol("@doc")), line, doc, expr) => (line, doc, expr)
        _ => (nothing, nothing, ex)
    end
end

"""
    split_function(ex::Expr) -> head, call, body

Split function head declaration with function body.
"""
function split_function(ex::Expr)
    @smatch ex begin
        Expr(:function, call, body) => (:function, call, body)
        Expr(:(=), call, body) => (:(=), call, body)
        Expr(:(->), call, body) => (:(->), call, body)
        _ => anlys_error("function", ex)
    end
end

"""
    split_function_head(ex::Expr) -> name, args, kw, whereparams

Split function head to name, arguments, keyword arguments and where parameters.
"""
function split_function_head(ex::Expr)
    @smatch ex begin
        Expr(:tuple, Expr(:parameters, kw...), args...) => (nothing, args, kw, nothing)
        Expr(:tuple, args...) => (nothing, args, nothing, nothing)
        Expr(:call, name, Expr(:parameters, kw...), args...) => (name, args, kw, nothing)
        Expr(:call, name, args...) => (name, args, nothing, nothing)
        Expr(:block, x, ::LineNumberNode, Expr(:(=), kw, value)) => (nothing, Any[x], Any[Expr(:kw, kw, value)], nothing)
        Expr(:block, x, ::LineNumberNode, kw) => (nothing, Any[x], Any[kw], nothing)
        Expr(:where, call, whereparams...) => begin
            name, args, kw, _ = split_function_head(call)
            (name, args, kw, whereparams)
        end
        _ => anlys_error("function head expr", ex)
    end
end

"""
    split_struct_name(ex::Expr) -> name, typevars, supertype

Split the name, type parameters and supertype definition from `struct`
declaration head.
"""
function split_struct_name(@nospecialize(ex))
    return @smatch ex begin
        :($name{$(typevars...)}) => (name, typevars, nothing)
        :($name{$(typevars...)} <: $type) => (name, typevars, type)
        ::Symbol => (ex, [], nothing)
        :($name <: $type) => (name, [], type)
        _ => anlys_error("struct", ex)
    end
end

"""
    split_struct(ex::Expr) -> ismutable, name, typevars, supertype, body

Split struct definition head and body.
"""
function split_struct(ex::Expr)
    ex.head === :struct || error("expect a struct expr, got $ex")
    name, typevars, supertype = split_struct_name(ex.args[2])
    body = ex.args[3]
    return ex.args[1], name, typevars, supertype, body
end

function split_ifelse(ex::Expr)
    dmap = OrderedDict()
    otherwise = split_ifelse!(dmap, ex)
    return dmap, otherwise
end

function split_ifelse!(d::AbstractDict, ex::Expr)
    ex.head in [:if, :elseif] || return ex
    d[ex.args[1]] = ex.args[2]
    if length(ex.args) == 3
        return split_ifelse!(d, ex.args[3])
    end
    return
end

function split_forloop(ex::Expr)
    ex.head === :for || error("expect a for loop expr, got $ex")
    lhead = ex.args[1]
    lbody = ex.args[2]
    return split_for_head(lhead)..., lbody
end

function split_for_head(ex::Expr)
    if ex.head === :block
        vars, itrs = [], []
        for each in ex.args
            each isa Expr || continue # skip other things
            var, itr = split_single_for_head(each)
            push!(vars, var)
            push!(itrs, itr)
        end
        return vars, itrs
    else
        var, itr = split_single_for_head(ex)
        return Any[var], Any[itr]
    end
end

function split_single_for_head(ex::Expr)
    ex.head === :(=) || error("expect a single loop head, got $ex")
    return ex.args[1], ex.args[2]
end

function uninferrable_typevars(def::Union{JLStruct, JLKwStruct}; leading_inferable::Bool=true)
    typevars = name_only.(def.typevars)
    field_types = [field.type for field in def.fields]

    if leading_inferable
        idx = findfirst(typevars) do t
            !any(map(f->has_symbol(f, t), field_types))
        end
        idx === nothing && return []
    else
        idx = 0
    end
    uninferrable = typevars[1:idx]

    for T in typevars[idx+1:end]
        any(map(f->has_symbol(f, T), field_types)) || push!(uninferrable, T)
    end
    return uninferrable
end

"""
    JLFunction(ex::Expr)

Create a `JLFunction` object from a Julia function `Expr`.

# Example

```julia
julia> JLFunction(:(f(x) = 2))
f(x) = begin
    #= REPL[37]:1 =#    
    2    
end
```
"""
function JLFunction(ex::Expr)
    line, doc, expr = split_doc(ex)
    head, call, body = split_function(expr)
    name, args, kw, whereparams = split_function_head(call)
    JLFunction(head, name, args, kw, whereparams, body, line, doc)
end

"""
    JLStruct(ex::Expr)

Create a `JLStruct` object from a Julia struct `Expr`.

# Example

```julia
julia> JLStruct(:(struct Foo
           x::Int
       end))
struct Foo
    #= REPL[38]:2 =#
    x::Int
end
```
"""
function JLStruct(ex::Expr)
    line, doc, expr = split_doc(ex)
    ismutable, typename, typevars, supertype, body = split_struct(expr)

    fields, constructors, misc = JLField[], JLFunction[], []
    field_doc, field_line = nothing, nothing

    for each in body.args
        @sswitch each begin
            @case :($name::$type)
                push!(fields, JLField(name, type, field_doc, field_line))
            @case name::Symbol
                push!(fields, JLField(name, Any, field_doc, field_line))
            @case ::String
                field_doc = each
            @case ::LineNumberNode
                field_line = each
            @case _
                if is_function(each) && name_only(each) === typename
                    push!(constructors, JLFunction(each))
                else
                    push!(misc, each)
                end
        end
    end
    JLStruct(typename, ismutable, typevars, supertype, fields, constructors, line, doc, misc)
end

"""
    JLKwStruct(ex::Expr, typealias=nothing)

Create a `JLKwStruct` from given Julia struct `Expr`, with an option to attach
an alias to this type name.

# Example

```julia
julia> JLKwStruct(:(struct Foo
           x::Int = 1
       end))
#= kw =# struct Foo
    #= REPL[39]:2 =#
    x::Int = 1
end
```
"""
function JLKwStruct(ex::Expr, typealias=nothing)
    line, doc, expr = split_doc(ex)
    ismutable, typename, typevars, supertype, body = split_struct(expr)

    fields, constructors, misc = JLKwField[], JLFunction[], []
    field_doc, field_line = nothing, nothing

    for each in body.args
        @sswitch each begin
            @case :($name::$type = $default)
                push!(fields, JLKwField(name, type, field_doc, field_line, default))
            @case :($(name::Symbol) = $default)
                push!(fields, JLKwField(name, Any, field_doc, field_line, default))
            @case name::Symbol
                push!(fields, JLKwField(name, Any, field_doc, field_line, no_default))
            @case :($name::$type)
                push!(fields, JLKwField(name, type, field_doc, field_line, no_default))
            @case ::String
                field_doc = each
            @case ::LineNumberNode
                field_line = each
            @case _
                if is_function(each) && name_only(each) === typename
                    push!(constructors, JLFunction(each))
                else
                    push!(misc, each)
                end
        end
    end
    JLKwStruct(typename, typealias, ismutable, typevars, supertype, fields, constructors, line, doc, misc)
end

"""
    JLIfElse(ex::Expr)

Create a `JLIfElse` from given Julia ifelse `Expr`.

# Example

```julia
julia> ex = :(if foo(x)
             x = 1 + 1
         elseif goo(x)
             y = 1 + 2
         else
             error("abc")
         end)
:(if foo(x)
      #= REPL[41]:2 =#
      x = 1 + 1
  elseif #= REPL[41]:3 =# goo(x)
      #= REPL[41]:4 =#
      y = 1 + 2
  else
      #= REPL[41]:6 =#
      error("abc")
  end)

julia> JLIfElse(ex)
if foo(x)
    begin
        #= REPL[41]:2 =#        
        x = 1 + 1        
    end
elseif begin
    #= REPL[41]:3 =#    
    goo(x)    
end
    begin
        #= REPL[41]:4 =#        
        y = 1 + 2        
    end
else
    begin
        #= REPL[41]:6 =#        
        error("abc")        
    end
end
```
"""
function JLIfElse(ex::Expr)
    ex.head === :if || error("expect an if ... elseif ... else ... end expression")
    d, otherwise = split_ifelse(ex)
    return JLIfElse(d, otherwise)
end

"""
    JLFor(ex::Expr)

Create a `JLFor` from given Julia for loop expression.

# Example

```julia
julia> ex = @expr for i in 1:10, j in 1:j
           M[i, j] += 1
       end
:(for i = 1:10, j = 1:j
      #= REPL[3]:2 =#
      M[i, j] += 1
  end)

julia> jl = JLFor(ex)
for i in 1 : 10,
    j in 1 : j
    #= loop body =#
    begin
        #= REPL[3]:2 =#        
        M[i, j] += 1        
    end
end

julia> jl.vars
2-element Vector{Any}:
 :i
 :j

julia> jl.iterators
2-element Vector{Any}:
 :(1:10)
 :(1:j)
```
"""
function JLFor(ex::Expr)
    vars, itrs, body = split_forloop(ex)
    return JLFor(vars, itrs, body)
end
