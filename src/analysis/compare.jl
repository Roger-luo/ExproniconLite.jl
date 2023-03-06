
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
            var"##407" = (lhs, rhs)
            if var"##407" isa Tuple{TypeVar, TypeVar}
                if begin
                            var"##408" = var"##407"[1]
                            var"##408" isa TypeVar
                        end && begin
                            var"##409" = var"##407"[2]
                            var"##409" isa TypeVar
                        end
                    var"##return#405" = begin
                            compare_expr(m, lhs.lb, rhs.lb) || return false
                            compare_expr(m, lhs.ub, rhs.ub) || return false
                            return true
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#406#456")))
                end
            end
            if var"##407" isa Tuple{LineNumberNode, LineNumberNode}
                if begin
                            var"##410" = var"##407"[1]
                            var"##410" isa LineNumberNode
                        end && begin
                            var"##411" = var"##407"[2]
                            var"##411" isa LineNumberNode
                        end
                    var"##return#405" = begin
                            return true
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#406#456")))
                end
            end
            if var"##407" isa Tuple{GlobalRef, GlobalRef}
                if begin
                            var"##412" = var"##407"[1]
                            var"##412" isa GlobalRef
                        end && begin
                            var"##413" = var"##407"[2]
                            var"##413" isa GlobalRef
                        end
                    var"##return#405" = begin
                            return lhs === rhs
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#406#456")))
                end
            end
            if var"##407" isa Tuple{Any, Any}
                if var"##407" isa Tuple{Symbol, Symbol} && (begin
                                var"##414" = var"##407"[1]
                                var"##414" isa Symbol
                            end && begin
                                var"##415" = var"##407"[2]
                                var"##415" isa Symbol
                            end)
                    var"##return#405" = begin
                            return lhs === rhs
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#406#456")))
                end
                if var"##407" isa Tuple{Module, Module} && (begin
                                var"##416" = var"##407"[1]
                                var"##416" isa Module
                            end && begin
                                var"##417" = var"##407"[2]
                                var"##417" isa Module
                            end)
                    var"##return#405" = begin
                            return lhs === rhs
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#406#456")))
                end
                if var"##407" isa Tuple{QuoteNode, Expr} && (begin
                                var"##418" = var"##407"[1]
                                var"##418" isa QuoteNode
                            end && (begin
                                    begin
                                        var"##cache#420" = nothing
                                    end
                                    var"##419" = var"##407"[2]
                                    var"##419" isa Expr
                                end && (begin
                                        if var"##cache#420" === nothing
                                            var"##cache#420" = Some(((var"##419").head, (var"##419").args))
                                        end
                                        var"##421" = (var"##cache#420").value
                                        var"##421" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##421"[1] == :call && (begin
                                                var"##422" = var"##421"[2]
                                                var"##422" isa AbstractArray
                                            end && (length(var"##422") === 2 && (var"##422"[1] == :Symbol && begin
                                                        var"##423" = var"##422"[2]
                                                        true
                                                    end)))))))
                    a = var"##418"
                    b = var"##423"
                    var"##return#405" = begin
                            isdefined(m, :Symbol) || return false
                            return a.value === Symbol(b)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#406#456")))
                end
                if var"##407" isa Tuple{Expr, QuoteNode} && (begin
                                begin
                                    var"##cache#425" = nothing
                                end
                                var"##424" = var"##407"[1]
                                var"##424" isa Expr
                            end && (begin
                                    if var"##cache#425" === nothing
                                        var"##cache#425" = Some(((var"##424").head, (var"##424").args))
                                    end
                                    var"##426" = (var"##cache#425").value
                                    var"##426" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##426"[1] == :call && (begin
                                            var"##427" = var"##426"[2]
                                            var"##427" isa AbstractArray
                                        end && (length(var"##427") === 2 && (var"##427"[1] == :Symbol && begin
                                                    var"##428" = var"##427"[2]
                                                    var"##429" = var"##407"[2]
                                                    var"##429" isa QuoteNode
                                                end))))))
                    a = var"##429"
                    b = var"##428"
                    var"##return#405" = begin
                            isdefined(m, :Symbol) || return false
                            return a.value === Symbol(b)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#406#456")))
                end
                if var"##407" isa Tuple{Expr, Expr} && (begin
                                var"##430" = var"##407"[1]
                                var"##430" isa Expr
                            end && begin
                                var"##431" = var"##407"[2]
                                var"##431" isa Expr
                            end)
                    var"##return#405" = begin
                            return compare_expr_object(m, lhs, rhs)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#406#456")))
                end
                if var"##407" isa (Tuple{Expr, var2} where var2 <: Type) && (begin
                                begin
                                    var"##cache#433" = nothing
                                end
                                var"##432" = var"##407"[1]
                                var"##432" isa Expr
                            end && (begin
                                    if var"##cache#433" === nothing
                                        var"##cache#433" = Some(((var"##432").head, (var"##432").args))
                                    end
                                    var"##434" = (var"##cache#433").value
                                    var"##434" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##434"[1] == :curly && (begin
                                            var"##435" = var"##434"[2]
                                            var"##435" isa AbstractArray
                                        end && ((ndims(var"##435") === 1 && length(var"##435") >= 0) && begin
                                                var"##436" = var"##407"[2]
                                                var"##436" isa Type
                                            end)))))
                    var"##return#405" = begin
                            return guess_type(m, lhs) == rhs
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#406#456")))
                end
                if var"##407" isa (Tuple{var1, Expr} where var1 <: Type) && (begin
                                var"##437" = var"##407"[1]
                                var"##437" isa Type
                            end && (begin
                                    begin
                                        var"##cache#439" = nothing
                                    end
                                    var"##438" = var"##407"[2]
                                    var"##438" isa Expr
                                end && (begin
                                        if var"##cache#439" === nothing
                                            var"##cache#439" = Some(((var"##438").head, (var"##438").args))
                                        end
                                        var"##440" = (var"##cache#439").value
                                        var"##440" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##440"[1] == :curly && (begin
                                                var"##441" = var"##440"[2]
                                                var"##441" isa AbstractArray
                                            end && (ndims(var"##441") === 1 && length(var"##441") >= 0))))))
                    var"##return#405" = begin
                            return lhs == guess_type(m, rhs)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#406#456")))
                end
                if var"##407" isa (Tuple{var1, Symbol} where var1) && begin
                            var"##442" = var"##407"[1]
                            var"##443" = var"##407"[2]
                            var"##443" isa Symbol
                        end
                    a = var"##442"
                    b = var"##443"
                    var"##return#405" = begin
                            isdefined(m, b) || return false
                            return getfield(m, b) === a
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#406#456")))
                end
                if var"##407" isa (Tuple{Symbol, var2} where var2) && (begin
                                var"##444" = var"##407"[1]
                                var"##444" isa Symbol
                            end && begin
                                var"##445" = var"##407"[2]
                                true
                            end)
                    a = var"##445"
                    b = var"##444"
                    var"##return#405" = begin
                            isdefined(m, b) || return false
                            return getfield(m, b) === a
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#406#456")))
                end
                if var"##407" isa (Tuple{var1, Expr} where var1) && begin
                            var"##446" = var"##407"[1]
                            var"##447" = var"##407"[2]
                            var"##447" isa Expr
                        end
                    a = var"##446"
                    b = var"##447"
                    var"##return#405" = begin
                            try
                                return a == Base.eval(m, b)
                            catch _
                                return false
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#406#456")))
                end
                if var"##407" isa (Tuple{Expr, var2} where var2) && (begin
                                var"##448" = var"##407"[1]
                                var"##448" isa Expr
                            end && begin
                                var"##449" = var"##407"[2]
                                true
                            end)
                    a = var"##449"
                    b = var"##448"
                    var"##return#405" = begin
                            try
                                return a == Base.eval(m, b)
                            catch _
                                return false
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#406#456")))
                end
                if var"##407" isa (Tuple{Module, var2} where var2) && (begin
                                var"##450" = var"##407"[1]
                                var"##450" isa Module
                            end && begin
                                var"##451" = var"##407"[2]
                                true
                            end)
                    a = var"##450"
                    b = var"##451"
                    var"##return#405" = begin
                            mod = guess_module(m, b)
                            isnothing(mod) && return false
                            return a === mod
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#406#456")))
                end
                if var"##407" isa (Tuple{var1, Module} where var1) && begin
                            var"##452" = var"##407"[1]
                            var"##453" = var"##407"[2]
                            var"##453" isa Module
                        end
                    a = var"##453"
                    b = var"##452"
                    var"##return#405" = begin
                            mod = guess_module(m, b)
                            isnothing(mod) && return false
                            return a === mod
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#406#456")))
                end
            end
            if var"##407" isa Tuple{Variable, Variable}
                if begin
                            var"##454" = var"##407"[1]
                            var"##454" isa Variable
                        end && begin
                            var"##455" = var"##407"[2]
                            var"##455" isa Variable
                        end
                    var"##return#405" = begin
                            return true
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#406#456")))
                end
            end
            begin
                var"##return#405" = begin
                        return lhs == rhs
                    end
                $(Expr(:symbolicgoto, Symbol("####final#406#456")))
            end
            error("matching non-exhaustive, at #= none:161 =#")
            $(Expr(:symboliclabel, Symbol("####final#406#456")))
            var"##return#405"
        end
    end
    function compare_expr_object(m::Module, lhs::Expr, rhs::Expr)
        begin
            true
            var"##459" = (lhs, rhs)
            if var"##459" isa Tuple{Expr, Expr}
                if begin
                            begin
                                var"##cache#461" = nothing
                            end
                            var"##460" = var"##459"[1]
                            var"##460" isa Expr
                        end && (begin
                                if var"##cache#461" === nothing
                                    var"##cache#461" = Some(((var"##460").head, (var"##460").args))
                                end
                                var"##462" = (var"##cache#461").value
                                var"##462" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##462"[1] == :(::) && (begin
                                        var"##463" = var"##462"[2]
                                        var"##463" isa AbstractArray
                                    end && (length(var"##463") === 1 && (begin
                                                var"##464" = var"##463"[1]
                                                begin
                                                    var"##cache#466" = nothing
                                                end
                                                var"##465" = var"##459"[2]
                                                var"##465" isa Expr
                                            end && (begin
                                                    if var"##cache#466" === nothing
                                                        var"##cache#466" = Some(((var"##465").head, (var"##465").args))
                                                    end
                                                    var"##467" = (var"##cache#466").value
                                                    var"##467" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##467"[1] == :(::) && (begin
                                                            var"##468" = var"##467"[2]
                                                            var"##468" isa AbstractArray
                                                        end && (length(var"##468") === 1 && begin
                                                                var"##469" = var"##468"[1]
                                                                true
                                                            end)))))))))
                    tx = var"##464"
                    ty = var"##469"
                    var"##return#457" = begin
                            tx = guess_type(m, tx)
                            ty = guess_type(m, ty)
                            return compare_expr(m, tx, ty)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#458#522")))
                end
                if begin
                            begin
                                var"##cache#471" = nothing
                            end
                            var"##470" = var"##459"[1]
                            var"##470" isa Expr
                        end && (begin
                                if var"##cache#471" === nothing
                                    var"##cache#471" = Some(((var"##470").head, (var"##470").args))
                                end
                                var"##472" = (var"##cache#471").value
                                var"##472" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##472"[1] == :(::) && (begin
                                        var"##473" = var"##472"[2]
                                        var"##473" isa AbstractArray
                                    end && (length(var"##473") === 2 && (begin
                                                var"##474" = var"##473"[1]
                                                var"##475" = var"##473"[2]
                                                begin
                                                    var"##cache#477" = nothing
                                                end
                                                var"##476" = var"##459"[2]
                                                var"##476" isa Expr
                                            end && (begin
                                                    if var"##cache#477" === nothing
                                                        var"##cache#477" = Some(((var"##476").head, (var"##476").args))
                                                    end
                                                    var"##478" = (var"##cache#477").value
                                                    var"##478" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##478"[1] == :(::) && (begin
                                                            var"##479" = var"##478"[2]
                                                            var"##479" isa AbstractArray
                                                        end && (length(var"##479") === 2 && begin
                                                                var"##480" = var"##479"[1]
                                                                var"##481" = var"##479"[2]
                                                                true
                                                            end)))))))))
                    tx = var"##475"
                    y = var"##480"
                    ty = var"##481"
                    x = var"##474"
                    var"##return#457" = begin
                            tx = guess_type(m, tx)
                            ty = guess_type(m, ty)
                            return compare_expr(m, x, y) && compare_expr(m, tx, ty)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#458#522")))
                end
                if begin
                            begin
                                var"##cache#483" = nothing
                            end
                            var"##482" = var"##459"[1]
                            var"##482" isa Expr
                        end && (begin
                                if var"##cache#483" === nothing
                                    var"##cache#483" = Some(((var"##482").head, (var"##482").args))
                                end
                                var"##484" = (var"##cache#483").value
                                var"##484" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##484"[1] == :. && (begin
                                        var"##485" = var"##484"[2]
                                        var"##485" isa AbstractArray
                                    end && (length(var"##485") === 2 && (begin
                                                var"##486" = var"##485"[1]
                                                var"##487" = var"##485"[2]
                                                var"##487" isa QuoteNode
                                            end && (begin
                                                    var"##488" = (var"##487").value
                                                    begin
                                                        var"##cache#490" = nothing
                                                    end
                                                    var"##489" = var"##459"[2]
                                                    var"##489" isa Expr
                                                end && (begin
                                                        if var"##cache#490" === nothing
                                                            var"##cache#490" = Some(((var"##489").head, (var"##489").args))
                                                        end
                                                        var"##491" = (var"##cache#490").value
                                                        var"##491" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                    end && (var"##491"[1] == :. && (begin
                                                                var"##492" = var"##491"[2]
                                                                var"##492" isa AbstractArray
                                                            end && (length(var"##492") === 2 && (begin
                                                                        var"##493" = var"##492"[1]
                                                                        var"##494" = var"##492"[2]
                                                                        var"##494" isa QuoteNode
                                                                    end && begin
                                                                        var"##495" = (var"##494").value
                                                                        true
                                                                    end)))))))))))
                    sub_a = var"##488"
                    sub_b = var"##495"
                    mod_b = var"##493"
                    mod_a = var"##486"
                    var"##return#457" = begin
                            mod_a = guess_module(m, mod_a)
                            mod_b = guess_module(m, mod_b)
                            compare_expr(m, mod_a, mod_b) || return false
                            return compare_expr(m, sub_a, sub_b)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#458#522")))
                end
                if begin
                            begin
                                var"##cache#497" = nothing
                            end
                            var"##496" = var"##459"[1]
                            var"##496" isa Expr
                        end && (begin
                                if var"##cache#497" === nothing
                                    var"##cache#497" = Some(((var"##496").head, (var"##496").args))
                                end
                                var"##498" = (var"##cache#497").value
                                var"##498" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##498"[1] == :where && (begin
                                        var"##499" = var"##498"[2]
                                        var"##499" isa AbstractArray
                                    end && ((ndims(var"##499") === 1 && length(var"##499") >= 0) && (begin
                                                begin
                                                    var"##cache#501" = nothing
                                                end
                                                var"##500" = var"##459"[2]
                                                var"##500" isa Expr
                                            end && (begin
                                                    if var"##cache#501" === nothing
                                                        var"##cache#501" = Some(((var"##500").head, (var"##500").args))
                                                    end
                                                    var"##502" = (var"##cache#501").value
                                                    var"##502" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##502"[1] == :where && (begin
                                                            var"##503" = var"##502"[2]
                                                            var"##503" isa AbstractArray
                                                        end && (ndims(var"##503") === 1 && length(var"##503") >= 0)))))))))
                    var"##return#457" = begin
                            return compare_where(m, lhs, rhs)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#458#522")))
                end
                if begin
                            begin
                                var"##cache#505" = nothing
                            end
                            var"##504" = var"##459"[1]
                            var"##504" isa Expr
                        end && (begin
                                if var"##cache#505" === nothing
                                    var"##cache#505" = Some(((var"##504").head, (var"##504").args))
                                end
                                var"##506" = (var"##cache#505").value
                                var"##506" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##506"[1] == :curly && (begin
                                        var"##507" = var"##506"[2]
                                        var"##507" isa AbstractArray
                                    end && ((ndims(var"##507") === 1 && length(var"##507") >= 0) && (begin
                                                begin
                                                    var"##cache#509" = nothing
                                                end
                                                var"##508" = var"##459"[2]
                                                var"##508" isa Expr
                                            end && (begin
                                                    if var"##cache#509" === nothing
                                                        var"##cache#509" = Some(((var"##508").head, (var"##508").args))
                                                    end
                                                    var"##510" = (var"##cache#509").value
                                                    var"##510" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##510"[1] == :curly && (begin
                                                            var"##511" = var"##510"[2]
                                                            var"##511" isa AbstractArray
                                                        end && (ndims(var"##511") === 1 && length(var"##511") >= 0)))))))))
                    var"##return#457" = begin
                            return compare_curly(m, lhs, rhs)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#458#522")))
                end
                if begin
                            begin
                                var"##cache#513" = nothing
                            end
                            var"##512" = var"##459"[1]
                            var"##512" isa Expr
                        end && (begin
                                if var"##cache#513" === nothing
                                    var"##cache#513" = Some(((var"##512").head, (var"##512").args))
                                end
                                var"##514" = (var"##cache#513").value
                                var"##514" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##514"[1] == :function && (begin
                                        var"##515" = var"##514"[2]
                                        var"##515" isa AbstractArray
                                    end && ((ndims(var"##515") === 1 && length(var"##515") >= 0) && (begin
                                                begin
                                                    var"##cache#517" = nothing
                                                end
                                                var"##516" = var"##459"[2]
                                                var"##516" isa Expr
                                            end && (begin
                                                    if var"##cache#517" === nothing
                                                        var"##cache#517" = Some(((var"##516").head, (var"##516").args))
                                                    end
                                                    var"##518" = (var"##cache#517").value
                                                    var"##518" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##518"[1] == :function && (begin
                                                            var"##519" = var"##518"[2]
                                                            var"##519" isa AbstractArray
                                                        end && (ndims(var"##519") === 1 && length(var"##519") >= 0)))))))))
                    var"##return#457" = begin
                            return compare_function(m, lhs, rhs)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#458#522")))
                end
                if begin
                            var"##520" = var"##459"[1]
                            var"##520" isa Expr
                        end && begin
                            var"##521" = var"##459"[2]
                            var"##521" isa Expr
                        end
                    var"##return#457" = begin
                            lhs.head === rhs.head || return false
                            length(lhs.args) == length(rhs.args) || return false
                            for (a, b) = zip(lhs.args, rhs.args)
                                compare_expr(m, a, b) || return false
                            end
                            return true
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#458#522")))
                end
            end
            begin
                var"##return#457" = begin
                        return lhs == rhs
                    end
                $(Expr(:symbolicgoto, Symbol("####final#458#522")))
            end
            error("matching non-exhaustive, at #= none:206 =#")
            $(Expr(:symboliclabel, Symbol("####final#458#522")))
            var"##return#457"
        end
    end
    function compare_function(m::Module, lhs::Expr, rhs::Expr)
        (lhs, rhs) = (canonicalize_lambda_head(lhs), canonicalize_lambda_head(rhs))
        #= none:242 =# @show lhs
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
                #= none:290 =# @show (l, r)
                #= none:291 =# @show compare_expr(m, l.args[2], r.args[2])
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
