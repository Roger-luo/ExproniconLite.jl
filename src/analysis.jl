begin
    #= none:1 =# Core.@doc "    @expr <expression>\n\nReturn the original expression object.\n\n# Example\n\n```julia\njulia> ex = @expr x + 1\n:(x + 1)\n```\n" macro expr(ex)
            return QuoteNode(ex)
        end
    #= none:17 =# Core.@doc "    @test_expr <type> <ex>\n\nTest if the syntax type generates the same expression `ex`. Returns the\ncorresponding syntax type instance. Requires `using Test` before using\nthis macro.\n\n# Example\n\n```julia\ndef = @test_expr JLFunction function (x, y)\n    return 2\nend\n@test is_kw_fn(def) == false\n```\n" macro test_expr(type, ex)
            #= none:34 =# @gensym def generated_expr original_expr
            quote
                    $def = #= none:36 =# ExproniconLite.@expr($type, $ex)
                    println($def)
                    $generated_expr = ($prettify)(($codegen_ast)($def))
                    $original_expr = ($prettify)($(Expr(:quote, ex)))
                    #= none:40 =# @test ($compare_expr)($generated_expr, $original_expr)
                    $def
                end |> esc
        end
    #= none:45 =# Core.@doc "    @test_expr <expr> == <expr>\n\nTest if two expression is equivalent semantically, this uses `compare_expr`\nto decide if they are equivalent, ignores things such as `LineNumberNode`\ngenerated `Symbol` in `Expr(:curly, ...)` or `Expr(:where, ...)`.\n" macro test_expr(ex::Expr)
            ex.head === :call && ex.args[1] === :(==) || error("expect <expr> == <expr>, got $(ex)")
            (lhs, rhs) = (ex.args[2], ex.args[3])
            quote
                    $__source__
                    #= none:57 =# @test ($compare_expr)(($prettify)($lhs), ($prettify)($rhs))
                end |> esc
        end
    #= none:61 =# Core.@doc "    @expr <type> <expression>\n\nReturn the expression in given type.\n\n# Example\n\n```julia\njulia> ex = @expr JLKwStruct struct Foo{N, T}\n           x::T = 1\n       end\n#= kw =# struct Foo{N, T}\n    #= /home/roger/code/julia/Expronicon/test/analysis.jl:5 =#\n    x::T = 1\nend\n```\n" macro expr(type, ex)
            quote
                    ($type)($(Expr(:quote, ex)))
                end |> esc
        end
    struct AnalysisError <: Exception
        expect::String
        got
    end
    anlys_error(expect, got) = begin
            throw(AnalysisError(expect, got))
        end
    function Base.show(io::IO, e::AnalysisError)
        print(io, "expect ", e.expect, " expression, got ", e.got, ".")
    end
    #= none:95 =# Core.@doc "    compare_expr(lhs, rhs)\n\nCompare two expression of type `Expr` or `Symbol` semantically, which:\n\n1. ignore the detail value `LineNumberNode` in comparision\n2. ignore the detailed name of typevars in `Expr(:curly, ...)` or `Expr(:where, ...)`\n\nThis gives a way to compare two Julia expression semantically which means\nalthough some details of the expression is different but they should\nproduce the same lowered code.\n" function compare_expr(lhs, rhs)
            true
            x_1 = (lhs, rhs)
            if x_1 isa Tuple{Expr, Expr}
                if begin
                            cache_1 = nothing
                            x_2 = x_1[1]
                            x_2 isa Expr
                        end && (begin
                                if cache_1 === nothing
                                    cache_1 = Some((x_2.head, x_2.args))
                                end
                                x_3 = cache_1.value
                                x_3 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_3[1] == :curly && (begin
                                        x_4 = x_3[2]
                                        x_4 isa AbstractArray
                                    end && ((ndims(x_4) === 1 && length(x_4) >= 1) && (begin
                                                x_5 = x_4[1]
                                                x_6 = (SubArray)(x_4, (2:length(x_4),))
                                                cache_2 = nothing
                                                x_7 = x_1[2]
                                                x_7 isa Expr
                                            end && (begin
                                                    if cache_2 === nothing
                                                        cache_2 = Some((x_7.head, x_7.args))
                                                    end
                                                    x_8 = cache_2.value
                                                    x_8 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                end && (x_8[1] == :curly && (begin
                                                            x_9 = x_8[2]
                                                            x_9 isa AbstractArray
                                                        end && ((ndims(x_9) === 1 && length(x_9) >= 1) && (begin
                                                                    x_10 = x_9[1]
                                                                    let name = x_5, lhs_vars = x_6
                                                                        x_10 == name
                                                                    end
                                                                end && begin
                                                                    x_11 = (SubArray)(x_9, (2:length(x_9),))
                                                                    true
                                                                end))))))))))
                    rhs_vars = x_11
                    name = x_5
                    lhs_vars = x_6
                    return_1 = begin
                            all(map(compare_vars, lhs_vars, rhs_vars))
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#258_1")))
                end
                if begin
                            cache_3 = nothing
                            x_12 = x_1[1]
                            x_12 isa Expr
                        end && (begin
                                if cache_3 === nothing
                                    cache_3 = Some((x_12.head, x_12.args))
                                end
                                x_13 = cache_3.value
                                x_13 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_13[1] == :where && (begin
                                        x_14 = x_13[2]
                                        x_14 isa AbstractArray
                                    end && ((ndims(x_14) === 1 && length(x_14) >= 1) && (begin
                                                x_15 = x_14[1]
                                                x_16 = (SubArray)(x_14, (2:length(x_14),))
                                                cache_4 = nothing
                                                x_17 = x_1[2]
                                                x_17 isa Expr
                                            end && (begin
                                                    if cache_4 === nothing
                                                        cache_4 = Some((x_17.head, x_17.args))
                                                    end
                                                    x_18 = cache_4.value
                                                    x_18 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                end && (x_18[1] == :where && (begin
                                                            x_19 = x_18[2]
                                                            x_19 isa AbstractArray
                                                        end && ((ndims(x_19) === 1 && length(x_19) >= 1) && begin
                                                                x_20 = x_19[1]
                                                                x_21 = (SubArray)(x_19, (2:length(x_19),))
                                                                true
                                                            end)))))))))
                    lbody = x_15
                    rbody = x_20
                    rparams = x_21
                    lparams = x_16
                    return_1 = begin
                            compare_expr(lbody, rbody) && all(map(compare_vars, lparams, rparams))
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#258_1")))
                end
                if begin
                            cache_5 = nothing
                            x_22 = x_1[1]
                            x_22 isa Expr
                        end && (begin
                                if cache_5 === nothing
                                    cache_5 = Some((x_22.head, x_22.args))
                                end
                                x_23 = cache_5.value
                                x_23 isa Tuple{var1, var2} where {var2<:AbstractArray, var1}
                            end && (begin
                                    x_24 = x_23[1]
                                    x_25 = x_23[2]
                                    x_25 isa AbstractArray
                                end && ((ndims(x_25) === 1 && length(x_25) >= 0) && (begin
                                            x_26 = (SubArray)(x_25, (1:length(x_25),))
                                            cache_6 = nothing
                                            x_27 = x_1[2]
                                            x_27 isa Expr
                                        end && (begin
                                                if cache_6 === nothing
                                                    cache_6 = Some((x_27.head, x_27.args))
                                                end
                                                x_28 = cache_6.value
                                                x_28 isa Tuple{var1, var2} where {var2<:AbstractArray, var1}
                                            end && (begin
                                                    x_29 = x_28[1]
                                                    let head = x_24, largs = x_26
                                                        x_29 == head
                                                    end
                                                end && (begin
                                                        x_30 = x_28[2]
                                                        x_30 isa AbstractArray
                                                    end && ((ndims(x_30) === 1 && length(x_30) >= 0) && begin
                                                            x_31 = (SubArray)(x_30, (1:length(x_30),))
                                                            true
                                                        end))))))))
                    head = x_24
                    largs = x_26
                    rargs = x_31
                    return_1 = begin
                            isempty(largs) && isempty(rargs) || length(largs) == length(rargs) && all(map(compare_expr, largs, rargs))
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#258_1")))
                end
            end
            if x_1 isa Tuple{Symbol, Symbol}
                if begin
                            x_32 = x_1[1]
                            x_32 isa Symbol
                        end && begin
                            x_33 = x_1[2]
                            x_33 isa Symbol
                        end
                    return_1 = begin
                            lhs === rhs
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#258_1")))
                end
            end
            if x_1 isa Tuple{LineNumberNode, LineNumberNode}
                if begin
                            x_34 = x_1[1]
                            x_34 isa LineNumberNode
                        end && begin
                            x_35 = x_1[2]
                            x_35 isa LineNumberNode
                        end
                    return_1 = begin
                            true
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#258_1")))
                end
            end
            return_1 = begin
                    lhs == rhs
                end
            $(Expr(:symbolicgoto, Symbol("##final#258_1")))
            (error)("matching non-exhaustive, at #= none:108 =#")
            $(Expr(:symboliclabel, Symbol("##final#258_1")))
            return_1
        end
    #= none:127 =# Core.@doc "    compare_vars(lhs, rhs)\n\nCompare two expression by assuming all `Symbol`s are variables,\nthus their value doesn't matter, only where they are matters under\nthis assumption. See also [`compare_expr`](@ref).\n" function compare_vars(lhs, rhs)
            true
            x_36 = (lhs, rhs)
            if x_36 isa Tuple{Expr, Expr}
                if begin
                            cache_7 = nothing
                            x_37 = x_36[1]
                            x_37 isa Expr
                        end && (begin
                                if cache_7 === nothing
                                    cache_7 = Some((x_37.head, x_37.args))
                                end
                                x_38 = cache_7.value
                                x_38 isa Tuple{var1, var2} where {var2<:AbstractArray, var1}
                            end && (begin
                                    x_39 = x_38[1]
                                    x_40 = x_38[2]
                                    x_40 isa AbstractArray
                                end && ((ndims(x_40) === 1 && length(x_40) >= 0) && (begin
                                            x_41 = (SubArray)(x_40, (1:length(x_40),))
                                            cache_8 = nothing
                                            x_42 = x_36[2]
                                            x_42 isa Expr
                                        end && (begin
                                                if cache_8 === nothing
                                                    cache_8 = Some((x_42.head, x_42.args))
                                                end
                                                x_43 = cache_8.value
                                                x_43 isa Tuple{var1, var2} where {var2<:AbstractArray, var1}
                                            end && (begin
                                                    x_44 = x_43[1]
                                                    let head = x_39, largs = x_41
                                                        x_44 == head
                                                    end
                                                end && (begin
                                                        x_45 = x_43[2]
                                                        x_45 isa AbstractArray
                                                    end && ((ndims(x_45) === 1 && length(x_45) >= 0) && begin
                                                            x_46 = (SubArray)(x_45, (1:length(x_45),))
                                                            true
                                                        end))))))))
                    head = x_39
                    largs = x_41
                    rargs = x_46
                    return_2 = begin
                            all(map(compare_vars, largs, rargs))
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#302_1")))
                end
            end
            if x_36 isa Tuple{Symbol, Symbol}
                if begin
                            x_47 = x_36[1]
                            x_47 isa Symbol
                        end && begin
                            x_48 = x_36[2]
                            x_48 isa Symbol
                        end
                    return_2 = begin
                            true
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#302_1")))
                end
            end
            if x_36 isa Tuple{LineNumberNode, LineNumberNode}
                if begin
                            x_49 = x_36[1]
                            x_49 isa LineNumberNode
                        end && begin
                            x_50 = x_36[2]
                            x_50 isa LineNumberNode
                        end
                    return_2 = begin
                            true
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#302_1")))
                end
            end
            return_2 = begin
                    lhs == rhs
                end
            $(Expr(:symbolicgoto, Symbol("##final#302_1")))
            (error)("matching non-exhaustive, at #= none:135 =#")
            $(Expr(:symboliclabel, Symbol("##final#302_1")))
            return_2
        end
    #= none:148 =# Core.@doc "    is_literal(x)\n\nCheck if `x` is a literal value.\n" function is_literal(x)
            !(x isa Expr || (x isa Symbol || x isa GlobalRef))
        end
    #= none:157 =# Core.@doc "    is_gensym(s)\n\nCheck if `s` is generated by `gensym`.\n\n!!! note\n    Borrowed from [MacroTools](https://github.com/FluxML/MacroTools.jl).\n" is_gensym(s::Symbol) = begin
                occursin("#", string(s))
            end
    is_gensym(s) = begin
            false
        end
    #= none:168 =# Core.@doc "    gensym_name(x::Symbol)\n\nReturn the gensym name.\n\n!!! note\n    Borrowed from [MacroTools](https://github.com/FluxML/MacroTools.jl).\n" function gensym_name(x::Symbol)
            m = Base.match(r"##(.+)#\d+", String(x))
            m === nothing || return m.captures[1]
            m = Base.match(r"#\d+#(.+)", String(x))
            m === nothing || return m.captures[1]
            return "x"
        end
    #= none:184 =# Core.@doc "    support_default(f)\n\nCheck if field type `f` supports default value.\n" support_default(f) = begin
                false
            end
    support_default(f::JLKwField) = begin
            true
        end
    function has_symbol(#= none:192 =# @nospecialize(ex), name::Symbol)
        ex isa Symbol && return ex === name
        ex isa Expr || return false
        return any((x->begin
                        has_symbol(x, name)
                    end), ex.args)
    end
    #= none:198 =# Core.@doc "    has_kwfn_constructor(def[, name = struct_name_plain(def)])\n\nCheck if the struct definition contains keyword function constructor of `name`.\nThe constructor name to check by default is the plain constructor which does\nnot infer any type variables and requires user to input all type variables.\nSee also [`struct_name_plain`](@ref).\n" function has_kwfn_constructor(def, name = struct_name_plain(def))
            any(def.constructors) do fn::JLFunction
                isempty(fn.args) && fn.name == name
            end
        end
    #= none:212 =# Core.@doc "    has_plain_constructor(def, name = struct_name_plain(def))\n\nCheck if the struct definition contains the plain constructor of `name`.\nBy default the name is the inferable name [`struct_name_plain`](@ref).\n\n# Example\n\n```julia\ndef = @expr JLKwStruct struct Foo{T, N}\n    x::Int\n    y::N\n\n    Foo{T, N}(x, y) where {T, N} = new{T, N}(x, y)\nend\n\nhas_plain_constructor(def) # true\n\ndef = @expr JLKwStruct struct Foo{T, N}\n    x::T\n    y::N\n\n    Foo(x, y) = new{typeof(x), typeof(y)}(x, y)\nend\n\nhas_plain_constructor(def) # false\n```\n\nthe arguments must have no type annotations.\n\n```julia\ndef = @expr JLKwStruct struct Foo{T, N}\n    x::T\n    y::N\n\n    Foo{T, N}(x::T, y::N) where {T, N} = new{T, N}(x, y)\nend\n\nhas_plain_constructor(def) # false\n```\n" function has_plain_constructor(def, name = struct_name_plain(def))
            any(def.constructors) do fn::JLFunction
                fn.name == name || return false
                fn.kwargs === nothing || return false
                length(def.fields) == length(fn.args) || return false
                for (f, x) = zip(def.fields, fn.args)
                    f.name === x || return false
                end
                return true
            end
        end
    #= none:265 =# Core.@doc "    is_function(def)\n\nCheck if given object is a function expression.\n" function is_function(#= none:270 =# @nospecialize(def))
            let
                cache_9 = nothing
                return_3 = nothing
                x_51 = def
                if x_51 isa Expr
                    if begin
                                if cache_9 === nothing
                                    cache_9 = Some((x_51.head, x_51.args))
                                end
                                x_52 = cache_9.value
                                x_52 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_52[1] == :function && (begin
                                        x_53 = x_52[2]
                                        x_53 isa AbstractArray
                                    end && length(x_53) === 2))
                        return_3 = let
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#322_1")))
                    end
                    if begin
                                x_54 = cache_9.value
                                x_54 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_54[1] == :(=) && (begin
                                        x_55 = x_54[2]
                                        x_55 isa AbstractArray
                                    end && length(x_55) === 2))
                        return_3 = let
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#322_1")))
                    end
                    if begin
                                x_56 = cache_9.value
                                x_56 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_56[1] == :-> && (begin
                                        x_57 = x_56[2]
                                        x_57 isa AbstractArray
                                    end && length(x_57) === 2))
                        return_3 = let
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#322_1")))
                    end
                end
                if x_51 isa JLFunction
                    return_3 = let
                            true
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#322_1")))
                end
                return_3 = let
                        false
                    end
                $(Expr(:symbolicgoto, Symbol("##final#322_1")))
                (error)("matching non-exhaustive, at #= none:271 =#")
                $(Expr(:symboliclabel, Symbol("##final#322_1")))
                return_3
            end
        end
    #= none:280 =# Core.@doc "    is_kw_function(def)\n\nCheck if a given function definition supports keyword arguments.\n" function is_kw_function(#= none:285 =# @nospecialize(def))
            is_function(def) || return false
            if def isa JLFunction
                return def.kwargs !== nothing
            end
            (_, call, _) = split_function(def)
            let
                cache_10 = nothing
                return_4 = nothing
                x_58 = call
                if x_58 isa Expr
                    if begin
                                if cache_10 === nothing
                                    cache_10 = Some((x_58.head, x_58.args))
                                end
                                x_59 = cache_10.value
                                x_59 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_59[1] == :tuple && (begin
                                        x_60 = x_59[2]
                                        x_60 isa AbstractArray
                                    end && ((ndims(x_60) === 1 && length(x_60) >= 1) && (begin
                                                cache_11 = nothing
                                                x_61 = x_60[1]
                                                x_61 isa Expr
                                            end && (begin
                                                    if cache_11 === nothing
                                                        cache_11 = Some((x_61.head, x_61.args))
                                                    end
                                                    x_62 = cache_11.value
                                                    x_62 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                end && (x_62[1] == :parameters && (begin
                                                            x_63 = x_62[2]
                                                            x_63 isa AbstractArray
                                                        end && (ndims(x_63) === 1 && length(x_63) >= 0))))))))
                        return_4 = let
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#333_1")))
                    end
                    if begin
                                x_64 = cache_10.value
                                x_64 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_64[1] == :call && (begin
                                        x_65 = x_64[2]
                                        x_65 isa AbstractArray
                                    end && ((ndims(x_65) === 1 && length(x_65) >= 2) && (begin
                                                cache_12 = nothing
                                                x_66 = x_65[2]
                                                x_66 isa Expr
                                            end && (begin
                                                    if cache_12 === nothing
                                                        cache_12 = Some((x_66.head, x_66.args))
                                                    end
                                                    x_67 = cache_12.value
                                                    x_67 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                end && (x_67[1] == :parameters && (begin
                                                            x_68 = x_67[2]
                                                            x_68 isa AbstractArray
                                                        end && (ndims(x_68) === 1 && length(x_68) >= 0))))))))
                        return_4 = let
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#333_1")))
                    end
                    if begin
                                x_69 = cache_10.value
                                x_69 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_69[1] == :block && (begin
                                        x_70 = x_69[2]
                                        x_70 isa AbstractArray
                                    end && (length(x_70) === 3 && begin
                                            x_71 = x_70[2]
                                            x_71 isa LineNumberNode
                                        end)))
                        return_4 = let
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#333_1")))
                    end
                end
                return_4 = let
                        false
                    end
                $(Expr(:symbolicgoto, Symbol("##final#333_1")))
                (error)("matching non-exhaustive, at #= none:293 =#")
                $(Expr(:symboliclabel, Symbol("##final#333_1")))
                return_4
            end
        end
    #= none:301 =# @deprecate is_kw_fn(def) is_kw_function(def)
    #= none:302 =# @deprecate is_fn(def) is_function(def)
    #= none:304 =# Core.@doc "    is_struct(ex)\n\nCheck if `ex` is a struct expression.\n" function is_struct(#= none:309 =# @nospecialize(ex))
            ex isa Expr || return false
            return ex.head === :struct
        end
    #= none:314 =# Core.@doc "    is_struct_not_kw_struct(ex)\n\nCheck if `ex` is a struct expression excluding keyword struct syntax.\n" function is_struct_not_kw_struct(ex)
            is_struct(ex) || return false
            body = ex.args[3]
            body isa Expr && body.head === :block || return false
            any(is_field_default, body.args) && return false
            return true
        end
    #= none:327 =# Core.@doc "    is_ifelse(ex)\n\nCheck if `ex` is an `if ... elseif ... else ... end` expression.\n" function is_ifelse(#= none:332 =# @nospecialize(ex))
            ex isa Expr || return false
            return ex.head === :if
        end
    #= none:337 =# Core.@doc "    is_for(ex)\n\nCheck if `ex` is a `for` loop expression.\n" function is_for(#= none:342 =# @nospecialize(ex))
            ex isa Expr || return false
            return ex.head === :for
        end
    #= none:347 =# Core.@doc "    is_field(ex)\n\nCheck if `ex` is a valid field expression.\n" function is_field(#= none:352 =# @nospecialize(ex))
            let
                cache_13 = nothing
                return_5 = nothing
                x_72 = ex
                if x_72 isa Symbol
                    return_5 = let name = x_72
                            true
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#353_1")))
                end
                if x_72 isa Expr
                    if begin
                                if cache_13 === nothing
                                    cache_13 = Some((x_72.head, x_72.args))
                                end
                                x_73 = cache_13.value
                                x_73 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_73[1] == :(=) && (begin
                                        x_74 = x_73[2]
                                        x_74 isa AbstractArray
                                    end && (length(x_74) === 2 && (begin
                                                cache_14 = nothing
                                                x_75 = x_74[1]
                                                x_75 isa Expr
                                            end && (begin
                                                    if cache_14 === nothing
                                                        cache_14 = Some((x_75.head, x_75.args))
                                                    end
                                                    x_76 = cache_14.value
                                                    x_76 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                end && (x_76[1] == :(::) && (begin
                                                            x_77 = x_76[2]
                                                            x_77 isa AbstractArray
                                                        end && (length(x_77) === 2 && begin
                                                                x_78 = x_77[1]
                                                                x_79 = x_77[2]
                                                                x_80 = x_74[2]
                                                                true
                                                            end))))))))
                        return_5 = let default = x_80, type = x_79, name = x_78
                                false
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#353_1")))
                    end
                    if begin
                                x_81 = cache_13.value
                                x_81 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_81[1] == :(=) && (begin
                                        x_82 = x_81[2]
                                        x_82 isa AbstractArray
                                    end && (length(x_82) === 2 && (begin
                                                x_83 = x_82[1]
                                                x_83 isa Symbol
                                            end && begin
                                                x_84 = x_82[2]
                                                true
                                            end))))
                        return_5 = let default = x_84, name = x_83
                                false
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#353_1")))
                    end
                    if begin
                                x_85 = cache_13.value
                                x_85 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_85[1] == :(::) && (begin
                                        x_86 = x_85[2]
                                        x_86 isa AbstractArray
                                    end && (length(x_86) === 2 && begin
                                            x_87 = x_86[1]
                                            x_88 = x_86[2]
                                            true
                                        end)))
                        return_5 = let type = x_88, name = x_87
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#353_1")))
                    end
                end
                return_5 = let
                        false
                    end
                $(Expr(:symbolicgoto, Symbol("##final#353_1")))
                (error)("matching non-exhaustive, at #= none:353 =#")
                $(Expr(:symboliclabel, Symbol("##final#353_1")))
                return_5
            end
        end
    #= none:362 =# Core.@doc "    is_field_default(ex)\n\nCheck if `ex` is a `<field expr> = <default expr>` expression.\n" function is_field_default(#= none:367 =# @nospecialize(ex))
            let
                cache_15 = nothing
                return_6 = nothing
                x_89 = ex
                if x_89 isa Expr
                    if begin
                                if cache_15 === nothing
                                    cache_15 = Some((x_89.head, x_89.args))
                                end
                                x_90 = cache_15.value
                                x_90 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_90[1] == :(=) && (begin
                                        x_91 = x_90[2]
                                        x_91 isa AbstractArray
                                    end && (length(x_91) === 2 && (begin
                                                cache_16 = nothing
                                                x_92 = x_91[1]
                                                x_92 isa Expr
                                            end && (begin
                                                    if cache_16 === nothing
                                                        cache_16 = Some((x_92.head, x_92.args))
                                                    end
                                                    x_93 = cache_16.value
                                                    x_93 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                end && (x_93[1] == :(::) && (begin
                                                            x_94 = x_93[2]
                                                            x_94 isa AbstractArray
                                                        end && (length(x_94) === 2 && begin
                                                                x_95 = x_94[1]
                                                                x_96 = x_94[2]
                                                                x_97 = x_91[2]
                                                                true
                                                            end))))))))
                        return_6 = let default = x_97, type = x_96, name = x_95
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#375_1")))
                    end
                    if begin
                                x_98 = cache_15.value
                                x_98 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_98[1] == :(=) && (begin
                                        x_99 = x_98[2]
                                        x_99 isa AbstractArray
                                    end && (length(x_99) === 2 && (begin
                                                x_100 = x_99[1]
                                                x_100 isa Symbol
                                            end && begin
                                                x_101 = x_99[2]
                                                true
                                            end))))
                        return_6 = let default = x_101, name = x_100
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#375_1")))
                    end
                end
                return_6 = let
                        false
                    end
                $(Expr(:symbolicgoto, Symbol("##final#375_1")))
                (error)("matching non-exhaustive, at #= none:368 =#")
                $(Expr(:symboliclabel, Symbol("##final#375_1")))
                return_6
            end
        end
    #= none:375 =# Core.@doc "    split_doc(ex::Expr) -> line, doc, expr\n\nSplit doc string from given expression.\n" function split_doc(ex::Expr)
            if ex.head === :macrocall && ex.args[1] == GlobalRef(Core, Symbol("@doc"))
                return (ex.args[2], ex.args[3], ex.args[4])
            else
                return (nothing, nothing, ex)
            end
        end
    #= none:388 =# Core.@doc "    split_function(ex::Expr) -> head, call, body\n\nSplit function head declaration with function body.\n" function split_function(ex::Expr)
            let
                cache_17 = nothing
                return_7 = nothing
                x_102 = ex
                if x_102 isa Expr
                    if begin
                                if cache_17 === nothing
                                    cache_17 = Some((x_102.head, x_102.args))
                                end
                                x_103 = cache_17.value
                                x_103 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_103[1] == :function && (begin
                                        x_104 = x_103[2]
                                        x_104 isa AbstractArray
                                    end && (length(x_104) === 2 && begin
                                            x_105 = x_104[1]
                                            x_106 = x_104[2]
                                            true
                                        end)))
                        return_7 = let call = x_105, body = x_106
                                (:function, call, body)
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#393_1")))
                    end
                    if begin
                                x_107 = cache_17.value
                                x_107 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_107[1] == :(=) && (begin
                                        x_108 = x_107[2]
                                        x_108 isa AbstractArray
                                    end && (length(x_108) === 2 && begin
                                            x_109 = x_108[1]
                                            x_110 = x_108[2]
                                            true
                                        end)))
                        return_7 = let call = x_109, body = x_110
                                (:(=), call, body)
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#393_1")))
                    end
                    if begin
                                x_111 = cache_17.value
                                x_111 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_111[1] == :-> && (begin
                                        x_112 = x_111[2]
                                        x_112 isa AbstractArray
                                    end && (length(x_112) === 2 && begin
                                            x_113 = x_112[1]
                                            x_114 = x_112[2]
                                            true
                                        end)))
                        return_7 = let call = x_113, body = x_114
                                (:->, call, body)
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#393_1")))
                    end
                end
                return_7 = let
                        anlys_error("function", ex)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#393_1")))
                (error)("matching non-exhaustive, at #= none:394 =#")
                $(Expr(:symboliclabel, Symbol("##final#393_1")))
                return_7
            end
        end
    #= none:402 =# Core.@doc "    split_function_head(ex::Expr) -> name, args, kw, whereparams, rettype\n\nSplit function head to name, arguments, keyword arguments and where parameters.\n" function split_function_head(ex::Expr)
            let
                cache_18 = nothing
                return_8 = nothing
                x_115 = ex
                if x_115 isa Expr
                    if begin
                                if cache_18 === nothing
                                    cache_18 = Some((x_115.head, x_115.args))
                                end
                                x_116 = cache_18.value
                                x_116 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_116[1] == :tuple && (begin
                                        x_117 = x_116[2]
                                        x_117 isa AbstractArray
                                    end && ((ndims(x_117) === 1 && length(x_117) >= 1) && (begin
                                                cache_19 = nothing
                                                x_118 = x_117[1]
                                                x_118 isa Expr
                                            end && (begin
                                                    if cache_19 === nothing
                                                        cache_19 = Some((x_118.head, x_118.args))
                                                    end
                                                    x_119 = cache_19.value
                                                    x_119 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                end && (x_119[1] == :parameters && (begin
                                                            x_120 = x_119[2]
                                                            x_120 isa AbstractArray
                                                        end && ((ndims(x_120) === 1 && length(x_120) >= 0) && begin
                                                                x_121 = (SubArray)(x_120, (1:length(x_120),))
                                                                x_122 = (SubArray)(x_117, (2:length(x_117),))
                                                                true
                                                            end))))))))
                        return_8 = let args = x_122, kw = x_121
                                (nothing, args, kw, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#410_1")))
                    end
                    if begin
                                x_123 = cache_18.value
                                x_123 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_123[1] == :tuple && (begin
                                        x_124 = x_123[2]
                                        x_124 isa AbstractArray
                                    end && ((ndims(x_124) === 1 && length(x_124) >= 0) && begin
                                            x_125 = (SubArray)(x_124, (1:length(x_124),))
                                            true
                                        end)))
                        return_8 = let args = x_125
                                (nothing, args, nothing, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#410_1")))
                    end
                    if begin
                                x_126 = cache_18.value
                                x_126 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_126[1] == :call && (begin
                                        x_127 = x_126[2]
                                        x_127 isa AbstractArray
                                    end && ((ndims(x_127) === 1 && length(x_127) >= 2) && (begin
                                                x_128 = x_127[1]
                                                cache_20 = nothing
                                                x_129 = x_127[2]
                                                x_129 isa Expr
                                            end && (begin
                                                    if cache_20 === nothing
                                                        cache_20 = Some((x_129.head, x_129.args))
                                                    end
                                                    x_130 = cache_20.value
                                                    x_130 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                end && (x_130[1] == :parameters && (begin
                                                            x_131 = x_130[2]
                                                            x_131 isa AbstractArray
                                                        end && ((ndims(x_131) === 1 && length(x_131) >= 0) && begin
                                                                x_132 = (SubArray)(x_131, (1:length(x_131),))
                                                                x_133 = (SubArray)(x_127, (3:length(x_127),))
                                                                true
                                                            end))))))))
                        return_8 = let name = x_128, args = x_133, kw = x_132
                                (name, args, kw, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#410_1")))
                    end
                    if begin
                                x_134 = cache_18.value
                                x_134 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_134[1] == :call && (begin
                                        x_135 = x_134[2]
                                        x_135 isa AbstractArray
                                    end && ((ndims(x_135) === 1 && length(x_135) >= 1) && begin
                                            x_136 = x_135[1]
                                            x_137 = (SubArray)(x_135, (2:length(x_135),))
                                            true
                                        end)))
                        return_8 = let name = x_136, args = x_137
                                (name, args, nothing, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#410_1")))
                    end
                    if begin
                                x_138 = cache_18.value
                                x_138 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_138[1] == :block && (begin
                                        x_139 = x_138[2]
                                        x_139 isa AbstractArray
                                    end && (length(x_139) === 3 && (begin
                                                x_140 = x_139[1]
                                                x_141 = x_139[2]
                                                x_141 isa LineNumberNode
                                            end && (begin
                                                    cache_21 = nothing
                                                    x_142 = x_139[3]
                                                    x_142 isa Expr
                                                end && (begin
                                                        if cache_21 === nothing
                                                            cache_21 = Some((x_142.head, x_142.args))
                                                        end
                                                        x_143 = cache_21.value
                                                        x_143 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                    end && (x_143[1] == :(=) && (begin
                                                                x_144 = x_143[2]
                                                                x_144 isa AbstractArray
                                                            end && (length(x_144) === 2 && begin
                                                                    x_145 = x_144[1]
                                                                    x_146 = x_144[2]
                                                                    true
                                                                end)))))))))
                        return_8 = let value = x_146, kw = x_145, x = x_140
                                (nothing, Any[x], Any[Expr(:kw, kw, value)], nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#410_1")))
                    end
                    if begin
                                x_147 = cache_18.value
                                x_147 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_147[1] == :block && (begin
                                        x_148 = x_147[2]
                                        x_148 isa AbstractArray
                                    end && (length(x_148) === 3 && (begin
                                                x_149 = x_148[1]
                                                x_150 = x_148[2]
                                                x_150 isa LineNumberNode
                                            end && begin
                                                x_151 = x_148[3]
                                                true
                                            end))))
                        return_8 = let kw = x_151, x = x_149
                                (nothing, Any[x], Any[kw], nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#410_1")))
                    end
                    if begin
                                x_152 = cache_18.value
                                x_152 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_152[1] == :(::) && (begin
                                        x_153 = x_152[2]
                                        x_153 isa AbstractArray
                                    end && (length(x_153) === 2 && begin
                                            x_154 = x_153[1]
                                            x_155 = x_153[2]
                                            true
                                        end)))
                        return_8 = let call = x_154, rettype = x_155
                                (name, args, kw, whereparams, _) = split_function_head(call)
                                (name, args, kw, whereparams, rettype)
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#410_1")))
                    end
                    if begin
                                x_156 = cache_18.value
                                x_156 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_156[1] == :where && (begin
                                        x_157 = x_156[2]
                                        x_157 isa AbstractArray
                                    end && ((ndims(x_157) === 1 && length(x_157) >= 1) && begin
                                            x_158 = x_157[1]
                                            x_159 = (SubArray)(x_157, (2:length(x_157),))
                                            true
                                        end)))
                        return_8 = let call = x_158, whereparams = x_159
                                (name, args, kw, _, rettype) = split_function_head(call)
                                (name, args, kw, whereparams, rettype)
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#410_1")))
                    end
                end
                return_8 = let
                        anlys_error("function head expr", ex)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#410_1")))
                (error)("matching non-exhaustive, at #= none:408 =#")
                $(Expr(:symboliclabel, Symbol("##final#410_1")))
                return_8
            end
        end
    #= none:427 =# Core.@doc "    split_struct_name(ex::Expr) -> name, typevars, supertype\n\nSplit the name, type parameters and supertype definition from `struct`\ndeclaration head.\n" function split_struct_name(#= none:433 =# @nospecialize(ex))
            return let
                    cache_22 = nothing
                    return_9 = nothing
                    x_160 = ex
                    if x_160 isa Symbol
                        return_9 = let
                                (ex, [], nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#462_1")))
                    end
                    if x_160 isa Expr
                        if begin
                                    if cache_22 === nothing
                                        cache_22 = Some((x_160.head, x_160.args))
                                    end
                                    x_161 = cache_22.value
                                    x_161 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                end && (x_161[1] == :curly && (begin
                                            x_162 = x_161[2]
                                            x_162 isa AbstractArray
                                        end && ((ndims(x_162) === 1 && length(x_162) >= 1) && begin
                                                x_163 = x_162[1]
                                                x_164 = (SubArray)(x_162, (2:length(x_162),))
                                                true
                                            end)))
                            return_9 = let typevars = x_164, name = x_163
                                    (name, typevars, nothing)
                                end
                            $(Expr(:symbolicgoto, Symbol("##final#462_1")))
                        end
                        if begin
                                    x_165 = cache_22.value
                                    x_165 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                end && (x_165[1] == :<: && (begin
                                            x_166 = x_165[2]
                                            x_166 isa AbstractArray
                                        end && (length(x_166) === 2 && (begin
                                                    cache_23 = nothing
                                                    x_167 = x_166[1]
                                                    x_167 isa Expr
                                                end && (begin
                                                        if cache_23 === nothing
                                                            cache_23 = Some((x_167.head, x_167.args))
                                                        end
                                                        x_168 = cache_23.value
                                                        x_168 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                    end && (x_168[1] == :curly && (begin
                                                                x_169 = x_168[2]
                                                                x_169 isa AbstractArray
                                                            end && ((ndims(x_169) === 1 && length(x_169) >= 1) && begin
                                                                    x_170 = x_169[1]
                                                                    x_171 = (SubArray)(x_169, (2:length(x_169),))
                                                                    x_172 = x_166[2]
                                                                    true
                                                                end))))))))
                            return_9 = let typevars = x_171, type = x_172, name = x_170
                                    (name, typevars, type)
                                end
                            $(Expr(:symbolicgoto, Symbol("##final#462_1")))
                        end
                        if begin
                                    x_173 = cache_22.value
                                    x_173 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                end && (x_173[1] == :<: && (begin
                                            x_174 = x_173[2]
                                            x_174 isa AbstractArray
                                        end && (length(x_174) === 2 && begin
                                                x_175 = x_174[1]
                                                x_176 = x_174[2]
                                                true
                                            end)))
                            return_9 = let type = x_176, name = x_175
                                    (name, [], type)
                                end
                            $(Expr(:symbolicgoto, Symbol("##final#462_1")))
                        end
                    end
                    return_9 = let
                            anlys_error("struct", ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#462_1")))
                    (error)("matching non-exhaustive, at #= none:434 =#")
                    $(Expr(:symboliclabel, Symbol("##final#462_1")))
                    return_9
                end
        end
    #= none:443 =# Core.@doc "    split_struct(ex::Expr) -> ismutable, name, typevars, supertype, body\n\nSplit struct definition head and body.\n" function split_struct(ex::Expr)
            ex.head === :struct || error("expect a struct expr, got $(ex)")
            (name, typevars, supertype) = split_struct_name(ex.args[2])
            body = ex.args[3]
            return (ex.args[1], name, typevars, supertype, body)
        end
    function split_ifelse(ex::Expr)
        (conds, stmts) = ([], [])
        otherwise = split_ifelse!((conds, stmts), ex)
        return (conds, stmts, otherwise)
    end
    function split_ifelse!((conds, stmts), ex::Expr)
        ex.head in [:if, :elseif] || return ex
        push!(conds, ex.args[1])
        push!(stmts, ex.args[2])
        if length(ex.args) == 3
            return split_ifelse!((conds, stmts), ex.args[3])
        end
        return
    end
    function split_forloop(ex::Expr)
        ex.head === :for || error("expect a for loop expr, got $(ex)")
        lhead = ex.args[1]
        lbody = ex.args[2]
        return (split_for_head(lhead)..., lbody)
    end
    function split_for_head(ex::Expr)
        if ex.head === :block
            (vars, itrs) = ([], [])
            for each = ex.args
                each isa Expr || continue
                (var, itr) = split_single_for_head(each)
                push!(vars, var)
                push!(itrs, itr)
            end
            return (vars, itrs)
        else
            (var, itr) = split_single_for_head(ex)
            return (Any[var], Any[itr])
        end
    end
    function split_single_for_head(ex::Expr)
        ex.head === :(=) || error("expect a single loop head, got $(ex)")
        return (ex.args[1], ex.args[2])
    end
    function uninferrable_typevars(def::Union{JLStruct, JLKwStruct}; leading_inferable::Bool = true)
        typevars = name_only.(def.typevars)
        field_types = [field.type for field = def.fields]
        if leading_inferable
            idx = findfirst(typevars) do t
                    !(any(map((f->begin
                                        has_symbol(f, t)
                                    end), field_types)))
                end
            idx === nothing && return []
        else
            idx = 0
        end
        uninferrable = typevars[1:idx]
        for T = typevars[idx + 1:end]
            any(map((f->begin
                                has_symbol(f, T)
                            end), field_types)) || push!(uninferrable, T)
        end
        return uninferrable
    end
    #= none:520 =# Core.@doc "    JLFunction(ex::Expr)\n\nCreate a `JLFunction` object from a Julia function `Expr`.\n\n# Example\n\n```julia\njulia> JLFunction(:(f(x) = 2))\nf(x) = begin\n    #= REPL[37]:1 =#    \n    2    \nend\n```\n" function JLFunction(ex::Expr)
            (line, doc, expr) = split_doc(ex)
            (head, call, body) = split_function(expr)
            (name, args, kw, whereparams, rettype) = split_function_head(call)
            JLFunction(head, name, args, kw, rettype, whereparams, body, line, doc)
        end
    #= none:542 =# Core.@doc "    JLStruct(ex::Expr)\n\nCreate a `JLStruct` object from a Julia struct `Expr`.\n\n# Example\n\n```julia\njulia> JLStruct(:(struct Foo\n           x::Int\n       end))\nstruct Foo\n    #= REPL[38]:2 =#\n    x::Int\nend\n```\n" function JLStruct(ex::Expr)
            (line, doc, expr) = split_doc(ex)
            (ismutable, typename, typevars, supertype, body) = split_struct(expr)
            (fields, constructors, misc) = (JLField[], JLFunction[], [])
            (field_doc, field_line) = (nothing, nothing)
            for each = body.args
                cache_24 = nothing
                x_177 = each
                if x_177 isa Symbol
                    name = x_177
                    return_10 = begin
                            push!(fields, JLField(name, Any, field_doc, field_line))
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#484_1")))
                end
                if x_177 isa Expr
                    if begin
                                if cache_24 === nothing
                                    cache_24 = Some((x_177.head, x_177.args))
                                end
                                x_178 = cache_24.value
                                x_178 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_178[1] == :(::) && (begin
                                        x_179 = x_178[2]
                                        x_179 isa AbstractArray
                                    end && (length(x_179) === 2 && begin
                                            x_180 = x_179[1]
                                            x_181 = x_179[2]
                                            true
                                        end)))
                        type = x_181
                        name = x_180
                        return_10 = begin
                                push!(fields, JLField(name, type, field_doc, field_line))
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#484_1")))
                    end
                end
                if x_177 isa LineNumberNode
                    return_10 = begin
                            field_line = each
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#484_1")))
                end
                if x_177 isa String
                    return_10 = begin
                            field_doc = each
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#484_1")))
                end
                if is_function(x_177)
                    return_10 = begin
                            if name_only(each) === typename
                                push!(constructors, JLFunction(each))
                            else
                                push!(misc, each)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#484_1")))
                end
                return_10 = begin
                        push!(misc, each)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#484_1")))
                (error)("matching non-exhaustive, at #= none:567 =#")
                $(Expr(:symboliclabel, Symbol("##final#484_1")))
                return_10
            end
            JLStruct(typename, ismutable, typevars, supertype, fields, constructors, line, doc, misc)
        end
    #= none:589 =# Core.@doc "    JLKwStruct(ex::Expr, typealias=nothing)\n\nCreate a `JLKwStruct` from given Julia struct `Expr`, with an option to attach\nan alias to this type name.\n\n# Example\n\n```julia\njulia> JLKwStruct(:(struct Foo\n           x::Int = 1\n       end))\n#= kw =# struct Foo\n    #= REPL[39]:2 =#\n    x::Int = 1\nend\n```\n" function JLKwStruct(ex::Expr, typealias = nothing)
            (line, doc, expr) = split_doc(ex)
            (ismutable, typename, typevars, supertype, body) = split_struct(expr)
            (fields, constructors, misc) = (JLKwField[], JLFunction[], [])
            (field_doc, field_line) = (nothing, nothing)
            for each = body.args
                cache_25 = nothing
                x_182 = each
                if x_182 isa Symbol
                    name = x_182
                    return_11 = begin
                            push!(fields, JLKwField(name, Any, field_doc, field_line, no_default))
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#493_1")))
                end
                if x_182 isa Expr
                    if begin
                                if cache_25 === nothing
                                    cache_25 = Some((x_182.head, x_182.args))
                                end
                                x_183 = cache_25.value
                                x_183 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_183[1] == :(=) && (begin
                                        x_184 = x_183[2]
                                        x_184 isa AbstractArray
                                    end && (length(x_184) === 2 && (begin
                                                cache_26 = nothing
                                                x_185 = x_184[1]
                                                x_185 isa Expr
                                            end && (begin
                                                    if cache_26 === nothing
                                                        cache_26 = Some((x_185.head, x_185.args))
                                                    end
                                                    x_186 = cache_26.value
                                                    x_186 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                end && (x_186[1] == :(::) && (begin
                                                            x_187 = x_186[2]
                                                            x_187 isa AbstractArray
                                                        end && (length(x_187) === 2 && begin
                                                                x_188 = x_187[1]
                                                                x_189 = x_187[2]
                                                                x_190 = x_184[2]
                                                                true
                                                            end))))))))
                        default = x_190
                        type = x_189
                        name = x_188
                        return_11 = begin
                                push!(fields, JLKwField(name, type, field_doc, field_line, default))
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#493_1")))
                    end
                    if begin
                                x_191 = cache_25.value
                                x_191 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_191[1] == :(=) && (begin
                                        x_192 = x_191[2]
                                        x_192 isa AbstractArray
                                    end && (length(x_192) === 2 && (begin
                                                x_193 = x_192[1]
                                                x_193 isa Symbol
                                            end && begin
                                                x_194 = x_192[2]
                                                true
                                            end))))
                        default = x_194
                        name = x_193
                        return_11 = begin
                                push!(fields, JLKwField(name, Any, field_doc, field_line, default))
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#493_1")))
                    end
                    if begin
                                x_195 = cache_25.value
                                x_195 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_195[1] == :(::) && (begin
                                        x_196 = x_195[2]
                                        x_196 isa AbstractArray
                                    end && (length(x_196) === 2 && begin
                                            x_197 = x_196[1]
                                            x_198 = x_196[2]
                                            true
                                        end)))
                        type = x_198
                        name = x_197
                        return_11 = begin
                                push!(fields, JLKwField(name, type, field_doc, field_line, no_default))
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#493_1")))
                    end
                end
                if x_182 isa LineNumberNode
                    return_11 = begin
                            field_line = each
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#493_1")))
                end
                if x_182 isa String
                    return_11 = begin
                            field_doc = each
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#493_1")))
                end
                if is_function(x_182)
                    return_11 = begin
                            if name_only(each) === typename
                                push!(constructors, JLFunction(each))
                            else
                                push!(misc, each)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#493_1")))
                end
                return_11 = begin
                        push!(misc, each)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#493_1")))
                (error)("matching non-exhaustive, at #= none:615 =#")
                $(Expr(:symboliclabel, Symbol("##final#493_1")))
                return_11
            end
            JLKwStruct(typename, typealias, ismutable, typevars, supertype, fields, constructors, line, doc, misc)
        end
    #= none:641 =# Core.@doc "    JLIfElse(ex::Expr)\n\nCreate a `JLIfElse` from given Julia ifelse `Expr`.\n\n# Example\n\n```julia\njulia> ex = :(if foo(x)\n             x = 1 + 1\n         elseif goo(x)\n             y = 1 + 2\n         else\n             error(\"abc\")\n         end)\n:(if foo(x)\n      #= REPL[41]:2 =#\n      x = 1 + 1\n  elseif #= REPL[41]:3 =# goo(x)\n      #= REPL[41]:4 =#\n      y = 1 + 2\n  else\n      #= REPL[41]:6 =#\n      error(\"abc\")\n  end)\n\njulia> JLIfElse(ex)\nif foo(x)\n    begin\n        #= REPL[41]:2 =#        \n        x = 1 + 1        \n    end\nelseif begin\n    #= REPL[41]:3 =#    \n    goo(x)    \nend\n    begin\n        #= REPL[41]:4 =#        \n        y = 1 + 2        \n    end\nelse\n    begin\n        #= REPL[41]:6 =#        \n        error(\"abc\")        \n    end\nend\n```\n" function JLIfElse(ex::Expr)
            ex.head === :if || error("expect an if ... elseif ... else ... end expression")
            (conds, stmts, otherwise) = split_ifelse(ex)
            return JLIfElse(conds, stmts, otherwise)
        end
    #= none:695 =# Core.@doc "    JLFor(ex::Expr)\n\nCreate a `JLFor` from given Julia for loop expression.\n\n# Example\n\n```julia\njulia> ex = @expr for i in 1:10, j in 1:j\n           M[i, j] += 1\n       end\n:(for i = 1:10, j = 1:j\n      #= REPL[3]:2 =#\n      M[i, j] += 1\n  end)\n\njulia> jl = JLFor(ex)\nfor i in 1 : 10,\n    j in 1 : j\n    #= loop body =#\n    begin\n        #= REPL[3]:2 =#        \n        M[i, j] += 1        \n    end\nend\n\njulia> jl.vars\n2-element Vector{Any}:\n :i\n :j\n\njulia> jl.iterators\n2-element Vector{Any}:\n :(1:10)\n :(1:j)\n```\n" function JLFor(ex::Expr)
            (vars, itrs, body) = split_forloop(ex)
            return JLFor(vars, itrs, body)
        end
end
