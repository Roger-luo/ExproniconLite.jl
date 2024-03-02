
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
                    var"##cache#1320" = nothing
                end
                var"##return#1317" = nothing
                var"##1319" = ex
                if var"##1319" isa Expr
                    if begin
                                if var"##cache#1320" === nothing
                                    var"##cache#1320" = Some(((var"##1319").head, (var"##1319").args))
                                end
                                var"##1321" = (var"##cache#1320").value
                                var"##1321" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1321"[1] == :macrocall && (begin
                                        var"##1322" = var"##1321"[2]
                                        var"##1322" isa AbstractArray
                                    end && ((ndims(var"##1322") === 1 && length(var"##1322") >= 2) && begin
                                            var"##1323" = var"##1322"[1]
                                            var"##1324" = var"##1322"[2]
                                            var"##1325" = SubArray(var"##1322", (3:length(var"##1322"),))
                                            true
                                        end)))
                        var"##return#1317" = let line = var"##1324", name = var"##1323", args = var"##1325"
                                Expr(:macrocall, name, line, map(rm_lineinfo, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1318#1330")))
                    end
                    if begin
                                var"##1326" = (var"##cache#1320").value
                                var"##1326" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1327" = var"##1326"[1]
                                    var"##1328" = var"##1326"[2]
                                    var"##1328" isa AbstractArray
                                end && ((ndims(var"##1328") === 1 && length(var"##1328") >= 0) && begin
                                        var"##1329" = SubArray(var"##1328", (1:length(var"##1328"),))
                                        true
                                    end))
                        var"##return#1317" = let args = var"##1329", head = var"##1327"
                                Expr(head, map(rm_lineinfo, filter((x->begin
                                                    !(x isa LineNumberNode)
                                                end), args))...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1318#1330")))
                    end
                end
                begin
                    var"##return#1317" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1318#1330")))
                end
                error("matching non-exhaustive, at #= none:108 =#")
                $(Expr(:symboliclabel, Symbol("####final#1318#1330")))
                var"##return#1317"
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
                            end && (var"##1335"[1] == :block && (begin
                                        var"##1336" = var"##1335"[2]
                                        var"##1336" isa AbstractArray
                                    end && ((ndims(var"##1336") === 1 && length(var"##1336") >= 0) && begin
                                            var"##1337" = SubArray(var"##1336", (1:length(var"##1336"),))
                                            true
                                        end)))
                        var"##return#1331" = let args = var"##1337"
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
                        $(Expr(:symbolicgoto, Symbol("####final#1332#1342")))
                    end
                    if begin
                                var"##1338" = (var"##cache#1334").value
                                var"##1338" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1339" = var"##1338"[1]
                                    var"##1340" = var"##1338"[2]
                                    var"##1340" isa AbstractArray
                                end && ((ndims(var"##1340") === 1 && length(var"##1340") >= 0) && begin
                                        var"##1341" = SubArray(var"##1340", (1:length(var"##1340"),))
                                        true
                                    end))
                        var"##return#1331" = let args = var"##1341", head = var"##1339"
                                Expr(head, map(rm_nothing, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1332#1342")))
                    end
                end
                begin
                    var"##return#1331" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1332#1342")))
                end
                error("matching non-exhaustive, at #= none:219 =#")
                $(Expr(:symboliclabel, Symbol("####final#1332#1342")))
                var"##return#1331"
            end
        end
    #= none:232 =# Core.@doc "    canonicalize_lambda_head(ex)\n\nCanonicalize the `Expr(:function, Expr(:block, x, Expr(:(=), key, default)), body)` to\n\n```julia\nExpr(:function, Expr(:tuple, Expr(:parameters, Expr(:kw, key, default)), x), body)\n```\n" function canonicalize_lambda_head(ex)
            let
                begin
                    var"##cache#1346" = nothing
                end
                var"##return#1343" = nothing
                var"##1345" = ex
                if var"##1345" isa Expr
                    if begin
                                if var"##cache#1346" === nothing
                                    var"##cache#1346" = Some(((var"##1345").head, (var"##1345").args))
                                end
                                var"##1347" = (var"##cache#1346").value
                                var"##1347" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1347"[1] == :function && (begin
                                        var"##1348" = var"##1347"[2]
                                        var"##1348" isa AbstractArray
                                    end && (length(var"##1348") === 2 && (begin
                                                begin
                                                    var"##cache#1350" = nothing
                                                end
                                                var"##1349" = var"##1348"[1]
                                                var"##1349" isa Expr
                                            end && (begin
                                                    if var"##cache#1350" === nothing
                                                        var"##cache#1350" = Some(((var"##1349").head, (var"##1349").args))
                                                    end
                                                    var"##1351" = (var"##cache#1350").value
                                                    var"##1351" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1351"[1] == :block && (begin
                                                            var"##1352" = var"##1351"[2]
                                                            var"##1352" isa AbstractArray
                                                        end && (length(var"##1352") === 2 && begin
                                                                var"##1353" = var"##1352"[1]
                                                                var"##1354" = var"##1352"[2]
                                                                var"##1355" = var"##1348"[2]
                                                                true
                                                            end))))))))
                        var"##return#1343" = let y = var"##1354", body = var"##1355", x = var"##1353"
                                Expr(:function, Expr(:tuple, Expr(:parameters, y), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1344#1399")))
                    end
                    if begin
                                var"##1356" = (var"##cache#1346").value
                                var"##1356" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1356"[1] == :function && (begin
                                        var"##1357" = var"##1356"[2]
                                        var"##1357" isa AbstractArray
                                    end && (length(var"##1357") === 2 && (begin
                                                begin
                                                    var"##cache#1359" = nothing
                                                end
                                                var"##1358" = var"##1357"[1]
                                                var"##1358" isa Expr
                                            end && (begin
                                                    if var"##cache#1359" === nothing
                                                        var"##cache#1359" = Some(((var"##1358").head, (var"##1358").args))
                                                    end
                                                    var"##1360" = (var"##cache#1359").value
                                                    var"##1360" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1360"[1] == :block && (begin
                                                            var"##1361" = var"##1360"[2]
                                                            var"##1361" isa AbstractArray
                                                        end && (length(var"##1361") === 3 && (begin
                                                                    var"##1362" = var"##1361"[1]
                                                                    var"##1363" = var"##1361"[2]
                                                                    var"##1363" isa LineNumberNode
                                                                end && begin
                                                                    var"##1364" = var"##1361"[3]
                                                                    var"##1365" = var"##1357"[2]
                                                                    true
                                                                end)))))))))
                        var"##return#1343" = let y = var"##1364", body = var"##1365", x = var"##1362"
                                Expr(:function, Expr(:tuple, Expr(:parameters, y), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1344#1399")))
                    end
                    if begin
                                var"##1366" = (var"##cache#1346").value
                                var"##1366" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1366"[1] == :function && (begin
                                        var"##1367" = var"##1366"[2]
                                        var"##1367" isa AbstractArray
                                    end && (length(var"##1367") === 2 && (begin
                                                begin
                                                    var"##cache#1369" = nothing
                                                end
                                                var"##1368" = var"##1367"[1]
                                                var"##1368" isa Expr
                                            end && (begin
                                                    if var"##cache#1369" === nothing
                                                        var"##cache#1369" = Some(((var"##1368").head, (var"##1368").args))
                                                    end
                                                    var"##1370" = (var"##cache#1369").value
                                                    var"##1370" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1370"[1] == :block && (begin
                                                            var"##1371" = var"##1370"[2]
                                                            var"##1371" isa AbstractArray
                                                        end && (length(var"##1371") === 2 && (begin
                                                                    var"##1372" = var"##1371"[1]
                                                                    begin
                                                                        var"##cache#1374" = nothing
                                                                    end
                                                                    var"##1373" = var"##1371"[2]
                                                                    var"##1373" isa Expr
                                                                end && (begin
                                                                        if var"##cache#1374" === nothing
                                                                            var"##cache#1374" = Some(((var"##1373").head, (var"##1373").args))
                                                                        end
                                                                        var"##1375" = (var"##cache#1374").value
                                                                        var"##1375" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                    end && (var"##1375"[1] == :(=) && (begin
                                                                                var"##1376" = var"##1375"[2]
                                                                                var"##1376" isa AbstractArray
                                                                            end && (length(var"##1376") === 2 && begin
                                                                                    var"##1377" = var"##1376"[1]
                                                                                    var"##1378" = var"##1376"[2]
                                                                                    var"##1379" = var"##1367"[2]
                                                                                    true
                                                                                end)))))))))))))
                        var"##return#1343" = let default = var"##1378", key = var"##1377", body = var"##1379", x = var"##1372"
                                Expr(:function, Expr(:tuple, Expr(:parameters, Expr(:kw, key, default)), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1344#1399")))
                    end
                    if begin
                                var"##1380" = (var"##cache#1346").value
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
                                                        end && (length(var"##1385") === 3 && (begin
                                                                    var"##1386" = var"##1385"[1]
                                                                    var"##1387" = var"##1385"[2]
                                                                    var"##1387" isa LineNumberNode
                                                                end && (begin
                                                                        begin
                                                                            var"##cache#1389" = nothing
                                                                        end
                                                                        var"##1388" = var"##1385"[3]
                                                                        var"##1388" isa Expr
                                                                    end && (begin
                                                                            if var"##cache#1389" === nothing
                                                                                var"##cache#1389" = Some(((var"##1388").head, (var"##1388").args))
                                                                            end
                                                                            var"##1390" = (var"##cache#1389").value
                                                                            var"##1390" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                        end && (var"##1390"[1] == :(=) && (begin
                                                                                    var"##1391" = var"##1390"[2]
                                                                                    var"##1391" isa AbstractArray
                                                                                end && (length(var"##1391") === 2 && begin
                                                                                        var"##1392" = var"##1391"[1]
                                                                                        var"##1393" = var"##1391"[2]
                                                                                        var"##1394" = var"##1381"[2]
                                                                                        true
                                                                                    end))))))))))))))
                        var"##return#1343" = let default = var"##1393", key = var"##1392", body = var"##1394", x = var"##1386"
                                Expr(:function, Expr(:tuple, Expr(:parameters, Expr(:kw, key, default)), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1344#1399")))
                    end
                    if begin
                                var"##1395" = (var"##cache#1346").value
                                var"##1395" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1396" = var"##1395"[1]
                                    var"##1397" = var"##1395"[2]
                                    var"##1397" isa AbstractArray
                                end && ((ndims(var"##1397") === 1 && length(var"##1397") >= 0) && begin
                                        var"##1398" = SubArray(var"##1397", (1:length(var"##1397"),))
                                        true
                                    end))
                        var"##return#1343" = let args = var"##1398", head = var"##1396"
                                Expr(head, map(canonicalize_lambda_head, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1344#1399")))
                    end
                end
                begin
                    var"##return#1343" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1344#1399")))
                end
                error("matching non-exhaustive, at #= none:242 =#")
                $(Expr(:symboliclabel, Symbol("####final#1344#1399")))
                var"##return#1343"
            end
        end
    function rm_single_block(ex)
        let
            begin
                var"##cache#1403" = nothing
            end
            var"##return#1400" = nothing
            var"##1402" = ex
            if var"##1402" isa Expr
                if begin
                            if var"##cache#1403" === nothing
                                var"##cache#1403" = Some(((var"##1402").head, (var"##1402").args))
                            end
                            var"##1404" = (var"##cache#1403").value
                            var"##1404" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1404"[1] == :(=) && (begin
                                    var"##1405" = var"##1404"[2]
                                    var"##1405" isa AbstractArray
                                end && (ndims(var"##1405") === 1 && length(var"##1405") >= 0)))
                    var"##return#1400" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1401#1468")))
                end
                if begin
                            var"##1406" = (var"##cache#1403").value
                            var"##1406" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1406"[1] == :-> && (begin
                                    var"##1407" = var"##1406"[2]
                                    var"##1407" isa AbstractArray
                                end && (ndims(var"##1407") === 1 && length(var"##1407") >= 0)))
                    var"##return#1400" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1401#1468")))
                end
                if begin
                            var"##1408" = (var"##cache#1403").value
                            var"##1408" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1408"[1] == :quote && (begin
                                    var"##1409" = var"##1408"[2]
                                    var"##1409" isa AbstractArray
                                end && ((ndims(var"##1409") === 1 && length(var"##1409") >= 0) && begin
                                        var"##1410" = SubArray(var"##1409", (1:length(var"##1409"),))
                                        true
                                    end)))
                    var"##return#1400" = let xs = var"##1410"
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1401#1468")))
                end
                if begin
                            var"##1411" = (var"##cache#1403").value
                            var"##1411" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1411"[1] == :block && (begin
                                    var"##1412" = var"##1411"[2]
                                    var"##1412" isa AbstractArray
                                end && (length(var"##1412") === 1 && (begin
                                            begin
                                                var"##cache#1414" = nothing
                                            end
                                            var"##1413" = var"##1412"[1]
                                            var"##1413" isa Expr
                                        end && (begin
                                                if var"##cache#1414" === nothing
                                                    var"##cache#1414" = Some(((var"##1413").head, (var"##1413").args))
                                                end
                                                var"##1415" = (var"##cache#1414").value
                                                var"##1415" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1415"[1] == :quote && (begin
                                                        var"##1416" = var"##1415"[2]
                                                        var"##1416" isa AbstractArray
                                                    end && ((ndims(var"##1416") === 1 && length(var"##1416") >= 0) && begin
                                                            var"##1417" = SubArray(var"##1416", (1:length(var"##1416"),))
                                                            true
                                                        end))))))))
                    var"##return#1400" = let xs = var"##1417"
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1401#1468")))
                end
                if begin
                            var"##1418" = (var"##cache#1403").value
                            var"##1418" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1418"[1] == :try && (begin
                                    var"##1419" = var"##1418"[2]
                                    var"##1419" isa AbstractArray
                                end && (length(var"##1419") === 4 && (begin
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
                                                    end && ((ndims(var"##1423") === 1 && length(var"##1423") >= 0) && (begin
                                                                var"##1424" = SubArray(var"##1423", (1:length(var"##1423"),))
                                                                var"##1419"[2] === false
                                                            end && (var"##1419"[3] === false && (begin
                                                                        begin
                                                                            var"##cache#1426" = nothing
                                                                        end
                                                                        var"##1425" = var"##1419"[4]
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
                                                                                end && ((ndims(var"##1428") === 1 && length(var"##1428") >= 0) && begin
                                                                                        var"##1429" = SubArray(var"##1428", (1:length(var"##1428"),))
                                                                                        true
                                                                                    end)))))))))))))))
                    var"##return#1400" = let try_stmts = var"##1424", finally_stmts = var"##1429"
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), false, false, Expr(:block, rm_single_block.(finally_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1401#1468")))
                end
                if begin
                            var"##1430" = (var"##cache#1403").value
                            var"##1430" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1430"[1] == :try && (begin
                                    var"##1431" = var"##1430"[2]
                                    var"##1431" isa AbstractArray
                                end && (length(var"##1431") === 3 && (begin
                                            begin
                                                var"##cache#1433" = nothing
                                            end
                                            var"##1432" = var"##1431"[1]
                                            var"##1432" isa Expr
                                        end && (begin
                                                if var"##cache#1433" === nothing
                                                    var"##cache#1433" = Some(((var"##1432").head, (var"##1432").args))
                                                end
                                                var"##1434" = (var"##cache#1433").value
                                                var"##1434" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1434"[1] == :block && (begin
                                                        var"##1435" = var"##1434"[2]
                                                        var"##1435" isa AbstractArray
                                                    end && ((ndims(var"##1435") === 1 && length(var"##1435") >= 0) && (begin
                                                                var"##1436" = SubArray(var"##1435", (1:length(var"##1435"),))
                                                                var"##1437" = var"##1431"[2]
                                                                begin
                                                                    var"##cache#1439" = nothing
                                                                end
                                                                var"##1438" = var"##1431"[3]
                                                                var"##1438" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1439" === nothing
                                                                        var"##cache#1439" = Some(((var"##1438").head, (var"##1438").args))
                                                                    end
                                                                    var"##1440" = (var"##cache#1439").value
                                                                    var"##1440" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1440"[1] == :block && (begin
                                                                            var"##1441" = var"##1440"[2]
                                                                            var"##1441" isa AbstractArray
                                                                        end && ((ndims(var"##1441") === 1 && length(var"##1441") >= 0) && begin
                                                                                var"##1442" = SubArray(var"##1441", (1:length(var"##1441"),))
                                                                                true
                                                                            end)))))))))))))
                    var"##return#1400" = let try_stmts = var"##1436", catch_stmts = var"##1442", catch_var = var"##1437"
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), catch_var, Expr(:block, rm_single_block.(catch_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1401#1468")))
                end
                if begin
                            var"##1443" = (var"##cache#1403").value
                            var"##1443" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1443"[1] == :try && (begin
                                    var"##1444" = var"##1443"[2]
                                    var"##1444" isa AbstractArray
                                end && (length(var"##1444") === 4 && (begin
                                            begin
                                                var"##cache#1446" = nothing
                                            end
                                            var"##1445" = var"##1444"[1]
                                            var"##1445" isa Expr
                                        end && (begin
                                                if var"##cache#1446" === nothing
                                                    var"##cache#1446" = Some(((var"##1445").head, (var"##1445").args))
                                                end
                                                var"##1447" = (var"##cache#1446").value
                                                var"##1447" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1447"[1] == :block && (begin
                                                        var"##1448" = var"##1447"[2]
                                                        var"##1448" isa AbstractArray
                                                    end && ((ndims(var"##1448") === 1 && length(var"##1448") >= 0) && (begin
                                                                var"##1449" = SubArray(var"##1448", (1:length(var"##1448"),))
                                                                var"##1450" = var"##1444"[2]
                                                                begin
                                                                    var"##cache#1452" = nothing
                                                                end
                                                                var"##1451" = var"##1444"[3]
                                                                var"##1451" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1452" === nothing
                                                                        var"##cache#1452" = Some(((var"##1451").head, (var"##1451").args))
                                                                    end
                                                                    var"##1453" = (var"##cache#1452").value
                                                                    var"##1453" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1453"[1] == :block && (begin
                                                                            var"##1454" = var"##1453"[2]
                                                                            var"##1454" isa AbstractArray
                                                                        end && ((ndims(var"##1454") === 1 && length(var"##1454") >= 0) && (begin
                                                                                    var"##1455" = SubArray(var"##1454", (1:length(var"##1454"),))
                                                                                    begin
                                                                                        var"##cache#1457" = nothing
                                                                                    end
                                                                                    var"##1456" = var"##1444"[4]
                                                                                    var"##1456" isa Expr
                                                                                end && (begin
                                                                                        if var"##cache#1457" === nothing
                                                                                            var"##cache#1457" = Some(((var"##1456").head, (var"##1456").args))
                                                                                        end
                                                                                        var"##1458" = (var"##cache#1457").value
                                                                                        var"##1458" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                                    end && (var"##1458"[1] == :block && (begin
                                                                                                var"##1459" = var"##1458"[2]
                                                                                                var"##1459" isa AbstractArray
                                                                                            end && ((ndims(var"##1459") === 1 && length(var"##1459") >= 0) && begin
                                                                                                    var"##1460" = SubArray(var"##1459", (1:length(var"##1459"),))
                                                                                                    true
                                                                                                end))))))))))))))))))
                    var"##return#1400" = let try_stmts = var"##1449", catch_stmts = var"##1455", catch_var = var"##1450", finally_stmts = var"##1460"
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), catch_var, Expr(:block, rm_single_block.(catch_stmts)...), Expr(:block, rm_single_block.(finally_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1401#1468")))
                end
                if begin
                            var"##1461" = (var"##cache#1403").value
                            var"##1461" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1461"[1] == :block && (begin
                                    var"##1462" = var"##1461"[2]
                                    var"##1462" isa AbstractArray
                                end && (length(var"##1462") === 1 && begin
                                        var"##1463" = var"##1462"[1]
                                        true
                                    end)))
                    var"##return#1400" = let stmt = var"##1463"
                            stmt
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1401#1468")))
                end
                if begin
                            var"##1464" = (var"##cache#1403").value
                            var"##1464" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                        end && (begin
                                var"##1465" = var"##1464"[1]
                                var"##1466" = var"##1464"[2]
                                var"##1466" isa AbstractArray
                            end && ((ndims(var"##1466") === 1 && length(var"##1466") >= 0) && begin
                                    var"##1467" = SubArray(var"##1466", (1:length(var"##1466"),))
                                    true
                                end))
                    var"##return#1400" = let args = var"##1467", head = var"##1465"
                            Expr(head, map(rm_single_block, args)...)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1401#1468")))
                end
            end
            begin
                var"##return#1400" = let
                        ex
                    end
                $(Expr(:symbolicgoto, Symbol("####final#1401#1468")))
            end
            error("matching non-exhaustive, at #= none:258 =#")
            $(Expr(:symboliclabel, Symbol("####final#1401#1468")))
            var"##return#1400"
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
    #= none:368 =# Core.@doc "    expr_map(f, c...)\n\nSimilar to `Base.map`, but expects `f` to return an expression,\nand will concanate these expression as a `Expr(:block, ...)`\nexpression.\n\n# Example\n\n```jldoctest\njulia> expr_map(1:10, 2:11) do i,j\n           :(1 + \$i + \$j)\n       end\nquote\n    1 + 1 + 2\n    1 + 2 + 3\n    1 + 3 + 4\n    1 + 4 + 5\n    1 + 5 + 6\n    1 + 6 + 7\n    1 + 7 + 8\n    1 + 8 + 9\n    1 + 9 + 10\n    1 + 10 + 11\nend\n```\n" function expr_map(f, c...)
            ex = Expr(:block)
            for args = zip(c...)
                push!(ex.args, f(args...))
            end
            return ex
        end
    #= none:403 =# Core.@doc "    nexprs(f, n::Int)\n\nCreate `n` similar expressions by evaluating `f`.\n\n# Example\n\n```jldoctest\njulia> nexprs(5) do k\n           :(1 + \$k)\n       end\nquote\n    1 + 1\n    1 + 2\n    1 + 3\n    1 + 4\n    1 + 5\nend\n```\n" nexprs(f, k::Int) = begin
                expr_map(f, 1:k)
            end
    #= none:425 =# Core.@doc "    Substitute(condition) -> substitute(f(expr), expr)\n\nReturns a function that substitutes `expr` with\n`f(expr)` if `condition(expr)` is true. Applied\nrecursively to all sub-expressions.\n\n# Example\n\n```jldoctest\njulia> sub = Substitute() do expr\n           expr isa Symbol && expr in [:x] && return true\n           return false\n       end;\n\njulia> sub(_->1, :(x + y))\n:(1 + y)\n```\n" struct Substitute
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
