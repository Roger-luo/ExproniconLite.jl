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
                $(Expr(:symbolicgoto, Symbol("####final#515#583")))
            end
            if begin
                        var"##522" = (var"##cache#517").value
                        var"##522" isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (var"##522"[1] == :block && (begin
                                var"##523" = var"##522"[2]
                                var"##523" isa AbstractArray
                            end && (length(var"##523") === 3 && (begin
                                        var"##524" = var"##523"[1]
                                        var"##525" = var"##523"[2]
                                        var"##525" isa LineNumberNode
                                    end && begin
                                        var"##526" = var"##523"[3]
                                        true
                                    end))))
                line = var"##525"
                stmt2 = var"##526"
                stmt1 = var"##524"
                var"##return#514" = begin
                        printstyled(io, "("; color = ps.color)
                        print_expr(io, stmt1, ps, theme)
                        printstyled(io, "; "; color = ps.color)
                        print_expr(io, stmt2)
                        printstyled(io, ")"; color = ps.color)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#515#583")))
            end
            if begin
                        var"##527" = (var"##cache#517").value
                        var"##527" isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (var"##527"[1] == :block && (begin
                                var"##528" = var"##527"[2]
                                var"##528" isa AbstractArray
                            end && ((ndims(var"##528") === 1 && length(var"##528") >= 0) && begin
                                    var"##529" = (SubArray)(var"##528", (1:length(var"##528"),))
                                    true
                                end)))
                stmts = var"##529"
                var"##return#514" = begin
                        print_kw(io, "begin", ps, theme)
                        println(io, ps)
                        print_stmts_list(io, stmts, ps, theme)
                        print_end(io, ps, theme)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#515#583")))
            end
            if begin
                        var"##530" = (var"##cache#517").value
                        var"##530" isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (var"##530"[1] == :let && (begin
                                var"##531" = var"##530"[2]
                                var"##531" isa AbstractArray
                            end && (length(var"##531") === 2 && begin
                                    var"##532" = var"##531"[1]
                                    var"##533" = var"##531"[2]
                                    true
                                end)))
                vars = var"##532"
                body = var"##533"
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
                $(Expr(:symbolicgoto, Symbol("####final#515#583")))
            end
            if begin
                        var"##534" = (var"##cache#517").value
                        var"##534" isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (var"##534"[1] == :if && (begin
                                var"##535" = var"##534"[2]
                                var"##535" isa AbstractArray
                            end && ((ndims(var"##535") === 1 && length(var"##535") >= 2) && begin
                                    var"##536" = var"##535"[1]
                                    var"##537" = var"##535"[2]
                                    var"##538" = (SubArray)(var"##535", (3:length(var"##535"),))
                                    true
                                end)))
                cond = var"##536"
                body = var"##537"
                otherwise = var"##538"
                var"##return#514" = begin
                        printstyled(io, ex.head, tab(1); color = theme.kw)
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
                $(Expr(:symbolicgoto, Symbol("####final#515#583")))
            end
            if begin
                        var"##539" = (var"##cache#517").value
                        var"##539" isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (var"##539"[1] == :elseif && (begin
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
                        printstyled(io, ex.head, tab(1); color = theme.kw)
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
                $(Expr(:symbolicgoto, Symbol("####final#515#583")))
            end
            if begin
                        var"##544" = (var"##cache#517").value
                        var"##544" isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (var"##544"[1] == :for && (begin
                                var"##545" = var"##544"[2]
                                var"##545" isa AbstractArray
                            end && (length(var"##545") === 2 && begin
                                    var"##546" = var"##545"[1]
                                    var"##547" = var"##545"[2]
                                    true
                                end)))
                body = var"##547"
                head = var"##546"
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
                $(Expr(:symbolicgoto, Symbol("####final#515#583")))
            end
            if begin
                        var"##548" = (var"##cache#517").value
                        var"##548" isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (var"##548"[1] == :function && (begin
                                var"##549" = var"##548"[2]
                                var"##549" isa AbstractArray
                            end && (length(var"##549") === 2 && begin
                                    var"##550" = var"##549"[1]
                                    var"##551" = var"##549"[2]
                                    true
                                end)))
                call = var"##550"
                body = var"##551"
                var"##return#514" = begin
                        within_line(io, ps) do 
                            print_kw(io, "function ", ps, theme)
                            print_expr(io, call, ps, theme)
                        end
                        println(io, ps)
                        print_stmts(io, body, ps, theme)
                        print_end(io, ps, theme)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#515#583")))
            end
            if begin
                        var"##552" = (var"##cache#517").value
                        var"##552" isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (var"##552"[1] == :macrocall && (begin
                                var"##553" = var"##552"[2]
                                var"##553" isa AbstractArray
                            end && (length(var"##553") === 4 && (begin
                                        var"##554" = var"##553"[1]
                                        var"##554" == GlobalRef(Core, Symbol("@doc"))
                                    end && begin
                                        var"##555" = var"##553"[2]
                                        var"##556" = var"##553"[3]
                                        var"##557" = var"##553"[4]
                                        true
                                    end))))
                line = var"##555"
                code = var"##557"
                doc = var"##556"
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
                $(Expr(:symbolicgoto, Symbol("####final#515#583")))
            end
            if begin
                        var"##558" = (var"##cache#517").value
                        var"##558" isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (var"##558"[1] == :macrocall && (begin
                                var"##559" = var"##558"[2]
                                var"##559" isa AbstractArray
                            end && ((ndims(var"##559") === 1 && length(var"##559") >= 2) && begin
                                    var"##560" = var"##559"[1]
                                    var"##561" = var"##559"[2]
                                    var"##562" = (SubArray)(var"##559", (3:length(var"##559"),))
                                    true
                                end)))
                line = var"##561"
                name = var"##560"
                xs = var"##562"
                var"##return#514" = begin
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
                $(Expr(:symbolicgoto, Symbol("####final#515#583")))
            end
            if begin
                        var"##563" = (var"##cache#517").value
                        var"##563" isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (var"##563"[1] == :struct && (begin
                                var"##564" = var"##563"[2]
                                var"##564" isa AbstractArray
                            end && (length(var"##564") === 3 && begin
                                    var"##565" = var"##564"[1]
                                    var"##566" = var"##564"[2]
                                    var"##567" = var"##564"[3]
                                    true
                                end)))
                ismutable = var"##565"
                body = var"##567"
                head = var"##566"
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
                $(Expr(:symbolicgoto, Symbol("####final#515#583")))
            end
            if begin
                        var"##568" = (var"##cache#517").value
                        var"##568" isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (var"##568"[1] == :try && (begin
                                var"##569" = var"##568"[2]
                                var"##569" isa AbstractArray
                            end && (length(var"##569") === 3 && begin
                                    var"##570" = var"##569"[1]
                                    var"##571" = var"##569"[2]
                                    var"##572" = var"##569"[3]
                                    true
                                end)))
                catch_body = var"##572"
                try_body = var"##570"
                catch_var = var"##571"
                var"##return#514" = begin
                        print_try(io, try_body, ps, theme)
                        print_catch(io, catch_var, catch_body, ps, theme)
                        print_end(io, ps, theme)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#515#583")))
            end
            if begin
                        var"##573" = (var"##cache#517").value
                        var"##573" isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (var"##573"[1] == :try && (begin
                                var"##574" = var"##573"[2]
                                var"##574" isa AbstractArray
                            end && (length(var"##574") === 4 && (begin
                                        var"##575" = var"##574"[1]
                                        var"##574"[2] === false
                                    end && (var"##574"[3] === false && begin
                                            var"##576" = var"##574"[4]
                                            true
                                        end)))))
                try_body = var"##575"
                finally_body = var"##576"
                var"##return#514" = begin
                        print_try(io, try_body, ps, theme)
                        print_finally(io, finally_body, ps, theme)
                        print_end(io, ps, theme)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#515#583")))
            end
            if begin
                        var"##577" = (var"##cache#517").value
                        var"##577" isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (var"##577"[1] == :try && (begin
                                var"##578" = var"##577"[2]
                                var"##578" isa AbstractArray
                            end && (length(var"##578") === 4 && begin
                                    var"##579" = var"##578"[1]
                                    var"##580" = var"##578"[2]
                                    var"##581" = var"##578"[3]
                                    var"##582" = var"##578"[4]
                                    true
                                end)))
                catch_body = var"##581"
                try_body = var"##579"
                finally_body = var"##582"
                catch_var = var"##580"
                var"##return#514" = begin
                        print_try(io, try_body, ps, theme)
                        print_catch(io, catch_var, catch_body, ps, theme)
                        print_finally(io, finally_body, ps, theme)
                        print_end(io, ps, theme)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#515#583")))
            end
        end
        var"##return#514" = begin
                print_within_line(io, ex, ps, theme)
            end
        $(Expr(:symbolicgoto, Symbol("####final#515#583")))
        (error)("matching non-exhaustive, at #= none:58 =#")
        $(Expr(:symboliclabel, Symbol("####final#515#583")))
        var"##return#514"
    end
    function print_kw(io::IO, x, ps, theme::Color)
        print(io, tab(ps.line_indent))
        printstyled(io, x; color = theme.kw)
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
            var"##cache#587" = nothing
            var"##586" = ex
            if var"##586" isa GlobalRef
                var"##return#584" = begin
                        printstyled(io, ex.mod, "."; color = ps.color)
                        print_expr(io, ex.name, ps, theme)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#585#679")))
            end
            if var"##586" isa Symbol
                var"##return#584" = begin
                        printstyled(io, ex; color = ps.color)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#585#679")))
            end
            if var"##586" isa Expr
                if begin
                            if var"##cache#587" === nothing
                                var"##cache#587" = Some(((var"##586").head, (var"##586").args))
                            end
                            var"##588" = (var"##cache#587").value
                            var"##588" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##588"[1] == :tuple && (begin
                                    var"##589" = var"##588"[2]
                                    var"##589" isa AbstractArray
                                end && ((ndims(var"##589") === 1 && length(var"##589") >= 1) && (begin
                                            var"##cache#591" = nothing
                                            var"##590" = var"##589"[1]
                                            var"##590" isa Expr
                                        end && (begin
                                                if var"##cache#591" === nothing
                                                    var"##cache#591" = Some(((var"##590").head, (var"##590").args))
                                                end
                                                var"##592" = (var"##cache#591").value
                                                var"##592" isa Tuple{Symbol, var2} where var2<:AbstractArray
                                            end && (var"##592"[1] == :parameters && (begin
                                                        var"##593" = var"##592"[2]
                                                        var"##593" isa AbstractArray
                                                    end && ((ndims(var"##593") === 1 && length(var"##593") >= 0) && begin
                                                            var"##594" = (SubArray)(var"##593", (1:length(var"##593"),))
                                                            var"##595" = (SubArray)(var"##589", (2:length(var"##589"),))
                                                            true
                                                        end))))))))
                    args = var"##595"
                    kwargs = var"##594"
                    var"##return#584" = begin
                            printstyled(io, "("; color = ps.color)
                            print_collection(io, args, ps, theme)
                            if !(isempty(kwargs))
                                printstyled(io, "; "; color = ps.color)
                                print_collection(io, kwargs, ps)
                            end
                            printstyled(io, ")"; color = ps.color)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#585#679")))
                end
                if begin
                            var"##596" = (var"##cache#587").value
                            var"##596" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##596"[1] == :tuple && (begin
                                    var"##597" = var"##596"[2]
                                    var"##597" isa AbstractArray
                                end && ((ndims(var"##597") === 1 && length(var"##597") >= 0) && begin
                                        var"##598" = (SubArray)(var"##597", (1:length(var"##597"),))
                                        true
                                    end)))
                    xs = var"##598"
                    var"##return#584" = begin
                            printstyled(io, "("; color = ps.color)
                            print_collection(io, xs, ps)
                            printstyled(io, ")"; color = ps.color)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#585#679")))
                end
                if begin
                            var"##599" = (var"##cache#587").value
                            var"##599" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##599"[1] == :(::) && (begin
                                    var"##600" = var"##599"[2]
                                    var"##600" isa AbstractArray
                                end && (length(var"##600") === 1 && begin
                                        var"##601" = var"##600"[1]
                                        true
                                    end)))
                    type = var"##601"
                    var"##return#584" = begin
                            printstyled(io, "::"; color = ps.color)
                            with_color(theme.type, ps) do 
                                print_expr(io, type, ps, theme)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#585#679")))
                end
                if begin
                            var"##602" = (var"##cache#587").value
                            var"##602" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##602"[1] == :(::) && (begin
                                    var"##603" = var"##602"[2]
                                    var"##603" isa AbstractArray
                                end && (length(var"##603") === 2 && begin
                                        var"##604" = var"##603"[1]
                                        var"##605" = var"##603"[2]
                                        true
                                    end)))
                    type = var"##605"
                    name = var"##604"
                    var"##return#584" = begin
                            print_expr(io, name, ps, theme)
                            printstyled(io, "::"; color = ps.color)
                            with_color(theme.type, ps) do 
                                print_expr(io, type, ps, theme)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#585#679")))
                end
                if begin
                            var"##606" = (var"##cache#587").value
                            var"##606" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##606"[1] == :<: && (begin
                                    var"##607" = var"##606"[2]
                                    var"##607" isa AbstractArray
                                end && (length(var"##607") === 2 && begin
                                        var"##608" = var"##607"[1]
                                        var"##609" = var"##607"[2]
                                        true
                                    end)))
                    type = var"##609"
                    name = var"##608"
                    var"##return#584" = begin
                            print_expr(io, name, ps, theme)
                            printstyled(io, " <: "; color = ps.color)
                            with_color(theme.type, ps) do 
                                print_expr(io, type, ps, theme)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#585#679")))
                end
                if begin
                            var"##610" = (var"##cache#587").value
                            var"##610" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##610"[1] == :kw && (begin
                                    var"##611" = var"##610"[2]
                                    var"##611" isa AbstractArray
                                end && (length(var"##611") === 2 && begin
                                        var"##612" = var"##611"[1]
                                        var"##613" = var"##611"[2]
                                        true
                                    end)))
                    value = var"##613"
                    name = var"##612"
                    var"##return#584" = begin
                            print_expr(io, name, ps, theme)
                            printstyled(io, tab(1), "=", tab(1); color = ps.color)
                            print_expr(io, value, ps, theme)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#585#679")))
                end
                if begin
                            var"##614" = (var"##cache#587").value
                            var"##614" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##614"[1] == :(=) && (begin
                                    var"##615" = var"##614"[2]
                                    var"##615" isa AbstractArray
                                end && (length(var"##615") === 2 && begin
                                        var"##616" = var"##615"[1]
                                        var"##617" = var"##615"[2]
                                        true
                                    end)))
                    value = var"##617"
                    name = var"##616"
                    var"##return#584" = begin
                            print_expr(io, name, ps, theme)
                            printstyled(io, tab(1), "=", tab(1); color = ps.color)
                            print_expr(io, value, ps, theme)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#585#679")))
                end
                if begin
                            var"##618" = (var"##cache#587").value
                            var"##618" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##618"[1] == :... && (begin
                                    var"##619" = var"##618"[2]
                                    var"##619" isa AbstractArray
                                end && (length(var"##619") === 1 && begin
                                        var"##620" = var"##619"[1]
                                        true
                                    end)))
                    name = var"##620"
                    var"##return#584" = begin
                            print_expr(io, name, ps, theme)
                            print(io, "...")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#585#679")))
                end
                if begin
                            var"##621" = (var"##cache#587").value
                            var"##621" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##621"[1] == :& && (begin
                                    var"##622" = var"##621"[2]
                                    var"##622" isa AbstractArray
                                end && (length(var"##622") === 1 && begin
                                        var"##623" = var"##622"[1]
                                        true
                                    end)))
                    name = var"##623"
                    var"##return#584" = begin
                            printstyled(io, "&"; color = theme.kw)
                            print_expr(io, name, ps, theme)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#585#679")))
                end
                if begin
                            var"##624" = (var"##cache#587").value
                            var"##624" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##624"[1] == :$ && (begin
                                    var"##625" = var"##624"[2]
                                    var"##625" isa AbstractArray
                                end && (length(var"##625") === 1 && begin
                                        var"##626" = var"##625"[1]
                                        true
                                    end)))
                    name = var"##626"
                    var"##return#584" = begin
                            printstyled(io, "\$"; color = theme.kw)
                            print(io, "(")
                            print_expr(io, name, ps, theme)
                            print(io, ")")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#585#679")))
                end
                if begin
                            var"##627" = (var"##cache#587").value
                            var"##627" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##627"[1] == :curly && (begin
                                    var"##628" = var"##627"[2]
                                    var"##628" isa AbstractArray
                                end && ((ndims(var"##628") === 1 && length(var"##628") >= 1) && begin
                                        var"##629" = var"##628"[1]
                                        var"##630" = (SubArray)(var"##628", (2:length(var"##628"),))
                                        true
                                    end)))
                    vars = var"##630"
                    name = var"##629"
                    var"##return#584" = begin
                            print_expr(io, name, ps, theme)
                            print(io, "{")
                            with_color(theme.type, ps) do 
                                print_collection(io, vars, ps, theme)
                            end
                            print(io, "}")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#585#679")))
                end
                if begin
                            var"##631" = (var"##cache#587").value
                            var"##631" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##631"[1] == :ref && (begin
                                    var"##632" = var"##631"[2]
                                    var"##632" isa AbstractArray
                                end && ((ndims(var"##632") === 1 && length(var"##632") >= 1) && begin
                                        var"##633" = var"##632"[1]
                                        var"##634" = (SubArray)(var"##632", (2:length(var"##632"),))
                                        true
                                    end)))
                    name = var"##633"
                    xs = var"##634"
                    var"##return#584" = begin
                            print_expr(io, name, ps, theme)
                            print(io, "[")
                            print_collection(io, xs, ps, theme)
                            print(io, "]")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#585#679")))
                end
                if begin
                            var"##635" = (var"##cache#587").value
                            var"##635" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##635"[1] == :where && (begin
                                    var"##636" = var"##635"[2]
                                    var"##636" isa AbstractArray
                                end && ((ndims(var"##636") === 1 && length(var"##636") >= 1) && begin
                                        var"##637" = var"##636"[1]
                                        var"##638" = (SubArray)(var"##636", (2:length(var"##636"),))
                                        true
                                    end)))
                    body = var"##637"
                    whereparams = var"##638"
                    var"##return#584" = begin
                            print_expr(io, body, ps, theme)
                            printstyled(io, tab(1), "where", tab(1); color = theme.kw)
                            print(io, "{")
                            print_collection(io, whereparams, ps, theme)
                            print(io, "}")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#585#679")))
                end
                if begin
                            var"##639" = (var"##cache#587").value
                            var"##639" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##639"[1] == :call && (begin
                                    var"##640" = var"##639"[2]
                                    var"##640" isa AbstractArray
                                end && ((ndims(var"##640") === 1 && length(var"##640") >= 2) && (begin
                                            var"##641" = var"##640"[1]
                                            var"##cache#643" = nothing
                                            var"##642" = var"##640"[2]
                                            var"##642" isa Expr
                                        end && (begin
                                                if var"##cache#643" === nothing
                                                    var"##cache#643" = Some(((var"##642").head, (var"##642").args))
                                                end
                                                var"##644" = (var"##cache#643").value
                                                var"##644" isa Tuple{Symbol, var2} where var2<:AbstractArray
                                            end && (var"##644"[1] == :parameters && (begin
                                                        var"##645" = var"##644"[2]
                                                        var"##645" isa AbstractArray
                                                    end && ((ndims(var"##645") === 1 && length(var"##645") >= 0) && begin
                                                            var"##646" = (SubArray)(var"##645", (1:length(var"##645"),))
                                                            var"##647" = (SubArray)(var"##640", (3:length(var"##640"),))
                                                            true
                                                        end))))))))
                    name = var"##641"
                    args = var"##647"
                    kwargs = var"##646"
                    var"##return#584" = begin
                            print_expr(io, name, ps, theme)
                            printstyled(io, "("; color = ps.color)
                            print_collection(io, args, ps)
                            if !(isempty(kwargs))
                                printstyled(io, "; "; color = ps.color)
                                print_collection(io, kwargs, ps)
                            end
                            printstyled(io, ")"; color = ps.color)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#585#679")))
                end
                if begin
                            var"##648" = (var"##cache#587").value
                            var"##648" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##648"[1] == :call && (begin
                                    var"##649" = var"##648"[2]
                                    var"##649" isa AbstractArray
                                end && ((ndims(var"##649") === 1 && length(var"##649") >= 1) && (var"##649"[1] == :(:) && begin
                                            var"##650" = (SubArray)(var"##649", (2:length(var"##649"),))
                                            true
                                        end))))
                    xs = var"##650"
                    var"##return#584" = begin
                            print_collection(io, xs, ps, theme; delim = ":")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#585#679")))
                end
                if begin
                            var"##651" = (var"##cache#587").value
                            var"##651" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##651"[1] == :call && (begin
                                    var"##652" = var"##651"[2]
                                    var"##652" isa AbstractArray
                                end && (length(var"##652") === 2 && (begin
                                            var"##653" = var"##652"[1]
                                            var"##653" isa Symbol
                                        end && begin
                                            var"##654" = var"##652"[2]
                                            true
                                        end))))
                    name = var"##653"
                    x = var"##654"
                    var"##return#584" = begin
                            if name in uni_ops
                                print_expr(io, name, ps, theme)
                                print_expr(io, x, ps, theme)
                            else
                                print_call_expr(io, name, [x], ps, theme)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#585#679")))
                end
                if begin
                            var"##655" = (var"##cache#587").value
                            var"##655" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##655"[1] == :call && (begin
                                    var"##656" = var"##655"[2]
                                    var"##656" isa AbstractArray
                                end && (length(var"##656") === 3 && begin
                                        var"##657" = var"##656"[1]
                                        var"##658" = var"##656"[2]
                                        var"##659" = var"##656"[3]
                                        true
                                    end)))
                    rhs = var"##659"
                    lhs = var"##658"
                    name = var"##657"
                    var"##return#584" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#585#679")))
                end
                if begin
                            var"##660" = (var"##cache#587").value
                            var"##660" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##660"[1] == :call && (begin
                                    var"##661" = var"##660"[2]
                                    var"##661" isa AbstractArray
                                end && ((ndims(var"##661") === 1 && length(var"##661") >= 1) && begin
                                        var"##662" = var"##661"[1]
                                        var"##663" = (SubArray)(var"##661", (2:length(var"##661"),))
                                        true
                                    end)))
                    name = var"##662"
                    args = var"##663"
                    var"##return#584" = begin
                            print_call_expr(io, name, args, ps, theme)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#585#679")))
                end
                if begin
                            var"##664" = (var"##cache#587").value
                            var"##664" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##664"[1] == :-> && (begin
                                    var"##665" = var"##664"[2]
                                    var"##665" isa AbstractArray
                                end && (length(var"##665") === 2 && begin
                                        var"##666" = var"##665"[1]
                                        var"##667" = var"##665"[2]
                                        true
                                    end)))
                    call = var"##666"
                    body = var"##667"
                    var"##return#584" = begin
                            print_expr(io, call, ps, theme)
                            printstyled(io, tab(1), "->", tab(1); color = theme.kw)
                            print_expr(io, body, ps, theme)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#585#679")))
                end
                if begin
                            var"##668" = (var"##cache#587").value
                            var"##668" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##668"[1] == :return && (begin
                                    var"##669" = var"##668"[2]
                                    var"##669" isa AbstractArray
                                end && (length(var"##669") === 1 && begin
                                        var"##670" = var"##669"[1]
                                        true
                                    end)))
                    x = var"##670"
                    var"##return#584" = begin
                            printstyled(io, "return", tab(1); color = theme.kw)
                            let
                                var"##cache#683" = nothing
                                var"##return#680" = nothing
                                var"##682" = x
                                if var"##682" isa Expr && (begin
                                                if var"##cache#683" === nothing
                                                    var"##cache#683" = Some(((var"##682").head, (var"##682").args))
                                                end
                                                var"##684" = (var"##cache#683").value
                                                var"##684" isa Tuple{Symbol, var2} where var2<:AbstractArray
                                            end && (var"##684"[1] == :tuple && (begin
                                                        var"##685" = var"##684"[2]
                                                        var"##685" isa AbstractArray
                                                    end && ((ndims(var"##685") === 1 && length(var"##685") >= 0) && begin
                                                            var"##686" = (SubArray)(var"##685", (1:length(var"##685"),))
                                                            true
                                                        end))))
                                    var"##return#680" = let xs = var"##686"
                                            print_collection(io, xs, ps)
                                        end
                                    $(Expr(:symbolicgoto, Symbol("####final#681#687")))
                                end
                                var"##return#680" = let
                                        print_expr(io, x, ps, theme)
                                    end
                                $(Expr(:symbolicgoto, Symbol("####final#681#687")))
                                (error)("matching non-exhaustive, at #= none:388 =#")
                                $(Expr(:symboliclabel, Symbol("####final#681#687")))
                                var"##return#680"
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#585#679")))
                end
                if begin
                            var"##671" = (var"##cache#587").value
                            var"##671" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##671"[1] == :string && (begin
                                    var"##672" = var"##671"[2]
                                    var"##672" isa AbstractArray
                                end && ((ndims(var"##672") === 1 && length(var"##672") >= 0) && begin
                                        var"##673" = (SubArray)(var"##672", (1:length(var"##672"),))
                                        true
                                    end)))
                    xs = var"##673"
                    var"##return#584" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#585#679")))
                end
                if begin
                            var"##674" = (var"##cache#587").value
                            var"##674" isa Tuple{var1, var2} where {var2<:AbstractArray, var1}
                        end && (begin
                                var"##675" = var"##674"[1]
                                var"##676" = var"##674"[2]
                                var"##676" isa AbstractArray
                            end && (length(var"##676") === 2 && begin
                                    var"##677" = var"##676"[1]
                                    var"##678" = var"##676"[2]
                                    true
                                end))
                    rhs = var"##678"
                    lhs = var"##677"
                    head = var"##675"
                    var"##return#584" = begin
                            if head in expr_infix_wide
                                print_expr(io, lhs, ps, theme)
                                printstyled(io, tab(1), head, tab(1); color = theme.kw)
                                print_expr(io, rhs, ps, theme)
                            else
                                Base.show_unquoted_quote_expr(IOContext(io, :unquote_fallback => true), ex, ps.line_indent, -1, 0)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#585#679")))
                end
            end
            if var"##586" isa Number
                var"##return#584" = begin
                        printstyled(io, ex; color = theme.literal)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#585#679")))
            end
            if var"##586" isa Nothing
                var"##return#584" = begin
                        printstyled(io, "nothing"; color = :blue)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#585#679")))
            end
            if var"##586" isa QuoteNode
                var"##return#584" = begin
                        if Base.isidentifier(ex.value)
                            print(io, ":", ex.value)
                        else
                            print(io, ":(", ex.value, ")")
                        end
                    end
                $(Expr(:symbolicgoto, Symbol("####final#585#679")))
            end
            if var"##586" isa LineNumberNode
                var"##return#584" = begin
                        printstyled(io, ex; color = theme.comment)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#585#679")))
            end
            if var"##586" isa String
                var"##return#584" = begin
                        printstyled(io, "\"", ex, "\""; color = theme.string)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#585#679")))
            end
            if var"##586" isa Base.ExprNode
                var"##return#584" = begin
                        Base.show_unquoted_quote_expr(IOContext(io, :unquote_fallback => true), ex, ps.line_indent, -1, 0)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#585#679")))
            end
            var"##return#584" = begin
                    print(io, ex)
                end
            $(Expr(:symbolicgoto, Symbol("####final#585#679")))
            (error)("matching non-exhaustive, at #= none:269 =#")
            $(Expr(:symboliclabel, Symbol("####final#585#679")))
            var"##return#584"
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
