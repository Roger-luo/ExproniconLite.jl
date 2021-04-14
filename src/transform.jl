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
                ##cache#805 = nothing
                ##return#802 = nothing
                ##804 = ex
                if ##804 isa Expr
                    if begin
                                if ##cache#805 === nothing
                                    ##cache#805 = Some(((##804).head, (##804).args))
                                end
                                ##806 = (##cache#805).value
                                ##806 isa Tuple{Symbol,var2} where var2<:AbstractArray
                            end && (##806[1] == :macrocall && (begin
                                        ##807 = ##806[2]
                                        ##807 isa AbstractArray
                                    end && ((ndims(##807) === 1 && length(##807) >= 2) && begin
                                            ##808 = ##807[1]
                                            ##809 = ##807[2]
                                            ##810 = (SubArray)(##807, (3:length(##807),))
                                            true
                                        end)))
                        ##return#802 = let line = ##809, name = ##808, args = ##810
                                Expr(:macrocall, name, line, map(rm_lineinfo, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#803#815")))
                    end
                    if begin
                                ##811 = (##cache#805).value
                                ##811 isa Tuple{var1,var2} where var1 where var2<:AbstractArray
                            end && (begin
                                    ##812 = ##811[1]
                                    ##813 = ##811[2]
                                    ##813 isa AbstractArray
                                end && ((ndims(##813) === 1 && length(##813) >= 0) && begin
                                        ##814 = (SubArray)(##813, (1:length(##813),))
                                        true
                                    end))
                        ##return#802 = let args = ##814, head = ##812
                                Expr(head, map(rm_lineinfo, filter((x->begin
                                                    !(x isa LineNumberNode)
                                                end), args))...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#803#815")))
                    end
                end
                ##return#802 = let
                        ex
                    end
                $(Expr(:symbolicgoto, Symbol("####final#803#815")))
                (error)("matching non-exhaustive, at #= none:97 =#")
                $(Expr(:symboliclabel, Symbol("####final#803#815")))
                ##return#802
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
                ##cache#819 = nothing
                ##return#816 = nothing
                ##818 = ex
                if ##818 isa Expr
                    if begin
                                if ##cache#819 === nothing
                                    ##cache#819 = Some(((##818).head, (##818).args))
                                end
                                ##820 = (##cache#819).value
                                ##820 isa Tuple{Symbol,var2} where var2<:AbstractArray
                            end && (##820[1] == :block && (begin
                                        ##821 = ##820[2]
                                        ##821 isa AbstractArray
                                    end && ((ndims(##821) === 1 && length(##821) >= 0) && begin
                                            ##822 = (SubArray)(##821, (1:length(##821),))
                                            true
                                        end)))
                        ##return#816 = let args = ##822
                                Expr(:block, filter((x->begin
                                                x !== nothing
                                            end), args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#817#827")))
                    end
                    if begin
                                ##823 = (##cache#819).value
                                ##823 isa Tuple{var1,var2} where var1 where var2<:AbstractArray
                            end && (begin
                                    ##824 = ##823[1]
                                    ##825 = ##823[2]
                                    ##825 isa AbstractArray
                                end && ((ndims(##825) === 1 && length(##825) >= 0) && begin
                                        ##826 = (SubArray)(##825, (1:length(##825),))
                                        true
                                    end))
                        ##return#816 = let args = ##826, head = ##824
                                Expr(head, map(rm_nothing, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#817#827")))
                    end
                end
                ##return#816 = let
                        ex
                    end
                $(Expr(:symbolicgoto, Symbol("####final#817#827")))
                (error)("matching non-exhaustive, at #= none:175 =#")
                $(Expr(:symboliclabel, Symbol("####final#817#827")))
                ##return#816
            end
        end
    function rm_single_block(ex)
        let
            ##cache#831 = nothing
            ##return#828 = nothing
            ##830 = ex
            if ##830 isa Expr
                if begin
                            if ##cache#831 === nothing
                                ##cache#831 = Some(((##830).head, (##830).args))
                            end
                            ##832 = (##cache#831).value
                            ##832 isa Tuple{Symbol,var2} where var2<:AbstractArray
                        end && (##832[1] == :(=) && (begin
                                    ##833 = ##832[2]
                                    ##833 isa AbstractArray
                                end && (ndims(##833) === 1 && length(##833) >= 0)))
                    ##return#828 = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#829#853")))
                end
                if begin
                            ##834 = (##cache#831).value
                            ##834 isa Tuple{Symbol,var2} where var2<:AbstractArray
                        end && (##834[1] == :-> && (begin
                                    ##835 = ##834[2]
                                    ##835 isa AbstractArray
                                end && (ndims(##835) === 1 && length(##835) >= 0)))
                    ##return#828 = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#829#853")))
                end
                if begin
                            ##836 = (##cache#831).value
                            ##836 isa Tuple{Symbol,var2} where var2<:AbstractArray
                        end && (##836[1] == :block && (begin
                                    ##837 = ##836[2]
                                    ##837 isa AbstractArray
                                end && (length(##837) === 1 && (begin
                                            ##cache#839 = nothing
                                            ##838 = ##837[1]
                                            ##838 isa Expr
                                        end && (begin
                                                if ##cache#839 === nothing
                                                    ##cache#839 = Some(((##838).head, (##838).args))
                                                end
                                                ##840 = (##cache#839).value
                                                ##840 isa Tuple{Symbol,var2} where var2<:AbstractArray
                                            end && (##840[1] == :quote && (begin
                                                        ##841 = ##840[2]
                                                        ##841 isa AbstractArray
                                                    end && ((ndims(##841) === 1 && length(##841) >= 0) && begin
                                                            ##842 = (SubArray)(##841, (1:length(##841),))
                                                            true
                                                        end))))))))
                    ##return#828 = let xs = ##842
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#829#853")))
                end
                if begin
                            ##843 = (##cache#831).value
                            ##843 isa Tuple{Symbol,var2} where var2<:AbstractArray
                        end && (##843[1] == :quote && (begin
                                    ##844 = ##843[2]
                                    ##844 isa AbstractArray
                                end && ((ndims(##844) === 1 && length(##844) >= 0) && begin
                                        ##845 = (SubArray)(##844, (1:length(##844),))
                                        true
                                    end)))
                    ##return#828 = let xs = ##845
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#829#853")))
                end
                if begin
                            ##846 = (##cache#831).value
                            ##846 isa Tuple{Symbol,var2} where var2<:AbstractArray
                        end && (##846[1] == :block && (begin
                                    ##847 = ##846[2]
                                    ##847 isa AbstractArray
                                end && (length(##847) === 1 && begin
                                        ##848 = ##847[1]
                                        true
                                    end)))
                    ##return#828 = let stmt = ##848
                            stmt
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#829#853")))
                end
                if begin
                            ##849 = (##cache#831).value
                            ##849 isa Tuple{var1,var2} where var1 where var2<:AbstractArray
                        end && (begin
                                ##850 = ##849[1]
                                ##851 = ##849[2]
                                ##851 isa AbstractArray
                            end && ((ndims(##851) === 1 && length(##851) >= 0) && begin
                                    ##852 = (SubArray)(##851, (1:length(##851),))
                                    true
                                end))
                    ##return#828 = let args = ##852, head = ##850
                            Expr(head, map(rm_single_block, args)...)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#829#853")))
                end
            end
            ##return#828 = let
                    ex
                end
            $(Expr(:symbolicgoto, Symbol("####final#829#853")))
            (error)("matching non-exhaustive, at #= none:183 =#")
            $(Expr(:symboliclabel, Symbol("####final#829#853")))
            ##return#828
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
