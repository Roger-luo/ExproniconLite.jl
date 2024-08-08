
    #= none:2 =# Core.@doc "    eval_interp(m::Module, ex)\n\nevaluate the interpolation operator in `ex` inside given module `m`.\n" function eval_interp(m::Module, ex)
            ex isa Expr || return ex
            if ex.head === :$
                x = ex.args[1]
                if x isa Symbol && isdefined(m, x)
                    return Base.eval(m, x)
                else
                    return ex
                end
            end
            return Expr(ex.head, map((x->begin
                                eval_interp(m, x)
                            end), ex.args)...)
        end
    #= none:20 =# Core.@doc "    eval_literal(m::Module, ex)\n\nEvaluate the literal values and insert them back to the expression.\nThe literal value can be checked via [`is_literal`](@ref).\n" function eval_literal(m::Module, ex)
            ex isa Expr || return ex
            if ex.head === :call && all(is_literal, ex.args[2:end])
                return Base.eval(m, ex)
            end
            return Expr(ex.head, map((x->begin
                                eval_literal(m, x)
                            end), ex.args)...)
        end
    #= none:34 =# Core.@doc "    substitute(ex::Expr, old=>new)\n\nSubstitute the old symbol `old` with `new`.\n" function substitute(ex::Expr, replace::Pair)
            (old, new) = replace
            sub = Substitute() do x
                    x == old
                end
            return sub((_->begin
                            new
                        end), ex)
        end
    #= none:47 =# Core.@doc "    name_only(ex)\n\nRemove everything else leaving just names, currently supports\nfunction calls, type with type variables, subtype operator `<:`\nand type annotation `::`.\n\n# Example\n\n```julia\njulia> using Expronicon\n\njulia> name_only(:(sin(2)))\n:sin\n\njulia> name_only(:(Foo{Int}))\n:Foo\n\njulia> name_only(:(Foo{Int} <: Real))\n:Foo\n\njulia> name_only(:(x::Int))\n:x\n```\n" function name_only(#= none:72 =# @nospecialize(ex))
            ex isa Symbol && return ex
            ex isa QuoteNode && return ex.value
            ex isa Expr || error("unsupported expression $(ex)")
            ex.head in [:call, :curly, :<:, :(::), :where, :function, :kw, :(=), :->] && return name_only(ex.args[1])
            ex.head === :. && return name_only(ex.args[2])
            ex.head === :... && return name_only(ex.args[1])
            ex.head === :module && return name_only(ex.args[2])
            error("unsupported expression $(ex)")
        end
    #= none:83 =# Core.@doc "    annotations_only(ex)\n\nReturn type annotations only. See also [`name_only`](@ref).\n" function annotations_only(#= none:88 =# @nospecialize(ex))
            ex isa Symbol && return :(())
            ex isa Expr || error("unsupported expression $(ex)")
            Meta.isexpr(ex, :...) && return annotations_only(ex.args[1])
            Meta.isexpr(ex, :(::)) && return ex.args[end]
            error("unsupported expression $(ex)")
        end
    #= none:96 =# Core.@doc "    rm_lineinfo(ex)\n\nRemove `LineNumberNode` in a given expression.\n\n!!! tips\n\n    the `LineNumberNode` inside macro calls won't be removed since\n    the `macrocall` expression requires a `LineNumberNode`. See also\n    [issues/#9](https://github.com/Roger-luo/Expronicon.jl/issues/9).\n" function rm_lineinfo(ex)
            let
                begin
                    var"##cache#1391" = nothing
                end
                var"##return#1388" = nothing
                var"##1390" = ex
                if var"##1390" isa Expr
                    if begin
                                if var"##cache#1391" === nothing
                                    var"##cache#1391" = Some(((var"##1390").head, (var"##1390").args))
                                end
                                var"##1392" = (var"##cache#1391").value
                                var"##1392" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1392"[1] == :macrocall && (begin
                                        var"##1393" = var"##1392"[2]
                                        var"##1393" isa AbstractArray
                                    end && ((ndims(var"##1393") === 1 && length(var"##1393") >= 2) && begin
                                            var"##1394" = var"##1393"[1]
                                            var"##1395" = var"##1393"[2]
                                            var"##1396" = SubArray(var"##1393", (3:length(var"##1393"),))
                                            true
                                        end)))
                        var"##return#1388" = let line = var"##1395", name = var"##1394", args = var"##1396"
                                Expr(:macrocall, name, line, map(rm_lineinfo, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1389#1401")))
                    end
                    if begin
                                var"##1397" = (var"##cache#1391").value
                                var"##1397" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1398" = var"##1397"[1]
                                    var"##1399" = var"##1397"[2]
                                    var"##1399" isa AbstractArray
                                end && ((ndims(var"##1399") === 1 && length(var"##1399") >= 0) && begin
                                        var"##1400" = SubArray(var"##1399", (1:length(var"##1399"),))
                                        true
                                    end))
                        var"##return#1388" = let args = var"##1400", head = var"##1398"
                                Expr(head, map(rm_lineinfo, filter((x->begin
                                                    !(x isa LineNumberNode)
                                                end), args))...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1389#1401")))
                    end
                end
                begin
                    var"##return#1388" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1389#1401")))
                end
                error("matching non-exhaustive, at #= none:108 =#")
                $(Expr(:symboliclabel, Symbol("####final#1389#1401")))
                var"##return#1388"
            end
        end
    #= none:115 =# Base.@kwdef struct PrettifyOptions
            rm_lineinfo::Bool = true
            flatten_blocks::Bool = true
            rm_nothing::Bool = true
            preserve_last_nothing::Bool = false
            rm_single_block::Bool = true
            alias_gensym::Bool = true
            renumber_gensym::Bool = true
        end
    #= none:125 =# Core.@doc "    prettify(ex; kw...)\n\nPrettify given expression, remove all `LineNumberNode` and\nextra code blocks.\n\n# Options (Kwargs)\n\nAll the options are `true` by default.\n\n- `rm_lineinfo`: remove `LineNumberNode`.\n- `flatten_blocks`: flatten `begin ... end` code blocks.\n- `rm_nothing`: remove `nothing` in the `begin ... end`.\n- `preserve_last_nothing`: preserve the last `nothing` in the `begin ... end`.\n- `rm_single_block`: remove single `begin ... end`.\n- `alias_gensym`: replace `##<name>#<num>` with `<name>_<id>`.\n- `renumber_gensym`: renumber the gensym id.\n\n!!! tips\n\n    the `LineNumberNode` inside macro calls won't be removed since\n    the `macrocall` expression requires a `LineNumberNode`. See also\n    [issues/#9](https://github.com/Roger-luo/Expronicon.jl/issues/9).\n" function prettify(ex; kw...)
            prettify(ex, PrettifyOptions(; kw...))
        end
    function prettify(ex, options::PrettifyOptions)
        ex isa Expr || return ex
        ex = if options.renumber_gensym
                renumber_gensym(ex)
            else
                ex
            end
        ex = if options.alias_gensym
                alias_gensym(ex)
            else
                ex
            end
        for _ = 1:10
            curr = prettify_pass(ex, options)
            ex == curr && break
            ex = curr
        end
        return ex
    end
    function prettify_pass(ex, options::PrettifyOptions)
        ex = if options.rm_lineinfo
                rm_lineinfo(ex)
            else
                ex
            end
        ex = if options.flatten_blocks
                flatten_blocks(ex)
            else
                ex
            end
        ex = if options.rm_nothing
                rm_nothing(ex; options.preserve_last_nothing)
            else
                ex
            end
        ex = if options.rm_single_block
                rm_single_block(ex)
            else
                ex
            end
        return ex
    end
    #= none:173 =# Core.@doc "    flatten_blocks(ex)\n\nRemove hierachical expression blocks.\n" function flatten_blocks(ex)
            ex isa Expr || return ex
            ex.head === :block || return Expr(ex.head, map(_flatten_blocks, ex.args)...)
            has_block = any(ex.args) do x
                    x isa Expr && x.head === :block
                end
            if has_block
                return flatten_blocks(_flatten_blocks(ex))
            end
            return Expr(ex.head, map(flatten_blocks, ex.args)...)
        end
    function _flatten_blocks(ex)
        ex isa Expr || return ex
        ex.head === :block || return Expr(ex.head, map(flatten_blocks, ex.args)...)
        args = []
        for stmt = ex.args
            if stmt isa Expr && stmt.head === :block
                for each = stmt.args
                    push!(args, flatten_blocks(each))
                end
            else
                push!(args, flatten_blocks(stmt))
            end
        end
        return Expr(:block, args...)
    end
    #= none:208 =# Core.@doc "    rm_nothing(ex)\n\nRemove the constant value `nothing` in given expression `ex`.\n\n# Keyword Arguments\n\n- `preserve_last_nothing`: if `true`, the last `nothing`\n    will be preserved.\n" function rm_nothing(ex; preserve_last_nothing::Bool = false)
            let
                begin
                    var"##cache#1405" = nothing
                end
                var"##return#1402" = nothing
                var"##1404" = ex
                if var"##1404" isa Expr
                    if begin
                                if var"##cache#1405" === nothing
                                    var"##cache#1405" = Some(((var"##1404").head, (var"##1404").args))
                                end
                                var"##1406" = (var"##cache#1405").value
                                var"##1406" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1406"[1] == :block && (begin
                                        var"##1407" = var"##1406"[2]
                                        var"##1407" isa AbstractArray
                                    end && ((ndims(var"##1407") === 1 && length(var"##1407") >= 0) && begin
                                            var"##1408" = SubArray(var"##1407", (1:length(var"##1407"),))
                                            true
                                        end)))
                        var"##return#1402" = let args = var"##1408"
                                if preserve_last_nothing && (!(isempty(args)) && isnothing(last(args)))
                                    Expr(:block, filter((x->begin
                                                    x !== nothing
                                                end), args)..., nothing)
                                else
                                    Expr(:block, filter((x->begin
                                                    x !== nothing
                                                end), args)...)
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1403#1413")))
                    end
                    if begin
                                var"##1409" = (var"##cache#1405").value
                                var"##1409" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1410" = var"##1409"[1]
                                    var"##1411" = var"##1409"[2]
                                    var"##1411" isa AbstractArray
                                end && ((ndims(var"##1411") === 1 && length(var"##1411") >= 0) && begin
                                        var"##1412" = SubArray(var"##1411", (1:length(var"##1411"),))
                                        true
                                    end))
                        var"##return#1402" = let args = var"##1412", head = var"##1410"
                                Expr(head, map(rm_nothing, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1403#1413")))
                    end
                end
                begin
                    var"##return#1402" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1403#1413")))
                end
                error("matching non-exhaustive, at #= none:219 =#")
                $(Expr(:symboliclabel, Symbol("####final#1403#1413")))
                var"##return#1402"
            end
        end
    #= none:232 =# Core.@doc "    canonicalize_lambda_head(ex)\n\nCanonicalize the `Expr(:function, Expr(:block, x, Expr(:(=), key, default)), body)` to\n\n```julia\nExpr(:function, Expr(:tuple, Expr(:parameters, Expr(:kw, key, default)), x), body)\n```\n" function canonicalize_lambda_head(ex)
            let
                begin
                    var"##cache#1417" = nothing
                end
                var"##return#1414" = nothing
                var"##1416" = ex
                if var"##1416" isa Expr
                    if begin
                                if var"##cache#1417" === nothing
                                    var"##cache#1417" = Some(((var"##1416").head, (var"##1416").args))
                                end
                                var"##1418" = (var"##cache#1417").value
                                var"##1418" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1418"[1] == :function && (begin
                                        var"##1419" = var"##1418"[2]
                                        var"##1419" isa AbstractArray
                                    end && (length(var"##1419") === 2 && (begin
                                                begin
                                                    var"##cache#1421" = nothing
                                                end
                                                var"##1420" = var"##1419"[1]
                                                var"##1420" isa Expr
                                            end && (begin
                                                    if var"##cache#1421" === nothing
                                                        var"##cache#1421" = Some(((var"##1420").head, (var"##1420").args))
                                                    end
                                                    var"##1422" = (var"##cache#1421").value
                                                    var"##1422" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1422"[1] == :block && (begin
                                                            var"##1423" = var"##1422"[2]
                                                            var"##1423" isa AbstractArray
                                                        end && (length(var"##1423") === 2 && begin
                                                                var"##1424" = var"##1423"[1]
                                                                var"##1425" = var"##1423"[2]
                                                                var"##1426" = var"##1419"[2]
                                                                true
                                                            end))))))))
                        var"##return#1414" = let y = var"##1425", body = var"##1426", x = var"##1424"
                                Expr(:function, Expr(:tuple, Expr(:parameters, y), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1415#1470")))
                    end
                    if begin
                                var"##1427" = (var"##cache#1417").value
                                var"##1427" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1427"[1] == :function && (begin
                                        var"##1428" = var"##1427"[2]
                                        var"##1428" isa AbstractArray
                                    end && (length(var"##1428") === 2 && (begin
                                                begin
                                                    var"##cache#1430" = nothing
                                                end
                                                var"##1429" = var"##1428"[1]
                                                var"##1429" isa Expr
                                            end && (begin
                                                    if var"##cache#1430" === nothing
                                                        var"##cache#1430" = Some(((var"##1429").head, (var"##1429").args))
                                                    end
                                                    var"##1431" = (var"##cache#1430").value
                                                    var"##1431" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1431"[1] == :block && (begin
                                                            var"##1432" = var"##1431"[2]
                                                            var"##1432" isa AbstractArray
                                                        end && (length(var"##1432") === 3 && (begin
                                                                    var"##1433" = var"##1432"[1]
                                                                    var"##1434" = var"##1432"[2]
                                                                    var"##1434" isa LineNumberNode
                                                                end && begin
                                                                    var"##1435" = var"##1432"[3]
                                                                    var"##1436" = var"##1428"[2]
                                                                    true
                                                                end)))))))))
                        var"##return#1414" = let y = var"##1435", body = var"##1436", x = var"##1433"
                                Expr(:function, Expr(:tuple, Expr(:parameters, y), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1415#1470")))
                    end
                    if begin
                                var"##1437" = (var"##cache#1417").value
                                var"##1437" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1437"[1] == :function && (begin
                                        var"##1438" = var"##1437"[2]
                                        var"##1438" isa AbstractArray
                                    end && (length(var"##1438") === 2 && (begin
                                                begin
                                                    var"##cache#1440" = nothing
                                                end
                                                var"##1439" = var"##1438"[1]
                                                var"##1439" isa Expr
                                            end && (begin
                                                    if var"##cache#1440" === nothing
                                                        var"##cache#1440" = Some(((var"##1439").head, (var"##1439").args))
                                                    end
                                                    var"##1441" = (var"##cache#1440").value
                                                    var"##1441" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1441"[1] == :block && (begin
                                                            var"##1442" = var"##1441"[2]
                                                            var"##1442" isa AbstractArray
                                                        end && (length(var"##1442") === 2 && (begin
                                                                    var"##1443" = var"##1442"[1]
                                                                    begin
                                                                        var"##cache#1445" = nothing
                                                                    end
                                                                    var"##1444" = var"##1442"[2]
                                                                    var"##1444" isa Expr
                                                                end && (begin
                                                                        if var"##cache#1445" === nothing
                                                                            var"##cache#1445" = Some(((var"##1444").head, (var"##1444").args))
                                                                        end
                                                                        var"##1446" = (var"##cache#1445").value
                                                                        var"##1446" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                    end && (var"##1446"[1] == :(=) && (begin
                                                                                var"##1447" = var"##1446"[2]
                                                                                var"##1447" isa AbstractArray
                                                                            end && (length(var"##1447") === 2 && begin
                                                                                    var"##1448" = var"##1447"[1]
                                                                                    var"##1449" = var"##1447"[2]
                                                                                    var"##1450" = var"##1438"[2]
                                                                                    true
                                                                                end)))))))))))))
                        var"##return#1414" = let default = var"##1449", key = var"##1448", body = var"##1450", x = var"##1443"
                                Expr(:function, Expr(:tuple, Expr(:parameters, Expr(:kw, key, default)), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1415#1470")))
                    end
                    if begin
                                var"##1451" = (var"##cache#1417").value
                                var"##1451" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1451"[1] == :function && (begin
                                        var"##1452" = var"##1451"[2]
                                        var"##1452" isa AbstractArray
                                    end && (length(var"##1452") === 2 && (begin
                                                begin
                                                    var"##cache#1454" = nothing
                                                end
                                                var"##1453" = var"##1452"[1]
                                                var"##1453" isa Expr
                                            end && (begin
                                                    if var"##cache#1454" === nothing
                                                        var"##cache#1454" = Some(((var"##1453").head, (var"##1453").args))
                                                    end
                                                    var"##1455" = (var"##cache#1454").value
                                                    var"##1455" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1455"[1] == :block && (begin
                                                            var"##1456" = var"##1455"[2]
                                                            var"##1456" isa AbstractArray
                                                        end && (length(var"##1456") === 3 && (begin
                                                                    var"##1457" = var"##1456"[1]
                                                                    var"##1458" = var"##1456"[2]
                                                                    var"##1458" isa LineNumberNode
                                                                end && (begin
                                                                        begin
                                                                            var"##cache#1460" = nothing
                                                                        end
                                                                        var"##1459" = var"##1456"[3]
                                                                        var"##1459" isa Expr
                                                                    end && (begin
                                                                            if var"##cache#1460" === nothing
                                                                                var"##cache#1460" = Some(((var"##1459").head, (var"##1459").args))
                                                                            end
                                                                            var"##1461" = (var"##cache#1460").value
                                                                            var"##1461" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                        end && (var"##1461"[1] == :(=) && (begin
                                                                                    var"##1462" = var"##1461"[2]
                                                                                    var"##1462" isa AbstractArray
                                                                                end && (length(var"##1462") === 2 && begin
                                                                                        var"##1463" = var"##1462"[1]
                                                                                        var"##1464" = var"##1462"[2]
                                                                                        var"##1465" = var"##1452"[2]
                                                                                        true
                                                                                    end))))))))))))))
                        var"##return#1414" = let default = var"##1464", key = var"##1463", body = var"##1465", x = var"##1457"
                                Expr(:function, Expr(:tuple, Expr(:parameters, Expr(:kw, key, default)), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1415#1470")))
                    end
                    if begin
                                var"##1466" = (var"##cache#1417").value
                                var"##1466" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1467" = var"##1466"[1]
                                    var"##1468" = var"##1466"[2]
                                    var"##1468" isa AbstractArray
                                end && ((ndims(var"##1468") === 1 && length(var"##1468") >= 0) && begin
                                        var"##1469" = SubArray(var"##1468", (1:length(var"##1468"),))
                                        true
                                    end))
                        var"##return#1414" = let args = var"##1469", head = var"##1467"
                                Expr(head, map(canonicalize_lambda_head, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1415#1470")))
                    end
                end
                begin
                    var"##return#1414" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1415#1470")))
                end
                error("matching non-exhaustive, at #= none:242 =#")
                $(Expr(:symboliclabel, Symbol("####final#1415#1470")))
                var"##return#1414"
            end
        end
    function rm_single_block(ex)
        let
            begin
                var"##cache#1474" = nothing
            end
            var"##return#1471" = nothing
            var"##1473" = ex
            if var"##1473" isa Expr
                if begin
                            if var"##cache#1474" === nothing
                                var"##cache#1474" = Some(((var"##1473").head, (var"##1473").args))
                            end
                            var"##1475" = (var"##cache#1474").value
                            var"##1475" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1475"[1] == :(=) && (begin
                                    var"##1476" = var"##1475"[2]
                                    var"##1476" isa AbstractArray
                                end && (ndims(var"##1476") === 1 && length(var"##1476") >= 0)))
                    var"##return#1471" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1472#1539")))
                end
                if begin
                            var"##1477" = (var"##cache#1474").value
                            var"##1477" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1477"[1] == :-> && (begin
                                    var"##1478" = var"##1477"[2]
                                    var"##1478" isa AbstractArray
                                end && (ndims(var"##1478") === 1 && length(var"##1478") >= 0)))
                    var"##return#1471" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1472#1539")))
                end
                if begin
                            var"##1479" = (var"##cache#1474").value
                            var"##1479" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1479"[1] == :quote && (begin
                                    var"##1480" = var"##1479"[2]
                                    var"##1480" isa AbstractArray
                                end && ((ndims(var"##1480") === 1 && length(var"##1480") >= 0) && begin
                                        var"##1481" = SubArray(var"##1480", (1:length(var"##1480"),))
                                        true
                                    end)))
                    var"##return#1471" = let xs = var"##1481"
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1472#1539")))
                end
                if begin
                            var"##1482" = (var"##cache#1474").value
                            var"##1482" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1482"[1] == :block && (begin
                                    var"##1483" = var"##1482"[2]
                                    var"##1483" isa AbstractArray
                                end && (length(var"##1483") === 1 && (begin
                                            begin
                                                var"##cache#1485" = nothing
                                            end
                                            var"##1484" = var"##1483"[1]
                                            var"##1484" isa Expr
                                        end && (begin
                                                if var"##cache#1485" === nothing
                                                    var"##cache#1485" = Some(((var"##1484").head, (var"##1484").args))
                                                end
                                                var"##1486" = (var"##cache#1485").value
                                                var"##1486" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1486"[1] == :quote && (begin
                                                        var"##1487" = var"##1486"[2]
                                                        var"##1487" isa AbstractArray
                                                    end && ((ndims(var"##1487") === 1 && length(var"##1487") >= 0) && begin
                                                            var"##1488" = SubArray(var"##1487", (1:length(var"##1487"),))
                                                            true
                                                        end))))))))
                    var"##return#1471" = let xs = var"##1488"
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1472#1539")))
                end
                if begin
                            var"##1489" = (var"##cache#1474").value
                            var"##1489" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1489"[1] == :try && (begin
                                    var"##1490" = var"##1489"[2]
                                    var"##1490" isa AbstractArray
                                end && (length(var"##1490") === 4 && (begin
                                            begin
                                                var"##cache#1492" = nothing
                                            end
                                            var"##1491" = var"##1490"[1]
                                            var"##1491" isa Expr
                                        end && (begin
                                                if var"##cache#1492" === nothing
                                                    var"##cache#1492" = Some(((var"##1491").head, (var"##1491").args))
                                                end
                                                var"##1493" = (var"##cache#1492").value
                                                var"##1493" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1493"[1] == :block && (begin
                                                        var"##1494" = var"##1493"[2]
                                                        var"##1494" isa AbstractArray
                                                    end && ((ndims(var"##1494") === 1 && length(var"##1494") >= 0) && (begin
                                                                var"##1495" = SubArray(var"##1494", (1:length(var"##1494"),))
                                                                var"##1490"[2] === false
                                                            end && (var"##1490"[3] === false && (begin
                                                                        begin
                                                                            var"##cache#1497" = nothing
                                                                        end
                                                                        var"##1496" = var"##1490"[4]
                                                                        var"##1496" isa Expr
                                                                    end && (begin
                                                                            if var"##cache#1497" === nothing
                                                                                var"##cache#1497" = Some(((var"##1496").head, (var"##1496").args))
                                                                            end
                                                                            var"##1498" = (var"##cache#1497").value
                                                                            var"##1498" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                        end && (var"##1498"[1] == :block && (begin
                                                                                    var"##1499" = var"##1498"[2]
                                                                                    var"##1499" isa AbstractArray
                                                                                end && ((ndims(var"##1499") === 1 && length(var"##1499") >= 0) && begin
                                                                                        var"##1500" = SubArray(var"##1499", (1:length(var"##1499"),))
                                                                                        true
                                                                                    end)))))))))))))))
                    var"##return#1471" = let try_stmts = var"##1495", finally_stmts = var"##1500"
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), false, false, Expr(:block, rm_single_block.(finally_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1472#1539")))
                end
                if begin
                            var"##1501" = (var"##cache#1474").value
                            var"##1501" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1501"[1] == :try && (begin
                                    var"##1502" = var"##1501"[2]
                                    var"##1502" isa AbstractArray
                                end && (length(var"##1502") === 3 && (begin
                                            begin
                                                var"##cache#1504" = nothing
                                            end
                                            var"##1503" = var"##1502"[1]
                                            var"##1503" isa Expr
                                        end && (begin
                                                if var"##cache#1504" === nothing
                                                    var"##cache#1504" = Some(((var"##1503").head, (var"##1503").args))
                                                end
                                                var"##1505" = (var"##cache#1504").value
                                                var"##1505" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1505"[1] == :block && (begin
                                                        var"##1506" = var"##1505"[2]
                                                        var"##1506" isa AbstractArray
                                                    end && ((ndims(var"##1506") === 1 && length(var"##1506") >= 0) && (begin
                                                                var"##1507" = SubArray(var"##1506", (1:length(var"##1506"),))
                                                                var"##1508" = var"##1502"[2]
                                                                begin
                                                                    var"##cache#1510" = nothing
                                                                end
                                                                var"##1509" = var"##1502"[3]
                                                                var"##1509" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1510" === nothing
                                                                        var"##cache#1510" = Some(((var"##1509").head, (var"##1509").args))
                                                                    end
                                                                    var"##1511" = (var"##cache#1510").value
                                                                    var"##1511" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1511"[1] == :block && (begin
                                                                            var"##1512" = var"##1511"[2]
                                                                            var"##1512" isa AbstractArray
                                                                        end && ((ndims(var"##1512") === 1 && length(var"##1512") >= 0) && begin
                                                                                var"##1513" = SubArray(var"##1512", (1:length(var"##1512"),))
                                                                                true
                                                                            end)))))))))))))
                    var"##return#1471" = let try_stmts = var"##1507", catch_stmts = var"##1513", catch_var = var"##1508"
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), catch_var, Expr(:block, rm_single_block.(catch_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1472#1539")))
                end
                if begin
                            var"##1514" = (var"##cache#1474").value
                            var"##1514" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1514"[1] == :try && (begin
                                    var"##1515" = var"##1514"[2]
                                    var"##1515" isa AbstractArray
                                end && (length(var"##1515") === 4 && (begin
                                            begin
                                                var"##cache#1517" = nothing
                                            end
                                            var"##1516" = var"##1515"[1]
                                            var"##1516" isa Expr
                                        end && (begin
                                                if var"##cache#1517" === nothing
                                                    var"##cache#1517" = Some(((var"##1516").head, (var"##1516").args))
                                                end
                                                var"##1518" = (var"##cache#1517").value
                                                var"##1518" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1518"[1] == :block && (begin
                                                        var"##1519" = var"##1518"[2]
                                                        var"##1519" isa AbstractArray
                                                    end && ((ndims(var"##1519") === 1 && length(var"##1519") >= 0) && (begin
                                                                var"##1520" = SubArray(var"##1519", (1:length(var"##1519"),))
                                                                var"##1521" = var"##1515"[2]
                                                                begin
                                                                    var"##cache#1523" = nothing
                                                                end
                                                                var"##1522" = var"##1515"[3]
                                                                var"##1522" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1523" === nothing
                                                                        var"##cache#1523" = Some(((var"##1522").head, (var"##1522").args))
                                                                    end
                                                                    var"##1524" = (var"##cache#1523").value
                                                                    var"##1524" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1524"[1] == :block && (begin
                                                                            var"##1525" = var"##1524"[2]
                                                                            var"##1525" isa AbstractArray
                                                                        end && ((ndims(var"##1525") === 1 && length(var"##1525") >= 0) && (begin
                                                                                    var"##1526" = SubArray(var"##1525", (1:length(var"##1525"),))
                                                                                    begin
                                                                                        var"##cache#1528" = nothing
                                                                                    end
                                                                                    var"##1527" = var"##1515"[4]
                                                                                    var"##1527" isa Expr
                                                                                end && (begin
                                                                                        if var"##cache#1528" === nothing
                                                                                            var"##cache#1528" = Some(((var"##1527").head, (var"##1527").args))
                                                                                        end
                                                                                        var"##1529" = (var"##cache#1528").value
                                                                                        var"##1529" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                                    end && (var"##1529"[1] == :block && (begin
                                                                                                var"##1530" = var"##1529"[2]
                                                                                                var"##1530" isa AbstractArray
                                                                                            end && ((ndims(var"##1530") === 1 && length(var"##1530") >= 0) && begin
                                                                                                    var"##1531" = SubArray(var"##1530", (1:length(var"##1530"),))
                                                                                                    true
                                                                                                end))))))))))))))))))
                    var"##return#1471" = let try_stmts = var"##1520", catch_stmts = var"##1526", catch_var = var"##1521", finally_stmts = var"##1531"
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), catch_var, Expr(:block, rm_single_block.(catch_stmts)...), Expr(:block, rm_single_block.(finally_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1472#1539")))
                end
                if begin
                            var"##1532" = (var"##cache#1474").value
                            var"##1532" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1532"[1] == :block && (begin
                                    var"##1533" = var"##1532"[2]
                                    var"##1533" isa AbstractArray
                                end && (length(var"##1533") === 1 && begin
                                        var"##1534" = var"##1533"[1]
                                        true
                                    end)))
                    var"##return#1471" = let stmt = var"##1534"
                            stmt
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1472#1539")))
                end
                if begin
                            var"##1535" = (var"##cache#1474").value
                            var"##1535" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                        end && (begin
                                var"##1536" = var"##1535"[1]
                                var"##1537" = var"##1535"[2]
                                var"##1537" isa AbstractArray
                            end && ((ndims(var"##1537") === 1 && length(var"##1537") >= 0) && begin
                                    var"##1538" = SubArray(var"##1537", (1:length(var"##1537"),))
                                    true
                                end))
                    var"##return#1471" = let args = var"##1538", head = var"##1536"
                            Expr(head, map(rm_single_block, args)...)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1472#1539")))
                end
            end
            begin
                var"##return#1471" = let
                        ex
                    end
                $(Expr(:symbolicgoto, Symbol("####final#1472#1539")))
            end
            error("matching non-exhaustive, at #= none:258 =#")
            $(Expr(:symboliclabel, Symbol("####final#1472#1539")))
            var"##return#1471"
        end
    end
    #= none:286 =# Core.@doc "    rm_annotations(x)\n\nRemove type annotation of given expression.\n" function rm_annotations(x)
            x isa Expr || return x
            if x.head == :(::)
                if length(x.args) == 1
                    return gensym("::$(x.args[1])")
                else
                    return x.args[1]
                end
            elseif x.head in [:(=), :kw]
                return rm_annotations(x.args[1])
            else
                return Expr(x.head, map(rm_annotations, x.args)...)
            end
        end
    #= none:306 =# Core.@doc "    alias_gensym(ex)\n\nReplace gensym with `<name>_<id>`.\n\n!!! note\n    Borrowed from [MacroTools](https://github.com/FluxML/MacroTools.jl).\n" alias_gensym(ex) = begin
                alias_gensym!(Dict{Symbol, Symbol}(), Dict{Symbol, Int}(), ex)
            end
    function alias_gensym!(d::Dict{Symbol, Symbol}, count::Dict{Symbol, Int}, ex)
        if is_gensym(ex)
            haskey(d, ex) && return d[ex]
            name = Symbol(gensym_name(ex))
            id = get(count, name, 0) + 1
            d[ex] = Symbol(name, :_, id)
            count[name] = id
            return d[ex]
        end
        ex isa Expr || return ex
        args = map(ex.args) do x
                alias_gensym!(d, count, x)
            end
        return Expr(ex.head, args...)
    end
    #= none:334 =# Core.@doc "    renumber_gensym(ex)\n\nRe-number gensym with counter from this expression.\nProduce a deterministic gensym name for testing etc.\nSee also: [`alias_gensym`](@ref)\n" renumber_gensym(ex) = begin
                renumber_gensym!(Dict{Symbol, Symbol}(), Dict{Symbol, Int}(), ex)
            end
    function renumber_gensym!(d::Dict{Symbol, Symbol}, count::Dict{Symbol, Int}, ex)
        function renumber(head, m)
            name = Symbol(m.captures[1])
            id = (count[name] = get(count, name, 0) + 1)
            return d[ex] = Symbol(head, name, "#", id)
        end
        if is_gensym(ex)
            haskey(d, ex) && return d[ex]
            gensym_str = String(ex)
            m = Base.match(r"##(.+)#\d+", gensym_str)
            m === nothing || return renumber("##", m)
            m = Base.match(r"#\d+#(.+)", gensym_str)
            m === nothing || return renumber("#", m)
        end
        ex isa Expr || return ex
        args = map(ex.args) do x
                renumber_gensym!(d, count, x)
            end
        return Expr(ex.head, args...)
    end
    #= none:368 =# Core.@doc "    expr_map(f, c...; skip_nothing::Bool=false)\n\nSimilar to `Base.map`, but expects `f` to return an expression,\nand will concanate these expression as a `Expr(:block, ...)`\nexpression.\n\nSkip `nothing` if `skip_nothing` is `true`.\n\n# Example\n\n```jldoctest\njulia> expr_map(1:10, 2:11) do i,j\n           :(1 + \$i + \$j)\n       end\nquote\n    1 + 1 + 2\n    1 + 2 + 3\n    1 + 3 + 4\n    1 + 4 + 5\n    1 + 5 + 6\n    1 + 6 + 7\n    1 + 7 + 8\n    1 + 8 + 9\n    1 + 9 + 10\n    1 + 10 + 11\nend\n```\n" function expr_map(f, c...; skip_nothing::Bool = false)
            ex = Expr(:block)
            for args = zip(c...)
                ret = f(args...)
                skip_nothing && (isnothing(ret) && continue)
                push!(ex.args, ret)
            end
            return ex
        end
    #= none:407 =# Core.@doc "    nexprs(f, n::Int)\n\nCreate `n` similar expressions by evaluating `f`.\n\n# Example\n\n```jldoctest\njulia> nexprs(5) do k\n           :(1 + \$k)\n       end\nquote\n    1 + 1\n    1 + 2\n    1 + 3\n    1 + 4\n    1 + 5\nend\n```\n" nexprs(f, k::Int) = begin
                expr_map(f, 1:k)
            end
    #= none:429 =# Core.@doc "    Substitute(condition) -> substitute(f(expr), expr)\n\nReturns a function that substitutes `expr` with\n`f(expr)` if `condition(expr)` is true. Applied\nrecursively to all sub-expressions.\n\n# Example\n\n```jldoctest\njulia> sub = Substitute() do expr\n           expr isa Symbol && expr in [:x] && return true\n           return false\n       end;\n\njulia> sub(_->1, :(x + y))\n:(1 + y)\n```\n" struct Substitute
            condition
        end
    (sub::Substitute)(f) = begin
            Base.Fix1(sub, f)
        end
    function (sub::Substitute)(f, expr)
        if sub.condition(expr)
            return f(expr)
        elseif expr isa Expr
            return Expr(expr.head, map(sub(f), expr.args)...)
        else
            return expr
        end
    end
