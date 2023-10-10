
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
                    var"##cache#1277" = nothing
                end
                var"##return#1274" = nothing
                var"##1276" = ex
                if var"##1276" isa Expr
                    if begin
                                if var"##cache#1277" === nothing
                                    var"##cache#1277" = Some(((var"##1276").head, (var"##1276").args))
                                end
                                var"##1278" = (var"##cache#1277").value
                                var"##1278" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1278"[1] == :macrocall && (begin
                                        var"##1279" = var"##1278"[2]
                                        var"##1279" isa AbstractArray
                                    end && ((ndims(var"##1279") === 1 && length(var"##1279") >= 2) && begin
                                            var"##1280" = var"##1279"[1]
                                            var"##1281" = var"##1279"[2]
                                            var"##1282" = SubArray(var"##1279", (3:length(var"##1279"),))
                                            true
                                        end)))
                        var"##return#1274" = let line = var"##1281", name = var"##1280", args = var"##1282"
                                Expr(:macrocall, name, line, map(rm_lineinfo, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1275#1287")))
                    end
                    if begin
                                var"##1283" = (var"##cache#1277").value
                                var"##1283" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1284" = var"##1283"[1]
                                    var"##1285" = var"##1283"[2]
                                    var"##1285" isa AbstractArray
                                end && ((ndims(var"##1285") === 1 && length(var"##1285") >= 0) && begin
                                        var"##1286" = SubArray(var"##1285", (1:length(var"##1285"),))
                                        true
                                    end))
                        var"##return#1274" = let args = var"##1286", head = var"##1284"
                                Expr(head, map(rm_lineinfo, filter((x->begin
                                                    !(x isa LineNumberNode)
                                                end), args))...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1275#1287")))
                    end
                end
                begin
                    var"##return#1274" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1275#1287")))
                end
                error("matching non-exhaustive, at #= none:106 =#")
                $(Expr(:symboliclabel, Symbol("####final#1275#1287")))
                var"##return#1274"
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
                    var"##cache#1291" = nothing
                end
                var"##return#1288" = nothing
                var"##1290" = ex
                if var"##1290" isa Expr
                    if begin
                                if var"##cache#1291" === nothing
                                    var"##cache#1291" = Some(((var"##1290").head, (var"##1290").args))
                                end
                                var"##1292" = (var"##cache#1291").value
                                var"##1292" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1292"[1] == :block && (begin
                                        var"##1293" = var"##1292"[2]
                                        var"##1293" isa AbstractArray
                                    end && ((ndims(var"##1293") === 1 && length(var"##1293") >= 0) && begin
                                            var"##1294" = SubArray(var"##1293", (1:length(var"##1293"),))
                                            true
                                        end)))
                        var"##return#1288" = let args = var"##1294"
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
                        $(Expr(:symbolicgoto, Symbol("####final#1289#1299")))
                    end
                    if begin
                                var"##1295" = (var"##cache#1291").value
                                var"##1295" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1296" = var"##1295"[1]
                                    var"##1297" = var"##1295"[2]
                                    var"##1297" isa AbstractArray
                                end && ((ndims(var"##1297") === 1 && length(var"##1297") >= 0) && begin
                                        var"##1298" = SubArray(var"##1297", (1:length(var"##1297"),))
                                        true
                                    end))
                        var"##return#1288" = let args = var"##1298", head = var"##1296"
                                Expr(head, map(rm_nothing, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1289#1299")))
                    end
                end
                begin
                    var"##return#1288" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1289#1299")))
                end
                error("matching non-exhaustive, at #= none:217 =#")
                $(Expr(:symboliclabel, Symbol("####final#1289#1299")))
                var"##return#1288"
            end
        end
    #= none:230 =# Core.@doc "    canonicalize_lambda_head(ex)\n\nCanonicalize the `Expr(:function, Expr(:block, x, Expr(:(=), key, default)), body)` to\n\n```julia\nExpr(:function, Expr(:tuple, Expr(:parameters, Expr(:kw, key, default)), x), body)\n```\n" function canonicalize_lambda_head(ex)
            let
                begin
                    var"##cache#1303" = nothing
                end
                var"##return#1300" = nothing
                var"##1302" = ex
                if var"##1302" isa Expr
                    if begin
                                if var"##cache#1303" === nothing
                                    var"##cache#1303" = Some(((var"##1302").head, (var"##1302").args))
                                end
                                var"##1304" = (var"##cache#1303").value
                                var"##1304" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1304"[1] == :function && (begin
                                        var"##1305" = var"##1304"[2]
                                        var"##1305" isa AbstractArray
                                    end && (length(var"##1305") === 2 && (begin
                                                begin
                                                    var"##cache#1307" = nothing
                                                end
                                                var"##1306" = var"##1305"[1]
                                                var"##1306" isa Expr
                                            end && (begin
                                                    if var"##cache#1307" === nothing
                                                        var"##cache#1307" = Some(((var"##1306").head, (var"##1306").args))
                                                    end
                                                    var"##1308" = (var"##cache#1307").value
                                                    var"##1308" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1308"[1] == :block && (begin
                                                            var"##1309" = var"##1308"[2]
                                                            var"##1309" isa AbstractArray
                                                        end && (length(var"##1309") === 2 && begin
                                                                var"##1310" = var"##1309"[1]
                                                                var"##1311" = var"##1309"[2]
                                                                var"##1312" = var"##1305"[2]
                                                                true
                                                            end))))))))
                        var"##return#1300" = let y = var"##1311", body = var"##1312", x = var"##1310"
                                Expr(:function, Expr(:tuple, Expr(:parameters, y), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1301#1356")))
                    end
                    if begin
                                var"##1313" = (var"##cache#1303").value
                                var"##1313" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1313"[1] == :function && (begin
                                        var"##1314" = var"##1313"[2]
                                        var"##1314" isa AbstractArray
                                    end && (length(var"##1314") === 2 && (begin
                                                begin
                                                    var"##cache#1316" = nothing
                                                end
                                                var"##1315" = var"##1314"[1]
                                                var"##1315" isa Expr
                                            end && (begin
                                                    if var"##cache#1316" === nothing
                                                        var"##cache#1316" = Some(((var"##1315").head, (var"##1315").args))
                                                    end
                                                    var"##1317" = (var"##cache#1316").value
                                                    var"##1317" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1317"[1] == :block && (begin
                                                            var"##1318" = var"##1317"[2]
                                                            var"##1318" isa AbstractArray
                                                        end && (length(var"##1318") === 3 && (begin
                                                                    var"##1319" = var"##1318"[1]
                                                                    var"##1320" = var"##1318"[2]
                                                                    var"##1320" isa LineNumberNode
                                                                end && begin
                                                                    var"##1321" = var"##1318"[3]
                                                                    var"##1322" = var"##1314"[2]
                                                                    true
                                                                end)))))))))
                        var"##return#1300" = let y = var"##1321", body = var"##1322", x = var"##1319"
                                Expr(:function, Expr(:tuple, Expr(:parameters, y), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1301#1356")))
                    end
                    if begin
                                var"##1323" = (var"##cache#1303").value
                                var"##1323" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1323"[1] == :function && (begin
                                        var"##1324" = var"##1323"[2]
                                        var"##1324" isa AbstractArray
                                    end && (length(var"##1324") === 2 && (begin
                                                begin
                                                    var"##cache#1326" = nothing
                                                end
                                                var"##1325" = var"##1324"[1]
                                                var"##1325" isa Expr
                                            end && (begin
                                                    if var"##cache#1326" === nothing
                                                        var"##cache#1326" = Some(((var"##1325").head, (var"##1325").args))
                                                    end
                                                    var"##1327" = (var"##cache#1326").value
                                                    var"##1327" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1327"[1] == :block && (begin
                                                            var"##1328" = var"##1327"[2]
                                                            var"##1328" isa AbstractArray
                                                        end && (length(var"##1328") === 2 && (begin
                                                                    var"##1329" = var"##1328"[1]
                                                                    begin
                                                                        var"##cache#1331" = nothing
                                                                    end
                                                                    var"##1330" = var"##1328"[2]
                                                                    var"##1330" isa Expr
                                                                end && (begin
                                                                        if var"##cache#1331" === nothing
                                                                            var"##cache#1331" = Some(((var"##1330").head, (var"##1330").args))
                                                                        end
                                                                        var"##1332" = (var"##cache#1331").value
                                                                        var"##1332" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                    end && (var"##1332"[1] == :(=) && (begin
                                                                                var"##1333" = var"##1332"[2]
                                                                                var"##1333" isa AbstractArray
                                                                            end && (length(var"##1333") === 2 && begin
                                                                                    var"##1334" = var"##1333"[1]
                                                                                    var"##1335" = var"##1333"[2]
                                                                                    var"##1336" = var"##1324"[2]
                                                                                    true
                                                                                end)))))))))))))
                        var"##return#1300" = let default = var"##1335", key = var"##1334", body = var"##1336", x = var"##1329"
                                Expr(:function, Expr(:tuple, Expr(:parameters, Expr(:kw, key, default)), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1301#1356")))
                    end
                    if begin
                                var"##1337" = (var"##cache#1303").value
                                var"##1337" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1337"[1] == :function && (begin
                                        var"##1338" = var"##1337"[2]
                                        var"##1338" isa AbstractArray
                                    end && (length(var"##1338") === 2 && (begin
                                                begin
                                                    var"##cache#1340" = nothing
                                                end
                                                var"##1339" = var"##1338"[1]
                                                var"##1339" isa Expr
                                            end && (begin
                                                    if var"##cache#1340" === nothing
                                                        var"##cache#1340" = Some(((var"##1339").head, (var"##1339").args))
                                                    end
                                                    var"##1341" = (var"##cache#1340").value
                                                    var"##1341" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1341"[1] == :block && (begin
                                                            var"##1342" = var"##1341"[2]
                                                            var"##1342" isa AbstractArray
                                                        end && (length(var"##1342") === 3 && (begin
                                                                    var"##1343" = var"##1342"[1]
                                                                    var"##1344" = var"##1342"[2]
                                                                    var"##1344" isa LineNumberNode
                                                                end && (begin
                                                                        begin
                                                                            var"##cache#1346" = nothing
                                                                        end
                                                                        var"##1345" = var"##1342"[3]
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
                                                                                        var"##1351" = var"##1338"[2]
                                                                                        true
                                                                                    end))))))))))))))
                        var"##return#1300" = let default = var"##1350", key = var"##1349", body = var"##1351", x = var"##1343"
                                Expr(:function, Expr(:tuple, Expr(:parameters, Expr(:kw, key, default)), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1301#1356")))
                    end
                    if begin
                                var"##1352" = (var"##cache#1303").value
                                var"##1352" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1353" = var"##1352"[1]
                                    var"##1354" = var"##1352"[2]
                                    var"##1354" isa AbstractArray
                                end && ((ndims(var"##1354") === 1 && length(var"##1354") >= 0) && begin
                                        var"##1355" = SubArray(var"##1354", (1:length(var"##1354"),))
                                        true
                                    end))
                        var"##return#1300" = let args = var"##1355", head = var"##1353"
                                Expr(head, map(canonicalize_lambda_head, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1301#1356")))
                    end
                end
                begin
                    var"##return#1300" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1301#1356")))
                end
                error("matching non-exhaustive, at #= none:240 =#")
                $(Expr(:symboliclabel, Symbol("####final#1301#1356")))
                var"##return#1300"
            end
        end
    function rm_single_block(ex)
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
                        end && (var"##1361"[1] == :(=) && (begin
                                    var"##1362" = var"##1361"[2]
                                    var"##1362" isa AbstractArray
                                end && (ndims(var"##1362") === 1 && length(var"##1362") >= 0)))
                    var"##return#1357" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1358#1425")))
                end
                if begin
                            var"##1363" = (var"##cache#1360").value
                            var"##1363" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1363"[1] == :-> && (begin
                                    var"##1364" = var"##1363"[2]
                                    var"##1364" isa AbstractArray
                                end && (ndims(var"##1364") === 1 && length(var"##1364") >= 0)))
                    var"##return#1357" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1358#1425")))
                end
                if begin
                            var"##1365" = (var"##cache#1360").value
                            var"##1365" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1365"[1] == :quote && (begin
                                    var"##1366" = var"##1365"[2]
                                    var"##1366" isa AbstractArray
                                end && ((ndims(var"##1366") === 1 && length(var"##1366") >= 0) && begin
                                        var"##1367" = SubArray(var"##1366", (1:length(var"##1366"),))
                                        true
                                    end)))
                    var"##return#1357" = let xs = var"##1367"
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1358#1425")))
                end
                if begin
                            var"##1368" = (var"##cache#1360").value
                            var"##1368" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1368"[1] == :block && (begin
                                    var"##1369" = var"##1368"[2]
                                    var"##1369" isa AbstractArray
                                end && (length(var"##1369") === 1 && (begin
                                            begin
                                                var"##cache#1371" = nothing
                                            end
                                            var"##1370" = var"##1369"[1]
                                            var"##1370" isa Expr
                                        end && (begin
                                                if var"##cache#1371" === nothing
                                                    var"##cache#1371" = Some(((var"##1370").head, (var"##1370").args))
                                                end
                                                var"##1372" = (var"##cache#1371").value
                                                var"##1372" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1372"[1] == :quote && (begin
                                                        var"##1373" = var"##1372"[2]
                                                        var"##1373" isa AbstractArray
                                                    end && ((ndims(var"##1373") === 1 && length(var"##1373") >= 0) && begin
                                                            var"##1374" = SubArray(var"##1373", (1:length(var"##1373"),))
                                                            true
                                                        end))))))))
                    var"##return#1357" = let xs = var"##1374"
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1358#1425")))
                end
                if begin
                            var"##1375" = (var"##cache#1360").value
                            var"##1375" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1375"[1] == :try && (begin
                                    var"##1376" = var"##1375"[2]
                                    var"##1376" isa AbstractArray
                                end && (length(var"##1376") === 4 && (begin
                                            begin
                                                var"##cache#1378" = nothing
                                            end
                                            var"##1377" = var"##1376"[1]
                                            var"##1377" isa Expr
                                        end && (begin
                                                if var"##cache#1378" === nothing
                                                    var"##cache#1378" = Some(((var"##1377").head, (var"##1377").args))
                                                end
                                                var"##1379" = (var"##cache#1378").value
                                                var"##1379" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1379"[1] == :block && (begin
                                                        var"##1380" = var"##1379"[2]
                                                        var"##1380" isa AbstractArray
                                                    end && ((ndims(var"##1380") === 1 && length(var"##1380") >= 0) && (begin
                                                                var"##1381" = SubArray(var"##1380", (1:length(var"##1380"),))
                                                                var"##1376"[2] === false
                                                            end && (var"##1376"[3] === false && (begin
                                                                        begin
                                                                            var"##cache#1383" = nothing
                                                                        end
                                                                        var"##1382" = var"##1376"[4]
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
                                                                                end && ((ndims(var"##1385") === 1 && length(var"##1385") >= 0) && begin
                                                                                        var"##1386" = SubArray(var"##1385", (1:length(var"##1385"),))
                                                                                        true
                                                                                    end)))))))))))))))
                    var"##return#1357" = let try_stmts = var"##1381", finally_stmts = var"##1386"
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), false, false, Expr(:block, rm_single_block.(finally_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1358#1425")))
                end
                if begin
                            var"##1387" = (var"##cache#1360").value
                            var"##1387" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1387"[1] == :try && (begin
                                    var"##1388" = var"##1387"[2]
                                    var"##1388" isa AbstractArray
                                end && (length(var"##1388") === 3 && (begin
                                            begin
                                                var"##cache#1390" = nothing
                                            end
                                            var"##1389" = var"##1388"[1]
                                            var"##1389" isa Expr
                                        end && (begin
                                                if var"##cache#1390" === nothing
                                                    var"##cache#1390" = Some(((var"##1389").head, (var"##1389").args))
                                                end
                                                var"##1391" = (var"##cache#1390").value
                                                var"##1391" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1391"[1] == :block && (begin
                                                        var"##1392" = var"##1391"[2]
                                                        var"##1392" isa AbstractArray
                                                    end && ((ndims(var"##1392") === 1 && length(var"##1392") >= 0) && (begin
                                                                var"##1393" = SubArray(var"##1392", (1:length(var"##1392"),))
                                                                var"##1394" = var"##1388"[2]
                                                                begin
                                                                    var"##cache#1396" = nothing
                                                                end
                                                                var"##1395" = var"##1388"[3]
                                                                var"##1395" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1396" === nothing
                                                                        var"##cache#1396" = Some(((var"##1395").head, (var"##1395").args))
                                                                    end
                                                                    var"##1397" = (var"##cache#1396").value
                                                                    var"##1397" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1397"[1] == :block && (begin
                                                                            var"##1398" = var"##1397"[2]
                                                                            var"##1398" isa AbstractArray
                                                                        end && ((ndims(var"##1398") === 1 && length(var"##1398") >= 0) && begin
                                                                                var"##1399" = SubArray(var"##1398", (1:length(var"##1398"),))
                                                                                true
                                                                            end)))))))))))))
                    var"##return#1357" = let try_stmts = var"##1393", catch_stmts = var"##1399", catch_var = var"##1394"
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), catch_var, Expr(:block, rm_single_block.(catch_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1358#1425")))
                end
                if begin
                            var"##1400" = (var"##cache#1360").value
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
                                                                var"##1407" = var"##1401"[2]
                                                                begin
                                                                    var"##cache#1409" = nothing
                                                                end
                                                                var"##1408" = var"##1401"[3]
                                                                var"##1408" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1409" === nothing
                                                                        var"##cache#1409" = Some(((var"##1408").head, (var"##1408").args))
                                                                    end
                                                                    var"##1410" = (var"##cache#1409").value
                                                                    var"##1410" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1410"[1] == :block && (begin
                                                                            var"##1411" = var"##1410"[2]
                                                                            var"##1411" isa AbstractArray
                                                                        end && ((ndims(var"##1411") === 1 && length(var"##1411") >= 0) && (begin
                                                                                    var"##1412" = SubArray(var"##1411", (1:length(var"##1411"),))
                                                                                    begin
                                                                                        var"##cache#1414" = nothing
                                                                                    end
                                                                                    var"##1413" = var"##1401"[4]
                                                                                    var"##1413" isa Expr
                                                                                end && (begin
                                                                                        if var"##cache#1414" === nothing
                                                                                            var"##cache#1414" = Some(((var"##1413").head, (var"##1413").args))
                                                                                        end
                                                                                        var"##1415" = (var"##cache#1414").value
                                                                                        var"##1415" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                                    end && (var"##1415"[1] == :block && (begin
                                                                                                var"##1416" = var"##1415"[2]
                                                                                                var"##1416" isa AbstractArray
                                                                                            end && ((ndims(var"##1416") === 1 && length(var"##1416") >= 0) && begin
                                                                                                    var"##1417" = SubArray(var"##1416", (1:length(var"##1416"),))
                                                                                                    true
                                                                                                end))))))))))))))))))
                    var"##return#1357" = let try_stmts = var"##1406", catch_stmts = var"##1412", catch_var = var"##1407", finally_stmts = var"##1417"
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), catch_var, Expr(:block, rm_single_block.(catch_stmts)...), Expr(:block, rm_single_block.(finally_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1358#1425")))
                end
                if begin
                            var"##1418" = (var"##cache#1360").value
                            var"##1418" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1418"[1] == :block && (begin
                                    var"##1419" = var"##1418"[2]
                                    var"##1419" isa AbstractArray
                                end && (length(var"##1419") === 1 && begin
                                        var"##1420" = var"##1419"[1]
                                        true
                                    end)))
                    var"##return#1357" = let stmt = var"##1420"
                            stmt
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1358#1425")))
                end
                if begin
                            var"##1421" = (var"##cache#1360").value
                            var"##1421" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                        end && (begin
                                var"##1422" = var"##1421"[1]
                                var"##1423" = var"##1421"[2]
                                var"##1423" isa AbstractArray
                            end && ((ndims(var"##1423") === 1 && length(var"##1423") >= 0) && begin
                                    var"##1424" = SubArray(var"##1423", (1:length(var"##1423"),))
                                    true
                                end))
                    var"##return#1357" = let args = var"##1424", head = var"##1422"
                            Expr(head, map(rm_single_block, args)...)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1358#1425")))
                end
            end
            begin
                var"##return#1357" = let
                        ex
                    end
                $(Expr(:symbolicgoto, Symbol("####final#1358#1425")))
            end
            error("matching non-exhaustive, at #= none:256 =#")
            $(Expr(:symboliclabel, Symbol("####final#1358#1425")))
            var"##return#1357"
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
