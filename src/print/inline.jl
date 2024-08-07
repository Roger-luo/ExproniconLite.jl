
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
                        var"##cache#793" = nothing
                    end
                    var"##return#790" = nothing
                    var"##792" = ex
                    if var"##792" isa Expr
                        if begin
                                    if var"##cache#793" === nothing
                                        var"##cache#793" = Some(((var"##792").head, (var"##792").args))
                                    end
                                    var"##794" = (var"##cache#793").value
                                    var"##794" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##794"[1] == :. && (begin
                                            var"##795" = var"##794"[2]
                                            var"##795" isa AbstractArray
                                        end && (ndims(var"##795") === 1 && length(var"##795") >= 0)))
                            var"##return#790" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#791#796")))
                        end
                    end
                    if var"##792" isa Symbol
                        begin
                            var"##return#790" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#791#796")))
                        end
                    end
                    begin
                        var"##return#790" = let
                                false
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#791#796")))
                    end
                    error("matching non-exhaustive, at #= none:85 =#")
                    $(Expr(:symboliclabel, Symbol("####final#791#796")))
                    var"##return#790"
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
                    var"##cache#800" = nothing
                end
                var"##799" = ex
                if var"##799" isa Expr && (begin
                                if var"##cache#800" === nothing
                                    var"##cache#800" = Some(((var"##799").head, (var"##799").args))
                                end
                                var"##801" = (var"##cache#800").value
                                var"##801" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##801"[1] == :call && (begin
                                        var"##802" = var"##801"[2]
                                        var"##802" isa AbstractArray
                                    end && ((ndims(var"##802") === 1 && length(var"##802") >= 1) && (var"##802"[1] == :(:) && begin
                                                var"##803" = SubArray(var"##802", (2:length(var"##802"),))
                                                true
                                            end)))))
                    args = var"##803"
                    var"##return#797" = begin
                            precedence(:(:)) do 
                                join(args, ":")
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#798#825")))
                end
                if var"##799" isa Expr && (begin
                                if var"##cache#800" === nothing
                                    var"##cache#800" = Some(((var"##799").head, (var"##799").args))
                                end
                                var"##804" = (var"##cache#800").value
                                var"##804" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##804"[1] == :call && (begin
                                        var"##805" = var"##804"[2]
                                        var"##805" isa AbstractArray
                                    end && (length(var"##805") === 2 && (begin
                                                var"##806" = var"##805"[1]
                                                var"##806" isa Symbol
                                            end && begin
                                                var"##807" = var"##805"[2]
                                                let f = var"##806", arg = var"##807"
                                                    Base.isunaryoperator(f)
                                                end
                                            end)))))
                    f = var"##806"
                    arg = var"##807"
                    var"##return#797" = begin
                            precedence(typemax(Int)) do 
                                keyword(f)
                                p(arg)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#798#825")))
                end
                if var"##799" isa Expr && (begin
                                if var"##cache#800" === nothing
                                    var"##cache#800" = Some(((var"##799").head, (var"##799").args))
                                end
                                var"##808" = (var"##cache#800").value
                                var"##808" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##808"[1] == :call && (begin
                                        var"##809" = var"##808"[2]
                                        var"##809" isa AbstractArray
                                    end && ((ndims(var"##809") === 1 && length(var"##809") >= 1) && (begin
                                                var"##810" = var"##809"[1]
                                                var"##810" isa Symbol
                                            end && begin
                                                var"##811" = SubArray(var"##809", (2:length(var"##809"),))
                                                let f = var"##810", args = var"##811"
                                                    Base.isbinaryoperator(f)
                                                end
                                            end)))))
                    f = var"##810"
                    args = var"##811"
                    var"##return#797" = begin
                            precedence(f) do 
                                join(args, " $(f) ")
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#798#825")))
                end
                if var"##799" isa Expr && (begin
                                if var"##cache#800" === nothing
                                    var"##cache#800" = Some(((var"##799").head, (var"##799").args))
                                end
                                var"##812" = (var"##cache#800").value
                                var"##812" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##812"[1] == :call && (begin
                                        var"##813" = var"##812"[2]
                                        var"##813" isa AbstractArray
                                    end && ((ndims(var"##813") === 1 && length(var"##813") >= 2) && (begin
                                                var"##814" = var"##813"[1]
                                                begin
                                                    var"##cache#816" = nothing
                                                end
                                                var"##815" = var"##813"[2]
                                                var"##815" isa Expr
                                            end && (begin
                                                    if var"##cache#816" === nothing
                                                        var"##cache#816" = Some(((var"##815").head, (var"##815").args))
                                                    end
                                                    var"##817" = (var"##cache#816").value
                                                    var"##817" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##817"[1] == :parameters && (begin
                                                            var"##818" = var"##817"[2]
                                                            var"##818" isa AbstractArray
                                                        end && ((ndims(var"##818") === 1 && length(var"##818") >= 0) && begin
                                                                var"##819" = SubArray(var"##818", (1:length(var"##818"),))
                                                                var"##820" = SubArray(var"##813", (3:length(var"##813"),))
                                                                true
                                                            end)))))))))
                    f = var"##814"
                    args = var"##820"
                    kwargs = var"##819"
                    var"##return#797" = begin
                            call(f)
                            print("(")
                            join(args)
                            keyword("; ")
                            join(kwargs)
                            print(")")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#798#825")))
                end
                if var"##799" isa Expr && (begin
                                if var"##cache#800" === nothing
                                    var"##cache#800" = Some(((var"##799").head, (var"##799").args))
                                end
                                var"##821" = (var"##cache#800").value
                                var"##821" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##821"[1] == :call && (begin
                                        var"##822" = var"##821"[2]
                                        var"##822" isa AbstractArray
                                    end && ((ndims(var"##822") === 1 && length(var"##822") >= 1) && begin
                                            var"##823" = var"##822"[1]
                                            var"##824" = SubArray(var"##822", (2:length(var"##822"),))
                                            true
                                        end))))
                    f = var"##823"
                    args = var"##824"
                    var"##return#797" = begin
                            call(f)
                            print_braces(args, "(", ")")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#798#825")))
                end
                error("matching non-exhaustive, at #= none:111 =#")
                $(Expr(:symboliclabel, Symbol("####final#798#825")))
                var"##return#797"
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
                    var"##cache#829" = nothing
                end
                var"##828" = ex
                if var"##828" isa GlobalRef
                    begin
                        var"##return#826" = begin
                                p(ex.mod)
                                keyword(".")
                                p(ex.name)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                end
                if var"##828" isa Nothing
                    begin
                        var"##return#826" = begin
                                printstyled("nothing", color = c.number)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                end
                if var"##828" isa Char
                    begin
                        var"##return#826" = begin
                                printstyled(repr(ex), color = c.string)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                end
                if var"##828" isa Number
                    begin
                        var"##return#826" = begin
                                printstyled(ex, color = c.number)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                end
                if var"##828" isa Symbol
                    begin
                        var"##return#826" = begin
                                symbol(ex)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                end
                if var"##828" isa Expr
                    if begin
                                if var"##cache#829" === nothing
                                    var"##cache#829" = Some(((var"##828").head, (var"##828").args))
                                end
                                var"##830" = (var"##cache#829").value
                                var"##830" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##830"[1] == :line && (begin
                                        var"##831" = var"##830"[2]
                                        var"##831" isa AbstractArray
                                    end && (length(var"##831") === 2 && begin
                                            var"##832" = var"##831"[1]
                                            var"##833" = var"##831"[2]
                                            true
                                        end)))
                        line = var"##833"
                        file = var"##832"
                        var"##return#826" = begin
                                p.line || return nothing
                                printstyled("#= $(file):$(line) =#", color = c.line)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##834" = (var"##cache#829").value
                                var"##834" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##834"[1] == :kw && (begin
                                        var"##835" = var"##834"[2]
                                        var"##835" isa AbstractArray
                                    end && (length(var"##835") === 2 && begin
                                            var"##836" = var"##835"[1]
                                            var"##837" = var"##835"[2]
                                            true
                                        end)))
                        k = var"##836"
                        v = var"##837"
                        var"##return#826" = begin
                                p(k)
                                print(" = ")
                                p(v)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##838" = (var"##cache#829").value
                                var"##838" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##838"[1] == :(=) && (begin
                                        var"##839" = var"##838"[2]
                                        var"##839" isa AbstractArray
                                    end && (length(var"##839") === 2 && (begin
                                                var"##840" = var"##839"[1]
                                                begin
                                                    var"##cache#842" = nothing
                                                end
                                                var"##841" = var"##839"[2]
                                                var"##841" isa Expr
                                            end && (begin
                                                    if var"##cache#842" === nothing
                                                        var"##cache#842" = Some(((var"##841").head, (var"##841").args))
                                                    end
                                                    var"##843" = (var"##cache#842").value
                                                    var"##843" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##843"[1] == :block && (begin
                                                            var"##844" = var"##843"[2]
                                                            var"##844" isa AbstractArray
                                                        end && ((ndims(var"##844") === 1 && length(var"##844") >= 0) && begin
                                                                var"##845" = SubArray(var"##844", (1:length(var"##844"),))
                                                                true
                                                            end))))))))
                        k = var"##840"
                        stmts = var"##845"
                        var"##return#826" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##846" = (var"##cache#829").value
                                var"##846" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##846"[1] == :(=) && (begin
                                        var"##847" = var"##846"[2]
                                        var"##847" isa AbstractArray
                                    end && (length(var"##847") === 2 && begin
                                            var"##848" = var"##847"[1]
                                            var"##849" = var"##847"[2]
                                            true
                                        end)))
                        k = var"##848"
                        v = var"##849"
                        var"##return#826" = begin
                                precedence(:(=)) do 
                                    p(k)
                                    assign()
                                    p(v)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##850" = (var"##cache#829").value
                                var"##850" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##850"[1] == :... && (begin
                                        var"##851" = var"##850"[2]
                                        var"##851" isa AbstractArray
                                    end && (length(var"##851") === 1 && begin
                                            var"##852" = var"##851"[1]
                                            true
                                        end)))
                        name = var"##852"
                        var"##return#826" = begin
                                precedence(:...) do 
                                    p(name)
                                    keyword("...")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##853" = (var"##cache#829").value
                                var"##853" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##853"[1] == :& && (begin
                                        var"##854" = var"##853"[2]
                                        var"##854" isa AbstractArray
                                    end && (length(var"##854") === 1 && begin
                                            var"##855" = var"##854"[1]
                                            true
                                        end)))
                        name = var"##855"
                        var"##return#826" = begin
                                precedence(:&) do 
                                    keyword("&")
                                    p(name)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##856" = (var"##cache#829").value
                                var"##856" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##856"[1] == :(::) && (begin
                                        var"##857" = var"##856"[2]
                                        var"##857" isa AbstractArray
                                    end && (length(var"##857") === 1 && begin
                                            var"##858" = var"##857"[1]
                                            true
                                        end)))
                        t = var"##858"
                        var"##return#826" = begin
                                precedence(:(::)) do 
                                    keyword("::")
                                    type(t)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##859" = (var"##cache#829").value
                                var"##859" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##859"[1] == :(::) && (begin
                                        var"##860" = var"##859"[2]
                                        var"##860" isa AbstractArray
                                    end && (length(var"##860") === 2 && begin
                                            var"##861" = var"##860"[1]
                                            var"##862" = var"##860"[2]
                                            true
                                        end)))
                        name = var"##861"
                        t = var"##862"
                        var"##return#826" = begin
                                precedence(:(::)) do 
                                    p(name)
                                    keyword("::")
                                    type(t)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##863" = (var"##cache#829").value
                                var"##863" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##863"[1] == :$ && (begin
                                        var"##864" = var"##863"[2]
                                        var"##864" isa AbstractArray
                                    end && (length(var"##864") === 1 && begin
                                            var"##865" = var"##864"[1]
                                            true
                                        end)))
                        name = var"##865"
                        var"##return#826" = begin
                                precedence(:$) do 
                                    keyword('$')
                                    print("(")
                                    p(name)
                                    print(")")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##866" = (var"##cache#829").value
                                var"##866" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##867" = var"##866"[1]
                                    var"##868" = var"##866"[2]
                                    var"##868" isa AbstractArray
                                end && (length(var"##868") === 2 && begin
                                        var"##869" = var"##868"[1]
                                        var"##870" = var"##868"[2]
                                        let rhs = var"##870", lhs = var"##869", head = var"##867"
                                            head in expr_infix_wide
                                        end
                                    end))
                        rhs = var"##870"
                        lhs = var"##869"
                        head = var"##867"
                        var"##return#826" = begin
                                precedence(head) do 
                                    p(lhs)
                                    keyword(" $(head) ")
                                    p(rhs)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##871" = (var"##cache#829").value
                                var"##871" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##871"[1] == :. && (begin
                                        var"##872" = var"##871"[2]
                                        var"##872" isa AbstractArray
                                    end && (length(var"##872") === 1 && begin
                                            var"##873" = var"##872"[1]
                                            true
                                        end)))
                        name = var"##873"
                        var"##return#826" = begin
                                print(name)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##874" = (var"##cache#829").value
                                var"##874" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##874"[1] == :. && (begin
                                        var"##875" = var"##874"[2]
                                        var"##875" isa AbstractArray
                                    end && (length(var"##875") === 2 && (begin
                                                var"##876" = var"##875"[1]
                                                var"##877" = var"##875"[2]
                                                var"##877" isa QuoteNode
                                            end && begin
                                                var"##878" = (var"##877").value
                                                true
                                            end))))
                        name = var"##878"
                        object = var"##876"
                        var"##return#826" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##879" = (var"##cache#829").value
                                var"##879" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##879"[1] == :. && (begin
                                        var"##880" = var"##879"[2]
                                        var"##880" isa AbstractArray
                                    end && (length(var"##880") === 2 && begin
                                            var"##881" = var"##880"[1]
                                            var"##882" = var"##880"[2]
                                            true
                                        end)))
                        name = var"##882"
                        object = var"##881"
                        var"##return#826" = begin
                                precedence(:.) do 
                                    p(object)
                                    keyword(".")
                                    p(name)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##883" = (var"##cache#829").value
                                var"##883" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##883"[1] == :<: && (begin
                                        var"##884" = var"##883"[2]
                                        var"##884" isa AbstractArray
                                    end && (length(var"##884") === 2 && begin
                                            var"##885" = var"##884"[1]
                                            var"##886" = var"##884"[2]
                                            true
                                        end)))
                        type = var"##885"
                        supertype = var"##886"
                        var"##return#826" = begin
                                precedence(:<:) do 
                                    p(type)
                                    keyword(" <: ")
                                    p(supertype)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##887" = (var"##cache#829").value
                                var"##887" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##887"[1] == :call && (begin
                                        var"##888" = var"##887"[2]
                                        var"##888" isa AbstractArray
                                    end && (ndims(var"##888") === 1 && length(var"##888") >= 0)))
                        var"##return#826" = begin
                                print_call(ex)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##889" = (var"##cache#829").value
                                var"##889" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##889"[1] == :tuple && (begin
                                        var"##890" = var"##889"[2]
                                        var"##890" isa AbstractArray
                                    end && (length(var"##890") === 1 && (begin
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
                                                end && (var"##893"[1] == :parameters && (begin
                                                            var"##894" = var"##893"[2]
                                                            var"##894" isa AbstractArray
                                                        end && ((ndims(var"##894") === 1 && length(var"##894") >= 0) && begin
                                                                var"##895" = SubArray(var"##894", (1:length(var"##894"),))
                                                                true
                                                            end))))))))
                        args = var"##895"
                        var"##return#826" = begin
                                print_braces(args, "(;", ")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##896" = (var"##cache#829").value
                                var"##896" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##896"[1] == :tuple && (begin
                                        var"##897" = var"##896"[2]
                                        var"##897" isa AbstractArray
                                    end && ((ndims(var"##897") === 1 && length(var"##897") >= 0) && begin
                                            var"##898" = SubArray(var"##897", (1:length(var"##897"),))
                                            true
                                        end)))
                        args = var"##898"
                        var"##return#826" = begin
                                if length(args) == 1
                                    print("(")
                                    p(args[1])
                                    print(",)")
                                else
                                    print_braces(args, "(", ")")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##899" = (var"##cache#829").value
                                var"##899" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##899"[1] == :curly && (begin
                                        var"##900" = var"##899"[2]
                                        var"##900" isa AbstractArray
                                    end && ((ndims(var"##900") === 1 && length(var"##900") >= 1) && begin
                                            var"##901" = var"##900"[1]
                                            var"##902" = SubArray(var"##900", (2:length(var"##900"),))
                                            true
                                        end)))
                        args = var"##902"
                        t = var"##901"
                        var"##return#826" = begin
                                with(p.state, :type, true) do 
                                    p(t)
                                    print_braces(args, "{", "}")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##903" = (var"##cache#829").value
                                var"##903" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##903"[1] == :vect && (begin
                                        var"##904" = var"##903"[2]
                                        var"##904" isa AbstractArray
                                    end && ((ndims(var"##904") === 1 && length(var"##904") >= 0) && begin
                                            var"##905" = SubArray(var"##904", (1:length(var"##904"),))
                                            true
                                        end)))
                        args = var"##905"
                        var"##return#826" = begin
                                print_braces(args, "[", "]")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##906" = (var"##cache#829").value
                                var"##906" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##906"[1] == :hcat && (begin
                                        var"##907" = var"##906"[2]
                                        var"##907" isa AbstractArray
                                    end && ((ndims(var"##907") === 1 && length(var"##907") >= 0) && begin
                                            var"##908" = SubArray(var"##907", (1:length(var"##907"),))
                                            true
                                        end)))
                        args = var"##908"
                        var"##return#826" = begin
                                print_braces(args, "[", "]", " ")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##909" = (var"##cache#829").value
                                var"##909" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##909"[1] == :typed_hcat && (begin
                                        var"##910" = var"##909"[2]
                                        var"##910" isa AbstractArray
                                    end && ((ndims(var"##910") === 1 && length(var"##910") >= 1) && begin
                                            var"##911" = var"##910"[1]
                                            var"##912" = SubArray(var"##910", (2:length(var"##910"),))
                                            true
                                        end)))
                        args = var"##912"
                        t = var"##911"
                        var"##return#826" = begin
                                type(t)
                                print_braces(args, "[", "]", " ")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##913" = (var"##cache#829").value
                                var"##913" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##913"[1] == :vcat && (begin
                                        var"##914" = var"##913"[2]
                                        var"##914" isa AbstractArray
                                    end && ((ndims(var"##914") === 1 && length(var"##914") >= 0) && begin
                                            var"##915" = SubArray(var"##914", (1:length(var"##914"),))
                                            true
                                        end)))
                        args = var"##915"
                        var"##return#826" = begin
                                print_braces(args, "[", "]", "; ")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##916" = (var"##cache#829").value
                                var"##916" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##916"[1] == :ncat && (begin
                                        var"##917" = var"##916"[2]
                                        var"##917" isa AbstractArray
                                    end && ((ndims(var"##917") === 1 && length(var"##917") >= 1) && begin
                                            var"##918" = var"##917"[1]
                                            var"##919" = SubArray(var"##917", (2:length(var"##917"),))
                                            true
                                        end)))
                        n = var"##918"
                        args = var"##919"
                        var"##return#826" = begin
                                print_braces(args, "[", "]", ";" ^ n * " ")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##920" = (var"##cache#829").value
                                var"##920" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##920"[1] == :ref && (begin
                                        var"##921" = var"##920"[2]
                                        var"##921" isa AbstractArray
                                    end && ((ndims(var"##921") === 1 && length(var"##921") >= 1) && begin
                                            var"##922" = var"##921"[1]
                                            var"##923" = SubArray(var"##921", (2:length(var"##921"),))
                                            true
                                        end)))
                        args = var"##923"
                        object = var"##922"
                        var"##return#826" = begin
                                p(object)
                                print_braces(args, "[", "]")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##924" = (var"##cache#829").value
                                var"##924" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##924"[1] == :comprehension && (begin
                                        var"##925" = var"##924"[2]
                                        var"##925" isa AbstractArray
                                    end && (length(var"##925") === 1 && (begin
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
                                                end && (var"##928"[1] == :generator && (begin
                                                            var"##929" = var"##928"[2]
                                                            var"##929" isa AbstractArray
                                                        end && (length(var"##929") === 2 && begin
                                                                var"##930" = var"##929"[1]
                                                                var"##931" = var"##929"[2]
                                                                true
                                                            end))))))))
                        iter = var"##930"
                        body = var"##931"
                        var"##return#826" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##932" = (var"##cache#829").value
                                var"##932" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##932"[1] == :typed_comprehension && (begin
                                        var"##933" = var"##932"[2]
                                        var"##933" isa AbstractArray
                                    end && (length(var"##933") === 2 && (begin
                                                var"##934" = var"##933"[1]
                                                begin
                                                    var"##cache#936" = nothing
                                                end
                                                var"##935" = var"##933"[2]
                                                var"##935" isa Expr
                                            end && (begin
                                                    if var"##cache#936" === nothing
                                                        var"##cache#936" = Some(((var"##935").head, (var"##935").args))
                                                    end
                                                    var"##937" = (var"##cache#936").value
                                                    var"##937" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##937"[1] == :generator && (begin
                                                            var"##938" = var"##937"[2]
                                                            var"##938" isa AbstractArray
                                                        end && (length(var"##938") === 2 && begin
                                                                var"##939" = var"##938"[1]
                                                                var"##940" = var"##938"[2]
                                                                true
                                                            end))))))))
                        iter = var"##939"
                        body = var"##940"
                        t = var"##934"
                        var"##return#826" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##941" = (var"##cache#829").value
                                var"##941" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##941"[1] == :-> && (begin
                                        var"##942" = var"##941"[2]
                                        var"##942" isa AbstractArray
                                    end && (length(var"##942") === 2 && (begin
                                                var"##943" = var"##942"[1]
                                                begin
                                                    var"##cache#945" = nothing
                                                end
                                                var"##944" = var"##942"[2]
                                                var"##944" isa Expr
                                            end && (begin
                                                    if var"##cache#945" === nothing
                                                        var"##cache#945" = Some(((var"##944").head, (var"##944").args))
                                                    end
                                                    var"##946" = (var"##cache#945").value
                                                    var"##946" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##946"[1] == :block && (begin
                                                            var"##947" = var"##946"[2]
                                                            var"##947" isa AbstractArray
                                                        end && (length(var"##947") === 2 && begin
                                                                var"##948" = var"##947"[1]
                                                                var"##949" = var"##947"[2]
                                                                true
                                                            end))))))))
                        line = var"##948"
                        code = var"##949"
                        args = var"##943"
                        var"##return#826" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##950" = (var"##cache#829").value
                                var"##950" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##950"[1] == :-> && (begin
                                        var"##951" = var"##950"[2]
                                        var"##951" isa AbstractArray
                                    end && (length(var"##951") === 2 && begin
                                            var"##952" = var"##951"[1]
                                            var"##953" = var"##951"[2]
                                            true
                                        end)))
                        args = var"##952"
                        body = var"##953"
                        var"##return#826" = begin
                                p(args)
                                keyword(" -> ")
                                print("(")
                                noblock(body)
                                print(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##954" = (var"##cache#829").value
                                var"##954" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##954"[1] == :do && (begin
                                        var"##955" = var"##954"[2]
                                        var"##955" isa AbstractArray
                                    end && (length(var"##955") === 2 && (begin
                                                var"##956" = var"##955"[1]
                                                begin
                                                    var"##cache#958" = nothing
                                                end
                                                var"##957" = var"##955"[2]
                                                var"##957" isa Expr
                                            end && (begin
                                                    if var"##cache#958" === nothing
                                                        var"##cache#958" = Some(((var"##957").head, (var"##957").args))
                                                    end
                                                    var"##959" = (var"##cache#958").value
                                                    var"##959" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##959"[1] == :-> && (begin
                                                            var"##960" = var"##959"[2]
                                                            var"##960" isa AbstractArray
                                                        end && (length(var"##960") === 2 && (begin
                                                                    begin
                                                                        var"##cache#962" = nothing
                                                                    end
                                                                    var"##961" = var"##960"[1]
                                                                    var"##961" isa Expr
                                                                end && (begin
                                                                        if var"##cache#962" === nothing
                                                                            var"##cache#962" = Some(((var"##961").head, (var"##961").args))
                                                                        end
                                                                        var"##963" = (var"##cache#962").value
                                                                        var"##963" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                    end && (var"##963"[1] == :tuple && (begin
                                                                                var"##964" = var"##963"[2]
                                                                                var"##964" isa AbstractArray
                                                                            end && ((ndims(var"##964") === 1 && length(var"##964") >= 0) && begin
                                                                                    var"##965" = SubArray(var"##964", (1:length(var"##964"),))
                                                                                    var"##966" = var"##960"[2]
                                                                                    true
                                                                                end)))))))))))))
                        call = var"##956"
                        args = var"##965"
                        body = var"##966"
                        var"##return#826" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##967" = (var"##cache#829").value
                                var"##967" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##967"[1] == :function && (begin
                                        var"##968" = var"##967"[2]
                                        var"##968" isa AbstractArray
                                    end && (length(var"##968") === 2 && begin
                                            var"##969" = var"##968"[1]
                                            var"##970" = var"##968"[2]
                                            true
                                        end)))
                        call = var"##969"
                        body = var"##970"
                        var"##return#826" = begin
                                print_function(:function, call, body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##971" = (var"##cache#829").value
                                var"##971" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##971"[1] == :quote && (begin
                                        var"##972" = var"##971"[2]
                                        var"##972" isa AbstractArray
                                    end && (length(var"##972") === 1 && begin
                                            var"##973" = var"##972"[1]
                                            true
                                        end)))
                        stmt = var"##973"
                        var"##return#826" = begin
                                keyword(":(")
                                noblock(stmt)
                                keyword(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##974" = (var"##cache#829").value
                                var"##974" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##974"[1] == :quote && (begin
                                        var"##975" = var"##974"[2]
                                        var"##975" isa AbstractArray
                                    end && ((ndims(var"##975") === 1 && length(var"##975") >= 0) && begin
                                            var"##976" = SubArray(var"##975", (1:length(var"##975"),))
                                            true
                                        end)))
                        args = var"##976"
                        var"##return#826" = begin
                                keyword("quote ")
                                with(p.state, :block, false) do 
                                    join(args, "; ")
                                end
                                keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##977" = (var"##cache#829").value
                                var"##977" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##977"[1] == :string && (begin
                                        var"##978" = var"##977"[2]
                                        var"##978" isa AbstractArray
                                    end && ((ndims(var"##978") === 1 && length(var"##978") >= 0) && begin
                                            var"##979" = SubArray(var"##978", (1:length(var"##978"),))
                                            true
                                        end)))
                        args = var"##979"
                        var"##return#826" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##980" = (var"##cache#829").value
                                var"##980" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##980"[1] == :block && (begin
                                        var"##981" = var"##980"[2]
                                        var"##981" isa AbstractArray
                                    end && ((ndims(var"##981") === 1 && length(var"##981") >= 0) && begin
                                            var"##982" = SubArray(var"##981", (1:length(var"##981"),))
                                            let args = var"##982"
                                                length(args) == 2 && (is_line_no(args[1]) && is_line_no(args[2]))
                                            end
                                        end)))
                        args = var"##982"
                        var"##return#826" = begin
                                p(args[1])
                                print(" ")
                                p(args[2])
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##983" = (var"##cache#829").value
                                var"##983" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##983"[1] == :block && (begin
                                        var"##984" = var"##983"[2]
                                        var"##984" isa AbstractArray
                                    end && ((ndims(var"##984") === 1 && length(var"##984") >= 0) && begin
                                            var"##985" = SubArray(var"##984", (1:length(var"##984"),))
                                            let args = var"##985"
                                                length(args) == 2 && is_line_no(args[1])
                                            end
                                        end)))
                        args = var"##985"
                        var"##return#826" = begin
                                p(args[1])
                                print(" ")
                                noblock(args[2])
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##986" = (var"##cache#829").value
                                var"##986" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##986"[1] == :block && (begin
                                        var"##987" = var"##986"[2]
                                        var"##987" isa AbstractArray
                                    end && ((ndims(var"##987") === 1 && length(var"##987") >= 0) && begin
                                            var"##988" = SubArray(var"##987", (1:length(var"##987"),))
                                            let args = var"##988"
                                                length(args) == 2 && is_line_no(args[2])
                                            end
                                        end)))
                        args = var"##988"
                        var"##return#826" = begin
                                noblock(args[1])
                                print(" ")
                                p(args[2])
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##989" = (var"##cache#829").value
                                var"##989" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##989"[1] == :block && (begin
                                        var"##990" = var"##989"[2]
                                        var"##990" isa AbstractArray
                                    end && ((ndims(var"##990") === 1 && length(var"##990") >= 0) && begin
                                            var"##991" = SubArray(var"##990", (1:length(var"##990"),))
                                            let args = var"##991"
                                                length(args) == 2
                                            end
                                        end)))
                        args = var"##991"
                        var"##return#826" = begin
                                print("(")
                                noblock(args[1])
                                keyword("; ")
                                noblock(args[2])
                                print(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##992" = (var"##cache#829").value
                                var"##992" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##992"[1] == :block && (begin
                                        var"##993" = var"##992"[2]
                                        var"##993" isa AbstractArray
                                    end && ((ndims(var"##993") === 1 && length(var"##993") >= 0) && begin
                                            var"##994" = SubArray(var"##993", (1:length(var"##993"),))
                                            true
                                        end)))
                        args = var"##994"
                        var"##return#826" = begin
                                p.state.block && keyword("begin ")
                                with(p.state, :block, true) do 
                                    join(args, "; ")
                                end
                                p.state.block && keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##995" = (var"##cache#829").value
                                var"##995" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##995"[1] == :let && (begin
                                        var"##996" = var"##995"[2]
                                        var"##996" isa AbstractArray
                                    end && (length(var"##996") === 2 && (begin
                                                begin
                                                    var"##cache#998" = nothing
                                                end
                                                var"##997" = var"##996"[1]
                                                var"##997" isa Expr
                                            end && (begin
                                                    if var"##cache#998" === nothing
                                                        var"##cache#998" = Some(((var"##997").head, (var"##997").args))
                                                    end
                                                    var"##999" = (var"##cache#998").value
                                                    var"##999" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##999"[1] == :block && (begin
                                                            var"##1000" = var"##999"[2]
                                                            var"##1000" isa AbstractArray
                                                        end && ((ndims(var"##1000") === 1 && length(var"##1000") >= 0) && begin
                                                                var"##1001" = SubArray(var"##1000", (1:length(var"##1000"),))
                                                                var"##1002" = var"##996"[2]
                                                                true
                                                            end))))))))
                        args = var"##1001"
                        body = var"##1002"
                        var"##return#826" = begin
                                keyword("let ")
                                join(args, ", ")
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##1003" = (var"##cache#829").value
                                var"##1003" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1003"[1] == :let && (begin
                                        var"##1004" = var"##1003"[2]
                                        var"##1004" isa AbstractArray
                                    end && (length(var"##1004") === 2 && begin
                                            var"##1005" = var"##1004"[1]
                                            var"##1006" = var"##1004"[2]
                                            true
                                        end)))
                        arg = var"##1005"
                        body = var"##1006"
                        var"##return#826" = begin
                                keyword("let ")
                                p(arg)
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##1007" = (var"##cache#829").value
                                var"##1007" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1007"[1] == :macrocall && (begin
                                        var"##1008" = var"##1007"[2]
                                        var"##1008" isa AbstractArray
                                    end && ((ndims(var"##1008") === 1 && length(var"##1008") >= 2) && begin
                                            var"##1009" = var"##1008"[1]
                                            var"##1010" = var"##1008"[2]
                                            var"##1011" = SubArray(var"##1008", (3:length(var"##1008"),))
                                            true
                                        end)))
                        f = var"##1009"
                        line = var"##1010"
                        args = var"##1011"
                        var"##return#826" = begin
                                p.line && printstyled(line, color = c.comment)
                                macrocall(f)
                                print_braces(args, "(", ")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##1012" = (var"##cache#829").value
                                var"##1012" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1012"[1] == :return && (begin
                                        var"##1013" = var"##1012"[2]
                                        var"##1013" isa AbstractArray
                                    end && (length(var"##1013") === 1 && (begin
                                                begin
                                                    var"##cache#1015" = nothing
                                                end
                                                var"##1014" = var"##1013"[1]
                                                var"##1014" isa Expr
                                            end && (begin
                                                    if var"##cache#1015" === nothing
                                                        var"##cache#1015" = Some(((var"##1014").head, (var"##1014").args))
                                                    end
                                                    var"##1016" = (var"##cache#1015").value
                                                    var"##1016" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1016"[1] == :tuple && (begin
                                                            var"##1017" = var"##1016"[2]
                                                            var"##1017" isa AbstractArray
                                                        end && ((ndims(var"##1017") === 1 && length(var"##1017") >= 1) && (begin
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
                                                                    end && (var"##1020"[1] == :parameters && (begin
                                                                                var"##1021" = var"##1020"[2]
                                                                                var"##1021" isa AbstractArray
                                                                            end && ((ndims(var"##1021") === 1 && length(var"##1021") >= 0) && begin
                                                                                    var"##1022" = SubArray(var"##1021", (1:length(var"##1021"),))
                                                                                    var"##1023" = SubArray(var"##1017", (2:length(var"##1017"),))
                                                                                    true
                                                                                end)))))))))))))
                        args = var"##1023"
                        kwargs = var"##1022"
                        var"##return#826" = begin
                                keyword("return ")
                                p(Expr(:tuple, Expr(:parameters, kwargs...), args...))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##1024" = (var"##cache#829").value
                                var"##1024" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1024"[1] == :return && (begin
                                        var"##1025" = var"##1024"[2]
                                        var"##1025" isa AbstractArray
                                    end && (length(var"##1025") === 1 && (begin
                                                begin
                                                    var"##cache#1027" = nothing
                                                end
                                                var"##1026" = var"##1025"[1]
                                                var"##1026" isa Expr
                                            end && (begin
                                                    if var"##cache#1027" === nothing
                                                        var"##cache#1027" = Some(((var"##1026").head, (var"##1026").args))
                                                    end
                                                    var"##1028" = (var"##cache#1027").value
                                                    var"##1028" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1028"[1] == :tuple && (begin
                                                            var"##1029" = var"##1028"[2]
                                                            var"##1029" isa AbstractArray
                                                        end && ((ndims(var"##1029") === 1 && length(var"##1029") >= 0) && begin
                                                                var"##1030" = SubArray(var"##1029", (1:length(var"##1029"),))
                                                                true
                                                            end))))))))
                        args = var"##1030"
                        var"##return#826" = begin
                                keyword("return ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##1031" = (var"##cache#829").value
                                var"##1031" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1031"[1] == :return && (begin
                                        var"##1032" = var"##1031"[2]
                                        var"##1032" isa AbstractArray
                                    end && ((ndims(var"##1032") === 1 && length(var"##1032") >= 0) && begin
                                            var"##1033" = SubArray(var"##1032", (1:length(var"##1032"),))
                                            true
                                        end)))
                        args = var"##1033"
                        var"##return#826" = begin
                                keyword("return ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##1034" = (var"##cache#829").value
                                var"##1034" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1034"[1] == :module && (begin
                                        var"##1035" = var"##1034"[2]
                                        var"##1035" isa AbstractArray
                                    end && (length(var"##1035") === 3 && begin
                                            var"##1036" = var"##1035"[1]
                                            var"##1037" = var"##1035"[2]
                                            var"##1038" = var"##1035"[3]
                                            true
                                        end)))
                        bare = var"##1036"
                        name = var"##1037"
                        body = var"##1038"
                        var"##return#826" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##1039" = (var"##cache#829").value
                                var"##1039" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1039"[1] == :using && (begin
                                        var"##1040" = var"##1039"[2]
                                        var"##1040" isa AbstractArray
                                    end && ((ndims(var"##1040") === 1 && length(var"##1040") >= 0) && begin
                                            var"##1041" = SubArray(var"##1040", (1:length(var"##1040"),))
                                            true
                                        end)))
                        args = var"##1041"
                        var"##return#826" = begin
                                keyword("using ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##1042" = (var"##cache#829").value
                                var"##1042" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1042"[1] == :import && (begin
                                        var"##1043" = var"##1042"[2]
                                        var"##1043" isa AbstractArray
                                    end && ((ndims(var"##1043") === 1 && length(var"##1043") >= 0) && begin
                                            var"##1044" = SubArray(var"##1043", (1:length(var"##1043"),))
                                            true
                                        end)))
                        args = var"##1044"
                        var"##return#826" = begin
                                keyword("import ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##1045" = (var"##cache#829").value
                                var"##1045" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1045"[1] == :as && (begin
                                        var"##1046" = var"##1045"[2]
                                        var"##1046" isa AbstractArray
                                    end && (length(var"##1046") === 2 && begin
                                            var"##1047" = var"##1046"[1]
                                            var"##1048" = var"##1046"[2]
                                            true
                                        end)))
                        name = var"##1047"
                        alias = var"##1048"
                        var"##return#826" = begin
                                p(name)
                                keyword(" as ")
                                p(alias)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##1049" = (var"##cache#829").value
                                var"##1049" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1049"[1] == :export && (begin
                                        var"##1050" = var"##1049"[2]
                                        var"##1050" isa AbstractArray
                                    end && ((ndims(var"##1050") === 1 && length(var"##1050") >= 0) && begin
                                            var"##1051" = SubArray(var"##1050", (1:length(var"##1050"),))
                                            true
                                        end)))
                        args = var"##1051"
                        var"##return#826" = begin
                                keyword("export ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##1052" = (var"##cache#829").value
                                var"##1052" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1052"[1] == :(:) && (begin
                                        var"##1053" = var"##1052"[2]
                                        var"##1053" isa AbstractArray
                                    end && ((ndims(var"##1053") === 1 && length(var"##1053") >= 1) && begin
                                            var"##1054" = var"##1053"[1]
                                            var"##1055" = SubArray(var"##1053", (2:length(var"##1053"),))
                                            true
                                        end)))
                        args = var"##1055"
                        head = var"##1054"
                        var"##return#826" = begin
                                p(head)
                                keyword(": ")
                                join(args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##1056" = (var"##cache#829").value
                                var"##1056" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1056"[1] == :where && (begin
                                        var"##1057" = var"##1056"[2]
                                        var"##1057" isa AbstractArray
                                    end && ((ndims(var"##1057") === 1 && length(var"##1057") >= 1) && begin
                                            var"##1058" = var"##1057"[1]
                                            var"##1059" = SubArray(var"##1057", (2:length(var"##1057"),))
                                            true
                                        end)))
                        body = var"##1058"
                        whereparams = var"##1059"
                        var"##return#826" = begin
                                p(body)
                                keyword(" where {")
                                with(p.state, :type, true) do 
                                    join(whereparams, ", ")
                                end
                                keyword("}")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##1060" = (var"##cache#829").value
                                var"##1060" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1060"[1] == :for && (begin
                                        var"##1061" = var"##1060"[2]
                                        var"##1061" isa AbstractArray
                                    end && (length(var"##1061") === 2 && begin
                                            var"##1062" = var"##1061"[1]
                                            var"##1063" = var"##1061"[2]
                                            true
                                        end)))
                        body = var"##1063"
                        iteration = var"##1062"
                        var"##return#826" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##1064" = (var"##cache#829").value
                                var"##1064" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1064"[1] == :while && (begin
                                        var"##1065" = var"##1064"[2]
                                        var"##1065" isa AbstractArray
                                    end && (length(var"##1065") === 2 && begin
                                            var"##1066" = var"##1065"[1]
                                            var"##1067" = var"##1065"[2]
                                            true
                                        end)))
                        body = var"##1067"
                        condition = var"##1066"
                        var"##return#826" = begin
                                keyword("while ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##1068" = (var"##cache#829").value
                                var"##1068" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1068"[1] == :continue && (begin
                                        var"##1069" = var"##1068"[2]
                                        var"##1069" isa AbstractArray
                                    end && isempty(var"##1069")))
                        var"##return#826" = begin
                                keyword("continue")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##1070" = (var"##cache#829").value
                                var"##1070" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1070"[1] == :if && (begin
                                        var"##1071" = var"##1070"[2]
                                        var"##1071" isa AbstractArray
                                    end && (length(var"##1071") === 2 && begin
                                            var"##1072" = var"##1071"[1]
                                            var"##1073" = var"##1071"[2]
                                            true
                                        end)))
                        body = var"##1073"
                        condition = var"##1072"
                        var"##return#826" = begin
                                keyword("if ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##1074" = (var"##cache#829").value
                                var"##1074" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1074"[1] == :if && (begin
                                        var"##1075" = var"##1074"[2]
                                        var"##1075" isa AbstractArray
                                    end && (length(var"##1075") === 3 && begin
                                            var"##1076" = var"##1075"[1]
                                            var"##1077" = var"##1075"[2]
                                            var"##1078" = var"##1075"[3]
                                            true
                                        end)))
                        body = var"##1077"
                        elsebody = var"##1078"
                        condition = var"##1076"
                        var"##return#826" = begin
                                keyword("if ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                                keyword("; ")
                                Meta.isexpr(elsebody, :elseif) || keyword("else ")
                                noblock(elsebody)
                                keyword("; end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##1079" = (var"##cache#829").value
                                var"##1079" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1079"[1] == :elseif && (begin
                                        var"##1080" = var"##1079"[2]
                                        var"##1080" isa AbstractArray
                                    end && (length(var"##1080") === 2 && begin
                                            var"##1081" = var"##1080"[1]
                                            var"##1082" = var"##1080"[2]
                                            true
                                        end)))
                        body = var"##1082"
                        condition = var"##1081"
                        var"##return#826" = begin
                                keyword("elseif ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##1083" = (var"##cache#829").value
                                var"##1083" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1083"[1] == :elseif && (begin
                                        var"##1084" = var"##1083"[2]
                                        var"##1084" isa AbstractArray
                                    end && (length(var"##1084") === 3 && begin
                                            var"##1085" = var"##1084"[1]
                                            var"##1086" = var"##1084"[2]
                                            var"##1087" = var"##1084"[3]
                                            true
                                        end)))
                        body = var"##1086"
                        elsebody = var"##1087"
                        condition = var"##1085"
                        var"##return#826" = begin
                                keyword("elseif ")
                                noblock(condition)
                                keyword("; ")
                                noblock(body)
                                keyword("; ")
                                Meta.isexpr(elsebody, :elseif) || keyword("else")
                                noblock(elsebody)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##1088" = (var"##cache#829").value
                                var"##1088" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1088"[1] == :try && (begin
                                        var"##1089" = var"##1088"[2]
                                        var"##1089" isa AbstractArray
                                    end && (length(var"##1089") === 3 && begin
                                            var"##1090" = var"##1089"[1]
                                            var"##1091" = var"##1089"[2]
                                            var"##1092" = var"##1089"[3]
                                            true
                                        end)))
                        catch_vars = var"##1091"
                        catch_body = var"##1092"
                        try_body = var"##1090"
                        var"##return#826" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##1093" = (var"##cache#829").value
                                var"##1093" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1093"[1] == :try && (begin
                                        var"##1094" = var"##1093"[2]
                                        var"##1094" isa AbstractArray
                                    end && (length(var"##1094") === 4 && begin
                                            var"##1095" = var"##1094"[1]
                                            var"##1096" = var"##1094"[2]
                                            var"##1097" = var"##1094"[3]
                                            var"##1098" = var"##1094"[4]
                                            true
                                        end)))
                        catch_vars = var"##1096"
                        catch_body = var"##1097"
                        try_body = var"##1095"
                        finally_body = var"##1098"
                        var"##return#826" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##1099" = (var"##cache#829").value
                                var"##1099" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1099"[1] == :try && (begin
                                        var"##1100" = var"##1099"[2]
                                        var"##1100" isa AbstractArray
                                    end && (length(var"##1100") === 5 && begin
                                            var"##1101" = var"##1100"[1]
                                            var"##1102" = var"##1100"[2]
                                            var"##1103" = var"##1100"[3]
                                            var"##1104" = var"##1100"[4]
                                            var"##1105" = var"##1100"[5]
                                            true
                                        end)))
                        catch_vars = var"##1102"
                        catch_body = var"##1103"
                        try_body = var"##1101"
                        finally_body = var"##1104"
                        else_body = var"##1105"
                        var"##return#826" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##1106" = (var"##cache#829").value
                                var"##1106" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1106"[1] == :struct && (begin
                                        var"##1107" = var"##1106"[2]
                                        var"##1107" isa AbstractArray
                                    end && (length(var"##1107") === 3 && begin
                                            var"##1108" = var"##1107"[1]
                                            var"##1109" = var"##1107"[2]
                                            var"##1110" = var"##1107"[3]
                                            true
                                        end)))
                        ismutable = var"##1108"
                        name = var"##1109"
                        body = var"##1110"
                        var"##return#826" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##1111" = (var"##cache#829").value
                                var"##1111" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1111"[1] == :abstract && (begin
                                        var"##1112" = var"##1111"[2]
                                        var"##1112" isa AbstractArray
                                    end && (length(var"##1112") === 1 && begin
                                            var"##1113" = var"##1112"[1]
                                            true
                                        end)))
                        name = var"##1113"
                        var"##return#826" = begin
                                keyword("abstract type ")
                                p(name)
                                keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##1114" = (var"##cache#829").value
                                var"##1114" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1114"[1] == :primitive && (begin
                                        var"##1115" = var"##1114"[2]
                                        var"##1115" isa AbstractArray
                                    end && (length(var"##1115") === 2 && begin
                                            var"##1116" = var"##1115"[1]
                                            var"##1117" = var"##1115"[2]
                                            true
                                        end)))
                        name = var"##1116"
                        size = var"##1117"
                        var"##return#826" = begin
                                keyword("primitive type ")
                                p(name)
                                print(" ")
                                p(size)
                                keyword(" end")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##1118" = (var"##cache#829").value
                                var"##1118" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1118"[1] == :meta && (begin
                                        var"##1119" = var"##1118"[2]
                                        var"##1119" isa AbstractArray
                                    end && (length(var"##1119") === 1 && var"##1119"[1] == :inline)))
                        var"##return#826" = begin
                                macrocall(GlobalRef(Base, Symbol("@_inline_meta")))
                                keyword(";")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##1120" = (var"##cache#829").value
                                var"##1120" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1120"[1] == :break && (begin
                                        var"##1121" = var"##1120"[2]
                                        var"##1121" isa AbstractArray
                                    end && isempty(var"##1121")))
                        var"##return#826" = begin
                                keyword("break")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##1122" = (var"##cache#829").value
                                var"##1122" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1122"[1] == :symboliclabel && (begin
                                        var"##1123" = var"##1122"[2]
                                        var"##1123" isa AbstractArray
                                    end && (length(var"##1123") === 1 && begin
                                            var"##1124" = var"##1123"[1]
                                            true
                                        end)))
                        label = var"##1124"
                        var"##return#826" = begin
                                macrocall(GlobalRef(Base, Symbol("@label")))
                                print(" ")
                                p(label)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##1125" = (var"##cache#829").value
                                var"##1125" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1125"[1] == :symbolicgoto && (begin
                                        var"##1126" = var"##1125"[2]
                                        var"##1126" isa AbstractArray
                                    end && (length(var"##1126") === 1 && begin
                                            var"##1127" = var"##1126"[1]
                                            true
                                        end)))
                        label = var"##1127"
                        var"##return#826" = begin
                                macrocall(GlobalRef(Base, Symbol("@goto")))
                                print(" ")
                                p(label)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    if begin
                                var"##1128" = (var"##cache#829").value
                                var"##1128" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1129" = var"##1128"[1]
                                    var"##1130" = var"##1128"[2]
                                    var"##1130" isa AbstractArray
                                end && ((ndims(var"##1130") === 1 && length(var"##1130") >= 0) && begin
                                        var"##1131" = SubArray(var"##1130", (1:length(var"##1130"),))
                                        true
                                    end))
                        args = var"##1131"
                        head = var"##1129"
                        var"##return#826" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                end
                if var"##828" isa QuoteNode
                    if ex.value in Base.quoted_syms
                        var"##return#826" = begin
                                keyword(":(")
                                quoted(ex.value)
                                keyword(")")
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                    begin
                        var"##return#826" = begin
                                if ex.value isa Symbol && Base.isidentifier(ex.value)
                                    keyword(":")
                                    quoted(ex.value)
                                else
                                    keyword(":(")
                                    quoted(ex.value)
                                    keyword(")")
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                end
                if var"##828" isa String
                    begin
                        var"##return#826" = begin
                                string(ex)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                end
                if var"##828" isa LineNumberNode
                    begin
                        var"##return#826" = begin
                                p.line || return nothing
                                printstyled("#= $(ex.file):$(ex.line) =#", color = c.line)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                    end
                end
                begin
                    var"##return#826" = begin
                            print(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#827#1132")))
                end
                error("matching non-exhaustive, at #= none:142 =#")
                $(Expr(:symboliclabel, Symbol("####final#827#1132")))
                var"##return#826"
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
