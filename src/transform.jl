begin
    #= none:2 =# Core.@doc "    eval_interp(m::Module, ex)\n\nevaluate the interpolation operator in `ex` inside given module `m`.\n" function eval_interp(m::Module, ex)
            ex isa Expr || return ex
            if ex.head === :$
                x = ex.args[1]
                if x isa Symbol && isdefined(m, x)
                    return Base.eval(m, x)
                else
                    return ex
                end
            end
            return Expr(ex.head, map((x->begin
                                eval_interp(m, x)
                            end), ex.args)...)
        end
    #= none:20 =# Core.@doc "    eval_literal(m::Module, ex)\n\nEvaluate the literal values and insert them back to the expression.\nThe literal value can be checked via [`is_literal`](@ref).\n" function eval_literal(m::Module, ex)
            ex isa Expr || return ex
            if ex.head === :call && all(is_literal, ex.args[2:end])
                return Base.eval(m, ex)
            end
            return Expr(ex.head, map((x->begin
                                eval_literal(m, x)
                            end), ex.args)...)
        end
    replace_symbol(x::Symbol, name::Symbol, value) = begin
            if x === name
                value
            else
                x
            end
        end
    replace_symbol(x, ::Symbol, value) = begin
            x
        end
    function replace_symbol(ex::Expr, name::Symbol, value)
        Expr(ex.head, map((x->begin
                        replace_symbol(x, name, value)
                    end), ex.args)...)
    end
    #= none:41 =# Core.@doc "    subtitute(ex::Expr, old=>new)\n\nSubtitute the old symbol `old` with `new`.\n" function subtitute(ex::Expr, replace::Pair)
            (name, value) = replace
            return replace_symbol(ex, name, value)
        end
    #= none:51 =# Core.@doc "    name_only(ex)\n\nRemove everything else leaving just names, currently supports\nfunction calls, type with type variables, subtype operator `<:`\nand type annotation `::`.\n\n# Example\n\n```julia\njulia> using Expronicon\n\njulia> name_only(:(sin(2)))\n:sin\n\njulia> name_only(:(Foo{Int}))\n:Foo\n\njulia> name_only(:(Foo{Int} <: Real))\n:Foo\n\njulia> name_only(:(x::Int))\n:x\n```\n" function name_only(#= none:76 =# @nospecialize(ex))
            ex isa Symbol && return ex
            ex isa QuoteNode && return ex.value
            ex isa Expr || error("unsupported expression $(ex)")
            ex.head in [:call, :curly, :<:, :(::), :where, :function, :kw, :(=), :->] && return name_only(ex.args[1])
            ex.head === :. && return name_only(ex.args[2])
            ex.head === :module && return name_only(ex.args[2])
            error("unsupported expression $(ex)")
        end
    #= none:86 =# Core.@doc "    rm_lineinfo(ex)\n\nRemove `LineNumberNode` in a given expression.\n\n!!! tips\n\n    the `LineNumberNode` inside macro calls won't be removed since\n    the `macrocall` expression requires a `LineNumberNode`. See also\n    [issues/#9](https://github.com/Roger-luo/Expronicon.jl/issues/9).\n" function rm_lineinfo(ex)
            let
                cache_1 = nothing
                return_1 = nothing
                x_1 = ex
                if x_1 isa Expr
                    if begin
                                if cache_1 === nothing
                                    cache_1 = Some((x_1.head, x_1.args))
                                end
                                x_2 = cache_1.value
                                x_2 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_2[1] == :macrocall && (begin
                                        x_3 = x_2[2]
                                        x_3 isa AbstractArray
                                    end && ((ndims(x_3) === 1 && length(x_3) >= 2) && begin
                                            x_4 = x_3[1]
                                            x_5 = x_3[2]
                                            x_6 = (SubArray)(x_3, (3:length(x_3),))
                                            true
                                        end)))
                        return_1 = let line = x_5, name = x_4, args = x_6
                                Expr(:macrocall, name, line, map(rm_lineinfo, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#768_1")))
                    end
                    if begin
                                x_7 = cache_1.value
                                x_7 isa Tuple{var1, var2} where {var2<:AbstractArray, var1}
                            end && (begin
                                    x_8 = x_7[1]
                                    x_9 = x_7[2]
                                    x_9 isa AbstractArray
                                end && ((ndims(x_9) === 1 && length(x_9) >= 0) && begin
                                        x_10 = (SubArray)(x_9, (1:length(x_9),))
                                        true
                                    end))
                        return_1 = let args = x_10, head = x_8
                                Expr(head, map(rm_lineinfo, filter((x->begin
                                                    !(x isa LineNumberNode)
                                                end), args))...)
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#768_1")))
                    end
                end
                return_1 = let
                        ex
                    end
                $(Expr(:symbolicgoto, Symbol("##final#768_1")))
                (error)("matching non-exhaustive, at #= none:98 =#")
                $(Expr(:symboliclabel, Symbol("##final#768_1")))
                return_1
            end
        end
    #= none:105 =# Base.@kwdef struct PrettifyOptions
            rm_lineinfo::Bool = true
            flatten_blocks::Bool = true
            rm_nothing::Bool = true
            rm_single_block::Bool = true
            alias_gensym::Bool = true
        end
    #= none:113 =# Core.@doc "    prettify(ex; kw...)\n\nPrettify given expression, remove all `LineNumberNode` and\nextra code blocks.\n\n# Options (Kwargs)\n\nAll the options are `true` by default.\n\n- `rm_lineinfo`: remove `LineNumberNode`.\n- `flatten_blocks`: flatten `begin ... end` code blocks.\n- `rm_nothing`: remove `nothing` in the `begin ... end`.\n- `rm_single_block`: remove single `begin ... end`.\n- `alias_gensym`: replace `##<name>#<num>` with `<name>_<id>`.\n\n!!! tips\n\n    the `LineNumberNode` inside macro calls won't be removed since\n    the `macrocall` expression requires a `LineNumberNode`. See also\n    [issues/#9](https://github.com/Roger-luo/Expronicon.jl/issues/9).\n" function prettify(ex; kw...)
            prettify(ex, PrettifyOptions(; kw...))
        end
    function prettify(ex, options::PrettifyOptions)
        ex isa Expr || return ex
        ex = if options.alias_gensym
                alias_gensym(ex)
            else
                ex
            end
        for _ = 1:10
            curr = prettify_pass(ex, options)
            ex == curr && break
            ex = curr
        end
        return ex
    end
    function prettify_pass(ex, options::PrettifyOptions)
        ex = if options.rm_lineinfo
                rm_lineinfo(ex)
            else
                ex
            end
        ex = if options.flatten_blocks
                flatten_blocks(ex)
            else
                ex
            end
        ex = if options.rm_nothing
                rm_nothing(ex)
            else
                ex
            end
        ex = if options.rm_single_block
                rm_single_block(ex)
            else
                ex
            end
        return ex
    end
    #= none:158 =# Core.@doc "    flatten_blocks(ex)\n\nRemove hierachical expression blocks.\n" function flatten_blocks(ex)
            ex isa Expr || return ex
            ex.head === :block || return Expr(ex.head, map(_flatten_blocks, ex.args)...)
            has_block = any(ex.args) do x
                    x isa Expr && x.head === :block
                end
            if has_block
                return flatten_blocks(_flatten_blocks(ex))
            end
            return Expr(ex.head, map(flatten_blocks, ex.args)...)
        end
    function _flatten_blocks(ex)
        ex isa Expr || return ex
        ex.head === :block || return Expr(ex.head, map(flatten_blocks, ex.args)...)
        args = []
        for stmt = ex.args
            if stmt isa Expr && stmt.head === :block
                for each = stmt.args
                    push!(args, flatten_blocks(each))
                end
            else
                push!(args, flatten_blocks(stmt))
            end
        end
        return Expr(:block, args...)
    end
    #= none:193 =# Core.@doc "    rm_nothing(ex)\n\nRemove the constant value `nothing` in given expression `ex`.\n" function rm_nothing(ex)
            let
                cache_2 = nothing
                return_2 = nothing
                x_11 = ex
                if x_11 isa Expr
                    if begin
                                if cache_2 === nothing
                                    cache_2 = Some((x_11.head, x_11.args))
                                end
                                x_12 = cache_2.value
                                x_12 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_12[1] == :block && (begin
                                        x_13 = x_12[2]
                                        x_13 isa AbstractArray
                                    end && ((ndims(x_13) === 1 && length(x_13) >= 0) && begin
                                            x_14 = (SubArray)(x_13, (1:length(x_13),))
                                            true
                                        end)))
                        return_2 = let args = x_14
                                Expr(:block, filter((x->begin
                                                x !== nothing
                                            end), args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#782_1")))
                    end
                    if begin
                                x_15 = cache_2.value
                                x_15 isa Tuple{var1, var2} where {var2<:AbstractArray, var1}
                            end && (begin
                                    x_16 = x_15[1]
                                    x_17 = x_15[2]
                                    x_17 isa AbstractArray
                                end && ((ndims(x_17) === 1 && length(x_17) >= 0) && begin
                                        x_18 = (SubArray)(x_17, (1:length(x_17),))
                                        true
                                    end))
                        return_2 = let args = x_18, head = x_16
                                Expr(head, map(rm_nothing, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#782_1")))
                    end
                end
                return_2 = let
                        ex
                    end
                $(Expr(:symbolicgoto, Symbol("##final#782_1")))
                (error)("matching non-exhaustive, at #= none:199 =#")
                $(Expr(:symboliclabel, Symbol("##final#782_1")))
                return_2
            end
        end
    function rm_single_block(ex)
        let
            cache_3 = nothing
            return_3 = nothing
            x_19 = ex
            if x_19 isa Expr
                if begin
                            if cache_3 === nothing
                                cache_3 = Some((x_19.head, x_19.args))
                            end
                            x_20 = cache_3.value
                            x_20 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_20[1] == :(=) && (begin
                                    x_21 = x_20[2]
                                    x_21 isa AbstractArray
                                end && (ndims(x_21) === 1 && length(x_21) >= 0)))
                    return_3 = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#794_1")))
                end
                if begin
                            x_22 = cache_3.value
                            x_22 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_22[1] == :-> && (begin
                                    x_23 = x_22[2]
                                    x_23 isa AbstractArray
                                end && (ndims(x_23) === 1 && length(x_23) >= 0)))
                    return_3 = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#794_1")))
                end
                if begin
                            x_24 = cache_3.value
                            x_24 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_24[1] == :quote && (begin
                                    x_25 = x_24[2]
                                    x_25 isa AbstractArray
                                end && ((ndims(x_25) === 1 && length(x_25) >= 0) && begin
                                        x_26 = (SubArray)(x_25, (1:length(x_25),))
                                        true
                                    end)))
                    return_3 = let xs = x_26
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#794_1")))
                end
                if begin
                            x_27 = cache_3.value
                            x_27 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_27[1] == :block && (begin
                                    x_28 = x_27[2]
                                    x_28 isa AbstractArray
                                end && (length(x_28) === 1 && (begin
                                            cache_4 = nothing
                                            x_29 = x_28[1]
                                            x_29 isa Expr
                                        end && (begin
                                                if cache_4 === nothing
                                                    cache_4 = Some((x_29.head, x_29.args))
                                                end
                                                x_30 = cache_4.value
                                                x_30 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                            end && (x_30[1] == :quote && (begin
                                                        x_31 = x_30[2]
                                                        x_31 isa AbstractArray
                                                    end && ((ndims(x_31) === 1 && length(x_31) >= 0) && begin
                                                            x_32 = (SubArray)(x_31, (1:length(x_31),))
                                                            true
                                                        end))))))))
                    return_3 = let xs = x_32
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#794_1")))
                end
                if begin
                            x_33 = cache_3.value
                            x_33 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_33[1] == :try && (begin
                                    x_34 = x_33[2]
                                    x_34 isa AbstractArray
                                end && (length(x_34) === 4 && (begin
                                            cache_5 = nothing
                                            x_35 = x_34[1]
                                            x_35 isa Expr
                                        end && (begin
                                                if cache_5 === nothing
                                                    cache_5 = Some((x_35.head, x_35.args))
                                                end
                                                x_36 = cache_5.value
                                                x_36 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                            end && (x_36[1] == :block && (begin
                                                        x_37 = x_36[2]
                                                        x_37 isa AbstractArray
                                                    end && ((ndims(x_37) === 1 && length(x_37) >= 0) && (begin
                                                                x_38 = (SubArray)(x_37, (1:length(x_37),))
                                                                x_34[2] === false
                                                            end && (x_34[3] === false && (begin
                                                                        cache_6 = nothing
                                                                        x_39 = x_34[4]
                                                                        x_39 isa Expr
                                                                    end && (begin
                                                                            if cache_6 === nothing
                                                                                cache_6 = Some((x_39.head, x_39.args))
                                                                            end
                                                                            x_40 = cache_6.value
                                                                            x_40 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                                        end && (x_40[1] == :block && (begin
                                                                                    x_41 = x_40[2]
                                                                                    x_41 isa AbstractArray
                                                                                end && ((ndims(x_41) === 1 && length(x_41) >= 0) && begin
                                                                                        x_42 = (SubArray)(x_41, (1:length(x_41),))
                                                                                        true
                                                                                    end)))))))))))))))
                    return_3 = let try_stmts = x_38, finally_stmts = x_42
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), false, false, Expr(:block, rm_single_block.(finally_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#794_1")))
                end
                if begin
                            x_43 = cache_3.value
                            x_43 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_43[1] == :try && (begin
                                    x_44 = x_43[2]
                                    x_44 isa AbstractArray
                                end && (length(x_44) === 3 && (begin
                                            cache_7 = nothing
                                            x_45 = x_44[1]
                                            x_45 isa Expr
                                        end && (begin
                                                if cache_7 === nothing
                                                    cache_7 = Some((x_45.head, x_45.args))
                                                end
                                                x_46 = cache_7.value
                                                x_46 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                            end && (x_46[1] == :block && (begin
                                                        x_47 = x_46[2]
                                                        x_47 isa AbstractArray
                                                    end && ((ndims(x_47) === 1 && length(x_47) >= 0) && (begin
                                                                x_48 = (SubArray)(x_47, (1:length(x_47),))
                                                                x_49 = x_44[2]
                                                                cache_8 = nothing
                                                                x_50 = x_44[3]
                                                                x_50 isa Expr
                                                            end && (begin
                                                                    if cache_8 === nothing
                                                                        cache_8 = Some((x_50.head, x_50.args))
                                                                    end
                                                                    x_51 = cache_8.value
                                                                    x_51 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                                end && (x_51[1] == :block && (begin
                                                                            x_52 = x_51[2]
                                                                            x_52 isa AbstractArray
                                                                        end && ((ndims(x_52) === 1 && length(x_52) >= 0) && begin
                                                                                x_53 = (SubArray)(x_52, (1:length(x_52),))
                                                                                true
                                                                            end)))))))))))))
                    return_3 = let try_stmts = x_48, catch_stmts = x_53, catch_var = x_49
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), catch_var, Expr(:block, rm_single_block.(catch_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#794_1")))
                end
                if begin
                            x_54 = cache_3.value
                            x_54 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_54[1] == :try && (begin
                                    x_55 = x_54[2]
                                    x_55 isa AbstractArray
                                end && (length(x_55) === 4 && (begin
                                            cache_9 = nothing
                                            x_56 = x_55[1]
                                            x_56 isa Expr
                                        end && (begin
                                                if cache_9 === nothing
                                                    cache_9 = Some((x_56.head, x_56.args))
                                                end
                                                x_57 = cache_9.value
                                                x_57 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                            end && (x_57[1] == :block && (begin
                                                        x_58 = x_57[2]
                                                        x_58 isa AbstractArray
                                                    end && ((ndims(x_58) === 1 && length(x_58) >= 0) && (begin
                                                                x_59 = (SubArray)(x_58, (1:length(x_58),))
                                                                x_60 = x_55[2]
                                                                cache_10 = nothing
                                                                x_61 = x_55[3]
                                                                x_61 isa Expr
                                                            end && (begin
                                                                    if cache_10 === nothing
                                                                        cache_10 = Some((x_61.head, x_61.args))
                                                                    end
                                                                    x_62 = cache_10.value
                                                                    x_62 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                                end && (x_62[1] == :block && (begin
                                                                            x_63 = x_62[2]
                                                                            x_63 isa AbstractArray
                                                                        end && ((ndims(x_63) === 1 && length(x_63) >= 0) && (begin
                                                                                    x_64 = (SubArray)(x_63, (1:length(x_63),))
                                                                                    cache_11 = nothing
                                                                                    x_65 = x_55[4]
                                                                                    x_65 isa Expr
                                                                                end && (begin
                                                                                        if cache_11 === nothing
                                                                                            cache_11 = Some((x_65.head, x_65.args))
                                                                                        end
                                                                                        x_66 = cache_11.value
                                                                                        x_66 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                                                    end && (x_66[1] == :block && (begin
                                                                                                x_67 = x_66[2]
                                                                                                x_67 isa AbstractArray
                                                                                            end && ((ndims(x_67) === 1 && length(x_67) >= 0) && begin
                                                                                                    x_68 = (SubArray)(x_67, (1:length(x_67),))
                                                                                                    true
                                                                                                end))))))))))))))))))
                    return_3 = let try_stmts = x_59, catch_stmts = x_64, catch_var = x_60, finally_stmts = x_68
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), catch_var, Expr(:block, rm_single_block.(catch_stmts)...), Expr(:block, rm_single_block.(finally_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#794_1")))
                end
                if begin
                            x_69 = cache_3.value
                            x_69 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_69[1] == :block && (begin
                                    x_70 = x_69[2]
                                    x_70 isa AbstractArray
                                end && (length(x_70) === 1 && begin
                                        x_71 = x_70[1]
                                        true
                                    end)))
                    return_3 = let stmt = x_71
                            stmt
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#794_1")))
                end
                if begin
                            x_72 = cache_3.value
                            x_72 isa Tuple{var1, var2} where {var2<:AbstractArray, var1}
                        end && (begin
                                x_73 = x_72[1]
                                x_74 = x_72[2]
                                x_74 isa AbstractArray
                            end && ((ndims(x_74) === 1 && length(x_74) >= 0) && begin
                                    x_75 = (SubArray)(x_74, (1:length(x_74),))
                                    true
                                end))
                    return_3 = let args = x_75, head = x_73
                            Expr(head, map(rm_single_block, args)...)
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#794_1")))
                end
            end
            return_3 = let
                    ex
                end
            $(Expr(:symbolicgoto, Symbol("##final#794_1")))
            (error)("matching non-exhaustive, at #= none:207 =#")
            $(Expr(:symboliclabel, Symbol("##final#794_1")))
            return_3
        end
    end
    #= none:235 =# Core.@doc "    rm_annotations(x)\n\nRemove type annotation of given expression.\n" function rm_annotations(x)
            x isa Expr || return x
            if x.head == :(::)
                if length(x.args) == 1
                    return gensym("::$(x.args[1])")
                else
                    return x.args[1]
                end
            elseif x.head in [:(=), :kw]
                return rm_annotations(x.args[1])
            else
                return Expr(x.head, map(rm_annotations, x.args)...)
            end
        end
    #= none:255 =# Core.@doc "    alias_gensym(ex)\n\nReplace gensym with `<name>_<id>`.\n\n!!! note\n    Borrowed from [MacroTools](https://github.com/FluxML/MacroTools.jl).\n" alias_gensym(ex) = begin
                alias_gensym!(Dict{Symbol, Symbol}(), Dict{Symbol, Int}(), ex)
            end
    function alias_gensym!(d::Dict{Symbol, Symbol}, count::Dict{Symbol, Int}, ex)
        if is_gensym(ex)
            haskey(d, ex) && return d[ex]
            name = Symbol(gensym_name(ex))
            id = get(count, name, 0) + 1
            d[ex] = Symbol(name, :_, id)
            count[name] = id
            return d[ex]
        end
        ex isa Expr || return ex
        args = map(ex.args) do x
                alias_gensym!(d, count, x)
            end
        return Expr(ex.head, args...)
    end
end
