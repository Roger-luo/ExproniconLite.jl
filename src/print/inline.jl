
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
                        var"##cache#768" = nothing
                    end
                    var"##return#765" = nothing
                    var"##767" = ex
                    if var"##767" isa Expr
                        if begin
                                    if var"##cache#768" === nothing
                                        var"##cache#768" = Some(((var"##767").head, (var"##767").args))
                                    end
                                    var"##769" = (var"##cache#768").value
                                    var"##769" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##769"[1] == :. && (begin
                                            var"##770" = var"##769"[2]
                                            var"##770" isa AbstractArray
                                        end && (ndims(var"##770") === 1 && length(var"##770") >= 0)))
                            var"##return#765" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#766#771")))
                        end
                    end
                    if var"##767" isa Symbol
                        begin
                            var"##return#765" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#766#771")))
                        end
                    end
                    begin
                        var"##return#765" = let
                                false
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#766#771")))
                    end
                    error("matching non-exhaustive, at #= none:85 =#")
                    $(Expr(:symboliclabel, Symbol("####final#766#771")))
                    var"##return#765"
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
                    var"##cache#775" = nothing
                end
                var"##774" = ex
                if var"##774" isa Expr && (begin
                                if var"##cache#775" === nothing
                                    var"##cache#775" = Some(((var"##774").head, (var"##774").args))
                                end
                                var"##776" = (var"##cache#775").value
                                var"##776" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##776"[1] == :call && (begin
                                        var"##777" = var"##776"[2]
                                        var"##777" isa AbstractArray
                                    end && ((ndims(var"##777") === 1 && length(var"##777") >= 1) && (var"##777"[1] == :(:) && begin
                                                var"##778" = SubArray(var"##777", (2:length(var"##777"),))
                                                true
                                            end)))))
                    args = var"##778"
                    var"##return#772" = begin
                            precedence(:(:)) do 
                                join(args, ":")
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#773#800")))
                end
                if var"##774" isa Expr && (begin
                                if var"##cache#775" === nothing
                                    var"##cache#775" = Some(((var"##774").head, (var"##774").args))
                                end
                                var"##779" = (var"##cache#775").value
                                var"##779" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##779"[1] == :call && (begin
                                        var"##780" = var"##779"[2]
                                        var"##780" isa AbstractArray
                                    end && (length(var"##780") === 2 && (begin
                                                var"##781" = var"##780"[1]
                                                var"##781" isa Symbol
                                            end && begin
                                                var"##782" = var"##780"[2]
                                                let f = var"##781", arg = var"##782"
                                                    Base.isunaryoperator(f)
                                                end
                                            end)))))
                    f = var"##781"
                    arg = var"##782"
                    var"##return#772" = begin
                            precedence(typemax(Int)) do 
                                keyword(f)
                                p(arg)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#773#800")))
                end
                if var"##774" isa Expr && (begin
                                if var"##cache#775" === nothing
                                    var"##cache#775" = Some(((var"##774").head, (var"##774").args))
                                end
                                var"##783" = (var"##cache#775").value
                                var"##783" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##783"[1] == :call && (begin
                                        var"##784" = var"##783"[2]
                                        var"##784" isa AbstractArray
                                    end && ((ndims(var"##784") === 1 && length(var"##784") >= 1) && (begin
                                                var"##785" = var"##784"[1]
                                                var"##785" isa Symbol
                                            end && begin
                                                var"##786" = SubArray(var"##784", (2:length(var"##784"),))
                                                let f = var"##785", args = var"##786"
                                                    Base.isbinaryoperator(f)
                                                end
                                            end)))))
                    f = var"##785"
                    args = var"##786"
                    var"##return#772" = begin
                            precedence(f) do 
                                join(args, " $(f) ")
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#773#800")))
                end
                if var"##774" isa Expr && (begin
                                if var"##cache#775" === nothing
                                    var"##cache#775" = Some(((var"##774").head, (var"##774").args))
                                end
                                var"##787" = (var"##cache#775").value
                                var"##787" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##787"[1] == :call && (begin
                                        var"##788" = var"##787"[2]
                                        var"##788" isa AbstractArray
                                    end && ((ndims(var"##788") === 1 && length(var"##788") >= 2) && (begin
                                                var"##789" = var"##788"[1]
                                                begin
                                                    var"##cache#791" = nothing
                                                end
                                                var"##790" = var"##788"[2]
                                                var"##790" isa Expr
                                            end && (begin
                                                    if var"##cache#791" === nothing
                                                        var"##cache#791" = Some(((var"##790").head, (var"##790").args))
                                                    end
                                                    var"##792" = (var"##cache#791").value
                                                    var"##792" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##792"[1] == :parameters && (begin
                                                            var"##793" = var"##792"[2]
                                                            var"##793" isa AbstractArray
                                                        end && ((ndims(var"##793") === 1 && length(var"##793") >= 0) && begin
                                                                var"##794" = SubArray(var"##793", (1:length(var"##793"),))
                                                                var"##795" = SubArray(var"##788", (3:length(var"##788"),))
                                                                true
                                                            end)))))))))
                    f = var"##789"
                    args = var"##795"
                    kwargs = var"##794"
                    var"##return#772" = begin
                            call(f)
                            print("(")
                            join(args)
                            keyword("; ")
                            join(kwargs)
                            print(")")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#773#800")))
                end
                if var"##774" isa Expr && (begin
                                if var"##cache#775" === nothing
                                    var"##cache#775" = Some(((var"##774").head, (var"##774").args))
                                end
                                var"##796" = (var"##cache#775").value
                                var"##796" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##796"[1] == :call && (begin
                                        var"##797" = var"##796"[2]
                                        var"##797" isa AbstractArray
                                    end && ((ndims(var"##797") === 1 && length(var"##797") >= 1) && begin
                                            var"##798" = var"##797"[1]
                                            var"##799" = SubArray(var"##797", (2:length(var"##797"),))
                                            true
                                        end))))
                    f = var"##798"
                    args = var"##799"
                    var"##return#772" = begin
                            call(f)
                            print_braces(args, "(", ")")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#773#800")))
                end
                error("matching non-exhaustive, at #= none:111 =#")
                $(Expr(:symboliclabel, Symbol("####final#773#800")))
                var"##return#772"
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
                    var"##cache#804" = nothing
                end
                var"##803" = ex
                if var"##803" isa GlobalRef
                    begin
                        var"##return#801" = begin
                                p(ex.mod)
                                keyword(".")
                                p(ex.name)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                end
                if var"##803" isa Nothing
                    begin
                        var"##return#801" = begin
                                printstyled("nothing", color = c.number)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                end
                if var"##803" isa Symbol
                    begin
                        var"##return#801" = begin
                                symbol(ex)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                end
                if var"##803" isa Number
                    begin
                        var"##return#801" = begin
                                printstyled(ex, color = c.number)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                end
                if var"##803" isa Expr
                    if begin
                                if var"##cache#804" === nothing
                                    var"##cache#804" = Some(((var"##803").head, (var"##803").args))
                                end
                                var"##805" = (var"##cache#804").value
                                var"##805" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##805"[1] == :line && (begin
                                        var"##806" = var"##805"[2]
                                        var"##806" isa AbstractArray
                                    end && (length(var"##806") === 2 && begin
                                            var"##807" = var"##806"[1]
                                            var"##808" = var"##806"[2]
                                            true
                                        end)))
                        line = var"##808"
                        file = var"##807"
                        var"##return#801" = begin
                                p.line || return nothing
                                printstyled("#= $(file):$(line) =#", color = c.line)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##809" = (var"##cache#804").value
                                var"##809" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##809"[1] == :kw && (begin
                                        var"##810" = var"##809"[2]
                                        var"##810" isa AbstractArray
                                    end && (length(var"##810") === 2 && begin
                                            var"##811" = var"##810"[1]
                                            var"##812" = var"##810"[2]
                                            true
                                        end)))
                        k = var"##811"
                        v = var"##812"
                        var"##return#801" = begin
                                p(k)
                                print(" = ")
                                p(v)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##813" = (var"##cache#804").value
                                var"##813" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##813"[1] == :(=) && (begin
                                        var"##814" = var"##813"[2]
                                        var"##814" isa AbstractArray
                                    end && (length(var"##814") === 2 && (begin
                                                var"##815" = var"##814"[1]
                                                begin
                                                    var"##cache#817" = nothing
                                                end
                                                var"##816" = var"##814"[2]
                                                var"##816" isa Expr
                                            end && (begin
                                                    if var"##cache#817" === nothing
                                                        var"##cache#817" = Some(((var"##816").head, (var"##816").args))
                                                    end
                                                    var"##818" = (var"##cache#817").value
                                                    var"##818" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##818"[1] == :block && (begin
                                                            var"##819" = var"##818"[2]
                                                            var"##819" isa AbstractArray
                                                        end && ((ndims(var"##819") === 1 && length(var"##819") >= 0) && begin
                                                                var"##820" = SubArray(var"##819", (1:length(var"##819"),))
                                                                true
                                                            end))))))))
                        k = var"##815"
                        stmts = var"##820"
                        var"##return#801" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##821" = (var"##cache#804").value
                                var"##821" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##821"[1] == :(=) && (begin
                                        var"##822" = var"##821"[2]
                                        var"##822" isa AbstractArray
                                    end && (length(var"##822") === 2 && begin
                                            var"##823" = var"##822"[1]
                                            var"##824" = var"##822"[2]
                                            true
                                        end)))
                        k = var"##823"
                        v = var"##824"
                        var"##return#801" = begin
                                precedence(:(=)) do 
                                    p(k)
                                    assign()
                                    p(v)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##825" = (var"##cache#804").value
                                var"##825" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##825"[1] == :... && (begin
                                        var"##826" = var"##825"[2]
                                        var"##826" isa AbstractArray
                                    end && (length(var"##826") === 1 && begin
                                            var"##827" = var"##826"[1]
                                            true
                                        end)))
                        name = var"##827"
                        var"##return#801" = begin
                                precedence(:...) do 
                                    p(name)
                                    keyword("...")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##828" = (var"##cache#804").value
                                var"##828" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##828"[1] == :& && (begin
                                        var"##829" = var"##828"[2]
                                        var"##829" isa AbstractArray
                                    end && (length(var"##829") === 1 && begin
                                            var"##830" = var"##829"[1]
                                            true
                                        end)))
                        name = var"##830"
                        var"##return#801" = begin
                                precedence(:&) do 
                                    keyword("&")
                                    p(name)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##831" = (var"##cache#804").value
                                var"##831" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##831"[1] == :(::) && (begin
                                        var"##832" = var"##831"[2]
                                        var"##832" isa AbstractArray
                                    end && (length(var"##832") === 1 && begin
                                            var"##833" = var"##832"[1]
                                            true
                                        end)))
                        t = var"##833"
                        var"##return#801" = begin
                                precedence(:(::)) do 
                                    keyword("::")
                                    type(t)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##834" = (var"##cache#804").value
                                var"##834" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##834"[1] == :(::) && (begin
                                        var"##835" = var"##834"[2]
                                        var"##835" isa AbstractArray
                                    end && (length(var"##835") === 2 && begin
                                            var"##836" = var"##835"[1]
                                            var"##837" = var"##835"[2]
                                            true
                                        end)))
                        name = var"##836"
                        t = var"##837"
                        var"##return#801" = begin
                                precedence(:(::)) do 
                                    p(name)
                                    keyword("::")
                                    type(t)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##838" = (var"##cache#804").value
                                var"##838" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##838"[1] == :$ && (begin
                                        var"##839" = var"##838"[2]
                                        var"##839" isa AbstractArray
                                    end && (length(var"##839") === 1 && begin
                                            var"##840" = var"##839"[1]
                                            true
                                        end)))
                        name = var"##840"
                        var"##return#801" = begin
                                precedence(:$) do 
                                    keyword('$')
                                    print("(")
                                    p(name)
                                    print(")")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##841" = (var"##cache#804").value
                                var"##841" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##842" = var"##841"[1]
                                    var"##843" = var"##841"[2]
                                    var"##843" isa AbstractArray
                                end && (length(var"##843") === 2 && begin
                                        var"##844" = var"##843"[1]
                                        var"##845" = var"##843"[2]
                                        let rhs = var"##845", lhs = var"##844", head = var"##842"
                                            head in expr_infix_wide
                                        end
                                    end))
                        rhs = var"##845"
                        lhs = var"##844"
                        head = var"##842"
                        var"##return#801" = begin
                                precedence(head) do 
                                    p(lhs)
                                    keyword(" $(head) ")
                                    p(rhs)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##846" = (var"##cache#804").value
                                var"##846" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##846"[1] == :. && (begin
                                        var"##847" = var"##846"[2]
                                        var"##847" isa AbstractArray
                                    end && (length(var"##847") === 1 && begin
                                            var"##848" = var"##847"[1]
                                            true
                                        end)))
                        name = var"##848"
                        var"##return#801" = begin
                                print(name)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##849" = (var"##cache#804").value
                                var"##849" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##849"[1] == :. && (begin
                                        var"##850" = var"##849"[2]
                                        var"##850" isa AbstractArray
                                    end && (length(var"##850") === 2 && (begin
                                                var"##851" = var"##850"[1]
                                                var"##852" = var"##850"[2]
                                                var"##852" isa QuoteNode
                                            end && begin
                                                var"##853" = (var"##852").value
                                                true
                                            end))))
                        name = var"##853"
                        object = var"##851"
                        var"##return#801" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##854" = (var"##cache#804").value
                                var"##854" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##854"[1] == :. && (begin
                                        var"##855" = var"##854"[2]
                                        var"##855" isa AbstractArray
                                    end && (length(var"##855") === 2 && begin
                                            var"##856" = var"##855"[1]
                                            var"##857" = var"##855"[2]
                                            true
                                        end)))
                        name = var"##857"
                        object = var"##856"
                        var"##return#801" = begin
                                precedence(:.) do 
                                    p(object)
                                    keyword(".")
                                    p(name)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##858" = (var"##cache#804").value
                                var"##858" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##858"[1] == :<: && (begin
                                        var"##859" = var"##858"[2]
                                        var"##859" isa AbstractArray
                                    end && (length(var"##859") === 2 && begin
                                            var"##860" = var"##859"[1]
                                            var"##861" = var"##859"[2]
                                            true
                                        end)))
                        type = var"##860"
                        supertype = var"##861"
                        var"##return#801" = begin
                                precedence(:<:) do 
                                    p(type)
                                    keyword(" <: ")
                                    p(supertype)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##862" = (var"##cache#804").value
                                var"##862" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##862"[1] == :call && (begin
                                        var"##863" = var"##862"[2]
                                        var"##863" isa AbstractArray
                                    end && (ndims(var"##863") === 1 && length(var"##863") >= 0)))
                        var"##return#801" = begin
                                print_call(ex)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##864" = (var"##cache#804").value
                                var"##864" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##864"[1] == :tuple && (begin
                                        var"##865" = var"##864"[2]
                                        var"##865" isa AbstractArray
                                    end && (length(var"##865") === 1 && (begin
                                                begin
                                                    var"##cache#867" = nothing
                                                end
                                                var"##866" = var"##865"[1]
                                                var"##866" isa Expr
                                            end && (begin
                                                    if var"##cache#867" === nothing
                                                        var"##cache#867" = Some(((var"##866").head, (var"##866").args))
                                                    end
                                                    var"##868" = (var"##cache#867").value
                                                    var"##868" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##868"[1] == :parameters && (begin
                                                            var"##869" = var"##868"[2]
                                                            var"##869" isa AbstractArray
                                                        end && ((ndims(var"##869") === 1 && length(var"##869") >= 0) && begin
                                                                var"##870" = SubArray(var"##869", (1:length(var"##869"),))
                                                                true
                                                            end))))))))
                        args = var"##870"
                        var"##return#801" = begin
                                print_braces(args, "(;", ")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##871" = (var"##cache#804").value
                                var"##871" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##871"[1] == :tuple && (begin
                                        var"##872" = var"##871"[2]
                                        var"##872" isa AbstractArray
                                    end && ((ndims(var"##872") === 1 && length(var"##872") >= 0) && begin
                                            var"##873" = SubArray(var"##872", (1:length(var"##872"),))
                                            true
                                        end)))
                        args = var"##873"
                        var"##return#801" = begin
                                if length(args) == 1
                                    print("(")
                                    p(args[1])
                                    print(",)")
                                else
                                    print_braces(args, "(", ")")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##874" = (var"##cache#804").value
                                var"##874" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##874"[1] == :curly && (begin
                                        var"##875" = var"##874"[2]
                                        var"##875" isa AbstractArray
                                    end && ((ndims(var"##875") === 1 && length(var"##875") >= 1) && begin
                                            var"##876" = var"##875"[1]
                                            var"##877" = SubArray(var"##875", (2:length(var"##875"),))
                                            true
                                        end)))
                        args = var"##877"
                        t = var"##876"
                        var"##return#801" = begin
                                with(p.state, :type, true) do 
                                    p(t)
                                    print_braces(args, "{", "}")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##878" = (var"##cache#804").value
                                var"##878" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##878"[1] == :vect && (begin
                                        var"##879" = var"##878"[2]
                                        var"##879" isa AbstractArray
                                    end && ((ndims(var"##879") === 1 && length(var"##879") >= 0) && begin
                                            var"##880" = SubArray(var"##879", (1:length(var"##879"),))
                                            true
                                        end)))
                        args = var"##880"
                        var"##return#801" = begin
                                print_braces(args, "[", "]")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##881" = (var"##cache#804").value
                                var"##881" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##881"[1] == :hcat && (begin
                                        var"##882" = var"##881"[2]
                                        var"##882" isa AbstractArray
                                    end && ((ndims(var"##882") === 1 && length(var"##882") >= 0) && begin
                                            var"##883" = SubArray(var"##882", (1:length(var"##882"),))
                                            true
                                        end)))
                        args = var"##883"
                        var"##return#801" = begin
                                print_braces(args, "[", "]", " ")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##884" = (var"##cache#804").value
                                var"##884" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##884"[1] == :typed_hcat && (begin
                                        var"##885" = var"##884"[2]
                                        var"##885" isa AbstractArray
                                    end && ((ndims(var"##885") === 1 && length(var"##885") >= 1) && begin
                                            var"##886" = var"##885"[1]
                                            var"##887" = SubArray(var"##885", (2:length(var"##885"),))
                                            true
                                        end)))
                        args = var"##887"
                        t = var"##886"
                        var"##return#801" = begin
                                type(t)
                                print_braces(args, "[", "]", " ")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##888" = (var"##cache#804").value
                                var"##888" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##888"[1] == :vcat && (begin
                                        var"##889" = var"##888"[2]
                                        var"##889" isa AbstractArray
                                    end && ((ndims(var"##889") === 1 && length(var"##889") >= 0) && begin
                                            var"##890" = SubArray(var"##889", (1:length(var"##889"),))
                                            true
                                        end)))
                        args = var"##890"
                        var"##return#801" = begin
                                print_braces(args, "[", "]", "; ")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##891" = (var"##cache#804").value
                                var"##891" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##891"[1] == :ncat && (begin
                                        var"##892" = var"##891"[2]
                                        var"##892" isa AbstractArray
                                    end && ((ndims(var"##892") === 1 && length(var"##892") >= 1) && begin
                                            var"##893" = var"##892"[1]
                                            var"##894" = SubArray(var"##892", (2:length(var"##892"),))
                                            true
                                        end)))
                        n = var"##893"
                        args = var"##894"
                        var"##return#801" = begin
                                print_braces(args, "[", "]", ";" ^ n * " ")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##895" = (var"##cache#804").value
                                var"##895" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##895"[1] == :ref && (begin
                                        var"##896" = var"##895"[2]
                                        var"##896" isa AbstractArray
                                    end && ((ndims(var"##896") === 1 && length(var"##896") >= 1) && begin
                                            var"##897" = var"##896"[1]
                                            var"##898" = SubArray(var"##896", (2:length(var"##896"),))
                                            true
                                        end)))
                        args = var"##898"
                        object = var"##897"
                        var"##return#801" = begin
                                p(object)
                                print_braces(args, "[", "]")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##899" = (var"##cache#804").value
                                var"##899" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##899"[1] == :comprehension && (begin
                                        var"##900" = var"##899"[2]
                                        var"##900" isa AbstractArray
                                    end && (length(var"##900") === 1 && (begin
                                                begin
                                                    var"##cache#902" = nothing
                                                end
                                                var"##901" = var"##900"[1]
                                                var"##901" isa Expr
                                            end && (begin
                                                    if var"##cache#902" === nothing
                                                        var"##cache#902" = Some(((var"##901").head, (var"##901").args))
                                                    end
                                                    var"##903" = (var"##cache#902").value
                                                    var"##903" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##903"[1] == :generator && (begin
                                                            var"##904" = var"##903"[2]
                                                            var"##904" isa AbstractArray
                                                        end && (length(var"##904") === 2 && begin
                                                                var"##905" = var"##904"[1]
                                                                var"##906" = var"##904"[2]
                                                                true
                                                            end))))))))
                        iter = var"##905"
                        body = var"##906"
                        var"##return#801" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##907" = (var"##cache#804").value
                                var"##907" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##907"[1] == :typed_comprehension && (begin
                                        var"##908" = var"##907"[2]
                                        var"##908" isa AbstractArray
                                    end && (length(var"##908") === 2 && (begin
                                                var"##909" = var"##908"[1]
                                                begin
                                                    var"##cache#911" = nothing
                                                end
                                                var"##910" = var"##908"[2]
                                                var"##910" isa Expr
                                            end && (begin
                                                    if var"##cache#911" === nothing
                                                        var"##cache#911" = Some(((var"##910").head, (var"##910").args))
                                                    end
                                                    var"##912" = (var"##cache#911").value
                                                    var"##912" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##912"[1] == :generator && (begin
                                                            var"##913" = var"##912"[2]
                                                            var"##913" isa AbstractArray
                                                        end && (length(var"##913") === 2 && begin
                                                                var"##914" = var"##913"[1]
                                                                var"##915" = var"##913"[2]
                                                                true
                                                            end))))))))
                        iter = var"##914"
                        body = var"##915"
                        t = var"##909"
                        var"##return#801" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##916" = (var"##cache#804").value
                                var"##916" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##916"[1] == :-> && (begin
                                        var"##917" = var"##916"[2]
                                        var"##917" isa AbstractArray
                                    end && (length(var"##917") === 2 && (begin
                                                var"##918" = var"##917"[1]
                                                begin
                                                    var"##cache#920" = nothing
                                                end
                                                var"##919" = var"##917"[2]
                                                var"##919" isa Expr
                                            end && (begin
                                                    if var"##cache#920" === nothing
                                                        var"##cache#920" = Some(((var"##919").head, (var"##919").args))
                                                    end
                                                    var"##921" = (var"##cache#920").value
                                                    var"##921" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##921"[1] == :block && (begin
                                                            var"##922" = var"##921"[2]
                                                            var"##922" isa AbstractArray
                                                        end && (length(var"##922") === 2 && begin
                                                                var"##923" = var"##922"[1]
                                                                var"##924" = var"##922"[2]
                                                                true
                                                            end))))))))
                        line = var"##923"
                        code = var"##924"
                        args = var"##918"
                        var"##return#801" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##925" = (var"##cache#804").value
                                var"##925" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##925"[1] == :-> && (begin
                                        var"##926" = var"##925"[2]
                                        var"##926" isa AbstractArray
                                    end && (length(var"##926") === 2 && begin
                                            var"##927" = var"##926"[1]
                                            var"##928" = var"##926"[2]
                                            true
                                        end)))
                        args = var"##927"
                        body = var"##928"
                        var"##return#801" = begin
                                p(args)
                                keyword(" -> ")
                                print("(")
                                noblock(body)
                                print(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##929" = (var"##cache#804").value
                                var"##929" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##929"[1] == :do && (begin
                                        var"##930" = var"##929"[2]
                                        var"##930" isa AbstractArray
                                    end && (length(var"##930") === 2 && (begin
                                                var"##931" = var"##930"[1]
                                                begin
                                                    var"##cache#933" = nothing
                                                end
                                                var"##932" = var"##930"[2]
                                                var"##932" isa Expr
                                            end && (begin
                                                    if var"##cache#933" === nothing
                                                        var"##cache#933" = Some(((var"##932").head, (var"##932").args))
                                                    end
                                                    var"##934" = (var"##cache#933").value
                                                    var"##934" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##934"[1] == :-> && (begin
                                                            var"##935" = var"##934"[2]
                                                            var"##935" isa AbstractArray
                                                        end && (length(var"##935") === 2 && (begin
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
                                                                    end && (var"##938"[1] == :tuple && (begin
                                                                                var"##939" = var"##938"[2]
                                                                                var"##939" isa AbstractArray
                                                                            end && ((ndims(var"##939") === 1 && length(var"##939") >= 0) && begin
                                                                                    var"##940" = SubArray(var"##939", (1:length(var"##939"),))
                                                                                    var"##941" = var"##935"[2]
                                                                                    true
                                                                                end)))))))))))))
                        call = var"##931"
                        args = var"##940"
                        body = var"##941"
                        var"##return#801" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##942" = (var"##cache#804").value
                                var"##942" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##942"[1] == :function && (begin
                                        var"##943" = var"##942"[2]
                                        var"##943" isa AbstractArray
                                    end && (length(var"##943") === 2 && begin
                                            var"##944" = var"##943"[1]
                                            var"##945" = var"##943"[2]
                                            true
                                        end)))
                        call = var"##944"
                        body = var"##945"
                        var"##return#801" = begin
                                print_function(:function, call, body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##946" = (var"##cache#804").value
                                var"##946" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##946"[1] == :quote && (begin
                                        var"##947" = var"##946"[2]
                                        var"##947" isa AbstractArray
                                    end && (length(var"##947") === 1 && begin
                                            var"##948" = var"##947"[1]
                                            true
                                        end)))
                        stmt = var"##948"
                        var"##return#801" = begin
                                keyword(":(")
                                noblock(stmt)
                                keyword(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##949" = (var"##cache#804").value
                                var"##949" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##949"[1] == :quote && (begin
                                        var"##950" = var"##949"[2]
                                        var"##950" isa AbstractArray
                                    end && ((ndims(var"##950") === 1 && length(var"##950") >= 0) && begin
                                            var"##951" = SubArray(var"##950", (1:length(var"##950"),))
                                            true
                                        end)))
                        args = var"##951"
                        var"##return#801" = begin
                                keyword("quote ")
                                with(p.state, :block, false) do 
                                    join(args, "; ")
                                end
                                keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##952" = (var"##cache#804").value
                                var"##952" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##952"[1] == :string && (begin
                                        var"##953" = var"##952"[2]
                                        var"##953" isa AbstractArray
                                    end && ((ndims(var"##953") === 1 && length(var"##953") >= 0) && begin
                                            var"##954" = SubArray(var"##953", (1:length(var"##953"),))
                                            true
                                        end)))
                        args = var"##954"
                        var"##return#801" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##955" = (var"##cache#804").value
                                var"##955" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##955"[1] == :block && (begin
                                        var"##956" = var"##955"[2]
                                        var"##956" isa AbstractArray
                                    end && ((ndims(var"##956") === 1 && length(var"##956") >= 0) && begin
                                            var"##957" = SubArray(var"##956", (1:length(var"##956"),))
                                            let args = var"##957"
                                                length(args) == 2 && (is_line_no(args[1]) && is_line_no(args[2]))
                                            end
                                        end)))
                        args = var"##957"
                        var"##return#801" = begin
                                p(args[1])
                                print(" ")
                                p(args[2])
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##958" = (var"##cache#804").value
                                var"##958" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##958"[1] == :block && (begin
                                        var"##959" = var"##958"[2]
                                        var"##959" isa AbstractArray
                                    end && ((ndims(var"##959") === 1 && length(var"##959") >= 0) && begin
                                            var"##960" = SubArray(var"##959", (1:length(var"##959"),))
                                            let args = var"##960"
                                                length(args) == 2 && is_line_no(args[1])
                                            end
                                        end)))
                        args = var"##960"
                        var"##return#801" = begin
                                p(args[1])
                                print(" ")
                                noblock(args[2])
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##961" = (var"##cache#804").value
                                var"##961" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##961"[1] == :block && (begin
                                        var"##962" = var"##961"[2]
                                        var"##962" isa AbstractArray
                                    end && ((ndims(var"##962") === 1 && length(var"##962") >= 0) && begin
                                            var"##963" = SubArray(var"##962", (1:length(var"##962"),))
                                            let args = var"##963"
                                                length(args) == 2 && is_line_no(args[2])
                                            end
                                        end)))
                        args = var"##963"
                        var"##return#801" = begin
                                noblock(args[1])
                                print(" ")
                                p(args[2])
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##964" = (var"##cache#804").value
                                var"##964" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##964"[1] == :block && (begin
                                        var"##965" = var"##964"[2]
                                        var"##965" isa AbstractArray
                                    end && ((ndims(var"##965") === 1 && length(var"##965") >= 0) && begin
                                            var"##966" = SubArray(var"##965", (1:length(var"##965"),))
                                            let args = var"##966"
                                                length(args) == 2
                                            end
                                        end)))
                        args = var"##966"
                        var"##return#801" = begin
                                print("(")
                                noblock(args[1])
                                keyword("; ")
                                noblock(args[2])
                                print(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##967" = (var"##cache#804").value
                                var"##967" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##967"[1] == :block && (begin
                                        var"##968" = var"##967"[2]
                                        var"##968" isa AbstractArray
                                    end && ((ndims(var"##968") === 1 && length(var"##968") >= 0) && begin
                                            var"##969" = SubArray(var"##968", (1:length(var"##968"),))
                                            true
                                        end)))
                        args = var"##969"
                        var"##return#801" = begin
                                p.state.block && keyword("begin ")
                                with(p.state, :block, true) do 
                                    join(args, "; ")
                                end
                                p.state.block && keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##970" = (var"##cache#804").value
                                var"##970" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##970"[1] == :let && (begin
                                        var"##971" = var"##970"[2]
                                        var"##971" isa AbstractArray
                                    end && (length(var"##971") === 2 && (begin
                                                begin
                                                    var"##cache#973" = nothing
                                                end
                                                var"##972" = var"##971"[1]
                                                var"##972" isa Expr
                                            end && (begin
                                                    if var"##cache#973" === nothing
                                                        var"##cache#973" = Some(((var"##972").head, (var"##972").args))
                                                    end
                                                    var"##974" = (var"##cache#973").value
                                                    var"##974" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##974"[1] == :block && (begin
                                                            var"##975" = var"##974"[2]
                                                            var"##975" isa AbstractArray
                                                        end && ((ndims(var"##975") === 1 && length(var"##975") >= 0) && begin
                                                                var"##976" = SubArray(var"##975", (1:length(var"##975"),))
                                                                var"##977" = var"##971"[2]
                                                                true
                                                            end))))))))
                        args = var"##976"
                        body = var"##977"
                        var"##return#801" = begin
                                keyword("let ")
                                join(args, ", ")
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##978" = (var"##cache#804").value
                                var"##978" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##978"[1] == :let && (begin
                                        var"##979" = var"##978"[2]
                                        var"##979" isa AbstractArray
                                    end && (length(var"##979") === 2 && begin
                                            var"##980" = var"##979"[1]
                                            var"##981" = var"##979"[2]
                                            true
                                        end)))
                        arg = var"##980"
                        body = var"##981"
                        var"##return#801" = begin
                                keyword("let ")
                                p(arg)
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##982" = (var"##cache#804").value
                                var"##982" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##982"[1] == :macrocall && (begin
                                        var"##983" = var"##982"[2]
                                        var"##983" isa AbstractArray
                                    end && ((ndims(var"##983") === 1 && length(var"##983") >= 2) && begin
                                            var"##984" = var"##983"[1]
                                            var"##985" = var"##983"[2]
                                            var"##986" = SubArray(var"##983", (3:length(var"##983"),))
                                            true
                                        end)))
                        f = var"##984"
                        line = var"##985"
                        args = var"##986"
                        var"##return#801" = begin
                                p.line && printstyled(line, color = c.comment)
                                macrocall(f)
                                print_braces(args, "(", ")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##987" = (var"##cache#804").value
                                var"##987" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##987"[1] == :return && (begin
                                        var"##988" = var"##987"[2]
                                        var"##988" isa AbstractArray
                                    end && (length(var"##988") === 1 && (begin
                                                begin
                                                    var"##cache#990" = nothing
                                                end
                                                var"##989" = var"##988"[1]
                                                var"##989" isa Expr
                                            end && (begin
                                                    if var"##cache#990" === nothing
                                                        var"##cache#990" = Some(((var"##989").head, (var"##989").args))
                                                    end
                                                    var"##991" = (var"##cache#990").value
                                                    var"##991" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##991"[1] == :tuple && (begin
                                                            var"##992" = var"##991"[2]
                                                            var"##992" isa AbstractArray
                                                        end && ((ndims(var"##992") === 1 && length(var"##992") >= 1) && (begin
                                                                    begin
                                                                        var"##cache#994" = nothing
                                                                    end
                                                                    var"##993" = var"##992"[1]
                                                                    var"##993" isa Expr
                                                                end && (begin
                                                                        if var"##cache#994" === nothing
                                                                            var"##cache#994" = Some(((var"##993").head, (var"##993").args))
                                                                        end
                                                                        var"##995" = (var"##cache#994").value
                                                                        var"##995" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                    end && (var"##995"[1] == :parameters && (begin
                                                                                var"##996" = var"##995"[2]
                                                                                var"##996" isa AbstractArray
                                                                            end && ((ndims(var"##996") === 1 && length(var"##996") >= 0) && begin
                                                                                    var"##997" = SubArray(var"##996", (1:length(var"##996"),))
                                                                                    var"##998" = SubArray(var"##992", (2:length(var"##992"),))
                                                                                    true
                                                                                end)))))))))))))
                        args = var"##998"
                        kwargs = var"##997"
                        var"##return#801" = begin
                                keyword("return ")
                                p(Expr(:tuple, Expr(:parameters, kwargs...), args...))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##999" = (var"##cache#804").value
                                var"##999" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##999"[1] == :return && (begin
                                        var"##1000" = var"##999"[2]
                                        var"##1000" isa AbstractArray
                                    end && (length(var"##1000") === 1 && (begin
                                                begin
                                                    var"##cache#1002" = nothing
                                                end
                                                var"##1001" = var"##1000"[1]
                                                var"##1001" isa Expr
                                            end && (begin
                                                    if var"##cache#1002" === nothing
                                                        var"##cache#1002" = Some(((var"##1001").head, (var"##1001").args))
                                                    end
                                                    var"##1003" = (var"##cache#1002").value
                                                    var"##1003" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1003"[1] == :tuple && (begin
                                                            var"##1004" = var"##1003"[2]
                                                            var"##1004" isa AbstractArray
                                                        end && ((ndims(var"##1004") === 1 && length(var"##1004") >= 0) && begin
                                                                var"##1005" = SubArray(var"##1004", (1:length(var"##1004"),))
                                                                true
                                                            end))))))))
                        args = var"##1005"
                        var"##return#801" = begin
                                keyword("return ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##1006" = (var"##cache#804").value
                                var"##1006" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1006"[1] == :return && (begin
                                        var"##1007" = var"##1006"[2]
                                        var"##1007" isa AbstractArray
                                    end && ((ndims(var"##1007") === 1 && length(var"##1007") >= 0) && begin
                                            var"##1008" = SubArray(var"##1007", (1:length(var"##1007"),))
                                            true
                                        end)))
                        args = var"##1008"
                        var"##return#801" = begin
                                keyword("return ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##1009" = (var"##cache#804").value
                                var"##1009" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1009"[1] == :module && (begin
                                        var"##1010" = var"##1009"[2]
                                        var"##1010" isa AbstractArray
                                    end && (length(var"##1010") === 3 && begin
                                            var"##1011" = var"##1010"[1]
                                            var"##1012" = var"##1010"[2]
                                            var"##1013" = var"##1010"[3]
                                            true
                                        end)))
                        bare = var"##1011"
                        name = var"##1012"
                        body = var"##1013"
                        var"##return#801" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##1014" = (var"##cache#804").value
                                var"##1014" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1014"[1] == :using && (begin
                                        var"##1015" = var"##1014"[2]
                                        var"##1015" isa AbstractArray
                                    end && ((ndims(var"##1015") === 1 && length(var"##1015") >= 0) && begin
                                            var"##1016" = SubArray(var"##1015", (1:length(var"##1015"),))
                                            true
                                        end)))
                        args = var"##1016"
                        var"##return#801" = begin
                                keyword("using ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##1017" = (var"##cache#804").value
                                var"##1017" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1017"[1] == :import && (begin
                                        var"##1018" = var"##1017"[2]
                                        var"##1018" isa AbstractArray
                                    end && ((ndims(var"##1018") === 1 && length(var"##1018") >= 0) && begin
                                            var"##1019" = SubArray(var"##1018", (1:length(var"##1018"),))
                                            true
                                        end)))
                        args = var"##1019"
                        var"##return#801" = begin
                                keyword("import ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##1020" = (var"##cache#804").value
                                var"##1020" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1020"[1] == :as && (begin
                                        var"##1021" = var"##1020"[2]
                                        var"##1021" isa AbstractArray
                                    end && (length(var"##1021") === 2 && begin
                                            var"##1022" = var"##1021"[1]
                                            var"##1023" = var"##1021"[2]
                                            true
                                        end)))
                        name = var"##1022"
                        alias = var"##1023"
                        var"##return#801" = begin
                                p(name)
                                keyword(" as ")
                                p(alias)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##1024" = (var"##cache#804").value
                                var"##1024" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1024"[1] == :export && (begin
                                        var"##1025" = var"##1024"[2]
                                        var"##1025" isa AbstractArray
                                    end && ((ndims(var"##1025") === 1 && length(var"##1025") >= 0) && begin
                                            var"##1026" = SubArray(var"##1025", (1:length(var"##1025"),))
                                            true
                                        end)))
                        args = var"##1026"
                        var"##return#801" = begin
                                keyword("export ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##1027" = (var"##cache#804").value
                                var"##1027" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1027"[1] == :(:) && (begin
                                        var"##1028" = var"##1027"[2]
                                        var"##1028" isa AbstractArray
                                    end && ((ndims(var"##1028") === 1 && length(var"##1028") >= 1) && begin
                                            var"##1029" = var"##1028"[1]
                                            var"##1030" = SubArray(var"##1028", (2:length(var"##1028"),))
                                            true
                                        end)))
                        args = var"##1030"
                        head = var"##1029"
                        var"##return#801" = begin
                                p(head)
                                keyword(": ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##1031" = (var"##cache#804").value
                                var"##1031" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1031"[1] == :where && (begin
                                        var"##1032" = var"##1031"[2]
                                        var"##1032" isa AbstractArray
                                    end && ((ndims(var"##1032") === 1 && length(var"##1032") >= 1) && begin
                                            var"##1033" = var"##1032"[1]
                                            var"##1034" = SubArray(var"##1032", (2:length(var"##1032"),))
                                            true
                                        end)))
                        body = var"##1033"
                        whereparams = var"##1034"
                        var"##return#801" = begin
                                p(body)
                                keyword(" where {")
                                with(p.state, :type, true) do 
                                    join(whereparams, ", ")
                                end
                                keyword("}")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##1035" = (var"##cache#804").value
                                var"##1035" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1035"[1] == :for && (begin
                                        var"##1036" = var"##1035"[2]
                                        var"##1036" isa AbstractArray
                                    end && (length(var"##1036") === 2 && begin
                                            var"##1037" = var"##1036"[1]
                                            var"##1038" = var"##1036"[2]
                                            true
                                        end)))
                        body = var"##1038"
                        iteration = var"##1037"
                        var"##return#801" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##1039" = (var"##cache#804").value
                                var"##1039" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1039"[1] == :while && (begin
                                        var"##1040" = var"##1039"[2]
                                        var"##1040" isa AbstractArray
                                    end && (length(var"##1040") === 2 && begin
                                            var"##1041" = var"##1040"[1]
                                            var"##1042" = var"##1040"[2]
                                            true
                                        end)))
                        body = var"##1042"
                        condition = var"##1041"
                        var"##return#801" = begin
                                keyword("while ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##1043" = (var"##cache#804").value
                                var"##1043" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1043"[1] == :continue && (begin
                                        var"##1044" = var"##1043"[2]
                                        var"##1044" isa AbstractArray
                                    end && isempty(var"##1044")))
                        var"##return#801" = begin
                                keyword("continue")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##1045" = (var"##cache#804").value
                                var"##1045" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1045"[1] == :if && (begin
                                        var"##1046" = var"##1045"[2]
                                        var"##1046" isa AbstractArray
                                    end && (length(var"##1046") === 2 && begin
                                            var"##1047" = var"##1046"[1]
                                            var"##1048" = var"##1046"[2]
                                            true
                                        end)))
                        body = var"##1048"
                        condition = var"##1047"
                        var"##return#801" = begin
                                keyword("if ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##1049" = (var"##cache#804").value
                                var"##1049" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1049"[1] == :if && (begin
                                        var"##1050" = var"##1049"[2]
                                        var"##1050" isa AbstractArray
                                    end && (length(var"##1050") === 3 && begin
                                            var"##1051" = var"##1050"[1]
                                            var"##1052" = var"##1050"[2]
                                            var"##1053" = var"##1050"[3]
                                            true
                                        end)))
                        body = var"##1052"
                        elsebody = var"##1053"
                        condition = var"##1051"
                        var"##return#801" = begin
                                keyword("if ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                                keyword("; ")
                                Meta.isexpr(elsebody, :elseif) || keyword("else ")
                                noblock(elsebody)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##1054" = (var"##cache#804").value
                                var"##1054" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1054"[1] == :elseif && (begin
                                        var"##1055" = var"##1054"[2]
                                        var"##1055" isa AbstractArray
                                    end && (length(var"##1055") === 2 && begin
                                            var"##1056" = var"##1055"[1]
                                            var"##1057" = var"##1055"[2]
                                            true
                                        end)))
                        body = var"##1057"
                        condition = var"##1056"
                        var"##return#801" = begin
                                keyword("elseif ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##1058" = (var"##cache#804").value
                                var"##1058" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1058"[1] == :elseif && (begin
                                        var"##1059" = var"##1058"[2]
                                        var"##1059" isa AbstractArray
                                    end && (length(var"##1059") === 3 && begin
                                            var"##1060" = var"##1059"[1]
                                            var"##1061" = var"##1059"[2]
                                            var"##1062" = var"##1059"[3]
                                            true
                                        end)))
                        body = var"##1061"
                        elsebody = var"##1062"
                        condition = var"##1060"
                        var"##return#801" = begin
                                keyword("elseif ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                                keyword("; ")
                                Meta.isexpr(elsebody, :elseif) || keyword("else")
                                noblock(elsebody)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##1063" = (var"##cache#804").value
                                var"##1063" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1063"[1] == :try && (begin
                                        var"##1064" = var"##1063"[2]
                                        var"##1064" isa AbstractArray
                                    end && (length(var"##1064") === 3 && begin
                                            var"##1065" = var"##1064"[1]
                                            var"##1066" = var"##1064"[2]
                                            var"##1067" = var"##1064"[3]
                                            true
                                        end)))
                        catch_vars = var"##1066"
                        catch_body = var"##1067"
                        try_body = var"##1065"
                        var"##return#801" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##1068" = (var"##cache#804").value
                                var"##1068" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1068"[1] == :try && (begin
                                        var"##1069" = var"##1068"[2]
                                        var"##1069" isa AbstractArray
                                    end && (length(var"##1069") === 4 && begin
                                            var"##1070" = var"##1069"[1]
                                            var"##1071" = var"##1069"[2]
                                            var"##1072" = var"##1069"[3]
                                            var"##1073" = var"##1069"[4]
                                            true
                                        end)))
                        catch_vars = var"##1071"
                        catch_body = var"##1072"
                        try_body = var"##1070"
                        finally_body = var"##1073"
                        var"##return#801" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##1074" = (var"##cache#804").value
                                var"##1074" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1074"[1] == :try && (begin
                                        var"##1075" = var"##1074"[2]
                                        var"##1075" isa AbstractArray
                                    end && (length(var"##1075") === 5 && begin
                                            var"##1076" = var"##1075"[1]
                                            var"##1077" = var"##1075"[2]
                                            var"##1078" = var"##1075"[3]
                                            var"##1079" = var"##1075"[4]
                                            var"##1080" = var"##1075"[5]
                                            true
                                        end)))
                        catch_vars = var"##1077"
                        catch_body = var"##1078"
                        try_body = var"##1076"
                        finally_body = var"##1079"
                        else_body = var"##1080"
                        var"##return#801" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##1081" = (var"##cache#804").value
                                var"##1081" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1081"[1] == :struct && (begin
                                        var"##1082" = var"##1081"[2]
                                        var"##1082" isa AbstractArray
                                    end && (length(var"##1082") === 3 && begin
                                            var"##1083" = var"##1082"[1]
                                            var"##1084" = var"##1082"[2]
                                            var"##1085" = var"##1082"[3]
                                            true
                                        end)))
                        ismutable = var"##1083"
                        name = var"##1084"
                        body = var"##1085"
                        var"##return#801" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##1086" = (var"##cache#804").value
                                var"##1086" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1086"[1] == :abstract && (begin
                                        var"##1087" = var"##1086"[2]
                                        var"##1087" isa AbstractArray
                                    end && (length(var"##1087") === 1 && begin
                                            var"##1088" = var"##1087"[1]
                                            true
                                        end)))
                        name = var"##1088"
                        var"##return#801" = begin
                                keyword("abstract type ")
                                p(name)
                                keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##1089" = (var"##cache#804").value
                                var"##1089" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1089"[1] == :primitive && (begin
                                        var"##1090" = var"##1089"[2]
                                        var"##1090" isa AbstractArray
                                    end && (length(var"##1090") === 2 && begin
                                            var"##1091" = var"##1090"[1]
                                            var"##1092" = var"##1090"[2]
                                            true
                                        end)))
                        name = var"##1091"
                        size = var"##1092"
                        var"##return#801" = begin
                                keyword("primitive type ")
                                p(name)
                                print(" ")
                                p(size)
                                keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##1093" = (var"##cache#804").value
                                var"##1093" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1093"[1] == :meta && (begin
                                        var"##1094" = var"##1093"[2]
                                        var"##1094" isa AbstractArray
                                    end && (length(var"##1094") === 1 && var"##1094"[1] == :inline)))
                        var"##return#801" = begin
                                macrocall(GlobalRef(Base, Symbol("@_inline_meta")))
                                keyword(";")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##1095" = (var"##cache#804").value
                                var"##1095" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1095"[1] == :break && (begin
                                        var"##1096" = var"##1095"[2]
                                        var"##1096" isa AbstractArray
                                    end && isempty(var"##1096")))
                        var"##return#801" = begin
                                keyword("break")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##1097" = (var"##cache#804").value
                                var"##1097" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1097"[1] == :symboliclabel && (begin
                                        var"##1098" = var"##1097"[2]
                                        var"##1098" isa AbstractArray
                                    end && (length(var"##1098") === 1 && begin
                                            var"##1099" = var"##1098"[1]
                                            true
                                        end)))
                        label = var"##1099"
                        var"##return#801" = begin
                                macrocall(GlobalRef(Base, Symbol("@label")))
                                print(" ")
                                p(label)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##1100" = (var"##cache#804").value
                                var"##1100" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1100"[1] == :symbolicgoto && (begin
                                        var"##1101" = var"##1100"[2]
                                        var"##1101" isa AbstractArray
                                    end && (length(var"##1101") === 1 && begin
                                            var"##1102" = var"##1101"[1]
                                            true
                                        end)))
                        label = var"##1102"
                        var"##return#801" = begin
                                macrocall(GlobalRef(Base, Symbol("@goto")))
                                print(" ")
                                p(label)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    if begin
                                var"##1103" = (var"##cache#804").value
                                var"##1103" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1104" = var"##1103"[1]
                                    var"##1105" = var"##1103"[2]
                                    var"##1105" isa AbstractArray
                                end && ((ndims(var"##1105") === 1 && length(var"##1105") >= 0) && begin
                                        var"##1106" = SubArray(var"##1105", (1:length(var"##1105"),))
                                        true
                                    end))
                        args = var"##1106"
                        head = var"##1104"
                        var"##return#801" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                end
                if var"##803" isa QuoteNode
                    if ex.value in Base.quoted_syms
                        var"##return#801" = begin
                                keyword(":(")
                                quoted(ex.value)
                                keyword(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                    begin
                        var"##return#801" = begin
                                if ex.value isa Symbol && Base.isidentifier(ex.value)
                                    keyword(":")
                                    quoted(ex.value)
                                else
                                    keyword(":(")
                                    quoted(ex.value)
                                    keyword(")")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                end
                if var"##803" isa Char
                    begin
                        var"##return#801" = begin
                                printstyled(repr(ex), color = c.string)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                end
                if var"##803" isa String
                    begin
                        var"##return#801" = begin
                                string(ex)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                end
                if var"##803" isa LineNumberNode
                    begin
                        var"##return#801" = begin
                                p.line || return nothing
                                printstyled("#= $(ex.file):$(ex.line) =#", color = c.line)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                    end
                end
                begin
                    var"##return#801" = begin
                            print(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#802#1107")))
                end
                error("matching non-exhaustive, at #= none:142 =#")
                $(Expr(:symboliclabel, Symbol("####final#802#1107")))
                var"##return#801"
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
