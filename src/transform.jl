
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
                    var"##cache#1292" = nothing
                end
                var"##return#1289" = nothing
                var"##1291" = ex
                if var"##1291" isa Expr
                    if begin
                                if var"##cache#1292" === nothing
                                    var"##cache#1292" = Some(((var"##1291").head, (var"##1291").args))
                                end
                                var"##1293" = (var"##cache#1292").value
                                var"##1293" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1293"[1] == :macrocall && (begin
                                        var"##1294" = var"##1293"[2]
                                        var"##1294" isa AbstractArray
                                    end && ((ndims(var"##1294") === 1 && length(var"##1294") >= 2) && begin
                                            var"##1295" = var"##1294"[1]
                                            var"##1296" = var"##1294"[2]
                                            var"##1297" = SubArray(var"##1294", (3:length(var"##1294"),))
                                            true
                                        end)))
                        var"##return#1289" = let line = var"##1296", name = var"##1295", args = var"##1297"
                                Expr(:macrocall, name, line, map(rm_lineinfo, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1290#1302")))
                    end
                    if begin
                                var"##1298" = (var"##cache#1292").value
                                var"##1298" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1299" = var"##1298"[1]
                                    var"##1300" = var"##1298"[2]
                                    var"##1300" isa AbstractArray
                                end && ((ndims(var"##1300") === 1 && length(var"##1300") >= 0) && begin
                                        var"##1301" = SubArray(var"##1300", (1:length(var"##1300"),))
                                        true
                                    end))
                        var"##return#1289" = let args = var"##1301", head = var"##1299"
                                Expr(head, map(rm_lineinfo, filter((x->begin
                                                    !(x isa LineNumberNode)
                                                end), args))...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1290#1302")))
                    end
                end
                begin
                    var"##return#1289" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1290#1302")))
                end
                error("matching non-exhaustive, at #= none:106 =#")
                $(Expr(:symboliclabel, Symbol("####final#1290#1302")))
                var"##return#1289"
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
                            end && (var"##1307"[1] == :block && (begin
                                        var"##1308" = var"##1307"[2]
                                        var"##1308" isa AbstractArray
                                    end && ((ndims(var"##1308") === 1 && length(var"##1308") >= 0) && begin
                                            var"##1309" = SubArray(var"##1308", (1:length(var"##1308"),))
                                            true
                                        end)))
                        var"##return#1303" = let args = var"##1309"
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
                        $(Expr(:symbolicgoto, Symbol("####final#1304#1314")))
                    end
                    if begin
                                var"##1310" = (var"##cache#1306").value
                                var"##1310" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1311" = var"##1310"[1]
                                    var"##1312" = var"##1310"[2]
                                    var"##1312" isa AbstractArray
                                end && ((ndims(var"##1312") === 1 && length(var"##1312") >= 0) && begin
                                        var"##1313" = SubArray(var"##1312", (1:length(var"##1312"),))
                                        true
                                    end))
                        var"##return#1303" = let args = var"##1313", head = var"##1311"
                                Expr(head, map(rm_nothing, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1304#1314")))
                    end
                end
                begin
                    var"##return#1303" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1304#1314")))
                end
                error("matching non-exhaustive, at #= none:217 =#")
                $(Expr(:symboliclabel, Symbol("####final#1304#1314")))
                var"##return#1303"
            end
        end
    #= none:230 =# Core.@doc "    canonicalize_lambda_head(ex)\n\nCanonicalize the `Expr(:function, Expr(:block, x, Expr(:(=), key, default)), body)` to\n\n```julia\nExpr(:function, Expr(:tuple, Expr(:parameters, Expr(:kw, key, default)), x), body)\n```\n" function canonicalize_lambda_head(ex)
            let
                begin
                    var"##cache#1318" = nothing
                end
                var"##return#1315" = nothing
                var"##1317" = ex
                if var"##1317" isa Expr
                    if begin
                                if var"##cache#1318" === nothing
                                    var"##cache#1318" = Some(((var"##1317").head, (var"##1317").args))
                                end
                                var"##1319" = (var"##cache#1318").value
                                var"##1319" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1319"[1] == :function && (begin
                                        var"##1320" = var"##1319"[2]
                                        var"##1320" isa AbstractArray
                                    end && (length(var"##1320") === 2 && (begin
                                                begin
                                                    var"##cache#1322" = nothing
                                                end
                                                var"##1321" = var"##1320"[1]
                                                var"##1321" isa Expr
                                            end && (begin
                                                    if var"##cache#1322" === nothing
                                                        var"##cache#1322" = Some(((var"##1321").head, (var"##1321").args))
                                                    end
                                                    var"##1323" = (var"##cache#1322").value
                                                    var"##1323" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1323"[1] == :block && (begin
                                                            var"##1324" = var"##1323"[2]
                                                            var"##1324" isa AbstractArray
                                                        end && (length(var"##1324") === 2 && begin
                                                                var"##1325" = var"##1324"[1]
                                                                var"##1326" = var"##1324"[2]
                                                                var"##1327" = var"##1320"[2]
                                                                true
                                                            end))))))))
                        var"##return#1315" = let y = var"##1326", body = var"##1327", x = var"##1325"
                                Expr(:function, Expr(:tuple, Expr(:parameters, y), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1316#1371")))
                    end
                    if begin
                                var"##1328" = (var"##cache#1318").value
                                var"##1328" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1328"[1] == :function && (begin
                                        var"##1329" = var"##1328"[2]
                                        var"##1329" isa AbstractArray
                                    end && (length(var"##1329") === 2 && (begin
                                                begin
                                                    var"##cache#1331" = nothing
                                                end
                                                var"##1330" = var"##1329"[1]
                                                var"##1330" isa Expr
                                            end && (begin
                                                    if var"##cache#1331" === nothing
                                                        var"##cache#1331" = Some(((var"##1330").head, (var"##1330").args))
                                                    end
                                                    var"##1332" = (var"##cache#1331").value
                                                    var"##1332" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1332"[1] == :block && (begin
                                                            var"##1333" = var"##1332"[2]
                                                            var"##1333" isa AbstractArray
                                                        end && (length(var"##1333") === 3 && (begin
                                                                    var"##1334" = var"##1333"[1]
                                                                    var"##1335" = var"##1333"[2]
                                                                    var"##1335" isa LineNumberNode
                                                                end && begin
                                                                    var"##1336" = var"##1333"[3]
                                                                    var"##1337" = var"##1329"[2]
                                                                    true
                                                                end)))))))))
                        var"##return#1315" = let y = var"##1336", body = var"##1337", x = var"##1334"
                                Expr(:function, Expr(:tuple, Expr(:parameters, y), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1316#1371")))
                    end
                    if begin
                                var"##1338" = (var"##cache#1318").value
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
                                                        end && (length(var"##1343") === 2 && (begin
                                                                    var"##1344" = var"##1343"[1]
                                                                    begin
                                                                        var"##cache#1346" = nothing
                                                                    end
                                                                    var"##1345" = var"##1343"[2]
                                                                    var"##1345" isa Expr
                                                                end && (begin
                                                                        if var"##cache#1346" === nothing
                                                                            var"##cache#1346" = Some(((var"##1345").head, (var"##1345").args))
                                                                        end
                                                                        var"##1347" = (var"##cache#1346").value
                                                                        var"##1347" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                    end && (var"##1347"[1] == :(=) && (begin
                                                                                var"##1348" = var"##1347"[2]
                                                                                var"##1348" isa AbstractArray
                                                                            end && (length(var"##1348") === 2 && begin
                                                                                    var"##1349" = var"##1348"[1]
                                                                                    var"##1350" = var"##1348"[2]
                                                                                    var"##1351" = var"##1339"[2]
                                                                                    true
                                                                                end)))))))))))))
                        var"##return#1315" = let default = var"##1350", key = var"##1349", body = var"##1351", x = var"##1344"
                                Expr(:function, Expr(:tuple, Expr(:parameters, Expr(:kw, key, default)), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1316#1371")))
                    end
                    if begin
                                var"##1352" = (var"##cache#1318").value
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
                                                        end && (length(var"##1357") === 3 && (begin
                                                                    var"##1358" = var"##1357"[1]
                                                                    var"##1359" = var"##1357"[2]
                                                                    var"##1359" isa LineNumberNode
                                                                end && (begin
                                                                        begin
                                                                            var"##cache#1361" = nothing
                                                                        end
                                                                        var"##1360" = var"##1357"[3]
                                                                        var"##1360" isa Expr
                                                                    end && (begin
                                                                            if var"##cache#1361" === nothing
                                                                                var"##cache#1361" = Some(((var"##1360").head, (var"##1360").args))
                                                                            end
                                                                            var"##1362" = (var"##cache#1361").value
                                                                            var"##1362" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                        end && (var"##1362"[1] == :(=) && (begin
                                                                                    var"##1363" = var"##1362"[2]
                                                                                    var"##1363" isa AbstractArray
                                                                                end && (length(var"##1363") === 2 && begin
                                                                                        var"##1364" = var"##1363"[1]
                                                                                        var"##1365" = var"##1363"[2]
                                                                                        var"##1366" = var"##1353"[2]
                                                                                        true
                                                                                    end))))))))))))))
                        var"##return#1315" = let default = var"##1365", key = var"##1364", body = var"##1366", x = var"##1358"
                                Expr(:function, Expr(:tuple, Expr(:parameters, Expr(:kw, key, default)), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1316#1371")))
                    end
                    if begin
                                var"##1367" = (var"##cache#1318").value
                                var"##1367" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1368" = var"##1367"[1]
                                    var"##1369" = var"##1367"[2]
                                    var"##1369" isa AbstractArray
                                end && ((ndims(var"##1369") === 1 && length(var"##1369") >= 0) && begin
                                        var"##1370" = SubArray(var"##1369", (1:length(var"##1369"),))
                                        true
                                    end))
                        var"##return#1315" = let args = var"##1370", head = var"##1368"
                                Expr(head, map(canonicalize_lambda_head, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1316#1371")))
                    end
                end
                begin
                    var"##return#1315" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1316#1371")))
                end
                error("matching non-exhaustive, at #= none:240 =#")
                $(Expr(:symboliclabel, Symbol("####final#1316#1371")))
                var"##return#1315"
            end
        end
    function rm_single_block(ex)
        let
            begin
                var"##cache#1375" = nothing
            end
            var"##return#1372" = nothing
            var"##1374" = ex
            if var"##1374" isa Expr
                if begin
                            if var"##cache#1375" === nothing
                                var"##cache#1375" = Some(((var"##1374").head, (var"##1374").args))
                            end
                            var"##1376" = (var"##cache#1375").value
                            var"##1376" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1376"[1] == :(=) && (begin
                                    var"##1377" = var"##1376"[2]
                                    var"##1377" isa AbstractArray
                                end && (ndims(var"##1377") === 1 && length(var"##1377") >= 0)))
                    var"##return#1372" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1373#1440")))
                end
                if begin
                            var"##1378" = (var"##cache#1375").value
                            var"##1378" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1378"[1] == :-> && (begin
                                    var"##1379" = var"##1378"[2]
                                    var"##1379" isa AbstractArray
                                end && (ndims(var"##1379") === 1 && length(var"##1379") >= 0)))
                    var"##return#1372" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1373#1440")))
                end
                if begin
                            var"##1380" = (var"##cache#1375").value
                            var"##1380" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1380"[1] == :quote && (begin
                                    var"##1381" = var"##1380"[2]
                                    var"##1381" isa AbstractArray
                                end && ((ndims(var"##1381") === 1 && length(var"##1381") >= 0) && begin
                                        var"##1382" = SubArray(var"##1381", (1:length(var"##1381"),))
                                        true
                                    end)))
                    var"##return#1372" = let xs = var"##1382"
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1373#1440")))
                end
                if begin
                            var"##1383" = (var"##cache#1375").value
                            var"##1383" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1383"[1] == :block && (begin
                                    var"##1384" = var"##1383"[2]
                                    var"##1384" isa AbstractArray
                                end && (length(var"##1384") === 1 && (begin
                                            begin
                                                var"##cache#1386" = nothing
                                            end
                                            var"##1385" = var"##1384"[1]
                                            var"##1385" isa Expr
                                        end && (begin
                                                if var"##cache#1386" === nothing
                                                    var"##cache#1386" = Some(((var"##1385").head, (var"##1385").args))
                                                end
                                                var"##1387" = (var"##cache#1386").value
                                                var"##1387" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1387"[1] == :quote && (begin
                                                        var"##1388" = var"##1387"[2]
                                                        var"##1388" isa AbstractArray
                                                    end && ((ndims(var"##1388") === 1 && length(var"##1388") >= 0) && begin
                                                            var"##1389" = SubArray(var"##1388", (1:length(var"##1388"),))
                                                            true
                                                        end))))))))
                    var"##return#1372" = let xs = var"##1389"
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1373#1440")))
                end
                if begin
                            var"##1390" = (var"##cache#1375").value
                            var"##1390" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1390"[1] == :try && (begin
                                    var"##1391" = var"##1390"[2]
                                    var"##1391" isa AbstractArray
                                end && (length(var"##1391") === 4 && (begin
                                            begin
                                                var"##cache#1393" = nothing
                                            end
                                            var"##1392" = var"##1391"[1]
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
                                                    end && ((ndims(var"##1395") === 1 && length(var"##1395") >= 0) && (begin
                                                                var"##1396" = SubArray(var"##1395", (1:length(var"##1395"),))
                                                                var"##1391"[2] === false
                                                            end && (var"##1391"[3] === false && (begin
                                                                        begin
                                                                            var"##cache#1398" = nothing
                                                                        end
                                                                        var"##1397" = var"##1391"[4]
                                                                        var"##1397" isa Expr
                                                                    end && (begin
                                                                            if var"##cache#1398" === nothing
                                                                                var"##cache#1398" = Some(((var"##1397").head, (var"##1397").args))
                                                                            end
                                                                            var"##1399" = (var"##cache#1398").value
                                                                            var"##1399" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                        end && (var"##1399"[1] == :block && (begin
                                                                                    var"##1400" = var"##1399"[2]
                                                                                    var"##1400" isa AbstractArray
                                                                                end && ((ndims(var"##1400") === 1 && length(var"##1400") >= 0) && begin
                                                                                        var"##1401" = SubArray(var"##1400", (1:length(var"##1400"),))
                                                                                        true
                                                                                    end)))))))))))))))
                    var"##return#1372" = let try_stmts = var"##1396", finally_stmts = var"##1401"
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), false, false, Expr(:block, rm_single_block.(finally_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1373#1440")))
                end
                if begin
                            var"##1402" = (var"##cache#1375").value
                            var"##1402" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1402"[1] == :try && (begin
                                    var"##1403" = var"##1402"[2]
                                    var"##1403" isa AbstractArray
                                end && (length(var"##1403") === 3 && (begin
                                            begin
                                                var"##cache#1405" = nothing
                                            end
                                            var"##1404" = var"##1403"[1]
                                            var"##1404" isa Expr
                                        end && (begin
                                                if var"##cache#1405" === nothing
                                                    var"##cache#1405" = Some(((var"##1404").head, (var"##1404").args))
                                                end
                                                var"##1406" = (var"##cache#1405").value
                                                var"##1406" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1406"[1] == :block && (begin
                                                        var"##1407" = var"##1406"[2]
                                                        var"##1407" isa AbstractArray
                                                    end && ((ndims(var"##1407") === 1 && length(var"##1407") >= 0) && (begin
                                                                var"##1408" = SubArray(var"##1407", (1:length(var"##1407"),))
                                                                var"##1409" = var"##1403"[2]
                                                                begin
                                                                    var"##cache#1411" = nothing
                                                                end
                                                                var"##1410" = var"##1403"[3]
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
                                                                            end)))))))))))))
                    var"##return#1372" = let try_stmts = var"##1408", catch_stmts = var"##1414", catch_var = var"##1409"
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), catch_var, Expr(:block, rm_single_block.(catch_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1373#1440")))
                end
                if begin
                            var"##1415" = (var"##cache#1375").value
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
                                                                var"##1422" = var"##1416"[2]
                                                                begin
                                                                    var"##cache#1424" = nothing
                                                                end
                                                                var"##1423" = var"##1416"[3]
                                                                var"##1423" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1424" === nothing
                                                                        var"##cache#1424" = Some(((var"##1423").head, (var"##1423").args))
                                                                    end
                                                                    var"##1425" = (var"##cache#1424").value
                                                                    var"##1425" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1425"[1] == :block && (begin
                                                                            var"##1426" = var"##1425"[2]
                                                                            var"##1426" isa AbstractArray
                                                                        end && ((ndims(var"##1426") === 1 && length(var"##1426") >= 0) && (begin
                                                                                    var"##1427" = SubArray(var"##1426", (1:length(var"##1426"),))
                                                                                    begin
                                                                                        var"##cache#1429" = nothing
                                                                                    end
                                                                                    var"##1428" = var"##1416"[4]
                                                                                    var"##1428" isa Expr
                                                                                end && (begin
                                                                                        if var"##cache#1429" === nothing
                                                                                            var"##cache#1429" = Some(((var"##1428").head, (var"##1428").args))
                                                                                        end
                                                                                        var"##1430" = (var"##cache#1429").value
                                                                                        var"##1430" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                                    end && (var"##1430"[1] == :block && (begin
                                                                                                var"##1431" = var"##1430"[2]
                                                                                                var"##1431" isa AbstractArray
                                                                                            end && ((ndims(var"##1431") === 1 && length(var"##1431") >= 0) && begin
                                                                                                    var"##1432" = SubArray(var"##1431", (1:length(var"##1431"),))
                                                                                                    true
                                                                                                end))))))))))))))))))
                    var"##return#1372" = let try_stmts = var"##1421", catch_stmts = var"##1427", catch_var = var"##1422", finally_stmts = var"##1432"
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), catch_var, Expr(:block, rm_single_block.(catch_stmts)...), Expr(:block, rm_single_block.(finally_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1373#1440")))
                end
                if begin
                            var"##1433" = (var"##cache#1375").value
                            var"##1433" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1433"[1] == :block && (begin
                                    var"##1434" = var"##1433"[2]
                                    var"##1434" isa AbstractArray
                                end && (length(var"##1434") === 1 && begin
                                        var"##1435" = var"##1434"[1]
                                        true
                                    end)))
                    var"##return#1372" = let stmt = var"##1435"
                            stmt
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1373#1440")))
                end
                if begin
                            var"##1436" = (var"##cache#1375").value
                            var"##1436" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                        end && (begin
                                var"##1437" = var"##1436"[1]
                                var"##1438" = var"##1436"[2]
                                var"##1438" isa AbstractArray
                            end && ((ndims(var"##1438") === 1 && length(var"##1438") >= 0) && begin
                                    var"##1439" = SubArray(var"##1438", (1:length(var"##1438"),))
                                    true
                                end))
                    var"##return#1372" = let args = var"##1439", head = var"##1437"
                            Expr(head, map(rm_single_block, args)...)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1373#1440")))
                end
            end
            begin
                var"##return#1372" = let
                        ex
                    end
                $(Expr(:symbolicgoto, Symbol("####final#1373#1440")))
            end
            error("matching non-exhaustive, at #= none:256 =#")
            $(Expr(:symboliclabel, Symbol("####final#1373#1440")))
            var"##return#1372"
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
