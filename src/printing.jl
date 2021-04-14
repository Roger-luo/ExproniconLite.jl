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
    #= none:18 =# Core.@doc "    sprint_expr(ex; context=nothing)\n\nPrint given expression to `String`, see also [`print_expr`](@ref).\n" function sprint_expr(ex; context=nothing)
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
        ##cache#631 = nothing
        ##630 = ex
        if ##630 isa Expr
            if begin
                        if ##cache#631 === nothing
                            ##cache#631 = Some(((##630).head, (##630).args))
                        end
                        ##632 = (##cache#631).value
                        ##632 isa Tuple{Symbol,var2} where var2<:AbstractArray
                    end && (##632[1] == :block && (begin
                                ##633 = ##632[2]
                                ##633 isa AbstractArray
                            end && (length(##633) === 2 && (begin
                                        ##634 = ##633[1]
                                        ##634 isa LineNumberNode
                                    end && begin
                                        ##635 = ##633[2]
                                        true
                                    end))))
                stmt = ##635
                line = ##634
                ##return#628 = begin
                        print_expr(io, stmt, ps, theme)
                        print(io, tab(2))
                        print_expr(io, line, ps, theme)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#629#697")))
            end
            if begin
                        ##636 = (##cache#631).value
                        ##636 isa Tuple{Symbol,var2} where var2<:AbstractArray
                    end && (##636[1] == :block && (begin
                                ##637 = ##636[2]
                                ##637 isa AbstractArray
                            end && (length(##637) === 3 && (begin
                                        ##638 = ##637[1]
                                        ##639 = ##637[2]
                                        ##639 isa LineNumberNode
                                    end && begin
                                        ##640 = ##637[3]
                                        true
                                    end))))
                line = ##639
                stmt2 = ##640
                stmt1 = ##638
                ##return#628 = begin
                        printstyled(io, "("; color=ps.color)
                        print_expr(io, stmt1, ps, theme)
                        printstyled(io, "; "; color=ps.color)
                        print_expr(io, stmt2)
                        printstyled(io, ")"; color=ps.color)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#629#697")))
            end
            if begin
                        ##641 = (##cache#631).value
                        ##641 isa Tuple{Symbol,var2} where var2<:AbstractArray
                    end && (##641[1] == :block && (begin
                                ##642 = ##641[2]
                                ##642 isa AbstractArray
                            end && ((ndims(##642) === 1 && length(##642) >= 0) && begin
                                    ##643 = (SubArray)(##642, (1:length(##642),))
                                    true
                                end)))
                stmts = ##643
                ##return#628 = begin
                        print_kw(io, "begin", ps, theme)
                        println(io, ps)
                        print_stmts_list(io, stmts, ps, theme)
                        print_end(io, ps, theme)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#629#697")))
            end
            if begin
                        ##644 = (##cache#631).value
                        ##644 isa Tuple{Symbol,var2} where var2<:AbstractArray
                    end && (##644[1] == :let && (begin
                                ##645 = ##644[2]
                                ##645 isa AbstractArray
                            end && (length(##645) === 2 && begin
                                    ##646 = ##645[1]
                                    ##647 = ##645[2]
                                    true
                                end)))
                vars = ##646
                body = ##647
                ##return#628 = begin
                        print_kw(io, "let", ps, theme)
                        if !(isempty(vars.args))
                            print(io, tab(1))
                            print_collection(io, vars.args, ps, theme)
                        end
                        println(io, ps)
                        print_stmts(io, body, ps, theme)
                        print_end(io, ps, theme)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#629#697")))
            end
            if begin
                        ##648 = (##cache#631).value
                        ##648 isa Tuple{Symbol,var2} where var2<:AbstractArray
                    end && (##648[1] == :if && (begin
                                ##649 = ##648[2]
                                ##649 isa AbstractArray
                            end && ((ndims(##649) === 1 && length(##649) >= 2) && begin
                                    ##650 = ##649[1]
                                    ##651 = ##649[2]
                                    ##652 = (SubArray)(##649, (3:length(##649),))
                                    true
                                end)))
                cond = ##650
                body = ##651
                otherwise = ##652
                ##return#628 = begin
                        printstyled(io, ex.head, tab(1); color=theme.kw)
                        print_expr(io, cond, ps, theme)
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
                $(Expr(:symbolicgoto, Symbol("####final#629#697")))
            end
            if begin
                        ##653 = (##cache#631).value
                        ##653 isa Tuple{Symbol,var2} where var2<:AbstractArray
                    end && (##653[1] == :elseif && (begin
                                ##654 = ##653[2]
                                ##654 isa AbstractArray
                            end && ((ndims(##654) === 1 && length(##654) >= 2) && begin
                                    ##655 = ##654[1]
                                    ##656 = ##654[2]
                                    ##657 = (SubArray)(##654, (3:length(##654),))
                                    true
                                end)))
                cond = ##655
                body = ##656
                otherwise = ##657
                ##return#628 = begin
                        printstyled(io, ex.head, tab(1); color=theme.kw)
                        print_expr(io, cond, ps, theme)
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
                $(Expr(:symbolicgoto, Symbol("####final#629#697")))
            end
            if begin
                        ##658 = (##cache#631).value
                        ##658 isa Tuple{Symbol,var2} where var2<:AbstractArray
                    end && (##658[1] == :for && (begin
                                ##659 = ##658[2]
                                ##659 isa AbstractArray
                            end && (length(##659) === 2 && begin
                                    ##660 = ##659[1]
                                    ##661 = ##659[2]
                                    true
                                end)))
                body = ##661
                head = ##660
                ##return#628 = begin
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
                $(Expr(:symbolicgoto, Symbol("####final#629#697")))
            end
            if begin
                        ##662 = (##cache#631).value
                        ##662 isa Tuple{Symbol,var2} where var2<:AbstractArray
                    end && (##662[1] == :function && (begin
                                ##663 = ##662[2]
                                ##663 isa AbstractArray
                            end && (length(##663) === 2 && begin
                                    ##664 = ##663[1]
                                    ##665 = ##663[2]
                                    true
                                end)))
                call = ##664
                body = ##665
                ##return#628 = begin
                        within_line(io, ps) do 
                            print_kw(io, "function ", ps, theme)
                            print_expr(io, call, ps, theme)
                        end
                        println(io, ps)
                        print_stmts(io, body, ps, theme)
                        print_end(io, ps, theme)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#629#697")))
            end
            if begin
                        ##666 = (##cache#631).value
                        ##666 isa Tuple{Symbol,var2} where var2<:AbstractArray
                    end && (##666[1] == :macrocall && (begin
                                ##667 = ##666[2]
                                ##667 isa AbstractArray
                            end && (length(##667) === 4 && (begin
                                        ##668 = ##667[1]
                                        ##668 == GlobalRef(Core, Symbol("@doc"))
                                    end && begin
                                        ##669 = ##667[2]
                                        ##670 = ##667[3]
                                        ##671 = ##667[4]
                                        true
                                    end))))
                line = ##669
                code = ##671
                doc = ##670
                ##return#628 = begin
                        print_expr(io, line, ps, theme)
                        println(io, ps)
                        print(io, tab(ps.line_indent))
                        printstyled(io, "\"\"\""; color=theme.string)
                        println(io, ps)
                        lines = split(doc, '\n')
                        for (i, line) = enumerate(lines)
                            print(io, tab(ps.line_indent))
                            printstyled(io, line; color=theme.string)
                            if i != length(lines)
                                println(io, ps)
                            end
                        end
                        print(io, tab(ps.line_indent))
                        printstyled(io, "\"\"\""; color=theme.string)
                        println(io, ps)
                        print_expr(io, code, ps, theme)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#629#697")))
            end
            if begin
                        ##672 = (##cache#631).value
                        ##672 isa Tuple{Symbol,var2} where var2<:AbstractArray
                    end && (##672[1] == :macrocall && (begin
                                ##673 = ##672[2]
                                ##673 isa AbstractArray
                            end && ((ndims(##673) === 1 && length(##673) >= 2) && begin
                                    ##674 = ##673[1]
                                    ##675 = ##673[2]
                                    ##676 = (SubArray)(##673, (3:length(##673),))
                                    true
                                end)))
                line = ##675
                name = ##674
                xs = ##676
                ##return#628 = begin
                        print_expr(io, line, ps, theme)
                        println(io, ps)
                        within_line(io, ps) do 
                            with_color(theme.fn, ps) do 
                                print_expr(io, name, ps, theme)
                            end
                            print(io, tab(1))
                            print_collection(io, xs, ps, theme; delim=tab(1))
                        end
                    end
                $(Expr(:symbolicgoto, Symbol("####final#629#697")))
            end
            if begin
                        ##677 = (##cache#631).value
                        ##677 isa Tuple{Symbol,var2} where var2<:AbstractArray
                    end && (##677[1] == :struct && (begin
                                ##678 = ##677[2]
                                ##678 isa AbstractArray
                            end && (length(##678) === 3 && begin
                                    ##679 = ##678[1]
                                    ##680 = ##678[2]
                                    ##681 = ##678[3]
                                    true
                                end)))
                ismutable = ##679
                body = ##681
                head = ##680
                ##return#628 = begin
                        within_line(io, ps) do 
                            if ismutable
                                printstyled(io, "mutable "; color=theme.kw)
                            end
                            printstyled(io, "struct "; color=theme.kw)
                            print_expr(io, head, ps, theme)
                        end
                        println(io, ps)
                        print_stmts(io, body, ps, theme)
                        print_end(io, ps, theme)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#629#697")))
            end
            if begin
                        ##682 = (##cache#631).value
                        ##682 isa Tuple{Symbol,var2} where var2<:AbstractArray
                    end && (##682[1] == :try && (begin
                                ##683 = ##682[2]
                                ##683 isa AbstractArray
                            end && (length(##683) === 3 && begin
                                    ##684 = ##683[1]
                                    ##685 = ##683[2]
                                    ##686 = ##683[3]
                                    true
                                end)))
                catch_body = ##686
                try_body = ##684
                catch_var = ##685
                ##return#628 = begin
                        print_try(io, try_body, ps, theme)
                        print_catch(io, catch_var, catch_body, ps, theme)
                        print_end(io, ps, theme)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#629#697")))
            end
            if begin
                        ##687 = (##cache#631).value
                        ##687 isa Tuple{Symbol,var2} where var2<:AbstractArray
                    end && (##687[1] == :try && (begin
                                ##688 = ##687[2]
                                ##688 isa AbstractArray
                            end && (length(##688) === 4 && (begin
                                        ##689 = ##688[1]
                                        ##688[2] === false
                                    end && (##688[3] === false && begin
                                            ##690 = ##688[4]
                                            true
                                        end)))))
                try_body = ##689
                finally_body = ##690
                ##return#628 = begin
                        print_try(io, try_body, ps, theme)
                        print_finally(io, finally_body, ps, theme)
                        print_end(io, ps, theme)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#629#697")))
            end
            if begin
                        ##691 = (##cache#631).value
                        ##691 isa Tuple{Symbol,var2} where var2<:AbstractArray
                    end && (##691[1] == :try && (begin
                                ##692 = ##691[2]
                                ##692 isa AbstractArray
                            end && (length(##692) === 4 && begin
                                    ##693 = ##692[1]
                                    ##694 = ##692[2]
                                    ##695 = ##692[3]
                                    ##696 = ##692[4]
                                    true
                                end)))
                catch_body = ##695
                try_body = ##693
                finally_body = ##696
                catch_var = ##694
                ##return#628 = begin
                        print_try(io, try_body, ps, theme)
                        print_catch(io, catch_var, catch_body, ps, theme)
                        print_finally(io, finally_body, ps, theme)
                        print_end(io, ps, theme)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#629#697")))
            end
        end
        ##return#628 = begin
                print_within_line(io, ex, ps, theme)
            end
        $(Expr(:symbolicgoto, Symbol("####final#629#697")))
        (error)("matching non-exhaustive, at #= none:58 =#")
        $(Expr(:symboliclabel, Symbol("####final#629#697")))
        ##return#628
    end
    function print_kw(io::IO, x, ps, theme::Color)
        print(io, tab(ps.line_indent))
        printstyled(io, x; color=theme.kw)
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
    function print_collection(io, xs, ps::PrintState, theme=Color(); delim=", ")
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
    function print_within_line(io::IO, ex, ps::PrintState, theme::Color=Color())
        within_line(io, ps) do 
            ##cache#701 = nothing
            ##700 = ex
            if ##700 isa Number
                ##return#698 = begin
                        printstyled(io, ex; color=theme.literal)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#699#793")))
            end
            if ##700 isa GlobalRef
                ##return#698 = begin
                        printstyled(io, ex.mod, "."; color=ps.color)
                        print_expr(io, ex.name, ps, theme)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#699#793")))
            end
            if ##700 isa LineNumberNode
                ##return#698 = begin
                        printstyled(io, ex; color=theme.comment)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#699#793")))
            end
            if ##700 isa QuoteNode
                ##return#698 = begin
                        if Base.isidentifier(ex.value)
                            print(io, ":", ex.value)
                        else
                            print(io, ":(", ex.value, ")")
                        end
                    end
                $(Expr(:symbolicgoto, Symbol("####final#699#793")))
            end
            if ##700 isa Expr
                if begin
                            if ##cache#701 === nothing
                                ##cache#701 = Some(((##700).head, (##700).args))
                            end
                            ##702 = (##cache#701).value
                            ##702 isa Tuple{Symbol,var2} where var2<:AbstractArray
                        end && (##702[1] == :tuple && (begin
                                    ##703 = ##702[2]
                                    ##703 isa AbstractArray
                                end && ((ndims(##703) === 1 && length(##703) >= 1) && (begin
                                            ##cache#705 = nothing
                                            ##704 = ##703[1]
                                            ##704 isa Expr
                                        end && (begin
                                                if ##cache#705 === nothing
                                                    ##cache#705 = Some(((##704).head, (##704).args))
                                                end
                                                ##706 = (##cache#705).value
                                                ##706 isa Tuple{Symbol,var2} where var2<:AbstractArray
                                            end && (##706[1] == :parameters && (begin
                                                        ##707 = ##706[2]
                                                        ##707 isa AbstractArray
                                                    end && ((ndims(##707) === 1 && length(##707) >= 0) && begin
                                                            ##708 = (SubArray)(##707, (1:length(##707),))
                                                            ##709 = (SubArray)(##703, (2:length(##703),))
                                                            true
                                                        end))))))))
                    args = ##709
                    kwargs = ##708
                    ##return#698 = begin
                            printstyled(io, "("; color=ps.color)
                            print_collection(io, args, ps, theme)
                            if !(isempty(kwargs))
                                printstyled(io, "; "; color=ps.color)
                                print_collection(io, kwargs, ps)
                            end
                            printstyled(io, ")"; color=ps.color)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#699#793")))
                end
                if begin
                            ##710 = (##cache#701).value
                            ##710 isa Tuple{Symbol,var2} where var2<:AbstractArray
                        end && (##710[1] == :tuple && (begin
                                    ##711 = ##710[2]
                                    ##711 isa AbstractArray
                                end && ((ndims(##711) === 1 && length(##711) >= 0) && begin
                                        ##712 = (SubArray)(##711, (1:length(##711),))
                                        true
                                    end)))
                    xs = ##712
                    ##return#698 = begin
                            printstyled(io, "("; color=ps.color)
                            print_collection(io, xs, ps)
                            printstyled(io, ")"; color=ps.color)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#699#793")))
                end
                if begin
                            ##713 = (##cache#701).value
                            ##713 isa Tuple{Symbol,var2} where var2<:AbstractArray
                        end && (##713[1] == :(::) && (begin
                                    ##714 = ##713[2]
                                    ##714 isa AbstractArray
                                end && (length(##714) === 1 && begin
                                        ##715 = ##714[1]
                                        true
                                    end)))
                    type = ##715
                    ##return#698 = begin
                            printstyled(io, "::"; color=ps.color)
                            with_color(theme.type, ps) do 
                                print_expr(io, type, ps, theme)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#699#793")))
                end
                if begin
                            ##716 = (##cache#701).value
                            ##716 isa Tuple{Symbol,var2} where var2<:AbstractArray
                        end && (##716[1] == :(::) && (begin
                                    ##717 = ##716[2]
                                    ##717 isa AbstractArray
                                end && (length(##717) === 2 && begin
                                        ##718 = ##717[1]
                                        ##719 = ##717[2]
                                        true
                                    end)))
                    type = ##719
                    name = ##718
                    ##return#698 = begin
                            print_expr(io, name, ps, theme)
                            printstyled(io, "::"; color=ps.color)
                            with_color(theme.type, ps) do 
                                print_expr(io, type, ps, theme)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#699#793")))
                end
                if begin
                            ##720 = (##cache#701).value
                            ##720 isa Tuple{Symbol,var2} where var2<:AbstractArray
                        end && (##720[1] == :<: && (begin
                                    ##721 = ##720[2]
                                    ##721 isa AbstractArray
                                end && (length(##721) === 2 && begin
                                        ##722 = ##721[1]
                                        ##723 = ##721[2]
                                        true
                                    end)))
                    type = ##723
                    name = ##722
                    ##return#698 = begin
                            print_expr(io, name, ps, theme)
                            printstyled(io, " <: "; color=ps.color)
                            with_color(theme.type, ps) do 
                                print_expr(io, type, ps, theme)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#699#793")))
                end
                if begin
                            ##724 = (##cache#701).value
                            ##724 isa Tuple{Symbol,var2} where var2<:AbstractArray
                        end && (##724[1] == :kw && (begin
                                    ##725 = ##724[2]
                                    ##725 isa AbstractArray
                                end && (length(##725) === 2 && begin
                                        ##726 = ##725[1]
                                        ##727 = ##725[2]
                                        true
                                    end)))
                    value = ##727
                    name = ##726
                    ##return#698 = begin
                            print_expr(io, name, ps, theme)
                            printstyled(io, tab(1), "=", tab(1); color=ps.color)
                            print_expr(io, value, ps, theme)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#699#793")))
                end
                if begin
                            ##728 = (##cache#701).value
                            ##728 isa Tuple{Symbol,var2} where var2<:AbstractArray
                        end && (##728[1] == :(=) && (begin
                                    ##729 = ##728[2]
                                    ##729 isa AbstractArray
                                end && (length(##729) === 2 && begin
                                        ##730 = ##729[1]
                                        ##731 = ##729[2]
                                        true
                                    end)))
                    value = ##731
                    name = ##730
                    ##return#698 = begin
                            print_expr(io, name, ps, theme)
                            printstyled(io, tab(1), "=", tab(1); color=ps.color)
                            print_expr(io, value, ps, theme)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#699#793")))
                end
                if begin
                            ##732 = (##cache#701).value
                            ##732 isa Tuple{Symbol,var2} where var2<:AbstractArray
                        end && (##732[1] == :... && (begin
                                    ##733 = ##732[2]
                                    ##733 isa AbstractArray
                                end && (length(##733) === 1 && begin
                                        ##734 = ##733[1]
                                        true
                                    end)))
                    name = ##734
                    ##return#698 = begin
                            print_expr(io, name, ps, theme)
                            print(io, "...")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#699#793")))
                end
                if begin
                            ##735 = (##cache#701).value
                            ##735 isa Tuple{Symbol,var2} where var2<:AbstractArray
                        end && (##735[1] == :& && (begin
                                    ##736 = ##735[2]
                                    ##736 isa AbstractArray
                                end && (length(##736) === 1 && begin
                                        ##737 = ##736[1]
                                        true
                                    end)))
                    name = ##737
                    ##return#698 = begin
                            printstyled(io, "&"; color=theme.kw)
                            print_expr(io, name, ps, theme)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#699#793")))
                end
                if begin
                            ##738 = (##cache#701).value
                            ##738 isa Tuple{Symbol,var2} where var2<:AbstractArray
                        end && (##738[1] == :$ && (begin
                                    ##739 = ##738[2]
                                    ##739 isa AbstractArray
                                end && (length(##739) === 1 && begin
                                        ##740 = ##739[1]
                                        true
                                    end)))
                    name = ##740
                    ##return#698 = begin
                            printstyled(io, "\$"; color=theme.kw)
                            print(io, "(")
                            print_expr(io, name, ps, theme)
                            print(io, ")")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#699#793")))
                end
                if begin
                            ##741 = (##cache#701).value
                            ##741 isa Tuple{Symbol,var2} where var2<:AbstractArray
                        end && (##741[1] == :curly && (begin
                                    ##742 = ##741[2]
                                    ##742 isa AbstractArray
                                end && ((ndims(##742) === 1 && length(##742) >= 1) && begin
                                        ##743 = ##742[1]
                                        ##744 = (SubArray)(##742, (2:length(##742),))
                                        true
                                    end)))
                    vars = ##744
                    name = ##743
                    ##return#698 = begin
                            print_expr(io, name, ps, theme)
                            print(io, "{")
                            with_color(theme.type, ps) do 
                                print_collection(io, vars, ps, theme)
                            end
                            print(io, "}")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#699#793")))
                end
                if begin
                            ##745 = (##cache#701).value
                            ##745 isa Tuple{Symbol,var2} where var2<:AbstractArray
                        end && (##745[1] == :ref && (begin
                                    ##746 = ##745[2]
                                    ##746 isa AbstractArray
                                end && ((ndims(##746) === 1 && length(##746) >= 1) && begin
                                        ##747 = ##746[1]
                                        ##748 = (SubArray)(##746, (2:length(##746),))
                                        true
                                    end)))
                    name = ##747
                    xs = ##748
                    ##return#698 = begin
                            print_expr(io, name, ps, theme)
                            print(io, "[")
                            print_collection(io, xs, ps, theme)
                            print(io, "]")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#699#793")))
                end
                if begin
                            ##749 = (##cache#701).value
                            ##749 isa Tuple{Symbol,var2} where var2<:AbstractArray
                        end && (##749[1] == :where && (begin
                                    ##750 = ##749[2]
                                    ##750 isa AbstractArray
                                end && ((ndims(##750) === 1 && length(##750) >= 1) && begin
                                        ##751 = ##750[1]
                                        ##752 = (SubArray)(##750, (2:length(##750),))
                                        true
                                    end)))
                    body = ##751
                    whereparams = ##752
                    ##return#698 = begin
                            print_expr(io, body, ps, theme)
                            printstyled(io, tab(1), "where", tab(1); color=theme.kw)
                            print(io, "{")
                            print_collection(io, whereparams, ps, theme)
                            print(io, "}")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#699#793")))
                end
                if begin
                            ##753 = (##cache#701).value
                            ##753 isa Tuple{Symbol,var2} where var2<:AbstractArray
                        end && (##753[1] == :call && (begin
                                    ##754 = ##753[2]
                                    ##754 isa AbstractArray
                                end && ((ndims(##754) === 1 && length(##754) >= 2) && (begin
                                            ##755 = ##754[1]
                                            ##cache#757 = nothing
                                            ##756 = ##754[2]
                                            ##756 isa Expr
                                        end && (begin
                                                if ##cache#757 === nothing
                                                    ##cache#757 = Some(((##756).head, (##756).args))
                                                end
                                                ##758 = (##cache#757).value
                                                ##758 isa Tuple{Symbol,var2} where var2<:AbstractArray
                                            end && (##758[1] == :parameters && (begin
                                                        ##759 = ##758[2]
                                                        ##759 isa AbstractArray
                                                    end && ((ndims(##759) === 1 && length(##759) >= 0) && begin
                                                            ##760 = (SubArray)(##759, (1:length(##759),))
                                                            ##761 = (SubArray)(##754, (3:length(##754),))
                                                            true
                                                        end))))))))
                    name = ##755
                    args = ##761
                    kwargs = ##760
                    ##return#698 = begin
                            print_expr(io, name, ps, theme)
                            printstyled(io, "("; color=ps.color)
                            print_collection(io, args, ps)
                            if !(isempty(kwargs))
                                printstyled(io, "; "; color=ps.color)
                                print_collection(io, kwargs, ps)
                            end
                            printstyled(io, ")"; color=ps.color)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#699#793")))
                end
                if begin
                            ##762 = (##cache#701).value
                            ##762 isa Tuple{Symbol,var2} where var2<:AbstractArray
                        end && (##762[1] == :call && (begin
                                    ##763 = ##762[2]
                                    ##763 isa AbstractArray
                                end && ((ndims(##763) === 1 && length(##763) >= 1) && (##763[1] == :(:) && begin
                                            ##764 = (SubArray)(##763, (2:length(##763),))
                                            true
                                        end))))
                    xs = ##764
                    ##return#698 = begin
                            print_collection(io, xs, ps, theme; delim=":")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#699#793")))
                end
                if begin
                            ##765 = (##cache#701).value
                            ##765 isa Tuple{Symbol,var2} where var2<:AbstractArray
                        end && (##765[1] == :call && (begin
                                    ##766 = ##765[2]
                                    ##766 isa AbstractArray
                                end && (length(##766) === 2 && (begin
                                            ##767 = ##766[1]
                                            ##767 isa Symbol
                                        end && begin
                                            ##768 = ##766[2]
                                            true
                                        end))))
                    name = ##767
                    x = ##768
                    ##return#698 = begin
                            if name in uni_ops
                                print_expr(io, name, ps, theme)
                                print_expr(io, x, ps, theme)
                            else
                                print_call_expr(io, name, [x], ps, theme)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#699#793")))
                end
                if begin
                            ##769 = (##cache#701).value
                            ##769 isa Tuple{Symbol,var2} where var2<:AbstractArray
                        end && (##769[1] == :call && (begin
                                    ##770 = ##769[2]
                                    ##770 isa AbstractArray
                                end && (length(##770) === 3 && begin
                                        ##771 = ##770[1]
                                        ##772 = ##770[2]
                                        ##773 = ##770[3]
                                        true
                                    end)))
                    rhs = ##773
                    lhs = ##772
                    name = ##771
                    ##return#698 = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#699#793")))
                end
                if begin
                            ##774 = (##cache#701).value
                            ##774 isa Tuple{Symbol,var2} where var2<:AbstractArray
                        end && (##774[1] == :call && (begin
                                    ##775 = ##774[2]
                                    ##775 isa AbstractArray
                                end && ((ndims(##775) === 1 && length(##775) >= 1) && begin
                                        ##776 = ##775[1]
                                        ##777 = (SubArray)(##775, (2:length(##775),))
                                        true
                                    end)))
                    name = ##776
                    args = ##777
                    ##return#698 = begin
                            print_call_expr(io, name, args, ps, theme)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#699#793")))
                end
                if begin
                            ##778 = (##cache#701).value
                            ##778 isa Tuple{Symbol,var2} where var2<:AbstractArray
                        end && (##778[1] == :-> && (begin
                                    ##779 = ##778[2]
                                    ##779 isa AbstractArray
                                end && (length(##779) === 2 && begin
                                        ##780 = ##779[1]
                                        ##781 = ##779[2]
                                        true
                                    end)))
                    call = ##780
                    body = ##781
                    ##return#698 = begin
                            print_expr(io, call, ps, theme)
                            printstyled(io, tab(1), "->", tab(1); color=theme.kw)
                            print_expr(io, body, ps, theme)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#699#793")))
                end
                if begin
                            ##782 = (##cache#701).value
                            ##782 isa Tuple{Symbol,var2} where var2<:AbstractArray
                        end && (##782[1] == :return && (begin
                                    ##783 = ##782[2]
                                    ##783 isa AbstractArray
                                end && (length(##783) === 1 && begin
                                        ##784 = ##783[1]
                                        true
                                    end)))
                    x = ##784
                    ##return#698 = begin
                            printstyled(io, "return", tab(1); color=theme.kw)
                            let
                                ##cache#797 = nothing
                                ##return#794 = nothing
                                ##796 = x
                                if ##796 isa Expr && (begin
                                                if ##cache#797 === nothing
                                                    ##cache#797 = Some(((##796).head, (##796).args))
                                                end
                                                ##798 = (##cache#797).value
                                                ##798 isa Tuple{Symbol,var2} where var2<:AbstractArray
                                            end && (##798[1] == :tuple && (begin
                                                        ##799 = ##798[2]
                                                        ##799 isa AbstractArray
                                                    end && ((ndims(##799) === 1 && length(##799) >= 0) && begin
                                                            ##800 = (SubArray)(##799, (1:length(##799),))
                                                            true
                                                        end))))
                                    ##return#794 = let xs = ##800
                                            print_collection(io, xs, ps)
                                        end
                                    $(Expr(:symbolicgoto, Symbol("####final#795#801")))
                                end
                                ##return#794 = let
                                        print_expr(io, x, ps, theme)
                                    end
                                $(Expr(:symbolicgoto, Symbol("####final#795#801")))
                                (error)("matching non-exhaustive, at #= none:388 =#")
                                $(Expr(:symboliclabel, Symbol("####final#795#801")))
                                ##return#794
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#699#793")))
                end
                if begin
                            ##785 = (##cache#701).value
                            ##785 isa Tuple{Symbol,var2} where var2<:AbstractArray
                        end && (##785[1] == :string && (begin
                                    ##786 = ##785[2]
                                    ##786 isa AbstractArray
                                end && ((ndims(##786) === 1 && length(##786) >= 0) && begin
                                        ##787 = (SubArray)(##786, (1:length(##786),))
                                        true
                                    end)))
                    xs = ##787
                    ##return#698 = begin
                            printstyled(io, "\""; color=theme.string)
                            for x = xs
                                if x isa String
                                    printstyled(io, x; color=theme.string)
                                else
                                    printstyled(io, "\$"; color=theme.literal)
                                    with_color(theme.literal, ps) do 
                                        print_expr(io, x, ps, theme)
                                    end
                                end
                            end
                            printstyled(io, "\""; color=theme.string)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#699#793")))
                end
                if begin
                            ##788 = (##cache#701).value
                            ##788 isa Tuple{var1,var2} where var1 where var2<:AbstractArray
                        end && (begin
                                ##789 = ##788[1]
                                ##790 = ##788[2]
                                ##790 isa AbstractArray
                            end && (length(##790) === 2 && begin
                                    ##791 = ##790[1]
                                    ##792 = ##790[2]
                                    true
                                end))
                    rhs = ##792
                    lhs = ##791
                    head = ##789
                    ##return#698 = begin
                            if head in expr_infix_wide
                                print_expr(io, lhs, ps, theme)
                                printstyled(io, tab(1), head, tab(1); color=theme.kw)
                                print_expr(io, rhs, ps, theme)
                            else
                                Base.show_unquoted_quote_expr(IOContext(io, :unquote_fallback => true), ex, ps.line_indent, -1, 0)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#699#793")))
                end
            end
            if ##700 isa String
                ##return#698 = begin
                        printstyled(io, "\"", ex, "\""; color=theme.string)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#699#793")))
            end
            if ##700 isa Symbol
                ##return#698 = begin
                        printstyled(io, ex; color=ps.color)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#699#793")))
            end
            if ##700 isa Nothing
                ##return#698 = begin
                        printstyled(io, "nothing"; color=:blue)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#699#793")))
            end
            if ##700 isa Base.ExprNode
                ##return#698 = begin
                        Base.show_unquoted_quote_expr(IOContext(io, :unquote_fallback => true), ex, ps.line_indent, -1, 0)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#699#793")))
            end
            ##return#698 = begin
                    print(io, ex)
                end
            $(Expr(:symbolicgoto, Symbol("####final#699#793")))
            (error)("matching non-exhaustive, at #= none:269 =#")
            $(Expr(:symboliclabel, Symbol("####final#699#793")))
            ##return#698
        end
        return
    end
    function print_call_expr(io::IO, name, args, ps, theme)
        print_expr(io, name, ps, theme)
        printstyled(io, "("; color=ps.color)
        print_collection(io, args, ps, theme)
        printstyled(io, ")"; color=ps.color)
    end
end
