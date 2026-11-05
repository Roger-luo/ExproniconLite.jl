
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
            if ex.head === :call && all(is_literal, ex.args[2:var"end"])
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
            ex.head === :module && return name_only(ex.args[if ex.args[1] isa VersionNumber
                                3
                            else
                                2
                            end])
            error("unsupported expression $(ex)")
        end
    #= none:84 =# Core.@doc "    annotations_only(ex)\n\nReturn type annotations only. See also [`name_only`](@ref).\n" function annotations_only(#= none:89 =# @nospecialize(ex))
            ex isa Symbol && return :(())
            ex isa Expr || error("unsupported expression $(ex)")
            Meta.isexpr(ex, :...) && return annotations_only(ex.args[1])
            Meta.isexpr(ex, :(::)) && return ex.args[var"end"]
            error("unsupported expression $(ex)")
        end
    #= none:97 =# Core.@doc "    rm_lineinfo(ex)\n\nRemove `LineNumberNode` in a given expression.\n\n!!! tips\n\n    the `LineNumberNode` inside macro calls won't be removed since\n    the `macrocall` expression requires a `LineNumberNode`. See also\n    [issues/#9](https://github.com/Roger-luo/Expronicon.jl/issues/9).\n" function rm_lineinfo(ex)
            let
                begin
                    var"##cache#1306" = nothing
                end
                var"##return#1303" = nothing
                var"##1305" = ex
                if var"##1305" isa Expr
                    if begin
                                if var"##cache#1306" === nothing
                                    var"##cache#1306" = Some(((var"##1305").head, (var"##1305").args))
                                end
                                var"##1307" = (var"##cache#1306").value
                                var"##1307" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1307"[1] == :macrocall && (begin
                                        var"##1308" = var"##1307"[2]
                                        var"##1308" isa AbstractArray
                                    end && ((ndims(var"##1308") === 1 && length(var"##1308") >= 2) && begin
                                            var"##1309" = var"##1308"[1]
                                            var"##1310" = var"##1308"[2]
                                            var"##1311" = SubArray(var"##1308", (3:length(var"##1308"),))
                                            true
                                        end)))
                        var"##return#1303" = let line = var"##1310", name = var"##1309", args = var"##1311"
                                Expr(:macrocall, name, line, map(rm_lineinfo, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1304#1316")))
                    end
                    if begin
                                var"##1312" = (var"##cache#1306").value
                                var"##1312" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1313" = var"##1312"[1]
                                    var"##1314" = var"##1312"[2]
                                    var"##1314" isa AbstractArray
                                end && ((ndims(var"##1314") === 1 && length(var"##1314") >= 0) && begin
                                        var"##1315" = SubArray(var"##1314", (1:length(var"##1314"),))
                                        true
                                    end))
                        var"##return#1303" = let args = var"##1315", head = var"##1313"
                                Expr(head, map(rm_lineinfo, filter((x->begin
                                                    !(x isa LineNumberNode)
                                                end), args))...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1304#1316")))
                    end
                end
                begin
                    var"##return#1303" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1304#1316")))
                end
                error("matching non-exhaustive, at #= none:109 =#")
                $(Expr(:symboliclabel, Symbol("####final#1304#1316")))
                var"##return#1303"
            end
        end
    #= none:116 =# Base.@kwdef struct PrettifyOptions
            rm_lineinfo::Bool = true
            flatten_blocks::Bool = true
            rm_nothing::Bool = true
            preserve_last_nothing::Bool = false
            rm_single_block::Bool = true
            alias_gensym::Bool = true
            renumber_gensym::Bool = true
        end
    #= none:126 =# Core.@doc "    prettify(ex; kw...)\n\nPrettify given expression, remove all `LineNumberNode` and\nextra code blocks.\n\n# Options (Kwargs)\n\nAll the options are `true` by default.\n\n- `rm_lineinfo`: remove `LineNumberNode`.\n- `flatten_blocks`: flatten `begin ... end` code blocks.\n- `rm_nothing`: remove `nothing` in the `begin ... end`.\n- `preserve_last_nothing`: preserve the last `nothing` in the `begin ... end`.\n- `rm_single_block`: remove single `begin ... end`.\n- `alias_gensym`: replace `##<name>#<num>` with `<name>_<id>`.\n- `renumber_gensym`: renumber the gensym id.\n\n!!! tips\n\n    the `LineNumberNode` inside macro calls won't be removed since\n    the `macrocall` expression requires a `LineNumberNode`. See also\n    [issues/#9](https://github.com/Roger-luo/Expronicon.jl/issues/9).\n" function prettify(ex; kw...)
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
    #= none:174 =# Core.@doc "    flatten_blocks(ex)\n\nRemove hierachical expression blocks.\n" function flatten_blocks(ex)
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
    #= none:209 =# Core.@doc "    rm_nothing(ex)\n\nRemove the constant value `nothing` in given expression `ex`.\n\n# Keyword Arguments\n\n- `preserve_last_nothing`: if `true`, the last `nothing`\n    will be preserved.\n" function rm_nothing(ex; preserve_last_nothing::Bool = false)
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
                            end && (var"##1321"[1] == :block && (begin
                                        var"##1322" = var"##1321"[2]
                                        var"##1322" isa AbstractArray
                                    end && ((ndims(var"##1322") === 1 && length(var"##1322") >= 0) && begin
                                            var"##1323" = SubArray(var"##1322", (1:length(var"##1322"),))
                                            true
                                        end)))
                        var"##return#1317" = let args = var"##1323"
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
                        $(Expr(:symbolicgoto, Symbol("####final#1318#1328")))
                    end
                    if begin
                                var"##1324" = (var"##cache#1320").value
                                var"##1324" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1325" = var"##1324"[1]
                                    var"##1326" = var"##1324"[2]
                                    var"##1326" isa AbstractArray
                                end && ((ndims(var"##1326") === 1 && length(var"##1326") >= 0) && begin
                                        var"##1327" = SubArray(var"##1326", (1:length(var"##1326"),))
                                        true
                                    end))
                        var"##return#1317" = let args = var"##1327", head = var"##1325"
                                Expr(head, map(rm_nothing, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1318#1328")))
                    end
                end
                begin
                    var"##return#1317" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1318#1328")))
                end
                error("matching non-exhaustive, at #= none:220 =#")
                $(Expr(:symboliclabel, Symbol("####final#1318#1328")))
                var"##return#1317"
            end
        end
    #= none:233 =# Core.@doc "    canonicalize_lambda_head(ex)\n\nCanonicalize the `Expr(:function, Expr(:block, x, Expr(:(=), key, default)), body)` to\n\n```julia\nExpr(:function, Expr(:tuple, Expr(:parameters, Expr(:kw, key, default)), x), body)\n```\n" function canonicalize_lambda_head(ex)
            let
                begin
                    var"##cache#1332" = nothing
                end
                var"##return#1329" = nothing
                var"##1331" = ex
                if var"##1331" isa Expr
                    if begin
                                if var"##cache#1332" === nothing
                                    var"##cache#1332" = Some(((var"##1331").head, (var"##1331").args))
                                end
                                var"##1333" = (var"##cache#1332").value
                                var"##1333" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1333"[1] == :function && (begin
                                        var"##1334" = var"##1333"[2]
                                        var"##1334" isa AbstractArray
                                    end && (length(var"##1334") === 2 && (begin
                                                begin
                                                    var"##cache#1336" = nothing
                                                end
                                                var"##1335" = var"##1334"[1]
                                                var"##1335" isa Expr
                                            end && (begin
                                                    if var"##cache#1336" === nothing
                                                        var"##cache#1336" = Some(((var"##1335").head, (var"##1335").args))
                                                    end
                                                    var"##1337" = (var"##cache#1336").value
                                                    var"##1337" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1337"[1] == :block && (begin
                                                            var"##1338" = var"##1337"[2]
                                                            var"##1338" isa AbstractArray
                                                        end && (length(var"##1338") === 2 && begin
                                                                var"##1339" = var"##1338"[1]
                                                                var"##1340" = var"##1338"[2]
                                                                var"##1341" = var"##1334"[2]
                                                                true
                                                            end))))))))
                        var"##return#1329" = let y = var"##1340", body = var"##1341", x = var"##1339"
                                Expr(:function, Expr(:tuple, Expr(:parameters, y), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1330#1385")))
                    end
                    if begin
                                var"##1342" = (var"##cache#1332").value
                                var"##1342" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1342"[1] == :function && (begin
                                        var"##1343" = var"##1342"[2]
                                        var"##1343" isa AbstractArray
                                    end && (length(var"##1343") === 2 && (begin
                                                begin
                                                    var"##cache#1345" = nothing
                                                end
                                                var"##1344" = var"##1343"[1]
                                                var"##1344" isa Expr
                                            end && (begin
                                                    if var"##cache#1345" === nothing
                                                        var"##cache#1345" = Some(((var"##1344").head, (var"##1344").args))
                                                    end
                                                    var"##1346" = (var"##cache#1345").value
                                                    var"##1346" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1346"[1] == :block && (begin
                                                            var"##1347" = var"##1346"[2]
                                                            var"##1347" isa AbstractArray
                                                        end && (length(var"##1347") === 3 && (begin
                                                                    var"##1348" = var"##1347"[1]
                                                                    var"##1349" = var"##1347"[2]
                                                                    var"##1349" isa LineNumberNode
                                                                end && begin
                                                                    var"##1350" = var"##1347"[3]
                                                                    var"##1351" = var"##1343"[2]
                                                                    true
                                                                end)))))))))
                        var"##return#1329" = let y = var"##1350", body = var"##1351", x = var"##1348"
                                Expr(:function, Expr(:tuple, Expr(:parameters, y), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1330#1385")))
                    end
                    if begin
                                var"##1352" = (var"##cache#1332").value
                                var"##1352" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1352"[1] == :function && (begin
                                        var"##1353" = var"##1352"[2]
                                        var"##1353" isa AbstractArray
                                    end && (length(var"##1353") === 2 && (begin
                                                begin
                                                    var"##cache#1355" = nothing
                                                end
                                                var"##1354" = var"##1353"[1]
                                                var"##1354" isa Expr
                                            end && (begin
                                                    if var"##cache#1355" === nothing
                                                        var"##cache#1355" = Some(((var"##1354").head, (var"##1354").args))
                                                    end
                                                    var"##1356" = (var"##cache#1355").value
                                                    var"##1356" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1356"[1] == :block && (begin
                                                            var"##1357" = var"##1356"[2]
                                                            var"##1357" isa AbstractArray
                                                        end && (length(var"##1357") === 2 && (begin
                                                                    var"##1358" = var"##1357"[1]
                                                                    begin
                                                                        var"##cache#1360" = nothing
                                                                    end
                                                                    var"##1359" = var"##1357"[2]
                                                                    var"##1359" isa Expr
                                                                end && (begin
                                                                        if var"##cache#1360" === nothing
                                                                            var"##cache#1360" = Some(((var"##1359").head, (var"##1359").args))
                                                                        end
                                                                        var"##1361" = (var"##cache#1360").value
                                                                        var"##1361" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                    end && (var"##1361"[1] == :(=) && (begin
                                                                                var"##1362" = var"##1361"[2]
                                                                                var"##1362" isa AbstractArray
                                                                            end && (length(var"##1362") === 2 && begin
                                                                                    var"##1363" = var"##1362"[1]
                                                                                    var"##1364" = var"##1362"[2]
                                                                                    var"##1365" = var"##1353"[2]
                                                                                    true
                                                                                end)))))))))))))
                        var"##return#1329" = let default = var"##1364", key = var"##1363", body = var"##1365", x = var"##1358"
                                Expr(:function, Expr(:tuple, Expr(:parameters, Expr(:kw, key, default)), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1330#1385")))
                    end
                    if begin
                                var"##1366" = (var"##cache#1332").value
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
                                                        end && (length(var"##1371") === 3 && (begin
                                                                    var"##1372" = var"##1371"[1]
                                                                    var"##1373" = var"##1371"[2]
                                                                    var"##1373" isa LineNumberNode
                                                                end && (begin
                                                                        begin
                                                                            var"##cache#1375" = nothing
                                                                        end
                                                                        var"##1374" = var"##1371"[3]
                                                                        var"##1374" isa Expr
                                                                    end && (begin
                                                                            if var"##cache#1375" === nothing
                                                                                var"##cache#1375" = Some(((var"##1374").head, (var"##1374").args))
                                                                            end
                                                                            var"##1376" = (var"##cache#1375").value
                                                                            var"##1376" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                        end && (var"##1376"[1] == :(=) && (begin
                                                                                    var"##1377" = var"##1376"[2]
                                                                                    var"##1377" isa AbstractArray
                                                                                end && (length(var"##1377") === 2 && begin
                                                                                        var"##1378" = var"##1377"[1]
                                                                                        var"##1379" = var"##1377"[2]
                                                                                        var"##1380" = var"##1367"[2]
                                                                                        true
                                                                                    end))))))))))))))
                        var"##return#1329" = let default = var"##1379", key = var"##1378", body = var"##1380", x = var"##1372"
                                Expr(:function, Expr(:tuple, Expr(:parameters, Expr(:kw, key, default)), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1330#1385")))
                    end
                    if begin
                                var"##1381" = (var"##cache#1332").value
                                var"##1381" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1382" = var"##1381"[1]
                                    var"##1383" = var"##1381"[2]
                                    var"##1383" isa AbstractArray
                                end && ((ndims(var"##1383") === 1 && length(var"##1383") >= 0) && begin
                                        var"##1384" = SubArray(var"##1383", (1:length(var"##1383"),))
                                        true
                                    end))
                        var"##return#1329" = let args = var"##1384", head = var"##1382"
                                Expr(head, map(canonicalize_lambda_head, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1330#1385")))
                    end
                end
                begin
                    var"##return#1329" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1330#1385")))
                end
                error("matching non-exhaustive, at #= none:243 =#")
                $(Expr(:symboliclabel, Symbol("####final#1330#1385")))
                var"##return#1329"
            end
        end
    function rm_single_block(ex)
        let
            begin
                var"##cache#1389" = nothing
            end
            var"##return#1386" = nothing
            var"##1388" = ex
            if var"##1388" isa Expr
                if begin
                            if var"##cache#1389" === nothing
                                var"##cache#1389" = Some(((var"##1388").head, (var"##1388").args))
                            end
                            var"##1390" = (var"##cache#1389").value
                            var"##1390" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1390"[1] == :(=) && (begin
                                    var"##1391" = var"##1390"[2]
                                    var"##1391" isa AbstractArray
                                end && (ndims(var"##1391") === 1 && length(var"##1391") >= 0)))
                    var"##return#1386" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1387#1454")))
                end
                if begin
                            var"##1392" = (var"##cache#1389").value
                            var"##1392" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1392"[1] == :-> && (begin
                                    var"##1393" = var"##1392"[2]
                                    var"##1393" isa AbstractArray
                                end && (ndims(var"##1393") === 1 && length(var"##1393") >= 0)))
                    var"##return#1386" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1387#1454")))
                end
                if begin
                            var"##1394" = (var"##cache#1389").value
                            var"##1394" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1394"[1] == :quote && (begin
                                    var"##1395" = var"##1394"[2]
                                    var"##1395" isa AbstractArray
                                end && ((ndims(var"##1395") === 1 && length(var"##1395") >= 0) && begin
                                        var"##1396" = SubArray(var"##1395", (1:length(var"##1395"),))
                                        true
                                    end)))
                    var"##return#1386" = let xs = var"##1396"
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1387#1454")))
                end
                if begin
                            var"##1397" = (var"##cache#1389").value
                            var"##1397" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1397"[1] == :block && (begin
                                    var"##1398" = var"##1397"[2]
                                    var"##1398" isa AbstractArray
                                end && (length(var"##1398") === 1 && (begin
                                            begin
                                                var"##cache#1400" = nothing
                                            end
                                            var"##1399" = var"##1398"[1]
                                            var"##1399" isa Expr
                                        end && (begin
                                                if var"##cache#1400" === nothing
                                                    var"##cache#1400" = Some(((var"##1399").head, (var"##1399").args))
                                                end
                                                var"##1401" = (var"##cache#1400").value
                                                var"##1401" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1401"[1] == :quote && (begin
                                                        var"##1402" = var"##1401"[2]
                                                        var"##1402" isa AbstractArray
                                                    end && ((ndims(var"##1402") === 1 && length(var"##1402") >= 0) && begin
                                                            var"##1403" = SubArray(var"##1402", (1:length(var"##1402"),))
                                                            true
                                                        end))))))))
                    var"##return#1386" = let xs = var"##1403"
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1387#1454")))
                end
                if begin
                            var"##1404" = (var"##cache#1389").value
                            var"##1404" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1404"[1] == :try && (begin
                                    var"##1405" = var"##1404"[2]
                                    var"##1405" isa AbstractArray
                                end && (length(var"##1405") === 4 && (begin
                                            begin
                                                var"##cache#1407" = nothing
                                            end
                                            var"##1406" = var"##1405"[1]
                                            var"##1406" isa Expr
                                        end && (begin
                                                if var"##cache#1407" === nothing
                                                    var"##cache#1407" = Some(((var"##1406").head, (var"##1406").args))
                                                end
                                                var"##1408" = (var"##cache#1407").value
                                                var"##1408" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1408"[1] == :block && (begin
                                                        var"##1409" = var"##1408"[2]
                                                        var"##1409" isa AbstractArray
                                                    end && ((ndims(var"##1409") === 1 && length(var"##1409") >= 0) && (begin
                                                                var"##1410" = SubArray(var"##1409", (1:length(var"##1409"),))
                                                                var"##1405"[2] === false
                                                            end && (var"##1405"[3] === false && (begin
                                                                        begin
                                                                            var"##cache#1412" = nothing
                                                                        end
                                                                        var"##1411" = var"##1405"[4]
                                                                        var"##1411" isa Expr
                                                                    end && (begin
                                                                            if var"##cache#1412" === nothing
                                                                                var"##cache#1412" = Some(((var"##1411").head, (var"##1411").args))
                                                                            end
                                                                            var"##1413" = (var"##cache#1412").value
                                                                            var"##1413" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                        end && (var"##1413"[1] == :block && (begin
                                                                                    var"##1414" = var"##1413"[2]
                                                                                    var"##1414" isa AbstractArray
                                                                                end && ((ndims(var"##1414") === 1 && length(var"##1414") >= 0) && begin
                                                                                        var"##1415" = SubArray(var"##1414", (1:length(var"##1414"),))
                                                                                        true
                                                                                    end)))))))))))))))
                    var"##return#1386" = let try_stmts = var"##1410", finally_stmts = var"##1415"
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), false, false, Expr(:block, rm_single_block.(finally_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1387#1454")))
                end
                if begin
                            var"##1416" = (var"##cache#1389").value
                            var"##1416" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1416"[1] == :try && (begin
                                    var"##1417" = var"##1416"[2]
                                    var"##1417" isa AbstractArray
                                end && (length(var"##1417") === 3 && (begin
                                            begin
                                                var"##cache#1419" = nothing
                                            end
                                            var"##1418" = var"##1417"[1]
                                            var"##1418" isa Expr
                                        end && (begin
                                                if var"##cache#1419" === nothing
                                                    var"##cache#1419" = Some(((var"##1418").head, (var"##1418").args))
                                                end
                                                var"##1420" = (var"##cache#1419").value
                                                var"##1420" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1420"[1] == :block && (begin
                                                        var"##1421" = var"##1420"[2]
                                                        var"##1421" isa AbstractArray
                                                    end && ((ndims(var"##1421") === 1 && length(var"##1421") >= 0) && (begin
                                                                var"##1422" = SubArray(var"##1421", (1:length(var"##1421"),))
                                                                var"##1423" = var"##1417"[2]
                                                                begin
                                                                    var"##cache#1425" = nothing
                                                                end
                                                                var"##1424" = var"##1417"[3]
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
                                                                        end && ((ndims(var"##1427") === 1 && length(var"##1427") >= 0) && begin
                                                                                var"##1428" = SubArray(var"##1427", (1:length(var"##1427"),))
                                                                                true
                                                                            end)))))))))))))
                    var"##return#1386" = let try_stmts = var"##1422", catch_stmts = var"##1428", catch_var = var"##1423"
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), catch_var, Expr(:block, rm_single_block.(catch_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1387#1454")))
                end
                if begin
                            var"##1429" = (var"##cache#1389").value
                            var"##1429" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1429"[1] == :try && (begin
                                    var"##1430" = var"##1429"[2]
                                    var"##1430" isa AbstractArray
                                end && (length(var"##1430") === 4 && (begin
                                            begin
                                                var"##cache#1432" = nothing
                                            end
                                            var"##1431" = var"##1430"[1]
                                            var"##1431" isa Expr
                                        end && (begin
                                                if var"##cache#1432" === nothing
                                                    var"##cache#1432" = Some(((var"##1431").head, (var"##1431").args))
                                                end
                                                var"##1433" = (var"##cache#1432").value
                                                var"##1433" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1433"[1] == :block && (begin
                                                        var"##1434" = var"##1433"[2]
                                                        var"##1434" isa AbstractArray
                                                    end && ((ndims(var"##1434") === 1 && length(var"##1434") >= 0) && (begin
                                                                var"##1435" = SubArray(var"##1434", (1:length(var"##1434"),))
                                                                var"##1436" = var"##1430"[2]
                                                                begin
                                                                    var"##cache#1438" = nothing
                                                                end
                                                                var"##1437" = var"##1430"[3]
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
                                                                                    begin
                                                                                        var"##cache#1443" = nothing
                                                                                    end
                                                                                    var"##1442" = var"##1430"[4]
                                                                                    var"##1442" isa Expr
                                                                                end && (begin
                                                                                        if var"##cache#1443" === nothing
                                                                                            var"##cache#1443" = Some(((var"##1442").head, (var"##1442").args))
                                                                                        end
                                                                                        var"##1444" = (var"##cache#1443").value
                                                                                        var"##1444" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                                    end && (var"##1444"[1] == :block && (begin
                                                                                                var"##1445" = var"##1444"[2]
                                                                                                var"##1445" isa AbstractArray
                                                                                            end && ((ndims(var"##1445") === 1 && length(var"##1445") >= 0) && begin
                                                                                                    var"##1446" = SubArray(var"##1445", (1:length(var"##1445"),))
                                                                                                    true
                                                                                                end))))))))))))))))))
                    var"##return#1386" = let try_stmts = var"##1435", catch_stmts = var"##1441", catch_var = var"##1436", finally_stmts = var"##1446"
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), catch_var, Expr(:block, rm_single_block.(catch_stmts)...), Expr(:block, rm_single_block.(finally_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1387#1454")))
                end
                if begin
                            var"##1447" = (var"##cache#1389").value
                            var"##1447" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1447"[1] == :block && (begin
                                    var"##1448" = var"##1447"[2]
                                    var"##1448" isa AbstractArray
                                end && (length(var"##1448") === 1 && begin
                                        var"##1449" = var"##1448"[1]
                                        true
                                    end)))
                    var"##return#1386" = let stmt = var"##1449"
                            stmt
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1387#1454")))
                end
                if begin
                            var"##1450" = (var"##cache#1389").value
                            var"##1450" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                        end && (begin
                                var"##1451" = var"##1450"[1]
                                var"##1452" = var"##1450"[2]
                                var"##1452" isa AbstractArray
                            end && ((ndims(var"##1452") === 1 && length(var"##1452") >= 0) && begin
                                    var"##1453" = SubArray(var"##1452", (1:length(var"##1452"),))
                                    true
                                end))
                    var"##return#1386" = let args = var"##1453", head = var"##1451"
                            Expr(head, map(rm_single_block, args)...)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1387#1454")))
                end
            end
            begin
                var"##return#1386" = let
                        ex
                    end
                $(Expr(:symbolicgoto, Symbol("####final#1387#1454")))
            end
            error("matching non-exhaustive, at #= none:259 =#")
            $(Expr(:symboliclabel, Symbol("####final#1387#1454")))
            var"##return#1386"
        end
    end
    #= none:287 =# Core.@doc "    rm_annotations(x)\n\nRemove type annotation of given expression.\n" function rm_annotations(x)
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
    #= none:307 =# Core.@doc "    alias_gensym(ex)\n\nReplace gensym with `<name>_<id>`.\n\n!!! note\n    Borrowed from [MacroTools](https://github.com/FluxML/MacroTools.jl).\n" alias_gensym(ex) = begin
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
    #= none:335 =# Core.@doc "    renumber_gensym(ex)\n\nRe-number gensym with counter from this expression.\nProduce a deterministic gensym name for testing etc.\nSee also: [`alias_gensym`](@ref)\n" renumber_gensym(ex) = begin
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
    #= none:369 =# Core.@doc "    expr_map(f, c...; skip_nothing::Bool=false)\n\nSimilar to `Base.map`, but expects `f` to return an expression,\nand will concanate these expression as a `Expr(:block, ...)`\nexpression.\n\nSkip `nothing` if `skip_nothing` is `true`.\n\n# Example\n\n```jldoctest\njulia> expr_map(1:10, 2:11) do i,j\n           :(1 + \$i + \$j)\n       end\nquote\n    1 + 1 + 2\n    1 + 2 + 3\n    1 + 3 + 4\n    1 + 4 + 5\n    1 + 5 + 6\n    1 + 6 + 7\n    1 + 7 + 8\n    1 + 8 + 9\n    1 + 9 + 10\n    1 + 10 + 11\nend\n```\n" function expr_map(f, c...; skip_nothing::Bool = false)
            ex = Expr(:block)
            for args = zip(c...)
                ret = f(args...)
                skip_nothing && (isnothing(ret) && continue)
                push!(ex.args, ret)
            end
            return ex
        end
    #= none:408 =# Core.@doc "    nexprs(f, n::Int)\n\nCreate `n` similar expressions by evaluating `f`.\n\n# Example\n\n```jldoctest\njulia> nexprs(5) do k\n           :(1 + \$k)\n       end\nquote\n    1 + 1\n    1 + 2\n    1 + 3\n    1 + 4\n    1 + 5\nend\n```\n" nexprs(f, k::Int) = begin
                expr_map(f, 1:k)
            end
    #= none:430 =# Core.@doc "    Substitute(condition) -> substitute(f(expr), expr)\n\nReturns a function that substitutes `expr` with\n`f(expr)` if `condition(expr)` is true. Applied\nrecursively to all sub-expressions.\n\n# Example\n\n```jldoctest\njulia> sub = Substitute() do expr\n           expr isa Symbol && expr in [:x] && return true\n           return false\n       end;\n\njulia> sub(_->1, :(x + y))\n:(1 + y)\n```\n" struct Substitute
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
