
    #= none:1 =# Core.@doc "    split_doc(ex::Expr) -> line, doc, expr\n\nSplit doc string from given expression.\n" function split_doc(ex::Expr)
            begin
                begin
                    var"##cache#545" = nothing
                end
                var"##544" = ex
                if var"##544" isa Expr
                    if begin
                                if var"##cache#545" === nothing
                                    var"##cache#545" = Some(((var"##544").head, (var"##544").args))
                                end
                                var"##546" = (var"##cache#545").value
                                var"##546" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##546"[1] == :macrocall && (begin
                                        var"##547" = var"##546"[2]
                                        var"##547" isa AbstractArray
                                    end && (length(var"##547") === 4 && (begin
                                                var"##548" = var"##547"[1]
                                                var"##548" == GlobalRef(Core, Symbol("@doc"))
                                            end && begin
                                                var"##549" = var"##547"[2]
                                                var"##550" = var"##547"[3]
                                                var"##551" = var"##547"[4]
                                                true
                                            end))))
                        line = var"##549"
                        expr = var"##551"
                        doc = var"##550"
                        var"##return#542" = begin
                                return (line, doc, expr)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#543#572")))
                    end
                    if begin
                                var"##552" = (var"##cache#545").value
                                var"##552" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##552"[1] == :macrocall && (begin
                                        var"##553" = var"##552"[2]
                                        var"##553" isa AbstractArray
                                    end && (length(var"##553") === 4 && (begin
                                                var"##554" = var"##553"[1]
                                                var"##554" == Symbol("@doc")
                                            end && begin
                                                var"##555" = var"##553"[2]
                                                var"##556" = var"##553"[3]
                                                var"##557" = var"##553"[4]
                                                true
                                            end))))
                        line = var"##555"
                        expr = var"##557"
                        doc = var"##556"
                        var"##return#542" = begin
                                return (line, doc, expr)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#543#572")))
                    end
                    if begin
                                var"##558" = (var"##cache#545").value
                                var"##558" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##558"[1] == :macrocall && (begin
                                        var"##559" = var"##558"[2]
                                        var"##559" isa AbstractArray
                                    end && (length(var"##559") === 4 && (begin
                                                begin
                                                    var"##cache#561" = nothing
                                                end
                                                var"##560" = var"##559"[1]
                                                var"##560" isa Expr
                                            end && (begin
                                                    if var"##cache#561" === nothing
                                                        var"##cache#561" = Some(((var"##560").head, (var"##560").args))
                                                    end
                                                    var"##562" = (var"##cache#561").value
                                                    var"##562" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##562"[1] == :. && (begin
                                                            var"##563" = var"##562"[2]
                                                            var"##563" isa AbstractArray
                                                        end && (length(var"##563") === 2 && (var"##563"[1] == :Core && (begin
                                                                        var"##564" = var"##563"[2]
                                                                        var"##564" == QuoteNode(Symbol("@doc"))
                                                                    end && begin
                                                                        var"##565" = var"##559"[2]
                                                                        var"##566" = var"##559"[3]
                                                                        var"##567" = var"##559"[4]
                                                                        true
                                                                    end))))))))))
                        line = var"##565"
                        expr = var"##567"
                        doc = var"##566"
                        var"##return#542" = begin
                                return (line, doc, expr)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#543#572")))
                    end
                    if begin
                                var"##568" = (var"##cache#545").value
                                var"##568" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##568"[1] == :block && (begin
                                        var"##569" = var"##568"[2]
                                        var"##569" isa AbstractArray
                                    end && (length(var"##569") === 2 && (begin
                                                var"##570" = var"##569"[1]
                                                var"##570" isa LineNumberNode
                                            end && begin
                                                var"##571" = var"##569"[2]
                                                true
                                            end))))
                        stmt = var"##571"
                        var"##return#542" = begin
                                (line, doc, expr) = split_doc(stmt)
                                return (line, doc, expr)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#543#572")))
                    end
                end
                begin
                    var"##return#542" = begin
                            return (nothing, nothing, ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#543#572")))
                end
                error("matching non-exhaustive, at #= none:7 =#")
                $(Expr(:symboliclabel, Symbol("####final#543#572")))
                var"##return#542"
            end
        end
    #= none:24 =# Core.@doc "    split_function(ex::Expr) -> head, call, body\n\nSplit function head declaration with function body.\n" function split_function(ex::Expr)
            let
                begin
                    var"##cache#576" = nothing
                end
                var"##return#573" = nothing
                var"##575" = ex
                if var"##575" isa Expr
                    if begin
                                if var"##cache#576" === nothing
                                    var"##cache#576" = Some(((var"##575").head, (var"##575").args))
                                end
                                var"##577" = (var"##cache#576").value
                                var"##577" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##577"[1] == :function && (begin
                                        var"##578" = var"##577"[2]
                                        var"##578" isa AbstractArray
                                    end && (length(var"##578") === 2 && begin
                                            var"##579" = var"##578"[1]
                                            var"##580" = var"##578"[2]
                                            true
                                        end)))
                        var"##return#573" = let call = var"##579", body = var"##580"
                                (:function, call, body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#574#589")))
                    end
                    if begin
                                var"##581" = (var"##cache#576").value
                                var"##581" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##581"[1] == :(=) && (begin
                                        var"##582" = var"##581"[2]
                                        var"##582" isa AbstractArray
                                    end && (length(var"##582") === 2 && begin
                                            var"##583" = var"##582"[1]
                                            var"##584" = var"##582"[2]
                                            true
                                        end)))
                        var"##return#573" = let call = var"##583", body = var"##584"
                                (:(=), call, body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#574#589")))
                    end
                    if begin
                                var"##585" = (var"##cache#576").value
                                var"##585" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##585"[1] == :-> && (begin
                                        var"##586" = var"##585"[2]
                                        var"##586" isa AbstractArray
                                    end && (length(var"##586") === 2 && begin
                                            var"##587" = var"##586"[1]
                                            var"##588" = var"##586"[2]
                                            true
                                        end)))
                        var"##return#573" = let call = var"##587", body = var"##588"
                                (:->, call, body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#574#589")))
                    end
                end
                begin
                    var"##return#573" = let
                            anlys_error("function", ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#574#589")))
                end
                error("matching non-exhaustive, at #= none:30 =#")
                $(Expr(:symboliclabel, Symbol("####final#574#589")))
                var"##return#573"
            end
        end
    #= none:38 =# Core.@doc "    split_function_head(ex::Expr) -> name, args, kw, whereparams, rettype\n\nSplit function head to name, arguments, keyword arguments and where parameters.\n" function split_function_head(ex::Expr)
            let
                begin
                    var"##cache#593" = nothing
                end
                var"##return#590" = nothing
                var"##592" = ex
                if var"##592" isa Expr
                    if begin
                                if var"##cache#593" === nothing
                                    var"##cache#593" = Some(((var"##592").head, (var"##592").args))
                                end
                                var"##594" = (var"##cache#593").value
                                var"##594" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##594"[1] == :tuple && (begin
                                        var"##595" = var"##594"[2]
                                        var"##595" isa AbstractArray
                                    end && ((ndims(var"##595") === 1 && length(var"##595") >= 1) && (begin
                                                begin
                                                    var"##cache#597" = nothing
                                                end
                                                var"##596" = var"##595"[1]
                                                var"##596" isa Expr
                                            end && (begin
                                                    if var"##cache#597" === nothing
                                                        var"##cache#597" = Some(((var"##596").head, (var"##596").args))
                                                    end
                                                    var"##598" = (var"##cache#597").value
                                                    var"##598" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##598"[1] == :parameters && (begin
                                                            var"##599" = var"##598"[2]
                                                            var"##599" isa AbstractArray
                                                        end && ((ndims(var"##599") === 1 && length(var"##599") >= 0) && begin
                                                                var"##600" = SubArray(var"##599", (1:length(var"##599"),))
                                                                var"##601" = SubArray(var"##595", (2:length(var"##595"),))
                                                                true
                                                            end))))))))
                        var"##return#590" = let args = var"##601", kw = var"##600"
                                (nothing, args, kw, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#591#641")))
                    end
                    if begin
                                var"##602" = (var"##cache#593").value
                                var"##602" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##602"[1] == :tuple && (begin
                                        var"##603" = var"##602"[2]
                                        var"##603" isa AbstractArray
                                    end && ((ndims(var"##603") === 1 && length(var"##603") >= 0) && begin
                                            var"##604" = SubArray(var"##603", (1:length(var"##603"),))
                                            true
                                        end)))
                        var"##return#590" = let args = var"##604"
                                (nothing, args, nothing, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#591#641")))
                    end
                    if begin
                                var"##605" = (var"##cache#593").value
                                var"##605" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##605"[1] == :call && (begin
                                        var"##606" = var"##605"[2]
                                        var"##606" isa AbstractArray
                                    end && ((ndims(var"##606") === 1 && length(var"##606") >= 2) && (begin
                                                var"##607" = var"##606"[1]
                                                begin
                                                    var"##cache#609" = nothing
                                                end
                                                var"##608" = var"##606"[2]
                                                var"##608" isa Expr
                                            end && (begin
                                                    if var"##cache#609" === nothing
                                                        var"##cache#609" = Some(((var"##608").head, (var"##608").args))
                                                    end
                                                    var"##610" = (var"##cache#609").value
                                                    var"##610" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##610"[1] == :parameters && (begin
                                                            var"##611" = var"##610"[2]
                                                            var"##611" isa AbstractArray
                                                        end && ((ndims(var"##611") === 1 && length(var"##611") >= 0) && begin
                                                                var"##612" = SubArray(var"##611", (1:length(var"##611"),))
                                                                var"##613" = SubArray(var"##606", (3:length(var"##606"),))
                                                                true
                                                            end))))))))
                        var"##return#590" = let name = var"##607", args = var"##613", kw = var"##612"
                                (name, args, kw, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#591#641")))
                    end
                    if begin
                                var"##614" = (var"##cache#593").value
                                var"##614" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##614"[1] == :call && (begin
                                        var"##615" = var"##614"[2]
                                        var"##615" isa AbstractArray
                                    end && ((ndims(var"##615") === 1 && length(var"##615") >= 1) && begin
                                            var"##616" = var"##615"[1]
                                            var"##617" = SubArray(var"##615", (2:length(var"##615"),))
                                            true
                                        end)))
                        var"##return#590" = let name = var"##616", args = var"##617"
                                (name, args, nothing, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#591#641")))
                    end
                    if begin
                                var"##618" = (var"##cache#593").value
                                var"##618" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##618"[1] == :block && (begin
                                        var"##619" = var"##618"[2]
                                        var"##619" isa AbstractArray
                                    end && (length(var"##619") === 3 && (begin
                                                var"##620" = var"##619"[1]
                                                var"##621" = var"##619"[2]
                                                var"##621" isa LineNumberNode
                                            end && (begin
                                                    begin
                                                        var"##cache#623" = nothing
                                                    end
                                                    var"##622" = var"##619"[3]
                                                    var"##622" isa Expr
                                                end && (begin
                                                        if var"##cache#623" === nothing
                                                            var"##cache#623" = Some(((var"##622").head, (var"##622").args))
                                                        end
                                                        var"##624" = (var"##cache#623").value
                                                        var"##624" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                    end && (var"##624"[1] == :(=) && (begin
                                                                var"##625" = var"##624"[2]
                                                                var"##625" isa AbstractArray
                                                            end && (length(var"##625") === 2 && begin
                                                                    var"##626" = var"##625"[1]
                                                                    var"##627" = var"##625"[2]
                                                                    true
                                                                end)))))))))
                        var"##return#590" = let value = var"##627", kw = var"##626", x = var"##620"
                                (nothing, Any[x], Any[Expr(:kw, kw, value)], nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#591#641")))
                    end
                    if begin
                                var"##628" = (var"##cache#593").value
                                var"##628" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##628"[1] == :block && (begin
                                        var"##629" = var"##628"[2]
                                        var"##629" isa AbstractArray
                                    end && (length(var"##629") === 3 && (begin
                                                var"##630" = var"##629"[1]
                                                var"##631" = var"##629"[2]
                                                var"##631" isa LineNumberNode
                                            end && begin
                                                var"##632" = var"##629"[3]
                                                true
                                            end))))
                        var"##return#590" = let kw = var"##632", x = var"##630"
                                (nothing, Any[x], Any[kw], nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#591#641")))
                    end
                    if begin
                                var"##633" = (var"##cache#593").value
                                var"##633" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##633"[1] == :(::) && (begin
                                        var"##634" = var"##633"[2]
                                        var"##634" isa AbstractArray
                                    end && (length(var"##634") === 2 && begin
                                            var"##635" = var"##634"[1]
                                            var"##636" = var"##634"[2]
                                            true
                                        end)))
                        var"##return#590" = let call = var"##635", rettype = var"##636"
                                (name, args, kw, whereparams, _) = split_function_head(call)
                                (name, args, kw, whereparams, rettype)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#591#641")))
                    end
                    if begin
                                var"##637" = (var"##cache#593").value
                                var"##637" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##637"[1] == :where && (begin
                                        var"##638" = var"##637"[2]
                                        var"##638" isa AbstractArray
                                    end && ((ndims(var"##638") === 1 && length(var"##638") >= 1) && begin
                                            var"##639" = var"##638"[1]
                                            var"##640" = SubArray(var"##638", (2:length(var"##638"),))
                                            true
                                        end)))
                        var"##return#590" = let call = var"##639", whereparams = var"##640"
                                (name, args, kw, _, rettype) = split_function_head(call)
                                (name, args, kw, whereparams, rettype)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#591#641")))
                    end
                end
                begin
                    var"##return#590" = let
                            anlys_error("function head expr", ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#591#641")))
                end
                error("matching non-exhaustive, at #= none:44 =#")
                $(Expr(:symboliclabel, Symbol("####final#591#641")))
                var"##return#590"
            end
        end
    #= none:63 =# Core.@doc "    split_struct_name(ex::Expr) -> name, typevars, supertype\n\nSplit the name, type parameters and supertype definition from `struct`\ndeclaration head.\n" function split_struct_name(#= none:69 =# @nospecialize(ex))
            return let
                    begin
                        var"##cache#645" = nothing
                    end
                    var"##return#642" = nothing
                    var"##644" = ex
                    if var"##644" isa Expr
                        if begin
                                    if var"##cache#645" === nothing
                                        var"##cache#645" = Some(((var"##644").head, (var"##644").args))
                                    end
                                    var"##646" = (var"##cache#645").value
                                    var"##646" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##646"[1] == :curly && (begin
                                            var"##647" = var"##646"[2]
                                            var"##647" isa AbstractArray
                                        end && ((ndims(var"##647") === 1 && length(var"##647") >= 1) && begin
                                                var"##648" = var"##647"[1]
                                                var"##649" = SubArray(var"##647", (2:length(var"##647"),))
                                                true
                                            end)))
                            var"##return#642" = let typevars = var"##649", name = var"##648"
                                    (name, typevars, nothing)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#643#663")))
                        end
                        if begin
                                    var"##650" = (var"##cache#645").value
                                    var"##650" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##650"[1] == :<: && (begin
                                            var"##651" = var"##650"[2]
                                            var"##651" isa AbstractArray
                                        end && (length(var"##651") === 2 && (begin
                                                    begin
                                                        var"##cache#653" = nothing
                                                    end
                                                    var"##652" = var"##651"[1]
                                                    var"##652" isa Expr
                                                end && (begin
                                                        if var"##cache#653" === nothing
                                                            var"##cache#653" = Some(((var"##652").head, (var"##652").args))
                                                        end
                                                        var"##654" = (var"##cache#653").value
                                                        var"##654" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                    end && (var"##654"[1] == :curly && (begin
                                                                var"##655" = var"##654"[2]
                                                                var"##655" isa AbstractArray
                                                            end && ((ndims(var"##655") === 1 && length(var"##655") >= 1) && begin
                                                                    var"##656" = var"##655"[1]
                                                                    var"##657" = SubArray(var"##655", (2:length(var"##655"),))
                                                                    var"##658" = var"##651"[2]
                                                                    true
                                                                end))))))))
                            var"##return#642" = let typevars = var"##657", type = var"##658", name = var"##656"
                                    (name, typevars, type)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#643#663")))
                        end
                        if begin
                                    var"##659" = (var"##cache#645").value
                                    var"##659" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##659"[1] == :<: && (begin
                                            var"##660" = var"##659"[2]
                                            var"##660" isa AbstractArray
                                        end && (length(var"##660") === 2 && begin
                                                var"##661" = var"##660"[1]
                                                var"##662" = var"##660"[2]
                                                true
                                            end)))
                            var"##return#642" = let type = var"##662", name = var"##661"
                                    (name, [], type)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#643#663")))
                        end
                    end
                    if var"##644" isa Symbol
                        begin
                            var"##return#642" = let
                                    (ex, [], nothing)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#643#663")))
                        end
                    end
                    begin
                        var"##return#642" = let
                                anlys_error("struct", ex)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#643#663")))
                    end
                    error("matching non-exhaustive, at #= none:70 =#")
                    $(Expr(:symboliclabel, Symbol("####final#643#663")))
                    var"##return#642"
                end
        end
    #= none:79 =# Core.@doc "    split_struct(ex::Expr) -> ismutable, name, typevars, supertype, body\n\nSplit struct definition head and body.\n" function split_struct(ex::Expr)
            ex.head === :struct || error("expect a struct expr, got $(ex)")
            (name, typevars, supertype) = split_struct_name(ex.args[2])
            body = ex.args[3]
            return (ex.args[1], name, typevars, supertype, body)
        end
    function split_ifelse(ex::Expr)
        (conds, stmts) = ([], [])
        otherwise = split_ifelse!((conds, stmts), ex)
        return (conds, stmts, otherwise)
    end
    function split_ifelse!((conds, stmts), ex::Expr)
        ex.head in [:if, :elseif] || return ex
        push!(conds, ex.args[1])
        push!(stmts, ex.args[2])
        if length(ex.args) == 3
            return split_ifelse!((conds, stmts), ex.args[3])
        end
        return nothing
    end
    function split_forloop(ex::Expr)
        ex.head === :for || error("expect a for loop expr, got $(ex)")
        lhead = ex.args[1]
        lbody = ex.args[2]
        return (split_for_head(lhead)..., lbody)
    end
    function split_for_head(ex::Expr)
        if ex.head === :block
            (vars, itrs) = ([], [])
            for each = ex.args
                each isa Expr || continue
                (var, itr) = split_single_for_head(each)
                push!(vars, var)
                push!(itrs, itr)
            end
            return (vars, itrs)
        else
            (var, itr) = split_single_for_head(ex)
            return (Any[var], Any[itr])
        end
    end
    function split_single_for_head(ex::Expr)
        ex.head === :(=) || error("expect a single loop head, got $(ex)")
        return (ex.args[1], ex.args[2])
    end
    #= none:136 =# Core.@doc "    uninferrable_typevars(def::Union{JLStruct, JLKwStruct}; leading_inferable::Bool=true)\n\nReturn the type variables that are not inferrable in given struct definition.\n" function uninferrable_typevars(def::Union{JLStruct, JLKwStruct}; leading_inferable::Bool = true)
            typevars = name_only.(def.typevars)
            field_types = [field.type for field = def.fields]
            if leading_inferable
                idx = findfirst(typevars) do t
                        !(any(map((f->begin
                                            has_symbol(f, t)
                                        end), field_types)))
                    end
                idx === nothing && return []
            else
                idx = 0
            end
            uninferrable = typevars[1:idx]
            for T = typevars[idx + 1:end]
                any(map((f->begin
                                    has_symbol(f, T)
                                end), field_types)) || push!(uninferrable, T)
            end
            return uninferrable
        end
    #= none:161 =# Core.@doc "    split_field_if_match(typename::Symbol, expr, default::Bool=false)\n\nSplit the field definition if it matches the given type name.\nReturns `NamedTuple` with `name`, `type`, `default` and `isconst` fields\nif it matches, otherwise return `nothing`.\n" function split_field_if_match(typename::Symbol, expr, default::Bool = false)
            begin
                begin
                    var"##cache#667" = nothing
                end
                var"##666" = expr
                if var"##666" isa Expr
                    if begin
                                if var"##cache#667" === nothing
                                    var"##cache#667" = Some(((var"##666").head, (var"##666").args))
                                end
                                var"##668" = (var"##cache#667").value
                                var"##668" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##668"[1] == :const && (begin
                                        var"##669" = var"##668"[2]
                                        var"##669" isa AbstractArray
                                    end && (length(var"##669") === 1 && (begin
                                                begin
                                                    var"##cache#671" = nothing
                                                end
                                                var"##670" = var"##669"[1]
                                                var"##670" isa Expr
                                            end && (begin
                                                    if var"##cache#671" === nothing
                                                        var"##cache#671" = Some(((var"##670").head, (var"##670").args))
                                                    end
                                                    var"##672" = (var"##cache#671").value
                                                    var"##672" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##672"[1] == :(=) && (begin
                                                            var"##673" = var"##672"[2]
                                                            var"##673" isa AbstractArray
                                                        end && (length(var"##673") === 2 && (begin
                                                                    begin
                                                                        var"##cache#675" = nothing
                                                                    end
                                                                    var"##674" = var"##673"[1]
                                                                    var"##674" isa Expr
                                                                end && (begin
                                                                        if var"##cache#675" === nothing
                                                                            var"##cache#675" = Some(((var"##674").head, (var"##674").args))
                                                                        end
                                                                        var"##676" = (var"##cache#675").value
                                                                        var"##676" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                    end && (var"##676"[1] == :(::) && (begin
                                                                                var"##677" = var"##676"[2]
                                                                                var"##677" isa AbstractArray
                                                                            end && (length(var"##677") === 2 && (begin
                                                                                        var"##678" = var"##677"[1]
                                                                                        var"##678" isa Symbol
                                                                                    end && begin
                                                                                        var"##679" = var"##677"[2]
                                                                                        var"##680" = var"##673"[2]
                                                                                        true
                                                                                    end))))))))))))))
                        value = var"##680"
                        type = var"##679"
                        name = var"##678"
                        var"##return#664" = begin
                                default && return (; name, type, isconst = true, default = value)
                                throw(ArgumentError("default value syntax is not allowed"))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#665#717")))
                    end
                    if begin
                                var"##681" = (var"##cache#667").value
                                var"##681" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##681"[1] == :const && (begin
                                        var"##682" = var"##681"[2]
                                        var"##682" isa AbstractArray
                                    end && (length(var"##682") === 1 && (begin
                                                begin
                                                    var"##cache#684" = nothing
                                                end
                                                var"##683" = var"##682"[1]
                                                var"##683" isa Expr
                                            end && (begin
                                                    if var"##cache#684" === nothing
                                                        var"##cache#684" = Some(((var"##683").head, (var"##683").args))
                                                    end
                                                    var"##685" = (var"##cache#684").value
                                                    var"##685" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##685"[1] == :(=) && (begin
                                                            var"##686" = var"##685"[2]
                                                            var"##686" isa AbstractArray
                                                        end && (length(var"##686") === 2 && (begin
                                                                    var"##687" = var"##686"[1]
                                                                    var"##687" isa Symbol
                                                                end && begin
                                                                    var"##688" = var"##686"[2]
                                                                    true
                                                                end)))))))))
                        value = var"##688"
                        name = var"##687"
                        var"##return#664" = begin
                                default && return (; name, type = Any, isconst = true, default = value)
                                throw(ArgumentError("default value syntax is not allowed"))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#665#717")))
                    end
                    if begin
                                var"##689" = (var"##cache#667").value
                                var"##689" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##689"[1] == :(=) && (begin
                                        var"##690" = var"##689"[2]
                                        var"##690" isa AbstractArray
                                    end && (length(var"##690") === 2 && (begin
                                                begin
                                                    var"##cache#692" = nothing
                                                end
                                                var"##691" = var"##690"[1]
                                                var"##691" isa Expr
                                            end && (begin
                                                    if var"##cache#692" === nothing
                                                        var"##cache#692" = Some(((var"##691").head, (var"##691").args))
                                                    end
                                                    var"##693" = (var"##cache#692").value
                                                    var"##693" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##693"[1] == :(::) && (begin
                                                            var"##694" = var"##693"[2]
                                                            var"##694" isa AbstractArray
                                                        end && (length(var"##694") === 2 && (begin
                                                                    var"##695" = var"##694"[1]
                                                                    var"##695" isa Symbol
                                                                end && begin
                                                                    var"##696" = var"##694"[2]
                                                                    var"##697" = var"##690"[2]
                                                                    true
                                                                end)))))))))
                        value = var"##697"
                        type = var"##696"
                        name = var"##695"
                        var"##return#664" = begin
                                default && return (; name, type, isconst = false, default = value)
                                throw(ArgumentError("default value syntax is not allowed"))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#665#717")))
                    end
                    if begin
                                var"##698" = (var"##cache#667").value
                                var"##698" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##698"[1] == :(=) && (begin
                                        var"##699" = var"##698"[2]
                                        var"##699" isa AbstractArray
                                    end && (length(var"##699") === 2 && (begin
                                                var"##700" = var"##699"[1]
                                                var"##700" isa Symbol
                                            end && begin
                                                var"##701" = var"##699"[2]
                                                true
                                            end))))
                        value = var"##701"
                        name = var"##700"
                        var"##return#664" = begin
                                default && return (; name, type = Any, isconst = false, default = value)
                                throw(ArgumentError("default value syntax is not allowed"))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#665#717")))
                    end
                    if begin
                                var"##702" = (var"##cache#667").value
                                var"##702" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##702"[1] == :const && (begin
                                        var"##703" = var"##702"[2]
                                        var"##703" isa AbstractArray
                                    end && (length(var"##703") === 1 && (begin
                                                begin
                                                    var"##cache#705" = nothing
                                                end
                                                var"##704" = var"##703"[1]
                                                var"##704" isa Expr
                                            end && (begin
                                                    if var"##cache#705" === nothing
                                                        var"##cache#705" = Some(((var"##704").head, (var"##704").args))
                                                    end
                                                    var"##706" = (var"##cache#705").value
                                                    var"##706" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##706"[1] == :(::) && (begin
                                                            var"##707" = var"##706"[2]
                                                            var"##707" isa AbstractArray
                                                        end && (length(var"##707") === 2 && (begin
                                                                    var"##708" = var"##707"[1]
                                                                    var"##708" isa Symbol
                                                                end && begin
                                                                    var"##709" = var"##707"[2]
                                                                    true
                                                                end)))))))))
                        type = var"##709"
                        name = var"##708"
                        var"##return#664" = begin
                                default && return (; name, type, isconst = true, default = no_default)
                                return (; name, type, isconst = true)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#665#717")))
                    end
                    if begin
                                var"##710" = (var"##cache#667").value
                                var"##710" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##710"[1] == :const && (begin
                                        var"##711" = var"##710"[2]
                                        var"##711" isa AbstractArray
                                    end && (length(var"##711") === 1 && begin
                                            var"##712" = var"##711"[1]
                                            var"##712" isa Symbol
                                        end)))
                        name = var"##712"
                        var"##return#664" = begin
                                default && return (; name, type = Any, isconst = true, default = no_default)
                                return (; name, type = Any, isconst = true)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#665#717")))
                    end
                    if begin
                                var"##713" = (var"##cache#667").value
                                var"##713" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##713"[1] == :(::) && (begin
                                        var"##714" = var"##713"[2]
                                        var"##714" isa AbstractArray
                                    end && (length(var"##714") === 2 && (begin
                                                var"##715" = var"##714"[1]
                                                var"##715" isa Symbol
                                            end && begin
                                                var"##716" = var"##714"[2]
                                                true
                                            end))))
                        type = var"##716"
                        name = var"##715"
                        var"##return#664" = begin
                                default && return (; name, type, isconst = false, default = no_default)
                                return (; name, type, isconst = false)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#665#717")))
                    end
                end
                if var"##666" isa Symbol
                    begin
                        name = var"##666"
                        var"##return#664" = begin
                                default && return (; name, type = Any, isconst = false, default = no_default)
                                return (; name, type = Any, isconst = false)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#665#717")))
                    end
                end
                if var"##666" isa String
                    begin
                        var"##return#664" = begin
                                return expr
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#665#717")))
                    end
                end
                if var"##666" isa LineNumberNode
                    begin
                        var"##return#664" = begin
                                return expr
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#665#717")))
                    end
                end
                if is_function(expr)
                    var"##return#664" = begin
                            if name_only(expr) === typename
                                return JLFunction(expr)
                            else
                                return expr
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#665#717")))
                end
                begin
                    var"##return#664" = begin
                            return expr
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#665#717")))
                end
                error("matching non-exhaustive, at #= none:169 =#")
                $(Expr(:symboliclabel, Symbol("####final#665#717")))
                var"##return#664"
            end
        end
