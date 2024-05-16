
    #= none:1 =# Core.@doc "    split_doc(ex::Expr) -> line, doc, expr\n\nSplit doc string from given expression.\n" function split_doc(ex::Expr)
            begin
                begin
                    var"##cache#501" = nothing
                end
                var"##500" = ex
                if var"##500" isa Expr
                    if begin
                                if var"##cache#501" === nothing
                                    var"##cache#501" = Some(((var"##500").head, (var"##500").args))
                                end
                                var"##502" = (var"##cache#501").value
                                var"##502" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##502"[1] == :macrocall && (begin
                                        var"##503" = var"##502"[2]
                                        var"##503" isa AbstractArray
                                    end && (length(var"##503") === 4 && (begin
                                                var"##504" = var"##503"[1]
                                                var"##504" == GlobalRef(Core, Symbol("@doc"))
                                            end && begin
                                                var"##505" = var"##503"[2]
                                                var"##506" = var"##503"[3]
                                                var"##507" = var"##503"[4]
                                                true
                                            end))))
                        line = var"##505"
                        expr = var"##507"
                        doc = var"##506"
                        var"##return#498" = begin
                                return (line, doc, expr)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#499#528")))
                    end
                    if begin
                                var"##508" = (var"##cache#501").value
                                var"##508" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##508"[1] == :macrocall && (begin
                                        var"##509" = var"##508"[2]
                                        var"##509" isa AbstractArray
                                    end && (length(var"##509") === 4 && (begin
                                                var"##510" = var"##509"[1]
                                                var"##510" == Symbol("@doc")
                                            end && begin
                                                var"##511" = var"##509"[2]
                                                var"##512" = var"##509"[3]
                                                var"##513" = var"##509"[4]
                                                true
                                            end))))
                        line = var"##511"
                        expr = var"##513"
                        doc = var"##512"
                        var"##return#498" = begin
                                return (line, doc, expr)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#499#528")))
                    end
                    if begin
                                var"##514" = (var"##cache#501").value
                                var"##514" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##514"[1] == :macrocall && (begin
                                        var"##515" = var"##514"[2]
                                        var"##515" isa AbstractArray
                                    end && (length(var"##515") === 4 && (begin
                                                begin
                                                    var"##cache#517" = nothing
                                                end
                                                var"##516" = var"##515"[1]
                                                var"##516" isa Expr
                                            end && (begin
                                                    if var"##cache#517" === nothing
                                                        var"##cache#517" = Some(((var"##516").head, (var"##516").args))
                                                    end
                                                    var"##518" = (var"##cache#517").value
                                                    var"##518" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##518"[1] == :. && (begin
                                                            var"##519" = var"##518"[2]
                                                            var"##519" isa AbstractArray
                                                        end && (length(var"##519") === 2 && (var"##519"[1] == :Core && (begin
                                                                        var"##520" = var"##519"[2]
                                                                        var"##520" == QuoteNode(Symbol("@doc"))
                                                                    end && begin
                                                                        var"##521" = var"##515"[2]
                                                                        var"##522" = var"##515"[3]
                                                                        var"##523" = var"##515"[4]
                                                                        true
                                                                    end))))))))))
                        line = var"##521"
                        expr = var"##523"
                        doc = var"##522"
                        var"##return#498" = begin
                                return (line, doc, expr)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#499#528")))
                    end
                    if begin
                                var"##524" = (var"##cache#501").value
                                var"##524" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##524"[1] == :block && (begin
                                        var"##525" = var"##524"[2]
                                        var"##525" isa AbstractArray
                                    end && (length(var"##525") === 2 && (begin
                                                var"##526" = var"##525"[1]
                                                var"##526" isa LineNumberNode
                                            end && begin
                                                var"##527" = var"##525"[2]
                                                true
                                            end))))
                        stmt = var"##527"
                        var"##return#498" = begin
                                (line, doc, expr) = split_doc(stmt)
                                return (line, doc, expr)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#499#528")))
                    end
                end
                begin
                    var"##return#498" = begin
                            return (nothing, nothing, ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#499#528")))
                end
                error("matching non-exhaustive, at #= none:7 =#")
                $(Expr(:symboliclabel, Symbol("####final#499#528")))
                var"##return#498"
            end
        end
    #= none:24 =# Core.@doc "    split_function(ex::Expr) -> head, call, body\n\nSplit function head declaration with function body.\n" function split_function(ex::Expr; source = nothing)
            ret = split_function_nothrow(ex)
            isnothing(ret) && throw(SyntaxError("expect a function expr, got $(ex)", source))
            ret
        end
    function split_function_nothrow(ex::Expr)
        let
            begin
                var"##cache#532" = nothing
            end
            var"##return#529" = nothing
            var"##531" = ex
            if var"##531" isa Expr
                if begin
                            if var"##cache#532" === nothing
                                var"##cache#532" = Some(((var"##531").head, (var"##531").args))
                            end
                            var"##533" = (var"##cache#532").value
                            var"##533" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##533"[1] == :function && (begin
                                    var"##534" = var"##533"[2]
                                    var"##534" isa AbstractArray
                                end && (length(var"##534") === 2 && begin
                                        var"##535" = var"##534"[1]
                                        var"##536" = var"##534"[2]
                                        true
                                    end)))
                    var"##return#529" = let call = var"##535", body = var"##536"
                            (:function, call, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#530#549")))
                end
                if begin
                            var"##537" = (var"##cache#532").value
                            var"##537" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##537"[1] == :function && (begin
                                    var"##538" = var"##537"[2]
                                    var"##538" isa AbstractArray
                                end && (length(var"##538") === 2 && begin
                                        var"##539" = var"##538"[1]
                                        var"##540" = var"##538"[2]
                                        true
                                    end)))
                    var"##return#529" = let call = var"##539", body = var"##540"
                            (:function, call, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#530#549")))
                end
                if begin
                            var"##541" = (var"##cache#532").value
                            var"##541" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##541"[1] == :(=) && (begin
                                    var"##542" = var"##541"[2]
                                    var"##542" isa AbstractArray
                                end && (length(var"##542") === 2 && begin
                                        var"##543" = var"##542"[1]
                                        var"##544" = var"##542"[2]
                                        true
                                    end)))
                    var"##return#529" = let call = var"##543", body = var"##544"
                            let
                                begin
                                    var"##cache#553" = nothing
                                end
                                var"##return#550" = nothing
                                var"##552" = call
                                if var"##552" isa Expr
                                    if begin
                                                if var"##cache#553" === nothing
                                                    var"##cache#553" = Some(((var"##552").head, (var"##552").args))
                                                end
                                                var"##554" = (var"##cache#553").value
                                                var"##554" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##554"[1] == :call && (begin
                                                        var"##555" = var"##554"[2]
                                                        var"##555" isa AbstractArray
                                                    end && ((ndims(var"##555") === 1 && length(var"##555") >= 1) && begin
                                                            var"##556" = var"##555"[1]
                                                            var"##557" = SubArray(var"##555", (2:length(var"##555"),))
                                                            true
                                                        end)))
                                        var"##return#550" = let f = var"##556", args = var"##557"
                                                true
                                            end
                                        $(Expr(:symbolicgoto, Symbol("####final#551#590")))
                                    end
                                    if begin
                                                var"##558" = (var"##cache#553").value
                                                var"##558" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##558"[1] == :(::) && (begin
                                                        var"##559" = var"##558"[2]
                                                        var"##559" isa AbstractArray
                                                    end && (length(var"##559") === 2 && (begin
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
                                                                end && (var"##562"[1] == :call && (begin
                                                                            var"##563" = var"##562"[2]
                                                                            var"##563" isa AbstractArray
                                                                        end && ((ndims(var"##563") === 1 && length(var"##563") >= 1) && begin
                                                                                var"##564" = var"##563"[1]
                                                                                var"##565" = SubArray(var"##563", (2:length(var"##563"),))
                                                                                var"##566" = var"##559"[2]
                                                                                true
                                                                            end))))))))
                                        var"##return#550" = let f = var"##564", args = var"##565", rettype = var"##566"
                                                true
                                            end
                                        $(Expr(:symbolicgoto, Symbol("####final#551#590")))
                                    end
                                    if begin
                                                var"##567" = (var"##cache#553").value
                                                var"##567" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##567"[1] == :where && (begin
                                                        var"##568" = var"##567"[2]
                                                        var"##568" isa AbstractArray
                                                    end && ((ndims(var"##568") === 1 && length(var"##568") >= 1) && (begin
                                                                begin
                                                                    var"##cache#570" = nothing
                                                                end
                                                                var"##569" = var"##568"[1]
                                                                var"##569" isa Expr
                                                            end && (begin
                                                                    if var"##cache#570" === nothing
                                                                        var"##cache#570" = Some(((var"##569").head, (var"##569").args))
                                                                    end
                                                                    var"##571" = (var"##cache#570").value
                                                                    var"##571" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##571"[1] == :call && (begin
                                                                            var"##572" = var"##571"[2]
                                                                            var"##572" isa AbstractArray
                                                                        end && ((ndims(var"##572") === 1 && length(var"##572") >= 1) && begin
                                                                                var"##573" = var"##572"[1]
                                                                                var"##574" = SubArray(var"##572", (2:length(var"##572"),))
                                                                                var"##575" = SubArray(var"##568", (2:length(var"##568"),))
                                                                                true
                                                                            end))))))))
                                        var"##return#550" = let f = var"##573", params = var"##575", args = var"##574"
                                                true
                                            end
                                        $(Expr(:symbolicgoto, Symbol("####final#551#590")))
                                    end
                                    if begin
                                                var"##576" = (var"##cache#553").value
                                                var"##576" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##576"[1] == :where && (begin
                                                        var"##577" = var"##576"[2]
                                                        var"##577" isa AbstractArray
                                                    end && ((ndims(var"##577") === 1 && length(var"##577") >= 1) && (begin
                                                                begin
                                                                    var"##cache#579" = nothing
                                                                end
                                                                var"##578" = var"##577"[1]
                                                                var"##578" isa Expr
                                                            end && (begin
                                                                    if var"##cache#579" === nothing
                                                                        var"##cache#579" = Some(((var"##578").head, (var"##578").args))
                                                                    end
                                                                    var"##580" = (var"##cache#579").value
                                                                    var"##580" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##580"[1] == :(::) && (begin
                                                                            var"##581" = var"##580"[2]
                                                                            var"##581" isa AbstractArray
                                                                        end && (length(var"##581") === 2 && (begin
                                                                                    begin
                                                                                        var"##cache#583" = nothing
                                                                                    end
                                                                                    var"##582" = var"##581"[1]
                                                                                    var"##582" isa Expr
                                                                                end && (begin
                                                                                        if var"##cache#583" === nothing
                                                                                            var"##cache#583" = Some(((var"##582").head, (var"##582").args))
                                                                                        end
                                                                                        var"##584" = (var"##cache#583").value
                                                                                        var"##584" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                                    end && (var"##584"[1] == :call && (begin
                                                                                                var"##585" = var"##584"[2]
                                                                                                var"##585" isa AbstractArray
                                                                                            end && ((ndims(var"##585") === 1 && length(var"##585") >= 1) && begin
                                                                                                    var"##586" = var"##585"[1]
                                                                                                    var"##587" = SubArray(var"##585", (2:length(var"##585"),))
                                                                                                    var"##588" = var"##581"[2]
                                                                                                    var"##589" = SubArray(var"##577", (2:length(var"##577"),))
                                                                                                    true
                                                                                                end)))))))))))))
                                        var"##return#550" = let f = var"##586", params = var"##589", args = var"##587", rettype = var"##588"
                                                true
                                            end
                                        $(Expr(:symbolicgoto, Symbol("####final#551#590")))
                                    end
                                end
                                begin
                                    var"##return#550" = let
                                            return nothing
                                        end
                                    $(Expr(:symbolicgoto, Symbol("####final#551#590")))
                                end
                                error("matching non-exhaustive, at #= none:40 =#")
                                $(Expr(:symboliclabel, Symbol("####final#551#590")))
                                var"##return#550"
                            end
                            (:(=), call, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#530#549")))
                end
                if begin
                            var"##545" = (var"##cache#532").value
                            var"##545" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##545"[1] == :-> && (begin
                                    var"##546" = var"##545"[2]
                                    var"##546" isa AbstractArray
                                end && (length(var"##546") === 2 && begin
                                        var"##547" = var"##546"[1]
                                        var"##548" = var"##546"[2]
                                        true
                                    end)))
                    var"##return#529" = let call = var"##547", body = var"##548"
                            (:->, call, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#530#549")))
                end
            end
            begin
                var"##return#529" = let
                        nothing
                    end
                $(Expr(:symbolicgoto, Symbol("####final#530#549")))
            end
            error("matching non-exhaustive, at #= none:36 =#")
            $(Expr(:symboliclabel, Symbol("####final#530#549")))
            var"##return#529"
        end
    end
    #= none:54 =# Core.@doc "    split_function_head(ex::Expr) -> name, args, kw, whereparams, rettype\n\nSplit function head to name, arguments, keyword arguments and where parameters.\n" function split_function_head(ex::Expr; source = nothing)
            split_head_tuple = split_function_head_nothrow(ex)
            isnothing(split_head_tuple) && throw(SyntaxError("expect a function head, got $(ex)", source))
            split_head_tuple
        end
    function split_function_head_nothrow(ex::Expr)
        let
            begin
                var"##cache#594" = nothing
            end
            var"##return#591" = nothing
            var"##593" = ex
            if var"##593" isa Expr
                if begin
                            if var"##cache#594" === nothing
                                var"##cache#594" = Some(((var"##593").head, (var"##593").args))
                            end
                            var"##595" = (var"##cache#594").value
                            var"##595" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##595"[1] == :tuple && (begin
                                    var"##596" = var"##595"[2]
                                    var"##596" isa AbstractArray
                                end && ((ndims(var"##596") === 1 && length(var"##596") >= 1) && (begin
                                            begin
                                                var"##cache#598" = nothing
                                            end
                                            var"##597" = var"##596"[1]
                                            var"##597" isa Expr
                                        end && (begin
                                                if var"##cache#598" === nothing
                                                    var"##cache#598" = Some(((var"##597").head, (var"##597").args))
                                                end
                                                var"##599" = (var"##cache#598").value
                                                var"##599" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##599"[1] == :parameters && (begin
                                                        var"##600" = var"##599"[2]
                                                        var"##600" isa AbstractArray
                                                    end && ((ndims(var"##600") === 1 && length(var"##600") >= 0) && begin
                                                            var"##601" = SubArray(var"##600", (1:length(var"##600"),))
                                                            var"##602" = SubArray(var"##596", (2:length(var"##596"),))
                                                            true
                                                        end))))))))
                    var"##return#591" = let args = var"##602", kw = var"##601"
                            (nothing, args, kw, nothing, nothing)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#592#642")))
                end
                if begin
                            var"##603" = (var"##cache#594").value
                            var"##603" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##603"[1] == :tuple && (begin
                                    var"##604" = var"##603"[2]
                                    var"##604" isa AbstractArray
                                end && ((ndims(var"##604") === 1 && length(var"##604") >= 0) && begin
                                        var"##605" = SubArray(var"##604", (1:length(var"##604"),))
                                        true
                                    end)))
                    var"##return#591" = let args = var"##605"
                            (nothing, args, nothing, nothing, nothing)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#592#642")))
                end
                if begin
                            var"##606" = (var"##cache#594").value
                            var"##606" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##606"[1] == :call && (begin
                                    var"##607" = var"##606"[2]
                                    var"##607" isa AbstractArray
                                end && ((ndims(var"##607") === 1 && length(var"##607") >= 2) && (begin
                                            var"##608" = var"##607"[1]
                                            begin
                                                var"##cache#610" = nothing
                                            end
                                            var"##609" = var"##607"[2]
                                            var"##609" isa Expr
                                        end && (begin
                                                if var"##cache#610" === nothing
                                                    var"##cache#610" = Some(((var"##609").head, (var"##609").args))
                                                end
                                                var"##611" = (var"##cache#610").value
                                                var"##611" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##611"[1] == :parameters && (begin
                                                        var"##612" = var"##611"[2]
                                                        var"##612" isa AbstractArray
                                                    end && ((ndims(var"##612") === 1 && length(var"##612") >= 0) && begin
                                                            var"##613" = SubArray(var"##612", (1:length(var"##612"),))
                                                            var"##614" = SubArray(var"##607", (3:length(var"##607"),))
                                                            true
                                                        end))))))))
                    var"##return#591" = let name = var"##608", args = var"##614", kw = var"##613"
                            (name, args, kw, nothing, nothing)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#592#642")))
                end
                if begin
                            var"##615" = (var"##cache#594").value
                            var"##615" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##615"[1] == :call && (begin
                                    var"##616" = var"##615"[2]
                                    var"##616" isa AbstractArray
                                end && ((ndims(var"##616") === 1 && length(var"##616") >= 1) && begin
                                        var"##617" = var"##616"[1]
                                        var"##618" = SubArray(var"##616", (2:length(var"##616"),))
                                        true
                                    end)))
                    var"##return#591" = let name = var"##617", args = var"##618"
                            (name, args, nothing, nothing, nothing)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#592#642")))
                end
                if begin
                            var"##619" = (var"##cache#594").value
                            var"##619" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##619"[1] == :block && (begin
                                    var"##620" = var"##619"[2]
                                    var"##620" isa AbstractArray
                                end && (length(var"##620") === 3 && (begin
                                            var"##621" = var"##620"[1]
                                            var"##622" = var"##620"[2]
                                            var"##622" isa LineNumberNode
                                        end && (begin
                                                begin
                                                    var"##cache#624" = nothing
                                                end
                                                var"##623" = var"##620"[3]
                                                var"##623" isa Expr
                                            end && (begin
                                                    if var"##cache#624" === nothing
                                                        var"##cache#624" = Some(((var"##623").head, (var"##623").args))
                                                    end
                                                    var"##625" = (var"##cache#624").value
                                                    var"##625" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##625"[1] == :(=) && (begin
                                                            var"##626" = var"##625"[2]
                                                            var"##626" isa AbstractArray
                                                        end && (length(var"##626") === 2 && begin
                                                                var"##627" = var"##626"[1]
                                                                var"##628" = var"##626"[2]
                                                                true
                                                            end)))))))))
                    var"##return#591" = let value = var"##628", kw = var"##627", x = var"##621"
                            (nothing, Any[x], Any[Expr(:kw, kw, value)], nothing, nothing)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#592#642")))
                end
                if begin
                            var"##629" = (var"##cache#594").value
                            var"##629" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##629"[1] == :block && (begin
                                    var"##630" = var"##629"[2]
                                    var"##630" isa AbstractArray
                                end && (length(var"##630") === 3 && (begin
                                            var"##631" = var"##630"[1]
                                            var"##632" = var"##630"[2]
                                            var"##632" isa LineNumberNode
                                        end && begin
                                            var"##633" = var"##630"[3]
                                            true
                                        end))))
                    var"##return#591" = let kw = var"##633", x = var"##631"
                            (nothing, Any[x], Any[kw], nothing, nothing)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#592#642")))
                end
                if begin
                            var"##634" = (var"##cache#594").value
                            var"##634" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##634"[1] == :(::) && (begin
                                    var"##635" = var"##634"[2]
                                    var"##635" isa AbstractArray
                                end && (length(var"##635") === 2 && (begin
                                            var"##636" = var"##635"[1]
                                            var"##636" isa Expr
                                        end && begin
                                            var"##637" = var"##635"[2]
                                            true
                                        end))))
                    var"##return#591" = let call = var"##636", rettype = var"##637"
                            sub_tuple = split_function_head_nothrow(call)
                            isnothing(sub_tuple) && return nothing
                            (name, args, kw, whereparams, _) = split_function_head_nothrow(call)
                            (name, args, kw, whereparams, rettype)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#592#642")))
                end
                if begin
                            var"##638" = (var"##cache#594").value
                            var"##638" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##638"[1] == :where && (begin
                                    var"##639" = var"##638"[2]
                                    var"##639" isa AbstractArray
                                end && ((ndims(var"##639") === 1 && length(var"##639") >= 1) && begin
                                        var"##640" = var"##639"[1]
                                        var"##641" = SubArray(var"##639", (2:length(var"##639"),))
                                        true
                                    end)))
                    var"##return#591" = let call = var"##640", whereparams = var"##641"
                            sub_tuple = split_function_head_nothrow(call)
                            isnothing(sub_tuple) && return nothing
                            (name, args, kw, _, rettype) = sub_tuple
                            (name, args, kw, whereparams, rettype)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#592#642")))
                end
            end
            begin
                var"##return#591" = let
                        nothing
                    end
                $(Expr(:symbolicgoto, Symbol("####final#592#642")))
            end
            error("matching non-exhaustive, at #= none:66 =#")
            $(Expr(:symboliclabel, Symbol("####final#592#642")))
            var"##return#591"
        end
    end
    split_function_head_nothrow(s::Symbol) = begin
            (nothing, Any[s], nothing, nothing, nothing)
        end
    #= none:90 =# Core.@doc "    split_anonymous_function_head(ex::Expr) -> nothing, args, kw, whereparams, rettype\n\nSplit anonymous function head to arguments, keyword arguments and where parameters.\n" function split_anonymous_function_head(ex::Expr; source = nothing)
            split_head_tuple = split_anonymous_function_head_nothrow(ex)
            isnothing(split_head_tuple) && throw(SyntaxError("expect an anonymous function head, got $(ex)", source))
            split_head_tuple
        end
    split_anonymous_function_head(ex::Symbol; source = nothing) = begin
            split_anonymous_function_head_nothrow(ex)
        end
    function split_anonymous_function_head_nothrow(ex::Expr)
        let
            begin
                var"##cache#646" = nothing
            end
            var"##return#643" = nothing
            var"##645" = ex
            if var"##645" isa Expr
                if begin
                            if var"##cache#646" === nothing
                                var"##cache#646" = Some(((var"##645").head, (var"##645").args))
                            end
                            var"##647" = (var"##cache#646").value
                            var"##647" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##647"[1] == :tuple && (begin
                                    var"##648" = var"##647"[2]
                                    var"##648" isa AbstractArray
                                end && ((ndims(var"##648") === 1 && length(var"##648") >= 1) && (begin
                                            begin
                                                var"##cache#650" = nothing
                                            end
                                            var"##649" = var"##648"[1]
                                            var"##649" isa Expr
                                        end && (begin
                                                if var"##cache#650" === nothing
                                                    var"##cache#650" = Some(((var"##649").head, (var"##649").args))
                                                end
                                                var"##651" = (var"##cache#650").value
                                                var"##651" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##651"[1] == :parameters && (begin
                                                        var"##652" = var"##651"[2]
                                                        var"##652" isa AbstractArray
                                                    end && ((ndims(var"##652") === 1 && length(var"##652") >= 0) && begin
                                                            var"##653" = SubArray(var"##652", (1:length(var"##652"),))
                                                            var"##654" = SubArray(var"##648", (2:length(var"##648"),))
                                                            true
                                                        end))))))))
                    var"##return#643" = let args = var"##654", kw = var"##653"
                            (nothing, args, kw, nothing, nothing)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#644#688")))
                end
                if begin
                            var"##655" = (var"##cache#646").value
                            var"##655" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##655"[1] == :tuple && (begin
                                    var"##656" = var"##655"[2]
                                    var"##656" isa AbstractArray
                                end && ((ndims(var"##656") === 1 && length(var"##656") >= 0) && begin
                                        var"##657" = SubArray(var"##656", (1:length(var"##656"),))
                                        true
                                    end)))
                    var"##return#643" = let args = var"##657"
                            (nothing, args, nothing, nothing, nothing)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#644#688")))
                end
                if begin
                            var"##658" = (var"##cache#646").value
                            var"##658" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##658"[1] == :block && (begin
                                    var"##659" = var"##658"[2]
                                    var"##659" isa AbstractArray
                                end && (length(var"##659") === 3 && (begin
                                            var"##660" = var"##659"[1]
                                            var"##661" = var"##659"[2]
                                            var"##661" isa LineNumberNode
                                        end && (begin
                                                begin
                                                    var"##cache#663" = nothing
                                                end
                                                var"##662" = var"##659"[3]
                                                var"##662" isa Expr
                                            end && (begin
                                                    if var"##cache#663" === nothing
                                                        var"##cache#663" = Some(((var"##662").head, (var"##662").args))
                                                    end
                                                    var"##664" = (var"##cache#663").value
                                                    var"##664" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##664"[1] == :(=) && (begin
                                                            var"##665" = var"##664"[2]
                                                            var"##665" isa AbstractArray
                                                        end && (length(var"##665") === 2 && begin
                                                                var"##666" = var"##665"[1]
                                                                var"##667" = var"##665"[2]
                                                                true
                                                            end)))))))))
                    var"##return#643" = let value = var"##667", kw = var"##666", x = var"##660"
                            (nothing, Any[x], Any[Expr(:kw, kw, value)], nothing, nothing)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#644#688")))
                end
                if begin
                            var"##668" = (var"##cache#646").value
                            var"##668" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##668"[1] == :block && (begin
                                    var"##669" = var"##668"[2]
                                    var"##669" isa AbstractArray
                                end && (length(var"##669") === 3 && (begin
                                            var"##670" = var"##669"[1]
                                            var"##671" = var"##669"[2]
                                            var"##671" isa LineNumberNode
                                        end && begin
                                            var"##672" = var"##669"[3]
                                            true
                                        end))))
                    var"##return#643" = let kw = var"##672", x = var"##670"
                            (nothing, Any[x], Any[kw], nothing, nothing)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#644#688")))
                end
                if begin
                            var"##673" = (var"##cache#646").value
                            var"##673" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##673"[1] == :(::) && (begin
                                    var"##674" = var"##673"[2]
                                    var"##674" isa AbstractArray
                                end && (length(var"##674") === 2 && (begin
                                            var"##675" = var"##674"[1]
                                            var"##675" isa Expr
                                        end && begin
                                            var"##676" = var"##674"[2]
                                            true
                                        end))))
                    var"##return#643" = let rettype = var"##676", fh = var"##675"
                            sub_tuple = split_anonymous_function_head_nothrow(fh)
                            isnothing(sub_tuple) && return nothing
                            (name, args, kw, whereparams, _) = sub_tuple
                            (name, args, kw, whereparams, rettype)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#644#688")))
                end
                if begin
                            var"##677" = (var"##cache#646").value
                            var"##677" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##677"[1] == :(::) && (begin
                                    var"##678" = var"##677"[2]
                                    var"##678" isa AbstractArray
                                end && (length(var"##678") === 2 && (begin
                                            var"##679" = var"##678"[1]
                                            var"##679" isa Symbol
                                        end && begin
                                            var"##680" = var"##678"[2]
                                            true
                                        end))))
                    var"##return#643" = let arg = var"##679", argtype = var"##680"
                            (nothing, Any[ex], nothing, nothing, nothing)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#644#688")))
                end
                if begin
                            var"##681" = (var"##cache#646").value
                            var"##681" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##681"[1] == :(::) && (begin
                                    var"##682" = var"##681"[2]
                                    var"##682" isa AbstractArray
                                end && (length(var"##682") === 1 && begin
                                        var"##683" = var"##682"[1]
                                        true
                                    end)))
                    var"##return#643" = let argtype = var"##683"
                            (nothing, Any[ex], nothing, nothing, nothing)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#644#688")))
                end
                if begin
                            var"##684" = (var"##cache#646").value
                            var"##684" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##684"[1] == :where && (begin
                                    var"##685" = var"##684"[2]
                                    var"##685" isa AbstractArray
                                end && ((ndims(var"##685") === 1 && length(var"##685") >= 1) && begin
                                        var"##686" = var"##685"[1]
                                        var"##687" = SubArray(var"##685", (2:length(var"##685"),))
                                        true
                                    end)))
                    var"##return#643" = let call = var"##686", whereparams = var"##687"
                            sub_tuple = split_anonymous_function_head_nothrow(call)
                            isnothing(sub_tuple) && return nothing
                            (name, args, kw, _, rettype) = sub_tuple
                            (name, args, kw, whereparams, rettype)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#644#688")))
                end
            end
            begin
                var"##return#643" = let
                        nothing
                    end
                $(Expr(:symbolicgoto, Symbol("####final#644#688")))
            end
            error("matching non-exhaustive, at #= none:105 =#")
            $(Expr(:symboliclabel, Symbol("####final#644#688")))
            var"##return#643"
        end
    end
    split_anonymous_function_head_nothrow(s::Symbol) = begin
            (nothing, Any[s], nothing, nothing, nothing)
        end
    #= none:129 =# Core.@doc "    split_struct_name(ex::Expr) -> name, typevars, supertype\n\nSplit the name, type parameters and supertype definition from `struct`\ndeclaration head.\n" function split_struct_name(#= none:135 =# @nospecialize(ex); source = nothing)
            return let
                    begin
                        var"##cache#692" = nothing
                    end
                    var"##return#689" = nothing
                    var"##691" = ex
                    if var"##691" isa Expr
                        if begin
                                    if var"##cache#692" === nothing
                                        var"##cache#692" = Some(((var"##691").head, (var"##691").args))
                                    end
                                    var"##693" = (var"##cache#692").value
                                    var"##693" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##693"[1] == :curly && (begin
                                            var"##694" = var"##693"[2]
                                            var"##694" isa AbstractArray
                                        end && ((ndims(var"##694") === 1 && length(var"##694") >= 1) && begin
                                                var"##695" = var"##694"[1]
                                                var"##696" = SubArray(var"##694", (2:length(var"##694"),))
                                                true
                                            end)))
                            var"##return#689" = let typevars = var"##696", name = var"##695"
                                    (name, typevars, nothing)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#690#710")))
                        end
                        if begin
                                    var"##697" = (var"##cache#692").value
                                    var"##697" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##697"[1] == :<: && (begin
                                            var"##698" = var"##697"[2]
                                            var"##698" isa AbstractArray
                                        end && (length(var"##698") === 2 && (begin
                                                    begin
                                                        var"##cache#700" = nothing
                                                    end
                                                    var"##699" = var"##698"[1]
                                                    var"##699" isa Expr
                                                end && (begin
                                                        if var"##cache#700" === nothing
                                                            var"##cache#700" = Some(((var"##699").head, (var"##699").args))
                                                        end
                                                        var"##701" = (var"##cache#700").value
                                                        var"##701" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                    end && (var"##701"[1] == :curly && (begin
                                                                var"##702" = var"##701"[2]
                                                                var"##702" isa AbstractArray
                                                            end && ((ndims(var"##702") === 1 && length(var"##702") >= 1) && begin
                                                                    var"##703" = var"##702"[1]
                                                                    var"##704" = SubArray(var"##702", (2:length(var"##702"),))
                                                                    var"##705" = var"##698"[2]
                                                                    true
                                                                end))))))))
                            var"##return#689" = let typevars = var"##704", type = var"##705", name = var"##703"
                                    (name, typevars, type)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#690#710")))
                        end
                        if begin
                                    var"##706" = (var"##cache#692").value
                                    var"##706" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##706"[1] == :<: && (begin
                                            var"##707" = var"##706"[2]
                                            var"##707" isa AbstractArray
                                        end && (length(var"##707") === 2 && begin
                                                var"##708" = var"##707"[1]
                                                var"##709" = var"##707"[2]
                                                true
                                            end)))
                            var"##return#689" = let type = var"##709", name = var"##708"
                                    (name, [], type)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#690#710")))
                        end
                    end
                    if var"##691" isa Symbol
                        begin
                            var"##return#689" = let
                                    (ex, [], nothing)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#690#710")))
                        end
                    end
                    begin
                        var"##return#689" = let
                                throw(SyntaxError("expect struct got $(ex)", source))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#690#710")))
                    end
                    error("matching non-exhaustive, at #= none:136 =#")
                    $(Expr(:symboliclabel, Symbol("####final#690#710")))
                    var"##return#689"
                end
        end
    #= none:145 =# Core.@doc "    split_struct(ex::Expr) -> ismutable, name, typevars, supertype, body\n\nSplit struct definition head and body.\n" function split_struct(ex::Expr; source = nothing)
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
    #= none:202 =# Core.@doc "    uninferrable_typevars(def::Union{JLStruct, JLKwStruct}; leading_inferable::Bool=true)\n\nReturn the type variables that are not inferrable in given struct definition.\n" function uninferrable_typevars(def::Union{JLStruct, JLKwStruct}; leading_inferable::Bool = true)
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
    #= none:227 =# Core.@doc "    split_field_if_match(typename::Symbol, expr, default::Bool=false)\n\nSplit the field definition if it matches the given type name.\nReturns `NamedTuple` with `name`, `type`, `default` and `isconst` fields\nif it matches, otherwise return `nothing`.\n" function split_field_if_match(typename::Symbol, expr, default::Bool = false; source = nothing)
            begin
                begin
                    var"##cache#714" = nothing
                end
                var"##713" = expr
                if var"##713" isa Expr
                    if begin
                                if var"##cache#714" === nothing
                                    var"##cache#714" = Some(((var"##713").head, (var"##713").args))
                                end
                                var"##715" = (var"##cache#714").value
                                var"##715" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##715"[1] == :const && (begin
                                        var"##716" = var"##715"[2]
                                        var"##716" isa AbstractArray
                                    end && (length(var"##716") === 1 && (begin
                                                begin
                                                    var"##cache#718" = nothing
                                                end
                                                var"##717" = var"##716"[1]
                                                var"##717" isa Expr
                                            end && (begin
                                                    if var"##cache#718" === nothing
                                                        var"##cache#718" = Some(((var"##717").head, (var"##717").args))
                                                    end
                                                    var"##719" = (var"##cache#718").value
                                                    var"##719" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##719"[1] == :(=) && (begin
                                                            var"##720" = var"##719"[2]
                                                            var"##720" isa AbstractArray
                                                        end && (length(var"##720") === 2 && (begin
                                                                    begin
                                                                        var"##cache#722" = nothing
                                                                    end
                                                                    var"##721" = var"##720"[1]
                                                                    var"##721" isa Expr
                                                                end && (begin
                                                                        if var"##cache#722" === nothing
                                                                            var"##cache#722" = Some(((var"##721").head, (var"##721").args))
                                                                        end
                                                                        var"##723" = (var"##cache#722").value
                                                                        var"##723" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                    end && (var"##723"[1] == :(::) && (begin
                                                                                var"##724" = var"##723"[2]
                                                                                var"##724" isa AbstractArray
                                                                            end && (length(var"##724") === 2 && (begin
                                                                                        var"##725" = var"##724"[1]
                                                                                        var"##725" isa Symbol
                                                                                    end && begin
                                                                                        var"##726" = var"##724"[2]
                                                                                        var"##727" = var"##720"[2]
                                                                                        true
                                                                                    end))))))))))))))
                        value = var"##727"
                        type = var"##726"
                        name = var"##725"
                        var"##return#711" = begin
                                default && return (; name, type, isconst = true, default = value)
                                throw(SyntaxError("default value syntax is not allowed", source))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#712#764")))
                    end
                    if begin
                                var"##728" = (var"##cache#714").value
                                var"##728" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##728"[1] == :const && (begin
                                        var"##729" = var"##728"[2]
                                        var"##729" isa AbstractArray
                                    end && (length(var"##729") === 1 && (begin
                                                begin
                                                    var"##cache#731" = nothing
                                                end
                                                var"##730" = var"##729"[1]
                                                var"##730" isa Expr
                                            end && (begin
                                                    if var"##cache#731" === nothing
                                                        var"##cache#731" = Some(((var"##730").head, (var"##730").args))
                                                    end
                                                    var"##732" = (var"##cache#731").value
                                                    var"##732" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##732"[1] == :(=) && (begin
                                                            var"##733" = var"##732"[2]
                                                            var"##733" isa AbstractArray
                                                        end && (length(var"##733") === 2 && (begin
                                                                    var"##734" = var"##733"[1]
                                                                    var"##734" isa Symbol
                                                                end && begin
                                                                    var"##735" = var"##733"[2]
                                                                    true
                                                                end)))))))))
                        value = var"##735"
                        name = var"##734"
                        var"##return#711" = begin
                                default && return (; name, type = Any, isconst = true, default = value)
                                throw(SyntaxError("default value syntax is not allowed", source))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#712#764")))
                    end
                    if begin
                                var"##736" = (var"##cache#714").value
                                var"##736" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##736"[1] == :(=) && (begin
                                        var"##737" = var"##736"[2]
                                        var"##737" isa AbstractArray
                                    end && (length(var"##737") === 2 && (begin
                                                begin
                                                    var"##cache#739" = nothing
                                                end
                                                var"##738" = var"##737"[1]
                                                var"##738" isa Expr
                                            end && (begin
                                                    if var"##cache#739" === nothing
                                                        var"##cache#739" = Some(((var"##738").head, (var"##738").args))
                                                    end
                                                    var"##740" = (var"##cache#739").value
                                                    var"##740" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##740"[1] == :(::) && (begin
                                                            var"##741" = var"##740"[2]
                                                            var"##741" isa AbstractArray
                                                        end && (length(var"##741") === 2 && (begin
                                                                    var"##742" = var"##741"[1]
                                                                    var"##742" isa Symbol
                                                                end && begin
                                                                    var"##743" = var"##741"[2]
                                                                    var"##744" = var"##737"[2]
                                                                    true
                                                                end)))))))))
                        value = var"##744"
                        type = var"##743"
                        name = var"##742"
                        var"##return#711" = begin
                                default && return (; name, type, isconst = false, default = value)
                                throw(SyntaxError("default value syntax is not allowed", source))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#712#764")))
                    end
                    if begin
                                var"##745" = (var"##cache#714").value
                                var"##745" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##745"[1] == :(=) && (begin
                                        var"##746" = var"##745"[2]
                                        var"##746" isa AbstractArray
                                    end && (length(var"##746") === 2 && (begin
                                                var"##747" = var"##746"[1]
                                                var"##747" isa Symbol
                                            end && begin
                                                var"##748" = var"##746"[2]
                                                true
                                            end))))
                        value = var"##748"
                        name = var"##747"
                        var"##return#711" = begin
                                default && return (; name, type = Any, isconst = false, default = value)
                                throw(SyntaxError("default value syntax is not allowed", source))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#712#764")))
                    end
                    if begin
                                var"##749" = (var"##cache#714").value
                                var"##749" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##749"[1] == :const && (begin
                                        var"##750" = var"##749"[2]
                                        var"##750" isa AbstractArray
                                    end && (length(var"##750") === 1 && (begin
                                                begin
                                                    var"##cache#752" = nothing
                                                end
                                                var"##751" = var"##750"[1]
                                                var"##751" isa Expr
                                            end && (begin
                                                    if var"##cache#752" === nothing
                                                        var"##cache#752" = Some(((var"##751").head, (var"##751").args))
                                                    end
                                                    var"##753" = (var"##cache#752").value
                                                    var"##753" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##753"[1] == :(::) && (begin
                                                            var"##754" = var"##753"[2]
                                                            var"##754" isa AbstractArray
                                                        end && (length(var"##754") === 2 && (begin
                                                                    var"##755" = var"##754"[1]
                                                                    var"##755" isa Symbol
                                                                end && begin
                                                                    var"##756" = var"##754"[2]
                                                                    true
                                                                end)))))))))
                        type = var"##756"
                        name = var"##755"
                        var"##return#711" = begin
                                default && return (; name, type, isconst = true, default = no_default)
                                return (; name, type, isconst = true)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#712#764")))
                    end
                    if begin
                                var"##757" = (var"##cache#714").value
                                var"##757" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##757"[1] == :const && (begin
                                        var"##758" = var"##757"[2]
                                        var"##758" isa AbstractArray
                                    end && (length(var"##758") === 1 && begin
                                            var"##759" = var"##758"[1]
                                            var"##759" isa Symbol
                                        end)))
                        name = var"##759"
                        var"##return#711" = begin
                                default && return (; name, type = Any, isconst = true, default = no_default)
                                return (; name, type = Any, isconst = true)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#712#764")))
                    end
                    if begin
                                var"##760" = (var"##cache#714").value
                                var"##760" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##760"[1] == :(::) && (begin
                                        var"##761" = var"##760"[2]
                                        var"##761" isa AbstractArray
                                    end && (length(var"##761") === 2 && (begin
                                                var"##762" = var"##761"[1]
                                                var"##762" isa Symbol
                                            end && begin
                                                var"##763" = var"##761"[2]
                                                true
                                            end))))
                        type = var"##763"
                        name = var"##762"
                        var"##return#711" = begin
                                default && return (; name, type, isconst = false, default = no_default)
                                return (; name, type, isconst = false)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#712#764")))
                    end
                end
                if var"##713" isa Symbol
                    begin
                        name = var"##713"
                        var"##return#711" = begin
                                default && return (; name, type = Any, isconst = false, default = no_default)
                                return (; name, type = Any, isconst = false)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#712#764")))
                    end
                end
                if var"##713" isa String
                    begin
                        var"##return#711" = begin
                                return expr
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#712#764")))
                    end
                end
                if var"##713" isa LineNumberNode
                    begin
                        var"##return#711" = begin
                                return expr
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#712#764")))
                    end
                end
                if is_function(expr)
                    var"##return#711" = begin
                            if name_only(expr) === typename
                                return JLFunction(expr)
                            else
                                return expr
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#712#764")))
                end
                begin
                    var"##return#711" = begin
                            return expr
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#712#764")))
                end
                error("matching non-exhaustive, at #= none:235 =#")
                $(Expr(:symboliclabel, Symbol("####final#712#764")))
                var"##return#711"
            end
        end
