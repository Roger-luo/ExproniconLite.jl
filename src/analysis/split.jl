
    #= none:1 =# Core.@doc "    split_doc(ex::Expr) -> line, doc, expr\n\nSplit doc string from given expression.\n" function split_doc(ex::Expr)
            begin
                begin
                    var"##cache#525" = nothing
                end
                var"##524" = ex
                if var"##524" isa Expr
                    if begin
                                if var"##cache#525" === nothing
                                    var"##cache#525" = Some(((var"##524").head, (var"##524").args))
                                end
                                var"##526" = (var"##cache#525").value
                                var"##526" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##526"[1] == :macrocall && (begin
                                        var"##527" = var"##526"[2]
                                        var"##527" isa AbstractArray
                                    end && (length(var"##527") === 4 && (begin
                                                var"##528" = var"##527"[1]
                                                var"##528" == GlobalRef(Core, Symbol("@doc"))
                                            end && begin
                                                var"##529" = var"##527"[2]
                                                var"##530" = var"##527"[3]
                                                var"##531" = var"##527"[4]
                                                true
                                            end))))
                        line = var"##529"
                        expr = var"##531"
                        doc = var"##530"
                        var"##return#522" = begin
                                return (line, doc, expr)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#523#552")))
                    end
                    if begin
                                var"##532" = (var"##cache#525").value
                                var"##532" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##532"[1] == :macrocall && (begin
                                        var"##533" = var"##532"[2]
                                        var"##533" isa AbstractArray
                                    end && (length(var"##533") === 4 && (begin
                                                var"##534" = var"##533"[1]
                                                var"##534" == Symbol("@doc")
                                            end && begin
                                                var"##535" = var"##533"[2]
                                                var"##536" = var"##533"[3]
                                                var"##537" = var"##533"[4]
                                                true
                                            end))))
                        line = var"##535"
                        expr = var"##537"
                        doc = var"##536"
                        var"##return#522" = begin
                                return (line, doc, expr)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#523#552")))
                    end
                    if begin
                                var"##538" = (var"##cache#525").value
                                var"##538" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##538"[1] == :macrocall && (begin
                                        var"##539" = var"##538"[2]
                                        var"##539" isa AbstractArray
                                    end && (length(var"##539") === 4 && (begin
                                                begin
                                                    var"##cache#541" = nothing
                                                end
                                                var"##540" = var"##539"[1]
                                                var"##540" isa Expr
                                            end && (begin
                                                    if var"##cache#541" === nothing
                                                        var"##cache#541" = Some(((var"##540").head, (var"##540").args))
                                                    end
                                                    var"##542" = (var"##cache#541").value
                                                    var"##542" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##542"[1] == :. && (begin
                                                            var"##543" = var"##542"[2]
                                                            var"##543" isa AbstractArray
                                                        end && (length(var"##543") === 2 && (var"##543"[1] == :Core && (begin
                                                                        var"##544" = var"##543"[2]
                                                                        var"##544" == QuoteNode(Symbol("@doc"))
                                                                    end && begin
                                                                        var"##545" = var"##539"[2]
                                                                        var"##546" = var"##539"[3]
                                                                        var"##547" = var"##539"[4]
                                                                        true
                                                                    end))))))))))
                        line = var"##545"
                        expr = var"##547"
                        doc = var"##546"
                        var"##return#522" = begin
                                return (line, doc, expr)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#523#552")))
                    end
                    if begin
                                var"##548" = (var"##cache#525").value
                                var"##548" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##548"[1] == :block && (begin
                                        var"##549" = var"##548"[2]
                                        var"##549" isa AbstractArray
                                    end && (length(var"##549") === 2 && (begin
                                                var"##550" = var"##549"[1]
                                                var"##550" isa LineNumberNode
                                            end && begin
                                                var"##551" = var"##549"[2]
                                                true
                                            end))))
                        stmt = var"##551"
                        var"##return#522" = begin
                                (line, doc, expr) = split_doc(stmt)
                                return (line, doc, expr)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#523#552")))
                    end
                end
                begin
                    var"##return#522" = begin
                            return (nothing, nothing, ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#523#552")))
                end
                error("matching non-exhaustive, at #= none:7 =#")
                $(Expr(:symboliclabel, Symbol("####final#523#552")))
                var"##return#522"
            end
        end
    #= none:24 =# Core.@doc "    split_function(ex::Expr) -> head, call, body\n\nSplit function head declaration with function body.\n" function split_function(ex::Expr)
            let
                begin
                    var"##cache#556" = nothing
                end
                var"##return#553" = nothing
                var"##555" = ex
                if var"##555" isa Expr
                    if begin
                                if var"##cache#556" === nothing
                                    var"##cache#556" = Some(((var"##555").head, (var"##555").args))
                                end
                                var"##557" = (var"##cache#556").value
                                var"##557" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##557"[1] == :function && (begin
                                        var"##558" = var"##557"[2]
                                        var"##558" isa AbstractArray
                                    end && (length(var"##558") === 2 && begin
                                            var"##559" = var"##558"[1]
                                            var"##560" = var"##558"[2]
                                            true
                                        end)))
                        var"##return#553" = let call = var"##559", body = var"##560"
                                (:function, call, body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#554#569")))
                    end
                    if begin
                                var"##561" = (var"##cache#556").value
                                var"##561" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##561"[1] == :(=) && (begin
                                        var"##562" = var"##561"[2]
                                        var"##562" isa AbstractArray
                                    end && (length(var"##562") === 2 && begin
                                            var"##563" = var"##562"[1]
                                            var"##564" = var"##562"[2]
                                            true
                                        end)))
                        var"##return#553" = let call = var"##563", body = var"##564"
                                (:(=), call, body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#554#569")))
                    end
                    if begin
                                var"##565" = (var"##cache#556").value
                                var"##565" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##565"[1] == :-> && (begin
                                        var"##566" = var"##565"[2]
                                        var"##566" isa AbstractArray
                                    end && (length(var"##566") === 2 && begin
                                            var"##567" = var"##566"[1]
                                            var"##568" = var"##566"[2]
                                            true
                                        end)))
                        var"##return#553" = let call = var"##567", body = var"##568"
                                (:->, call, body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#554#569")))
                    end
                end
                begin
                    var"##return#553" = let
                            anlys_error("function", ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#554#569")))
                end
                error("matching non-exhaustive, at #= none:30 =#")
                $(Expr(:symboliclabel, Symbol("####final#554#569")))
                var"##return#553"
            end
        end
    #= none:38 =# Core.@doc "    split_function_head(ex::Expr) -> name, args, kw, whereparams, rettype\n\nSplit function head to name, arguments, keyword arguments and where parameters.\n" function split_function_head(ex::Expr)
            let
                begin
                    var"##cache#573" = nothing
                end
                var"##return#570" = nothing
                var"##572" = ex
                if var"##572" isa Expr
                    if begin
                                if var"##cache#573" === nothing
                                    var"##cache#573" = Some(((var"##572").head, (var"##572").args))
                                end
                                var"##574" = (var"##cache#573").value
                                var"##574" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##574"[1] == :tuple && (begin
                                        var"##575" = var"##574"[2]
                                        var"##575" isa AbstractArray
                                    end && ((ndims(var"##575") === 1 && length(var"##575") >= 1) && (begin
                                                begin
                                                    var"##cache#577" = nothing
                                                end
                                                var"##576" = var"##575"[1]
                                                var"##576" isa Expr
                                            end && (begin
                                                    if var"##cache#577" === nothing
                                                        var"##cache#577" = Some(((var"##576").head, (var"##576").args))
                                                    end
                                                    var"##578" = (var"##cache#577").value
                                                    var"##578" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##578"[1] == :parameters && (begin
                                                            var"##579" = var"##578"[2]
                                                            var"##579" isa AbstractArray
                                                        end && ((ndims(var"##579") === 1 && length(var"##579") >= 0) && begin
                                                                var"##580" = SubArray(var"##579", (1:length(var"##579"),))
                                                                var"##581" = SubArray(var"##575", (2:length(var"##575"),))
                                                                true
                                                            end))))))))
                        var"##return#570" = let args = var"##581", kw = var"##580"
                                (nothing, args, kw, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#571#621")))
                    end
                    if begin
                                var"##582" = (var"##cache#573").value
                                var"##582" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##582"[1] == :tuple && (begin
                                        var"##583" = var"##582"[2]
                                        var"##583" isa AbstractArray
                                    end && ((ndims(var"##583") === 1 && length(var"##583") >= 0) && begin
                                            var"##584" = SubArray(var"##583", (1:length(var"##583"),))
                                            true
                                        end)))
                        var"##return#570" = let args = var"##584"
                                (nothing, args, nothing, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#571#621")))
                    end
                    if begin
                                var"##585" = (var"##cache#573").value
                                var"##585" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##585"[1] == :call && (begin
                                        var"##586" = var"##585"[2]
                                        var"##586" isa AbstractArray
                                    end && ((ndims(var"##586") === 1 && length(var"##586") >= 2) && (begin
                                                var"##587" = var"##586"[1]
                                                begin
                                                    var"##cache#589" = nothing
                                                end
                                                var"##588" = var"##586"[2]
                                                var"##588" isa Expr
                                            end && (begin
                                                    if var"##cache#589" === nothing
                                                        var"##cache#589" = Some(((var"##588").head, (var"##588").args))
                                                    end
                                                    var"##590" = (var"##cache#589").value
                                                    var"##590" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##590"[1] == :parameters && (begin
                                                            var"##591" = var"##590"[2]
                                                            var"##591" isa AbstractArray
                                                        end && ((ndims(var"##591") === 1 && length(var"##591") >= 0) && begin
                                                                var"##592" = SubArray(var"##591", (1:length(var"##591"),))
                                                                var"##593" = SubArray(var"##586", (3:length(var"##586"),))
                                                                true
                                                            end))))))))
                        var"##return#570" = let name = var"##587", args = var"##593", kw = var"##592"
                                (name, args, kw, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#571#621")))
                    end
                    if begin
                                var"##594" = (var"##cache#573").value
                                var"##594" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##594"[1] == :call && (begin
                                        var"##595" = var"##594"[2]
                                        var"##595" isa AbstractArray
                                    end && ((ndims(var"##595") === 1 && length(var"##595") >= 1) && begin
                                            var"##596" = var"##595"[1]
                                            var"##597" = SubArray(var"##595", (2:length(var"##595"),))
                                            true
                                        end)))
                        var"##return#570" = let name = var"##596", args = var"##597"
                                (name, args, nothing, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#571#621")))
                    end
                    if begin
                                var"##598" = (var"##cache#573").value
                                var"##598" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##598"[1] == :block && (begin
                                        var"##599" = var"##598"[2]
                                        var"##599" isa AbstractArray
                                    end && (length(var"##599") === 3 && (begin
                                                var"##600" = var"##599"[1]
                                                var"##601" = var"##599"[2]
                                                var"##601" isa LineNumberNode
                                            end && (begin
                                                    begin
                                                        var"##cache#603" = nothing
                                                    end
                                                    var"##602" = var"##599"[3]
                                                    var"##602" isa Expr
                                                end && (begin
                                                        if var"##cache#603" === nothing
                                                            var"##cache#603" = Some(((var"##602").head, (var"##602").args))
                                                        end
                                                        var"##604" = (var"##cache#603").value
                                                        var"##604" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                    end && (var"##604"[1] == :(=) && (begin
                                                                var"##605" = var"##604"[2]
                                                                var"##605" isa AbstractArray
                                                            end && (length(var"##605") === 2 && begin
                                                                    var"##606" = var"##605"[1]
                                                                    var"##607" = var"##605"[2]
                                                                    true
                                                                end)))))))))
                        var"##return#570" = let value = var"##607", kw = var"##606", x = var"##600"
                                (nothing, Any[x], Any[Expr(:kw, kw, value)], nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#571#621")))
                    end
                    if begin
                                var"##608" = (var"##cache#573").value
                                var"##608" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##608"[1] == :block && (begin
                                        var"##609" = var"##608"[2]
                                        var"##609" isa AbstractArray
                                    end && (length(var"##609") === 3 && (begin
                                                var"##610" = var"##609"[1]
                                                var"##611" = var"##609"[2]
                                                var"##611" isa LineNumberNode
                                            end && begin
                                                var"##612" = var"##609"[3]
                                                true
                                            end))))
                        var"##return#570" = let kw = var"##612", x = var"##610"
                                (nothing, Any[x], Any[kw], nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#571#621")))
                    end
                    if begin
                                var"##613" = (var"##cache#573").value
                                var"##613" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##613"[1] == :(::) && (begin
                                        var"##614" = var"##613"[2]
                                        var"##614" isa AbstractArray
                                    end && (length(var"##614") === 2 && begin
                                            var"##615" = var"##614"[1]
                                            var"##616" = var"##614"[2]
                                            true
                                        end)))
                        var"##return#570" = let call = var"##615", rettype = var"##616"
                                (name, args, kw, whereparams, _) = split_function_head(call)
                                (name, args, kw, whereparams, rettype)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#571#621")))
                    end
                    if begin
                                var"##617" = (var"##cache#573").value
                                var"##617" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##617"[1] == :where && (begin
                                        var"##618" = var"##617"[2]
                                        var"##618" isa AbstractArray
                                    end && ((ndims(var"##618") === 1 && length(var"##618") >= 1) && begin
                                            var"##619" = var"##618"[1]
                                            var"##620" = SubArray(var"##618", (2:length(var"##618"),))
                                            true
                                        end)))
                        var"##return#570" = let call = var"##619", whereparams = var"##620"
                                (name, args, kw, _, rettype) = split_function_head(call)
                                (name, args, kw, whereparams, rettype)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#571#621")))
                    end
                end
                begin
                    var"##return#570" = let
                            anlys_error("function head expr", ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#571#621")))
                end
                error("matching non-exhaustive, at #= none:44 =#")
                $(Expr(:symboliclabel, Symbol("####final#571#621")))
                var"##return#570"
            end
        end
    #= none:63 =# Core.@doc "    split_struct_name(ex::Expr) -> name, typevars, supertype\n\nSplit the name, type parameters and supertype definition from `struct`\ndeclaration head.\n" function split_struct_name(#= none:69 =# @nospecialize(ex))
            return let
                    begin
                        var"##cache#625" = nothing
                    end
                    var"##return#622" = nothing
                    var"##624" = ex
                    if var"##624" isa Expr
                        if begin
                                    if var"##cache#625" === nothing
                                        var"##cache#625" = Some(((var"##624").head, (var"##624").args))
                                    end
                                    var"##626" = (var"##cache#625").value
                                    var"##626" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##626"[1] == :curly && (begin
                                            var"##627" = var"##626"[2]
                                            var"##627" isa AbstractArray
                                        end && ((ndims(var"##627") === 1 && length(var"##627") >= 1) && begin
                                                var"##628" = var"##627"[1]
                                                var"##629" = SubArray(var"##627", (2:length(var"##627"),))
                                                true
                                            end)))
                            var"##return#622" = let typevars = var"##629", name = var"##628"
                                    (name, typevars, nothing)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#623#643")))
                        end
                        if begin
                                    var"##630" = (var"##cache#625").value
                                    var"##630" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##630"[1] == :<: && (begin
                                            var"##631" = var"##630"[2]
                                            var"##631" isa AbstractArray
                                        end && (length(var"##631") === 2 && (begin
                                                    begin
                                                        var"##cache#633" = nothing
                                                    end
                                                    var"##632" = var"##631"[1]
                                                    var"##632" isa Expr
                                                end && (begin
                                                        if var"##cache#633" === nothing
                                                            var"##cache#633" = Some(((var"##632").head, (var"##632").args))
                                                        end
                                                        var"##634" = (var"##cache#633").value
                                                        var"##634" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                    end && (var"##634"[1] == :curly && (begin
                                                                var"##635" = var"##634"[2]
                                                                var"##635" isa AbstractArray
                                                            end && ((ndims(var"##635") === 1 && length(var"##635") >= 1) && begin
                                                                    var"##636" = var"##635"[1]
                                                                    var"##637" = SubArray(var"##635", (2:length(var"##635"),))
                                                                    var"##638" = var"##631"[2]
                                                                    true
                                                                end))))))))
                            var"##return#622" = let typevars = var"##637", type = var"##638", name = var"##636"
                                    (name, typevars, type)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#623#643")))
                        end
                        if begin
                                    var"##639" = (var"##cache#625").value
                                    var"##639" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##639"[1] == :<: && (begin
                                            var"##640" = var"##639"[2]
                                            var"##640" isa AbstractArray
                                        end && (length(var"##640") === 2 && begin
                                                var"##641" = var"##640"[1]
                                                var"##642" = var"##640"[2]
                                                true
                                            end)))
                            var"##return#622" = let type = var"##642", name = var"##641"
                                    (name, [], type)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#623#643")))
                        end
                    end
                    if var"##624" isa Symbol
                        begin
                            var"##return#622" = let
                                    (ex, [], nothing)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#623#643")))
                        end
                    end
                    begin
                        var"##return#622" = let
                                anlys_error("struct", ex)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#623#643")))
                    end
                    error("matching non-exhaustive, at #= none:70 =#")
                    $(Expr(:symboliclabel, Symbol("####final#623#643")))
                    var"##return#622"
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
                    var"##cache#647" = nothing
                end
                var"##646" = expr
                if var"##646" isa Expr
                    if begin
                                if var"##cache#647" === nothing
                                    var"##cache#647" = Some(((var"##646").head, (var"##646").args))
                                end
                                var"##648" = (var"##cache#647").value
                                var"##648" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##648"[1] == :const && (begin
                                        var"##649" = var"##648"[2]
                                        var"##649" isa AbstractArray
                                    end && (length(var"##649") === 1 && (begin
                                                begin
                                                    var"##cache#651" = nothing
                                                end
                                                var"##650" = var"##649"[1]
                                                var"##650" isa Expr
                                            end && (begin
                                                    if var"##cache#651" === nothing
                                                        var"##cache#651" = Some(((var"##650").head, (var"##650").args))
                                                    end
                                                    var"##652" = (var"##cache#651").value
                                                    var"##652" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##652"[1] == :(=) && (begin
                                                            var"##653" = var"##652"[2]
                                                            var"##653" isa AbstractArray
                                                        end && (length(var"##653") === 2 && (begin
                                                                    begin
                                                                        var"##cache#655" = nothing
                                                                    end
                                                                    var"##654" = var"##653"[1]
                                                                    var"##654" isa Expr
                                                                end && (begin
                                                                        if var"##cache#655" === nothing
                                                                            var"##cache#655" = Some(((var"##654").head, (var"##654").args))
                                                                        end
                                                                        var"##656" = (var"##cache#655").value
                                                                        var"##656" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                    end && (var"##656"[1] == :(::) && (begin
                                                                                var"##657" = var"##656"[2]
                                                                                var"##657" isa AbstractArray
                                                                            end && (length(var"##657") === 2 && (begin
                                                                                        var"##658" = var"##657"[1]
                                                                                        var"##658" isa Symbol
                                                                                    end && begin
                                                                                        var"##659" = var"##657"[2]
                                                                                        var"##660" = var"##653"[2]
                                                                                        true
                                                                                    end))))))))))))))
                        value = var"##660"
                        type = var"##659"
                        name = var"##658"
                        var"##return#644" = begin
                                default && return (; name, type, isconst = true, default = value)
                                throw(ArgumentError("default value syntax is not allowed"))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#645#697")))
                    end
                    if begin
                                var"##661" = (var"##cache#647").value
                                var"##661" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##661"[1] == :const && (begin
                                        var"##662" = var"##661"[2]
                                        var"##662" isa AbstractArray
                                    end && (length(var"##662") === 1 && (begin
                                                begin
                                                    var"##cache#664" = nothing
                                                end
                                                var"##663" = var"##662"[1]
                                                var"##663" isa Expr
                                            end && (begin
                                                    if var"##cache#664" === nothing
                                                        var"##cache#664" = Some(((var"##663").head, (var"##663").args))
                                                    end
                                                    var"##665" = (var"##cache#664").value
                                                    var"##665" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##665"[1] == :(=) && (begin
                                                            var"##666" = var"##665"[2]
                                                            var"##666" isa AbstractArray
                                                        end && (length(var"##666") === 2 && (begin
                                                                    var"##667" = var"##666"[1]
                                                                    var"##667" isa Symbol
                                                                end && begin
                                                                    var"##668" = var"##666"[2]
                                                                    true
                                                                end)))))))))
                        value = var"##668"
                        name = var"##667"
                        var"##return#644" = begin
                                default && return (; name, type = Any, isconst = true, default = value)
                                throw(ArgumentError("default value syntax is not allowed"))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#645#697")))
                    end
                    if begin
                                var"##669" = (var"##cache#647").value
                                var"##669" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##669"[1] == :(=) && (begin
                                        var"##670" = var"##669"[2]
                                        var"##670" isa AbstractArray
                                    end && (length(var"##670") === 2 && (begin
                                                begin
                                                    var"##cache#672" = nothing
                                                end
                                                var"##671" = var"##670"[1]
                                                var"##671" isa Expr
                                            end && (begin
                                                    if var"##cache#672" === nothing
                                                        var"##cache#672" = Some(((var"##671").head, (var"##671").args))
                                                    end
                                                    var"##673" = (var"##cache#672").value
                                                    var"##673" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##673"[1] == :(::) && (begin
                                                            var"##674" = var"##673"[2]
                                                            var"##674" isa AbstractArray
                                                        end && (length(var"##674") === 2 && (begin
                                                                    var"##675" = var"##674"[1]
                                                                    var"##675" isa Symbol
                                                                end && begin
                                                                    var"##676" = var"##674"[2]
                                                                    var"##677" = var"##670"[2]
                                                                    true
                                                                end)))))))))
                        value = var"##677"
                        type = var"##676"
                        name = var"##675"
                        var"##return#644" = begin
                                default && return (; name, type, isconst = false, default = value)
                                throw(ArgumentError("default value syntax is not allowed"))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#645#697")))
                    end
                    if begin
                                var"##678" = (var"##cache#647").value
                                var"##678" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##678"[1] == :(=) && (begin
                                        var"##679" = var"##678"[2]
                                        var"##679" isa AbstractArray
                                    end && (length(var"##679") === 2 && (begin
                                                var"##680" = var"##679"[1]
                                                var"##680" isa Symbol
                                            end && begin
                                                var"##681" = var"##679"[2]
                                                true
                                            end))))
                        value = var"##681"
                        name = var"##680"
                        var"##return#644" = begin
                                default && return (; name, type = Any, isconst = false, default = value)
                                throw(ArgumentError("default value syntax is not allowed"))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#645#697")))
                    end
                    if begin
                                var"##682" = (var"##cache#647").value
                                var"##682" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##682"[1] == :const && (begin
                                        var"##683" = var"##682"[2]
                                        var"##683" isa AbstractArray
                                    end && (length(var"##683") === 1 && (begin
                                                begin
                                                    var"##cache#685" = nothing
                                                end
                                                var"##684" = var"##683"[1]
                                                var"##684" isa Expr
                                            end && (begin
                                                    if var"##cache#685" === nothing
                                                        var"##cache#685" = Some(((var"##684").head, (var"##684").args))
                                                    end
                                                    var"##686" = (var"##cache#685").value
                                                    var"##686" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##686"[1] == :(::) && (begin
                                                            var"##687" = var"##686"[2]
                                                            var"##687" isa AbstractArray
                                                        end && (length(var"##687") === 2 && (begin
                                                                    var"##688" = var"##687"[1]
                                                                    var"##688" isa Symbol
                                                                end && begin
                                                                    var"##689" = var"##687"[2]
                                                                    true
                                                                end)))))))))
                        type = var"##689"
                        name = var"##688"
                        var"##return#644" = begin
                                default && return (; name, type, isconst = true, default = no_default)
                                return (; name, type, isconst = true)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#645#697")))
                    end
                    if begin
                                var"##690" = (var"##cache#647").value
                                var"##690" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##690"[1] == :const && (begin
                                        var"##691" = var"##690"[2]
                                        var"##691" isa AbstractArray
                                    end && (length(var"##691") === 1 && begin
                                            var"##692" = var"##691"[1]
                                            var"##692" isa Symbol
                                        end)))
                        name = var"##692"
                        var"##return#644" = begin
                                default && return (; name, type = Any, isconst = true, default = no_default)
                                return (; name, type = Any, isconst = true)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#645#697")))
                    end
                    if begin
                                var"##693" = (var"##cache#647").value
                                var"##693" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##693"[1] == :(::) && (begin
                                        var"##694" = var"##693"[2]
                                        var"##694" isa AbstractArray
                                    end && (length(var"##694") === 2 && (begin
                                                var"##695" = var"##694"[1]
                                                var"##695" isa Symbol
                                            end && begin
                                                var"##696" = var"##694"[2]
                                                true
                                            end))))
                        type = var"##696"
                        name = var"##695"
                        var"##return#644" = begin
                                default && return (; name, type, isconst = false, default = no_default)
                                return (; name, type, isconst = false)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#645#697")))
                    end
                end
                if var"##646" isa Symbol
                    begin
                        name = var"##646"
                        var"##return#644" = begin
                                default && return (; name, type = Any, isconst = false, default = no_default)
                                return (; name, type = Any, isconst = false)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#645#697")))
                    end
                end
                if var"##646" isa String
                    begin
                        var"##return#644" = begin
                                return expr
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#645#697")))
                    end
                end
                if var"##646" isa LineNumberNode
                    begin
                        var"##return#644" = begin
                                return expr
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#645#697")))
                    end
                end
                if is_function(expr)
                    var"##return#644" = begin
                            if name_only(expr) === typename
                                return JLFunction(expr)
                            else
                                return expr
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#645#697")))
                end
                begin
                    var"##return#644" = begin
                            return expr
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#645#697")))
                end
                error("matching non-exhaustive, at #= none:169 =#")
                $(Expr(:symboliclabel, Symbol("####final#645#697")))
                var"##return#644"
            end
        end
