
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
                    var"##cache#1387" = nothing
                end
                var"##return#1384" = nothing
                var"##1386" = ex
                if var"##1386" isa Expr
                    if begin
                                if var"##cache#1387" === nothing
                                    var"##cache#1387" = Some(((var"##1386").head, (var"##1386").args))
                                end
                                var"##1388" = (var"##cache#1387").value
                                var"##1388" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1388"[1] == :macrocall && (begin
                                        var"##1389" = var"##1388"[2]
                                        var"##1389" isa AbstractArray
                                    end && ((ndims(var"##1389") === 1 && length(var"##1389") >= 2) && begin
                                            var"##1390" = var"##1389"[1]
                                            var"##1391" = var"##1389"[2]
                                            var"##1392" = SubArray(var"##1389", (3:length(var"##1389"),))
                                            true
                                        end)))
                        var"##return#1384" = let line = var"##1391", name = var"##1390", args = var"##1392"
                                Expr(:macrocall, name, line, map(rm_lineinfo, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1385#1397")))
                    end
                    if begin
                                var"##1393" = (var"##cache#1387").value
                                var"##1393" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1394" = var"##1393"[1]
                                    var"##1395" = var"##1393"[2]
                                    var"##1395" isa AbstractArray
                                end && ((ndims(var"##1395") === 1 && length(var"##1395") >= 0) && begin
                                        var"##1396" = SubArray(var"##1395", (1:length(var"##1395"),))
                                        true
                                    end))
                        var"##return#1384" = let args = var"##1396", head = var"##1394"
                                Expr(head, map(rm_lineinfo, filter((x->begin
                                                    !(x isa LineNumberNode)
                                                end), args))...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1385#1397")))
                    end
                end
                begin
                    var"##return#1384" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1385#1397")))
                end
                error("matching non-exhaustive, at #= none:108 =#")
                $(Expr(:symboliclabel, Symbol("####final#1385#1397")))
                var"##return#1384"
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
                    var"##cache#1401" = nothing
                end
                var"##return#1398" = nothing
                var"##1400" = ex
                if var"##1400" isa Expr
                    if begin
                                if var"##cache#1401" === nothing
                                    var"##cache#1401" = Some(((var"##1400").head, (var"##1400").args))
                                end
                                var"##1402" = (var"##cache#1401").value
                                var"##1402" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1402"[1] == :block && (begin
                                        var"##1403" = var"##1402"[2]
                                        var"##1403" isa AbstractArray
                                    end && ((ndims(var"##1403") === 1 && length(var"##1403") >= 0) && begin
                                            var"##1404" = SubArray(var"##1403", (1:length(var"##1403"),))
                                            true
                                        end)))
                        var"##return#1398" = let args = var"##1404"
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
                        $(Expr(:symbolicgoto, Symbol("####final#1399#1409")))
                    end
                    if begin
                                var"##1405" = (var"##cache#1401").value
                                var"##1405" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1406" = var"##1405"[1]
                                    var"##1407" = var"##1405"[2]
                                    var"##1407" isa AbstractArray
                                end && ((ndims(var"##1407") === 1 && length(var"##1407") >= 0) && begin
                                        var"##1408" = SubArray(var"##1407", (1:length(var"##1407"),))
                                        true
                                    end))
                        var"##return#1398" = let args = var"##1408", head = var"##1406"
                                Expr(head, map(rm_nothing, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1399#1409")))
                    end
                end
                begin
                    var"##return#1398" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1399#1409")))
                end
                error("matching non-exhaustive, at #= none:219 =#")
                $(Expr(:symboliclabel, Symbol("####final#1399#1409")))
                var"##return#1398"
            end
        end
    #= none:232 =# Core.@doc "    canonicalize_lambda_head(ex)\n\nCanonicalize the `Expr(:function, Expr(:block, x, Expr(:(=), key, default)), body)` to\n\n```julia\nExpr(:function, Expr(:tuple, Expr(:parameters, Expr(:kw, key, default)), x), body)\n```\n" function canonicalize_lambda_head(ex)
            let
                begin
                    var"##cache#1413" = nothing
                end
                var"##return#1410" = nothing
                var"##1412" = ex
                if var"##1412" isa Expr
                    if begin
                                if var"##cache#1413" === nothing
                                    var"##cache#1413" = Some(((var"##1412").head, (var"##1412").args))
                                end
                                var"##1414" = (var"##cache#1413").value
                                var"##1414" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1414"[1] == :function && (begin
                                        var"##1415" = var"##1414"[2]
                                        var"##1415" isa AbstractArray
                                    end && (length(var"##1415") === 2 && (begin
                                                begin
                                                    var"##cache#1417" = nothing
                                                end
                                                var"##1416" = var"##1415"[1]
                                                var"##1416" isa Expr
                                            end && (begin
                                                    if var"##cache#1417" === nothing
                                                        var"##cache#1417" = Some(((var"##1416").head, (var"##1416").args))
                                                    end
                                                    var"##1418" = (var"##cache#1417").value
                                                    var"##1418" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1418"[1] == :block && (begin
                                                            var"##1419" = var"##1418"[2]
                                                            var"##1419" isa AbstractArray
                                                        end && (length(var"##1419") === 2 && begin
                                                                var"##1420" = var"##1419"[1]
                                                                var"##1421" = var"##1419"[2]
                                                                var"##1422" = var"##1415"[2]
                                                                true
                                                            end))))))))
                        var"##return#1410" = let y = var"##1421", body = var"##1422", x = var"##1420"
                                Expr(:function, Expr(:tuple, Expr(:parameters, y), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1411#1466")))
                    end
                    if begin
                                var"##1423" = (var"##cache#1413").value
                                var"##1423" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1423"[1] == :function && (begin
                                        var"##1424" = var"##1423"[2]
                                        var"##1424" isa AbstractArray
                                    end && (length(var"##1424") === 2 && (begin
                                                begin
                                                    var"##cache#1426" = nothing
                                                end
                                                var"##1425" = var"##1424"[1]
                                                var"##1425" isa Expr
                                            end && (begin
                                                    if var"##cache#1426" === nothing
                                                        var"##cache#1426" = Some(((var"##1425").head, (var"##1425").args))
                                                    end
                                                    var"##1427" = (var"##cache#1426").value
                                                    var"##1427" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1427"[1] == :block && (begin
                                                            var"##1428" = var"##1427"[2]
                                                            var"##1428" isa AbstractArray
                                                        end && (length(var"##1428") === 3 && (begin
                                                                    var"##1429" = var"##1428"[1]
                                                                    var"##1430" = var"##1428"[2]
                                                                    var"##1430" isa LineNumberNode
                                                                end && begin
                                                                    var"##1431" = var"##1428"[3]
                                                                    var"##1432" = var"##1424"[2]
                                                                    true
                                                                end)))))))))
                        var"##return#1410" = let y = var"##1431", body = var"##1432", x = var"##1429"
                                Expr(:function, Expr(:tuple, Expr(:parameters, y), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1411#1466")))
                    end
                    if begin
                                var"##1433" = (var"##cache#1413").value
                                var"##1433" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1433"[1] == :function && (begin
                                        var"##1434" = var"##1433"[2]
                                        var"##1434" isa AbstractArray
                                    end && (length(var"##1434") === 2 && (begin
                                                begin
                                                    var"##cache#1436" = nothing
                                                end
                                                var"##1435" = var"##1434"[1]
                                                var"##1435" isa Expr
                                            end && (begin
                                                    if var"##cache#1436" === nothing
                                                        var"##cache#1436" = Some(((var"##1435").head, (var"##1435").args))
                                                    end
                                                    var"##1437" = (var"##cache#1436").value
                                                    var"##1437" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1437"[1] == :block && (begin
                                                            var"##1438" = var"##1437"[2]
                                                            var"##1438" isa AbstractArray
                                                        end && (length(var"##1438") === 2 && (begin
                                                                    var"##1439" = var"##1438"[1]
                                                                    begin
                                                                        var"##cache#1441" = nothing
                                                                    end
                                                                    var"##1440" = var"##1438"[2]
                                                                    var"##1440" isa Expr
                                                                end && (begin
                                                                        if var"##cache#1441" === nothing
                                                                            var"##cache#1441" = Some(((var"##1440").head, (var"##1440").args))
                                                                        end
                                                                        var"##1442" = (var"##cache#1441").value
                                                                        var"##1442" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                    end && (var"##1442"[1] == :(=) && (begin
                                                                                var"##1443" = var"##1442"[2]
                                                                                var"##1443" isa AbstractArray
                                                                            end && (length(var"##1443") === 2 && begin
                                                                                    var"##1444" = var"##1443"[1]
                                                                                    var"##1445" = var"##1443"[2]
                                                                                    var"##1446" = var"##1434"[2]
                                                                                    true
                                                                                end)))))))))))))
                        var"##return#1410" = let default = var"##1445", key = var"##1444", body = var"##1446", x = var"##1439"
                                Expr(:function, Expr(:tuple, Expr(:parameters, Expr(:kw, key, default)), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1411#1466")))
                    end
                    if begin
                                var"##1447" = (var"##cache#1413").value
                                var"##1447" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1447"[1] == :function && (begin
                                        var"##1448" = var"##1447"[2]
                                        var"##1448" isa AbstractArray
                                    end && (length(var"##1448") === 2 && (begin
                                                begin
                                                    var"##cache#1450" = nothing
                                                end
                                                var"##1449" = var"##1448"[1]
                                                var"##1449" isa Expr
                                            end && (begin
                                                    if var"##cache#1450" === nothing
                                                        var"##cache#1450" = Some(((var"##1449").head, (var"##1449").args))
                                                    end
                                                    var"##1451" = (var"##cache#1450").value
                                                    var"##1451" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1451"[1] == :block && (begin
                                                            var"##1452" = var"##1451"[2]
                                                            var"##1452" isa AbstractArray
                                                        end && (length(var"##1452") === 3 && (begin
                                                                    var"##1453" = var"##1452"[1]
                                                                    var"##1454" = var"##1452"[2]
                                                                    var"##1454" isa LineNumberNode
                                                                end && (begin
                                                                        begin
                                                                            var"##cache#1456" = nothing
                                                                        end
                                                                        var"##1455" = var"##1452"[3]
                                                                        var"##1455" isa Expr
                                                                    end && (begin
                                                                            if var"##cache#1456" === nothing
                                                                                var"##cache#1456" = Some(((var"##1455").head, (var"##1455").args))
                                                                            end
                                                                            var"##1457" = (var"##cache#1456").value
                                                                            var"##1457" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                        end && (var"##1457"[1] == :(=) && (begin
                                                                                    var"##1458" = var"##1457"[2]
                                                                                    var"##1458" isa AbstractArray
                                                                                end && (length(var"##1458") === 2 && begin
                                                                                        var"##1459" = var"##1458"[1]
                                                                                        var"##1460" = var"##1458"[2]
                                                                                        var"##1461" = var"##1448"[2]
                                                                                        true
                                                                                    end))))))))))))))
                        var"##return#1410" = let default = var"##1460", key = var"##1459", body = var"##1461", x = var"##1453"
                                Expr(:function, Expr(:tuple, Expr(:parameters, Expr(:kw, key, default)), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1411#1466")))
                    end
                    if begin
                                var"##1462" = (var"##cache#1413").value
                                var"##1462" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1463" = var"##1462"[1]
                                    var"##1464" = var"##1462"[2]
                                    var"##1464" isa AbstractArray
                                end && ((ndims(var"##1464") === 1 && length(var"##1464") >= 0) && begin
                                        var"##1465" = SubArray(var"##1464", (1:length(var"##1464"),))
                                        true
                                    end))
                        var"##return#1410" = let args = var"##1465", head = var"##1463"
                                Expr(head, map(canonicalize_lambda_head, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1411#1466")))
                    end
                end
                begin
                    var"##return#1410" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1411#1466")))
                end
                error("matching non-exhaustive, at #= none:242 =#")
                $(Expr(:symboliclabel, Symbol("####final#1411#1466")))
                var"##return#1410"
            end
        end
    function rm_single_block(ex)
        let
            begin
                var"##cache#1470" = nothing
            end
            var"##return#1467" = nothing
            var"##1469" = ex
            if var"##1469" isa Expr
                if begin
                            if var"##cache#1470" === nothing
                                var"##cache#1470" = Some(((var"##1469").head, (var"##1469").args))
                            end
                            var"##1471" = (var"##cache#1470").value
                            var"##1471" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1471"[1] == :(=) && (begin
                                    var"##1472" = var"##1471"[2]
                                    var"##1472" isa AbstractArray
                                end && (ndims(var"##1472") === 1 && length(var"##1472") >= 0)))
                    var"##return#1467" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1468#1535")))
                end
                if begin
                            var"##1473" = (var"##cache#1470").value
                            var"##1473" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1473"[1] == :-> && (begin
                                    var"##1474" = var"##1473"[2]
                                    var"##1474" isa AbstractArray
                                end && (ndims(var"##1474") === 1 && length(var"##1474") >= 0)))
                    var"##return#1467" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1468#1535")))
                end
                if begin
                            var"##1475" = (var"##cache#1470").value
                            var"##1475" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1475"[1] == :quote && (begin
                                    var"##1476" = var"##1475"[2]
                                    var"##1476" isa AbstractArray
                                end && ((ndims(var"##1476") === 1 && length(var"##1476") >= 0) && begin
                                        var"##1477" = SubArray(var"##1476", (1:length(var"##1476"),))
                                        true
                                    end)))
                    var"##return#1467" = let xs = var"##1477"
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1468#1535")))
                end
                if begin
                            var"##1478" = (var"##cache#1470").value
                            var"##1478" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1478"[1] == :block && (begin
                                    var"##1479" = var"##1478"[2]
                                    var"##1479" isa AbstractArray
                                end && (length(var"##1479") === 1 && (begin
                                            begin
                                                var"##cache#1481" = nothing
                                            end
                                            var"##1480" = var"##1479"[1]
                                            var"##1480" isa Expr
                                        end && (begin
                                                if var"##cache#1481" === nothing
                                                    var"##cache#1481" = Some(((var"##1480").head, (var"##1480").args))
                                                end
                                                var"##1482" = (var"##cache#1481").value
                                                var"##1482" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1482"[1] == :quote && (begin
                                                        var"##1483" = var"##1482"[2]
                                                        var"##1483" isa AbstractArray
                                                    end && ((ndims(var"##1483") === 1 && length(var"##1483") >= 0) && begin
                                                            var"##1484" = SubArray(var"##1483", (1:length(var"##1483"),))
                                                            true
                                                        end))))))))
                    var"##return#1467" = let xs = var"##1484"
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1468#1535")))
                end
                if begin
                            var"##1485" = (var"##cache#1470").value
                            var"##1485" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1485"[1] == :try && (begin
                                    var"##1486" = var"##1485"[2]
                                    var"##1486" isa AbstractArray
                                end && (length(var"##1486") === 4 && (begin
                                            begin
                                                var"##cache#1488" = nothing
                                            end
                                            var"##1487" = var"##1486"[1]
                                            var"##1487" isa Expr
                                        end && (begin
                                                if var"##cache#1488" === nothing
                                                    var"##cache#1488" = Some(((var"##1487").head, (var"##1487").args))
                                                end
                                                var"##1489" = (var"##cache#1488").value
                                                var"##1489" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1489"[1] == :block && (begin
                                                        var"##1490" = var"##1489"[2]
                                                        var"##1490" isa AbstractArray
                                                    end && ((ndims(var"##1490") === 1 && length(var"##1490") >= 0) && (begin
                                                                var"##1491" = SubArray(var"##1490", (1:length(var"##1490"),))
                                                                var"##1486"[2] === false
                                                            end && (var"##1486"[3] === false && (begin
                                                                        begin
                                                                            var"##cache#1493" = nothing
                                                                        end
                                                                        var"##1492" = var"##1486"[4]
                                                                        var"##1492" isa Expr
                                                                    end && (begin
                                                                            if var"##cache#1493" === nothing
                                                                                var"##cache#1493" = Some(((var"##1492").head, (var"##1492").args))
                                                                            end
                                                                            var"##1494" = (var"##cache#1493").value
                                                                            var"##1494" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                        end && (var"##1494"[1] == :block && (begin
                                                                                    var"##1495" = var"##1494"[2]
                                                                                    var"##1495" isa AbstractArray
                                                                                end && ((ndims(var"##1495") === 1 && length(var"##1495") >= 0) && begin
                                                                                        var"##1496" = SubArray(var"##1495", (1:length(var"##1495"),))
                                                                                        true
                                                                                    end)))))))))))))))
                    var"##return#1467" = let try_stmts = var"##1491", finally_stmts = var"##1496"
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), false, false, Expr(:block, rm_single_block.(finally_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1468#1535")))
                end
                if begin
                            var"##1497" = (var"##cache#1470").value
                            var"##1497" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1497"[1] == :try && (begin
                                    var"##1498" = var"##1497"[2]
                                    var"##1498" isa AbstractArray
                                end && (length(var"##1498") === 3 && (begin
                                            begin
                                                var"##cache#1500" = nothing
                                            end
                                            var"##1499" = var"##1498"[1]
                                            var"##1499" isa Expr
                                        end && (begin
                                                if var"##cache#1500" === nothing
                                                    var"##cache#1500" = Some(((var"##1499").head, (var"##1499").args))
                                                end
                                                var"##1501" = (var"##cache#1500").value
                                                var"##1501" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1501"[1] == :block && (begin
                                                        var"##1502" = var"##1501"[2]
                                                        var"##1502" isa AbstractArray
                                                    end && ((ndims(var"##1502") === 1 && length(var"##1502") >= 0) && (begin
                                                                var"##1503" = SubArray(var"##1502", (1:length(var"##1502"),))
                                                                var"##1504" = var"##1498"[2]
                                                                begin
                                                                    var"##cache#1506" = nothing
                                                                end
                                                                var"##1505" = var"##1498"[3]
                                                                var"##1505" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1506" === nothing
                                                                        var"##cache#1506" = Some(((var"##1505").head, (var"##1505").args))
                                                                    end
                                                                    var"##1507" = (var"##cache#1506").value
                                                                    var"##1507" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1507"[1] == :block && (begin
                                                                            var"##1508" = var"##1507"[2]
                                                                            var"##1508" isa AbstractArray
                                                                        end && ((ndims(var"##1508") === 1 && length(var"##1508") >= 0) && begin
                                                                                var"##1509" = SubArray(var"##1508", (1:length(var"##1508"),))
                                                                                true
                                                                            end)))))))))))))
                    var"##return#1467" = let try_stmts = var"##1503", catch_stmts = var"##1509", catch_var = var"##1504"
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), catch_var, Expr(:block, rm_single_block.(catch_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1468#1535")))
                end
                if begin
                            var"##1510" = (var"##cache#1470").value
                            var"##1510" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1510"[1] == :try && (begin
                                    var"##1511" = var"##1510"[2]
                                    var"##1511" isa AbstractArray
                                end && (length(var"##1511") === 4 && (begin
                                            begin
                                                var"##cache#1513" = nothing
                                            end
                                            var"##1512" = var"##1511"[1]
                                            var"##1512" isa Expr
                                        end && (begin
                                                if var"##cache#1513" === nothing
                                                    var"##cache#1513" = Some(((var"##1512").head, (var"##1512").args))
                                                end
                                                var"##1514" = (var"##cache#1513").value
                                                var"##1514" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1514"[1] == :block && (begin
                                                        var"##1515" = var"##1514"[2]
                                                        var"##1515" isa AbstractArray
                                                    end && ((ndims(var"##1515") === 1 && length(var"##1515") >= 0) && (begin
                                                                var"##1516" = SubArray(var"##1515", (1:length(var"##1515"),))
                                                                var"##1517" = var"##1511"[2]
                                                                begin
                                                                    var"##cache#1519" = nothing
                                                                end
                                                                var"##1518" = var"##1511"[3]
                                                                var"##1518" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1519" === nothing
                                                                        var"##cache#1519" = Some(((var"##1518").head, (var"##1518").args))
                                                                    end
                                                                    var"##1520" = (var"##cache#1519").value
                                                                    var"##1520" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1520"[1] == :block && (begin
                                                                            var"##1521" = var"##1520"[2]
                                                                            var"##1521" isa AbstractArray
                                                                        end && ((ndims(var"##1521") === 1 && length(var"##1521") >= 0) && (begin
                                                                                    var"##1522" = SubArray(var"##1521", (1:length(var"##1521"),))
                                                                                    begin
                                                                                        var"##cache#1524" = nothing
                                                                                    end
                                                                                    var"##1523" = var"##1511"[4]
                                                                                    var"##1523" isa Expr
                                                                                end && (begin
                                                                                        if var"##cache#1524" === nothing
                                                                                            var"##cache#1524" = Some(((var"##1523").head, (var"##1523").args))
                                                                                        end
                                                                                        var"##1525" = (var"##cache#1524").value
                                                                                        var"##1525" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                                    end && (var"##1525"[1] == :block && (begin
                                                                                                var"##1526" = var"##1525"[2]
                                                                                                var"##1526" isa AbstractArray
                                                                                            end && ((ndims(var"##1526") === 1 && length(var"##1526") >= 0) && begin
                                                                                                    var"##1527" = SubArray(var"##1526", (1:length(var"##1526"),))
                                                                                                    true
                                                                                                end))))))))))))))))))
                    var"##return#1467" = let try_stmts = var"##1516", catch_stmts = var"##1522", catch_var = var"##1517", finally_stmts = var"##1527"
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), catch_var, Expr(:block, rm_single_block.(catch_stmts)...), Expr(:block, rm_single_block.(finally_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1468#1535")))
                end
                if begin
                            var"##1528" = (var"##cache#1470").value
                            var"##1528" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1528"[1] == :block && (begin
                                    var"##1529" = var"##1528"[2]
                                    var"##1529" isa AbstractArray
                                end && (length(var"##1529") === 1 && begin
                                        var"##1530" = var"##1529"[1]
                                        true
                                    end)))
                    var"##return#1467" = let stmt = var"##1530"
                            stmt
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1468#1535")))
                end
                if begin
                            var"##1531" = (var"##cache#1470").value
                            var"##1531" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                        end && (begin
                                var"##1532" = var"##1531"[1]
                                var"##1533" = var"##1531"[2]
                                var"##1533" isa AbstractArray
                            end && ((ndims(var"##1533") === 1 && length(var"##1533") >= 0) && begin
                                    var"##1534" = SubArray(var"##1533", (1:length(var"##1533"),))
                                    true
                                end))
                    var"##return#1467" = let args = var"##1534", head = var"##1532"
                            Expr(head, map(rm_single_block, args)...)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1468#1535")))
                end
            end
            begin
                var"##return#1467" = let
                        ex
                    end
                $(Expr(:symbolicgoto, Symbol("####final#1468#1535")))
            end
            error("matching non-exhaustive, at #= none:258 =#")
            $(Expr(:symboliclabel, Symbol("####final#1468#1535")))
            var"##return#1467"
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
