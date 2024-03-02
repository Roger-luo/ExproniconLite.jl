
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
                        var"##cache#726" = nothing
                    end
                    var"##return#723" = nothing
                    var"##725" = ex
                    if var"##725" isa Expr
                        if begin
                                    if var"##cache#726" === nothing
                                        var"##cache#726" = Some(((var"##725").head, (var"##725").args))
                                    end
                                    var"##727" = (var"##cache#726").value
                                    var"##727" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##727"[1] == :. && (begin
                                            var"##728" = var"##727"[2]
                                            var"##728" isa AbstractArray
                                        end && (ndims(var"##728") === 1 && length(var"##728") >= 0)))
                            var"##return#723" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#724#729")))
                        end
                    end
                    if var"##725" isa Symbol
                        begin
                            var"##return#723" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#724#729")))
                        end
                    end
                    begin
                        var"##return#723" = let
                                false
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#724#729")))
                    end
                    error("matching non-exhaustive, at #= none:85 =#")
                    $(Expr(:symboliclabel, Symbol("####final#724#729")))
                    var"##return#723"
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
                    var"##cache#733" = nothing
                end
                var"##732" = ex
                if var"##732" isa Expr && (begin
                                if var"##cache#733" === nothing
                                    var"##cache#733" = Some(((var"##732").head, (var"##732").args))
                                end
                                var"##734" = (var"##cache#733").value
                                var"##734" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##734"[1] == :call && (begin
                                        var"##735" = var"##734"[2]
                                        var"##735" isa AbstractArray
                                    end && ((ndims(var"##735") === 1 && length(var"##735") >= 1) && (var"##735"[1] == :(:) && begin
                                                var"##736" = SubArray(var"##735", (2:length(var"##735"),))
                                                true
                                            end)))))
                    args = var"##736"
                    var"##return#730" = begin
                            precedence(:(:)) do 
                                join(args, ":")
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#731#758")))
                end
                if var"##732" isa Expr && (begin
                                if var"##cache#733" === nothing
                                    var"##cache#733" = Some(((var"##732").head, (var"##732").args))
                                end
                                var"##737" = (var"##cache#733").value
                                var"##737" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##737"[1] == :call && (begin
                                        var"##738" = var"##737"[2]
                                        var"##738" isa AbstractArray
                                    end && (length(var"##738") === 2 && (begin
                                                var"##739" = var"##738"[1]
                                                var"##739" isa Symbol
                                            end && begin
                                                var"##740" = var"##738"[2]
                                                let f = var"##739", arg = var"##740"
                                                    Base.isunaryoperator(f)
                                                end
                                            end)))))
                    f = var"##739"
                    arg = var"##740"
                    var"##return#730" = begin
                            precedence(typemax(Int)) do 
                                keyword(f)
                                p(arg)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#731#758")))
                end
                if var"##732" isa Expr && (begin
                                if var"##cache#733" === nothing
                                    var"##cache#733" = Some(((var"##732").head, (var"##732").args))
                                end
                                var"##741" = (var"##cache#733").value
                                var"##741" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##741"[1] == :call && (begin
                                        var"##742" = var"##741"[2]
                                        var"##742" isa AbstractArray
                                    end && ((ndims(var"##742") === 1 && length(var"##742") >= 1) && (begin
                                                var"##743" = var"##742"[1]
                                                var"##743" isa Symbol
                                            end && begin
                                                var"##744" = SubArray(var"##742", (2:length(var"##742"),))
                                                let f = var"##743", args = var"##744"
                                                    Base.isbinaryoperator(f)
                                                end
                                            end)))))
                    f = var"##743"
                    args = var"##744"
                    var"##return#730" = begin
                            precedence(f) do 
                                join(args, " $(f) ")
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#731#758")))
                end
                if var"##732" isa Expr && (begin
                                if var"##cache#733" === nothing
                                    var"##cache#733" = Some(((var"##732").head, (var"##732").args))
                                end
                                var"##745" = (var"##cache#733").value
                                var"##745" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##745"[1] == :call && (begin
                                        var"##746" = var"##745"[2]
                                        var"##746" isa AbstractArray
                                    end && ((ndims(var"##746") === 1 && length(var"##746") >= 2) && (begin
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
                                                end && (var"##750"[1] == :parameters && (begin
                                                            var"##751" = var"##750"[2]
                                                            var"##751" isa AbstractArray
                                                        end && ((ndims(var"##751") === 1 && length(var"##751") >= 0) && begin
                                                                var"##752" = SubArray(var"##751", (1:length(var"##751"),))
                                                                var"##753" = SubArray(var"##746", (3:length(var"##746"),))
                                                                true
                                                            end)))))))))
                    f = var"##747"
                    args = var"##753"
                    kwargs = var"##752"
                    var"##return#730" = begin
                            call(f)
                            print("(")
                            join(args)
                            keyword("; ")
                            join(kwargs)
                            print(")")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#731#758")))
                end
                if var"##732" isa Expr && (begin
                                if var"##cache#733" === nothing
                                    var"##cache#733" = Some(((var"##732").head, (var"##732").args))
                                end
                                var"##754" = (var"##cache#733").value
                                var"##754" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##754"[1] == :call && (begin
                                        var"##755" = var"##754"[2]
                                        var"##755" isa AbstractArray
                                    end && ((ndims(var"##755") === 1 && length(var"##755") >= 1) && begin
                                            var"##756" = var"##755"[1]
                                            var"##757" = SubArray(var"##755", (2:length(var"##755"),))
                                            true
                                        end))))
                    f = var"##756"
                    args = var"##757"
                    var"##return#730" = begin
                            call(f)
                            print_braces(args, "(", ")")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#731#758")))
                end
                error("matching non-exhaustive, at #= none:111 =#")
                $(Expr(:symboliclabel, Symbol("####final#731#758")))
                var"##return#730"
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
                    var"##cache#762" = nothing
                end
                var"##761" = ex
                if var"##761" isa Char
                    begin
                        var"##return#759" = begin
                                printstyled(repr(ex), color = c.string)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                end
                if var"##761" isa Nothing
                    begin
                        var"##return#759" = begin
                                printstyled("nothing", color = c.number)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                end
                if var"##761" isa Symbol
                    begin
                        var"##return#759" = begin
                                symbol(ex)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                end
                if var"##761" isa Expr
                    if begin
                                if var"##cache#762" === nothing
                                    var"##cache#762" = Some(((var"##761").head, (var"##761").args))
                                end
                                var"##763" = (var"##cache#762").value
                                var"##763" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##763"[1] == :line && (begin
                                        var"##764" = var"##763"[2]
                                        var"##764" isa AbstractArray
                                    end && (length(var"##764") === 2 && begin
                                            var"##765" = var"##764"[1]
                                            var"##766" = var"##764"[2]
                                            true
                                        end)))
                        line = var"##766"
                        file = var"##765"
                        var"##return#759" = begin
                                p.line || return nothing
                                printstyled("#= $(file):$(line) =#", color = c.line)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##767" = (var"##cache#762").value
                                var"##767" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##767"[1] == :kw && (begin
                                        var"##768" = var"##767"[2]
                                        var"##768" isa AbstractArray
                                    end && (length(var"##768") === 2 && begin
                                            var"##769" = var"##768"[1]
                                            var"##770" = var"##768"[2]
                                            true
                                        end)))
                        k = var"##769"
                        v = var"##770"
                        var"##return#759" = begin
                                p(k)
                                print(" = ")
                                p(v)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##771" = (var"##cache#762").value
                                var"##771" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##771"[1] == :(=) && (begin
                                        var"##772" = var"##771"[2]
                                        var"##772" isa AbstractArray
                                    end && (length(var"##772") === 2 && (begin
                                                var"##773" = var"##772"[1]
                                                begin
                                                    var"##cache#775" = nothing
                                                end
                                                var"##774" = var"##772"[2]
                                                var"##774" isa Expr
                                            end && (begin
                                                    if var"##cache#775" === nothing
                                                        var"##cache#775" = Some(((var"##774").head, (var"##774").args))
                                                    end
                                                    var"##776" = (var"##cache#775").value
                                                    var"##776" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##776"[1] == :block && (begin
                                                            var"##777" = var"##776"[2]
                                                            var"##777" isa AbstractArray
                                                        end && ((ndims(var"##777") === 1 && length(var"##777") >= 0) && begin
                                                                var"##778" = SubArray(var"##777", (1:length(var"##777"),))
                                                                true
                                                            end))))))))
                        k = var"##773"
                        stmts = var"##778"
                        var"##return#759" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##779" = (var"##cache#762").value
                                var"##779" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##779"[1] == :(=) && (begin
                                        var"##780" = var"##779"[2]
                                        var"##780" isa AbstractArray
                                    end && (length(var"##780") === 2 && begin
                                            var"##781" = var"##780"[1]
                                            var"##782" = var"##780"[2]
                                            true
                                        end)))
                        k = var"##781"
                        v = var"##782"
                        var"##return#759" = begin
                                precedence(:(=)) do 
                                    p(k)
                                    assign()
                                    p(v)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##783" = (var"##cache#762").value
                                var"##783" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##783"[1] == :... && (begin
                                        var"##784" = var"##783"[2]
                                        var"##784" isa AbstractArray
                                    end && (length(var"##784") === 1 && begin
                                            var"##785" = var"##784"[1]
                                            true
                                        end)))
                        name = var"##785"
                        var"##return#759" = begin
                                precedence(:...) do 
                                    p(name)
                                    keyword("...")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##786" = (var"##cache#762").value
                                var"##786" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##786"[1] == :& && (begin
                                        var"##787" = var"##786"[2]
                                        var"##787" isa AbstractArray
                                    end && (length(var"##787") === 1 && begin
                                            var"##788" = var"##787"[1]
                                            true
                                        end)))
                        name = var"##788"
                        var"##return#759" = begin
                                precedence(:&) do 
                                    keyword("&")
                                    p(name)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##789" = (var"##cache#762").value
                                var"##789" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##789"[1] == :(::) && (begin
                                        var"##790" = var"##789"[2]
                                        var"##790" isa AbstractArray
                                    end && (length(var"##790") === 1 && begin
                                            var"##791" = var"##790"[1]
                                            true
                                        end)))
                        t = var"##791"
                        var"##return#759" = begin
                                precedence(:(::)) do 
                                    keyword("::")
                                    type(t)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##792" = (var"##cache#762").value
                                var"##792" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##792"[1] == :(::) && (begin
                                        var"##793" = var"##792"[2]
                                        var"##793" isa AbstractArray
                                    end && (length(var"##793") === 2 && begin
                                            var"##794" = var"##793"[1]
                                            var"##795" = var"##793"[2]
                                            true
                                        end)))
                        name = var"##794"
                        t = var"##795"
                        var"##return#759" = begin
                                precedence(:(::)) do 
                                    p(name)
                                    keyword("::")
                                    type(t)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##796" = (var"##cache#762").value
                                var"##796" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##796"[1] == :$ && (begin
                                        var"##797" = var"##796"[2]
                                        var"##797" isa AbstractArray
                                    end && (length(var"##797") === 1 && begin
                                            var"##798" = var"##797"[1]
                                            true
                                        end)))
                        name = var"##798"
                        var"##return#759" = begin
                                precedence(:$) do 
                                    keyword('$')
                                    print("(")
                                    p(name)
                                    print(")")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##799" = (var"##cache#762").value
                                var"##799" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##800" = var"##799"[1]
                                    var"##801" = var"##799"[2]
                                    var"##801" isa AbstractArray
                                end && (length(var"##801") === 2 && begin
                                        var"##802" = var"##801"[1]
                                        var"##803" = var"##801"[2]
                                        let rhs = var"##803", lhs = var"##802", head = var"##800"
                                            head in expr_infix_wide
                                        end
                                    end))
                        rhs = var"##803"
                        lhs = var"##802"
                        head = var"##800"
                        var"##return#759" = begin
                                precedence(head) do 
                                    p(lhs)
                                    keyword(" $(head) ")
                                    p(rhs)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##804" = (var"##cache#762").value
                                var"##804" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##804"[1] == :. && (begin
                                        var"##805" = var"##804"[2]
                                        var"##805" isa AbstractArray
                                    end && (length(var"##805") === 1 && begin
                                            var"##806" = var"##805"[1]
                                            true
                                        end)))
                        name = var"##806"
                        var"##return#759" = begin
                                print(name)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##807" = (var"##cache#762").value
                                var"##807" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##807"[1] == :. && (begin
                                        var"##808" = var"##807"[2]
                                        var"##808" isa AbstractArray
                                    end && (length(var"##808") === 2 && (begin
                                                var"##809" = var"##808"[1]
                                                var"##810" = var"##808"[2]
                                                var"##810" isa QuoteNode
                                            end && begin
                                                var"##811" = (var"##810").value
                                                true
                                            end))))
                        name = var"##811"
                        object = var"##809"
                        var"##return#759" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##812" = (var"##cache#762").value
                                var"##812" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##812"[1] == :. && (begin
                                        var"##813" = var"##812"[2]
                                        var"##813" isa AbstractArray
                                    end && (length(var"##813") === 2 && begin
                                            var"##814" = var"##813"[1]
                                            var"##815" = var"##813"[2]
                                            true
                                        end)))
                        name = var"##815"
                        object = var"##814"
                        var"##return#759" = begin
                                precedence(:.) do 
                                    p(object)
                                    keyword(".")
                                    p(name)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##816" = (var"##cache#762").value
                                var"##816" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##816"[1] == :<: && (begin
                                        var"##817" = var"##816"[2]
                                        var"##817" isa AbstractArray
                                    end && (length(var"##817") === 2 && begin
                                            var"##818" = var"##817"[1]
                                            var"##819" = var"##817"[2]
                                            true
                                        end)))
                        type = var"##818"
                        supertype = var"##819"
                        var"##return#759" = begin
                                precedence(:<:) do 
                                    p(type)
                                    keyword(" <: ")
                                    p(supertype)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##820" = (var"##cache#762").value
                                var"##820" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##820"[1] == :call && (begin
                                        var"##821" = var"##820"[2]
                                        var"##821" isa AbstractArray
                                    end && (ndims(var"##821") === 1 && length(var"##821") >= 0)))
                        var"##return#759" = begin
                                print_call(ex)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##822" = (var"##cache#762").value
                                var"##822" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##822"[1] == :tuple && (begin
                                        var"##823" = var"##822"[2]
                                        var"##823" isa AbstractArray
                                    end && (length(var"##823") === 1 && (begin
                                                begin
                                                    var"##cache#825" = nothing
                                                end
                                                var"##824" = var"##823"[1]
                                                var"##824" isa Expr
                                            end && (begin
                                                    if var"##cache#825" === nothing
                                                        var"##cache#825" = Some(((var"##824").head, (var"##824").args))
                                                    end
                                                    var"##826" = (var"##cache#825").value
                                                    var"##826" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##826"[1] == :parameters && (begin
                                                            var"##827" = var"##826"[2]
                                                            var"##827" isa AbstractArray
                                                        end && ((ndims(var"##827") === 1 && length(var"##827") >= 0) && begin
                                                                var"##828" = SubArray(var"##827", (1:length(var"##827"),))
                                                                true
                                                            end))))))))
                        args = var"##828"
                        var"##return#759" = begin
                                print_braces(args, "(;", ")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##829" = (var"##cache#762").value
                                var"##829" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##829"[1] == :tuple && (begin
                                        var"##830" = var"##829"[2]
                                        var"##830" isa AbstractArray
                                    end && ((ndims(var"##830") === 1 && length(var"##830") >= 0) && begin
                                            var"##831" = SubArray(var"##830", (1:length(var"##830"),))
                                            true
                                        end)))
                        args = var"##831"
                        var"##return#759" = begin
                                if length(args) == 1
                                    print("(")
                                    p(args[1])
                                    print(",)")
                                else
                                    print_braces(args, "(", ")")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##832" = (var"##cache#762").value
                                var"##832" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##832"[1] == :curly && (begin
                                        var"##833" = var"##832"[2]
                                        var"##833" isa AbstractArray
                                    end && ((ndims(var"##833") === 1 && length(var"##833") >= 1) && begin
                                            var"##834" = var"##833"[1]
                                            var"##835" = SubArray(var"##833", (2:length(var"##833"),))
                                            true
                                        end)))
                        args = var"##835"
                        t = var"##834"
                        var"##return#759" = begin
                                with(p.state, :type, true) do 
                                    p(t)
                                    print_braces(args, "{", "}")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##836" = (var"##cache#762").value
                                var"##836" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##836"[1] == :vect && (begin
                                        var"##837" = var"##836"[2]
                                        var"##837" isa AbstractArray
                                    end && ((ndims(var"##837") === 1 && length(var"##837") >= 0) && begin
                                            var"##838" = SubArray(var"##837", (1:length(var"##837"),))
                                            true
                                        end)))
                        args = var"##838"
                        var"##return#759" = begin
                                print_braces(args, "[", "]")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##839" = (var"##cache#762").value
                                var"##839" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##839"[1] == :hcat && (begin
                                        var"##840" = var"##839"[2]
                                        var"##840" isa AbstractArray
                                    end && ((ndims(var"##840") === 1 && length(var"##840") >= 0) && begin
                                            var"##841" = SubArray(var"##840", (1:length(var"##840"),))
                                            true
                                        end)))
                        args = var"##841"
                        var"##return#759" = begin
                                print_braces(args, "[", "]", " ")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##842" = (var"##cache#762").value
                                var"##842" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##842"[1] == :typed_hcat && (begin
                                        var"##843" = var"##842"[2]
                                        var"##843" isa AbstractArray
                                    end && ((ndims(var"##843") === 1 && length(var"##843") >= 1) && begin
                                            var"##844" = var"##843"[1]
                                            var"##845" = SubArray(var"##843", (2:length(var"##843"),))
                                            true
                                        end)))
                        args = var"##845"
                        t = var"##844"
                        var"##return#759" = begin
                                type(t)
                                print_braces(args, "[", "]", " ")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##846" = (var"##cache#762").value
                                var"##846" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##846"[1] == :vcat && (begin
                                        var"##847" = var"##846"[2]
                                        var"##847" isa AbstractArray
                                    end && ((ndims(var"##847") === 1 && length(var"##847") >= 0) && begin
                                            var"##848" = SubArray(var"##847", (1:length(var"##847"),))
                                            true
                                        end)))
                        args = var"##848"
                        var"##return#759" = begin
                                print_braces(args, "[", "]", "; ")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##849" = (var"##cache#762").value
                                var"##849" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##849"[1] == :ncat && (begin
                                        var"##850" = var"##849"[2]
                                        var"##850" isa AbstractArray
                                    end && ((ndims(var"##850") === 1 && length(var"##850") >= 1) && begin
                                            var"##851" = var"##850"[1]
                                            var"##852" = SubArray(var"##850", (2:length(var"##850"),))
                                            true
                                        end)))
                        n = var"##851"
                        args = var"##852"
                        var"##return#759" = begin
                                print_braces(args, "[", "]", ";" ^ n * " ")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##853" = (var"##cache#762").value
                                var"##853" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##853"[1] == :ref && (begin
                                        var"##854" = var"##853"[2]
                                        var"##854" isa AbstractArray
                                    end && ((ndims(var"##854") === 1 && length(var"##854") >= 1) && begin
                                            var"##855" = var"##854"[1]
                                            var"##856" = SubArray(var"##854", (2:length(var"##854"),))
                                            true
                                        end)))
                        args = var"##856"
                        object = var"##855"
                        var"##return#759" = begin
                                p(object)
                                print_braces(args, "[", "]")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##857" = (var"##cache#762").value
                                var"##857" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##857"[1] == :comprehension && (begin
                                        var"##858" = var"##857"[2]
                                        var"##858" isa AbstractArray
                                    end && (length(var"##858") === 1 && (begin
                                                begin
                                                    var"##cache#860" = nothing
                                                end
                                                var"##859" = var"##858"[1]
                                                var"##859" isa Expr
                                            end && (begin
                                                    if var"##cache#860" === nothing
                                                        var"##cache#860" = Some(((var"##859").head, (var"##859").args))
                                                    end
                                                    var"##861" = (var"##cache#860").value
                                                    var"##861" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##861"[1] == :generator && (begin
                                                            var"##862" = var"##861"[2]
                                                            var"##862" isa AbstractArray
                                                        end && (length(var"##862") === 2 && begin
                                                                var"##863" = var"##862"[1]
                                                                var"##864" = var"##862"[2]
                                                                true
                                                            end))))))))
                        iter = var"##863"
                        body = var"##864"
                        var"##return#759" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##865" = (var"##cache#762").value
                                var"##865" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##865"[1] == :typed_comprehension && (begin
                                        var"##866" = var"##865"[2]
                                        var"##866" isa AbstractArray
                                    end && (length(var"##866") === 2 && (begin
                                                var"##867" = var"##866"[1]
                                                begin
                                                    var"##cache#869" = nothing
                                                end
                                                var"##868" = var"##866"[2]
                                                var"##868" isa Expr
                                            end && (begin
                                                    if var"##cache#869" === nothing
                                                        var"##cache#869" = Some(((var"##868").head, (var"##868").args))
                                                    end
                                                    var"##870" = (var"##cache#869").value
                                                    var"##870" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##870"[1] == :generator && (begin
                                                            var"##871" = var"##870"[2]
                                                            var"##871" isa AbstractArray
                                                        end && (length(var"##871") === 2 && begin
                                                                var"##872" = var"##871"[1]
                                                                var"##873" = var"##871"[2]
                                                                true
                                                            end))))))))
                        iter = var"##872"
                        body = var"##873"
                        t = var"##867"
                        var"##return#759" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##874" = (var"##cache#762").value
                                var"##874" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##874"[1] == :-> && (begin
                                        var"##875" = var"##874"[2]
                                        var"##875" isa AbstractArray
                                    end && (length(var"##875") === 2 && (begin
                                                var"##876" = var"##875"[1]
                                                begin
                                                    var"##cache#878" = nothing
                                                end
                                                var"##877" = var"##875"[2]
                                                var"##877" isa Expr
                                            end && (begin
                                                    if var"##cache#878" === nothing
                                                        var"##cache#878" = Some(((var"##877").head, (var"##877").args))
                                                    end
                                                    var"##879" = (var"##cache#878").value
                                                    var"##879" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##879"[1] == :block && (begin
                                                            var"##880" = var"##879"[2]
                                                            var"##880" isa AbstractArray
                                                        end && (length(var"##880") === 2 && begin
                                                                var"##881" = var"##880"[1]
                                                                var"##882" = var"##880"[2]
                                                                true
                                                            end))))))))
                        line = var"##881"
                        code = var"##882"
                        args = var"##876"
                        var"##return#759" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##883" = (var"##cache#762").value
                                var"##883" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##883"[1] == :-> && (begin
                                        var"##884" = var"##883"[2]
                                        var"##884" isa AbstractArray
                                    end && (length(var"##884") === 2 && begin
                                            var"##885" = var"##884"[1]
                                            var"##886" = var"##884"[2]
                                            true
                                        end)))
                        args = var"##885"
                        body = var"##886"
                        var"##return#759" = begin
                                p(args)
                                keyword(" -> ")
                                print("(")
                                noblock(body)
                                print(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##887" = (var"##cache#762").value
                                var"##887" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##887"[1] == :do && (begin
                                        var"##888" = var"##887"[2]
                                        var"##888" isa AbstractArray
                                    end && (length(var"##888") === 2 && (begin
                                                var"##889" = var"##888"[1]
                                                begin
                                                    var"##cache#891" = nothing
                                                end
                                                var"##890" = var"##888"[2]
                                                var"##890" isa Expr
                                            end && (begin
                                                    if var"##cache#891" === nothing
                                                        var"##cache#891" = Some(((var"##890").head, (var"##890").args))
                                                    end
                                                    var"##892" = (var"##cache#891").value
                                                    var"##892" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##892"[1] == :-> && (begin
                                                            var"##893" = var"##892"[2]
                                                            var"##893" isa AbstractArray
                                                        end && (length(var"##893") === 2 && (begin
                                                                    begin
                                                                        var"##cache#895" = nothing
                                                                    end
                                                                    var"##894" = var"##893"[1]
                                                                    var"##894" isa Expr
                                                                end && (begin
                                                                        if var"##cache#895" === nothing
                                                                            var"##cache#895" = Some(((var"##894").head, (var"##894").args))
                                                                        end
                                                                        var"##896" = (var"##cache#895").value
                                                                        var"##896" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                    end && (var"##896"[1] == :tuple && (begin
                                                                                var"##897" = var"##896"[2]
                                                                                var"##897" isa AbstractArray
                                                                            end && ((ndims(var"##897") === 1 && length(var"##897") >= 0) && begin
                                                                                    var"##898" = SubArray(var"##897", (1:length(var"##897"),))
                                                                                    var"##899" = var"##893"[2]
                                                                                    true
                                                                                end)))))))))))))
                        call = var"##889"
                        args = var"##898"
                        body = var"##899"
                        var"##return#759" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##900" = (var"##cache#762").value
                                var"##900" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##900"[1] == :function && (begin
                                        var"##901" = var"##900"[2]
                                        var"##901" isa AbstractArray
                                    end && (length(var"##901") === 2 && begin
                                            var"##902" = var"##901"[1]
                                            var"##903" = var"##901"[2]
                                            true
                                        end)))
                        call = var"##902"
                        body = var"##903"
                        var"##return#759" = begin
                                print_function(:function, call, body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##904" = (var"##cache#762").value
                                var"##904" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##904"[1] == :quote && (begin
                                        var"##905" = var"##904"[2]
                                        var"##905" isa AbstractArray
                                    end && (length(var"##905") === 1 && begin
                                            var"##906" = var"##905"[1]
                                            true
                                        end)))
                        stmt = var"##906"
                        var"##return#759" = begin
                                keyword(":(")
                                noblock(stmt)
                                keyword(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##907" = (var"##cache#762").value
                                var"##907" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##907"[1] == :quote && (begin
                                        var"##908" = var"##907"[2]
                                        var"##908" isa AbstractArray
                                    end && ((ndims(var"##908") === 1 && length(var"##908") >= 0) && begin
                                            var"##909" = SubArray(var"##908", (1:length(var"##908"),))
                                            true
                                        end)))
                        args = var"##909"
                        var"##return#759" = begin
                                keyword("quote ")
                                with(p.state, :block, false) do 
                                    join(args, "; ")
                                end
                                keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##910" = (var"##cache#762").value
                                var"##910" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##910"[1] == :string && (begin
                                        var"##911" = var"##910"[2]
                                        var"##911" isa AbstractArray
                                    end && ((ndims(var"##911") === 1 && length(var"##911") >= 0) && begin
                                            var"##912" = SubArray(var"##911", (1:length(var"##911"),))
                                            true
                                        end)))
                        args = var"##912"
                        var"##return#759" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##913" = (var"##cache#762").value
                                var"##913" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##913"[1] == :block && (begin
                                        var"##914" = var"##913"[2]
                                        var"##914" isa AbstractArray
                                    end && ((ndims(var"##914") === 1 && length(var"##914") >= 0) && begin
                                            var"##915" = SubArray(var"##914", (1:length(var"##914"),))
                                            let args = var"##915"
                                                length(args) == 2 && (is_line_no(args[1]) && is_line_no(args[2]))
                                            end
                                        end)))
                        args = var"##915"
                        var"##return#759" = begin
                                p(args[1])
                                print(" ")
                                p(args[2])
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##916" = (var"##cache#762").value
                                var"##916" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##916"[1] == :block && (begin
                                        var"##917" = var"##916"[2]
                                        var"##917" isa AbstractArray
                                    end && ((ndims(var"##917") === 1 && length(var"##917") >= 0) && begin
                                            var"##918" = SubArray(var"##917", (1:length(var"##917"),))
                                            let args = var"##918"
                                                length(args) == 2 && is_line_no(args[1])
                                            end
                                        end)))
                        args = var"##918"
                        var"##return#759" = begin
                                p(args[1])
                                print(" ")
                                noblock(args[2])
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##919" = (var"##cache#762").value
                                var"##919" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##919"[1] == :block && (begin
                                        var"##920" = var"##919"[2]
                                        var"##920" isa AbstractArray
                                    end && ((ndims(var"##920") === 1 && length(var"##920") >= 0) && begin
                                            var"##921" = SubArray(var"##920", (1:length(var"##920"),))
                                            let args = var"##921"
                                                length(args) == 2 && is_line_no(args[2])
                                            end
                                        end)))
                        args = var"##921"
                        var"##return#759" = begin
                                noblock(args[1])
                                print(" ")
                                p(args[2])
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##922" = (var"##cache#762").value
                                var"##922" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##922"[1] == :block && (begin
                                        var"##923" = var"##922"[2]
                                        var"##923" isa AbstractArray
                                    end && ((ndims(var"##923") === 1 && length(var"##923") >= 0) && begin
                                            var"##924" = SubArray(var"##923", (1:length(var"##923"),))
                                            let args = var"##924"
                                                length(args) == 2
                                            end
                                        end)))
                        args = var"##924"
                        var"##return#759" = begin
                                print("(")
                                noblock(args[1])
                                keyword("; ")
                                noblock(args[2])
                                print(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##925" = (var"##cache#762").value
                                var"##925" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##925"[1] == :block && (begin
                                        var"##926" = var"##925"[2]
                                        var"##926" isa AbstractArray
                                    end && ((ndims(var"##926") === 1 && length(var"##926") >= 0) && begin
                                            var"##927" = SubArray(var"##926", (1:length(var"##926"),))
                                            true
                                        end)))
                        args = var"##927"
                        var"##return#759" = begin
                                p.state.block && keyword("begin ")
                                with(p.state, :block, true) do 
                                    join(args, "; ")
                                end
                                p.state.block && keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##928" = (var"##cache#762").value
                                var"##928" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##928"[1] == :let && (begin
                                        var"##929" = var"##928"[2]
                                        var"##929" isa AbstractArray
                                    end && (length(var"##929") === 2 && (begin
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
                                                end && (var"##932"[1] == :block && (begin
                                                            var"##933" = var"##932"[2]
                                                            var"##933" isa AbstractArray
                                                        end && ((ndims(var"##933") === 1 && length(var"##933") >= 0) && begin
                                                                var"##934" = SubArray(var"##933", (1:length(var"##933"),))
                                                                var"##935" = var"##929"[2]
                                                                true
                                                            end))))))))
                        args = var"##934"
                        body = var"##935"
                        var"##return#759" = begin
                                keyword("let ")
                                join(args, ", ")
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##936" = (var"##cache#762").value
                                var"##936" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##936"[1] == :let && (begin
                                        var"##937" = var"##936"[2]
                                        var"##937" isa AbstractArray
                                    end && (length(var"##937") === 2 && begin
                                            var"##938" = var"##937"[1]
                                            var"##939" = var"##937"[2]
                                            true
                                        end)))
                        arg = var"##938"
                        body = var"##939"
                        var"##return#759" = begin
                                keyword("let ")
                                p(arg)
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##940" = (var"##cache#762").value
                                var"##940" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##940"[1] == :macrocall && (begin
                                        var"##941" = var"##940"[2]
                                        var"##941" isa AbstractArray
                                    end && ((ndims(var"##941") === 1 && length(var"##941") >= 2) && begin
                                            var"##942" = var"##941"[1]
                                            var"##943" = var"##941"[2]
                                            var"##944" = SubArray(var"##941", (3:length(var"##941"),))
                                            true
                                        end)))
                        f = var"##942"
                        line = var"##943"
                        args = var"##944"
                        var"##return#759" = begin
                                p.line && printstyled(line, color = c.comment)
                                macrocall(f)
                                print_braces(args, "(", ")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##945" = (var"##cache#762").value
                                var"##945" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##945"[1] == :return && (begin
                                        var"##946" = var"##945"[2]
                                        var"##946" isa AbstractArray
                                    end && (length(var"##946") === 1 && (begin
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
                                                end && (var"##949"[1] == :tuple && (begin
                                                            var"##950" = var"##949"[2]
                                                            var"##950" isa AbstractArray
                                                        end && ((ndims(var"##950") === 1 && length(var"##950") >= 1) && (begin
                                                                    begin
                                                                        var"##cache#952" = nothing
                                                                    end
                                                                    var"##951" = var"##950"[1]
                                                                    var"##951" isa Expr
                                                                end && (begin
                                                                        if var"##cache#952" === nothing
                                                                            var"##cache#952" = Some(((var"##951").head, (var"##951").args))
                                                                        end
                                                                        var"##953" = (var"##cache#952").value
                                                                        var"##953" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                    end && (var"##953"[1] == :parameters && (begin
                                                                                var"##954" = var"##953"[2]
                                                                                var"##954" isa AbstractArray
                                                                            end && ((ndims(var"##954") === 1 && length(var"##954") >= 0) && begin
                                                                                    var"##955" = SubArray(var"##954", (1:length(var"##954"),))
                                                                                    var"##956" = SubArray(var"##950", (2:length(var"##950"),))
                                                                                    true
                                                                                end)))))))))))))
                        args = var"##956"
                        kwargs = var"##955"
                        var"##return#759" = begin
                                keyword("return ")
                                p(Expr(:tuple, Expr(:parameters, kwargs...), args...))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##957" = (var"##cache#762").value
                                var"##957" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##957"[1] == :return && (begin
                                        var"##958" = var"##957"[2]
                                        var"##958" isa AbstractArray
                                    end && (length(var"##958") === 1 && (begin
                                                begin
                                                    var"##cache#960" = nothing
                                                end
                                                var"##959" = var"##958"[1]
                                                var"##959" isa Expr
                                            end && (begin
                                                    if var"##cache#960" === nothing
                                                        var"##cache#960" = Some(((var"##959").head, (var"##959").args))
                                                    end
                                                    var"##961" = (var"##cache#960").value
                                                    var"##961" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##961"[1] == :tuple && (begin
                                                            var"##962" = var"##961"[2]
                                                            var"##962" isa AbstractArray
                                                        end && ((ndims(var"##962") === 1 && length(var"##962") >= 0) && begin
                                                                var"##963" = SubArray(var"##962", (1:length(var"##962"),))
                                                                true
                                                            end))))))))
                        args = var"##963"
                        var"##return#759" = begin
                                keyword("return ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##964" = (var"##cache#762").value
                                var"##964" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##964"[1] == :return && (begin
                                        var"##965" = var"##964"[2]
                                        var"##965" isa AbstractArray
                                    end && ((ndims(var"##965") === 1 && length(var"##965") >= 0) && begin
                                            var"##966" = SubArray(var"##965", (1:length(var"##965"),))
                                            true
                                        end)))
                        args = var"##966"
                        var"##return#759" = begin
                                keyword("return ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##967" = (var"##cache#762").value
                                var"##967" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##967"[1] == :module && (begin
                                        var"##968" = var"##967"[2]
                                        var"##968" isa AbstractArray
                                    end && (length(var"##968") === 3 && begin
                                            var"##969" = var"##968"[1]
                                            var"##970" = var"##968"[2]
                                            var"##971" = var"##968"[3]
                                            true
                                        end)))
                        bare = var"##969"
                        name = var"##970"
                        body = var"##971"
                        var"##return#759" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##972" = (var"##cache#762").value
                                var"##972" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##972"[1] == :using && (begin
                                        var"##973" = var"##972"[2]
                                        var"##973" isa AbstractArray
                                    end && ((ndims(var"##973") === 1 && length(var"##973") >= 0) && begin
                                            var"##974" = SubArray(var"##973", (1:length(var"##973"),))
                                            true
                                        end)))
                        args = var"##974"
                        var"##return#759" = begin
                                keyword("using ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##975" = (var"##cache#762").value
                                var"##975" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##975"[1] == :import && (begin
                                        var"##976" = var"##975"[2]
                                        var"##976" isa AbstractArray
                                    end && ((ndims(var"##976") === 1 && length(var"##976") >= 0) && begin
                                            var"##977" = SubArray(var"##976", (1:length(var"##976"),))
                                            true
                                        end)))
                        args = var"##977"
                        var"##return#759" = begin
                                keyword("import ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##978" = (var"##cache#762").value
                                var"##978" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##978"[1] == :as && (begin
                                        var"##979" = var"##978"[2]
                                        var"##979" isa AbstractArray
                                    end && (length(var"##979") === 2 && begin
                                            var"##980" = var"##979"[1]
                                            var"##981" = var"##979"[2]
                                            true
                                        end)))
                        name = var"##980"
                        alias = var"##981"
                        var"##return#759" = begin
                                p(name)
                                keyword(" as ")
                                p(alias)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##982" = (var"##cache#762").value
                                var"##982" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##982"[1] == :export && (begin
                                        var"##983" = var"##982"[2]
                                        var"##983" isa AbstractArray
                                    end && ((ndims(var"##983") === 1 && length(var"##983") >= 0) && begin
                                            var"##984" = SubArray(var"##983", (1:length(var"##983"),))
                                            true
                                        end)))
                        args = var"##984"
                        var"##return#759" = begin
                                keyword("export ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##985" = (var"##cache#762").value
                                var"##985" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##985"[1] == :(:) && (begin
                                        var"##986" = var"##985"[2]
                                        var"##986" isa AbstractArray
                                    end && ((ndims(var"##986") === 1 && length(var"##986") >= 1) && begin
                                            var"##987" = var"##986"[1]
                                            var"##988" = SubArray(var"##986", (2:length(var"##986"),))
                                            true
                                        end)))
                        args = var"##988"
                        head = var"##987"
                        var"##return#759" = begin
                                p(head)
                                keyword(": ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##989" = (var"##cache#762").value
                                var"##989" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##989"[1] == :where && (begin
                                        var"##990" = var"##989"[2]
                                        var"##990" isa AbstractArray
                                    end && ((ndims(var"##990") === 1 && length(var"##990") >= 1) && begin
                                            var"##991" = var"##990"[1]
                                            var"##992" = SubArray(var"##990", (2:length(var"##990"),))
                                            true
                                        end)))
                        body = var"##991"
                        whereparams = var"##992"
                        var"##return#759" = begin
                                p(body)
                                keyword(" where {")
                                with(p.state, :type, true) do 
                                    join(whereparams, ", ")
                                end
                                keyword("}")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##993" = (var"##cache#762").value
                                var"##993" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##993"[1] == :for && (begin
                                        var"##994" = var"##993"[2]
                                        var"##994" isa AbstractArray
                                    end && (length(var"##994") === 2 && begin
                                            var"##995" = var"##994"[1]
                                            var"##996" = var"##994"[2]
                                            true
                                        end)))
                        body = var"##996"
                        iteration = var"##995"
                        var"##return#759" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##997" = (var"##cache#762").value
                                var"##997" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##997"[1] == :while && (begin
                                        var"##998" = var"##997"[2]
                                        var"##998" isa AbstractArray
                                    end && (length(var"##998") === 2 && begin
                                            var"##999" = var"##998"[1]
                                            var"##1000" = var"##998"[2]
                                            true
                                        end)))
                        body = var"##1000"
                        condition = var"##999"
                        var"##return#759" = begin
                                keyword("while ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##1001" = (var"##cache#762").value
                                var"##1001" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1001"[1] == :continue && (begin
                                        var"##1002" = var"##1001"[2]
                                        var"##1002" isa AbstractArray
                                    end && isempty(var"##1002")))
                        var"##return#759" = begin
                                keyword("continue")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##1003" = (var"##cache#762").value
                                var"##1003" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1003"[1] == :if && (begin
                                        var"##1004" = var"##1003"[2]
                                        var"##1004" isa AbstractArray
                                    end && (length(var"##1004") === 2 && begin
                                            var"##1005" = var"##1004"[1]
                                            var"##1006" = var"##1004"[2]
                                            true
                                        end)))
                        body = var"##1006"
                        condition = var"##1005"
                        var"##return#759" = begin
                                keyword("if ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##1007" = (var"##cache#762").value
                                var"##1007" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1007"[1] == :if && (begin
                                        var"##1008" = var"##1007"[2]
                                        var"##1008" isa AbstractArray
                                    end && (length(var"##1008") === 3 && begin
                                            var"##1009" = var"##1008"[1]
                                            var"##1010" = var"##1008"[2]
                                            var"##1011" = var"##1008"[3]
                                            true
                                        end)))
                        body = var"##1010"
                        elsebody = var"##1011"
                        condition = var"##1009"
                        var"##return#759" = begin
                                keyword("if ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                                keyword("; ")
                                Meta.isexpr(elsebody, :elseif) || keyword("else ")
                                noblock(elsebody)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##1012" = (var"##cache#762").value
                                var"##1012" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1012"[1] == :elseif && (begin
                                        var"##1013" = var"##1012"[2]
                                        var"##1013" isa AbstractArray
                                    end && (length(var"##1013") === 2 && begin
                                            var"##1014" = var"##1013"[1]
                                            var"##1015" = var"##1013"[2]
                                            true
                                        end)))
                        body = var"##1015"
                        condition = var"##1014"
                        var"##return#759" = begin
                                keyword("elseif ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##1016" = (var"##cache#762").value
                                var"##1016" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1016"[1] == :elseif && (begin
                                        var"##1017" = var"##1016"[2]
                                        var"##1017" isa AbstractArray
                                    end && (length(var"##1017") === 3 && begin
                                            var"##1018" = var"##1017"[1]
                                            var"##1019" = var"##1017"[2]
                                            var"##1020" = var"##1017"[3]
                                            true
                                        end)))
                        body = var"##1019"
                        elsebody = var"##1020"
                        condition = var"##1018"
                        var"##return#759" = begin
                                keyword("elseif ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                                keyword("; ")
                                Meta.isexpr(elsebody, :elseif) || keyword("else")
                                noblock(elsebody)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##1021" = (var"##cache#762").value
                                var"##1021" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1021"[1] == :try && (begin
                                        var"##1022" = var"##1021"[2]
                                        var"##1022" isa AbstractArray
                                    end && (length(var"##1022") === 3 && begin
                                            var"##1023" = var"##1022"[1]
                                            var"##1024" = var"##1022"[2]
                                            var"##1025" = var"##1022"[3]
                                            true
                                        end)))
                        catch_vars = var"##1024"
                        catch_body = var"##1025"
                        try_body = var"##1023"
                        var"##return#759" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##1026" = (var"##cache#762").value
                                var"##1026" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1026"[1] == :try && (begin
                                        var"##1027" = var"##1026"[2]
                                        var"##1027" isa AbstractArray
                                    end && (length(var"##1027") === 4 && begin
                                            var"##1028" = var"##1027"[1]
                                            var"##1029" = var"##1027"[2]
                                            var"##1030" = var"##1027"[3]
                                            var"##1031" = var"##1027"[4]
                                            true
                                        end)))
                        catch_vars = var"##1029"
                        catch_body = var"##1030"
                        try_body = var"##1028"
                        finally_body = var"##1031"
                        var"##return#759" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##1032" = (var"##cache#762").value
                                var"##1032" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1032"[1] == :try && (begin
                                        var"##1033" = var"##1032"[2]
                                        var"##1033" isa AbstractArray
                                    end && (length(var"##1033") === 5 && begin
                                            var"##1034" = var"##1033"[1]
                                            var"##1035" = var"##1033"[2]
                                            var"##1036" = var"##1033"[3]
                                            var"##1037" = var"##1033"[4]
                                            var"##1038" = var"##1033"[5]
                                            true
                                        end)))
                        catch_vars = var"##1035"
                        catch_body = var"##1036"
                        try_body = var"##1034"
                        finally_body = var"##1037"
                        else_body = var"##1038"
                        var"##return#759" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##1039" = (var"##cache#762").value
                                var"##1039" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1039"[1] == :struct && (begin
                                        var"##1040" = var"##1039"[2]
                                        var"##1040" isa AbstractArray
                                    end && (length(var"##1040") === 3 && begin
                                            var"##1041" = var"##1040"[1]
                                            var"##1042" = var"##1040"[2]
                                            var"##1043" = var"##1040"[3]
                                            true
                                        end)))
                        ismutable = var"##1041"
                        name = var"##1042"
                        body = var"##1043"
                        var"##return#759" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##1044" = (var"##cache#762").value
                                var"##1044" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1044"[1] == :abstract && (begin
                                        var"##1045" = var"##1044"[2]
                                        var"##1045" isa AbstractArray
                                    end && (length(var"##1045") === 1 && begin
                                            var"##1046" = var"##1045"[1]
                                            true
                                        end)))
                        name = var"##1046"
                        var"##return#759" = begin
                                keyword("abstract type ")
                                p(name)
                                keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##1047" = (var"##cache#762").value
                                var"##1047" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1047"[1] == :primitive && (begin
                                        var"##1048" = var"##1047"[2]
                                        var"##1048" isa AbstractArray
                                    end && (length(var"##1048") === 2 && begin
                                            var"##1049" = var"##1048"[1]
                                            var"##1050" = var"##1048"[2]
                                            true
                                        end)))
                        name = var"##1049"
                        size = var"##1050"
                        var"##return#759" = begin
                                keyword("primitive type ")
                                p(name)
                                print(" ")
                                p(size)
                                keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##1051" = (var"##cache#762").value
                                var"##1051" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1051"[1] == :meta && (begin
                                        var"##1052" = var"##1051"[2]
                                        var"##1052" isa AbstractArray
                                    end && (length(var"##1052") === 1 && var"##1052"[1] == :inline)))
                        var"##return#759" = begin
                                macrocall(GlobalRef(Base, Symbol("@_inline_meta")))
                                keyword(";")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##1053" = (var"##cache#762").value
                                var"##1053" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1053"[1] == :break && (begin
                                        var"##1054" = var"##1053"[2]
                                        var"##1054" isa AbstractArray
                                    end && isempty(var"##1054")))
                        var"##return#759" = begin
                                keyword("break")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##1055" = (var"##cache#762").value
                                var"##1055" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1055"[1] == :symboliclabel && (begin
                                        var"##1056" = var"##1055"[2]
                                        var"##1056" isa AbstractArray
                                    end && (length(var"##1056") === 1 && begin
                                            var"##1057" = var"##1056"[1]
                                            true
                                        end)))
                        label = var"##1057"
                        var"##return#759" = begin
                                macrocall(GlobalRef(Base, Symbol("@label")))
                                print(" ")
                                p(label)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##1058" = (var"##cache#762").value
                                var"##1058" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1058"[1] == :symbolicgoto && (begin
                                        var"##1059" = var"##1058"[2]
                                        var"##1059" isa AbstractArray
                                    end && (length(var"##1059") === 1 && begin
                                            var"##1060" = var"##1059"[1]
                                            true
                                        end)))
                        label = var"##1060"
                        var"##return#759" = begin
                                macrocall(GlobalRef(Base, Symbol("@goto")))
                                print(" ")
                                p(label)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    if begin
                                var"##1061" = (var"##cache#762").value
                                var"##1061" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1062" = var"##1061"[1]
                                    var"##1063" = var"##1061"[2]
                                    var"##1063" isa AbstractArray
                                end && ((ndims(var"##1063") === 1 && length(var"##1063") >= 0) && begin
                                        var"##1064" = SubArray(var"##1063", (1:length(var"##1063"),))
                                        true
                                    end))
                        args = var"##1064"
                        head = var"##1062"
                        var"##return#759" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                end
                if var"##761" isa GlobalRef
                    begin
                        var"##return#759" = begin
                                p(ex.mod)
                                keyword(".")
                                p(ex.name)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                end
                if var"##761" isa QuoteNode
                    if ex.value in Base.quoted_syms
                        var"##return#759" = begin
                                keyword(":(")
                                quoted(ex.value)
                                keyword(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                    begin
                        var"##return#759" = begin
                                if ex.value isa Symbol && Base.isidentifier(ex.value)
                                    keyword(":")
                                    quoted(ex.value)
                                else
                                    keyword(":(")
                                    quoted(ex.value)
                                    keyword(")")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                end
                if var"##761" isa Number
                    begin
                        var"##return#759" = begin
                                printstyled(ex, color = c.number)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                end
                if var"##761" isa String
                    begin
                        var"##return#759" = begin
                                string(ex)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                end
                if var"##761" isa LineNumberNode
                    begin
                        var"##return#759" = begin
                                p.line || return nothing
                                printstyled("#= $(ex.file):$(ex.line) =#", color = c.line)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                    end
                end
                begin
                    var"##return#759" = begin
                            print(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#760#1065")))
                end
                error("matching non-exhaustive, at #= none:142 =#")
                $(Expr(:symboliclabel, Symbol("####final#760#1065")))
                var"##return#759"
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
