begin
    tab(n::Int) = begin
            " " ^ n
        end
    #= none:3 =# Base.@kwdef struct Color
            literal::Symbol = :light_blue
            type::Symbol = :light_green
            string::Symbol = :yellow
            comment::Symbol = :light_black
            kw::Symbol = :light_magenta
            fn::Symbol = :light_blue
        end
    #= none:12 =# Base.@kwdef mutable struct PrintState
            line_indent::Int = 0
            content_indent::Int = line_indent
            color::Symbol = :normal
        end
    #= none:18 =# Core.@doc "    sprint_expr(ex; context=nothing)\n\nPrint given expression to `String`, see also [`print_expr`](@ref).\n" function sprint_expr(ex; context = nothing)
            buf = IOBuffer()
            if context === nothing
                print_expr(buf, ex)
            else
                print_expr(IOContext(buf, context), ex)
            end
            return String(take!(buf))
        end
    #= none:33 =# Core.@doc "    print_expr([io::IO], ex)\n\nPrint a given expression. `ex` can be a `Expr` or a syntax type `JLExpr`.\n" print_expr(ex) = begin
                print_expr(stdout, ex)
            end
    print_expr(io::IO, ex) = begin
            print_expr(io, ex, PrintState())
        end
    print_expr(io::IO, ex, p::PrintState) = begin
            print_expr(io, ex, p, Color())
        end
    #= none:42 =# @deprecate print_ast(ex) print_expr(ex)
    #= none:43 =# @deprecate print_ast(io, ex) print_expr(io, ex)
    const uni_ops = Set{Symbol}([:+, :-, :!, :¬, :~, :<:, :>:, :√, :∛, :∜])
    const expr_infix_wide = Set{Symbol}([:(=), :+=, :-=, :*=, :/=, :\=, :^=, :&=, :|=, :÷=, :%=, :>>>=, :>>=, :<<=, :.=, :.+=, :.-=, :.*=, :./=, :.\=, :.^=, :.&=, :.|=, :.÷=, :.%=, :.>>>=, :.>>=, :.<<=, :&&, :||, :<:, :$=, :⊻=, :>:, :-->])
    Base.show(io::IO, def::JLExpr) = begin
            print_expr(io, def)
        end
    function print_expr(io::IO, ex::JLExpr, ps::PrintState, theme::Color)
        print_expr(io, codegen_ast(ex), ps, theme)
    end
    function print_expr(io::IO, ex, ps::PrintState, theme::Color)
        cache_1 = nothing
        x_1 = ex
        if x_1 isa Expr
            if begin
                        if cache_1 === nothing
                            cache_1 = Some((x_1.head, x_1.args))
                        end
                        x_2 = cache_1.value
                        x_2 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_2[1] == :block && (begin
                                x_3 = x_2[2]
                                x_3 isa AbstractArray
                            end && (length(x_3) === 2 && (begin
                                        x_4 = x_3[1]
                                        x_4 isa LineNumberNode
                                    end && begin
                                        x_5 = x_3[2]
                                        true
                                    end))))
                stmt = x_5
                line = x_4
                return_1 = begin
                        print_expr(io, stmt, ps, theme)
                        print(io, tab(2))
                        print_expr(io, line, ps, theme)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#313_1")))
            end
            if begin
                        x_6 = cache_1.value
                        x_6 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_6[1] == :block && (begin
                                x_7 = x_6[2]
                                x_7 isa AbstractArray
                            end && ((ndims(x_7) === 1 && length(x_7) >= 2) && (begin
                                        x_8 = x_7[1]
                                        x_8 isa LineNumberNode
                                    end && (begin
                                            x_9 = x_7[2]
                                            x_9 isa LineNumberNode
                                        end && begin
                                            x_10 = (SubArray)(x_7, (3:length(x_7),))
                                            true
                                        end)))))
                line2 = x_9
                stmts = x_10
                line1 = x_8
                return_1 = begin
                        print_kw(io, "begin", ps, theme)
                        println(io, ps)
                        print_stmts_list(io, ex.args, ps, theme)
                        print_end(io, ps, theme)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#313_1")))
            end
            if begin
                        x_11 = cache_1.value
                        x_11 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_11[1] == :block && (begin
                                x_12 = x_11[2]
                                x_12 isa AbstractArray
                            end && (length(x_12) === 3 && (begin
                                        x_13 = x_12[1]
                                        x_14 = x_12[2]
                                        x_14 isa LineNumberNode
                                    end && begin
                                        x_15 = x_12[3]
                                        true
                                    end))))
                line = x_14
                stmt2 = x_15
                stmt1 = x_13
                return_1 = begin
                        printstyled(io, "("; color = ps.color)
                        print_expr(io, stmt1, ps, theme)
                        printstyled(io, "; "; color = ps.color)
                        print_expr(io, stmt2)
                        printstyled(io, ")"; color = ps.color)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#313_1")))
            end
            if begin
                        x_16 = cache_1.value
                        x_16 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_16[1] == :block && (begin
                                x_17 = x_16[2]
                                x_17 isa AbstractArray
                            end && ((ndims(x_17) === 1 && length(x_17) >= 0) && begin
                                    x_18 = (SubArray)(x_17, (1:length(x_17),))
                                    true
                                end)))
                stmts = x_18
                return_1 = begin
                        print_kw(io, "begin", ps, theme)
                        println(io, ps)
                        print_stmts_list(io, stmts, ps, theme)
                        print_end(io, ps, theme)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#313_1")))
            end
            if begin
                        x_19 = cache_1.value
                        x_19 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_19[1] == :let && (begin
                                x_20 = x_19[2]
                                x_20 isa AbstractArray
                            end && (length(x_20) === 2 && begin
                                    x_21 = x_20[1]
                                    x_22 = x_20[2]
                                    true
                                end)))
                vars = x_21
                body = x_22
                return_1 = begin
                        print_kw(io, "let", ps, theme)
                        if !(isempty(vars.args))
                            print(io, tab(1))
                            print_collection(io, vars.args, ps, theme)
                        end
                        println(io, ps)
                        print_stmts(io, body, ps, theme)
                        print_end(io, ps, theme)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#313_1")))
            end
            if begin
                        x_23 = cache_1.value
                        x_23 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_23[1] == :if && (begin
                                x_24 = x_23[2]
                                x_24 isa AbstractArray
                            end && ((ndims(x_24) === 1 && length(x_24) >= 2) && begin
                                    x_25 = x_24[1]
                                    x_26 = x_24[2]
                                    x_27 = (SubArray)(x_24, (3:length(x_24),))
                                    true
                                end)))
                cond = x_25
                body = x_26
                otherwise = x_27
                return_1 = begin
                        within_line(io, ps) do 
                            print_kw(io, string(ex.head, tab(1)), ps, theme)
                            print_expr(io, cond, ps, theme)
                        end
                        println(io, ps)
                        print_stmts(io, body, ps, theme)
                        if isempty(otherwise)
                            print_end(io, ps, theme)
                        else
                            otherwise = otherwise[1]
                            if Meta.isexpr(otherwise, :elseif)
                                print_expr(io, otherwise, ps, theme)
                            else
                                print_kw(io, "else", ps, theme)
                                println(io, ps)
                                print_stmts(io, otherwise, ps, theme)
                                print_end(io, ps, theme)
                            end
                        end
                    end
                $(Expr(:symbolicgoto, Symbol("##final#313_1")))
            end
            if begin
                        x_28 = cache_1.value
                        x_28 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_28[1] == :elseif && (begin
                                x_29 = x_28[2]
                                x_29 isa AbstractArray
                            end && ((ndims(x_29) === 1 && length(x_29) >= 2) && begin
                                    x_30 = x_29[1]
                                    x_31 = x_29[2]
                                    x_32 = (SubArray)(x_29, (3:length(x_29),))
                                    true
                                end)))
                cond = x_30
                body = x_31
                otherwise = x_32
                return_1 = begin
                        within_line(io, ps) do 
                            print_kw(io, string(ex.head, tab(1)), ps, theme)
                            print_expr(io, cond, ps, theme)
                        end
                        println(io, ps)
                        print_stmts(io, body, ps, theme)
                        if isempty(otherwise)
                            print_end(io, ps, theme)
                        else
                            otherwise = otherwise[1]
                            if Meta.isexpr(otherwise, :elseif)
                                print_expr(io, otherwise, ps, theme)
                            else
                                print_kw(io, "else", ps, theme)
                                println(io, ps)
                                print_stmts(io, otherwise, ps, theme)
                                print_end(io, ps, theme)
                            end
                        end
                    end
                $(Expr(:symbolicgoto, Symbol("##final#313_1")))
            end
            if begin
                        x_33 = cache_1.value
                        x_33 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_33[1] == :for && (begin
                                x_34 = x_33[2]
                                x_34 isa AbstractArray
                            end && (length(x_34) === 2 && begin
                                    x_35 = x_34[1]
                                    x_36 = x_34[2]
                                    true
                                end)))
                body = x_36
                head = x_35
                return_1 = begin
                        within_line(io, ps) do 
                            print_kw(io, "for ", ps, theme)
                            if Meta.isexpr(head, :block)
                                print_collection(io, head.args, ps, theme)
                            else
                                print_expr(io, head, ps, theme)
                            end
                        end
                        println(io, ps)
                        print_stmts(io, body, ps, theme)
                        print_end(io, ps, theme)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#313_1")))
            end
            if begin
                        x_37 = cache_1.value
                        x_37 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_37[1] == :function && (begin
                                x_38 = x_37[2]
                                x_38 isa AbstractArray
                            end && (length(x_38) === 2 && begin
                                    x_39 = x_38[1]
                                    x_40 = x_38[2]
                                    true
                                end)))
                call = x_39
                body = x_40
                return_1 = begin
                        within_line(io, ps) do 
                            print_kw(io, "function ", ps, theme)
                            print_expr(io, call, ps, theme)
                        end
                        println(io, ps)
                        print_stmts(io, body, ps, theme)
                        print_end(io, ps, theme)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#313_1")))
            end
            if begin
                        x_41 = cache_1.value
                        x_41 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_41[1] == :macro && (begin
                                x_42 = x_41[2]
                                x_42 isa AbstractArray
                            end && (length(x_42) === 2 && begin
                                    x_43 = x_42[1]
                                    x_44 = x_42[2]
                                    true
                                end)))
                call = x_43
                body = x_44
                return_1 = begin
                        within_line(io, ps) do 
                            print_kw(io, "macro ", ps, theme)
                            print_expr(io, call, ps, theme)
                        end
                        println(io, ps)
                        print_stmts(io, body, ps, theme)
                        print_end(io, ps, theme)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#313_1")))
            end
            if begin
                        x_45 = cache_1.value
                        x_45 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_45[1] == :macrocall && (begin
                                x_46 = x_45[2]
                                x_46 isa AbstractArray
                            end && (length(x_46) === 4 && (begin
                                        x_47 = x_46[1]
                                        x_47 == GlobalRef(Core, Symbol("@doc"))
                                    end && begin
                                        x_48 = x_46[2]
                                        x_49 = x_46[3]
                                        x_50 = x_46[4]
                                        true
                                    end))))
                line = x_48
                code = x_50
                doc = x_49
                return_1 = begin
                        print_expr(io, line, ps, theme)
                        println(io, ps)
                        print(io, tab(ps.line_indent))
                        printstyled(io, "\"\"\""; color = theme.string)
                        println(io, ps)
                        lines = split(doc, '\n')
                        for (i, line) = enumerate(lines)
                            print(io, tab(ps.line_indent))
                            printstyled(io, line; color = theme.string)
                            if i != length(lines)
                                println(io, ps)
                            end
                        end
                        print(io, tab(ps.line_indent))
                        printstyled(io, "\"\"\""; color = theme.string)
                        println(io, ps)
                        print_expr(io, code, ps, theme)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#313_1")))
            end
            if begin
                        x_51 = cache_1.value
                        x_51 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_51[1] == :macrocall && (begin
                                x_52 = x_51[2]
                                x_52 isa AbstractArray
                            end && (length(x_52) === 2 && (begin
                                        cache_2 = nothing
                                        x_53 = x_52[1]
                                        if cache_2 === nothing
                                            cache_2 = Some(((Val{(view, Symbol("##Symbol(x)#313"))}())())(x_53))
                                        end
                                        cache_2.value !== nothing && (cache_2.value isa Some || (error)("invalid use of active patterns: 1-ary view pattern(Symbol(x)) should accept Union{Some{T}, Nothing} instead of Union{T, Nothing}! A simple solution is:\n  (@active Symbol(x) ex) =>\n  (@active Symbol(x) let r=ex; r === nothing? r : Some(r)) end"))
                                    end && (begin
                                            x_54 = cache_2.value
                                            x_54 isa Some{T} where T<:AbstractString
                                        end && (x_54 !== nothing && (x_54.value == "@__MODULE__" && begin
                                                    x_55 = x_52[2]
                                                    true
                                                end)))))))
                line = x_55
                return_1 = begin
                        with_color(theme.fn, ps) do 
                            print_expr(io, Symbol("@__MODULE__"), ps, theme)
                        end
                    end
                $(Expr(:symbolicgoto, Symbol("##final#313_1")))
            end
            if begin
                        x_56 = cache_1.value
                        x_56 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_56[1] == :macrocall && (begin
                                x_57 = x_56[2]
                                x_57 isa AbstractArray
                            end && (length(x_57) === 3 && (begin
                                        x_58 = x_57[1]
                                        x_58 isa Symbol
                                    end && begin
                                        x_59 = x_57[2]
                                        x_60 = x_57[3]
                                        x_60 isa String
                                    end))))
                line = x_59
                s = x_60
                name = x_58
                return_1 = begin
                        if endswith(string(name), "_str")
                            printstyled(io, (string(name))[2:end - 4]; color = theme.fn)
                            print_expr(s)
                        else
                            print_macro(io, name, line, (s,), ps, theme)
                        end
                    end
                $(Expr(:symbolicgoto, Symbol("##final#313_1")))
            end
            if begin
                        x_61 = cache_1.value
                        x_61 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_61[1] == :macrocall && (begin
                                x_62 = x_61[2]
                                x_62 isa AbstractArray
                            end && ((ndims(x_62) === 1 && length(x_62) >= 2) && begin
                                    x_63 = x_62[1]
                                    x_64 = x_62[2]
                                    x_65 = (SubArray)(x_62, (3:length(x_62),))
                                    true
                                end)))
                line = x_64
                name = x_63
                xs = x_65
                return_1 = begin
                        print_macro(io, name, line, xs, ps, theme)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#313_1")))
            end
            if begin
                        x_66 = cache_1.value
                        x_66 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_66[1] == :struct && (begin
                                x_67 = x_66[2]
                                x_67 isa AbstractArray
                            end && (length(x_67) === 3 && begin
                                    x_68 = x_67[1]
                                    x_69 = x_67[2]
                                    x_70 = x_67[3]
                                    true
                                end)))
                ismutable = x_68
                body = x_70
                head = x_69
                return_1 = begin
                        within_line(io, ps) do 
                            if ismutable
                                printstyled(io, "mutable "; color = theme.kw)
                            end
                            printstyled(io, "struct "; color = theme.kw)
                            print_expr(io, head, ps, theme)
                        end
                        println(io, ps)
                        print_stmts(io, body, ps, theme)
                        print_end(io, ps, theme)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#313_1")))
            end
            if begin
                        x_71 = cache_1.value
                        x_71 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_71[1] == :try && (begin
                                x_72 = x_71[2]
                                x_72 isa AbstractArray
                            end && (length(x_72) === 3 && begin
                                    x_73 = x_72[1]
                                    x_74 = x_72[2]
                                    x_75 = x_72[3]
                                    true
                                end)))
                catch_body = x_75
                try_body = x_73
                catch_var = x_74
                return_1 = begin
                        print_try(io, try_body, ps, theme)
                        print_catch(io, catch_var, catch_body, ps, theme)
                        print_end(io, ps, theme)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#313_1")))
            end
            if begin
                        x_76 = cache_1.value
                        x_76 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_76[1] == :try && (begin
                                x_77 = x_76[2]
                                x_77 isa AbstractArray
                            end && (length(x_77) === 4 && (begin
                                        x_78 = x_77[1]
                                        x_77[2] === false
                                    end && (x_77[3] === false && begin
                                            x_79 = x_77[4]
                                            true
                                        end)))))
                try_body = x_78
                finally_body = x_79
                return_1 = begin
                        print_try(io, try_body, ps, theme)
                        print_finally(io, finally_body, ps, theme)
                        print_end(io, ps, theme)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#313_1")))
            end
            if begin
                        x_80 = cache_1.value
                        x_80 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_80[1] == :try && (begin
                                x_81 = x_80[2]
                                x_81 isa AbstractArray
                            end && (length(x_81) === 4 && begin
                                    x_82 = x_81[1]
                                    x_83 = x_81[2]
                                    x_84 = x_81[3]
                                    x_85 = x_81[4]
                                    true
                                end)))
                catch_body = x_84
                try_body = x_82
                finally_body = x_85
                catch_var = x_83
                return_1 = begin
                        print_try(io, try_body, ps, theme)
                        print_catch(io, catch_var, catch_body, ps, theme)
                        print_finally(io, finally_body, ps, theme)
                        print_end(io, ps, theme)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#313_1")))
            end
            if begin
                        x_86 = cache_1.value
                        x_86 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_86[1] == :module && (begin
                                x_87 = x_86[2]
                                x_87 isa AbstractArray
                            end && (length(x_87) === 3 && begin
                                    x_88 = x_87[1]
                                    x_89 = x_87[2]
                                    x_90 = x_87[3]
                                    true
                                end)))
                name = x_89
                body = x_90
                notbare = x_88
                return_1 = begin
                        if notbare
                            print_kw(io, "module", ps, theme)
                        else
                            print_kw(io, "baremodule", ps, theme)
                        end
                        println(io, ps)
                        print_stmts(io, body, ps, theme)
                        print_end(io, ps, theme)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#313_1")))
            end
            if begin
                        x_91 = cache_1.value
                        x_91 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_91[1] == :const && (begin
                                x_92 = x_91[2]
                                x_92 isa AbstractArray
                            end && (length(x_92) === 1 && begin
                                    x_93 = x_92[1]
                                    true
                                end)))
                body = x_93
                return_1 = begin
                        within_line(io, ps) do 
                            print_kw(io, "const", ps, theme)
                            print(io, tab(1))
                            print_expr(io, body, ps, theme)
                        end
                    end
                $(Expr(:symbolicgoto, Symbol("##final#313_1")))
            end
        end
        return_1 = begin
                print_within_line(io, ex, ps, theme)
            end
        $(Expr(:symbolicgoto, Symbol("##final#313_1")))
        (error)("matching non-exhaustive, at #= none:58 =#")
        $(Expr(:symboliclabel, Symbol("##final#313_1")))
        return_1
    end
    function print_kw(io::IO, x, ps, theme::Color)
        print(io, tab(ps.line_indent))
        printstyled(io, x; color = theme.kw)
    end
    function print_macro(io, name, line, xs, ps, theme)
        print_expr(io, line, ps, theme)
        println(io, ps)
        within_line(io, ps) do 
            with_color(theme.fn, ps) do 
                print_expr(io, name, ps, theme)
            end
            print(io, tab(1))
            print_collection(io, xs, ps, theme; delim = tab(1))
        end
    end
    print_end(io::IO, ps, theme) = begin
            print_kw(io, "end", ps, theme)
        end
    function Base.println(io::IO, ps::PrintState)
        ps.line_indent = ps.content_indent
        println(io)
    end
    function print_stmts(io, body, ps::PrintState, theme::Color)
        if body isa Expr && body.head === :block
            print_stmts_list(io, body.args, ps, theme)
        else
            within_indent(ps) do 
                print_expr(io, body, ps, theme)
                println(io, ps)
            end
        end
    end
    function print_try(io, try_body, ps, theme)
        print_kw(io, "try", ps, theme)
        println(io, ps)
        print_stmts(io, try_body, ps, theme)
    end
    function print_catch(io, catch_var, catch_body, ps, theme)
        print_kw(io, "catch ", ps, theme)
        print_expr(io, catch_var, ps, theme)
        println(io, ps)
        print_stmts(io, catch_body, ps, theme)
    end
    function print_finally(io, finally_body, ps, theme)
        print_kw(io, "finally", ps, theme)
        println(io, ps)
        print_stmts(io, finally_body, ps, theme)
    end
    function print_stmts_list(io, stmts, ps::PrintState, theme::Color)
        within_indent(ps) do 
            for stmt = stmts
                print_expr(io, stmt, ps, theme)
                println(io, ps)
            end
        end
        return
    end
    function print_collection(io, xs, ps::PrintState, theme = Color(); delim = ", ")
        for i = 1:length(xs)
            print_expr(io, xs[i], ps, theme)
            if i !== length(xs)
                print(io, delim)
            end
        end
    end
    function with_color(f, name::Symbol, ps::PrintState)
        color = ps.color
        if color === :normal
            ps.color = name
        end
        ret = f()
        ps.color = color
        return ret
    end
    function within_line(f, io, ps)
        indent = ps.line_indent
        print(io, tab(indent))
        ps.line_indent = 0
        ret = f()
        ps.line_indent = indent
        return ret
    end
    function within_indent(f, ps)
        ps.line_indent += 4
        ps.content_indent = ps.line_indent
        ret = f()
        ps.line_indent -= 4
        ps.content_indent = ps.line_indent
        return ret
    end
    function print_within_line(io::IO, ex, ps::PrintState, theme::Color = Color())
        within_line(io, ps) do 
            cache_3 = nothing
            x_94 = ex
            if x_94 isa GlobalRef
                return_2 = begin
                        printstyled(io, ex.mod, "."; color = ps.color)
                        print_expr(io, ex.name, ps, theme)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#411_1")))
            end
            if x_94 isa Nothing
                return_2 = begin
                        printstyled(io, "nothing"; color = :blue)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#411_1")))
            end
            if x_94 isa Symbol
                return_2 = begin
                        printstyled(io, ex; color = ps.color)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#411_1")))
            end
            if x_94 isa Expr
                if begin
                            if cache_3 === nothing
                                cache_3 = Some((x_94.head, x_94.args))
                            end
                            x_95 = cache_3.value
                            x_95 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_95[1] == :export && (begin
                                    x_96 = x_95[2]
                                    x_96 isa AbstractArray
                                end && ((ndims(x_96) === 1 && length(x_96) >= 0) && begin
                                        x_97 = (SubArray)(x_96, (1:length(x_96),))
                                        true
                                    end)))
                    xs = x_97
                    return_2 = begin
                            print_kw(io, "export ", ps, theme)
                            print_collection(io, xs, ps, theme)
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#411_1")))
                end
                if begin
                            x_98 = cache_3.value
                            x_98 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_98[1] == :tuple && (begin
                                    x_99 = x_98[2]
                                    x_99 isa AbstractArray
                                end && ((ndims(x_99) === 1 && length(x_99) >= 1) && (begin
                                            cache_4 = nothing
                                            x_100 = x_99[1]
                                            x_100 isa Expr
                                        end && (begin
                                                if cache_4 === nothing
                                                    cache_4 = Some((x_100.head, x_100.args))
                                                end
                                                x_101 = cache_4.value
                                                x_101 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                            end && (x_101[1] == :parameters && (begin
                                                        x_102 = x_101[2]
                                                        x_102 isa AbstractArray
                                                    end && ((ndims(x_102) === 1 && length(x_102) >= 0) && begin
                                                            x_103 = (SubArray)(x_102, (1:length(x_102),))
                                                            x_104 = (SubArray)(x_99, (2:length(x_99),))
                                                            true
                                                        end))))))))
                    args = x_104
                    kwargs = x_103
                    return_2 = begin
                            printstyled(io, "("; color = ps.color)
                            print_collection(io, args, ps, theme)
                            if !(isempty(kwargs))
                                printstyled(io, "; "; color = ps.color)
                                print_collection(io, kwargs, ps)
                            end
                            printstyled(io, ")"; color = ps.color)
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#411_1")))
                end
                if begin
                            x_105 = cache_3.value
                            x_105 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_105[1] == :tuple && (begin
                                    x_106 = x_105[2]
                                    x_106 isa AbstractArray
                                end && ((ndims(x_106) === 1 && length(x_106) >= 0) && begin
                                        x_107 = (SubArray)(x_106, (1:length(x_106),))
                                        true
                                    end)))
                    xs = x_107
                    return_2 = begin
                            printstyled(io, "("; color = ps.color)
                            print_collection(io, xs, ps)
                            printstyled(io, ")"; color = ps.color)
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#411_1")))
                end
                if begin
                            x_108 = cache_3.value
                            x_108 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_108[1] == :(::) && (begin
                                    x_109 = x_108[2]
                                    x_109 isa AbstractArray
                                end && (length(x_109) === 1 && begin
                                        x_110 = x_109[1]
                                        true
                                    end)))
                    type = x_110
                    return_2 = begin
                            printstyled(io, "::"; color = ps.color)
                            with_color(theme.type, ps) do 
                                print_expr(io, type, ps, theme)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#411_1")))
                end
                if begin
                            x_111 = cache_3.value
                            x_111 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_111[1] == :(::) && (begin
                                    x_112 = x_111[2]
                                    x_112 isa AbstractArray
                                end && (length(x_112) === 2 && begin
                                        x_113 = x_112[1]
                                        x_114 = x_112[2]
                                        true
                                    end)))
                    type = x_114
                    name = x_113
                    return_2 = begin
                            print_expr(io, name, ps, theme)
                            printstyled(io, "::"; color = ps.color)
                            with_color(theme.type, ps) do 
                                print_expr(io, type, ps, theme)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#411_1")))
                end
                if begin
                            x_115 = cache_3.value
                            x_115 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_115[1] == :. && (begin
                                    x_116 = x_115[2]
                                    x_116 isa AbstractArray
                                end && (length(x_116) === 2 && begin
                                        x_117 = x_116[1]
                                        x_118 = x_116[2]
                                        x_118 isa QuoteNode
                                    end)))
                    a = x_117
                    b = x_118
                    return_2 = begin
                            print_expr(io, a, ps, theme)
                            printstyled(io, "."; color = ps.color)
                            print_expr(io, b.value, ps, theme)
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#411_1")))
                end
                if begin
                            x_119 = cache_3.value
                            x_119 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_119[1] == :. && (begin
                                    x_120 = x_119[2]
                                    x_120 isa AbstractArray
                                end && (length(x_120) === 2 && begin
                                        x_121 = x_120[1]
                                        x_122 = x_120[2]
                                        true
                                    end)))
                    a = x_121
                    b = x_122
                    return_2 = begin
                            print_expr(io, a, ps, theme)
                            printstyled(io, "."; color = ps.color)
                            print_expr(io, b, ps, theme)
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#411_1")))
                end
                if begin
                            x_123 = cache_3.value
                            x_123 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_123[1] == :<: && (begin
                                    x_124 = x_123[2]
                                    x_124 isa AbstractArray
                                end && (length(x_124) === 2 && begin
                                        x_125 = x_124[1]
                                        x_126 = x_124[2]
                                        true
                                    end)))
                    type = x_126
                    name = x_125
                    return_2 = begin
                            print_expr(io, name, ps, theme)
                            printstyled(io, " <: "; color = ps.color)
                            with_color(theme.type, ps) do 
                                print_expr(io, type, ps, theme)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#411_1")))
                end
                if begin
                            x_127 = cache_3.value
                            x_127 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_127[1] == :kw && (begin
                                    x_128 = x_127[2]
                                    x_128 isa AbstractArray
                                end && (length(x_128) === 2 && begin
                                        x_129 = x_128[1]
                                        x_130 = x_128[2]
                                        true
                                    end)))
                    value = x_130
                    name = x_129
                    return_2 = begin
                            print_expr(io, name, ps, theme)
                            printstyled(io, tab(1), "=", tab(1); color = ps.color)
                            print_expr(io, value, ps, theme)
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#411_1")))
                end
                if begin
                            x_131 = cache_3.value
                            x_131 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_131[1] == :(=) && (begin
                                    x_132 = x_131[2]
                                    x_132 isa AbstractArray
                                end && (length(x_132) === 2 && begin
                                        x_133 = x_132[1]
                                        x_134 = x_132[2]
                                        true
                                    end)))
                    value = x_134
                    name = x_133
                    return_2 = begin
                            print_expr(io, name, ps, theme)
                            printstyled(io, tab(1), "=", tab(1); color = ps.color)
                            print_expr(io, value, ps, theme)
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#411_1")))
                end
                if begin
                            x_135 = cache_3.value
                            x_135 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_135[1] == :... && (begin
                                    x_136 = x_135[2]
                                    x_136 isa AbstractArray
                                end && (length(x_136) === 1 && begin
                                        x_137 = x_136[1]
                                        true
                                    end)))
                    name = x_137
                    return_2 = begin
                            print_expr(io, name, ps, theme)
                            print(io, "...")
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#411_1")))
                end
                if begin
                            x_138 = cache_3.value
                            x_138 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_138[1] == :& && (begin
                                    x_139 = x_138[2]
                                    x_139 isa AbstractArray
                                end && (length(x_139) === 1 && begin
                                        x_140 = x_139[1]
                                        true
                                    end)))
                    name = x_140
                    return_2 = begin
                            printstyled(io, "&"; color = theme.kw)
                            print_expr(io, name, ps, theme)
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#411_1")))
                end
                if begin
                            x_141 = cache_3.value
                            x_141 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_141[1] == :$ && (begin
                                    x_142 = x_141[2]
                                    x_142 isa AbstractArray
                                end && (length(x_142) === 1 && begin
                                        x_143 = x_142[1]
                                        true
                                    end)))
                    name = x_143
                    return_2 = begin
                            printstyled(io, "\$"; color = theme.kw)
                            print(io, "(")
                            print_expr(io, name, ps, theme)
                            print(io, ")")
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#411_1")))
                end
                if begin
                            x_144 = cache_3.value
                            x_144 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_144[1] == :curly && (begin
                                    x_145 = x_144[2]
                                    x_145 isa AbstractArray
                                end && ((ndims(x_145) === 1 && length(x_145) >= 1) && begin
                                        x_146 = x_145[1]
                                        x_147 = (SubArray)(x_145, (2:length(x_145),))
                                        true
                                    end)))
                    vars = x_147
                    name = x_146
                    return_2 = begin
                            print_expr(io, name, ps, theme)
                            print(io, "{")
                            with_color(theme.type, ps) do 
                                print_collection(io, vars, ps, theme)
                            end
                            print(io, "}")
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#411_1")))
                end
                if begin
                            x_148 = cache_3.value
                            x_148 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_148[1] == :ref && (begin
                                    x_149 = x_148[2]
                                    x_149 isa AbstractArray
                                end && ((ndims(x_149) === 1 && length(x_149) >= 1) && begin
                                        x_150 = x_149[1]
                                        x_151 = (SubArray)(x_149, (2:length(x_149),))
                                        true
                                    end)))
                    name = x_150
                    xs = x_151
                    return_2 = begin
                            print_expr(io, name, ps, theme)
                            print(io, "[")
                            print_collection(io, xs, ps, theme)
                            print(io, "]")
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#411_1")))
                end
                if begin
                            x_152 = cache_3.value
                            x_152 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_152[1] == :where && (begin
                                    x_153 = x_152[2]
                                    x_153 isa AbstractArray
                                end && ((ndims(x_153) === 1 && length(x_153) >= 1) && begin
                                        x_154 = x_153[1]
                                        x_155 = (SubArray)(x_153, (2:length(x_153),))
                                        true
                                    end)))
                    body = x_154
                    whereparams = x_155
                    return_2 = begin
                            print_expr(io, body, ps, theme)
                            printstyled(io, tab(1), "where", tab(1); color = theme.kw)
                            print(io, "{")
                            print_collection(io, whereparams, ps, theme)
                            print(io, "}")
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#411_1")))
                end
                if begin
                            x_156 = cache_3.value
                            x_156 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_156[1] == :call && (begin
                                    x_157 = x_156[2]
                                    x_157 isa AbstractArray
                                end && ((ndims(x_157) === 1 && length(x_157) >= 2) && (begin
                                            x_158 = x_157[1]
                                            cache_5 = nothing
                                            x_159 = x_157[2]
                                            x_159 isa Expr
                                        end && (begin
                                                if cache_5 === nothing
                                                    cache_5 = Some((x_159.head, x_159.args))
                                                end
                                                x_160 = cache_5.value
                                                x_160 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                            end && (x_160[1] == :parameters && (begin
                                                        x_161 = x_160[2]
                                                        x_161 isa AbstractArray
                                                    end && ((ndims(x_161) === 1 && length(x_161) >= 0) && begin
                                                            x_162 = (SubArray)(x_161, (1:length(x_161),))
                                                            x_163 = (SubArray)(x_157, (3:length(x_157),))
                                                            true
                                                        end))))))))
                    name = x_158
                    args = x_163
                    kwargs = x_162
                    return_2 = begin
                            print_expr(io, name, ps, theme)
                            printstyled(io, "("; color = ps.color)
                            print_collection(io, args, ps)
                            if !(isempty(kwargs))
                                printstyled(io, "; "; color = ps.color)
                                print_collection(io, kwargs, ps)
                            end
                            printstyled(io, ")"; color = ps.color)
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#411_1")))
                end
                if begin
                            x_164 = cache_3.value
                            x_164 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_164[1] == :call && (begin
                                    x_165 = x_164[2]
                                    x_165 isa AbstractArray
                                end && ((ndims(x_165) === 1 && length(x_165) >= 1) && (x_165[1] == :(:) && begin
                                            x_166 = (SubArray)(x_165, (2:length(x_165),))
                                            true
                                        end))))
                    xs = x_166
                    return_2 = begin
                            print_collection(io, xs, ps, theme; delim = ":")
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#411_1")))
                end
                if begin
                            x_167 = cache_3.value
                            x_167 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_167[1] == :call && (begin
                                    x_168 = x_167[2]
                                    x_168 isa AbstractArray
                                end && (length(x_168) === 2 && (begin
                                            x_169 = x_168[1]
                                            x_169 isa Symbol
                                        end && begin
                                            x_170 = x_168[2]
                                            true
                                        end))))
                    name = x_169
                    x = x_170
                    return_2 = begin
                            if name in uni_ops
                                print_expr(io, name, ps, theme)
                                print_expr(io, x, ps, theme)
                            else
                                print_call_expr(io, name, [x], ps, theme)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#411_1")))
                end
                if begin
                            x_171 = cache_3.value
                            x_171 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_171[1] == :call && (begin
                                    x_172 = x_171[2]
                                    x_172 isa AbstractArray
                                end && ((ndims(x_172) === 1 && length(x_172) >= 1) && (x_172[1] == :+ && begin
                                            x_173 = (SubArray)(x_172, (2:length(x_172),))
                                            true
                                        end))))
                    xs = x_173
                    return_2 = begin
                            print_collection(io, xs, ps, theme; delim = " + ")
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#411_1")))
                end
                if begin
                            x_174 = cache_3.value
                            x_174 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_174[1] == :call && (begin
                                    x_175 = x_174[2]
                                    x_175 isa AbstractArray
                                end && (length(x_175) === 3 && begin
                                        x_176 = x_175[1]
                                        x_177 = x_175[2]
                                        x_178 = x_175[3]
                                        true
                                    end)))
                    rhs = x_178
                    lhs = x_177
                    name = x_176
                    return_2 = begin
                            func_prec = Base.operator_precedence(name_only(name))
                            if func_prec > 0
                                print_expr(io, lhs, ps, theme)
                                print(io, tab(1))
                                print_expr(io, name, ps, theme)
                                print(io, tab(1))
                                print_expr(io, rhs, ps, theme)
                            else
                                print_call_expr(io, name, [lhs, rhs], ps, theme)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#411_1")))
                end
                if begin
                            x_179 = cache_3.value
                            x_179 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_179[1] == :call && (begin
                                    x_180 = x_179[2]
                                    x_180 isa AbstractArray
                                end && ((ndims(x_180) === 1 && length(x_180) >= 1) && begin
                                        x_181 = x_180[1]
                                        x_182 = (SubArray)(x_180, (2:length(x_180),))
                                        true
                                    end)))
                    name = x_181
                    args = x_182
                    return_2 = begin
                            print_call_expr(io, name, args, ps, theme)
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#411_1")))
                end
                if begin
                            x_183 = cache_3.value
                            x_183 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_183[1] == :-> && (begin
                                    x_184 = x_183[2]
                                    x_184 isa AbstractArray
                                end && (length(x_184) === 2 && begin
                                        x_185 = x_184[1]
                                        x_186 = x_184[2]
                                        true
                                    end)))
                    call = x_185
                    body = x_186
                    return_2 = begin
                            print_expr(io, call, ps, theme)
                            printstyled(io, tab(1), "->", tab(1); color = theme.kw)
                            print_expr(io, body, ps, theme)
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#411_1")))
                end
                if begin
                            x_187 = cache_3.value
                            x_187 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_187[1] == :return && (begin
                                    x_188 = x_187[2]
                                    x_188 isa AbstractArray
                                end && (length(x_188) === 1 && begin
                                        x_189 = x_188[1]
                                        true
                                    end)))
                    x = x_189
                    return_2 = begin
                            printstyled(io, "return", tab(1); color = theme.kw)
                            let
                                cache_6 = nothing
                                return_3 = nothing
                                x_190 = x
                                if x_190 isa Expr && (begin
                                                if cache_6 === nothing
                                                    cache_6 = Some((x_190.head, x_190.args))
                                                end
                                                x_191 = cache_6.value
                                                x_191 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                            end && (x_191[1] == :tuple && (begin
                                                        x_192 = x_191[2]
                                                        x_192 isa AbstractArray
                                                    end && ((ndims(x_192) === 1 && length(x_192) >= 0) && begin
                                                            x_193 = (SubArray)(x_192, (1:length(x_192),))
                                                            true
                                                        end))))
                                    return_3 = let xs = x_193
                                            print_collection(io, xs, ps)
                                        end
                                    $(Expr(:symbolicgoto, Symbol("##final#521_1")))
                                end
                                return_3 = let
                                        print_expr(io, x, ps, theme)
                                    end
                                $(Expr(:symbolicgoto, Symbol("##final#521_1")))
                                (error)("matching non-exhaustive, at #= none:447 =#")
                                $(Expr(:symboliclabel, Symbol("##final#521_1")))
                                return_3
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#411_1")))
                end
                if begin
                            x_194 = cache_3.value
                            x_194 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_194[1] == :string && (begin
                                    x_195 = x_194[2]
                                    x_195 isa AbstractArray
                                end && ((ndims(x_195) === 1 && length(x_195) >= 0) && begin
                                        x_196 = (SubArray)(x_195, (1:length(x_195),))
                                        true
                                    end)))
                    xs = x_196
                    return_2 = begin
                            printstyled(io, "\""; color = theme.string)
                            for x = xs
                                if x isa String
                                    printstyled(io, x; color = theme.string)
                                else
                                    printstyled(io, "\$"; color = theme.literal)
                                    with_color(theme.literal, ps) do 
                                        print_expr(io, x, ps, theme)
                                    end
                                end
                            end
                            printstyled(io, "\""; color = theme.string)
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#411_1")))
                end
                if begin
                            x_197 = cache_3.value
                            x_197 isa Tuple{var1, var2} where {var2<:AbstractArray, var1}
                        end && (begin
                                x_198 = x_197[1]
                                x_199 = x_197[2]
                                x_199 isa AbstractArray
                            end && (length(x_199) === 2 && begin
                                    x_200 = x_199[1]
                                    x_201 = x_199[2]
                                    true
                                end))
                    rhs = x_201
                    lhs = x_200
                    head = x_198
                    return_2 = begin
                            if head in expr_infix_wide
                                print_expr(io, lhs, ps, theme)
                                printstyled(io, tab(1), head, tab(1); color = theme.kw)
                                print_expr(io, rhs, ps, theme)
                            else
                                Base.show_unquoted_quote_expr(IOContext(io, :unquote_fallback => true), ex, ps.line_indent, -1, 0)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#411_1")))
                end
            end
            if x_94 isa QuoteNode
                return_2 = begin
                        if Base.isidentifier(ex.value)
                            print(io, ":", ex.value)
                        else
                            print(io, ":(", ex.value, ")")
                        end
                    end
                $(Expr(:symbolicgoto, Symbol("##final#411_1")))
            end
            if x_94 isa String
                return_2 = begin
                        printstyled(io, "\"", ex, "\""; color = theme.string)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#411_1")))
            end
            if x_94 isa LineNumberNode
                return_2 = begin
                        printstyled(io, ex; color = theme.comment)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#411_1")))
            end
            if x_94 isa Number
                return_2 = begin
                        printstyled(io, ex; color = theme.literal)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#411_1")))
            end
            if x_94 isa Base.ExprNode
                return_2 = begin
                        Base.show_unquoted_quote_expr(IOContext(io, :unquote_fallback => true), ex, ps.line_indent, -1, 0)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#411_1")))
            end
            return_2 = begin
                    print(io, ex)
                end
            $(Expr(:symbolicgoto, Symbol("##final#411_1")))
            (error)("matching non-exhaustive, at #= none:315 =#")
            $(Expr(:symboliclabel, Symbol("##final#411_1")))
            return_2
        end
        return
    end
    function print_call_expr(io::IO, name, args, ps, theme)
        print_expr(io, name, ps, theme)
        printstyled(io, "("; color = ps.color)
        print_collection(io, args, ps, theme)
        printstyled(io, ")"; color = ps.color)
    end
end
