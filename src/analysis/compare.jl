
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
            var"##320" = (lhs, rhs)
            if var"##320" isa Tuple{Any, Any}
                if var"##320" isa Tuple{Symbol, Symbol} && (begin
                                var"##321" = var"##320"[1]
                                var"##321" isa Symbol
                            end && begin
                                var"##322" = var"##320"[2]
                                var"##322" isa Symbol
                            end)
                    var"##return#318" = begin
                            return lhs === rhs
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#319#369")))
                end
                if var"##320" isa Tuple{Module, Module} && (begin
                                var"##323" = var"##320"[1]
                                var"##323" isa Module
                            end && begin
                                var"##324" = var"##320"[2]
                                var"##324" isa Module
                            end)
                    var"##return#318" = begin
                            return lhs === rhs
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#319#369")))
                end
                if var"##320" isa Tuple{QuoteNode, Expr} && (begin
                                var"##325" = var"##320"[1]
                                var"##325" isa QuoteNode
                            end && (begin
                                    begin
                                        var"##cache#327" = nothing
                                    end
                                    var"##326" = var"##320"[2]
                                    var"##326" isa Expr
                                end && (begin
                                        if var"##cache#327" === nothing
                                            var"##cache#327" = Some(((var"##326").head, (var"##326").args))
                                        end
                                        var"##328" = (var"##cache#327").value
                                        var"##328" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##328"[1] == :call && (begin
                                                var"##329" = var"##328"[2]
                                                var"##329" isa AbstractArray
                                            end && (length(var"##329") === 2 && (var"##329"[1] == :Symbol && begin
                                                        var"##330" = var"##329"[2]
                                                        true
                                                    end)))))))
                    a = var"##325"
                    b = var"##330"
                    var"##return#318" = begin
                            isdefined(m, :Symbol) || return false
                            return a.value === Symbol(b)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#319#369")))
                end
                if var"##320" isa Tuple{Expr, QuoteNode} && (begin
                                begin
                                    var"##cache#332" = nothing
                                end
                                var"##331" = var"##320"[1]
                                var"##331" isa Expr
                            end && (begin
                                    if var"##cache#332" === nothing
                                        var"##cache#332" = Some(((var"##331").head, (var"##331").args))
                                    end
                                    var"##333" = (var"##cache#332").value
                                    var"##333" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##333"[1] == :call && (begin
                                            var"##334" = var"##333"[2]
                                            var"##334" isa AbstractArray
                                        end && (length(var"##334") === 2 && (var"##334"[1] == :Symbol && begin
                                                    var"##335" = var"##334"[2]
                                                    var"##336" = var"##320"[2]
                                                    var"##336" isa QuoteNode
                                                end))))))
                    a = var"##336"
                    b = var"##335"
                    var"##return#318" = begin
                            isdefined(m, :Symbol) || return false
                            return a.value === Symbol(b)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#319#369")))
                end
                if var"##320" isa Tuple{Expr, Expr} && (begin
                                var"##337" = var"##320"[1]
                                var"##337" isa Expr
                            end && begin
                                var"##338" = var"##320"[2]
                                var"##338" isa Expr
                            end)
                    var"##return#318" = begin
                            return compare_expr_object(m, lhs, rhs)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#319#369")))
                end
                if var"##320" isa (Tuple{Expr, var2} where var2 <: Type) && (begin
                                begin
                                    var"##cache#340" = nothing
                                end
                                var"##339" = var"##320"[1]
                                var"##339" isa Expr
                            end && (begin
                                    if var"##cache#340" === nothing
                                        var"##cache#340" = Some(((var"##339").head, (var"##339").args))
                                    end
                                    var"##341" = (var"##cache#340").value
                                    var"##341" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##341"[1] == :curly && (begin
                                            var"##342" = var"##341"[2]
                                            var"##342" isa AbstractArray
                                        end && ((ndims(var"##342") === 1 && length(var"##342") >= 0) && begin
                                                var"##343" = var"##320"[2]
                                                var"##343" isa Type
                                            end)))))
                    var"##return#318" = begin
                            return guess_type(m, lhs) == rhs
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#319#369")))
                end
                if var"##320" isa (Tuple{var1, Expr} where var1 <: Type) && (begin
                                var"##344" = var"##320"[1]
                                var"##344" isa Type
                            end && (begin
                                    begin
                                        var"##cache#346" = nothing
                                    end
                                    var"##345" = var"##320"[2]
                                    var"##345" isa Expr
                                end && (begin
                                        if var"##cache#346" === nothing
                                            var"##cache#346" = Some(((var"##345").head, (var"##345").args))
                                        end
                                        var"##347" = (var"##cache#346").value
                                        var"##347" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##347"[1] == :curly && (begin
                                                var"##348" = var"##347"[2]
                                                var"##348" isa AbstractArray
                                            end && (ndims(var"##348") === 1 && length(var"##348") >= 0))))))
                    var"##return#318" = begin
                            return lhs == guess_type(m, rhs)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#319#369")))
                end
                if var"##320" isa (Tuple{var1, Symbol} where var1) && begin
                            var"##349" = var"##320"[1]
                            var"##350" = var"##320"[2]
                            var"##350" isa Symbol
                        end
                    a = var"##349"
                    b = var"##350"
                    var"##return#318" = begin
                            isdefined(m, b) || return false
                            return getfield(m, b) === a
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#319#369")))
                end
                if var"##320" isa (Tuple{Symbol, var2} where var2) && (begin
                                var"##351" = var"##320"[1]
                                var"##351" isa Symbol
                            end && begin
                                var"##352" = var"##320"[2]
                                true
                            end)
                    a = var"##352"
                    b = var"##351"
                    var"##return#318" = begin
                            isdefined(m, b) || return false
                            return getfield(m, b) === a
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#319#369")))
                end
                if var"##320" isa (Tuple{var1, Expr} where var1) && begin
                            var"##353" = var"##320"[1]
                            var"##354" = var"##320"[2]
                            var"##354" isa Expr
                        end
                    a = var"##353"
                    b = var"##354"
                    var"##return#318" = begin
                            try
                                return a == Base.eval(m, b)
                            catch _
                                return false
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#319#369")))
                end
                if var"##320" isa (Tuple{Expr, var2} where var2) && (begin
                                var"##355" = var"##320"[1]
                                var"##355" isa Expr
                            end && begin
                                var"##356" = var"##320"[2]
                                true
                            end)
                    a = var"##356"
                    b = var"##355"
                    var"##return#318" = begin
                            try
                                return a == Base.eval(m, b)
                            catch _
                                return false
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#319#369")))
                end
                if var"##320" isa (Tuple{Module, var2} where var2) && (begin
                                var"##357" = var"##320"[1]
                                var"##357" isa Module
                            end && begin
                                var"##358" = var"##320"[2]
                                true
                            end)
                    a = var"##357"
                    b = var"##358"
                    var"##return#318" = begin
                            mod = guess_module(m, b)
                            isnothing(mod) && return false
                            return a === mod
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#319#369")))
                end
                if var"##320" isa (Tuple{var1, Module} where var1) && begin
                            var"##359" = var"##320"[1]
                            var"##360" = var"##320"[2]
                            var"##360" isa Module
                        end
                    a = var"##360"
                    b = var"##359"
                    var"##return#318" = begin
                            mod = guess_module(m, b)
                            isnothing(mod) && return false
                            return a === mod
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#319#369")))
                end
            end
            if var"##320" isa Tuple{TypeVar, TypeVar}
                if begin
                            var"##361" = var"##320"[1]
                            var"##361" isa TypeVar
                        end && begin
                            var"##362" = var"##320"[2]
                            var"##362" isa TypeVar
                        end
                    var"##return#318" = begin
                            compare_expr(m, lhs.lb, rhs.lb) || return false
                            compare_expr(m, lhs.ub, rhs.ub) || return false
                            return true
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#319#369")))
                end
            end
            if var"##320" isa Tuple{Variable, Variable}
                if begin
                            var"##363" = var"##320"[1]
                            var"##363" isa Variable
                        end && begin
                            var"##364" = var"##320"[2]
                            var"##364" isa Variable
                        end
                    var"##return#318" = begin
                            return true
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#319#369")))
                end
            end
            if var"##320" isa Tuple{LineNumberNode, LineNumberNode}
                if begin
                            var"##365" = var"##320"[1]
                            var"##365" isa LineNumberNode
                        end && begin
                            var"##366" = var"##320"[2]
                            var"##366" isa LineNumberNode
                        end
                    var"##return#318" = begin
                            return true
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#319#369")))
                end
            end
            if var"##320" isa Tuple{GlobalRef, GlobalRef}
                if begin
                            var"##367" = var"##320"[1]
                            var"##367" isa GlobalRef
                        end && begin
                            var"##368" = var"##320"[2]
                            var"##368" isa GlobalRef
                        end
                    var"##return#318" = begin
                            return lhs === rhs
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#319#369")))
                end
            end
            begin
                var"##return#318" = begin
                        return lhs == rhs
                    end
                $(Expr(:symbolicgoto, Symbol("####final#319#369")))
            end
            error("matching non-exhaustive, at #= none:161 =#")
            $(Expr(:symboliclabel, Symbol("####final#319#369")))
            var"##return#318"
        end
    end
    function compare_expr_object(m::Module, lhs::Expr, rhs::Expr)
        begin
            true
            var"##372" = (lhs, rhs)
            if var"##372" isa Tuple{Expr, Expr}
                if begin
                            begin
                                var"##cache#374" = nothing
                            end
                            var"##373" = var"##372"[1]
                            var"##373" isa Expr
                        end && (begin
                                if var"##cache#374" === nothing
                                    var"##cache#374" = Some(((var"##373").head, (var"##373").args))
                                end
                                var"##375" = (var"##cache#374").value
                                var"##375" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##375"[1] == :(::) && (begin
                                        var"##376" = var"##375"[2]
                                        var"##376" isa AbstractArray
                                    end && (length(var"##376") === 1 && (begin
                                                var"##377" = var"##376"[1]
                                                begin
                                                    var"##cache#379" = nothing
                                                end
                                                var"##378" = var"##372"[2]
                                                var"##378" isa Expr
                                            end && (begin
                                                    if var"##cache#379" === nothing
                                                        var"##cache#379" = Some(((var"##378").head, (var"##378").args))
                                                    end
                                                    var"##380" = (var"##cache#379").value
                                                    var"##380" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##380"[1] == :(::) && (begin
                                                            var"##381" = var"##380"[2]
                                                            var"##381" isa AbstractArray
                                                        end && (length(var"##381") === 1 && begin
                                                                var"##382" = var"##381"[1]
                                                                true
                                                            end)))))))))
                    tx = var"##377"
                    ty = var"##382"
                    var"##return#370" = begin
                            tx = guess_type(m, tx)
                            ty = guess_type(m, ty)
                            return compare_expr(m, tx, ty)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#371#443")))
                end
                if begin
                            begin
                                var"##cache#384" = nothing
                            end
                            var"##383" = var"##372"[1]
                            var"##383" isa Expr
                        end && (begin
                                if var"##cache#384" === nothing
                                    var"##cache#384" = Some(((var"##383").head, (var"##383").args))
                                end
                                var"##385" = (var"##cache#384").value
                                var"##385" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##385"[1] == :(::) && (begin
                                        var"##386" = var"##385"[2]
                                        var"##386" isa AbstractArray
                                    end && (length(var"##386") === 2 && (begin
                                                var"##387" = var"##386"[1]
                                                var"##388" = var"##386"[2]
                                                begin
                                                    var"##cache#390" = nothing
                                                end
                                                var"##389" = var"##372"[2]
                                                var"##389" isa Expr
                                            end && (begin
                                                    if var"##cache#390" === nothing
                                                        var"##cache#390" = Some(((var"##389").head, (var"##389").args))
                                                    end
                                                    var"##391" = (var"##cache#390").value
                                                    var"##391" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##391"[1] == :(::) && (begin
                                                            var"##392" = var"##391"[2]
                                                            var"##392" isa AbstractArray
                                                        end && (length(var"##392") === 2 && begin
                                                                var"##393" = var"##392"[1]
                                                                var"##394" = var"##392"[2]
                                                                true
                                                            end)))))))))
                    tx = var"##388"
                    y = var"##393"
                    ty = var"##394"
                    x = var"##387"
                    var"##return#370" = begin
                            tx = guess_type(m, tx)
                            ty = guess_type(m, ty)
                            return compare_expr(m, x, y) && compare_expr(m, tx, ty)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#371#443")))
                end
                if begin
                            begin
                                var"##cache#396" = nothing
                            end
                            var"##395" = var"##372"[1]
                            var"##395" isa Expr
                        end && (begin
                                if var"##cache#396" === nothing
                                    var"##cache#396" = Some(((var"##395").head, (var"##395").args))
                                end
                                var"##397" = (var"##cache#396").value
                                var"##397" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##397"[1] == :. && (begin
                                        var"##398" = var"##397"[2]
                                        var"##398" isa AbstractArray
                                    end && (length(var"##398") === 2 && (begin
                                                var"##399" = var"##398"[1]
                                                var"##400" = var"##398"[2]
                                                var"##400" isa QuoteNode
                                            end && (begin
                                                    var"##401" = (var"##400").value
                                                    begin
                                                        var"##cache#403" = nothing
                                                    end
                                                    var"##402" = var"##372"[2]
                                                    var"##402" isa Expr
                                                end && (begin
                                                        if var"##cache#403" === nothing
                                                            var"##cache#403" = Some(((var"##402").head, (var"##402").args))
                                                        end
                                                        var"##404" = (var"##cache#403").value
                                                        var"##404" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                    end && (var"##404"[1] == :. && (begin
                                                                var"##405" = var"##404"[2]
                                                                var"##405" isa AbstractArray
                                                            end && (length(var"##405") === 2 && (begin
                                                                        var"##406" = var"##405"[1]
                                                                        var"##407" = var"##405"[2]
                                                                        var"##407" isa QuoteNode
                                                                    end && begin
                                                                        var"##408" = (var"##407").value
                                                                        true
                                                                    end)))))))))))
                    sub_a = var"##401"
                    sub_b = var"##408"
                    mod_b = var"##406"
                    mod_a = var"##399"
                    var"##return#370" = begin
                            mod_a = guess_module(m, mod_a)
                            mod_b = guess_module(m, mod_b)
                            compare_expr(m, mod_a, mod_b) || return false
                            return compare_expr(m, sub_a, sub_b)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#371#443")))
                end
                if begin
                            begin
                                var"##cache#410" = nothing
                            end
                            var"##409" = var"##372"[1]
                            var"##409" isa Expr
                        end && (begin
                                if var"##cache#410" === nothing
                                    var"##cache#410" = Some(((var"##409").head, (var"##409").args))
                                end
                                var"##411" = (var"##cache#410").value
                                var"##411" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##411"[1] == :where && (begin
                                        var"##412" = var"##411"[2]
                                        var"##412" isa AbstractArray
                                    end && ((ndims(var"##412") === 1 && length(var"##412") >= 0) && (begin
                                                begin
                                                    var"##cache#414" = nothing
                                                end
                                                var"##413" = var"##372"[2]
                                                var"##413" isa Expr
                                            end && (begin
                                                    if var"##cache#414" === nothing
                                                        var"##cache#414" = Some(((var"##413").head, (var"##413").args))
                                                    end
                                                    var"##415" = (var"##cache#414").value
                                                    var"##415" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##415"[1] == :where && (begin
                                                            var"##416" = var"##415"[2]
                                                            var"##416" isa AbstractArray
                                                        end && (ndims(var"##416") === 1 && length(var"##416") >= 0)))))))))
                    var"##return#370" = begin
                            return compare_where(m, lhs, rhs)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#371#443")))
                end
                if begin
                            begin
                                var"##cache#418" = nothing
                            end
                            var"##417" = var"##372"[1]
                            var"##417" isa Expr
                        end && (begin
                                if var"##cache#418" === nothing
                                    var"##cache#418" = Some(((var"##417").head, (var"##417").args))
                                end
                                var"##419" = (var"##cache#418").value
                                var"##419" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##419"[1] == :curly && (begin
                                        var"##420" = var"##419"[2]
                                        var"##420" isa AbstractArray
                                    end && ((ndims(var"##420") === 1 && length(var"##420") >= 0) && (begin
                                                begin
                                                    var"##cache#422" = nothing
                                                end
                                                var"##421" = var"##372"[2]
                                                var"##421" isa Expr
                                            end && (begin
                                                    if var"##cache#422" === nothing
                                                        var"##cache#422" = Some(((var"##421").head, (var"##421").args))
                                                    end
                                                    var"##423" = (var"##cache#422").value
                                                    var"##423" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##423"[1] == :curly && (begin
                                                            var"##424" = var"##423"[2]
                                                            var"##424" isa AbstractArray
                                                        end && (ndims(var"##424") === 1 && length(var"##424") >= 0)))))))))
                    var"##return#370" = begin
                            return compare_curly(m, lhs, rhs)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#371#443")))
                end
                if begin
                            begin
                                var"##cache#426" = nothing
                            end
                            var"##425" = var"##372"[1]
                            var"##425" isa Expr
                        end && (begin
                                if var"##cache#426" === nothing
                                    var"##cache#426" = Some(((var"##425").head, (var"##425").args))
                                end
                                var"##427" = (var"##cache#426").value
                                var"##427" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##427"[1] == :macrocall && (begin
                                        var"##428" = var"##427"[2]
                                        var"##428" isa AbstractArray
                                    end && ((ndims(var"##428") === 1 && length(var"##428") >= 0) && (begin
                                                begin
                                                    var"##cache#430" = nothing
                                                end
                                                var"##429" = var"##372"[2]
                                                var"##429" isa Expr
                                            end && (begin
                                                    if var"##cache#430" === nothing
                                                        var"##cache#430" = Some(((var"##429").head, (var"##429").args))
                                                    end
                                                    var"##431" = (var"##cache#430").value
                                                    var"##431" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##431"[1] == :macrocall && (begin
                                                            var"##432" = var"##431"[2]
                                                            var"##432" isa AbstractArray
                                                        end && (ndims(var"##432") === 1 && length(var"##432") >= 0)))))))))
                    var"##return#370" = begin
                            return compare_macrocall(m, lhs, rhs)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#371#443")))
                end
                if begin
                            begin
                                var"##cache#434" = nothing
                            end
                            var"##433" = var"##372"[1]
                            var"##433" isa Expr
                        end && (begin
                                if var"##cache#434" === nothing
                                    var"##cache#434" = Some(((var"##433").head, (var"##433").args))
                                end
                                var"##435" = (var"##cache#434").value
                                var"##435" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##435"[1] == :function && (begin
                                        var"##436" = var"##435"[2]
                                        var"##436" isa AbstractArray
                                    end && ((ndims(var"##436") === 1 && length(var"##436") >= 0) && (begin
                                                begin
                                                    var"##cache#438" = nothing
                                                end
                                                var"##437" = var"##372"[2]
                                                var"##437" isa Expr
                                            end && (begin
                                                    if var"##cache#438" === nothing
                                                        var"##cache#438" = Some(((var"##437").head, (var"##437").args))
                                                    end
                                                    var"##439" = (var"##cache#438").value
                                                    var"##439" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##439"[1] == :function && (begin
                                                            var"##440" = var"##439"[2]
                                                            var"##440" isa AbstractArray
                                                        end && (ndims(var"##440") === 1 && length(var"##440") >= 0)))))))))
                    var"##return#370" = begin
                            return compare_function(m, lhs, rhs)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#371#443")))
                end
                if begin
                            var"##441" = var"##372"[1]
                            var"##441" isa Expr
                        end && begin
                            var"##442" = var"##372"[2]
                            var"##442" isa Expr
                        end
                    var"##return#370" = begin
                            lhs.head === rhs.head || return false
                            length(lhs.args) == length(rhs.args) || return false
                            for (a, b) = zip(lhs.args, rhs.args)
                                compare_expr(m, a, b) || return false
                            end
                            return true
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#371#443")))
                end
            end
            begin
                var"##return#370" = begin
                        return lhs == rhs
                    end
                $(Expr(:symbolicgoto, Symbol("####final#371#443")))
            end
            error("matching non-exhaustive, at #= none:206 =#")
            $(Expr(:symboliclabel, Symbol("####final#371#443")))
            var"##return#370"
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
