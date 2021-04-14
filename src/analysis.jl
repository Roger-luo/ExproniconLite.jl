begin
    #= none:1 =# Core.@doc "    @expr <expression>\n\nReturn the original expression object.\n\n# Example\n\n```julia\njulia> ex = @expr x + 1\n:(x + 1)\n```\n" $(Expr(:macro, :(expr(ex)), :(return QuoteNode(ex))))
    #= none:17 =# Core.@doc "    @test_expr <type> <ex>\n\nTest if the syntax type generates the same expression `ex`. Returns the\ncorresponding syntax type instance. Requires `using Test` before using\nthis macro.\n\n# Example\n\n```julia\ndef = @test_expr JLFunction function (x, y)\n    return 2\nend\n@test is_kw_fn(def) == false\n```\n" $(Expr(:macro, :(test_expr(type, ex)), quote
    #= none:34 =# @gensym def generated_expr original_expr
    $(Expr(:quote, quote
    $(Expr(:$, :def)) = #= none:36 =# ExproniconLite.@expr($(Expr(:$, :type)), $(Expr(:$, :ex)))
    println($(Expr(:$, :def)))
    $(Expr(:$, :generated_expr)) = ($(Expr(:$, :prettify)))(($(Expr(:$, :codegen_ast)))($(Expr(:$, :def))))
    $(Expr(:$, :original_expr)) = ($(Expr(:$, :prettify)))($(Expr(:$, :(Expr(:quote, ex)))))
    #= none:40 =# @test ($(Expr(:$, :compare_expr)))($(Expr(:$, :generated_expr)), $(Expr(:$, :original_expr)))
    $(Expr(:$, :def))
end)) |> esc
end))
    #= none:45 =# Core.@doc "    @test_expr <expr> == <expr>\n\nTest if two expression is equivalent semantically, this uses `compare_expr`\nto decide if they are equivalent, ignores things such as `LineNumberNode`\ngenerated `Symbol` in `Expr(:curly, ...)` or `Expr(:where, ...)`.\n" $(Expr(:macro, :(test_expr(ex::Expr)), quote
    ex.head === :call && ex.args[1] === :(==) || error("expect <expr> == <expr>, got $(ex)")
    (lhs, rhs) = (ex.args[2], ex.args[3])
    $(Expr(:quote, quote
    $(Expr(:$, :__source__))
    #= none:57 =# @test ($(Expr(:$, :compare_expr)))(($(Expr(:$, :prettify)))($(Expr(:$, :lhs))), ($(Expr(:$, :prettify)))($(Expr(:$, :rhs))))
end)) |> esc
end))
    #= none:61 =# Core.@doc "    @expr <type> <expression>\n\nReturn the expression in given type.\n\n# Example\n\n```julia\njulia> ex = @expr JLKwStruct struct Foo{N, T}\n           x::T = 1\n       end\n#= kw =# struct Foo{N, T}\n    #= /home/roger/code/julia/Expronicon/test/analysis.jl:5 =#\n    x::T = 1\nend\n```\n" $(Expr(:macro, :(expr(type, ex)), :($(Expr(:quote, quote
    ($(Expr(:$, :type)))($(Expr(:$, :(Expr(:quote, ex)))))
end)) |> esc)))
    struct AnalysisError <: Exception
        expect::String
        got
    end
    anlys_error(expect, got) = begin
            throw(AnalysisError(expect, got))
        end
    function Base.show(io::IO, e::AnalysisError)
        print(io, "expect ", e.expect, " expression, got ", e.got, ".")
    end
    #= none:95 =# Core.@doc "    compare_expr(lhs, rhs)\n\nCompare two expression of type `Expr` or `Symbol` semantically, which:\n\n1. ignore the detail value `LineNumberNode` in comparision\n2. ignore the detailed name of typevars in `Expr(:curly, ...)` or `Expr(:where, ...)`\n\nThis gives a way to compare two Julia expression semantically which means\nalthough some details of the expression is different but they should\nproduce the same lowered code.\n" function compare_expr(lhs, rhs)
            true
            ##373 = (lhs, rhs)
            if ##373 isa Tuple{Symbol,Symbol}
                if begin
                            ##374 = ##373[1]
                            ##374 isa Symbol
                        end && begin
                            ##375 = ##373[2]
                            ##375 isa Symbol
                        end
                    ##return#371 = begin
                            lhs === rhs
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#372#414")))
                end
            end
            if ##373 isa Tuple{Expr,Expr}
                if begin
                            ##cache#377 = nothing
                            ##376 = ##373[1]
                            ##376 isa Expr
                        end && (begin
                                if ##cache#377 === nothing
                                    ##cache#377 = Some(((##376).head, (##376).args))
                                end
                                ##378 = (##cache#377).value
                                ##378 isa Tuple{Symbol,var2} where var2<:AbstractArray
                            end && (##378[1] == :curly && (begin
                                        ##379 = ##378[2]
                                        ##379 isa AbstractArray
                                    end && ((ndims(##379) === 1 && length(##379) >= 1) && (begin
                                                ##380 = ##379[1]
                                                ##381 = (SubArray)(##379, (2:length(##379),))
                                                ##cache#383 = nothing
                                                ##382 = ##373[2]
                                                ##382 isa Expr
                                            end && (begin
                                                    if ##cache#383 === nothing
                                                        ##cache#383 = Some(((##382).head, (##382).args))
                                                    end
                                                    ##384 = (##cache#383).value
                                                    ##384 isa Tuple{Symbol,var2} where var2<:AbstractArray
                                                end && (##384[1] == :curly && (begin
                                                            ##385 = ##384[2]
                                                            ##385 isa AbstractArray
                                                        end && ((ndims(##385) === 1 && length(##385) >= 1) && (begin
                                                                    ##386 = ##385[1]
                                                                    let name = ##380, lhs_vars = ##381
                                                                        ##386 == name
                                                                    end
                                                                end && begin
                                                                    ##387 = (SubArray)(##385, (2:length(##385),))
                                                                    true
                                                                end))))))))))
                    rhs_vars = ##387
                    name = ##380
                    lhs_vars = ##381
                    ##return#371 = begin
                            all(map(compare_vars, lhs_vars, rhs_vars))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#372#414")))
                end
                if begin
                            ##cache#389 = nothing
                            ##388 = ##373[1]
                            ##388 isa Expr
                        end && (begin
                                if ##cache#389 === nothing
                                    ##cache#389 = Some(((##388).head, (##388).args))
                                end
                                ##390 = (##cache#389).value
                                ##390 isa Tuple{Symbol,var2} where var2<:AbstractArray
                            end && (##390[1] == :where && (begin
                                        ##391 = ##390[2]
                                        ##391 isa AbstractArray
                                    end && ((ndims(##391) === 1 && length(##391) >= 1) && (begin
                                                ##392 = ##391[1]
                                                ##393 = (SubArray)(##391, (2:length(##391),))
                                                ##cache#395 = nothing
                                                ##394 = ##373[2]
                                                ##394 isa Expr
                                            end && (begin
                                                    if ##cache#395 === nothing
                                                        ##cache#395 = Some(((##394).head, (##394).args))
                                                    end
                                                    ##396 = (##cache#395).value
                                                    ##396 isa Tuple{Symbol,var2} where var2<:AbstractArray
                                                end && (##396[1] == :where && (begin
                                                            ##397 = ##396[2]
                                                            ##397 isa AbstractArray
                                                        end && ((ndims(##397) === 1 && length(##397) >= 1) && begin
                                                                ##398 = ##397[1]
                                                                ##399 = (SubArray)(##397, (2:length(##397),))
                                                                true
                                                            end)))))))))
                    lbody = ##392
                    rbody = ##398
                    rparams = ##399
                    lparams = ##393
                    ##return#371 = begin
                            compare_expr(lbody, rbody) && all(map(compare_vars, lparams, rparams))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#372#414")))
                end
                if begin
                            ##cache#401 = nothing
                            ##400 = ##373[1]
                            ##400 isa Expr
                        end && (begin
                                if ##cache#401 === nothing
                                    ##cache#401 = Some(((##400).head, (##400).args))
                                end
                                ##402 = (##cache#401).value
                                ##402 isa Tuple{var1,var2} where var1 where var2<:AbstractArray
                            end && (begin
                                    ##403 = ##402[1]
                                    ##404 = ##402[2]
                                    ##404 isa AbstractArray
                                end && ((ndims(##404) === 1 && length(##404) >= 0) && (begin
                                            ##405 = (SubArray)(##404, (1:length(##404),))
                                            ##cache#407 = nothing
                                            ##406 = ##373[2]
                                            ##406 isa Expr
                                        end && (begin
                                                if ##cache#407 === nothing
                                                    ##cache#407 = Some(((##406).head, (##406).args))
                                                end
                                                ##408 = (##cache#407).value
                                                ##408 isa Tuple{var1,var2} where var1 where var2<:AbstractArray
                                            end && (begin
                                                    ##409 = ##408[1]
                                                    let head = ##403, largs = ##405
                                                        ##409 == head
                                                    end
                                                end && (begin
                                                        ##410 = ##408[2]
                                                        ##410 isa AbstractArray
                                                    end && ((ndims(##410) === 1 && length(##410) >= 0) && begin
                                                            ##411 = (SubArray)(##410, (1:length(##410),))
                                                            true
                                                        end))))))))
                    head = ##403
                    largs = ##405
                    rargs = ##411
                    ##return#371 = begin
                            isempty(largs) && isempty(rargs) || length(largs) == length(rargs) && all(map(compare_expr, largs, rargs))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#372#414")))
                end
            end
            if ##373 isa Tuple{LineNumberNode,LineNumberNode}
                if begin
                            ##412 = ##373[1]
                            ##412 isa LineNumberNode
                        end && begin
                            ##413 = ##373[2]
                            ##413 isa LineNumberNode
                        end
                    ##return#371 = begin
                            true
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#372#414")))
                end
            end
            ##return#371 = begin
                    lhs == rhs
                end
            $(Expr(:symbolicgoto, Symbol("####final#372#414")))
            (error)("matching non-exhaustive, at #= none:108 =#")
            $(Expr(:symboliclabel, Symbol("####final#372#414")))
            ##return#371
        end
    #= none:127 =# Core.@doc "    compare_vars(lhs, rhs)\n\nCompare two expression by assuming all `Symbol`s are variables,\nthus their value doesn't matter, only where they are matters under\nthis assumption. See also [`compare_expr`](@ref).\n" function compare_vars(lhs, rhs)
            true
            ##417 = (lhs, rhs)
            if ##417 isa Tuple{Symbol,Symbol}
                if begin
                            ##418 = ##417[1]
                            ##418 isa Symbol
                        end && begin
                            ##419 = ##417[2]
                            ##419 isa Symbol
                        end
                    ##return#415 = begin
                            true
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#416#434")))
                end
            end
            if ##417 isa Tuple{Expr,Expr}
                if begin
                            ##cache#421 = nothing
                            ##420 = ##417[1]
                            ##420 isa Expr
                        end && (begin
                                if ##cache#421 === nothing
                                    ##cache#421 = Some(((##420).head, (##420).args))
                                end
                                ##422 = (##cache#421).value
                                ##422 isa Tuple{var1,var2} where var1 where var2<:AbstractArray
                            end && (begin
                                    ##423 = ##422[1]
                                    ##424 = ##422[2]
                                    ##424 isa AbstractArray
                                end && ((ndims(##424) === 1 && length(##424) >= 0) && (begin
                                            ##425 = (SubArray)(##424, (1:length(##424),))
                                            ##cache#427 = nothing
                                            ##426 = ##417[2]
                                            ##426 isa Expr
                                        end && (begin
                                                if ##cache#427 === nothing
                                                    ##cache#427 = Some(((##426).head, (##426).args))
                                                end
                                                ##428 = (##cache#427).value
                                                ##428 isa Tuple{var1,var2} where var1 where var2<:AbstractArray
                                            end && (begin
                                                    ##429 = ##428[1]
                                                    let head = ##423, largs = ##425
                                                        ##429 == head
                                                    end
                                                end && (begin
                                                        ##430 = ##428[2]
                                                        ##430 isa AbstractArray
                                                    end && ((ndims(##430) === 1 && length(##430) >= 0) && begin
                                                            ##431 = (SubArray)(##430, (1:length(##430),))
                                                            true
                                                        end))))))))
                    head = ##423
                    largs = ##425
                    rargs = ##431
                    ##return#415 = begin
                            all(map(compare_vars, largs, rargs))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#416#434")))
                end
            end
            if ##417 isa Tuple{LineNumberNode,LineNumberNode}
                if begin
                            ##432 = ##417[1]
                            ##432 isa LineNumberNode
                        end && begin
                            ##433 = ##417[2]
                            ##433 isa LineNumberNode
                        end
                    ##return#415 = begin
                            true
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#416#434")))
                end
            end
            ##return#415 = begin
                    lhs == rhs
                end
            $(Expr(:symbolicgoto, Symbol("####final#416#434")))
            (error)("matching non-exhaustive, at #= none:135 =#")
            $(Expr(:symboliclabel, Symbol("####final#416#434")))
            ##return#415
        end
    #= none:148 =# Core.@doc "    is_literal(x)\n\nCheck if `x` is a literal value.\n" function is_literal(x)
            !(x isa Expr || (x isa Symbol || x isa GlobalRef))
        end
    #= none:157 =# Core.@doc "    support_default(f)\n\nCheck if field type `f` supports default value.\n" support_default(f) = begin
                false
            end
    support_default(f::JLKwField) = begin
            true
        end
    function has_symbol(#= none:165 =# @nospecialize(ex), name::Symbol)
        ex isa Symbol && return ex === name
        ex isa Expr || return false
        return any((x->begin
                        has_symbol(x, name)
                    end), ex.args)
    end
    #= none:171 =# Core.@doc "    has_kwfn_constructor(def[, name = struct_name_plain(def)])\n\nCheck if the struct definition contains keyword function constructor of `name`.\nThe constructor name to check by default is the plain constructor which does\nnot infer any type variables and requires user to input all type variables.\nSee also [`struct_name_plain`](@ref).\n" function has_kwfn_constructor(def, name=struct_name_plain(def))
            any(def.constructors) do fn::JLFunction
                isempty(fn.args) && fn.name == name
            end
        end
    #= none:185 =# Core.@doc "    has_plain_constructor(def, name = struct_name_plain(def))\n\nCheck if the struct definition contains the plain constructor of `name`.\nBy default the name is the inferable name [`struct_name_plain`](@ref).\n\n# Example\n\n```julia\ndef = @expr JLKwStruct struct Foo{T, N}\n    x::Int\n    y::N\n\n    Foo{T, N}(x, y) where {T, N} = new{T, N}(x, y)\nend\n\nhas_plain_constructor(def) # true\n\ndef = @expr JLKwStruct struct Foo{T, N}\n    x::T\n    y::N\n\n    Foo(x, y) = new{typeof(x), typeof(y)}(x, y)\nend\n\nhas_plain_constructor(def) # false\n```\n\nthe arguments must have no type annotations.\n\n```julia\ndef = @expr JLKwStruct struct Foo{T, N}\n    x::T\n    y::N\n\n    Foo{T, N}(x::T, y::N) where {T, N} = new{T, N}(x, y)\nend\n\nhas_plain_constructor(def) # false\n```\n" function has_plain_constructor(def, name=struct_name_plain(def))
            any(def.constructors) do fn::JLFunction
                fn.name == name || return false
                fn.kwargs === nothing || return false
                length(def.fields) == length(fn.args) || return false
                for (f, x) = zip(def.fields, fn.args)
                    f.name === x || return false
                end
                return true
            end
        end
    #= none:238 =# Core.@doc "    is_function(def)\n\nCheck if given object is a function expression.\n" function is_function(#= none:243 =# @nospecialize(def))
            let
                ##cache#438 = nothing
                ##return#435 = nothing
                ##437 = def
                if ##437 isa Expr
                    if begin
                                if ##cache#438 === nothing
                                    ##cache#438 = Some(((##437).head, (##437).args))
                                end
                                ##439 = (##cache#438).value
                                ##439 isa Tuple{Symbol,var2} where var2<:AbstractArray
                            end && (##439[1] == :function && (begin
                                        ##440 = ##439[2]
                                        ##440 isa AbstractArray
                                    end && length(##440) === 2))
                        ##return#435 = let
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#436#445")))
                    end
                    if begin
                                ##441 = (##cache#438).value
                                ##441 isa Tuple{Symbol,var2} where var2<:AbstractArray
                            end && (##441[1] == :(=) && (begin
                                        ##442 = ##441[2]
                                        ##442 isa AbstractArray
                                    end && length(##442) === 2))
                        ##return#435 = let
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#436#445")))
                    end
                    if begin
                                ##443 = (##cache#438).value
                                ##443 isa Tuple{Symbol,var2} where var2<:AbstractArray
                            end && (##443[1] == :-> && (begin
                                        ##444 = ##443[2]
                                        ##444 isa AbstractArray
                                    end && length(##444) === 2))
                        ##return#435 = let
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#436#445")))
                    end
                end
                if ##437 isa JLFunction
                    ##return#435 = let
                            true
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#436#445")))
                end
                ##return#435 = let
                        false
                    end
                $(Expr(:symbolicgoto, Symbol("####final#436#445")))
                (error)("matching non-exhaustive, at #= none:244 =#")
                $(Expr(:symboliclabel, Symbol("####final#436#445")))
                ##return#435
            end
        end
    #= none:253 =# Core.@doc "    is_kw_function(def)\n\nCheck if a given function definition supports keyword arguments.\n" function is_kw_function(#= none:258 =# @nospecialize(def))
            is_function(def) || return false
            if def isa JLFunction
                return def.kwargs !== nothing
            end
            (_, call, _) = split_function(def)
            let
                ##cache#449 = nothing
                ##return#446 = nothing
                ##448 = call
                if ##448 isa Expr
                    if begin
                                if ##cache#449 === nothing
                                    ##cache#449 = Some(((##448).head, (##448).args))
                                end
                                ##450 = (##cache#449).value
                                ##450 isa Tuple{Symbol,var2} where var2<:AbstractArray
                            end && (##450[1] == :tuple && (begin
                                        ##451 = ##450[2]
                                        ##451 isa AbstractArray
                                    end && ((ndims(##451) === 1 && length(##451) >= 1) && (begin
                                                ##cache#453 = nothing
                                                ##452 = ##451[1]
                                                ##452 isa Expr
                                            end && (begin
                                                    if ##cache#453 === nothing
                                                        ##cache#453 = Some(((##452).head, (##452).args))
                                                    end
                                                    ##454 = (##cache#453).value
                                                    ##454 isa Tuple{Symbol,var2} where var2<:AbstractArray
                                                end && (##454[1] == :parameters && (begin
                                                            ##455 = ##454[2]
                                                            ##455 isa AbstractArray
                                                        end && (ndims(##455) === 1 && length(##455) >= 0))))))))
                        ##return#446 = let
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#447#465")))
                    end
                    if begin
                                ##456 = (##cache#449).value
                                ##456 isa Tuple{Symbol,var2} where var2<:AbstractArray
                            end && (##456[1] == :call && (begin
                                        ##457 = ##456[2]
                                        ##457 isa AbstractArray
                                    end && ((ndims(##457) === 1 && length(##457) >= 2) && (begin
                                                ##cache#459 = nothing
                                                ##458 = ##457[2]
                                                ##458 isa Expr
                                            end && (begin
                                                    if ##cache#459 === nothing
                                                        ##cache#459 = Some(((##458).head, (##458).args))
                                                    end
                                                    ##460 = (##cache#459).value
                                                    ##460 isa Tuple{Symbol,var2} where var2<:AbstractArray
                                                end && (##460[1] == :parameters && (begin
                                                            ##461 = ##460[2]
                                                            ##461 isa AbstractArray
                                                        end && (ndims(##461) === 1 && length(##461) >= 0))))))))
                        ##return#446 = let
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#447#465")))
                    end
                    if begin
                                ##462 = (##cache#449).value
                                ##462 isa Tuple{Symbol,var2} where var2<:AbstractArray
                            end && (##462[1] == :block && (begin
                                        ##463 = ##462[2]
                                        ##463 isa AbstractArray
                                    end && (length(##463) === 3 && begin
                                            ##464 = ##463[2]
                                            ##464 isa LineNumberNode
                                        end)))
                        ##return#446 = let
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#447#465")))
                    end
                end
                ##return#446 = let
                        false
                    end
                $(Expr(:symbolicgoto, Symbol("####final#447#465")))
                (error)("matching non-exhaustive, at #= none:266 =#")
                $(Expr(:symboliclabel, Symbol("####final#447#465")))
                ##return#446
            end
        end
    #= none:274 =# @deprecate is_kw_fn(def) is_kw_function(def)
    #= none:275 =# @deprecate is_fn(def) is_function(def)
    #= none:277 =# Core.@doc "    is_struct(ex)\n\nCheck if `ex` is a struct expression.\n" function is_struct(#= none:282 =# @nospecialize(ex))
            ex isa Expr || return false
            return ex.head === :struct
        end
    #= none:287 =# Core.@doc "    is_struct_not_kw_struct(ex)\n\nCheck if `ex` is a struct expression excluding keyword struct syntax.\n" function is_struct_not_kw_struct(ex)
            is_struct(ex) || return false
            body = ex.args[3]
            body isa Expr && body.head === :block || return false
            any(is_field_default, body.args) && return false
            return true
        end
    #= none:300 =# Core.@doc "    is_ifelse(ex)\n\nCheck if `ex` is an `if ... elseif ... else ... end` expression.\n" function is_ifelse(#= none:305 =# @nospecialize(ex))
            ex isa Expr || return false
            return ex.head === :if
        end
    #= none:310 =# Core.@doc "    is_for(ex)\n\nCheck if `ex` is a `for` loop expression.\n" function is_for(#= none:315 =# @nospecialize(ex))
            ex isa Expr || return false
            return ex.head === :for
        end
    #= none:320 =# Core.@doc "    is_field(ex)\n\nCheck if `ex` is a valid field expression.\n" function is_field(#= none:325 =# @nospecialize(ex))
            let
                ##cache#469 = nothing
                ##return#466 = nothing
                ##468 = ex
                if ##468 isa Expr
                    if begin
                                if ##cache#469 === nothing
                                    ##cache#469 = Some(((##468).head, (##468).args))
                                end
                                ##470 = (##cache#469).value
                                ##470 isa Tuple{Symbol,var2} where var2<:AbstractArray
                            end && (##470[1] == :(=) && (begin
                                        ##471 = ##470[2]
                                        ##471 isa AbstractArray
                                    end && (length(##471) === 2 && (begin
                                                ##cache#473 = nothing
                                                ##472 = ##471[1]
                                                ##472 isa Expr
                                            end && (begin
                                                    if ##cache#473 === nothing
                                                        ##cache#473 = Some(((##472).head, (##472).args))
                                                    end
                                                    ##474 = (##cache#473).value
                                                    ##474 isa Tuple{Symbol,var2} where var2<:AbstractArray
                                                end && (##474[1] == :(::) && (begin
                                                            ##475 = ##474[2]
                                                            ##475 isa AbstractArray
                                                        end && (length(##475) === 2 && begin
                                                                ##476 = ##475[1]
                                                                ##477 = ##475[2]
                                                                ##478 = ##471[2]
                                                                true
                                                            end))))))))
                        ##return#466 = let default = ##478, type = ##477, name = ##476
                                false
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#467#487")))
                    end
                    if begin
                                ##479 = (##cache#469).value
                                ##479 isa Tuple{Symbol,var2} where var2<:AbstractArray
                            end && (##479[1] == :(=) && (begin
                                        ##480 = ##479[2]
                                        ##480 isa AbstractArray
                                    end && (length(##480) === 2 && (begin
                                                ##481 = ##480[1]
                                                ##481 isa Symbol
                                            end && begin
                                                ##482 = ##480[2]
                                                true
                                            end))))
                        ##return#466 = let default = ##482, name = ##481
                                false
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#467#487")))
                    end
                    if begin
                                ##483 = (##cache#469).value
                                ##483 isa Tuple{Symbol,var2} where var2<:AbstractArray
                            end && (##483[1] == :(::) && (begin
                                        ##484 = ##483[2]
                                        ##484 isa AbstractArray
                                    end && (length(##484) === 2 && begin
                                            ##485 = ##484[1]
                                            ##486 = ##484[2]
                                            true
                                        end)))
                        ##return#466 = let type = ##486, name = ##485
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#467#487")))
                    end
                end
                if ##468 isa Symbol
                    ##return#466 = let name = ##468
                            true
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#467#487")))
                end
                ##return#466 = let
                        false
                    end
                $(Expr(:symbolicgoto, Symbol("####final#467#487")))
                (error)("matching non-exhaustive, at #= none:326 =#")
                $(Expr(:symboliclabel, Symbol("####final#467#487")))
                ##return#466
            end
        end
    #= none:335 =# Core.@doc "    is_field_default(ex)\n\nCheck if `ex` is a `<field expr> = <default expr>` expression.\n" function is_field_default(#= none:340 =# @nospecialize(ex))
            let
                ##cache#491 = nothing
                ##return#488 = nothing
                ##490 = ex
                if ##490 isa Expr
                    if begin
                                if ##cache#491 === nothing
                                    ##cache#491 = Some(((##490).head, (##490).args))
                                end
                                ##492 = (##cache#491).value
                                ##492 isa Tuple{Symbol,var2} where var2<:AbstractArray
                            end && (##492[1] == :(=) && (begin
                                        ##493 = ##492[2]
                                        ##493 isa AbstractArray
                                    end && (length(##493) === 2 && (begin
                                                ##cache#495 = nothing
                                                ##494 = ##493[1]
                                                ##494 isa Expr
                                            end && (begin
                                                    if ##cache#495 === nothing
                                                        ##cache#495 = Some(((##494).head, (##494).args))
                                                    end
                                                    ##496 = (##cache#495).value
                                                    ##496 isa Tuple{Symbol,var2} where var2<:AbstractArray
                                                end && (##496[1] == :(::) && (begin
                                                            ##497 = ##496[2]
                                                            ##497 isa AbstractArray
                                                        end && (length(##497) === 2 && begin
                                                                ##498 = ##497[1]
                                                                ##499 = ##497[2]
                                                                ##500 = ##493[2]
                                                                true
                                                            end))))))))
                        ##return#488 = let default = ##500, type = ##499, name = ##498
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#489#505")))
                    end
                    if begin
                                ##501 = (##cache#491).value
                                ##501 isa Tuple{Symbol,var2} where var2<:AbstractArray
                            end && (##501[1] == :(=) && (begin
                                        ##502 = ##501[2]
                                        ##502 isa AbstractArray
                                    end && (length(##502) === 2 && (begin
                                                ##503 = ##502[1]
                                                ##503 isa Symbol
                                            end && begin
                                                ##504 = ##502[2]
                                                true
                                            end))))
                        ##return#488 = let default = ##504, name = ##503
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#489#505")))
                    end
                end
                ##return#488 = let
                        false
                    end
                $(Expr(:symbolicgoto, Symbol("####final#489#505")))
                (error)("matching non-exhaustive, at #= none:341 =#")
                $(Expr(:symboliclabel, Symbol("####final#489#505")))
                ##return#488
            end
        end
    #= none:348 =# Core.@doc "    split_doc(ex::Expr) -> line, doc, expr\n\nSplit doc string from given expression.\n" function split_doc(ex::Expr)
            if ex.head === :macrocall && ex.args[1] == GlobalRef(Core, Symbol("@doc"))
                return (ex.args[2], ex.args[3], ex.args[4])
            else
                return (nothing, nothing, ex)
            end
        end
    #= none:361 =# Core.@doc "    split_function(ex::Expr) -> head, call, body\n\nSplit function head declaration with function body.\n" function split_function(ex::Expr)
            let
                ##cache#509 = nothing
                ##return#506 = nothing
                ##508 = ex
                if ##508 isa Expr
                    if begin
                                if ##cache#509 === nothing
                                    ##cache#509 = Some(((##508).head, (##508).args))
                                end
                                ##510 = (##cache#509).value
                                ##510 isa Tuple{Symbol,var2} where var2<:AbstractArray
                            end && (##510[1] == :function && (begin
                                        ##511 = ##510[2]
                                        ##511 isa AbstractArray
                                    end && (length(##511) === 2 && begin
                                            ##512 = ##511[1]
                                            ##513 = ##511[2]
                                            true
                                        end)))
                        ##return#506 = let call = ##512, body = ##513
                                (:function, call, body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#507#522")))
                    end
                    if begin
                                ##514 = (##cache#509).value
                                ##514 isa Tuple{Symbol,var2} where var2<:AbstractArray
                            end && (##514[1] == :(=) && (begin
                                        ##515 = ##514[2]
                                        ##515 isa AbstractArray
                                    end && (length(##515) === 2 && begin
                                            ##516 = ##515[1]
                                            ##517 = ##515[2]
                                            true
                                        end)))
                        ##return#506 = let call = ##516, body = ##517
                                (:(=), call, body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#507#522")))
                    end
                    if begin
                                ##518 = (##cache#509).value
                                ##518 isa Tuple{Symbol,var2} where var2<:AbstractArray
                            end && (##518[1] == :-> && (begin
                                        ##519 = ##518[2]
                                        ##519 isa AbstractArray
                                    end && (length(##519) === 2 && begin
                                            ##520 = ##519[1]
                                            ##521 = ##519[2]
                                            true
                                        end)))
                        ##return#506 = let call = ##520, body = ##521
                                (:->, call, body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#507#522")))
                    end
                end
                ##return#506 = let
                        anlys_error("function", ex)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#507#522")))
                (error)("matching non-exhaustive, at #= none:367 =#")
                $(Expr(:symboliclabel, Symbol("####final#507#522")))
                ##return#506
            end
        end
    #= none:375 =# Core.@doc "    split_function_head(ex::Expr) -> name, args, kw, whereparams, rettype\n\nSplit function head to name, arguments, keyword arguments and where parameters.\n" function split_function_head(ex::Expr)
            let
                ##cache#526 = nothing
                ##return#523 = nothing
                ##525 = ex
                if ##525 isa Expr
                    if begin
                                if ##cache#526 === nothing
                                    ##cache#526 = Some(((##525).head, (##525).args))
                                end
                                ##527 = (##cache#526).value
                                ##527 isa Tuple{Symbol,var2} where var2<:AbstractArray
                            end && (##527[1] == :tuple && (begin
                                        ##528 = ##527[2]
                                        ##528 isa AbstractArray
                                    end && ((ndims(##528) === 1 && length(##528) >= 1) && (begin
                                                ##cache#530 = nothing
                                                ##529 = ##528[1]
                                                ##529 isa Expr
                                            end && (begin
                                                    if ##cache#530 === nothing
                                                        ##cache#530 = Some(((##529).head, (##529).args))
                                                    end
                                                    ##531 = (##cache#530).value
                                                    ##531 isa Tuple{Symbol,var2} where var2<:AbstractArray
                                                end && (##531[1] == :parameters && (begin
                                                            ##532 = ##531[2]
                                                            ##532 isa AbstractArray
                                                        end && ((ndims(##532) === 1 && length(##532) >= 0) && begin
                                                                ##533 = (SubArray)(##532, (1:length(##532),))
                                                                ##534 = (SubArray)(##528, (2:length(##528),))
                                                                true
                                                            end))))))))
                        ##return#523 = let args = ##534, kw = ##533
                                (nothing, args, kw, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#524#574")))
                    end
                    if begin
                                ##535 = (##cache#526).value
                                ##535 isa Tuple{Symbol,var2} where var2<:AbstractArray
                            end && (##535[1] == :tuple && (begin
                                        ##536 = ##535[2]
                                        ##536 isa AbstractArray
                                    end && ((ndims(##536) === 1 && length(##536) >= 0) && begin
                                            ##537 = (SubArray)(##536, (1:length(##536),))
                                            true
                                        end)))
                        ##return#523 = let args = ##537
                                (nothing, args, nothing, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#524#574")))
                    end
                    if begin
                                ##538 = (##cache#526).value
                                ##538 isa Tuple{Symbol,var2} where var2<:AbstractArray
                            end && (##538[1] == :call && (begin
                                        ##539 = ##538[2]
                                        ##539 isa AbstractArray
                                    end && ((ndims(##539) === 1 && length(##539) >= 2) && (begin
                                                ##540 = ##539[1]
                                                ##cache#542 = nothing
                                                ##541 = ##539[2]
                                                ##541 isa Expr
                                            end && (begin
                                                    if ##cache#542 === nothing
                                                        ##cache#542 = Some(((##541).head, (##541).args))
                                                    end
                                                    ##543 = (##cache#542).value
                                                    ##543 isa Tuple{Symbol,var2} where var2<:AbstractArray
                                                end && (##543[1] == :parameters && (begin
                                                            ##544 = ##543[2]
                                                            ##544 isa AbstractArray
                                                        end && ((ndims(##544) === 1 && length(##544) >= 0) && begin
                                                                ##545 = (SubArray)(##544, (1:length(##544),))
                                                                ##546 = (SubArray)(##539, (3:length(##539),))
                                                                true
                                                            end))))))))
                        ##return#523 = let name = ##540, args = ##546, kw = ##545
                                (name, args, kw, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#524#574")))
                    end
                    if begin
                                ##547 = (##cache#526).value
                                ##547 isa Tuple{Symbol,var2} where var2<:AbstractArray
                            end && (##547[1] == :call && (begin
                                        ##548 = ##547[2]
                                        ##548 isa AbstractArray
                                    end && ((ndims(##548) === 1 && length(##548) >= 1) && begin
                                            ##549 = ##548[1]
                                            ##550 = (SubArray)(##548, (2:length(##548),))
                                            true
                                        end)))
                        ##return#523 = let name = ##549, args = ##550
                                (name, args, nothing, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#524#574")))
                    end
                    if begin
                                ##551 = (##cache#526).value
                                ##551 isa Tuple{Symbol,var2} where var2<:AbstractArray
                            end && (##551[1] == :block && (begin
                                        ##552 = ##551[2]
                                        ##552 isa AbstractArray
                                    end && (length(##552) === 3 && (begin
                                                ##553 = ##552[1]
                                                ##554 = ##552[2]
                                                ##554 isa LineNumberNode
                                            end && (begin
                                                    ##cache#556 = nothing
                                                    ##555 = ##552[3]
                                                    ##555 isa Expr
                                                end && (begin
                                                        if ##cache#556 === nothing
                                                            ##cache#556 = Some(((##555).head, (##555).args))
                                                        end
                                                        ##557 = (##cache#556).value
                                                        ##557 isa Tuple{Symbol,var2} where var2<:AbstractArray
                                                    end && (##557[1] == :(=) && (begin
                                                                ##558 = ##557[2]
                                                                ##558 isa AbstractArray
                                                            end && (length(##558) === 2 && begin
                                                                    ##559 = ##558[1]
                                                                    ##560 = ##558[2]
                                                                    true
                                                                end)))))))))
                        ##return#523 = let value = ##560, kw = ##559, x = ##553
                                (nothing, Any[x], Any[Expr(:kw, kw, value)], nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#524#574")))
                    end
                    if begin
                                ##561 = (##cache#526).value
                                ##561 isa Tuple{Symbol,var2} where var2<:AbstractArray
                            end && (##561[1] == :block && (begin
                                        ##562 = ##561[2]
                                        ##562 isa AbstractArray
                                    end && (length(##562) === 3 && (begin
                                                ##563 = ##562[1]
                                                ##564 = ##562[2]
                                                ##564 isa LineNumberNode
                                            end && begin
                                                ##565 = ##562[3]
                                                true
                                            end))))
                        ##return#523 = let kw = ##565, x = ##563
                                (nothing, Any[x], Any[kw], nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#524#574")))
                    end
                    if begin
                                ##566 = (##cache#526).value
                                ##566 isa Tuple{Symbol,var2} where var2<:AbstractArray
                            end && (##566[1] == :(::) && (begin
                                        ##567 = ##566[2]
                                        ##567 isa AbstractArray
                                    end && (length(##567) === 2 && begin
                                            ##568 = ##567[1]
                                            ##569 = ##567[2]
                                            true
                                        end)))
                        ##return#523 = let call = ##568, rettype = ##569
                                (name, args, kw, whereparams, _) = split_function_head(call)
                                (name, args, kw, whereparams, rettype)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#524#574")))
                    end
                    if begin
                                ##570 = (##cache#526).value
                                ##570 isa Tuple{Symbol,var2} where var2<:AbstractArray
                            end && (##570[1] == :where && (begin
                                        ##571 = ##570[2]
                                        ##571 isa AbstractArray
                                    end && ((ndims(##571) === 1 && length(##571) >= 1) && begin
                                            ##572 = ##571[1]
                                            ##573 = (SubArray)(##571, (2:length(##571),))
                                            true
                                        end)))
                        ##return#523 = let call = ##572, whereparams = ##573
                                (name, args, kw, _, rettype) = split_function_head(call)
                                (name, args, kw, whereparams, rettype)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#524#574")))
                    end
                end
                ##return#523 = let
                        anlys_error("function head expr", ex)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#524#574")))
                (error)("matching non-exhaustive, at #= none:381 =#")
                $(Expr(:symboliclabel, Symbol("####final#524#574")))
                ##return#523
            end
        end
    #= none:400 =# Core.@doc "    split_struct_name(ex::Expr) -> name, typevars, supertype\n\nSplit the name, type parameters and supertype definition from `struct`\ndeclaration head.\n" function split_struct_name(#= none:406 =# @nospecialize(ex))
            return let
                    ##cache#578 = nothing
                    ##return#575 = nothing
                    ##577 = ex
                    if ##577 isa Expr
                        if begin
                                    if ##cache#578 === nothing
                                        ##cache#578 = Some(((##577).head, (##577).args))
                                    end
                                    ##579 = (##cache#578).value
                                    ##579 isa Tuple{Symbol,var2} where var2<:AbstractArray
                                end && (##579[1] == :curly && (begin
                                            ##580 = ##579[2]
                                            ##580 isa AbstractArray
                                        end && ((ndims(##580) === 1 && length(##580) >= 1) && begin
                                                ##581 = ##580[1]
                                                ##582 = (SubArray)(##580, (2:length(##580),))
                                                true
                                            end)))
                            ##return#575 = let typevars = ##582, name = ##581
                                    (name, typevars, nothing)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#576#596")))
                        end
                        if begin
                                    ##583 = (##cache#578).value
                                    ##583 isa Tuple{Symbol,var2} where var2<:AbstractArray
                                end && (##583[1] == :<: && (begin
                                            ##584 = ##583[2]
                                            ##584 isa AbstractArray
                                        end && (length(##584) === 2 && (begin
                                                    ##cache#586 = nothing
                                                    ##585 = ##584[1]
                                                    ##585 isa Expr
                                                end && (begin
                                                        if ##cache#586 === nothing
                                                            ##cache#586 = Some(((##585).head, (##585).args))
                                                        end
                                                        ##587 = (##cache#586).value
                                                        ##587 isa Tuple{Symbol,var2} where var2<:AbstractArray
                                                    end && (##587[1] == :curly && (begin
                                                                ##588 = ##587[2]
                                                                ##588 isa AbstractArray
                                                            end && ((ndims(##588) === 1 && length(##588) >= 1) && begin
                                                                    ##589 = ##588[1]
                                                                    ##590 = (SubArray)(##588, (2:length(##588),))
                                                                    ##591 = ##584[2]
                                                                    true
                                                                end))))))))
                            ##return#575 = let typevars = ##590, type = ##591, name = ##589
                                    (name, typevars, type)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#576#596")))
                        end
                        if begin
                                    ##592 = (##cache#578).value
                                    ##592 isa Tuple{Symbol,var2} where var2<:AbstractArray
                                end && (##592[1] == :<: && (begin
                                            ##593 = ##592[2]
                                            ##593 isa AbstractArray
                                        end && (length(##593) === 2 && begin
                                                ##594 = ##593[1]
                                                ##595 = ##593[2]
                                                true
                                            end)))
                            ##return#575 = let type = ##595, name = ##594
                                    (name, [], type)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#576#596")))
                        end
                    end
                    if ##577 isa Symbol
                        ##return#575 = let
                                (ex, [], nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#576#596")))
                    end
                    ##return#575 = let
                            anlys_error("struct", ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#576#596")))
                    (error)("matching non-exhaustive, at #= none:407 =#")
                    $(Expr(:symboliclabel, Symbol("####final#576#596")))
                    ##return#575
                end
        end
    #= none:416 =# Core.@doc "    split_struct(ex::Expr) -> ismutable, name, typevars, supertype, body\n\nSplit struct definition head and body.\n" function split_struct(ex::Expr)
            ex.head === :struct || error("expect a struct expr, got $(ex)")
            (name, typevars, supertype) = split_struct_name(ex.args[2])
            body = ex.args[3]
            return (ex.args[1], name, typevars, supertype, body)
        end
    function split_ifelse(ex::Expr)
        (conds, stmts) = ([], [])
        otherwise = split_ifelse!((conds, stmts), ex)
        return (conds, stmts, otherwise)
    end
    function split_ifelse!((conds, stmts), ex::Expr)
        ex.head in [:if, :elseif] || return ex
        push!(conds, ex.args[1])
        push!(stmts, ex.args[2])
        if length(ex.args) == 3
            return split_ifelse!((conds, stmts), ex.args[3])
        end
        return
    end
    function split_forloop(ex::Expr)
        ex.head === :for || error("expect a for loop expr, got $(ex)")
        lhead = ex.args[1]
        lbody = ex.args[2]
        return (split_for_head(lhead)..., lbody)
    end
    function split_for_head(ex::Expr)
        if ex.head === :block
            (vars, itrs) = ([], [])
            for each = ex.args
                each isa Expr || continue
                (var, itr) = split_single_for_head(each)
                push!(vars, var)
                push!(itrs, itr)
            end
            return (vars, itrs)
        else
            (var, itr) = split_single_for_head(ex)
            return (Any[var], Any[itr])
        end
    end
    function split_single_for_head(ex::Expr)
        ex.head === :(=) || error("expect a single loop head, got $(ex)")
        return (ex.args[1], ex.args[2])
    end
    function uninferrable_typevars(def::Union{JLStruct, JLKwStruct}; leading_inferable::Bool=true)
        typevars = name_only.(def.typevars)
        field_types = [field.type for field = def.fields]
        if leading_inferable
            idx = findfirst(typevars) do t
                    !(any(map((f->begin
                                        has_symbol(f, t)
                                    end), field_types)))
                end
            idx === nothing && return []
        else
            idx = 0
        end
        uninferrable = typevars[1:idx]
        for T = typevars[idx + 1:end]
            any(map((f->begin
                                has_symbol(f, T)
                            end), field_types)) || push!(uninferrable, T)
        end
        return uninferrable
    end
    #= none:493 =# Core.@doc "    JLFunction(ex::Expr)\n\nCreate a `JLFunction` object from a Julia function `Expr`.\n\n# Example\n\n```julia\njulia> JLFunction(:(f(x) = 2))\nf(x) = begin\n    #= REPL[37]:1 =#    \n    2    \nend\n```\n" function JLFunction(ex::Expr)
            (line, doc, expr) = split_doc(ex)
            (head, call, body) = split_function(expr)
            (name, args, kw, whereparams, rettype) = split_function_head(call)
            JLFunction(head, name, args, kw, rettype, whereparams, body, line, doc)
        end
    #= none:515 =# Core.@doc "    JLStruct(ex::Expr)\n\nCreate a `JLStruct` object from a Julia struct `Expr`.\n\n# Example\n\n```julia\njulia> JLStruct(:(struct Foo\n           x::Int\n       end))\nstruct Foo\n    #= REPL[38]:2 =#\n    x::Int\nend\n```\n" function JLStruct(ex::Expr)
            (line, doc, expr) = split_doc(ex)
            (ismutable, typename, typevars, supertype, body) = split_struct(expr)
            (fields, constructors, misc) = (JLField[], JLFunction[], [])
            (field_doc, field_line) = (nothing, nothing)
            for each = body.args
                ##cache#600 = nothing
                ##599 = each
                if ##599 isa LineNumberNode
                    ##return#597 = begin
                            field_line = each
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#598#605")))
                end
                if ##599 isa Expr
                    if begin
                                if ##cache#600 === nothing
                                    ##cache#600 = Some(((##599).head, (##599).args))
                                end
                                ##601 = (##cache#600).value
                                ##601 isa Tuple{Symbol,var2} where var2<:AbstractArray
                            end && (##601[1] == :(::) && (begin
                                        ##602 = ##601[2]
                                        ##602 isa AbstractArray
                                    end && (length(##602) === 2 && begin
                                            ##603 = ##602[1]
                                            ##604 = ##602[2]
                                            true
                                        end)))
                        type = ##604
                        name = ##603
                        ##return#597 = begin
                                push!(fields, JLField(name, type, field_doc, field_line))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#598#605")))
                    end
                end
                if ##599 isa String
                    ##return#597 = begin
                            field_doc = each
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#598#605")))
                end
                if ##599 isa Symbol
                    name = ##599
                    ##return#597 = begin
                            push!(fields, JLField(name, Any, field_doc, field_line))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#598#605")))
                end
                if is_function(##599)
                    ##return#597 = begin
                            if name_only(each) === typename
                                push!(constructors, JLFunction(each))
                            else
                                push!(misc, each)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#598#605")))
                end
                ##return#597 = begin
                        push!(misc, each)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#598#605")))
                (error)("matching non-exhaustive, at #= none:540 =#")
                $(Expr(:symboliclabel, Symbol("####final#598#605")))
                ##return#597
            end
            JLStruct(typename, ismutable, typevars, supertype, fields, constructors, line, doc, misc)
        end
    #= none:562 =# Core.@doc "    JLKwStruct(ex::Expr, typealias=nothing)\n\nCreate a `JLKwStruct` from given Julia struct `Expr`, with an option to attach\nan alias to this type name.\n\n# Example\n\n```julia\njulia> JLKwStruct(:(struct Foo\n           x::Int = 1\n       end))\n#= kw =# struct Foo\n    #= REPL[39]:2 =#\n    x::Int = 1\nend\n```\n" function JLKwStruct(ex::Expr, typealias=nothing)
            (line, doc, expr) = split_doc(ex)
            (ismutable, typename, typevars, supertype, body) = split_struct(expr)
            (fields, constructors, misc) = (JLKwField[], JLFunction[], [])
            (field_doc, field_line) = (nothing, nothing)
            for each = body.args
                ##cache#609 = nothing
                ##608 = each
                if ##608 isa LineNumberNode
                    ##return#606 = begin
                            field_line = each
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#607#627")))
                end
                if ##608 isa Expr
                    if begin
                                if ##cache#609 === nothing
                                    ##cache#609 = Some(((##608).head, (##608).args))
                                end
                                ##610 = (##cache#609).value
                                ##610 isa Tuple{Symbol,var2} where var2<:AbstractArray
                            end && (##610[1] == :(=) && (begin
                                        ##611 = ##610[2]
                                        ##611 isa AbstractArray
                                    end && (length(##611) === 2 && (begin
                                                ##cache#613 = nothing
                                                ##612 = ##611[1]
                                                ##612 isa Expr
                                            end && (begin
                                                    if ##cache#613 === nothing
                                                        ##cache#613 = Some(((##612).head, (##612).args))
                                                    end
                                                    ##614 = (##cache#613).value
                                                    ##614 isa Tuple{Symbol,var2} where var2<:AbstractArray
                                                end && (##614[1] == :(::) && (begin
                                                            ##615 = ##614[2]
                                                            ##615 isa AbstractArray
                                                        end && (length(##615) === 2 && begin
                                                                ##616 = ##615[1]
                                                                ##617 = ##615[2]
                                                                ##618 = ##611[2]
                                                                true
                                                            end))))))))
                        default = ##618
                        type = ##617
                        name = ##616
                        ##return#606 = begin
                                push!(fields, JLKwField(name, type, field_doc, field_line, default))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#607#627")))
                    end
                    if begin
                                ##619 = (##cache#609).value
                                ##619 isa Tuple{Symbol,var2} where var2<:AbstractArray
                            end && (##619[1] == :(=) && (begin
                                        ##620 = ##619[2]
                                        ##620 isa AbstractArray
                                    end && (length(##620) === 2 && (begin
                                                ##621 = ##620[1]
                                                ##621 isa Symbol
                                            end && begin
                                                ##622 = ##620[2]
                                                true
                                            end))))
                        default = ##622
                        name = ##621
                        ##return#606 = begin
                                push!(fields, JLKwField(name, Any, field_doc, field_line, default))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#607#627")))
                    end
                    if begin
                                ##623 = (##cache#609).value
                                ##623 isa Tuple{Symbol,var2} where var2<:AbstractArray
                            end && (##623[1] == :(::) && (begin
                                        ##624 = ##623[2]
                                        ##624 isa AbstractArray
                                    end && (length(##624) === 2 && begin
                                            ##625 = ##624[1]
                                            ##626 = ##624[2]
                                            true
                                        end)))
                        type = ##626
                        name = ##625
                        ##return#606 = begin
                                push!(fields, JLKwField(name, type, field_doc, field_line, no_default))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#607#627")))
                    end
                end
                if ##608 isa String
                    ##return#606 = begin
                            field_doc = each
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#607#627")))
                end
                if ##608 isa Symbol
                    name = ##608
                    ##return#606 = begin
                            push!(fields, JLKwField(name, Any, field_doc, field_line, no_default))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#607#627")))
                end
                if is_function(##608)
                    ##return#606 = begin
                            if name_only(each) === typename
                                push!(constructors, JLFunction(each))
                            else
                                push!(misc, each)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#607#627")))
                end
                ##return#606 = begin
                        push!(misc, each)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#607#627")))
                (error)("matching non-exhaustive, at #= none:588 =#")
                $(Expr(:symboliclabel, Symbol("####final#607#627")))
                ##return#606
            end
            JLKwStruct(typename, typealias, ismutable, typevars, supertype, fields, constructors, line, doc, misc)
        end
    #= none:614 =# Core.@doc "    JLIfElse(ex::Expr)\n\nCreate a `JLIfElse` from given Julia ifelse `Expr`.\n\n# Example\n\n```julia\njulia> ex = :(if foo(x)\n             x = 1 + 1\n         elseif goo(x)\n             y = 1 + 2\n         else\n             error(\"abc\")\n         end)\n:(if foo(x)\n      #= REPL[41]:2 =#\n      x = 1 + 1\n  elseif #= REPL[41]:3 =# goo(x)\n      #= REPL[41]:4 =#\n      y = 1 + 2\n  else\n      #= REPL[41]:6 =#\n      error(\"abc\")\n  end)\n\njulia> JLIfElse(ex)\nif foo(x)\n    begin\n        #= REPL[41]:2 =#        \n        x = 1 + 1        \n    end\nelseif begin\n    #= REPL[41]:3 =#    \n    goo(x)    \nend\n    begin\n        #= REPL[41]:4 =#        \n        y = 1 + 2        \n    end\nelse\n    begin\n        #= REPL[41]:6 =#        \n        error(\"abc\")        \n    end\nend\n```\n" function JLIfElse(ex::Expr)
            ex.head === :if || error("expect an if ... elseif ... else ... end expression")
            (conds, stmts, otherwise) = split_ifelse(ex)
            return JLIfElse(conds, stmts, otherwise)
        end
    #= none:668 =# Core.@doc "    JLFor(ex::Expr)\n\nCreate a `JLFor` from given Julia for loop expression.\n\n# Example\n\n```julia\njulia> ex = @expr for i in 1:10, j in 1:j\n           M[i, j] += 1\n       end\n:(for i = 1:10, j = 1:j\n      #= REPL[3]:2 =#\n      M[i, j] += 1\n  end)\n\njulia> jl = JLFor(ex)\nfor i in 1 : 10,\n    j in 1 : j\n    #= loop body =#\n    begin\n        #= REPL[3]:2 =#        \n        M[i, j] += 1        \n    end\nend\n\njulia> jl.vars\n2-element Vector{Any}:\n :i\n :j\n\njulia> jl.iterators\n2-element Vector{Any}:\n :(1:10)\n :(1:j)\n```\n" function JLFor(ex::Expr)
            (vars, itrs, body) = split_forloop(ex)
            return JLFor(vars, itrs, body)
        end
end
