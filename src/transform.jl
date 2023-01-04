
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
                    var"##cache#1312" = nothing
                end
                var"##return#1309" = nothing
                var"##1311" = ex
                if var"##1311" isa Expr
                    if begin
                                if var"##cache#1312" === nothing
                                    var"##cache#1312" = Some(((var"##1311").head, (var"##1311").args))
                                end
                                var"##1313" = (var"##cache#1312").value
                                var"##1313" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1313"[1] == :macrocall && (begin
                                        var"##1314" = var"##1313"[2]
                                        var"##1314" isa AbstractArray
                                    end && ((ndims(var"##1314") === 1 && length(var"##1314") >= 2) && begin
                                            var"##1315" = var"##1314"[1]
                                            var"##1316" = var"##1314"[2]
                                            var"##1317" = SubArray(var"##1314", (3:length(var"##1314"),))
                                            true
                                        end)))
                        var"##return#1309" = let line = var"##1316", name = var"##1315", args = var"##1317"
                                Expr(:macrocall, name, line, map(rm_lineinfo, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1310#1322")))
                    end
                    if begin
                                var"##1318" = (var"##cache#1312").value
                                var"##1318" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1319" = var"##1318"[1]
                                    var"##1320" = var"##1318"[2]
                                    var"##1320" isa AbstractArray
                                end && ((ndims(var"##1320") === 1 && length(var"##1320") >= 0) && begin
                                        var"##1321" = SubArray(var"##1320", (1:length(var"##1320"),))
                                        true
                                    end))
                        var"##return#1309" = let args = var"##1321", head = var"##1319"
                                Expr(head, map(rm_lineinfo, filter((x->begin
                                                    !(x isa LineNumberNode)
                                                end), args))...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1310#1322")))
                    end
                end
                begin
                    var"##return#1309" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1310#1322")))
                end
                error("matching non-exhaustive, at #= none:106 =#")
                $(Expr(:symboliclabel, Symbol("####final#1310#1322")))
                var"##return#1309"
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
                    var"##cache#1326" = nothing
                end
                var"##return#1323" = nothing
                var"##1325" = ex
                if var"##1325" isa Expr
                    if begin
                                if var"##cache#1326" === nothing
                                    var"##cache#1326" = Some(((var"##1325").head, (var"##1325").args))
                                end
                                var"##1327" = (var"##cache#1326").value
                                var"##1327" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1327"[1] == :block && (begin
                                        var"##1328" = var"##1327"[2]
                                        var"##1328" isa AbstractArray
                                    end && ((ndims(var"##1328") === 1 && length(var"##1328") >= 0) && begin
                                            var"##1329" = SubArray(var"##1328", (1:length(var"##1328"),))
                                            true
                                        end)))
                        var"##return#1323" = let args = var"##1329"
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
                        $(Expr(:symbolicgoto, Symbol("####final#1324#1334")))
                    end
                    if begin
                                var"##1330" = (var"##cache#1326").value
                                var"##1330" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1331" = var"##1330"[1]
                                    var"##1332" = var"##1330"[2]
                                    var"##1332" isa AbstractArray
                                end && ((ndims(var"##1332") === 1 && length(var"##1332") >= 0) && begin
                                        var"##1333" = SubArray(var"##1332", (1:length(var"##1332"),))
                                        true
                                    end))
                        var"##return#1323" = let args = var"##1333", head = var"##1331"
                                Expr(head, map(rm_nothing, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1324#1334")))
                    end
                end
                begin
                    var"##return#1323" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1324#1334")))
                end
                error("matching non-exhaustive, at #= none:217 =#")
                $(Expr(:symboliclabel, Symbol("####final#1324#1334")))
                var"##return#1323"
            end
        end
    #= none:230 =# Core.@doc "    canonicalize_lambda_head(ex)\n\nCanonicalize the `Expr(:function, Expr(:block, x, Expr(:(=), key, default)), body)` to\n\n```julia\nExpr(:function, Expr(:tuple, Expr(:parameters, Expr(:kw, key, default)), x), body)\n```\n" function canonicalize_lambda_head(ex)
            let
                begin
                    var"##cache#1338" = nothing
                end
                var"##return#1335" = nothing
                var"##1337" = ex
                if var"##1337" isa Expr
                    if begin
                                if var"##cache#1338" === nothing
                                    var"##cache#1338" = Some(((var"##1337").head, (var"##1337").args))
                                end
                                var"##1339" = (var"##cache#1338").value
                                var"##1339" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1339"[1] == :function && (begin
                                        var"##1340" = var"##1339"[2]
                                        var"##1340" isa AbstractArray
                                    end && (length(var"##1340") === 2 && (begin
                                                begin
                                                    var"##cache#1342" = nothing
                                                end
                                                var"##1341" = var"##1340"[1]
                                                var"##1341" isa Expr
                                            end && (begin
                                                    if var"##cache#1342" === nothing
                                                        var"##cache#1342" = Some(((var"##1341").head, (var"##1341").args))
                                                    end
                                                    var"##1343" = (var"##cache#1342").value
                                                    var"##1343" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1343"[1] == :block && (begin
                                                            var"##1344" = var"##1343"[2]
                                                            var"##1344" isa AbstractArray
                                                        end && (length(var"##1344") === 2 && begin
                                                                var"##1345" = var"##1344"[1]
                                                                var"##1346" = var"##1344"[2]
                                                                var"##1347" = var"##1340"[2]
                                                                true
                                                            end))))))))
                        var"##return#1335" = let y = var"##1346", body = var"##1347", x = var"##1345"
                                Expr(:function, Expr(:tuple, Expr(:parameters, y), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1336#1391")))
                    end
                    if begin
                                var"##1348" = (var"##cache#1338").value
                                var"##1348" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1348"[1] == :function && (begin
                                        var"##1349" = var"##1348"[2]
                                        var"##1349" isa AbstractArray
                                    end && (length(var"##1349") === 2 && (begin
                                                begin
                                                    var"##cache#1351" = nothing
                                                end
                                                var"##1350" = var"##1349"[1]
                                                var"##1350" isa Expr
                                            end && (begin
                                                    if var"##cache#1351" === nothing
                                                        var"##cache#1351" = Some(((var"##1350").head, (var"##1350").args))
                                                    end
                                                    var"##1352" = (var"##cache#1351").value
                                                    var"##1352" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1352"[1] == :block && (begin
                                                            var"##1353" = var"##1352"[2]
                                                            var"##1353" isa AbstractArray
                                                        end && (length(var"##1353") === 3 && (begin
                                                                    var"##1354" = var"##1353"[1]
                                                                    var"##1355" = var"##1353"[2]
                                                                    var"##1355" isa LineNumberNode
                                                                end && begin
                                                                    var"##1356" = var"##1353"[3]
                                                                    var"##1357" = var"##1349"[2]
                                                                    true
                                                                end)))))))))
                        var"##return#1335" = let y = var"##1356", body = var"##1357", x = var"##1354"
                                Expr(:function, Expr(:tuple, Expr(:parameters, y), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1336#1391")))
                    end
                    if begin
                                var"##1358" = (var"##cache#1338").value
                                var"##1358" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1358"[1] == :function && (begin
                                        var"##1359" = var"##1358"[2]
                                        var"##1359" isa AbstractArray
                                    end && (length(var"##1359") === 2 && (begin
                                                begin
                                                    var"##cache#1361" = nothing
                                                end
                                                var"##1360" = var"##1359"[1]
                                                var"##1360" isa Expr
                                            end && (begin
                                                    if var"##cache#1361" === nothing
                                                        var"##cache#1361" = Some(((var"##1360").head, (var"##1360").args))
                                                    end
                                                    var"##1362" = (var"##cache#1361").value
                                                    var"##1362" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1362"[1] == :block && (begin
                                                            var"##1363" = var"##1362"[2]
                                                            var"##1363" isa AbstractArray
                                                        end && (length(var"##1363") === 2 && (begin
                                                                    var"##1364" = var"##1363"[1]
                                                                    begin
                                                                        var"##cache#1366" = nothing
                                                                    end
                                                                    var"##1365" = var"##1363"[2]
                                                                    var"##1365" isa Expr
                                                                end && (begin
                                                                        if var"##cache#1366" === nothing
                                                                            var"##cache#1366" = Some(((var"##1365").head, (var"##1365").args))
                                                                        end
                                                                        var"##1367" = (var"##cache#1366").value
                                                                        var"##1367" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                    end && (var"##1367"[1] == :(=) && (begin
                                                                                var"##1368" = var"##1367"[2]
                                                                                var"##1368" isa AbstractArray
                                                                            end && (length(var"##1368") === 2 && begin
                                                                                    var"##1369" = var"##1368"[1]
                                                                                    var"##1370" = var"##1368"[2]
                                                                                    var"##1371" = var"##1359"[2]
                                                                                    true
                                                                                end)))))))))))))
                        var"##return#1335" = let default = var"##1370", key = var"##1369", body = var"##1371", x = var"##1364"
                                Expr(:function, Expr(:tuple, Expr(:parameters, Expr(:kw, key, default)), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1336#1391")))
                    end
                    if begin
                                var"##1372" = (var"##cache#1338").value
                                var"##1372" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1372"[1] == :function && (begin
                                        var"##1373" = var"##1372"[2]
                                        var"##1373" isa AbstractArray
                                    end && (length(var"##1373") === 2 && (begin
                                                begin
                                                    var"##cache#1375" = nothing
                                                end
                                                var"##1374" = var"##1373"[1]
                                                var"##1374" isa Expr
                                            end && (begin
                                                    if var"##cache#1375" === nothing
                                                        var"##cache#1375" = Some(((var"##1374").head, (var"##1374").args))
                                                    end
                                                    var"##1376" = (var"##cache#1375").value
                                                    var"##1376" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1376"[1] == :block && (begin
                                                            var"##1377" = var"##1376"[2]
                                                            var"##1377" isa AbstractArray
                                                        end && (length(var"##1377") === 3 && (begin
                                                                    var"##1378" = var"##1377"[1]
                                                                    var"##1379" = var"##1377"[2]
                                                                    var"##1379" isa LineNumberNode
                                                                end && (begin
                                                                        begin
                                                                            var"##cache#1381" = nothing
                                                                        end
                                                                        var"##1380" = var"##1377"[3]
                                                                        var"##1380" isa Expr
                                                                    end && (begin
                                                                            if var"##cache#1381" === nothing
                                                                                var"##cache#1381" = Some(((var"##1380").head, (var"##1380").args))
                                                                            end
                                                                            var"##1382" = (var"##cache#1381").value
                                                                            var"##1382" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                        end && (var"##1382"[1] == :(=) && (begin
                                                                                    var"##1383" = var"##1382"[2]
                                                                                    var"##1383" isa AbstractArray
                                                                                end && (length(var"##1383") === 2 && begin
                                                                                        var"##1384" = var"##1383"[1]
                                                                                        var"##1385" = var"##1383"[2]
                                                                                        var"##1386" = var"##1373"[2]
                                                                                        true
                                                                                    end))))))))))))))
                        var"##return#1335" = let default = var"##1385", key = var"##1384", body = var"##1386", x = var"##1378"
                                Expr(:function, Expr(:tuple, Expr(:parameters, Expr(:kw, key, default)), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1336#1391")))
                    end
                    if begin
                                var"##1387" = (var"##cache#1338").value
                                var"##1387" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1388" = var"##1387"[1]
                                    var"##1389" = var"##1387"[2]
                                    var"##1389" isa AbstractArray
                                end && ((ndims(var"##1389") === 1 && length(var"##1389") >= 0) && begin
                                        var"##1390" = SubArray(var"##1389", (1:length(var"##1389"),))
                                        true
                                    end))
                        var"##return#1335" = let args = var"##1390", head = var"##1388"
                                Expr(head, map(canonicalize_lambda_head, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1336#1391")))
                    end
                end
                begin
                    var"##return#1335" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1336#1391")))
                end
                error("matching non-exhaustive, at #= none:240 =#")
                $(Expr(:symboliclabel, Symbol("####final#1336#1391")))
                var"##return#1335"
            end
        end
    function rm_single_block(ex)
        let
            begin
                var"##cache#1395" = nothing
            end
            var"##return#1392" = nothing
            var"##1394" = ex
            if var"##1394" isa Expr
                if begin
                            if var"##cache#1395" === nothing
                                var"##cache#1395" = Some(((var"##1394").head, (var"##1394").args))
                            end
                            var"##1396" = (var"##cache#1395").value
                            var"##1396" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1396"[1] == :(=) && (begin
                                    var"##1397" = var"##1396"[2]
                                    var"##1397" isa AbstractArray
                                end && (ndims(var"##1397") === 1 && length(var"##1397") >= 0)))
                    var"##return#1392" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1393#1460")))
                end
                if begin
                            var"##1398" = (var"##cache#1395").value
                            var"##1398" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1398"[1] == :-> && (begin
                                    var"##1399" = var"##1398"[2]
                                    var"##1399" isa AbstractArray
                                end && (ndims(var"##1399") === 1 && length(var"##1399") >= 0)))
                    var"##return#1392" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1393#1460")))
                end
                if begin
                            var"##1400" = (var"##cache#1395").value
                            var"##1400" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1400"[1] == :quote && (begin
                                    var"##1401" = var"##1400"[2]
                                    var"##1401" isa AbstractArray
                                end && ((ndims(var"##1401") === 1 && length(var"##1401") >= 0) && begin
                                        var"##1402" = SubArray(var"##1401", (1:length(var"##1401"),))
                                        true
                                    end)))
                    var"##return#1392" = let xs = var"##1402"
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1393#1460")))
                end
                if begin
                            var"##1403" = (var"##cache#1395").value
                            var"##1403" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1403"[1] == :block && (begin
                                    var"##1404" = var"##1403"[2]
                                    var"##1404" isa AbstractArray
                                end && (length(var"##1404") === 1 && (begin
                                            begin
                                                var"##cache#1406" = nothing
                                            end
                                            var"##1405" = var"##1404"[1]
                                            var"##1405" isa Expr
                                        end && (begin
                                                if var"##cache#1406" === nothing
                                                    var"##cache#1406" = Some(((var"##1405").head, (var"##1405").args))
                                                end
                                                var"##1407" = (var"##cache#1406").value
                                                var"##1407" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1407"[1] == :quote && (begin
                                                        var"##1408" = var"##1407"[2]
                                                        var"##1408" isa AbstractArray
                                                    end && ((ndims(var"##1408") === 1 && length(var"##1408") >= 0) && begin
                                                            var"##1409" = SubArray(var"##1408", (1:length(var"##1408"),))
                                                            true
                                                        end))))))))
                    var"##return#1392" = let xs = var"##1409"
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1393#1460")))
                end
                if begin
                            var"##1410" = (var"##cache#1395").value
                            var"##1410" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1410"[1] == :try && (begin
                                    var"##1411" = var"##1410"[2]
                                    var"##1411" isa AbstractArray
                                end && (length(var"##1411") === 4 && (begin
                                            begin
                                                var"##cache#1413" = nothing
                                            end
                                            var"##1412" = var"##1411"[1]
                                            var"##1412" isa Expr
                                        end && (begin
                                                if var"##cache#1413" === nothing
                                                    var"##cache#1413" = Some(((var"##1412").head, (var"##1412").args))
                                                end
                                                var"##1414" = (var"##cache#1413").value
                                                var"##1414" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1414"[1] == :block && (begin
                                                        var"##1415" = var"##1414"[2]
                                                        var"##1415" isa AbstractArray
                                                    end && ((ndims(var"##1415") === 1 && length(var"##1415") >= 0) && (begin
                                                                var"##1416" = SubArray(var"##1415", (1:length(var"##1415"),))
                                                                var"##1411"[2] === false
                                                            end && (var"##1411"[3] === false && (begin
                                                                        begin
                                                                            var"##cache#1418" = nothing
                                                                        end
                                                                        var"##1417" = var"##1411"[4]
                                                                        var"##1417" isa Expr
                                                                    end && (begin
                                                                            if var"##cache#1418" === nothing
                                                                                var"##cache#1418" = Some(((var"##1417").head, (var"##1417").args))
                                                                            end
                                                                            var"##1419" = (var"##cache#1418").value
                                                                            var"##1419" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                        end && (var"##1419"[1] == :block && (begin
                                                                                    var"##1420" = var"##1419"[2]
                                                                                    var"##1420" isa AbstractArray
                                                                                end && ((ndims(var"##1420") === 1 && length(var"##1420") >= 0) && begin
                                                                                        var"##1421" = SubArray(var"##1420", (1:length(var"##1420"),))
                                                                                        true
                                                                                    end)))))))))))))))
                    var"##return#1392" = let try_stmts = var"##1416", finally_stmts = var"##1421"
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), false, false, Expr(:block, rm_single_block.(finally_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1393#1460")))
                end
                if begin
                            var"##1422" = (var"##cache#1395").value
                            var"##1422" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1422"[1] == :try && (begin
                                    var"##1423" = var"##1422"[2]
                                    var"##1423" isa AbstractArray
                                end && (length(var"##1423") === 3 && (begin
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
                                                    end && ((ndims(var"##1427") === 1 && length(var"##1427") >= 0) && (begin
                                                                var"##1428" = SubArray(var"##1427", (1:length(var"##1427"),))
                                                                var"##1429" = var"##1423"[2]
                                                                begin
                                                                    var"##cache#1431" = nothing
                                                                end
                                                                var"##1430" = var"##1423"[3]
                                                                var"##1430" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1431" === nothing
                                                                        var"##cache#1431" = Some(((var"##1430").head, (var"##1430").args))
                                                                    end
                                                                    var"##1432" = (var"##cache#1431").value
                                                                    var"##1432" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1432"[1] == :block && (begin
                                                                            var"##1433" = var"##1432"[2]
                                                                            var"##1433" isa AbstractArray
                                                                        end && ((ndims(var"##1433") === 1 && length(var"##1433") >= 0) && begin
                                                                                var"##1434" = SubArray(var"##1433", (1:length(var"##1433"),))
                                                                                true
                                                                            end)))))))))))))
                    var"##return#1392" = let try_stmts = var"##1428", catch_stmts = var"##1434", catch_var = var"##1429"
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), catch_var, Expr(:block, rm_single_block.(catch_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1393#1460")))
                end
                if begin
                            var"##1435" = (var"##cache#1395").value
                            var"##1435" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1435"[1] == :try && (begin
                                    var"##1436" = var"##1435"[2]
                                    var"##1436" isa AbstractArray
                                end && (length(var"##1436") === 4 && (begin
                                            begin
                                                var"##cache#1438" = nothing
                                            end
                                            var"##1437" = var"##1436"[1]
                                            var"##1437" isa Expr
                                        end && (begin
                                                if var"##cache#1438" === nothing
                                                    var"##cache#1438" = Some(((var"##1437").head, (var"##1437").args))
                                                end
                                                var"##1439" = (var"##cache#1438").value
                                                var"##1439" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1439"[1] == :block && (begin
                                                        var"##1440" = var"##1439"[2]
                                                        var"##1440" isa AbstractArray
                                                    end && ((ndims(var"##1440") === 1 && length(var"##1440") >= 0) && (begin
                                                                var"##1441" = SubArray(var"##1440", (1:length(var"##1440"),))
                                                                var"##1442" = var"##1436"[2]
                                                                begin
                                                                    var"##cache#1444" = nothing
                                                                end
                                                                var"##1443" = var"##1436"[3]
                                                                var"##1443" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1444" === nothing
                                                                        var"##cache#1444" = Some(((var"##1443").head, (var"##1443").args))
                                                                    end
                                                                    var"##1445" = (var"##cache#1444").value
                                                                    var"##1445" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1445"[1] == :block && (begin
                                                                            var"##1446" = var"##1445"[2]
                                                                            var"##1446" isa AbstractArray
                                                                        end && ((ndims(var"##1446") === 1 && length(var"##1446") >= 0) && (begin
                                                                                    var"##1447" = SubArray(var"##1446", (1:length(var"##1446"),))
                                                                                    begin
                                                                                        var"##cache#1449" = nothing
                                                                                    end
                                                                                    var"##1448" = var"##1436"[4]
                                                                                    var"##1448" isa Expr
                                                                                end && (begin
                                                                                        if var"##cache#1449" === nothing
                                                                                            var"##cache#1449" = Some(((var"##1448").head, (var"##1448").args))
                                                                                        end
                                                                                        var"##1450" = (var"##cache#1449").value
                                                                                        var"##1450" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                                    end && (var"##1450"[1] == :block && (begin
                                                                                                var"##1451" = var"##1450"[2]
                                                                                                var"##1451" isa AbstractArray
                                                                                            end && ((ndims(var"##1451") === 1 && length(var"##1451") >= 0) && begin
                                                                                                    var"##1452" = SubArray(var"##1451", (1:length(var"##1451"),))
                                                                                                    true
                                                                                                end))))))))))))))))))
                    var"##return#1392" = let try_stmts = var"##1441", catch_stmts = var"##1447", catch_var = var"##1442", finally_stmts = var"##1452"
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), catch_var, Expr(:block, rm_single_block.(catch_stmts)...), Expr(:block, rm_single_block.(finally_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1393#1460")))
                end
                if begin
                            var"##1453" = (var"##cache#1395").value
                            var"##1453" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1453"[1] == :block && (begin
                                    var"##1454" = var"##1453"[2]
                                    var"##1454" isa AbstractArray
                                end && (length(var"##1454") === 1 && begin
                                        var"##1455" = var"##1454"[1]
                                        true
                                    end)))
                    var"##return#1392" = let stmt = var"##1455"
                            stmt
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1393#1460")))
                end
                if begin
                            var"##1456" = (var"##cache#1395").value
                            var"##1456" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                        end && (begin
                                var"##1457" = var"##1456"[1]
                                var"##1458" = var"##1456"[2]
                                var"##1458" isa AbstractArray
                            end && ((ndims(var"##1458") === 1 && length(var"##1458") >= 0) && begin
                                    var"##1459" = SubArray(var"##1458", (1:length(var"##1458"),))
                                    true
                                end))
                    var"##return#1392" = let args = var"##1459", head = var"##1457"
                            Expr(head, map(rm_single_block, args)...)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1393#1460")))
                end
            end
            begin
                var"##return#1392" = let
                        ex
                    end
                $(Expr(:symbolicgoto, Symbol("####final#1393#1460")))
            end
            error("matching non-exhaustive, at #= none:256 =#")
            $(Expr(:symboliclabel, Symbol("####final#1393#1460")))
            var"##return#1392"
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
