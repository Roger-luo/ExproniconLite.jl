
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
            var"##387" = (lhs, rhs)
            if var"##387" isa Tuple{Variable, Variable}
                if begin
                            var"##388" = var"##387"[1]
                            var"##388" isa Variable
                        end && begin
                            var"##389" = var"##387"[2]
                            var"##389" isa Variable
                        end
                    var"##return#385" = begin
                            return true
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#386#436")))
                end
            end
            if var"##387" isa Tuple{LineNumberNode, LineNumberNode}
                if begin
                            var"##390" = var"##387"[1]
                            var"##390" isa LineNumberNode
                        end && begin
                            var"##391" = var"##387"[2]
                            var"##391" isa LineNumberNode
                        end
                    var"##return#385" = begin
                            return true
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#386#436")))
                end
            end
            if var"##387" isa Tuple{GlobalRef, GlobalRef}
                if begin
                            var"##392" = var"##387"[1]
                            var"##392" isa GlobalRef
                        end && begin
                            var"##393" = var"##387"[2]
                            var"##393" isa GlobalRef
                        end
                    var"##return#385" = begin
                            return lhs === rhs
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#386#436")))
                end
            end
            if var"##387" isa Tuple{TypeVar, TypeVar}
                if begin
                            var"##394" = var"##387"[1]
                            var"##394" isa TypeVar
                        end && begin
                            var"##395" = var"##387"[2]
                            var"##395" isa TypeVar
                        end
                    var"##return#385" = begin
                            compare_expr(m, lhs.lb, rhs.lb) || return false
                            compare_expr(m, lhs.ub, rhs.ub) || return false
                            return true
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#386#436")))
                end
            end
            if var"##387" isa Tuple{Any, Any}
                if var"##387" isa Tuple{Symbol, Symbol} && (begin
                                var"##396" = var"##387"[1]
                                var"##396" isa Symbol
                            end && begin
                                var"##397" = var"##387"[2]
                                var"##397" isa Symbol
                            end)
                    var"##return#385" = begin
                            return lhs === rhs
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#386#436")))
                end
                if var"##387" isa Tuple{Module, Module} && (begin
                                var"##398" = var"##387"[1]
                                var"##398" isa Module
                            end && begin
                                var"##399" = var"##387"[2]
                                var"##399" isa Module
                            end)
                    var"##return#385" = begin
                            return lhs === rhs
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#386#436")))
                end
                if var"##387" isa Tuple{QuoteNode, Expr} && (begin
                                var"##400" = var"##387"[1]
                                var"##400" isa QuoteNode
                            end && (begin
                                    begin
                                        var"##cache#402" = nothing
                                    end
                                    var"##401" = var"##387"[2]
                                    var"##401" isa Expr
                                end && (begin
                                        if var"##cache#402" === nothing
                                            var"##cache#402" = Some(((var"##401").head, (var"##401").args))
                                        end
                                        var"##403" = (var"##cache#402").value
                                        var"##403" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##403"[1] == :call && (begin
                                                var"##404" = var"##403"[2]
                                                var"##404" isa AbstractArray
                                            end && (length(var"##404") === 2 && (var"##404"[1] == :Symbol && begin
                                                        var"##405" = var"##404"[2]
                                                        true
                                                    end)))))))
                    a = var"##400"
                    b = var"##405"
                    var"##return#385" = begin
                            isdefined(m, :Symbol) || return false
                            return a.value === Symbol(b)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#386#436")))
                end
                if var"##387" isa Tuple{Expr, QuoteNode} && (begin
                                begin
                                    var"##cache#407" = nothing
                                end
                                var"##406" = var"##387"[1]
                                var"##406" isa Expr
                            end && (begin
                                    if var"##cache#407" === nothing
                                        var"##cache#407" = Some(((var"##406").head, (var"##406").args))
                                    end
                                    var"##408" = (var"##cache#407").value
                                    var"##408" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##408"[1] == :call && (begin
                                            var"##409" = var"##408"[2]
                                            var"##409" isa AbstractArray
                                        end && (length(var"##409") === 2 && (var"##409"[1] == :Symbol && begin
                                                    var"##410" = var"##409"[2]
                                                    var"##411" = var"##387"[2]
                                                    var"##411" isa QuoteNode
                                                end))))))
                    a = var"##411"
                    b = var"##410"
                    var"##return#385" = begin
                            isdefined(m, :Symbol) || return false
                            return a.value === Symbol(b)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#386#436")))
                end
                if var"##387" isa Tuple{Expr, Expr} && (begin
                                var"##412" = var"##387"[1]
                                var"##412" isa Expr
                            end && begin
                                var"##413" = var"##387"[2]
                                var"##413" isa Expr
                            end)
                    var"##return#385" = begin
                            return compare_expr_object(m, lhs, rhs)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#386#436")))
                end
                if var"##387" isa (Tuple{Expr, var2} where var2 <: Type) && (begin
                                begin
                                    var"##cache#415" = nothing
                                end
                                var"##414" = var"##387"[1]
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
                                        end && ((ndims(var"##417") === 1 && length(var"##417") >= 0) && begin
                                                var"##418" = var"##387"[2]
                                                var"##418" isa Type
                                            end)))))
                    var"##return#385" = begin
                            return guess_type(m, lhs) == rhs
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#386#436")))
                end
                if var"##387" isa (Tuple{var1, Expr} where var1 <: Type) && (begin
                                var"##419" = var"##387"[1]
                                var"##419" isa Type
                            end && (begin
                                    begin
                                        var"##cache#421" = nothing
                                    end
                                    var"##420" = var"##387"[2]
                                    var"##420" isa Expr
                                end && (begin
                                        if var"##cache#421" === nothing
                                            var"##cache#421" = Some(((var"##420").head, (var"##420").args))
                                        end
                                        var"##422" = (var"##cache#421").value
                                        var"##422" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##422"[1] == :curly && (begin
                                                var"##423" = var"##422"[2]
                                                var"##423" isa AbstractArray
                                            end && (ndims(var"##423") === 1 && length(var"##423") >= 0))))))
                    var"##return#385" = begin
                            return lhs == guess_type(m, rhs)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#386#436")))
                end
                if var"##387" isa (Tuple{var1, Symbol} where var1) && begin
                            var"##424" = var"##387"[1]
                            var"##425" = var"##387"[2]
                            var"##425" isa Symbol
                        end
                    a = var"##424"
                    b = var"##425"
                    var"##return#385" = begin
                            isdefined(m, b) || return false
                            return getfield(m, b) === a
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#386#436")))
                end
                if var"##387" isa (Tuple{Symbol, var2} where var2) && (begin
                                var"##426" = var"##387"[1]
                                var"##426" isa Symbol
                            end && begin
                                var"##427" = var"##387"[2]
                                true
                            end)
                    a = var"##427"
                    b = var"##426"
                    var"##return#385" = begin
                            isdefined(m, b) || return false
                            return getfield(m, b) === a
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#386#436")))
                end
                if var"##387" isa (Tuple{var1, Expr} where var1) && begin
                            var"##428" = var"##387"[1]
                            var"##429" = var"##387"[2]
                            var"##429" isa Expr
                        end
                    a = var"##428"
                    b = var"##429"
                    var"##return#385" = begin
                            try
                                return a == Base.eval(m, b)
                            catch _
                                return false
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#386#436")))
                end
                if var"##387" isa (Tuple{Expr, var2} where var2) && (begin
                                var"##430" = var"##387"[1]
                                var"##430" isa Expr
                            end && begin
                                var"##431" = var"##387"[2]
                                true
                            end)
                    a = var"##431"
                    b = var"##430"
                    var"##return#385" = begin
                            try
                                return a == Base.eval(m, b)
                            catch _
                                return false
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#386#436")))
                end
                if var"##387" isa (Tuple{Module, var2} where var2) && (begin
                                var"##432" = var"##387"[1]
                                var"##432" isa Module
                            end && begin
                                var"##433" = var"##387"[2]
                                true
                            end)
                    a = var"##432"
                    b = var"##433"
                    var"##return#385" = begin
                            mod = guess_module(m, b)
                            isnothing(mod) && return false
                            return a === mod
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#386#436")))
                end
                if var"##387" isa (Tuple{var1, Module} where var1) && begin
                            var"##434" = var"##387"[1]
                            var"##435" = var"##387"[2]
                            var"##435" isa Module
                        end
                    a = var"##435"
                    b = var"##434"
                    var"##return#385" = begin
                            mod = guess_module(m, b)
                            isnothing(mod) && return false
                            return a === mod
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#386#436")))
                end
            end
            begin
                var"##return#385" = begin
                        return lhs == rhs
                    end
                $(Expr(:symbolicgoto, Symbol("####final#386#436")))
            end
            error("matching non-exhaustive, at #= none:161 =#")
            $(Expr(:symboliclabel, Symbol("####final#386#436")))
            var"##return#385"
        end
    end
    function compare_expr_object(m::Module, lhs::Expr, rhs::Expr)
        begin
            true
            var"##439" = (lhs, rhs)
            if var"##439" isa Tuple{Expr, Expr}
                if begin
                            begin
                                var"##cache#441" = nothing
                            end
                            var"##440" = var"##439"[1]
                            var"##440" isa Expr
                        end && (begin
                                if var"##cache#441" === nothing
                                    var"##cache#441" = Some(((var"##440").head, (var"##440").args))
                                end
                                var"##442" = (var"##cache#441").value
                                var"##442" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##442"[1] == :(::) && (begin
                                        var"##443" = var"##442"[2]
                                        var"##443" isa AbstractArray
                                    end && (length(var"##443") === 1 && (begin
                                                var"##444" = var"##443"[1]
                                                begin
                                                    var"##cache#446" = nothing
                                                end
                                                var"##445" = var"##439"[2]
                                                var"##445" isa Expr
                                            end && (begin
                                                    if var"##cache#446" === nothing
                                                        var"##cache#446" = Some(((var"##445").head, (var"##445").args))
                                                    end
                                                    var"##447" = (var"##cache#446").value
                                                    var"##447" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##447"[1] == :(::) && (begin
                                                            var"##448" = var"##447"[2]
                                                            var"##448" isa AbstractArray
                                                        end && (length(var"##448") === 1 && begin
                                                                var"##449" = var"##448"[1]
                                                                true
                                                            end)))))))))
                    tx = var"##444"
                    ty = var"##449"
                    var"##return#437" = begin
                            tx = guess_type(m, tx)
                            ty = guess_type(m, ty)
                            return compare_expr(m, tx, ty)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#438#502")))
                end
                if begin
                            begin
                                var"##cache#451" = nothing
                            end
                            var"##450" = var"##439"[1]
                            var"##450" isa Expr
                        end && (begin
                                if var"##cache#451" === nothing
                                    var"##cache#451" = Some(((var"##450").head, (var"##450").args))
                                end
                                var"##452" = (var"##cache#451").value
                                var"##452" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##452"[1] == :(::) && (begin
                                        var"##453" = var"##452"[2]
                                        var"##453" isa AbstractArray
                                    end && (length(var"##453") === 2 && (begin
                                                var"##454" = var"##453"[1]
                                                var"##455" = var"##453"[2]
                                                begin
                                                    var"##cache#457" = nothing
                                                end
                                                var"##456" = var"##439"[2]
                                                var"##456" isa Expr
                                            end && (begin
                                                    if var"##cache#457" === nothing
                                                        var"##cache#457" = Some(((var"##456").head, (var"##456").args))
                                                    end
                                                    var"##458" = (var"##cache#457").value
                                                    var"##458" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##458"[1] == :(::) && (begin
                                                            var"##459" = var"##458"[2]
                                                            var"##459" isa AbstractArray
                                                        end && (length(var"##459") === 2 && begin
                                                                var"##460" = var"##459"[1]
                                                                var"##461" = var"##459"[2]
                                                                true
                                                            end)))))))))
                    tx = var"##455"
                    y = var"##460"
                    ty = var"##461"
                    x = var"##454"
                    var"##return#437" = begin
                            tx = guess_type(m, tx)
                            ty = guess_type(m, ty)
                            return compare_expr(m, x, y) && compare_expr(m, tx, ty)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#438#502")))
                end
                if begin
                            begin
                                var"##cache#463" = nothing
                            end
                            var"##462" = var"##439"[1]
                            var"##462" isa Expr
                        end && (begin
                                if var"##cache#463" === nothing
                                    var"##cache#463" = Some(((var"##462").head, (var"##462").args))
                                end
                                var"##464" = (var"##cache#463").value
                                var"##464" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##464"[1] == :. && (begin
                                        var"##465" = var"##464"[2]
                                        var"##465" isa AbstractArray
                                    end && (length(var"##465") === 2 && (begin
                                                var"##466" = var"##465"[1]
                                                var"##467" = var"##465"[2]
                                                var"##467" isa QuoteNode
                                            end && (begin
                                                    var"##468" = (var"##467").value
                                                    begin
                                                        var"##cache#470" = nothing
                                                    end
                                                    var"##469" = var"##439"[2]
                                                    var"##469" isa Expr
                                                end && (begin
                                                        if var"##cache#470" === nothing
                                                            var"##cache#470" = Some(((var"##469").head, (var"##469").args))
                                                        end
                                                        var"##471" = (var"##cache#470").value
                                                        var"##471" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                    end && (var"##471"[1] == :. && (begin
                                                                var"##472" = var"##471"[2]
                                                                var"##472" isa AbstractArray
                                                            end && (length(var"##472") === 2 && (begin
                                                                        var"##473" = var"##472"[1]
                                                                        var"##474" = var"##472"[2]
                                                                        var"##474" isa QuoteNode
                                                                    end && begin
                                                                        var"##475" = (var"##474").value
                                                                        true
                                                                    end)))))))))))
                    sub_a = var"##468"
                    sub_b = var"##475"
                    mod_b = var"##473"
                    mod_a = var"##466"
                    var"##return#437" = begin
                            mod_a = guess_module(m, mod_a)
                            mod_b = guess_module(m, mod_b)
                            compare_expr(m, mod_a, mod_b) || return false
                            return compare_expr(m, sub_a, sub_b)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#438#502")))
                end
                if begin
                            begin
                                var"##cache#477" = nothing
                            end
                            var"##476" = var"##439"[1]
                            var"##476" isa Expr
                        end && (begin
                                if var"##cache#477" === nothing
                                    var"##cache#477" = Some(((var"##476").head, (var"##476").args))
                                end
                                var"##478" = (var"##cache#477").value
                                var"##478" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##478"[1] == :where && (begin
                                        var"##479" = var"##478"[2]
                                        var"##479" isa AbstractArray
                                    end && ((ndims(var"##479") === 1 && length(var"##479") >= 0) && (begin
                                                begin
                                                    var"##cache#481" = nothing
                                                end
                                                var"##480" = var"##439"[2]
                                                var"##480" isa Expr
                                            end && (begin
                                                    if var"##cache#481" === nothing
                                                        var"##cache#481" = Some(((var"##480").head, (var"##480").args))
                                                    end
                                                    var"##482" = (var"##cache#481").value
                                                    var"##482" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##482"[1] == :where && (begin
                                                            var"##483" = var"##482"[2]
                                                            var"##483" isa AbstractArray
                                                        end && (ndims(var"##483") === 1 && length(var"##483") >= 0)))))))))
                    var"##return#437" = begin
                            return compare_where(m, lhs, rhs)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#438#502")))
                end
                if begin
                            begin
                                var"##cache#485" = nothing
                            end
                            var"##484" = var"##439"[1]
                            var"##484" isa Expr
                        end && (begin
                                if var"##cache#485" === nothing
                                    var"##cache#485" = Some(((var"##484").head, (var"##484").args))
                                end
                                var"##486" = (var"##cache#485").value
                                var"##486" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##486"[1] == :curly && (begin
                                        var"##487" = var"##486"[2]
                                        var"##487" isa AbstractArray
                                    end && ((ndims(var"##487") === 1 && length(var"##487") >= 0) && (begin
                                                begin
                                                    var"##cache#489" = nothing
                                                end
                                                var"##488" = var"##439"[2]
                                                var"##488" isa Expr
                                            end && (begin
                                                    if var"##cache#489" === nothing
                                                        var"##cache#489" = Some(((var"##488").head, (var"##488").args))
                                                    end
                                                    var"##490" = (var"##cache#489").value
                                                    var"##490" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##490"[1] == :curly && (begin
                                                            var"##491" = var"##490"[2]
                                                            var"##491" isa AbstractArray
                                                        end && (ndims(var"##491") === 1 && length(var"##491") >= 0)))))))))
                    var"##return#437" = begin
                            return compare_curly(m, lhs, rhs)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#438#502")))
                end
                if begin
                            begin
                                var"##cache#493" = nothing
                            end
                            var"##492" = var"##439"[1]
                            var"##492" isa Expr
                        end && (begin
                                if var"##cache#493" === nothing
                                    var"##cache#493" = Some(((var"##492").head, (var"##492").args))
                                end
                                var"##494" = (var"##cache#493").value
                                var"##494" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##494"[1] == :function && (begin
                                        var"##495" = var"##494"[2]
                                        var"##495" isa AbstractArray
                                    end && ((ndims(var"##495") === 1 && length(var"##495") >= 0) && (begin
                                                begin
                                                    var"##cache#497" = nothing
                                                end
                                                var"##496" = var"##439"[2]
                                                var"##496" isa Expr
                                            end && (begin
                                                    if var"##cache#497" === nothing
                                                        var"##cache#497" = Some(((var"##496").head, (var"##496").args))
                                                    end
                                                    var"##498" = (var"##cache#497").value
                                                    var"##498" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##498"[1] == :function && (begin
                                                            var"##499" = var"##498"[2]
                                                            var"##499" isa AbstractArray
                                                        end && (ndims(var"##499") === 1 && length(var"##499") >= 0)))))))))
                    var"##return#437" = begin
                            return compare_function(m, lhs, rhs)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#438#502")))
                end
                if begin
                            var"##500" = var"##439"[1]
                            var"##500" isa Expr
                        end && begin
                            var"##501" = var"##439"[2]
                            var"##501" isa Expr
                        end
                    var"##return#437" = begin
                            lhs.head === rhs.head || return false
                            length(lhs.args) == length(rhs.args) || return false
                            for (a, b) = zip(lhs.args, rhs.args)
                                compare_expr(m, a, b) || return false
                            end
                            return true
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#438#502")))
                end
            end
            begin
                var"##return#437" = begin
                        return lhs == rhs
                    end
                $(Expr(:symbolicgoto, Symbol("####final#438#502")))
            end
            error("matching non-exhaustive, at #= none:206 =#")
            $(Expr(:symboliclabel, Symbol("####final#438#502")))
            var"##return#437"
        end
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
