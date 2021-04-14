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
            error("unsupported expression $(ex)")
        end
    #= none:85 =# Core.@doc "    rm_lineinfo(ex)\n\nRemove `LineNumberNode` in a given expression.\n\n!!! tips\n\n    the `LineNumberNode` inside macro calls won't be removed since\n    the `macrocall` expression requires a `LineNumberNode`. See also\n    [issues/#9](https://github.com/Roger-luo/Expronicon.jl/issues/9).\n" function rm_lineinfo(ex)
            let
                var"##cache#691" = nothing
                var"##return#688" = nothing
                var"##690" = ex
                if var"##690" isa Expr
                    if begin
                                if var"##cache#691" === nothing
                                    var"##cache#691" = Some(((var"##690").head, (var"##690").args))
                                end
                                var"##692" = (var"##cache#691").value
                                var"##692" isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (var"##692"[1] == :macrocall && (begin
                                        var"##693" = var"##692"[2]
                                        var"##693" isa AbstractArray
                                    end && ((ndims(var"##693") === 1 && length(var"##693") >= 2) && begin
                                            var"##694" = var"##693"[1]
                                            var"##695" = var"##693"[2]
                                            var"##696" = (SubArray)(var"##693", (3:length(var"##693"),))
                                            true
                                        end)))
                        var"##return#688" = let line = var"##695", name = var"##694", args = var"##696"
                                Expr(:macrocall, name, line, map(rm_lineinfo, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#689#701")))
                    end
                    if begin
                                var"##697" = (var"##cache#691").value
                                var"##697" isa Tuple{var1, var2} where {var2<:AbstractArray, var1}
                            end && (begin
                                    var"##698" = var"##697"[1]
                                    var"##699" = var"##697"[2]
                                    var"##699" isa AbstractArray
                                end && ((ndims(var"##699") === 1 && length(var"##699") >= 0) && begin
                                        var"##700" = (SubArray)(var"##699", (1:length(var"##699"),))
                                        true
                                    end))
                        var"##return#688" = let args = var"##700", head = var"##698"
                                Expr(head, map(rm_lineinfo, filter((x->begin
                                                    !(x isa LineNumberNode)
                                                end), args))...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#689#701")))
                    end
                end
                var"##return#688" = let
                        ex
                    end
                $(Expr(:symbolicgoto, Symbol("####final#689#701")))
                (error)("matching non-exhaustive, at #= none:97 =#")
                $(Expr(:symboliclabel, Symbol("####final#689#701")))
                var"##return#688"
            end
        end
    #= none:104 =# Core.@doc "    prettify(ex)\n\nPrettify given expression, remove all `LineNumberNode` and\nextra code blocks.\n\n!!! tips\n\n    the `LineNumberNode` inside macro calls won't be removed since\n    the `macrocall` expression requires a `LineNumberNode`. See also\n    [issues/#9](https://github.com/Roger-luo/Expronicon.jl/issues/9).\n" function prettify(ex)
            ex isa Expr || return ex
            for _ = 1:10
                curr = prettify_pass(ex)
                ex == curr && break
                ex = curr
            end
            return ex
        end
    function prettify_pass(ex)
        ex = rm_lineinfo(ex)
        ex = flatten_blocks(ex)
        ex = rm_nothing(ex)
        ex = rm_single_block(ex)
        return ex
    end
    #= none:134 =# Core.@doc "    flatten_blocks(ex)\n\nRemove hierachical expression blocks.\n" function flatten_blocks(ex)
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
    #= none:169 =# Core.@doc "    rm_nothing(ex)\n\nRemove the constant value `nothing` in given expression `ex`.\n" function rm_nothing(ex)
            let
                var"##cache#705" = nothing
                var"##return#702" = nothing
                var"##704" = ex
                if var"##704" isa Expr
                    if begin
                                if var"##cache#705" === nothing
                                    var"##cache#705" = Some(((var"##704").head, (var"##704").args))
                                end
                                var"##706" = (var"##cache#705").value
                                var"##706" isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (var"##706"[1] == :block && (begin
                                        var"##707" = var"##706"[2]
                                        var"##707" isa AbstractArray
                                    end && ((ndims(var"##707") === 1 && length(var"##707") >= 0) && begin
                                            var"##708" = (SubArray)(var"##707", (1:length(var"##707"),))
                                            true
                                        end)))
                        var"##return#702" = let args = var"##708"
                                Expr(:block, filter((x->begin
                                                x !== nothing
                                            end), args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#703#713")))
                    end
                    if begin
                                var"##709" = (var"##cache#705").value
                                var"##709" isa Tuple{var1, var2} where {var2<:AbstractArray, var1}
                            end && (begin
                                    var"##710" = var"##709"[1]
                                    var"##711" = var"##709"[2]
                                    var"##711" isa AbstractArray
                                end && ((ndims(var"##711") === 1 && length(var"##711") >= 0) && begin
                                        var"##712" = (SubArray)(var"##711", (1:length(var"##711"),))
                                        true
                                    end))
                        var"##return#702" = let args = var"##712", head = var"##710"
                                Expr(head, map(rm_nothing, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#703#713")))
                    end
                end
                var"##return#702" = let
                        ex
                    end
                $(Expr(:symbolicgoto, Symbol("####final#703#713")))
                (error)("matching non-exhaustive, at #= none:175 =#")
                $(Expr(:symboliclabel, Symbol("####final#703#713")))
                var"##return#702"
            end
        end
    function rm_single_block(ex)
        let
            var"##cache#717" = nothing
            var"##return#714" = nothing
            var"##716" = ex
            if var"##716" isa Expr
                if begin
                            if var"##cache#717" === nothing
                                var"##cache#717" = Some(((var"##716").head, (var"##716").args))
                            end
                            var"##718" = (var"##cache#717").value
                            var"##718" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##718"[1] == :(=) && (begin
                                    var"##719" = var"##718"[2]
                                    var"##719" isa AbstractArray
                                end && (ndims(var"##719") === 1 && length(var"##719") >= 0)))
                    var"##return#714" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#715#739")))
                end
                if begin
                            var"##720" = (var"##cache#717").value
                            var"##720" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##720"[1] == :-> && (begin
                                    var"##721" = var"##720"[2]
                                    var"##721" isa AbstractArray
                                end && (ndims(var"##721") === 1 && length(var"##721") >= 0)))
                    var"##return#714" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#715#739")))
                end
                if begin
                            var"##722" = (var"##cache#717").value
                            var"##722" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##722"[1] == :block && (begin
                                    var"##723" = var"##722"[2]
                                    var"##723" isa AbstractArray
                                end && (length(var"##723") === 1 && (begin
                                            var"##cache#725" = nothing
                                            var"##724" = var"##723"[1]
                                            var"##724" isa Expr
                                        end && (begin
                                                if var"##cache#725" === nothing
                                                    var"##cache#725" = Some(((var"##724").head, (var"##724").args))
                                                end
                                                var"##726" = (var"##cache#725").value
                                                var"##726" isa Tuple{Symbol, var2} where var2<:AbstractArray
                                            end && (var"##726"[1] == :quote && (begin
                                                        var"##727" = var"##726"[2]
                                                        var"##727" isa AbstractArray
                                                    end && ((ndims(var"##727") === 1 && length(var"##727") >= 0) && begin
                                                            var"##728" = (SubArray)(var"##727", (1:length(var"##727"),))
                                                            true
                                                        end))))))))
                    var"##return#714" = let xs = var"##728"
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#715#739")))
                end
                if begin
                            var"##729" = (var"##cache#717").value
                            var"##729" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##729"[1] == :quote && (begin
                                    var"##730" = var"##729"[2]
                                    var"##730" isa AbstractArray
                                end && ((ndims(var"##730") === 1 && length(var"##730") >= 0) && begin
                                        var"##731" = (SubArray)(var"##730", (1:length(var"##730"),))
                                        true
                                    end)))
                    var"##return#714" = let xs = var"##731"
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#715#739")))
                end
                if begin
                            var"##732" = (var"##cache#717").value
                            var"##732" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##732"[1] == :block && (begin
                                    var"##733" = var"##732"[2]
                                    var"##733" isa AbstractArray
                                end && (length(var"##733") === 1 && begin
                                        var"##734" = var"##733"[1]
                                        true
                                    end)))
                    var"##return#714" = let stmt = var"##734"
                            stmt
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#715#739")))
                end
                if begin
                            var"##735" = (var"##cache#717").value
                            var"##735" isa Tuple{var1, var2} where {var2<:AbstractArray, var1}
                        end && (begin
                                var"##736" = var"##735"[1]
                                var"##737" = var"##735"[2]
                                var"##737" isa AbstractArray
                            end && ((ndims(var"##737") === 1 && length(var"##737") >= 0) && begin
                                    var"##738" = (SubArray)(var"##737", (1:length(var"##737"),))
                                    true
                                end))
                    var"##return#714" = let args = var"##738", head = var"##736"
                            Expr(head, map(rm_single_block, args)...)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#715#739")))
                end
            end
            var"##return#714" = let
                    ex
                end
            $(Expr(:symbolicgoto, Symbol("####final#715#739")))
            (error)("matching non-exhaustive, at #= none:183 =#")
            $(Expr(:symboliclabel, Symbol("####final#715#739")))
            var"##return#714"
        end
    end
    #= none:193 =# Core.@doc "    rm_annotations(x)\n\nRemove type annotation of given expression.\n" function rm_annotations(x)
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
end
