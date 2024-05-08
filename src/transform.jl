
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
                    var"##cache#1317" = nothing
                end
                var"##return#1314" = nothing
                var"##1316" = ex
                if var"##1316" isa Expr
                    if begin
                                if var"##cache#1317" === nothing
                                    var"##cache#1317" = Some(((var"##1316").head, (var"##1316").args))
                                end
                                var"##1318" = (var"##cache#1317").value
                                var"##1318" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1318"[1] == :macrocall && (begin
                                        var"##1319" = var"##1318"[2]
                                        var"##1319" isa AbstractArray
                                    end && ((ndims(var"##1319") === 1 && length(var"##1319") >= 2) && begin
                                            var"##1320" = var"##1319"[1]
                                            var"##1321" = var"##1319"[2]
                                            var"##1322" = SubArray(var"##1319", (3:length(var"##1319"),))
                                            true
                                        end)))
                        var"##return#1314" = let line = var"##1321", name = var"##1320", args = var"##1322"
                                Expr(:macrocall, name, line, map(rm_lineinfo, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1315#1327")))
                    end
                    if begin
                                var"##1323" = (var"##cache#1317").value
                                var"##1323" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1324" = var"##1323"[1]
                                    var"##1325" = var"##1323"[2]
                                    var"##1325" isa AbstractArray
                                end && ((ndims(var"##1325") === 1 && length(var"##1325") >= 0) && begin
                                        var"##1326" = SubArray(var"##1325", (1:length(var"##1325"),))
                                        true
                                    end))
                        var"##return#1314" = let args = var"##1326", head = var"##1324"
                                Expr(head, map(rm_lineinfo, filter((x->begin
                                                    !(x isa LineNumberNode)
                                                end), args))...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1315#1327")))
                    end
                end
                begin
                    var"##return#1314" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1315#1327")))
                end
                error("matching non-exhaustive, at #= none:108 =#")
                $(Expr(:symboliclabel, Symbol("####final#1315#1327")))
                var"##return#1314"
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
                    var"##cache#1331" = nothing
                end
                var"##return#1328" = nothing
                var"##1330" = ex
                if var"##1330" isa Expr
                    if begin
                                if var"##cache#1331" === nothing
                                    var"##cache#1331" = Some(((var"##1330").head, (var"##1330").args))
                                end
                                var"##1332" = (var"##cache#1331").value
                                var"##1332" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1332"[1] == :block && (begin
                                        var"##1333" = var"##1332"[2]
                                        var"##1333" isa AbstractArray
                                    end && ((ndims(var"##1333") === 1 && length(var"##1333") >= 0) && begin
                                            var"##1334" = SubArray(var"##1333", (1:length(var"##1333"),))
                                            true
                                        end)))
                        var"##return#1328" = let args = var"##1334"
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
                        $(Expr(:symbolicgoto, Symbol("####final#1329#1339")))
                    end
                    if begin
                                var"##1335" = (var"##cache#1331").value
                                var"##1335" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1336" = var"##1335"[1]
                                    var"##1337" = var"##1335"[2]
                                    var"##1337" isa AbstractArray
                                end && ((ndims(var"##1337") === 1 && length(var"##1337") >= 0) && begin
                                        var"##1338" = SubArray(var"##1337", (1:length(var"##1337"),))
                                        true
                                    end))
                        var"##return#1328" = let args = var"##1338", head = var"##1336"
                                Expr(head, map(rm_nothing, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1329#1339")))
                    end
                end
                begin
                    var"##return#1328" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1329#1339")))
                end
                error("matching non-exhaustive, at #= none:219 =#")
                $(Expr(:symboliclabel, Symbol("####final#1329#1339")))
                var"##return#1328"
            end
        end
    #= none:232 =# Core.@doc "    canonicalize_lambda_head(ex)\n\nCanonicalize the `Expr(:function, Expr(:block, x, Expr(:(=), key, default)), body)` to\n\n```julia\nExpr(:function, Expr(:tuple, Expr(:parameters, Expr(:kw, key, default)), x), body)\n```\n" function canonicalize_lambda_head(ex)
            let
                begin
                    var"##cache#1343" = nothing
                end
                var"##return#1340" = nothing
                var"##1342" = ex
                if var"##1342" isa Expr
                    if begin
                                if var"##cache#1343" === nothing
                                    var"##cache#1343" = Some(((var"##1342").head, (var"##1342").args))
                                end
                                var"##1344" = (var"##cache#1343").value
                                var"##1344" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1344"[1] == :function && (begin
                                        var"##1345" = var"##1344"[2]
                                        var"##1345" isa AbstractArray
                                    end && (length(var"##1345") === 2 && (begin
                                                begin
                                                    var"##cache#1347" = nothing
                                                end
                                                var"##1346" = var"##1345"[1]
                                                var"##1346" isa Expr
                                            end && (begin
                                                    if var"##cache#1347" === nothing
                                                        var"##cache#1347" = Some(((var"##1346").head, (var"##1346").args))
                                                    end
                                                    var"##1348" = (var"##cache#1347").value
                                                    var"##1348" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1348"[1] == :block && (begin
                                                            var"##1349" = var"##1348"[2]
                                                            var"##1349" isa AbstractArray
                                                        end && (length(var"##1349") === 2 && begin
                                                                var"##1350" = var"##1349"[1]
                                                                var"##1351" = var"##1349"[2]
                                                                var"##1352" = var"##1345"[2]
                                                                true
                                                            end))))))))
                        var"##return#1340" = let y = var"##1351", body = var"##1352", x = var"##1350"
                                Expr(:function, Expr(:tuple, Expr(:parameters, y), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1341#1396")))
                    end
                    if begin
                                var"##1353" = (var"##cache#1343").value
                                var"##1353" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1353"[1] == :function && (begin
                                        var"##1354" = var"##1353"[2]
                                        var"##1354" isa AbstractArray
                                    end && (length(var"##1354") === 2 && (begin
                                                begin
                                                    var"##cache#1356" = nothing
                                                end
                                                var"##1355" = var"##1354"[1]
                                                var"##1355" isa Expr
                                            end && (begin
                                                    if var"##cache#1356" === nothing
                                                        var"##cache#1356" = Some(((var"##1355").head, (var"##1355").args))
                                                    end
                                                    var"##1357" = (var"##cache#1356").value
                                                    var"##1357" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1357"[1] == :block && (begin
                                                            var"##1358" = var"##1357"[2]
                                                            var"##1358" isa AbstractArray
                                                        end && (length(var"##1358") === 3 && (begin
                                                                    var"##1359" = var"##1358"[1]
                                                                    var"##1360" = var"##1358"[2]
                                                                    var"##1360" isa LineNumberNode
                                                                end && begin
                                                                    var"##1361" = var"##1358"[3]
                                                                    var"##1362" = var"##1354"[2]
                                                                    true
                                                                end)))))))))
                        var"##return#1340" = let y = var"##1361", body = var"##1362", x = var"##1359"
                                Expr(:function, Expr(:tuple, Expr(:parameters, y), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1341#1396")))
                    end
                    if begin
                                var"##1363" = (var"##cache#1343").value
                                var"##1363" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1363"[1] == :function && (begin
                                        var"##1364" = var"##1363"[2]
                                        var"##1364" isa AbstractArray
                                    end && (length(var"##1364") === 2 && (begin
                                                begin
                                                    var"##cache#1366" = nothing
                                                end
                                                var"##1365" = var"##1364"[1]
                                                var"##1365" isa Expr
                                            end && (begin
                                                    if var"##cache#1366" === nothing
                                                        var"##cache#1366" = Some(((var"##1365").head, (var"##1365").args))
                                                    end
                                                    var"##1367" = (var"##cache#1366").value
                                                    var"##1367" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1367"[1] == :block && (begin
                                                            var"##1368" = var"##1367"[2]
                                                            var"##1368" isa AbstractArray
                                                        end && (length(var"##1368") === 2 && (begin
                                                                    var"##1369" = var"##1368"[1]
                                                                    begin
                                                                        var"##cache#1371" = nothing
                                                                    end
                                                                    var"##1370" = var"##1368"[2]
                                                                    var"##1370" isa Expr
                                                                end && (begin
                                                                        if var"##cache#1371" === nothing
                                                                            var"##cache#1371" = Some(((var"##1370").head, (var"##1370").args))
                                                                        end
                                                                        var"##1372" = (var"##cache#1371").value
                                                                        var"##1372" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                    end && (var"##1372"[1] == :(=) && (begin
                                                                                var"##1373" = var"##1372"[2]
                                                                                var"##1373" isa AbstractArray
                                                                            end && (length(var"##1373") === 2 && begin
                                                                                    var"##1374" = var"##1373"[1]
                                                                                    var"##1375" = var"##1373"[2]
                                                                                    var"##1376" = var"##1364"[2]
                                                                                    true
                                                                                end)))))))))))))
                        var"##return#1340" = let default = var"##1375", key = var"##1374", body = var"##1376", x = var"##1369"
                                Expr(:function, Expr(:tuple, Expr(:parameters, Expr(:kw, key, default)), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1341#1396")))
                    end
                    if begin
                                var"##1377" = (var"##cache#1343").value
                                var"##1377" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1377"[1] == :function && (begin
                                        var"##1378" = var"##1377"[2]
                                        var"##1378" isa AbstractArray
                                    end && (length(var"##1378") === 2 && (begin
                                                begin
                                                    var"##cache#1380" = nothing
                                                end
                                                var"##1379" = var"##1378"[1]
                                                var"##1379" isa Expr
                                            end && (begin
                                                    if var"##cache#1380" === nothing
                                                        var"##cache#1380" = Some(((var"##1379").head, (var"##1379").args))
                                                    end
                                                    var"##1381" = (var"##cache#1380").value
                                                    var"##1381" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1381"[1] == :block && (begin
                                                            var"##1382" = var"##1381"[2]
                                                            var"##1382" isa AbstractArray
                                                        end && (length(var"##1382") === 3 && (begin
                                                                    var"##1383" = var"##1382"[1]
                                                                    var"##1384" = var"##1382"[2]
                                                                    var"##1384" isa LineNumberNode
                                                                end && (begin
                                                                        begin
                                                                            var"##cache#1386" = nothing
                                                                        end
                                                                        var"##1385" = var"##1382"[3]
                                                                        var"##1385" isa Expr
                                                                    end && (begin
                                                                            if var"##cache#1386" === nothing
                                                                                var"##cache#1386" = Some(((var"##1385").head, (var"##1385").args))
                                                                            end
                                                                            var"##1387" = (var"##cache#1386").value
                                                                            var"##1387" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                        end && (var"##1387"[1] == :(=) && (begin
                                                                                    var"##1388" = var"##1387"[2]
                                                                                    var"##1388" isa AbstractArray
                                                                                end && (length(var"##1388") === 2 && begin
                                                                                        var"##1389" = var"##1388"[1]
                                                                                        var"##1390" = var"##1388"[2]
                                                                                        var"##1391" = var"##1378"[2]
                                                                                        true
                                                                                    end))))))))))))))
                        var"##return#1340" = let default = var"##1390", key = var"##1389", body = var"##1391", x = var"##1383"
                                Expr(:function, Expr(:tuple, Expr(:parameters, Expr(:kw, key, default)), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1341#1396")))
                    end
                    if begin
                                var"##1392" = (var"##cache#1343").value
                                var"##1392" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1393" = var"##1392"[1]
                                    var"##1394" = var"##1392"[2]
                                    var"##1394" isa AbstractArray
                                end && ((ndims(var"##1394") === 1 && length(var"##1394") >= 0) && begin
                                        var"##1395" = SubArray(var"##1394", (1:length(var"##1394"),))
                                        true
                                    end))
                        var"##return#1340" = let args = var"##1395", head = var"##1393"
                                Expr(head, map(canonicalize_lambda_head, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1341#1396")))
                    end
                end
                begin
                    var"##return#1340" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1341#1396")))
                end
                error("matching non-exhaustive, at #= none:242 =#")
                $(Expr(:symboliclabel, Symbol("####final#1341#1396")))
                var"##return#1340"
            end
        end
    function rm_single_block(ex)
        let
            begin
                var"##cache#1400" = nothing
            end
            var"##return#1397" = nothing
            var"##1399" = ex
            if var"##1399" isa Expr
                if begin
                            if var"##cache#1400" === nothing
                                var"##cache#1400" = Some(((var"##1399").head, (var"##1399").args))
                            end
                            var"##1401" = (var"##cache#1400").value
                            var"##1401" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1401"[1] == :(=) && (begin
                                    var"##1402" = var"##1401"[2]
                                    var"##1402" isa AbstractArray
                                end && (ndims(var"##1402") === 1 && length(var"##1402") >= 0)))
                    var"##return#1397" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1398#1465")))
                end
                if begin
                            var"##1403" = (var"##cache#1400").value
                            var"##1403" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1403"[1] == :-> && (begin
                                    var"##1404" = var"##1403"[2]
                                    var"##1404" isa AbstractArray
                                end && (ndims(var"##1404") === 1 && length(var"##1404") >= 0)))
                    var"##return#1397" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1398#1465")))
                end
                if begin
                            var"##1405" = (var"##cache#1400").value
                            var"##1405" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1405"[1] == :quote && (begin
                                    var"##1406" = var"##1405"[2]
                                    var"##1406" isa AbstractArray
                                end && ((ndims(var"##1406") === 1 && length(var"##1406") >= 0) && begin
                                        var"##1407" = SubArray(var"##1406", (1:length(var"##1406"),))
                                        true
                                    end)))
                    var"##return#1397" = let xs = var"##1407"
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1398#1465")))
                end
                if begin
                            var"##1408" = (var"##cache#1400").value
                            var"##1408" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1408"[1] == :block && (begin
                                    var"##1409" = var"##1408"[2]
                                    var"##1409" isa AbstractArray
                                end && (length(var"##1409") === 1 && (begin
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
                                            end && (var"##1412"[1] == :quote && (begin
                                                        var"##1413" = var"##1412"[2]
                                                        var"##1413" isa AbstractArray
                                                    end && ((ndims(var"##1413") === 1 && length(var"##1413") >= 0) && begin
                                                            var"##1414" = SubArray(var"##1413", (1:length(var"##1413"),))
                                                            true
                                                        end))))))))
                    var"##return#1397" = let xs = var"##1414"
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1398#1465")))
                end
                if begin
                            var"##1415" = (var"##cache#1400").value
                            var"##1415" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1415"[1] == :try && (begin
                                    var"##1416" = var"##1415"[2]
                                    var"##1416" isa AbstractArray
                                end && (length(var"##1416") === 4 && (begin
                                            begin
                                                var"##cache#1418" = nothing
                                            end
                                            var"##1417" = var"##1416"[1]
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
                                                    end && ((ndims(var"##1420") === 1 && length(var"##1420") >= 0) && (begin
                                                                var"##1421" = SubArray(var"##1420", (1:length(var"##1420"),))
                                                                var"##1416"[2] === false
                                                            end && (var"##1416"[3] === false && (begin
                                                                        begin
                                                                            var"##cache#1423" = nothing
                                                                        end
                                                                        var"##1422" = var"##1416"[4]
                                                                        var"##1422" isa Expr
                                                                    end && (begin
                                                                            if var"##cache#1423" === nothing
                                                                                var"##cache#1423" = Some(((var"##1422").head, (var"##1422").args))
                                                                            end
                                                                            var"##1424" = (var"##cache#1423").value
                                                                            var"##1424" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                        end && (var"##1424"[1] == :block && (begin
                                                                                    var"##1425" = var"##1424"[2]
                                                                                    var"##1425" isa AbstractArray
                                                                                end && ((ndims(var"##1425") === 1 && length(var"##1425") >= 0) && begin
                                                                                        var"##1426" = SubArray(var"##1425", (1:length(var"##1425"),))
                                                                                        true
                                                                                    end)))))))))))))))
                    var"##return#1397" = let try_stmts = var"##1421", finally_stmts = var"##1426"
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), false, false, Expr(:block, rm_single_block.(finally_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1398#1465")))
                end
                if begin
                            var"##1427" = (var"##cache#1400").value
                            var"##1427" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1427"[1] == :try && (begin
                                    var"##1428" = var"##1427"[2]
                                    var"##1428" isa AbstractArray
                                end && (length(var"##1428") === 3 && (begin
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
                                                    end && ((ndims(var"##1432") === 1 && length(var"##1432") >= 0) && (begin
                                                                var"##1433" = SubArray(var"##1432", (1:length(var"##1432"),))
                                                                var"##1434" = var"##1428"[2]
                                                                begin
                                                                    var"##cache#1436" = nothing
                                                                end
                                                                var"##1435" = var"##1428"[3]
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
                                                                        end && ((ndims(var"##1438") === 1 && length(var"##1438") >= 0) && begin
                                                                                var"##1439" = SubArray(var"##1438", (1:length(var"##1438"),))
                                                                                true
                                                                            end)))))))))))))
                    var"##return#1397" = let try_stmts = var"##1433", catch_stmts = var"##1439", catch_var = var"##1434"
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), catch_var, Expr(:block, rm_single_block.(catch_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1398#1465")))
                end
                if begin
                            var"##1440" = (var"##cache#1400").value
                            var"##1440" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1440"[1] == :try && (begin
                                    var"##1441" = var"##1440"[2]
                                    var"##1441" isa AbstractArray
                                end && (length(var"##1441") === 4 && (begin
                                            begin
                                                var"##cache#1443" = nothing
                                            end
                                            var"##1442" = var"##1441"[1]
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
                                                    end && ((ndims(var"##1445") === 1 && length(var"##1445") >= 0) && (begin
                                                                var"##1446" = SubArray(var"##1445", (1:length(var"##1445"),))
                                                                var"##1447" = var"##1441"[2]
                                                                begin
                                                                    var"##cache#1449" = nothing
                                                                end
                                                                var"##1448" = var"##1441"[3]
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
                                                                        end && ((ndims(var"##1451") === 1 && length(var"##1451") >= 0) && (begin
                                                                                    var"##1452" = SubArray(var"##1451", (1:length(var"##1451"),))
                                                                                    begin
                                                                                        var"##cache#1454" = nothing
                                                                                    end
                                                                                    var"##1453" = var"##1441"[4]
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
                                                                                            end && ((ndims(var"##1456") === 1 && length(var"##1456") >= 0) && begin
                                                                                                    var"##1457" = SubArray(var"##1456", (1:length(var"##1456"),))
                                                                                                    true
                                                                                                end))))))))))))))))))
                    var"##return#1397" = let try_stmts = var"##1446", catch_stmts = var"##1452", catch_var = var"##1447", finally_stmts = var"##1457"
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), catch_var, Expr(:block, rm_single_block.(catch_stmts)...), Expr(:block, rm_single_block.(finally_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1398#1465")))
                end
                if begin
                            var"##1458" = (var"##cache#1400").value
                            var"##1458" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1458"[1] == :block && (begin
                                    var"##1459" = var"##1458"[2]
                                    var"##1459" isa AbstractArray
                                end && (length(var"##1459") === 1 && begin
                                        var"##1460" = var"##1459"[1]
                                        true
                                    end)))
                    var"##return#1397" = let stmt = var"##1460"
                            stmt
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1398#1465")))
                end
                if begin
                            var"##1461" = (var"##cache#1400").value
                            var"##1461" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                        end && (begin
                                var"##1462" = var"##1461"[1]
                                var"##1463" = var"##1461"[2]
                                var"##1463" isa AbstractArray
                            end && ((ndims(var"##1463") === 1 && length(var"##1463") >= 0) && begin
                                    var"##1464" = SubArray(var"##1463", (1:length(var"##1463"),))
                                    true
                                end))
                    var"##return#1397" = let args = var"##1464", head = var"##1462"
                            Expr(head, map(rm_single_block, args)...)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1398#1465")))
                end
            end
            begin
                var"##return#1397" = let
                        ex
                    end
                $(Expr(:symbolicgoto, Symbol("####final#1398#1465")))
            end
            error("matching non-exhaustive, at #= none:258 =#")
            $(Expr(:symboliclabel, Symbol("####final#1398#1465")))
            var"##return#1397"
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
