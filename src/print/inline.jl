
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
                        var"##cache#701" = nothing
                    end
                    var"##return#698" = nothing
                    var"##700" = ex
                    if var"##700" isa Expr
                        if begin
                                    if var"##cache#701" === nothing
                                        var"##cache#701" = Some(((var"##700").head, (var"##700").args))
                                    end
                                    var"##702" = (var"##cache#701").value
                                    var"##702" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##702"[1] == :. && (begin
                                            var"##703" = var"##702"[2]
                                            var"##703" isa AbstractArray
                                        end && (ndims(var"##703") === 1 && length(var"##703") >= 0)))
                            var"##return#698" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#699#704")))
                        end
                    end
                    if var"##700" isa Symbol
                        begin
                            var"##return#698" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#699#704")))
                        end
                    end
                    begin
                        var"##return#698" = let
                                false
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#699#704")))
                    end
                    error("matching non-exhaustive, at #= none:85 =#")
                    $(Expr(:symboliclabel, Symbol("####final#699#704")))
                    var"##return#698"
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
                    var"##cache#708" = nothing
                end
                var"##707" = ex
                if var"##707" isa Expr && (begin
                                if var"##cache#708" === nothing
                                    var"##cache#708" = Some(((var"##707").head, (var"##707").args))
                                end
                                var"##709" = (var"##cache#708").value
                                var"##709" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##709"[1] == :call && (begin
                                        var"##710" = var"##709"[2]
                                        var"##710" isa AbstractArray
                                    end && ((ndims(var"##710") === 1 && length(var"##710") >= 1) && (var"##710"[1] == :(:) && begin
                                                var"##711" = SubArray(var"##710", (2:length(var"##710"),))
                                                true
                                            end)))))
                    args = var"##711"
                    var"##return#705" = begin
                            precedence(:(:)) do 
                                join(args, ":")
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#706#733")))
                end
                if var"##707" isa Expr && (begin
                                if var"##cache#708" === nothing
                                    var"##cache#708" = Some(((var"##707").head, (var"##707").args))
                                end
                                var"##712" = (var"##cache#708").value
                                var"##712" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##712"[1] == :call && (begin
                                        var"##713" = var"##712"[2]
                                        var"##713" isa AbstractArray
                                    end && (length(var"##713") === 2 && (begin
                                                var"##714" = var"##713"[1]
                                                var"##714" isa Symbol
                                            end && begin
                                                var"##715" = var"##713"[2]
                                                let f = var"##714", arg = var"##715"
                                                    Base.isunaryoperator(f)
                                                end
                                            end)))))
                    f = var"##714"
                    arg = var"##715"
                    var"##return#705" = begin
                            precedence(typemax(Int)) do 
                                keyword(f)
                                p(arg)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#706#733")))
                end
                if var"##707" isa Expr && (begin
                                if var"##cache#708" === nothing
                                    var"##cache#708" = Some(((var"##707").head, (var"##707").args))
                                end
                                var"##716" = (var"##cache#708").value
                                var"##716" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##716"[1] == :call && (begin
                                        var"##717" = var"##716"[2]
                                        var"##717" isa AbstractArray
                                    end && ((ndims(var"##717") === 1 && length(var"##717") >= 1) && (begin
                                                var"##718" = var"##717"[1]
                                                var"##718" isa Symbol
                                            end && begin
                                                var"##719" = SubArray(var"##717", (2:length(var"##717"),))
                                                let f = var"##718", args = var"##719"
                                                    Base.isbinaryoperator(f)
                                                end
                                            end)))))
                    f = var"##718"
                    args = var"##719"
                    var"##return#705" = begin
                            precedence(f) do 
                                join(args, " $(f) ")
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#706#733")))
                end
                if var"##707" isa Expr && (begin
                                if var"##cache#708" === nothing
                                    var"##cache#708" = Some(((var"##707").head, (var"##707").args))
                                end
                                var"##720" = (var"##cache#708").value
                                var"##720" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##720"[1] == :call && (begin
                                        var"##721" = var"##720"[2]
                                        var"##721" isa AbstractArray
                                    end && ((ndims(var"##721") === 1 && length(var"##721") >= 2) && (begin
                                                var"##722" = var"##721"[1]
                                                begin
                                                    var"##cache#724" = nothing
                                                end
                                                var"##723" = var"##721"[2]
                                                var"##723" isa Expr
                                            end && (begin
                                                    if var"##cache#724" === nothing
                                                        var"##cache#724" = Some(((var"##723").head, (var"##723").args))
                                                    end
                                                    var"##725" = (var"##cache#724").value
                                                    var"##725" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##725"[1] == :parameters && (begin
                                                            var"##726" = var"##725"[2]
                                                            var"##726" isa AbstractArray
                                                        end && ((ndims(var"##726") === 1 && length(var"##726") >= 0) && begin
                                                                var"##727" = SubArray(var"##726", (1:length(var"##726"),))
                                                                var"##728" = SubArray(var"##721", (3:length(var"##721"),))
                                                                true
                                                            end)))))))))
                    f = var"##722"
                    args = var"##728"
                    kwargs = var"##727"
                    var"##return#705" = begin
                            call(f)
                            print("(")
                            join(args)
                            keyword("; ")
                            join(kwargs)
                            print(")")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#706#733")))
                end
                if var"##707" isa Expr && (begin
                                if var"##cache#708" === nothing
                                    var"##cache#708" = Some(((var"##707").head, (var"##707").args))
                                end
                                var"##729" = (var"##cache#708").value
                                var"##729" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##729"[1] == :call && (begin
                                        var"##730" = var"##729"[2]
                                        var"##730" isa AbstractArray
                                    end && ((ndims(var"##730") === 1 && length(var"##730") >= 1) && begin
                                            var"##731" = var"##730"[1]
                                            var"##732" = SubArray(var"##730", (2:length(var"##730"),))
                                            true
                                        end))))
                    f = var"##731"
                    args = var"##732"
                    var"##return#705" = begin
                            call(f)
                            print_braces(args, "(", ")")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#706#733")))
                end
                error("matching non-exhaustive, at #= none:111 =#")
                $(Expr(:symboliclabel, Symbol("####final#706#733")))
                var"##return#705"
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
                    var"##cache#737" = nothing
                end
                var"##736" = ex
                if var"##736" isa GlobalRef
                    begin
                        var"##return#734" = begin
                                p(ex.mod)
                                keyword(".")
                                p(ex.name)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                end
                if var"##736" isa Nothing
                    begin
                        var"##return#734" = begin
                                printstyled("nothing", color = c.number)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                end
                if var"##736" isa Char
                    begin
                        var"##return#734" = begin
                                printstyled(repr(ex), color = c.string)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                end
                if var"##736" isa Symbol
                    begin
                        var"##return#734" = begin
                                symbol(ex)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                end
                if var"##736" isa Expr
                    if begin
                                if var"##cache#737" === nothing
                                    var"##cache#737" = Some(((var"##736").head, (var"##736").args))
                                end
                                var"##738" = (var"##cache#737").value
                                var"##738" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##738"[1] == :line && (begin
                                        var"##739" = var"##738"[2]
                                        var"##739" isa AbstractArray
                                    end && (length(var"##739") === 2 && begin
                                            var"##740" = var"##739"[1]
                                            var"##741" = var"##739"[2]
                                            true
                                        end)))
                        line = var"##741"
                        file = var"##740"
                        var"##return#734" = begin
                                p.line || return nothing
                                printstyled("#= $(file):$(line) =#", color = c.line)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##742" = (var"##cache#737").value
                                var"##742" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##742"[1] == :kw && (begin
                                        var"##743" = var"##742"[2]
                                        var"##743" isa AbstractArray
                                    end && (length(var"##743") === 2 && begin
                                            var"##744" = var"##743"[1]
                                            var"##745" = var"##743"[2]
                                            true
                                        end)))
                        k = var"##744"
                        v = var"##745"
                        var"##return#734" = begin
                                p(k)
                                print(" = ")
                                p(v)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##746" = (var"##cache#737").value
                                var"##746" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##746"[1] == :(=) && (begin
                                        var"##747" = var"##746"[2]
                                        var"##747" isa AbstractArray
                                    end && (length(var"##747") === 2 && (begin
                                                var"##748" = var"##747"[1]
                                                begin
                                                    var"##cache#750" = nothing
                                                end
                                                var"##749" = var"##747"[2]
                                                var"##749" isa Expr
                                            end && (begin
                                                    if var"##cache#750" === nothing
                                                        var"##cache#750" = Some(((var"##749").head, (var"##749").args))
                                                    end
                                                    var"##751" = (var"##cache#750").value
                                                    var"##751" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##751"[1] == :block && (begin
                                                            var"##752" = var"##751"[2]
                                                            var"##752" isa AbstractArray
                                                        end && ((ndims(var"##752") === 1 && length(var"##752") >= 0) && begin
                                                                var"##753" = SubArray(var"##752", (1:length(var"##752"),))
                                                                true
                                                            end))))))))
                        k = var"##748"
                        stmts = var"##753"
                        var"##return#734" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##754" = (var"##cache#737").value
                                var"##754" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##754"[1] == :(=) && (begin
                                        var"##755" = var"##754"[2]
                                        var"##755" isa AbstractArray
                                    end && (length(var"##755") === 2 && begin
                                            var"##756" = var"##755"[1]
                                            var"##757" = var"##755"[2]
                                            true
                                        end)))
                        k = var"##756"
                        v = var"##757"
                        var"##return#734" = begin
                                precedence(:(=)) do 
                                    p(k)
                                    assign()
                                    p(v)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##758" = (var"##cache#737").value
                                var"##758" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##758"[1] == :... && (begin
                                        var"##759" = var"##758"[2]
                                        var"##759" isa AbstractArray
                                    end && (length(var"##759") === 1 && begin
                                            var"##760" = var"##759"[1]
                                            true
                                        end)))
                        name = var"##760"
                        var"##return#734" = begin
                                precedence(:...) do 
                                    p(name)
                                    keyword("...")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##761" = (var"##cache#737").value
                                var"##761" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##761"[1] == :& && (begin
                                        var"##762" = var"##761"[2]
                                        var"##762" isa AbstractArray
                                    end && (length(var"##762") === 1 && begin
                                            var"##763" = var"##762"[1]
                                            true
                                        end)))
                        name = var"##763"
                        var"##return#734" = begin
                                precedence(:&) do 
                                    keyword("&")
                                    p(name)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##764" = (var"##cache#737").value
                                var"##764" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##764"[1] == :(::) && (begin
                                        var"##765" = var"##764"[2]
                                        var"##765" isa AbstractArray
                                    end && (length(var"##765") === 1 && begin
                                            var"##766" = var"##765"[1]
                                            true
                                        end)))
                        t = var"##766"
                        var"##return#734" = begin
                                precedence(:(::)) do 
                                    keyword("::")
                                    type(t)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##767" = (var"##cache#737").value
                                var"##767" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##767"[1] == :(::) && (begin
                                        var"##768" = var"##767"[2]
                                        var"##768" isa AbstractArray
                                    end && (length(var"##768") === 2 && begin
                                            var"##769" = var"##768"[1]
                                            var"##770" = var"##768"[2]
                                            true
                                        end)))
                        name = var"##769"
                        t = var"##770"
                        var"##return#734" = begin
                                precedence(:(::)) do 
                                    p(name)
                                    keyword("::")
                                    type(t)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##771" = (var"##cache#737").value
                                var"##771" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##771"[1] == :$ && (begin
                                        var"##772" = var"##771"[2]
                                        var"##772" isa AbstractArray
                                    end && (length(var"##772") === 1 && begin
                                            var"##773" = var"##772"[1]
                                            true
                                        end)))
                        name = var"##773"
                        var"##return#734" = begin
                                precedence(:$) do 
                                    keyword('$')
                                    print("(")
                                    p(name)
                                    print(")")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##774" = (var"##cache#737").value
                                var"##774" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##775" = var"##774"[1]
                                    var"##776" = var"##774"[2]
                                    var"##776" isa AbstractArray
                                end && (length(var"##776") === 2 && begin
                                        var"##777" = var"##776"[1]
                                        var"##778" = var"##776"[2]
                                        let rhs = var"##778", lhs = var"##777", head = var"##775"
                                            head in expr_infix_wide
                                        end
                                    end))
                        rhs = var"##778"
                        lhs = var"##777"
                        head = var"##775"
                        var"##return#734" = begin
                                precedence(head) do 
                                    p(lhs)
                                    keyword(" $(head) ")
                                    p(rhs)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##779" = (var"##cache#737").value
                                var"##779" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##779"[1] == :. && (begin
                                        var"##780" = var"##779"[2]
                                        var"##780" isa AbstractArray
                                    end && (length(var"##780") === 1 && begin
                                            var"##781" = var"##780"[1]
                                            true
                                        end)))
                        name = var"##781"
                        var"##return#734" = begin
                                print(name)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##782" = (var"##cache#737").value
                                var"##782" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##782"[1] == :. && (begin
                                        var"##783" = var"##782"[2]
                                        var"##783" isa AbstractArray
                                    end && (length(var"##783") === 2 && (begin
                                                var"##784" = var"##783"[1]
                                                var"##785" = var"##783"[2]
                                                var"##785" isa QuoteNode
                                            end && begin
                                                var"##786" = (var"##785").value
                                                true
                                            end))))
                        name = var"##786"
                        object = var"##784"
                        var"##return#734" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##787" = (var"##cache#737").value
                                var"##787" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##787"[1] == :. && (begin
                                        var"##788" = var"##787"[2]
                                        var"##788" isa AbstractArray
                                    end && (length(var"##788") === 2 && begin
                                            var"##789" = var"##788"[1]
                                            var"##790" = var"##788"[2]
                                            true
                                        end)))
                        name = var"##790"
                        object = var"##789"
                        var"##return#734" = begin
                                precedence(:.) do 
                                    p(object)
                                    keyword(".")
                                    p(name)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##791" = (var"##cache#737").value
                                var"##791" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##791"[1] == :<: && (begin
                                        var"##792" = var"##791"[2]
                                        var"##792" isa AbstractArray
                                    end && (length(var"##792") === 2 && begin
                                            var"##793" = var"##792"[1]
                                            var"##794" = var"##792"[2]
                                            true
                                        end)))
                        type = var"##793"
                        supertype = var"##794"
                        var"##return#734" = begin
                                precedence(:<:) do 
                                    p(type)
                                    keyword(" <: ")
                                    p(supertype)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##795" = (var"##cache#737").value
                                var"##795" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##795"[1] == :call && (begin
                                        var"##796" = var"##795"[2]
                                        var"##796" isa AbstractArray
                                    end && (ndims(var"##796") === 1 && length(var"##796") >= 0)))
                        var"##return#734" = begin
                                print_call(ex)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##797" = (var"##cache#737").value
                                var"##797" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##797"[1] == :tuple && (begin
                                        var"##798" = var"##797"[2]
                                        var"##798" isa AbstractArray
                                    end && (length(var"##798") === 1 && (begin
                                                begin
                                                    var"##cache#800" = nothing
                                                end
                                                var"##799" = var"##798"[1]
                                                var"##799" isa Expr
                                            end && (begin
                                                    if var"##cache#800" === nothing
                                                        var"##cache#800" = Some(((var"##799").head, (var"##799").args))
                                                    end
                                                    var"##801" = (var"##cache#800").value
                                                    var"##801" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##801"[1] == :parameters && (begin
                                                            var"##802" = var"##801"[2]
                                                            var"##802" isa AbstractArray
                                                        end && ((ndims(var"##802") === 1 && length(var"##802") >= 0) && begin
                                                                var"##803" = SubArray(var"##802", (1:length(var"##802"),))
                                                                true
                                                            end))))))))
                        args = var"##803"
                        var"##return#734" = begin
                                print_braces(args, "(;", ")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##804" = (var"##cache#737").value
                                var"##804" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##804"[1] == :tuple && (begin
                                        var"##805" = var"##804"[2]
                                        var"##805" isa AbstractArray
                                    end && ((ndims(var"##805") === 1 && length(var"##805") >= 0) && begin
                                            var"##806" = SubArray(var"##805", (1:length(var"##805"),))
                                            true
                                        end)))
                        args = var"##806"
                        var"##return#734" = begin
                                if length(args) == 1
                                    print("(")
                                    p(args[1])
                                    print(",)")
                                else
                                    print_braces(args, "(", ")")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##807" = (var"##cache#737").value
                                var"##807" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##807"[1] == :curly && (begin
                                        var"##808" = var"##807"[2]
                                        var"##808" isa AbstractArray
                                    end && ((ndims(var"##808") === 1 && length(var"##808") >= 1) && begin
                                            var"##809" = var"##808"[1]
                                            var"##810" = SubArray(var"##808", (2:length(var"##808"),))
                                            true
                                        end)))
                        args = var"##810"
                        t = var"##809"
                        var"##return#734" = begin
                                with(p.state, :type, true) do 
                                    p(t)
                                    print_braces(args, "{", "}")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##811" = (var"##cache#737").value
                                var"##811" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##811"[1] == :vect && (begin
                                        var"##812" = var"##811"[2]
                                        var"##812" isa AbstractArray
                                    end && ((ndims(var"##812") === 1 && length(var"##812") >= 0) && begin
                                            var"##813" = SubArray(var"##812", (1:length(var"##812"),))
                                            true
                                        end)))
                        args = var"##813"
                        var"##return#734" = begin
                                print_braces(args, "[", "]")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##814" = (var"##cache#737").value
                                var"##814" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##814"[1] == :hcat && (begin
                                        var"##815" = var"##814"[2]
                                        var"##815" isa AbstractArray
                                    end && ((ndims(var"##815") === 1 && length(var"##815") >= 0) && begin
                                            var"##816" = SubArray(var"##815", (1:length(var"##815"),))
                                            true
                                        end)))
                        args = var"##816"
                        var"##return#734" = begin
                                print_braces(args, "[", "]", " ")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##817" = (var"##cache#737").value
                                var"##817" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##817"[1] == :typed_hcat && (begin
                                        var"##818" = var"##817"[2]
                                        var"##818" isa AbstractArray
                                    end && ((ndims(var"##818") === 1 && length(var"##818") >= 1) && begin
                                            var"##819" = var"##818"[1]
                                            var"##820" = SubArray(var"##818", (2:length(var"##818"),))
                                            true
                                        end)))
                        args = var"##820"
                        t = var"##819"
                        var"##return#734" = begin
                                type(t)
                                print_braces(args, "[", "]", " ")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##821" = (var"##cache#737").value
                                var"##821" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##821"[1] == :vcat && (begin
                                        var"##822" = var"##821"[2]
                                        var"##822" isa AbstractArray
                                    end && ((ndims(var"##822") === 1 && length(var"##822") >= 0) && begin
                                            var"##823" = SubArray(var"##822", (1:length(var"##822"),))
                                            true
                                        end)))
                        args = var"##823"
                        var"##return#734" = begin
                                print_braces(args, "[", "]", "; ")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##824" = (var"##cache#737").value
                                var"##824" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##824"[1] == :ncat && (begin
                                        var"##825" = var"##824"[2]
                                        var"##825" isa AbstractArray
                                    end && ((ndims(var"##825") === 1 && length(var"##825") >= 1) && begin
                                            var"##826" = var"##825"[1]
                                            var"##827" = SubArray(var"##825", (2:length(var"##825"),))
                                            true
                                        end)))
                        n = var"##826"
                        args = var"##827"
                        var"##return#734" = begin
                                print_braces(args, "[", "]", ";" ^ n * " ")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##828" = (var"##cache#737").value
                                var"##828" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##828"[1] == :ref && (begin
                                        var"##829" = var"##828"[2]
                                        var"##829" isa AbstractArray
                                    end && ((ndims(var"##829") === 1 && length(var"##829") >= 1) && begin
                                            var"##830" = var"##829"[1]
                                            var"##831" = SubArray(var"##829", (2:length(var"##829"),))
                                            true
                                        end)))
                        args = var"##831"
                        object = var"##830"
                        var"##return#734" = begin
                                p(object)
                                print_braces(args, "[", "]")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##832" = (var"##cache#737").value
                                var"##832" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##832"[1] == :comprehension && (begin
                                        var"##833" = var"##832"[2]
                                        var"##833" isa AbstractArray
                                    end && (length(var"##833") === 1 && (begin
                                                begin
                                                    var"##cache#835" = nothing
                                                end
                                                var"##834" = var"##833"[1]
                                                var"##834" isa Expr
                                            end && (begin
                                                    if var"##cache#835" === nothing
                                                        var"##cache#835" = Some(((var"##834").head, (var"##834").args))
                                                    end
                                                    var"##836" = (var"##cache#835").value
                                                    var"##836" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##836"[1] == :generator && (begin
                                                            var"##837" = var"##836"[2]
                                                            var"##837" isa AbstractArray
                                                        end && (length(var"##837") === 2 && begin
                                                                var"##838" = var"##837"[1]
                                                                var"##839" = var"##837"[2]
                                                                true
                                                            end))))))))
                        iter = var"##838"
                        body = var"##839"
                        var"##return#734" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##840" = (var"##cache#737").value
                                var"##840" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##840"[1] == :typed_comprehension && (begin
                                        var"##841" = var"##840"[2]
                                        var"##841" isa AbstractArray
                                    end && (length(var"##841") === 2 && (begin
                                                var"##842" = var"##841"[1]
                                                begin
                                                    var"##cache#844" = nothing
                                                end
                                                var"##843" = var"##841"[2]
                                                var"##843" isa Expr
                                            end && (begin
                                                    if var"##cache#844" === nothing
                                                        var"##cache#844" = Some(((var"##843").head, (var"##843").args))
                                                    end
                                                    var"##845" = (var"##cache#844").value
                                                    var"##845" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##845"[1] == :generator && (begin
                                                            var"##846" = var"##845"[2]
                                                            var"##846" isa AbstractArray
                                                        end && (length(var"##846") === 2 && begin
                                                                var"##847" = var"##846"[1]
                                                                var"##848" = var"##846"[2]
                                                                true
                                                            end))))))))
                        iter = var"##847"
                        body = var"##848"
                        t = var"##842"
                        var"##return#734" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##849" = (var"##cache#737").value
                                var"##849" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##849"[1] == :-> && (begin
                                        var"##850" = var"##849"[2]
                                        var"##850" isa AbstractArray
                                    end && (length(var"##850") === 2 && (begin
                                                var"##851" = var"##850"[1]
                                                begin
                                                    var"##cache#853" = nothing
                                                end
                                                var"##852" = var"##850"[2]
                                                var"##852" isa Expr
                                            end && (begin
                                                    if var"##cache#853" === nothing
                                                        var"##cache#853" = Some(((var"##852").head, (var"##852").args))
                                                    end
                                                    var"##854" = (var"##cache#853").value
                                                    var"##854" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##854"[1] == :block && (begin
                                                            var"##855" = var"##854"[2]
                                                            var"##855" isa AbstractArray
                                                        end && (length(var"##855") === 2 && begin
                                                                var"##856" = var"##855"[1]
                                                                var"##857" = var"##855"[2]
                                                                true
                                                            end))))))))
                        line = var"##856"
                        code = var"##857"
                        args = var"##851"
                        var"##return#734" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##858" = (var"##cache#737").value
                                var"##858" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##858"[1] == :-> && (begin
                                        var"##859" = var"##858"[2]
                                        var"##859" isa AbstractArray
                                    end && (length(var"##859") === 2 && begin
                                            var"##860" = var"##859"[1]
                                            var"##861" = var"##859"[2]
                                            true
                                        end)))
                        args = var"##860"
                        body = var"##861"
                        var"##return#734" = begin
                                p(args)
                                keyword(" -> ")
                                print("(")
                                noblock(body)
                                print(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##862" = (var"##cache#737").value
                                var"##862" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##862"[1] == :do && (begin
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
                                                end && (var"##867"[1] == :-> && (begin
                                                            var"##868" = var"##867"[2]
                                                            var"##868" isa AbstractArray
                                                        end && (length(var"##868") === 2 && (begin
                                                                    begin
                                                                        var"##cache#870" = nothing
                                                                    end
                                                                    var"##869" = var"##868"[1]
                                                                    var"##869" isa Expr
                                                                end && (begin
                                                                        if var"##cache#870" === nothing
                                                                            var"##cache#870" = Some(((var"##869").head, (var"##869").args))
                                                                        end
                                                                        var"##871" = (var"##cache#870").value
                                                                        var"##871" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                    end && (var"##871"[1] == :tuple && (begin
                                                                                var"##872" = var"##871"[2]
                                                                                var"##872" isa AbstractArray
                                                                            end && ((ndims(var"##872") === 1 && length(var"##872") >= 0) && begin
                                                                                    var"##873" = SubArray(var"##872", (1:length(var"##872"),))
                                                                                    var"##874" = var"##868"[2]
                                                                                    true
                                                                                end)))))))))))))
                        call = var"##864"
                        args = var"##873"
                        body = var"##874"
                        var"##return#734" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##875" = (var"##cache#737").value
                                var"##875" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##875"[1] == :function && (begin
                                        var"##876" = var"##875"[2]
                                        var"##876" isa AbstractArray
                                    end && (length(var"##876") === 2 && begin
                                            var"##877" = var"##876"[1]
                                            var"##878" = var"##876"[2]
                                            true
                                        end)))
                        call = var"##877"
                        body = var"##878"
                        var"##return#734" = begin
                                print_function(:function, call, body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##879" = (var"##cache#737").value
                                var"##879" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##879"[1] == :quote && (begin
                                        var"##880" = var"##879"[2]
                                        var"##880" isa AbstractArray
                                    end && (length(var"##880") === 1 && begin
                                            var"##881" = var"##880"[1]
                                            true
                                        end)))
                        stmt = var"##881"
                        var"##return#734" = begin
                                keyword(":(")
                                noblock(stmt)
                                keyword(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##882" = (var"##cache#737").value
                                var"##882" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##882"[1] == :quote && (begin
                                        var"##883" = var"##882"[2]
                                        var"##883" isa AbstractArray
                                    end && ((ndims(var"##883") === 1 && length(var"##883") >= 0) && begin
                                            var"##884" = SubArray(var"##883", (1:length(var"##883"),))
                                            true
                                        end)))
                        args = var"##884"
                        var"##return#734" = begin
                                keyword("quote ")
                                with(p.state, :block, false) do 
                                    join(args, "; ")
                                end
                                keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##885" = (var"##cache#737").value
                                var"##885" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##885"[1] == :string && (begin
                                        var"##886" = var"##885"[2]
                                        var"##886" isa AbstractArray
                                    end && ((ndims(var"##886") === 1 && length(var"##886") >= 0) && begin
                                            var"##887" = SubArray(var"##886", (1:length(var"##886"),))
                                            true
                                        end)))
                        args = var"##887"
                        var"##return#734" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##888" = (var"##cache#737").value
                                var"##888" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##888"[1] == :block && (begin
                                        var"##889" = var"##888"[2]
                                        var"##889" isa AbstractArray
                                    end && ((ndims(var"##889") === 1 && length(var"##889") >= 0) && begin
                                            var"##890" = SubArray(var"##889", (1:length(var"##889"),))
                                            let args = var"##890"
                                                length(args) == 2 && (is_line_no(args[1]) && is_line_no(args[2]))
                                            end
                                        end)))
                        args = var"##890"
                        var"##return#734" = begin
                                p(args[1])
                                print(" ")
                                p(args[2])
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##891" = (var"##cache#737").value
                                var"##891" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##891"[1] == :block && (begin
                                        var"##892" = var"##891"[2]
                                        var"##892" isa AbstractArray
                                    end && ((ndims(var"##892") === 1 && length(var"##892") >= 0) && begin
                                            var"##893" = SubArray(var"##892", (1:length(var"##892"),))
                                            let args = var"##893"
                                                length(args) == 2 && is_line_no(args[1])
                                            end
                                        end)))
                        args = var"##893"
                        var"##return#734" = begin
                                p(args[1])
                                print(" ")
                                noblock(args[2])
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##894" = (var"##cache#737").value
                                var"##894" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##894"[1] == :block && (begin
                                        var"##895" = var"##894"[2]
                                        var"##895" isa AbstractArray
                                    end && ((ndims(var"##895") === 1 && length(var"##895") >= 0) && begin
                                            var"##896" = SubArray(var"##895", (1:length(var"##895"),))
                                            let args = var"##896"
                                                length(args) == 2 && is_line_no(args[2])
                                            end
                                        end)))
                        args = var"##896"
                        var"##return#734" = begin
                                noblock(args[1])
                                print(" ")
                                p(args[2])
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##897" = (var"##cache#737").value
                                var"##897" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##897"[1] == :block && (begin
                                        var"##898" = var"##897"[2]
                                        var"##898" isa AbstractArray
                                    end && ((ndims(var"##898") === 1 && length(var"##898") >= 0) && begin
                                            var"##899" = SubArray(var"##898", (1:length(var"##898"),))
                                            let args = var"##899"
                                                length(args) == 2
                                            end
                                        end)))
                        args = var"##899"
                        var"##return#734" = begin
                                print("(")
                                noblock(args[1])
                                keyword("; ")
                                noblock(args[2])
                                print(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##900" = (var"##cache#737").value
                                var"##900" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##900"[1] == :block && (begin
                                        var"##901" = var"##900"[2]
                                        var"##901" isa AbstractArray
                                    end && ((ndims(var"##901") === 1 && length(var"##901") >= 0) && begin
                                            var"##902" = SubArray(var"##901", (1:length(var"##901"),))
                                            true
                                        end)))
                        args = var"##902"
                        var"##return#734" = begin
                                p.state.block && keyword("begin ")
                                with(p.state, :block, true) do 
                                    join(args, "; ")
                                end
                                p.state.block && keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##903" = (var"##cache#737").value
                                var"##903" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##903"[1] == :let && (begin
                                        var"##904" = var"##903"[2]
                                        var"##904" isa AbstractArray
                                    end && (length(var"##904") === 2 && (begin
                                                begin
                                                    var"##cache#906" = nothing
                                                end
                                                var"##905" = var"##904"[1]
                                                var"##905" isa Expr
                                            end && (begin
                                                    if var"##cache#906" === nothing
                                                        var"##cache#906" = Some(((var"##905").head, (var"##905").args))
                                                    end
                                                    var"##907" = (var"##cache#906").value
                                                    var"##907" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##907"[1] == :block && (begin
                                                            var"##908" = var"##907"[2]
                                                            var"##908" isa AbstractArray
                                                        end && ((ndims(var"##908") === 1 && length(var"##908") >= 0) && begin
                                                                var"##909" = SubArray(var"##908", (1:length(var"##908"),))
                                                                var"##910" = var"##904"[2]
                                                                true
                                                            end))))))))
                        args = var"##909"
                        body = var"##910"
                        var"##return#734" = begin
                                keyword("let ")
                                join(args, ", ")
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##911" = (var"##cache#737").value
                                var"##911" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##911"[1] == :let && (begin
                                        var"##912" = var"##911"[2]
                                        var"##912" isa AbstractArray
                                    end && (length(var"##912") === 2 && begin
                                            var"##913" = var"##912"[1]
                                            var"##914" = var"##912"[2]
                                            true
                                        end)))
                        arg = var"##913"
                        body = var"##914"
                        var"##return#734" = begin
                                keyword("let ")
                                p(arg)
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##915" = (var"##cache#737").value
                                var"##915" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##915"[1] == :macrocall && (begin
                                        var"##916" = var"##915"[2]
                                        var"##916" isa AbstractArray
                                    end && ((ndims(var"##916") === 1 && length(var"##916") >= 2) && begin
                                            var"##917" = var"##916"[1]
                                            var"##918" = var"##916"[2]
                                            var"##919" = SubArray(var"##916", (3:length(var"##916"),))
                                            true
                                        end)))
                        f = var"##917"
                        line = var"##918"
                        args = var"##919"
                        var"##return#734" = begin
                                p.line && printstyled(line, color = c.comment)
                                macrocall(f)
                                print_braces(args, "(", ")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##920" = (var"##cache#737").value
                                var"##920" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##920"[1] == :return && (begin
                                        var"##921" = var"##920"[2]
                                        var"##921" isa AbstractArray
                                    end && (length(var"##921") === 1 && (begin
                                                begin
                                                    var"##cache#923" = nothing
                                                end
                                                var"##922" = var"##921"[1]
                                                var"##922" isa Expr
                                            end && (begin
                                                    if var"##cache#923" === nothing
                                                        var"##cache#923" = Some(((var"##922").head, (var"##922").args))
                                                    end
                                                    var"##924" = (var"##cache#923").value
                                                    var"##924" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##924"[1] == :tuple && (begin
                                                            var"##925" = var"##924"[2]
                                                            var"##925" isa AbstractArray
                                                        end && ((ndims(var"##925") === 1 && length(var"##925") >= 1) && (begin
                                                                    begin
                                                                        var"##cache#927" = nothing
                                                                    end
                                                                    var"##926" = var"##925"[1]
                                                                    var"##926" isa Expr
                                                                end && (begin
                                                                        if var"##cache#927" === nothing
                                                                            var"##cache#927" = Some(((var"##926").head, (var"##926").args))
                                                                        end
                                                                        var"##928" = (var"##cache#927").value
                                                                        var"##928" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                    end && (var"##928"[1] == :parameters && (begin
                                                                                var"##929" = var"##928"[2]
                                                                                var"##929" isa AbstractArray
                                                                            end && ((ndims(var"##929") === 1 && length(var"##929") >= 0) && begin
                                                                                    var"##930" = SubArray(var"##929", (1:length(var"##929"),))
                                                                                    var"##931" = SubArray(var"##925", (2:length(var"##925"),))
                                                                                    true
                                                                                end)))))))))))))
                        args = var"##931"
                        kwargs = var"##930"
                        var"##return#734" = begin
                                keyword("return ")
                                p(Expr(:tuple, Expr(:parameters, kwargs...), args...))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##932" = (var"##cache#737").value
                                var"##932" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##932"[1] == :return && (begin
                                        var"##933" = var"##932"[2]
                                        var"##933" isa AbstractArray
                                    end && (length(var"##933") === 1 && (begin
                                                begin
                                                    var"##cache#935" = nothing
                                                end
                                                var"##934" = var"##933"[1]
                                                var"##934" isa Expr
                                            end && (begin
                                                    if var"##cache#935" === nothing
                                                        var"##cache#935" = Some(((var"##934").head, (var"##934").args))
                                                    end
                                                    var"##936" = (var"##cache#935").value
                                                    var"##936" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##936"[1] == :tuple && (begin
                                                            var"##937" = var"##936"[2]
                                                            var"##937" isa AbstractArray
                                                        end && ((ndims(var"##937") === 1 && length(var"##937") >= 0) && begin
                                                                var"##938" = SubArray(var"##937", (1:length(var"##937"),))
                                                                true
                                                            end))))))))
                        args = var"##938"
                        var"##return#734" = begin
                                keyword("return ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##939" = (var"##cache#737").value
                                var"##939" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##939"[1] == :return && (begin
                                        var"##940" = var"##939"[2]
                                        var"##940" isa AbstractArray
                                    end && ((ndims(var"##940") === 1 && length(var"##940") >= 0) && begin
                                            var"##941" = SubArray(var"##940", (1:length(var"##940"),))
                                            true
                                        end)))
                        args = var"##941"
                        var"##return#734" = begin
                                keyword("return ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##942" = (var"##cache#737").value
                                var"##942" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##942"[1] == :module && (begin
                                        var"##943" = var"##942"[2]
                                        var"##943" isa AbstractArray
                                    end && (length(var"##943") === 3 && begin
                                            var"##944" = var"##943"[1]
                                            var"##945" = var"##943"[2]
                                            var"##946" = var"##943"[3]
                                            true
                                        end)))
                        bare = var"##944"
                        name = var"##945"
                        body = var"##946"
                        var"##return#734" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##947" = (var"##cache#737").value
                                var"##947" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##947"[1] == :using && (begin
                                        var"##948" = var"##947"[2]
                                        var"##948" isa AbstractArray
                                    end && ((ndims(var"##948") === 1 && length(var"##948") >= 0) && begin
                                            var"##949" = SubArray(var"##948", (1:length(var"##948"),))
                                            true
                                        end)))
                        args = var"##949"
                        var"##return#734" = begin
                                keyword("using ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##950" = (var"##cache#737").value
                                var"##950" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##950"[1] == :import && (begin
                                        var"##951" = var"##950"[2]
                                        var"##951" isa AbstractArray
                                    end && ((ndims(var"##951") === 1 && length(var"##951") >= 0) && begin
                                            var"##952" = SubArray(var"##951", (1:length(var"##951"),))
                                            true
                                        end)))
                        args = var"##952"
                        var"##return#734" = begin
                                keyword("import ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##953" = (var"##cache#737").value
                                var"##953" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##953"[1] == :as && (begin
                                        var"##954" = var"##953"[2]
                                        var"##954" isa AbstractArray
                                    end && (length(var"##954") === 2 && begin
                                            var"##955" = var"##954"[1]
                                            var"##956" = var"##954"[2]
                                            true
                                        end)))
                        name = var"##955"
                        alias = var"##956"
                        var"##return#734" = begin
                                p(name)
                                keyword(" as ")
                                p(alias)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##957" = (var"##cache#737").value
                                var"##957" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##957"[1] == :export && (begin
                                        var"##958" = var"##957"[2]
                                        var"##958" isa AbstractArray
                                    end && ((ndims(var"##958") === 1 && length(var"##958") >= 0) && begin
                                            var"##959" = SubArray(var"##958", (1:length(var"##958"),))
                                            true
                                        end)))
                        args = var"##959"
                        var"##return#734" = begin
                                keyword("export ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##960" = (var"##cache#737").value
                                var"##960" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##960"[1] == :(:) && (begin
                                        var"##961" = var"##960"[2]
                                        var"##961" isa AbstractArray
                                    end && ((ndims(var"##961") === 1 && length(var"##961") >= 1) && begin
                                            var"##962" = var"##961"[1]
                                            var"##963" = SubArray(var"##961", (2:length(var"##961"),))
                                            true
                                        end)))
                        args = var"##963"
                        head = var"##962"
                        var"##return#734" = begin
                                p(head)
                                keyword(": ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##964" = (var"##cache#737").value
                                var"##964" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##964"[1] == :where && (begin
                                        var"##965" = var"##964"[2]
                                        var"##965" isa AbstractArray
                                    end && ((ndims(var"##965") === 1 && length(var"##965") >= 1) && begin
                                            var"##966" = var"##965"[1]
                                            var"##967" = SubArray(var"##965", (2:length(var"##965"),))
                                            true
                                        end)))
                        body = var"##966"
                        whereparams = var"##967"
                        var"##return#734" = begin
                                p(body)
                                keyword(" where {")
                                with(p.state, :type, true) do 
                                    join(whereparams, ", ")
                                end
                                keyword("}")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##968" = (var"##cache#737").value
                                var"##968" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##968"[1] == :for && (begin
                                        var"##969" = var"##968"[2]
                                        var"##969" isa AbstractArray
                                    end && (length(var"##969") === 2 && begin
                                            var"##970" = var"##969"[1]
                                            var"##971" = var"##969"[2]
                                            true
                                        end)))
                        body = var"##971"
                        iteration = var"##970"
                        var"##return#734" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##972" = (var"##cache#737").value
                                var"##972" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##972"[1] == :while && (begin
                                        var"##973" = var"##972"[2]
                                        var"##973" isa AbstractArray
                                    end && (length(var"##973") === 2 && begin
                                            var"##974" = var"##973"[1]
                                            var"##975" = var"##973"[2]
                                            true
                                        end)))
                        body = var"##975"
                        condition = var"##974"
                        var"##return#734" = begin
                                keyword("while ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##976" = (var"##cache#737").value
                                var"##976" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##976"[1] == :continue && (begin
                                        var"##977" = var"##976"[2]
                                        var"##977" isa AbstractArray
                                    end && isempty(var"##977")))
                        var"##return#734" = begin
                                keyword("continue")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##978" = (var"##cache#737").value
                                var"##978" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##978"[1] == :if && (begin
                                        var"##979" = var"##978"[2]
                                        var"##979" isa AbstractArray
                                    end && (length(var"##979") === 2 && begin
                                            var"##980" = var"##979"[1]
                                            var"##981" = var"##979"[2]
                                            true
                                        end)))
                        body = var"##981"
                        condition = var"##980"
                        var"##return#734" = begin
                                keyword("if ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##982" = (var"##cache#737").value
                                var"##982" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##982"[1] == :if && (begin
                                        var"##983" = var"##982"[2]
                                        var"##983" isa AbstractArray
                                    end && (length(var"##983") === 3 && begin
                                            var"##984" = var"##983"[1]
                                            var"##985" = var"##983"[2]
                                            var"##986" = var"##983"[3]
                                            true
                                        end)))
                        body = var"##985"
                        elsebody = var"##986"
                        condition = var"##984"
                        var"##return#734" = begin
                                keyword("if ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                                keyword("; ")
                                Meta.isexpr(elsebody, :elseif) || keyword("else ")
                                noblock(elsebody)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##987" = (var"##cache#737").value
                                var"##987" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##987"[1] == :elseif && (begin
                                        var"##988" = var"##987"[2]
                                        var"##988" isa AbstractArray
                                    end && (length(var"##988") === 2 && begin
                                            var"##989" = var"##988"[1]
                                            var"##990" = var"##988"[2]
                                            true
                                        end)))
                        body = var"##990"
                        condition = var"##989"
                        var"##return#734" = begin
                                keyword("elseif ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##991" = (var"##cache#737").value
                                var"##991" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##991"[1] == :elseif && (begin
                                        var"##992" = var"##991"[2]
                                        var"##992" isa AbstractArray
                                    end && (length(var"##992") === 3 && begin
                                            var"##993" = var"##992"[1]
                                            var"##994" = var"##992"[2]
                                            var"##995" = var"##992"[3]
                                            true
                                        end)))
                        body = var"##994"
                        elsebody = var"##995"
                        condition = var"##993"
                        var"##return#734" = begin
                                keyword("elseif ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                                keyword("; ")
                                Meta.isexpr(elsebody, :elseif) || keyword("else")
                                noblock(elsebody)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##996" = (var"##cache#737").value
                                var"##996" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##996"[1] == :try && (begin
                                        var"##997" = var"##996"[2]
                                        var"##997" isa AbstractArray
                                    end && (length(var"##997") === 3 && begin
                                            var"##998" = var"##997"[1]
                                            var"##999" = var"##997"[2]
                                            var"##1000" = var"##997"[3]
                                            true
                                        end)))
                        catch_vars = var"##999"
                        catch_body = var"##1000"
                        try_body = var"##998"
                        var"##return#734" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##1001" = (var"##cache#737").value
                                var"##1001" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1001"[1] == :try && (begin
                                        var"##1002" = var"##1001"[2]
                                        var"##1002" isa AbstractArray
                                    end && (length(var"##1002") === 4 && begin
                                            var"##1003" = var"##1002"[1]
                                            var"##1004" = var"##1002"[2]
                                            var"##1005" = var"##1002"[3]
                                            var"##1006" = var"##1002"[4]
                                            true
                                        end)))
                        catch_vars = var"##1004"
                        catch_body = var"##1005"
                        try_body = var"##1003"
                        finally_body = var"##1006"
                        var"##return#734" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##1007" = (var"##cache#737").value
                                var"##1007" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1007"[1] == :try && (begin
                                        var"##1008" = var"##1007"[2]
                                        var"##1008" isa AbstractArray
                                    end && (length(var"##1008") === 5 && begin
                                            var"##1009" = var"##1008"[1]
                                            var"##1010" = var"##1008"[2]
                                            var"##1011" = var"##1008"[3]
                                            var"##1012" = var"##1008"[4]
                                            var"##1013" = var"##1008"[5]
                                            true
                                        end)))
                        catch_vars = var"##1010"
                        catch_body = var"##1011"
                        try_body = var"##1009"
                        finally_body = var"##1012"
                        else_body = var"##1013"
                        var"##return#734" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##1014" = (var"##cache#737").value
                                var"##1014" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1014"[1] == :struct && (begin
                                        var"##1015" = var"##1014"[2]
                                        var"##1015" isa AbstractArray
                                    end && (length(var"##1015") === 3 && begin
                                            var"##1016" = var"##1015"[1]
                                            var"##1017" = var"##1015"[2]
                                            var"##1018" = var"##1015"[3]
                                            true
                                        end)))
                        ismutable = var"##1016"
                        name = var"##1017"
                        body = var"##1018"
                        var"##return#734" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##1019" = (var"##cache#737").value
                                var"##1019" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1019"[1] == :abstract && (begin
                                        var"##1020" = var"##1019"[2]
                                        var"##1020" isa AbstractArray
                                    end && (length(var"##1020") === 1 && begin
                                            var"##1021" = var"##1020"[1]
                                            true
                                        end)))
                        name = var"##1021"
                        var"##return#734" = begin
                                keyword("abstract type ")
                                p(name)
                                keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##1022" = (var"##cache#737").value
                                var"##1022" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1022"[1] == :primitive && (begin
                                        var"##1023" = var"##1022"[2]
                                        var"##1023" isa AbstractArray
                                    end && (length(var"##1023") === 2 && begin
                                            var"##1024" = var"##1023"[1]
                                            var"##1025" = var"##1023"[2]
                                            true
                                        end)))
                        name = var"##1024"
                        size = var"##1025"
                        var"##return#734" = begin
                                keyword("primitive type ")
                                p(name)
                                print(" ")
                                p(size)
                                keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##1026" = (var"##cache#737").value
                                var"##1026" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1026"[1] == :meta && (begin
                                        var"##1027" = var"##1026"[2]
                                        var"##1027" isa AbstractArray
                                    end && (length(var"##1027") === 1 && var"##1027"[1] == :inline)))
                        var"##return#734" = begin
                                macrocall(GlobalRef(Base, Symbol("@_inline_meta")))
                                keyword(";")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##1028" = (var"##cache#737").value
                                var"##1028" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1028"[1] == :break && (begin
                                        var"##1029" = var"##1028"[2]
                                        var"##1029" isa AbstractArray
                                    end && isempty(var"##1029")))
                        var"##return#734" = begin
                                keyword("break")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##1030" = (var"##cache#737").value
                                var"##1030" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1030"[1] == :symboliclabel && (begin
                                        var"##1031" = var"##1030"[2]
                                        var"##1031" isa AbstractArray
                                    end && (length(var"##1031") === 1 && begin
                                            var"##1032" = var"##1031"[1]
                                            true
                                        end)))
                        label = var"##1032"
                        var"##return#734" = begin
                                macrocall(GlobalRef(Base, Symbol("@label")))
                                print(" ")
                                p(label)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##1033" = (var"##cache#737").value
                                var"##1033" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1033"[1] == :symbolicgoto && (begin
                                        var"##1034" = var"##1033"[2]
                                        var"##1034" isa AbstractArray
                                    end && (length(var"##1034") === 1 && begin
                                            var"##1035" = var"##1034"[1]
                                            true
                                        end)))
                        label = var"##1035"
                        var"##return#734" = begin
                                macrocall(GlobalRef(Base, Symbol("@goto")))
                                print(" ")
                                p(label)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    if begin
                                var"##1036" = (var"##cache#737").value
                                var"##1036" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1037" = var"##1036"[1]
                                    var"##1038" = var"##1036"[2]
                                    var"##1038" isa AbstractArray
                                end && ((ndims(var"##1038") === 1 && length(var"##1038") >= 0) && begin
                                        var"##1039" = SubArray(var"##1038", (1:length(var"##1038"),))
                                        true
                                    end))
                        args = var"##1039"
                        head = var"##1037"
                        var"##return#734" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                end
                if var"##736" isa QuoteNode
                    if ex.value in Base.quoted_syms
                        var"##return#734" = begin
                                keyword(":(")
                                quoted(ex.value)
                                keyword(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                    begin
                        var"##return#734" = begin
                                if ex.value isa Symbol && Base.isidentifier(ex.value)
                                    keyword(":")
                                    quoted(ex.value)
                                else
                                    keyword(":(")
                                    quoted(ex.value)
                                    keyword(")")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                end
                if var"##736" isa String
                    begin
                        var"##return#734" = begin
                                string(ex)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                end
                if var"##736" isa Number
                    begin
                        var"##return#734" = begin
                                printstyled(ex, color = c.number)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                end
                if var"##736" isa LineNumberNode
                    begin
                        var"##return#734" = begin
                                p.line || return nothing
                                printstyled("#= $(ex.file):$(ex.line) =#", color = c.line)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                    end
                end
                begin
                    var"##return#734" = begin
                            print(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#735#1040")))
                end
                error("matching non-exhaustive, at #= none:142 =#")
                $(Expr(:symboliclabel, Symbol("####final#735#1040")))
                var"##return#734"
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
