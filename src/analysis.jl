begin
    #= none:1 =# Core.@doc "    @expr <expression>\n\nReturn the original expression object.\n\n# Example\n\n```julia\njulia> ex = @expr x + 1\n:(x + 1)\n```\n" macro expr(ex)
            return QuoteNode(ex)
        end
    #= none:17 =# Core.@doc "    @test_expr <type> <ex>\n\nTest if the syntax type generates the same expression `ex`. Returns the\ncorresponding syntax type instance. Requires `using Test` before using\nthis macro.\n\n# Example\n\n```julia\ndef = @test_expr JLFunction function (x, y)\n    return 2\nend\n@test is_kw_fn(def) == false\n```\n" macro test_expr(type, ex)
            #= none:34 =# @gensym def generated_expr original_expr
            quote
                    $def = #= none:36 =# ExproniconLite.@expr($type, $ex)
                    println($def)
                    $generated_expr = ($prettify)(($codegen_ast)($def))
                    $original_expr = ($prettify)($(Expr(:quote, ex)))
                    #= none:40 =# @test ($compare_expr)($generated_expr, $original_expr)
                    $def
                end |> esc
        end
    #= none:45 =# Core.@doc "    @test_expr <expr> == <expr>\n\nTest if two expression is equivalent semantically, this uses `compare_expr`\nto decide if they are equivalent, ignores things such as `LineNumberNode`\ngenerated `Symbol` in `Expr(:curly, ...)` or `Expr(:where, ...)`.\n" macro test_expr(ex::Expr)
            ex.head === :call && ex.args[1] === :(==) || error("expect <expr> == <expr>, got $(ex)")
            (lhs, rhs) = (ex.args[2], ex.args[3])
            quote
                    $__source__
                    #= none:57 =# @test ($compare_expr)(($prettify)($lhs), ($prettify)($rhs))
                end |> esc
        end
    #= none:61 =# Core.@doc "    @expr <type> <expression>\n\nReturn the expression in given type.\n\n# Example\n\n```julia\njulia> ex = @expr JLKwStruct struct Foo{N, T}\n           x::T = 1\n       end\n#= kw =# struct Foo{N, T}\n    #= /home/roger/code/julia/Expronicon/test/analysis.jl:5 =#\n    x::T = 1\nend\n```\n" macro expr(type, ex)
            quote
                    ($type)($(Expr(:quote, ex)))
                end |> esc
        end
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
            var"##259" = (lhs, rhs)
            if var"##259" isa Tuple{Expr, Expr}
                if begin
                            var"##cache#261" = nothing
                            var"##260" = var"##259"[1]
                            var"##260" isa Expr
                        end && (begin
                                if var"##cache#261" === nothing
                                    var"##cache#261" = Some(((var"##260").head, (var"##260").args))
                                end
                                var"##262" = (var"##cache#261").value
                                var"##262" isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (var"##262"[1] == :curly && (begin
                                        var"##263" = var"##262"[2]
                                        var"##263" isa AbstractArray
                                    end && ((ndims(var"##263") === 1 && length(var"##263") >= 1) && (begin
                                                var"##264" = var"##263"[1]
                                                var"##265" = (SubArray)(var"##263", (2:length(var"##263"),))
                                                var"##cache#267" = nothing
                                                var"##266" = var"##259"[2]
                                                var"##266" isa Expr
                                            end && (begin
                                                    if var"##cache#267" === nothing
                                                        var"##cache#267" = Some(((var"##266").head, (var"##266").args))
                                                    end
                                                    var"##268" = (var"##cache#267").value
                                                    var"##268" isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                end && (var"##268"[1] == :curly && (begin
                                                            var"##269" = var"##268"[2]
                                                            var"##269" isa AbstractArray
                                                        end && ((ndims(var"##269") === 1 && length(var"##269") >= 1) && (begin
                                                                    var"##270" = var"##269"[1]
                                                                    let name = var"##264", lhs_vars = var"##265"
                                                                        var"##270" == name
                                                                    end
                                                                end && begin
                                                                    var"##271" = (SubArray)(var"##269", (2:length(var"##269"),))
                                                                    true
                                                                end))))))))))
                    rhs_vars = var"##271"
                    name = var"##264"
                    lhs_vars = var"##265"
                    var"##return#257" = begin
                            all(map(compare_vars, lhs_vars, rhs_vars))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#258#300")))
                end
                if begin
                            var"##cache#273" = nothing
                            var"##272" = var"##259"[1]
                            var"##272" isa Expr
                        end && (begin
                                if var"##cache#273" === nothing
                                    var"##cache#273" = Some(((var"##272").head, (var"##272").args))
                                end
                                var"##274" = (var"##cache#273").value
                                var"##274" isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (var"##274"[1] == :where && (begin
                                        var"##275" = var"##274"[2]
                                        var"##275" isa AbstractArray
                                    end && ((ndims(var"##275") === 1 && length(var"##275") >= 1) && (begin
                                                var"##276" = var"##275"[1]
                                                var"##277" = (SubArray)(var"##275", (2:length(var"##275"),))
                                                var"##cache#279" = nothing
                                                var"##278" = var"##259"[2]
                                                var"##278" isa Expr
                                            end && (begin
                                                    if var"##cache#279" === nothing
                                                        var"##cache#279" = Some(((var"##278").head, (var"##278").args))
                                                    end
                                                    var"##280" = (var"##cache#279").value
                                                    var"##280" isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                end && (var"##280"[1] == :where && (begin
                                                            var"##281" = var"##280"[2]
                                                            var"##281" isa AbstractArray
                                                        end && ((ndims(var"##281") === 1 && length(var"##281") >= 1) && begin
                                                                var"##282" = var"##281"[1]
                                                                var"##283" = (SubArray)(var"##281", (2:length(var"##281"),))
                                                                true
                                                            end)))))))))
                    lbody = var"##276"
                    rbody = var"##282"
                    rparams = var"##283"
                    lparams = var"##277"
                    var"##return#257" = begin
                            compare_expr(lbody, rbody) && all(map(compare_vars, lparams, rparams))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#258#300")))
                end
                if begin
                            var"##cache#285" = nothing
                            var"##284" = var"##259"[1]
                            var"##284" isa Expr
                        end && (begin
                                if var"##cache#285" === nothing
                                    var"##cache#285" = Some(((var"##284").head, (var"##284").args))
                                end
                                var"##286" = (var"##cache#285").value
                                var"##286" isa Tuple{var1, var2} where {var2<:AbstractArray, var1}
                            end && (begin
                                    var"##287" = var"##286"[1]
                                    var"##288" = var"##286"[2]
                                    var"##288" isa AbstractArray
                                end && ((ndims(var"##288") === 1 && length(var"##288") >= 0) && (begin
                                            var"##289" = (SubArray)(var"##288", (1:length(var"##288"),))
                                            var"##cache#291" = nothing
                                            var"##290" = var"##259"[2]
                                            var"##290" isa Expr
                                        end && (begin
                                                if var"##cache#291" === nothing
                                                    var"##cache#291" = Some(((var"##290").head, (var"##290").args))
                                                end
                                                var"##292" = (var"##cache#291").value
                                                var"##292" isa Tuple{var1, var2} where {var2<:AbstractArray, var1}
                                            end && (begin
                                                    var"##293" = var"##292"[1]
                                                    let head = var"##287", largs = var"##289"
                                                        var"##293" == head
                                                    end
                                                end && (begin
                                                        var"##294" = var"##292"[2]
                                                        var"##294" isa AbstractArray
                                                    end && ((ndims(var"##294") === 1 && length(var"##294") >= 0) && begin
                                                            var"##295" = (SubArray)(var"##294", (1:length(var"##294"),))
                                                            true
                                                        end))))))))
                    head = var"##287"
                    largs = var"##289"
                    rargs = var"##295"
                    var"##return#257" = begin
                            isempty(largs) && isempty(rargs) || length(largs) == length(rargs) && all(map(compare_expr, largs, rargs))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#258#300")))
                end
            end
            if var"##259" isa Tuple{Symbol, Symbol}
                if begin
                            var"##296" = var"##259"[1]
                            var"##296" isa Symbol
                        end && begin
                            var"##297" = var"##259"[2]
                            var"##297" isa Symbol
                        end
                    var"##return#257" = begin
                            lhs === rhs
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#258#300")))
                end
            end
            if var"##259" isa Tuple{LineNumberNode, LineNumberNode}
                if begin
                            var"##298" = var"##259"[1]
                            var"##298" isa LineNumberNode
                        end && begin
                            var"##299" = var"##259"[2]
                            var"##299" isa LineNumberNode
                        end
                    var"##return#257" = begin
                            true
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#258#300")))
                end
            end
            var"##return#257" = begin
                    lhs == rhs
                end
            $(Expr(:symbolicgoto, Symbol("####final#258#300")))
            (error)("matching non-exhaustive, at #= none:108 =#")
            $(Expr(:symboliclabel, Symbol("####final#258#300")))
            var"##return#257"
        end
    #= none:127 =# Core.@doc "    compare_vars(lhs, rhs)\n\nCompare two expression by assuming all `Symbol`s are variables,\nthus their value doesn't matter, only where they are matters under\nthis assumption. See also [`compare_expr`](@ref).\n" function compare_vars(lhs, rhs)
            true
            var"##303" = (lhs, rhs)
            if var"##303" isa Tuple{Expr, Expr}
                if begin
                            var"##cache#305" = nothing
                            var"##304" = var"##303"[1]
                            var"##304" isa Expr
                        end && (begin
                                if var"##cache#305" === nothing
                                    var"##cache#305" = Some(((var"##304").head, (var"##304").args))
                                end
                                var"##306" = (var"##cache#305").value
                                var"##306" isa Tuple{var1, var2} where {var2<:AbstractArray, var1}
                            end && (begin
                                    var"##307" = var"##306"[1]
                                    var"##308" = var"##306"[2]
                                    var"##308" isa AbstractArray
                                end && ((ndims(var"##308") === 1 && length(var"##308") >= 0) && (begin
                                            var"##309" = (SubArray)(var"##308", (1:length(var"##308"),))
                                            var"##cache#311" = nothing
                                            var"##310" = var"##303"[2]
                                            var"##310" isa Expr
                                        end && (begin
                                                if var"##cache#311" === nothing
                                                    var"##cache#311" = Some(((var"##310").head, (var"##310").args))
                                                end
                                                var"##312" = (var"##cache#311").value
                                                var"##312" isa Tuple{var1, var2} where {var2<:AbstractArray, var1}
                                            end && (begin
                                                    var"##313" = var"##312"[1]
                                                    let head = var"##307", largs = var"##309"
                                                        var"##313" == head
                                                    end
                                                end && (begin
                                                        var"##314" = var"##312"[2]
                                                        var"##314" isa AbstractArray
                                                    end && ((ndims(var"##314") === 1 && length(var"##314") >= 0) && begin
                                                            var"##315" = (SubArray)(var"##314", (1:length(var"##314"),))
                                                            true
                                                        end))))))))
                    head = var"##307"
                    largs = var"##309"
                    rargs = var"##315"
                    var"##return#301" = begin
                            all(map(compare_vars, largs, rargs))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#302#320")))
                end
            end
            if var"##303" isa Tuple{Symbol, Symbol}
                if begin
                            var"##316" = var"##303"[1]
                            var"##316" isa Symbol
                        end && begin
                            var"##317" = var"##303"[2]
                            var"##317" isa Symbol
                        end
                    var"##return#301" = begin
                            true
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#302#320")))
                end
            end
            if var"##303" isa Tuple{LineNumberNode, LineNumberNode}
                if begin
                            var"##318" = var"##303"[1]
                            var"##318" isa LineNumberNode
                        end && begin
                            var"##319" = var"##303"[2]
                            var"##319" isa LineNumberNode
                        end
                    var"##return#301" = begin
                            true
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#302#320")))
                end
            end
            var"##return#301" = begin
                    lhs == rhs
                end
            $(Expr(:symbolicgoto, Symbol("####final#302#320")))
            (error)("matching non-exhaustive, at #= none:135 =#")
            $(Expr(:symboliclabel, Symbol("####final#302#320")))
            var"##return#301"
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
    #= none:171 =# Core.@doc "    has_kwfn_constructor(def[, name = struct_name_plain(def)])\n\nCheck if the struct definition contains keyword function constructor of `name`.\nThe constructor name to check by default is the plain constructor which does\nnot infer any type variables and requires user to input all type variables.\nSee also [`struct_name_plain`](@ref).\n" function has_kwfn_constructor(def, name = struct_name_plain(def))
            any(def.constructors) do fn::JLFunction
                isempty(fn.args) && fn.name == name
            end
        end
    #= none:185 =# Core.@doc "    has_plain_constructor(def, name = struct_name_plain(def))\n\nCheck if the struct definition contains the plain constructor of `name`.\nBy default the name is the inferable name [`struct_name_plain`](@ref).\n\n# Example\n\n```julia\ndef = @expr JLKwStruct struct Foo{T, N}\n    x::Int\n    y::N\n\n    Foo{T, N}(x, y) where {T, N} = new{T, N}(x, y)\nend\n\nhas_plain_constructor(def) # true\n\ndef = @expr JLKwStruct struct Foo{T, N}\n    x::T\n    y::N\n\n    Foo(x, y) = new{typeof(x), typeof(y)}(x, y)\nend\n\nhas_plain_constructor(def) # false\n```\n\nthe arguments must have no type annotations.\n\n```julia\ndef = @expr JLKwStruct struct Foo{T, N}\n    x::T\n    y::N\n\n    Foo{T, N}(x::T, y::N) where {T, N} = new{T, N}(x, y)\nend\n\nhas_plain_constructor(def) # false\n```\n" function has_plain_constructor(def, name = struct_name_plain(def))
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
                var"##cache#324" = nothing
                var"##return#321" = nothing
                var"##323" = def
                if var"##323" isa Expr
                    if begin
                                if var"##cache#324" === nothing
                                    var"##cache#324" = Some(((var"##323").head, (var"##323").args))
                                end
                                var"##325" = (var"##cache#324").value
                                var"##325" isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (var"##325"[1] == :function && (begin
                                        var"##326" = var"##325"[2]
                                        var"##326" isa AbstractArray
                                    end && length(var"##326") === 2))
                        var"##return#321" = let
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#322#331")))
                    end
                    if begin
                                var"##327" = (var"##cache#324").value
                                var"##327" isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (var"##327"[1] == :(=) && (begin
                                        var"##328" = var"##327"[2]
                                        var"##328" isa AbstractArray
                                    end && length(var"##328") === 2))
                        var"##return#321" = let
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#322#331")))
                    end
                    if begin
                                var"##329" = (var"##cache#324").value
                                var"##329" isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (var"##329"[1] == :-> && (begin
                                        var"##330" = var"##329"[2]
                                        var"##330" isa AbstractArray
                                    end && length(var"##330") === 2))
                        var"##return#321" = let
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#322#331")))
                    end
                end
                if var"##323" isa JLFunction
                    var"##return#321" = let
                            true
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#322#331")))
                end
                var"##return#321" = let
                        false
                    end
                $(Expr(:symbolicgoto, Symbol("####final#322#331")))
                (error)("matching non-exhaustive, at #= none:244 =#")
                $(Expr(:symboliclabel, Symbol("####final#322#331")))
                var"##return#321"
            end
        end
    #= none:253 =# Core.@doc "    is_kw_function(def)\n\nCheck if a given function definition supports keyword arguments.\n" function is_kw_function(#= none:258 =# @nospecialize(def))
            is_function(def) || return false
            if def isa JLFunction
                return def.kwargs !== nothing
            end
            (_, call, _) = split_function(def)
            let
                var"##cache#335" = nothing
                var"##return#332" = nothing
                var"##334" = call
                if var"##334" isa Expr
                    if begin
                                if var"##cache#335" === nothing
                                    var"##cache#335" = Some(((var"##334").head, (var"##334").args))
                                end
                                var"##336" = (var"##cache#335").value
                                var"##336" isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (var"##336"[1] == :tuple && (begin
                                        var"##337" = var"##336"[2]
                                        var"##337" isa AbstractArray
                                    end && ((ndims(var"##337") === 1 && length(var"##337") >= 1) && (begin
                                                var"##cache#339" = nothing
                                                var"##338" = var"##337"[1]
                                                var"##338" isa Expr
                                            end && (begin
                                                    if var"##cache#339" === nothing
                                                        var"##cache#339" = Some(((var"##338").head, (var"##338").args))
                                                    end
                                                    var"##340" = (var"##cache#339").value
                                                    var"##340" isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                end && (var"##340"[1] == :parameters && (begin
                                                            var"##341" = var"##340"[2]
                                                            var"##341" isa AbstractArray
                                                        end && (ndims(var"##341") === 1 && length(var"##341") >= 0))))))))
                        var"##return#332" = let
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#333#351")))
                    end
                    if begin
                                var"##342" = (var"##cache#335").value
                                var"##342" isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (var"##342"[1] == :call && (begin
                                        var"##343" = var"##342"[2]
                                        var"##343" isa AbstractArray
                                    end && ((ndims(var"##343") === 1 && length(var"##343") >= 2) && (begin
                                                var"##cache#345" = nothing
                                                var"##344" = var"##343"[2]
                                                var"##344" isa Expr
                                            end && (begin
                                                    if var"##cache#345" === nothing
                                                        var"##cache#345" = Some(((var"##344").head, (var"##344").args))
                                                    end
                                                    var"##346" = (var"##cache#345").value
                                                    var"##346" isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                end && (var"##346"[1] == :parameters && (begin
                                                            var"##347" = var"##346"[2]
                                                            var"##347" isa AbstractArray
                                                        end && (ndims(var"##347") === 1 && length(var"##347") >= 0))))))))
                        var"##return#332" = let
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#333#351")))
                    end
                    if begin
                                var"##348" = (var"##cache#335").value
                                var"##348" isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (var"##348"[1] == :block && (begin
                                        var"##349" = var"##348"[2]
                                        var"##349" isa AbstractArray
                                    end && (length(var"##349") === 3 && begin
                                            var"##350" = var"##349"[2]
                                            var"##350" isa LineNumberNode
                                        end)))
                        var"##return#332" = let
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#333#351")))
                    end
                end
                var"##return#332" = let
                        false
                    end
                $(Expr(:symbolicgoto, Symbol("####final#333#351")))
                (error)("matching non-exhaustive, at #= none:266 =#")
                $(Expr(:symboliclabel, Symbol("####final#333#351")))
                var"##return#332"
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
                var"##cache#355" = nothing
                var"##return#352" = nothing
                var"##354" = ex
                if var"##354" isa Symbol
                    var"##return#352" = let name = var"##354"
                            true
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#353#373")))
                end
                if var"##354" isa Expr
                    if begin
                                if var"##cache#355" === nothing
                                    var"##cache#355" = Some(((var"##354").head, (var"##354").args))
                                end
                                var"##356" = (var"##cache#355").value
                                var"##356" isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (var"##356"[1] == :(=) && (begin
                                        var"##357" = var"##356"[2]
                                        var"##357" isa AbstractArray
                                    end && (length(var"##357") === 2 && (begin
                                                var"##cache#359" = nothing
                                                var"##358" = var"##357"[1]
                                                var"##358" isa Expr
                                            end && (begin
                                                    if var"##cache#359" === nothing
                                                        var"##cache#359" = Some(((var"##358").head, (var"##358").args))
                                                    end
                                                    var"##360" = (var"##cache#359").value
                                                    var"##360" isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                end && (var"##360"[1] == :(::) && (begin
                                                            var"##361" = var"##360"[2]
                                                            var"##361" isa AbstractArray
                                                        end && (length(var"##361") === 2 && begin
                                                                var"##362" = var"##361"[1]
                                                                var"##363" = var"##361"[2]
                                                                var"##364" = var"##357"[2]
                                                                true
                                                            end))))))))
                        var"##return#352" = let default = var"##364", type = var"##363", name = var"##362"
                                false
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#353#373")))
                    end
                    if begin
                                var"##365" = (var"##cache#355").value
                                var"##365" isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (var"##365"[1] == :(=) && (begin
                                        var"##366" = var"##365"[2]
                                        var"##366" isa AbstractArray
                                    end && (length(var"##366") === 2 && (begin
                                                var"##367" = var"##366"[1]
                                                var"##367" isa Symbol
                                            end && begin
                                                var"##368" = var"##366"[2]
                                                true
                                            end))))
                        var"##return#352" = let default = var"##368", name = var"##367"
                                false
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#353#373")))
                    end
                    if begin
                                var"##369" = (var"##cache#355").value
                                var"##369" isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (var"##369"[1] == :(::) && (begin
                                        var"##370" = var"##369"[2]
                                        var"##370" isa AbstractArray
                                    end && (length(var"##370") === 2 && begin
                                            var"##371" = var"##370"[1]
                                            var"##372" = var"##370"[2]
                                            true
                                        end)))
                        var"##return#352" = let type = var"##372", name = var"##371"
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#353#373")))
                    end
                end
                var"##return#352" = let
                        false
                    end
                $(Expr(:symbolicgoto, Symbol("####final#353#373")))
                (error)("matching non-exhaustive, at #= none:326 =#")
                $(Expr(:symboliclabel, Symbol("####final#353#373")))
                var"##return#352"
            end
        end
    #= none:335 =# Core.@doc "    is_field_default(ex)\n\nCheck if `ex` is a `<field expr> = <default expr>` expression.\n" function is_field_default(#= none:340 =# @nospecialize(ex))
            let
                var"##cache#377" = nothing
                var"##return#374" = nothing
                var"##376" = ex
                if var"##376" isa Expr
                    if begin
                                if var"##cache#377" === nothing
                                    var"##cache#377" = Some(((var"##376").head, (var"##376").args))
                                end
                                var"##378" = (var"##cache#377").value
                                var"##378" isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (var"##378"[1] == :(=) && (begin
                                        var"##379" = var"##378"[2]
                                        var"##379" isa AbstractArray
                                    end && (length(var"##379") === 2 && (begin
                                                var"##cache#381" = nothing
                                                var"##380" = var"##379"[1]
                                                var"##380" isa Expr
                                            end && (begin
                                                    if var"##cache#381" === nothing
                                                        var"##cache#381" = Some(((var"##380").head, (var"##380").args))
                                                    end
                                                    var"##382" = (var"##cache#381").value
                                                    var"##382" isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                end && (var"##382"[1] == :(::) && (begin
                                                            var"##383" = var"##382"[2]
                                                            var"##383" isa AbstractArray
                                                        end && (length(var"##383") === 2 && begin
                                                                var"##384" = var"##383"[1]
                                                                var"##385" = var"##383"[2]
                                                                var"##386" = var"##379"[2]
                                                                true
                                                            end))))))))
                        var"##return#374" = let default = var"##386", type = var"##385", name = var"##384"
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#375#391")))
                    end
                    if begin
                                var"##387" = (var"##cache#377").value
                                var"##387" isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (var"##387"[1] == :(=) && (begin
                                        var"##388" = var"##387"[2]
                                        var"##388" isa AbstractArray
                                    end && (length(var"##388") === 2 && (begin
                                                var"##389" = var"##388"[1]
                                                var"##389" isa Symbol
                                            end && begin
                                                var"##390" = var"##388"[2]
                                                true
                                            end))))
                        var"##return#374" = let default = var"##390", name = var"##389"
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#375#391")))
                    end
                end
                var"##return#374" = let
                        false
                    end
                $(Expr(:symbolicgoto, Symbol("####final#375#391")))
                (error)("matching non-exhaustive, at #= none:341 =#")
                $(Expr(:symboliclabel, Symbol("####final#375#391")))
                var"##return#374"
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
                var"##cache#395" = nothing
                var"##return#392" = nothing
                var"##394" = ex
                if var"##394" isa Expr
                    if begin
                                if var"##cache#395" === nothing
                                    var"##cache#395" = Some(((var"##394").head, (var"##394").args))
                                end
                                var"##396" = (var"##cache#395").value
                                var"##396" isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (var"##396"[1] == :function && (begin
                                        var"##397" = var"##396"[2]
                                        var"##397" isa AbstractArray
                                    end && (length(var"##397") === 2 && begin
                                            var"##398" = var"##397"[1]
                                            var"##399" = var"##397"[2]
                                            true
                                        end)))
                        var"##return#392" = let call = var"##398", body = var"##399"
                                (:function, call, body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#393#408")))
                    end
                    if begin
                                var"##400" = (var"##cache#395").value
                                var"##400" isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (var"##400"[1] == :(=) && (begin
                                        var"##401" = var"##400"[2]
                                        var"##401" isa AbstractArray
                                    end && (length(var"##401") === 2 && begin
                                            var"##402" = var"##401"[1]
                                            var"##403" = var"##401"[2]
                                            true
                                        end)))
                        var"##return#392" = let call = var"##402", body = var"##403"
                                (:(=), call, body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#393#408")))
                    end
                    if begin
                                var"##404" = (var"##cache#395").value
                                var"##404" isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (var"##404"[1] == :-> && (begin
                                        var"##405" = var"##404"[2]
                                        var"##405" isa AbstractArray
                                    end && (length(var"##405") === 2 && begin
                                            var"##406" = var"##405"[1]
                                            var"##407" = var"##405"[2]
                                            true
                                        end)))
                        var"##return#392" = let call = var"##406", body = var"##407"
                                (:->, call, body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#393#408")))
                    end
                end
                var"##return#392" = let
                        anlys_error("function", ex)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#393#408")))
                (error)("matching non-exhaustive, at #= none:367 =#")
                $(Expr(:symboliclabel, Symbol("####final#393#408")))
                var"##return#392"
            end
        end
    #= none:375 =# Core.@doc "    split_function_head(ex::Expr) -> name, args, kw, whereparams, rettype\n\nSplit function head to name, arguments, keyword arguments and where parameters.\n" function split_function_head(ex::Expr)
            let
                var"##cache#412" = nothing
                var"##return#409" = nothing
                var"##411" = ex
                if var"##411" isa Expr
                    if begin
                                if var"##cache#412" === nothing
                                    var"##cache#412" = Some(((var"##411").head, (var"##411").args))
                                end
                                var"##413" = (var"##cache#412").value
                                var"##413" isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (var"##413"[1] == :tuple && (begin
                                        var"##414" = var"##413"[2]
                                        var"##414" isa AbstractArray
                                    end && ((ndims(var"##414") === 1 && length(var"##414") >= 1) && (begin
                                                var"##cache#416" = nothing
                                                var"##415" = var"##414"[1]
                                                var"##415" isa Expr
                                            end && (begin
                                                    if var"##cache#416" === nothing
                                                        var"##cache#416" = Some(((var"##415").head, (var"##415").args))
                                                    end
                                                    var"##417" = (var"##cache#416").value
                                                    var"##417" isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                end && (var"##417"[1] == :parameters && (begin
                                                            var"##418" = var"##417"[2]
                                                            var"##418" isa AbstractArray
                                                        end && ((ndims(var"##418") === 1 && length(var"##418") >= 0) && begin
                                                                var"##419" = (SubArray)(var"##418", (1:length(var"##418"),))
                                                                var"##420" = (SubArray)(var"##414", (2:length(var"##414"),))
                                                                true
                                                            end))))))))
                        var"##return#409" = let args = var"##420", kw = var"##419"
                                (nothing, args, kw, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#410#460")))
                    end
                    if begin
                                var"##421" = (var"##cache#412").value
                                var"##421" isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (var"##421"[1] == :tuple && (begin
                                        var"##422" = var"##421"[2]
                                        var"##422" isa AbstractArray
                                    end && ((ndims(var"##422") === 1 && length(var"##422") >= 0) && begin
                                            var"##423" = (SubArray)(var"##422", (1:length(var"##422"),))
                                            true
                                        end)))
                        var"##return#409" = let args = var"##423"
                                (nothing, args, nothing, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#410#460")))
                    end
                    if begin
                                var"##424" = (var"##cache#412").value
                                var"##424" isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (var"##424"[1] == :call && (begin
                                        var"##425" = var"##424"[2]
                                        var"##425" isa AbstractArray
                                    end && ((ndims(var"##425") === 1 && length(var"##425") >= 2) && (begin
                                                var"##426" = var"##425"[1]
                                                var"##cache#428" = nothing
                                                var"##427" = var"##425"[2]
                                                var"##427" isa Expr
                                            end && (begin
                                                    if var"##cache#428" === nothing
                                                        var"##cache#428" = Some(((var"##427").head, (var"##427").args))
                                                    end
                                                    var"##429" = (var"##cache#428").value
                                                    var"##429" isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                end && (var"##429"[1] == :parameters && (begin
                                                            var"##430" = var"##429"[2]
                                                            var"##430" isa AbstractArray
                                                        end && ((ndims(var"##430") === 1 && length(var"##430") >= 0) && begin
                                                                var"##431" = (SubArray)(var"##430", (1:length(var"##430"),))
                                                                var"##432" = (SubArray)(var"##425", (3:length(var"##425"),))
                                                                true
                                                            end))))))))
                        var"##return#409" = let name = var"##426", args = var"##432", kw = var"##431"
                                (name, args, kw, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#410#460")))
                    end
                    if begin
                                var"##433" = (var"##cache#412").value
                                var"##433" isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (var"##433"[1] == :call && (begin
                                        var"##434" = var"##433"[2]
                                        var"##434" isa AbstractArray
                                    end && ((ndims(var"##434") === 1 && length(var"##434") >= 1) && begin
                                            var"##435" = var"##434"[1]
                                            var"##436" = (SubArray)(var"##434", (2:length(var"##434"),))
                                            true
                                        end)))
                        var"##return#409" = let name = var"##435", args = var"##436"
                                (name, args, nothing, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#410#460")))
                    end
                    if begin
                                var"##437" = (var"##cache#412").value
                                var"##437" isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (var"##437"[1] == :block && (begin
                                        var"##438" = var"##437"[2]
                                        var"##438" isa AbstractArray
                                    end && (length(var"##438") === 3 && (begin
                                                var"##439" = var"##438"[1]
                                                var"##440" = var"##438"[2]
                                                var"##440" isa LineNumberNode
                                            end && (begin
                                                    var"##cache#442" = nothing
                                                    var"##441" = var"##438"[3]
                                                    var"##441" isa Expr
                                                end && (begin
                                                        if var"##cache#442" === nothing
                                                            var"##cache#442" = Some(((var"##441").head, (var"##441").args))
                                                        end
                                                        var"##443" = (var"##cache#442").value
                                                        var"##443" isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                    end && (var"##443"[1] == :(=) && (begin
                                                                var"##444" = var"##443"[2]
                                                                var"##444" isa AbstractArray
                                                            end && (length(var"##444") === 2 && begin
                                                                    var"##445" = var"##444"[1]
                                                                    var"##446" = var"##444"[2]
                                                                    true
                                                                end)))))))))
                        var"##return#409" = let value = var"##446", kw = var"##445", x = var"##439"
                                (nothing, Any[x], Any[Expr(:kw, kw, value)], nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#410#460")))
                    end
                    if begin
                                var"##447" = (var"##cache#412").value
                                var"##447" isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (var"##447"[1] == :block && (begin
                                        var"##448" = var"##447"[2]
                                        var"##448" isa AbstractArray
                                    end && (length(var"##448") === 3 && (begin
                                                var"##449" = var"##448"[1]
                                                var"##450" = var"##448"[2]
                                                var"##450" isa LineNumberNode
                                            end && begin
                                                var"##451" = var"##448"[3]
                                                true
                                            end))))
                        var"##return#409" = let kw = var"##451", x = var"##449"
                                (nothing, Any[x], Any[kw], nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#410#460")))
                    end
                    if begin
                                var"##452" = (var"##cache#412").value
                                var"##452" isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (var"##452"[1] == :(::) && (begin
                                        var"##453" = var"##452"[2]
                                        var"##453" isa AbstractArray
                                    end && (length(var"##453") === 2 && begin
                                            var"##454" = var"##453"[1]
                                            var"##455" = var"##453"[2]
                                            true
                                        end)))
                        var"##return#409" = let call = var"##454", rettype = var"##455"
                                (name, args, kw, whereparams, _) = split_function_head(call)
                                (name, args, kw, whereparams, rettype)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#410#460")))
                    end
                    if begin
                                var"##456" = (var"##cache#412").value
                                var"##456" isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (var"##456"[1] == :where && (begin
                                        var"##457" = var"##456"[2]
                                        var"##457" isa AbstractArray
                                    end && ((ndims(var"##457") === 1 && length(var"##457") >= 1) && begin
                                            var"##458" = var"##457"[1]
                                            var"##459" = (SubArray)(var"##457", (2:length(var"##457"),))
                                            true
                                        end)))
                        var"##return#409" = let call = var"##458", whereparams = var"##459"
                                (name, args, kw, _, rettype) = split_function_head(call)
                                (name, args, kw, whereparams, rettype)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#410#460")))
                    end
                end
                var"##return#409" = let
                        anlys_error("function head expr", ex)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#410#460")))
                (error)("matching non-exhaustive, at #= none:381 =#")
                $(Expr(:symboliclabel, Symbol("####final#410#460")))
                var"##return#409"
            end
        end
    #= none:400 =# Core.@doc "    split_struct_name(ex::Expr) -> name, typevars, supertype\n\nSplit the name, type parameters and supertype definition from `struct`\ndeclaration head.\n" function split_struct_name(#= none:406 =# @nospecialize(ex))
            return let
                    var"##cache#464" = nothing
                    var"##return#461" = nothing
                    var"##463" = ex
                    if var"##463" isa Symbol
                        var"##return#461" = let
                                (ex, [], nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#462#482")))
                    end
                    if var"##463" isa Expr
                        if begin
                                    if var"##cache#464" === nothing
                                        var"##cache#464" = Some(((var"##463").head, (var"##463").args))
                                    end
                                    var"##465" = (var"##cache#464").value
                                    var"##465" isa Tuple{Symbol, var2} where var2<:AbstractArray
                                end && (var"##465"[1] == :curly && (begin
                                            var"##466" = var"##465"[2]
                                            var"##466" isa AbstractArray
                                        end && ((ndims(var"##466") === 1 && length(var"##466") >= 1) && begin
                                                var"##467" = var"##466"[1]
                                                var"##468" = (SubArray)(var"##466", (2:length(var"##466"),))
                                                true
                                            end)))
                            var"##return#461" = let typevars = var"##468", name = var"##467"
                                    (name, typevars, nothing)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#462#482")))
                        end
                        if begin
                                    var"##469" = (var"##cache#464").value
                                    var"##469" isa Tuple{Symbol, var2} where var2<:AbstractArray
                                end && (var"##469"[1] == :<: && (begin
                                            var"##470" = var"##469"[2]
                                            var"##470" isa AbstractArray
                                        end && (length(var"##470") === 2 && (begin
                                                    var"##cache#472" = nothing
                                                    var"##471" = var"##470"[1]
                                                    var"##471" isa Expr
                                                end && (begin
                                                        if var"##cache#472" === nothing
                                                            var"##cache#472" = Some(((var"##471").head, (var"##471").args))
                                                        end
                                                        var"##473" = (var"##cache#472").value
                                                        var"##473" isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                    end && (var"##473"[1] == :curly && (begin
                                                                var"##474" = var"##473"[2]
                                                                var"##474" isa AbstractArray
                                                            end && ((ndims(var"##474") === 1 && length(var"##474") >= 1) && begin
                                                                    var"##475" = var"##474"[1]
                                                                    var"##476" = (SubArray)(var"##474", (2:length(var"##474"),))
                                                                    var"##477" = var"##470"[2]
                                                                    true
                                                                end))))))))
                            var"##return#461" = let typevars = var"##476", type = var"##477", name = var"##475"
                                    (name, typevars, type)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#462#482")))
                        end
                        if begin
                                    var"##478" = (var"##cache#464").value
                                    var"##478" isa Tuple{Symbol, var2} where var2<:AbstractArray
                                end && (var"##478"[1] == :<: && (begin
                                            var"##479" = var"##478"[2]
                                            var"##479" isa AbstractArray
                                        end && (length(var"##479") === 2 && begin
                                                var"##480" = var"##479"[1]
                                                var"##481" = var"##479"[2]
                                                true
                                            end)))
                            var"##return#461" = let type = var"##481", name = var"##480"
                                    (name, [], type)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#462#482")))
                        end
                    end
                    var"##return#461" = let
                            anlys_error("struct", ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#462#482")))
                    (error)("matching non-exhaustive, at #= none:407 =#")
                    $(Expr(:symboliclabel, Symbol("####final#462#482")))
                    var"##return#461"
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
    function uninferrable_typevars(def::Union{JLStruct, JLKwStruct}; leading_inferable::Bool = true)
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
                var"##cache#486" = nothing
                var"##485" = each
                if var"##485" isa Symbol
                    name = var"##485"
                    var"##return#483" = begin
                            push!(fields, JLField(name, Any, field_doc, field_line))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#484#491")))
                end
                if var"##485" isa Expr
                    if begin
                                if var"##cache#486" === nothing
                                    var"##cache#486" = Some(((var"##485").head, (var"##485").args))
                                end
                                var"##487" = (var"##cache#486").value
                                var"##487" isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (var"##487"[1] == :(::) && (begin
                                        var"##488" = var"##487"[2]
                                        var"##488" isa AbstractArray
                                    end && (length(var"##488") === 2 && begin
                                            var"##489" = var"##488"[1]
                                            var"##490" = var"##488"[2]
                                            true
                                        end)))
                        type = var"##490"
                        name = var"##489"
                        var"##return#483" = begin
                                push!(fields, JLField(name, type, field_doc, field_line))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#484#491")))
                    end
                end
                if var"##485" isa LineNumberNode
                    var"##return#483" = begin
                            field_line = each
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#484#491")))
                end
                if var"##485" isa String
                    var"##return#483" = begin
                            field_doc = each
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#484#491")))
                end
                if is_function(var"##485")
                    var"##return#483" = begin
                            if name_only(each) === typename
                                push!(constructors, JLFunction(each))
                            else
                                push!(misc, each)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#484#491")))
                end
                var"##return#483" = begin
                        push!(misc, each)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#484#491")))
                (error)("matching non-exhaustive, at #= none:540 =#")
                $(Expr(:symboliclabel, Symbol("####final#484#491")))
                var"##return#483"
            end
            JLStruct(typename, ismutable, typevars, supertype, fields, constructors, line, doc, misc)
        end
    #= none:562 =# Core.@doc "    JLKwStruct(ex::Expr, typealias=nothing)\n\nCreate a `JLKwStruct` from given Julia struct `Expr`, with an option to attach\nan alias to this type name.\n\n# Example\n\n```julia\njulia> JLKwStruct(:(struct Foo\n           x::Int = 1\n       end))\n#= kw =# struct Foo\n    #= REPL[39]:2 =#\n    x::Int = 1\nend\n```\n" function JLKwStruct(ex::Expr, typealias = nothing)
            (line, doc, expr) = split_doc(ex)
            (ismutable, typename, typevars, supertype, body) = split_struct(expr)
            (fields, constructors, misc) = (JLKwField[], JLFunction[], [])
            (field_doc, field_line) = (nothing, nothing)
            for each = body.args
                var"##cache#495" = nothing
                var"##494" = each
                if var"##494" isa Symbol
                    name = var"##494"
                    var"##return#492" = begin
                            push!(fields, JLKwField(name, Any, field_doc, field_line, no_default))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#493#513")))
                end
                if var"##494" isa Expr
                    if begin
                                if var"##cache#495" === nothing
                                    var"##cache#495" = Some(((var"##494").head, (var"##494").args))
                                end
                                var"##496" = (var"##cache#495").value
                                var"##496" isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (var"##496"[1] == :(=) && (begin
                                        var"##497" = var"##496"[2]
                                        var"##497" isa AbstractArray
                                    end && (length(var"##497") === 2 && (begin
                                                var"##cache#499" = nothing
                                                var"##498" = var"##497"[1]
                                                var"##498" isa Expr
                                            end && (begin
                                                    if var"##cache#499" === nothing
                                                        var"##cache#499" = Some(((var"##498").head, (var"##498").args))
                                                    end
                                                    var"##500" = (var"##cache#499").value
                                                    var"##500" isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                end && (var"##500"[1] == :(::) && (begin
                                                            var"##501" = var"##500"[2]
                                                            var"##501" isa AbstractArray
                                                        end && (length(var"##501") === 2 && begin
                                                                var"##502" = var"##501"[1]
                                                                var"##503" = var"##501"[2]
                                                                var"##504" = var"##497"[2]
                                                                true
                                                            end))))))))
                        default = var"##504"
                        type = var"##503"
                        name = var"##502"
                        var"##return#492" = begin
                                push!(fields, JLKwField(name, type, field_doc, field_line, default))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#493#513")))
                    end
                    if begin
                                var"##505" = (var"##cache#495").value
                                var"##505" isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (var"##505"[1] == :(=) && (begin
                                        var"##506" = var"##505"[2]
                                        var"##506" isa AbstractArray
                                    end && (length(var"##506") === 2 && (begin
                                                var"##507" = var"##506"[1]
                                                var"##507" isa Symbol
                                            end && begin
                                                var"##508" = var"##506"[2]
                                                true
                                            end))))
                        default = var"##508"
                        name = var"##507"
                        var"##return#492" = begin
                                push!(fields, JLKwField(name, Any, field_doc, field_line, default))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#493#513")))
                    end
                    if begin
                                var"##509" = (var"##cache#495").value
                                var"##509" isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (var"##509"[1] == :(::) && (begin
                                        var"##510" = var"##509"[2]
                                        var"##510" isa AbstractArray
                                    end && (length(var"##510") === 2 && begin
                                            var"##511" = var"##510"[1]
                                            var"##512" = var"##510"[2]
                                            true
                                        end)))
                        type = var"##512"
                        name = var"##511"
                        var"##return#492" = begin
                                push!(fields, JLKwField(name, type, field_doc, field_line, no_default))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#493#513")))
                    end
                end
                if var"##494" isa LineNumberNode
                    var"##return#492" = begin
                            field_line = each
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#493#513")))
                end
                if var"##494" isa String
                    var"##return#492" = begin
                            field_doc = each
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#493#513")))
                end
                if is_function(var"##494")
                    var"##return#492" = begin
                            if name_only(each) === typename
                                push!(constructors, JLFunction(each))
                            else
                                push!(misc, each)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#493#513")))
                end
                var"##return#492" = begin
                        push!(misc, each)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#493#513")))
                (error)("matching non-exhaustive, at #= none:588 =#")
                $(Expr(:symboliclabel, Symbol("####final#493#513")))
                var"##return#492"
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
