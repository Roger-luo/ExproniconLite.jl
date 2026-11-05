
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
                        var"##cache#700" = nothing
                    end
                    var"##return#697" = nothing
                    var"##699" = ex
                    if var"##699" isa Expr
                        if begin
                                    if var"##cache#700" === nothing
                                        var"##cache#700" = Some(((var"##699").head, (var"##699").args))
                                    end
                                    var"##701" = (var"##cache#700").value
                                    var"##701" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##701"[1] == :. && (begin
                                            var"##702" = var"##701"[2]
                                            var"##702" isa AbstractArray
                                        end && (ndims(var"##702") === 1 && length(var"##702") >= 0)))
                            var"##return#697" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#698#703")))
                        end
                    end
                    if var"##699" isa Symbol
                        begin
                            var"##return#697" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#698#703")))
                        end
                    end
                    begin
                        var"##return#697" = let
                                false
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#698#703")))
                    end
                    error("matching non-exhaustive, at #= none:85 =#")
                    $(Expr(:symboliclabel, Symbol("####final#698#703")))
                    var"##return#697"
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
                    var"##cache#707" = nothing
                end
                var"##706" = ex
                if var"##706" isa Expr && (begin
                                if var"##cache#707" === nothing
                                    var"##cache#707" = Some(((var"##706").head, (var"##706").args))
                                end
                                var"##708" = (var"##cache#707").value
                                var"##708" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##708"[1] == :call && (begin
                                        var"##709" = var"##708"[2]
                                        var"##709" isa AbstractArray
                                    end && ((ndims(var"##709") === 1 && length(var"##709") >= 1) && (var"##709"[1] == :(:) && begin
                                                var"##710" = SubArray(var"##709", (2:length(var"##709"),))
                                                true
                                            end)))))
                    args = var"##710"
                    var"##return#704" = begin
                            precedence(:(:)) do
                                join(args, ":")
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#705#732")))
                end
                if var"##706" isa Expr && (begin
                                if var"##cache#707" === nothing
                                    var"##cache#707" = Some(((var"##706").head, (var"##706").args))
                                end
                                var"##711" = (var"##cache#707").value
                                var"##711" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##711"[1] == :call && (begin
                                        var"##712" = var"##711"[2]
                                        var"##712" isa AbstractArray
                                    end && (length(var"##712") === 2 && (begin
                                                var"##713" = var"##712"[1]
                                                var"##713" isa Symbol
                                            end && begin
                                                var"##714" = var"##712"[2]
                                                let f = var"##713", arg = var"##714"
                                                    Base.isunaryoperator(f)
                                                end
                                            end)))))
                    f = var"##713"
                    arg = var"##714"
                    var"##return#704" = begin
                            precedence(typemax(Int)) do
                                keyword(f)
                                p(arg)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#705#732")))
                end
                if var"##706" isa Expr && (begin
                                if var"##cache#707" === nothing
                                    var"##cache#707" = Some(((var"##706").head, (var"##706").args))
                                end
                                var"##715" = (var"##cache#707").value
                                var"##715" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##715"[1] == :call && (begin
                                        var"##716" = var"##715"[2]
                                        var"##716" isa AbstractArray
                                    end && ((ndims(var"##716") === 1 && length(var"##716") >= 1) && (begin
                                                var"##717" = var"##716"[1]
                                                var"##717" isa Symbol
                                            end && begin
                                                var"##718" = SubArray(var"##716", (2:length(var"##716"),))
                                                let f = var"##717", args = var"##718"
                                                    Base.isbinaryoperator(f)
                                                end
                                            end)))))
                    f = var"##717"
                    args = var"##718"
                    var"##return#704" = begin
                            precedence(f) do
                                join(args, " $(f) ")
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#705#732")))
                end
                if var"##706" isa Expr && (begin
                                if var"##cache#707" === nothing
                                    var"##cache#707" = Some(((var"##706").head, (var"##706").args))
                                end
                                var"##719" = (var"##cache#707").value
                                var"##719" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##719"[1] == :call && (begin
                                        var"##720" = var"##719"[2]
                                        var"##720" isa AbstractArray
                                    end && ((ndims(var"##720") === 1 && length(var"##720") >= 2) && (begin
                                                var"##721" = var"##720"[1]
                                                begin
                                                    var"##cache#723" = nothing
                                                end
                                                var"##722" = var"##720"[2]
                                                var"##722" isa Expr
                                            end && (begin
                                                    if var"##cache#723" === nothing
                                                        var"##cache#723" = Some(((var"##722").head, (var"##722").args))
                                                    end
                                                    var"##724" = (var"##cache#723").value
                                                    var"##724" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##724"[1] == :parameters && (begin
                                                            var"##725" = var"##724"[2]
                                                            var"##725" isa AbstractArray
                                                        end && ((ndims(var"##725") === 1 && length(var"##725") >= 0) && begin
                                                                var"##726" = SubArray(var"##725", (1:length(var"##725"),))
                                                                var"##727" = SubArray(var"##720", (3:length(var"##720"),))
                                                                true
                                                            end)))))))))
                    f = var"##721"
                    args = var"##727"
                    kwargs = var"##726"
                    var"##return#704" = begin
                            call(f)
                            print("(")
                            join(args)
                            keyword("; ")
                            join(kwargs)
                            print(")")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#705#732")))
                end
                if var"##706" isa Expr && (begin
                                if var"##cache#707" === nothing
                                    var"##cache#707" = Some(((var"##706").head, (var"##706").args))
                                end
                                var"##728" = (var"##cache#707").value
                                var"##728" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##728"[1] == :call && (begin
                                        var"##729" = var"##728"[2]
                                        var"##729" isa AbstractArray
                                    end && ((ndims(var"##729") === 1 && length(var"##729") >= 1) && begin
                                            var"##730" = var"##729"[1]
                                            var"##731" = SubArray(var"##729", (2:length(var"##729"),))
                                            true
                                        end))))
                    f = var"##730"
                    args = var"##731"
                    var"##return#704" = begin
                            call(f)
                            print_braces(args, "(", ")")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#705#732")))
                end
                error("matching non-exhaustive, at #= none:111 =#")
                $(Expr(:symboliclabel, Symbol("####final#705#732")))
                var"##return#704"
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
                    var"##cache#736" = nothing
                end
                var"##735" = ex
                if var"##735" isa Nothing
                    begin
                        var"##return#733" = begin
                                printstyled("nothing", color = c.number)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                end
                if var"##735" isa LineNumberNode
                    begin
                        var"##return#733" = begin
                                p.line || return nothing
                                printstyled("#= $(ex.file):$(ex.line) =#", color = c.line)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                end
                if var"##735" isa String
                    begin
                        var"##return#733" = begin
                                string(ex)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                end
                if var"##735" isa Number
                    begin
                        var"##return#733" = begin
                                printstyled(ex, color = c.number)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                end
                if var"##735" isa Symbol
                    begin
                        var"##return#733" = begin
                                symbol(ex)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                end
                if var"##735" isa Expr
                    if begin
                                if var"##cache#736" === nothing
                                    var"##cache#736" = Some(((var"##735").head, (var"##735").args))
                                end
                                var"##737" = (var"##cache#736").value
                                var"##737" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##737"[1] == :line && (begin
                                        var"##738" = var"##737"[2]
                                        var"##738" isa AbstractArray
                                    end && (length(var"##738") === 2 && begin
                                            var"##739" = var"##738"[1]
                                            var"##740" = var"##738"[2]
                                            true
                                        end)))
                        line = var"##740"
                        file = var"##739"
                        var"##return#733" = begin
                                p.line || return nothing
                                printstyled("#= $(file):$(line) =#", color = c.line)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##741" = (var"##cache#736").value
                                var"##741" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##741"[1] == :kw && (begin
                                        var"##742" = var"##741"[2]
                                        var"##742" isa AbstractArray
                                    end && (length(var"##742") === 2 && begin
                                            var"##743" = var"##742"[1]
                                            var"##744" = var"##742"[2]
                                            true
                                        end)))
                        k = var"##743"
                        v = var"##744"
                        var"##return#733" = begin
                                p(k)
                                print(" = ")
                                p(v)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##745" = (var"##cache#736").value
                                var"##745" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##745"[1] == :(=) && (begin
                                        var"##746" = var"##745"[2]
                                        var"##746" isa AbstractArray
                                    end && (length(var"##746") === 2 && (begin
                                                var"##747" = var"##746"[1]
                                                begin
                                                    var"##cache#749" = nothing
                                                end
                                                var"##748" = var"##746"[2]
                                                var"##748" isa Expr
                                            end && (begin
                                                    if var"##cache#749" === nothing
                                                        var"##cache#749" = Some(((var"##748").head, (var"##748").args))
                                                    end
                                                    var"##750" = (var"##cache#749").value
                                                    var"##750" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##750"[1] == :block && (begin
                                                            var"##751" = var"##750"[2]
                                                            var"##751" isa AbstractArray
                                                        end && ((ndims(var"##751") === 1 && length(var"##751") >= 0) && begin
                                                                var"##752" = SubArray(var"##751", (1:length(var"##751"),))
                                                                true
                                                            end))))))))
                        k = var"##747"
                        stmts = var"##752"
                        var"##return#733" = begin
                                precedence(:(=)) do
                                    if length(stmts) == 2 && count(!is_line_no, stmts) == 1
                                        p(k)
                                        assign()
                                        p.line && (is_line_no(stmts[1]) && p(stmts[1]))
                                        p(stmts[var"end"])
                                    else
                                        p(k)
                                        assign()
                                        p(ex.args[2])
                                    end
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##753" = (var"##cache#736").value
                                var"##753" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##753"[1] == :(=) && (begin
                                        var"##754" = var"##753"[2]
                                        var"##754" isa AbstractArray
                                    end && (length(var"##754") === 2 && begin
                                            var"##755" = var"##754"[1]
                                            var"##756" = var"##754"[2]
                                            true
                                        end)))
                        k = var"##755"
                        v = var"##756"
                        var"##return#733" = begin
                                precedence(:(=)) do
                                    p(k)
                                    assign()
                                    p(v)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##757" = (var"##cache#736").value
                                var"##757" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##757"[1] == :... && (begin
                                        var"##758" = var"##757"[2]
                                        var"##758" isa AbstractArray
                                    end && (length(var"##758") === 1 && begin
                                            var"##759" = var"##758"[1]
                                            true
                                        end)))
                        name = var"##759"
                        var"##return#733" = begin
                                precedence(:...) do
                                    p(name)
                                    keyword("...")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##760" = (var"##cache#736").value
                                var"##760" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##760"[1] == :& && (begin
                                        var"##761" = var"##760"[2]
                                        var"##761" isa AbstractArray
                                    end && (length(var"##761") === 1 && begin
                                            var"##762" = var"##761"[1]
                                            true
                                        end)))
                        name = var"##762"
                        var"##return#733" = begin
                                precedence(:&) do
                                    keyword("&")
                                    p(name)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##763" = (var"##cache#736").value
                                var"##763" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##763"[1] == :(::) && (begin
                                        var"##764" = var"##763"[2]
                                        var"##764" isa AbstractArray
                                    end && (length(var"##764") === 1 && begin
                                            var"##765" = var"##764"[1]
                                            true
                                        end)))
                        t = var"##765"
                        var"##return#733" = begin
                                precedence(:(::)) do
                                    keyword("::")
                                    type(t)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##766" = (var"##cache#736").value
                                var"##766" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##766"[1] == :(::) && (begin
                                        var"##767" = var"##766"[2]
                                        var"##767" isa AbstractArray
                                    end && (length(var"##767") === 2 && begin
                                            var"##768" = var"##767"[1]
                                            var"##769" = var"##767"[2]
                                            true
                                        end)))
                        name = var"##768"
                        t = var"##769"
                        var"##return#733" = begin
                                precedence(:(::)) do
                                    p(name)
                                    keyword("::")
                                    type(t)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##770" = (var"##cache#736").value
                                var"##770" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##770"[1] == :$ && (begin
                                        var"##771" = var"##770"[2]
                                        var"##771" isa AbstractArray
                                    end && (length(var"##771") === 1 && begin
                                            var"##772" = var"##771"[1]
                                            true
                                        end)))
                        name = var"##772"
                        var"##return#733" = begin
                                precedence(:$) do
                                    keyword('$')
                                    print("(")
                                    p(name)
                                    print(")")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##773" = (var"##cache#736").value
                                var"##773" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##774" = var"##773"[1]
                                    var"##775" = var"##773"[2]
                                    var"##775" isa AbstractArray
                                end && (length(var"##775") === 2 && begin
                                        var"##776" = var"##775"[1]
                                        var"##777" = var"##775"[2]
                                        let rhs = var"##777", lhs = var"##776", head = var"##774"
                                            head in expr_infix_wide
                                        end
                                    end))
                        rhs = var"##777"
                        lhs = var"##776"
                        head = var"##774"
                        var"##return#733" = begin
                                precedence(head) do
                                    p(lhs)
                                    keyword(" $(head) ")
                                    p(rhs)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##778" = (var"##cache#736").value
                                var"##778" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##778"[1] == :. && (begin
                                        var"##779" = var"##778"[2]
                                        var"##779" isa AbstractArray
                                    end && (length(var"##779") === 1 && begin
                                            var"##780" = var"##779"[1]
                                            true
                                        end)))
                        name = var"##780"
                        var"##return#733" = begin
                                print(name)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##781" = (var"##cache#736").value
                                var"##781" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##781"[1] == :. && (begin
                                        var"##782" = var"##781"[2]
                                        var"##782" isa AbstractArray
                                    end && (length(var"##782") === 2 && (begin
                                                var"##783" = var"##782"[1]
                                                var"##784" = var"##782"[2]
                                                var"##784" isa QuoteNode
                                            end && begin
                                                var"##785" = (var"##784").value
                                                true
                                            end))))
                        name = var"##785"
                        object = var"##783"
                        var"##return#733" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##786" = (var"##cache#736").value
                                var"##786" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##786"[1] == :. && (begin
                                        var"##787" = var"##786"[2]
                                        var"##787" isa AbstractArray
                                    end && (length(var"##787") === 2 && begin
                                            var"##788" = var"##787"[1]
                                            var"##789" = var"##787"[2]
                                            true
                                        end)))
                        name = var"##789"
                        object = var"##788"
                        var"##return#733" = begin
                                precedence(:.) do
                                    p(object)
                                    keyword(".")
                                    p(name)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##790" = (var"##cache#736").value
                                var"##790" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##790"[1] == :<: && (begin
                                        var"##791" = var"##790"[2]
                                        var"##791" isa AbstractArray
                                    end && (length(var"##791") === 2 && begin
                                            var"##792" = var"##791"[1]
                                            var"##793" = var"##791"[2]
                                            true
                                        end)))
                        type = var"##792"
                        supertype = var"##793"
                        var"##return#733" = begin
                                precedence(:<:) do
                                    p(type)
                                    keyword(" <: ")
                                    p(supertype)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##794" = (var"##cache#736").value
                                var"##794" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##794"[1] == :call && (begin
                                        var"##795" = var"##794"[2]
                                        var"##795" isa AbstractArray
                                    end && (ndims(var"##795") === 1 && length(var"##795") >= 0)))
                        var"##return#733" = begin
                                print_call(ex)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##796" = (var"##cache#736").value
                                var"##796" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##796"[1] == :tuple && (begin
                                        var"##797" = var"##796"[2]
                                        var"##797" isa AbstractArray
                                    end && (length(var"##797") === 1 && (begin
                                                begin
                                                    var"##cache#799" = nothing
                                                end
                                                var"##798" = var"##797"[1]
                                                var"##798" isa Expr
                                            end && (begin
                                                    if var"##cache#799" === nothing
                                                        var"##cache#799" = Some(((var"##798").head, (var"##798").args))
                                                    end
                                                    var"##800" = (var"##cache#799").value
                                                    var"##800" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##800"[1] == :parameters && (begin
                                                            var"##801" = var"##800"[2]
                                                            var"##801" isa AbstractArray
                                                        end && ((ndims(var"##801") === 1 && length(var"##801") >= 0) && begin
                                                                var"##802" = SubArray(var"##801", (1:length(var"##801"),))
                                                                true
                                                            end))))))))
                        args = var"##802"
                        var"##return#733" = begin
                                print_braces(args, "(;", ")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##803" = (var"##cache#736").value
                                var"##803" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##803"[1] == :tuple && (begin
                                        var"##804" = var"##803"[2]
                                        var"##804" isa AbstractArray
                                    end && ((ndims(var"##804") === 1 && length(var"##804") >= 0) && begin
                                            var"##805" = SubArray(var"##804", (1:length(var"##804"),))
                                            true
                                        end)))
                        args = var"##805"
                        var"##return#733" = begin
                                if length(args) == 1
                                    print("(")
                                    p(args[1])
                                    print(",)")
                                else
                                    print_braces(args, "(", ")")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##806" = (var"##cache#736").value
                                var"##806" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##806"[1] == :curly && (begin
                                        var"##807" = var"##806"[2]
                                        var"##807" isa AbstractArray
                                    end && ((ndims(var"##807") === 1 && length(var"##807") >= 1) && begin
                                            var"##808" = var"##807"[1]
                                            var"##809" = SubArray(var"##807", (2:length(var"##807"),))
                                            true
                                        end)))
                        args = var"##809"
                        t = var"##808"
                        var"##return#733" = begin
                                with(p.state, :type, true) do
                                    p(t)
                                    print_braces(args, "{", "}")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##810" = (var"##cache#736").value
                                var"##810" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##810"[1] == :vect && (begin
                                        var"##811" = var"##810"[2]
                                        var"##811" isa AbstractArray
                                    end && ((ndims(var"##811") === 1 && length(var"##811") >= 0) && begin
                                            var"##812" = SubArray(var"##811", (1:length(var"##811"),))
                                            true
                                        end)))
                        args = var"##812"
                        var"##return#733" = begin
                                print_braces(args, "[", "]")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##813" = (var"##cache#736").value
                                var"##813" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##813"[1] == :hcat && (begin
                                        var"##814" = var"##813"[2]
                                        var"##814" isa AbstractArray
                                    end && ((ndims(var"##814") === 1 && length(var"##814") >= 0) && begin
                                            var"##815" = SubArray(var"##814", (1:length(var"##814"),))
                                            true
                                        end)))
                        args = var"##815"
                        var"##return#733" = begin
                                print_braces(args, "[", "]", " ")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##816" = (var"##cache#736").value
                                var"##816" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##816"[1] == :typed_hcat && (begin
                                        var"##817" = var"##816"[2]
                                        var"##817" isa AbstractArray
                                    end && ((ndims(var"##817") === 1 && length(var"##817") >= 1) && begin
                                            var"##818" = var"##817"[1]
                                            var"##819" = SubArray(var"##817", (2:length(var"##817"),))
                                            true
                                        end)))
                        args = var"##819"
                        t = var"##818"
                        var"##return#733" = begin
                                type(t)
                                print_braces(args, "[", "]", " ")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##820" = (var"##cache#736").value
                                var"##820" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##820"[1] == :vcat && (begin
                                        var"##821" = var"##820"[2]
                                        var"##821" isa AbstractArray
                                    end && ((ndims(var"##821") === 1 && length(var"##821") >= 0) && begin
                                            var"##822" = SubArray(var"##821", (1:length(var"##821"),))
                                            true
                                        end)))
                        args = var"##822"
                        var"##return#733" = begin
                                print_braces(args, "[", "]", "; ")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##823" = (var"##cache#736").value
                                var"##823" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##823"[1] == :ncat && (begin
                                        var"##824" = var"##823"[2]
                                        var"##824" isa AbstractArray
                                    end && ((ndims(var"##824") === 1 && length(var"##824") >= 1) && begin
                                            var"##825" = var"##824"[1]
                                            var"##826" = SubArray(var"##824", (2:length(var"##824"),))
                                            true
                                        end)))
                        n = var"##825"
                        args = var"##826"
                        var"##return#733" = begin
                                print_braces(args, "[", "]", ";" ^ n * " ")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##827" = (var"##cache#736").value
                                var"##827" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##827"[1] == :ref && (begin
                                        var"##828" = var"##827"[2]
                                        var"##828" isa AbstractArray
                                    end && ((ndims(var"##828") === 1 && length(var"##828") >= 1) && begin
                                            var"##829" = var"##828"[1]
                                            var"##830" = SubArray(var"##828", (2:length(var"##828"),))
                                            true
                                        end)))
                        args = var"##830"
                        object = var"##829"
                        var"##return#733" = begin
                                p(object)
                                print_braces(args, "[", "]")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##831" = (var"##cache#736").value
                                var"##831" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##831"[1] == :comprehension && (begin
                                        var"##832" = var"##831"[2]
                                        var"##832" isa AbstractArray
                                    end && (length(var"##832") === 1 && (begin
                                                begin
                                                    var"##cache#834" = nothing
                                                end
                                                var"##833" = var"##832"[1]
                                                var"##833" isa Expr
                                            end && (begin
                                                    if var"##cache#834" === nothing
                                                        var"##cache#834" = Some(((var"##833").head, (var"##833").args))
                                                    end
                                                    var"##835" = (var"##cache#834").value
                                                    var"##835" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##835"[1] == :generator && (begin
                                                            var"##836" = var"##835"[2]
                                                            var"##836" isa AbstractArray
                                                        end && (length(var"##836") === 2 && begin
                                                                var"##837" = var"##836"[1]
                                                                var"##838" = var"##836"[2]
                                                                true
                                                            end))))))))
                        iter = var"##837"
                        body = var"##838"
                        var"##return#733" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##839" = (var"##cache#736").value
                                var"##839" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##839"[1] == :typed_comprehension && (begin
                                        var"##840" = var"##839"[2]
                                        var"##840" isa AbstractArray
                                    end && (length(var"##840") === 2 && (begin
                                                var"##841" = var"##840"[1]
                                                begin
                                                    var"##cache#843" = nothing
                                                end
                                                var"##842" = var"##840"[2]
                                                var"##842" isa Expr
                                            end && (begin
                                                    if var"##cache#843" === nothing
                                                        var"##cache#843" = Some(((var"##842").head, (var"##842").args))
                                                    end
                                                    var"##844" = (var"##cache#843").value
                                                    var"##844" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##844"[1] == :generator && (begin
                                                            var"##845" = var"##844"[2]
                                                            var"##845" isa AbstractArray
                                                        end && (length(var"##845") === 2 && begin
                                                                var"##846" = var"##845"[1]
                                                                var"##847" = var"##845"[2]
                                                                true
                                                            end))))))))
                        iter = var"##846"
                        body = var"##847"
                        t = var"##841"
                        var"##return#733" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##848" = (var"##cache#736").value
                                var"##848" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##848"[1] == :-> && (begin
                                        var"##849" = var"##848"[2]
                                        var"##849" isa AbstractArray
                                    end && (length(var"##849") === 2 && (begin
                                                var"##850" = var"##849"[1]
                                                begin
                                                    var"##cache#852" = nothing
                                                end
                                                var"##851" = var"##849"[2]
                                                var"##851" isa Expr
                                            end && (begin
                                                    if var"##cache#852" === nothing
                                                        var"##cache#852" = Some(((var"##851").head, (var"##851").args))
                                                    end
                                                    var"##853" = (var"##cache#852").value
                                                    var"##853" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##853"[1] == :block && (begin
                                                            var"##854" = var"##853"[2]
                                                            var"##854" isa AbstractArray
                                                        end && (length(var"##854") === 2 && begin
                                                                var"##855" = var"##854"[1]
                                                                var"##856" = var"##854"[2]
                                                                true
                                                            end))))))))
                        line = var"##855"
                        code = var"##856"
                        args = var"##850"
                        var"##return#733" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##857" = (var"##cache#736").value
                                var"##857" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##857"[1] == :-> && (begin
                                        var"##858" = var"##857"[2]
                                        var"##858" isa AbstractArray
                                    end && (length(var"##858") === 2 && begin
                                            var"##859" = var"##858"[1]
                                            var"##860" = var"##858"[2]
                                            true
                                        end)))
                        args = var"##859"
                        body = var"##860"
                        var"##return#733" = begin
                                p(args)
                                keyword(" -> ")
                                print("(")
                                noblock(body)
                                print(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##861" = (var"##cache#736").value
                                var"##861" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##861"[1] == :do && (begin
                                        var"##862" = var"##861"[2]
                                        var"##862" isa AbstractArray
                                    end && (length(var"##862") === 2 && (begin
                                                var"##863" = var"##862"[1]
                                                begin
                                                    var"##cache#865" = nothing
                                                end
                                                var"##864" = var"##862"[2]
                                                var"##864" isa Expr
                                            end && (begin
                                                    if var"##cache#865" === nothing
                                                        var"##cache#865" = Some(((var"##864").head, (var"##864").args))
                                                    end
                                                    var"##866" = (var"##cache#865").value
                                                    var"##866" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##866"[1] == :-> && (begin
                                                            var"##867" = var"##866"[2]
                                                            var"##867" isa AbstractArray
                                                        end && (length(var"##867") === 2 && (begin
                                                                    begin
                                                                        var"##cache#869" = nothing
                                                                    end
                                                                    var"##868" = var"##867"[1]
                                                                    var"##868" isa Expr
                                                                end && (begin
                                                                        if var"##cache#869" === nothing
                                                                            var"##cache#869" = Some(((var"##868").head, (var"##868").args))
                                                                        end
                                                                        var"##870" = (var"##cache#869").value
                                                                        var"##870" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                    end && (var"##870"[1] == :tuple && (begin
                                                                                var"##871" = var"##870"[2]
                                                                                var"##871" isa AbstractArray
                                                                            end && ((ndims(var"##871") === 1 && length(var"##871") >= 0) && begin
                                                                                    var"##872" = SubArray(var"##871", (1:length(var"##871"),))
                                                                                    var"##873" = var"##867"[2]
                                                                                    true
                                                                                end)))))))))))))
                        call = var"##863"
                        args = var"##872"
                        body = var"##873"
                        var"##return#733" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##874" = (var"##cache#736").value
                                var"##874" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##874"[1] == :function && (begin
                                        var"##875" = var"##874"[2]
                                        var"##875" isa AbstractArray
                                    end && (length(var"##875") === 2 && begin
                                            var"##876" = var"##875"[1]
                                            var"##877" = var"##875"[2]
                                            true
                                        end)))
                        call = var"##876"
                        body = var"##877"
                        var"##return#733" = begin
                                print_function(:function, call, body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##878" = (var"##cache#736").value
                                var"##878" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##878"[1] == :quote && (begin
                                        var"##879" = var"##878"[2]
                                        var"##879" isa AbstractArray
                                    end && (length(var"##879") === 1 && begin
                                            var"##880" = var"##879"[1]
                                            true
                                        end)))
                        stmt = var"##880"
                        var"##return#733" = begin
                                keyword(":(")
                                noblock(stmt)
                                keyword(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##881" = (var"##cache#736").value
                                var"##881" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##881"[1] == :quote && (begin
                                        var"##882" = var"##881"[2]
                                        var"##882" isa AbstractArray
                                    end && ((ndims(var"##882") === 1 && length(var"##882") >= 0) && begin
                                            var"##883" = SubArray(var"##882", (1:length(var"##882"),))
                                            true
                                        end)))
                        args = var"##883"
                        var"##return#733" = begin
                                keyword("quote ")
                                with(p.state, :block, false) do
                                    join(args, "; ")
                                end
                                keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##884" = (var"##cache#736").value
                                var"##884" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##884"[1] == :string && (begin
                                        var"##885" = var"##884"[2]
                                        var"##885" isa AbstractArray
                                    end && ((ndims(var"##885") === 1 && length(var"##885") >= 0) && begin
                                            var"##886" = SubArray(var"##885", (1:length(var"##885"),))
                                            true
                                        end)))
                        args = var"##886"
                        var"##return#733" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##887" = (var"##cache#736").value
                                var"##887" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##887"[1] == :block && (begin
                                        var"##888" = var"##887"[2]
                                        var"##888" isa AbstractArray
                                    end && ((ndims(var"##888") === 1 && length(var"##888") >= 0) && begin
                                            var"##889" = SubArray(var"##888", (1:length(var"##888"),))
                                            let args = var"##889"
                                                length(args) == 2 && (is_line_no(args[1]) && is_line_no(args[2]))
                                            end
                                        end)))
                        args = var"##889"
                        var"##return#733" = begin
                                p(args[1])
                                print(" ")
                                p(args[2])
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##890" = (var"##cache#736").value
                                var"##890" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##890"[1] == :block && (begin
                                        var"##891" = var"##890"[2]
                                        var"##891" isa AbstractArray
                                    end && ((ndims(var"##891") === 1 && length(var"##891") >= 0) && begin
                                            var"##892" = SubArray(var"##891", (1:length(var"##891"),))
                                            let args = var"##892"
                                                length(args) == 2 && is_line_no(args[1])
                                            end
                                        end)))
                        args = var"##892"
                        var"##return#733" = begin
                                p(args[1])
                                print(" ")
                                noblock(args[2])
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##893" = (var"##cache#736").value
                                var"##893" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##893"[1] == :block && (begin
                                        var"##894" = var"##893"[2]
                                        var"##894" isa AbstractArray
                                    end && ((ndims(var"##894") === 1 && length(var"##894") >= 0) && begin
                                            var"##895" = SubArray(var"##894", (1:length(var"##894"),))
                                            let args = var"##895"
                                                length(args) == 2 && is_line_no(args[2])
                                            end
                                        end)))
                        args = var"##895"
                        var"##return#733" = begin
                                noblock(args[1])
                                print(" ")
                                p(args[2])
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##896" = (var"##cache#736").value
                                var"##896" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##896"[1] == :block && (begin
                                        var"##897" = var"##896"[2]
                                        var"##897" isa AbstractArray
                                    end && ((ndims(var"##897") === 1 && length(var"##897") >= 0) && begin
                                            var"##898" = SubArray(var"##897", (1:length(var"##897"),))
                                            let args = var"##898"
                                                length(args) == 2
                                            end
                                        end)))
                        args = var"##898"
                        var"##return#733" = begin
                                print("(")
                                noblock(args[1])
                                keyword("; ")
                                noblock(args[2])
                                print(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##899" = (var"##cache#736").value
                                var"##899" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##899"[1] == :block && (begin
                                        var"##900" = var"##899"[2]
                                        var"##900" isa AbstractArray
                                    end && ((ndims(var"##900") === 1 && length(var"##900") >= 0) && begin
                                            var"##901" = SubArray(var"##900", (1:length(var"##900"),))
                                            true
                                        end)))
                        args = var"##901"
                        var"##return#733" = begin
                                p.state.block && keyword("begin ")
                                with(p.state, :block, true) do
                                    join(args, "; ")
                                end
                                p.state.block && keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##902" = (var"##cache#736").value
                                var"##902" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##902"[1] == :let && (begin
                                        var"##903" = var"##902"[2]
                                        var"##903" isa AbstractArray
                                    end && (length(var"##903") === 2 && (begin
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
                                                end && (var"##906"[1] == :block && (begin
                                                            var"##907" = var"##906"[2]
                                                            var"##907" isa AbstractArray
                                                        end && ((ndims(var"##907") === 1 && length(var"##907") >= 0) && begin
                                                                var"##908" = SubArray(var"##907", (1:length(var"##907"),))
                                                                var"##909" = var"##903"[2]
                                                                true
                                                            end))))))))
                        args = var"##908"
                        body = var"##909"
                        var"##return#733" = begin
                                keyword("let ")
                                join(args, ", ")
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##910" = (var"##cache#736").value
                                var"##910" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##910"[1] == :let && (begin
                                        var"##911" = var"##910"[2]
                                        var"##911" isa AbstractArray
                                    end && (length(var"##911") === 2 && begin
                                            var"##912" = var"##911"[1]
                                            var"##913" = var"##911"[2]
                                            true
                                        end)))
                        arg = var"##912"
                        body = var"##913"
                        var"##return#733" = begin
                                keyword("let ")
                                p(arg)
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##914" = (var"##cache#736").value
                                var"##914" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##914"[1] == :macrocall && (begin
                                        var"##915" = var"##914"[2]
                                        var"##915" isa AbstractArray
                                    end && ((ndims(var"##915") === 1 && length(var"##915") >= 2) && begin
                                            var"##916" = var"##915"[1]
                                            var"##917" = var"##915"[2]
                                            var"##918" = SubArray(var"##915", (3:length(var"##915"),))
                                            true
                                        end)))
                        f = var"##916"
                        line = var"##917"
                        args = var"##918"
                        var"##return#733" = begin
                                p.line && printstyled(line, color = c.comment)
                                macrocall(f)
                                print_braces(args, "(", ")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##919" = (var"##cache#736").value
                                var"##919" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##919"[1] == :return && (begin
                                        var"##920" = var"##919"[2]
                                        var"##920" isa AbstractArray
                                    end && (length(var"##920") === 1 && (begin
                                                begin
                                                    var"##cache#922" = nothing
                                                end
                                                var"##921" = var"##920"[1]
                                                var"##921" isa Expr
                                            end && (begin
                                                    if var"##cache#922" === nothing
                                                        var"##cache#922" = Some(((var"##921").head, (var"##921").args))
                                                    end
                                                    var"##923" = (var"##cache#922").value
                                                    var"##923" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##923"[1] == :tuple && (begin
                                                            var"##924" = var"##923"[2]
                                                            var"##924" isa AbstractArray
                                                        end && ((ndims(var"##924") === 1 && length(var"##924") >= 1) && (begin
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
                                                                    end && (var"##927"[1] == :parameters && (begin
                                                                                var"##928" = var"##927"[2]
                                                                                var"##928" isa AbstractArray
                                                                            end && ((ndims(var"##928") === 1 && length(var"##928") >= 0) && begin
                                                                                    var"##929" = SubArray(var"##928", (1:length(var"##928"),))
                                                                                    var"##930" = SubArray(var"##924", (2:length(var"##924"),))
                                                                                    true
                                                                                end)))))))))))))
                        args = var"##930"
                        kwargs = var"##929"
                        var"##return#733" = begin
                                keyword("return ")
                                p(Expr(:tuple, Expr(:parameters, kwargs...), args...))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##931" = (var"##cache#736").value
                                var"##931" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##931"[1] == :return && (begin
                                        var"##932" = var"##931"[2]
                                        var"##932" isa AbstractArray
                                    end && (length(var"##932") === 1 && (begin
                                                begin
                                                    var"##cache#934" = nothing
                                                end
                                                var"##933" = var"##932"[1]
                                                var"##933" isa Expr
                                            end && (begin
                                                    if var"##cache#934" === nothing
                                                        var"##cache#934" = Some(((var"##933").head, (var"##933").args))
                                                    end
                                                    var"##935" = (var"##cache#934").value
                                                    var"##935" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##935"[1] == :tuple && (begin
                                                            var"##936" = var"##935"[2]
                                                            var"##936" isa AbstractArray
                                                        end && ((ndims(var"##936") === 1 && length(var"##936") >= 0) && begin
                                                                var"##937" = SubArray(var"##936", (1:length(var"##936"),))
                                                                true
                                                            end))))))))
                        args = var"##937"
                        var"##return#733" = begin
                                keyword("return ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##938" = (var"##cache#736").value
                                var"##938" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##938"[1] == :return && (begin
                                        var"##939" = var"##938"[2]
                                        var"##939" isa AbstractArray
                                    end && ((ndims(var"##939") === 1 && length(var"##939") >= 0) && begin
                                            var"##940" = SubArray(var"##939", (1:length(var"##939"),))
                                            true
                                        end)))
                        args = var"##940"
                        var"##return#733" = begin
                                keyword("return ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##941" = (var"##cache#736").value
                                var"##941" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##941"[1] == :module && (begin
                                        var"##942" = var"##941"[2]
                                        var"##942" isa AbstractArray
                                    end && (length(var"##942") === 3 && begin
                                            var"##943" = var"##942"[1]
                                            var"##944" = var"##942"[2]
                                            var"##945" = var"##942"[3]
                                            true
                                        end)))
                        bare = var"##943"
                        name = var"##944"
                        body = var"##945"
                        var"##return#733" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##946" = (var"##cache#736").value
                                var"##946" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##946"[1] == :module && (begin
                                        var"##947" = var"##946"[2]
                                        var"##947" isa AbstractArray
                                    end && (length(var"##947") === 4 && (begin
                                                var"##948" = var"##947"[1]
                                                var"##948" isa VersionNumber
                                            end && begin
                                                var"##949" = var"##947"[2]
                                                var"##950" = var"##947"[3]
                                                var"##951" = var"##947"[4]
                                                true
                                            end))))
                        bare = var"##949"
                        name = var"##950"
                        body = var"##951"
                        var"##return#733" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##952" = (var"##cache#736").value
                                var"##952" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##952"[1] == :using && (begin
                                        var"##953" = var"##952"[2]
                                        var"##953" isa AbstractArray
                                    end && ((ndims(var"##953") === 1 && length(var"##953") >= 0) && begin
                                            var"##954" = SubArray(var"##953", (1:length(var"##953"),))
                                            true
                                        end)))
                        args = var"##954"
                        var"##return#733" = begin
                                keyword("using ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##955" = (var"##cache#736").value
                                var"##955" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##955"[1] == :import && (begin
                                        var"##956" = var"##955"[2]
                                        var"##956" isa AbstractArray
                                    end && ((ndims(var"##956") === 1 && length(var"##956") >= 0) && begin
                                            var"##957" = SubArray(var"##956", (1:length(var"##956"),))
                                            true
                                        end)))
                        args = var"##957"
                        var"##return#733" = begin
                                keyword("import ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##958" = (var"##cache#736").value
                                var"##958" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##958"[1] == :as && (begin
                                        var"##959" = var"##958"[2]
                                        var"##959" isa AbstractArray
                                    end && (length(var"##959") === 2 && begin
                                            var"##960" = var"##959"[1]
                                            var"##961" = var"##959"[2]
                                            true
                                        end)))
                        name = var"##960"
                        alias = var"##961"
                        var"##return#733" = begin
                                p(name)
                                keyword(" as ")
                                p(alias)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##962" = (var"##cache#736").value
                                var"##962" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##962"[1] == :export && (begin
                                        var"##963" = var"##962"[2]
                                        var"##963" isa AbstractArray
                                    end && ((ndims(var"##963") === 1 && length(var"##963") >= 0) && begin
                                            var"##964" = SubArray(var"##963", (1:length(var"##963"),))
                                            true
                                        end)))
                        args = var"##964"
                        var"##return#733" = begin
                                keyword("export ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##965" = (var"##cache#736").value
                                var"##965" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##965"[1] == :(:) && (begin
                                        var"##966" = var"##965"[2]
                                        var"##966" isa AbstractArray
                                    end && ((ndims(var"##966") === 1 && length(var"##966") >= 1) && begin
                                            var"##967" = var"##966"[1]
                                            var"##968" = SubArray(var"##966", (2:length(var"##966"),))
                                            true
                                        end)))
                        args = var"##968"
                        head = var"##967"
                        var"##return#733" = begin
                                p(head)
                                keyword(": ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##969" = (var"##cache#736").value
                                var"##969" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##969"[1] == :where && (begin
                                        var"##970" = var"##969"[2]
                                        var"##970" isa AbstractArray
                                    end && ((ndims(var"##970") === 1 && length(var"##970") >= 1) && begin
                                            var"##971" = var"##970"[1]
                                            var"##972" = SubArray(var"##970", (2:length(var"##970"),))
                                            true
                                        end)))
                        body = var"##971"
                        whereparams = var"##972"
                        var"##return#733" = begin
                                p(body)
                                keyword(" where {")
                                with(p.state, :type, true) do
                                    join(whereparams, ", ")
                                end
                                keyword("}")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##973" = (var"##cache#736").value
                                var"##973" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##973"[1] == :for && (begin
                                        var"##974" = var"##973"[2]
                                        var"##974" isa AbstractArray
                                    end && (length(var"##974") === 2 && begin
                                            var"##975" = var"##974"[1]
                                            var"##976" = var"##974"[2]
                                            true
                                        end)))
                        body = var"##976"
                        iteration = var"##975"
                        var"##return#733" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##977" = (var"##cache#736").value
                                var"##977" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##977"[1] == :while && (begin
                                        var"##978" = var"##977"[2]
                                        var"##978" isa AbstractArray
                                    end && (length(var"##978") === 2 && begin
                                            var"##979" = var"##978"[1]
                                            var"##980" = var"##978"[2]
                                            true
                                        end)))
                        body = var"##980"
                        condition = var"##979"
                        var"##return#733" = begin
                                keyword("while ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##981" = (var"##cache#736").value
                                var"##981" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##981"[1] == :continue && (begin
                                        var"##982" = var"##981"[2]
                                        var"##982" isa AbstractArray
                                    end && isempty(var"##982")))
                        var"##return#733" = begin
                                keyword("continue")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##983" = (var"##cache#736").value
                                var"##983" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##983"[1] == :if && (begin
                                        var"##984" = var"##983"[2]
                                        var"##984" isa AbstractArray
                                    end && (length(var"##984") === 2 && begin
                                            var"##985" = var"##984"[1]
                                            var"##986" = var"##984"[2]
                                            true
                                        end)))
                        body = var"##986"
                        condition = var"##985"
                        var"##return#733" = begin
                                keyword("if ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##987" = (var"##cache#736").value
                                var"##987" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##987"[1] == :if && (begin
                                        var"##988" = var"##987"[2]
                                        var"##988" isa AbstractArray
                                    end && (length(var"##988") === 3 && begin
                                            var"##989" = var"##988"[1]
                                            var"##990" = var"##988"[2]
                                            var"##991" = var"##988"[3]
                                            true
                                        end)))
                        body = var"##990"
                        elsebody = var"##991"
                        condition = var"##989"
                        var"##return#733" = begin
                                keyword("if ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                                keyword("; ")
                                Meta.isexpr(elsebody, :elseif) || keyword("else ")
                                noblock(elsebody)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##992" = (var"##cache#736").value
                                var"##992" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##992"[1] == :elseif && (begin
                                        var"##993" = var"##992"[2]
                                        var"##993" isa AbstractArray
                                    end && (length(var"##993") === 2 && begin
                                            var"##994" = var"##993"[1]
                                            var"##995" = var"##993"[2]
                                            true
                                        end)))
                        body = var"##995"
                        condition = var"##994"
                        var"##return#733" = begin
                                keyword("elseif ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##996" = (var"##cache#736").value
                                var"##996" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##996"[1] == :elseif && (begin
                                        var"##997" = var"##996"[2]
                                        var"##997" isa AbstractArray
                                    end && (length(var"##997") === 3 && begin
                                            var"##998" = var"##997"[1]
                                            var"##999" = var"##997"[2]
                                            var"##1000" = var"##997"[3]
                                            true
                                        end)))
                        body = var"##999"
                        elsebody = var"##1000"
                        condition = var"##998"
                        var"##return#733" = begin
                                keyword("elseif ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                                keyword("; ")
                                Meta.isexpr(elsebody, :elseif) || keyword("else")
                                noblock(elsebody)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##1001" = (var"##cache#736").value
                                var"##1001" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1001"[1] == :try && (begin
                                        var"##1002" = var"##1001"[2]
                                        var"##1002" isa AbstractArray
                                    end && (length(var"##1002") === 3 && begin
                                            var"##1003" = var"##1002"[1]
                                            var"##1004" = var"##1002"[2]
                                            var"##1005" = var"##1002"[3]
                                            true
                                        end)))
                        catch_vars = var"##1004"
                        catch_body = var"##1005"
                        try_body = var"##1003"
                        var"##return#733" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##1006" = (var"##cache#736").value
                                var"##1006" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1006"[1] == :try && (begin
                                        var"##1007" = var"##1006"[2]
                                        var"##1007" isa AbstractArray
                                    end && (length(var"##1007") === 4 && begin
                                            var"##1008" = var"##1007"[1]
                                            var"##1009" = var"##1007"[2]
                                            var"##1010" = var"##1007"[3]
                                            var"##1011" = var"##1007"[4]
                                            true
                                        end)))
                        catch_vars = var"##1009"
                        catch_body = var"##1010"
                        try_body = var"##1008"
                        finally_body = var"##1011"
                        var"##return#733" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##1012" = (var"##cache#736").value
                                var"##1012" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1012"[1] == :try && (begin
                                        var"##1013" = var"##1012"[2]
                                        var"##1013" isa AbstractArray
                                    end && (length(var"##1013") === 5 && begin
                                            var"##1014" = var"##1013"[1]
                                            var"##1015" = var"##1013"[2]
                                            var"##1016" = var"##1013"[3]
                                            var"##1017" = var"##1013"[4]
                                            var"##1018" = var"##1013"[5]
                                            true
                                        end)))
                        catch_vars = var"##1015"
                        catch_body = var"##1016"
                        try_body = var"##1014"
                        finally_body = var"##1017"
                        else_body = var"##1018"
                        var"##return#733" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##1019" = (var"##cache#736").value
                                var"##1019" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1019"[1] == :struct && (begin
                                        var"##1020" = var"##1019"[2]
                                        var"##1020" isa AbstractArray
                                    end && (length(var"##1020") === 3 && begin
                                            var"##1021" = var"##1020"[1]
                                            var"##1022" = var"##1020"[2]
                                            var"##1023" = var"##1020"[3]
                                            true
                                        end)))
                        ismutable = var"##1021"
                        name = var"##1022"
                        body = var"##1023"
                        var"##return#733" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##1024" = (var"##cache#736").value
                                var"##1024" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1024"[1] == :abstract && (begin
                                        var"##1025" = var"##1024"[2]
                                        var"##1025" isa AbstractArray
                                    end && (length(var"##1025") === 1 && begin
                                            var"##1026" = var"##1025"[1]
                                            true
                                        end)))
                        name = var"##1026"
                        var"##return#733" = begin
                                keyword("abstract type ")
                                p(name)
                                keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##1027" = (var"##cache#736").value
                                var"##1027" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1027"[1] == :primitive && (begin
                                        var"##1028" = var"##1027"[2]
                                        var"##1028" isa AbstractArray
                                    end && (length(var"##1028") === 2 && begin
                                            var"##1029" = var"##1028"[1]
                                            var"##1030" = var"##1028"[2]
                                            true
                                        end)))
                        name = var"##1029"
                        size = var"##1030"
                        var"##return#733" = begin
                                keyword("primitive type ")
                                p(name)
                                print(" ")
                                p(size)
                                keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##1031" = (var"##cache#736").value
                                var"##1031" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1031"[1] == :meta && (begin
                                        var"##1032" = var"##1031"[2]
                                        var"##1032" isa AbstractArray
                                    end && (length(var"##1032") === 1 && var"##1032"[1] == :inline)))
                        var"##return#733" = begin
                                macrocall(GlobalRef(Base, Symbol("@_inline_meta")))
                                keyword(";")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##1033" = (var"##cache#736").value
                                var"##1033" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1033"[1] == :break && (begin
                                        var"##1034" = var"##1033"[2]
                                        var"##1034" isa AbstractArray
                                    end && isempty(var"##1034")))
                        var"##return#733" = begin
                                keyword("break")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##1035" = (var"##cache#736").value
                                var"##1035" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1035"[1] == :symboliclabel && (begin
                                        var"##1036" = var"##1035"[2]
                                        var"##1036" isa AbstractArray
                                    end && (length(var"##1036") === 1 && begin
                                            var"##1037" = var"##1036"[1]
                                            true
                                        end)))
                        label = var"##1037"
                        var"##return#733" = begin
                                macrocall(GlobalRef(Base, Symbol("@label")))
                                print(" ")
                                p(label)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##1038" = (var"##cache#736").value
                                var"##1038" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1038"[1] == :symbolicgoto && (begin
                                        var"##1039" = var"##1038"[2]
                                        var"##1039" isa AbstractArray
                                    end && (length(var"##1039") === 1 && begin
                                            var"##1040" = var"##1039"[1]
                                            true
                                        end)))
                        label = var"##1040"
                        var"##return#733" = begin
                                macrocall(GlobalRef(Base, Symbol("@goto")))
                                print(" ")
                                p(label)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    if begin
                                var"##1041" = (var"##cache#736").value
                                var"##1041" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1042" = var"##1041"[1]
                                    var"##1043" = var"##1041"[2]
                                    var"##1043" isa AbstractArray
                                end && ((ndims(var"##1043") === 1 && length(var"##1043") >= 0) && begin
                                        var"##1044" = SubArray(var"##1043", (1:length(var"##1043"),))
                                        true
                                    end))
                        args = var"##1044"
                        head = var"##1042"
                        var"##return#733" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                end
                if var"##735" isa Char
                    begin
                        var"##return#733" = begin
                                printstyled(repr(ex), color = c.string)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                end
                if var"##735" isa QuoteNode
                    if ex.value in Base.quoted_syms
                        var"##return#733" = begin
                                keyword(":(")
                                quoted(ex.value)
                                keyword(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                    begin
                        var"##return#733" = begin
                                if ex.value isa Symbol && Base.isidentifier(ex.value)
                                    keyword(":")
                                    quoted(ex.value)
                                else
                                    keyword(":(")
                                    quoted(ex.value)
                                    keyword(")")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                end
                if var"##735" isa GlobalRef
                    begin
                        var"##return#733" = begin
                                p(ex.mod)
                                keyword(".")
                                p(ex.name)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                    end
                end
                begin
                    var"##return#733" = begin
                            print(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#734#1045")))
                end
                error("matching non-exhaustive, at #= none:142 =#")
                $(Expr(:symboliclabel, Symbol("####final#734#1045")))
                var"##return#733"
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
