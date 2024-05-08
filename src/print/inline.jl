
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
                        var"##cache#723" = nothing
                    end
                    var"##return#720" = nothing
                    var"##722" = ex
                    if var"##722" isa Expr
                        if begin
                                    if var"##cache#723" === nothing
                                        var"##cache#723" = Some(((var"##722").head, (var"##722").args))
                                    end
                                    var"##724" = (var"##cache#723").value
                                    var"##724" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##724"[1] == :. && (begin
                                            var"##725" = var"##724"[2]
                                            var"##725" isa AbstractArray
                                        end && (ndims(var"##725") === 1 && length(var"##725") >= 0)))
                            var"##return#720" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#721#726")))
                        end
                    end
                    if var"##722" isa Symbol
                        begin
                            var"##return#720" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#721#726")))
                        end
                    end
                    begin
                        var"##return#720" = let
                                false
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#721#726")))
                    end
                    error("matching non-exhaustive, at #= none:85 =#")
                    $(Expr(:symboliclabel, Symbol("####final#721#726")))
                    var"##return#720"
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
                    var"##cache#730" = nothing
                end
                var"##729" = ex
                if var"##729" isa Expr && (begin
                                if var"##cache#730" === nothing
                                    var"##cache#730" = Some(((var"##729").head, (var"##729").args))
                                end
                                var"##731" = (var"##cache#730").value
                                var"##731" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##731"[1] == :call && (begin
                                        var"##732" = var"##731"[2]
                                        var"##732" isa AbstractArray
                                    end && ((ndims(var"##732") === 1 && length(var"##732") >= 1) && (var"##732"[1] == :(:) && begin
                                                var"##733" = SubArray(var"##732", (2:length(var"##732"),))
                                                true
                                            end)))))
                    args = var"##733"
                    var"##return#727" = begin
                            precedence(:(:)) do 
                                join(args, ":")
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#728#755")))
                end
                if var"##729" isa Expr && (begin
                                if var"##cache#730" === nothing
                                    var"##cache#730" = Some(((var"##729").head, (var"##729").args))
                                end
                                var"##734" = (var"##cache#730").value
                                var"##734" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##734"[1] == :call && (begin
                                        var"##735" = var"##734"[2]
                                        var"##735" isa AbstractArray
                                    end && (length(var"##735") === 2 && (begin
                                                var"##736" = var"##735"[1]
                                                var"##736" isa Symbol
                                            end && begin
                                                var"##737" = var"##735"[2]
                                                let f = var"##736", arg = var"##737"
                                                    Base.isunaryoperator(f)
                                                end
                                            end)))))
                    f = var"##736"
                    arg = var"##737"
                    var"##return#727" = begin
                            precedence(typemax(Int)) do 
                                keyword(f)
                                p(arg)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#728#755")))
                end
                if var"##729" isa Expr && (begin
                                if var"##cache#730" === nothing
                                    var"##cache#730" = Some(((var"##729").head, (var"##729").args))
                                end
                                var"##738" = (var"##cache#730").value
                                var"##738" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##738"[1] == :call && (begin
                                        var"##739" = var"##738"[2]
                                        var"##739" isa AbstractArray
                                    end && ((ndims(var"##739") === 1 && length(var"##739") >= 1) && (begin
                                                var"##740" = var"##739"[1]
                                                var"##740" isa Symbol
                                            end && begin
                                                var"##741" = SubArray(var"##739", (2:length(var"##739"),))
                                                let f = var"##740", args = var"##741"
                                                    Base.isbinaryoperator(f)
                                                end
                                            end)))))
                    f = var"##740"
                    args = var"##741"
                    var"##return#727" = begin
                            precedence(f) do 
                                join(args, " $(f) ")
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#728#755")))
                end
                if var"##729" isa Expr && (begin
                                if var"##cache#730" === nothing
                                    var"##cache#730" = Some(((var"##729").head, (var"##729").args))
                                end
                                var"##742" = (var"##cache#730").value
                                var"##742" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##742"[1] == :call && (begin
                                        var"##743" = var"##742"[2]
                                        var"##743" isa AbstractArray
                                    end && ((ndims(var"##743") === 1 && length(var"##743") >= 2) && (begin
                                                var"##744" = var"##743"[1]
                                                begin
                                                    var"##cache#746" = nothing
                                                end
                                                var"##745" = var"##743"[2]
                                                var"##745" isa Expr
                                            end && (begin
                                                    if var"##cache#746" === nothing
                                                        var"##cache#746" = Some(((var"##745").head, (var"##745").args))
                                                    end
                                                    var"##747" = (var"##cache#746").value
                                                    var"##747" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##747"[1] == :parameters && (begin
                                                            var"##748" = var"##747"[2]
                                                            var"##748" isa AbstractArray
                                                        end && ((ndims(var"##748") === 1 && length(var"##748") >= 0) && begin
                                                                var"##749" = SubArray(var"##748", (1:length(var"##748"),))
                                                                var"##750" = SubArray(var"##743", (3:length(var"##743"),))
                                                                true
                                                            end)))))))))
                    f = var"##744"
                    args = var"##750"
                    kwargs = var"##749"
                    var"##return#727" = begin
                            call(f)
                            print("(")
                            join(args)
                            keyword("; ")
                            join(kwargs)
                            print(")")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#728#755")))
                end
                if var"##729" isa Expr && (begin
                                if var"##cache#730" === nothing
                                    var"##cache#730" = Some(((var"##729").head, (var"##729").args))
                                end
                                var"##751" = (var"##cache#730").value
                                var"##751" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##751"[1] == :call && (begin
                                        var"##752" = var"##751"[2]
                                        var"##752" isa AbstractArray
                                    end && ((ndims(var"##752") === 1 && length(var"##752") >= 1) && begin
                                            var"##753" = var"##752"[1]
                                            var"##754" = SubArray(var"##752", (2:length(var"##752"),))
                                            true
                                        end))))
                    f = var"##753"
                    args = var"##754"
                    var"##return#727" = begin
                            call(f)
                            print_braces(args, "(", ")")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#728#755")))
                end
                error("matching non-exhaustive, at #= none:111 =#")
                $(Expr(:symboliclabel, Symbol("####final#728#755")))
                var"##return#727"
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
                    var"##cache#759" = nothing
                end
                var"##758" = ex
                if var"##758" isa GlobalRef
                    begin
                        var"##return#756" = begin
                                p(ex.mod)
                                keyword(".")
                                p(ex.name)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                end
                if var"##758" isa Nothing
                    begin
                        var"##return#756" = begin
                                printstyled("nothing", color = c.number)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                end
                if var"##758" isa Symbol
                    begin
                        var"##return#756" = begin
                                symbol(ex)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                end
                if var"##758" isa Number
                    begin
                        var"##return#756" = begin
                                printstyled(ex, color = c.number)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                end
                if var"##758" isa Expr
                    if begin
                                if var"##cache#759" === nothing
                                    var"##cache#759" = Some(((var"##758").head, (var"##758").args))
                                end
                                var"##760" = (var"##cache#759").value
                                var"##760" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##760"[1] == :line && (begin
                                        var"##761" = var"##760"[2]
                                        var"##761" isa AbstractArray
                                    end && (length(var"##761") === 2 && begin
                                            var"##762" = var"##761"[1]
                                            var"##763" = var"##761"[2]
                                            true
                                        end)))
                        line = var"##763"
                        file = var"##762"
                        var"##return#756" = begin
                                p.line || return nothing
                                printstyled("#= $(file):$(line) =#", color = c.line)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##764" = (var"##cache#759").value
                                var"##764" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##764"[1] == :kw && (begin
                                        var"##765" = var"##764"[2]
                                        var"##765" isa AbstractArray
                                    end && (length(var"##765") === 2 && begin
                                            var"##766" = var"##765"[1]
                                            var"##767" = var"##765"[2]
                                            true
                                        end)))
                        k = var"##766"
                        v = var"##767"
                        var"##return#756" = begin
                                p(k)
                                print(" = ")
                                p(v)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##768" = (var"##cache#759").value
                                var"##768" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##768"[1] == :(=) && (begin
                                        var"##769" = var"##768"[2]
                                        var"##769" isa AbstractArray
                                    end && (length(var"##769") === 2 && (begin
                                                var"##770" = var"##769"[1]
                                                begin
                                                    var"##cache#772" = nothing
                                                end
                                                var"##771" = var"##769"[2]
                                                var"##771" isa Expr
                                            end && (begin
                                                    if var"##cache#772" === nothing
                                                        var"##cache#772" = Some(((var"##771").head, (var"##771").args))
                                                    end
                                                    var"##773" = (var"##cache#772").value
                                                    var"##773" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##773"[1] == :block && (begin
                                                            var"##774" = var"##773"[2]
                                                            var"##774" isa AbstractArray
                                                        end && ((ndims(var"##774") === 1 && length(var"##774") >= 0) && begin
                                                                var"##775" = SubArray(var"##774", (1:length(var"##774"),))
                                                                true
                                                            end))))))))
                        k = var"##770"
                        stmts = var"##775"
                        var"##return#756" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##776" = (var"##cache#759").value
                                var"##776" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##776"[1] == :(=) && (begin
                                        var"##777" = var"##776"[2]
                                        var"##777" isa AbstractArray
                                    end && (length(var"##777") === 2 && begin
                                            var"##778" = var"##777"[1]
                                            var"##779" = var"##777"[2]
                                            true
                                        end)))
                        k = var"##778"
                        v = var"##779"
                        var"##return#756" = begin
                                precedence(:(=)) do 
                                    p(k)
                                    assign()
                                    p(v)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##780" = (var"##cache#759").value
                                var"##780" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##780"[1] == :... && (begin
                                        var"##781" = var"##780"[2]
                                        var"##781" isa AbstractArray
                                    end && (length(var"##781") === 1 && begin
                                            var"##782" = var"##781"[1]
                                            true
                                        end)))
                        name = var"##782"
                        var"##return#756" = begin
                                precedence(:...) do 
                                    p(name)
                                    keyword("...")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##783" = (var"##cache#759").value
                                var"##783" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##783"[1] == :& && (begin
                                        var"##784" = var"##783"[2]
                                        var"##784" isa AbstractArray
                                    end && (length(var"##784") === 1 && begin
                                            var"##785" = var"##784"[1]
                                            true
                                        end)))
                        name = var"##785"
                        var"##return#756" = begin
                                precedence(:&) do 
                                    keyword("&")
                                    p(name)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##786" = (var"##cache#759").value
                                var"##786" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##786"[1] == :(::) && (begin
                                        var"##787" = var"##786"[2]
                                        var"##787" isa AbstractArray
                                    end && (length(var"##787") === 1 && begin
                                            var"##788" = var"##787"[1]
                                            true
                                        end)))
                        t = var"##788"
                        var"##return#756" = begin
                                precedence(:(::)) do 
                                    keyword("::")
                                    type(t)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##789" = (var"##cache#759").value
                                var"##789" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##789"[1] == :(::) && (begin
                                        var"##790" = var"##789"[2]
                                        var"##790" isa AbstractArray
                                    end && (length(var"##790") === 2 && begin
                                            var"##791" = var"##790"[1]
                                            var"##792" = var"##790"[2]
                                            true
                                        end)))
                        name = var"##791"
                        t = var"##792"
                        var"##return#756" = begin
                                precedence(:(::)) do 
                                    p(name)
                                    keyword("::")
                                    type(t)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##793" = (var"##cache#759").value
                                var"##793" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##793"[1] == :$ && (begin
                                        var"##794" = var"##793"[2]
                                        var"##794" isa AbstractArray
                                    end && (length(var"##794") === 1 && begin
                                            var"##795" = var"##794"[1]
                                            true
                                        end)))
                        name = var"##795"
                        var"##return#756" = begin
                                precedence(:$) do 
                                    keyword('$')
                                    print("(")
                                    p(name)
                                    print(")")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##796" = (var"##cache#759").value
                                var"##796" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##797" = var"##796"[1]
                                    var"##798" = var"##796"[2]
                                    var"##798" isa AbstractArray
                                end && (length(var"##798") === 2 && begin
                                        var"##799" = var"##798"[1]
                                        var"##800" = var"##798"[2]
                                        let rhs = var"##800", lhs = var"##799", head = var"##797"
                                            head in expr_infix_wide
                                        end
                                    end))
                        rhs = var"##800"
                        lhs = var"##799"
                        head = var"##797"
                        var"##return#756" = begin
                                precedence(head) do 
                                    p(lhs)
                                    keyword(" $(head) ")
                                    p(rhs)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##801" = (var"##cache#759").value
                                var"##801" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##801"[1] == :. && (begin
                                        var"##802" = var"##801"[2]
                                        var"##802" isa AbstractArray
                                    end && (length(var"##802") === 1 && begin
                                            var"##803" = var"##802"[1]
                                            true
                                        end)))
                        name = var"##803"
                        var"##return#756" = begin
                                print(name)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##804" = (var"##cache#759").value
                                var"##804" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##804"[1] == :. && (begin
                                        var"##805" = var"##804"[2]
                                        var"##805" isa AbstractArray
                                    end && (length(var"##805") === 2 && (begin
                                                var"##806" = var"##805"[1]
                                                var"##807" = var"##805"[2]
                                                var"##807" isa QuoteNode
                                            end && begin
                                                var"##808" = (var"##807").value
                                                true
                                            end))))
                        name = var"##808"
                        object = var"##806"
                        var"##return#756" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##809" = (var"##cache#759").value
                                var"##809" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##809"[1] == :. && (begin
                                        var"##810" = var"##809"[2]
                                        var"##810" isa AbstractArray
                                    end && (length(var"##810") === 2 && begin
                                            var"##811" = var"##810"[1]
                                            var"##812" = var"##810"[2]
                                            true
                                        end)))
                        name = var"##812"
                        object = var"##811"
                        var"##return#756" = begin
                                precedence(:.) do 
                                    p(object)
                                    keyword(".")
                                    p(name)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##813" = (var"##cache#759").value
                                var"##813" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##813"[1] == :<: && (begin
                                        var"##814" = var"##813"[2]
                                        var"##814" isa AbstractArray
                                    end && (length(var"##814") === 2 && begin
                                            var"##815" = var"##814"[1]
                                            var"##816" = var"##814"[2]
                                            true
                                        end)))
                        type = var"##815"
                        supertype = var"##816"
                        var"##return#756" = begin
                                precedence(:<:) do 
                                    p(type)
                                    keyword(" <: ")
                                    p(supertype)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##817" = (var"##cache#759").value
                                var"##817" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##817"[1] == :call && (begin
                                        var"##818" = var"##817"[2]
                                        var"##818" isa AbstractArray
                                    end && (ndims(var"##818") === 1 && length(var"##818") >= 0)))
                        var"##return#756" = begin
                                print_call(ex)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##819" = (var"##cache#759").value
                                var"##819" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##819"[1] == :tuple && (begin
                                        var"##820" = var"##819"[2]
                                        var"##820" isa AbstractArray
                                    end && (length(var"##820") === 1 && (begin
                                                begin
                                                    var"##cache#822" = nothing
                                                end
                                                var"##821" = var"##820"[1]
                                                var"##821" isa Expr
                                            end && (begin
                                                    if var"##cache#822" === nothing
                                                        var"##cache#822" = Some(((var"##821").head, (var"##821").args))
                                                    end
                                                    var"##823" = (var"##cache#822").value
                                                    var"##823" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##823"[1] == :parameters && (begin
                                                            var"##824" = var"##823"[2]
                                                            var"##824" isa AbstractArray
                                                        end && ((ndims(var"##824") === 1 && length(var"##824") >= 0) && begin
                                                                var"##825" = SubArray(var"##824", (1:length(var"##824"),))
                                                                true
                                                            end))))))))
                        args = var"##825"
                        var"##return#756" = begin
                                print_braces(args, "(;", ")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##826" = (var"##cache#759").value
                                var"##826" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##826"[1] == :tuple && (begin
                                        var"##827" = var"##826"[2]
                                        var"##827" isa AbstractArray
                                    end && ((ndims(var"##827") === 1 && length(var"##827") >= 0) && begin
                                            var"##828" = SubArray(var"##827", (1:length(var"##827"),))
                                            true
                                        end)))
                        args = var"##828"
                        var"##return#756" = begin
                                if length(args) == 1
                                    print("(")
                                    p(args[1])
                                    print(",)")
                                else
                                    print_braces(args, "(", ")")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##829" = (var"##cache#759").value
                                var"##829" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##829"[1] == :curly && (begin
                                        var"##830" = var"##829"[2]
                                        var"##830" isa AbstractArray
                                    end && ((ndims(var"##830") === 1 && length(var"##830") >= 1) && begin
                                            var"##831" = var"##830"[1]
                                            var"##832" = SubArray(var"##830", (2:length(var"##830"),))
                                            true
                                        end)))
                        args = var"##832"
                        t = var"##831"
                        var"##return#756" = begin
                                with(p.state, :type, true) do 
                                    p(t)
                                    print_braces(args, "{", "}")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##833" = (var"##cache#759").value
                                var"##833" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##833"[1] == :vect && (begin
                                        var"##834" = var"##833"[2]
                                        var"##834" isa AbstractArray
                                    end && ((ndims(var"##834") === 1 && length(var"##834") >= 0) && begin
                                            var"##835" = SubArray(var"##834", (1:length(var"##834"),))
                                            true
                                        end)))
                        args = var"##835"
                        var"##return#756" = begin
                                print_braces(args, "[", "]")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##836" = (var"##cache#759").value
                                var"##836" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##836"[1] == :hcat && (begin
                                        var"##837" = var"##836"[2]
                                        var"##837" isa AbstractArray
                                    end && ((ndims(var"##837") === 1 && length(var"##837") >= 0) && begin
                                            var"##838" = SubArray(var"##837", (1:length(var"##837"),))
                                            true
                                        end)))
                        args = var"##838"
                        var"##return#756" = begin
                                print_braces(args, "[", "]", " ")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##839" = (var"##cache#759").value
                                var"##839" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##839"[1] == :typed_hcat && (begin
                                        var"##840" = var"##839"[2]
                                        var"##840" isa AbstractArray
                                    end && ((ndims(var"##840") === 1 && length(var"##840") >= 1) && begin
                                            var"##841" = var"##840"[1]
                                            var"##842" = SubArray(var"##840", (2:length(var"##840"),))
                                            true
                                        end)))
                        args = var"##842"
                        t = var"##841"
                        var"##return#756" = begin
                                type(t)
                                print_braces(args, "[", "]", " ")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##843" = (var"##cache#759").value
                                var"##843" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##843"[1] == :vcat && (begin
                                        var"##844" = var"##843"[2]
                                        var"##844" isa AbstractArray
                                    end && ((ndims(var"##844") === 1 && length(var"##844") >= 0) && begin
                                            var"##845" = SubArray(var"##844", (1:length(var"##844"),))
                                            true
                                        end)))
                        args = var"##845"
                        var"##return#756" = begin
                                print_braces(args, "[", "]", "; ")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##846" = (var"##cache#759").value
                                var"##846" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##846"[1] == :ncat && (begin
                                        var"##847" = var"##846"[2]
                                        var"##847" isa AbstractArray
                                    end && ((ndims(var"##847") === 1 && length(var"##847") >= 1) && begin
                                            var"##848" = var"##847"[1]
                                            var"##849" = SubArray(var"##847", (2:length(var"##847"),))
                                            true
                                        end)))
                        n = var"##848"
                        args = var"##849"
                        var"##return#756" = begin
                                print_braces(args, "[", "]", ";" ^ n * " ")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##850" = (var"##cache#759").value
                                var"##850" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##850"[1] == :ref && (begin
                                        var"##851" = var"##850"[2]
                                        var"##851" isa AbstractArray
                                    end && ((ndims(var"##851") === 1 && length(var"##851") >= 1) && begin
                                            var"##852" = var"##851"[1]
                                            var"##853" = SubArray(var"##851", (2:length(var"##851"),))
                                            true
                                        end)))
                        args = var"##853"
                        object = var"##852"
                        var"##return#756" = begin
                                p(object)
                                print_braces(args, "[", "]")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##854" = (var"##cache#759").value
                                var"##854" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##854"[1] == :comprehension && (begin
                                        var"##855" = var"##854"[2]
                                        var"##855" isa AbstractArray
                                    end && (length(var"##855") === 1 && (begin
                                                begin
                                                    var"##cache#857" = nothing
                                                end
                                                var"##856" = var"##855"[1]
                                                var"##856" isa Expr
                                            end && (begin
                                                    if var"##cache#857" === nothing
                                                        var"##cache#857" = Some(((var"##856").head, (var"##856").args))
                                                    end
                                                    var"##858" = (var"##cache#857").value
                                                    var"##858" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##858"[1] == :generator && (begin
                                                            var"##859" = var"##858"[2]
                                                            var"##859" isa AbstractArray
                                                        end && (length(var"##859") === 2 && begin
                                                                var"##860" = var"##859"[1]
                                                                var"##861" = var"##859"[2]
                                                                true
                                                            end))))))))
                        iter = var"##860"
                        body = var"##861"
                        var"##return#756" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##862" = (var"##cache#759").value
                                var"##862" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##862"[1] == :typed_comprehension && (begin
                                        var"##863" = var"##862"[2]
                                        var"##863" isa AbstractArray
                                    end && (length(var"##863") === 2 && (begin
                                                var"##864" = var"##863"[1]
                                                begin
                                                    var"##cache#866" = nothing
                                                end
                                                var"##865" = var"##863"[2]
                                                var"##865" isa Expr
                                            end && (begin
                                                    if var"##cache#866" === nothing
                                                        var"##cache#866" = Some(((var"##865").head, (var"##865").args))
                                                    end
                                                    var"##867" = (var"##cache#866").value
                                                    var"##867" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##867"[1] == :generator && (begin
                                                            var"##868" = var"##867"[2]
                                                            var"##868" isa AbstractArray
                                                        end && (length(var"##868") === 2 && begin
                                                                var"##869" = var"##868"[1]
                                                                var"##870" = var"##868"[2]
                                                                true
                                                            end))))))))
                        iter = var"##869"
                        body = var"##870"
                        t = var"##864"
                        var"##return#756" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##871" = (var"##cache#759").value
                                var"##871" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##871"[1] == :-> && (begin
                                        var"##872" = var"##871"[2]
                                        var"##872" isa AbstractArray
                                    end && (length(var"##872") === 2 && (begin
                                                var"##873" = var"##872"[1]
                                                begin
                                                    var"##cache#875" = nothing
                                                end
                                                var"##874" = var"##872"[2]
                                                var"##874" isa Expr
                                            end && (begin
                                                    if var"##cache#875" === nothing
                                                        var"##cache#875" = Some(((var"##874").head, (var"##874").args))
                                                    end
                                                    var"##876" = (var"##cache#875").value
                                                    var"##876" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##876"[1] == :block && (begin
                                                            var"##877" = var"##876"[2]
                                                            var"##877" isa AbstractArray
                                                        end && (length(var"##877") === 2 && begin
                                                                var"##878" = var"##877"[1]
                                                                var"##879" = var"##877"[2]
                                                                true
                                                            end))))))))
                        line = var"##878"
                        code = var"##879"
                        args = var"##873"
                        var"##return#756" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##880" = (var"##cache#759").value
                                var"##880" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##880"[1] == :-> && (begin
                                        var"##881" = var"##880"[2]
                                        var"##881" isa AbstractArray
                                    end && (length(var"##881") === 2 && begin
                                            var"##882" = var"##881"[1]
                                            var"##883" = var"##881"[2]
                                            true
                                        end)))
                        args = var"##882"
                        body = var"##883"
                        var"##return#756" = begin
                                p(args)
                                keyword(" -> ")
                                print("(")
                                noblock(body)
                                print(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##884" = (var"##cache#759").value
                                var"##884" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##884"[1] == :do && (begin
                                        var"##885" = var"##884"[2]
                                        var"##885" isa AbstractArray
                                    end && (length(var"##885") === 2 && (begin
                                                var"##886" = var"##885"[1]
                                                begin
                                                    var"##cache#888" = nothing
                                                end
                                                var"##887" = var"##885"[2]
                                                var"##887" isa Expr
                                            end && (begin
                                                    if var"##cache#888" === nothing
                                                        var"##cache#888" = Some(((var"##887").head, (var"##887").args))
                                                    end
                                                    var"##889" = (var"##cache#888").value
                                                    var"##889" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##889"[1] == :-> && (begin
                                                            var"##890" = var"##889"[2]
                                                            var"##890" isa AbstractArray
                                                        end && (length(var"##890") === 2 && (begin
                                                                    begin
                                                                        var"##cache#892" = nothing
                                                                    end
                                                                    var"##891" = var"##890"[1]
                                                                    var"##891" isa Expr
                                                                end && (begin
                                                                        if var"##cache#892" === nothing
                                                                            var"##cache#892" = Some(((var"##891").head, (var"##891").args))
                                                                        end
                                                                        var"##893" = (var"##cache#892").value
                                                                        var"##893" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                    end && (var"##893"[1] == :tuple && (begin
                                                                                var"##894" = var"##893"[2]
                                                                                var"##894" isa AbstractArray
                                                                            end && ((ndims(var"##894") === 1 && length(var"##894") >= 0) && begin
                                                                                    var"##895" = SubArray(var"##894", (1:length(var"##894"),))
                                                                                    var"##896" = var"##890"[2]
                                                                                    true
                                                                                end)))))))))))))
                        call = var"##886"
                        args = var"##895"
                        body = var"##896"
                        var"##return#756" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##897" = (var"##cache#759").value
                                var"##897" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##897"[1] == :function && (begin
                                        var"##898" = var"##897"[2]
                                        var"##898" isa AbstractArray
                                    end && (length(var"##898") === 2 && begin
                                            var"##899" = var"##898"[1]
                                            var"##900" = var"##898"[2]
                                            true
                                        end)))
                        call = var"##899"
                        body = var"##900"
                        var"##return#756" = begin
                                print_function(:function, call, body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##901" = (var"##cache#759").value
                                var"##901" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##901"[1] == :quote && (begin
                                        var"##902" = var"##901"[2]
                                        var"##902" isa AbstractArray
                                    end && (length(var"##902") === 1 && begin
                                            var"##903" = var"##902"[1]
                                            true
                                        end)))
                        stmt = var"##903"
                        var"##return#756" = begin
                                keyword(":(")
                                noblock(stmt)
                                keyword(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##904" = (var"##cache#759").value
                                var"##904" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##904"[1] == :quote && (begin
                                        var"##905" = var"##904"[2]
                                        var"##905" isa AbstractArray
                                    end && ((ndims(var"##905") === 1 && length(var"##905") >= 0) && begin
                                            var"##906" = SubArray(var"##905", (1:length(var"##905"),))
                                            true
                                        end)))
                        args = var"##906"
                        var"##return#756" = begin
                                keyword("quote ")
                                with(p.state, :block, false) do 
                                    join(args, "; ")
                                end
                                keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##907" = (var"##cache#759").value
                                var"##907" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##907"[1] == :string && (begin
                                        var"##908" = var"##907"[2]
                                        var"##908" isa AbstractArray
                                    end && ((ndims(var"##908") === 1 && length(var"##908") >= 0) && begin
                                            var"##909" = SubArray(var"##908", (1:length(var"##908"),))
                                            true
                                        end)))
                        args = var"##909"
                        var"##return#756" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##910" = (var"##cache#759").value
                                var"##910" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##910"[1] == :block && (begin
                                        var"##911" = var"##910"[2]
                                        var"##911" isa AbstractArray
                                    end && ((ndims(var"##911") === 1 && length(var"##911") >= 0) && begin
                                            var"##912" = SubArray(var"##911", (1:length(var"##911"),))
                                            let args = var"##912"
                                                length(args) == 2 && (is_line_no(args[1]) && is_line_no(args[2]))
                                            end
                                        end)))
                        args = var"##912"
                        var"##return#756" = begin
                                p(args[1])
                                print(" ")
                                p(args[2])
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##913" = (var"##cache#759").value
                                var"##913" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##913"[1] == :block && (begin
                                        var"##914" = var"##913"[2]
                                        var"##914" isa AbstractArray
                                    end && ((ndims(var"##914") === 1 && length(var"##914") >= 0) && begin
                                            var"##915" = SubArray(var"##914", (1:length(var"##914"),))
                                            let args = var"##915"
                                                length(args) == 2 && is_line_no(args[1])
                                            end
                                        end)))
                        args = var"##915"
                        var"##return#756" = begin
                                p(args[1])
                                print(" ")
                                noblock(args[2])
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##916" = (var"##cache#759").value
                                var"##916" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##916"[1] == :block && (begin
                                        var"##917" = var"##916"[2]
                                        var"##917" isa AbstractArray
                                    end && ((ndims(var"##917") === 1 && length(var"##917") >= 0) && begin
                                            var"##918" = SubArray(var"##917", (1:length(var"##917"),))
                                            let args = var"##918"
                                                length(args) == 2 && is_line_no(args[2])
                                            end
                                        end)))
                        args = var"##918"
                        var"##return#756" = begin
                                noblock(args[1])
                                print(" ")
                                p(args[2])
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##919" = (var"##cache#759").value
                                var"##919" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##919"[1] == :block && (begin
                                        var"##920" = var"##919"[2]
                                        var"##920" isa AbstractArray
                                    end && ((ndims(var"##920") === 1 && length(var"##920") >= 0) && begin
                                            var"##921" = SubArray(var"##920", (1:length(var"##920"),))
                                            let args = var"##921"
                                                length(args) == 2
                                            end
                                        end)))
                        args = var"##921"
                        var"##return#756" = begin
                                print("(")
                                noblock(args[1])
                                keyword("; ")
                                noblock(args[2])
                                print(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##922" = (var"##cache#759").value
                                var"##922" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##922"[1] == :block && (begin
                                        var"##923" = var"##922"[2]
                                        var"##923" isa AbstractArray
                                    end && ((ndims(var"##923") === 1 && length(var"##923") >= 0) && begin
                                            var"##924" = SubArray(var"##923", (1:length(var"##923"),))
                                            true
                                        end)))
                        args = var"##924"
                        var"##return#756" = begin
                                p.state.block && keyword("begin ")
                                with(p.state, :block, true) do 
                                    join(args, "; ")
                                end
                                p.state.block && keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##925" = (var"##cache#759").value
                                var"##925" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##925"[1] == :let && (begin
                                        var"##926" = var"##925"[2]
                                        var"##926" isa AbstractArray
                                    end && (length(var"##926") === 2 && (begin
                                                begin
                                                    var"##cache#928" = nothing
                                                end
                                                var"##927" = var"##926"[1]
                                                var"##927" isa Expr
                                            end && (begin
                                                    if var"##cache#928" === nothing
                                                        var"##cache#928" = Some(((var"##927").head, (var"##927").args))
                                                    end
                                                    var"##929" = (var"##cache#928").value
                                                    var"##929" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##929"[1] == :block && (begin
                                                            var"##930" = var"##929"[2]
                                                            var"##930" isa AbstractArray
                                                        end && ((ndims(var"##930") === 1 && length(var"##930") >= 0) && begin
                                                                var"##931" = SubArray(var"##930", (1:length(var"##930"),))
                                                                var"##932" = var"##926"[2]
                                                                true
                                                            end))))))))
                        args = var"##931"
                        body = var"##932"
                        var"##return#756" = begin
                                keyword("let ")
                                join(args, ", ")
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##933" = (var"##cache#759").value
                                var"##933" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##933"[1] == :let && (begin
                                        var"##934" = var"##933"[2]
                                        var"##934" isa AbstractArray
                                    end && (length(var"##934") === 2 && begin
                                            var"##935" = var"##934"[1]
                                            var"##936" = var"##934"[2]
                                            true
                                        end)))
                        arg = var"##935"
                        body = var"##936"
                        var"##return#756" = begin
                                keyword("let ")
                                p(arg)
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##937" = (var"##cache#759").value
                                var"##937" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##937"[1] == :macrocall && (begin
                                        var"##938" = var"##937"[2]
                                        var"##938" isa AbstractArray
                                    end && ((ndims(var"##938") === 1 && length(var"##938") >= 2) && begin
                                            var"##939" = var"##938"[1]
                                            var"##940" = var"##938"[2]
                                            var"##941" = SubArray(var"##938", (3:length(var"##938"),))
                                            true
                                        end)))
                        f = var"##939"
                        line = var"##940"
                        args = var"##941"
                        var"##return#756" = begin
                                p.line && printstyled(line, color = c.comment)
                                macrocall(f)
                                print_braces(args, "(", ")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##942" = (var"##cache#759").value
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
                                                        end && ((ndims(var"##947") === 1 && length(var"##947") >= 1) && (begin
                                                                    begin
                                                                        var"##cache#949" = nothing
                                                                    end
                                                                    var"##948" = var"##947"[1]
                                                                    var"##948" isa Expr
                                                                end && (begin
                                                                        if var"##cache#949" === nothing
                                                                            var"##cache#949" = Some(((var"##948").head, (var"##948").args))
                                                                        end
                                                                        var"##950" = (var"##cache#949").value
                                                                        var"##950" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                    end && (var"##950"[1] == :parameters && (begin
                                                                                var"##951" = var"##950"[2]
                                                                                var"##951" isa AbstractArray
                                                                            end && ((ndims(var"##951") === 1 && length(var"##951") >= 0) && begin
                                                                                    var"##952" = SubArray(var"##951", (1:length(var"##951"),))
                                                                                    var"##953" = SubArray(var"##947", (2:length(var"##947"),))
                                                                                    true
                                                                                end)))))))))))))
                        args = var"##953"
                        kwargs = var"##952"
                        var"##return#756" = begin
                                keyword("return ")
                                p(Expr(:tuple, Expr(:parameters, kwargs...), args...))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##954" = (var"##cache#759").value
                                var"##954" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##954"[1] == :return && (begin
                                        var"##955" = var"##954"[2]
                                        var"##955" isa AbstractArray
                                    end && (length(var"##955") === 1 && (begin
                                                begin
                                                    var"##cache#957" = nothing
                                                end
                                                var"##956" = var"##955"[1]
                                                var"##956" isa Expr
                                            end && (begin
                                                    if var"##cache#957" === nothing
                                                        var"##cache#957" = Some(((var"##956").head, (var"##956").args))
                                                    end
                                                    var"##958" = (var"##cache#957").value
                                                    var"##958" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##958"[1] == :tuple && (begin
                                                            var"##959" = var"##958"[2]
                                                            var"##959" isa AbstractArray
                                                        end && ((ndims(var"##959") === 1 && length(var"##959") >= 0) && begin
                                                                var"##960" = SubArray(var"##959", (1:length(var"##959"),))
                                                                true
                                                            end))))))))
                        args = var"##960"
                        var"##return#756" = begin
                                keyword("return ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##961" = (var"##cache#759").value
                                var"##961" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##961"[1] == :return && (begin
                                        var"##962" = var"##961"[2]
                                        var"##962" isa AbstractArray
                                    end && ((ndims(var"##962") === 1 && length(var"##962") >= 0) && begin
                                            var"##963" = SubArray(var"##962", (1:length(var"##962"),))
                                            true
                                        end)))
                        args = var"##963"
                        var"##return#756" = begin
                                keyword("return ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##964" = (var"##cache#759").value
                                var"##964" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##964"[1] == :module && (begin
                                        var"##965" = var"##964"[2]
                                        var"##965" isa AbstractArray
                                    end && (length(var"##965") === 3 && begin
                                            var"##966" = var"##965"[1]
                                            var"##967" = var"##965"[2]
                                            var"##968" = var"##965"[3]
                                            true
                                        end)))
                        bare = var"##966"
                        name = var"##967"
                        body = var"##968"
                        var"##return#756" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##969" = (var"##cache#759").value
                                var"##969" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##969"[1] == :using && (begin
                                        var"##970" = var"##969"[2]
                                        var"##970" isa AbstractArray
                                    end && ((ndims(var"##970") === 1 && length(var"##970") >= 0) && begin
                                            var"##971" = SubArray(var"##970", (1:length(var"##970"),))
                                            true
                                        end)))
                        args = var"##971"
                        var"##return#756" = begin
                                keyword("using ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##972" = (var"##cache#759").value
                                var"##972" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##972"[1] == :import && (begin
                                        var"##973" = var"##972"[2]
                                        var"##973" isa AbstractArray
                                    end && ((ndims(var"##973") === 1 && length(var"##973") >= 0) && begin
                                            var"##974" = SubArray(var"##973", (1:length(var"##973"),))
                                            true
                                        end)))
                        args = var"##974"
                        var"##return#756" = begin
                                keyword("import ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##975" = (var"##cache#759").value
                                var"##975" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##975"[1] == :as && (begin
                                        var"##976" = var"##975"[2]
                                        var"##976" isa AbstractArray
                                    end && (length(var"##976") === 2 && begin
                                            var"##977" = var"##976"[1]
                                            var"##978" = var"##976"[2]
                                            true
                                        end)))
                        name = var"##977"
                        alias = var"##978"
                        var"##return#756" = begin
                                p(name)
                                keyword(" as ")
                                p(alias)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##979" = (var"##cache#759").value
                                var"##979" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##979"[1] == :export && (begin
                                        var"##980" = var"##979"[2]
                                        var"##980" isa AbstractArray
                                    end && ((ndims(var"##980") === 1 && length(var"##980") >= 0) && begin
                                            var"##981" = SubArray(var"##980", (1:length(var"##980"),))
                                            true
                                        end)))
                        args = var"##981"
                        var"##return#756" = begin
                                keyword("export ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##982" = (var"##cache#759").value
                                var"##982" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##982"[1] == :(:) && (begin
                                        var"##983" = var"##982"[2]
                                        var"##983" isa AbstractArray
                                    end && ((ndims(var"##983") === 1 && length(var"##983") >= 1) && begin
                                            var"##984" = var"##983"[1]
                                            var"##985" = SubArray(var"##983", (2:length(var"##983"),))
                                            true
                                        end)))
                        args = var"##985"
                        head = var"##984"
                        var"##return#756" = begin
                                p(head)
                                keyword(": ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##986" = (var"##cache#759").value
                                var"##986" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##986"[1] == :where && (begin
                                        var"##987" = var"##986"[2]
                                        var"##987" isa AbstractArray
                                    end && ((ndims(var"##987") === 1 && length(var"##987") >= 1) && begin
                                            var"##988" = var"##987"[1]
                                            var"##989" = SubArray(var"##987", (2:length(var"##987"),))
                                            true
                                        end)))
                        body = var"##988"
                        whereparams = var"##989"
                        var"##return#756" = begin
                                p(body)
                                keyword(" where {")
                                with(p.state, :type, true) do 
                                    join(whereparams, ", ")
                                end
                                keyword("}")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##990" = (var"##cache#759").value
                                var"##990" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##990"[1] == :for && (begin
                                        var"##991" = var"##990"[2]
                                        var"##991" isa AbstractArray
                                    end && (length(var"##991") === 2 && begin
                                            var"##992" = var"##991"[1]
                                            var"##993" = var"##991"[2]
                                            true
                                        end)))
                        body = var"##993"
                        iteration = var"##992"
                        var"##return#756" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##994" = (var"##cache#759").value
                                var"##994" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##994"[1] == :while && (begin
                                        var"##995" = var"##994"[2]
                                        var"##995" isa AbstractArray
                                    end && (length(var"##995") === 2 && begin
                                            var"##996" = var"##995"[1]
                                            var"##997" = var"##995"[2]
                                            true
                                        end)))
                        body = var"##997"
                        condition = var"##996"
                        var"##return#756" = begin
                                keyword("while ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##998" = (var"##cache#759").value
                                var"##998" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##998"[1] == :continue && (begin
                                        var"##999" = var"##998"[2]
                                        var"##999" isa AbstractArray
                                    end && isempty(var"##999")))
                        var"##return#756" = begin
                                keyword("continue")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##1000" = (var"##cache#759").value
                                var"##1000" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1000"[1] == :if && (begin
                                        var"##1001" = var"##1000"[2]
                                        var"##1001" isa AbstractArray
                                    end && (length(var"##1001") === 2 && begin
                                            var"##1002" = var"##1001"[1]
                                            var"##1003" = var"##1001"[2]
                                            true
                                        end)))
                        body = var"##1003"
                        condition = var"##1002"
                        var"##return#756" = begin
                                keyword("if ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##1004" = (var"##cache#759").value
                                var"##1004" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1004"[1] == :if && (begin
                                        var"##1005" = var"##1004"[2]
                                        var"##1005" isa AbstractArray
                                    end && (length(var"##1005") === 3 && begin
                                            var"##1006" = var"##1005"[1]
                                            var"##1007" = var"##1005"[2]
                                            var"##1008" = var"##1005"[3]
                                            true
                                        end)))
                        body = var"##1007"
                        elsebody = var"##1008"
                        condition = var"##1006"
                        var"##return#756" = begin
                                keyword("if ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                                keyword("; ")
                                Meta.isexpr(elsebody, :elseif) || keyword("else ")
                                noblock(elsebody)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##1009" = (var"##cache#759").value
                                var"##1009" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1009"[1] == :elseif && (begin
                                        var"##1010" = var"##1009"[2]
                                        var"##1010" isa AbstractArray
                                    end && (length(var"##1010") === 2 && begin
                                            var"##1011" = var"##1010"[1]
                                            var"##1012" = var"##1010"[2]
                                            true
                                        end)))
                        body = var"##1012"
                        condition = var"##1011"
                        var"##return#756" = begin
                                keyword("elseif ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##1013" = (var"##cache#759").value
                                var"##1013" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1013"[1] == :elseif && (begin
                                        var"##1014" = var"##1013"[2]
                                        var"##1014" isa AbstractArray
                                    end && (length(var"##1014") === 3 && begin
                                            var"##1015" = var"##1014"[1]
                                            var"##1016" = var"##1014"[2]
                                            var"##1017" = var"##1014"[3]
                                            true
                                        end)))
                        body = var"##1016"
                        elsebody = var"##1017"
                        condition = var"##1015"
                        var"##return#756" = begin
                                keyword("elseif ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                                keyword("; ")
                                Meta.isexpr(elsebody, :elseif) || keyword("else")
                                noblock(elsebody)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##1018" = (var"##cache#759").value
                                var"##1018" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1018"[1] == :try && (begin
                                        var"##1019" = var"##1018"[2]
                                        var"##1019" isa AbstractArray
                                    end && (length(var"##1019") === 3 && begin
                                            var"##1020" = var"##1019"[1]
                                            var"##1021" = var"##1019"[2]
                                            var"##1022" = var"##1019"[3]
                                            true
                                        end)))
                        catch_vars = var"##1021"
                        catch_body = var"##1022"
                        try_body = var"##1020"
                        var"##return#756" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##1023" = (var"##cache#759").value
                                var"##1023" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1023"[1] == :try && (begin
                                        var"##1024" = var"##1023"[2]
                                        var"##1024" isa AbstractArray
                                    end && (length(var"##1024") === 4 && begin
                                            var"##1025" = var"##1024"[1]
                                            var"##1026" = var"##1024"[2]
                                            var"##1027" = var"##1024"[3]
                                            var"##1028" = var"##1024"[4]
                                            true
                                        end)))
                        catch_vars = var"##1026"
                        catch_body = var"##1027"
                        try_body = var"##1025"
                        finally_body = var"##1028"
                        var"##return#756" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##1029" = (var"##cache#759").value
                                var"##1029" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1029"[1] == :try && (begin
                                        var"##1030" = var"##1029"[2]
                                        var"##1030" isa AbstractArray
                                    end && (length(var"##1030") === 5 && begin
                                            var"##1031" = var"##1030"[1]
                                            var"##1032" = var"##1030"[2]
                                            var"##1033" = var"##1030"[3]
                                            var"##1034" = var"##1030"[4]
                                            var"##1035" = var"##1030"[5]
                                            true
                                        end)))
                        catch_vars = var"##1032"
                        catch_body = var"##1033"
                        try_body = var"##1031"
                        finally_body = var"##1034"
                        else_body = var"##1035"
                        var"##return#756" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##1036" = (var"##cache#759").value
                                var"##1036" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1036"[1] == :struct && (begin
                                        var"##1037" = var"##1036"[2]
                                        var"##1037" isa AbstractArray
                                    end && (length(var"##1037") === 3 && begin
                                            var"##1038" = var"##1037"[1]
                                            var"##1039" = var"##1037"[2]
                                            var"##1040" = var"##1037"[3]
                                            true
                                        end)))
                        ismutable = var"##1038"
                        name = var"##1039"
                        body = var"##1040"
                        var"##return#756" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##1041" = (var"##cache#759").value
                                var"##1041" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1041"[1] == :abstract && (begin
                                        var"##1042" = var"##1041"[2]
                                        var"##1042" isa AbstractArray
                                    end && (length(var"##1042") === 1 && begin
                                            var"##1043" = var"##1042"[1]
                                            true
                                        end)))
                        name = var"##1043"
                        var"##return#756" = begin
                                keyword("abstract type ")
                                p(name)
                                keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##1044" = (var"##cache#759").value
                                var"##1044" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1044"[1] == :primitive && (begin
                                        var"##1045" = var"##1044"[2]
                                        var"##1045" isa AbstractArray
                                    end && (length(var"##1045") === 2 && begin
                                            var"##1046" = var"##1045"[1]
                                            var"##1047" = var"##1045"[2]
                                            true
                                        end)))
                        name = var"##1046"
                        size = var"##1047"
                        var"##return#756" = begin
                                keyword("primitive type ")
                                p(name)
                                print(" ")
                                p(size)
                                keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##1048" = (var"##cache#759").value
                                var"##1048" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1048"[1] == :meta && (begin
                                        var"##1049" = var"##1048"[2]
                                        var"##1049" isa AbstractArray
                                    end && (length(var"##1049") === 1 && var"##1049"[1] == :inline)))
                        var"##return#756" = begin
                                macrocall(GlobalRef(Base, Symbol("@_inline_meta")))
                                keyword(";")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##1050" = (var"##cache#759").value
                                var"##1050" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1050"[1] == :break && (begin
                                        var"##1051" = var"##1050"[2]
                                        var"##1051" isa AbstractArray
                                    end && isempty(var"##1051")))
                        var"##return#756" = begin
                                keyword("break")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##1052" = (var"##cache#759").value
                                var"##1052" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1052"[1] == :symboliclabel && (begin
                                        var"##1053" = var"##1052"[2]
                                        var"##1053" isa AbstractArray
                                    end && (length(var"##1053") === 1 && begin
                                            var"##1054" = var"##1053"[1]
                                            true
                                        end)))
                        label = var"##1054"
                        var"##return#756" = begin
                                macrocall(GlobalRef(Base, Symbol("@label")))
                                print(" ")
                                p(label)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##1055" = (var"##cache#759").value
                                var"##1055" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1055"[1] == :symbolicgoto && (begin
                                        var"##1056" = var"##1055"[2]
                                        var"##1056" isa AbstractArray
                                    end && (length(var"##1056") === 1 && begin
                                            var"##1057" = var"##1056"[1]
                                            true
                                        end)))
                        label = var"##1057"
                        var"##return#756" = begin
                                macrocall(GlobalRef(Base, Symbol("@goto")))
                                print(" ")
                                p(label)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    if begin
                                var"##1058" = (var"##cache#759").value
                                var"##1058" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1059" = var"##1058"[1]
                                    var"##1060" = var"##1058"[2]
                                    var"##1060" isa AbstractArray
                                end && ((ndims(var"##1060") === 1 && length(var"##1060") >= 0) && begin
                                        var"##1061" = SubArray(var"##1060", (1:length(var"##1060"),))
                                        true
                                    end))
                        args = var"##1061"
                        head = var"##1059"
                        var"##return#756" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                end
                if var"##758" isa QuoteNode
                    if ex.value in Base.quoted_syms
                        var"##return#756" = begin
                                keyword(":(")
                                quoted(ex.value)
                                keyword(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                    begin
                        var"##return#756" = begin
                                if ex.value isa Symbol && Base.isidentifier(ex.value)
                                    keyword(":")
                                    quoted(ex.value)
                                else
                                    keyword(":(")
                                    quoted(ex.value)
                                    keyword(")")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                end
                if var"##758" isa Char
                    begin
                        var"##return#756" = begin
                                printstyled(repr(ex), color = c.string)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                end
                if var"##758" isa String
                    begin
                        var"##return#756" = begin
                                string(ex)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                end
                if var"##758" isa LineNumberNode
                    begin
                        var"##return#756" = begin
                                p.line || return nothing
                                printstyled("#= $(ex.file):$(ex.line) =#", color = c.line)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                    end
                end
                begin
                    var"##return#756" = begin
                            print(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#757#1062")))
                end
                error("matching non-exhaustive, at #= none:142 =#")
                $(Expr(:symboliclabel, Symbol("####final#757#1062")))
                var"##return#756"
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
