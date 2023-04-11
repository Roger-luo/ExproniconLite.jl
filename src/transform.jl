
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
                    var"##cache#1302" = nothing
                end
                var"##return#1299" = nothing
                var"##1301" = ex
                if var"##1301" isa Expr
                    if begin
                                if var"##cache#1302" === nothing
                                    var"##cache#1302" = Some(((var"##1301").head, (var"##1301").args))
                                end
                                var"##1303" = (var"##cache#1302").value
                                var"##1303" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1303"[1] == :macrocall && (begin
                                        var"##1304" = var"##1303"[2]
                                        var"##1304" isa AbstractArray
                                    end && ((ndims(var"##1304") === 1 && length(var"##1304") >= 2) && begin
                                            var"##1305" = var"##1304"[1]
                                            var"##1306" = var"##1304"[2]
                                            var"##1307" = SubArray(var"##1304", (3:length(var"##1304"),))
                                            true
                                        end)))
                        var"##return#1299" = let line = var"##1306", name = var"##1305", args = var"##1307"
                                Expr(:macrocall, name, line, map(rm_lineinfo, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1300#1312")))
                    end
                    if begin
                                var"##1308" = (var"##cache#1302").value
                                var"##1308" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1309" = var"##1308"[1]
                                    var"##1310" = var"##1308"[2]
                                    var"##1310" isa AbstractArray
                                end && ((ndims(var"##1310") === 1 && length(var"##1310") >= 0) && begin
                                        var"##1311" = SubArray(var"##1310", (1:length(var"##1310"),))
                                        true
                                    end))
                        var"##return#1299" = let args = var"##1311", head = var"##1309"
                                Expr(head, map(rm_lineinfo, filter((x->begin
                                                    !(x isa LineNumberNode)
                                                end), args))...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1300#1312")))
                    end
                end
                begin
                    var"##return#1299" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1300#1312")))
                end
                error("matching non-exhaustive, at #= none:106 =#")
                $(Expr(:symboliclabel, Symbol("####final#1300#1312")))
                var"##return#1299"
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
                    var"##cache#1316" = nothing
                end
                var"##return#1313" = nothing
                var"##1315" = ex
                if var"##1315" isa Expr
                    if begin
                                if var"##cache#1316" === nothing
                                    var"##cache#1316" = Some(((var"##1315").head, (var"##1315").args))
                                end
                                var"##1317" = (var"##cache#1316").value
                                var"##1317" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1317"[1] == :block && (begin
                                        var"##1318" = var"##1317"[2]
                                        var"##1318" isa AbstractArray
                                    end && ((ndims(var"##1318") === 1 && length(var"##1318") >= 0) && begin
                                            var"##1319" = SubArray(var"##1318", (1:length(var"##1318"),))
                                            true
                                        end)))
                        var"##return#1313" = let args = var"##1319"
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
                        $(Expr(:symbolicgoto, Symbol("####final#1314#1324")))
                    end
                    if begin
                                var"##1320" = (var"##cache#1316").value
                                var"##1320" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1321" = var"##1320"[1]
                                    var"##1322" = var"##1320"[2]
                                    var"##1322" isa AbstractArray
                                end && ((ndims(var"##1322") === 1 && length(var"##1322") >= 0) && begin
                                        var"##1323" = SubArray(var"##1322", (1:length(var"##1322"),))
                                        true
                                    end))
                        var"##return#1313" = let args = var"##1323", head = var"##1321"
                                Expr(head, map(rm_nothing, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1314#1324")))
                    end
                end
                begin
                    var"##return#1313" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1314#1324")))
                end
                error("matching non-exhaustive, at #= none:217 =#")
                $(Expr(:symboliclabel, Symbol("####final#1314#1324")))
                var"##return#1313"
            end
        end
    #= none:230 =# Core.@doc "    canonicalize_lambda_head(ex)\n\nCanonicalize the `Expr(:function, Expr(:block, x, Expr(:(=), key, default)), body)` to\n\n```julia\nExpr(:function, Expr(:tuple, Expr(:parameters, Expr(:kw, key, default)), x), body)\n```\n" function canonicalize_lambda_head(ex)
            let
                begin
                    var"##cache#1328" = nothing
                end
                var"##return#1325" = nothing
                var"##1327" = ex
                if var"##1327" isa Expr
                    if begin
                                if var"##cache#1328" === nothing
                                    var"##cache#1328" = Some(((var"##1327").head, (var"##1327").args))
                                end
                                var"##1329" = (var"##cache#1328").value
                                var"##1329" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1329"[1] == :function && (begin
                                        var"##1330" = var"##1329"[2]
                                        var"##1330" isa AbstractArray
                                    end && (length(var"##1330") === 2 && (begin
                                                begin
                                                    var"##cache#1332" = nothing
                                                end
                                                var"##1331" = var"##1330"[1]
                                                var"##1331" isa Expr
                                            end && (begin
                                                    if var"##cache#1332" === nothing
                                                        var"##cache#1332" = Some(((var"##1331").head, (var"##1331").args))
                                                    end
                                                    var"##1333" = (var"##cache#1332").value
                                                    var"##1333" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1333"[1] == :block && (begin
                                                            var"##1334" = var"##1333"[2]
                                                            var"##1334" isa AbstractArray
                                                        end && (length(var"##1334") === 2 && begin
                                                                var"##1335" = var"##1334"[1]
                                                                var"##1336" = var"##1334"[2]
                                                                var"##1337" = var"##1330"[2]
                                                                true
                                                            end))))))))
                        var"##return#1325" = let y = var"##1336", body = var"##1337", x = var"##1335"
                                Expr(:function, Expr(:tuple, Expr(:parameters, y), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1326#1381")))
                    end
                    if begin
                                var"##1338" = (var"##cache#1328").value
                                var"##1338" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1338"[1] == :function && (begin
                                        var"##1339" = var"##1338"[2]
                                        var"##1339" isa AbstractArray
                                    end && (length(var"##1339") === 2 && (begin
                                                begin
                                                    var"##cache#1341" = nothing
                                                end
                                                var"##1340" = var"##1339"[1]
                                                var"##1340" isa Expr
                                            end && (begin
                                                    if var"##cache#1341" === nothing
                                                        var"##cache#1341" = Some(((var"##1340").head, (var"##1340").args))
                                                    end
                                                    var"##1342" = (var"##cache#1341").value
                                                    var"##1342" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1342"[1] == :block && (begin
                                                            var"##1343" = var"##1342"[2]
                                                            var"##1343" isa AbstractArray
                                                        end && (length(var"##1343") === 3 && (begin
                                                                    var"##1344" = var"##1343"[1]
                                                                    var"##1345" = var"##1343"[2]
                                                                    var"##1345" isa LineNumberNode
                                                                end && begin
                                                                    var"##1346" = var"##1343"[3]
                                                                    var"##1347" = var"##1339"[2]
                                                                    true
                                                                end)))))))))
                        var"##return#1325" = let y = var"##1346", body = var"##1347", x = var"##1344"
                                Expr(:function, Expr(:tuple, Expr(:parameters, y), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1326#1381")))
                    end
                    if begin
                                var"##1348" = (var"##cache#1328").value
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
                                                        end && (length(var"##1353") === 2 && (begin
                                                                    var"##1354" = var"##1353"[1]
                                                                    begin
                                                                        var"##cache#1356" = nothing
                                                                    end
                                                                    var"##1355" = var"##1353"[2]
                                                                    var"##1355" isa Expr
                                                                end && (begin
                                                                        if var"##cache#1356" === nothing
                                                                            var"##cache#1356" = Some(((var"##1355").head, (var"##1355").args))
                                                                        end
                                                                        var"##1357" = (var"##cache#1356").value
                                                                        var"##1357" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                    end && (var"##1357"[1] == :(=) && (begin
                                                                                var"##1358" = var"##1357"[2]
                                                                                var"##1358" isa AbstractArray
                                                                            end && (length(var"##1358") === 2 && begin
                                                                                    var"##1359" = var"##1358"[1]
                                                                                    var"##1360" = var"##1358"[2]
                                                                                    var"##1361" = var"##1349"[2]
                                                                                    true
                                                                                end)))))))))))))
                        var"##return#1325" = let default = var"##1360", key = var"##1359", body = var"##1361", x = var"##1354"
                                Expr(:function, Expr(:tuple, Expr(:parameters, Expr(:kw, key, default)), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1326#1381")))
                    end
                    if begin
                                var"##1362" = (var"##cache#1328").value
                                var"##1362" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1362"[1] == :function && (begin
                                        var"##1363" = var"##1362"[2]
                                        var"##1363" isa AbstractArray
                                    end && (length(var"##1363") === 2 && (begin
                                                begin
                                                    var"##cache#1365" = nothing
                                                end
                                                var"##1364" = var"##1363"[1]
                                                var"##1364" isa Expr
                                            end && (begin
                                                    if var"##cache#1365" === nothing
                                                        var"##cache#1365" = Some(((var"##1364").head, (var"##1364").args))
                                                    end
                                                    var"##1366" = (var"##cache#1365").value
                                                    var"##1366" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1366"[1] == :block && (begin
                                                            var"##1367" = var"##1366"[2]
                                                            var"##1367" isa AbstractArray
                                                        end && (length(var"##1367") === 3 && (begin
                                                                    var"##1368" = var"##1367"[1]
                                                                    var"##1369" = var"##1367"[2]
                                                                    var"##1369" isa LineNumberNode
                                                                end && (begin
                                                                        begin
                                                                            var"##cache#1371" = nothing
                                                                        end
                                                                        var"##1370" = var"##1367"[3]
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
                                                                                        var"##1376" = var"##1363"[2]
                                                                                        true
                                                                                    end))))))))))))))
                        var"##return#1325" = let default = var"##1375", key = var"##1374", body = var"##1376", x = var"##1368"
                                Expr(:function, Expr(:tuple, Expr(:parameters, Expr(:kw, key, default)), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1326#1381")))
                    end
                    if begin
                                var"##1377" = (var"##cache#1328").value
                                var"##1377" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1378" = var"##1377"[1]
                                    var"##1379" = var"##1377"[2]
                                    var"##1379" isa AbstractArray
                                end && ((ndims(var"##1379") === 1 && length(var"##1379") >= 0) && begin
                                        var"##1380" = SubArray(var"##1379", (1:length(var"##1379"),))
                                        true
                                    end))
                        var"##return#1325" = let args = var"##1380", head = var"##1378"
                                Expr(head, map(canonicalize_lambda_head, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1326#1381")))
                    end
                end
                begin
                    var"##return#1325" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1326#1381")))
                end
                error("matching non-exhaustive, at #= none:240 =#")
                $(Expr(:symboliclabel, Symbol("####final#1326#1381")))
                var"##return#1325"
            end
        end
    function rm_single_block(ex)
        let
            begin
                var"##cache#1385" = nothing
            end
            var"##return#1382" = nothing
            var"##1384" = ex
            if var"##1384" isa Expr
                if begin
                            if var"##cache#1385" === nothing
                                var"##cache#1385" = Some(((var"##1384").head, (var"##1384").args))
                            end
                            var"##1386" = (var"##cache#1385").value
                            var"##1386" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1386"[1] == :(=) && (begin
                                    var"##1387" = var"##1386"[2]
                                    var"##1387" isa AbstractArray
                                end && (ndims(var"##1387") === 1 && length(var"##1387") >= 0)))
                    var"##return#1382" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1383#1450")))
                end
                if begin
                            var"##1388" = (var"##cache#1385").value
                            var"##1388" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1388"[1] == :-> && (begin
                                    var"##1389" = var"##1388"[2]
                                    var"##1389" isa AbstractArray
                                end && (ndims(var"##1389") === 1 && length(var"##1389") >= 0)))
                    var"##return#1382" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1383#1450")))
                end
                if begin
                            var"##1390" = (var"##cache#1385").value
                            var"##1390" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1390"[1] == :quote && (begin
                                    var"##1391" = var"##1390"[2]
                                    var"##1391" isa AbstractArray
                                end && ((ndims(var"##1391") === 1 && length(var"##1391") >= 0) && begin
                                        var"##1392" = SubArray(var"##1391", (1:length(var"##1391"),))
                                        true
                                    end)))
                    var"##return#1382" = let xs = var"##1392"
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1383#1450")))
                end
                if begin
                            var"##1393" = (var"##cache#1385").value
                            var"##1393" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1393"[1] == :block && (begin
                                    var"##1394" = var"##1393"[2]
                                    var"##1394" isa AbstractArray
                                end && (length(var"##1394") === 1 && (begin
                                            begin
                                                var"##cache#1396" = nothing
                                            end
                                            var"##1395" = var"##1394"[1]
                                            var"##1395" isa Expr
                                        end && (begin
                                                if var"##cache#1396" === nothing
                                                    var"##cache#1396" = Some(((var"##1395").head, (var"##1395").args))
                                                end
                                                var"##1397" = (var"##cache#1396").value
                                                var"##1397" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1397"[1] == :quote && (begin
                                                        var"##1398" = var"##1397"[2]
                                                        var"##1398" isa AbstractArray
                                                    end && ((ndims(var"##1398") === 1 && length(var"##1398") >= 0) && begin
                                                            var"##1399" = SubArray(var"##1398", (1:length(var"##1398"),))
                                                            true
                                                        end))))))))
                    var"##return#1382" = let xs = var"##1399"
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1383#1450")))
                end
                if begin
                            var"##1400" = (var"##cache#1385").value
                            var"##1400" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1400"[1] == :try && (begin
                                    var"##1401" = var"##1400"[2]
                                    var"##1401" isa AbstractArray
                                end && (length(var"##1401") === 4 && (begin
                                            begin
                                                var"##cache#1403" = nothing
                                            end
                                            var"##1402" = var"##1401"[1]
                                            var"##1402" isa Expr
                                        end && (begin
                                                if var"##cache#1403" === nothing
                                                    var"##cache#1403" = Some(((var"##1402").head, (var"##1402").args))
                                                end
                                                var"##1404" = (var"##cache#1403").value
                                                var"##1404" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1404"[1] == :block && (begin
                                                        var"##1405" = var"##1404"[2]
                                                        var"##1405" isa AbstractArray
                                                    end && ((ndims(var"##1405") === 1 && length(var"##1405") >= 0) && (begin
                                                                var"##1406" = SubArray(var"##1405", (1:length(var"##1405"),))
                                                                var"##1401"[2] === false
                                                            end && (var"##1401"[3] === false && (begin
                                                                        begin
                                                                            var"##cache#1408" = nothing
                                                                        end
                                                                        var"##1407" = var"##1401"[4]
                                                                        var"##1407" isa Expr
                                                                    end && (begin
                                                                            if var"##cache#1408" === nothing
                                                                                var"##cache#1408" = Some(((var"##1407").head, (var"##1407").args))
                                                                            end
                                                                            var"##1409" = (var"##cache#1408").value
                                                                            var"##1409" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                        end && (var"##1409"[1] == :block && (begin
                                                                                    var"##1410" = var"##1409"[2]
                                                                                    var"##1410" isa AbstractArray
                                                                                end && ((ndims(var"##1410") === 1 && length(var"##1410") >= 0) && begin
                                                                                        var"##1411" = SubArray(var"##1410", (1:length(var"##1410"),))
                                                                                        true
                                                                                    end)))))))))))))))
                    var"##return#1382" = let try_stmts = var"##1406", finally_stmts = var"##1411"
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), false, false, Expr(:block, rm_single_block.(finally_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1383#1450")))
                end
                if begin
                            var"##1412" = (var"##cache#1385").value
                            var"##1412" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1412"[1] == :try && (begin
                                    var"##1413" = var"##1412"[2]
                                    var"##1413" isa AbstractArray
                                end && (length(var"##1413") === 3 && (begin
                                            begin
                                                var"##cache#1415" = nothing
                                            end
                                            var"##1414" = var"##1413"[1]
                                            var"##1414" isa Expr
                                        end && (begin
                                                if var"##cache#1415" === nothing
                                                    var"##cache#1415" = Some(((var"##1414").head, (var"##1414").args))
                                                end
                                                var"##1416" = (var"##cache#1415").value
                                                var"##1416" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1416"[1] == :block && (begin
                                                        var"##1417" = var"##1416"[2]
                                                        var"##1417" isa AbstractArray
                                                    end && ((ndims(var"##1417") === 1 && length(var"##1417") >= 0) && (begin
                                                                var"##1418" = SubArray(var"##1417", (1:length(var"##1417"),))
                                                                var"##1419" = var"##1413"[2]
                                                                begin
                                                                    var"##cache#1421" = nothing
                                                                end
                                                                var"##1420" = var"##1413"[3]
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
                                                                        end && ((ndims(var"##1423") === 1 && length(var"##1423") >= 0) && begin
                                                                                var"##1424" = SubArray(var"##1423", (1:length(var"##1423"),))
                                                                                true
                                                                            end)))))))))))))
                    var"##return#1382" = let try_stmts = var"##1418", catch_stmts = var"##1424", catch_var = var"##1419"
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), catch_var, Expr(:block, rm_single_block.(catch_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1383#1450")))
                end
                if begin
                            var"##1425" = (var"##cache#1385").value
                            var"##1425" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1425"[1] == :try && (begin
                                    var"##1426" = var"##1425"[2]
                                    var"##1426" isa AbstractArray
                                end && (length(var"##1426") === 4 && (begin
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
                                            end && (var"##1429"[1] == :block && (begin
                                                        var"##1430" = var"##1429"[2]
                                                        var"##1430" isa AbstractArray
                                                    end && ((ndims(var"##1430") === 1 && length(var"##1430") >= 0) && (begin
                                                                var"##1431" = SubArray(var"##1430", (1:length(var"##1430"),))
                                                                var"##1432" = var"##1426"[2]
                                                                begin
                                                                    var"##cache#1434" = nothing
                                                                end
                                                                var"##1433" = var"##1426"[3]
                                                                var"##1433" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1434" === nothing
                                                                        var"##cache#1434" = Some(((var"##1433").head, (var"##1433").args))
                                                                    end
                                                                    var"##1435" = (var"##cache#1434").value
                                                                    var"##1435" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1435"[1] == :block && (begin
                                                                            var"##1436" = var"##1435"[2]
                                                                            var"##1436" isa AbstractArray
                                                                        end && ((ndims(var"##1436") === 1 && length(var"##1436") >= 0) && (begin
                                                                                    var"##1437" = SubArray(var"##1436", (1:length(var"##1436"),))
                                                                                    begin
                                                                                        var"##cache#1439" = nothing
                                                                                    end
                                                                                    var"##1438" = var"##1426"[4]
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
                                                                                                end))))))))))))))))))
                    var"##return#1382" = let try_stmts = var"##1431", catch_stmts = var"##1437", catch_var = var"##1432", finally_stmts = var"##1442"
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), catch_var, Expr(:block, rm_single_block.(catch_stmts)...), Expr(:block, rm_single_block.(finally_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1383#1450")))
                end
                if begin
                            var"##1443" = (var"##cache#1385").value
                            var"##1443" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1443"[1] == :block && (begin
                                    var"##1444" = var"##1443"[2]
                                    var"##1444" isa AbstractArray
                                end && (length(var"##1444") === 1 && begin
                                        var"##1445" = var"##1444"[1]
                                        true
                                    end)))
                    var"##return#1382" = let stmt = var"##1445"
                            stmt
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1383#1450")))
                end
                if begin
                            var"##1446" = (var"##cache#1385").value
                            var"##1446" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                        end && (begin
                                var"##1447" = var"##1446"[1]
                                var"##1448" = var"##1446"[2]
                                var"##1448" isa AbstractArray
                            end && ((ndims(var"##1448") === 1 && length(var"##1448") >= 0) && begin
                                    var"##1449" = SubArray(var"##1448", (1:length(var"##1448"),))
                                    true
                                end))
                    var"##return#1382" = let args = var"##1449", head = var"##1447"
                            Expr(head, map(rm_single_block, args)...)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1383#1450")))
                end
            end
            begin
                var"##return#1382" = let
                        ex
                    end
                $(Expr(:symbolicgoto, Symbol("####final#1383#1450")))
            end
            error("matching non-exhaustive, at #= none:256 =#")
            $(Expr(:symboliclabel, Symbol("####final#1383#1450")))
            var"##return#1382"
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
