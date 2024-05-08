
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
        for each = rhs.args[length(lhs.args) + 1:end]
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
            var"##317" = (lhs, rhs)
            if var"##317" isa Tuple{Any, Any}
                if var"##317" isa Tuple{Symbol, Symbol} && (begin
                                var"##318" = var"##317"[1]
                                var"##318" isa Symbol
                            end && begin
                                var"##319" = var"##317"[2]
                                var"##319" isa Symbol
                            end)
                    var"##return#315" = begin
                            return lhs === rhs
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#316#366")))
                end
                if var"##317" isa Tuple{Module, Module} && (begin
                                var"##320" = var"##317"[1]
                                var"##320" isa Module
                            end && begin
                                var"##321" = var"##317"[2]
                                var"##321" isa Module
                            end)
                    var"##return#315" = begin
                            return lhs === rhs
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#316#366")))
                end
                if var"##317" isa Tuple{QuoteNode, Expr} && (begin
                                var"##322" = var"##317"[1]
                                var"##322" isa QuoteNode
                            end && (begin
                                    begin
                                        var"##cache#324" = nothing
                                    end
                                    var"##323" = var"##317"[2]
                                    var"##323" isa Expr
                                end && (begin
                                        if var"##cache#324" === nothing
                                            var"##cache#324" = Some(((var"##323").head, (var"##323").args))
                                        end
                                        var"##325" = (var"##cache#324").value
                                        var"##325" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##325"[1] == :call && (begin
                                                var"##326" = var"##325"[2]
                                                var"##326" isa AbstractArray
                                            end && (length(var"##326") === 2 && (var"##326"[1] == :Symbol && begin
                                                        var"##327" = var"##326"[2]
                                                        true
                                                    end)))))))
                    a = var"##322"
                    b = var"##327"
                    var"##return#315" = begin
                            isdefined(m, :Symbol) || return false
                            return a.value === Symbol(b)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#316#366")))
                end
                if var"##317" isa Tuple{Expr, QuoteNode} && (begin
                                begin
                                    var"##cache#329" = nothing
                                end
                                var"##328" = var"##317"[1]
                                var"##328" isa Expr
                            end && (begin
                                    if var"##cache#329" === nothing
                                        var"##cache#329" = Some(((var"##328").head, (var"##328").args))
                                    end
                                    var"##330" = (var"##cache#329").value
                                    var"##330" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##330"[1] == :call && (begin
                                            var"##331" = var"##330"[2]
                                            var"##331" isa AbstractArray
                                        end && (length(var"##331") === 2 && (var"##331"[1] == :Symbol && begin
                                                    var"##332" = var"##331"[2]
                                                    var"##333" = var"##317"[2]
                                                    var"##333" isa QuoteNode
                                                end))))))
                    a = var"##333"
                    b = var"##332"
                    var"##return#315" = begin
                            isdefined(m, :Symbol) || return false
                            return a.value === Symbol(b)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#316#366")))
                end
                if var"##317" isa Tuple{Expr, Expr} && (begin
                                var"##334" = var"##317"[1]
                                var"##334" isa Expr
                            end && begin
                                var"##335" = var"##317"[2]
                                var"##335" isa Expr
                            end)
                    var"##return#315" = begin
                            return compare_expr_object(m, lhs, rhs)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#316#366")))
                end
                if var"##317" isa (Tuple{Expr, var2} where var2 <: Type) && (begin
                                begin
                                    var"##cache#337" = nothing
                                end
                                var"##336" = var"##317"[1]
                                var"##336" isa Expr
                            end && (begin
                                    if var"##cache#337" === nothing
                                        var"##cache#337" = Some(((var"##336").head, (var"##336").args))
                                    end
                                    var"##338" = (var"##cache#337").value
                                    var"##338" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##338"[1] == :curly && (begin
                                            var"##339" = var"##338"[2]
                                            var"##339" isa AbstractArray
                                        end && ((ndims(var"##339") === 1 && length(var"##339") >= 0) && begin
                                                var"##340" = var"##317"[2]
                                                var"##340" isa Type
                                            end)))))
                    var"##return#315" = begin
                            return guess_type(m, lhs) == rhs
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#316#366")))
                end
                if var"##317" isa (Tuple{var1, Expr} where var1 <: Type) && (begin
                                var"##341" = var"##317"[1]
                                var"##341" isa Type
                            end && (begin
                                    begin
                                        var"##cache#343" = nothing
                                    end
                                    var"##342" = var"##317"[2]
                                    var"##342" isa Expr
                                end && (begin
                                        if var"##cache#343" === nothing
                                            var"##cache#343" = Some(((var"##342").head, (var"##342").args))
                                        end
                                        var"##344" = (var"##cache#343").value
                                        var"##344" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##344"[1] == :curly && (begin
                                                var"##345" = var"##344"[2]
                                                var"##345" isa AbstractArray
                                            end && (ndims(var"##345") === 1 && length(var"##345") >= 0))))))
                    var"##return#315" = begin
                            return lhs == guess_type(m, rhs)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#316#366")))
                end
                if var"##317" isa (Tuple{var1, Symbol} where var1) && begin
                            var"##346" = var"##317"[1]
                            var"##347" = var"##317"[2]
                            var"##347" isa Symbol
                        end
                    a = var"##346"
                    b = var"##347"
                    var"##return#315" = begin
                            isdefined(m, b) || return false
                            return getfield(m, b) === a
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#316#366")))
                end
                if var"##317" isa (Tuple{Symbol, var2} where var2) && (begin
                                var"##348" = var"##317"[1]
                                var"##348" isa Symbol
                            end && begin
                                var"##349" = var"##317"[2]
                                true
                            end)
                    a = var"##349"
                    b = var"##348"
                    var"##return#315" = begin
                            isdefined(m, b) || return false
                            return getfield(m, b) === a
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#316#366")))
                end
                if var"##317" isa (Tuple{var1, Expr} where var1) && begin
                            var"##350" = var"##317"[1]
                            var"##351" = var"##317"[2]
                            var"##351" isa Expr
                        end
                    a = var"##350"
                    b = var"##351"
                    var"##return#315" = begin
                            try
                                return a == Base.eval(m, b)
                            catch _
                                return false
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#316#366")))
                end
                if var"##317" isa (Tuple{Expr, var2} where var2) && (begin
                                var"##352" = var"##317"[1]
                                var"##352" isa Expr
                            end && begin
                                var"##353" = var"##317"[2]
                                true
                            end)
                    a = var"##353"
                    b = var"##352"
                    var"##return#315" = begin
                            try
                                return a == Base.eval(m, b)
                            catch _
                                return false
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#316#366")))
                end
                if var"##317" isa (Tuple{Module, var2} where var2) && (begin
                                var"##354" = var"##317"[1]
                                var"##354" isa Module
                            end && begin
                                var"##355" = var"##317"[2]
                                true
                            end)
                    a = var"##354"
                    b = var"##355"
                    var"##return#315" = begin
                            mod = guess_module(m, b)
                            isnothing(mod) && return false
                            return a === mod
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#316#366")))
                end
                if var"##317" isa (Tuple{var1, Module} where var1) && begin
                            var"##356" = var"##317"[1]
                            var"##357" = var"##317"[2]
                            var"##357" isa Module
                        end
                    a = var"##357"
                    b = var"##356"
                    var"##return#315" = begin
                            mod = guess_module(m, b)
                            isnothing(mod) && return false
                            return a === mod
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#316#366")))
                end
            end
            if var"##317" isa Tuple{TypeVar, TypeVar}
                if begin
                            var"##358" = var"##317"[1]
                            var"##358" isa TypeVar
                        end && begin
                            var"##359" = var"##317"[2]
                            var"##359" isa TypeVar
                        end
                    var"##return#315" = begin
                            compare_expr(m, lhs.lb, rhs.lb) || return false
                            compare_expr(m, lhs.ub, rhs.ub) || return false
                            return true
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#316#366")))
                end
            end
            if var"##317" isa Tuple{LineNumberNode, LineNumberNode}
                if begin
                            var"##360" = var"##317"[1]
                            var"##360" isa LineNumberNode
                        end && begin
                            var"##361" = var"##317"[2]
                            var"##361" isa LineNumberNode
                        end
                    var"##return#315" = begin
                            return true
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#316#366")))
                end
            end
            if var"##317" isa Tuple{GlobalRef, GlobalRef}
                if begin
                            var"##362" = var"##317"[1]
                            var"##362" isa GlobalRef
                        end && begin
                            var"##363" = var"##317"[2]
                            var"##363" isa GlobalRef
                        end
                    var"##return#315" = begin
                            return lhs === rhs
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#316#366")))
                end
            end
            if var"##317" isa Tuple{Variable, Variable}
                if begin
                            var"##364" = var"##317"[1]
                            var"##364" isa Variable
                        end && begin
                            var"##365" = var"##317"[2]
                            var"##365" isa Variable
                        end
                    var"##return#315" = begin
                            return true
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#316#366")))
                end
            end
            begin
                var"##return#315" = begin
                        return lhs == rhs
                    end
                $(Expr(:symbolicgoto, Symbol("####final#316#366")))
            end
            error("matching non-exhaustive, at #= none:161 =#")
            $(Expr(:symboliclabel, Symbol("####final#316#366")))
            var"##return#315"
        end
    end
    function compare_expr_object(m::Module, lhs::Expr, rhs::Expr)
        begin
            true
            var"##369" = (lhs, rhs)
            if var"##369" isa Tuple{Expr, Expr}
                if begin
                            begin
                                var"##cache#371" = nothing
                            end
                            var"##370" = var"##369"[1]
                            var"##370" isa Expr
                        end && (begin
                                if var"##cache#371" === nothing
                                    var"##cache#371" = Some(((var"##370").head, (var"##370").args))
                                end
                                var"##372" = (var"##cache#371").value
                                var"##372" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##372"[1] == :(::) && (begin
                                        var"##373" = var"##372"[2]
                                        var"##373" isa AbstractArray
                                    end && (length(var"##373") === 1 && (begin
                                                var"##374" = var"##373"[1]
                                                begin
                                                    var"##cache#376" = nothing
                                                end
                                                var"##375" = var"##369"[2]
                                                var"##375" isa Expr
                                            end && (begin
                                                    if var"##cache#376" === nothing
                                                        var"##cache#376" = Some(((var"##375").head, (var"##375").args))
                                                    end
                                                    var"##377" = (var"##cache#376").value
                                                    var"##377" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##377"[1] == :(::) && (begin
                                                            var"##378" = var"##377"[2]
                                                            var"##378" isa AbstractArray
                                                        end && (length(var"##378") === 1 && begin
                                                                var"##379" = var"##378"[1]
                                                                true
                                                            end)))))))))
                    tx = var"##374"
                    ty = var"##379"
                    var"##return#367" = begin
                            tx = guess_type(m, tx)
                            ty = guess_type(m, ty)
                            return compare_expr(m, tx, ty)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#368#440")))
                end
                if begin
                            begin
                                var"##cache#381" = nothing
                            end
                            var"##380" = var"##369"[1]
                            var"##380" isa Expr
                        end && (begin
                                if var"##cache#381" === nothing
                                    var"##cache#381" = Some(((var"##380").head, (var"##380").args))
                                end
                                var"##382" = (var"##cache#381").value
                                var"##382" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##382"[1] == :(::) && (begin
                                        var"##383" = var"##382"[2]
                                        var"##383" isa AbstractArray
                                    end && (length(var"##383") === 2 && (begin
                                                var"##384" = var"##383"[1]
                                                var"##385" = var"##383"[2]
                                                begin
                                                    var"##cache#387" = nothing
                                                end
                                                var"##386" = var"##369"[2]
                                                var"##386" isa Expr
                                            end && (begin
                                                    if var"##cache#387" === nothing
                                                        var"##cache#387" = Some(((var"##386").head, (var"##386").args))
                                                    end
                                                    var"##388" = (var"##cache#387").value
                                                    var"##388" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##388"[1] == :(::) && (begin
                                                            var"##389" = var"##388"[2]
                                                            var"##389" isa AbstractArray
                                                        end && (length(var"##389") === 2 && begin
                                                                var"##390" = var"##389"[1]
                                                                var"##391" = var"##389"[2]
                                                                true
                                                            end)))))))))
                    tx = var"##385"
                    y = var"##390"
                    ty = var"##391"
                    x = var"##384"
                    var"##return#367" = begin
                            tx = guess_type(m, tx)
                            ty = guess_type(m, ty)
                            return compare_expr(m, x, y) && compare_expr(m, tx, ty)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#368#440")))
                end
                if begin
                            begin
                                var"##cache#393" = nothing
                            end
                            var"##392" = var"##369"[1]
                            var"##392" isa Expr
                        end && (begin
                                if var"##cache#393" === nothing
                                    var"##cache#393" = Some(((var"##392").head, (var"##392").args))
                                end
                                var"##394" = (var"##cache#393").value
                                var"##394" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##394"[1] == :. && (begin
                                        var"##395" = var"##394"[2]
                                        var"##395" isa AbstractArray
                                    end && (length(var"##395") === 2 && (begin
                                                var"##396" = var"##395"[1]
                                                var"##397" = var"##395"[2]
                                                var"##397" isa QuoteNode
                                            end && (begin
                                                    var"##398" = (var"##397").value
                                                    begin
                                                        var"##cache#400" = nothing
                                                    end
                                                    var"##399" = var"##369"[2]
                                                    var"##399" isa Expr
                                                end && (begin
                                                        if var"##cache#400" === nothing
                                                            var"##cache#400" = Some(((var"##399").head, (var"##399").args))
                                                        end
                                                        var"##401" = (var"##cache#400").value
                                                        var"##401" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                    end && (var"##401"[1] == :. && (begin
                                                                var"##402" = var"##401"[2]
                                                                var"##402" isa AbstractArray
                                                            end && (length(var"##402") === 2 && (begin
                                                                        var"##403" = var"##402"[1]
                                                                        var"##404" = var"##402"[2]
                                                                        var"##404" isa QuoteNode
                                                                    end && begin
                                                                        var"##405" = (var"##404").value
                                                                        true
                                                                    end)))))))))))
                    sub_a = var"##398"
                    sub_b = var"##405"
                    mod_b = var"##403"
                    mod_a = var"##396"
                    var"##return#367" = begin
                            mod_a = guess_module(m, mod_a)
                            mod_b = guess_module(m, mod_b)
                            compare_expr(m, mod_a, mod_b) || return false
                            return compare_expr(m, sub_a, sub_b)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#368#440")))
                end
                if begin
                            begin
                                var"##cache#407" = nothing
                            end
                            var"##406" = var"##369"[1]
                            var"##406" isa Expr
                        end && (begin
                                if var"##cache#407" === nothing
                                    var"##cache#407" = Some(((var"##406").head, (var"##406").args))
                                end
                                var"##408" = (var"##cache#407").value
                                var"##408" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##408"[1] == :where && (begin
                                        var"##409" = var"##408"[2]
                                        var"##409" isa AbstractArray
                                    end && ((ndims(var"##409") === 1 && length(var"##409") >= 0) && (begin
                                                begin
                                                    var"##cache#411" = nothing
                                                end
                                                var"##410" = var"##369"[2]
                                                var"##410" isa Expr
                                            end && (begin
                                                    if var"##cache#411" === nothing
                                                        var"##cache#411" = Some(((var"##410").head, (var"##410").args))
                                                    end
                                                    var"##412" = (var"##cache#411").value
                                                    var"##412" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##412"[1] == :where && (begin
                                                            var"##413" = var"##412"[2]
                                                            var"##413" isa AbstractArray
                                                        end && (ndims(var"##413") === 1 && length(var"##413") >= 0)))))))))
                    var"##return#367" = begin
                            return compare_where(m, lhs, rhs)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#368#440")))
                end
                if begin
                            begin
                                var"##cache#415" = nothing
                            end
                            var"##414" = var"##369"[1]
                            var"##414" isa Expr
                        end && (begin
                                if var"##cache#415" === nothing
                                    var"##cache#415" = Some(((var"##414").head, (var"##414").args))
                                end
                                var"##416" = (var"##cache#415").value
                                var"##416" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##416"[1] == :curly && (begin
                                        var"##417" = var"##416"[2]
                                        var"##417" isa AbstractArray
                                    end && ((ndims(var"##417") === 1 && length(var"##417") >= 0) && (begin
                                                begin
                                                    var"##cache#419" = nothing
                                                end
                                                var"##418" = var"##369"[2]
                                                var"##418" isa Expr
                                            end && (begin
                                                    if var"##cache#419" === nothing
                                                        var"##cache#419" = Some(((var"##418").head, (var"##418").args))
                                                    end
                                                    var"##420" = (var"##cache#419").value
                                                    var"##420" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##420"[1] == :curly && (begin
                                                            var"##421" = var"##420"[2]
                                                            var"##421" isa AbstractArray
                                                        end && (ndims(var"##421") === 1 && length(var"##421") >= 0)))))))))
                    var"##return#367" = begin
                            return compare_curly(m, lhs, rhs)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#368#440")))
                end
                if begin
                            begin
                                var"##cache#423" = nothing
                            end
                            var"##422" = var"##369"[1]
                            var"##422" isa Expr
                        end && (begin
                                if var"##cache#423" === nothing
                                    var"##cache#423" = Some(((var"##422").head, (var"##422").args))
                                end
                                var"##424" = (var"##cache#423").value
                                var"##424" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##424"[1] == :macrocall && (begin
                                        var"##425" = var"##424"[2]
                                        var"##425" isa AbstractArray
                                    end && ((ndims(var"##425") === 1 && length(var"##425") >= 0) && (begin
                                                begin
                                                    var"##cache#427" = nothing
                                                end
                                                var"##426" = var"##369"[2]
                                                var"##426" isa Expr
                                            end && (begin
                                                    if var"##cache#427" === nothing
                                                        var"##cache#427" = Some(((var"##426").head, (var"##426").args))
                                                    end
                                                    var"##428" = (var"##cache#427").value
                                                    var"##428" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##428"[1] == :macrocall && (begin
                                                            var"##429" = var"##428"[2]
                                                            var"##429" isa AbstractArray
                                                        end && (ndims(var"##429") === 1 && length(var"##429") >= 0)))))))))
                    var"##return#367" = begin
                            return compare_macrocall(m, lhs, rhs)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#368#440")))
                end
                if begin
                            begin
                                var"##cache#431" = nothing
                            end
                            var"##430" = var"##369"[1]
                            var"##430" isa Expr
                        end && (begin
                                if var"##cache#431" === nothing
                                    var"##cache#431" = Some(((var"##430").head, (var"##430").args))
                                end
                                var"##432" = (var"##cache#431").value
                                var"##432" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##432"[1] == :function && (begin
                                        var"##433" = var"##432"[2]
                                        var"##433" isa AbstractArray
                                    end && ((ndims(var"##433") === 1 && length(var"##433") >= 0) && (begin
                                                begin
                                                    var"##cache#435" = nothing
                                                end
                                                var"##434" = var"##369"[2]
                                                var"##434" isa Expr
                                            end && (begin
                                                    if var"##cache#435" === nothing
                                                        var"##cache#435" = Some(((var"##434").head, (var"##434").args))
                                                    end
                                                    var"##436" = (var"##cache#435").value
                                                    var"##436" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##436"[1] == :function && (begin
                                                            var"##437" = var"##436"[2]
                                                            var"##437" isa AbstractArray
                                                        end && (ndims(var"##437") === 1 && length(var"##437") >= 0)))))))))
                    var"##return#367" = begin
                            return compare_function(m, lhs, rhs)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#368#440")))
                end
                if begin
                            var"##438" = var"##369"[1]
                            var"##438" isa Expr
                        end && begin
                            var"##439" = var"##369"[2]
                            var"##439" isa Expr
                        end
                    var"##return#367" = begin
                            lhs.head === rhs.head || return false
                            length(lhs.args) == length(rhs.args) || return false
                            for (a, b) = zip(lhs.args, rhs.args)
                                compare_expr(m, a, b) || return false
                            end
                            return true
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#368#440")))
                end
            end
            begin
                var"##return#367" = begin
                        return lhs == rhs
                    end
                $(Expr(:symbolicgoto, Symbol("####final#368#440")))
            end
            error("matching non-exhaustive, at #= none:206 =#")
            $(Expr(:symboliclabel, Symbol("####final#368#440")))
            var"##return#367"
        end
    end
    function compare_macrocall(m::Module, lhs::Expr, rhs::Expr)
        length(lhs.args) == length(rhs.args) || return false
        compare_expr(lhs.args[1], rhs.args[1]) || return false
        for (a, b) = zip(lhs.args[3:end], rhs.args[3:end])
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
        (typevars_a, typevars_b) = (lhs.args[2:end], rhs.args[2:end])
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
        (lbody, lparams) = (lhs.args[1], lhs.args[2:end])
        (rbody, rparams) = (rhs.args[1], rhs.args[2:end])
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
