
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
            ex.head === :module && return name_only(ex.args[2])
            error("unsupported expression $(ex)")
        end
    #= none:83 =# Core.@doc "    annotations_only(ex)\n\nReturn type annotations only. See also [`name_only`](@ref).\n" function annotations_only(#= none:88 =# @nospecialize(ex))
            ex isa Symbol && return :(())
            ex isa Expr || error("unsupported expression $(ex)")
            Meta.isexpr(ex, :...) && return annotations_only(ex.args[1])
            Meta.isexpr(ex, :(::)) && return ex.args[var"end"]
            error("unsupported expression $(ex)")
        end
    #= none:96 =# Core.@doc "    rm_lineinfo(ex)\n\nRemove `LineNumberNode` in a given expression.\n\n!!! tips\n\n    the `LineNumberNode` inside macro calls won't be removed since\n    the `macrocall` expression requires a `LineNumberNode`. See also\n    [issues/#9](https://github.com/Roger-luo/Expronicon.jl/issues/9).\n" function rm_lineinfo(ex)
            let
                begin
                    var"##cache#1294" = nothing
                end
                var"##return#1291" = nothing
                var"##1293" = ex
                if var"##1293" isa Expr
                    if begin
                                if var"##cache#1294" === nothing
                                    var"##cache#1294" = Some(((var"##1293").head, (var"##1293").args))
                                end
                                var"##1295" = (var"##cache#1294").value
                                var"##1295" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1295"[1] == :macrocall && (begin
                                        var"##1296" = var"##1295"[2]
                                        var"##1296" isa AbstractArray
                                    end && ((ndims(var"##1296") === 1 && length(var"##1296") >= 2) && begin
                                            var"##1297" = var"##1296"[1]
                                            var"##1298" = var"##1296"[2]
                                            var"##1299" = SubArray(var"##1296", (3:length(var"##1296"),))
                                            true
                                        end)))
                        var"##return#1291" = let line = var"##1298", name = var"##1297", args = var"##1299"
                                Expr(:macrocall, name, line, map(rm_lineinfo, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1292#1304")))
                    end
                    if begin
                                var"##1300" = (var"##cache#1294").value
                                var"##1300" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1301" = var"##1300"[1]
                                    var"##1302" = var"##1300"[2]
                                    var"##1302" isa AbstractArray
                                end && ((ndims(var"##1302") === 1 && length(var"##1302") >= 0) && begin
                                        var"##1303" = SubArray(var"##1302", (1:length(var"##1302"),))
                                        true
                                    end))
                        var"##return#1291" = let args = var"##1303", head = var"##1301"
                                Expr(head, map(rm_lineinfo, filter((x->begin
                                                    !(x isa LineNumberNode)
                                                end), args))...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1292#1304")))
                    end
                end
                begin
                    var"##return#1291" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1292#1304")))
                end
                error("matching non-exhaustive, at #= none:108 =#")
                $(Expr(:symboliclabel, Symbol("####final#1292#1304")))
                var"##return#1291"
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
                    var"##cache#1308" = nothing
                end
                var"##return#1305" = nothing
                var"##1307" = ex
                if var"##1307" isa Expr
                    if begin
                                if var"##cache#1308" === nothing
                                    var"##cache#1308" = Some(((var"##1307").head, (var"##1307").args))
                                end
                                var"##1309" = (var"##cache#1308").value
                                var"##1309" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1309"[1] == :block && (begin
                                        var"##1310" = var"##1309"[2]
                                        var"##1310" isa AbstractArray
                                    end && ((ndims(var"##1310") === 1 && length(var"##1310") >= 0) && begin
                                            var"##1311" = SubArray(var"##1310", (1:length(var"##1310"),))
                                            true
                                        end)))
                        var"##return#1305" = let args = var"##1311"
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
                        $(Expr(:symbolicgoto, Symbol("####final#1306#1316")))
                    end
                    if begin
                                var"##1312" = (var"##cache#1308").value
                                var"##1312" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1313" = var"##1312"[1]
                                    var"##1314" = var"##1312"[2]
                                    var"##1314" isa AbstractArray
                                end && ((ndims(var"##1314") === 1 && length(var"##1314") >= 0) && begin
                                        var"##1315" = SubArray(var"##1314", (1:length(var"##1314"),))
                                        true
                                    end))
                        var"##return#1305" = let args = var"##1315", head = var"##1313"
                                Expr(head, map(rm_nothing, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1306#1316")))
                    end
                end
                begin
                    var"##return#1305" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1306#1316")))
                end
                error("matching non-exhaustive, at #= none:219 =#")
                $(Expr(:symboliclabel, Symbol("####final#1306#1316")))
                var"##return#1305"
            end
        end
    #= none:232 =# Core.@doc "    canonicalize_lambda_head(ex)\n\nCanonicalize the `Expr(:function, Expr(:block, x, Expr(:(=), key, default)), body)` to\n\n```julia\nExpr(:function, Expr(:tuple, Expr(:parameters, Expr(:kw, key, default)), x), body)\n```\n" function canonicalize_lambda_head(ex)
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
                            end && (var"##1321"[1] == :function && (begin
                                        var"##1322" = var"##1321"[2]
                                        var"##1322" isa AbstractArray
                                    end && (length(var"##1322") === 2 && (begin
                                                begin
                                                    var"##cache#1324" = nothing
                                                end
                                                var"##1323" = var"##1322"[1]
                                                var"##1323" isa Expr
                                            end && (begin
                                                    if var"##cache#1324" === nothing
                                                        var"##cache#1324" = Some(((var"##1323").head, (var"##1323").args))
                                                    end
                                                    var"##1325" = (var"##cache#1324").value
                                                    var"##1325" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1325"[1] == :block && (begin
                                                            var"##1326" = var"##1325"[2]
                                                            var"##1326" isa AbstractArray
                                                        end && (length(var"##1326") === 2 && begin
                                                                var"##1327" = var"##1326"[1]
                                                                var"##1328" = var"##1326"[2]
                                                                var"##1329" = var"##1322"[2]
                                                                true
                                                            end))))))))
                        var"##return#1317" = let y = var"##1328", body = var"##1329", x = var"##1327"
                                Expr(:function, Expr(:tuple, Expr(:parameters, y), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1318#1373")))
                    end
                    if begin
                                var"##1330" = (var"##cache#1320").value
                                var"##1330" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1330"[1] == :function && (begin
                                        var"##1331" = var"##1330"[2]
                                        var"##1331" isa AbstractArray
                                    end && (length(var"##1331") === 2 && (begin
                                                begin
                                                    var"##cache#1333" = nothing
                                                end
                                                var"##1332" = var"##1331"[1]
                                                var"##1332" isa Expr
                                            end && (begin
                                                    if var"##cache#1333" === nothing
                                                        var"##cache#1333" = Some(((var"##1332").head, (var"##1332").args))
                                                    end
                                                    var"##1334" = (var"##cache#1333").value
                                                    var"##1334" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1334"[1] == :block && (begin
                                                            var"##1335" = var"##1334"[2]
                                                            var"##1335" isa AbstractArray
                                                        end && (length(var"##1335") === 3 && (begin
                                                                    var"##1336" = var"##1335"[1]
                                                                    var"##1337" = var"##1335"[2]
                                                                    var"##1337" isa LineNumberNode
                                                                end && begin
                                                                    var"##1338" = var"##1335"[3]
                                                                    var"##1339" = var"##1331"[2]
                                                                    true
                                                                end)))))))))
                        var"##return#1317" = let y = var"##1338", body = var"##1339", x = var"##1336"
                                Expr(:function, Expr(:tuple, Expr(:parameters, y), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1318#1373")))
                    end
                    if begin
                                var"##1340" = (var"##cache#1320").value
                                var"##1340" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1340"[1] == :function && (begin
                                        var"##1341" = var"##1340"[2]
                                        var"##1341" isa AbstractArray
                                    end && (length(var"##1341") === 2 && (begin
                                                begin
                                                    var"##cache#1343" = nothing
                                                end
                                                var"##1342" = var"##1341"[1]
                                                var"##1342" isa Expr
                                            end && (begin
                                                    if var"##cache#1343" === nothing
                                                        var"##cache#1343" = Some(((var"##1342").head, (var"##1342").args))
                                                    end
                                                    var"##1344" = (var"##cache#1343").value
                                                    var"##1344" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1344"[1] == :block && (begin
                                                            var"##1345" = var"##1344"[2]
                                                            var"##1345" isa AbstractArray
                                                        end && (length(var"##1345") === 2 && (begin
                                                                    var"##1346" = var"##1345"[1]
                                                                    begin
                                                                        var"##cache#1348" = nothing
                                                                    end
                                                                    var"##1347" = var"##1345"[2]
                                                                    var"##1347" isa Expr
                                                                end && (begin
                                                                        if var"##cache#1348" === nothing
                                                                            var"##cache#1348" = Some(((var"##1347").head, (var"##1347").args))
                                                                        end
                                                                        var"##1349" = (var"##cache#1348").value
                                                                        var"##1349" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                    end && (var"##1349"[1] == :(=) && (begin
                                                                                var"##1350" = var"##1349"[2]
                                                                                var"##1350" isa AbstractArray
                                                                            end && (length(var"##1350") === 2 && begin
                                                                                    var"##1351" = var"##1350"[1]
                                                                                    var"##1352" = var"##1350"[2]
                                                                                    var"##1353" = var"##1341"[2]
                                                                                    true
                                                                                end)))))))))))))
                        var"##return#1317" = let default = var"##1352", key = var"##1351", body = var"##1353", x = var"##1346"
                                Expr(:function, Expr(:tuple, Expr(:parameters, Expr(:kw, key, default)), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1318#1373")))
                    end
                    if begin
                                var"##1354" = (var"##cache#1320").value
                                var"##1354" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1354"[1] == :function && (begin
                                        var"##1355" = var"##1354"[2]
                                        var"##1355" isa AbstractArray
                                    end && (length(var"##1355") === 2 && (begin
                                                begin
                                                    var"##cache#1357" = nothing
                                                end
                                                var"##1356" = var"##1355"[1]
                                                var"##1356" isa Expr
                                            end && (begin
                                                    if var"##cache#1357" === nothing
                                                        var"##cache#1357" = Some(((var"##1356").head, (var"##1356").args))
                                                    end
                                                    var"##1358" = (var"##cache#1357").value
                                                    var"##1358" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1358"[1] == :block && (begin
                                                            var"##1359" = var"##1358"[2]
                                                            var"##1359" isa AbstractArray
                                                        end && (length(var"##1359") === 3 && (begin
                                                                    var"##1360" = var"##1359"[1]
                                                                    var"##1361" = var"##1359"[2]
                                                                    var"##1361" isa LineNumberNode
                                                                end && (begin
                                                                        begin
                                                                            var"##cache#1363" = nothing
                                                                        end
                                                                        var"##1362" = var"##1359"[3]
                                                                        var"##1362" isa Expr
                                                                    end && (begin
                                                                            if var"##cache#1363" === nothing
                                                                                var"##cache#1363" = Some(((var"##1362").head, (var"##1362").args))
                                                                            end
                                                                            var"##1364" = (var"##cache#1363").value
                                                                            var"##1364" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                        end && (var"##1364"[1] == :(=) && (begin
                                                                                    var"##1365" = var"##1364"[2]
                                                                                    var"##1365" isa AbstractArray
                                                                                end && (length(var"##1365") === 2 && begin
                                                                                        var"##1366" = var"##1365"[1]
                                                                                        var"##1367" = var"##1365"[2]
                                                                                        var"##1368" = var"##1355"[2]
                                                                                        true
                                                                                    end))))))))))))))
                        var"##return#1317" = let default = var"##1367", key = var"##1366", body = var"##1368", x = var"##1360"
                                Expr(:function, Expr(:tuple, Expr(:parameters, Expr(:kw, key, default)), x), body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1318#1373")))
                    end
                    if begin
                                var"##1369" = (var"##cache#1320").value
                                var"##1369" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                            end && (begin
                                    var"##1370" = var"##1369"[1]
                                    var"##1371" = var"##1369"[2]
                                    var"##1371" isa AbstractArray
                                end && ((ndims(var"##1371") === 1 && length(var"##1371") >= 0) && begin
                                        var"##1372" = SubArray(var"##1371", (1:length(var"##1371"),))
                                        true
                                    end))
                        var"##return#1317" = let args = var"##1372", head = var"##1370"
                                Expr(head, map(canonicalize_lambda_head, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#1318#1373")))
                    end
                end
                begin
                    var"##return#1317" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1318#1373")))
                end
                error("matching non-exhaustive, at #= none:242 =#")
                $(Expr(:symboliclabel, Symbol("####final#1318#1373")))
                var"##return#1317"
            end
        end
    function rm_single_block(ex)
        let
            begin
                var"##cache#1377" = nothing
            end
            var"##return#1374" = nothing
            var"##1376" = ex
            if var"##1376" isa Expr
                if begin
                            if var"##cache#1377" === nothing
                                var"##cache#1377" = Some(((var"##1376").head, (var"##1376").args))
                            end
                            var"##1378" = (var"##cache#1377").value
                            var"##1378" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1378"[1] == :(=) && (begin
                                    var"##1379" = var"##1378"[2]
                                    var"##1379" isa AbstractArray
                                end && (ndims(var"##1379") === 1 && length(var"##1379") >= 0)))
                    var"##return#1374" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1375#1442")))
                end
                if begin
                            var"##1380" = (var"##cache#1377").value
                            var"##1380" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1380"[1] == :-> && (begin
                                    var"##1381" = var"##1380"[2]
                                    var"##1381" isa AbstractArray
                                end && (ndims(var"##1381") === 1 && length(var"##1381") >= 0)))
                    var"##return#1374" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1375#1442")))
                end
                if begin
                            var"##1382" = (var"##cache#1377").value
                            var"##1382" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1382"[1] == :quote && (begin
                                    var"##1383" = var"##1382"[2]
                                    var"##1383" isa AbstractArray
                                end && ((ndims(var"##1383") === 1 && length(var"##1383") >= 0) && begin
                                        var"##1384" = SubArray(var"##1383", (1:length(var"##1383"),))
                                        true
                                    end)))
                    var"##return#1374" = let xs = var"##1384"
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1375#1442")))
                end
                if begin
                            var"##1385" = (var"##cache#1377").value
                            var"##1385" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1385"[1] == :block && (begin
                                    var"##1386" = var"##1385"[2]
                                    var"##1386" isa AbstractArray
                                end && (length(var"##1386") === 1 && (begin
                                            begin
                                                var"##cache#1388" = nothing
                                            end
                                            var"##1387" = var"##1386"[1]
                                            var"##1387" isa Expr
                                        end && (begin
                                                if var"##cache#1388" === nothing
                                                    var"##cache#1388" = Some(((var"##1387").head, (var"##1387").args))
                                                end
                                                var"##1389" = (var"##cache#1388").value
                                                var"##1389" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1389"[1] == :quote && (begin
                                                        var"##1390" = var"##1389"[2]
                                                        var"##1390" isa AbstractArray
                                                    end && ((ndims(var"##1390") === 1 && length(var"##1390") >= 0) && begin
                                                            var"##1391" = SubArray(var"##1390", (1:length(var"##1390"),))
                                                            true
                                                        end))))))))
                    var"##return#1374" = let xs = var"##1391"
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1375#1442")))
                end
                if begin
                            var"##1392" = (var"##cache#1377").value
                            var"##1392" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1392"[1] == :try && (begin
                                    var"##1393" = var"##1392"[2]
                                    var"##1393" isa AbstractArray
                                end && (length(var"##1393") === 4 && (begin
                                            begin
                                                var"##cache#1395" = nothing
                                            end
                                            var"##1394" = var"##1393"[1]
                                            var"##1394" isa Expr
                                        end && (begin
                                                if var"##cache#1395" === nothing
                                                    var"##cache#1395" = Some(((var"##1394").head, (var"##1394").args))
                                                end
                                                var"##1396" = (var"##cache#1395").value
                                                var"##1396" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1396"[1] == :block && (begin
                                                        var"##1397" = var"##1396"[2]
                                                        var"##1397" isa AbstractArray
                                                    end && ((ndims(var"##1397") === 1 && length(var"##1397") >= 0) && (begin
                                                                var"##1398" = SubArray(var"##1397", (1:length(var"##1397"),))
                                                                var"##1393"[2] === false
                                                            end && (var"##1393"[3] === false && (begin
                                                                        begin
                                                                            var"##cache#1400" = nothing
                                                                        end
                                                                        var"##1399" = var"##1393"[4]
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
                                                                                end && ((ndims(var"##1402") === 1 && length(var"##1402") >= 0) && begin
                                                                                        var"##1403" = SubArray(var"##1402", (1:length(var"##1402"),))
                                                                                        true
                                                                                    end)))))))))))))))
                    var"##return#1374" = let try_stmts = var"##1398", finally_stmts = var"##1403"
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), false, false, Expr(:block, rm_single_block.(finally_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1375#1442")))
                end
                if begin
                            var"##1404" = (var"##cache#1377").value
                            var"##1404" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1404"[1] == :try && (begin
                                    var"##1405" = var"##1404"[2]
                                    var"##1405" isa AbstractArray
                                end && (length(var"##1405") === 3 && (begin
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
                                                                var"##1411" = var"##1405"[2]
                                                                begin
                                                                    var"##cache#1413" = nothing
                                                                end
                                                                var"##1412" = var"##1405"[3]
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
                                                                        end && ((ndims(var"##1415") === 1 && length(var"##1415") >= 0) && begin
                                                                                var"##1416" = SubArray(var"##1415", (1:length(var"##1415"),))
                                                                                true
                                                                            end)))))))))))))
                    var"##return#1374" = let try_stmts = var"##1410", catch_stmts = var"##1416", catch_var = var"##1411"
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), catch_var, Expr(:block, rm_single_block.(catch_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1375#1442")))
                end
                if begin
                            var"##1417" = (var"##cache#1377").value
                            var"##1417" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1417"[1] == :try && (begin
                                    var"##1418" = var"##1417"[2]
                                    var"##1418" isa AbstractArray
                                end && (length(var"##1418") === 4 && (begin
                                            begin
                                                var"##cache#1420" = nothing
                                            end
                                            var"##1419" = var"##1418"[1]
                                            var"##1419" isa Expr
                                        end && (begin
                                                if var"##cache#1420" === nothing
                                                    var"##cache#1420" = Some(((var"##1419").head, (var"##1419").args))
                                                end
                                                var"##1421" = (var"##cache#1420").value
                                                var"##1421" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1421"[1] == :block && (begin
                                                        var"##1422" = var"##1421"[2]
                                                        var"##1422" isa AbstractArray
                                                    end && ((ndims(var"##1422") === 1 && length(var"##1422") >= 0) && (begin
                                                                var"##1423" = SubArray(var"##1422", (1:length(var"##1422"),))
                                                                var"##1424" = var"##1418"[2]
                                                                begin
                                                                    var"##cache#1426" = nothing
                                                                end
                                                                var"##1425" = var"##1418"[3]
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
                                                                        end && ((ndims(var"##1428") === 1 && length(var"##1428") >= 0) && (begin
                                                                                    var"##1429" = SubArray(var"##1428", (1:length(var"##1428"),))
                                                                                    begin
                                                                                        var"##cache#1431" = nothing
                                                                                    end
                                                                                    var"##1430" = var"##1418"[4]
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
                                                                                                end))))))))))))))))))
                    var"##return#1374" = let try_stmts = var"##1423", catch_stmts = var"##1429", catch_var = var"##1424", finally_stmts = var"##1434"
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), catch_var, Expr(:block, rm_single_block.(catch_stmts)...), Expr(:block, rm_single_block.(finally_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1375#1442")))
                end
                if begin
                            var"##1435" = (var"##cache#1377").value
                            var"##1435" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1435"[1] == :block && (begin
                                    var"##1436" = var"##1435"[2]
                                    var"##1436" isa AbstractArray
                                end && (length(var"##1436") === 1 && begin
                                        var"##1437" = var"##1436"[1]
                                        true
                                    end)))
                    var"##return#1374" = let stmt = var"##1437"
                            stmt
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1375#1442")))
                end
                if begin
                            var"##1438" = (var"##cache#1377").value
                            var"##1438" isa (Tuple{var1, var2} where {var2 <: AbstractArray, var1})
                        end && (begin
                                var"##1439" = var"##1438"[1]
                                var"##1440" = var"##1438"[2]
                                var"##1440" isa AbstractArray
                            end && ((ndims(var"##1440") === 1 && length(var"##1440") >= 0) && begin
                                    var"##1441" = SubArray(var"##1440", (1:length(var"##1440"),))
                                    true
                                end))
                    var"##return#1374" = let args = var"##1441", head = var"##1439"
                            Expr(head, map(rm_single_block, args)...)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1375#1442")))
                end
            end
            begin
                var"##return#1374" = let
                        ex
                    end
                $(Expr(:symbolicgoto, Symbol("####final#1375#1442")))
            end
            error("matching non-exhaustive, at #= none:258 =#")
            $(Expr(:symboliclabel, Symbol("####final#1375#1442")))
            var"##return#1374"
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
