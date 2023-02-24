
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
                        var"##cache#721" = nothing
                    end
                    var"##return#718" = nothing
                    var"##720" = ex
                    if var"##720" isa Expr
                        if begin
                                    if var"##cache#721" === nothing
                                        var"##cache#721" = Some(((var"##720").head, (var"##720").args))
                                    end
                                    var"##722" = (var"##cache#721").value
                                    var"##722" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##722"[1] == :. && (begin
                                            var"##723" = var"##722"[2]
                                            var"##723" isa AbstractArray
                                        end && (ndims(var"##723") === 1 && length(var"##723") >= 0)))
                            var"##return#718" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#719#724")))
                        end
                    end
                    if var"##720" isa Symbol
                        begin
                            var"##return#718" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#719#724")))
                        end
                    end
                    begin
                        var"##return#718" = let
                                false
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#719#724")))
                    end
                    error("matching non-exhaustive, at #= none:85 =#")
                    $(Expr(:symboliclabel, Symbol("####final#719#724")))
                    var"##return#718"
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
                    var"##cache#728" = nothing
                end
                var"##727" = ex
                if var"##727" isa Expr && (begin
                                if var"##cache#728" === nothing
                                    var"##cache#728" = Some(((var"##727").head, (var"##727").args))
                                end
                                var"##729" = (var"##cache#728").value
                                var"##729" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##729"[1] == :call && (begin
                                        var"##730" = var"##729"[2]
                                        var"##730" isa AbstractArray
                                    end && ((ndims(var"##730") === 1 && length(var"##730") >= 1) && (var"##730"[1] == :(:) && begin
                                                var"##731" = SubArray(var"##730", (2:length(var"##730"),))
                                                true
                                            end)))))
                    args = var"##731"
                    var"##return#725" = begin
                            precedence(:(:)) do 
                                join(args, ":")
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#726#753")))
                end
                if var"##727" isa Expr && (begin
                                if var"##cache#728" === nothing
                                    var"##cache#728" = Some(((var"##727").head, (var"##727").args))
                                end
                                var"##732" = (var"##cache#728").value
                                var"##732" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##732"[1] == :call && (begin
                                        var"##733" = var"##732"[2]
                                        var"##733" isa AbstractArray
                                    end && (length(var"##733") === 2 && (begin
                                                var"##734" = var"##733"[1]
                                                var"##734" isa Symbol
                                            end && begin
                                                var"##735" = var"##733"[2]
                                                let f = var"##734", arg = var"##735"
                                                    Base.isunaryoperator(f)
                                                end
                                            end)))))
                    f = var"##734"
                    arg = var"##735"
                    var"##return#725" = begin
                            precedence(typemax(Int)) do 
                                keyword(f)
                                p(arg)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#726#753")))
                end
                if var"##727" isa Expr && (begin
                                if var"##cache#728" === nothing
                                    var"##cache#728" = Some(((var"##727").head, (var"##727").args))
                                end
                                var"##736" = (var"##cache#728").value
                                var"##736" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##736"[1] == :call && (begin
                                        var"##737" = var"##736"[2]
                                        var"##737" isa AbstractArray
                                    end && ((ndims(var"##737") === 1 && length(var"##737") >= 1) && (begin
                                                var"##738" = var"##737"[1]
                                                var"##738" isa Symbol
                                            end && begin
                                                var"##739" = SubArray(var"##737", (2:length(var"##737"),))
                                                let f = var"##738", args = var"##739"
                                                    Base.isbinaryoperator(f)
                                                end
                                            end)))))
                    f = var"##738"
                    args = var"##739"
                    var"##return#725" = begin
                            precedence(f) do 
                                join(args, " $(f) ")
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#726#753")))
                end
                if var"##727" isa Expr && (begin
                                if var"##cache#728" === nothing
                                    var"##cache#728" = Some(((var"##727").head, (var"##727").args))
                                end
                                var"##740" = (var"##cache#728").value
                                var"##740" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##740"[1] == :call && (begin
                                        var"##741" = var"##740"[2]
                                        var"##741" isa AbstractArray
                                    end && ((ndims(var"##741") === 1 && length(var"##741") >= 2) && (begin
                                                var"##742" = var"##741"[1]
                                                begin
                                                    var"##cache#744" = nothing
                                                end
                                                var"##743" = var"##741"[2]
                                                var"##743" isa Expr
                                            end && (begin
                                                    if var"##cache#744" === nothing
                                                        var"##cache#744" = Some(((var"##743").head, (var"##743").args))
                                                    end
                                                    var"##745" = (var"##cache#744").value
                                                    var"##745" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##745"[1] == :parameters && (begin
                                                            var"##746" = var"##745"[2]
                                                            var"##746" isa AbstractArray
                                                        end && ((ndims(var"##746") === 1 && length(var"##746") >= 0) && begin
                                                                var"##747" = SubArray(var"##746", (1:length(var"##746"),))
                                                                var"##748" = SubArray(var"##741", (3:length(var"##741"),))
                                                                true
                                                            end)))))))))
                    f = var"##742"
                    args = var"##748"
                    kwargs = var"##747"
                    var"##return#725" = begin
                            call(f)
                            print("(")
                            join(args)
                            keyword("; ")
                            join(kwargs)
                            print(")")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#726#753")))
                end
                if var"##727" isa Expr && (begin
                                if var"##cache#728" === nothing
                                    var"##cache#728" = Some(((var"##727").head, (var"##727").args))
                                end
                                var"##749" = (var"##cache#728").value
                                var"##749" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##749"[1] == :call && (begin
                                        var"##750" = var"##749"[2]
                                        var"##750" isa AbstractArray
                                    end && ((ndims(var"##750") === 1 && length(var"##750") >= 1) && begin
                                            var"##751" = var"##750"[1]
                                            var"##752" = SubArray(var"##750", (2:length(var"##750"),))
                                            true
                                        end))))
                    f = var"##751"
                    args = var"##752"
                    var"##return#725" = begin
                            call(f)
                            print_braces(args, "(", ")")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#726#753")))
                end
                error("matching non-exhaustive, at #= none:111 =#")
                $(Expr(:symboliclabel, Symbol("####final#726#753")))
                var"##return#725"
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
                    var"##cache#757" = nothing
                end
                var"##756" = ex
                if var"##756" isa Char
                    begin
                        var"##return#754" = begin
                                printstyled(repr(ex), color = c.string)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                end
                if var"##756" isa Nothing
                    begin
                        var"##return#754" = begin
                                printstyled("nothing", color = c.number)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                end
                if var"##756" isa Symbol
                    begin
                        var"##return#754" = begin
                                symbol(ex)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                end
                if var"##756" isa Expr
                    if begin
                                if var"##cache#757" === nothing
                                    var"##cache#757" = Some(((var"##756").head, (var"##756").args))
                                end
                                var"##758" = (var"##cache#757").value
                                var"##758" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##758"[1] == :line && (begin
                                        var"##759" = var"##758"[2]
                                        var"##759" isa AbstractArray
                                    end && (length(var"##759") === 2 && begin
                                            var"##760" = var"##759"[1]
                                            var"##761" = var"##759"[2]
                                            true
                                        end)))
                        line = var"##761"
                        file = var"##760"
                        var"##return#754" = begin
                                p.line || return nothing
                                printstyled("#= $(file):$(line) =#", color = c.line)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##762" = (var"##cache#757").value
                                var"##762" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##762"[1] == :kw && (begin
                                        var"##763" = var"##762"[2]
                                        var"##763" isa AbstractArray
                                    end && (length(var"##763") === 2 && begin
                                            var"##764" = var"##763"[1]
                                            var"##765" = var"##763"[2]
                                            true
                                        end)))
                        k = var"##764"
                        v = var"##765"
                        var"##return#754" = begin
                                p(k)
                                print(" = ")
                                p(v)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##766" = (var"##cache#757").value
                                var"##766" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##766"[1] == :(=) && (begin
                                        var"##767" = var"##766"[2]
                                        var"##767" isa AbstractArray
                                    end && (length(var"##767") === 2 && (begin
                                                var"##768" = var"##767"[1]
                                                begin
                                                    var"##cache#770" = nothing
                                                end
                                                var"##769" = var"##767"[2]
                                                var"##769" isa Expr
                                            end && (begin
                                                    if var"##cache#770" === nothing
                                                        var"##cache#770" = Some(((var"##769").head, (var"##769").args))
                                                    end
                                                    var"##771" = (var"##cache#770").value
                                                    var"##771" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##771"[1] == :block && (begin
                                                            var"##772" = var"##771"[2]
                                                            var"##772" isa AbstractArray
                                                        end && ((ndims(var"##772") === 1 && length(var"##772") >= 0) && begin
                                                                var"##773" = SubArray(var"##772", (1:length(var"##772"),))
                                                                true
                                                            end))))))))
                        k = var"##768"
                        stmts = var"##773"
                        var"##return#754" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##774" = (var"##cache#757").value
                                var"##774" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##774"[1] == :(=) && (begin
                                        var"##775" = var"##774"[2]
                                        var"##775" isa AbstractArray
                                    end && (length(var"##775") === 2 && begin
                                            var"##776" = var"##775"[1]
                                            var"##777" = var"##775"[2]
                                            true
                                        end)))
                        k = var"##776"
                        v = var"##777"
                        var"##return#754" = begin
                                precedence(:(=)) do 
                                    p(k)
                                    assign()
                                    p(v)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##778" = (var"##cache#757").value
                                var"##778" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##778"[1] == :... && (begin
                                        var"##779" = var"##778"[2]
                                        var"##779" isa AbstractArray
                                    end && (length(var"##779") === 1 && begin
                                            var"##780" = var"##779"[1]
                                            true
                                        end)))
                        name = var"##780"
                        var"##return#754" = begin
                                precedence(:...) do 
                                    p(name)
                                    keyword("...")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##781" = (var"##cache#757").value
                                var"##781" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##781"[1] == :& && (begin
                                        var"##782" = var"##781"[2]
                                        var"##782" isa AbstractArray
                                    end && (length(var"##782") === 1 && begin
                                            var"##783" = var"##782"[1]
                                            true
                                        end)))
                        name = var"##783"
                        var"##return#754" = begin
                                precedence(:&) do 
                                    keyword("&")
                                    p(name)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##784" = (var"##cache#757").value
                                var"##784" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##784"[1] == :(::) && (begin
                                        var"##785" = var"##784"[2]
                                        var"##785" isa AbstractArray
                                    end && (length(var"##785") === 1 && begin
                                            var"##786" = var"##785"[1]
                                            true
                                        end)))
                        t = var"##786"
                        var"##return#754" = begin
                                precedence(:(::)) do 
                                    keyword("::")
                                    type(t)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##787" = (var"##cache#757").value
                                var"##787" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##787"[1] == :(::) && (begin
                                        var"##788" = var"##787"[2]
                                        var"##788" isa AbstractArray
                                    end && (length(var"##788") === 2 && begin
                                            var"##789" = var"##788"[1]
                                            var"##790" = var"##788"[2]
                                            true
                                        end)))
                        name = var"##789"
                        t = var"##790"
                        var"##return#754" = begin
                                precedence(:(::)) do 
                                    p(name)
                                    keyword("::")
                                    type(t)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##791" = (var"##cache#757").value
                                var"##791" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##791"[1] == :$ && (begin
                                        var"##792" = var"##791"[2]
                                        var"##792" isa AbstractArray
                                    end && (length(var"##792") === 1 && begin
                                            var"##793" = var"##792"[1]
                                            true
                                        end)))
                        name = var"##793"
                        var"##return#754" = begin
                                precedence(:$) do 
                                    keyword('$')
                                    print("(")
                                    p(name)
                                    print(")")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##794" = (var"##cache#757").value
                                var"##794" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##795" = var"##794"[1]
                                    var"##796" = var"##794"[2]
                                    var"##796" isa AbstractArray
                                end && (length(var"##796") === 2 && begin
                                        var"##797" = var"##796"[1]
                                        var"##798" = var"##796"[2]
                                        let rhs = var"##798", lhs = var"##797", head = var"##795"
                                            head in expr_infix_wide
                                        end
                                    end))
                        rhs = var"##798"
                        lhs = var"##797"
                        head = var"##795"
                        var"##return#754" = begin
                                precedence(head) do 
                                    p(lhs)
                                    keyword(" $(head) ")
                                    p(rhs)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##799" = (var"##cache#757").value
                                var"##799" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##799"[1] == :. && (begin
                                        var"##800" = var"##799"[2]
                                        var"##800" isa AbstractArray
                                    end && (length(var"##800") === 1 && begin
                                            var"##801" = var"##800"[1]
                                            true
                                        end)))
                        name = var"##801"
                        var"##return#754" = begin
                                print(name)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##802" = (var"##cache#757").value
                                var"##802" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##802"[1] == :. && (begin
                                        var"##803" = var"##802"[2]
                                        var"##803" isa AbstractArray
                                    end && (length(var"##803") === 2 && (begin
                                                var"##804" = var"##803"[1]
                                                var"##805" = var"##803"[2]
                                                var"##805" isa QuoteNode
                                            end && begin
                                                var"##806" = (var"##805").value
                                                true
                                            end))))
                        name = var"##806"
                        object = var"##804"
                        var"##return#754" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##807" = (var"##cache#757").value
                                var"##807" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##807"[1] == :. && (begin
                                        var"##808" = var"##807"[2]
                                        var"##808" isa AbstractArray
                                    end && (length(var"##808") === 2 && begin
                                            var"##809" = var"##808"[1]
                                            var"##810" = var"##808"[2]
                                            true
                                        end)))
                        name = var"##810"
                        object = var"##809"
                        var"##return#754" = begin
                                precedence(:.) do 
                                    p(object)
                                    keyword(".")
                                    p(name)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##811" = (var"##cache#757").value
                                var"##811" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##811"[1] == :<: && (begin
                                        var"##812" = var"##811"[2]
                                        var"##812" isa AbstractArray
                                    end && (length(var"##812") === 2 && begin
                                            var"##813" = var"##812"[1]
                                            var"##814" = var"##812"[2]
                                            true
                                        end)))
                        type = var"##813"
                        supertype = var"##814"
                        var"##return#754" = begin
                                precedence(:<:) do 
                                    p(type)
                                    keyword(" <: ")
                                    p(supertype)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##815" = (var"##cache#757").value
                                var"##815" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##815"[1] == :call && (begin
                                        var"##816" = var"##815"[2]
                                        var"##816" isa AbstractArray
                                    end && (ndims(var"##816") === 1 && length(var"##816") >= 0)))
                        var"##return#754" = begin
                                print_call(ex)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##817" = (var"##cache#757").value
                                var"##817" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##817"[1] == :tuple && (begin
                                        var"##818" = var"##817"[2]
                                        var"##818" isa AbstractArray
                                    end && (length(var"##818") === 1 && (begin
                                                begin
                                                    var"##cache#820" = nothing
                                                end
                                                var"##819" = var"##818"[1]
                                                var"##819" isa Expr
                                            end && (begin
                                                    if var"##cache#820" === nothing
                                                        var"##cache#820" = Some(((var"##819").head, (var"##819").args))
                                                    end
                                                    var"##821" = (var"##cache#820").value
                                                    var"##821" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##821"[1] == :parameters && (begin
                                                            var"##822" = var"##821"[2]
                                                            var"##822" isa AbstractArray
                                                        end && ((ndims(var"##822") === 1 && length(var"##822") >= 0) && begin
                                                                var"##823" = SubArray(var"##822", (1:length(var"##822"),))
                                                                true
                                                            end))))))))
                        args = var"##823"
                        var"##return#754" = begin
                                print_braces(args, "(;", ")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##824" = (var"##cache#757").value
                                var"##824" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##824"[1] == :tuple && (begin
                                        var"##825" = var"##824"[2]
                                        var"##825" isa AbstractArray
                                    end && ((ndims(var"##825") === 1 && length(var"##825") >= 0) && begin
                                            var"##826" = SubArray(var"##825", (1:length(var"##825"),))
                                            true
                                        end)))
                        args = var"##826"
                        var"##return#754" = begin
                                if length(args) == 1
                                    print("(")
                                    p(args[1])
                                    print(",)")
                                else
                                    print_braces(args, "(", ")")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##827" = (var"##cache#757").value
                                var"##827" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##827"[1] == :curly && (begin
                                        var"##828" = var"##827"[2]
                                        var"##828" isa AbstractArray
                                    end && ((ndims(var"##828") === 1 && length(var"##828") >= 1) && begin
                                            var"##829" = var"##828"[1]
                                            var"##830" = SubArray(var"##828", (2:length(var"##828"),))
                                            true
                                        end)))
                        args = var"##830"
                        t = var"##829"
                        var"##return#754" = begin
                                with(p.state, :type, true) do 
                                    p(t)
                                    print_braces(args, "{", "}")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##831" = (var"##cache#757").value
                                var"##831" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##831"[1] == :vect && (begin
                                        var"##832" = var"##831"[2]
                                        var"##832" isa AbstractArray
                                    end && ((ndims(var"##832") === 1 && length(var"##832") >= 0) && begin
                                            var"##833" = SubArray(var"##832", (1:length(var"##832"),))
                                            true
                                        end)))
                        args = var"##833"
                        var"##return#754" = begin
                                print_braces(args, "[", "]")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##834" = (var"##cache#757").value
                                var"##834" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##834"[1] == :hcat && (begin
                                        var"##835" = var"##834"[2]
                                        var"##835" isa AbstractArray
                                    end && ((ndims(var"##835") === 1 && length(var"##835") >= 0) && begin
                                            var"##836" = SubArray(var"##835", (1:length(var"##835"),))
                                            true
                                        end)))
                        args = var"##836"
                        var"##return#754" = begin
                                print_braces(args, "[", "]", " ")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##837" = (var"##cache#757").value
                                var"##837" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##837"[1] == :typed_hcat && (begin
                                        var"##838" = var"##837"[2]
                                        var"##838" isa AbstractArray
                                    end && ((ndims(var"##838") === 1 && length(var"##838") >= 1) && begin
                                            var"##839" = var"##838"[1]
                                            var"##840" = SubArray(var"##838", (2:length(var"##838"),))
                                            true
                                        end)))
                        args = var"##840"
                        t = var"##839"
                        var"##return#754" = begin
                                type(t)
                                print_braces(args, "[", "]", " ")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##841" = (var"##cache#757").value
                                var"##841" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##841"[1] == :vcat && (begin
                                        var"##842" = var"##841"[2]
                                        var"##842" isa AbstractArray
                                    end && ((ndims(var"##842") === 1 && length(var"##842") >= 0) && begin
                                            var"##843" = SubArray(var"##842", (1:length(var"##842"),))
                                            true
                                        end)))
                        args = var"##843"
                        var"##return#754" = begin
                                print_braces(args, "[", "]", "; ")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##844" = (var"##cache#757").value
                                var"##844" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##844"[1] == :ncat && (begin
                                        var"##845" = var"##844"[2]
                                        var"##845" isa AbstractArray
                                    end && ((ndims(var"##845") === 1 && length(var"##845") >= 1) && begin
                                            var"##846" = var"##845"[1]
                                            var"##847" = SubArray(var"##845", (2:length(var"##845"),))
                                            true
                                        end)))
                        n = var"##846"
                        args = var"##847"
                        var"##return#754" = begin
                                print_braces(args, "[", "]", ";" ^ n * " ")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##848" = (var"##cache#757").value
                                var"##848" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##848"[1] == :ref && (begin
                                        var"##849" = var"##848"[2]
                                        var"##849" isa AbstractArray
                                    end && ((ndims(var"##849") === 1 && length(var"##849") >= 1) && begin
                                            var"##850" = var"##849"[1]
                                            var"##851" = SubArray(var"##849", (2:length(var"##849"),))
                                            true
                                        end)))
                        args = var"##851"
                        object = var"##850"
                        var"##return#754" = begin
                                p(object)
                                print_braces(args, "[", "]")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##852" = (var"##cache#757").value
                                var"##852" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##852"[1] == :comprehension && (begin
                                        var"##853" = var"##852"[2]
                                        var"##853" isa AbstractArray
                                    end && (length(var"##853") === 1 && (begin
                                                begin
                                                    var"##cache#855" = nothing
                                                end
                                                var"##854" = var"##853"[1]
                                                var"##854" isa Expr
                                            end && (begin
                                                    if var"##cache#855" === nothing
                                                        var"##cache#855" = Some(((var"##854").head, (var"##854").args))
                                                    end
                                                    var"##856" = (var"##cache#855").value
                                                    var"##856" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##856"[1] == :generator && (begin
                                                            var"##857" = var"##856"[2]
                                                            var"##857" isa AbstractArray
                                                        end && (length(var"##857") === 2 && begin
                                                                var"##858" = var"##857"[1]
                                                                var"##859" = var"##857"[2]
                                                                true
                                                            end))))))))
                        iter = var"##858"
                        body = var"##859"
                        var"##return#754" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##860" = (var"##cache#757").value
                                var"##860" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##860"[1] == :typed_comprehension && (begin
                                        var"##861" = var"##860"[2]
                                        var"##861" isa AbstractArray
                                    end && (length(var"##861") === 2 && (begin
                                                var"##862" = var"##861"[1]
                                                begin
                                                    var"##cache#864" = nothing
                                                end
                                                var"##863" = var"##861"[2]
                                                var"##863" isa Expr
                                            end && (begin
                                                    if var"##cache#864" === nothing
                                                        var"##cache#864" = Some(((var"##863").head, (var"##863").args))
                                                    end
                                                    var"##865" = (var"##cache#864").value
                                                    var"##865" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##865"[1] == :generator && (begin
                                                            var"##866" = var"##865"[2]
                                                            var"##866" isa AbstractArray
                                                        end && (length(var"##866") === 2 && begin
                                                                var"##867" = var"##866"[1]
                                                                var"##868" = var"##866"[2]
                                                                true
                                                            end))))))))
                        iter = var"##867"
                        body = var"##868"
                        t = var"##862"
                        var"##return#754" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##869" = (var"##cache#757").value
                                var"##869" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##869"[1] == :-> && (begin
                                        var"##870" = var"##869"[2]
                                        var"##870" isa AbstractArray
                                    end && (length(var"##870") === 2 && (begin
                                                var"##871" = var"##870"[1]
                                                begin
                                                    var"##cache#873" = nothing
                                                end
                                                var"##872" = var"##870"[2]
                                                var"##872" isa Expr
                                            end && (begin
                                                    if var"##cache#873" === nothing
                                                        var"##cache#873" = Some(((var"##872").head, (var"##872").args))
                                                    end
                                                    var"##874" = (var"##cache#873").value
                                                    var"##874" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##874"[1] == :block && (begin
                                                            var"##875" = var"##874"[2]
                                                            var"##875" isa AbstractArray
                                                        end && (length(var"##875") === 2 && begin
                                                                var"##876" = var"##875"[1]
                                                                var"##877" = var"##875"[2]
                                                                true
                                                            end))))))))
                        line = var"##876"
                        code = var"##877"
                        args = var"##871"
                        var"##return#754" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##878" = (var"##cache#757").value
                                var"##878" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##878"[1] == :-> && (begin
                                        var"##879" = var"##878"[2]
                                        var"##879" isa AbstractArray
                                    end && (length(var"##879") === 2 && begin
                                            var"##880" = var"##879"[1]
                                            var"##881" = var"##879"[2]
                                            true
                                        end)))
                        args = var"##880"
                        body = var"##881"
                        var"##return#754" = begin
                                p(args)
                                keyword(" -> ")
                                print("(")
                                noblock(body)
                                print(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##882" = (var"##cache#757").value
                                var"##882" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##882"[1] == :do && (begin
                                        var"##883" = var"##882"[2]
                                        var"##883" isa AbstractArray
                                    end && (length(var"##883") === 2 && (begin
                                                var"##884" = var"##883"[1]
                                                begin
                                                    var"##cache#886" = nothing
                                                end
                                                var"##885" = var"##883"[2]
                                                var"##885" isa Expr
                                            end && (begin
                                                    if var"##cache#886" === nothing
                                                        var"##cache#886" = Some(((var"##885").head, (var"##885").args))
                                                    end
                                                    var"##887" = (var"##cache#886").value
                                                    var"##887" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##887"[1] == :-> && (begin
                                                            var"##888" = var"##887"[2]
                                                            var"##888" isa AbstractArray
                                                        end && (length(var"##888") === 2 && (begin
                                                                    begin
                                                                        var"##cache#890" = nothing
                                                                    end
                                                                    var"##889" = var"##888"[1]
                                                                    var"##889" isa Expr
                                                                end && (begin
                                                                        if var"##cache#890" === nothing
                                                                            var"##cache#890" = Some(((var"##889").head, (var"##889").args))
                                                                        end
                                                                        var"##891" = (var"##cache#890").value
                                                                        var"##891" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                    end && (var"##891"[1] == :tuple && (begin
                                                                                var"##892" = var"##891"[2]
                                                                                var"##892" isa AbstractArray
                                                                            end && ((ndims(var"##892") === 1 && length(var"##892") >= 0) && begin
                                                                                    var"##893" = SubArray(var"##892", (1:length(var"##892"),))
                                                                                    var"##894" = var"##888"[2]
                                                                                    true
                                                                                end)))))))))))))
                        call = var"##884"
                        args = var"##893"
                        body = var"##894"
                        var"##return#754" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##895" = (var"##cache#757").value
                                var"##895" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##895"[1] == :function && (begin
                                        var"##896" = var"##895"[2]
                                        var"##896" isa AbstractArray
                                    end && (length(var"##896") === 2 && begin
                                            var"##897" = var"##896"[1]
                                            var"##898" = var"##896"[2]
                                            true
                                        end)))
                        call = var"##897"
                        body = var"##898"
                        var"##return#754" = begin
                                print_function(:function, call, body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##899" = (var"##cache#757").value
                                var"##899" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##899"[1] == :quote && (begin
                                        var"##900" = var"##899"[2]
                                        var"##900" isa AbstractArray
                                    end && (length(var"##900") === 1 && begin
                                            var"##901" = var"##900"[1]
                                            true
                                        end)))
                        stmt = var"##901"
                        var"##return#754" = begin
                                keyword(":(")
                                noblock(stmt)
                                keyword(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##902" = (var"##cache#757").value
                                var"##902" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##902"[1] == :quote && (begin
                                        var"##903" = var"##902"[2]
                                        var"##903" isa AbstractArray
                                    end && ((ndims(var"##903") === 1 && length(var"##903") >= 0) && begin
                                            var"##904" = SubArray(var"##903", (1:length(var"##903"),))
                                            true
                                        end)))
                        args = var"##904"
                        var"##return#754" = begin
                                keyword("quote ")
                                with(p.state, :block, false) do 
                                    join(args, "; ")
                                end
                                keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##905" = (var"##cache#757").value
                                var"##905" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##905"[1] == :string && (begin
                                        var"##906" = var"##905"[2]
                                        var"##906" isa AbstractArray
                                    end && ((ndims(var"##906") === 1 && length(var"##906") >= 0) && begin
                                            var"##907" = SubArray(var"##906", (1:length(var"##906"),))
                                            true
                                        end)))
                        args = var"##907"
                        var"##return#754" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##908" = (var"##cache#757").value
                                var"##908" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##908"[1] == :block && (begin
                                        var"##909" = var"##908"[2]
                                        var"##909" isa AbstractArray
                                    end && ((ndims(var"##909") === 1 && length(var"##909") >= 0) && begin
                                            var"##910" = SubArray(var"##909", (1:length(var"##909"),))
                                            let args = var"##910"
                                                length(args) == 2 && (is_line_no(args[1]) && is_line_no(args[2]))
                                            end
                                        end)))
                        args = var"##910"
                        var"##return#754" = begin
                                p(args[1])
                                print(" ")
                                p(args[2])
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##911" = (var"##cache#757").value
                                var"##911" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##911"[1] == :block && (begin
                                        var"##912" = var"##911"[2]
                                        var"##912" isa AbstractArray
                                    end && ((ndims(var"##912") === 1 && length(var"##912") >= 0) && begin
                                            var"##913" = SubArray(var"##912", (1:length(var"##912"),))
                                            let args = var"##913"
                                                length(args) == 2 && is_line_no(args[1])
                                            end
                                        end)))
                        args = var"##913"
                        var"##return#754" = begin
                                p(args[1])
                                print(" ")
                                noblock(args[2])
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##914" = (var"##cache#757").value
                                var"##914" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##914"[1] == :block && (begin
                                        var"##915" = var"##914"[2]
                                        var"##915" isa AbstractArray
                                    end && ((ndims(var"##915") === 1 && length(var"##915") >= 0) && begin
                                            var"##916" = SubArray(var"##915", (1:length(var"##915"),))
                                            let args = var"##916"
                                                length(args) == 2 && is_line_no(args[2])
                                            end
                                        end)))
                        args = var"##916"
                        var"##return#754" = begin
                                noblock(args[1])
                                print(" ")
                                p(args[2])
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##917" = (var"##cache#757").value
                                var"##917" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##917"[1] == :block && (begin
                                        var"##918" = var"##917"[2]
                                        var"##918" isa AbstractArray
                                    end && ((ndims(var"##918") === 1 && length(var"##918") >= 0) && begin
                                            var"##919" = SubArray(var"##918", (1:length(var"##918"),))
                                            let args = var"##919"
                                                length(args) == 2
                                            end
                                        end)))
                        args = var"##919"
                        var"##return#754" = begin
                                print("(")
                                noblock(args[1])
                                keyword("; ")
                                noblock(args[2])
                                print(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##920" = (var"##cache#757").value
                                var"##920" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##920"[1] == :block && (begin
                                        var"##921" = var"##920"[2]
                                        var"##921" isa AbstractArray
                                    end && ((ndims(var"##921") === 1 && length(var"##921") >= 0) && begin
                                            var"##922" = SubArray(var"##921", (1:length(var"##921"),))
                                            true
                                        end)))
                        args = var"##922"
                        var"##return#754" = begin
                                p.state.block && keyword("begin ")
                                with(p.state, :block, true) do 
                                    join(args, "; ")
                                end
                                p.state.block && keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##923" = (var"##cache#757").value
                                var"##923" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##923"[1] == :let && (begin
                                        var"##924" = var"##923"[2]
                                        var"##924" isa AbstractArray
                                    end && (length(var"##924") === 2 && (begin
                                                begin
                                                    var"##cache#926" = nothing
                                                end
                                                var"##925" = var"##924"[1]
                                                var"##925" isa Expr
                                            end && (begin
                                                    if var"##cache#926" === nothing
                                                        var"##cache#926" = Some(((var"##925").head, (var"##925").args))
                                                    end
                                                    var"##927" = (var"##cache#926").value
                                                    var"##927" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##927"[1] == :block && (begin
                                                            var"##928" = var"##927"[2]
                                                            var"##928" isa AbstractArray
                                                        end && ((ndims(var"##928") === 1 && length(var"##928") >= 0) && begin
                                                                var"##929" = SubArray(var"##928", (1:length(var"##928"),))
                                                                var"##930" = var"##924"[2]
                                                                true
                                                            end))))))))
                        args = var"##929"
                        body = var"##930"
                        var"##return#754" = begin
                                keyword("let ")
                                join(args, ", ")
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##931" = (var"##cache#757").value
                                var"##931" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##931"[1] == :let && (begin
                                        var"##932" = var"##931"[2]
                                        var"##932" isa AbstractArray
                                    end && (length(var"##932") === 2 && begin
                                            var"##933" = var"##932"[1]
                                            var"##934" = var"##932"[2]
                                            true
                                        end)))
                        arg = var"##933"
                        body = var"##934"
                        var"##return#754" = begin
                                keyword("let ")
                                p(arg)
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##935" = (var"##cache#757").value
                                var"##935" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##935"[1] == :macrocall && (begin
                                        var"##936" = var"##935"[2]
                                        var"##936" isa AbstractArray
                                    end && ((ndims(var"##936") === 1 && length(var"##936") >= 2) && begin
                                            var"##937" = var"##936"[1]
                                            var"##938" = var"##936"[2]
                                            var"##939" = SubArray(var"##936", (3:length(var"##936"),))
                                            true
                                        end)))
                        f = var"##937"
                        line = var"##938"
                        args = var"##939"
                        var"##return#754" = begin
                                p.line && printstyled(line, color = c.comment)
                                macrocall(f)
                                print_braces(args, "(", ")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##940" = (var"##cache#757").value
                                var"##940" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##940"[1] == :return && (begin
                                        var"##941" = var"##940"[2]
                                        var"##941" isa AbstractArray
                                    end && (length(var"##941") === 1 && (begin
                                                begin
                                                    var"##cache#943" = nothing
                                                end
                                                var"##942" = var"##941"[1]
                                                var"##942" isa Expr
                                            end && (begin
                                                    if var"##cache#943" === nothing
                                                        var"##cache#943" = Some(((var"##942").head, (var"##942").args))
                                                    end
                                                    var"##944" = (var"##cache#943").value
                                                    var"##944" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##944"[1] == :tuple && (begin
                                                            var"##945" = var"##944"[2]
                                                            var"##945" isa AbstractArray
                                                        end && ((ndims(var"##945") === 1 && length(var"##945") >= 1) && (begin
                                                                    begin
                                                                        var"##cache#947" = nothing
                                                                    end
                                                                    var"##946" = var"##945"[1]
                                                                    var"##946" isa Expr
                                                                end && (begin
                                                                        if var"##cache#947" === nothing
                                                                            var"##cache#947" = Some(((var"##946").head, (var"##946").args))
                                                                        end
                                                                        var"##948" = (var"##cache#947").value
                                                                        var"##948" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                    end && (var"##948"[1] == :parameters && (begin
                                                                                var"##949" = var"##948"[2]
                                                                                var"##949" isa AbstractArray
                                                                            end && ((ndims(var"##949") === 1 && length(var"##949") >= 0) && begin
                                                                                    var"##950" = SubArray(var"##949", (1:length(var"##949"),))
                                                                                    var"##951" = SubArray(var"##945", (2:length(var"##945"),))
                                                                                    true
                                                                                end)))))))))))))
                        args = var"##951"
                        kwargs = var"##950"
                        var"##return#754" = begin
                                keyword("return ")
                                p(Expr(:tuple, Expr(:parameters, kwargs...), args...))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##952" = (var"##cache#757").value
                                var"##952" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##952"[1] == :return && (begin
                                        var"##953" = var"##952"[2]
                                        var"##953" isa AbstractArray
                                    end && (length(var"##953") === 1 && (begin
                                                begin
                                                    var"##cache#955" = nothing
                                                end
                                                var"##954" = var"##953"[1]
                                                var"##954" isa Expr
                                            end && (begin
                                                    if var"##cache#955" === nothing
                                                        var"##cache#955" = Some(((var"##954").head, (var"##954").args))
                                                    end
                                                    var"##956" = (var"##cache#955").value
                                                    var"##956" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##956"[1] == :tuple && (begin
                                                            var"##957" = var"##956"[2]
                                                            var"##957" isa AbstractArray
                                                        end && ((ndims(var"##957") === 1 && length(var"##957") >= 0) && begin
                                                                var"##958" = SubArray(var"##957", (1:length(var"##957"),))
                                                                true
                                                            end))))))))
                        args = var"##958"
                        var"##return#754" = begin
                                keyword("return ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##959" = (var"##cache#757").value
                                var"##959" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##959"[1] == :return && (begin
                                        var"##960" = var"##959"[2]
                                        var"##960" isa AbstractArray
                                    end && ((ndims(var"##960") === 1 && length(var"##960") >= 0) && begin
                                            var"##961" = SubArray(var"##960", (1:length(var"##960"),))
                                            true
                                        end)))
                        args = var"##961"
                        var"##return#754" = begin
                                keyword("return ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##962" = (var"##cache#757").value
                                var"##962" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##962"[1] == :module && (begin
                                        var"##963" = var"##962"[2]
                                        var"##963" isa AbstractArray
                                    end && (length(var"##963") === 3 && begin
                                            var"##964" = var"##963"[1]
                                            var"##965" = var"##963"[2]
                                            var"##966" = var"##963"[3]
                                            true
                                        end)))
                        bare = var"##964"
                        name = var"##965"
                        body = var"##966"
                        var"##return#754" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##967" = (var"##cache#757").value
                                var"##967" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##967"[1] == :using && (begin
                                        var"##968" = var"##967"[2]
                                        var"##968" isa AbstractArray
                                    end && ((ndims(var"##968") === 1 && length(var"##968") >= 0) && begin
                                            var"##969" = SubArray(var"##968", (1:length(var"##968"),))
                                            true
                                        end)))
                        args = var"##969"
                        var"##return#754" = begin
                                keyword("using ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##970" = (var"##cache#757").value
                                var"##970" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##970"[1] == :import && (begin
                                        var"##971" = var"##970"[2]
                                        var"##971" isa AbstractArray
                                    end && ((ndims(var"##971") === 1 && length(var"##971") >= 0) && begin
                                            var"##972" = SubArray(var"##971", (1:length(var"##971"),))
                                            true
                                        end)))
                        args = var"##972"
                        var"##return#754" = begin
                                keyword("import ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##973" = (var"##cache#757").value
                                var"##973" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##973"[1] == :as && (begin
                                        var"##974" = var"##973"[2]
                                        var"##974" isa AbstractArray
                                    end && (length(var"##974") === 2 && begin
                                            var"##975" = var"##974"[1]
                                            var"##976" = var"##974"[2]
                                            true
                                        end)))
                        name = var"##975"
                        alias = var"##976"
                        var"##return#754" = begin
                                p(name)
                                keyword(" as ")
                                p(alias)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##977" = (var"##cache#757").value
                                var"##977" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##977"[1] == :export && (begin
                                        var"##978" = var"##977"[2]
                                        var"##978" isa AbstractArray
                                    end && ((ndims(var"##978") === 1 && length(var"##978") >= 0) && begin
                                            var"##979" = SubArray(var"##978", (1:length(var"##978"),))
                                            true
                                        end)))
                        args = var"##979"
                        var"##return#754" = begin
                                keyword("export ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##980" = (var"##cache#757").value
                                var"##980" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##980"[1] == :(:) && (begin
                                        var"##981" = var"##980"[2]
                                        var"##981" isa AbstractArray
                                    end && ((ndims(var"##981") === 1 && length(var"##981") >= 1) && begin
                                            var"##982" = var"##981"[1]
                                            var"##983" = SubArray(var"##981", (2:length(var"##981"),))
                                            true
                                        end)))
                        args = var"##983"
                        head = var"##982"
                        var"##return#754" = begin
                                p(head)
                                keyword(": ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##984" = (var"##cache#757").value
                                var"##984" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##984"[1] == :where && (begin
                                        var"##985" = var"##984"[2]
                                        var"##985" isa AbstractArray
                                    end && ((ndims(var"##985") === 1 && length(var"##985") >= 1) && begin
                                            var"##986" = var"##985"[1]
                                            var"##987" = SubArray(var"##985", (2:length(var"##985"),))
                                            true
                                        end)))
                        body = var"##986"
                        whereparams = var"##987"
                        var"##return#754" = begin
                                p(body)
                                keyword(" where {")
                                with(p.state, :type, true) do 
                                    join(whereparams, ", ")
                                end
                                keyword("}")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##988" = (var"##cache#757").value
                                var"##988" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##988"[1] == :for && (begin
                                        var"##989" = var"##988"[2]
                                        var"##989" isa AbstractArray
                                    end && (length(var"##989") === 2 && begin
                                            var"##990" = var"##989"[1]
                                            var"##991" = var"##989"[2]
                                            true
                                        end)))
                        body = var"##991"
                        iteration = var"##990"
                        var"##return#754" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##992" = (var"##cache#757").value
                                var"##992" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##992"[1] == :while && (begin
                                        var"##993" = var"##992"[2]
                                        var"##993" isa AbstractArray
                                    end && (length(var"##993") === 2 && begin
                                            var"##994" = var"##993"[1]
                                            var"##995" = var"##993"[2]
                                            true
                                        end)))
                        body = var"##995"
                        condition = var"##994"
                        var"##return#754" = begin
                                keyword("while ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##996" = (var"##cache#757").value
                                var"##996" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##996"[1] == :continue && (begin
                                        var"##997" = var"##996"[2]
                                        var"##997" isa AbstractArray
                                    end && isempty(var"##997")))
                        var"##return#754" = begin
                                keyword("continue")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##998" = (var"##cache#757").value
                                var"##998" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##998"[1] == :if && (begin
                                        var"##999" = var"##998"[2]
                                        var"##999" isa AbstractArray
                                    end && (length(var"##999") === 2 && begin
                                            var"##1000" = var"##999"[1]
                                            var"##1001" = var"##999"[2]
                                            true
                                        end)))
                        body = var"##1001"
                        condition = var"##1000"
                        var"##return#754" = begin
                                keyword("if ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##1002" = (var"##cache#757").value
                                var"##1002" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1002"[1] == :if && (begin
                                        var"##1003" = var"##1002"[2]
                                        var"##1003" isa AbstractArray
                                    end && (length(var"##1003") === 3 && begin
                                            var"##1004" = var"##1003"[1]
                                            var"##1005" = var"##1003"[2]
                                            var"##1006" = var"##1003"[3]
                                            true
                                        end)))
                        body = var"##1005"
                        elsebody = var"##1006"
                        condition = var"##1004"
                        var"##return#754" = begin
                                keyword("if ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                                keyword("; ")
                                Meta.isexpr(elsebody, :elseif) || keyword("else ")
                                noblock(elsebody)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##1007" = (var"##cache#757").value
                                var"##1007" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1007"[1] == :elseif && (begin
                                        var"##1008" = var"##1007"[2]
                                        var"##1008" isa AbstractArray
                                    end && (length(var"##1008") === 2 && begin
                                            var"##1009" = var"##1008"[1]
                                            var"##1010" = var"##1008"[2]
                                            true
                                        end)))
                        body = var"##1010"
                        condition = var"##1009"
                        var"##return#754" = begin
                                keyword("elseif ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##1011" = (var"##cache#757").value
                                var"##1011" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1011"[1] == :elseif && (begin
                                        var"##1012" = var"##1011"[2]
                                        var"##1012" isa AbstractArray
                                    end && (length(var"##1012") === 3 && begin
                                            var"##1013" = var"##1012"[1]
                                            var"##1014" = var"##1012"[2]
                                            var"##1015" = var"##1012"[3]
                                            true
                                        end)))
                        body = var"##1014"
                        elsebody = var"##1015"
                        condition = var"##1013"
                        var"##return#754" = begin
                                keyword("elseif ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                                keyword("; ")
                                Meta.isexpr(elsebody, :elseif) || keyword("else")
                                noblock(elsebody)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##1016" = (var"##cache#757").value
                                var"##1016" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1016"[1] == :try && (begin
                                        var"##1017" = var"##1016"[2]
                                        var"##1017" isa AbstractArray
                                    end && (length(var"##1017") === 3 && begin
                                            var"##1018" = var"##1017"[1]
                                            var"##1019" = var"##1017"[2]
                                            var"##1020" = var"##1017"[3]
                                            true
                                        end)))
                        catch_vars = var"##1019"
                        catch_body = var"##1020"
                        try_body = var"##1018"
                        var"##return#754" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##1021" = (var"##cache#757").value
                                var"##1021" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1021"[1] == :try && (begin
                                        var"##1022" = var"##1021"[2]
                                        var"##1022" isa AbstractArray
                                    end && (length(var"##1022") === 4 && begin
                                            var"##1023" = var"##1022"[1]
                                            var"##1024" = var"##1022"[2]
                                            var"##1025" = var"##1022"[3]
                                            var"##1026" = var"##1022"[4]
                                            true
                                        end)))
                        catch_vars = var"##1024"
                        catch_body = var"##1025"
                        try_body = var"##1023"
                        finally_body = var"##1026"
                        var"##return#754" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##1027" = (var"##cache#757").value
                                var"##1027" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1027"[1] == :try && (begin
                                        var"##1028" = var"##1027"[2]
                                        var"##1028" isa AbstractArray
                                    end && (length(var"##1028") === 5 && begin
                                            var"##1029" = var"##1028"[1]
                                            var"##1030" = var"##1028"[2]
                                            var"##1031" = var"##1028"[3]
                                            var"##1032" = var"##1028"[4]
                                            var"##1033" = var"##1028"[5]
                                            true
                                        end)))
                        catch_vars = var"##1030"
                        catch_body = var"##1031"
                        try_body = var"##1029"
                        finally_body = var"##1032"
                        else_body = var"##1033"
                        var"##return#754" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##1034" = (var"##cache#757").value
                                var"##1034" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1034"[1] == :struct && (begin
                                        var"##1035" = var"##1034"[2]
                                        var"##1035" isa AbstractArray
                                    end && (length(var"##1035") === 3 && begin
                                            var"##1036" = var"##1035"[1]
                                            var"##1037" = var"##1035"[2]
                                            var"##1038" = var"##1035"[3]
                                            true
                                        end)))
                        ismutable = var"##1036"
                        name = var"##1037"
                        body = var"##1038"
                        var"##return#754" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##1039" = (var"##cache#757").value
                                var"##1039" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1039"[1] == :abstract && (begin
                                        var"##1040" = var"##1039"[2]
                                        var"##1040" isa AbstractArray
                                    end && (length(var"##1040") === 1 && begin
                                            var"##1041" = var"##1040"[1]
                                            true
                                        end)))
                        name = var"##1041"
                        var"##return#754" = begin
                                keyword("abstract type ")
                                p(name)
                                keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##1042" = (var"##cache#757").value
                                var"##1042" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1042"[1] == :primitive && (begin
                                        var"##1043" = var"##1042"[2]
                                        var"##1043" isa AbstractArray
                                    end && (length(var"##1043") === 2 && begin
                                            var"##1044" = var"##1043"[1]
                                            var"##1045" = var"##1043"[2]
                                            true
                                        end)))
                        name = var"##1044"
                        size = var"##1045"
                        var"##return#754" = begin
                                keyword("primitive type ")
                                p(name)
                                print(" ")
                                p(size)
                                keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##1046" = (var"##cache#757").value
                                var"##1046" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1046"[1] == :meta && (begin
                                        var"##1047" = var"##1046"[2]
                                        var"##1047" isa AbstractArray
                                    end && (length(var"##1047") === 1 && var"##1047"[1] == :inline)))
                        var"##return#754" = begin
                                macrocall(GlobalRef(Base, Symbol("@_inline_meta")))
                                keyword(";")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##1048" = (var"##cache#757").value
                                var"##1048" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1048"[1] == :break && (begin
                                        var"##1049" = var"##1048"[2]
                                        var"##1049" isa AbstractArray
                                    end && isempty(var"##1049")))
                        var"##return#754" = begin
                                keyword("break")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##1050" = (var"##cache#757").value
                                var"##1050" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1050"[1] == :symboliclabel && (begin
                                        var"##1051" = var"##1050"[2]
                                        var"##1051" isa AbstractArray
                                    end && (length(var"##1051") === 1 && begin
                                            var"##1052" = var"##1051"[1]
                                            true
                                        end)))
                        label = var"##1052"
                        var"##return#754" = begin
                                macrocall(GlobalRef(Base, Symbol("@label")))
                                print(" ")
                                p(label)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##1053" = (var"##cache#757").value
                                var"##1053" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1053"[1] == :symbolicgoto && (begin
                                        var"##1054" = var"##1053"[2]
                                        var"##1054" isa AbstractArray
                                    end && (length(var"##1054") === 1 && begin
                                            var"##1055" = var"##1054"[1]
                                            true
                                        end)))
                        label = var"##1055"
                        var"##return#754" = begin
                                macrocall(GlobalRef(Base, Symbol("@goto")))
                                print(" ")
                                p(label)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    if begin
                                var"##1056" = (var"##cache#757").value
                                var"##1056" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1057" = var"##1056"[1]
                                    var"##1058" = var"##1056"[2]
                                    var"##1058" isa AbstractArray
                                end && ((ndims(var"##1058") === 1 && length(var"##1058") >= 0) && begin
                                        var"##1059" = SubArray(var"##1058", (1:length(var"##1058"),))
                                        true
                                    end))
                        args = var"##1059"
                        head = var"##1057"
                        var"##return#754" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                end
                if var"##756" isa GlobalRef
                    begin
                        var"##return#754" = begin
                                p(ex.mod)
                                keyword(".")
                                p(ex.name)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                end
                if var"##756" isa QuoteNode
                    if ex.value in Base.quoted_syms
                        var"##return#754" = begin
                                keyword(":(")
                                quoted(ex.value)
                                keyword(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                    begin
                        var"##return#754" = begin
                                if ex.value isa Symbol && Base.isidentifier(ex.value)
                                    keyword(":")
                                    quoted(ex.value)
                                else
                                    keyword(":(")
                                    quoted(ex.value)
                                    keyword(")")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                end
                if var"##756" isa Number
                    begin
                        var"##return#754" = begin
                                printstyled(ex, color = c.number)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                end
                if var"##756" isa String
                    begin
                        var"##return#754" = begin
                                string(ex)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                end
                if var"##756" isa LineNumberNode
                    begin
                        var"##return#754" = begin
                                p.line || return nothing
                                printstyled("#= $(ex.file):$(ex.line) =#", color = c.line)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                    end
                end
                begin
                    var"##return#754" = begin
                            print(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#755#1060")))
                end
                error("matching non-exhaustive, at #= none:142 =#")
                $(Expr(:symboliclabel, Symbol("####final#755#1060")))
                var"##return#754"
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
