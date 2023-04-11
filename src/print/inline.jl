
    #= none:1 =# Base.@kwdef mutable struct InlinePrinterState
            type::Bool = false
            symbol::Bool = false
            call::Bool = false
            macrocall::Bool = false
            quoted::Bool = false
            keyword::Bool = false
            loop_iterator::Bool = false
            block::Bool = true
            precedence::Int = 0
        end
    function with(f::Function, p::InlinePrinterState, name::Symbol, new)
        old = getfield(p, name)
        setfield!(p, name, new)
        f()
        setfield!(p, name, old)
    end
    struct InlinePrinter{IO_t <: IO}
        io::IO_t
        color::ColorScheme
        line::Bool
        state::InlinePrinterState
    end
    function InlinePrinter(io::IO; color::ColorScheme = Monokai256(), line::Bool = false)
        InlinePrinter(io, color, line, InlinePrinterState())
    end
    function (p::InlinePrinter)(x, xs...; delim = ", ")
        p(x)
        for x = xs
            printstyled(p.io, delim; color = p.color.keyword)
            p(x)
        end
    end
    function (p::InlinePrinter)(expr)
        c = p.color
        print(xs...) = begin
                Base.print(p.io, xs...)
            end
        printstyled(xs...; kw...) = begin
                Base.printstyled(p.io, xs...; kw...)
            end
        function join(xs, delim = ", ")
            if !(p.line)
                xs = filter(!is_line_no, xs)
            end
            for (i, x) = enumerate(xs)
                p(x)
                i < length(xs) && keyword(delim)
            end
        end
        function print_braces(xs, open, close, delim = ", ")
            print(open)
            join(xs, delim)
            print(close)
        end
        string(s) = begin
                printstyled(repr(s); color = c.string)
            end
        keyword(s) = begin
                printstyled(s, color = c.keyword)
            end
        assign() = begin
                if p.state.loop_iterator
                    keyword(" in ")
                else
                    keyword(" = ")
                end
            end
        function symbol(ex)
            color = if p.state.type
                    c.type
                elseif p.state.quoted
                    c.quoted
                elseif p.state.call
                    c.call
                elseif p.state.macrocall
                    c.macrocall
                else
                    :normal
                end
            is_gensym(ex) && printstyled("var\""; color = color)
            printstyled(ex, color = color)
            is_gensym(ex) && printstyled("\""; color = color)
        end
        quoted(ex) = begin
                with((()->begin
                            p(ex)
                        end), p.state, :quoted, true)
            end
        type(ex) = begin
                with((()->begin
                            p(ex)
                        end), p.state, :type, true)
            end
        function call(ex)
            omit_parent = let
                    begin
                        var"##cache#711" = nothing
                    end
                    var"##return#708" = nothing
                    var"##710" = ex
                    if var"##710" isa Expr
                        if begin
                                    if var"##cache#711" === nothing
                                        var"##cache#711" = Some(((var"##710").head, (var"##710").args))
                                    end
                                    var"##712" = (var"##cache#711").value
                                    var"##712" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##712"[1] == :. && (begin
                                            var"##713" = var"##712"[2]
                                            var"##713" isa AbstractArray
                                        end && (ndims(var"##713") === 1 && length(var"##713") >= 0)))
                            var"##return#708" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#709#714")))
                        end
                    end
                    if var"##710" isa Symbol
                        begin
                            var"##return#708" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#709#714")))
                        end
                    end
                    begin
                        var"##return#708" = let
                                false
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#709#714")))
                    end
                    error("matching non-exhaustive, at #= none:85 =#")
                    $(Expr(:symboliclabel, Symbol("####final#709#714")))
                    var"##return#708"
                end
            omit_parent || print("(")
            with((()->begin
                        p(ex)
                    end), p.state, :call, true)
            omit_parent || print(")")
        end
        macrocall(ex) = begin
                with((()->begin
                            p(ex)
                        end), p.state, :macrocall, true)
            end
        noblock(ex) = begin
                with((()->begin
                            p(ex)
                        end), p.state, :block, false)
            end
        block(ex) = begin
                with((()->begin
                            p(ex)
                        end), p.state, :block, true)
            end
        function precedence(f, s)
            if s isa Int
                preced = s
            else
                preced = Base.operator_precedence(s)
            end
            require = preced > 0 && p.state.precedence > 0
            require && (p.state.precedence >= preced && print('('))
            with(f, p.state, :precedence, preced)
            require && (p.state.precedence >= preced && print(')'))
        end
        function print_call(ex)
            begin
                begin
                    var"##cache#718" = nothing
                end
                var"##717" = ex
                if var"##717" isa Expr && (begin
                                if var"##cache#718" === nothing
                                    var"##cache#718" = Some(((var"##717").head, (var"##717").args))
                                end
                                var"##719" = (var"##cache#718").value
                                var"##719" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##719"[1] == :call && (begin
                                        var"##720" = var"##719"[2]
                                        var"##720" isa AbstractArray
                                    end && ((ndims(var"##720") === 1 && length(var"##720") >= 1) && (var"##720"[1] == :(:) && begin
                                                var"##721" = SubArray(var"##720", (2:length(var"##720"),))
                                                true
                                            end)))))
                    args = var"##721"
                    var"##return#715" = begin
                            precedence(:(:)) do 
                                join(args, ":")
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#716#743")))
                end
                if var"##717" isa Expr && (begin
                                if var"##cache#718" === nothing
                                    var"##cache#718" = Some(((var"##717").head, (var"##717").args))
                                end
                                var"##722" = (var"##cache#718").value
                                var"##722" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##722"[1] == :call && (begin
                                        var"##723" = var"##722"[2]
                                        var"##723" isa AbstractArray
                                    end && (length(var"##723") === 2 && (begin
                                                var"##724" = var"##723"[1]
                                                var"##724" isa Symbol
                                            end && begin
                                                var"##725" = var"##723"[2]
                                                let f = var"##724", arg = var"##725"
                                                    Base.isunaryoperator(f)
                                                end
                                            end)))))
                    f = var"##724"
                    arg = var"##725"
                    var"##return#715" = begin
                            precedence(typemax(Int)) do 
                                keyword(f)
                                p(arg)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#716#743")))
                end
                if var"##717" isa Expr && (begin
                                if var"##cache#718" === nothing
                                    var"##cache#718" = Some(((var"##717").head, (var"##717").args))
                                end
                                var"##726" = (var"##cache#718").value
                                var"##726" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##726"[1] == :call && (begin
                                        var"##727" = var"##726"[2]
                                        var"##727" isa AbstractArray
                                    end && ((ndims(var"##727") === 1 && length(var"##727") >= 1) && (begin
                                                var"##728" = var"##727"[1]
                                                var"##728" isa Symbol
                                            end && begin
                                                var"##729" = SubArray(var"##727", (2:length(var"##727"),))
                                                let f = var"##728", args = var"##729"
                                                    Base.isbinaryoperator(f)
                                                end
                                            end)))))
                    f = var"##728"
                    args = var"##729"
                    var"##return#715" = begin
                            precedence(f) do 
                                join(args, " $(f) ")
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#716#743")))
                end
                if var"##717" isa Expr && (begin
                                if var"##cache#718" === nothing
                                    var"##cache#718" = Some(((var"##717").head, (var"##717").args))
                                end
                                var"##730" = (var"##cache#718").value
                                var"##730" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##730"[1] == :call && (begin
                                        var"##731" = var"##730"[2]
                                        var"##731" isa AbstractArray
                                    end && ((ndims(var"##731") === 1 && length(var"##731") >= 2) && (begin
                                                var"##732" = var"##731"[1]
                                                begin
                                                    var"##cache#734" = nothing
                                                end
                                                var"##733" = var"##731"[2]
                                                var"##733" isa Expr
                                            end && (begin
                                                    if var"##cache#734" === nothing
                                                        var"##cache#734" = Some(((var"##733").head, (var"##733").args))
                                                    end
                                                    var"##735" = (var"##cache#734").value
                                                    var"##735" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##735"[1] == :parameters && (begin
                                                            var"##736" = var"##735"[2]
                                                            var"##736" isa AbstractArray
                                                        end && ((ndims(var"##736") === 1 && length(var"##736") >= 0) && begin
                                                                var"##737" = SubArray(var"##736", (1:length(var"##736"),))
                                                                var"##738" = SubArray(var"##731", (3:length(var"##731"),))
                                                                true
                                                            end)))))))))
                    f = var"##732"
                    args = var"##738"
                    kwargs = var"##737"
                    var"##return#715" = begin
                            call(f)
                            print("(")
                            join(args)
                            keyword("; ")
                            join(kwargs)
                            print(")")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#716#743")))
                end
                if var"##717" isa Expr && (begin
                                if var"##cache#718" === nothing
                                    var"##cache#718" = Some(((var"##717").head, (var"##717").args))
                                end
                                var"##739" = (var"##cache#718").value
                                var"##739" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##739"[1] == :call && (begin
                                        var"##740" = var"##739"[2]
                                        var"##740" isa AbstractArray
                                    end && ((ndims(var"##740") === 1 && length(var"##740") >= 1) && begin
                                            var"##741" = var"##740"[1]
                                            var"##742" = SubArray(var"##740", (2:length(var"##740"),))
                                            true
                                        end))))
                    f = var"##741"
                    args = var"##742"
                    var"##return#715" = begin
                            call(f)
                            print_braces(args, "(", ")")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#716#743")))
                end
                error("matching non-exhaustive, at #= none:111 =#")
                $(Expr(:symboliclabel, Symbol("####final#716#743")))
                var"##return#715"
            end
        end
        function print_function(head, call, body)
            keyword("$(head) ")
            p(call)
            keyword("; ")
            join(split_body(body), ";")
            keyword("; end")
        end
        function print_expr(ex)
            begin
                begin
                    var"##cache#747" = nothing
                end
                var"##746" = ex
                if var"##746" isa GlobalRef
                    begin
                        var"##return#744" = begin
                                p(ex.mod)
                                keyword(".")
                                p(ex.name)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                end
                if var"##746" isa Nothing
                    begin
                        var"##return#744" = begin
                                printstyled("nothing", color = c.number)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                end
                if var"##746" isa Symbol
                    begin
                        var"##return#744" = begin
                                symbol(ex)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                end
                if var"##746" isa Expr
                    if begin
                                if var"##cache#747" === nothing
                                    var"##cache#747" = Some(((var"##746").head, (var"##746").args))
                                end
                                var"##748" = (var"##cache#747").value
                                var"##748" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##748"[1] == :line && (begin
                                        var"##749" = var"##748"[2]
                                        var"##749" isa AbstractArray
                                    end && (length(var"##749") === 2 && begin
                                            var"##750" = var"##749"[1]
                                            var"##751" = var"##749"[2]
                                            true
                                        end)))
                        line = var"##751"
                        file = var"##750"
                        var"##return#744" = begin
                                p.line || return nothing
                                printstyled("#= $(file):$(line) =#", color = c.line)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##752" = (var"##cache#747").value
                                var"##752" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##752"[1] == :kw && (begin
                                        var"##753" = var"##752"[2]
                                        var"##753" isa AbstractArray
                                    end && (length(var"##753") === 2 && begin
                                            var"##754" = var"##753"[1]
                                            var"##755" = var"##753"[2]
                                            true
                                        end)))
                        k = var"##754"
                        v = var"##755"
                        var"##return#744" = begin
                                p(k)
                                print(" = ")
                                p(v)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##756" = (var"##cache#747").value
                                var"##756" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##756"[1] == :(=) && (begin
                                        var"##757" = var"##756"[2]
                                        var"##757" isa AbstractArray
                                    end && (length(var"##757") === 2 && (begin
                                                var"##758" = var"##757"[1]
                                                begin
                                                    var"##cache#760" = nothing
                                                end
                                                var"##759" = var"##757"[2]
                                                var"##759" isa Expr
                                            end && (begin
                                                    if var"##cache#760" === nothing
                                                        var"##cache#760" = Some(((var"##759").head, (var"##759").args))
                                                    end
                                                    var"##761" = (var"##cache#760").value
                                                    var"##761" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##761"[1] == :block && (begin
                                                            var"##762" = var"##761"[2]
                                                            var"##762" isa AbstractArray
                                                        end && ((ndims(var"##762") === 1 && length(var"##762") >= 0) && begin
                                                                var"##763" = SubArray(var"##762", (1:length(var"##762"),))
                                                                true
                                                            end))))))))
                        k = var"##758"
                        stmts = var"##763"
                        var"##return#744" = begin
                                precedence(:(=)) do 
                                    if length(stmts) == 2 && count(!is_line_no, stmts) == 1
                                        p(k)
                                        assign()
                                        p.line && (is_line_no(stmts[1]) && p(stmts[1]))
                                        p(stmts[end])
                                    else
                                        p(k)
                                        assign()
                                        p(ex.args[2])
                                    end
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##764" = (var"##cache#747").value
                                var"##764" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##764"[1] == :(=) && (begin
                                        var"##765" = var"##764"[2]
                                        var"##765" isa AbstractArray
                                    end && (length(var"##765") === 2 && begin
                                            var"##766" = var"##765"[1]
                                            var"##767" = var"##765"[2]
                                            true
                                        end)))
                        k = var"##766"
                        v = var"##767"
                        var"##return#744" = begin
                                precedence(:(=)) do 
                                    p(k)
                                    assign()
                                    p(v)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##768" = (var"##cache#747").value
                                var"##768" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##768"[1] == :... && (begin
                                        var"##769" = var"##768"[2]
                                        var"##769" isa AbstractArray
                                    end && (length(var"##769") === 1 && begin
                                            var"##770" = var"##769"[1]
                                            true
                                        end)))
                        name = var"##770"
                        var"##return#744" = begin
                                precedence(:...) do 
                                    p(name)
                                    keyword("...")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##771" = (var"##cache#747").value
                                var"##771" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##771"[1] == :& && (begin
                                        var"##772" = var"##771"[2]
                                        var"##772" isa AbstractArray
                                    end && (length(var"##772") === 1 && begin
                                            var"##773" = var"##772"[1]
                                            true
                                        end)))
                        name = var"##773"
                        var"##return#744" = begin
                                precedence(:&) do 
                                    keyword("&")
                                    p(name)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##774" = (var"##cache#747").value
                                var"##774" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##774"[1] == :(::) && (begin
                                        var"##775" = var"##774"[2]
                                        var"##775" isa AbstractArray
                                    end && (length(var"##775") === 1 && begin
                                            var"##776" = var"##775"[1]
                                            true
                                        end)))
                        t = var"##776"
                        var"##return#744" = begin
                                precedence(:(::)) do 
                                    keyword("::")
                                    type(t)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##777" = (var"##cache#747").value
                                var"##777" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##777"[1] == :(::) && (begin
                                        var"##778" = var"##777"[2]
                                        var"##778" isa AbstractArray
                                    end && (length(var"##778") === 2 && begin
                                            var"##779" = var"##778"[1]
                                            var"##780" = var"##778"[2]
                                            true
                                        end)))
                        name = var"##779"
                        t = var"##780"
                        var"##return#744" = begin
                                precedence(:(::)) do 
                                    p(name)
                                    keyword("::")
                                    type(t)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##781" = (var"##cache#747").value
                                var"##781" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##781"[1] == :$ && (begin
                                        var"##782" = var"##781"[2]
                                        var"##782" isa AbstractArray
                                    end && (length(var"##782") === 1 && begin
                                            var"##783" = var"##782"[1]
                                            true
                                        end)))
                        name = var"##783"
                        var"##return#744" = begin
                                precedence(:$) do 
                                    keyword('$')
                                    print("(")
                                    p(name)
                                    print(")")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##784" = (var"##cache#747").value
                                var"##784" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##785" = var"##784"[1]
                                    var"##786" = var"##784"[2]
                                    var"##786" isa AbstractArray
                                end && (length(var"##786") === 2 && begin
                                        var"##787" = var"##786"[1]
                                        var"##788" = var"##786"[2]
                                        let rhs = var"##788", lhs = var"##787", head = var"##785"
                                            head in expr_infix_wide
                                        end
                                    end))
                        rhs = var"##788"
                        lhs = var"##787"
                        head = var"##785"
                        var"##return#744" = begin
                                precedence(head) do 
                                    p(lhs)
                                    keyword(" $(head) ")
                                    p(rhs)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##789" = (var"##cache#747").value
                                var"##789" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##789"[1] == :. && (begin
                                        var"##790" = var"##789"[2]
                                        var"##790" isa AbstractArray
                                    end && (length(var"##790") === 1 && begin
                                            var"##791" = var"##790"[1]
                                            true
                                        end)))
                        name = var"##791"
                        var"##return#744" = begin
                                print(name)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##792" = (var"##cache#747").value
                                var"##792" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##792"[1] == :. && (begin
                                        var"##793" = var"##792"[2]
                                        var"##793" isa AbstractArray
                                    end && (length(var"##793") === 2 && (begin
                                                var"##794" = var"##793"[1]
                                                var"##795" = var"##793"[2]
                                                var"##795" isa QuoteNode
                                            end && begin
                                                var"##796" = (var"##795").value
                                                true
                                            end))))
                        name = var"##796"
                        object = var"##794"
                        var"##return#744" = begin
                                precedence(:.) do 
                                    p(object)
                                    keyword(".")
                                    if name in Base.quoted_syms
                                        p(QuoteNode(name))
                                    else
                                        p(name)
                                    end
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##797" = (var"##cache#747").value
                                var"##797" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##797"[1] == :. && (begin
                                        var"##798" = var"##797"[2]
                                        var"##798" isa AbstractArray
                                    end && (length(var"##798") === 2 && begin
                                            var"##799" = var"##798"[1]
                                            var"##800" = var"##798"[2]
                                            true
                                        end)))
                        name = var"##800"
                        object = var"##799"
                        var"##return#744" = begin
                                precedence(:.) do 
                                    p(object)
                                    keyword(".")
                                    p(name)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##801" = (var"##cache#747").value
                                var"##801" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##801"[1] == :<: && (begin
                                        var"##802" = var"##801"[2]
                                        var"##802" isa AbstractArray
                                    end && (length(var"##802") === 2 && begin
                                            var"##803" = var"##802"[1]
                                            var"##804" = var"##802"[2]
                                            true
                                        end)))
                        type = var"##803"
                        supertype = var"##804"
                        var"##return#744" = begin
                                precedence(:<:) do 
                                    p(type)
                                    keyword(" <: ")
                                    p(supertype)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##805" = (var"##cache#747").value
                                var"##805" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##805"[1] == :call && (begin
                                        var"##806" = var"##805"[2]
                                        var"##806" isa AbstractArray
                                    end && (ndims(var"##806") === 1 && length(var"##806") >= 0)))
                        var"##return#744" = begin
                                print_call(ex)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##807" = (var"##cache#747").value
                                var"##807" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##807"[1] == :tuple && (begin
                                        var"##808" = var"##807"[2]
                                        var"##808" isa AbstractArray
                                    end && (length(var"##808") === 1 && (begin
                                                begin
                                                    var"##cache#810" = nothing
                                                end
                                                var"##809" = var"##808"[1]
                                                var"##809" isa Expr
                                            end && (begin
                                                    if var"##cache#810" === nothing
                                                        var"##cache#810" = Some(((var"##809").head, (var"##809").args))
                                                    end
                                                    var"##811" = (var"##cache#810").value
                                                    var"##811" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##811"[1] == :parameters && (begin
                                                            var"##812" = var"##811"[2]
                                                            var"##812" isa AbstractArray
                                                        end && ((ndims(var"##812") === 1 && length(var"##812") >= 0) && begin
                                                                var"##813" = SubArray(var"##812", (1:length(var"##812"),))
                                                                true
                                                            end))))))))
                        args = var"##813"
                        var"##return#744" = begin
                                print_braces(args, "(;", ")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##814" = (var"##cache#747").value
                                var"##814" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##814"[1] == :tuple && (begin
                                        var"##815" = var"##814"[2]
                                        var"##815" isa AbstractArray
                                    end && ((ndims(var"##815") === 1 && length(var"##815") >= 0) && begin
                                            var"##816" = SubArray(var"##815", (1:length(var"##815"),))
                                            true
                                        end)))
                        args = var"##816"
                        var"##return#744" = begin
                                if length(args) == 1
                                    print("(")
                                    p(args[1])
                                    print(",)")
                                else
                                    print_braces(args, "(", ")")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##817" = (var"##cache#747").value
                                var"##817" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##817"[1] == :curly && (begin
                                        var"##818" = var"##817"[2]
                                        var"##818" isa AbstractArray
                                    end && ((ndims(var"##818") === 1 && length(var"##818") >= 1) && begin
                                            var"##819" = var"##818"[1]
                                            var"##820" = SubArray(var"##818", (2:length(var"##818"),))
                                            true
                                        end)))
                        args = var"##820"
                        t = var"##819"
                        var"##return#744" = begin
                                with(p.state, :type, true) do 
                                    p(t)
                                    print_braces(args, "{", "}")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##821" = (var"##cache#747").value
                                var"##821" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##821"[1] == :vect && (begin
                                        var"##822" = var"##821"[2]
                                        var"##822" isa AbstractArray
                                    end && ((ndims(var"##822") === 1 && length(var"##822") >= 0) && begin
                                            var"##823" = SubArray(var"##822", (1:length(var"##822"),))
                                            true
                                        end)))
                        args = var"##823"
                        var"##return#744" = begin
                                print_braces(args, "[", "]")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##824" = (var"##cache#747").value
                                var"##824" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##824"[1] == :hcat && (begin
                                        var"##825" = var"##824"[2]
                                        var"##825" isa AbstractArray
                                    end && ((ndims(var"##825") === 1 && length(var"##825") >= 0) && begin
                                            var"##826" = SubArray(var"##825", (1:length(var"##825"),))
                                            true
                                        end)))
                        args = var"##826"
                        var"##return#744" = begin
                                print_braces(args, "[", "]", " ")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##827" = (var"##cache#747").value
                                var"##827" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##827"[1] == :typed_hcat && (begin
                                        var"##828" = var"##827"[2]
                                        var"##828" isa AbstractArray
                                    end && ((ndims(var"##828") === 1 && length(var"##828") >= 1) && begin
                                            var"##829" = var"##828"[1]
                                            var"##830" = SubArray(var"##828", (2:length(var"##828"),))
                                            true
                                        end)))
                        args = var"##830"
                        t = var"##829"
                        var"##return#744" = begin
                                type(t)
                                print_braces(args, "[", "]", " ")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##831" = (var"##cache#747").value
                                var"##831" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##831"[1] == :vcat && (begin
                                        var"##832" = var"##831"[2]
                                        var"##832" isa AbstractArray
                                    end && ((ndims(var"##832") === 1 && length(var"##832") >= 0) && begin
                                            var"##833" = SubArray(var"##832", (1:length(var"##832"),))
                                            true
                                        end)))
                        args = var"##833"
                        var"##return#744" = begin
                                print_braces(args, "[", "]", "; ")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##834" = (var"##cache#747").value
                                var"##834" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##834"[1] == :ncat && (begin
                                        var"##835" = var"##834"[2]
                                        var"##835" isa AbstractArray
                                    end && ((ndims(var"##835") === 1 && length(var"##835") >= 1) && begin
                                            var"##836" = var"##835"[1]
                                            var"##837" = SubArray(var"##835", (2:length(var"##835"),))
                                            true
                                        end)))
                        n = var"##836"
                        args = var"##837"
                        var"##return#744" = begin
                                print_braces(args, "[", "]", ";" ^ n * " ")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##838" = (var"##cache#747").value
                                var"##838" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##838"[1] == :ref && (begin
                                        var"##839" = var"##838"[2]
                                        var"##839" isa AbstractArray
                                    end && ((ndims(var"##839") === 1 && length(var"##839") >= 1) && begin
                                            var"##840" = var"##839"[1]
                                            var"##841" = SubArray(var"##839", (2:length(var"##839"),))
                                            true
                                        end)))
                        args = var"##841"
                        object = var"##840"
                        var"##return#744" = begin
                                p(object)
                                print_braces(args, "[", "]")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##842" = (var"##cache#747").value
                                var"##842" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##842"[1] == :comprehension && (begin
                                        var"##843" = var"##842"[2]
                                        var"##843" isa AbstractArray
                                    end && (length(var"##843") === 1 && (begin
                                                begin
                                                    var"##cache#845" = nothing
                                                end
                                                var"##844" = var"##843"[1]
                                                var"##844" isa Expr
                                            end && (begin
                                                    if var"##cache#845" === nothing
                                                        var"##cache#845" = Some(((var"##844").head, (var"##844").args))
                                                    end
                                                    var"##846" = (var"##cache#845").value
                                                    var"##846" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##846"[1] == :generator && (begin
                                                            var"##847" = var"##846"[2]
                                                            var"##847" isa AbstractArray
                                                        end && (length(var"##847") === 2 && begin
                                                                var"##848" = var"##847"[1]
                                                                var"##849" = var"##847"[2]
                                                                true
                                                            end))))))))
                        iter = var"##848"
                        body = var"##849"
                        var"##return#744" = begin
                                preced = p.state.precedence
                                p.state.precedence = 0
                                with(p.state, :loop_iterator, true) do 
                                    print("[")
                                    p(iter)
                                    keyword(" for ")
                                    p(body)
                                    print("]")
                                end
                                p.state.precedence = preced
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##850" = (var"##cache#747").value
                                var"##850" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##850"[1] == :typed_comprehension && (begin
                                        var"##851" = var"##850"[2]
                                        var"##851" isa AbstractArray
                                    end && (length(var"##851") === 2 && (begin
                                                var"##852" = var"##851"[1]
                                                begin
                                                    var"##cache#854" = nothing
                                                end
                                                var"##853" = var"##851"[2]
                                                var"##853" isa Expr
                                            end && (begin
                                                    if var"##cache#854" === nothing
                                                        var"##cache#854" = Some(((var"##853").head, (var"##853").args))
                                                    end
                                                    var"##855" = (var"##cache#854").value
                                                    var"##855" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##855"[1] == :generator && (begin
                                                            var"##856" = var"##855"[2]
                                                            var"##856" isa AbstractArray
                                                        end && (length(var"##856") === 2 && begin
                                                                var"##857" = var"##856"[1]
                                                                var"##858" = var"##856"[2]
                                                                true
                                                            end))))))))
                        iter = var"##857"
                        body = var"##858"
                        t = var"##852"
                        var"##return#744" = begin
                                preced = p.state.precedence
                                p.state.precedence = 0
                                with(p.state, :loop_iterator, true) do 
                                    type(t)
                                    print("[")
                                    p(iter)
                                    keyword(" for ")
                                    p(body)
                                    print("]")
                                end
                                p.state.precedence = preced
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##859" = (var"##cache#747").value
                                var"##859" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##859"[1] == :-> && (begin
                                        var"##860" = var"##859"[2]
                                        var"##860" isa AbstractArray
                                    end && (length(var"##860") === 2 && (begin
                                                var"##861" = var"##860"[1]
                                                begin
                                                    var"##cache#863" = nothing
                                                end
                                                var"##862" = var"##860"[2]
                                                var"##862" isa Expr
                                            end && (begin
                                                    if var"##cache#863" === nothing
                                                        var"##cache#863" = Some(((var"##862").head, (var"##862").args))
                                                    end
                                                    var"##864" = (var"##cache#863").value
                                                    var"##864" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##864"[1] == :block && (begin
                                                            var"##865" = var"##864"[2]
                                                            var"##865" isa AbstractArray
                                                        end && (length(var"##865") === 2 && begin
                                                                var"##866" = var"##865"[1]
                                                                var"##867" = var"##865"[2]
                                                                true
                                                            end))))))))
                        line = var"##866"
                        code = var"##867"
                        args = var"##861"
                        var"##return#744" = begin
                                p(args)
                                keyword(" -> ")
                                p.line && begin
                                        print("(")
                                        p(line)
                                        print(" ")
                                    end
                                p(code)
                                p.line && print(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##868" = (var"##cache#747").value
                                var"##868" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##868"[1] == :-> && (begin
                                        var"##869" = var"##868"[2]
                                        var"##869" isa AbstractArray
                                    end && (length(var"##869") === 2 && begin
                                            var"##870" = var"##869"[1]
                                            var"##871" = var"##869"[2]
                                            true
                                        end)))
                        args = var"##870"
                        body = var"##871"
                        var"##return#744" = begin
                                p(args)
                                keyword(" -> ")
                                print("(")
                                noblock(body)
                                print(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##872" = (var"##cache#747").value
                                var"##872" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##872"[1] == :do && (begin
                                        var"##873" = var"##872"[2]
                                        var"##873" isa AbstractArray
                                    end && (length(var"##873") === 2 && (begin
                                                var"##874" = var"##873"[1]
                                                begin
                                                    var"##cache#876" = nothing
                                                end
                                                var"##875" = var"##873"[2]
                                                var"##875" isa Expr
                                            end && (begin
                                                    if var"##cache#876" === nothing
                                                        var"##cache#876" = Some(((var"##875").head, (var"##875").args))
                                                    end
                                                    var"##877" = (var"##cache#876").value
                                                    var"##877" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##877"[1] == :-> && (begin
                                                            var"##878" = var"##877"[2]
                                                            var"##878" isa AbstractArray
                                                        end && (length(var"##878") === 2 && (begin
                                                                    begin
                                                                        var"##cache#880" = nothing
                                                                    end
                                                                    var"##879" = var"##878"[1]
                                                                    var"##879" isa Expr
                                                                end && (begin
                                                                        if var"##cache#880" === nothing
                                                                            var"##cache#880" = Some(((var"##879").head, (var"##879").args))
                                                                        end
                                                                        var"##881" = (var"##cache#880").value
                                                                        var"##881" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                    end && (var"##881"[1] == :tuple && (begin
                                                                                var"##882" = var"##881"[2]
                                                                                var"##882" isa AbstractArray
                                                                            end && ((ndims(var"##882") === 1 && length(var"##882") >= 0) && begin
                                                                                    var"##883" = SubArray(var"##882", (1:length(var"##882"),))
                                                                                    var"##884" = var"##878"[2]
                                                                                    true
                                                                                end)))))))))))))
                        call = var"##874"
                        args = var"##883"
                        body = var"##884"
                        var"##return#744" = begin
                                p(call)
                                keyword(" do")
                                isempty(args) || begin
                                        print(" ")
                                        p(args...)
                                    end
                                keyword("; ")
                                noblock(body)
                                isempty(args) || print(" ")
                                keyword("end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##885" = (var"##cache#747").value
                                var"##885" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##885"[1] == :function && (begin
                                        var"##886" = var"##885"[2]
                                        var"##886" isa AbstractArray
                                    end && (length(var"##886") === 2 && begin
                                            var"##887" = var"##886"[1]
                                            var"##888" = var"##886"[2]
                                            true
                                        end)))
                        call = var"##887"
                        body = var"##888"
                        var"##return#744" = begin
                                print_function(:function, call, body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##889" = (var"##cache#747").value
                                var"##889" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##889"[1] == :quote && (begin
                                        var"##890" = var"##889"[2]
                                        var"##890" isa AbstractArray
                                    end && (length(var"##890") === 1 && begin
                                            var"##891" = var"##890"[1]
                                            true
                                        end)))
                        stmt = var"##891"
                        var"##return#744" = begin
                                keyword(":(")
                                noblock(stmt)
                                keyword(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##892" = (var"##cache#747").value
                                var"##892" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##892"[1] == :quote && (begin
                                        var"##893" = var"##892"[2]
                                        var"##893" isa AbstractArray
                                    end && ((ndims(var"##893") === 1 && length(var"##893") >= 0) && begin
                                            var"##894" = SubArray(var"##893", (1:length(var"##893"),))
                                            true
                                        end)))
                        args = var"##894"
                        var"##return#744" = begin
                                keyword("quote ")
                                with(p.state, :block, false) do 
                                    join(args, "; ")
                                end
                                keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##895" = (var"##cache#747").value
                                var"##895" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##895"[1] == :string && (begin
                                        var"##896" = var"##895"[2]
                                        var"##896" isa AbstractArray
                                    end && ((ndims(var"##896") === 1 && length(var"##896") >= 0) && begin
                                            var"##897" = SubArray(var"##896", (1:length(var"##896"),))
                                            true
                                        end)))
                        args = var"##897"
                        var"##return#744" = begin
                                printstyled("\"", color = c.string)
                                foreach(args) do x
                                    x isa AbstractString && return printstyled(x; color = c.string)
                                    keyword('$')
                                    x isa Symbol && return p(x)
                                    print("(")
                                    p(x)
                                    print(")")
                                end
                                printstyled("\"", color = c.string)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##898" = (var"##cache#747").value
                                var"##898" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##898"[1] == :block && (begin
                                        var"##899" = var"##898"[2]
                                        var"##899" isa AbstractArray
                                    end && ((ndims(var"##899") === 1 && length(var"##899") >= 0) && begin
                                            var"##900" = SubArray(var"##899", (1:length(var"##899"),))
                                            let args = var"##900"
                                                length(args) == 2 && (is_line_no(args[1]) && is_line_no(args[2]))
                                            end
                                        end)))
                        args = var"##900"
                        var"##return#744" = begin
                                p(args[1])
                                print(" ")
                                p(args[2])
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##901" = (var"##cache#747").value
                                var"##901" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##901"[1] == :block && (begin
                                        var"##902" = var"##901"[2]
                                        var"##902" isa AbstractArray
                                    end && ((ndims(var"##902") === 1 && length(var"##902") >= 0) && begin
                                            var"##903" = SubArray(var"##902", (1:length(var"##902"),))
                                            let args = var"##903"
                                                length(args) == 2 && is_line_no(args[1])
                                            end
                                        end)))
                        args = var"##903"
                        var"##return#744" = begin
                                p(args[1])
                                print(" ")
                                noblock(args[2])
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##904" = (var"##cache#747").value
                                var"##904" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##904"[1] == :block && (begin
                                        var"##905" = var"##904"[2]
                                        var"##905" isa AbstractArray
                                    end && ((ndims(var"##905") === 1 && length(var"##905") >= 0) && begin
                                            var"##906" = SubArray(var"##905", (1:length(var"##905"),))
                                            let args = var"##906"
                                                length(args) == 2 && is_line_no(args[2])
                                            end
                                        end)))
                        args = var"##906"
                        var"##return#744" = begin
                                noblock(args[1])
                                print(" ")
                                p(args[2])
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##907" = (var"##cache#747").value
                                var"##907" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##907"[1] == :block && (begin
                                        var"##908" = var"##907"[2]
                                        var"##908" isa AbstractArray
                                    end && ((ndims(var"##908") === 1 && length(var"##908") >= 0) && begin
                                            var"##909" = SubArray(var"##908", (1:length(var"##908"),))
                                            let args = var"##909"
                                                length(args) == 2
                                            end
                                        end)))
                        args = var"##909"
                        var"##return#744" = begin
                                print("(")
                                noblock(args[1])
                                keyword("; ")
                                noblock(args[2])
                                print(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##910" = (var"##cache#747").value
                                var"##910" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##910"[1] == :block && (begin
                                        var"##911" = var"##910"[2]
                                        var"##911" isa AbstractArray
                                    end && ((ndims(var"##911") === 1 && length(var"##911") >= 0) && begin
                                            var"##912" = SubArray(var"##911", (1:length(var"##911"),))
                                            true
                                        end)))
                        args = var"##912"
                        var"##return#744" = begin
                                p.state.block && keyword("begin ")
                                with(p.state, :block, true) do 
                                    join(args, "; ")
                                end
                                p.state.block && keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##913" = (var"##cache#747").value
                                var"##913" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##913"[1] == :let && (begin
                                        var"##914" = var"##913"[2]
                                        var"##914" isa AbstractArray
                                    end && (length(var"##914") === 2 && (begin
                                                begin
                                                    var"##cache#916" = nothing
                                                end
                                                var"##915" = var"##914"[1]
                                                var"##915" isa Expr
                                            end && (begin
                                                    if var"##cache#916" === nothing
                                                        var"##cache#916" = Some(((var"##915").head, (var"##915").args))
                                                    end
                                                    var"##917" = (var"##cache#916").value
                                                    var"##917" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##917"[1] == :block && (begin
                                                            var"##918" = var"##917"[2]
                                                            var"##918" isa AbstractArray
                                                        end && ((ndims(var"##918") === 1 && length(var"##918") >= 0) && begin
                                                                var"##919" = SubArray(var"##918", (1:length(var"##918"),))
                                                                var"##920" = var"##914"[2]
                                                                true
                                                            end))))))))
                        args = var"##919"
                        body = var"##920"
                        var"##return#744" = begin
                                keyword("let ")
                                join(args, ", ")
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##921" = (var"##cache#747").value
                                var"##921" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##921"[1] == :let && (begin
                                        var"##922" = var"##921"[2]
                                        var"##922" isa AbstractArray
                                    end && (length(var"##922") === 2 && begin
                                            var"##923" = var"##922"[1]
                                            var"##924" = var"##922"[2]
                                            true
                                        end)))
                        arg = var"##923"
                        body = var"##924"
                        var"##return#744" = begin
                                keyword("let ")
                                p(arg)
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##925" = (var"##cache#747").value
                                var"##925" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##925"[1] == :macrocall && (begin
                                        var"##926" = var"##925"[2]
                                        var"##926" isa AbstractArray
                                    end && ((ndims(var"##926") === 1 && length(var"##926") >= 2) && begin
                                            var"##927" = var"##926"[1]
                                            var"##928" = var"##926"[2]
                                            var"##929" = SubArray(var"##926", (3:length(var"##926"),))
                                            true
                                        end)))
                        f = var"##927"
                        line = var"##928"
                        args = var"##929"
                        var"##return#744" = begin
                                p.line && printstyled(line, color = c.comment)
                                macrocall(f)
                                print_braces(args, "(", ")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##930" = (var"##cache#747").value
                                var"##930" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##930"[1] == :return && (begin
                                        var"##931" = var"##930"[2]
                                        var"##931" isa AbstractArray
                                    end && (length(var"##931") === 1 && (begin
                                                begin
                                                    var"##cache#933" = nothing
                                                end
                                                var"##932" = var"##931"[1]
                                                var"##932" isa Expr
                                            end && (begin
                                                    if var"##cache#933" === nothing
                                                        var"##cache#933" = Some(((var"##932").head, (var"##932").args))
                                                    end
                                                    var"##934" = (var"##cache#933").value
                                                    var"##934" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##934"[1] == :tuple && (begin
                                                            var"##935" = var"##934"[2]
                                                            var"##935" isa AbstractArray
                                                        end && ((ndims(var"##935") === 1 && length(var"##935") >= 1) && (begin
                                                                    begin
                                                                        var"##cache#937" = nothing
                                                                    end
                                                                    var"##936" = var"##935"[1]
                                                                    var"##936" isa Expr
                                                                end && (begin
                                                                        if var"##cache#937" === nothing
                                                                            var"##cache#937" = Some(((var"##936").head, (var"##936").args))
                                                                        end
                                                                        var"##938" = (var"##cache#937").value
                                                                        var"##938" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                    end && (var"##938"[1] == :parameters && (begin
                                                                                var"##939" = var"##938"[2]
                                                                                var"##939" isa AbstractArray
                                                                            end && ((ndims(var"##939") === 1 && length(var"##939") >= 0) && begin
                                                                                    var"##940" = SubArray(var"##939", (1:length(var"##939"),))
                                                                                    var"##941" = SubArray(var"##935", (2:length(var"##935"),))
                                                                                    true
                                                                                end)))))))))))))
                        args = var"##941"
                        kwargs = var"##940"
                        var"##return#744" = begin
                                keyword("return ")
                                p(Expr(:tuple, Expr(:parameters, kwargs...), args...))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##942" = (var"##cache#747").value
                                var"##942" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##942"[1] == :return && (begin
                                        var"##943" = var"##942"[2]
                                        var"##943" isa AbstractArray
                                    end && (length(var"##943") === 1 && (begin
                                                begin
                                                    var"##cache#945" = nothing
                                                end
                                                var"##944" = var"##943"[1]
                                                var"##944" isa Expr
                                            end && (begin
                                                    if var"##cache#945" === nothing
                                                        var"##cache#945" = Some(((var"##944").head, (var"##944").args))
                                                    end
                                                    var"##946" = (var"##cache#945").value
                                                    var"##946" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##946"[1] == :tuple && (begin
                                                            var"##947" = var"##946"[2]
                                                            var"##947" isa AbstractArray
                                                        end && ((ndims(var"##947") === 1 && length(var"##947") >= 0) && begin
                                                                var"##948" = SubArray(var"##947", (1:length(var"##947"),))
                                                                true
                                                            end))))))))
                        args = var"##948"
                        var"##return#744" = begin
                                keyword("return ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##949" = (var"##cache#747").value
                                var"##949" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##949"[1] == :return && (begin
                                        var"##950" = var"##949"[2]
                                        var"##950" isa AbstractArray
                                    end && ((ndims(var"##950") === 1 && length(var"##950") >= 0) && begin
                                            var"##951" = SubArray(var"##950", (1:length(var"##950"),))
                                            true
                                        end)))
                        args = var"##951"
                        var"##return#744" = begin
                                keyword("return ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##952" = (var"##cache#747").value
                                var"##952" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##952"[1] == :module && (begin
                                        var"##953" = var"##952"[2]
                                        var"##953" isa AbstractArray
                                    end && (length(var"##953") === 3 && begin
                                            var"##954" = var"##953"[1]
                                            var"##955" = var"##953"[2]
                                            var"##956" = var"##953"[3]
                                            true
                                        end)))
                        bare = var"##954"
                        name = var"##955"
                        body = var"##956"
                        var"##return#744" = begin
                                if bare
                                    keyword("module ")
                                else
                                    keyword("baremodule ")
                                end
                                p(name)
                                print("; ")
                                noblock(body)
                                keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##957" = (var"##cache#747").value
                                var"##957" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##957"[1] == :using && (begin
                                        var"##958" = var"##957"[2]
                                        var"##958" isa AbstractArray
                                    end && ((ndims(var"##958") === 1 && length(var"##958") >= 0) && begin
                                            var"##959" = SubArray(var"##958", (1:length(var"##958"),))
                                            true
                                        end)))
                        args = var"##959"
                        var"##return#744" = begin
                                keyword("using ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##960" = (var"##cache#747").value
                                var"##960" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##960"[1] == :import && (begin
                                        var"##961" = var"##960"[2]
                                        var"##961" isa AbstractArray
                                    end && ((ndims(var"##961") === 1 && length(var"##961") >= 0) && begin
                                            var"##962" = SubArray(var"##961", (1:length(var"##961"),))
                                            true
                                        end)))
                        args = var"##962"
                        var"##return#744" = begin
                                keyword("import ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##963" = (var"##cache#747").value
                                var"##963" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##963"[1] == :as && (begin
                                        var"##964" = var"##963"[2]
                                        var"##964" isa AbstractArray
                                    end && (length(var"##964") === 2 && begin
                                            var"##965" = var"##964"[1]
                                            var"##966" = var"##964"[2]
                                            true
                                        end)))
                        name = var"##965"
                        alias = var"##966"
                        var"##return#744" = begin
                                p(name)
                                keyword(" as ")
                                p(alias)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##967" = (var"##cache#747").value
                                var"##967" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##967"[1] == :export && (begin
                                        var"##968" = var"##967"[2]
                                        var"##968" isa AbstractArray
                                    end && ((ndims(var"##968") === 1 && length(var"##968") >= 0) && begin
                                            var"##969" = SubArray(var"##968", (1:length(var"##968"),))
                                            true
                                        end)))
                        args = var"##969"
                        var"##return#744" = begin
                                keyword("export ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##970" = (var"##cache#747").value
                                var"##970" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##970"[1] == :(:) && (begin
                                        var"##971" = var"##970"[2]
                                        var"##971" isa AbstractArray
                                    end && ((ndims(var"##971") === 1 && length(var"##971") >= 1) && begin
                                            var"##972" = var"##971"[1]
                                            var"##973" = SubArray(var"##971", (2:length(var"##971"),))
                                            true
                                        end)))
                        args = var"##973"
                        head = var"##972"
                        var"##return#744" = begin
                                p(head)
                                keyword(": ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##974" = (var"##cache#747").value
                                var"##974" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##974"[1] == :where && (begin
                                        var"##975" = var"##974"[2]
                                        var"##975" isa AbstractArray
                                    end && ((ndims(var"##975") === 1 && length(var"##975") >= 1) && begin
                                            var"##976" = var"##975"[1]
                                            var"##977" = SubArray(var"##975", (2:length(var"##975"),))
                                            true
                                        end)))
                        body = var"##976"
                        whereparams = var"##977"
                        var"##return#744" = begin
                                p(body)
                                keyword(" where {")
                                with(p.state, :type, true) do 
                                    join(whereparams, ", ")
                                end
                                keyword("}")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##978" = (var"##cache#747").value
                                var"##978" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##978"[1] == :for && (begin
                                        var"##979" = var"##978"[2]
                                        var"##979" isa AbstractArray
                                    end && (length(var"##979") === 2 && begin
                                            var"##980" = var"##979"[1]
                                            var"##981" = var"##979"[2]
                                            true
                                        end)))
                        body = var"##981"
                        iteration = var"##980"
                        var"##return#744" = begin
                                preced = p.state.precedence
                                p.state.precedence = 0
                                with(p.state, :loop_iterator, true) do 
                                    keyword("for ")
                                    noblock(iteration)
                                    keyword("; ")
                                    noblock(body)
                                    keyword("; end")
                                end
                                p.state.precedence = preced
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##982" = (var"##cache#747").value
                                var"##982" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##982"[1] == :while && (begin
                                        var"##983" = var"##982"[2]
                                        var"##983" isa AbstractArray
                                    end && (length(var"##983") === 2 && begin
                                            var"##984" = var"##983"[1]
                                            var"##985" = var"##983"[2]
                                            true
                                        end)))
                        body = var"##985"
                        condition = var"##984"
                        var"##return#744" = begin
                                keyword("while ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##986" = (var"##cache#747").value
                                var"##986" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##986"[1] == :continue && (begin
                                        var"##987" = var"##986"[2]
                                        var"##987" isa AbstractArray
                                    end && isempty(var"##987")))
                        var"##return#744" = begin
                                keyword("continue")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##988" = (var"##cache#747").value
                                var"##988" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##988"[1] == :if && (begin
                                        var"##989" = var"##988"[2]
                                        var"##989" isa AbstractArray
                                    end && (length(var"##989") === 2 && begin
                                            var"##990" = var"##989"[1]
                                            var"##991" = var"##989"[2]
                                            true
                                        end)))
                        body = var"##991"
                        condition = var"##990"
                        var"##return#744" = begin
                                keyword("if ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##992" = (var"##cache#747").value
                                var"##992" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##992"[1] == :if && (begin
                                        var"##993" = var"##992"[2]
                                        var"##993" isa AbstractArray
                                    end && (length(var"##993") === 3 && begin
                                            var"##994" = var"##993"[1]
                                            var"##995" = var"##993"[2]
                                            var"##996" = var"##993"[3]
                                            true
                                        end)))
                        body = var"##995"
                        elsebody = var"##996"
                        condition = var"##994"
                        var"##return#744" = begin
                                keyword("if ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                                keyword("; ")
                                Meta.isexpr(elsebody, :elseif) || keyword("else ")
                                noblock(elsebody)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##997" = (var"##cache#747").value
                                var"##997" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##997"[1] == :elseif && (begin
                                        var"##998" = var"##997"[2]
                                        var"##998" isa AbstractArray
                                    end && (length(var"##998") === 2 && begin
                                            var"##999" = var"##998"[1]
                                            var"##1000" = var"##998"[2]
                                            true
                                        end)))
                        body = var"##1000"
                        condition = var"##999"
                        var"##return#744" = begin
                                keyword("elseif ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##1001" = (var"##cache#747").value
                                var"##1001" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1001"[1] == :elseif && (begin
                                        var"##1002" = var"##1001"[2]
                                        var"##1002" isa AbstractArray
                                    end && (length(var"##1002") === 3 && begin
                                            var"##1003" = var"##1002"[1]
                                            var"##1004" = var"##1002"[2]
                                            var"##1005" = var"##1002"[3]
                                            true
                                        end)))
                        body = var"##1004"
                        elsebody = var"##1005"
                        condition = var"##1003"
                        var"##return#744" = begin
                                keyword("elseif ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                                keyword("; ")
                                Meta.isexpr(elsebody, :elseif) || keyword("else")
                                noblock(elsebody)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##1006" = (var"##cache#747").value
                                var"##1006" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1006"[1] == :try && (begin
                                        var"##1007" = var"##1006"[2]
                                        var"##1007" isa AbstractArray
                                    end && (length(var"##1007") === 3 && begin
                                            var"##1008" = var"##1007"[1]
                                            var"##1009" = var"##1007"[2]
                                            var"##1010" = var"##1007"[3]
                                            true
                                        end)))
                        catch_vars = var"##1009"
                        catch_body = var"##1010"
                        try_body = var"##1008"
                        var"##return#744" = begin
                                keyword("try ")
                                noblock(try_body)
                                keyword("; ")
                                keyword("catch")
                                catch_vars == false || begin
                                        print(" ")
                                        noblock(catch_vars)
                                    end
                                keyword(";")
                                noblock(catch_body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##1011" = (var"##cache#747").value
                                var"##1011" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1011"[1] == :try && (begin
                                        var"##1012" = var"##1011"[2]
                                        var"##1012" isa AbstractArray
                                    end && (length(var"##1012") === 4 && begin
                                            var"##1013" = var"##1012"[1]
                                            var"##1014" = var"##1012"[2]
                                            var"##1015" = var"##1012"[3]
                                            var"##1016" = var"##1012"[4]
                                            true
                                        end)))
                        catch_vars = var"##1014"
                        catch_body = var"##1015"
                        try_body = var"##1013"
                        finally_body = var"##1016"
                        var"##return#744" = begin
                                keyword("try ")
                                noblock(try_body)
                                keyword("; ")
                                catch_vars == false || begin
                                        keyword("catch ")
                                        noblock(catch_vars)
                                    end
                                catch_vars == false || begin
                                        keyword("; ")
                                        noblock(catch_body)
                                    end
                                finally_body == false || begin
                                        keyword("; finally ")
                                        noblock(finally_body)
                                    end
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##1017" = (var"##cache#747").value
                                var"##1017" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1017"[1] == :try && (begin
                                        var"##1018" = var"##1017"[2]
                                        var"##1018" isa AbstractArray
                                    end && (length(var"##1018") === 5 && begin
                                            var"##1019" = var"##1018"[1]
                                            var"##1020" = var"##1018"[2]
                                            var"##1021" = var"##1018"[3]
                                            var"##1022" = var"##1018"[4]
                                            var"##1023" = var"##1018"[5]
                                            true
                                        end)))
                        catch_vars = var"##1020"
                        catch_body = var"##1021"
                        try_body = var"##1019"
                        finally_body = var"##1022"
                        else_body = var"##1023"
                        var"##return#744" = begin
                                keyword("try ")
                                noblock(try_body)
                                keyword("; ")
                                catch_vars == false || begin
                                        keyword("catch ")
                                        noblock(catch_vars)
                                    end
                                catch_vars == false || begin
                                        keyword("; ")
                                        noblock(catch_body)
                                    end
                                keyword("; else ")
                                noblock(else_body)
                                finally_body == false || begin
                                        keyword("; finally ")
                                        noblock(finally_body)
                                    end
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##1024" = (var"##cache#747").value
                                var"##1024" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1024"[1] == :struct && (begin
                                        var"##1025" = var"##1024"[2]
                                        var"##1025" isa AbstractArray
                                    end && (length(var"##1025") === 3 && begin
                                            var"##1026" = var"##1025"[1]
                                            var"##1027" = var"##1025"[2]
                                            var"##1028" = var"##1025"[3]
                                            true
                                        end)))
                        ismutable = var"##1026"
                        name = var"##1027"
                        body = var"##1028"
                        var"##return#744" = begin
                                if ismutable
                                    keyword("mutable struct ")
                                else
                                    keyword("struct ")
                                end
                                p(name)
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##1029" = (var"##cache#747").value
                                var"##1029" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1029"[1] == :abstract && (begin
                                        var"##1030" = var"##1029"[2]
                                        var"##1030" isa AbstractArray
                                    end && (length(var"##1030") === 1 && begin
                                            var"##1031" = var"##1030"[1]
                                            true
                                        end)))
                        name = var"##1031"
                        var"##return#744" = begin
                                keyword("abstract type ")
                                p(name)
                                keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##1032" = (var"##cache#747").value
                                var"##1032" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1032"[1] == :primitive && (begin
                                        var"##1033" = var"##1032"[2]
                                        var"##1033" isa AbstractArray
                                    end && (length(var"##1033") === 2 && begin
                                            var"##1034" = var"##1033"[1]
                                            var"##1035" = var"##1033"[2]
                                            true
                                        end)))
                        name = var"##1034"
                        size = var"##1035"
                        var"##return#744" = begin
                                keyword("primitive type ")
                                p(name)
                                print(" ")
                                p(size)
                                keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##1036" = (var"##cache#747").value
                                var"##1036" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1036"[1] == :meta && (begin
                                        var"##1037" = var"##1036"[2]
                                        var"##1037" isa AbstractArray
                                    end && (length(var"##1037") === 1 && var"##1037"[1] == :inline)))
                        var"##return#744" = begin
                                macrocall(GlobalRef(Base, Symbol("@_inline_meta")))
                                keyword(";")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##1038" = (var"##cache#747").value
                                var"##1038" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1038"[1] == :break && (begin
                                        var"##1039" = var"##1038"[2]
                                        var"##1039" isa AbstractArray
                                    end && isempty(var"##1039")))
                        var"##return#744" = begin
                                keyword("break")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##1040" = (var"##cache#747").value
                                var"##1040" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1040"[1] == :symboliclabel && (begin
                                        var"##1041" = var"##1040"[2]
                                        var"##1041" isa AbstractArray
                                    end && (length(var"##1041") === 1 && begin
                                            var"##1042" = var"##1041"[1]
                                            true
                                        end)))
                        label = var"##1042"
                        var"##return#744" = begin
                                macrocall(GlobalRef(Base, Symbol("@label")))
                                print(" ")
                                p(label)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##1043" = (var"##cache#747").value
                                var"##1043" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1043"[1] == :symbolicgoto && (begin
                                        var"##1044" = var"##1043"[2]
                                        var"##1044" isa AbstractArray
                                    end && (length(var"##1044") === 1 && begin
                                            var"##1045" = var"##1044"[1]
                                            true
                                        end)))
                        label = var"##1045"
                        var"##return#744" = begin
                                macrocall(GlobalRef(Base, Symbol("@goto")))
                                print(" ")
                                p(label)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    if begin
                                var"##1046" = (var"##cache#747").value
                                var"##1046" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1047" = var"##1046"[1]
                                    var"##1048" = var"##1046"[2]
                                    var"##1048" isa AbstractArray
                                end && ((ndims(var"##1048") === 1 && length(var"##1048") >= 0) && begin
                                        var"##1049" = SubArray(var"##1048", (1:length(var"##1048"),))
                                        true
                                    end))
                        args = var"##1049"
                        head = var"##1047"
                        var"##return#744" = begin
                                keyword('$')
                                print("(")
                                printstyled(:Expr, color = c.call)
                                print("(")
                                keyword(":")
                                printstyled(head, color = c.symbol)
                                print(", ")
                                join(args)
                                print("))")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                end
                if var"##746" isa Number
                    begin
                        var"##return#744" = begin
                                printstyled(ex, color = c.number)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                end
                if var"##746" isa QuoteNode
                    if ex.value in Base.quoted_syms
                        var"##return#744" = begin
                                keyword(":(")
                                quoted(ex.value)
                                keyword(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                    begin
                        var"##return#744" = begin
                                if ex.value isa Symbol && Base.isidentifier(ex.value)
                                    keyword(":")
                                    quoted(ex.value)
                                else
                                    keyword(":(")
                                    quoted(ex.value)
                                    keyword(")")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                end
                if var"##746" isa String
                    begin
                        var"##return#744" = begin
                                string(ex)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                end
                if var"##746" isa LineNumberNode
                    begin
                        var"##return#744" = begin
                                p.line || return nothing
                                printstyled("#= $(ex.file):$(ex.line) =#", color = c.line)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                end
                if var"##746" isa Char
                    begin
                        var"##return#744" = begin
                                printstyled(repr(ex), color = c.string)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                    end
                end
                begin
                    var"##return#744" = begin
                            print(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#745#1050")))
                end
                error("matching non-exhaustive, at #= none:142 =#")
                $(Expr(:symboliclabel, Symbol("####final#745#1050")))
                var"##return#744"
            end
        end
        print_expr(expr)
        return nothing
    end
    #= none:455 =# Core.@doc "    print_expr([io::IO], ex; kw...)\n\nPrint a given expression within one line.\n`ex` can be a `Expr` or a syntax type `JLExpr`.\n" print_inline(io::IO, expr; kw...) = begin
                (InlinePrinter(io; kw...))(expr)
            end
    print_inline(expr; kw...) = begin
            (InlinePrinter(stdout; kw...))(expr)
        end
