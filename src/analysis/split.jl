
    #= none:1 =# Core.@doc "    split_doc(ex::Expr) -> line, doc, expr\n\nSplit doc string from given expression.\n" function split_doc(ex::Expr)
            begin
                begin
                    var"##cache#535" = nothing
                end
                var"##534" = ex
                if var"##534" isa Expr
                    if begin
                                if var"##cache#535" === nothing
                                    var"##cache#535" = Some(((var"##534").head, (var"##534").args))
                                end
                                var"##536" = (var"##cache#535").value
                                var"##536" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##536"[1] == :macrocall && (begin
                                        var"##537" = var"##536"[2]
                                        var"##537" isa AbstractArray
                                    end && (length(var"##537") === 4 && (begin
                                                var"##538" = var"##537"[1]
                                                var"##538" == GlobalRef(Core, Symbol("@doc"))
                                            end && begin
                                                var"##539" = var"##537"[2]
                                                var"##540" = var"##537"[3]
                                                var"##541" = var"##537"[4]
                                                true
                                            end))))
                        line = var"##539"
                        expr = var"##541"
                        doc = var"##540"
                        var"##return#532" = begin
                                return (line, doc, expr)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#533#562")))
                    end
                    if begin
                                var"##542" = (var"##cache#535").value
                                var"##542" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##542"[1] == :macrocall && (begin
                                        var"##543" = var"##542"[2]
                                        var"##543" isa AbstractArray
                                    end && (length(var"##543") === 4 && (begin
                                                var"##544" = var"##543"[1]
                                                var"##544" == Symbol("@doc")
                                            end && begin
                                                var"##545" = var"##543"[2]
                                                var"##546" = var"##543"[3]
                                                var"##547" = var"##543"[4]
                                                true
                                            end))))
                        line = var"##545"
                        expr = var"##547"
                        doc = var"##546"
                        var"##return#532" = begin
                                return (line, doc, expr)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#533#562")))
                    end
                    if begin
                                var"##548" = (var"##cache#535").value
                                var"##548" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##548"[1] == :macrocall && (begin
                                        var"##549" = var"##548"[2]
                                        var"##549" isa AbstractArray
                                    end && (length(var"##549") === 4 && (begin
                                                begin
                                                    var"##cache#551" = nothing
                                                end
                                                var"##550" = var"##549"[1]
                                                var"##550" isa Expr
                                            end && (begin
                                                    if var"##cache#551" === nothing
                                                        var"##cache#551" = Some(((var"##550").head, (var"##550").args))
                                                    end
                                                    var"##552" = (var"##cache#551").value
                                                    var"##552" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##552"[1] == :. && (begin
                                                            var"##553" = var"##552"[2]
                                                            var"##553" isa AbstractArray
                                                        end && (length(var"##553") === 2 && (var"##553"[1] == :Core && (begin
                                                                        var"##554" = var"##553"[2]
                                                                        var"##554" == QuoteNode(Symbol("@doc"))
                                                                    end && begin
                                                                        var"##555" = var"##549"[2]
                                                                        var"##556" = var"##549"[3]
                                                                        var"##557" = var"##549"[4]
                                                                        true
                                                                    end))))))))))
                        line = var"##555"
                        expr = var"##557"
                        doc = var"##556"
                        var"##return#532" = begin
                                return (line, doc, expr)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#533#562")))
                    end
                    if begin
                                var"##558" = (var"##cache#535").value
                                var"##558" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##558"[1] == :block && (begin
                                        var"##559" = var"##558"[2]
                                        var"##559" isa AbstractArray
                                    end && (length(var"##559") === 2 && (begin
                                                var"##560" = var"##559"[1]
                                                var"##560" isa LineNumberNode
                                            end && begin
                                                var"##561" = var"##559"[2]
                                                true
                                            end))))
                        stmt = var"##561"
                        var"##return#532" = begin
                                (line, doc, expr) = split_doc(stmt)
                                return (line, doc, expr)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#533#562")))
                    end
                end
                begin
                    var"##return#532" = begin
                            return (nothing, nothing, ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#533#562")))
                end
                error("matching non-exhaustive, at #= none:7 =#")
                $(Expr(:symboliclabel, Symbol("####final#533#562")))
                var"##return#532"
            end
        end
    #= none:24 =# Core.@doc "    split_function(ex::Expr) -> head, call, body\n\nSplit function head declaration with function body.\n" function split_function(ex::Expr; source = nothing)
            let
                begin
                    var"##cache#566" = nothing
                end
                var"##return#563" = nothing
                var"##565" = ex
                if var"##565" isa Expr
                    if begin
                                if var"##cache#566" === nothing
                                    var"##cache#566" = Some(((var"##565").head, (var"##565").args))
                                end
                                var"##567" = (var"##cache#566").value
                                var"##567" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##567"[1] == :function && (begin
                                        var"##568" = var"##567"[2]
                                        var"##568" isa AbstractArray
                                    end && (length(var"##568") === 2 && begin
                                            var"##569" = var"##568"[1]
                                            var"##570" = var"##568"[2]
                                            true
                                        end)))
                        var"##return#563" = let call = var"##569", body = var"##570"
                                (:function, call, body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#564#579")))
                    end
                    if begin
                                var"##571" = (var"##cache#566").value
                                var"##571" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##571"[1] == :(=) && (begin
                                        var"##572" = var"##571"[2]
                                        var"##572" isa AbstractArray
                                    end && (length(var"##572") === 2 && begin
                                            var"##573" = var"##572"[1]
                                            var"##574" = var"##572"[2]
                                            true
                                        end)))
                        var"##return#563" = let call = var"##573", body = var"##574"
                                (:(=), call, body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#564#579")))
                    end
                    if begin
                                var"##575" = (var"##cache#566").value
                                var"##575" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##575"[1] == :-> && (begin
                                        var"##576" = var"##575"[2]
                                        var"##576" isa AbstractArray
                                    end && (length(var"##576") === 2 && begin
                                            var"##577" = var"##576"[1]
                                            var"##578" = var"##576"[2]
                                            true
                                        end)))
                        var"##return#563" = let call = var"##577", body = var"##578"
                                (:->, call, body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#564#579")))
                    end
                end
                begin
                    var"##return#563" = let
                            throw(SyntaxError("expect a function expr, got $(ex)", source))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#564#579")))
                end
                error("matching non-exhaustive, at #= none:30 =#")
                $(Expr(:symboliclabel, Symbol("####final#564#579")))
                var"##return#563"
            end
        end
    #= none:38 =# Core.@doc "    split_function_head(ex::Expr) -> name, args, kw, whereparams, rettype\n\nSplit function head to name, arguments, keyword arguments and where parameters.\n" function split_function_head(ex::Expr; source = nothing)
            let
                begin
                    var"##cache#583" = nothing
                end
                var"##return#580" = nothing
                var"##582" = ex
                if var"##582" isa Expr
                    if begin
                                if var"##cache#583" === nothing
                                    var"##cache#583" = Some(((var"##582").head, (var"##582").args))
                                end
                                var"##584" = (var"##cache#583").value
                                var"##584" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##584"[1] == :tuple && (begin
                                        var"##585" = var"##584"[2]
                                        var"##585" isa AbstractArray
                                    end && ((ndims(var"##585") === 1 && length(var"##585") >= 1) && (begin
                                                begin
                                                    var"##cache#587" = nothing
                                                end
                                                var"##586" = var"##585"[1]
                                                var"##586" isa Expr
                                            end && (begin
                                                    if var"##cache#587" === nothing
                                                        var"##cache#587" = Some(((var"##586").head, (var"##586").args))
                                                    end
                                                    var"##588" = (var"##cache#587").value
                                                    var"##588" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##588"[1] == :parameters && (begin
                                                            var"##589" = var"##588"[2]
                                                            var"##589" isa AbstractArray
                                                        end && ((ndims(var"##589") === 1 && length(var"##589") >= 0) && begin
                                                                var"##590" = SubArray(var"##589", (1:length(var"##589"),))
                                                                var"##591" = SubArray(var"##585", (2:length(var"##585"),))
                                                                true
                                                            end))))))))
                        var"##return#580" = let args = var"##591", kw = var"##590"
                                (nothing, args, kw, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#581#631")))
                    end
                    if begin
                                var"##592" = (var"##cache#583").value
                                var"##592" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##592"[1] == :tuple && (begin
                                        var"##593" = var"##592"[2]
                                        var"##593" isa AbstractArray
                                    end && ((ndims(var"##593") === 1 && length(var"##593") >= 0) && begin
                                            var"##594" = SubArray(var"##593", (1:length(var"##593"),))
                                            true
                                        end)))
                        var"##return#580" = let args = var"##594"
                                (nothing, args, nothing, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#581#631")))
                    end
                    if begin
                                var"##595" = (var"##cache#583").value
                                var"##595" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##595"[1] == :call && (begin
                                        var"##596" = var"##595"[2]
                                        var"##596" isa AbstractArray
                                    end && ((ndims(var"##596") === 1 && length(var"##596") >= 2) && (begin
                                                var"##597" = var"##596"[1]
                                                begin
                                                    var"##cache#599" = nothing
                                                end
                                                var"##598" = var"##596"[2]
                                                var"##598" isa Expr
                                            end && (begin
                                                    if var"##cache#599" === nothing
                                                        var"##cache#599" = Some(((var"##598").head, (var"##598").args))
                                                    end
                                                    var"##600" = (var"##cache#599").value
                                                    var"##600" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##600"[1] == :parameters && (begin
                                                            var"##601" = var"##600"[2]
                                                            var"##601" isa AbstractArray
                                                        end && ((ndims(var"##601") === 1 && length(var"##601") >= 0) && begin
                                                                var"##602" = SubArray(var"##601", (1:length(var"##601"),))
                                                                var"##603" = SubArray(var"##596", (3:length(var"##596"),))
                                                                true
                                                            end))))))))
                        var"##return#580" = let name = var"##597", args = var"##603", kw = var"##602"
                                (name, args, kw, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#581#631")))
                    end
                    if begin
                                var"##604" = (var"##cache#583").value
                                var"##604" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##604"[1] == :call && (begin
                                        var"##605" = var"##604"[2]
                                        var"##605" isa AbstractArray
                                    end && ((ndims(var"##605") === 1 && length(var"##605") >= 1) && begin
                                            var"##606" = var"##605"[1]
                                            var"##607" = SubArray(var"##605", (2:length(var"##605"),))
                                            true
                                        end)))
                        var"##return#580" = let name = var"##606", args = var"##607"
                                (name, args, nothing, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#581#631")))
                    end
                    if begin
                                var"##608" = (var"##cache#583").value
                                var"##608" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##608"[1] == :block && (begin
                                        var"##609" = var"##608"[2]
                                        var"##609" isa AbstractArray
                                    end && (length(var"##609") === 3 && (begin
                                                var"##610" = var"##609"[1]
                                                var"##611" = var"##609"[2]
                                                var"##611" isa LineNumberNode
                                            end && (begin
                                                    begin
                                                        var"##cache#613" = nothing
                                                    end
                                                    var"##612" = var"##609"[3]
                                                    var"##612" isa Expr
                                                end && (begin
                                                        if var"##cache#613" === nothing
                                                            var"##cache#613" = Some(((var"##612").head, (var"##612").args))
                                                        end
                                                        var"##614" = (var"##cache#613").value
                                                        var"##614" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                    end && (var"##614"[1] == :(=) && (begin
                                                                var"##615" = var"##614"[2]
                                                                var"##615" isa AbstractArray
                                                            end && (length(var"##615") === 2 && begin
                                                                    var"##616" = var"##615"[1]
                                                                    var"##617" = var"##615"[2]
                                                                    true
                                                                end)))))))))
                        var"##return#580" = let value = var"##617", kw = var"##616", x = var"##610"
                                (nothing, Any[x], Any[Expr(:kw, kw, value)], nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#581#631")))
                    end
                    if begin
                                var"##618" = (var"##cache#583").value
                                var"##618" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##618"[1] == :block && (begin
                                        var"##619" = var"##618"[2]
                                        var"##619" isa AbstractArray
                                    end && (length(var"##619") === 3 && (begin
                                                var"##620" = var"##619"[1]
                                                var"##621" = var"##619"[2]
                                                var"##621" isa LineNumberNode
                                            end && begin
                                                var"##622" = var"##619"[3]
                                                true
                                            end))))
                        var"##return#580" = let kw = var"##622", x = var"##620"
                                (nothing, Any[x], Any[kw], nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#581#631")))
                    end
                    if begin
                                var"##623" = (var"##cache#583").value
                                var"##623" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##623"[1] == :(::) && (begin
                                        var"##624" = var"##623"[2]
                                        var"##624" isa AbstractArray
                                    end && (length(var"##624") === 2 && begin
                                            var"##625" = var"##624"[1]
                                            var"##626" = var"##624"[2]
                                            true
                                        end)))
                        var"##return#580" = let call = var"##625", rettype = var"##626"
                                (name, args, kw, whereparams, _) = split_function_head(call)
                                (name, args, kw, whereparams, rettype)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#581#631")))
                    end
                    if begin
                                var"##627" = (var"##cache#583").value
                                var"##627" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##627"[1] == :where && (begin
                                        var"##628" = var"##627"[2]
                                        var"##628" isa AbstractArray
                                    end && ((ndims(var"##628") === 1 && length(var"##628") >= 1) && begin
                                            var"##629" = var"##628"[1]
                                            var"##630" = SubArray(var"##628", (2:length(var"##628"),))
                                            true
                                        end)))
                        var"##return#580" = let call = var"##629", whereparams = var"##630"
                                (name, args, kw, _, rettype) = split_function_head(call)
                                (name, args, kw, whereparams, rettype)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#581#631")))
                    end
                end
                begin
                    var"##return#580" = let
                            throw(SyntaxError("expect a function head, got $(ex)", source))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#581#631")))
                end
                error("matching non-exhaustive, at #= none:44 =#")
                $(Expr(:symboliclabel, Symbol("####final#581#631")))
                var"##return#580"
            end
        end
    #= none:63 =# Core.@doc "    split_struct_name(ex::Expr) -> name, typevars, supertype\n\nSplit the name, type parameters and supertype definition from `struct`\ndeclaration head.\n" function split_struct_name(#= none:69 =# @nospecialize(ex); source = nothing)
            return let
                    begin
                        var"##cache#635" = nothing
                    end
                    var"##return#632" = nothing
                    var"##634" = ex
                    if var"##634" isa Expr
                        if begin
                                    if var"##cache#635" === nothing
                                        var"##cache#635" = Some(((var"##634").head, (var"##634").args))
                                    end
                                    var"##636" = (var"##cache#635").value
                                    var"##636" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##636"[1] == :curly && (begin
                                            var"##637" = var"##636"[2]
                                            var"##637" isa AbstractArray
                                        end && ((ndims(var"##637") === 1 && length(var"##637") >= 1) && begin
                                                var"##638" = var"##637"[1]
                                                var"##639" = SubArray(var"##637", (2:length(var"##637"),))
                                                true
                                            end)))
                            var"##return#632" = let typevars = var"##639", name = var"##638"
                                    (name, typevars, nothing)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#633#653")))
                        end
                        if begin
                                    var"##640" = (var"##cache#635").value
                                    var"##640" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##640"[1] == :<: && (begin
                                            var"##641" = var"##640"[2]
                                            var"##641" isa AbstractArray
                                        end && (length(var"##641") === 2 && (begin
                                                    begin
                                                        var"##cache#643" = nothing
                                                    end
                                                    var"##642" = var"##641"[1]
                                                    var"##642" isa Expr
                                                end && (begin
                                                        if var"##cache#643" === nothing
                                                            var"##cache#643" = Some(((var"##642").head, (var"##642").args))
                                                        end
                                                        var"##644" = (var"##cache#643").value
                                                        var"##644" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                    end && (var"##644"[1] == :curly && (begin
                                                                var"##645" = var"##644"[2]
                                                                var"##645" isa AbstractArray
                                                            end && ((ndims(var"##645") === 1 && length(var"##645") >= 1) && begin
                                                                    var"##646" = var"##645"[1]
                                                                    var"##647" = SubArray(var"##645", (2:length(var"##645"),))
                                                                    var"##648" = var"##641"[2]
                                                                    true
                                                                end))))))))
                            var"##return#632" = let typevars = var"##647", type = var"##648", name = var"##646"
                                    (name, typevars, type)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#633#653")))
                        end
                        if begin
                                    var"##649" = (var"##cache#635").value
                                    var"##649" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##649"[1] == :<: && (begin
                                            var"##650" = var"##649"[2]
                                            var"##650" isa AbstractArray
                                        end && (length(var"##650") === 2 && begin
                                                var"##651" = var"##650"[1]
                                                var"##652" = var"##650"[2]
                                                true
                                            end)))
                            var"##return#632" = let type = var"##652", name = var"##651"
                                    (name, [], type)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#633#653")))
                        end
                    end
                    if var"##634" isa Symbol
                        begin
                            var"##return#632" = let
                                    (ex, [], nothing)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#633#653")))
                        end
                    end
                    begin
                        var"##return#632" = let
                                throw(SyntaxError("expect struct got $(ex)", source))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#633#653")))
                    end
                    error("matching non-exhaustive, at #= none:70 =#")
                    $(Expr(:symboliclabel, Symbol("####final#633#653")))
                    var"##return#632"
                end
        end
    #= none:79 =# Core.@doc "    split_struct(ex::Expr) -> ismutable, name, typevars, supertype, body\n\nSplit struct definition head and body.\n" function split_struct(ex::Expr; source = nothing)
            ex.head === :struct || throw(SyntaxError("expect a struct expr, got $(ex)", source))
            (name, typevars, supertype) = split_struct_name(ex.args[2]; source)
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
    #= none:161 =# Core.@doc "    split_field_if_match(typename::Symbol, expr, default::Bool=false)\n\nSplit the field definition if it matches the given type name.\nReturns `NamedTuple` with `name`, `type`, `default` and `isconst` fields\nif it matches, otherwise return `nothing`.\n" function split_field_if_match(typename::Symbol, expr, default::Bool = false; source = nothing)
            begin
                begin
                    var"##cache#657" = nothing
                end
                var"##656" = expr
                if var"##656" isa Expr
                    if begin
                                if var"##cache#657" === nothing
                                    var"##cache#657" = Some(((var"##656").head, (var"##656").args))
                                end
                                var"##658" = (var"##cache#657").value
                                var"##658" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##658"[1] == :const && (begin
                                        var"##659" = var"##658"[2]
                                        var"##659" isa AbstractArray
                                    end && (length(var"##659") === 1 && (begin
                                                begin
                                                    var"##cache#661" = nothing
                                                end
                                                var"##660" = var"##659"[1]
                                                var"##660" isa Expr
                                            end && (begin
                                                    if var"##cache#661" === nothing
                                                        var"##cache#661" = Some(((var"##660").head, (var"##660").args))
                                                    end
                                                    var"##662" = (var"##cache#661").value
                                                    var"##662" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##662"[1] == :(=) && (begin
                                                            var"##663" = var"##662"[2]
                                                            var"##663" isa AbstractArray
                                                        end && (length(var"##663") === 2 && (begin
                                                                    begin
                                                                        var"##cache#665" = nothing
                                                                    end
                                                                    var"##664" = var"##663"[1]
                                                                    var"##664" isa Expr
                                                                end && (begin
                                                                        if var"##cache#665" === nothing
                                                                            var"##cache#665" = Some(((var"##664").head, (var"##664").args))
                                                                        end
                                                                        var"##666" = (var"##cache#665").value
                                                                        var"##666" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                    end && (var"##666"[1] == :(::) && (begin
                                                                                var"##667" = var"##666"[2]
                                                                                var"##667" isa AbstractArray
                                                                            end && (length(var"##667") === 2 && (begin
                                                                                        var"##668" = var"##667"[1]
                                                                                        var"##668" isa Symbol
                                                                                    end && begin
                                                                                        var"##669" = var"##667"[2]
                                                                                        var"##670" = var"##663"[2]
                                                                                        true
                                                                                    end))))))))))))))
                        value = var"##670"
                        type = var"##669"
                        name = var"##668"
                        var"##return#654" = begin
                                default && return (; name, type, isconst = true, default = value)
                                throw(SyntaxError("default value syntax is not allowed", source))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#655#707")))
                    end
                    if begin
                                var"##671" = (var"##cache#657").value
                                var"##671" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##671"[1] == :const && (begin
                                        var"##672" = var"##671"[2]
                                        var"##672" isa AbstractArray
                                    end && (length(var"##672") === 1 && (begin
                                                begin
                                                    var"##cache#674" = nothing
                                                end
                                                var"##673" = var"##672"[1]
                                                var"##673" isa Expr
                                            end && (begin
                                                    if var"##cache#674" === nothing
                                                        var"##cache#674" = Some(((var"##673").head, (var"##673").args))
                                                    end
                                                    var"##675" = (var"##cache#674").value
                                                    var"##675" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##675"[1] == :(=) && (begin
                                                            var"##676" = var"##675"[2]
                                                            var"##676" isa AbstractArray
                                                        end && (length(var"##676") === 2 && (begin
                                                                    var"##677" = var"##676"[1]
                                                                    var"##677" isa Symbol
                                                                end && begin
                                                                    var"##678" = var"##676"[2]
                                                                    true
                                                                end)))))))))
                        value = var"##678"
                        name = var"##677"
                        var"##return#654" = begin
                                default && return (; name, type = Any, isconst = true, default = value)
                                throw(SyntaxError("default value syntax is not allowed", source))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#655#707")))
                    end
                    if begin
                                var"##679" = (var"##cache#657").value
                                var"##679" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##679"[1] == :(=) && (begin
                                        var"##680" = var"##679"[2]
                                        var"##680" isa AbstractArray
                                    end && (length(var"##680") === 2 && (begin
                                                begin
                                                    var"##cache#682" = nothing
                                                end
                                                var"##681" = var"##680"[1]
                                                var"##681" isa Expr
                                            end && (begin
                                                    if var"##cache#682" === nothing
                                                        var"##cache#682" = Some(((var"##681").head, (var"##681").args))
                                                    end
                                                    var"##683" = (var"##cache#682").value
                                                    var"##683" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##683"[1] == :(::) && (begin
                                                            var"##684" = var"##683"[2]
                                                            var"##684" isa AbstractArray
                                                        end && (length(var"##684") === 2 && (begin
                                                                    var"##685" = var"##684"[1]
                                                                    var"##685" isa Symbol
                                                                end && begin
                                                                    var"##686" = var"##684"[2]
                                                                    var"##687" = var"##680"[2]
                                                                    true
                                                                end)))))))))
                        value = var"##687"
                        type = var"##686"
                        name = var"##685"
                        var"##return#654" = begin
                                default && return (; name, type, isconst = false, default = value)
                                throw(SyntaxError("default value syntax is not allowed", source))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#655#707")))
                    end
                    if begin
                                var"##688" = (var"##cache#657").value
                                var"##688" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##688"[1] == :(=) && (begin
                                        var"##689" = var"##688"[2]
                                        var"##689" isa AbstractArray
                                    end && (length(var"##689") === 2 && (begin
                                                var"##690" = var"##689"[1]
                                                var"##690" isa Symbol
                                            end && begin
                                                var"##691" = var"##689"[2]
                                                true
                                            end))))
                        value = var"##691"
                        name = var"##690"
                        var"##return#654" = begin
                                default && return (; name, type = Any, isconst = false, default = value)
                                throw(SyntaxError("default value syntax is not allowed", source))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#655#707")))
                    end
                    if begin
                                var"##692" = (var"##cache#657").value
                                var"##692" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##692"[1] == :const && (begin
                                        var"##693" = var"##692"[2]
                                        var"##693" isa AbstractArray
                                    end && (length(var"##693") === 1 && (begin
                                                begin
                                                    var"##cache#695" = nothing
                                                end
                                                var"##694" = var"##693"[1]
                                                var"##694" isa Expr
                                            end && (begin
                                                    if var"##cache#695" === nothing
                                                        var"##cache#695" = Some(((var"##694").head, (var"##694").args))
                                                    end
                                                    var"##696" = (var"##cache#695").value
                                                    var"##696" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##696"[1] == :(::) && (begin
                                                            var"##697" = var"##696"[2]
                                                            var"##697" isa AbstractArray
                                                        end && (length(var"##697") === 2 && (begin
                                                                    var"##698" = var"##697"[1]
                                                                    var"##698" isa Symbol
                                                                end && begin
                                                                    var"##699" = var"##697"[2]
                                                                    true
                                                                end)))))))))
                        type = var"##699"
                        name = var"##698"
                        var"##return#654" = begin
                                default && return (; name, type, isconst = true, default = no_default)
                                return (; name, type, isconst = true)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#655#707")))
                    end
                    if begin
                                var"##700" = (var"##cache#657").value
                                var"##700" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##700"[1] == :const && (begin
                                        var"##701" = var"##700"[2]
                                        var"##701" isa AbstractArray
                                    end && (length(var"##701") === 1 && begin
                                            var"##702" = var"##701"[1]
                                            var"##702" isa Symbol
                                        end)))
                        name = var"##702"
                        var"##return#654" = begin
                                default && return (; name, type = Any, isconst = true, default = no_default)
                                return (; name, type = Any, isconst = true)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#655#707")))
                    end
                    if begin
                                var"##703" = (var"##cache#657").value
                                var"##703" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##703"[1] == :(::) && (begin
                                        var"##704" = var"##703"[2]
                                        var"##704" isa AbstractArray
                                    end && (length(var"##704") === 2 && (begin
                                                var"##705" = var"##704"[1]
                                                var"##705" isa Symbol
                                            end && begin
                                                var"##706" = var"##704"[2]
                                                true
                                            end))))
                        type = var"##706"
                        name = var"##705"
                        var"##return#654" = begin
                                default && return (; name, type, isconst = false, default = no_default)
                                return (; name, type, isconst = false)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#655#707")))
                    end
                end
                if var"##656" isa Symbol
                    begin
                        name = var"##656"
                        var"##return#654" = begin
                                default && return (; name, type = Any, isconst = false, default = no_default)
                                return (; name, type = Any, isconst = false)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#655#707")))
                    end
                end
                if var"##656" isa String
                    begin
                        var"##return#654" = begin
                                return expr
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#655#707")))
                    end
                end
                if var"##656" isa LineNumberNode
                    begin
                        var"##return#654" = begin
                                return expr
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#655#707")))
                    end
                end
                if is_function(expr)
                    var"##return#654" = begin
                            if name_only(expr) === typename
                                return JLFunction(expr)
                            else
                                return expr
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#655#707")))
                end
                begin
                    var"##return#654" = begin
                            return expr
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#655#707")))
                end
                error("matching non-exhaustive, at #= none:169 =#")
                $(Expr(:symboliclabel, Symbol("####final#655#707")))
                var"##return#654"
            end
        end
