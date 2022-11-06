begin
    #= none:1 =# Core.@doc "    is_valid_typevar(typevar)\n\nCheck if the given typevar is a valid typevar.\n\n!!! note\n    This function is based on [this discourse post](https://discourse.julialang.org/t/what-are-valid-type-parameters/471).\n" function is_valid_typevar(typevar)
            let
                true
                return_1 = nothing
                x_1 = typevar
                if x_1 isa TypeVar
                    return_1 = let
                            true
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#624_1")))
                end
                if x_1 isa Symbol
                    return_1 = let
                            true
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#624_1")))
                end
                if x_1 isa Type
                    return_1 = let
                            true
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#624_1")))
                end
                if isbitstype(typeof(typevar))
                    return_1 = let
                            true
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#624_1")))
                end
                if x_1 isa Tuple
                    return_1 = let
                            all((x->begin
                                        x isa Symbol || isbitstype(typeof(x))
                                    end), typevar)
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#624_1")))
                end
                return_1 = let
                        false
                    end
                $(Expr(:symbolicgoto, Symbol("##final#624_1")))
                (error)("matching non-exhaustive, at #= none:10 =#")
                $(Expr(:symboliclabel, Symbol("##final#624_1")))
                return_1
            end
        end
    #= none:20 =# Core.@doc "    is_literal(x)\n\nCheck if `x` is a literal value.\n" function is_literal(x)
            !(x isa Expr || (x isa Symbol || x isa GlobalRef))
        end
    #= none:29 =# Core.@doc "    is_tuple(ex)\n\nCheck if `ex` is a tuple expression, i.e. `:((a,b,c))`\n" is_tuple(x) = begin
                Meta.isexpr(x, :tuple)
            end
    #= none:36 =# Core.@doc "    is_splat(ex)\n\nCheck if `ex` is a splat expression, i.e. `:(f(x)...)`\n" is_splat(x) = begin
                Meta.isexpr(x, :...)
            end
    #= none:43 =# Core.@doc "    is_gensym(s)\n\nCheck if `s` is generated by `gensym`.\n\n!!! note\n    Borrowed from [MacroTools](https://github.com/FluxML/MacroTools.jl).\n" is_gensym(s::Symbol) = begin
                occursin("#", string(s))
            end
    is_gensym(s) = begin
            false
        end
    #= none:54 =# Core.@doc "    support_default(f)\n\nCheck if field type `f` supports default value.\n" support_default(f) = begin
                false
            end
    support_default(f::JLKwField) = begin
            true
        end
    #= none:62 =# Core.@doc "    has_symbol(ex, name::Symbol)\n\nCheck if `ex` contains symbol `name`.\n" function has_symbol(#= none:67 =# @nospecialize(ex), name::Symbol)
            ex isa Symbol && return ex === name
            ex isa Expr || return false
            return any((x->begin
                            has_symbol(x, name)
                        end), ex.args)
        end
    #= none:73 =# Core.@doc "    has_kwfn_constructor(def[, name = struct_name_plain(def)])\n\nCheck if the struct definition contains keyword function constructor of `name`.\nThe constructor name to check by default is the plain constructor which does\nnot infer any type variables and requires user to input all type variables.\nSee also [`struct_name_plain`](@ref).\n" function has_kwfn_constructor(def, name = struct_name_plain(def))
            any(def.constructors) do fn::JLFunction
                isempty(fn.args) && fn.name == name
            end
        end
    #= none:87 =# Core.@doc "    has_plain_constructor(def, name = struct_name_plain(def))\n\nCheck if the struct definition contains the plain constructor of `name`.\nBy default the name is the inferable name [`struct_name_plain`](@ref).\n\n# Example\n\n```julia\ndef = @expr JLKwStruct struct Foo{T, N}\n    x::Int\n    y::N\n\n    Foo{T, N}(x, y) where {T, N} = new{T, N}(x, y)\nend\n\nhas_plain_constructor(def) # true\n\ndef = @expr JLKwStruct struct Foo{T, N}\n    x::T\n    y::N\n\n    Foo(x, y) = new{typeof(x), typeof(y)}(x, y)\nend\n\nhas_plain_constructor(def) # false\n```\n\nthe arguments must have no type annotations.\n\n```julia\ndef = @expr JLKwStruct struct Foo{T, N}\n    x::T\n    y::N\n\n    Foo{T, N}(x::T, y::N) where {T, N} = new{T, N}(x, y)\nend\n\nhas_plain_constructor(def) # false\n```\n" function has_plain_constructor(def, name = struct_name_plain(def))
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
    #= none:140 =# Core.@doc "    is_function(def)\n\nCheck if given object is a function expression.\n" function is_function(#= none:145 =# @nospecialize(def))
            let
                cache_1 = nothing
                return_2 = nothing
                x_2 = def
                if x_2 isa Expr
                    if begin
                                if cache_1 === nothing
                                    cache_1 = Some((x_2.head, x_2.args))
                                end
                                x_3 = cache_1.value
                                x_3 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_3[1] == :function && (begin
                                        x_4 = x_3[2]
                                        x_4 isa AbstractArray
                                    end && length(x_4) === 2))
                        return_2 = let
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#628_1")))
                    end
                    if begin
                                x_5 = cache_1.value
                                x_5 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_5[1] == :(=) && (begin
                                        x_6 = x_5[2]
                                        x_6 isa AbstractArray
                                    end && length(x_6) === 2))
                        return_2 = let
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#628_1")))
                    end
                    if begin
                                x_7 = cache_1.value
                                x_7 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_7[1] == :-> && (begin
                                        x_8 = x_7[2]
                                        x_8 isa AbstractArray
                                    end && length(x_8) === 2))
                        return_2 = let
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#628_1")))
                    end
                end
                if x_2 isa JLFunction
                    return_2 = let
                            true
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#628_1")))
                end
                return_2 = let
                        false
                    end
                $(Expr(:symbolicgoto, Symbol("##final#628_1")))
                (error)("matching non-exhaustive, at #= none:146 =#")
                $(Expr(:symboliclabel, Symbol("##final#628_1")))
                return_2
            end
        end
    #= none:155 =# Core.@doc "    is_kw_function(def)\n\nCheck if a given function definition supports keyword arguments.\n" function is_kw_function(#= none:160 =# @nospecialize(def))
            is_function(def) || return false
            if def isa JLFunction
                return def.kwargs !== nothing
            end
            (_, call, _) = split_function(def)
            let
                cache_2 = nothing
                return_3 = nothing
                x_9 = call
                if x_9 isa Expr
                    if begin
                                if cache_2 === nothing
                                    cache_2 = Some((x_9.head, x_9.args))
                                end
                                x_10 = cache_2.value
                                x_10 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_10[1] == :tuple && (begin
                                        x_11 = x_10[2]
                                        x_11 isa AbstractArray
                                    end && ((ndims(x_11) === 1 && length(x_11) >= 1) && (begin
                                                cache_3 = nothing
                                                x_12 = x_11[1]
                                                x_12 isa Expr
                                            end && (begin
                                                    if cache_3 === nothing
                                                        cache_3 = Some((x_12.head, x_12.args))
                                                    end
                                                    x_13 = cache_3.value
                                                    x_13 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                end && (x_13[1] == :parameters && (begin
                                                            x_14 = x_13[2]
                                                            x_14 isa AbstractArray
                                                        end && (ndims(x_14) === 1 && length(x_14) >= 0))))))))
                        return_3 = let
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#639_1")))
                    end
                    if begin
                                x_15 = cache_2.value
                                x_15 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_15[1] == :call && (begin
                                        x_16 = x_15[2]
                                        x_16 isa AbstractArray
                                    end && ((ndims(x_16) === 1 && length(x_16) >= 2) && (begin
                                                cache_4 = nothing
                                                x_17 = x_16[2]
                                                x_17 isa Expr
                                            end && (begin
                                                    if cache_4 === nothing
                                                        cache_4 = Some((x_17.head, x_17.args))
                                                    end
                                                    x_18 = cache_4.value
                                                    x_18 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                end && (x_18[1] == :parameters && (begin
                                                            x_19 = x_18[2]
                                                            x_19 isa AbstractArray
                                                        end && (ndims(x_19) === 1 && length(x_19) >= 0))))))))
                        return_3 = let
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#639_1")))
                    end
                    if begin
                                x_20 = cache_2.value
                                x_20 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_20[1] == :block && (begin
                                        x_21 = x_20[2]
                                        x_21 isa AbstractArray
                                    end && (length(x_21) === 3 && begin
                                            x_22 = x_21[2]
                                            x_22 isa LineNumberNode
                                        end)))
                        return_3 = let
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#639_1")))
                    end
                end
                return_3 = let
                        false
                    end
                $(Expr(:symbolicgoto, Symbol("##final#639_1")))
                (error)("matching non-exhaustive, at #= none:168 =#")
                $(Expr(:symboliclabel, Symbol("##final#639_1")))
                return_3
            end
        end
    #= none:176 =# @deprecate is_kw_fn(def) is_kw_function(def)
    #= none:177 =# @deprecate is_fn(def) is_function(def)
    #= none:179 =# Core.@doc "    is_struct(ex)\n\nCheck if `ex` is a struct expression.\n" function is_struct(#= none:184 =# @nospecialize(ex))
            ex isa Expr || return false
            return ex.head === :struct
        end
    #= none:189 =# Core.@doc "    is_struct_not_kw_struct(ex)\n\nCheck if `ex` is a struct expression excluding keyword struct syntax.\n" function is_struct_not_kw_struct(ex)
            is_struct(ex) || return false
            body = ex.args[3]
            body isa Expr && body.head === :block || return false
            any(is_field_default, body.args) && return false
            return true
        end
    #= none:202 =# Core.@doc "    is_ifelse(ex)\n\nCheck if `ex` is an `if ... elseif ... else ... end` expression.\n" function is_ifelse(#= none:207 =# @nospecialize(ex))
            ex isa Expr || return false
            return ex.head === :if
        end
    #= none:212 =# Core.@doc "    is_for(ex)\n\nCheck if `ex` is a `for` loop expression.\n" function is_for(#= none:217 =# @nospecialize(ex))
            ex isa Expr || return false
            return ex.head === :for
        end
    #= none:222 =# Core.@doc "    is_field(ex)\n\nCheck if `ex` is a valid field expression.\n" function is_field(#= none:227 =# @nospecialize(ex))
            let
                cache_5 = nothing
                return_4 = nothing
                x_23 = ex
                if x_23 isa Expr
                    if begin
                                if cache_5 === nothing
                                    cache_5 = Some((x_23.head, x_23.args))
                                end
                                x_24 = cache_5.value
                                x_24 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_24[1] == :(=) && (begin
                                        x_25 = x_24[2]
                                        x_25 isa AbstractArray
                                    end && (length(x_25) === 2 && (begin
                                                cache_6 = nothing
                                                x_26 = x_25[1]
                                                x_26 isa Expr
                                            end && (begin
                                                    if cache_6 === nothing
                                                        cache_6 = Some((x_26.head, x_26.args))
                                                    end
                                                    x_27 = cache_6.value
                                                    x_27 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                end && (x_27[1] == :(::) && (begin
                                                            x_28 = x_27[2]
                                                            x_28 isa AbstractArray
                                                        end && (length(x_28) === 2 && begin
                                                                x_29 = x_28[1]
                                                                x_30 = x_28[2]
                                                                x_31 = x_25[2]
                                                                true
                                                            end))))))))
                        return_4 = let default = x_31, type = x_30, name = x_29
                                false
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#659_1")))
                    end
                    if begin
                                x_32 = cache_5.value
                                x_32 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_32[1] == :(=) && (begin
                                        x_33 = x_32[2]
                                        x_33 isa AbstractArray
                                    end && (length(x_33) === 2 && (begin
                                                x_34 = x_33[1]
                                                x_34 isa Symbol
                                            end && begin
                                                x_35 = x_33[2]
                                                true
                                            end))))
                        return_4 = let default = x_35, name = x_34
                                false
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#659_1")))
                    end
                    if begin
                                x_36 = cache_5.value
                                x_36 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_36[1] == :(::) && (begin
                                        x_37 = x_36[2]
                                        x_37 isa AbstractArray
                                    end && (length(x_37) === 2 && begin
                                            x_38 = x_37[1]
                                            x_39 = x_37[2]
                                            true
                                        end)))
                        return_4 = let type = x_39, name = x_38
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#659_1")))
                    end
                end
                if x_23 isa Symbol
                    return_4 = let name = x_23
                            true
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#659_1")))
                end
                return_4 = let
                        false
                    end
                $(Expr(:symbolicgoto, Symbol("##final#659_1")))
                (error)("matching non-exhaustive, at #= none:228 =#")
                $(Expr(:symboliclabel, Symbol("##final#659_1")))
                return_4
            end
        end
    #= none:237 =# Core.@doc "    is_field_default(ex)\n\nCheck if `ex` is a `<field expr> = <default expr>` expression.\n" function is_field_default(#= none:242 =# @nospecialize(ex))
            let
                cache_7 = nothing
                return_5 = nothing
                x_40 = ex
                if x_40 isa Expr
                    if begin
                                if cache_7 === nothing
                                    cache_7 = Some((x_40.head, x_40.args))
                                end
                                x_41 = cache_7.value
                                x_41 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_41[1] == :(=) && (begin
                                        x_42 = x_41[2]
                                        x_42 isa AbstractArray
                                    end && (length(x_42) === 2 && (begin
                                                cache_8 = nothing
                                                x_43 = x_42[1]
                                                x_43 isa Expr
                                            end && (begin
                                                    if cache_8 === nothing
                                                        cache_8 = Some((x_43.head, x_43.args))
                                                    end
                                                    x_44 = cache_8.value
                                                    x_44 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                end && (x_44[1] == :(::) && (begin
                                                            x_45 = x_44[2]
                                                            x_45 isa AbstractArray
                                                        end && (length(x_45) === 2 && begin
                                                                x_46 = x_45[1]
                                                                x_47 = x_45[2]
                                                                x_48 = x_42[2]
                                                                true
                                                            end))))))))
                        return_5 = let default = x_48, type = x_47, name = x_46
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#681_1")))
                    end
                    if begin
                                x_49 = cache_7.value
                                x_49 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_49[1] == :(=) && (begin
                                        x_50 = x_49[2]
                                        x_50 isa AbstractArray
                                    end && (length(x_50) === 2 && (begin
                                                x_51 = x_50[1]
                                                x_51 isa Symbol
                                            end && begin
                                                x_52 = x_50[2]
                                                true
                                            end))))
                        return_5 = let default = x_52, name = x_51
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#681_1")))
                    end
                end
                return_5 = let
                        false
                    end
                $(Expr(:symbolicgoto, Symbol("##final#681_1")))
                (error)("matching non-exhaustive, at #= none:243 =#")
                $(Expr(:symboliclabel, Symbol("##final#681_1")))
                return_5
            end
        end
    #= none:250 =# Core.@doc "    is_datatype_expr(ex)\n\nCheck if `ex` is an expression for a concrete `DataType`, e.g\n`where` is not allowed in the expression.\n" function is_datatype_expr(#= none:256 =# @nospecialize(ex))
            let
                cache_9 = nothing
                return_6 = nothing
                x_53 = ex
                if x_53 isa GlobalRef
                    return_6 = let
                            true
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#699_1")))
                end
                if x_53 isa Expr
                    if begin
                                if cache_9 === nothing
                                    cache_9 = Some((x_53.head, x_53.args))
                                end
                                x_54 = cache_9.value
                                x_54 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_54[1] == :curly && (begin
                                        x_55 = x_54[2]
                                        x_55 isa AbstractArray
                                    end && (length(x_55) === 2 && (begin
                                                cache_10 = nothing
                                                x_56 = x_55[2]
                                                x_56 isa Expr
                                            end && (begin
                                                    if cache_10 === nothing
                                                        cache_10 = Some((x_56.head, x_56.args))
                                                    end
                                                    x_57 = cache_10.value
                                                    x_57 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                end && (x_57[1] == :... && (begin
                                                            x_58 = x_57[2]
                                                            x_58 isa AbstractArray
                                                        end && length(x_58) === 1)))))))
                        return_6 = let
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#699_1")))
                    end
                    if begin
                                x_59 = cache_9.value
                                x_59 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_59[1] == :. && (begin
                                        x_60 = x_59[2]
                                        x_60 isa AbstractArray
                                    end && (length(x_60) === 2 && (begin
                                                x_61 = x_60[2]
                                                x_61 isa QuoteNode
                                            end && begin
                                                x_62 = x_61.value
                                                true
                                            end))))
                        return_6 = let b = x_62
                                is_datatype_expr(b)
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#699_1")))
                    end
                    if begin
                                x_63 = cache_9.value
                                x_63 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_63[1] == :curly && (begin
                                        x_64 = x_63[2]
                                        x_64 isa AbstractArray
                                    end && ((ndims(x_64) === 1 && length(x_64) >= 0) && begin
                                            x_65 = (SubArray)(x_64, (1:length(x_64),))
                                            true
                                        end)))
                        return_6 = let args = x_65
                                all(is_datatype_expr, args)
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#699_1")))
                    end
                end
                if x_53 isa Symbol
                    return_6 = let
                            true
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#699_1")))
                end
                return_6 = let
                        false
                    end
                $(Expr(:symbolicgoto, Symbol("##final#699_1")))
                (error)("matching non-exhaustive, at #= none:257 =#")
                $(Expr(:symboliclabel, Symbol("##final#699_1")))
                return_6
            end
        end
    #= none:267 =# Core.@doc "    is_matrix_expr(ex)\n\nCheck if `ex` is an expression for a `Matrix`.\n" function is_matrix_expr(#= none:272 =# @nospecialize(ex))
            Meta.isexpr(ex, :hcat) && return true
            if Meta.isexpr(ex, :typed_vcat)
                args = ex.args[2:end]
            elseif Meta.isexpr(ex, :vcat)
                args = ex.args
            else
                return false
            end
            for row = args
                Meta.isexpr(row, :row) || return false
            end
            return true
        end
end