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
            if x_1 isa Tuple{Symbol, Symbol}
                if begin
                            x_2 = x_1[1]
                            x_2 isa Symbol
                        end && begin
                            x_3 = x_1[2]
                            x_3 isa Symbol
                        end
                    return_1 = begin
                            lhs === rhs
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#283_1")))
                end
            end
            if x_1 isa Tuple{Expr, Expr}
                if begin
                            cache_1 = nothing
                            x_4 = x_1[1]
                            x_4 isa Expr
                        end && (begin
                                if cache_1 === nothing
                                    cache_1 = Some((x_4.head, x_4.args))
                                end
                                x_5 = cache_1.value
                                x_5 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_5[1] == :curly && (begin
                                        x_6 = x_5[2]
                                        x_6 isa AbstractArray
                                    end && ((ndims(x_6) === 1 && length(x_6) >= 1) && (begin
                                                x_7 = x_6[1]
                                                x_8 = (SubArray)(x_6, (2:length(x_6),))
                                                cache_2 = nothing
                                                x_9 = x_1[2]
                                                x_9 isa Expr
                                            end && (begin
                                                    if cache_2 === nothing
                                                        cache_2 = Some((x_9.head, x_9.args))
                                                    end
                                                    x_10 = cache_2.value
                                                    x_10 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                end && (x_10[1] == :curly && (begin
                                                            x_11 = x_10[2]
                                                            x_11 isa AbstractArray
                                                        end && ((ndims(x_11) === 1 && length(x_11) >= 1) && (begin
                                                                    x_12 = x_11[1]
                                                                    let name = x_7, lhs_vars = x_8
                                                                        x_12 == name
                                                                    end
                                                                end && begin
                                                                    x_13 = (SubArray)(x_11, (2:length(x_11),))
                                                                    true
                                                                end))))))))))
                    rhs_vars = x_13
                    name = x_7
                    lhs_vars = x_8
                    return_1 = begin
                            all(map(compare_vars, lhs_vars, rhs_vars))
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#283_1")))
                end
                if begin
                            cache_3 = nothing
                            x_14 = x_1[1]
                            x_14 isa Expr
                        end && (begin
                                if cache_3 === nothing
                                    cache_3 = Some((x_14.head, x_14.args))
                                end
                                x_15 = cache_3.value
                                x_15 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_15[1] == :where && (begin
                                        x_16 = x_15[2]
                                        x_16 isa AbstractArray
                                    end && ((ndims(x_16) === 1 && length(x_16) >= 1) && (begin
                                                x_17 = x_16[1]
                                                x_18 = (SubArray)(x_16, (2:length(x_16),))
                                                cache_4 = nothing
                                                x_19 = x_1[2]
                                                x_19 isa Expr
                                            end && (begin
                                                    if cache_4 === nothing
                                                        cache_4 = Some((x_19.head, x_19.args))
                                                    end
                                                    x_20 = cache_4.value
                                                    x_20 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                end && (x_20[1] == :where && (begin
                                                            x_21 = x_20[2]
                                                            x_21 isa AbstractArray
                                                        end && ((ndims(x_21) === 1 && length(x_21) >= 1) && begin
                                                                x_22 = x_21[1]
                                                                x_23 = (SubArray)(x_21, (2:length(x_21),))
                                                                true
                                                            end)))))))))
                    lbody = x_17
                    rbody = x_22
                    rparams = x_23
                    lparams = x_18
                    return_1 = begin
                            compare_expr(lbody, rbody) && all(map(compare_vars, lparams, rparams))
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#283_1")))
                end
                if begin
                            cache_5 = nothing
                            x_24 = x_1[1]
                            x_24 isa Expr
                        end && (begin
                                if cache_5 === nothing
                                    cache_5 = Some((x_24.head, x_24.args))
                                end
                                x_25 = cache_5.value
                                x_25 isa Tuple{var1, var2} where {var2<:AbstractArray, var1}
                            end && (begin
                                    x_26 = x_25[1]
                                    x_27 = x_25[2]
                                    x_27 isa AbstractArray
                                end && ((ndims(x_27) === 1 && length(x_27) >= 0) && (begin
                                            x_28 = (SubArray)(x_27, (1:length(x_27),))
                                            cache_6 = nothing
                                            x_29 = x_1[2]
                                            x_29 isa Expr
                                        end && (begin
                                                if cache_6 === nothing
                                                    cache_6 = Some((x_29.head, x_29.args))
                                                end
                                                x_30 = cache_6.value
                                                x_30 isa Tuple{var1, var2} where {var2<:AbstractArray, var1}
                                            end && (begin
                                                    x_31 = x_30[1]
                                                    let head = x_26, largs = x_28
                                                        x_31 == head
                                                    end
                                                end && (begin
                                                        x_32 = x_30[2]
                                                        x_32 isa AbstractArray
                                                    end && ((ndims(x_32) === 1 && length(x_32) >= 0) && begin
                                                            x_33 = (SubArray)(x_32, (1:length(x_32),))
                                                            true
                                                        end))))))))
                    head = x_26
                    largs = x_28
                    rargs = x_33
                    return_1 = begin
                            isempty(largs) && isempty(rargs) || length(largs) == length(rargs) && all(map(compare_expr, largs, rargs))
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#283_1")))
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
                    $(Expr(:symbolicgoto, Symbol("##final#283_1")))
                end
            end
            return_1 = begin
                    lhs == rhs
                end
            $(Expr(:symbolicgoto, Symbol("##final#283_1")))
            (error)("matching non-exhaustive, at #= none:108 =#")
            $(Expr(:symboliclabel, Symbol("##final#283_1")))
            return_1
        end
    #= none:127 =# Core.@doc "    compare_vars(lhs, rhs)\n\nCompare two expression by assuming all `Symbol`s are variables,\nthus their value doesn't matter, only where they are matters under\nthis assumption. See also [`compare_expr`](@ref).\n" function compare_vars(lhs, rhs)
            true
            x_36 = (lhs, rhs)
            if x_36 isa Tuple{Symbol, Symbol}
                if begin
                            x_37 = x_36[1]
                            x_37 isa Symbol
                        end && begin
                            x_38 = x_36[2]
                            x_38 isa Symbol
                        end
                    return_2 = begin
                            true
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#327_1")))
                end
            end
            if x_36 isa Tuple{Expr, Expr}
                if begin
                            cache_7 = nothing
                            x_39 = x_36[1]
                            x_39 isa Expr
                        end && (begin
                                if cache_7 === nothing
                                    cache_7 = Some((x_39.head, x_39.args))
                                end
                                x_40 = cache_7.value
                                x_40 isa Tuple{var1, var2} where {var2<:AbstractArray, var1}
                            end && (begin
                                    x_41 = x_40[1]
                                    x_42 = x_40[2]
                                    x_42 isa AbstractArray
                                end && ((ndims(x_42) === 1 && length(x_42) >= 0) && (begin
                                            x_43 = (SubArray)(x_42, (1:length(x_42),))
                                            cache_8 = nothing
                                            x_44 = x_36[2]
                                            x_44 isa Expr
                                        end && (begin
                                                if cache_8 === nothing
                                                    cache_8 = Some((x_44.head, x_44.args))
                                                end
                                                x_45 = cache_8.value
                                                x_45 isa Tuple{var1, var2} where {var2<:AbstractArray, var1}
                                            end && (begin
                                                    x_46 = x_45[1]
                                                    let head = x_41, largs = x_43
                                                        x_46 == head
                                                    end
                                                end && (begin
                                                        x_47 = x_45[2]
                                                        x_47 isa AbstractArray
                                                    end && ((ndims(x_47) === 1 && length(x_47) >= 0) && begin
                                                            x_48 = (SubArray)(x_47, (1:length(x_47),))
                                                            true
                                                        end))))))))
                    head = x_41
                    largs = x_43
                    rargs = x_48
                    return_2 = begin
                            all(map(compare_vars, largs, rargs))
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#327_1")))
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
                    $(Expr(:symbolicgoto, Symbol("##final#327_1")))
                end
            end
            return_2 = begin
                    lhs == rhs
                end
            $(Expr(:symbolicgoto, Symbol("##final#327_1")))
            (error)("matching non-exhaustive, at #= none:135 =#")
            $(Expr(:symboliclabel, Symbol("##final#327_1")))
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
                        $(Expr(:symbolicgoto, Symbol("##final#347_1")))
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
                        $(Expr(:symbolicgoto, Symbol("##final#347_1")))
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
                        $(Expr(:symbolicgoto, Symbol("##final#347_1")))
                    end
                end
                if x_51 isa JLFunction
                    return_3 = let
                            true
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#347_1")))
                end
                return_3 = let
                        false
                    end
                $(Expr(:symbolicgoto, Symbol("##final#347_1")))
                (error)("matching non-exhaustive, at #= none:271 =#")
                $(Expr(:symboliclabel, Symbol("##final#347_1")))
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
                        $(Expr(:symbolicgoto, Symbol("##final#358_1")))
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
                        $(Expr(:symbolicgoto, Symbol("##final#358_1")))
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
                        $(Expr(:symbolicgoto, Symbol("##final#358_1")))
                    end
                end
                return_4 = let
                        false
                    end
                $(Expr(:symbolicgoto, Symbol("##final#358_1")))
                (error)("matching non-exhaustive, at #= none:293 =#")
                $(Expr(:symboliclabel, Symbol("##final#358_1")))
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
                        $(Expr(:symbolicgoto, Symbol("##final#378_1")))
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
                        $(Expr(:symbolicgoto, Symbol("##final#378_1")))
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
                        $(Expr(:symbolicgoto, Symbol("##final#378_1")))
                    end
                end
                if x_72 isa Symbol
                    return_5 = let name = x_72
                            true
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#378_1")))
                end
                return_5 = let
                        false
                    end
                $(Expr(:symbolicgoto, Symbol("##final#378_1")))
                (error)("matching non-exhaustive, at #= none:353 =#")
                $(Expr(:symboliclabel, Symbol("##final#378_1")))
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
                        $(Expr(:symbolicgoto, Symbol("##final#400_1")))
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
                        $(Expr(:symbolicgoto, Symbol("##final#400_1")))
                    end
                end
                return_6 = let
                        false
                    end
                $(Expr(:symbolicgoto, Symbol("##final#400_1")))
                (error)("matching non-exhaustive, at #= none:368 =#")
                $(Expr(:symboliclabel, Symbol("##final#400_1")))
                return_6
            end
        end
    #= none:375 =# Core.@doc "    is_datatype_expr(ex)\n\nCheck if `ex` is an expression for a concrete `DataType`, e.g\n`where` is not allowed in the expression.\n" function is_datatype_expr(#= none:381 =# @nospecialize(ex))
            let
                cache_17 = nothing
                return_7 = nothing
                x_102 = ex
                if x_102 isa GlobalRef
                    return_7 = let
                            true
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#418_1")))
                end
                if x_102 isa Expr
                    if begin
                                if cache_17 === nothing
                                    cache_17 = Some((x_102.head, x_102.args))
                                end
                                x_103 = cache_17.value
                                x_103 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_103[1] == :curly && (begin
                                        x_104 = x_103[2]
                                        x_104 isa AbstractArray
                                    end && (length(x_104) === 2 && (begin
                                                cache_18 = nothing
                                                x_105 = x_104[2]
                                                x_105 isa Expr
                                            end && (begin
                                                    if cache_18 === nothing
                                                        cache_18 = Some((x_105.head, x_105.args))
                                                    end
                                                    x_106 = cache_18.value
                                                    x_106 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                end && (x_106[1] == :... && (begin
                                                            x_107 = x_106[2]
                                                            x_107 isa AbstractArray
                                                        end && length(x_107) === 1)))))))
                        return_7 = let
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#418_1")))
                    end
                    if begin
                                x_108 = cache_17.value
                                x_108 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_108[1] == :. && (begin
                                        x_109 = x_108[2]
                                        x_109 isa AbstractArray
                                    end && (length(x_109) === 2 && (begin
                                                x_110 = x_109[2]
                                                x_110 isa QuoteNode
                                            end && begin
                                                x_111 = x_110.value
                                                true
                                            end))))
                        return_7 = let b = x_111
                                is_datatype_expr(b)
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#418_1")))
                    end
                end
                if x_102 isa Symbol
                    return_7 = let
                            true
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#418_1")))
                end
                return_7 = let
                        false
                    end
                $(Expr(:symbolicgoto, Symbol("##final#418_1")))
                (error)("matching non-exhaustive, at #= none:382 =#")
                $(Expr(:symboliclabel, Symbol("##final#418_1")))
                return_7
            end
        end
    #= none:391 =# Core.@doc "    split_doc(ex::Expr) -> line, doc, expr\n\nSplit doc string from given expression.\n" function split_doc(ex::Expr)
            if ex.head === :macrocall && ex.args[1] == GlobalRef(Core, Symbol("@doc"))
                return (ex.args[2], ex.args[3], ex.args[4])
            else
                return (nothing, nothing, ex)
            end
        end
    #= none:404 =# Core.@doc "    split_function(ex::Expr) -> head, call, body\n\nSplit function head declaration with function body.\n" function split_function(ex::Expr)
            let
                cache_19 = nothing
                return_8 = nothing
                x_112 = ex
                if x_112 isa Expr
                    if begin
                                if cache_19 === nothing
                                    cache_19 = Some((x_112.head, x_112.args))
                                end
                                x_113 = cache_19.value
                                x_113 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_113[1] == :function && (begin
                                        x_114 = x_113[2]
                                        x_114 isa AbstractArray
                                    end && (length(x_114) === 2 && begin
                                            x_115 = x_114[1]
                                            x_116 = x_114[2]
                                            true
                                        end)))
                        return_8 = let call = x_115, body = x_116
                                (:function, call, body)
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#433_1")))
                    end
                    if begin
                                x_117 = cache_19.value
                                x_117 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_117[1] == :(=) && (begin
                                        x_118 = x_117[2]
                                        x_118 isa AbstractArray
                                    end && (length(x_118) === 2 && begin
                                            x_119 = x_118[1]
                                            x_120 = x_118[2]
                                            true
                                        end)))
                        return_8 = let call = x_119, body = x_120
                                (:(=), call, body)
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#433_1")))
                    end
                    if begin
                                x_121 = cache_19.value
                                x_121 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_121[1] == :-> && (begin
                                        x_122 = x_121[2]
                                        x_122 isa AbstractArray
                                    end && (length(x_122) === 2 && begin
                                            x_123 = x_122[1]
                                            x_124 = x_122[2]
                                            true
                                        end)))
                        return_8 = let call = x_123, body = x_124
                                (:->, call, body)
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#433_1")))
                    end
                end
                return_8 = let
                        anlys_error("function", ex)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#433_1")))
                (error)("matching non-exhaustive, at #= none:410 =#")
                $(Expr(:symboliclabel, Symbol("##final#433_1")))
                return_8
            end
        end
    #= none:418 =# Core.@doc "    split_function_head(ex::Expr) -> name, args, kw, whereparams, rettype\n\nSplit function head to name, arguments, keyword arguments and where parameters.\n" function split_function_head(ex::Expr)
            let
                cache_20 = nothing
                return_9 = nothing
                x_125 = ex
                if x_125 isa Expr
                    if begin
                                if cache_20 === nothing
                                    cache_20 = Some((x_125.head, x_125.args))
                                end
                                x_126 = cache_20.value
                                x_126 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_126[1] == :tuple && (begin
                                        x_127 = x_126[2]
                                        x_127 isa AbstractArray
                                    end && ((ndims(x_127) === 1 && length(x_127) >= 1) && (begin
                                                cache_21 = nothing
                                                x_128 = x_127[1]
                                                x_128 isa Expr
                                            end && (begin
                                                    if cache_21 === nothing
                                                        cache_21 = Some((x_128.head, x_128.args))
                                                    end
                                                    x_129 = cache_21.value
                                                    x_129 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                end && (x_129[1] == :parameters && (begin
                                                            x_130 = x_129[2]
                                                            x_130 isa AbstractArray
                                                        end && ((ndims(x_130) === 1 && length(x_130) >= 0) && begin
                                                                x_131 = (SubArray)(x_130, (1:length(x_130),))
                                                                x_132 = (SubArray)(x_127, (2:length(x_127),))
                                                                true
                                                            end))))))))
                        return_9 = let args = x_132, kw = x_131
                                (nothing, args, kw, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#450_1")))
                    end
                    if begin
                                x_133 = cache_20.value
                                x_133 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_133[1] == :tuple && (begin
                                        x_134 = x_133[2]
                                        x_134 isa AbstractArray
                                    end && ((ndims(x_134) === 1 && length(x_134) >= 0) && begin
                                            x_135 = (SubArray)(x_134, (1:length(x_134),))
                                            true
                                        end)))
                        return_9 = let args = x_135
                                (nothing, args, nothing, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#450_1")))
                    end
                    if begin
                                x_136 = cache_20.value
                                x_136 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_136[1] == :call && (begin
                                        x_137 = x_136[2]
                                        x_137 isa AbstractArray
                                    end && ((ndims(x_137) === 1 && length(x_137) >= 2) && (begin
                                                x_138 = x_137[1]
                                                cache_22 = nothing
                                                x_139 = x_137[2]
                                                x_139 isa Expr
                                            end && (begin
                                                    if cache_22 === nothing
                                                        cache_22 = Some((x_139.head, x_139.args))
                                                    end
                                                    x_140 = cache_22.value
                                                    x_140 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                end && (x_140[1] == :parameters && (begin
                                                            x_141 = x_140[2]
                                                            x_141 isa AbstractArray
                                                        end && ((ndims(x_141) === 1 && length(x_141) >= 0) && begin
                                                                x_142 = (SubArray)(x_141, (1:length(x_141),))
                                                                x_143 = (SubArray)(x_137, (3:length(x_137),))
                                                                true
                                                            end))))))))
                        return_9 = let name = x_138, args = x_143, kw = x_142
                                (name, args, kw, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#450_1")))
                    end
                    if begin
                                x_144 = cache_20.value
                                x_144 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_144[1] == :call && (begin
                                        x_145 = x_144[2]
                                        x_145 isa AbstractArray
                                    end && ((ndims(x_145) === 1 && length(x_145) >= 1) && begin
                                            x_146 = x_145[1]
                                            x_147 = (SubArray)(x_145, (2:length(x_145),))
                                            true
                                        end)))
                        return_9 = let name = x_146, args = x_147
                                (name, args, nothing, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#450_1")))
                    end
                    if begin
                                x_148 = cache_20.value
                                x_148 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_148[1] == :block && (begin
                                        x_149 = x_148[2]
                                        x_149 isa AbstractArray
                                    end && (length(x_149) === 3 && (begin
                                                x_150 = x_149[1]
                                                x_151 = x_149[2]
                                                x_151 isa LineNumberNode
                                            end && (begin
                                                    cache_23 = nothing
                                                    x_152 = x_149[3]
                                                    x_152 isa Expr
                                                end && (begin
                                                        if cache_23 === nothing
                                                            cache_23 = Some((x_152.head, x_152.args))
                                                        end
                                                        x_153 = cache_23.value
                                                        x_153 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                    end && (x_153[1] == :(=) && (begin
                                                                x_154 = x_153[2]
                                                                x_154 isa AbstractArray
                                                            end && (length(x_154) === 2 && begin
                                                                    x_155 = x_154[1]
                                                                    x_156 = x_154[2]
                                                                    true
                                                                end)))))))))
                        return_9 = let value = x_156, kw = x_155, x = x_150
                                (nothing, Any[x], Any[Expr(:kw, kw, value)], nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#450_1")))
                    end
                    if begin
                                x_157 = cache_20.value
                                x_157 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_157[1] == :block && (begin
                                        x_158 = x_157[2]
                                        x_158 isa AbstractArray
                                    end && (length(x_158) === 3 && (begin
                                                x_159 = x_158[1]
                                                x_160 = x_158[2]
                                                x_160 isa LineNumberNode
                                            end && begin
                                                x_161 = x_158[3]
                                                true
                                            end))))
                        return_9 = let kw = x_161, x = x_159
                                (nothing, Any[x], Any[kw], nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#450_1")))
                    end
                    if begin
                                x_162 = cache_20.value
                                x_162 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_162[1] == :(::) && (begin
                                        x_163 = x_162[2]
                                        x_163 isa AbstractArray
                                    end && (length(x_163) === 2 && begin
                                            x_164 = x_163[1]
                                            x_165 = x_163[2]
                                            true
                                        end)))
                        return_9 = let call = x_164, rettype = x_165
                                (name, args, kw, whereparams, _) = split_function_head(call)
                                (name, args, kw, whereparams, rettype)
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#450_1")))
                    end
                    if begin
                                x_166 = cache_20.value
                                x_166 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_166[1] == :where && (begin
                                        x_167 = x_166[2]
                                        x_167 isa AbstractArray
                                    end && ((ndims(x_167) === 1 && length(x_167) >= 1) && begin
                                            x_168 = x_167[1]
                                            x_169 = (SubArray)(x_167, (2:length(x_167),))
                                            true
                                        end)))
                        return_9 = let call = x_168, whereparams = x_169
                                (name, args, kw, _, rettype) = split_function_head(call)
                                (name, args, kw, whereparams, rettype)
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#450_1")))
                    end
                end
                return_9 = let
                        anlys_error("function head expr", ex)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#450_1")))
                (error)("matching non-exhaustive, at #= none:424 =#")
                $(Expr(:symboliclabel, Symbol("##final#450_1")))
                return_9
            end
        end
    #= none:443 =# Core.@doc "    split_struct_name(ex::Expr) -> name, typevars, supertype\n\nSplit the name, type parameters and supertype definition from `struct`\ndeclaration head.\n" function split_struct_name(#= none:449 =# @nospecialize(ex))
            return let
                    cache_24 = nothing
                    return_10 = nothing
                    x_170 = ex
                    if x_170 isa Expr
                        if begin
                                    if cache_24 === nothing
                                        cache_24 = Some((x_170.head, x_170.args))
                                    end
                                    x_171 = cache_24.value
                                    x_171 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                end && (x_171[1] == :curly && (begin
                                            x_172 = x_171[2]
                                            x_172 isa AbstractArray
                                        end && ((ndims(x_172) === 1 && length(x_172) >= 1) && begin
                                                x_173 = x_172[1]
                                                x_174 = (SubArray)(x_172, (2:length(x_172),))
                                                true
                                            end)))
                            return_10 = let typevars = x_174, name = x_173
                                    (name, typevars, nothing)
                                end
                            $(Expr(:symbolicgoto, Symbol("##final#502_1")))
                        end
                        if begin
                                    x_175 = cache_24.value
                                    x_175 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                end && (x_175[1] == :<: && (begin
                                            x_176 = x_175[2]
                                            x_176 isa AbstractArray
                                        end && (length(x_176) === 2 && (begin
                                                    cache_25 = nothing
                                                    x_177 = x_176[1]
                                                    x_177 isa Expr
                                                end && (begin
                                                        if cache_25 === nothing
                                                            cache_25 = Some((x_177.head, x_177.args))
                                                        end
                                                        x_178 = cache_25.value
                                                        x_178 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                    end && (x_178[1] == :curly && (begin
                                                                x_179 = x_178[2]
                                                                x_179 isa AbstractArray
                                                            end && ((ndims(x_179) === 1 && length(x_179) >= 1) && begin
                                                                    x_180 = x_179[1]
                                                                    x_181 = (SubArray)(x_179, (2:length(x_179),))
                                                                    x_182 = x_176[2]
                                                                    true
                                                                end))))))))
                            return_10 = let typevars = x_181, type = x_182, name = x_180
                                    (name, typevars, type)
                                end
                            $(Expr(:symbolicgoto, Symbol("##final#502_1")))
                        end
                        if begin
                                    x_183 = cache_24.value
                                    x_183 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                end && (x_183[1] == :<: && (begin
                                            x_184 = x_183[2]
                                            x_184 isa AbstractArray
                                        end && (length(x_184) === 2 && begin
                                                x_185 = x_184[1]
                                                x_186 = x_184[2]
                                                true
                                            end)))
                            return_10 = let type = x_186, name = x_185
                                    (name, [], type)
                                end
                            $(Expr(:symbolicgoto, Symbol("##final#502_1")))
                        end
                    end
                    if x_170 isa Symbol
                        return_10 = let
                                (ex, [], nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#502_1")))
                    end
                    return_10 = let
                            anlys_error("struct", ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#502_1")))
                    (error)("matching non-exhaustive, at #= none:450 =#")
                    $(Expr(:symboliclabel, Symbol("##final#502_1")))
                    return_10
                end
        end
    #= none:459 =# Core.@doc "    split_struct(ex::Expr) -> ismutable, name, typevars, supertype, body\n\nSplit struct definition head and body.\n" function split_struct(ex::Expr)
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
    #= none:536 =# Core.@doc "    JLFunction(ex::Expr)\n\nCreate a `JLFunction` object from a Julia function `Expr`.\n\n# Example\n\n```julia\njulia> JLFunction(:(f(x) = 2))\nf(x) = begin\n    #= REPL[37]:1 =#    \n    2    \nend\n```\n" function JLFunction(ex::Expr)
            (line, doc, expr) = split_doc(ex)
            (head, call, body) = split_function(expr)
            (name, args, kw, whereparams, rettype) = split_function_head(call)
            JLFunction(head, name, args, kw, rettype, whereparams, body, line, doc)
        end
    #= none:558 =# Core.@doc "    JLStruct(ex::Expr)\n\nCreate a `JLStruct` object from a Julia struct `Expr`.\n\n# Example\n\n```julia\njulia> JLStruct(:(struct Foo\n           x::Int\n       end))\nstruct Foo\n    #= REPL[38]:2 =#\n    x::Int\nend\n```\n" function JLStruct(ex::Expr)
            (line, doc, expr) = split_doc(ex)
            (ismutable, typename, typevars, supertype, body) = split_struct(expr)
            (fields, constructors, misc) = (JLField[], JLFunction[], [])
            (field_doc, field_line) = (nothing, nothing)
            body = flatten_blocks(body)
            for each = body.args
                cache_26 = nothing
                x_187 = each
                if x_187 isa Expr
                    if begin
                                if cache_26 === nothing
                                    cache_26 = Some((x_187.head, x_187.args))
                                end
                                x_188 = cache_26.value
                                x_188 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_188[1] == :(::) && (begin
                                        x_189 = x_188[2]
                                        x_189 isa AbstractArray
                                    end && (length(x_189) === 2 && begin
                                            x_190 = x_189[1]
                                            x_191 = x_189[2]
                                            true
                                        end)))
                        type = x_191
                        name = x_190
                        return_11 = begin
                                push!(fields, JLField(name, type, field_doc, field_line))
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#524_1")))
                    end
                end
                if x_187 isa Symbol
                    name = x_187
                    return_11 = begin
                            push!(fields, JLField(name, Any, field_doc, field_line))
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#524_1")))
                end
                if x_187 isa String
                    return_11 = begin
                            field_doc = each
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#524_1")))
                end
                if x_187 isa LineNumberNode
                    return_11 = begin
                            field_line = each
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#524_1")))
                end
                if is_function(x_187)
                    return_11 = begin
                            if name_only(each) === typename
                                push!(constructors, JLFunction(each))
                            else
                                push!(misc, each)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#524_1")))
                end
                return_11 = begin
                        push!(misc, each)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#524_1")))
                (error)("matching non-exhaustive, at #= none:585 =#")
                $(Expr(:symboliclabel, Symbol("##final#524_1")))
                return_11
            end
            JLStruct(typename, ismutable, typevars, supertype, fields, constructors, line, doc, misc)
        end
    #= none:607 =# Core.@doc "    JLKwStruct(ex::Expr, typealias=nothing)\n\nCreate a `JLKwStruct` from given Julia struct `Expr`, with an option to attach\nan alias to this type name.\n\n# Example\n\n```julia\njulia> JLKwStruct(:(struct Foo\n           x::Int = 1\n       end))\n#= kw =# struct Foo\n    #= REPL[39]:2 =#\n    x::Int = 1\nend\n```\n" function JLKwStruct(ex::Expr, typealias = nothing)
            (line, doc, expr) = split_doc(ex)
            (ismutable, typename, typevars, supertype, body) = split_struct(expr)
            (fields, constructors, misc) = (JLKwField[], JLFunction[], [])
            (field_doc, field_line) = (nothing, nothing)
            body = flatten_blocks(body)
            for each = body.args
                cache_27 = nothing
                x_192 = each
                if x_192 isa Expr
                    if begin
                                if cache_27 === nothing
                                    cache_27 = Some((x_192.head, x_192.args))
                                end
                                x_193 = cache_27.value
                                x_193 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_193[1] == :(=) && (begin
                                        x_194 = x_193[2]
                                        x_194 isa AbstractArray
                                    end && (length(x_194) === 2 && (begin
                                                cache_28 = nothing
                                                x_195 = x_194[1]
                                                x_195 isa Expr
                                            end && (begin
                                                    if cache_28 === nothing
                                                        cache_28 = Some((x_195.head, x_195.args))
                                                    end
                                                    x_196 = cache_28.value
                                                    x_196 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                end && (x_196[1] == :(::) && (begin
                                                            x_197 = x_196[2]
                                                            x_197 isa AbstractArray
                                                        end && (length(x_197) === 2 && begin
                                                                x_198 = x_197[1]
                                                                x_199 = x_197[2]
                                                                x_200 = x_194[2]
                                                                true
                                                            end))))))))
                        default = x_200
                        type = x_199
                        name = x_198
                        return_12 = begin
                                push!(fields, JLKwField(name, type, field_doc, field_line, default))
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#533_1")))
                    end
                    if begin
                                x_201 = cache_27.value
                                x_201 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_201[1] == :(=) && (begin
                                        x_202 = x_201[2]
                                        x_202 isa AbstractArray
                                    end && (length(x_202) === 2 && (begin
                                                x_203 = x_202[1]
                                                x_203 isa Symbol
                                            end && begin
                                                x_204 = x_202[2]
                                                true
                                            end))))
                        default = x_204
                        name = x_203
                        return_12 = begin
                                push!(fields, JLKwField(name, Any, field_doc, field_line, default))
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#533_1")))
                    end
                    if begin
                                x_205 = cache_27.value
                                x_205 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_205[1] == :(::) && (begin
                                        x_206 = x_205[2]
                                        x_206 isa AbstractArray
                                    end && (length(x_206) === 2 && begin
                                            x_207 = x_206[1]
                                            x_208 = x_206[2]
                                            true
                                        end)))
                        type = x_208
                        name = x_207
                        return_12 = begin
                                push!(fields, JLKwField(name, type, field_doc, field_line, no_default))
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#533_1")))
                    end
                end
                if x_192 isa Symbol
                    name = x_192
                    return_12 = begin
                            push!(fields, JLKwField(name, Any, field_doc, field_line, no_default))
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#533_1")))
                end
                if x_192 isa String
                    return_12 = begin
                            field_doc = each
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#533_1")))
                end
                if x_192 isa LineNumberNode
                    return_12 = begin
                            field_line = each
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#533_1")))
                end
                if is_function(x_192)
                    return_12 = begin
                            if name_only(each) === typename
                                push!(constructors, JLFunction(each))
                            else
                                push!(misc, each)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#533_1")))
                end
                return_12 = begin
                        push!(misc, each)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#533_1")))
                (error)("matching non-exhaustive, at #= none:633 =#")
                $(Expr(:symboliclabel, Symbol("##final#533_1")))
                return_12
            end
            JLKwStruct(typename, typealias, ismutable, typevars, supertype, fields, constructors, line, doc, misc)
        end
    #= none:659 =# Core.@doc "    JLIfElse(ex::Expr)\n\nCreate a `JLIfElse` from given Julia ifelse `Expr`.\n\n# Example\n\n```julia\njulia> ex = :(if foo(x)\n             x = 1 + 1\n         elseif goo(x)\n             y = 1 + 2\n         else\n             error(\"abc\")\n         end)\n:(if foo(x)\n      #= REPL[41]:2 =#\n      x = 1 + 1\n  elseif #= REPL[41]:3 =# goo(x)\n      #= REPL[41]:4 =#\n      y = 1 + 2\n  else\n      #= REPL[41]:6 =#\n      error(\"abc\")\n  end)\n\njulia> JLIfElse(ex)\nif foo(x)\n    begin\n        #= REPL[41]:2 =#        \n        x = 1 + 1        \n    end\nelseif begin\n    #= REPL[41]:3 =#    \n    goo(x)    \nend\n    begin\n        #= REPL[41]:4 =#        \n        y = 1 + 2        \n    end\nelse\n    begin\n        #= REPL[41]:6 =#        \n        error(\"abc\")        \n    end\nend\n```\n" function JLIfElse(ex::Expr)
            ex.head === :if || error("expect an if ... elseif ... else ... end expression")
            (conds, stmts, otherwise) = split_ifelse(ex)
            return JLIfElse(conds, stmts, otherwise)
        end
    #= none:713 =# Core.@doc "    JLFor(ex::Expr)\n\nCreate a `JLFor` from given Julia for loop expression.\n\n# Example\n\n```julia\njulia> ex = @expr for i in 1:10, j in 1:j\n           M[i, j] += 1\n       end\n:(for i = 1:10, j = 1:j\n      #= REPL[3]:2 =#\n      M[i, j] += 1\n  end)\n\njulia> jl = JLFor(ex)\nfor i in 1 : 10,\n    j in 1 : j\n    #= loop body =#\n    begin\n        #= REPL[3]:2 =#        \n        M[i, j] += 1        \n    end\nend\n\njulia> jl.vars\n2-element Vector{Any}:\n :i\n :j\n\njulia> jl.iterators\n2-element Vector{Any}:\n :(1:10)\n :(1:j)\n```\n" function JLFor(ex::Expr)
            (vars, itrs, body) = split_forloop(ex)
            return JLFor(vars, itrs, body)
        end
end
