
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
                    var"##cache#1362" = nothing
                end
                var"##return#1359" = nothing
                var"##1361" = ex
                if var"##1361" isa Expr
                    if begin
                                if var"##cache#1362" === nothing
                                    var"##cache#1362" = Some(((var"##1361").head, (var"##1361").args))
                                end
                                var"##1363" = (var"##cache#1362").value
                                var"##1363" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1363"[1] == :macrocall && (begin
                                        var"##1364" = var"##1363"[2]
                                        var"##1364" isa AbstractArray
                                    end && ((ndims(var"##1364") === 1 && length(var"##1364") >= 2) && begin
                                            var"##1365" = var"##1364"[1]
                                            var"##1366" = var"##1364"[2]
                                            var"##1367" = SubArray(var"##1364", (3:length(var"##1364"),))
                                            true
                                        end)))
                        var"##return#1359" = let line = var"##1366", name = var"##1365", args = var"##1367"
                                Expr(:macrocall, name, line, map(rm_lineinfo, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1360#1372")))
                    end
                    if begin
                                var"##1368" = (var"##cache#1362").value
                                var"##1368" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1369" = var"##1368"[1]
                                    var"##1370" = var"##1368"[2]
                                    var"##1370" isa AbstractArray
                                end && ((ndims(var"##1370") === 1 && length(var"##1370") >= 0) && begin
                                        var"##1371" = SubArray(var"##1370", (1:length(var"##1370"),))
                                        true
                                    end))
                        var"##return#1359" = let args = var"##1371", head = var"##1369"
                                Expr(head, map(rm_lineinfo, filter((x->begin
                                                    !(x isa LineNumberNode)
                                                end), args))...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1360#1372")))
                    end
                end
                begin
                    var"##return#1359" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1360#1372")))
                end
                error("matching non-exhaustive, at #= none:108 =#")
                $(Expr(:symboliclabel, Symbol("####final#1360#1372")))
                var"##return#1359"
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
                    var"##cache#1376" = nothing
                end
                var"##return#1373" = nothing
                var"##1375" = ex
                if var"##1375" isa Expr
                    if begin
                                if var"##cache#1376" === nothing
                                    var"##cache#1376" = Some(((var"##1375").head, (var"##1375").args))
                                end
                                var"##1377" = (var"##cache#1376").value
                                var"##1377" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1377"[1] == :block && (begin
                                        var"##1378" = var"##1377"[2]
                                        var"##1378" isa AbstractArray
                                    end && ((ndims(var"##1378") === 1 && length(var"##1378") >= 0) && begin
                                            var"##1379" = SubArray(var"##1378", (1:length(var"##1378"),))
                                            true
                                        end)))
                        var"##return#1373" = let args = var"##1379"
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
                        $(Expr(:symbolicgoto, Symbol("####final#1374#1384")))
                    end
                    if begin
                                var"##1380" = (var"##cache#1376").value
                                var"##1380" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1381" = var"##1380"[1]
                                    var"##1382" = var"##1380"[2]
                                    var"##1382" isa AbstractArray
                                end && ((ndims(var"##1382") === 1 && length(var"##1382") >= 0) && begin
                                        var"##1383" = SubArray(var"##1382", (1:length(var"##1382"),))
                                        true
                                    end))
                        var"##return#1373" = let args = var"##1383", head = var"##1381"
                                Expr(head, map(rm_nothing, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1374#1384")))
                    end
                end
                begin
                    var"##return#1373" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1374#1384")))
                end
                error("matching non-exhaustive, at #= none:219 =#")
                $(Expr(:symboliclabel, Symbol("####final#1374#1384")))
                var"##return#1373"
            end
        end
    #= none:232 =# Core.@doc "    canonicalize_lambda_head(ex)\n\nCanonicalize the `Expr(:function, Expr(:block, x, Expr(:(=), key, default)), body)` to\n\n```julia\nExpr(:function, Expr(:tuple, Expr(:parameters, Expr(:kw, key, default)), x), body)\n```\n" function canonicalize_lambda_head(ex)
            let
                begin
                    var"##cache#1388" = nothing
                end
                var"##return#1385" = nothing
                var"##1387" = ex
                if var"##1387" isa Expr
                    if begin
                                if var"##cache#1388" === nothing
                                    var"##cache#1388" = Some(((var"##1387").head, (var"##1387").args))
                                end
                                var"##1389" = (var"##cache#1388").value
                                var"##1389" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1389"[1] == :function && (begin
                                        var"##1390" = var"##1389"[2]
                                        var"##1390" isa AbstractArray
                                    end && (length(var"##1390") === 2 && (begin
                                                begin
                                                    var"##cache#1392" = nothing
                                                end
                                                var"##1391" = var"##1390"[1]
                                                var"##1391" isa Expr
                                            end && (begin
                                                    if var"##cache#1392" === nothing
                                                        var"##cache#1392" = Some(((var"##1391").head, (var"##1391").args))
                                                    end
                                                    var"##1393" = (var"##cache#1392").value
                                                    var"##1393" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1393"[1] == :block && (begin
                                                            var"##1394" = var"##1393"[2]
                                                            var"##1394" isa AbstractArray
                                                        end && (length(var"##1394") === 2 && begin
                                                                var"##1395" = var"##1394"[1]
                                                                var"##1396" = var"##1394"[2]
                                                                var"##1397" = var"##1390"[2]
                                                                true
                                                            end))))))))
                        var"##return#1385" = let y = var"##1396", body = var"##1397", x = var"##1395"
                                Expr(:function, Expr(:tuple, Expr(:parameters, y), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1386#1441")))
                    end
                    if begin
                                var"##1398" = (var"##cache#1388").value
                                var"##1398" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1398"[1] == :function && (begin
                                        var"##1399" = var"##1398"[2]
                                        var"##1399" isa AbstractArray
                                    end && (length(var"##1399") === 2 && (begin
                                                begin
                                                    var"##cache#1401" = nothing
                                                end
                                                var"##1400" = var"##1399"[1]
                                                var"##1400" isa Expr
                                            end && (begin
                                                    if var"##cache#1401" === nothing
                                                        var"##cache#1401" = Some(((var"##1400").head, (var"##1400").args))
                                                    end
                                                    var"##1402" = (var"##cache#1401").value
                                                    var"##1402" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1402"[1] == :block && (begin
                                                            var"##1403" = var"##1402"[2]
                                                            var"##1403" isa AbstractArray
                                                        end && (length(var"##1403") === 3 && (begin
                                                                    var"##1404" = var"##1403"[1]
                                                                    var"##1405" = var"##1403"[2]
                                                                    var"##1405" isa LineNumberNode
                                                                end && begin
                                                                    var"##1406" = var"##1403"[3]
                                                                    var"##1407" = var"##1399"[2]
                                                                    true
                                                                end)))))))))
                        var"##return#1385" = let y = var"##1406", body = var"##1407", x = var"##1404"
                                Expr(:function, Expr(:tuple, Expr(:parameters, y), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1386#1441")))
                    end
                    if begin
                                var"##1408" = (var"##cache#1388").value
                                var"##1408" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1408"[1] == :function && (begin
                                        var"##1409" = var"##1408"[2]
                                        var"##1409" isa AbstractArray
                                    end && (length(var"##1409") === 2 && (begin
                                                begin
                                                    var"##cache#1411" = nothing
                                                end
                                                var"##1410" = var"##1409"[1]
                                                var"##1410" isa Expr
                                            end && (begin
                                                    if var"##cache#1411" === nothing
                                                        var"##cache#1411" = Some(((var"##1410").head, (var"##1410").args))
                                                    end
                                                    var"##1412" = (var"##cache#1411").value
                                                    var"##1412" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1412"[1] == :block && (begin
                                                            var"##1413" = var"##1412"[2]
                                                            var"##1413" isa AbstractArray
                                                        end && (length(var"##1413") === 2 && (begin
                                                                    var"##1414" = var"##1413"[1]
                                                                    begin
                                                                        var"##cache#1416" = nothing
                                                                    end
                                                                    var"##1415" = var"##1413"[2]
                                                                    var"##1415" isa Expr
                                                                end && (begin
                                                                        if var"##cache#1416" === nothing
                                                                            var"##cache#1416" = Some(((var"##1415").head, (var"##1415").args))
                                                                        end
                                                                        var"##1417" = (var"##cache#1416").value
                                                                        var"##1417" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                    end && (var"##1417"[1] == :(=) && (begin
                                                                                var"##1418" = var"##1417"[2]
                                                                                var"##1418" isa AbstractArray
                                                                            end && (length(var"##1418") === 2 && begin
                                                                                    var"##1419" = var"##1418"[1]
                                                                                    var"##1420" = var"##1418"[2]
                                                                                    var"##1421" = var"##1409"[2]
                                                                                    true
                                                                                end)))))))))))))
                        var"##return#1385" = let default = var"##1420", key = var"##1419", body = var"##1421", x = var"##1414"
                                Expr(:function, Expr(:tuple, Expr(:parameters, Expr(:kw, key, default)), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1386#1441")))
                    end
                    if begin
                                var"##1422" = (var"##cache#1388").value
                                var"##1422" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1422"[1] == :function && (begin
                                        var"##1423" = var"##1422"[2]
                                        var"##1423" isa AbstractArray
                                    end && (length(var"##1423") === 2 && (begin
                                                begin
                                                    var"##cache#1425" = nothing
                                                end
                                                var"##1424" = var"##1423"[1]
                                                var"##1424" isa Expr
                                            end && (begin
                                                    if var"##cache#1425" === nothing
                                                        var"##cache#1425" = Some(((var"##1424").head, (var"##1424").args))
                                                    end
                                                    var"##1426" = (var"##cache#1425").value
                                                    var"##1426" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1426"[1] == :block && (begin
                                                            var"##1427" = var"##1426"[2]
                                                            var"##1427" isa AbstractArray
                                                        end && (length(var"##1427") === 3 && (begin
                                                                    var"##1428" = var"##1427"[1]
                                                                    var"##1429" = var"##1427"[2]
                                                                    var"##1429" isa LineNumberNode
                                                                end && (begin
                                                                        begin
                                                                            var"##cache#1431" = nothing
                                                                        end
                                                                        var"##1430" = var"##1427"[3]
                                                                        var"##1430" isa Expr
                                                                    end && (begin
                                                                            if var"##cache#1431" === nothing
                                                                                var"##cache#1431" = Some(((var"##1430").head, (var"##1430").args))
                                                                            end
                                                                            var"##1432" = (var"##cache#1431").value
                                                                            var"##1432" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                        end && (var"##1432"[1] == :(=) && (begin
                                                                                    var"##1433" = var"##1432"[2]
                                                                                    var"##1433" isa AbstractArray
                                                                                end && (length(var"##1433") === 2 && begin
                                                                                        var"##1434" = var"##1433"[1]
                                                                                        var"##1435" = var"##1433"[2]
                                                                                        var"##1436" = var"##1423"[2]
                                                                                        true
                                                                                    end))))))))))))))
                        var"##return#1385" = let default = var"##1435", key = var"##1434", body = var"##1436", x = var"##1428"
                                Expr(:function, Expr(:tuple, Expr(:parameters, Expr(:kw, key, default)), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1386#1441")))
                    end
                    if begin
                                var"##1437" = (var"##cache#1388").value
                                var"##1437" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1438" = var"##1437"[1]
                                    var"##1439" = var"##1437"[2]
                                    var"##1439" isa AbstractArray
                                end && ((ndims(var"##1439") === 1 && length(var"##1439") >= 0) && begin
                                        var"##1440" = SubArray(var"##1439", (1:length(var"##1439"),))
                                        true
                                    end))
                        var"##return#1385" = let args = var"##1440", head = var"##1438"
                                Expr(head, map(canonicalize_lambda_head, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1386#1441")))
                    end
                end
                begin
                    var"##return#1385" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1386#1441")))
                end
                error("matching non-exhaustive, at #= none:242 =#")
                $(Expr(:symboliclabel, Symbol("####final#1386#1441")))
                var"##return#1385"
            end
        end
    function rm_single_block(ex)
        let
            begin
                var"##cache#1445" = nothing
            end
            var"##return#1442" = nothing
            var"##1444" = ex
            if var"##1444" isa Expr
                if begin
                            if var"##cache#1445" === nothing
                                var"##cache#1445" = Some(((var"##1444").head, (var"##1444").args))
                            end
                            var"##1446" = (var"##cache#1445").value
                            var"##1446" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1446"[1] == :(=) && (begin
                                    var"##1447" = var"##1446"[2]
                                    var"##1447" isa AbstractArray
                                end && (ndims(var"##1447") === 1 && length(var"##1447") >= 0)))
                    var"##return#1442" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1443#1510")))
                end
                if begin
                            var"##1448" = (var"##cache#1445").value
                            var"##1448" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1448"[1] == :-> && (begin
                                    var"##1449" = var"##1448"[2]
                                    var"##1449" isa AbstractArray
                                end && (ndims(var"##1449") === 1 && length(var"##1449") >= 0)))
                    var"##return#1442" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1443#1510")))
                end
                if begin
                            var"##1450" = (var"##cache#1445").value
                            var"##1450" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1450"[1] == :quote && (begin
                                    var"##1451" = var"##1450"[2]
                                    var"##1451" isa AbstractArray
                                end && ((ndims(var"##1451") === 1 && length(var"##1451") >= 0) && begin
                                        var"##1452" = SubArray(var"##1451", (1:length(var"##1451"),))
                                        true
                                    end)))
                    var"##return#1442" = let xs = var"##1452"
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1443#1510")))
                end
                if begin
                            var"##1453" = (var"##cache#1445").value
                            var"##1453" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1453"[1] == :block && (begin
                                    var"##1454" = var"##1453"[2]
                                    var"##1454" isa AbstractArray
                                end && (length(var"##1454") === 1 && (begin
                                            begin
                                                var"##cache#1456" = nothing
                                            end
                                            var"##1455" = var"##1454"[1]
                                            var"##1455" isa Expr
                                        end && (begin
                                                if var"##cache#1456" === nothing
                                                    var"##cache#1456" = Some(((var"##1455").head, (var"##1455").args))
                                                end
                                                var"##1457" = (var"##cache#1456").value
                                                var"##1457" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1457"[1] == :quote && (begin
                                                        var"##1458" = var"##1457"[2]
                                                        var"##1458" isa AbstractArray
                                                    end && ((ndims(var"##1458") === 1 && length(var"##1458") >= 0) && begin
                                                            var"##1459" = SubArray(var"##1458", (1:length(var"##1458"),))
                                                            true
                                                        end))))))))
                    var"##return#1442" = let xs = var"##1459"
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1443#1510")))
                end
                if begin
                            var"##1460" = (var"##cache#1445").value
                            var"##1460" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1460"[1] == :try && (begin
                                    var"##1461" = var"##1460"[2]
                                    var"##1461" isa AbstractArray
                                end && (length(var"##1461") === 4 && (begin
                                            begin
                                                var"##cache#1463" = nothing
                                            end
                                            var"##1462" = var"##1461"[1]
                                            var"##1462" isa Expr
                                        end && (begin
                                                if var"##cache#1463" === nothing
                                                    var"##cache#1463" = Some(((var"##1462").head, (var"##1462").args))
                                                end
                                                var"##1464" = (var"##cache#1463").value
                                                var"##1464" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1464"[1] == :block && (begin
                                                        var"##1465" = var"##1464"[2]
                                                        var"##1465" isa AbstractArray
                                                    end && ((ndims(var"##1465") === 1 && length(var"##1465") >= 0) && (begin
                                                                var"##1466" = SubArray(var"##1465", (1:length(var"##1465"),))
                                                                var"##1461"[2] === false
                                                            end && (var"##1461"[3] === false && (begin
                                                                        begin
                                                                            var"##cache#1468" = nothing
                                                                        end
                                                                        var"##1467" = var"##1461"[4]
                                                                        var"##1467" isa Expr
                                                                    end && (begin
                                                                            if var"##cache#1468" === nothing
                                                                                var"##cache#1468" = Some(((var"##1467").head, (var"##1467").args))
                                                                            end
                                                                            var"##1469" = (var"##cache#1468").value
                                                                            var"##1469" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                        end && (var"##1469"[1] == :block && (begin
                                                                                    var"##1470" = var"##1469"[2]
                                                                                    var"##1470" isa AbstractArray
                                                                                end && ((ndims(var"##1470") === 1 && length(var"##1470") >= 0) && begin
                                                                                        var"##1471" = SubArray(var"##1470", (1:length(var"##1470"),))
                                                                                        true
                                                                                    end)))))))))))))))
                    var"##return#1442" = let try_stmts = var"##1466", finally_stmts = var"##1471"
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), false, false, Expr(:block, rm_single_block.(finally_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1443#1510")))
                end
                if begin
                            var"##1472" = (var"##cache#1445").value
                            var"##1472" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1472"[1] == :try && (begin
                                    var"##1473" = var"##1472"[2]
                                    var"##1473" isa AbstractArray
                                end && (length(var"##1473") === 3 && (begin
                                            begin
                                                var"##cache#1475" = nothing
                                            end
                                            var"##1474" = var"##1473"[1]
                                            var"##1474" isa Expr
                                        end && (begin
                                                if var"##cache#1475" === nothing
                                                    var"##cache#1475" = Some(((var"##1474").head, (var"##1474").args))
                                                end
                                                var"##1476" = (var"##cache#1475").value
                                                var"##1476" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1476"[1] == :block && (begin
                                                        var"##1477" = var"##1476"[2]
                                                        var"##1477" isa AbstractArray
                                                    end && ((ndims(var"##1477") === 1 && length(var"##1477") >= 0) && (begin
                                                                var"##1478" = SubArray(var"##1477", (1:length(var"##1477"),))
                                                                var"##1479" = var"##1473"[2]
                                                                begin
                                                                    var"##cache#1481" = nothing
                                                                end
                                                                var"##1480" = var"##1473"[3]
                                                                var"##1480" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1481" === nothing
                                                                        var"##cache#1481" = Some(((var"##1480").head, (var"##1480").args))
                                                                    end
                                                                    var"##1482" = (var"##cache#1481").value
                                                                    var"##1482" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1482"[1] == :block && (begin
                                                                            var"##1483" = var"##1482"[2]
                                                                            var"##1483" isa AbstractArray
                                                                        end && ((ndims(var"##1483") === 1 && length(var"##1483") >= 0) && begin
                                                                                var"##1484" = SubArray(var"##1483", (1:length(var"##1483"),))
                                                                                true
                                                                            end)))))))))))))
                    var"##return#1442" = let try_stmts = var"##1478", catch_stmts = var"##1484", catch_var = var"##1479"
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), catch_var, Expr(:block, rm_single_block.(catch_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1443#1510")))
                end
                if begin
                            var"##1485" = (var"##cache#1445").value
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
                                                                var"##1492" = var"##1486"[2]
                                                                begin
                                                                    var"##cache#1494" = nothing
                                                                end
                                                                var"##1493" = var"##1486"[3]
                                                                var"##1493" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1494" === nothing
                                                                        var"##cache#1494" = Some(((var"##1493").head, (var"##1493").args))
                                                                    end
                                                                    var"##1495" = (var"##cache#1494").value
                                                                    var"##1495" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1495"[1] == :block && (begin
                                                                            var"##1496" = var"##1495"[2]
                                                                            var"##1496" isa AbstractArray
                                                                        end && ((ndims(var"##1496") === 1 && length(var"##1496") >= 0) && (begin
                                                                                    var"##1497" = SubArray(var"##1496", (1:length(var"##1496"),))
                                                                                    begin
                                                                                        var"##cache#1499" = nothing
                                                                                    end
                                                                                    var"##1498" = var"##1486"[4]
                                                                                    var"##1498" isa Expr
                                                                                end && (begin
                                                                                        if var"##cache#1499" === nothing
                                                                                            var"##cache#1499" = Some(((var"##1498").head, (var"##1498").args))
                                                                                        end
                                                                                        var"##1500" = (var"##cache#1499").value
                                                                                        var"##1500" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                                    end && (var"##1500"[1] == :block && (begin
                                                                                                var"##1501" = var"##1500"[2]
                                                                                                var"##1501" isa AbstractArray
                                                                                            end && ((ndims(var"##1501") === 1 && length(var"##1501") >= 0) && begin
                                                                                                    var"##1502" = SubArray(var"##1501", (1:length(var"##1501"),))
                                                                                                    true
                                                                                                end))))))))))))))))))
                    var"##return#1442" = let try_stmts = var"##1491", catch_stmts = var"##1497", catch_var = var"##1492", finally_stmts = var"##1502"
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), catch_var, Expr(:block, rm_single_block.(catch_stmts)...), Expr(:block, rm_single_block.(finally_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1443#1510")))
                end
                if begin
                            var"##1503" = (var"##cache#1445").value
                            var"##1503" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1503"[1] == :block && (begin
                                    var"##1504" = var"##1503"[2]
                                    var"##1504" isa AbstractArray
                                end && (length(var"##1504") === 1 && begin
                                        var"##1505" = var"##1504"[1]
                                        true
                                    end)))
                    var"##return#1442" = let stmt = var"##1505"
                            stmt
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1443#1510")))
                end
                if begin
                            var"##1506" = (var"##cache#1445").value
                            var"##1506" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                        end && (begin
                                var"##1507" = var"##1506"[1]
                                var"##1508" = var"##1506"[2]
                                var"##1508" isa AbstractArray
                            end && ((ndims(var"##1508") === 1 && length(var"##1508") >= 0) && begin
                                    var"##1509" = SubArray(var"##1508", (1:length(var"##1508"),))
                                    true
                                end))
                    var"##return#1442" = let args = var"##1509", head = var"##1507"
                            Expr(head, map(rm_single_block, args)...)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1443#1510")))
                end
            end
            begin
                var"##return#1442" = let
                        ex
                    end
                $(Expr(:symbolicgoto, Symbol("####final#1443#1510")))
            end
            error("matching non-exhaustive, at #= none:258 =#")
            $(Expr(:symboliclabel, Symbol("####final#1443#1510")))
            var"##return#1442"
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
