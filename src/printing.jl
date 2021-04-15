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
        var"##cache#517" = nothing
        var"##516" = ex
        if var"##516" isa Expr
            if begin
                        if var"##cache#517" === nothing
                            var"##cache#517" = Some(((var"##516").head, (var"##516").args))
                        end
                        var"##518" = (var"##cache#517").value
                        var"##518" isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (var"##518"[1] == :block && (begin
                                var"##519" = var"##518"[2]
                                var"##519" isa AbstractArray
                            end && (length(var"##519") === 2 && (begin
                                        var"##520" = var"##519"[1]
                                        var"##520" isa LineNumberNode
                                    end && begin
                                        var"##521" = var"##519"[2]
                                        true
                                    end))))
                stmt = var"##521"
                line = var"##520"
                var"##return#514" = begin
                        print_expr(io, stmt, ps, theme)
                        print(io, tab(2))
                        print_expr(io, line, ps, theme)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#515#608")))
            end
            if begin
                        var"##522" = (var"##cache#517").value
                        var"##522" isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (var"##522"[1] == :block && (begin
                                var"##523" = var"##522"[2]
                                var"##523" isa AbstractArray
                            end && ((ndims(var"##523") === 1 && length(var"##523") >= 2) && (begin
                                        var"##524" = var"##523"[1]
                                        var"##524" isa LineNumberNode
                                    end && (begin
                                            var"##525" = var"##523"[2]
                                            var"##525" isa LineNumberNode
                                        end && begin
                                            var"##526" = (SubArray)(var"##523", (3:length(var"##523"),))
                                            true
                                        end)))))
                line2 = var"##525"
                stmts = var"##526"
                line1 = var"##524"
                var"##return#514" = begin
                        print_kw(io, "begin", ps, theme)
                        println(io, ps)
                        print_stmts_list(io, ex.args, ps, theme)
                        print_end(io, ps, theme)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#515#608")))
            end
            if begin
                        var"##527" = (var"##cache#517").value
                        var"##527" isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (var"##527"[1] == :block && (begin
                                var"##528" = var"##527"[2]
                                var"##528" isa AbstractArray
                            end && (length(var"##528") === 3 && (begin
                                        var"##529" = var"##528"[1]
                                        var"##530" = var"##528"[2]
                                        var"##530" isa LineNumberNode
                                    end && begin
                                        var"##531" = var"##528"[3]
                                        true
                                    end))))
                line = var"##530"
                stmt2 = var"##531"
                stmt1 = var"##529"
                var"##return#514" = begin
                        printstyled(io, "("; color = ps.color)
                        print_expr(io, stmt1, ps, theme)
                        printstyled(io, "; "; color = ps.color)
                        print_expr(io, stmt2)
                        printstyled(io, ")"; color = ps.color)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#515#608")))
            end
            if begin
                        var"##532" = (var"##cache#517").value
                        var"##532" isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (var"##532"[1] == :block && (begin
                                var"##533" = var"##532"[2]
                                var"##533" isa AbstractArray
                            end && ((ndims(var"##533") === 1 && length(var"##533") >= 0) && begin
                                    var"##534" = (SubArray)(var"##533", (1:length(var"##533"),))
                                    true
                                end)))
                stmts = var"##534"
                var"##return#514" = begin
                        print_kw(io, "begin", ps, theme)
                        println(io, ps)
                        print_stmts_list(io, stmts, ps, theme)
                        print_end(io, ps, theme)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#515#608")))
            end
            if begin
                        var"##535" = (var"##cache#517").value
                        var"##535" isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (var"##535"[1] == :let && (begin
                                var"##536" = var"##535"[2]
                                var"##536" isa AbstractArray
                            end && (length(var"##536") === 2 && begin
                                    var"##537" = var"##536"[1]
                                    var"##538" = var"##536"[2]
                                    true
                                end)))
                vars = var"##537"
                body = var"##538"
                var"##return#514" = begin
                        print_kw(io, "let", ps, theme)
                        if !(isempty(vars.args))
                            print(io, tab(1))
                            print_collection(io, vars.args, ps, theme)
                        end
                        println(io, ps)
                        print_stmts(io, body, ps, theme)
                        print_end(io, ps, theme)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#515#608")))
            end
            if begin
                        var"##539" = (var"##cache#517").value
                        var"##539" isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (var"##539"[1] == :if && (begin
                                var"##540" = var"##539"[2]
                                var"##540" isa AbstractArray
                            end && ((ndims(var"##540") === 1 && length(var"##540") >= 2) && begin
                                    var"##541" = var"##540"[1]
                                    var"##542" = var"##540"[2]
                                    var"##543" = (SubArray)(var"##540", (3:length(var"##540"),))
                                    true
                                end)))
                cond = var"##541"
                body = var"##542"
                otherwise = var"##543"
                var"##return#514" = begin
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
                $(Expr(:symbolicgoto, Symbol("####final#515#608")))
            end
            if begin
                        var"##544" = (var"##cache#517").value
                        var"##544" isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (var"##544"[1] == :elseif && (begin
                                var"##545" = var"##544"[2]
                                var"##545" isa AbstractArray
                            end && ((ndims(var"##545") === 1 && length(var"##545") >= 2) && begin
                                    var"##546" = var"##545"[1]
                                    var"##547" = var"##545"[2]
                                    var"##548" = (SubArray)(var"##545", (3:length(var"##545"),))
                                    true
                                end)))
                cond = var"##546"
                body = var"##547"
                otherwise = var"##548"
                var"##return#514" = begin
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
                $(Expr(:symbolicgoto, Symbol("####final#515#608")))
            end
            if begin
                        var"##549" = (var"##cache#517").value
                        var"##549" isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (var"##549"[1] == :for && (begin
                                var"##550" = var"##549"[2]
                                var"##550" isa AbstractArray
                            end && (length(var"##550") === 2 && begin
                                    var"##551" = var"##550"[1]
                                    var"##552" = var"##550"[2]
                                    true
                                end)))
                body = var"##552"
                head = var"##551"
                var"##return#514" = begin
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
                $(Expr(:symbolicgoto, Symbol("####final#515#608")))
            end
            if begin
                        var"##553" = (var"##cache#517").value
                        var"##553" isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (var"##553"[1] == :function && (begin
                                var"##554" = var"##553"[2]
                                var"##554" isa AbstractArray
                            end && (length(var"##554") === 2 && begin
                                    var"##555" = var"##554"[1]
                                    var"##556" = var"##554"[2]
                                    true
                                end)))
                call = var"##555"
                body = var"##556"
                var"##return#514" = begin
                        within_line(io, ps) do 
                            print_kw(io, "function ", ps, theme)
                            print_expr(io, call, ps, theme)
                        end
                        println(io, ps)
                        print_stmts(io, body, ps, theme)
                        print_end(io, ps, theme)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#515#608")))
            end
            if begin
                        var"##557" = (var"##cache#517").value
                        var"##557" isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (var"##557"[1] == :macro && (begin
                                var"##558" = var"##557"[2]
                                var"##558" isa AbstractArray
                            end && (length(var"##558") === 2 && begin
                                    var"##559" = var"##558"[1]
                                    var"##560" = var"##558"[2]
                                    true
                                end)))
                call = var"##559"
                body = var"##560"
                var"##return#514" = begin
                        within_line(io, ps) do 
                            print_kw(io, "macro ", ps, theme)
                            print_expr(io, call, ps, theme)
                        end
                        println(io, ps)
                        print_stmts(io, body, ps, theme)
                        print_end(io, ps, theme)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#515#608")))
            end
            if begin
                        var"##561" = (var"##cache#517").value
                        var"##561" isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (var"##561"[1] == :macrocall && (begin
                                var"##562" = var"##561"[2]
                                var"##562" isa AbstractArray
                            end && (length(var"##562") === 4 && (begin
                                        var"##563" = var"##562"[1]
                                        var"##563" == GlobalRef(Core, Symbol("@doc"))
                                    end && begin
                                        var"##564" = var"##562"[2]
                                        var"##565" = var"##562"[3]
                                        var"##566" = var"##562"[4]
                                        true
                                    end))))
                line = var"##564"
                code = var"##566"
                doc = var"##565"
                var"##return#514" = begin
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
                $(Expr(:symbolicgoto, Symbol("####final#515#608")))
            end
            if begin
                        var"##567" = (var"##cache#517").value
                        var"##567" isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (var"##567"[1] == :macrocall && (begin
                                var"##568" = var"##567"[2]
                                var"##568" isa AbstractArray
                            end && (length(var"##568") === 2 && (begin
                                        var"##cache#570" = nothing
                                        var"##569" = var"##568"[1]
                                        if var"##cache#570" === nothing
                                            var"##cache#570" = Some(((Val{(view, Symbol("##Symbol(x)#258"))}())())(var"##569"))
                                        end
                                        (var"##cache#570").value !== nothing && ((var"##cache#570").value isa Some || (error)("invalid use of active patterns: 1-ary view pattern(Symbol(x)) should accept Union{Some{T}, Nothing} instead of Union{T, Nothing}! A simple solution is:\n  (@active Symbol(x) ex) =>\n  (@active Symbol(x) let r=ex; r === nothing? r : Some(r)) end"))
                                    end && (begin
                                            var"##571" = (var"##cache#570").value
                                            var"##571" isa Some{T} where T<:AbstractString
                                        end && (var"##571" !== nothing && ((var"##571").value == "@__MODULE__" && begin
                                                    var"##572" = var"##568"[2]
                                                    true
                                                end)))))))
                line = var"##572"
                var"##return#514" = begin
                        with_color(theme.fn, ps) do 
                            print_expr(io, Symbol("@__MODULE__"), ps, theme)
                        end
                    end
                $(Expr(:symbolicgoto, Symbol("####final#515#608")))
            end
            if begin
                        var"##573" = (var"##cache#517").value
                        var"##573" isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (var"##573"[1] == :macrocall && (begin
                                var"##574" = var"##573"[2]
                                var"##574" isa AbstractArray
                            end && (length(var"##574") === 3 && (begin
                                        var"##575" = var"##574"[1]
                                        var"##575" isa Symbol
                                    end && begin
                                        var"##576" = var"##574"[2]
                                        var"##577" = var"##574"[3]
                                        var"##577" isa String
                                    end))))
                line = var"##576"
                s = var"##577"
                name = var"##575"
                var"##return#514" = begin
                        if endswith(string(name), "_str")
                            printstyled(io, (string(name))[2:end - 4]; color = theme.fn)
                            print_expr(s)
                        else
                            print_macro(io, name, line, (s,), ps, theme)
                        end
                    end
                $(Expr(:symbolicgoto, Symbol("####final#515#608")))
            end
            if begin
                        var"##578" = (var"##cache#517").value
                        var"##578" isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (var"##578"[1] == :macrocall && (begin
                                var"##579" = var"##578"[2]
                                var"##579" isa AbstractArray
                            end && ((ndims(var"##579") === 1 && length(var"##579") >= 2) && begin
                                    var"##580" = var"##579"[1]
                                    var"##581" = var"##579"[2]
                                    var"##582" = (SubArray)(var"##579", (3:length(var"##579"),))
                                    true
                                end)))
                line = var"##581"
                name = var"##580"
                xs = var"##582"
                var"##return#514" = begin
                        print_macro(io, name, line, xs, ps, theme)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#515#608")))
            end
            if begin
                        var"##583" = (var"##cache#517").value
                        var"##583" isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (var"##583"[1] == :struct && (begin
                                var"##584" = var"##583"[2]
                                var"##584" isa AbstractArray
                            end && (length(var"##584") === 3 && begin
                                    var"##585" = var"##584"[1]
                                    var"##586" = var"##584"[2]
                                    var"##587" = var"##584"[3]
                                    true
                                end)))
                ismutable = var"##585"
                body = var"##587"
                head = var"##586"
                var"##return#514" = begin
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
                $(Expr(:symbolicgoto, Symbol("####final#515#608")))
            end
            if begin
                        var"##588" = (var"##cache#517").value
                        var"##588" isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (var"##588"[1] == :try && (begin
                                var"##589" = var"##588"[2]
                                var"##589" isa AbstractArray
                            end && (length(var"##589") === 3 && begin
                                    var"##590" = var"##589"[1]
                                    var"##591" = var"##589"[2]
                                    var"##592" = var"##589"[3]
                                    true
                                end)))
                catch_body = var"##592"
                try_body = var"##590"
                catch_var = var"##591"
                var"##return#514" = begin
                        print_try(io, try_body, ps, theme)
                        print_catch(io, catch_var, catch_body, ps, theme)
                        print_end(io, ps, theme)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#515#608")))
            end
            if begin
                        var"##593" = (var"##cache#517").value
                        var"##593" isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (var"##593"[1] == :try && (begin
                                var"##594" = var"##593"[2]
                                var"##594" isa AbstractArray
                            end && (length(var"##594") === 4 && (begin
                                        var"##595" = var"##594"[1]
                                        var"##594"[2] === false
                                    end && (var"##594"[3] === false && begin
                                            var"##596" = var"##594"[4]
                                            true
                                        end)))))
                try_body = var"##595"
                finally_body = var"##596"
                var"##return#514" = begin
                        print_try(io, try_body, ps, theme)
                        print_finally(io, finally_body, ps, theme)
                        print_end(io, ps, theme)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#515#608")))
            end
            if begin
                        var"##597" = (var"##cache#517").value
                        var"##597" isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (var"##597"[1] == :try && (begin
                                var"##598" = var"##597"[2]
                                var"##598" isa AbstractArray
                            end && (length(var"##598") === 4 && begin
                                    var"##599" = var"##598"[1]
                                    var"##600" = var"##598"[2]
                                    var"##601" = var"##598"[3]
                                    var"##602" = var"##598"[4]
                                    true
                                end)))
                catch_body = var"##601"
                try_body = var"##599"
                finally_body = var"##602"
                catch_var = var"##600"
                var"##return#514" = begin
                        print_try(io, try_body, ps, theme)
                        print_catch(io, catch_var, catch_body, ps, theme)
                        print_finally(io, finally_body, ps, theme)
                        print_end(io, ps, theme)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#515#608")))
            end
            if begin
                        var"##603" = (var"##cache#517").value
                        var"##603" isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (var"##603"[1] == :module && (begin
                                var"##604" = var"##603"[2]
                                var"##604" isa AbstractArray
                            end && (length(var"##604") === 3 && begin
                                    var"##605" = var"##604"[1]
                                    var"##606" = var"##604"[2]
                                    var"##607" = var"##604"[3]
                                    true
                                end)))
                name = var"##606"
                body = var"##607"
                notbare = var"##605"
                var"##return#514" = begin
                        if notbare
                            print_kw(io, "module", ps, theme)
                        else
                            print_kw(io, "baremodule", ps, theme)
                        end
                        println(io, ps)
                        print_stmts(io, body, ps, theme)
                        print_end(io, ps, theme)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#515#608")))
            end
        end
        var"##return#514" = begin
                print_within_line(io, ex, ps, theme)
            end
        $(Expr(:symbolicgoto, Symbol("####final#515#608")))
        (error)("matching non-exhaustive, at #= none:58 =#")
        $(Expr(:symboliclabel, Symbol("####final#515#608")))
        var"##return#514"
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
            var"##cache#612" = nothing
            var"##611" = ex
            if var"##611" isa GlobalRef
                var"##return#609" = begin
                        printstyled(io, ex.mod, "."; color = ps.color)
                        print_expr(io, ex.name, ps, theme)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#610#718")))
            end
            if var"##611" isa Symbol
                var"##return#609" = begin
                        printstyled(io, ex; color = ps.color)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#610#718")))
            end
            if var"##611" isa Expr
                if begin
                            if var"##cache#612" === nothing
                                var"##cache#612" = Some(((var"##611").head, (var"##611").args))
                            end
                            var"##613" = (var"##cache#612").value
                            var"##613" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##613"[1] == :export && (begin
                                    var"##614" = var"##613"[2]
                                    var"##614" isa AbstractArray
                                end && ((ndims(var"##614") === 1 && length(var"##614") >= 0) && begin
                                        var"##615" = (SubArray)(var"##614", (1:length(var"##614"),))
                                        true
                                    end)))
                    xs = var"##615"
                    var"##return#609" = begin
                            print_kw(io, "export ", ps, theme)
                            print_collection(io, xs, ps, theme)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#610#718")))
                end
                if begin
                            var"##616" = (var"##cache#612").value
                            var"##616" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##616"[1] == :tuple && (begin
                                    var"##617" = var"##616"[2]
                                    var"##617" isa AbstractArray
                                end && ((ndims(var"##617") === 1 && length(var"##617") >= 1) && (begin
                                            var"##cache#619" = nothing
                                            var"##618" = var"##617"[1]
                                            var"##618" isa Expr
                                        end && (begin
                                                if var"##cache#619" === nothing
                                                    var"##cache#619" = Some(((var"##618").head, (var"##618").args))
                                                end
                                                var"##620" = (var"##cache#619").value
                                                var"##620" isa Tuple{Symbol, var2} where var2<:AbstractArray
                                            end && (var"##620"[1] == :parameters && (begin
                                                        var"##621" = var"##620"[2]
                                                        var"##621" isa AbstractArray
                                                    end && ((ndims(var"##621") === 1 && length(var"##621") >= 0) && begin
                                                            var"##622" = (SubArray)(var"##621", (1:length(var"##621"),))
                                                            var"##623" = (SubArray)(var"##617", (2:length(var"##617"),))
                                                            true
                                                        end))))))))
                    args = var"##623"
                    kwargs = var"##622"
                    var"##return#609" = begin
                            printstyled(io, "("; color = ps.color)
                            print_collection(io, args, ps, theme)
                            if !(isempty(kwargs))
                                printstyled(io, "; "; color = ps.color)
                                print_collection(io, kwargs, ps)
                            end
                            printstyled(io, ")"; color = ps.color)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#610#718")))
                end
                if begin
                            var"##624" = (var"##cache#612").value
                            var"##624" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##624"[1] == :tuple && (begin
                                    var"##625" = var"##624"[2]
                                    var"##625" isa AbstractArray
                                end && ((ndims(var"##625") === 1 && length(var"##625") >= 0) && begin
                                        var"##626" = (SubArray)(var"##625", (1:length(var"##625"),))
                                        true
                                    end)))
                    xs = var"##626"
                    var"##return#609" = begin
                            printstyled(io, "("; color = ps.color)
                            print_collection(io, xs, ps)
                            printstyled(io, ")"; color = ps.color)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#610#718")))
                end
                if begin
                            var"##627" = (var"##cache#612").value
                            var"##627" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##627"[1] == :(::) && (begin
                                    var"##628" = var"##627"[2]
                                    var"##628" isa AbstractArray
                                end && (length(var"##628") === 1 && begin
                                        var"##629" = var"##628"[1]
                                        true
                                    end)))
                    type = var"##629"
                    var"##return#609" = begin
                            printstyled(io, "::"; color = ps.color)
                            with_color(theme.type, ps) do 
                                print_expr(io, type, ps, theme)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#610#718")))
                end
                if begin
                            var"##630" = (var"##cache#612").value
                            var"##630" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##630"[1] == :(::) && (begin
                                    var"##631" = var"##630"[2]
                                    var"##631" isa AbstractArray
                                end && (length(var"##631") === 2 && begin
                                        var"##632" = var"##631"[1]
                                        var"##633" = var"##631"[2]
                                        true
                                    end)))
                    type = var"##633"
                    name = var"##632"
                    var"##return#609" = begin
                            print_expr(io, name, ps, theme)
                            printstyled(io, "::"; color = ps.color)
                            with_color(theme.type, ps) do 
                                print_expr(io, type, ps, theme)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#610#718")))
                end
                if begin
                            var"##634" = (var"##cache#612").value
                            var"##634" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##634"[1] == :. && (begin
                                    var"##635" = var"##634"[2]
                                    var"##635" isa AbstractArray
                                end && (length(var"##635") === 2 && begin
                                        var"##636" = var"##635"[1]
                                        var"##637" = var"##635"[2]
                                        var"##637" isa QuoteNode
                                    end)))
                    a = var"##636"
                    b = var"##637"
                    var"##return#609" = begin
                            print_expr(io, a, ps, theme)
                            printstyled(io, "."; color = ps.color)
                            print_expr(io, b.value, ps, theme)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#610#718")))
                end
                if begin
                            var"##638" = (var"##cache#612").value
                            var"##638" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##638"[1] == :. && (begin
                                    var"##639" = var"##638"[2]
                                    var"##639" isa AbstractArray
                                end && (length(var"##639") === 2 && begin
                                        var"##640" = var"##639"[1]
                                        var"##641" = var"##639"[2]
                                        true
                                    end)))
                    a = var"##640"
                    b = var"##641"
                    var"##return#609" = begin
                            print_expr(io, a, ps, theme)
                            printstyled(io, "."; color = ps.color)
                            print_expr(io, b, ps, theme)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#610#718")))
                end
                if begin
                            var"##642" = (var"##cache#612").value
                            var"##642" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##642"[1] == :<: && (begin
                                    var"##643" = var"##642"[2]
                                    var"##643" isa AbstractArray
                                end && (length(var"##643") === 2 && begin
                                        var"##644" = var"##643"[1]
                                        var"##645" = var"##643"[2]
                                        true
                                    end)))
                    type = var"##645"
                    name = var"##644"
                    var"##return#609" = begin
                            print_expr(io, name, ps, theme)
                            printstyled(io, " <: "; color = ps.color)
                            with_color(theme.type, ps) do 
                                print_expr(io, type, ps, theme)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#610#718")))
                end
                if begin
                            var"##646" = (var"##cache#612").value
                            var"##646" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##646"[1] == :kw && (begin
                                    var"##647" = var"##646"[2]
                                    var"##647" isa AbstractArray
                                end && (length(var"##647") === 2 && begin
                                        var"##648" = var"##647"[1]
                                        var"##649" = var"##647"[2]
                                        true
                                    end)))
                    value = var"##649"
                    name = var"##648"
                    var"##return#609" = begin
                            print_expr(io, name, ps, theme)
                            printstyled(io, tab(1), "=", tab(1); color = ps.color)
                            print_expr(io, value, ps, theme)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#610#718")))
                end
                if begin
                            var"##650" = (var"##cache#612").value
                            var"##650" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##650"[1] == :(=) && (begin
                                    var"##651" = var"##650"[2]
                                    var"##651" isa AbstractArray
                                end && (length(var"##651") === 2 && begin
                                        var"##652" = var"##651"[1]
                                        var"##653" = var"##651"[2]
                                        true
                                    end)))
                    value = var"##653"
                    name = var"##652"
                    var"##return#609" = begin
                            print_expr(io, name, ps, theme)
                            printstyled(io, tab(1), "=", tab(1); color = ps.color)
                            print_expr(io, value, ps, theme)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#610#718")))
                end
                if begin
                            var"##654" = (var"##cache#612").value
                            var"##654" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##654"[1] == :... && (begin
                                    var"##655" = var"##654"[2]
                                    var"##655" isa AbstractArray
                                end && (length(var"##655") === 1 && begin
                                        var"##656" = var"##655"[1]
                                        true
                                    end)))
                    name = var"##656"
                    var"##return#609" = begin
                            print_expr(io, name, ps, theme)
                            print(io, "...")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#610#718")))
                end
                if begin
                            var"##657" = (var"##cache#612").value
                            var"##657" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##657"[1] == :& && (begin
                                    var"##658" = var"##657"[2]
                                    var"##658" isa AbstractArray
                                end && (length(var"##658") === 1 && begin
                                        var"##659" = var"##658"[1]
                                        true
                                    end)))
                    name = var"##659"
                    var"##return#609" = begin
                            printstyled(io, "&"; color = theme.kw)
                            print_expr(io, name, ps, theme)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#610#718")))
                end
                if begin
                            var"##660" = (var"##cache#612").value
                            var"##660" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##660"[1] == :$ && (begin
                                    var"##661" = var"##660"[2]
                                    var"##661" isa AbstractArray
                                end && (length(var"##661") === 1 && begin
                                        var"##662" = var"##661"[1]
                                        true
                                    end)))
                    name = var"##662"
                    var"##return#609" = begin
                            printstyled(io, "\$"; color = theme.kw)
                            print(io, "(")
                            print_expr(io, name, ps, theme)
                            print(io, ")")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#610#718")))
                end
                if begin
                            var"##663" = (var"##cache#612").value
                            var"##663" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##663"[1] == :curly && (begin
                                    var"##664" = var"##663"[2]
                                    var"##664" isa AbstractArray
                                end && ((ndims(var"##664") === 1 && length(var"##664") >= 1) && begin
                                        var"##665" = var"##664"[1]
                                        var"##666" = (SubArray)(var"##664", (2:length(var"##664"),))
                                        true
                                    end)))
                    vars = var"##666"
                    name = var"##665"
                    var"##return#609" = begin
                            print_expr(io, name, ps, theme)
                            print(io, "{")
                            with_color(theme.type, ps) do 
                                print_collection(io, vars, ps, theme)
                            end
                            print(io, "}")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#610#718")))
                end
                if begin
                            var"##667" = (var"##cache#612").value
                            var"##667" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##667"[1] == :ref && (begin
                                    var"##668" = var"##667"[2]
                                    var"##668" isa AbstractArray
                                end && ((ndims(var"##668") === 1 && length(var"##668") >= 1) && begin
                                        var"##669" = var"##668"[1]
                                        var"##670" = (SubArray)(var"##668", (2:length(var"##668"),))
                                        true
                                    end)))
                    name = var"##669"
                    xs = var"##670"
                    var"##return#609" = begin
                            print_expr(io, name, ps, theme)
                            print(io, "[")
                            print_collection(io, xs, ps, theme)
                            print(io, "]")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#610#718")))
                end
                if begin
                            var"##671" = (var"##cache#612").value
                            var"##671" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##671"[1] == :where && (begin
                                    var"##672" = var"##671"[2]
                                    var"##672" isa AbstractArray
                                end && ((ndims(var"##672") === 1 && length(var"##672") >= 1) && begin
                                        var"##673" = var"##672"[1]
                                        var"##674" = (SubArray)(var"##672", (2:length(var"##672"),))
                                        true
                                    end)))
                    body = var"##673"
                    whereparams = var"##674"
                    var"##return#609" = begin
                            print_expr(io, body, ps, theme)
                            printstyled(io, tab(1), "where", tab(1); color = theme.kw)
                            print(io, "{")
                            print_collection(io, whereparams, ps, theme)
                            print(io, "}")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#610#718")))
                end
                if begin
                            var"##675" = (var"##cache#612").value
                            var"##675" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##675"[1] == :call && (begin
                                    var"##676" = var"##675"[2]
                                    var"##676" isa AbstractArray
                                end && ((ndims(var"##676") === 1 && length(var"##676") >= 2) && (begin
                                            var"##677" = var"##676"[1]
                                            var"##cache#679" = nothing
                                            var"##678" = var"##676"[2]
                                            var"##678" isa Expr
                                        end && (begin
                                                if var"##cache#679" === nothing
                                                    var"##cache#679" = Some(((var"##678").head, (var"##678").args))
                                                end
                                                var"##680" = (var"##cache#679").value
                                                var"##680" isa Tuple{Symbol, var2} where var2<:AbstractArray
                                            end && (var"##680"[1] == :parameters && (begin
                                                        var"##681" = var"##680"[2]
                                                        var"##681" isa AbstractArray
                                                    end && ((ndims(var"##681") === 1 && length(var"##681") >= 0) && begin
                                                            var"##682" = (SubArray)(var"##681", (1:length(var"##681"),))
                                                            var"##683" = (SubArray)(var"##676", (3:length(var"##676"),))
                                                            true
                                                        end))))))))
                    name = var"##677"
                    args = var"##683"
                    kwargs = var"##682"
                    var"##return#609" = begin
                            print_expr(io, name, ps, theme)
                            printstyled(io, "("; color = ps.color)
                            print_collection(io, args, ps)
                            if !(isempty(kwargs))
                                printstyled(io, "; "; color = ps.color)
                                print_collection(io, kwargs, ps)
                            end
                            printstyled(io, ")"; color = ps.color)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#610#718")))
                end
                if begin
                            var"##684" = (var"##cache#612").value
                            var"##684" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##684"[1] == :call && (begin
                                    var"##685" = var"##684"[2]
                                    var"##685" isa AbstractArray
                                end && ((ndims(var"##685") === 1 && length(var"##685") >= 1) && (var"##685"[1] == :(:) && begin
                                            var"##686" = (SubArray)(var"##685", (2:length(var"##685"),))
                                            true
                                        end))))
                    xs = var"##686"
                    var"##return#609" = begin
                            print_collection(io, xs, ps, theme; delim = ":")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#610#718")))
                end
                if begin
                            var"##687" = (var"##cache#612").value
                            var"##687" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##687"[1] == :call && (begin
                                    var"##688" = var"##687"[2]
                                    var"##688" isa AbstractArray
                                end && (length(var"##688") === 2 && (begin
                                            var"##689" = var"##688"[1]
                                            var"##689" isa Symbol
                                        end && begin
                                            var"##690" = var"##688"[2]
                                            true
                                        end))))
                    name = var"##689"
                    x = var"##690"
                    var"##return#609" = begin
                            if name in uni_ops
                                print_expr(io, name, ps, theme)
                                print_expr(io, x, ps, theme)
                            else
                                print_call_expr(io, name, [x], ps, theme)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#610#718")))
                end
                if begin
                            var"##691" = (var"##cache#612").value
                            var"##691" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##691"[1] == :call && (begin
                                    var"##692" = var"##691"[2]
                                    var"##692" isa AbstractArray
                                end && ((ndims(var"##692") === 1 && length(var"##692") >= 1) && (var"##692"[1] == :+ && begin
                                            var"##693" = (SubArray)(var"##692", (2:length(var"##692"),))
                                            true
                                        end))))
                    xs = var"##693"
                    var"##return#609" = begin
                            print_collection(io, xs, ps, theme; delim = " + ")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#610#718")))
                end
                if begin
                            var"##694" = (var"##cache#612").value
                            var"##694" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##694"[1] == :call && (begin
                                    var"##695" = var"##694"[2]
                                    var"##695" isa AbstractArray
                                end && (length(var"##695") === 3 && begin
                                        var"##696" = var"##695"[1]
                                        var"##697" = var"##695"[2]
                                        var"##698" = var"##695"[3]
                                        true
                                    end)))
                    rhs = var"##698"
                    lhs = var"##697"
                    name = var"##696"
                    var"##return#609" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#610#718")))
                end
                if begin
                            var"##699" = (var"##cache#612").value
                            var"##699" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##699"[1] == :call && (begin
                                    var"##700" = var"##699"[2]
                                    var"##700" isa AbstractArray
                                end && ((ndims(var"##700") === 1 && length(var"##700") >= 1) && begin
                                        var"##701" = var"##700"[1]
                                        var"##702" = (SubArray)(var"##700", (2:length(var"##700"),))
                                        true
                                    end)))
                    name = var"##701"
                    args = var"##702"
                    var"##return#609" = begin
                            print_call_expr(io, name, args, ps, theme)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#610#718")))
                end
                if begin
                            var"##703" = (var"##cache#612").value
                            var"##703" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##703"[1] == :-> && (begin
                                    var"##704" = var"##703"[2]
                                    var"##704" isa AbstractArray
                                end && (length(var"##704") === 2 && begin
                                        var"##705" = var"##704"[1]
                                        var"##706" = var"##704"[2]
                                        true
                                    end)))
                    call = var"##705"
                    body = var"##706"
                    var"##return#609" = begin
                            print_expr(io, call, ps, theme)
                            printstyled(io, tab(1), "->", tab(1); color = theme.kw)
                            print_expr(io, body, ps, theme)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#610#718")))
                end
                if begin
                            var"##707" = (var"##cache#612").value
                            var"##707" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##707"[1] == :return && (begin
                                    var"##708" = var"##707"[2]
                                    var"##708" isa AbstractArray
                                end && (length(var"##708") === 1 && begin
                                        var"##709" = var"##708"[1]
                                        true
                                    end)))
                    x = var"##709"
                    var"##return#609" = begin
                            printstyled(io, "return", tab(1); color = theme.kw)
                            let
                                var"##cache#722" = nothing
                                var"##return#719" = nothing
                                var"##721" = x
                                if var"##721" isa Expr && (begin
                                                if var"##cache#722" === nothing
                                                    var"##cache#722" = Some(((var"##721").head, (var"##721").args))
                                                end
                                                var"##723" = (var"##cache#722").value
                                                var"##723" isa Tuple{Symbol, var2} where var2<:AbstractArray
                                            end && (var"##723"[1] == :tuple && (begin
                                                        var"##724" = var"##723"[2]
                                                        var"##724" isa AbstractArray
                                                    end && ((ndims(var"##724") === 1 && length(var"##724") >= 0) && begin
                                                            var"##725" = (SubArray)(var"##724", (1:length(var"##724"),))
                                                            true
                                                        end))))
                                    var"##return#719" = let xs = var"##725"
                                            print_collection(io, xs, ps)
                                        end
                                    $(Expr(:symbolicgoto, Symbol("####final#720#726")))
                                end
                                var"##return#719" = let
                                        print_expr(io, x, ps, theme)
                                    end
                                $(Expr(:symbolicgoto, Symbol("####final#720#726")))
                                (error)("matching non-exhaustive, at #= none:441 =#")
                                $(Expr(:symboliclabel, Symbol("####final#720#726")))
                                var"##return#719"
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#610#718")))
                end
                if begin
                            var"##710" = (var"##cache#612").value
                            var"##710" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##710"[1] == :string && (begin
                                    var"##711" = var"##710"[2]
                                    var"##711" isa AbstractArray
                                end && ((ndims(var"##711") === 1 && length(var"##711") >= 0) && begin
                                        var"##712" = (SubArray)(var"##711", (1:length(var"##711"),))
                                        true
                                    end)))
                    xs = var"##712"
                    var"##return#609" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#610#718")))
                end
                if begin
                            var"##713" = (var"##cache#612").value
                            var"##713" isa Tuple{var1, var2} where {var2<:AbstractArray, var1}
                        end && (begin
                                var"##714" = var"##713"[1]
                                var"##715" = var"##713"[2]
                                var"##715" isa AbstractArray
                            end && (length(var"##715") === 2 && begin
                                    var"##716" = var"##715"[1]
                                    var"##717" = var"##715"[2]
                                    true
                                end))
                    rhs = var"##717"
                    lhs = var"##716"
                    head = var"##714"
                    var"##return#609" = begin
                            if head in expr_infix_wide
                                print_expr(io, lhs, ps, theme)
                                printstyled(io, tab(1), head, tab(1); color = theme.kw)
                                print_expr(io, rhs, ps, theme)
                            else
                                Base.show_unquoted_quote_expr(IOContext(io, :unquote_fallback => true), ex, ps.line_indent, -1, 0)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#610#718")))
                end
            end
            if var"##611" isa Number
                var"##return#609" = begin
                        printstyled(io, ex; color = theme.literal)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#610#718")))
            end
            if var"##611" isa Nothing
                var"##return#609" = begin
                        printstyled(io, "nothing"; color = :blue)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#610#718")))
            end
            if var"##611" isa QuoteNode
                var"##return#609" = begin
                        if Base.isidentifier(ex.value)
                            print(io, ":", ex.value)
                        else
                            print(io, ":(", ex.value, ")")
                        end
                    end
                $(Expr(:symbolicgoto, Symbol("####final#610#718")))
            end
            if var"##611" isa LineNumberNode
                var"##return#609" = begin
                        printstyled(io, ex; color = theme.comment)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#610#718")))
            end
            if var"##611" isa String
                var"##return#609" = begin
                        printstyled(io, "\"", ex, "\""; color = theme.string)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#610#718")))
            end
            if var"##611" isa Base.ExprNode
                var"##return#609" = begin
                        Base.show_unquoted_quote_expr(IOContext(io, :unquote_fallback => true), ex, ps.line_indent, -1, 0)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#610#718")))
            end
            var"##return#609" = begin
                    print(io, ex)
                end
            $(Expr(:symbolicgoto, Symbol("####final#610#718")))
            (error)("matching non-exhaustive, at #= none:309 =#")
            $(Expr(:symboliclabel, Symbol("####final#610#718")))
            var"##return#609"
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
