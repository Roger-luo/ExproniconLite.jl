
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
                        var"##cache#683" = nothing
                    end
                    var"##return#680" = nothing
                    var"##682" = ex
                    if var"##682" isa Expr
                        if begin
                                    if var"##cache#683" === nothing
                                        var"##cache#683" = Some(((var"##682").head, (var"##682").args))
                                    end
                                    var"##684" = (var"##cache#683").value
                                    var"##684" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##684"[1] == :. && (begin
                                            var"##685" = var"##684"[2]
                                            var"##685" isa AbstractArray
                                        end && (ndims(var"##685") === 1 && length(var"##685") >= 0)))
                            var"##return#680" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#681#686")))
                        end
                    end
                    if var"##682" isa Symbol
                        begin
                            var"##return#680" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#681#686")))
                        end
                    end
                    begin
                        var"##return#680" = let
                                false
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#681#686")))
                    end
                    error("matching non-exhaustive, at #= none:85 =#")
                    $(Expr(:symboliclabel, Symbol("####final#681#686")))
                    var"##return#680"
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
                    var"##cache#690" = nothing
                end
                var"##689" = ex
                if var"##689" isa Expr && (begin
                                if var"##cache#690" === nothing
                                    var"##cache#690" = Some(((var"##689").head, (var"##689").args))
                                end
                                var"##691" = (var"##cache#690").value
                                var"##691" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##691"[1] == :call && (begin
                                        var"##692" = var"##691"[2]
                                        var"##692" isa AbstractArray
                                    end && ((ndims(var"##692") === 1 && length(var"##692") >= 1) && (var"##692"[1] == :(:) && begin
                                                var"##693" = SubArray(var"##692", (2:length(var"##692"),))
                                                true
                                            end)))))
                    args = var"##693"
                    var"##return#687" = begin
                            precedence(:(:)) do 
                                join(args, ":")
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#688#715")))
                end
                if var"##689" isa Expr && (begin
                                if var"##cache#690" === nothing
                                    var"##cache#690" = Some(((var"##689").head, (var"##689").args))
                                end
                                var"##694" = (var"##cache#690").value
                                var"##694" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##694"[1] == :call && (begin
                                        var"##695" = var"##694"[2]
                                        var"##695" isa AbstractArray
                                    end && (length(var"##695") === 2 && (begin
                                                var"##696" = var"##695"[1]
                                                var"##696" isa Symbol
                                            end && begin
                                                var"##697" = var"##695"[2]
                                                let f = var"##696", arg = var"##697"
                                                    Base.isunaryoperator(f)
                                                end
                                            end)))))
                    f = var"##696"
                    arg = var"##697"
                    var"##return#687" = begin
                            precedence(typemax(Int)) do 
                                keyword(f)
                                p(arg)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#688#715")))
                end
                if var"##689" isa Expr && (begin
                                if var"##cache#690" === nothing
                                    var"##cache#690" = Some(((var"##689").head, (var"##689").args))
                                end
                                var"##698" = (var"##cache#690").value
                                var"##698" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##698"[1] == :call && (begin
                                        var"##699" = var"##698"[2]
                                        var"##699" isa AbstractArray
                                    end && ((ndims(var"##699") === 1 && length(var"##699") >= 1) && (begin
                                                var"##700" = var"##699"[1]
                                                var"##700" isa Symbol
                                            end && begin
                                                var"##701" = SubArray(var"##699", (2:length(var"##699"),))
                                                let f = var"##700", args = var"##701"
                                                    Base.isbinaryoperator(f)
                                                end
                                            end)))))
                    f = var"##700"
                    args = var"##701"
                    var"##return#687" = begin
                            precedence(f) do 
                                join(args, " $(f) ")
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#688#715")))
                end
                if var"##689" isa Expr && (begin
                                if var"##cache#690" === nothing
                                    var"##cache#690" = Some(((var"##689").head, (var"##689").args))
                                end
                                var"##702" = (var"##cache#690").value
                                var"##702" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##702"[1] == :call && (begin
                                        var"##703" = var"##702"[2]
                                        var"##703" isa AbstractArray
                                    end && ((ndims(var"##703") === 1 && length(var"##703") >= 2) && (begin
                                                var"##704" = var"##703"[1]
                                                begin
                                                    var"##cache#706" = nothing
                                                end
                                                var"##705" = var"##703"[2]
                                                var"##705" isa Expr
                                            end && (begin
                                                    if var"##cache#706" === nothing
                                                        var"##cache#706" = Some(((var"##705").head, (var"##705").args))
                                                    end
                                                    var"##707" = (var"##cache#706").value
                                                    var"##707" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##707"[1] == :parameters && (begin
                                                            var"##708" = var"##707"[2]
                                                            var"##708" isa AbstractArray
                                                        end && ((ndims(var"##708") === 1 && length(var"##708") >= 0) && begin
                                                                var"##709" = SubArray(var"##708", (1:length(var"##708"),))
                                                                var"##710" = SubArray(var"##703", (3:length(var"##703"),))
                                                                true
                                                            end)))))))))
                    f = var"##704"
                    args = var"##710"
                    kwargs = var"##709"
                    var"##return#687" = begin
                            call(f)
                            print("(")
                            join(args)
                            keyword("; ")
                            join(kwargs)
                            print(")")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#688#715")))
                end
                if var"##689" isa Expr && (begin
                                if var"##cache#690" === nothing
                                    var"##cache#690" = Some(((var"##689").head, (var"##689").args))
                                end
                                var"##711" = (var"##cache#690").value
                                var"##711" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##711"[1] == :call && (begin
                                        var"##712" = var"##711"[2]
                                        var"##712" isa AbstractArray
                                    end && ((ndims(var"##712") === 1 && length(var"##712") >= 1) && begin
                                            var"##713" = var"##712"[1]
                                            var"##714" = SubArray(var"##712", (2:length(var"##712"),))
                                            true
                                        end))))
                    f = var"##713"
                    args = var"##714"
                    var"##return#687" = begin
                            call(f)
                            print_braces(args, "(", ")")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#688#715")))
                end
                error("matching non-exhaustive, at #= none:111 =#")
                $(Expr(:symboliclabel, Symbol("####final#688#715")))
                var"##return#687"
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
                    var"##cache#719" = nothing
                end
                var"##718" = ex
                if var"##718" isa GlobalRef
                    begin
                        var"##return#716" = begin
                                p(ex.mod)
                                keyword(".")
                                p(ex.name)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                end
                if var"##718" isa Nothing
                    begin
                        var"##return#716" = begin
                                printstyled("nothing", color = c.number)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                end
                if var"##718" isa Char
                    begin
                        var"##return#716" = begin
                                printstyled(repr(ex), color = c.string)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                end
                if var"##718" isa Symbol
                    begin
                        var"##return#716" = begin
                                symbol(ex)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                end
                if var"##718" isa Expr
                    if begin
                                if var"##cache#719" === nothing
                                    var"##cache#719" = Some(((var"##718").head, (var"##718").args))
                                end
                                var"##720" = (var"##cache#719").value
                                var"##720" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##720"[1] == :line && (begin
                                        var"##721" = var"##720"[2]
                                        var"##721" isa AbstractArray
                                    end && (length(var"##721") === 2 && begin
                                            var"##722" = var"##721"[1]
                                            var"##723" = var"##721"[2]
                                            true
                                        end)))
                        line = var"##723"
                        file = var"##722"
                        var"##return#716" = begin
                                p.line || return nothing
                                printstyled("#= $(file):$(line) =#", color = c.line)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##724" = (var"##cache#719").value
                                var"##724" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##724"[1] == :kw && (begin
                                        var"##725" = var"##724"[2]
                                        var"##725" isa AbstractArray
                                    end && (length(var"##725") === 2 && begin
                                            var"##726" = var"##725"[1]
                                            var"##727" = var"##725"[2]
                                            true
                                        end)))
                        k = var"##726"
                        v = var"##727"
                        var"##return#716" = begin
                                p(k)
                                print(" = ")
                                p(v)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##728" = (var"##cache#719").value
                                var"##728" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##728"[1] == :(=) && (begin
                                        var"##729" = var"##728"[2]
                                        var"##729" isa AbstractArray
                                    end && (length(var"##729") === 2 && (begin
                                                var"##730" = var"##729"[1]
                                                begin
                                                    var"##cache#732" = nothing
                                                end
                                                var"##731" = var"##729"[2]
                                                var"##731" isa Expr
                                            end && (begin
                                                    if var"##cache#732" === nothing
                                                        var"##cache#732" = Some(((var"##731").head, (var"##731").args))
                                                    end
                                                    var"##733" = (var"##cache#732").value
                                                    var"##733" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##733"[1] == :block && (begin
                                                            var"##734" = var"##733"[2]
                                                            var"##734" isa AbstractArray
                                                        end && ((ndims(var"##734") === 1 && length(var"##734") >= 0) && begin
                                                                var"##735" = SubArray(var"##734", (1:length(var"##734"),))
                                                                true
                                                            end))))))))
                        k = var"##730"
                        stmts = var"##735"
                        var"##return#716" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##736" = (var"##cache#719").value
                                var"##736" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##736"[1] == :(=) && (begin
                                        var"##737" = var"##736"[2]
                                        var"##737" isa AbstractArray
                                    end && (length(var"##737") === 2 && begin
                                            var"##738" = var"##737"[1]
                                            var"##739" = var"##737"[2]
                                            true
                                        end)))
                        k = var"##738"
                        v = var"##739"
                        var"##return#716" = begin
                                precedence(:(=)) do 
                                    p(k)
                                    assign()
                                    p(v)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##740" = (var"##cache#719").value
                                var"##740" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##740"[1] == :... && (begin
                                        var"##741" = var"##740"[2]
                                        var"##741" isa AbstractArray
                                    end && (length(var"##741") === 1 && begin
                                            var"##742" = var"##741"[1]
                                            true
                                        end)))
                        name = var"##742"
                        var"##return#716" = begin
                                precedence(:...) do 
                                    p(name)
                                    keyword("...")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##743" = (var"##cache#719").value
                                var"##743" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##743"[1] == :& && (begin
                                        var"##744" = var"##743"[2]
                                        var"##744" isa AbstractArray
                                    end && (length(var"##744") === 1 && begin
                                            var"##745" = var"##744"[1]
                                            true
                                        end)))
                        name = var"##745"
                        var"##return#716" = begin
                                precedence(:&) do 
                                    keyword("&")
                                    p(name)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##746" = (var"##cache#719").value
                                var"##746" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##746"[1] == :(::) && (begin
                                        var"##747" = var"##746"[2]
                                        var"##747" isa AbstractArray
                                    end && (length(var"##747") === 1 && begin
                                            var"##748" = var"##747"[1]
                                            true
                                        end)))
                        t = var"##748"
                        var"##return#716" = begin
                                precedence(:(::)) do 
                                    keyword("::")
                                    type(t)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##749" = (var"##cache#719").value
                                var"##749" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##749"[1] == :(::) && (begin
                                        var"##750" = var"##749"[2]
                                        var"##750" isa AbstractArray
                                    end && (length(var"##750") === 2 && begin
                                            var"##751" = var"##750"[1]
                                            var"##752" = var"##750"[2]
                                            true
                                        end)))
                        name = var"##751"
                        t = var"##752"
                        var"##return#716" = begin
                                precedence(:(::)) do 
                                    p(name)
                                    keyword("::")
                                    type(t)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##753" = (var"##cache#719").value
                                var"##753" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##753"[1] == :$ && (begin
                                        var"##754" = var"##753"[2]
                                        var"##754" isa AbstractArray
                                    end && (length(var"##754") === 1 && begin
                                            var"##755" = var"##754"[1]
                                            true
                                        end)))
                        name = var"##755"
                        var"##return#716" = begin
                                precedence(:$) do 
                                    keyword('$')
                                    print("(")
                                    p(name)
                                    print(")")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##756" = (var"##cache#719").value
                                var"##756" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##757" = var"##756"[1]
                                    var"##758" = var"##756"[2]
                                    var"##758" isa AbstractArray
                                end && (length(var"##758") === 2 && begin
                                        var"##759" = var"##758"[1]
                                        var"##760" = var"##758"[2]
                                        let rhs = var"##760", lhs = var"##759", head = var"##757"
                                            head in expr_infix_wide
                                        end
                                    end))
                        rhs = var"##760"
                        lhs = var"##759"
                        head = var"##757"
                        var"##return#716" = begin
                                precedence(head) do 
                                    p(lhs)
                                    keyword(" $(head) ")
                                    p(rhs)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##761" = (var"##cache#719").value
                                var"##761" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##761"[1] == :. && (begin
                                        var"##762" = var"##761"[2]
                                        var"##762" isa AbstractArray
                                    end && (length(var"##762") === 1 && begin
                                            var"##763" = var"##762"[1]
                                            true
                                        end)))
                        name = var"##763"
                        var"##return#716" = begin
                                print(name)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##764" = (var"##cache#719").value
                                var"##764" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##764"[1] == :. && (begin
                                        var"##765" = var"##764"[2]
                                        var"##765" isa AbstractArray
                                    end && (length(var"##765") === 2 && (begin
                                                var"##766" = var"##765"[1]
                                                var"##767" = var"##765"[2]
                                                var"##767" isa QuoteNode
                                            end && begin
                                                var"##768" = (var"##767").value
                                                true
                                            end))))
                        name = var"##768"
                        object = var"##766"
                        var"##return#716" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##769" = (var"##cache#719").value
                                var"##769" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##769"[1] == :. && (begin
                                        var"##770" = var"##769"[2]
                                        var"##770" isa AbstractArray
                                    end && (length(var"##770") === 2 && begin
                                            var"##771" = var"##770"[1]
                                            var"##772" = var"##770"[2]
                                            true
                                        end)))
                        name = var"##772"
                        object = var"##771"
                        var"##return#716" = begin
                                precedence(:.) do 
                                    p(object)
                                    keyword(".")
                                    p(name)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##773" = (var"##cache#719").value
                                var"##773" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##773"[1] == :<: && (begin
                                        var"##774" = var"##773"[2]
                                        var"##774" isa AbstractArray
                                    end && (length(var"##774") === 2 && begin
                                            var"##775" = var"##774"[1]
                                            var"##776" = var"##774"[2]
                                            true
                                        end)))
                        type = var"##775"
                        supertype = var"##776"
                        var"##return#716" = begin
                                precedence(:<:) do 
                                    p(type)
                                    keyword(" <: ")
                                    p(supertype)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##777" = (var"##cache#719").value
                                var"##777" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##777"[1] == :call && (begin
                                        var"##778" = var"##777"[2]
                                        var"##778" isa AbstractArray
                                    end && (ndims(var"##778") === 1 && length(var"##778") >= 0)))
                        var"##return#716" = begin
                                print_call(ex)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##779" = (var"##cache#719").value
                                var"##779" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##779"[1] == :tuple && (begin
                                        var"##780" = var"##779"[2]
                                        var"##780" isa AbstractArray
                                    end && (length(var"##780") === 1 && (begin
                                                begin
                                                    var"##cache#782" = nothing
                                                end
                                                var"##781" = var"##780"[1]
                                                var"##781" isa Expr
                                            end && (begin
                                                    if var"##cache#782" === nothing
                                                        var"##cache#782" = Some(((var"##781").head, (var"##781").args))
                                                    end
                                                    var"##783" = (var"##cache#782").value
                                                    var"##783" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##783"[1] == :parameters && (begin
                                                            var"##784" = var"##783"[2]
                                                            var"##784" isa AbstractArray
                                                        end && ((ndims(var"##784") === 1 && length(var"##784") >= 0) && begin
                                                                var"##785" = SubArray(var"##784", (1:length(var"##784"),))
                                                                true
                                                            end))))))))
                        args = var"##785"
                        var"##return#716" = begin
                                print_braces(args, "(;", ")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##786" = (var"##cache#719").value
                                var"##786" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##786"[1] == :tuple && (begin
                                        var"##787" = var"##786"[2]
                                        var"##787" isa AbstractArray
                                    end && ((ndims(var"##787") === 1 && length(var"##787") >= 0) && begin
                                            var"##788" = SubArray(var"##787", (1:length(var"##787"),))
                                            true
                                        end)))
                        args = var"##788"
                        var"##return#716" = begin
                                if length(args) == 1
                                    print("(")
                                    p(args[1])
                                    print(",)")
                                else
                                    print_braces(args, "(", ")")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##789" = (var"##cache#719").value
                                var"##789" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##789"[1] == :curly && (begin
                                        var"##790" = var"##789"[2]
                                        var"##790" isa AbstractArray
                                    end && ((ndims(var"##790") === 1 && length(var"##790") >= 1) && begin
                                            var"##791" = var"##790"[1]
                                            var"##792" = SubArray(var"##790", (2:length(var"##790"),))
                                            true
                                        end)))
                        args = var"##792"
                        t = var"##791"
                        var"##return#716" = begin
                                with(p.state, :type, true) do 
                                    p(t)
                                    print_braces(args, "{", "}")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##793" = (var"##cache#719").value
                                var"##793" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##793"[1] == :vect && (begin
                                        var"##794" = var"##793"[2]
                                        var"##794" isa AbstractArray
                                    end && ((ndims(var"##794") === 1 && length(var"##794") >= 0) && begin
                                            var"##795" = SubArray(var"##794", (1:length(var"##794"),))
                                            true
                                        end)))
                        args = var"##795"
                        var"##return#716" = begin
                                print_braces(args, "[", "]")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##796" = (var"##cache#719").value
                                var"##796" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##796"[1] == :hcat && (begin
                                        var"##797" = var"##796"[2]
                                        var"##797" isa AbstractArray
                                    end && ((ndims(var"##797") === 1 && length(var"##797") >= 0) && begin
                                            var"##798" = SubArray(var"##797", (1:length(var"##797"),))
                                            true
                                        end)))
                        args = var"##798"
                        var"##return#716" = begin
                                print_braces(args, "[", "]", " ")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##799" = (var"##cache#719").value
                                var"##799" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##799"[1] == :typed_hcat && (begin
                                        var"##800" = var"##799"[2]
                                        var"##800" isa AbstractArray
                                    end && ((ndims(var"##800") === 1 && length(var"##800") >= 1) && begin
                                            var"##801" = var"##800"[1]
                                            var"##802" = SubArray(var"##800", (2:length(var"##800"),))
                                            true
                                        end)))
                        args = var"##802"
                        t = var"##801"
                        var"##return#716" = begin
                                type(t)
                                print_braces(args, "[", "]", " ")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##803" = (var"##cache#719").value
                                var"##803" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##803"[1] == :vcat && (begin
                                        var"##804" = var"##803"[2]
                                        var"##804" isa AbstractArray
                                    end && ((ndims(var"##804") === 1 && length(var"##804") >= 0) && begin
                                            var"##805" = SubArray(var"##804", (1:length(var"##804"),))
                                            true
                                        end)))
                        args = var"##805"
                        var"##return#716" = begin
                                print_braces(args, "[", "]", "; ")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##806" = (var"##cache#719").value
                                var"##806" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##806"[1] == :ncat && (begin
                                        var"##807" = var"##806"[2]
                                        var"##807" isa AbstractArray
                                    end && ((ndims(var"##807") === 1 && length(var"##807") >= 1) && begin
                                            var"##808" = var"##807"[1]
                                            var"##809" = SubArray(var"##807", (2:length(var"##807"),))
                                            true
                                        end)))
                        n = var"##808"
                        args = var"##809"
                        var"##return#716" = begin
                                print_braces(args, "[", "]", ";" ^ n * " ")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##810" = (var"##cache#719").value
                                var"##810" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##810"[1] == :ref && (begin
                                        var"##811" = var"##810"[2]
                                        var"##811" isa AbstractArray
                                    end && ((ndims(var"##811") === 1 && length(var"##811") >= 1) && begin
                                            var"##812" = var"##811"[1]
                                            var"##813" = SubArray(var"##811", (2:length(var"##811"),))
                                            true
                                        end)))
                        args = var"##813"
                        object = var"##812"
                        var"##return#716" = begin
                                p(object)
                                print_braces(args, "[", "]")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##814" = (var"##cache#719").value
                                var"##814" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##814"[1] == :comprehension && (begin
                                        var"##815" = var"##814"[2]
                                        var"##815" isa AbstractArray
                                    end && (length(var"##815") === 1 && (begin
                                                begin
                                                    var"##cache#817" = nothing
                                                end
                                                var"##816" = var"##815"[1]
                                                var"##816" isa Expr
                                            end && (begin
                                                    if var"##cache#817" === nothing
                                                        var"##cache#817" = Some(((var"##816").head, (var"##816").args))
                                                    end
                                                    var"##818" = (var"##cache#817").value
                                                    var"##818" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##818"[1] == :generator && (begin
                                                            var"##819" = var"##818"[2]
                                                            var"##819" isa AbstractArray
                                                        end && (length(var"##819") === 2 && begin
                                                                var"##820" = var"##819"[1]
                                                                var"##821" = var"##819"[2]
                                                                true
                                                            end))))))))
                        iter = var"##820"
                        body = var"##821"
                        var"##return#716" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##822" = (var"##cache#719").value
                                var"##822" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##822"[1] == :typed_comprehension && (begin
                                        var"##823" = var"##822"[2]
                                        var"##823" isa AbstractArray
                                    end && (length(var"##823") === 2 && (begin
                                                var"##824" = var"##823"[1]
                                                begin
                                                    var"##cache#826" = nothing
                                                end
                                                var"##825" = var"##823"[2]
                                                var"##825" isa Expr
                                            end && (begin
                                                    if var"##cache#826" === nothing
                                                        var"##cache#826" = Some(((var"##825").head, (var"##825").args))
                                                    end
                                                    var"##827" = (var"##cache#826").value
                                                    var"##827" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##827"[1] == :generator && (begin
                                                            var"##828" = var"##827"[2]
                                                            var"##828" isa AbstractArray
                                                        end && (length(var"##828") === 2 && begin
                                                                var"##829" = var"##828"[1]
                                                                var"##830" = var"##828"[2]
                                                                true
                                                            end))))))))
                        iter = var"##829"
                        body = var"##830"
                        t = var"##824"
                        var"##return#716" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##831" = (var"##cache#719").value
                                var"##831" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##831"[1] == :-> && (begin
                                        var"##832" = var"##831"[2]
                                        var"##832" isa AbstractArray
                                    end && (length(var"##832") === 2 && (begin
                                                var"##833" = var"##832"[1]
                                                begin
                                                    var"##cache#835" = nothing
                                                end
                                                var"##834" = var"##832"[2]
                                                var"##834" isa Expr
                                            end && (begin
                                                    if var"##cache#835" === nothing
                                                        var"##cache#835" = Some(((var"##834").head, (var"##834").args))
                                                    end
                                                    var"##836" = (var"##cache#835").value
                                                    var"##836" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##836"[1] == :block && (begin
                                                            var"##837" = var"##836"[2]
                                                            var"##837" isa AbstractArray
                                                        end && (length(var"##837") === 2 && begin
                                                                var"##838" = var"##837"[1]
                                                                var"##839" = var"##837"[2]
                                                                true
                                                            end))))))))
                        line = var"##838"
                        code = var"##839"
                        args = var"##833"
                        var"##return#716" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##840" = (var"##cache#719").value
                                var"##840" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##840"[1] == :-> && (begin
                                        var"##841" = var"##840"[2]
                                        var"##841" isa AbstractArray
                                    end && (length(var"##841") === 2 && begin
                                            var"##842" = var"##841"[1]
                                            var"##843" = var"##841"[2]
                                            true
                                        end)))
                        args = var"##842"
                        body = var"##843"
                        var"##return#716" = begin
                                p(args)
                                keyword(" -> ")
                                print("(")
                                noblock(body)
                                print(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##844" = (var"##cache#719").value
                                var"##844" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##844"[1] == :do && (begin
                                        var"##845" = var"##844"[2]
                                        var"##845" isa AbstractArray
                                    end && (length(var"##845") === 2 && (begin
                                                var"##846" = var"##845"[1]
                                                begin
                                                    var"##cache#848" = nothing
                                                end
                                                var"##847" = var"##845"[2]
                                                var"##847" isa Expr
                                            end && (begin
                                                    if var"##cache#848" === nothing
                                                        var"##cache#848" = Some(((var"##847").head, (var"##847").args))
                                                    end
                                                    var"##849" = (var"##cache#848").value
                                                    var"##849" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##849"[1] == :-> && (begin
                                                            var"##850" = var"##849"[2]
                                                            var"##850" isa AbstractArray
                                                        end && (length(var"##850") === 2 && (begin
                                                                    begin
                                                                        var"##cache#852" = nothing
                                                                    end
                                                                    var"##851" = var"##850"[1]
                                                                    var"##851" isa Expr
                                                                end && (begin
                                                                        if var"##cache#852" === nothing
                                                                            var"##cache#852" = Some(((var"##851").head, (var"##851").args))
                                                                        end
                                                                        var"##853" = (var"##cache#852").value
                                                                        var"##853" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                    end && (var"##853"[1] == :tuple && (begin
                                                                                var"##854" = var"##853"[2]
                                                                                var"##854" isa AbstractArray
                                                                            end && ((ndims(var"##854") === 1 && length(var"##854") >= 0) && begin
                                                                                    var"##855" = SubArray(var"##854", (1:length(var"##854"),))
                                                                                    var"##856" = var"##850"[2]
                                                                                    true
                                                                                end)))))))))))))
                        call = var"##846"
                        args = var"##855"
                        body = var"##856"
                        var"##return#716" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##857" = (var"##cache#719").value
                                var"##857" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##857"[1] == :function && (begin
                                        var"##858" = var"##857"[2]
                                        var"##858" isa AbstractArray
                                    end && (length(var"##858") === 2 && begin
                                            var"##859" = var"##858"[1]
                                            var"##860" = var"##858"[2]
                                            true
                                        end)))
                        call = var"##859"
                        body = var"##860"
                        var"##return#716" = begin
                                print_function(:function, call, body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##861" = (var"##cache#719").value
                                var"##861" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##861"[1] == :quote && (begin
                                        var"##862" = var"##861"[2]
                                        var"##862" isa AbstractArray
                                    end && (length(var"##862") === 1 && begin
                                            var"##863" = var"##862"[1]
                                            true
                                        end)))
                        stmt = var"##863"
                        var"##return#716" = begin
                                keyword(":(")
                                noblock(stmt)
                                keyword(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##864" = (var"##cache#719").value
                                var"##864" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##864"[1] == :quote && (begin
                                        var"##865" = var"##864"[2]
                                        var"##865" isa AbstractArray
                                    end && ((ndims(var"##865") === 1 && length(var"##865") >= 0) && begin
                                            var"##866" = SubArray(var"##865", (1:length(var"##865"),))
                                            true
                                        end)))
                        args = var"##866"
                        var"##return#716" = begin
                                keyword("quote ")
                                with(p.state, :block, false) do 
                                    join(args, "; ")
                                end
                                keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##867" = (var"##cache#719").value
                                var"##867" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##867"[1] == :string && (begin
                                        var"##868" = var"##867"[2]
                                        var"##868" isa AbstractArray
                                    end && ((ndims(var"##868") === 1 && length(var"##868") >= 0) && begin
                                            var"##869" = SubArray(var"##868", (1:length(var"##868"),))
                                            true
                                        end)))
                        args = var"##869"
                        var"##return#716" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##870" = (var"##cache#719").value
                                var"##870" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##870"[1] == :block && (begin
                                        var"##871" = var"##870"[2]
                                        var"##871" isa AbstractArray
                                    end && ((ndims(var"##871") === 1 && length(var"##871") >= 0) && begin
                                            var"##872" = SubArray(var"##871", (1:length(var"##871"),))
                                            let args = var"##872"
                                                length(args) == 2 && (is_line_no(args[1]) && is_line_no(args[2]))
                                            end
                                        end)))
                        args = var"##872"
                        var"##return#716" = begin
                                p(args[1])
                                print(" ")
                                p(args[2])
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##873" = (var"##cache#719").value
                                var"##873" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##873"[1] == :block && (begin
                                        var"##874" = var"##873"[2]
                                        var"##874" isa AbstractArray
                                    end && ((ndims(var"##874") === 1 && length(var"##874") >= 0) && begin
                                            var"##875" = SubArray(var"##874", (1:length(var"##874"),))
                                            let args = var"##875"
                                                length(args) == 2 && is_line_no(args[1])
                                            end
                                        end)))
                        args = var"##875"
                        var"##return#716" = begin
                                p(args[1])
                                print(" ")
                                noblock(args[2])
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##876" = (var"##cache#719").value
                                var"##876" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##876"[1] == :block && (begin
                                        var"##877" = var"##876"[2]
                                        var"##877" isa AbstractArray
                                    end && ((ndims(var"##877") === 1 && length(var"##877") >= 0) && begin
                                            var"##878" = SubArray(var"##877", (1:length(var"##877"),))
                                            let args = var"##878"
                                                length(args) == 2 && is_line_no(args[2])
                                            end
                                        end)))
                        args = var"##878"
                        var"##return#716" = begin
                                noblock(args[1])
                                print(" ")
                                p(args[2])
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##879" = (var"##cache#719").value
                                var"##879" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##879"[1] == :block && (begin
                                        var"##880" = var"##879"[2]
                                        var"##880" isa AbstractArray
                                    end && ((ndims(var"##880") === 1 && length(var"##880") >= 0) && begin
                                            var"##881" = SubArray(var"##880", (1:length(var"##880"),))
                                            let args = var"##881"
                                                length(args) == 2
                                            end
                                        end)))
                        args = var"##881"
                        var"##return#716" = begin
                                print("(")
                                noblock(args[1])
                                keyword("; ")
                                noblock(args[2])
                                print(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##882" = (var"##cache#719").value
                                var"##882" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##882"[1] == :block && (begin
                                        var"##883" = var"##882"[2]
                                        var"##883" isa AbstractArray
                                    end && ((ndims(var"##883") === 1 && length(var"##883") >= 0) && begin
                                            var"##884" = SubArray(var"##883", (1:length(var"##883"),))
                                            true
                                        end)))
                        args = var"##884"
                        var"##return#716" = begin
                                p.state.block && keyword("begin ")
                                with(p.state, :block, true) do 
                                    join(args, "; ")
                                end
                                p.state.block && keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##885" = (var"##cache#719").value
                                var"##885" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##885"[1] == :let && (begin
                                        var"##886" = var"##885"[2]
                                        var"##886" isa AbstractArray
                                    end && (length(var"##886") === 2 && (begin
                                                begin
                                                    var"##cache#888" = nothing
                                                end
                                                var"##887" = var"##886"[1]
                                                var"##887" isa Expr
                                            end && (begin
                                                    if var"##cache#888" === nothing
                                                        var"##cache#888" = Some(((var"##887").head, (var"##887").args))
                                                    end
                                                    var"##889" = (var"##cache#888").value
                                                    var"##889" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##889"[1] == :block && (begin
                                                            var"##890" = var"##889"[2]
                                                            var"##890" isa AbstractArray
                                                        end && ((ndims(var"##890") === 1 && length(var"##890") >= 0) && begin
                                                                var"##891" = SubArray(var"##890", (1:length(var"##890"),))
                                                                var"##892" = var"##886"[2]
                                                                true
                                                            end))))))))
                        args = var"##891"
                        body = var"##892"
                        var"##return#716" = begin
                                keyword("let ")
                                join(args, ", ")
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##893" = (var"##cache#719").value
                                var"##893" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##893"[1] == :let && (begin
                                        var"##894" = var"##893"[2]
                                        var"##894" isa AbstractArray
                                    end && (length(var"##894") === 2 && begin
                                            var"##895" = var"##894"[1]
                                            var"##896" = var"##894"[2]
                                            true
                                        end)))
                        arg = var"##895"
                        body = var"##896"
                        var"##return#716" = begin
                                keyword("let ")
                                p(arg)
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##897" = (var"##cache#719").value
                                var"##897" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##897"[1] == :macrocall && (begin
                                        var"##898" = var"##897"[2]
                                        var"##898" isa AbstractArray
                                    end && ((ndims(var"##898") === 1 && length(var"##898") >= 2) && begin
                                            var"##899" = var"##898"[1]
                                            var"##900" = var"##898"[2]
                                            var"##901" = SubArray(var"##898", (3:length(var"##898"),))
                                            true
                                        end)))
                        f = var"##899"
                        line = var"##900"
                        args = var"##901"
                        var"##return#716" = begin
                                p.line && printstyled(line, color = c.comment)
                                macrocall(f)
                                print_braces(args, "(", ")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##902" = (var"##cache#719").value
                                var"##902" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##902"[1] == :return && (begin
                                        var"##903" = var"##902"[2]
                                        var"##903" isa AbstractArray
                                    end && (length(var"##903") === 1 && (begin
                                                begin
                                                    var"##cache#905" = nothing
                                                end
                                                var"##904" = var"##903"[1]
                                                var"##904" isa Expr
                                            end && (begin
                                                    if var"##cache#905" === nothing
                                                        var"##cache#905" = Some(((var"##904").head, (var"##904").args))
                                                    end
                                                    var"##906" = (var"##cache#905").value
                                                    var"##906" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##906"[1] == :tuple && (begin
                                                            var"##907" = var"##906"[2]
                                                            var"##907" isa AbstractArray
                                                        end && ((ndims(var"##907") === 1 && length(var"##907") >= 1) && (begin
                                                                    begin
                                                                        var"##cache#909" = nothing
                                                                    end
                                                                    var"##908" = var"##907"[1]
                                                                    var"##908" isa Expr
                                                                end && (begin
                                                                        if var"##cache#909" === nothing
                                                                            var"##cache#909" = Some(((var"##908").head, (var"##908").args))
                                                                        end
                                                                        var"##910" = (var"##cache#909").value
                                                                        var"##910" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                    end && (var"##910"[1] == :parameters && (begin
                                                                                var"##911" = var"##910"[2]
                                                                                var"##911" isa AbstractArray
                                                                            end && ((ndims(var"##911") === 1 && length(var"##911") >= 0) && begin
                                                                                    var"##912" = SubArray(var"##911", (1:length(var"##911"),))
                                                                                    var"##913" = SubArray(var"##907", (2:length(var"##907"),))
                                                                                    true
                                                                                end)))))))))))))
                        args = var"##913"
                        kwargs = var"##912"
                        var"##return#716" = begin
                                keyword("return ")
                                p(Expr(:tuple, Expr(:parameters, kwargs...), args...))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##914" = (var"##cache#719").value
                                var"##914" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##914"[1] == :return && (begin
                                        var"##915" = var"##914"[2]
                                        var"##915" isa AbstractArray
                                    end && (length(var"##915") === 1 && (begin
                                                begin
                                                    var"##cache#917" = nothing
                                                end
                                                var"##916" = var"##915"[1]
                                                var"##916" isa Expr
                                            end && (begin
                                                    if var"##cache#917" === nothing
                                                        var"##cache#917" = Some(((var"##916").head, (var"##916").args))
                                                    end
                                                    var"##918" = (var"##cache#917").value
                                                    var"##918" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##918"[1] == :tuple && (begin
                                                            var"##919" = var"##918"[2]
                                                            var"##919" isa AbstractArray
                                                        end && ((ndims(var"##919") === 1 && length(var"##919") >= 0) && begin
                                                                var"##920" = SubArray(var"##919", (1:length(var"##919"),))
                                                                true
                                                            end))))))))
                        args = var"##920"
                        var"##return#716" = begin
                                keyword("return ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##921" = (var"##cache#719").value
                                var"##921" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##921"[1] == :return && (begin
                                        var"##922" = var"##921"[2]
                                        var"##922" isa AbstractArray
                                    end && ((ndims(var"##922") === 1 && length(var"##922") >= 0) && begin
                                            var"##923" = SubArray(var"##922", (1:length(var"##922"),))
                                            true
                                        end)))
                        args = var"##923"
                        var"##return#716" = begin
                                keyword("return ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##924" = (var"##cache#719").value
                                var"##924" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##924"[1] == :module && (begin
                                        var"##925" = var"##924"[2]
                                        var"##925" isa AbstractArray
                                    end && (length(var"##925") === 3 && begin
                                            var"##926" = var"##925"[1]
                                            var"##927" = var"##925"[2]
                                            var"##928" = var"##925"[3]
                                            true
                                        end)))
                        bare = var"##926"
                        name = var"##927"
                        body = var"##928"
                        var"##return#716" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##929" = (var"##cache#719").value
                                var"##929" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##929"[1] == :using && (begin
                                        var"##930" = var"##929"[2]
                                        var"##930" isa AbstractArray
                                    end && ((ndims(var"##930") === 1 && length(var"##930") >= 0) && begin
                                            var"##931" = SubArray(var"##930", (1:length(var"##930"),))
                                            true
                                        end)))
                        args = var"##931"
                        var"##return#716" = begin
                                keyword("using ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##932" = (var"##cache#719").value
                                var"##932" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##932"[1] == :import && (begin
                                        var"##933" = var"##932"[2]
                                        var"##933" isa AbstractArray
                                    end && ((ndims(var"##933") === 1 && length(var"##933") >= 0) && begin
                                            var"##934" = SubArray(var"##933", (1:length(var"##933"),))
                                            true
                                        end)))
                        args = var"##934"
                        var"##return#716" = begin
                                keyword("import ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##935" = (var"##cache#719").value
                                var"##935" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##935"[1] == :as && (begin
                                        var"##936" = var"##935"[2]
                                        var"##936" isa AbstractArray
                                    end && (length(var"##936") === 2 && begin
                                            var"##937" = var"##936"[1]
                                            var"##938" = var"##936"[2]
                                            true
                                        end)))
                        name = var"##937"
                        alias = var"##938"
                        var"##return#716" = begin
                                p(name)
                                keyword(" as ")
                                p(alias)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##939" = (var"##cache#719").value
                                var"##939" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##939"[1] == :export && (begin
                                        var"##940" = var"##939"[2]
                                        var"##940" isa AbstractArray
                                    end && ((ndims(var"##940") === 1 && length(var"##940") >= 0) && begin
                                            var"##941" = SubArray(var"##940", (1:length(var"##940"),))
                                            true
                                        end)))
                        args = var"##941"
                        var"##return#716" = begin
                                keyword("export ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##942" = (var"##cache#719").value
                                var"##942" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##942"[1] == :(:) && (begin
                                        var"##943" = var"##942"[2]
                                        var"##943" isa AbstractArray
                                    end && ((ndims(var"##943") === 1 && length(var"##943") >= 1) && begin
                                            var"##944" = var"##943"[1]
                                            var"##945" = SubArray(var"##943", (2:length(var"##943"),))
                                            true
                                        end)))
                        args = var"##945"
                        head = var"##944"
                        var"##return#716" = begin
                                p(head)
                                keyword(": ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##946" = (var"##cache#719").value
                                var"##946" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##946"[1] == :where && (begin
                                        var"##947" = var"##946"[2]
                                        var"##947" isa AbstractArray
                                    end && ((ndims(var"##947") === 1 && length(var"##947") >= 1) && begin
                                            var"##948" = var"##947"[1]
                                            var"##949" = SubArray(var"##947", (2:length(var"##947"),))
                                            true
                                        end)))
                        body = var"##948"
                        whereparams = var"##949"
                        var"##return#716" = begin
                                p(body)
                                keyword(" where {")
                                with(p.state, :type, true) do 
                                    join(whereparams, ", ")
                                end
                                keyword("}")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##950" = (var"##cache#719").value
                                var"##950" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##950"[1] == :for && (begin
                                        var"##951" = var"##950"[2]
                                        var"##951" isa AbstractArray
                                    end && (length(var"##951") === 2 && begin
                                            var"##952" = var"##951"[1]
                                            var"##953" = var"##951"[2]
                                            true
                                        end)))
                        body = var"##953"
                        iteration = var"##952"
                        var"##return#716" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##954" = (var"##cache#719").value
                                var"##954" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##954"[1] == :while && (begin
                                        var"##955" = var"##954"[2]
                                        var"##955" isa AbstractArray
                                    end && (length(var"##955") === 2 && begin
                                            var"##956" = var"##955"[1]
                                            var"##957" = var"##955"[2]
                                            true
                                        end)))
                        body = var"##957"
                        condition = var"##956"
                        var"##return#716" = begin
                                keyword("while ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##958" = (var"##cache#719").value
                                var"##958" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##958"[1] == :continue && (begin
                                        var"##959" = var"##958"[2]
                                        var"##959" isa AbstractArray
                                    end && isempty(var"##959")))
                        var"##return#716" = begin
                                keyword("continue")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##960" = (var"##cache#719").value
                                var"##960" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##960"[1] == :if && (begin
                                        var"##961" = var"##960"[2]
                                        var"##961" isa AbstractArray
                                    end && (length(var"##961") === 2 && begin
                                            var"##962" = var"##961"[1]
                                            var"##963" = var"##961"[2]
                                            true
                                        end)))
                        body = var"##963"
                        condition = var"##962"
                        var"##return#716" = begin
                                keyword("if ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##964" = (var"##cache#719").value
                                var"##964" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##964"[1] == :if && (begin
                                        var"##965" = var"##964"[2]
                                        var"##965" isa AbstractArray
                                    end && (length(var"##965") === 3 && begin
                                            var"##966" = var"##965"[1]
                                            var"##967" = var"##965"[2]
                                            var"##968" = var"##965"[3]
                                            true
                                        end)))
                        body = var"##967"
                        elsebody = var"##968"
                        condition = var"##966"
                        var"##return#716" = begin
                                keyword("if ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                                keyword("; ")
                                Meta.isexpr(elsebody, :elseif) || keyword("else ")
                                noblock(elsebody)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##969" = (var"##cache#719").value
                                var"##969" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##969"[1] == :elseif && (begin
                                        var"##970" = var"##969"[2]
                                        var"##970" isa AbstractArray
                                    end && (length(var"##970") === 2 && begin
                                            var"##971" = var"##970"[1]
                                            var"##972" = var"##970"[2]
                                            true
                                        end)))
                        body = var"##972"
                        condition = var"##971"
                        var"##return#716" = begin
                                keyword("elseif ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##973" = (var"##cache#719").value
                                var"##973" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##973"[1] == :elseif && (begin
                                        var"##974" = var"##973"[2]
                                        var"##974" isa AbstractArray
                                    end && (length(var"##974") === 3 && begin
                                            var"##975" = var"##974"[1]
                                            var"##976" = var"##974"[2]
                                            var"##977" = var"##974"[3]
                                            true
                                        end)))
                        body = var"##976"
                        elsebody = var"##977"
                        condition = var"##975"
                        var"##return#716" = begin
                                keyword("elseif ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                                keyword("; ")
                                Meta.isexpr(elsebody, :elseif) || keyword("else")
                                noblock(elsebody)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##978" = (var"##cache#719").value
                                var"##978" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##978"[1] == :try && (begin
                                        var"##979" = var"##978"[2]
                                        var"##979" isa AbstractArray
                                    end && (length(var"##979") === 3 && begin
                                            var"##980" = var"##979"[1]
                                            var"##981" = var"##979"[2]
                                            var"##982" = var"##979"[3]
                                            true
                                        end)))
                        catch_vars = var"##981"
                        catch_body = var"##982"
                        try_body = var"##980"
                        var"##return#716" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##983" = (var"##cache#719").value
                                var"##983" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##983"[1] == :try && (begin
                                        var"##984" = var"##983"[2]
                                        var"##984" isa AbstractArray
                                    end && (length(var"##984") === 4 && begin
                                            var"##985" = var"##984"[1]
                                            var"##986" = var"##984"[2]
                                            var"##987" = var"##984"[3]
                                            var"##988" = var"##984"[4]
                                            true
                                        end)))
                        catch_vars = var"##986"
                        catch_body = var"##987"
                        try_body = var"##985"
                        finally_body = var"##988"
                        var"##return#716" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##989" = (var"##cache#719").value
                                var"##989" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##989"[1] == :try && (begin
                                        var"##990" = var"##989"[2]
                                        var"##990" isa AbstractArray
                                    end && (length(var"##990") === 5 && begin
                                            var"##991" = var"##990"[1]
                                            var"##992" = var"##990"[2]
                                            var"##993" = var"##990"[3]
                                            var"##994" = var"##990"[4]
                                            var"##995" = var"##990"[5]
                                            true
                                        end)))
                        catch_vars = var"##992"
                        catch_body = var"##993"
                        try_body = var"##991"
                        finally_body = var"##994"
                        else_body = var"##995"
                        var"##return#716" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##996" = (var"##cache#719").value
                                var"##996" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##996"[1] == :struct && (begin
                                        var"##997" = var"##996"[2]
                                        var"##997" isa AbstractArray
                                    end && (length(var"##997") === 3 && begin
                                            var"##998" = var"##997"[1]
                                            var"##999" = var"##997"[2]
                                            var"##1000" = var"##997"[3]
                                            true
                                        end)))
                        ismutable = var"##998"
                        name = var"##999"
                        body = var"##1000"
                        var"##return#716" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##1001" = (var"##cache#719").value
                                var"##1001" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1001"[1] == :abstract && (begin
                                        var"##1002" = var"##1001"[2]
                                        var"##1002" isa AbstractArray
                                    end && (length(var"##1002") === 1 && begin
                                            var"##1003" = var"##1002"[1]
                                            true
                                        end)))
                        name = var"##1003"
                        var"##return#716" = begin
                                keyword("abstract type ")
                                p(name)
                                keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##1004" = (var"##cache#719").value
                                var"##1004" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1004"[1] == :primitive && (begin
                                        var"##1005" = var"##1004"[2]
                                        var"##1005" isa AbstractArray
                                    end && (length(var"##1005") === 2 && begin
                                            var"##1006" = var"##1005"[1]
                                            var"##1007" = var"##1005"[2]
                                            true
                                        end)))
                        name = var"##1006"
                        size = var"##1007"
                        var"##return#716" = begin
                                keyword("primitive type ")
                                p(name)
                                print(" ")
                                p(size)
                                keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##1008" = (var"##cache#719").value
                                var"##1008" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1008"[1] == :meta && (begin
                                        var"##1009" = var"##1008"[2]
                                        var"##1009" isa AbstractArray
                                    end && (length(var"##1009") === 1 && var"##1009"[1] == :inline)))
                        var"##return#716" = begin
                                macrocall(GlobalRef(Base, Symbol("@_inline_meta")))
                                keyword(";")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##1010" = (var"##cache#719").value
                                var"##1010" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1010"[1] == :break && (begin
                                        var"##1011" = var"##1010"[2]
                                        var"##1011" isa AbstractArray
                                    end && isempty(var"##1011")))
                        var"##return#716" = begin
                                keyword("break")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##1012" = (var"##cache#719").value
                                var"##1012" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1012"[1] == :symboliclabel && (begin
                                        var"##1013" = var"##1012"[2]
                                        var"##1013" isa AbstractArray
                                    end && (length(var"##1013") === 1 && begin
                                            var"##1014" = var"##1013"[1]
                                            true
                                        end)))
                        label = var"##1014"
                        var"##return#716" = begin
                                macrocall(GlobalRef(Base, Symbol("@label")))
                                print(" ")
                                p(label)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##1015" = (var"##cache#719").value
                                var"##1015" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1015"[1] == :symbolicgoto && (begin
                                        var"##1016" = var"##1015"[2]
                                        var"##1016" isa AbstractArray
                                    end && (length(var"##1016") === 1 && begin
                                            var"##1017" = var"##1016"[1]
                                            true
                                        end)))
                        label = var"##1017"
                        var"##return#716" = begin
                                macrocall(GlobalRef(Base, Symbol("@goto")))
                                print(" ")
                                p(label)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    if begin
                                var"##1018" = (var"##cache#719").value
                                var"##1018" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1019" = var"##1018"[1]
                                    var"##1020" = var"##1018"[2]
                                    var"##1020" isa AbstractArray
                                end && ((ndims(var"##1020") === 1 && length(var"##1020") >= 0) && begin
                                        var"##1021" = SubArray(var"##1020", (1:length(var"##1020"),))
                                        true
                                    end))
                        args = var"##1021"
                        head = var"##1019"
                        var"##return#716" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                end
                if var"##718" isa Number
                    begin
                        var"##return#716" = begin
                                printstyled(ex, color = c.number)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                end
                if var"##718" isa String
                    begin
                        var"##return#716" = begin
                                string(ex)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                end
                if var"##718" isa QuoteNode
                    if ex.value in Base.quoted_syms
                        var"##return#716" = begin
                                keyword(":(")
                                quoted(ex.value)
                                keyword(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                    begin
                        var"##return#716" = begin
                                if ex.value isa Symbol && Base.isidentifier(ex.value)
                                    keyword(":")
                                    quoted(ex.value)
                                else
                                    keyword(":(")
                                    quoted(ex.value)
                                    keyword(")")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                end
                if var"##718" isa LineNumberNode
                    begin
                        var"##return#716" = begin
                                p.line || return nothing
                                printstyled("#= $(ex.file):$(ex.line) =#", color = c.line)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                    end
                end
                begin
                    var"##return#716" = begin
                            print(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#717#1022")))
                end
                error("matching non-exhaustive, at #= none:142 =#")
                $(Expr(:symboliclabel, Symbol("####final#717#1022")))
                var"##return#716"
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
