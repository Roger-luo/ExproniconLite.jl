begin
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
            compare_expr(m, lhs, rhs) && return true
            (lhs, rhs) = locate_inequal_expr(m, lhs, rhs)
            throw(ExprNotEqual(lhs, rhs))
        end
    #= none:60 =# Core.@doc "    @test_expr <type> <ex>\n\nTest if the syntax type generates the same expression `ex`. Returns the\ncorresponding syntax type instance. Requires `using Test` before using\nthis macro.\n\n# Example\n\n```julia\ndef = @test_expr JLFunction function (x, y)\n    return 2\nend\n@test is_kw_fn(def) == false\n```\n" macro test_expr(type, ex)
            #= none:77 =# @gensym def generated_expr original_expr
            quote
                    $def = #= none:79 =# ExproniconLite.@expr($type, $ex)
                    ($Base).show(stdout, (MIME"text/plain")(), $def)
                    $generated_expr = ($codegen_ast)($def)
                    $original_expr = $(Expr(:quote, ex))
                    #= none:83 =# @test $(Expr(:block, __source__, :(($assert_equal_expr)($__module__, $generated_expr, $original_expr))))
                    $def
                end |> esc
        end
    #= none:91 =# Core.@doc "    @test_expr <expr> == <expr>\n\nTest if two expression is equivalent semantically, this uses `compare_expr`\nto decide if they are equivalent, ignores things such as `LineNumberNode`\ngenerated `Symbol` in `Expr(:curly, ...)` or `Expr(:where, ...)`.\n\n!!! note\n\n    This macro requires one `using Test` to import the `Test` module\n    name.\n" macro test_expr(ex::Expr)
            esc(test_expr_m(__module__, __source__, ex))
        end
    function test_expr_m(__module__, __source__, ex::Expr)
        ex.head === :call && ex.args[1] === :(==) || error("expect <expr> == <expr>, got $(ex)")
        (lhs, rhs) = (ex.args[2], ex.args[3])
        #= none:110 =# @gensym result cmp_result err
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
    #= none:135 =# Core.@doc "    compare_expr([m=Main], lhs, rhs)\n\nCompare two expression of type `Expr` or `Symbol` semantically, which:\n\n1. ignore the detail value `LineNumberNode` in comparision;\n2. ignore the detailed name of typevars declared by `where`;\n3. recognize inserted objects and `Symbol`, e.g `:(\$Int)` is equal to `:(Int)`;\n4. recognize `QuoteNode(:x)` and `Symbol(\"x\")` as equal;\n5. will guess module and type objects and compare their value directly\n    instead of their expression;\n\n!!! tips\n\n    This function is usually combined with [`prettify`](@ref)\n    with `preserve_last_nothing=true` and `alias_gensym=false`.\n\nThis gives a way to compare two Julia expression semantically which means\nalthough some details of the expression is different but they should\nproduce the same lowered code.\n" compare_expr(lhs, rhs) = begin
                compare_expr(Main, lhs, rhs)
            end
    function compare_expr(m::Module, lhs, rhs)
        true
        x_1 = (lhs, rhs)
        if x_1 isa Tuple{TypeVar, TypeVar}
            if begin
                        x_2 = x_1[1]
                        x_2 isa TypeVar
                    end && begin
                        x_3 = x_1[2]
                        x_3 isa TypeVar
                    end
                return_1 = begin
                        compare_expr(m, lhs.lb, rhs.lb) || return false
                        compare_expr(m, lhs.ub, rhs.ub) || return false
                        return true
                    end
                $(Expr(:symbolicgoto, Symbol("##final#717_1")))
            end
        end
        if x_1 isa Tuple{LineNumberNode, LineNumberNode}
            if begin
                        x_4 = x_1[1]
                        x_4 isa LineNumberNode
                    end && begin
                        x_5 = x_1[2]
                        x_5 isa LineNumberNode
                    end
                return_1 = begin
                        return true
                    end
                $(Expr(:symbolicgoto, Symbol("##final#717_1")))
            end
        end
        if x_1 isa Tuple{GlobalRef, GlobalRef}
            if begin
                        x_6 = x_1[1]
                        x_6 isa GlobalRef
                    end && begin
                        x_7 = x_1[2]
                        x_7 isa GlobalRef
                    end
                return_1 = begin
                        return lhs === rhs
                    end
                $(Expr(:symbolicgoto, Symbol("##final#717_1")))
            end
        end
        if x_1 isa Tuple{Variable, Variable}
            if begin
                        x_8 = x_1[1]
                        x_8 isa Variable
                    end && begin
                        x_9 = x_1[2]
                        x_9 isa Variable
                    end
                return_1 = begin
                        return true
                    end
                $(Expr(:symbolicgoto, Symbol("##final#717_1")))
            end
        end
        if x_1 isa Tuple{Any, Any}
            if x_1 isa Tuple{Symbol, Symbol} && (begin
                            x_10 = x_1[1]
                            x_10 isa Symbol
                        end && begin
                            x_11 = x_1[2]
                            x_11 isa Symbol
                        end)
                return_1 = begin
                        return lhs === rhs
                    end
                $(Expr(:symbolicgoto, Symbol("##final#717_1")))
            end
            if x_1 isa Tuple{Module, Module} && (begin
                            x_12 = x_1[1]
                            x_12 isa Module
                        end && begin
                            x_13 = x_1[2]
                            x_13 isa Module
                        end)
                return_1 = begin
                        return lhs === rhs
                    end
                $(Expr(:symbolicgoto, Symbol("##final#717_1")))
            end
            if x_1 isa Tuple{QuoteNode, Expr} && (begin
                            x_14 = x_1[1]
                            x_14 isa QuoteNode
                        end && (begin
                                cache_1 = nothing
                                x_15 = x_1[2]
                                x_15 isa Expr
                            end && (begin
                                    if cache_1 === nothing
                                        cache_1 = Some((x_15.head, x_15.args))
                                    end
                                    x_16 = cache_1.value
                                    x_16 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                end && (x_16[1] == :call && (begin
                                            x_17 = x_16[2]
                                            x_17 isa AbstractArray
                                        end && (length(x_17) === 2 && (x_17[1] == :Symbol && begin
                                                    x_18 = x_17[2]
                                                    true
                                                end)))))))
                a = x_14
                b = x_18
                return_1 = begin
                        isdefined(m, :Symbol) || return false
                        return a.value === Symbol(b)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#717_1")))
            end
            if x_1 isa Tuple{Expr, QuoteNode} && (begin
                            cache_2 = nothing
                            x_19 = x_1[1]
                            x_19 isa Expr
                        end && (begin
                                if cache_2 === nothing
                                    cache_2 = Some((x_19.head, x_19.args))
                                end
                                x_20 = cache_2.value
                                x_20 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_20[1] == :call && (begin
                                        x_21 = x_20[2]
                                        x_21 isa AbstractArray
                                    end && (length(x_21) === 2 && (x_21[1] == :Symbol && begin
                                                x_22 = x_21[2]
                                                x_23 = x_1[2]
                                                x_23 isa QuoteNode
                                            end))))))
                a = x_23
                b = x_22
                return_1 = begin
                        isdefined(m, :Symbol) || return false
                        return a.value === Symbol(b)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#717_1")))
            end
            if x_1 isa Tuple{Expr, Expr} && (begin
                            x_24 = x_1[1]
                            x_24 isa Expr
                        end && begin
                            x_25 = x_1[2]
                            x_25 isa Expr
                        end)
                return_1 = begin
                        return compare_expr_object(m, lhs, rhs)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#717_1")))
            end
            if x_1 isa Tuple{Expr, var2} where var2<:Type && (begin
                            cache_3 = nothing
                            x_26 = x_1[1]
                            x_26 isa Expr
                        end && (begin
                                if cache_3 === nothing
                                    cache_3 = Some((x_26.head, x_26.args))
                                end
                                x_27 = cache_3.value
                                x_27 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_27[1] == :curly && (begin
                                        x_28 = x_27[2]
                                        x_28 isa AbstractArray
                                    end && ((ndims(x_28) === 1 && length(x_28) >= 0) && begin
                                            x_29 = x_1[2]
                                            x_29 isa Type
                                        end)))))
                return_1 = begin
                        return guess_type(m, lhs) == rhs
                    end
                $(Expr(:symbolicgoto, Symbol("##final#717_1")))
            end
            if x_1 isa Tuple{var1, Expr} where var1<:Type && (begin
                            x_30 = x_1[1]
                            x_30 isa Type
                        end && (begin
                                cache_4 = nothing
                                x_31 = x_1[2]
                                x_31 isa Expr
                            end && (begin
                                    if cache_4 === nothing
                                        cache_4 = Some((x_31.head, x_31.args))
                                    end
                                    x_32 = cache_4.value
                                    x_32 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                end && (x_32[1] == :curly && (begin
                                            x_33 = x_32[2]
                                            x_33 isa AbstractArray
                                        end && (ndims(x_33) === 1 && length(x_33) >= 0))))))
                return_1 = begin
                        return lhs == guess_type(m, rhs)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#717_1")))
            end
            if x_1 isa Tuple{var1, Symbol} where var1 && begin
                        x_34 = x_1[1]
                        x_35 = x_1[2]
                        x_35 isa Symbol
                    end
                a = x_34
                b = x_35
                return_1 = begin
                        isdefined(m, b) || return false
                        return getfield(m, b) === a
                    end
                $(Expr(:symbolicgoto, Symbol("##final#717_1")))
            end
            if x_1 isa Tuple{Symbol, var2} where var2 && (begin
                            x_36 = x_1[1]
                            x_36 isa Symbol
                        end && begin
                            x_37 = x_1[2]
                            true
                        end)
                a = x_37
                b = x_36
                return_1 = begin
                        isdefined(m, b) || return false
                        return getfield(m, b) === a
                    end
                $(Expr(:symbolicgoto, Symbol("##final#717_1")))
            end
            if x_1 isa Tuple{var1, Expr} where var1 && begin
                        x_38 = x_1[1]
                        x_39 = x_1[2]
                        x_39 isa Expr
                    end
                a = x_38
                b = x_39
                return_1 = begin
                        try
                            return a == Base.eval(m, b)
                        catch _
                            return false
                        end
                    end
                $(Expr(:symbolicgoto, Symbol("##final#717_1")))
            end
            if x_1 isa Tuple{Expr, var2} where var2 && (begin
                            x_40 = x_1[1]
                            x_40 isa Expr
                        end && begin
                            x_41 = x_1[2]
                            true
                        end)
                a = x_41
                b = x_40
                return_1 = begin
                        try
                            return a == Base.eval(m, b)
                        catch _
                            return false
                        end
                    end
                $(Expr(:symbolicgoto, Symbol("##final#717_1")))
            end
            if x_1 isa Tuple{Module, var2} where var2 && (begin
                            x_42 = x_1[1]
                            x_42 isa Module
                        end && begin
                            x_43 = x_1[2]
                            true
                        end)
                a = x_42
                b = x_43
                return_1 = begin
                        mod = guess_module(m, b)
                        isnothing(mod) && return false
                        return a === mod
                    end
                $(Expr(:symbolicgoto, Symbol("##final#717_1")))
            end
            if x_1 isa Tuple{var1, Module} where var1 && begin
                        x_44 = x_1[1]
                        x_45 = x_1[2]
                        x_45 isa Module
                    end
                a = x_45
                b = x_44
                return_1 = begin
                        mod = guess_module(m, b)
                        isnothing(mod) && return false
                        return a === mod
                    end
                $(Expr(:symbolicgoto, Symbol("##final#717_1")))
            end
        end
        return_1 = begin
                return lhs == rhs
            end
        $(Expr(:symbolicgoto, Symbol("##final#717_1")))
        (error)("matching non-exhaustive, at #= none:159 =#")
        $(Expr(:symboliclabel, Symbol("##final#717_1")))
        return_1
    end
    function compare_expr_object(m::Module, lhs::Expr, rhs::Expr)
        true
        x_46 = (lhs, rhs)
        if x_46 isa Tuple{Expr, Expr}
            if begin
                        cache_5 = nothing
                        x_47 = x_46[1]
                        x_47 isa Expr
                    end && (begin
                            if cache_5 === nothing
                                cache_5 = Some((x_47.head, x_47.args))
                            end
                            x_48 = cache_5.value
                            x_48 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_48[1] == :(::) && (begin
                                    x_49 = x_48[2]
                                    x_49 isa AbstractArray
                                end && (length(x_49) === 1 && (begin
                                            x_50 = x_49[1]
                                            cache_6 = nothing
                                            x_51 = x_46[2]
                                            x_51 isa Expr
                                        end && (begin
                                                if cache_6 === nothing
                                                    cache_6 = Some((x_51.head, x_51.args))
                                                end
                                                x_52 = cache_6.value
                                                x_52 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                            end && (x_52[1] == :(::) && (begin
                                                        x_53 = x_52[2]
                                                        x_53 isa AbstractArray
                                                    end && (length(x_53) === 1 && begin
                                                            x_54 = x_53[1]
                                                            true
                                                        end)))))))))
                tx = x_50
                ty = x_54
                return_2 = begin
                        tx = guess_type(m, tx)
                        ty = guess_type(m, ty)
                        return compare_expr(m, tx, ty)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#769_1")))
            end
            if begin
                        cache_7 = nothing
                        x_55 = x_46[1]
                        x_55 isa Expr
                    end && (begin
                            if cache_7 === nothing
                                cache_7 = Some((x_55.head, x_55.args))
                            end
                            x_56 = cache_7.value
                            x_56 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_56[1] == :(::) && (begin
                                    x_57 = x_56[2]
                                    x_57 isa AbstractArray
                                end && (length(x_57) === 2 && (begin
                                            x_58 = x_57[1]
                                            x_59 = x_57[2]
                                            cache_8 = nothing
                                            x_60 = x_46[2]
                                            x_60 isa Expr
                                        end && (begin
                                                if cache_8 === nothing
                                                    cache_8 = Some((x_60.head, x_60.args))
                                                end
                                                x_61 = cache_8.value
                                                x_61 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                            end && (x_61[1] == :(::) && (begin
                                                        x_62 = x_61[2]
                                                        x_62 isa AbstractArray
                                                    end && (length(x_62) === 2 && begin
                                                            x_63 = x_62[1]
                                                            x_64 = x_62[2]
                                                            true
                                                        end)))))))))
                tx = x_59
                y = x_63
                ty = x_64
                x = x_58
                return_2 = begin
                        tx = guess_type(m, tx)
                        ty = guess_type(m, ty)
                        return compare_expr(m, x, y) && compare_expr(m, tx, ty)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#769_1")))
            end
            if begin
                        cache_9 = nothing
                        x_65 = x_46[1]
                        x_65 isa Expr
                    end && (begin
                            if cache_9 === nothing
                                cache_9 = Some((x_65.head, x_65.args))
                            end
                            x_66 = cache_9.value
                            x_66 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_66[1] == :. && (begin
                                    x_67 = x_66[2]
                                    x_67 isa AbstractArray
                                end && (length(x_67) === 2 && (begin
                                            x_68 = x_67[1]
                                            x_69 = x_67[2]
                                            x_69 isa QuoteNode
                                        end && (begin
                                                x_70 = x_69.value
                                                cache_10 = nothing
                                                x_71 = x_46[2]
                                                x_71 isa Expr
                                            end && (begin
                                                    if cache_10 === nothing
                                                        cache_10 = Some((x_71.head, x_71.args))
                                                    end
                                                    x_72 = cache_10.value
                                                    x_72 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                end && (x_72[1] == :. && (begin
                                                            x_73 = x_72[2]
                                                            x_73 isa AbstractArray
                                                        end && (length(x_73) === 2 && (begin
                                                                    x_74 = x_73[1]
                                                                    x_75 = x_73[2]
                                                                    x_75 isa QuoteNode
                                                                end && begin
                                                                    x_76 = x_75.value
                                                                    true
                                                                end)))))))))))
                sub_a = x_70
                sub_b = x_76
                mod_b = x_74
                mod_a = x_68
                return_2 = begin
                        mod_a = guess_module(m, mod_a)
                        mod_b = guess_module(m, mod_b)
                        compare_expr(m, mod_a, mod_b) || return false
                        return compare_expr(m, sub_a, sub_b)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#769_1")))
            end
            if begin
                        cache_11 = nothing
                        x_77 = x_46[1]
                        x_77 isa Expr
                    end && (begin
                            if cache_11 === nothing
                                cache_11 = Some((x_77.head, x_77.args))
                            end
                            x_78 = cache_11.value
                            x_78 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_78[1] == :where && (begin
                                    x_79 = x_78[2]
                                    x_79 isa AbstractArray
                                end && ((ndims(x_79) === 1 && length(x_79) >= 0) && (begin
                                            cache_12 = nothing
                                            x_80 = x_46[2]
                                            x_80 isa Expr
                                        end && (begin
                                                if cache_12 === nothing
                                                    cache_12 = Some((x_80.head, x_80.args))
                                                end
                                                x_81 = cache_12.value
                                                x_81 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                            end && (x_81[1] == :where && (begin
                                                        x_82 = x_81[2]
                                                        x_82 isa AbstractArray
                                                    end && (ndims(x_82) === 1 && length(x_82) >= 0)))))))))
                return_2 = begin
                        return compare_where(m, lhs, rhs)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#769_1")))
            end
            if begin
                        cache_13 = nothing
                        x_83 = x_46[1]
                        x_83 isa Expr
                    end && (begin
                            if cache_13 === nothing
                                cache_13 = Some((x_83.head, x_83.args))
                            end
                            x_84 = cache_13.value
                            x_84 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_84[1] == :curly && (begin
                                    x_85 = x_84[2]
                                    x_85 isa AbstractArray
                                end && ((ndims(x_85) === 1 && length(x_85) >= 0) && (begin
                                            cache_14 = nothing
                                            x_86 = x_46[2]
                                            x_86 isa Expr
                                        end && (begin
                                                if cache_14 === nothing
                                                    cache_14 = Some((x_86.head, x_86.args))
                                                end
                                                x_87 = cache_14.value
                                                x_87 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                            end && (x_87[1] == :curly && (begin
                                                        x_88 = x_87[2]
                                                        x_88 isa AbstractArray
                                                    end && (ndims(x_88) === 1 && length(x_88) >= 0)))))))))
                return_2 = begin
                        return compare_curly(m, lhs, rhs)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#769_1")))
            end
            if begin
                        x_89 = x_46[1]
                        x_89 isa Expr
                    end && begin
                        x_90 = x_46[2]
                        x_90 isa Expr
                    end
                return_2 = begin
                        lhs.head === rhs.head || return false
                        length(lhs.args) == length(rhs.args) || return false
                        for (a, b) = zip(lhs.args, rhs.args)
                            compare_expr(m, a, b) || return false
                        end
                        return true
                    end
                $(Expr(:symbolicgoto, Symbol("##final#769_1")))
            end
        end
        return_2 = begin
                return lhs == rhs
            end
        $(Expr(:symbolicgoto, Symbol("##final#769_1")))
        (error)("matching non-exhaustive, at #= none:204 =#")
        $(Expr(:symboliclabel, Symbol("##final#769_1")))
        return_2
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
                #= none:267 =# @show (l, r)
                #= none:268 =# @show compare_expr(m, l.args[2], r.args[2])
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
end
