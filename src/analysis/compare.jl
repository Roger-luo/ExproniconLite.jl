
    struct EmptyLine
    end
    const empty_line = EmptyLine()
    Base.show(io::IO, ::EmptyLine) = begin
            print(io, "<empty line>")
        end
    #= none:5 =# Core.@doc "    struct Variable\n\nMarks a `Symbol` as a variable. So that [`compare_expr`](@ref)\nwill always return `true`.\n" struct Variable
            name::Symbol
        end
    Base.show(io::IO, x::Variable) = begin
            printstyled(io, "<", x.name, ">"; color = :light_blue)
        end
    function locate_inequal_expr(m::Module, lhs, rhs)
        lhs isa Expr && rhs isa Expr || return (lhs, rhs)
        if length(lhs.args) > length(rhs.args)
            (lhs, rhs) = (rhs, lhs)
        end
        not_equals = Tuple{Any, Any}[]
        for (l, r) = zip(lhs.args, rhs.args)
            if !(compare_expr(m, l, r))
                push!(not_equals, (l, r))
            end
        end
        for each = rhs.args[length(lhs.args) + 1:var"end"]
            push!(not_equals, (empty_line, each))
        end
        if length(not_equals) == length(rhs.args)
            return (lhs, rhs)
        else
            return locate_inequal_expr(m, first(not_equals)...)
        end
    end
    #= none:46 =# Core.@doc "    assert_equal_expr(m::Module, lhs, rhs)\n\nAssert that `lhs` and `rhs` are equal in `m`.\nThrow an `ExprNotEqual` if they are not equal.\n" function assert_equal_expr(m::Module, lhs, rhs)
            lhs = prettify(lhs; preserve_last_nothing = true, alias_gensym = false)
            rhs = prettify(rhs; preserve_last_nothing = true, alias_gensym = false)
            lhs = renumber_gensym(lhs)
            rhs = renumber_gensym(rhs)
            compare_expr(m, lhs, rhs) && return true
            (lhs, rhs) = locate_inequal_expr(m, lhs, rhs)
            throw(ExprNotEqual(lhs, rhs))
        end
    #= none:62 =# Core.@doc "    @test_expr <type> <ex>\n\nTest if the syntax type generates the same expression `ex`. Returns the\ncorresponding syntax type instance. Requires `using Test` before using\nthis macro.\n\n# Example\n\n```julia\ndef = @test_expr JLFunction function (x, y)\n    return 2\nend\n@test is_kw_fn(def) == false\n```\n" macro test_expr(type, ex)
            #= none:79 =# @gensym def generated_expr original_expr
            quote
                    $def = #= none:81 =# ExproniconLite.@expr($type, $ex)
                    ($Base).show(stdout, (MIME"text/plain")(), $def)
                    $generated_expr = ($codegen_ast)($def)
                    $original_expr = $(Expr(:quote, ex))
                    #= none:85 =# @test $(Expr(:block, __source__, :(($assert_equal_expr)($__module__, $generated_expr, $original_expr))))
                    $def
                end |> esc
        end
    #= none:93 =# Core.@doc "    @test_expr <expr> == <expr>\n\nTest if two expression is equivalent semantically, this uses `compare_expr`\nto decide if they are equivalent, ignores things such as `LineNumberNode`\ngenerated `Symbol` in `Expr(:curly, ...)` or `Expr(:where, ...)`.\n\n!!! note\n\n    This macro requires one `using Test` to import the `Test` module\n    name.\n" macro test_expr(ex::Expr)
            esc(test_expr_m(__module__, __source__, ex))
        end
    function test_expr_m(__module__, __source__, ex::Expr)
        ex.head === :call && ex.args[1] === :(==) || error("expect <expr> == <expr>, got $(ex)")
        (lhs, rhs) = (ex.args[2], ex.args[3])
        #= none:112 =# @gensym result cmp_result err
        return quote
                $result = try
                        $cmp_result = ($assert_equal_expr)($__module__, $lhs, $rhs)
                        Test.Returned($cmp_result, nothing, $(QuoteNode(__source__)))
                    catch $err
                        $err isa Test.InterruptException && Test.rethrow()
                        Test.Threw($err, ($Base).current_exceptions(), $(QuoteNode(__source__)))
                    end
                Test.do_test($result, $(QuoteNode(ex)))
            end
    end
    macro compare_expr(lhs, rhs)
        return quote
                    ($ExproniconLite).compare_expr($__module__, $lhs, $rhs)
                end |> esc
    end
    #= none:137 =# Core.@doc "    compare_expr([m=Main], lhs, rhs)\n\nCompare two expression of type `Expr` or `Symbol` semantically, which:\n\n1. ignore the detail value `LineNumberNode` in comparision;\n2. ignore the detailed name of typevars declared by `where`;\n3. recognize inserted objects and `Symbol`, e.g `:(\$Int)` is equal to `:(Int)`;\n4. recognize `QuoteNode(:x)` and `Symbol(\"x\")` as equal;\n5. will guess module and type objects and compare their value directly\n    instead of their expression;\n\n!!! tips\n\n    This function is usually combined with [`prettify`](@ref)\n    with `preserve_last_nothing=true` and `alias_gensym=false`.\n\nThis gives a way to compare two Julia expression semantically which means\nalthough some details of the expression is different but they should\nproduce the same lowered code.\n" compare_expr(lhs, rhs) = begin
                compare_expr(Main, lhs, rhs)
            end
    function compare_expr(m::Module, lhs, rhs)
        begin
            true
            var"##233" = (lhs, rhs)
            if var"##233" isa Tuple{Any, Any}
                if var"##233" isa Tuple{Symbol, Symbol} && (begin
                                var"##234" = var"##233"[1]
                                var"##234" isa Symbol
                            end && begin
                                var"##235" = var"##233"[2]
                                var"##235" isa Symbol
                            end)
                    var"##return#231" = begin
                            return lhs === rhs
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#232#282")))
                end
                if var"##233" isa Tuple{Module, Module} && (begin
                                var"##236" = var"##233"[1]
                                var"##236" isa Module
                            end && begin
                                var"##237" = var"##233"[2]
                                var"##237" isa Module
                            end)
                    var"##return#231" = begin
                            return lhs === rhs
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#232#282")))
                end
                if var"##233" isa Tuple{QuoteNode, Expr} && (begin
                                var"##238" = var"##233"[1]
                                var"##238" isa QuoteNode
                            end && (begin
                                    begin
                                        var"##cache#240" = nothing
                                    end
                                    var"##239" = var"##233"[2]
                                    var"##239" isa Expr
                                end && (begin
                                        if var"##cache#240" === nothing
                                            var"##cache#240" = Some(((var"##239").head, (var"##239").args))
                                        end
                                        var"##241" = (var"##cache#240").value
                                        var"##241" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##241"[1] == :call && (begin
                                                var"##242" = var"##241"[2]
                                                var"##242" isa AbstractArray
                                            end && (length(var"##242") === 2 && (var"##242"[1] == :Symbol && begin
                                                        var"##243" = var"##242"[2]
                                                        true
                                                    end)))))))
                    a = var"##238"
                    b = var"##243"
                    var"##return#231" = begin
                            isdefined(m, :Symbol) || return false
                            return a.value === Symbol(b)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#232#282")))
                end
                if var"##233" isa Tuple{Expr, QuoteNode} && (begin
                                begin
                                    var"##cache#245" = nothing
                                end
                                var"##244" = var"##233"[1]
                                var"##244" isa Expr
                            end && (begin
                                    if var"##cache#245" === nothing
                                        var"##cache#245" = Some(((var"##244").head, (var"##244").args))
                                    end
                                    var"##246" = (var"##cache#245").value
                                    var"##246" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##246"[1] == :call && (begin
                                            var"##247" = var"##246"[2]
                                            var"##247" isa AbstractArray
                                        end && (length(var"##247") === 2 && (var"##247"[1] == :Symbol && begin
                                                    var"##248" = var"##247"[2]
                                                    var"##249" = var"##233"[2]
                                                    var"##249" isa QuoteNode
                                                end))))))
                    a = var"##249"
                    b = var"##248"
                    var"##return#231" = begin
                            isdefined(m, :Symbol) || return false
                            return a.value === Symbol(b)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#232#282")))
                end
                if var"##233" isa Tuple{Expr, Expr} && (begin
                                var"##250" = var"##233"[1]
                                var"##250" isa Expr
                            end && begin
                                var"##251" = var"##233"[2]
                                var"##251" isa Expr
                            end)
                    var"##return#231" = begin
                            return compare_expr_object(m, lhs, rhs)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#232#282")))
                end
                if var"##233" isa (Tuple{Expr, var2} where var2 <: Type) && (begin
                                begin
                                    var"##cache#253" = nothing
                                end
                                var"##252" = var"##233"[1]
                                var"##252" isa Expr
                            end && (begin
                                    if var"##cache#253" === nothing
                                        var"##cache#253" = Some(((var"##252").head, (var"##252").args))
                                    end
                                    var"##254" = (var"##cache#253").value
                                    var"##254" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##254"[1] == :curly && (begin
                                            var"##255" = var"##254"[2]
                                            var"##255" isa AbstractArray
                                        end && ((ndims(var"##255") === 1 && length(var"##255") >= 0) && begin
                                                var"##256" = var"##233"[2]
                                                var"##256" isa Type
                                            end)))))
                    var"##return#231" = begin
                            return guess_type(m, lhs) == rhs
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#232#282")))
                end
                if var"##233" isa (Tuple{var1, Expr} where var1 <: Type) && (begin
                                var"##257" = var"##233"[1]
                                var"##257" isa Type
                            end && (begin
                                    begin
                                        var"##cache#259" = nothing
                                    end
                                    var"##258" = var"##233"[2]
                                    var"##258" isa Expr
                                end && (begin
                                        if var"##cache#259" === nothing
                                            var"##cache#259" = Some(((var"##258").head, (var"##258").args))
                                        end
                                        var"##260" = (var"##cache#259").value
                                        var"##260" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##260"[1] == :curly && (begin
                                                var"##261" = var"##260"[2]
                                                var"##261" isa AbstractArray
                                            end && (ndims(var"##261") === 1 && length(var"##261") >= 0))))))
                    var"##return#231" = begin
                            return lhs == guess_type(m, rhs)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#232#282")))
                end
                if var"##233" isa (Tuple{var1, Symbol} where var1) && begin
                            var"##262" = var"##233"[1]
                            var"##263" = var"##233"[2]
                            var"##263" isa Symbol
                        end
                    a = var"##262"
                    b = var"##263"
                    var"##return#231" = begin
                            isdefined(m, b) || return false
                            return getfield(m, b) === a
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#232#282")))
                end
                if var"##233" isa (Tuple{Symbol, var2} where var2) && (begin
                                var"##264" = var"##233"[1]
                                var"##264" isa Symbol
                            end && begin
                                var"##265" = var"##233"[2]
                                true
                            end)
                    a = var"##265"
                    b = var"##264"
                    var"##return#231" = begin
                            isdefined(m, b) || return false
                            return getfield(m, b) === a
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#232#282")))
                end
                if var"##233" isa (Tuple{var1, Expr} where var1) && begin
                            var"##266" = var"##233"[1]
                            var"##267" = var"##233"[2]
                            var"##267" isa Expr
                        end
                    a = var"##266"
                    b = var"##267"
                    var"##return#231" = begin
                            try
                                return a == Base.eval(m, b)
                            catch _
                                return false
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#232#282")))
                end
                if var"##233" isa (Tuple{Expr, var2} where var2) && (begin
                                var"##268" = var"##233"[1]
                                var"##268" isa Expr
                            end && begin
                                var"##269" = var"##233"[2]
                                true
                            end)
                    a = var"##269"
                    b = var"##268"
                    var"##return#231" = begin
                            try
                                return a == Base.eval(m, b)
                            catch _
                                return false
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#232#282")))
                end
                if var"##233" isa (Tuple{Module, var2} where var2) && (begin
                                var"##270" = var"##233"[1]
                                var"##270" isa Module
                            end && begin
                                var"##271" = var"##233"[2]
                                true
                            end)
                    a = var"##270"
                    b = var"##271"
                    var"##return#231" = begin
                            mod = guess_module(m, b)
                            isnothing(mod) && return false
                            return a === mod
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#232#282")))
                end
                if var"##233" isa (Tuple{var1, Module} where var1) && begin
                            var"##272" = var"##233"[1]
                            var"##273" = var"##233"[2]
                            var"##273" isa Module
                        end
                    a = var"##273"
                    b = var"##272"
                    var"##return#231" = begin
                            mod = guess_module(m, b)
                            isnothing(mod) && return false
                            return a === mod
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#232#282")))
                end
            end
            if var"##233" isa Tuple{Variable, Variable}
                if begin
                            var"##274" = var"##233"[1]
                            var"##274" isa Variable
                        end && begin
                            var"##275" = var"##233"[2]
                            var"##275" isa Variable
                        end
                    var"##return#231" = begin
                            return true
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#232#282")))
                end
            end
            if var"##233" isa Tuple{LineNumberNode, LineNumberNode}
                if begin
                            var"##276" = var"##233"[1]
                            var"##276" isa LineNumberNode
                        end && begin
                            var"##277" = var"##233"[2]
                            var"##277" isa LineNumberNode
                        end
                    var"##return#231" = begin
                            return true
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#232#282")))
                end
            end
            if var"##233" isa Tuple{TypeVar, TypeVar}
                if begin
                            var"##278" = var"##233"[1]
                            var"##278" isa TypeVar
                        end && begin
                            var"##279" = var"##233"[2]
                            var"##279" isa TypeVar
                        end
                    var"##return#231" = begin
                            compare_expr(m, lhs.lb, rhs.lb) || return false
                            compare_expr(m, lhs.ub, rhs.ub) || return false
                            return true
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#232#282")))
                end
            end
            if var"##233" isa Tuple{GlobalRef, GlobalRef}
                if begin
                            var"##280" = var"##233"[1]
                            var"##280" isa GlobalRef
                        end && begin
                            var"##281" = var"##233"[2]
                            var"##281" isa GlobalRef
                        end
                    var"##return#231" = begin
                            return lhs === rhs
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#232#282")))
                end
            end
            begin
                var"##return#231" = begin
                        return lhs == rhs
                    end
                $(Expr(:symbolicgoto, Symbol("####final#232#282")))
            end
            error("matching non-exhaustive, at #= none:161 =#")
            $(Expr(:symboliclabel, Symbol("####final#232#282")))
            var"##return#231"
        end
    end
    function compare_expr_object(m::Module, lhs::Expr, rhs::Expr)
        begin
            true
            var"##285" = (lhs, rhs)
            if var"##285" isa Tuple{Expr, Expr}
                if begin
                            begin
                                var"##cache#287" = nothing
                            end
                            var"##286" = var"##285"[1]
                            var"##286" isa Expr
                        end && (begin
                                if var"##cache#287" === nothing
                                    var"##cache#287" = Some(((var"##286").head, (var"##286").args))
                                end
                                var"##288" = (var"##cache#287").value
                                var"##288" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##288"[1] == :(::) && (begin
                                        var"##289" = var"##288"[2]
                                        var"##289" isa AbstractArray
                                    end && (length(var"##289") === 1 && (begin
                                                var"##290" = var"##289"[1]
                                                begin
                                                    var"##cache#292" = nothing
                                                end
                                                var"##291" = var"##285"[2]
                                                var"##291" isa Expr
                                            end && (begin
                                                    if var"##cache#292" === nothing
                                                        var"##cache#292" = Some(((var"##291").head, (var"##291").args))
                                                    end
                                                    var"##293" = (var"##cache#292").value
                                                    var"##293" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##293"[1] == :(::) && (begin
                                                            var"##294" = var"##293"[2]
                                                            var"##294" isa AbstractArray
                                                        end && (length(var"##294") === 1 && begin
                                                                var"##295" = var"##294"[1]
                                                                true
                                                            end)))))))))
                    tx = var"##290"
                    ty = var"##295"
                    var"##return#283" = begin
                            tx = guess_type(m, tx)
                            ty = guess_type(m, ty)
                            return compare_expr(m, tx, ty)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#284#356")))
                end
                if begin
                            begin
                                var"##cache#297" = nothing
                            end
                            var"##296" = var"##285"[1]
                            var"##296" isa Expr
                        end && (begin
                                if var"##cache#297" === nothing
                                    var"##cache#297" = Some(((var"##296").head, (var"##296").args))
                                end
                                var"##298" = (var"##cache#297").value
                                var"##298" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##298"[1] == :(::) && (begin
                                        var"##299" = var"##298"[2]
                                        var"##299" isa AbstractArray
                                    end && (length(var"##299") === 2 && (begin
                                                var"##300" = var"##299"[1]
                                                var"##301" = var"##299"[2]
                                                begin
                                                    var"##cache#303" = nothing
                                                end
                                                var"##302" = var"##285"[2]
                                                var"##302" isa Expr
                                            end && (begin
                                                    if var"##cache#303" === nothing
                                                        var"##cache#303" = Some(((var"##302").head, (var"##302").args))
                                                    end
                                                    var"##304" = (var"##cache#303").value
                                                    var"##304" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##304"[1] == :(::) && (begin
                                                            var"##305" = var"##304"[2]
                                                            var"##305" isa AbstractArray
                                                        end && (length(var"##305") === 2 && begin
                                                                var"##306" = var"##305"[1]
                                                                var"##307" = var"##305"[2]
                                                                true
                                                            end)))))))))
                    tx = var"##301"
                    y = var"##306"
                    ty = var"##307"
                    x = var"##300"
                    var"##return#283" = begin
                            tx = guess_type(m, tx)
                            ty = guess_type(m, ty)
                            return compare_expr(m, x, y) && compare_expr(m, tx, ty)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#284#356")))
                end
                if begin
                            begin
                                var"##cache#309" = nothing
                            end
                            var"##308" = var"##285"[1]
                            var"##308" isa Expr
                        end && (begin
                                if var"##cache#309" === nothing
                                    var"##cache#309" = Some(((var"##308").head, (var"##308").args))
                                end
                                var"##310" = (var"##cache#309").value
                                var"##310" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##310"[1] == :. && (begin
                                        var"##311" = var"##310"[2]
                                        var"##311" isa AbstractArray
                                    end && (length(var"##311") === 2 && (begin
                                                var"##312" = var"##311"[1]
                                                var"##313" = var"##311"[2]
                                                var"##313" isa QuoteNode
                                            end && (begin
                                                    var"##314" = (var"##313").value
                                                    begin
                                                        var"##cache#316" = nothing
                                                    end
                                                    var"##315" = var"##285"[2]
                                                    var"##315" isa Expr
                                                end && (begin
                                                        if var"##cache#316" === nothing
                                                            var"##cache#316" = Some(((var"##315").head, (var"##315").args))
                                                        end
                                                        var"##317" = (var"##cache#316").value
                                                        var"##317" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                    end && (var"##317"[1] == :. && (begin
                                                                var"##318" = var"##317"[2]
                                                                var"##318" isa AbstractArray
                                                            end && (length(var"##318") === 2 && (begin
                                                                        var"##319" = var"##318"[1]
                                                                        var"##320" = var"##318"[2]
                                                                        var"##320" isa QuoteNode
                                                                    end && begin
                                                                        var"##321" = (var"##320").value
                                                                        true
                                                                    end)))))))))))
                    sub_a = var"##314"
                    sub_b = var"##321"
                    mod_b = var"##319"
                    mod_a = var"##312"
                    var"##return#283" = begin
                            mod_a = guess_module(m, mod_a)
                            mod_b = guess_module(m, mod_b)
                            compare_expr(m, mod_a, mod_b) || return false
                            return compare_expr(m, sub_a, sub_b)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#284#356")))
                end
                if begin
                            begin
                                var"##cache#323" = nothing
                            end
                            var"##322" = var"##285"[1]
                            var"##322" isa Expr
                        end && (begin
                                if var"##cache#323" === nothing
                                    var"##cache#323" = Some(((var"##322").head, (var"##322").args))
                                end
                                var"##324" = (var"##cache#323").value
                                var"##324" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##324"[1] == :where && (begin
                                        var"##325" = var"##324"[2]
                                        var"##325" isa AbstractArray
                                    end && ((ndims(var"##325") === 1 && length(var"##325") >= 0) && (begin
                                                begin
                                                    var"##cache#327" = nothing
                                                end
                                                var"##326" = var"##285"[2]
                                                var"##326" isa Expr
                                            end && (begin
                                                    if var"##cache#327" === nothing
                                                        var"##cache#327" = Some(((var"##326").head, (var"##326").args))
                                                    end
                                                    var"##328" = (var"##cache#327").value
                                                    var"##328" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##328"[1] == :where && (begin
                                                            var"##329" = var"##328"[2]
                                                            var"##329" isa AbstractArray
                                                        end && (ndims(var"##329") === 1 && length(var"##329") >= 0)))))))))
                    var"##return#283" = begin
                            return compare_where(m, lhs, rhs)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#284#356")))
                end
                if begin
                            begin
                                var"##cache#331" = nothing
                            end
                            var"##330" = var"##285"[1]
                            var"##330" isa Expr
                        end && (begin
                                if var"##cache#331" === nothing
                                    var"##cache#331" = Some(((var"##330").head, (var"##330").args))
                                end
                                var"##332" = (var"##cache#331").value
                                var"##332" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##332"[1] == :curly && (begin
                                        var"##333" = var"##332"[2]
                                        var"##333" isa AbstractArray
                                    end && ((ndims(var"##333") === 1 && length(var"##333") >= 0) && (begin
                                                begin
                                                    var"##cache#335" = nothing
                                                end
                                                var"##334" = var"##285"[2]
                                                var"##334" isa Expr
                                            end && (begin
                                                    if var"##cache#335" === nothing
                                                        var"##cache#335" = Some(((var"##334").head, (var"##334").args))
                                                    end
                                                    var"##336" = (var"##cache#335").value
                                                    var"##336" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##336"[1] == :curly && (begin
                                                            var"##337" = var"##336"[2]
                                                            var"##337" isa AbstractArray
                                                        end && (ndims(var"##337") === 1 && length(var"##337") >= 0)))))))))
                    var"##return#283" = begin
                            return compare_curly(m, lhs, rhs)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#284#356")))
                end
                if begin
                            begin
                                var"##cache#339" = nothing
                            end
                            var"##338" = var"##285"[1]
                            var"##338" isa Expr
                        end && (begin
                                if var"##cache#339" === nothing
                                    var"##cache#339" = Some(((var"##338").head, (var"##338").args))
                                end
                                var"##340" = (var"##cache#339").value
                                var"##340" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##340"[1] == :macrocall && (begin
                                        var"##341" = var"##340"[2]
                                        var"##341" isa AbstractArray
                                    end && ((ndims(var"##341") === 1 && length(var"##341") >= 0) && (begin
                                                begin
                                                    var"##cache#343" = nothing
                                                end
                                                var"##342" = var"##285"[2]
                                                var"##342" isa Expr
                                            end && (begin
                                                    if var"##cache#343" === nothing
                                                        var"##cache#343" = Some(((var"##342").head, (var"##342").args))
                                                    end
                                                    var"##344" = (var"##cache#343").value
                                                    var"##344" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##344"[1] == :macrocall && (begin
                                                            var"##345" = var"##344"[2]
                                                            var"##345" isa AbstractArray
                                                        end && (ndims(var"##345") === 1 && length(var"##345") >= 0)))))))))
                    var"##return#283" = begin
                            return compare_macrocall(m, lhs, rhs)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#284#356")))
                end
                if begin
                            begin
                                var"##cache#347" = nothing
                            end
                            var"##346" = var"##285"[1]
                            var"##346" isa Expr
                        end && (begin
                                if var"##cache#347" === nothing
                                    var"##cache#347" = Some(((var"##346").head, (var"##346").args))
                                end
                                var"##348" = (var"##cache#347").value
                                var"##348" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##348"[1] == :function && (begin
                                        var"##349" = var"##348"[2]
                                        var"##349" isa AbstractArray
                                    end && ((ndims(var"##349") === 1 && length(var"##349") >= 0) && (begin
                                                begin
                                                    var"##cache#351" = nothing
                                                end
                                                var"##350" = var"##285"[2]
                                                var"##350" isa Expr
                                            end && (begin
                                                    if var"##cache#351" === nothing
                                                        var"##cache#351" = Some(((var"##350").head, (var"##350").args))
                                                    end
                                                    var"##352" = (var"##cache#351").value
                                                    var"##352" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##352"[1] == :function && (begin
                                                            var"##353" = var"##352"[2]
                                                            var"##353" isa AbstractArray
                                                        end && (ndims(var"##353") === 1 && length(var"##353") >= 0)))))))))
                    var"##return#283" = begin
                            return compare_function(m, lhs, rhs)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#284#356")))
                end
                if begin
                            var"##354" = var"##285"[1]
                            var"##354" isa Expr
                        end && begin
                            var"##355" = var"##285"[2]
                            var"##355" isa Expr
                        end
                    var"##return#283" = begin
                            lhs.head === rhs.head || return false
                            length(lhs.args) == length(rhs.args) || return false
                            for (a, b) = zip(lhs.args, rhs.args)
                                compare_expr(m, a, b) || return false
                            end
                            return true
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#284#356")))
                end
            end
            begin
                var"##return#283" = begin
                        return lhs == rhs
                    end
                $(Expr(:symbolicgoto, Symbol("####final#284#356")))
            end
            error("matching non-exhaustive, at #= none:206 =#")
            $(Expr(:symboliclabel, Symbol("####final#284#356")))
            var"##return#283"
        end
    end
    function compare_macrocall(m::Module, lhs::Expr, rhs::Expr)
        length(lhs.args) == length(rhs.args) || return false
        compare_expr(lhs.args[1], rhs.args[1]) || return false
        for (a, b) = zip(lhs.args[3:var"end"], rhs.args[3:var"end"])
            compare_expr(m, a, b) || return false
        end
        return true
    end
    function compare_function(m::Module, lhs::Expr, rhs::Expr)
        (lhs, rhs) = (canonicalize_lambda_head(lhs), canonicalize_lambda_head(rhs))
        compare_expr(m, lhs.args[1], rhs.args[1]) || return false
        length(lhs.args) == length(rhs.args) == 1 && return true
        function is_all_lineno(ex)
            Meta.isexpr(ex, :block) || return false
            return all((x->begin
                            x isa LineNumberNode
                        end), ex.args)
        end
        if length(lhs.args) == 1
            is_all_lineno(rhs.args[2]) && return true
        elseif length(rhs.args) == 1
            is_all_lineno(lhs.args[2]) && return true
        end
        return compare_expr(m, lhs.args[2], rhs.args[2])
    end
    function compare_curly(m::Module, lhs::Expr, rhs::Expr)
        type_a = guess_type(m, lhs)
        type_b = guess_type(m, rhs)
        (name_a, name_b) = (lhs.args[1], rhs.args[1])
        (typevars_a, typevars_b) = (lhs.args[2:var"end"], rhs.args[2:var"end"])
        if type_a isa Type || type_b isa Type
            return type_a === type_b
        else
            compare_expr(m, guess_type(m, name_a), guess_type(m, name_b)) || return false
            length(typevars_a) == length(typevars_b) || return false
            return all(zip(typevars_a, typevars_b)) do (a, b)
                    compare_expr(m, guess_type(m, a), guess_type(m, b))
                end
        end
    end
    function compare_where(m::Module, lhs::Expr, rhs::Expr)
        (lbody, lparams) = (lhs.args[1], lhs.args[2:var"end"])
        (rbody, rparams) = (rhs.args[1], rhs.args[2:var"end"])
        lbody = mark_typevars(lbody, name_only.(lparams))
        rbody = mark_typevars(rbody, name_only.(rparams))
        compare_expr(m, lbody, rbody) || return false
        return all(zip(lparams, rparams)) do (l, r)
                l isa Symbol && (r isa Symbol && return true)
                Meta.isexpr(l, :<:) && Meta.isexpr(r, :<:) || return false
                return compare_expr(m, l.args[2], r.args[2])
            end
    end
    function mark_typevars(expr, typevars::Vector{Symbol})
        sub = Substitute() do expr
                expr isa Symbol && (expr in typevars && return true)
                return false
            end
        return sub(Variable, expr)
    end
