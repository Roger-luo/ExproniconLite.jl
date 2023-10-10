
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
                    var"##cache#1274" = nothing
                end
                var"##return#1271" = nothing
                var"##1273" = ex
                if var"##1273" isa Expr
                    if begin
                                if var"##cache#1274" === nothing
                                    var"##cache#1274" = Some(((var"##1273").head, (var"##1273").args))
                                end
                                var"##1275" = (var"##cache#1274").value
                                var"##1275" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1275"[1] == :macrocall && (begin
                                        var"##1276" = var"##1275"[2]
                                        var"##1276" isa AbstractArray
                                    end && ((ndims(var"##1276") === 1 && length(var"##1276") >= 2) && begin
                                            var"##1277" = var"##1276"[1]
                                            var"##1278" = var"##1276"[2]
                                            var"##1279" = SubArray(var"##1276", (3:length(var"##1276"),))
                                            true
                                        end)))
                        var"##return#1271" = let line = var"##1278", name = var"##1277", args = var"##1279"
                                Expr(:macrocall, name, line, map(rm_lineinfo, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1272#1284")))
                    end
                    if begin
                                var"##1280" = (var"##cache#1274").value
                                var"##1280" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1281" = var"##1280"[1]
                                    var"##1282" = var"##1280"[2]
                                    var"##1282" isa AbstractArray
                                end && ((ndims(var"##1282") === 1 && length(var"##1282") >= 0) && begin
                                        var"##1283" = SubArray(var"##1282", (1:length(var"##1282"),))
                                        true
                                    end))
                        var"##return#1271" = let args = var"##1283", head = var"##1281"
                                Expr(head, map(rm_lineinfo, filter((x->begin
                                                    !(x isa LineNumberNode)
                                                end), args))...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1272#1284")))
                    end
                end
                begin
                    var"##return#1271" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1272#1284")))
                end
                error("matching non-exhaustive, at #= none:106 =#")
                $(Expr(:symboliclabel, Symbol("####final#1272#1284")))
                var"##return#1271"
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
                    var"##cache#1288" = nothing
                end
                var"##return#1285" = nothing
                var"##1287" = ex
                if var"##1287" isa Expr
                    if begin
                                if var"##cache#1288" === nothing
                                    var"##cache#1288" = Some(((var"##1287").head, (var"##1287").args))
                                end
                                var"##1289" = (var"##cache#1288").value
                                var"##1289" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1289"[1] == :block && (begin
                                        var"##1290" = var"##1289"[2]
                                        var"##1290" isa AbstractArray
                                    end && ((ndims(var"##1290") === 1 && length(var"##1290") >= 0) && begin
                                            var"##1291" = SubArray(var"##1290", (1:length(var"##1290"),))
                                            true
                                        end)))
                        var"##return#1285" = let args = var"##1291"
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
                        $(Expr(:symbolicgoto, Symbol("####final#1286#1296")))
                    end
                    if begin
                                var"##1292" = (var"##cache#1288").value
                                var"##1292" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1293" = var"##1292"[1]
                                    var"##1294" = var"##1292"[2]
                                    var"##1294" isa AbstractArray
                                end && ((ndims(var"##1294") === 1 && length(var"##1294") >= 0) && begin
                                        var"##1295" = SubArray(var"##1294", (1:length(var"##1294"),))
                                        true
                                    end))
                        var"##return#1285" = let args = var"##1295", head = var"##1293"
                                Expr(head, map(rm_nothing, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1286#1296")))
                    end
                end
                begin
                    var"##return#1285" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1286#1296")))
                end
                error("matching non-exhaustive, at #= none:217 =#")
                $(Expr(:symboliclabel, Symbol("####final#1286#1296")))
                var"##return#1285"
            end
        end
    #= none:230 =# Core.@doc "    canonicalize_lambda_head(ex)\n\nCanonicalize the `Expr(:function, Expr(:block, x, Expr(:(=), key, default)), body)` to\n\n```julia\nExpr(:function, Expr(:tuple, Expr(:parameters, Expr(:kw, key, default)), x), body)\n```\n" function canonicalize_lambda_head(ex)
            let
                begin
                    var"##cache#1300" = nothing
                end
                var"##return#1297" = nothing
                var"##1299" = ex
                if var"##1299" isa Expr
                    if begin
                                if var"##cache#1300" === nothing
                                    var"##cache#1300" = Some(((var"##1299").head, (var"##1299").args))
                                end
                                var"##1301" = (var"##cache#1300").value
                                var"##1301" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1301"[1] == :function && (begin
                                        var"##1302" = var"##1301"[2]
                                        var"##1302" isa AbstractArray
                                    end && (length(var"##1302") === 2 && (begin
                                                begin
                                                    var"##cache#1304" = nothing
                                                end
                                                var"##1303" = var"##1302"[1]
                                                var"##1303" isa Expr
                                            end && (begin
                                                    if var"##cache#1304" === nothing
                                                        var"##cache#1304" = Some(((var"##1303").head, (var"##1303").args))
                                                    end
                                                    var"##1305" = (var"##cache#1304").value
                                                    var"##1305" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1305"[1] == :block && (begin
                                                            var"##1306" = var"##1305"[2]
                                                            var"##1306" isa AbstractArray
                                                        end && (length(var"##1306") === 2 && begin
                                                                var"##1307" = var"##1306"[1]
                                                                var"##1308" = var"##1306"[2]
                                                                var"##1309" = var"##1302"[2]
                                                                true
                                                            end))))))))
                        var"##return#1297" = let y = var"##1308", body = var"##1309", x = var"##1307"
                                Expr(:function, Expr(:tuple, Expr(:parameters, y), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1298#1353")))
                    end
                    if begin
                                var"##1310" = (var"##cache#1300").value
                                var"##1310" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1310"[1] == :function && (begin
                                        var"##1311" = var"##1310"[2]
                                        var"##1311" isa AbstractArray
                                    end && (length(var"##1311") === 2 && (begin
                                                begin
                                                    var"##cache#1313" = nothing
                                                end
                                                var"##1312" = var"##1311"[1]
                                                var"##1312" isa Expr
                                            end && (begin
                                                    if var"##cache#1313" === nothing
                                                        var"##cache#1313" = Some(((var"##1312").head, (var"##1312").args))
                                                    end
                                                    var"##1314" = (var"##cache#1313").value
                                                    var"##1314" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1314"[1] == :block && (begin
                                                            var"##1315" = var"##1314"[2]
                                                            var"##1315" isa AbstractArray
                                                        end && (length(var"##1315") === 3 && (begin
                                                                    var"##1316" = var"##1315"[1]
                                                                    var"##1317" = var"##1315"[2]
                                                                    var"##1317" isa LineNumberNode
                                                                end && begin
                                                                    var"##1318" = var"##1315"[3]
                                                                    var"##1319" = var"##1311"[2]
                                                                    true
                                                                end)))))))))
                        var"##return#1297" = let y = var"##1318", body = var"##1319", x = var"##1316"
                                Expr(:function, Expr(:tuple, Expr(:parameters, y), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1298#1353")))
                    end
                    if begin
                                var"##1320" = (var"##cache#1300").value
                                var"##1320" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1320"[1] == :function && (begin
                                        var"##1321" = var"##1320"[2]
                                        var"##1321" isa AbstractArray
                                    end && (length(var"##1321") === 2 && (begin
                                                begin
                                                    var"##cache#1323" = nothing
                                                end
                                                var"##1322" = var"##1321"[1]
                                                var"##1322" isa Expr
                                            end && (begin
                                                    if var"##cache#1323" === nothing
                                                        var"##cache#1323" = Some(((var"##1322").head, (var"##1322").args))
                                                    end
                                                    var"##1324" = (var"##cache#1323").value
                                                    var"##1324" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1324"[1] == :block && (begin
                                                            var"##1325" = var"##1324"[2]
                                                            var"##1325" isa AbstractArray
                                                        end && (length(var"##1325") === 2 && (begin
                                                                    var"##1326" = var"##1325"[1]
                                                                    begin
                                                                        var"##cache#1328" = nothing
                                                                    end
                                                                    var"##1327" = var"##1325"[2]
                                                                    var"##1327" isa Expr
                                                                end && (begin
                                                                        if var"##cache#1328" === nothing
                                                                            var"##cache#1328" = Some(((var"##1327").head, (var"##1327").args))
                                                                        end
                                                                        var"##1329" = (var"##cache#1328").value
                                                                        var"##1329" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                    end && (var"##1329"[1] == :(=) && (begin
                                                                                var"##1330" = var"##1329"[2]
                                                                                var"##1330" isa AbstractArray
                                                                            end && (length(var"##1330") === 2 && begin
                                                                                    var"##1331" = var"##1330"[1]
                                                                                    var"##1332" = var"##1330"[2]
                                                                                    var"##1333" = var"##1321"[2]
                                                                                    true
                                                                                end)))))))))))))
                        var"##return#1297" = let default = var"##1332", key = var"##1331", body = var"##1333", x = var"##1326"
                                Expr(:function, Expr(:tuple, Expr(:parameters, Expr(:kw, key, default)), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1298#1353")))
                    end
                    if begin
                                var"##1334" = (var"##cache#1300").value
                                var"##1334" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1334"[1] == :function && (begin
                                        var"##1335" = var"##1334"[2]
                                        var"##1335" isa AbstractArray
                                    end && (length(var"##1335") === 2 && (begin
                                                begin
                                                    var"##cache#1337" = nothing
                                                end
                                                var"##1336" = var"##1335"[1]
                                                var"##1336" isa Expr
                                            end && (begin
                                                    if var"##cache#1337" === nothing
                                                        var"##cache#1337" = Some(((var"##1336").head, (var"##1336").args))
                                                    end
                                                    var"##1338" = (var"##cache#1337").value
                                                    var"##1338" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1338"[1] == :block && (begin
                                                            var"##1339" = var"##1338"[2]
                                                            var"##1339" isa AbstractArray
                                                        end && (length(var"##1339") === 3 && (begin
                                                                    var"##1340" = var"##1339"[1]
                                                                    var"##1341" = var"##1339"[2]
                                                                    var"##1341" isa LineNumberNode
                                                                end && (begin
                                                                        begin
                                                                            var"##cache#1343" = nothing
                                                                        end
                                                                        var"##1342" = var"##1339"[3]
                                                                        var"##1342" isa Expr
                                                                    end && (begin
                                                                            if var"##cache#1343" === nothing
                                                                                var"##cache#1343" = Some(((var"##1342").head, (var"##1342").args))
                                                                            end
                                                                            var"##1344" = (var"##cache#1343").value
                                                                            var"##1344" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                        end && (var"##1344"[1] == :(=) && (begin
                                                                                    var"##1345" = var"##1344"[2]
                                                                                    var"##1345" isa AbstractArray
                                                                                end && (length(var"##1345") === 2 && begin
                                                                                        var"##1346" = var"##1345"[1]
                                                                                        var"##1347" = var"##1345"[2]
                                                                                        var"##1348" = var"##1335"[2]
                                                                                        true
                                                                                    end))))))))))))))
                        var"##return#1297" = let default = var"##1347", key = var"##1346", body = var"##1348", x = var"##1340"
                                Expr(:function, Expr(:tuple, Expr(:parameters, Expr(:kw, key, default)), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1298#1353")))
                    end
                    if begin
                                var"##1349" = (var"##cache#1300").value
                                var"##1349" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1350" = var"##1349"[1]
                                    var"##1351" = var"##1349"[2]
                                    var"##1351" isa AbstractArray
                                end && ((ndims(var"##1351") === 1 && length(var"##1351") >= 0) && begin
                                        var"##1352" = SubArray(var"##1351", (1:length(var"##1351"),))
                                        true
                                    end))
                        var"##return#1297" = let args = var"##1352", head = var"##1350"
                                Expr(head, map(canonicalize_lambda_head, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1298#1353")))
                    end
                end
                begin
                    var"##return#1297" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1298#1353")))
                end
                error("matching non-exhaustive, at #= none:240 =#")
                $(Expr(:symboliclabel, Symbol("####final#1298#1353")))
                var"##return#1297"
            end
        end
    function rm_single_block(ex)
        let
            begin
                var"##cache#1357" = nothing
            end
            var"##return#1354" = nothing
            var"##1356" = ex
            if var"##1356" isa Expr
                if begin
                            if var"##cache#1357" === nothing
                                var"##cache#1357" = Some(((var"##1356").head, (var"##1356").args))
                            end
                            var"##1358" = (var"##cache#1357").value
                            var"##1358" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1358"[1] == :(=) && (begin
                                    var"##1359" = var"##1358"[2]
                                    var"##1359" isa AbstractArray
                                end && (ndims(var"##1359") === 1 && length(var"##1359") >= 0)))
                    var"##return#1354" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1355#1422")))
                end
                if begin
                            var"##1360" = (var"##cache#1357").value
                            var"##1360" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1360"[1] == :-> && (begin
                                    var"##1361" = var"##1360"[2]
                                    var"##1361" isa AbstractArray
                                end && (ndims(var"##1361") === 1 && length(var"##1361") >= 0)))
                    var"##return#1354" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1355#1422")))
                end
                if begin
                            var"##1362" = (var"##cache#1357").value
                            var"##1362" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1362"[1] == :quote && (begin
                                    var"##1363" = var"##1362"[2]
                                    var"##1363" isa AbstractArray
                                end && ((ndims(var"##1363") === 1 && length(var"##1363") >= 0) && begin
                                        var"##1364" = SubArray(var"##1363", (1:length(var"##1363"),))
                                        true
                                    end)))
                    var"##return#1354" = let xs = var"##1364"
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1355#1422")))
                end
                if begin
                            var"##1365" = (var"##cache#1357").value
                            var"##1365" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1365"[1] == :block && (begin
                                    var"##1366" = var"##1365"[2]
                                    var"##1366" isa AbstractArray
                                end && (length(var"##1366") === 1 && (begin
                                            begin
                                                var"##cache#1368" = nothing
                                            end
                                            var"##1367" = var"##1366"[1]
                                            var"##1367" isa Expr
                                        end && (begin
                                                if var"##cache#1368" === nothing
                                                    var"##cache#1368" = Some(((var"##1367").head, (var"##1367").args))
                                                end
                                                var"##1369" = (var"##cache#1368").value
                                                var"##1369" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1369"[1] == :quote && (begin
                                                        var"##1370" = var"##1369"[2]
                                                        var"##1370" isa AbstractArray
                                                    end && ((ndims(var"##1370") === 1 && length(var"##1370") >= 0) && begin
                                                            var"##1371" = SubArray(var"##1370", (1:length(var"##1370"),))
                                                            true
                                                        end))))))))
                    var"##return#1354" = let xs = var"##1371"
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1355#1422")))
                end
                if begin
                            var"##1372" = (var"##cache#1357").value
                            var"##1372" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1372"[1] == :try && (begin
                                    var"##1373" = var"##1372"[2]
                                    var"##1373" isa AbstractArray
                                end && (length(var"##1373") === 4 && (begin
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
                                                    end && ((ndims(var"##1377") === 1 && length(var"##1377") >= 0) && (begin
                                                                var"##1378" = SubArray(var"##1377", (1:length(var"##1377"),))
                                                                var"##1373"[2] === false
                                                            end && (var"##1373"[3] === false && (begin
                                                                        begin
                                                                            var"##cache#1380" = nothing
                                                                        end
                                                                        var"##1379" = var"##1373"[4]
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
                                                                                end && ((ndims(var"##1382") === 1 && length(var"##1382") >= 0) && begin
                                                                                        var"##1383" = SubArray(var"##1382", (1:length(var"##1382"),))
                                                                                        true
                                                                                    end)))))))))))))))
                    var"##return#1354" = let try_stmts = var"##1378", finally_stmts = var"##1383"
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), false, false, Expr(:block, rm_single_block.(finally_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1355#1422")))
                end
                if begin
                            var"##1384" = (var"##cache#1357").value
                            var"##1384" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1384"[1] == :try && (begin
                                    var"##1385" = var"##1384"[2]
                                    var"##1385" isa AbstractArray
                                end && (length(var"##1385") === 3 && (begin
                                            begin
                                                var"##cache#1387" = nothing
                                            end
                                            var"##1386" = var"##1385"[1]
                                            var"##1386" isa Expr
                                        end && (begin
                                                if var"##cache#1387" === nothing
                                                    var"##cache#1387" = Some(((var"##1386").head, (var"##1386").args))
                                                end
                                                var"##1388" = (var"##cache#1387").value
                                                var"##1388" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1388"[1] == :block && (begin
                                                        var"##1389" = var"##1388"[2]
                                                        var"##1389" isa AbstractArray
                                                    end && ((ndims(var"##1389") === 1 && length(var"##1389") >= 0) && (begin
                                                                var"##1390" = SubArray(var"##1389", (1:length(var"##1389"),))
                                                                var"##1391" = var"##1385"[2]
                                                                begin
                                                                    var"##cache#1393" = nothing
                                                                end
                                                                var"##1392" = var"##1385"[3]
                                                                var"##1392" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1393" === nothing
                                                                        var"##cache#1393" = Some(((var"##1392").head, (var"##1392").args))
                                                                    end
                                                                    var"##1394" = (var"##cache#1393").value
                                                                    var"##1394" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1394"[1] == :block && (begin
                                                                            var"##1395" = var"##1394"[2]
                                                                            var"##1395" isa AbstractArray
                                                                        end && ((ndims(var"##1395") === 1 && length(var"##1395") >= 0) && begin
                                                                                var"##1396" = SubArray(var"##1395", (1:length(var"##1395"),))
                                                                                true
                                                                            end)))))))))))))
                    var"##return#1354" = let try_stmts = var"##1390", catch_stmts = var"##1396", catch_var = var"##1391"
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), catch_var, Expr(:block, rm_single_block.(catch_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1355#1422")))
                end
                if begin
                            var"##1397" = (var"##cache#1357").value
                            var"##1397" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1397"[1] == :try && (begin
                                    var"##1398" = var"##1397"[2]
                                    var"##1398" isa AbstractArray
                                end && (length(var"##1398") === 4 && (begin
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
                                            end && (var"##1401"[1] == :block && (begin
                                                        var"##1402" = var"##1401"[2]
                                                        var"##1402" isa AbstractArray
                                                    end && ((ndims(var"##1402") === 1 && length(var"##1402") >= 0) && (begin
                                                                var"##1403" = SubArray(var"##1402", (1:length(var"##1402"),))
                                                                var"##1404" = var"##1398"[2]
                                                                begin
                                                                    var"##cache#1406" = nothing
                                                                end
                                                                var"##1405" = var"##1398"[3]
                                                                var"##1405" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1406" === nothing
                                                                        var"##cache#1406" = Some(((var"##1405").head, (var"##1405").args))
                                                                    end
                                                                    var"##1407" = (var"##cache#1406").value
                                                                    var"##1407" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1407"[1] == :block && (begin
                                                                            var"##1408" = var"##1407"[2]
                                                                            var"##1408" isa AbstractArray
                                                                        end && ((ndims(var"##1408") === 1 && length(var"##1408") >= 0) && (begin
                                                                                    var"##1409" = SubArray(var"##1408", (1:length(var"##1408"),))
                                                                                    begin
                                                                                        var"##cache#1411" = nothing
                                                                                    end
                                                                                    var"##1410" = var"##1398"[4]
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
                                                                                            end && ((ndims(var"##1413") === 1 && length(var"##1413") >= 0) && begin
                                                                                                    var"##1414" = SubArray(var"##1413", (1:length(var"##1413"),))
                                                                                                    true
                                                                                                end))))))))))))))))))
                    var"##return#1354" = let try_stmts = var"##1403", catch_stmts = var"##1409", catch_var = var"##1404", finally_stmts = var"##1414"
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), catch_var, Expr(:block, rm_single_block.(catch_stmts)...), Expr(:block, rm_single_block.(finally_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1355#1422")))
                end
                if begin
                            var"##1415" = (var"##cache#1357").value
                            var"##1415" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1415"[1] == :block && (begin
                                    var"##1416" = var"##1415"[2]
                                    var"##1416" isa AbstractArray
                                end && (length(var"##1416") === 1 && begin
                                        var"##1417" = var"##1416"[1]
                                        true
                                    end)))
                    var"##return#1354" = let stmt = var"##1417"
                            stmt
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1355#1422")))
                end
                if begin
                            var"##1418" = (var"##cache#1357").value
                            var"##1418" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                        end && (begin
                                var"##1419" = var"##1418"[1]
                                var"##1420" = var"##1418"[2]
                                var"##1420" isa AbstractArray
                            end && ((ndims(var"##1420") === 1 && length(var"##1420") >= 0) && begin
                                    var"##1421" = SubArray(var"##1420", (1:length(var"##1420"),))
                                    true
                                end))
                    var"##return#1354" = let args = var"##1421", head = var"##1419"
                            Expr(head, map(rm_single_block, args)...)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1355#1422")))
                end
            end
            begin
                var"##return#1354" = let
                        ex
                    end
                $(Expr(:symbolicgoto, Symbol("####final#1355#1422")))
            end
            error("matching non-exhaustive, at #= none:256 =#")
            $(Expr(:symboliclabel, Symbol("####final#1355#1422")))
            var"##return#1354"
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
