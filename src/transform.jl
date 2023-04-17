
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
            ex.head === :module && return name_only(ex.args[2])
            error("unsupported expression $(ex)")
        end
    #= none:82 =# Core.@doc "    annotations_only(ex)\n\nReturn type annotations only. See also [`name_only`](@ref).\n" function annotations_only(#= none:87 =# @nospecialize(ex))
            ex isa Symbol && return :(())
            ex isa Expr || error("unsupported expression $(ex)")
            Meta.isexpr(ex, :(::)) && return ex.args[end]
            error("unsupported expression $(ex)")
        end
    #= none:94 =# Core.@doc "    rm_lineinfo(ex)\n\nRemove `LineNumberNode` in a given expression.\n\n!!! tips\n\n    the `LineNumberNode` inside macro calls won't be removed since\n    the `macrocall` expression requires a `LineNumberNode`. See also\n    [issues/#9](https://github.com/Roger-luo/Expronicon.jl/issues/9).\n" function rm_lineinfo(ex)
            let
                begin
                    var"##cache#1334" = nothing
                end
                var"##return#1331" = nothing
                var"##1333" = ex
                if var"##1333" isa Expr
                    if begin
                                if var"##cache#1334" === nothing
                                    var"##cache#1334" = Some(((var"##1333").head, (var"##1333").args))
                                end
                                var"##1335" = (var"##cache#1334").value
                                var"##1335" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1335"[1] == :macrocall && (begin
                                        var"##1336" = var"##1335"[2]
                                        var"##1336" isa AbstractArray
                                    end && ((ndims(var"##1336") === 1 && length(var"##1336") >= 2) && begin
                                            var"##1337" = var"##1336"[1]
                                            var"##1338" = var"##1336"[2]
                                            var"##1339" = SubArray(var"##1336", (3:length(var"##1336"),))
                                            true
                                        end)))
                        var"##return#1331" = let line = var"##1338", name = var"##1337", args = var"##1339"
                                Expr(:macrocall, name, line, map(rm_lineinfo, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1332#1344")))
                    end
                    if begin
                                var"##1340" = (var"##cache#1334").value
                                var"##1340" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1341" = var"##1340"[1]
                                    var"##1342" = var"##1340"[2]
                                    var"##1342" isa AbstractArray
                                end && ((ndims(var"##1342") === 1 && length(var"##1342") >= 0) && begin
                                        var"##1343" = SubArray(var"##1342", (1:length(var"##1342"),))
                                        true
                                    end))
                        var"##return#1331" = let args = var"##1343", head = var"##1341"
                                Expr(head, map(rm_lineinfo, filter((x->begin
                                                    !(x isa LineNumberNode)
                                                end), args))...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1332#1344")))
                    end
                end
                begin
                    var"##return#1331" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1332#1344")))
                end
                error("matching non-exhaustive, at #= none:106 =#")
                $(Expr(:symboliclabel, Symbol("####final#1332#1344")))
                var"##return#1331"
            end
        end
    #= none:113 =# Base.@kwdef struct PrettifyOptions
            rm_lineinfo::Bool = true
            flatten_blocks::Bool = true
            rm_nothing::Bool = true
            preserve_last_nothing::Bool = false
            rm_single_block::Bool = true
            alias_gensym::Bool = true
            renumber_gensym::Bool = true
        end
    #= none:123 =# Core.@doc "    prettify(ex; kw...)\n\nPrettify given expression, remove all `LineNumberNode` and\nextra code blocks.\n\n# Options (Kwargs)\n\nAll the options are `true` by default.\n\n- `rm_lineinfo`: remove `LineNumberNode`.\n- `flatten_blocks`: flatten `begin ... end` code blocks.\n- `rm_nothing`: remove `nothing` in the `begin ... end`.\n- `preserve_last_nothing`: preserve the last `nothing` in the `begin ... end`.\n- `rm_single_block`: remove single `begin ... end`.\n- `alias_gensym`: replace `##<name>#<num>` with `<name>_<id>`.\n- `renumber_gensym`: renumber the gensym id.\n\n!!! tips\n\n    the `LineNumberNode` inside macro calls won't be removed since\n    the `macrocall` expression requires a `LineNumberNode`. See also\n    [issues/#9](https://github.com/Roger-luo/Expronicon.jl/issues/9).\n" function prettify(ex; kw...)
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
    #= none:171 =# Core.@doc "    flatten_blocks(ex)\n\nRemove hierachical expression blocks.\n" function flatten_blocks(ex)
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
    #= none:206 =# Core.@doc "    rm_nothing(ex)\n\nRemove the constant value `nothing` in given expression `ex`.\n\n# Keyword Arguments\n\n- `preserve_last_nothing`: if `true`, the last `nothing`\n    will be preserved.\n" function rm_nothing(ex; preserve_last_nothing::Bool = false)
            let
                begin
                    var"##cache#1348" = nothing
                end
                var"##return#1345" = nothing
                var"##1347" = ex
                if var"##1347" isa Expr
                    if begin
                                if var"##cache#1348" === nothing
                                    var"##cache#1348" = Some(((var"##1347").head, (var"##1347").args))
                                end
                                var"##1349" = (var"##cache#1348").value
                                var"##1349" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1349"[1] == :block && (begin
                                        var"##1350" = var"##1349"[2]
                                        var"##1350" isa AbstractArray
                                    end && ((ndims(var"##1350") === 1 && length(var"##1350") >= 0) && begin
                                            var"##1351" = SubArray(var"##1350", (1:length(var"##1350"),))
                                            true
                                        end)))
                        var"##return#1345" = let args = var"##1351"
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
                        $(Expr(:symbolicgoto, Symbol("####final#1346#1356")))
                    end
                    if begin
                                var"##1352" = (var"##cache#1348").value
                                var"##1352" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1353" = var"##1352"[1]
                                    var"##1354" = var"##1352"[2]
                                    var"##1354" isa AbstractArray
                                end && ((ndims(var"##1354") === 1 && length(var"##1354") >= 0) && begin
                                        var"##1355" = SubArray(var"##1354", (1:length(var"##1354"),))
                                        true
                                    end))
                        var"##return#1345" = let args = var"##1355", head = var"##1353"
                                Expr(head, map(rm_nothing, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1346#1356")))
                    end
                end
                begin
                    var"##return#1345" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1346#1356")))
                end
                error("matching non-exhaustive, at #= none:217 =#")
                $(Expr(:symboliclabel, Symbol("####final#1346#1356")))
                var"##return#1345"
            end
        end
    #= none:230 =# Core.@doc "    canonicalize_lambda_head(ex)\n\nCanonicalize the `Expr(:function, Expr(:block, x, Expr(:(=), key, default)), body)` to\n\n```julia\nExpr(:function, Expr(:tuple, Expr(:parameters, Expr(:kw, key, default)), x), body)\n```\n" function canonicalize_lambda_head(ex)
            let
                begin
                    var"##cache#1360" = nothing
                end
                var"##return#1357" = nothing
                var"##1359" = ex
                if var"##1359" isa Expr
                    if begin
                                if var"##cache#1360" === nothing
                                    var"##cache#1360" = Some(((var"##1359").head, (var"##1359").args))
                                end
                                var"##1361" = (var"##cache#1360").value
                                var"##1361" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1361"[1] == :function && (begin
                                        var"##1362" = var"##1361"[2]
                                        var"##1362" isa AbstractArray
                                    end && (length(var"##1362") === 2 && (begin
                                                begin
                                                    var"##cache#1364" = nothing
                                                end
                                                var"##1363" = var"##1362"[1]
                                                var"##1363" isa Expr
                                            end && (begin
                                                    if var"##cache#1364" === nothing
                                                        var"##cache#1364" = Some(((var"##1363").head, (var"##1363").args))
                                                    end
                                                    var"##1365" = (var"##cache#1364").value
                                                    var"##1365" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1365"[1] == :block && (begin
                                                            var"##1366" = var"##1365"[2]
                                                            var"##1366" isa AbstractArray
                                                        end && (length(var"##1366") === 2 && begin
                                                                var"##1367" = var"##1366"[1]
                                                                var"##1368" = var"##1366"[2]
                                                                var"##1369" = var"##1362"[2]
                                                                true
                                                            end))))))))
                        var"##return#1357" = let y = var"##1368", body = var"##1369", x = var"##1367"
                                Expr(:function, Expr(:tuple, Expr(:parameters, y), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1358#1413")))
                    end
                    if begin
                                var"##1370" = (var"##cache#1360").value
                                var"##1370" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1370"[1] == :function && (begin
                                        var"##1371" = var"##1370"[2]
                                        var"##1371" isa AbstractArray
                                    end && (length(var"##1371") === 2 && (begin
                                                begin
                                                    var"##cache#1373" = nothing
                                                end
                                                var"##1372" = var"##1371"[1]
                                                var"##1372" isa Expr
                                            end && (begin
                                                    if var"##cache#1373" === nothing
                                                        var"##cache#1373" = Some(((var"##1372").head, (var"##1372").args))
                                                    end
                                                    var"##1374" = (var"##cache#1373").value
                                                    var"##1374" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1374"[1] == :block && (begin
                                                            var"##1375" = var"##1374"[2]
                                                            var"##1375" isa AbstractArray
                                                        end && (length(var"##1375") === 3 && (begin
                                                                    var"##1376" = var"##1375"[1]
                                                                    var"##1377" = var"##1375"[2]
                                                                    var"##1377" isa LineNumberNode
                                                                end && begin
                                                                    var"##1378" = var"##1375"[3]
                                                                    var"##1379" = var"##1371"[2]
                                                                    true
                                                                end)))))))))
                        var"##return#1357" = let y = var"##1378", body = var"##1379", x = var"##1376"
                                Expr(:function, Expr(:tuple, Expr(:parameters, y), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1358#1413")))
                    end
                    if begin
                                var"##1380" = (var"##cache#1360").value
                                var"##1380" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1380"[1] == :function && (begin
                                        var"##1381" = var"##1380"[2]
                                        var"##1381" isa AbstractArray
                                    end && (length(var"##1381") === 2 && (begin
                                                begin
                                                    var"##cache#1383" = nothing
                                                end
                                                var"##1382" = var"##1381"[1]
                                                var"##1382" isa Expr
                                            end && (begin
                                                    if var"##cache#1383" === nothing
                                                        var"##cache#1383" = Some(((var"##1382").head, (var"##1382").args))
                                                    end
                                                    var"##1384" = (var"##cache#1383").value
                                                    var"##1384" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1384"[1] == :block && (begin
                                                            var"##1385" = var"##1384"[2]
                                                            var"##1385" isa AbstractArray
                                                        end && (length(var"##1385") === 2 && (begin
                                                                    var"##1386" = var"##1385"[1]
                                                                    begin
                                                                        var"##cache#1388" = nothing
                                                                    end
                                                                    var"##1387" = var"##1385"[2]
                                                                    var"##1387" isa Expr
                                                                end && (begin
                                                                        if var"##cache#1388" === nothing
                                                                            var"##cache#1388" = Some(((var"##1387").head, (var"##1387").args))
                                                                        end
                                                                        var"##1389" = (var"##cache#1388").value
                                                                        var"##1389" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                    end && (var"##1389"[1] == :(=) && (begin
                                                                                var"##1390" = var"##1389"[2]
                                                                                var"##1390" isa AbstractArray
                                                                            end && (length(var"##1390") === 2 && begin
                                                                                    var"##1391" = var"##1390"[1]
                                                                                    var"##1392" = var"##1390"[2]
                                                                                    var"##1393" = var"##1381"[2]
                                                                                    true
                                                                                end)))))))))))))
                        var"##return#1357" = let default = var"##1392", key = var"##1391", body = var"##1393", x = var"##1386"
                                Expr(:function, Expr(:tuple, Expr(:parameters, Expr(:kw, key, default)), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1358#1413")))
                    end
                    if begin
                                var"##1394" = (var"##cache#1360").value
                                var"##1394" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1394"[1] == :function && (begin
                                        var"##1395" = var"##1394"[2]
                                        var"##1395" isa AbstractArray
                                    end && (length(var"##1395") === 2 && (begin
                                                begin
                                                    var"##cache#1397" = nothing
                                                end
                                                var"##1396" = var"##1395"[1]
                                                var"##1396" isa Expr
                                            end && (begin
                                                    if var"##cache#1397" === nothing
                                                        var"##cache#1397" = Some(((var"##1396").head, (var"##1396").args))
                                                    end
                                                    var"##1398" = (var"##cache#1397").value
                                                    var"##1398" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1398"[1] == :block && (begin
                                                            var"##1399" = var"##1398"[2]
                                                            var"##1399" isa AbstractArray
                                                        end && (length(var"##1399") === 3 && (begin
                                                                    var"##1400" = var"##1399"[1]
                                                                    var"##1401" = var"##1399"[2]
                                                                    var"##1401" isa LineNumberNode
                                                                end && (begin
                                                                        begin
                                                                            var"##cache#1403" = nothing
                                                                        end
                                                                        var"##1402" = var"##1399"[3]
                                                                        var"##1402" isa Expr
                                                                    end && (begin
                                                                            if var"##cache#1403" === nothing
                                                                                var"##cache#1403" = Some(((var"##1402").head, (var"##1402").args))
                                                                            end
                                                                            var"##1404" = (var"##cache#1403").value
                                                                            var"##1404" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                        end && (var"##1404"[1] == :(=) && (begin
                                                                                    var"##1405" = var"##1404"[2]
                                                                                    var"##1405" isa AbstractArray
                                                                                end && (length(var"##1405") === 2 && begin
                                                                                        var"##1406" = var"##1405"[1]
                                                                                        var"##1407" = var"##1405"[2]
                                                                                        var"##1408" = var"##1395"[2]
                                                                                        true
                                                                                    end))))))))))))))
                        var"##return#1357" = let default = var"##1407", key = var"##1406", body = var"##1408", x = var"##1400"
                                Expr(:function, Expr(:tuple, Expr(:parameters, Expr(:kw, key, default)), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1358#1413")))
                    end
                    if begin
                                var"##1409" = (var"##cache#1360").value
                                var"##1409" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1410" = var"##1409"[1]
                                    var"##1411" = var"##1409"[2]
                                    var"##1411" isa AbstractArray
                                end && ((ndims(var"##1411") === 1 && length(var"##1411") >= 0) && begin
                                        var"##1412" = SubArray(var"##1411", (1:length(var"##1411"),))
                                        true
                                    end))
                        var"##return#1357" = let args = var"##1412", head = var"##1410"
                                Expr(head, map(canonicalize_lambda_head, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1358#1413")))
                    end
                end
                begin
                    var"##return#1357" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1358#1413")))
                end
                error("matching non-exhaustive, at #= none:240 =#")
                $(Expr(:symboliclabel, Symbol("####final#1358#1413")))
                var"##return#1357"
            end
        end
    function rm_single_block(ex)
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
                        end && (var"##1418"[1] == :(=) && (begin
                                    var"##1419" = var"##1418"[2]
                                    var"##1419" isa AbstractArray
                                end && (ndims(var"##1419") === 1 && length(var"##1419") >= 0)))
                    var"##return#1414" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1415#1482")))
                end
                if begin
                            var"##1420" = (var"##cache#1417").value
                            var"##1420" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1420"[1] == :-> && (begin
                                    var"##1421" = var"##1420"[2]
                                    var"##1421" isa AbstractArray
                                end && (ndims(var"##1421") === 1 && length(var"##1421") >= 0)))
                    var"##return#1414" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1415#1482")))
                end
                if begin
                            var"##1422" = (var"##cache#1417").value
                            var"##1422" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1422"[1] == :quote && (begin
                                    var"##1423" = var"##1422"[2]
                                    var"##1423" isa AbstractArray
                                end && ((ndims(var"##1423") === 1 && length(var"##1423") >= 0) && begin
                                        var"##1424" = SubArray(var"##1423", (1:length(var"##1423"),))
                                        true
                                    end)))
                    var"##return#1414" = let xs = var"##1424"
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1415#1482")))
                end
                if begin
                            var"##1425" = (var"##cache#1417").value
                            var"##1425" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1425"[1] == :block && (begin
                                    var"##1426" = var"##1425"[2]
                                    var"##1426" isa AbstractArray
                                end && (length(var"##1426") === 1 && (begin
                                            begin
                                                var"##cache#1428" = nothing
                                            end
                                            var"##1427" = var"##1426"[1]
                                            var"##1427" isa Expr
                                        end && (begin
                                                if var"##cache#1428" === nothing
                                                    var"##cache#1428" = Some(((var"##1427").head, (var"##1427").args))
                                                end
                                                var"##1429" = (var"##cache#1428").value
                                                var"##1429" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1429"[1] == :quote && (begin
                                                        var"##1430" = var"##1429"[2]
                                                        var"##1430" isa AbstractArray
                                                    end && ((ndims(var"##1430") === 1 && length(var"##1430") >= 0) && begin
                                                            var"##1431" = SubArray(var"##1430", (1:length(var"##1430"),))
                                                            true
                                                        end))))))))
                    var"##return#1414" = let xs = var"##1431"
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1415#1482")))
                end
                if begin
                            var"##1432" = (var"##cache#1417").value
                            var"##1432" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1432"[1] == :try && (begin
                                    var"##1433" = var"##1432"[2]
                                    var"##1433" isa AbstractArray
                                end && (length(var"##1433") === 4 && (begin
                                            begin
                                                var"##cache#1435" = nothing
                                            end
                                            var"##1434" = var"##1433"[1]
                                            var"##1434" isa Expr
                                        end && (begin
                                                if var"##cache#1435" === nothing
                                                    var"##cache#1435" = Some(((var"##1434").head, (var"##1434").args))
                                                end
                                                var"##1436" = (var"##cache#1435").value
                                                var"##1436" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1436"[1] == :block && (begin
                                                        var"##1437" = var"##1436"[2]
                                                        var"##1437" isa AbstractArray
                                                    end && ((ndims(var"##1437") === 1 && length(var"##1437") >= 0) && (begin
                                                                var"##1438" = SubArray(var"##1437", (1:length(var"##1437"),))
                                                                var"##1433"[2] === false
                                                            end && (var"##1433"[3] === false && (begin
                                                                        begin
                                                                            var"##cache#1440" = nothing
                                                                        end
                                                                        var"##1439" = var"##1433"[4]
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
                                                                                end && ((ndims(var"##1442") === 1 && length(var"##1442") >= 0) && begin
                                                                                        var"##1443" = SubArray(var"##1442", (1:length(var"##1442"),))
                                                                                        true
                                                                                    end)))))))))))))))
                    var"##return#1414" = let try_stmts = var"##1438", finally_stmts = var"##1443"
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), false, false, Expr(:block, rm_single_block.(finally_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1415#1482")))
                end
                if begin
                            var"##1444" = (var"##cache#1417").value
                            var"##1444" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1444"[1] == :try && (begin
                                    var"##1445" = var"##1444"[2]
                                    var"##1445" isa AbstractArray
                                end && (length(var"##1445") === 3 && (begin
                                            begin
                                                var"##cache#1447" = nothing
                                            end
                                            var"##1446" = var"##1445"[1]
                                            var"##1446" isa Expr
                                        end && (begin
                                                if var"##cache#1447" === nothing
                                                    var"##cache#1447" = Some(((var"##1446").head, (var"##1446").args))
                                                end
                                                var"##1448" = (var"##cache#1447").value
                                                var"##1448" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1448"[1] == :block && (begin
                                                        var"##1449" = var"##1448"[2]
                                                        var"##1449" isa AbstractArray
                                                    end && ((ndims(var"##1449") === 1 && length(var"##1449") >= 0) && (begin
                                                                var"##1450" = SubArray(var"##1449", (1:length(var"##1449"),))
                                                                var"##1451" = var"##1445"[2]
                                                                begin
                                                                    var"##cache#1453" = nothing
                                                                end
                                                                var"##1452" = var"##1445"[3]
                                                                var"##1452" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1453" === nothing
                                                                        var"##cache#1453" = Some(((var"##1452").head, (var"##1452").args))
                                                                    end
                                                                    var"##1454" = (var"##cache#1453").value
                                                                    var"##1454" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1454"[1] == :block && (begin
                                                                            var"##1455" = var"##1454"[2]
                                                                            var"##1455" isa AbstractArray
                                                                        end && ((ndims(var"##1455") === 1 && length(var"##1455") >= 0) && begin
                                                                                var"##1456" = SubArray(var"##1455", (1:length(var"##1455"),))
                                                                                true
                                                                            end)))))))))))))
                    var"##return#1414" = let try_stmts = var"##1450", catch_stmts = var"##1456", catch_var = var"##1451"
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), catch_var, Expr(:block, rm_single_block.(catch_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1415#1482")))
                end
                if begin
                            var"##1457" = (var"##cache#1417").value
                            var"##1457" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1457"[1] == :try && (begin
                                    var"##1458" = var"##1457"[2]
                                    var"##1458" isa AbstractArray
                                end && (length(var"##1458") === 4 && (begin
                                            begin
                                                var"##cache#1460" = nothing
                                            end
                                            var"##1459" = var"##1458"[1]
                                            var"##1459" isa Expr
                                        end && (begin
                                                if var"##cache#1460" === nothing
                                                    var"##cache#1460" = Some(((var"##1459").head, (var"##1459").args))
                                                end
                                                var"##1461" = (var"##cache#1460").value
                                                var"##1461" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1461"[1] == :block && (begin
                                                        var"##1462" = var"##1461"[2]
                                                        var"##1462" isa AbstractArray
                                                    end && ((ndims(var"##1462") === 1 && length(var"##1462") >= 0) && (begin
                                                                var"##1463" = SubArray(var"##1462", (1:length(var"##1462"),))
                                                                var"##1464" = var"##1458"[2]
                                                                begin
                                                                    var"##cache#1466" = nothing
                                                                end
                                                                var"##1465" = var"##1458"[3]
                                                                var"##1465" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1466" === nothing
                                                                        var"##cache#1466" = Some(((var"##1465").head, (var"##1465").args))
                                                                    end
                                                                    var"##1467" = (var"##cache#1466").value
                                                                    var"##1467" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1467"[1] == :block && (begin
                                                                            var"##1468" = var"##1467"[2]
                                                                            var"##1468" isa AbstractArray
                                                                        end && ((ndims(var"##1468") === 1 && length(var"##1468") >= 0) && (begin
                                                                                    var"##1469" = SubArray(var"##1468", (1:length(var"##1468"),))
                                                                                    begin
                                                                                        var"##cache#1471" = nothing
                                                                                    end
                                                                                    var"##1470" = var"##1458"[4]
                                                                                    var"##1470" isa Expr
                                                                                end && (begin
                                                                                        if var"##cache#1471" === nothing
                                                                                            var"##cache#1471" = Some(((var"##1470").head, (var"##1470").args))
                                                                                        end
                                                                                        var"##1472" = (var"##cache#1471").value
                                                                                        var"##1472" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                                    end && (var"##1472"[1] == :block && (begin
                                                                                                var"##1473" = var"##1472"[2]
                                                                                                var"##1473" isa AbstractArray
                                                                                            end && ((ndims(var"##1473") === 1 && length(var"##1473") >= 0) && begin
                                                                                                    var"##1474" = SubArray(var"##1473", (1:length(var"##1473"),))
                                                                                                    true
                                                                                                end))))))))))))))))))
                    var"##return#1414" = let try_stmts = var"##1463", catch_stmts = var"##1469", catch_var = var"##1464", finally_stmts = var"##1474"
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), catch_var, Expr(:block, rm_single_block.(catch_stmts)...), Expr(:block, rm_single_block.(finally_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1415#1482")))
                end
                if begin
                            var"##1475" = (var"##cache#1417").value
                            var"##1475" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1475"[1] == :block && (begin
                                    var"##1476" = var"##1475"[2]
                                    var"##1476" isa AbstractArray
                                end && (length(var"##1476") === 1 && begin
                                        var"##1477" = var"##1476"[1]
                                        true
                                    end)))
                    var"##return#1414" = let stmt = var"##1477"
                            stmt
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1415#1482")))
                end
                if begin
                            var"##1478" = (var"##cache#1417").value
                            var"##1478" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                        end && (begin
                                var"##1479" = var"##1478"[1]
                                var"##1480" = var"##1478"[2]
                                var"##1480" isa AbstractArray
                            end && ((ndims(var"##1480") === 1 && length(var"##1480") >= 0) && begin
                                    var"##1481" = SubArray(var"##1480", (1:length(var"##1480"),))
                                    true
                                end))
                    var"##return#1414" = let args = var"##1481", head = var"##1479"
                            Expr(head, map(rm_single_block, args)...)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1415#1482")))
                end
            end
            begin
                var"##return#1414" = let
                        ex
                    end
                $(Expr(:symbolicgoto, Symbol("####final#1415#1482")))
            end
            error("matching non-exhaustive, at #= none:256 =#")
            $(Expr(:symboliclabel, Symbol("####final#1415#1482")))
            var"##return#1414"
        end
    end
    #= none:284 =# Core.@doc "    rm_annotations(x)\n\nRemove type annotation of given expression.\n" function rm_annotations(x)
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
    #= none:304 =# Core.@doc "    alias_gensym(ex)\n\nReplace gensym with `<name>_<id>`.\n\n!!! note\n    Borrowed from [MacroTools](https://github.com/FluxML/MacroTools.jl).\n" alias_gensym(ex) = begin
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
    #= none:332 =# Core.@doc "    renumber_gensym(ex)\n\nRe-number gensym with counter from this expression.\nProduce a deterministic gensym name for testing etc.\nSee also: [`alias_gensym`](@ref)\n" renumber_gensym(ex) = begin
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
    #= none:366 =# Core.@doc "    expr_map(f, c...)\n\nSimilar to `Base.map`, but expects `f` to return an expression,\nand will concanate these expression as a `Expr(:block, ...)`\nexpression.\n\n# Example\n\n```jldoctest\njulia> expr_map(1:10, 2:11) do i,j\n           :(1 + \$i + \$j)\n       end\nquote\n    1 + 1 + 2\n    1 + 2 + 3\n    1 + 3 + 4\n    1 + 4 + 5\n    1 + 5 + 6\n    1 + 6 + 7\n    1 + 7 + 8\n    1 + 8 + 9\n    1 + 9 + 10\n    1 + 10 + 11\nend\n```\n" function expr_map(f, c...)
            ex = Expr(:block)
            for args = zip(c...)
                push!(ex.args, f(args...))
            end
            return ex
        end
    #= none:401 =# Core.@doc "    nexprs(f, n::Int)\n\nCreate `n` similar expressions by evaluating `f`.\n\n# Example\n\n```jldoctest\njulia> nexprs(5) do k\n           :(1 + \$k)\n       end\nquote\n    1 + 1\n    1 + 2\n    1 + 3\n    1 + 4\n    1 + 5\nend\n```\n" nexprs(f, k::Int) = begin
                expr_map(f, 1:k)
            end
    #= none:423 =# Core.@doc "    Substitute(condition) -> substitute(f(expr), expr)\n\nReturns a function that substitutes `expr` with\n`f(expr)` if `condition(expr)` is true. Applied\nrecursively to all sub-expressions.\n\n# Example\n\n```jldoctest\njulia> sub = Substitute() do expr\n           expr isa Symbol && expr in [:x] && return true\n           return false\n       end;\n\njulia> sub(_->1, :(x + y))\n:(1 + y)\n```\n" struct Substitute
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
