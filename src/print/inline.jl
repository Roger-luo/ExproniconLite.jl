
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
                        var"##cache#797" = nothing
                    end
                    var"##return#794" = nothing
                    var"##796" = ex
                    if var"##796" isa Expr
                        if begin
                                    if var"##cache#797" === nothing
                                        var"##cache#797" = Some(((var"##796").head, (var"##796").args))
                                    end
                                    var"##798" = (var"##cache#797").value
                                    var"##798" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##798"[1] == :. && (begin
                                            var"##799" = var"##798"[2]
                                            var"##799" isa AbstractArray
                                        end && (ndims(var"##799") === 1 && length(var"##799") >= 0)))
                            var"##return#794" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#795#800")))
                        end
                    end
                    if var"##796" isa Symbol
                        begin
                            var"##return#794" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#795#800")))
                        end
                    end
                    begin
                        var"##return#794" = let
                                false
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#795#800")))
                    end
                    error("matching non-exhaustive, at #= none:85 =#")
                    $(Expr(:symboliclabel, Symbol("####final#795#800")))
                    var"##return#794"
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
                    var"##cache#804" = nothing
                end
                var"##803" = ex
                if var"##803" isa Expr && (begin
                                if var"##cache#804" === nothing
                                    var"##cache#804" = Some(((var"##803").head, (var"##803").args))
                                end
                                var"##805" = (var"##cache#804").value
                                var"##805" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##805"[1] == :call && (begin
                                        var"##806" = var"##805"[2]
                                        var"##806" isa AbstractArray
                                    end && ((ndims(var"##806") === 1 && length(var"##806") >= 1) && (var"##806"[1] == :(:) && begin
                                                var"##807" = SubArray(var"##806", (2:length(var"##806"),))
                                                true
                                            end)))))
                    args = var"##807"
                    var"##return#801" = begin
                            precedence(:(:)) do 
                                join(args, ":")
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#802#829")))
                end
                if var"##803" isa Expr && (begin
                                if var"##cache#804" === nothing
                                    var"##cache#804" = Some(((var"##803").head, (var"##803").args))
                                end
                                var"##808" = (var"##cache#804").value
                                var"##808" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##808"[1] == :call && (begin
                                        var"##809" = var"##808"[2]
                                        var"##809" isa AbstractArray
                                    end && (length(var"##809") === 2 && (begin
                                                var"##810" = var"##809"[1]
                                                var"##810" isa Symbol
                                            end && begin
                                                var"##811" = var"##809"[2]
                                                let f = var"##810", arg = var"##811"
                                                    Base.isunaryoperator(f)
                                                end
                                            end)))))
                    f = var"##810"
                    arg = var"##811"
                    var"##return#801" = begin
                            precedence(typemax(Int)) do 
                                keyword(f)
                                p(arg)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#802#829")))
                end
                if var"##803" isa Expr && (begin
                                if var"##cache#804" === nothing
                                    var"##cache#804" = Some(((var"##803").head, (var"##803").args))
                                end
                                var"##812" = (var"##cache#804").value
                                var"##812" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##812"[1] == :call && (begin
                                        var"##813" = var"##812"[2]
                                        var"##813" isa AbstractArray
                                    end && ((ndims(var"##813") === 1 && length(var"##813") >= 1) && (begin
                                                var"##814" = var"##813"[1]
                                                var"##814" isa Symbol
                                            end && begin
                                                var"##815" = SubArray(var"##813", (2:length(var"##813"),))
                                                let f = var"##814", args = var"##815"
                                                    Base.isbinaryoperator(f)
                                                end
                                            end)))))
                    f = var"##814"
                    args = var"##815"
                    var"##return#801" = begin
                            precedence(f) do 
                                join(args, " $(f) ")
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#802#829")))
                end
                if var"##803" isa Expr && (begin
                                if var"##cache#804" === nothing
                                    var"##cache#804" = Some(((var"##803").head, (var"##803").args))
                                end
                                var"##816" = (var"##cache#804").value
                                var"##816" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##816"[1] == :call && (begin
                                        var"##817" = var"##816"[2]
                                        var"##817" isa AbstractArray
                                    end && ((ndims(var"##817") === 1 && length(var"##817") >= 2) && (begin
                                                var"##818" = var"##817"[1]
                                                begin
                                                    var"##cache#820" = nothing
                                                end
                                                var"##819" = var"##817"[2]
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
                                                                var"##824" = SubArray(var"##817", (3:length(var"##817"),))
                                                                true
                                                            end)))))))))
                    f = var"##818"
                    args = var"##824"
                    kwargs = var"##823"
                    var"##return#801" = begin
                            call(f)
                            print("(")
                            join(args)
                            keyword("; ")
                            join(kwargs)
                            print(")")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#802#829")))
                end
                if var"##803" isa Expr && (begin
                                if var"##cache#804" === nothing
                                    var"##cache#804" = Some(((var"##803").head, (var"##803").args))
                                end
                                var"##825" = (var"##cache#804").value
                                var"##825" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##825"[1] == :call && (begin
                                        var"##826" = var"##825"[2]
                                        var"##826" isa AbstractArray
                                    end && ((ndims(var"##826") === 1 && length(var"##826") >= 1) && begin
                                            var"##827" = var"##826"[1]
                                            var"##828" = SubArray(var"##826", (2:length(var"##826"),))
                                            true
                                        end))))
                    f = var"##827"
                    args = var"##828"
                    var"##return#801" = begin
                            call(f)
                            print_braces(args, "(", ")")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#802#829")))
                end
                error("matching non-exhaustive, at #= none:111 =#")
                $(Expr(:symboliclabel, Symbol("####final#802#829")))
                var"##return#801"
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
                    var"##cache#833" = nothing
                end
                var"##832" = ex
                if var"##832" isa GlobalRef
                    begin
                        var"##return#830" = begin
                                p(ex.mod)
                                keyword(".")
                                p(ex.name)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                end
                if var"##832" isa Nothing
                    begin
                        var"##return#830" = begin
                                printstyled("nothing", color = c.number)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                end
                if var"##832" isa Char
                    begin
                        var"##return#830" = begin
                                printstyled(repr(ex), color = c.string)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                end
                if var"##832" isa Number
                    begin
                        var"##return#830" = begin
                                printstyled(ex, color = c.number)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                end
                if var"##832" isa Symbol
                    begin
                        var"##return#830" = begin
                                symbol(ex)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                end
                if var"##832" isa Expr
                    if begin
                                if var"##cache#833" === nothing
                                    var"##cache#833" = Some(((var"##832").head, (var"##832").args))
                                end
                                var"##834" = (var"##cache#833").value
                                var"##834" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##834"[1] == :line && (begin
                                        var"##835" = var"##834"[2]
                                        var"##835" isa AbstractArray
                                    end && (length(var"##835") === 2 && begin
                                            var"##836" = var"##835"[1]
                                            var"##837" = var"##835"[2]
                                            true
                                        end)))
                        line = var"##837"
                        file = var"##836"
                        var"##return#830" = begin
                                p.line || return nothing
                                printstyled("#= $(file):$(line) =#", color = c.line)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##838" = (var"##cache#833").value
                                var"##838" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##838"[1] == :kw && (begin
                                        var"##839" = var"##838"[2]
                                        var"##839" isa AbstractArray
                                    end && (length(var"##839") === 2 && begin
                                            var"##840" = var"##839"[1]
                                            var"##841" = var"##839"[2]
                                            true
                                        end)))
                        k = var"##840"
                        v = var"##841"
                        var"##return#830" = begin
                                p(k)
                                print(" = ")
                                p(v)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##842" = (var"##cache#833").value
                                var"##842" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##842"[1] == :(=) && (begin
                                        var"##843" = var"##842"[2]
                                        var"##843" isa AbstractArray
                                    end && (length(var"##843") === 2 && (begin
                                                var"##844" = var"##843"[1]
                                                begin
                                                    var"##cache#846" = nothing
                                                end
                                                var"##845" = var"##843"[2]
                                                var"##845" isa Expr
                                            end && (begin
                                                    if var"##cache#846" === nothing
                                                        var"##cache#846" = Some(((var"##845").head, (var"##845").args))
                                                    end
                                                    var"##847" = (var"##cache#846").value
                                                    var"##847" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##847"[1] == :block && (begin
                                                            var"##848" = var"##847"[2]
                                                            var"##848" isa AbstractArray
                                                        end && ((ndims(var"##848") === 1 && length(var"##848") >= 0) && begin
                                                                var"##849" = SubArray(var"##848", (1:length(var"##848"),))
                                                                true
                                                            end))))))))
                        k = var"##844"
                        stmts = var"##849"
                        var"##return#830" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##850" = (var"##cache#833").value
                                var"##850" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##850"[1] == :(=) && (begin
                                        var"##851" = var"##850"[2]
                                        var"##851" isa AbstractArray
                                    end && (length(var"##851") === 2 && begin
                                            var"##852" = var"##851"[1]
                                            var"##853" = var"##851"[2]
                                            true
                                        end)))
                        k = var"##852"
                        v = var"##853"
                        var"##return#830" = begin
                                precedence(:(=)) do 
                                    p(k)
                                    assign()
                                    p(v)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##854" = (var"##cache#833").value
                                var"##854" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##854"[1] == :... && (begin
                                        var"##855" = var"##854"[2]
                                        var"##855" isa AbstractArray
                                    end && (length(var"##855") === 1 && begin
                                            var"##856" = var"##855"[1]
                                            true
                                        end)))
                        name = var"##856"
                        var"##return#830" = begin
                                precedence(:...) do 
                                    p(name)
                                    keyword("...")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##857" = (var"##cache#833").value
                                var"##857" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##857"[1] == :& && (begin
                                        var"##858" = var"##857"[2]
                                        var"##858" isa AbstractArray
                                    end && (length(var"##858") === 1 && begin
                                            var"##859" = var"##858"[1]
                                            true
                                        end)))
                        name = var"##859"
                        var"##return#830" = begin
                                precedence(:&) do 
                                    keyword("&")
                                    p(name)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##860" = (var"##cache#833").value
                                var"##860" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##860"[1] == :(::) && (begin
                                        var"##861" = var"##860"[2]
                                        var"##861" isa AbstractArray
                                    end && (length(var"##861") === 1 && begin
                                            var"##862" = var"##861"[1]
                                            true
                                        end)))
                        t = var"##862"
                        var"##return#830" = begin
                                precedence(:(::)) do 
                                    keyword("::")
                                    type(t)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##863" = (var"##cache#833").value
                                var"##863" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##863"[1] == :(::) && (begin
                                        var"##864" = var"##863"[2]
                                        var"##864" isa AbstractArray
                                    end && (length(var"##864") === 2 && begin
                                            var"##865" = var"##864"[1]
                                            var"##866" = var"##864"[2]
                                            true
                                        end)))
                        name = var"##865"
                        t = var"##866"
                        var"##return#830" = begin
                                precedence(:(::)) do 
                                    p(name)
                                    keyword("::")
                                    type(t)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##867" = (var"##cache#833").value
                                var"##867" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##867"[1] == :$ && (begin
                                        var"##868" = var"##867"[2]
                                        var"##868" isa AbstractArray
                                    end && (length(var"##868") === 1 && begin
                                            var"##869" = var"##868"[1]
                                            true
                                        end)))
                        name = var"##869"
                        var"##return#830" = begin
                                precedence(:$) do 
                                    keyword('$')
                                    print("(")
                                    p(name)
                                    print(")")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##870" = (var"##cache#833").value
                                var"##870" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##871" = var"##870"[1]
                                    var"##872" = var"##870"[2]
                                    var"##872" isa AbstractArray
                                end && (length(var"##872") === 2 && begin
                                        var"##873" = var"##872"[1]
                                        var"##874" = var"##872"[2]
                                        let rhs = var"##874", lhs = var"##873", head = var"##871"
                                            head in expr_infix_wide
                                        end
                                    end))
                        rhs = var"##874"
                        lhs = var"##873"
                        head = var"##871"
                        var"##return#830" = begin
                                precedence(head) do 
                                    p(lhs)
                                    keyword(" $(head) ")
                                    p(rhs)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##875" = (var"##cache#833").value
                                var"##875" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##875"[1] == :. && (begin
                                        var"##876" = var"##875"[2]
                                        var"##876" isa AbstractArray
                                    end && (length(var"##876") === 1 && begin
                                            var"##877" = var"##876"[1]
                                            true
                                        end)))
                        name = var"##877"
                        var"##return#830" = begin
                                print(name)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##878" = (var"##cache#833").value
                                var"##878" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##878"[1] == :. && (begin
                                        var"##879" = var"##878"[2]
                                        var"##879" isa AbstractArray
                                    end && (length(var"##879") === 2 && (begin
                                                var"##880" = var"##879"[1]
                                                var"##881" = var"##879"[2]
                                                var"##881" isa QuoteNode
                                            end && begin
                                                var"##882" = (var"##881").value
                                                true
                                            end))))
                        name = var"##882"
                        object = var"##880"
                        var"##return#830" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##883" = (var"##cache#833").value
                                var"##883" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##883"[1] == :. && (begin
                                        var"##884" = var"##883"[2]
                                        var"##884" isa AbstractArray
                                    end && (length(var"##884") === 2 && begin
                                            var"##885" = var"##884"[1]
                                            var"##886" = var"##884"[2]
                                            true
                                        end)))
                        name = var"##886"
                        object = var"##885"
                        var"##return#830" = begin
                                precedence(:.) do 
                                    p(object)
                                    keyword(".")
                                    p(name)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##887" = (var"##cache#833").value
                                var"##887" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##887"[1] == :<: && (begin
                                        var"##888" = var"##887"[2]
                                        var"##888" isa AbstractArray
                                    end && (length(var"##888") === 2 && begin
                                            var"##889" = var"##888"[1]
                                            var"##890" = var"##888"[2]
                                            true
                                        end)))
                        type = var"##889"
                        supertype = var"##890"
                        var"##return#830" = begin
                                precedence(:<:) do 
                                    p(type)
                                    keyword(" <: ")
                                    p(supertype)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##891" = (var"##cache#833").value
                                var"##891" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##891"[1] == :call && (begin
                                        var"##892" = var"##891"[2]
                                        var"##892" isa AbstractArray
                                    end && (ndims(var"##892") === 1 && length(var"##892") >= 0)))
                        var"##return#830" = begin
                                print_call(ex)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##893" = (var"##cache#833").value
                                var"##893" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##893"[1] == :tuple && (begin
                                        var"##894" = var"##893"[2]
                                        var"##894" isa AbstractArray
                                    end && (length(var"##894") === 1 && (begin
                                                begin
                                                    var"##cache#896" = nothing
                                                end
                                                var"##895" = var"##894"[1]
                                                var"##895" isa Expr
                                            end && (begin
                                                    if var"##cache#896" === nothing
                                                        var"##cache#896" = Some(((var"##895").head, (var"##895").args))
                                                    end
                                                    var"##897" = (var"##cache#896").value
                                                    var"##897" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##897"[1] == :parameters && (begin
                                                            var"##898" = var"##897"[2]
                                                            var"##898" isa AbstractArray
                                                        end && ((ndims(var"##898") === 1 && length(var"##898") >= 0) && begin
                                                                var"##899" = SubArray(var"##898", (1:length(var"##898"),))
                                                                true
                                                            end))))))))
                        args = var"##899"
                        var"##return#830" = begin
                                print_braces(args, "(;", ")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##900" = (var"##cache#833").value
                                var"##900" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##900"[1] == :tuple && (begin
                                        var"##901" = var"##900"[2]
                                        var"##901" isa AbstractArray
                                    end && ((ndims(var"##901") === 1 && length(var"##901") >= 0) && begin
                                            var"##902" = SubArray(var"##901", (1:length(var"##901"),))
                                            true
                                        end)))
                        args = var"##902"
                        var"##return#830" = begin
                                if length(args) == 1
                                    print("(")
                                    p(args[1])
                                    print(",)")
                                else
                                    print_braces(args, "(", ")")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##903" = (var"##cache#833").value
                                var"##903" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##903"[1] == :curly && (begin
                                        var"##904" = var"##903"[2]
                                        var"##904" isa AbstractArray
                                    end && ((ndims(var"##904") === 1 && length(var"##904") >= 1) && begin
                                            var"##905" = var"##904"[1]
                                            var"##906" = SubArray(var"##904", (2:length(var"##904"),))
                                            true
                                        end)))
                        args = var"##906"
                        t = var"##905"
                        var"##return#830" = begin
                                with(p.state, :type, true) do 
                                    p(t)
                                    print_braces(args, "{", "}")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##907" = (var"##cache#833").value
                                var"##907" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##907"[1] == :vect && (begin
                                        var"##908" = var"##907"[2]
                                        var"##908" isa AbstractArray
                                    end && ((ndims(var"##908") === 1 && length(var"##908") >= 0) && begin
                                            var"##909" = SubArray(var"##908", (1:length(var"##908"),))
                                            true
                                        end)))
                        args = var"##909"
                        var"##return#830" = begin
                                print_braces(args, "[", "]")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##910" = (var"##cache#833").value
                                var"##910" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##910"[1] == :hcat && (begin
                                        var"##911" = var"##910"[2]
                                        var"##911" isa AbstractArray
                                    end && ((ndims(var"##911") === 1 && length(var"##911") >= 0) && begin
                                            var"##912" = SubArray(var"##911", (1:length(var"##911"),))
                                            true
                                        end)))
                        args = var"##912"
                        var"##return#830" = begin
                                print_braces(args, "[", "]", " ")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##913" = (var"##cache#833").value
                                var"##913" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##913"[1] == :typed_hcat && (begin
                                        var"##914" = var"##913"[2]
                                        var"##914" isa AbstractArray
                                    end && ((ndims(var"##914") === 1 && length(var"##914") >= 1) && begin
                                            var"##915" = var"##914"[1]
                                            var"##916" = SubArray(var"##914", (2:length(var"##914"),))
                                            true
                                        end)))
                        args = var"##916"
                        t = var"##915"
                        var"##return#830" = begin
                                type(t)
                                print_braces(args, "[", "]", " ")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##917" = (var"##cache#833").value
                                var"##917" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##917"[1] == :vcat && (begin
                                        var"##918" = var"##917"[2]
                                        var"##918" isa AbstractArray
                                    end && ((ndims(var"##918") === 1 && length(var"##918") >= 0) && begin
                                            var"##919" = SubArray(var"##918", (1:length(var"##918"),))
                                            true
                                        end)))
                        args = var"##919"
                        var"##return#830" = begin
                                print_braces(args, "[", "]", "; ")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##920" = (var"##cache#833").value
                                var"##920" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##920"[1] == :ncat && (begin
                                        var"##921" = var"##920"[2]
                                        var"##921" isa AbstractArray
                                    end && ((ndims(var"##921") === 1 && length(var"##921") >= 1) && begin
                                            var"##922" = var"##921"[1]
                                            var"##923" = SubArray(var"##921", (2:length(var"##921"),))
                                            true
                                        end)))
                        n = var"##922"
                        args = var"##923"
                        var"##return#830" = begin
                                print_braces(args, "[", "]", ";" ^ n * " ")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##924" = (var"##cache#833").value
                                var"##924" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##924"[1] == :ref && (begin
                                        var"##925" = var"##924"[2]
                                        var"##925" isa AbstractArray
                                    end && ((ndims(var"##925") === 1 && length(var"##925") >= 1) && begin
                                            var"##926" = var"##925"[1]
                                            var"##927" = SubArray(var"##925", (2:length(var"##925"),))
                                            true
                                        end)))
                        args = var"##927"
                        object = var"##926"
                        var"##return#830" = begin
                                p(object)
                                print_braces(args, "[", "]")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##928" = (var"##cache#833").value
                                var"##928" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##928"[1] == :comprehension && (begin
                                        var"##929" = var"##928"[2]
                                        var"##929" isa AbstractArray
                                    end && (length(var"##929") === 1 && (begin
                                                begin
                                                    var"##cache#931" = nothing
                                                end
                                                var"##930" = var"##929"[1]
                                                var"##930" isa Expr
                                            end && (begin
                                                    if var"##cache#931" === nothing
                                                        var"##cache#931" = Some(((var"##930").head, (var"##930").args))
                                                    end
                                                    var"##932" = (var"##cache#931").value
                                                    var"##932" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##932"[1] == :generator && (begin
                                                            var"##933" = var"##932"[2]
                                                            var"##933" isa AbstractArray
                                                        end && (length(var"##933") === 2 && begin
                                                                var"##934" = var"##933"[1]
                                                                var"##935" = var"##933"[2]
                                                                true
                                                            end))))))))
                        iter = var"##934"
                        body = var"##935"
                        var"##return#830" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##936" = (var"##cache#833").value
                                var"##936" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##936"[1] == :typed_comprehension && (begin
                                        var"##937" = var"##936"[2]
                                        var"##937" isa AbstractArray
                                    end && (length(var"##937") === 2 && (begin
                                                var"##938" = var"##937"[1]
                                                begin
                                                    var"##cache#940" = nothing
                                                end
                                                var"##939" = var"##937"[2]
                                                var"##939" isa Expr
                                            end && (begin
                                                    if var"##cache#940" === nothing
                                                        var"##cache#940" = Some(((var"##939").head, (var"##939").args))
                                                    end
                                                    var"##941" = (var"##cache#940").value
                                                    var"##941" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##941"[1] == :generator && (begin
                                                            var"##942" = var"##941"[2]
                                                            var"##942" isa AbstractArray
                                                        end && (length(var"##942") === 2 && begin
                                                                var"##943" = var"##942"[1]
                                                                var"##944" = var"##942"[2]
                                                                true
                                                            end))))))))
                        iter = var"##943"
                        body = var"##944"
                        t = var"##938"
                        var"##return#830" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##945" = (var"##cache#833").value
                                var"##945" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##945"[1] == :-> && (begin
                                        var"##946" = var"##945"[2]
                                        var"##946" isa AbstractArray
                                    end && (length(var"##946") === 2 && (begin
                                                var"##947" = var"##946"[1]
                                                begin
                                                    var"##cache#949" = nothing
                                                end
                                                var"##948" = var"##946"[2]
                                                var"##948" isa Expr
                                            end && (begin
                                                    if var"##cache#949" === nothing
                                                        var"##cache#949" = Some(((var"##948").head, (var"##948").args))
                                                    end
                                                    var"##950" = (var"##cache#949").value
                                                    var"##950" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##950"[1] == :block && (begin
                                                            var"##951" = var"##950"[2]
                                                            var"##951" isa AbstractArray
                                                        end && (length(var"##951") === 2 && begin
                                                                var"##952" = var"##951"[1]
                                                                var"##953" = var"##951"[2]
                                                                true
                                                            end))))))))
                        line = var"##952"
                        code = var"##953"
                        args = var"##947"
                        var"##return#830" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##954" = (var"##cache#833").value
                                var"##954" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##954"[1] == :-> && (begin
                                        var"##955" = var"##954"[2]
                                        var"##955" isa AbstractArray
                                    end && (length(var"##955") === 2 && begin
                                            var"##956" = var"##955"[1]
                                            var"##957" = var"##955"[2]
                                            true
                                        end)))
                        args = var"##956"
                        body = var"##957"
                        var"##return#830" = begin
                                p(args)
                                keyword(" -> ")
                                print("(")
                                noblock(body)
                                print(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##958" = (var"##cache#833").value
                                var"##958" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##958"[1] == :do && (begin
                                        var"##959" = var"##958"[2]
                                        var"##959" isa AbstractArray
                                    end && (length(var"##959") === 2 && (begin
                                                var"##960" = var"##959"[1]
                                                begin
                                                    var"##cache#962" = nothing
                                                end
                                                var"##961" = var"##959"[2]
                                                var"##961" isa Expr
                                            end && (begin
                                                    if var"##cache#962" === nothing
                                                        var"##cache#962" = Some(((var"##961").head, (var"##961").args))
                                                    end
                                                    var"##963" = (var"##cache#962").value
                                                    var"##963" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##963"[1] == :-> && (begin
                                                            var"##964" = var"##963"[2]
                                                            var"##964" isa AbstractArray
                                                        end && (length(var"##964") === 2 && (begin
                                                                    begin
                                                                        var"##cache#966" = nothing
                                                                    end
                                                                    var"##965" = var"##964"[1]
                                                                    var"##965" isa Expr
                                                                end && (begin
                                                                        if var"##cache#966" === nothing
                                                                            var"##cache#966" = Some(((var"##965").head, (var"##965").args))
                                                                        end
                                                                        var"##967" = (var"##cache#966").value
                                                                        var"##967" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                    end && (var"##967"[1] == :tuple && (begin
                                                                                var"##968" = var"##967"[2]
                                                                                var"##968" isa AbstractArray
                                                                            end && ((ndims(var"##968") === 1 && length(var"##968") >= 0) && begin
                                                                                    var"##969" = SubArray(var"##968", (1:length(var"##968"),))
                                                                                    var"##970" = var"##964"[2]
                                                                                    true
                                                                                end)))))))))))))
                        call = var"##960"
                        args = var"##969"
                        body = var"##970"
                        var"##return#830" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##971" = (var"##cache#833").value
                                var"##971" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##971"[1] == :function && (begin
                                        var"##972" = var"##971"[2]
                                        var"##972" isa AbstractArray
                                    end && (length(var"##972") === 2 && begin
                                            var"##973" = var"##972"[1]
                                            var"##974" = var"##972"[2]
                                            true
                                        end)))
                        call = var"##973"
                        body = var"##974"
                        var"##return#830" = begin
                                print_function(:function, call, body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##975" = (var"##cache#833").value
                                var"##975" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##975"[1] == :quote && (begin
                                        var"##976" = var"##975"[2]
                                        var"##976" isa AbstractArray
                                    end && (length(var"##976") === 1 && begin
                                            var"##977" = var"##976"[1]
                                            true
                                        end)))
                        stmt = var"##977"
                        var"##return#830" = begin
                                keyword(":(")
                                noblock(stmt)
                                keyword(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##978" = (var"##cache#833").value
                                var"##978" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##978"[1] == :quote && (begin
                                        var"##979" = var"##978"[2]
                                        var"##979" isa AbstractArray
                                    end && ((ndims(var"##979") === 1 && length(var"##979") >= 0) && begin
                                            var"##980" = SubArray(var"##979", (1:length(var"##979"),))
                                            true
                                        end)))
                        args = var"##980"
                        var"##return#830" = begin
                                keyword("quote ")
                                with(p.state, :block, false) do 
                                    join(args, "; ")
                                end
                                keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##981" = (var"##cache#833").value
                                var"##981" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##981"[1] == :string && (begin
                                        var"##982" = var"##981"[2]
                                        var"##982" isa AbstractArray
                                    end && ((ndims(var"##982") === 1 && length(var"##982") >= 0) && begin
                                            var"##983" = SubArray(var"##982", (1:length(var"##982"),))
                                            true
                                        end)))
                        args = var"##983"
                        var"##return#830" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##984" = (var"##cache#833").value
                                var"##984" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##984"[1] == :block && (begin
                                        var"##985" = var"##984"[2]
                                        var"##985" isa AbstractArray
                                    end && ((ndims(var"##985") === 1 && length(var"##985") >= 0) && begin
                                            var"##986" = SubArray(var"##985", (1:length(var"##985"),))
                                            let args = var"##986"
                                                length(args) == 2 && (is_line_no(args[1]) && is_line_no(args[2]))
                                            end
                                        end)))
                        args = var"##986"
                        var"##return#830" = begin
                                p(args[1])
                                print(" ")
                                p(args[2])
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##987" = (var"##cache#833").value
                                var"##987" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##987"[1] == :block && (begin
                                        var"##988" = var"##987"[2]
                                        var"##988" isa AbstractArray
                                    end && ((ndims(var"##988") === 1 && length(var"##988") >= 0) && begin
                                            var"##989" = SubArray(var"##988", (1:length(var"##988"),))
                                            let args = var"##989"
                                                length(args) == 2 && is_line_no(args[1])
                                            end
                                        end)))
                        args = var"##989"
                        var"##return#830" = begin
                                p(args[1])
                                print(" ")
                                noblock(args[2])
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##990" = (var"##cache#833").value
                                var"##990" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##990"[1] == :block && (begin
                                        var"##991" = var"##990"[2]
                                        var"##991" isa AbstractArray
                                    end && ((ndims(var"##991") === 1 && length(var"##991") >= 0) && begin
                                            var"##992" = SubArray(var"##991", (1:length(var"##991"),))
                                            let args = var"##992"
                                                length(args) == 2 && is_line_no(args[2])
                                            end
                                        end)))
                        args = var"##992"
                        var"##return#830" = begin
                                noblock(args[1])
                                print(" ")
                                p(args[2])
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##993" = (var"##cache#833").value
                                var"##993" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##993"[1] == :block && (begin
                                        var"##994" = var"##993"[2]
                                        var"##994" isa AbstractArray
                                    end && ((ndims(var"##994") === 1 && length(var"##994") >= 0) && begin
                                            var"##995" = SubArray(var"##994", (1:length(var"##994"),))
                                            let args = var"##995"
                                                length(args) == 2
                                            end
                                        end)))
                        args = var"##995"
                        var"##return#830" = begin
                                print("(")
                                noblock(args[1])
                                keyword("; ")
                                noblock(args[2])
                                print(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##996" = (var"##cache#833").value
                                var"##996" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##996"[1] == :block && (begin
                                        var"##997" = var"##996"[2]
                                        var"##997" isa AbstractArray
                                    end && ((ndims(var"##997") === 1 && length(var"##997") >= 0) && begin
                                            var"##998" = SubArray(var"##997", (1:length(var"##997"),))
                                            true
                                        end)))
                        args = var"##998"
                        var"##return#830" = begin
                                p.state.block && keyword("begin ")
                                with(p.state, :block, true) do 
                                    join(args, "; ")
                                end
                                p.state.block && keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##999" = (var"##cache#833").value
                                var"##999" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##999"[1] == :let && (begin
                                        var"##1000" = var"##999"[2]
                                        var"##1000" isa AbstractArray
                                    end && (length(var"##1000") === 2 && (begin
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
                                                end && (var"##1003"[1] == :block && (begin
                                                            var"##1004" = var"##1003"[2]
                                                            var"##1004" isa AbstractArray
                                                        end && ((ndims(var"##1004") === 1 && length(var"##1004") >= 0) && begin
                                                                var"##1005" = SubArray(var"##1004", (1:length(var"##1004"),))
                                                                var"##1006" = var"##1000"[2]
                                                                true
                                                            end))))))))
                        args = var"##1005"
                        body = var"##1006"
                        var"##return#830" = begin
                                keyword("let ")
                                join(args, ", ")
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##1007" = (var"##cache#833").value
                                var"##1007" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1007"[1] == :let && (begin
                                        var"##1008" = var"##1007"[2]
                                        var"##1008" isa AbstractArray
                                    end && (length(var"##1008") === 2 && begin
                                            var"##1009" = var"##1008"[1]
                                            var"##1010" = var"##1008"[2]
                                            true
                                        end)))
                        arg = var"##1009"
                        body = var"##1010"
                        var"##return#830" = begin
                                keyword("let ")
                                p(arg)
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##1011" = (var"##cache#833").value
                                var"##1011" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1011"[1] == :macrocall && (begin
                                        var"##1012" = var"##1011"[2]
                                        var"##1012" isa AbstractArray
                                    end && ((ndims(var"##1012") === 1 && length(var"##1012") >= 2) && begin
                                            var"##1013" = var"##1012"[1]
                                            var"##1014" = var"##1012"[2]
                                            var"##1015" = SubArray(var"##1012", (3:length(var"##1012"),))
                                            true
                                        end)))
                        f = var"##1013"
                        line = var"##1014"
                        args = var"##1015"
                        var"##return#830" = begin
                                p.line && printstyled(line, color = c.comment)
                                macrocall(f)
                                print_braces(args, "(", ")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##1016" = (var"##cache#833").value
                                var"##1016" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1016"[1] == :return && (begin
                                        var"##1017" = var"##1016"[2]
                                        var"##1017" isa AbstractArray
                                    end && (length(var"##1017") === 1 && (begin
                                                begin
                                                    var"##cache#1019" = nothing
                                                end
                                                var"##1018" = var"##1017"[1]
                                                var"##1018" isa Expr
                                            end && (begin
                                                    if var"##cache#1019" === nothing
                                                        var"##cache#1019" = Some(((var"##1018").head, (var"##1018").args))
                                                    end
                                                    var"##1020" = (var"##cache#1019").value
                                                    var"##1020" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1020"[1] == :tuple && (begin
                                                            var"##1021" = var"##1020"[2]
                                                            var"##1021" isa AbstractArray
                                                        end && ((ndims(var"##1021") === 1 && length(var"##1021") >= 1) && (begin
                                                                    begin
                                                                        var"##cache#1023" = nothing
                                                                    end
                                                                    var"##1022" = var"##1021"[1]
                                                                    var"##1022" isa Expr
                                                                end && (begin
                                                                        if var"##cache#1023" === nothing
                                                                            var"##cache#1023" = Some(((var"##1022").head, (var"##1022").args))
                                                                        end
                                                                        var"##1024" = (var"##cache#1023").value
                                                                        var"##1024" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                    end && (var"##1024"[1] == :parameters && (begin
                                                                                var"##1025" = var"##1024"[2]
                                                                                var"##1025" isa AbstractArray
                                                                            end && ((ndims(var"##1025") === 1 && length(var"##1025") >= 0) && begin
                                                                                    var"##1026" = SubArray(var"##1025", (1:length(var"##1025"),))
                                                                                    var"##1027" = SubArray(var"##1021", (2:length(var"##1021"),))
                                                                                    true
                                                                                end)))))))))))))
                        args = var"##1027"
                        kwargs = var"##1026"
                        var"##return#830" = begin
                                keyword("return ")
                                p(Expr(:tuple, Expr(:parameters, kwargs...), args...))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##1028" = (var"##cache#833").value
                                var"##1028" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1028"[1] == :return && (begin
                                        var"##1029" = var"##1028"[2]
                                        var"##1029" isa AbstractArray
                                    end && (length(var"##1029") === 1 && (begin
                                                begin
                                                    var"##cache#1031" = nothing
                                                end
                                                var"##1030" = var"##1029"[1]
                                                var"##1030" isa Expr
                                            end && (begin
                                                    if var"##cache#1031" === nothing
                                                        var"##cache#1031" = Some(((var"##1030").head, (var"##1030").args))
                                                    end
                                                    var"##1032" = (var"##cache#1031").value
                                                    var"##1032" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1032"[1] == :tuple && (begin
                                                            var"##1033" = var"##1032"[2]
                                                            var"##1033" isa AbstractArray
                                                        end && ((ndims(var"##1033") === 1 && length(var"##1033") >= 0) && begin
                                                                var"##1034" = SubArray(var"##1033", (1:length(var"##1033"),))
                                                                true
                                                            end))))))))
                        args = var"##1034"
                        var"##return#830" = begin
                                keyword("return ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##1035" = (var"##cache#833").value
                                var"##1035" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1035"[1] == :return && (begin
                                        var"##1036" = var"##1035"[2]
                                        var"##1036" isa AbstractArray
                                    end && ((ndims(var"##1036") === 1 && length(var"##1036") >= 0) && begin
                                            var"##1037" = SubArray(var"##1036", (1:length(var"##1036"),))
                                            true
                                        end)))
                        args = var"##1037"
                        var"##return#830" = begin
                                keyword("return ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##1038" = (var"##cache#833").value
                                var"##1038" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1038"[1] == :module && (begin
                                        var"##1039" = var"##1038"[2]
                                        var"##1039" isa AbstractArray
                                    end && (length(var"##1039") === 3 && begin
                                            var"##1040" = var"##1039"[1]
                                            var"##1041" = var"##1039"[2]
                                            var"##1042" = var"##1039"[3]
                                            true
                                        end)))
                        bare = var"##1040"
                        name = var"##1041"
                        body = var"##1042"
                        var"##return#830" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##1043" = (var"##cache#833").value
                                var"##1043" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1043"[1] == :using && (begin
                                        var"##1044" = var"##1043"[2]
                                        var"##1044" isa AbstractArray
                                    end && ((ndims(var"##1044") === 1 && length(var"##1044") >= 0) && begin
                                            var"##1045" = SubArray(var"##1044", (1:length(var"##1044"),))
                                            true
                                        end)))
                        args = var"##1045"
                        var"##return#830" = begin
                                keyword("using ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##1046" = (var"##cache#833").value
                                var"##1046" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1046"[1] == :import && (begin
                                        var"##1047" = var"##1046"[2]
                                        var"##1047" isa AbstractArray
                                    end && ((ndims(var"##1047") === 1 && length(var"##1047") >= 0) && begin
                                            var"##1048" = SubArray(var"##1047", (1:length(var"##1047"),))
                                            true
                                        end)))
                        args = var"##1048"
                        var"##return#830" = begin
                                keyword("import ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##1049" = (var"##cache#833").value
                                var"##1049" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1049"[1] == :as && (begin
                                        var"##1050" = var"##1049"[2]
                                        var"##1050" isa AbstractArray
                                    end && (length(var"##1050") === 2 && begin
                                            var"##1051" = var"##1050"[1]
                                            var"##1052" = var"##1050"[2]
                                            true
                                        end)))
                        name = var"##1051"
                        alias = var"##1052"
                        var"##return#830" = begin
                                p(name)
                                keyword(" as ")
                                p(alias)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##1053" = (var"##cache#833").value
                                var"##1053" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1053"[1] == :export && (begin
                                        var"##1054" = var"##1053"[2]
                                        var"##1054" isa AbstractArray
                                    end && ((ndims(var"##1054") === 1 && length(var"##1054") >= 0) && begin
                                            var"##1055" = SubArray(var"##1054", (1:length(var"##1054"),))
                                            true
                                        end)))
                        args = var"##1055"
                        var"##return#830" = begin
                                keyword("export ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##1056" = (var"##cache#833").value
                                var"##1056" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1056"[1] == :(:) && (begin
                                        var"##1057" = var"##1056"[2]
                                        var"##1057" isa AbstractArray
                                    end && ((ndims(var"##1057") === 1 && length(var"##1057") >= 1) && begin
                                            var"##1058" = var"##1057"[1]
                                            var"##1059" = SubArray(var"##1057", (2:length(var"##1057"),))
                                            true
                                        end)))
                        args = var"##1059"
                        head = var"##1058"
                        var"##return#830" = begin
                                p(head)
                                keyword(": ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##1060" = (var"##cache#833").value
                                var"##1060" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1060"[1] == :where && (begin
                                        var"##1061" = var"##1060"[2]
                                        var"##1061" isa AbstractArray
                                    end && ((ndims(var"##1061") === 1 && length(var"##1061") >= 1) && begin
                                            var"##1062" = var"##1061"[1]
                                            var"##1063" = SubArray(var"##1061", (2:length(var"##1061"),))
                                            true
                                        end)))
                        body = var"##1062"
                        whereparams = var"##1063"
                        var"##return#830" = begin
                                p(body)
                                keyword(" where {")
                                with(p.state, :type, true) do 
                                    join(whereparams, ", ")
                                end
                                keyword("}")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##1064" = (var"##cache#833").value
                                var"##1064" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1064"[1] == :for && (begin
                                        var"##1065" = var"##1064"[2]
                                        var"##1065" isa AbstractArray
                                    end && (length(var"##1065") === 2 && begin
                                            var"##1066" = var"##1065"[1]
                                            var"##1067" = var"##1065"[2]
                                            true
                                        end)))
                        body = var"##1067"
                        iteration = var"##1066"
                        var"##return#830" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##1068" = (var"##cache#833").value
                                var"##1068" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1068"[1] == :while && (begin
                                        var"##1069" = var"##1068"[2]
                                        var"##1069" isa AbstractArray
                                    end && (length(var"##1069") === 2 && begin
                                            var"##1070" = var"##1069"[1]
                                            var"##1071" = var"##1069"[2]
                                            true
                                        end)))
                        body = var"##1071"
                        condition = var"##1070"
                        var"##return#830" = begin
                                keyword("while ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##1072" = (var"##cache#833").value
                                var"##1072" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1072"[1] == :continue && (begin
                                        var"##1073" = var"##1072"[2]
                                        var"##1073" isa AbstractArray
                                    end && isempty(var"##1073")))
                        var"##return#830" = begin
                                keyword("continue")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##1074" = (var"##cache#833").value
                                var"##1074" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1074"[1] == :if && (begin
                                        var"##1075" = var"##1074"[2]
                                        var"##1075" isa AbstractArray
                                    end && (length(var"##1075") === 2 && begin
                                            var"##1076" = var"##1075"[1]
                                            var"##1077" = var"##1075"[2]
                                            true
                                        end)))
                        body = var"##1077"
                        condition = var"##1076"
                        var"##return#830" = begin
                                keyword("if ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##1078" = (var"##cache#833").value
                                var"##1078" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1078"[1] == :if && (begin
                                        var"##1079" = var"##1078"[2]
                                        var"##1079" isa AbstractArray
                                    end && (length(var"##1079") === 3 && begin
                                            var"##1080" = var"##1079"[1]
                                            var"##1081" = var"##1079"[2]
                                            var"##1082" = var"##1079"[3]
                                            true
                                        end)))
                        body = var"##1081"
                        elsebody = var"##1082"
                        condition = var"##1080"
                        var"##return#830" = begin
                                keyword("if ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                                keyword("; ")
                                Meta.isexpr(elsebody, :elseif) || keyword("else ")
                                noblock(elsebody)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##1083" = (var"##cache#833").value
                                var"##1083" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1083"[1] == :elseif && (begin
                                        var"##1084" = var"##1083"[2]
                                        var"##1084" isa AbstractArray
                                    end && (length(var"##1084") === 2 && begin
                                            var"##1085" = var"##1084"[1]
                                            var"##1086" = var"##1084"[2]
                                            true
                                        end)))
                        body = var"##1086"
                        condition = var"##1085"
                        var"##return#830" = begin
                                keyword("elseif ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##1087" = (var"##cache#833").value
                                var"##1087" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1087"[1] == :elseif && (begin
                                        var"##1088" = var"##1087"[2]
                                        var"##1088" isa AbstractArray
                                    end && (length(var"##1088") === 3 && begin
                                            var"##1089" = var"##1088"[1]
                                            var"##1090" = var"##1088"[2]
                                            var"##1091" = var"##1088"[3]
                                            true
                                        end)))
                        body = var"##1090"
                        elsebody = var"##1091"
                        condition = var"##1089"
                        var"##return#830" = begin
                                keyword("elseif ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                                keyword("; ")
                                Meta.isexpr(elsebody, :elseif) || keyword("else")
                                noblock(elsebody)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##1092" = (var"##cache#833").value
                                var"##1092" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1092"[1] == :try && (begin
                                        var"##1093" = var"##1092"[2]
                                        var"##1093" isa AbstractArray
                                    end && (length(var"##1093") === 3 && begin
                                            var"##1094" = var"##1093"[1]
                                            var"##1095" = var"##1093"[2]
                                            var"##1096" = var"##1093"[3]
                                            true
                                        end)))
                        catch_vars = var"##1095"
                        catch_body = var"##1096"
                        try_body = var"##1094"
                        var"##return#830" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##1097" = (var"##cache#833").value
                                var"##1097" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1097"[1] == :try && (begin
                                        var"##1098" = var"##1097"[2]
                                        var"##1098" isa AbstractArray
                                    end && (length(var"##1098") === 4 && begin
                                            var"##1099" = var"##1098"[1]
                                            var"##1100" = var"##1098"[2]
                                            var"##1101" = var"##1098"[3]
                                            var"##1102" = var"##1098"[4]
                                            true
                                        end)))
                        catch_vars = var"##1100"
                        catch_body = var"##1101"
                        try_body = var"##1099"
                        finally_body = var"##1102"
                        var"##return#830" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##1103" = (var"##cache#833").value
                                var"##1103" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1103"[1] == :try && (begin
                                        var"##1104" = var"##1103"[2]
                                        var"##1104" isa AbstractArray
                                    end && (length(var"##1104") === 5 && begin
                                            var"##1105" = var"##1104"[1]
                                            var"##1106" = var"##1104"[2]
                                            var"##1107" = var"##1104"[3]
                                            var"##1108" = var"##1104"[4]
                                            var"##1109" = var"##1104"[5]
                                            true
                                        end)))
                        catch_vars = var"##1106"
                        catch_body = var"##1107"
                        try_body = var"##1105"
                        finally_body = var"##1108"
                        else_body = var"##1109"
                        var"##return#830" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##1110" = (var"##cache#833").value
                                var"##1110" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1110"[1] == :struct && (begin
                                        var"##1111" = var"##1110"[2]
                                        var"##1111" isa AbstractArray
                                    end && (length(var"##1111") === 3 && begin
                                            var"##1112" = var"##1111"[1]
                                            var"##1113" = var"##1111"[2]
                                            var"##1114" = var"##1111"[3]
                                            true
                                        end)))
                        ismutable = var"##1112"
                        name = var"##1113"
                        body = var"##1114"
                        var"##return#830" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##1115" = (var"##cache#833").value
                                var"##1115" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1115"[1] == :abstract && (begin
                                        var"##1116" = var"##1115"[2]
                                        var"##1116" isa AbstractArray
                                    end && (length(var"##1116") === 1 && begin
                                            var"##1117" = var"##1116"[1]
                                            true
                                        end)))
                        name = var"##1117"
                        var"##return#830" = begin
                                keyword("abstract type ")
                                p(name)
                                keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##1118" = (var"##cache#833").value
                                var"##1118" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1118"[1] == :primitive && (begin
                                        var"##1119" = var"##1118"[2]
                                        var"##1119" isa AbstractArray
                                    end && (length(var"##1119") === 2 && begin
                                            var"##1120" = var"##1119"[1]
                                            var"##1121" = var"##1119"[2]
                                            true
                                        end)))
                        name = var"##1120"
                        size = var"##1121"
                        var"##return#830" = begin
                                keyword("primitive type ")
                                p(name)
                                print(" ")
                                p(size)
                                keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##1122" = (var"##cache#833").value
                                var"##1122" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1122"[1] == :meta && (begin
                                        var"##1123" = var"##1122"[2]
                                        var"##1123" isa AbstractArray
                                    end && (length(var"##1123") === 1 && var"##1123"[1] == :inline)))
                        var"##return#830" = begin
                                macrocall(GlobalRef(Base, Symbol("@_inline_meta")))
                                keyword(";")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##1124" = (var"##cache#833").value
                                var"##1124" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1124"[1] == :break && (begin
                                        var"##1125" = var"##1124"[2]
                                        var"##1125" isa AbstractArray
                                    end && isempty(var"##1125")))
                        var"##return#830" = begin
                                keyword("break")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##1126" = (var"##cache#833").value
                                var"##1126" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1126"[1] == :symboliclabel && (begin
                                        var"##1127" = var"##1126"[2]
                                        var"##1127" isa AbstractArray
                                    end && (length(var"##1127") === 1 && begin
                                            var"##1128" = var"##1127"[1]
                                            true
                                        end)))
                        label = var"##1128"
                        var"##return#830" = begin
                                macrocall(GlobalRef(Base, Symbol("@label")))
                                print(" ")
                                p(label)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##1129" = (var"##cache#833").value
                                var"##1129" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1129"[1] == :symbolicgoto && (begin
                                        var"##1130" = var"##1129"[2]
                                        var"##1130" isa AbstractArray
                                    end && (length(var"##1130") === 1 && begin
                                            var"##1131" = var"##1130"[1]
                                            true
                                        end)))
                        label = var"##1131"
                        var"##return#830" = begin
                                macrocall(GlobalRef(Base, Symbol("@goto")))
                                print(" ")
                                p(label)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    if begin
                                var"##1132" = (var"##cache#833").value
                                var"##1132" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1133" = var"##1132"[1]
                                    var"##1134" = var"##1132"[2]
                                    var"##1134" isa AbstractArray
                                end && ((ndims(var"##1134") === 1 && length(var"##1134") >= 0) && begin
                                        var"##1135" = SubArray(var"##1134", (1:length(var"##1134"),))
                                        true
                                    end))
                        args = var"##1135"
                        head = var"##1133"
                        var"##return#830" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                end
                if var"##832" isa QuoteNode
                    if ex.value in Base.quoted_syms
                        var"##return#830" = begin
                                keyword(":(")
                                quoted(ex.value)
                                keyword(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                    begin
                        var"##return#830" = begin
                                if ex.value isa Symbol && Base.isidentifier(ex.value)
                                    keyword(":")
                                    quoted(ex.value)
                                else
                                    keyword(":(")
                                    quoted(ex.value)
                                    keyword(")")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                end
                if var"##832" isa String
                    begin
                        var"##return#830" = begin
                                string(ex)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                end
                if var"##832" isa LineNumberNode
                    begin
                        var"##return#830" = begin
                                p.line || return nothing
                                printstyled("#= $(ex.file):$(ex.line) =#", color = c.line)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                    end
                end
                begin
                    var"##return#830" = begin
                            print(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#831#1136")))
                end
                error("matching non-exhaustive, at #= none:142 =#")
                $(Expr(:symboliclabel, Symbol("####final#831#1136")))
                var"##return#830"
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
