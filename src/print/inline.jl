
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
                        var"##cache#743" = nothing
                    end
                    var"##return#740" = nothing
                    var"##742" = ex
                    if var"##742" isa Expr
                        if begin
                                    if var"##cache#743" === nothing
                                        var"##cache#743" = Some(((var"##742").head, (var"##742").args))
                                    end
                                    var"##744" = (var"##cache#743").value
                                    var"##744" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##744"[1] == :. && (begin
                                            var"##745" = var"##744"[2]
                                            var"##745" isa AbstractArray
                                        end && (ndims(var"##745") === 1 && length(var"##745") >= 0)))
                            var"##return#740" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#741#746")))
                        end
                    end
                    if var"##742" isa Symbol
                        begin
                            var"##return#740" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#741#746")))
                        end
                    end
                    begin
                        var"##return#740" = let
                                false
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#741#746")))
                    end
                    error("matching non-exhaustive, at #= none:85 =#")
                    $(Expr(:symboliclabel, Symbol("####final#741#746")))
                    var"##return#740"
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
                    var"##cache#750" = nothing
                end
                var"##749" = ex
                if var"##749" isa Expr && (begin
                                if var"##cache#750" === nothing
                                    var"##cache#750" = Some(((var"##749").head, (var"##749").args))
                                end
                                var"##751" = (var"##cache#750").value
                                var"##751" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##751"[1] == :call && (begin
                                        var"##752" = var"##751"[2]
                                        var"##752" isa AbstractArray
                                    end && ((ndims(var"##752") === 1 && length(var"##752") >= 1) && (var"##752"[1] == :(:) && begin
                                                var"##753" = SubArray(var"##752", (2:length(var"##752"),))
                                                true
                                            end)))))
                    args = var"##753"
                    var"##return#747" = begin
                            precedence(:(:)) do 
                                join(args, ":")
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#748#775")))
                end
                if var"##749" isa Expr && (begin
                                if var"##cache#750" === nothing
                                    var"##cache#750" = Some(((var"##749").head, (var"##749").args))
                                end
                                var"##754" = (var"##cache#750").value
                                var"##754" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##754"[1] == :call && (begin
                                        var"##755" = var"##754"[2]
                                        var"##755" isa AbstractArray
                                    end && (length(var"##755") === 2 && (begin
                                                var"##756" = var"##755"[1]
                                                var"##756" isa Symbol
                                            end && begin
                                                var"##757" = var"##755"[2]
                                                let f = var"##756", arg = var"##757"
                                                    Base.isunaryoperator(f)
                                                end
                                            end)))))
                    f = var"##756"
                    arg = var"##757"
                    var"##return#747" = begin
                            precedence(typemax(Int)) do 
                                keyword(f)
                                p(arg)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#748#775")))
                end
                if var"##749" isa Expr && (begin
                                if var"##cache#750" === nothing
                                    var"##cache#750" = Some(((var"##749").head, (var"##749").args))
                                end
                                var"##758" = (var"##cache#750").value
                                var"##758" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##758"[1] == :call && (begin
                                        var"##759" = var"##758"[2]
                                        var"##759" isa AbstractArray
                                    end && ((ndims(var"##759") === 1 && length(var"##759") >= 1) && (begin
                                                var"##760" = var"##759"[1]
                                                var"##760" isa Symbol
                                            end && begin
                                                var"##761" = SubArray(var"##759", (2:length(var"##759"),))
                                                let f = var"##760", args = var"##761"
                                                    Base.isbinaryoperator(f)
                                                end
                                            end)))))
                    f = var"##760"
                    args = var"##761"
                    var"##return#747" = begin
                            precedence(f) do 
                                join(args, " $(f) ")
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#748#775")))
                end
                if var"##749" isa Expr && (begin
                                if var"##cache#750" === nothing
                                    var"##cache#750" = Some(((var"##749").head, (var"##749").args))
                                end
                                var"##762" = (var"##cache#750").value
                                var"##762" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##762"[1] == :call && (begin
                                        var"##763" = var"##762"[2]
                                        var"##763" isa AbstractArray
                                    end && ((ndims(var"##763") === 1 && length(var"##763") >= 2) && (begin
                                                var"##764" = var"##763"[1]
                                                begin
                                                    var"##cache#766" = nothing
                                                end
                                                var"##765" = var"##763"[2]
                                                var"##765" isa Expr
                                            end && (begin
                                                    if var"##cache#766" === nothing
                                                        var"##cache#766" = Some(((var"##765").head, (var"##765").args))
                                                    end
                                                    var"##767" = (var"##cache#766").value
                                                    var"##767" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##767"[1] == :parameters && (begin
                                                            var"##768" = var"##767"[2]
                                                            var"##768" isa AbstractArray
                                                        end && ((ndims(var"##768") === 1 && length(var"##768") >= 0) && begin
                                                                var"##769" = SubArray(var"##768", (1:length(var"##768"),))
                                                                var"##770" = SubArray(var"##763", (3:length(var"##763"),))
                                                                true
                                                            end)))))))))
                    f = var"##764"
                    args = var"##770"
                    kwargs = var"##769"
                    var"##return#747" = begin
                            call(f)
                            print("(")
                            join(args)
                            keyword("; ")
                            join(kwargs)
                            print(")")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#748#775")))
                end
                if var"##749" isa Expr && (begin
                                if var"##cache#750" === nothing
                                    var"##cache#750" = Some(((var"##749").head, (var"##749").args))
                                end
                                var"##771" = (var"##cache#750").value
                                var"##771" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##771"[1] == :call && (begin
                                        var"##772" = var"##771"[2]
                                        var"##772" isa AbstractArray
                                    end && ((ndims(var"##772") === 1 && length(var"##772") >= 1) && begin
                                            var"##773" = var"##772"[1]
                                            var"##774" = SubArray(var"##772", (2:length(var"##772"),))
                                            true
                                        end))))
                    f = var"##773"
                    args = var"##774"
                    var"##return#747" = begin
                            call(f)
                            print_braces(args, "(", ")")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#748#775")))
                end
                error("matching non-exhaustive, at #= none:111 =#")
                $(Expr(:symboliclabel, Symbol("####final#748#775")))
                var"##return#747"
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
                    var"##cache#779" = nothing
                end
                var"##778" = ex
                if var"##778" isa GlobalRef
                    begin
                        var"##return#776" = begin
                                p(ex.mod)
                                keyword(".")
                                p(ex.name)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                end
                if var"##778" isa Nothing
                    begin
                        var"##return#776" = begin
                                printstyled("nothing", color = c.number)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                end
                if var"##778" isa Symbol
                    begin
                        var"##return#776" = begin
                                symbol(ex)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                end
                if var"##778" isa Expr
                    if begin
                                if var"##cache#779" === nothing
                                    var"##cache#779" = Some(((var"##778").head, (var"##778").args))
                                end
                                var"##780" = (var"##cache#779").value
                                var"##780" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##780"[1] == :line && (begin
                                        var"##781" = var"##780"[2]
                                        var"##781" isa AbstractArray
                                    end && (length(var"##781") === 2 && begin
                                            var"##782" = var"##781"[1]
                                            var"##783" = var"##781"[2]
                                            true
                                        end)))
                        line = var"##783"
                        file = var"##782"
                        var"##return#776" = begin
                                p.line || return nothing
                                printstyled("#= $(file):$(line) =#", color = c.line)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##784" = (var"##cache#779").value
                                var"##784" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##784"[1] == :kw && (begin
                                        var"##785" = var"##784"[2]
                                        var"##785" isa AbstractArray
                                    end && (length(var"##785") === 2 && begin
                                            var"##786" = var"##785"[1]
                                            var"##787" = var"##785"[2]
                                            true
                                        end)))
                        k = var"##786"
                        v = var"##787"
                        var"##return#776" = begin
                                p(k)
                                print(" = ")
                                p(v)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##788" = (var"##cache#779").value
                                var"##788" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##788"[1] == :(=) && (begin
                                        var"##789" = var"##788"[2]
                                        var"##789" isa AbstractArray
                                    end && (length(var"##789") === 2 && (begin
                                                var"##790" = var"##789"[1]
                                                begin
                                                    var"##cache#792" = nothing
                                                end
                                                var"##791" = var"##789"[2]
                                                var"##791" isa Expr
                                            end && (begin
                                                    if var"##cache#792" === nothing
                                                        var"##cache#792" = Some(((var"##791").head, (var"##791").args))
                                                    end
                                                    var"##793" = (var"##cache#792").value
                                                    var"##793" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##793"[1] == :block && (begin
                                                            var"##794" = var"##793"[2]
                                                            var"##794" isa AbstractArray
                                                        end && ((ndims(var"##794") === 1 && length(var"##794") >= 0) && begin
                                                                var"##795" = SubArray(var"##794", (1:length(var"##794"),))
                                                                true
                                                            end))))))))
                        k = var"##790"
                        stmts = var"##795"
                        var"##return#776" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##796" = (var"##cache#779").value
                                var"##796" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##796"[1] == :(=) && (begin
                                        var"##797" = var"##796"[2]
                                        var"##797" isa AbstractArray
                                    end && (length(var"##797") === 2 && begin
                                            var"##798" = var"##797"[1]
                                            var"##799" = var"##797"[2]
                                            true
                                        end)))
                        k = var"##798"
                        v = var"##799"
                        var"##return#776" = begin
                                precedence(:(=)) do 
                                    p(k)
                                    assign()
                                    p(v)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##800" = (var"##cache#779").value
                                var"##800" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##800"[1] == :... && (begin
                                        var"##801" = var"##800"[2]
                                        var"##801" isa AbstractArray
                                    end && (length(var"##801") === 1 && begin
                                            var"##802" = var"##801"[1]
                                            true
                                        end)))
                        name = var"##802"
                        var"##return#776" = begin
                                precedence(:...) do 
                                    p(name)
                                    keyword("...")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##803" = (var"##cache#779").value
                                var"##803" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##803"[1] == :& && (begin
                                        var"##804" = var"##803"[2]
                                        var"##804" isa AbstractArray
                                    end && (length(var"##804") === 1 && begin
                                            var"##805" = var"##804"[1]
                                            true
                                        end)))
                        name = var"##805"
                        var"##return#776" = begin
                                precedence(:&) do 
                                    keyword("&")
                                    p(name)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##806" = (var"##cache#779").value
                                var"##806" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##806"[1] == :(::) && (begin
                                        var"##807" = var"##806"[2]
                                        var"##807" isa AbstractArray
                                    end && (length(var"##807") === 1 && begin
                                            var"##808" = var"##807"[1]
                                            true
                                        end)))
                        t = var"##808"
                        var"##return#776" = begin
                                precedence(:(::)) do 
                                    keyword("::")
                                    type(t)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##809" = (var"##cache#779").value
                                var"##809" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##809"[1] == :(::) && (begin
                                        var"##810" = var"##809"[2]
                                        var"##810" isa AbstractArray
                                    end && (length(var"##810") === 2 && begin
                                            var"##811" = var"##810"[1]
                                            var"##812" = var"##810"[2]
                                            true
                                        end)))
                        name = var"##811"
                        t = var"##812"
                        var"##return#776" = begin
                                precedence(:(::)) do 
                                    p(name)
                                    keyword("::")
                                    type(t)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##813" = (var"##cache#779").value
                                var"##813" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##813"[1] == :$ && (begin
                                        var"##814" = var"##813"[2]
                                        var"##814" isa AbstractArray
                                    end && (length(var"##814") === 1 && begin
                                            var"##815" = var"##814"[1]
                                            true
                                        end)))
                        name = var"##815"
                        var"##return#776" = begin
                                precedence(:$) do 
                                    keyword('$')
                                    print("(")
                                    p(name)
                                    print(")")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##816" = (var"##cache#779").value
                                var"##816" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##817" = var"##816"[1]
                                    var"##818" = var"##816"[2]
                                    var"##818" isa AbstractArray
                                end && (length(var"##818") === 2 && begin
                                        var"##819" = var"##818"[1]
                                        var"##820" = var"##818"[2]
                                        let rhs = var"##820", lhs = var"##819", head = var"##817"
                                            head in expr_infix_wide
                                        end
                                    end))
                        rhs = var"##820"
                        lhs = var"##819"
                        head = var"##817"
                        var"##return#776" = begin
                                precedence(head) do 
                                    p(lhs)
                                    keyword(" $(head) ")
                                    p(rhs)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##821" = (var"##cache#779").value
                                var"##821" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##821"[1] == :. && (begin
                                        var"##822" = var"##821"[2]
                                        var"##822" isa AbstractArray
                                    end && (length(var"##822") === 1 && begin
                                            var"##823" = var"##822"[1]
                                            true
                                        end)))
                        name = var"##823"
                        var"##return#776" = begin
                                print(name)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##824" = (var"##cache#779").value
                                var"##824" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##824"[1] == :. && (begin
                                        var"##825" = var"##824"[2]
                                        var"##825" isa AbstractArray
                                    end && (length(var"##825") === 2 && (begin
                                                var"##826" = var"##825"[1]
                                                var"##827" = var"##825"[2]
                                                var"##827" isa QuoteNode
                                            end && begin
                                                var"##828" = (var"##827").value
                                                true
                                            end))))
                        name = var"##828"
                        object = var"##826"
                        var"##return#776" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##829" = (var"##cache#779").value
                                var"##829" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##829"[1] == :. && (begin
                                        var"##830" = var"##829"[2]
                                        var"##830" isa AbstractArray
                                    end && (length(var"##830") === 2 && begin
                                            var"##831" = var"##830"[1]
                                            var"##832" = var"##830"[2]
                                            true
                                        end)))
                        name = var"##832"
                        object = var"##831"
                        var"##return#776" = begin
                                precedence(:.) do 
                                    p(object)
                                    keyword(".")
                                    p(name)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##833" = (var"##cache#779").value
                                var"##833" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##833"[1] == :<: && (begin
                                        var"##834" = var"##833"[2]
                                        var"##834" isa AbstractArray
                                    end && (length(var"##834") === 2 && begin
                                            var"##835" = var"##834"[1]
                                            var"##836" = var"##834"[2]
                                            true
                                        end)))
                        type = var"##835"
                        supertype = var"##836"
                        var"##return#776" = begin
                                precedence(:<:) do 
                                    p(type)
                                    keyword(" <: ")
                                    p(supertype)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##837" = (var"##cache#779").value
                                var"##837" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##837"[1] == :call && (begin
                                        var"##838" = var"##837"[2]
                                        var"##838" isa AbstractArray
                                    end && (ndims(var"##838") === 1 && length(var"##838") >= 0)))
                        var"##return#776" = begin
                                print_call(ex)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##839" = (var"##cache#779").value
                                var"##839" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##839"[1] == :tuple && (begin
                                        var"##840" = var"##839"[2]
                                        var"##840" isa AbstractArray
                                    end && (length(var"##840") === 1 && (begin
                                                begin
                                                    var"##cache#842" = nothing
                                                end
                                                var"##841" = var"##840"[1]
                                                var"##841" isa Expr
                                            end && (begin
                                                    if var"##cache#842" === nothing
                                                        var"##cache#842" = Some(((var"##841").head, (var"##841").args))
                                                    end
                                                    var"##843" = (var"##cache#842").value
                                                    var"##843" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##843"[1] == :parameters && (begin
                                                            var"##844" = var"##843"[2]
                                                            var"##844" isa AbstractArray
                                                        end && ((ndims(var"##844") === 1 && length(var"##844") >= 0) && begin
                                                                var"##845" = SubArray(var"##844", (1:length(var"##844"),))
                                                                true
                                                            end))))))))
                        args = var"##845"
                        var"##return#776" = begin
                                print_braces(args, "(;", ")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##846" = (var"##cache#779").value
                                var"##846" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##846"[1] == :tuple && (begin
                                        var"##847" = var"##846"[2]
                                        var"##847" isa AbstractArray
                                    end && ((ndims(var"##847") === 1 && length(var"##847") >= 0) && begin
                                            var"##848" = SubArray(var"##847", (1:length(var"##847"),))
                                            true
                                        end)))
                        args = var"##848"
                        var"##return#776" = begin
                                if length(args) == 1
                                    print("(")
                                    p(args[1])
                                    print(",)")
                                else
                                    print_braces(args, "(", ")")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##849" = (var"##cache#779").value
                                var"##849" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##849"[1] == :curly && (begin
                                        var"##850" = var"##849"[2]
                                        var"##850" isa AbstractArray
                                    end && ((ndims(var"##850") === 1 && length(var"##850") >= 1) && begin
                                            var"##851" = var"##850"[1]
                                            var"##852" = SubArray(var"##850", (2:length(var"##850"),))
                                            true
                                        end)))
                        args = var"##852"
                        t = var"##851"
                        var"##return#776" = begin
                                with(p.state, :type, true) do 
                                    p(t)
                                    print_braces(args, "{", "}")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##853" = (var"##cache#779").value
                                var"##853" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##853"[1] == :vect && (begin
                                        var"##854" = var"##853"[2]
                                        var"##854" isa AbstractArray
                                    end && ((ndims(var"##854") === 1 && length(var"##854") >= 0) && begin
                                            var"##855" = SubArray(var"##854", (1:length(var"##854"),))
                                            true
                                        end)))
                        args = var"##855"
                        var"##return#776" = begin
                                print_braces(args, "[", "]")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##856" = (var"##cache#779").value
                                var"##856" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##856"[1] == :hcat && (begin
                                        var"##857" = var"##856"[2]
                                        var"##857" isa AbstractArray
                                    end && ((ndims(var"##857") === 1 && length(var"##857") >= 0) && begin
                                            var"##858" = SubArray(var"##857", (1:length(var"##857"),))
                                            true
                                        end)))
                        args = var"##858"
                        var"##return#776" = begin
                                print_braces(args, "[", "]", " ")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##859" = (var"##cache#779").value
                                var"##859" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##859"[1] == :typed_hcat && (begin
                                        var"##860" = var"##859"[2]
                                        var"##860" isa AbstractArray
                                    end && ((ndims(var"##860") === 1 && length(var"##860") >= 1) && begin
                                            var"##861" = var"##860"[1]
                                            var"##862" = SubArray(var"##860", (2:length(var"##860"),))
                                            true
                                        end)))
                        args = var"##862"
                        t = var"##861"
                        var"##return#776" = begin
                                type(t)
                                print_braces(args, "[", "]", " ")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##863" = (var"##cache#779").value
                                var"##863" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##863"[1] == :vcat && (begin
                                        var"##864" = var"##863"[2]
                                        var"##864" isa AbstractArray
                                    end && ((ndims(var"##864") === 1 && length(var"##864") >= 0) && begin
                                            var"##865" = SubArray(var"##864", (1:length(var"##864"),))
                                            true
                                        end)))
                        args = var"##865"
                        var"##return#776" = begin
                                print_braces(args, "[", "]", "; ")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##866" = (var"##cache#779").value
                                var"##866" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##866"[1] == :ncat && (begin
                                        var"##867" = var"##866"[2]
                                        var"##867" isa AbstractArray
                                    end && ((ndims(var"##867") === 1 && length(var"##867") >= 1) && begin
                                            var"##868" = var"##867"[1]
                                            var"##869" = SubArray(var"##867", (2:length(var"##867"),))
                                            true
                                        end)))
                        n = var"##868"
                        args = var"##869"
                        var"##return#776" = begin
                                print_braces(args, "[", "]", ";" ^ n * " ")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##870" = (var"##cache#779").value
                                var"##870" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##870"[1] == :ref && (begin
                                        var"##871" = var"##870"[2]
                                        var"##871" isa AbstractArray
                                    end && ((ndims(var"##871") === 1 && length(var"##871") >= 1) && begin
                                            var"##872" = var"##871"[1]
                                            var"##873" = SubArray(var"##871", (2:length(var"##871"),))
                                            true
                                        end)))
                        args = var"##873"
                        object = var"##872"
                        var"##return#776" = begin
                                p(object)
                                print_braces(args, "[", "]")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##874" = (var"##cache#779").value
                                var"##874" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##874"[1] == :comprehension && (begin
                                        var"##875" = var"##874"[2]
                                        var"##875" isa AbstractArray
                                    end && (length(var"##875") === 1 && (begin
                                                begin
                                                    var"##cache#877" = nothing
                                                end
                                                var"##876" = var"##875"[1]
                                                var"##876" isa Expr
                                            end && (begin
                                                    if var"##cache#877" === nothing
                                                        var"##cache#877" = Some(((var"##876").head, (var"##876").args))
                                                    end
                                                    var"##878" = (var"##cache#877").value
                                                    var"##878" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##878"[1] == :generator && (begin
                                                            var"##879" = var"##878"[2]
                                                            var"##879" isa AbstractArray
                                                        end && (length(var"##879") === 2 && begin
                                                                var"##880" = var"##879"[1]
                                                                var"##881" = var"##879"[2]
                                                                true
                                                            end))))))))
                        iter = var"##880"
                        body = var"##881"
                        var"##return#776" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##882" = (var"##cache#779").value
                                var"##882" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##882"[1] == :typed_comprehension && (begin
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
                                                end && (var"##887"[1] == :generator && (begin
                                                            var"##888" = var"##887"[2]
                                                            var"##888" isa AbstractArray
                                                        end && (length(var"##888") === 2 && begin
                                                                var"##889" = var"##888"[1]
                                                                var"##890" = var"##888"[2]
                                                                true
                                                            end))))))))
                        iter = var"##889"
                        body = var"##890"
                        t = var"##884"
                        var"##return#776" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##891" = (var"##cache#779").value
                                var"##891" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##891"[1] == :-> && (begin
                                        var"##892" = var"##891"[2]
                                        var"##892" isa AbstractArray
                                    end && (length(var"##892") === 2 && (begin
                                                var"##893" = var"##892"[1]
                                                begin
                                                    var"##cache#895" = nothing
                                                end
                                                var"##894" = var"##892"[2]
                                                var"##894" isa Expr
                                            end && (begin
                                                    if var"##cache#895" === nothing
                                                        var"##cache#895" = Some(((var"##894").head, (var"##894").args))
                                                    end
                                                    var"##896" = (var"##cache#895").value
                                                    var"##896" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##896"[1] == :block && (begin
                                                            var"##897" = var"##896"[2]
                                                            var"##897" isa AbstractArray
                                                        end && (length(var"##897") === 2 && begin
                                                                var"##898" = var"##897"[1]
                                                                var"##899" = var"##897"[2]
                                                                true
                                                            end))))))))
                        line = var"##898"
                        code = var"##899"
                        args = var"##893"
                        var"##return#776" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##900" = (var"##cache#779").value
                                var"##900" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##900"[1] == :-> && (begin
                                        var"##901" = var"##900"[2]
                                        var"##901" isa AbstractArray
                                    end && (length(var"##901") === 2 && begin
                                            var"##902" = var"##901"[1]
                                            var"##903" = var"##901"[2]
                                            true
                                        end)))
                        args = var"##902"
                        body = var"##903"
                        var"##return#776" = begin
                                p(args)
                                keyword(" -> ")
                                print("(")
                                noblock(body)
                                print(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##904" = (var"##cache#779").value
                                var"##904" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##904"[1] == :do && (begin
                                        var"##905" = var"##904"[2]
                                        var"##905" isa AbstractArray
                                    end && (length(var"##905") === 2 && (begin
                                                var"##906" = var"##905"[1]
                                                begin
                                                    var"##cache#908" = nothing
                                                end
                                                var"##907" = var"##905"[2]
                                                var"##907" isa Expr
                                            end && (begin
                                                    if var"##cache#908" === nothing
                                                        var"##cache#908" = Some(((var"##907").head, (var"##907").args))
                                                    end
                                                    var"##909" = (var"##cache#908").value
                                                    var"##909" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##909"[1] == :-> && (begin
                                                            var"##910" = var"##909"[2]
                                                            var"##910" isa AbstractArray
                                                        end && (length(var"##910") === 2 && (begin
                                                                    begin
                                                                        var"##cache#912" = nothing
                                                                    end
                                                                    var"##911" = var"##910"[1]
                                                                    var"##911" isa Expr
                                                                end && (begin
                                                                        if var"##cache#912" === nothing
                                                                            var"##cache#912" = Some(((var"##911").head, (var"##911").args))
                                                                        end
                                                                        var"##913" = (var"##cache#912").value
                                                                        var"##913" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                    end && (var"##913"[1] == :tuple && (begin
                                                                                var"##914" = var"##913"[2]
                                                                                var"##914" isa AbstractArray
                                                                            end && ((ndims(var"##914") === 1 && length(var"##914") >= 0) && begin
                                                                                    var"##915" = SubArray(var"##914", (1:length(var"##914"),))
                                                                                    var"##916" = var"##910"[2]
                                                                                    true
                                                                                end)))))))))))))
                        call = var"##906"
                        args = var"##915"
                        body = var"##916"
                        var"##return#776" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##917" = (var"##cache#779").value
                                var"##917" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##917"[1] == :function && (begin
                                        var"##918" = var"##917"[2]
                                        var"##918" isa AbstractArray
                                    end && (length(var"##918") === 2 && begin
                                            var"##919" = var"##918"[1]
                                            var"##920" = var"##918"[2]
                                            true
                                        end)))
                        call = var"##919"
                        body = var"##920"
                        var"##return#776" = begin
                                print_function(:function, call, body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##921" = (var"##cache#779").value
                                var"##921" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##921"[1] == :quote && (begin
                                        var"##922" = var"##921"[2]
                                        var"##922" isa AbstractArray
                                    end && (length(var"##922") === 1 && begin
                                            var"##923" = var"##922"[1]
                                            true
                                        end)))
                        stmt = var"##923"
                        var"##return#776" = begin
                                keyword(":(")
                                noblock(stmt)
                                keyword(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##924" = (var"##cache#779").value
                                var"##924" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##924"[1] == :quote && (begin
                                        var"##925" = var"##924"[2]
                                        var"##925" isa AbstractArray
                                    end && ((ndims(var"##925") === 1 && length(var"##925") >= 0) && begin
                                            var"##926" = SubArray(var"##925", (1:length(var"##925"),))
                                            true
                                        end)))
                        args = var"##926"
                        var"##return#776" = begin
                                keyword("quote ")
                                with(p.state, :block, false) do 
                                    join(args, "; ")
                                end
                                keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##927" = (var"##cache#779").value
                                var"##927" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##927"[1] == :string && (begin
                                        var"##928" = var"##927"[2]
                                        var"##928" isa AbstractArray
                                    end && ((ndims(var"##928") === 1 && length(var"##928") >= 0) && begin
                                            var"##929" = SubArray(var"##928", (1:length(var"##928"),))
                                            true
                                        end)))
                        args = var"##929"
                        var"##return#776" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##930" = (var"##cache#779").value
                                var"##930" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##930"[1] == :block && (begin
                                        var"##931" = var"##930"[2]
                                        var"##931" isa AbstractArray
                                    end && ((ndims(var"##931") === 1 && length(var"##931") >= 0) && begin
                                            var"##932" = SubArray(var"##931", (1:length(var"##931"),))
                                            let args = var"##932"
                                                length(args) == 2 && (is_line_no(args[1]) && is_line_no(args[2]))
                                            end
                                        end)))
                        args = var"##932"
                        var"##return#776" = begin
                                p(args[1])
                                print(" ")
                                p(args[2])
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##933" = (var"##cache#779").value
                                var"##933" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##933"[1] == :block && (begin
                                        var"##934" = var"##933"[2]
                                        var"##934" isa AbstractArray
                                    end && ((ndims(var"##934") === 1 && length(var"##934") >= 0) && begin
                                            var"##935" = SubArray(var"##934", (1:length(var"##934"),))
                                            let args = var"##935"
                                                length(args) == 2 && is_line_no(args[1])
                                            end
                                        end)))
                        args = var"##935"
                        var"##return#776" = begin
                                p(args[1])
                                print(" ")
                                noblock(args[2])
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##936" = (var"##cache#779").value
                                var"##936" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##936"[1] == :block && (begin
                                        var"##937" = var"##936"[2]
                                        var"##937" isa AbstractArray
                                    end && ((ndims(var"##937") === 1 && length(var"##937") >= 0) && begin
                                            var"##938" = SubArray(var"##937", (1:length(var"##937"),))
                                            let args = var"##938"
                                                length(args) == 2 && is_line_no(args[2])
                                            end
                                        end)))
                        args = var"##938"
                        var"##return#776" = begin
                                noblock(args[1])
                                print(" ")
                                p(args[2])
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##939" = (var"##cache#779").value
                                var"##939" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##939"[1] == :block && (begin
                                        var"##940" = var"##939"[2]
                                        var"##940" isa AbstractArray
                                    end && ((ndims(var"##940") === 1 && length(var"##940") >= 0) && begin
                                            var"##941" = SubArray(var"##940", (1:length(var"##940"),))
                                            let args = var"##941"
                                                length(args) == 2
                                            end
                                        end)))
                        args = var"##941"
                        var"##return#776" = begin
                                print("(")
                                noblock(args[1])
                                keyword("; ")
                                noblock(args[2])
                                print(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##942" = (var"##cache#779").value
                                var"##942" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##942"[1] == :block && (begin
                                        var"##943" = var"##942"[2]
                                        var"##943" isa AbstractArray
                                    end && ((ndims(var"##943") === 1 && length(var"##943") >= 0) && begin
                                            var"##944" = SubArray(var"##943", (1:length(var"##943"),))
                                            true
                                        end)))
                        args = var"##944"
                        var"##return#776" = begin
                                p.state.block && keyword("begin ")
                                with(p.state, :block, true) do 
                                    join(args, "; ")
                                end
                                p.state.block && keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##945" = (var"##cache#779").value
                                var"##945" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##945"[1] == :let && (begin
                                        var"##946" = var"##945"[2]
                                        var"##946" isa AbstractArray
                                    end && (length(var"##946") === 2 && (begin
                                                begin
                                                    var"##cache#948" = nothing
                                                end
                                                var"##947" = var"##946"[1]
                                                var"##947" isa Expr
                                            end && (begin
                                                    if var"##cache#948" === nothing
                                                        var"##cache#948" = Some(((var"##947").head, (var"##947").args))
                                                    end
                                                    var"##949" = (var"##cache#948").value
                                                    var"##949" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##949"[1] == :block && (begin
                                                            var"##950" = var"##949"[2]
                                                            var"##950" isa AbstractArray
                                                        end && ((ndims(var"##950") === 1 && length(var"##950") >= 0) && begin
                                                                var"##951" = SubArray(var"##950", (1:length(var"##950"),))
                                                                var"##952" = var"##946"[2]
                                                                true
                                                            end))))))))
                        args = var"##951"
                        body = var"##952"
                        var"##return#776" = begin
                                keyword("let ")
                                join(args, ", ")
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##953" = (var"##cache#779").value
                                var"##953" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##953"[1] == :let && (begin
                                        var"##954" = var"##953"[2]
                                        var"##954" isa AbstractArray
                                    end && (length(var"##954") === 2 && begin
                                            var"##955" = var"##954"[1]
                                            var"##956" = var"##954"[2]
                                            true
                                        end)))
                        arg = var"##955"
                        body = var"##956"
                        var"##return#776" = begin
                                keyword("let ")
                                p(arg)
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##957" = (var"##cache#779").value
                                var"##957" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##957"[1] == :macrocall && (begin
                                        var"##958" = var"##957"[2]
                                        var"##958" isa AbstractArray
                                    end && ((ndims(var"##958") === 1 && length(var"##958") >= 2) && begin
                                            var"##959" = var"##958"[1]
                                            var"##960" = var"##958"[2]
                                            var"##961" = SubArray(var"##958", (3:length(var"##958"),))
                                            true
                                        end)))
                        f = var"##959"
                        line = var"##960"
                        args = var"##961"
                        var"##return#776" = begin
                                p.line && printstyled(line, color = c.comment)
                                macrocall(f)
                                print_braces(args, "(", ")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##962" = (var"##cache#779").value
                                var"##962" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##962"[1] == :return && (begin
                                        var"##963" = var"##962"[2]
                                        var"##963" isa AbstractArray
                                    end && (length(var"##963") === 1 && (begin
                                                begin
                                                    var"##cache#965" = nothing
                                                end
                                                var"##964" = var"##963"[1]
                                                var"##964" isa Expr
                                            end && (begin
                                                    if var"##cache#965" === nothing
                                                        var"##cache#965" = Some(((var"##964").head, (var"##964").args))
                                                    end
                                                    var"##966" = (var"##cache#965").value
                                                    var"##966" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##966"[1] == :tuple && (begin
                                                            var"##967" = var"##966"[2]
                                                            var"##967" isa AbstractArray
                                                        end && ((ndims(var"##967") === 1 && length(var"##967") >= 1) && (begin
                                                                    begin
                                                                        var"##cache#969" = nothing
                                                                    end
                                                                    var"##968" = var"##967"[1]
                                                                    var"##968" isa Expr
                                                                end && (begin
                                                                        if var"##cache#969" === nothing
                                                                            var"##cache#969" = Some(((var"##968").head, (var"##968").args))
                                                                        end
                                                                        var"##970" = (var"##cache#969").value
                                                                        var"##970" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                    end && (var"##970"[1] == :parameters && (begin
                                                                                var"##971" = var"##970"[2]
                                                                                var"##971" isa AbstractArray
                                                                            end && ((ndims(var"##971") === 1 && length(var"##971") >= 0) && begin
                                                                                    var"##972" = SubArray(var"##971", (1:length(var"##971"),))
                                                                                    var"##973" = SubArray(var"##967", (2:length(var"##967"),))
                                                                                    true
                                                                                end)))))))))))))
                        args = var"##973"
                        kwargs = var"##972"
                        var"##return#776" = begin
                                keyword("return ")
                                p(Expr(:tuple, Expr(:parameters, kwargs...), args...))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##974" = (var"##cache#779").value
                                var"##974" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##974"[1] == :return && (begin
                                        var"##975" = var"##974"[2]
                                        var"##975" isa AbstractArray
                                    end && (length(var"##975") === 1 && (begin
                                                begin
                                                    var"##cache#977" = nothing
                                                end
                                                var"##976" = var"##975"[1]
                                                var"##976" isa Expr
                                            end && (begin
                                                    if var"##cache#977" === nothing
                                                        var"##cache#977" = Some(((var"##976").head, (var"##976").args))
                                                    end
                                                    var"##978" = (var"##cache#977").value
                                                    var"##978" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##978"[1] == :tuple && (begin
                                                            var"##979" = var"##978"[2]
                                                            var"##979" isa AbstractArray
                                                        end && ((ndims(var"##979") === 1 && length(var"##979") >= 0) && begin
                                                                var"##980" = SubArray(var"##979", (1:length(var"##979"),))
                                                                true
                                                            end))))))))
                        args = var"##980"
                        var"##return#776" = begin
                                keyword("return ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##981" = (var"##cache#779").value
                                var"##981" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##981"[1] == :return && (begin
                                        var"##982" = var"##981"[2]
                                        var"##982" isa AbstractArray
                                    end && ((ndims(var"##982") === 1 && length(var"##982") >= 0) && begin
                                            var"##983" = SubArray(var"##982", (1:length(var"##982"),))
                                            true
                                        end)))
                        args = var"##983"
                        var"##return#776" = begin
                                keyword("return ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##984" = (var"##cache#779").value
                                var"##984" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##984"[1] == :module && (begin
                                        var"##985" = var"##984"[2]
                                        var"##985" isa AbstractArray
                                    end && (length(var"##985") === 3 && begin
                                            var"##986" = var"##985"[1]
                                            var"##987" = var"##985"[2]
                                            var"##988" = var"##985"[3]
                                            true
                                        end)))
                        bare = var"##986"
                        name = var"##987"
                        body = var"##988"
                        var"##return#776" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##989" = (var"##cache#779").value
                                var"##989" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##989"[1] == :using && (begin
                                        var"##990" = var"##989"[2]
                                        var"##990" isa AbstractArray
                                    end && ((ndims(var"##990") === 1 && length(var"##990") >= 0) && begin
                                            var"##991" = SubArray(var"##990", (1:length(var"##990"),))
                                            true
                                        end)))
                        args = var"##991"
                        var"##return#776" = begin
                                keyword("using ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##992" = (var"##cache#779").value
                                var"##992" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##992"[1] == :import && (begin
                                        var"##993" = var"##992"[2]
                                        var"##993" isa AbstractArray
                                    end && ((ndims(var"##993") === 1 && length(var"##993") >= 0) && begin
                                            var"##994" = SubArray(var"##993", (1:length(var"##993"),))
                                            true
                                        end)))
                        args = var"##994"
                        var"##return#776" = begin
                                keyword("import ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##995" = (var"##cache#779").value
                                var"##995" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##995"[1] == :as && (begin
                                        var"##996" = var"##995"[2]
                                        var"##996" isa AbstractArray
                                    end && (length(var"##996") === 2 && begin
                                            var"##997" = var"##996"[1]
                                            var"##998" = var"##996"[2]
                                            true
                                        end)))
                        name = var"##997"
                        alias = var"##998"
                        var"##return#776" = begin
                                p(name)
                                keyword(" as ")
                                p(alias)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##999" = (var"##cache#779").value
                                var"##999" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##999"[1] == :export && (begin
                                        var"##1000" = var"##999"[2]
                                        var"##1000" isa AbstractArray
                                    end && ((ndims(var"##1000") === 1 && length(var"##1000") >= 0) && begin
                                            var"##1001" = SubArray(var"##1000", (1:length(var"##1000"),))
                                            true
                                        end)))
                        args = var"##1001"
                        var"##return#776" = begin
                                keyword("export ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##1002" = (var"##cache#779").value
                                var"##1002" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1002"[1] == :(:) && (begin
                                        var"##1003" = var"##1002"[2]
                                        var"##1003" isa AbstractArray
                                    end && ((ndims(var"##1003") === 1 && length(var"##1003") >= 1) && begin
                                            var"##1004" = var"##1003"[1]
                                            var"##1005" = SubArray(var"##1003", (2:length(var"##1003"),))
                                            true
                                        end)))
                        args = var"##1005"
                        head = var"##1004"
                        var"##return#776" = begin
                                p(head)
                                keyword(": ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##1006" = (var"##cache#779").value
                                var"##1006" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1006"[1] == :where && (begin
                                        var"##1007" = var"##1006"[2]
                                        var"##1007" isa AbstractArray
                                    end && ((ndims(var"##1007") === 1 && length(var"##1007") >= 1) && begin
                                            var"##1008" = var"##1007"[1]
                                            var"##1009" = SubArray(var"##1007", (2:length(var"##1007"),))
                                            true
                                        end)))
                        body = var"##1008"
                        whereparams = var"##1009"
                        var"##return#776" = begin
                                p(body)
                                keyword(" where {")
                                with(p.state, :type, true) do 
                                    join(whereparams, ", ")
                                end
                                keyword("}")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##1010" = (var"##cache#779").value
                                var"##1010" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1010"[1] == :for && (begin
                                        var"##1011" = var"##1010"[2]
                                        var"##1011" isa AbstractArray
                                    end && (length(var"##1011") === 2 && begin
                                            var"##1012" = var"##1011"[1]
                                            var"##1013" = var"##1011"[2]
                                            true
                                        end)))
                        body = var"##1013"
                        iteration = var"##1012"
                        var"##return#776" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##1014" = (var"##cache#779").value
                                var"##1014" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1014"[1] == :while && (begin
                                        var"##1015" = var"##1014"[2]
                                        var"##1015" isa AbstractArray
                                    end && (length(var"##1015") === 2 && begin
                                            var"##1016" = var"##1015"[1]
                                            var"##1017" = var"##1015"[2]
                                            true
                                        end)))
                        body = var"##1017"
                        condition = var"##1016"
                        var"##return#776" = begin
                                keyword("while ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##1018" = (var"##cache#779").value
                                var"##1018" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1018"[1] == :continue && (begin
                                        var"##1019" = var"##1018"[2]
                                        var"##1019" isa AbstractArray
                                    end && isempty(var"##1019")))
                        var"##return#776" = begin
                                keyword("continue")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##1020" = (var"##cache#779").value
                                var"##1020" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1020"[1] == :if && (begin
                                        var"##1021" = var"##1020"[2]
                                        var"##1021" isa AbstractArray
                                    end && (length(var"##1021") === 2 && begin
                                            var"##1022" = var"##1021"[1]
                                            var"##1023" = var"##1021"[2]
                                            true
                                        end)))
                        body = var"##1023"
                        condition = var"##1022"
                        var"##return#776" = begin
                                keyword("if ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##1024" = (var"##cache#779").value
                                var"##1024" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1024"[1] == :if && (begin
                                        var"##1025" = var"##1024"[2]
                                        var"##1025" isa AbstractArray
                                    end && (length(var"##1025") === 3 && begin
                                            var"##1026" = var"##1025"[1]
                                            var"##1027" = var"##1025"[2]
                                            var"##1028" = var"##1025"[3]
                                            true
                                        end)))
                        body = var"##1027"
                        elsebody = var"##1028"
                        condition = var"##1026"
                        var"##return#776" = begin
                                keyword("if ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                                keyword("; ")
                                Meta.isexpr(elsebody, :elseif) || keyword("else ")
                                noblock(elsebody)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##1029" = (var"##cache#779").value
                                var"##1029" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1029"[1] == :elseif && (begin
                                        var"##1030" = var"##1029"[2]
                                        var"##1030" isa AbstractArray
                                    end && (length(var"##1030") === 2 && begin
                                            var"##1031" = var"##1030"[1]
                                            var"##1032" = var"##1030"[2]
                                            true
                                        end)))
                        body = var"##1032"
                        condition = var"##1031"
                        var"##return#776" = begin
                                keyword("elseif ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##1033" = (var"##cache#779").value
                                var"##1033" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1033"[1] == :elseif && (begin
                                        var"##1034" = var"##1033"[2]
                                        var"##1034" isa AbstractArray
                                    end && (length(var"##1034") === 3 && begin
                                            var"##1035" = var"##1034"[1]
                                            var"##1036" = var"##1034"[2]
                                            var"##1037" = var"##1034"[3]
                                            true
                                        end)))
                        body = var"##1036"
                        elsebody = var"##1037"
                        condition = var"##1035"
                        var"##return#776" = begin
                                keyword("elseif ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                                keyword("; ")
                                Meta.isexpr(elsebody, :elseif) || keyword("else")
                                noblock(elsebody)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##1038" = (var"##cache#779").value
                                var"##1038" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1038"[1] == :try && (begin
                                        var"##1039" = var"##1038"[2]
                                        var"##1039" isa AbstractArray
                                    end && (length(var"##1039") === 3 && begin
                                            var"##1040" = var"##1039"[1]
                                            var"##1041" = var"##1039"[2]
                                            var"##1042" = var"##1039"[3]
                                            true
                                        end)))
                        catch_vars = var"##1041"
                        catch_body = var"##1042"
                        try_body = var"##1040"
                        var"##return#776" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##1043" = (var"##cache#779").value
                                var"##1043" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1043"[1] == :try && (begin
                                        var"##1044" = var"##1043"[2]
                                        var"##1044" isa AbstractArray
                                    end && (length(var"##1044") === 4 && begin
                                            var"##1045" = var"##1044"[1]
                                            var"##1046" = var"##1044"[2]
                                            var"##1047" = var"##1044"[3]
                                            var"##1048" = var"##1044"[4]
                                            true
                                        end)))
                        catch_vars = var"##1046"
                        catch_body = var"##1047"
                        try_body = var"##1045"
                        finally_body = var"##1048"
                        var"##return#776" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##1049" = (var"##cache#779").value
                                var"##1049" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1049"[1] == :try && (begin
                                        var"##1050" = var"##1049"[2]
                                        var"##1050" isa AbstractArray
                                    end && (length(var"##1050") === 5 && begin
                                            var"##1051" = var"##1050"[1]
                                            var"##1052" = var"##1050"[2]
                                            var"##1053" = var"##1050"[3]
                                            var"##1054" = var"##1050"[4]
                                            var"##1055" = var"##1050"[5]
                                            true
                                        end)))
                        catch_vars = var"##1052"
                        catch_body = var"##1053"
                        try_body = var"##1051"
                        finally_body = var"##1054"
                        else_body = var"##1055"
                        var"##return#776" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##1056" = (var"##cache#779").value
                                var"##1056" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1056"[1] == :struct && (begin
                                        var"##1057" = var"##1056"[2]
                                        var"##1057" isa AbstractArray
                                    end && (length(var"##1057") === 3 && begin
                                            var"##1058" = var"##1057"[1]
                                            var"##1059" = var"##1057"[2]
                                            var"##1060" = var"##1057"[3]
                                            true
                                        end)))
                        ismutable = var"##1058"
                        name = var"##1059"
                        body = var"##1060"
                        var"##return#776" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##1061" = (var"##cache#779").value
                                var"##1061" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1061"[1] == :abstract && (begin
                                        var"##1062" = var"##1061"[2]
                                        var"##1062" isa AbstractArray
                                    end && (length(var"##1062") === 1 && begin
                                            var"##1063" = var"##1062"[1]
                                            true
                                        end)))
                        name = var"##1063"
                        var"##return#776" = begin
                                keyword("abstract type ")
                                p(name)
                                keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##1064" = (var"##cache#779").value
                                var"##1064" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1064"[1] == :primitive && (begin
                                        var"##1065" = var"##1064"[2]
                                        var"##1065" isa AbstractArray
                                    end && (length(var"##1065") === 2 && begin
                                            var"##1066" = var"##1065"[1]
                                            var"##1067" = var"##1065"[2]
                                            true
                                        end)))
                        name = var"##1066"
                        size = var"##1067"
                        var"##return#776" = begin
                                keyword("primitive type ")
                                p(name)
                                print(" ")
                                p(size)
                                keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##1068" = (var"##cache#779").value
                                var"##1068" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1068"[1] == :meta && (begin
                                        var"##1069" = var"##1068"[2]
                                        var"##1069" isa AbstractArray
                                    end && (length(var"##1069") === 1 && var"##1069"[1] == :inline)))
                        var"##return#776" = begin
                                macrocall(GlobalRef(Base, Symbol("@_inline_meta")))
                                keyword(";")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##1070" = (var"##cache#779").value
                                var"##1070" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1070"[1] == :break && (begin
                                        var"##1071" = var"##1070"[2]
                                        var"##1071" isa AbstractArray
                                    end && isempty(var"##1071")))
                        var"##return#776" = begin
                                keyword("break")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##1072" = (var"##cache#779").value
                                var"##1072" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1072"[1] == :symboliclabel && (begin
                                        var"##1073" = var"##1072"[2]
                                        var"##1073" isa AbstractArray
                                    end && (length(var"##1073") === 1 && begin
                                            var"##1074" = var"##1073"[1]
                                            true
                                        end)))
                        label = var"##1074"
                        var"##return#776" = begin
                                macrocall(GlobalRef(Base, Symbol("@label")))
                                print(" ")
                                p(label)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##1075" = (var"##cache#779").value
                                var"##1075" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1075"[1] == :symbolicgoto && (begin
                                        var"##1076" = var"##1075"[2]
                                        var"##1076" isa AbstractArray
                                    end && (length(var"##1076") === 1 && begin
                                            var"##1077" = var"##1076"[1]
                                            true
                                        end)))
                        label = var"##1077"
                        var"##return#776" = begin
                                macrocall(GlobalRef(Base, Symbol("@goto")))
                                print(" ")
                                p(label)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    if begin
                                var"##1078" = (var"##cache#779").value
                                var"##1078" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1079" = var"##1078"[1]
                                    var"##1080" = var"##1078"[2]
                                    var"##1080" isa AbstractArray
                                end && ((ndims(var"##1080") === 1 && length(var"##1080") >= 0) && begin
                                        var"##1081" = SubArray(var"##1080", (1:length(var"##1080"),))
                                        true
                                    end))
                        args = var"##1081"
                        head = var"##1079"
                        var"##return#776" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                end
                if var"##778" isa Number
                    begin
                        var"##return#776" = begin
                                printstyled(ex, color = c.number)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                end
                if var"##778" isa QuoteNode
                    if ex.value in Base.quoted_syms
                        var"##return#776" = begin
                                keyword(":(")
                                quoted(ex.value)
                                keyword(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                    begin
                        var"##return#776" = begin
                                if ex.value isa Symbol && Base.isidentifier(ex.value)
                                    keyword(":")
                                    quoted(ex.value)
                                else
                                    keyword(":(")
                                    quoted(ex.value)
                                    keyword(")")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                end
                if var"##778" isa String
                    begin
                        var"##return#776" = begin
                                string(ex)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                end
                if var"##778" isa LineNumberNode
                    begin
                        var"##return#776" = begin
                                p.line || return nothing
                                printstyled("#= $(ex.file):$(ex.line) =#", color = c.line)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                end
                if var"##778" isa Char
                    begin
                        var"##return#776" = begin
                                printstyled(repr(ex), color = c.string)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                    end
                end
                begin
                    var"##return#776" = begin
                            print(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#777#1082")))
                end
                error("matching non-exhaustive, at #= none:142 =#")
                $(Expr(:symboliclabel, Symbol("####final#777#1082")))
                var"##return#776"
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
