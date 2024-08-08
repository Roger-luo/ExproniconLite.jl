
    #= none:1 =# Core.@doc "    split_doc(ex::Expr) -> line, doc, expr\n\nSplit doc string from given expression.\n" function split_doc(ex)
            begin
                begin
                    var"##cache#506" = nothing
                end
                var"##505" = ex
                if var"##505" isa Expr
                    if begin
                                if var"##cache#506" === nothing
                                    var"##cache#506" = Some(((var"##505").head, (var"##505").args))
                                end
                                var"##507" = (var"##cache#506").value
                                var"##507" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##507"[1] == :macrocall && (begin
                                        var"##508" = var"##507"[2]
                                        var"##508" isa AbstractArray
                                    end && (length(var"##508") === 4 && (begin
                                                var"##509" = var"##508"[1]
                                                var"##509" == GlobalRef(Core, Symbol("@doc"))
                                            end && begin
                                                var"##510" = var"##508"[2]
                                                var"##511" = var"##508"[3]
                                                var"##512" = var"##508"[4]
                                                true
                                            end))))
                        line = var"##510"
                        expr = var"##512"
                        doc = var"##511"
                        var"##return#503" = begin
                                return (line, doc, expr)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#504#533")))
                    end
                    if begin
                                var"##513" = (var"##cache#506").value
                                var"##513" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##513"[1] == :macrocall && (begin
                                        var"##514" = var"##513"[2]
                                        var"##514" isa AbstractArray
                                    end && (length(var"##514") === 4 && (begin
                                                var"##515" = var"##514"[1]
                                                var"##515" == Symbol("@doc")
                                            end && begin
                                                var"##516" = var"##514"[2]
                                                var"##517" = var"##514"[3]
                                                var"##518" = var"##514"[4]
                                                true
                                            end))))
                        line = var"##516"
                        expr = var"##518"
                        doc = var"##517"
                        var"##return#503" = begin
                                return (line, doc, expr)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#504#533")))
                    end
                    if begin
                                var"##519" = (var"##cache#506").value
                                var"##519" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##519"[1] == :macrocall && (begin
                                        var"##520" = var"##519"[2]
                                        var"##520" isa AbstractArray
                                    end && (length(var"##520") === 4 && (begin
                                                begin
                                                    var"##cache#522" = nothing
                                                end
                                                var"##521" = var"##520"[1]
                                                var"##521" isa Expr
                                            end && (begin
                                                    if var"##cache#522" === nothing
                                                        var"##cache#522" = Some(((var"##521").head, (var"##521").args))
                                                    end
                                                    var"##523" = (var"##cache#522").value
                                                    var"##523" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##523"[1] == :. && (begin
                                                            var"##524" = var"##523"[2]
                                                            var"##524" isa AbstractArray
                                                        end && (length(var"##524") === 2 && (var"##524"[1] == :Core && (begin
                                                                        var"##525" = var"##524"[2]
                                                                        var"##525" == QuoteNode(Symbol("@doc"))
                                                                    end && begin
                                                                        var"##526" = var"##520"[2]
                                                                        var"##527" = var"##520"[3]
                                                                        var"##528" = var"##520"[4]
                                                                        true
                                                                    end))))))))))
                        line = var"##526"
                        expr = var"##528"
                        doc = var"##527"
                        var"##return#503" = begin
                                return (line, doc, expr)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#504#533")))
                    end
                    if begin
                                var"##529" = (var"##cache#506").value
                                var"##529" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##529"[1] == :block && (begin
                                        var"##530" = var"##529"[2]
                                        var"##530" isa AbstractArray
                                    end && (length(var"##530") === 2 && (begin
                                                var"##531" = var"##530"[1]
                                                var"##531" isa LineNumberNode
                                            end && begin
                                                var"##532" = var"##530"[2]
                                                true
                                            end))))
                        stmt = var"##532"
                        var"##return#503" = begin
                                (line, doc, expr) = split_doc(stmt)
                                return (line, doc, expr)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#504#533")))
                    end
                end
                begin
                    var"##return#503" = begin
                            return (nothing, nothing, ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#504#533")))
                end
                error("matching non-exhaustive, at #= none:7 =#")
                $(Expr(:symboliclabel, Symbol("####final#504#533")))
                var"##return#503"
            end
        end
    #= none:24 =# Core.@doc "    split_function(ex::Expr) -> head, call, body\n\nSplit function head declaration with function body.\n" function split_function(ex; source = nothing)
            ret = split_function_nothrow(ex)
            isnothing(ret) && throw(SyntaxError("expect a function expr, got $(ex)", source))
            ret
        end
    function split_function_nothrow(ex)
        let
            begin
                var"##cache#537" = nothing
            end
            var"##return#534" = nothing
            var"##536" = ex
            if var"##536" isa Expr
                if begin
                            if var"##cache#537" === nothing
                                var"##cache#537" = Some(((var"##536").head, (var"##536").args))
                            end
                            var"##538" = (var"##cache#537").value
                            var"##538" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##538"[1] == :function && (begin
                                    var"##539" = var"##538"[2]
                                    var"##539" isa AbstractArray
                                end && (length(var"##539") === 2 && begin
                                        var"##540" = var"##539"[1]
                                        var"##541" = var"##539"[2]
                                        true
                                    end)))
                    var"##return#534" = let call = var"##540", body = var"##541"
                            (:function, call, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#535#554")))
                end
                if begin
                            var"##542" = (var"##cache#537").value
                            var"##542" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##542"[1] == :function && (begin
                                    var"##543" = var"##542"[2]
                                    var"##543" isa AbstractArray
                                end && (length(var"##543") === 2 && begin
                                        var"##544" = var"##543"[1]
                                        var"##545" = var"##543"[2]
                                        true
                                    end)))
                    var"##return#534" = let call = var"##544", body = var"##545"
                            (:function, call, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#535#554")))
                end
                if begin
                            var"##546" = (var"##cache#537").value
                            var"##546" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##546"[1] == :(=) && (begin
                                    var"##547" = var"##546"[2]
                                    var"##547" isa AbstractArray
                                end && (length(var"##547") === 2 && begin
                                        var"##548" = var"##547"[1]
                                        var"##549" = var"##547"[2]
                                        true
                                    end)))
                    var"##return#534" = let call = var"##548", body = var"##549"
                            let
                                begin
                                    var"##cache#558" = nothing
                                end
                                var"##return#555" = nothing
                                var"##557" = call
                                if var"##557" isa Expr
                                    if begin
                                                if var"##cache#558" === nothing
                                                    var"##cache#558" = Some(((var"##557").head, (var"##557").args))
                                                end
                                                var"##559" = (var"##cache#558").value
                                                var"##559" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##559"[1] == :call && (begin
                                                        var"##560" = var"##559"[2]
                                                        var"##560" isa AbstractArray
                                                    end && ((ndims(var"##560") === 1 && length(var"##560") >= 1) && begin
                                                            var"##561" = var"##560"[1]
                                                            var"##562" = SubArray(var"##560", (2:length(var"##560"),))
                                                            true
                                                        end)))
                                        var"##return#555" = let f = var"##561", args = var"##562"
                                                true
                                            end
                                        $(Expr(:symbolicgoto, Symbol("####final#556#595")))
                                    end
                                    if begin
                                                var"##563" = (var"##cache#558").value
                                                var"##563" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##563"[1] == :(::) && (begin
                                                        var"##564" = var"##563"[2]
                                                        var"##564" isa AbstractArray
                                                    end && (length(var"##564") === 2 && (begin
                                                                begin
                                                                    var"##cache#566" = nothing
                                                                end
                                                                var"##565" = var"##564"[1]
                                                                var"##565" isa Expr
                                                            end && (begin
                                                                    if var"##cache#566" === nothing
                                                                        var"##cache#566" = Some(((var"##565").head, (var"##565").args))
                                                                    end
                                                                    var"##567" = (var"##cache#566").value
                                                                    var"##567" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##567"[1] == :call && (begin
                                                                            var"##568" = var"##567"[2]
                                                                            var"##568" isa AbstractArray
                                                                        end && ((ndims(var"##568") === 1 && length(var"##568") >= 1) && begin
                                                                                var"##569" = var"##568"[1]
                                                                                var"##570" = SubArray(var"##568", (2:length(var"##568"),))
                                                                                var"##571" = var"##564"[2]
                                                                                true
                                                                            end))))))))
                                        var"##return#555" = let f = var"##569", args = var"##570", rettype = var"##571"
                                                true
                                            end
                                        $(Expr(:symbolicgoto, Symbol("####final#556#595")))
                                    end
                                    if begin
                                                var"##572" = (var"##cache#558").value
                                                var"##572" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##572"[1] == :where && (begin
                                                        var"##573" = var"##572"[2]
                                                        var"##573" isa AbstractArray
                                                    end && ((ndims(var"##573") === 1 && length(var"##573") >= 1) && (begin
                                                                begin
                                                                    var"##cache#575" = nothing
                                                                end
                                                                var"##574" = var"##573"[1]
                                                                var"##574" isa Expr
                                                            end && (begin
                                                                    if var"##cache#575" === nothing
                                                                        var"##cache#575" = Some(((var"##574").head, (var"##574").args))
                                                                    end
                                                                    var"##576" = (var"##cache#575").value
                                                                    var"##576" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##576"[1] == :call && (begin
                                                                            var"##577" = var"##576"[2]
                                                                            var"##577" isa AbstractArray
                                                                        end && ((ndims(var"##577") === 1 && length(var"##577") >= 1) && begin
                                                                                var"##578" = var"##577"[1]
                                                                                var"##579" = SubArray(var"##577", (2:length(var"##577"),))
                                                                                var"##580" = SubArray(var"##573", (2:length(var"##573"),))
                                                                                true
                                                                            end))))))))
                                        var"##return#555" = let f = var"##578", params = var"##580", args = var"##579"
                                                true
                                            end
                                        $(Expr(:symbolicgoto, Symbol("####final#556#595")))
                                    end
                                    if begin
                                                var"##581" = (var"##cache#558").value
                                                var"##581" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##581"[1] == :where && (begin
                                                        var"##582" = var"##581"[2]
                                                        var"##582" isa AbstractArray
                                                    end && ((ndims(var"##582") === 1 && length(var"##582") >= 1) && (begin
                                                                begin
                                                                    var"##cache#584" = nothing
                                                                end
                                                                var"##583" = var"##582"[1]
                                                                var"##583" isa Expr
                                                            end && (begin
                                                                    if var"##cache#584" === nothing
                                                                        var"##cache#584" = Some(((var"##583").head, (var"##583").args))
                                                                    end
                                                                    var"##585" = (var"##cache#584").value
                                                                    var"##585" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##585"[1] == :(::) && (begin
                                                                            var"##586" = var"##585"[2]
                                                                            var"##586" isa AbstractArray
                                                                        end && (length(var"##586") === 2 && (begin
                                                                                    begin
                                                                                        var"##cache#588" = nothing
                                                                                    end
                                                                                    var"##587" = var"##586"[1]
                                                                                    var"##587" isa Expr
                                                                                end && (begin
                                                                                        if var"##cache#588" === nothing
                                                                                            var"##cache#588" = Some(((var"##587").head, (var"##587").args))
                                                                                        end
                                                                                        var"##589" = (var"##cache#588").value
                                                                                        var"##589" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                                    end && (var"##589"[1] == :call && (begin
                                                                                                var"##590" = var"##589"[2]
                                                                                                var"##590" isa AbstractArray
                                                                                            end && ((ndims(var"##590") === 1 && length(var"##590") >= 1) && begin
                                                                                                    var"##591" = var"##590"[1]
                                                                                                    var"##592" = SubArray(var"##590", (2:length(var"##590"),))
                                                                                                    var"##593" = var"##586"[2]
                                                                                                    var"##594" = SubArray(var"##582", (2:length(var"##582"),))
                                                                                                    true
                                                                                                end)))))))))))))
                                        var"##return#555" = let f = var"##591", params = var"##594", args = var"##592", rettype = var"##593"
                                                true
                                            end
                                        $(Expr(:symbolicgoto, Symbol("####final#556#595")))
                                    end
                                end
                                begin
                                    var"##return#555" = let
                                            return nothing
                                        end
                                    $(Expr(:symbolicgoto, Symbol("####final#556#595")))
                                end
                                error("matching non-exhaustive, at #= none:40 =#")
                                $(Expr(:symboliclabel, Symbol("####final#556#595")))
                                var"##return#555"
                            end
                            (:(=), call, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#535#554")))
                end
                if begin
                            var"##550" = (var"##cache#537").value
                            var"##550" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##550"[1] == :-> && (begin
                                    var"##551" = var"##550"[2]
                                    var"##551" isa AbstractArray
                                end && (length(var"##551") === 2 && begin
                                        var"##552" = var"##551"[1]
                                        var"##553" = var"##551"[2]
                                        true
                                    end)))
                    var"##return#534" = let call = var"##552", body = var"##553"
                            (:->, call, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#535#554")))
                end
            end
            begin
                var"##return#534" = let
                        nothing
                    end
                $(Expr(:symbolicgoto, Symbol("####final#535#554")))
            end
            error("matching non-exhaustive, at #= none:36 =#")
            $(Expr(:symboliclabel, Symbol("####final#535#554")))
            var"##return#534"
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
                var"##cache#599" = nothing
            end
            var"##return#596" = nothing
            var"##598" = ex
            if var"##598" isa Expr
                if begin
                            if var"##cache#599" === nothing
                                var"##cache#599" = Some(((var"##598").head, (var"##598").args))
                            end
                            var"##600" = (var"##cache#599").value
                            var"##600" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##600"[1] == :tuple && (begin
                                    var"##601" = var"##600"[2]
                                    var"##601" isa AbstractArray
                                end && ((ndims(var"##601") === 1 && length(var"##601") >= 1) && (begin
                                            begin
                                                var"##cache#603" = nothing
                                            end
                                            var"##602" = var"##601"[1]
                                            var"##602" isa Expr
                                        end && (begin
                                                if var"##cache#603" === nothing
                                                    var"##cache#603" = Some(((var"##602").head, (var"##602").args))
                                                end
                                                var"##604" = (var"##cache#603").value
                                                var"##604" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##604"[1] == :parameters && (begin
                                                        var"##605" = var"##604"[2]
                                                        var"##605" isa AbstractArray
                                                    end && ((ndims(var"##605") === 1 && length(var"##605") >= 0) && begin
                                                            var"##606" = SubArray(var"##605", (1:length(var"##605"),))
                                                            var"##607" = SubArray(var"##601", (2:length(var"##601"),))
                                                            true
                                                        end))))))))
                    var"##return#596" = let args = var"##607", kw = var"##606"
                            (nothing, args, kw, nothing, nothing)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#597#647")))
                end
                if begin
                            var"##608" = (var"##cache#599").value
                            var"##608" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##608"[1] == :tuple && (begin
                                    var"##609" = var"##608"[2]
                                    var"##609" isa AbstractArray
                                end && ((ndims(var"##609") === 1 && length(var"##609") >= 0) && begin
                                        var"##610" = SubArray(var"##609", (1:length(var"##609"),))
                                        true
                                    end)))
                    var"##return#596" = let args = var"##610"
                            (nothing, args, nothing, nothing, nothing)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#597#647")))
                end
                if begin
                            var"##611" = (var"##cache#599").value
                            var"##611" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##611"[1] == :call && (begin
                                    var"##612" = var"##611"[2]
                                    var"##612" isa AbstractArray
                                end && ((ndims(var"##612") === 1 && length(var"##612") >= 2) && (begin
                                            var"##613" = var"##612"[1]
                                            begin
                                                var"##cache#615" = nothing
                                            end
                                            var"##614" = var"##612"[2]
                                            var"##614" isa Expr
                                        end && (begin
                                                if var"##cache#615" === nothing
                                                    var"##cache#615" = Some(((var"##614").head, (var"##614").args))
                                                end
                                                var"##616" = (var"##cache#615").value
                                                var"##616" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##616"[1] == :parameters && (begin
                                                        var"##617" = var"##616"[2]
                                                        var"##617" isa AbstractArray
                                                    end && ((ndims(var"##617") === 1 && length(var"##617") >= 0) && begin
                                                            var"##618" = SubArray(var"##617", (1:length(var"##617"),))
                                                            var"##619" = SubArray(var"##612", (3:length(var"##612"),))
                                                            true
                                                        end))))))))
                    var"##return#596" = let name = var"##613", args = var"##619", kw = var"##618"
                            (name, args, kw, nothing, nothing)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#597#647")))
                end
                if begin
                            var"##620" = (var"##cache#599").value
                            var"##620" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##620"[1] == :call && (begin
                                    var"##621" = var"##620"[2]
                                    var"##621" isa AbstractArray
                                end && ((ndims(var"##621") === 1 && length(var"##621") >= 1) && begin
                                        var"##622" = var"##621"[1]
                                        var"##623" = SubArray(var"##621", (2:length(var"##621"),))
                                        true
                                    end)))
                    var"##return#596" = let name = var"##622", args = var"##623"
                            (name, args, nothing, nothing, nothing)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#597#647")))
                end
                if begin
                            var"##624" = (var"##cache#599").value
                            var"##624" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##624"[1] == :block && (begin
                                    var"##625" = var"##624"[2]
                                    var"##625" isa AbstractArray
                                end && (length(var"##625") === 3 && (begin
                                            var"##626" = var"##625"[1]
                                            var"##627" = var"##625"[2]
                                            var"##627" isa LineNumberNode
                                        end && (begin
                                                begin
                                                    var"##cache#629" = nothing
                                                end
                                                var"##628" = var"##625"[3]
                                                var"##628" isa Expr
                                            end && (begin
                                                    if var"##cache#629" === nothing
                                                        var"##cache#629" = Some(((var"##628").head, (var"##628").args))
                                                    end
                                                    var"##630" = (var"##cache#629").value
                                                    var"##630" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##630"[1] == :(=) && (begin
                                                            var"##631" = var"##630"[2]
                                                            var"##631" isa AbstractArray
                                                        end && (length(var"##631") === 2 && begin
                                                                var"##632" = var"##631"[1]
                                                                var"##633" = var"##631"[2]
                                                                true
                                                            end)))))))))
                    var"##return#596" = let value = var"##633", kw = var"##632", x = var"##626"
                            (nothing, Any[x], Any[Expr(:kw, kw, value)], nothing, nothing)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#597#647")))
                end
                if begin
                            var"##634" = (var"##cache#599").value
                            var"##634" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##634"[1] == :block && (begin
                                    var"##635" = var"##634"[2]
                                    var"##635" isa AbstractArray
                                end && (length(var"##635") === 3 && (begin
                                            var"##636" = var"##635"[1]
                                            var"##637" = var"##635"[2]
                                            var"##637" isa LineNumberNode
                                        end && begin
                                            var"##638" = var"##635"[3]
                                            true
                                        end))))
                    var"##return#596" = let kw = var"##638", x = var"##636"
                            (nothing, Any[x], Any[kw], nothing, nothing)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#597#647")))
                end
                if begin
                            var"##639" = (var"##cache#599").value
                            var"##639" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##639"[1] == :(::) && (begin
                                    var"##640" = var"##639"[2]
                                    var"##640" isa AbstractArray
                                end && (length(var"##640") === 2 && (begin
                                            var"##641" = var"##640"[1]
                                            var"##641" isa Expr
                                        end && begin
                                            var"##642" = var"##640"[2]
                                            true
                                        end))))
                    var"##return#596" = let call = var"##641", rettype = var"##642"
                            sub_tuple = split_function_head_nothrow(call)
                            isnothing(sub_tuple) && return nothing
                            (name, args, kw, whereparams, _) = split_function_head_nothrow(call)
                            (name, args, kw, whereparams, rettype)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#597#647")))
                end
                if begin
                            var"##643" = (var"##cache#599").value
                            var"##643" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##643"[1] == :where && (begin
                                    var"##644" = var"##643"[2]
                                    var"##644" isa AbstractArray
                                end && ((ndims(var"##644") === 1 && length(var"##644") >= 1) && begin
                                        var"##645" = var"##644"[1]
                                        var"##646" = SubArray(var"##644", (2:length(var"##644"),))
                                        true
                                    end)))
                    var"##return#596" = let call = var"##645", whereparams = var"##646"
                            sub_tuple = split_function_head_nothrow(call)
                            isnothing(sub_tuple) && return nothing
                            (name, args, kw, _, rettype) = sub_tuple
                            (name, args, kw, whereparams, rettype)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#597#647")))
                end
            end
            begin
                var"##return#596" = let
                        nothing
                    end
                $(Expr(:symbolicgoto, Symbol("####final#597#647")))
            end
            error("matching non-exhaustive, at #= none:66 =#")
            $(Expr(:symboliclabel, Symbol("####final#597#647")))
            var"##return#596"
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
                var"##cache#651" = nothing
            end
            var"##return#648" = nothing
            var"##650" = ex
            if var"##650" isa Expr
                if begin
                            if var"##cache#651" === nothing
                                var"##cache#651" = Some(((var"##650").head, (var"##650").args))
                            end
                            var"##652" = (var"##cache#651").value
                            var"##652" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##652"[1] == :tuple && (begin
                                    var"##653" = var"##652"[2]
                                    var"##653" isa AbstractArray
                                end && ((ndims(var"##653") === 1 && length(var"##653") >= 1) && (begin
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
                                            end && (var"##656"[1] == :parameters && (begin
                                                        var"##657" = var"##656"[2]
                                                        var"##657" isa AbstractArray
                                                    end && ((ndims(var"##657") === 1 && length(var"##657") >= 0) && begin
                                                            var"##658" = SubArray(var"##657", (1:length(var"##657"),))
                                                            var"##659" = SubArray(var"##653", (2:length(var"##653"),))
                                                            true
                                                        end))))))))
                    var"##return#648" = let args = var"##659", kw = var"##658"
                            (nothing, args, kw, nothing, nothing)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#649#693")))
                end
                if begin
                            var"##660" = (var"##cache#651").value
                            var"##660" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##660"[1] == :tuple && (begin
                                    var"##661" = var"##660"[2]
                                    var"##661" isa AbstractArray
                                end && ((ndims(var"##661") === 1 && length(var"##661") >= 0) && begin
                                        var"##662" = SubArray(var"##661", (1:length(var"##661"),))
                                        true
                                    end)))
                    var"##return#648" = let args = var"##662"
                            (nothing, args, nothing, nothing, nothing)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#649#693")))
                end
                if begin
                            var"##663" = (var"##cache#651").value
                            var"##663" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##663"[1] == :block && (begin
                                    var"##664" = var"##663"[2]
                                    var"##664" isa AbstractArray
                                end && (length(var"##664") === 3 && (begin
                                            var"##665" = var"##664"[1]
                                            var"##666" = var"##664"[2]
                                            var"##666" isa LineNumberNode
                                        end && (begin
                                                begin
                                                    var"##cache#668" = nothing
                                                end
                                                var"##667" = var"##664"[3]
                                                var"##667" isa Expr
                                            end && (begin
                                                    if var"##cache#668" === nothing
                                                        var"##cache#668" = Some(((var"##667").head, (var"##667").args))
                                                    end
                                                    var"##669" = (var"##cache#668").value
                                                    var"##669" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##669"[1] == :(=) && (begin
                                                            var"##670" = var"##669"[2]
                                                            var"##670" isa AbstractArray
                                                        end && (length(var"##670") === 2 && begin
                                                                var"##671" = var"##670"[1]
                                                                var"##672" = var"##670"[2]
                                                                true
                                                            end)))))))))
                    var"##return#648" = let value = var"##672", kw = var"##671", x = var"##665"
                            (nothing, Any[x], Any[Expr(:kw, kw, value)], nothing, nothing)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#649#693")))
                end
                if begin
                            var"##673" = (var"##cache#651").value
                            var"##673" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##673"[1] == :block && (begin
                                    var"##674" = var"##673"[2]
                                    var"##674" isa AbstractArray
                                end && (length(var"##674") === 3 && (begin
                                            var"##675" = var"##674"[1]
                                            var"##676" = var"##674"[2]
                                            var"##676" isa LineNumberNode
                                        end && begin
                                            var"##677" = var"##674"[3]
                                            true
                                        end))))
                    var"##return#648" = let kw = var"##677", x = var"##675"
                            (nothing, Any[x], Any[kw], nothing, nothing)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#649#693")))
                end
                if begin
                            var"##678" = (var"##cache#651").value
                            var"##678" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##678"[1] == :(::) && (begin
                                    var"##679" = var"##678"[2]
                                    var"##679" isa AbstractArray
                                end && (length(var"##679") === 2 && (begin
                                            var"##680" = var"##679"[1]
                                            var"##680" isa Expr
                                        end && begin
                                            var"##681" = var"##679"[2]
                                            true
                                        end))))
                    var"##return#648" = let rettype = var"##681", fh = var"##680"
                            sub_tuple = split_anonymous_function_head_nothrow(fh)
                            isnothing(sub_tuple) && return nothing
                            (name, args, kw, whereparams, _) = sub_tuple
                            (name, args, kw, whereparams, rettype)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#649#693")))
                end
                if begin
                            var"##682" = (var"##cache#651").value
                            var"##682" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##682"[1] == :(::) && (begin
                                    var"##683" = var"##682"[2]
                                    var"##683" isa AbstractArray
                                end && (length(var"##683") === 2 && (begin
                                            var"##684" = var"##683"[1]
                                            var"##684" isa Symbol
                                        end && begin
                                            var"##685" = var"##683"[2]
                                            true
                                        end))))
                    var"##return#648" = let arg = var"##684", argtype = var"##685"
                            (nothing, Any[ex], nothing, nothing, nothing)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#649#693")))
                end
                if begin
                            var"##686" = (var"##cache#651").value
                            var"##686" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##686"[1] == :(::) && (begin
                                    var"##687" = var"##686"[2]
                                    var"##687" isa AbstractArray
                                end && (length(var"##687") === 1 && begin
                                        var"##688" = var"##687"[1]
                                        true
                                    end)))
                    var"##return#648" = let argtype = var"##688"
                            (nothing, Any[ex], nothing, nothing, nothing)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#649#693")))
                end
                if begin
                            var"##689" = (var"##cache#651").value
                            var"##689" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##689"[1] == :where && (begin
                                    var"##690" = var"##689"[2]
                                    var"##690" isa AbstractArray
                                end && ((ndims(var"##690") === 1 && length(var"##690") >= 1) && begin
                                        var"##691" = var"##690"[1]
                                        var"##692" = SubArray(var"##690", (2:length(var"##690"),))
                                        true
                                    end)))
                    var"##return#648" = let call = var"##691", whereparams = var"##692"
                            sub_tuple = split_anonymous_function_head_nothrow(call)
                            isnothing(sub_tuple) && return nothing
                            (name, args, kw, _, rettype) = sub_tuple
                            (name, args, kw, whereparams, rettype)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#649#693")))
                end
            end
            begin
                var"##return#648" = let
                        nothing
                    end
                $(Expr(:symbolicgoto, Symbol("####final#649#693")))
            end
            error("matching non-exhaustive, at #= none:105 =#")
            $(Expr(:symboliclabel, Symbol("####final#649#693")))
            var"##return#648"
        end
    end
    split_anonymous_function_head_nothrow(s::Symbol) = begin
            (nothing, Any[s], nothing, nothing, nothing)
        end
    #= none:129 =# Core.@doc "    split_struct_name(ex::Expr) -> name, typevars, supertype\n\nSplit the name, type parameters and supertype definition from `struct`\ndeclaration head.\n" function split_struct_name(#= none:135 =# @nospecialize(ex); source = nothing)
            return let
                    begin
                        var"##cache#697" = nothing
                    end
                    var"##return#694" = nothing
                    var"##696" = ex
                    if var"##696" isa Expr
                        if begin
                                    if var"##cache#697" === nothing
                                        var"##cache#697" = Some(((var"##696").head, (var"##696").args))
                                    end
                                    var"##698" = (var"##cache#697").value
                                    var"##698" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##698"[1] == :curly && (begin
                                            var"##699" = var"##698"[2]
                                            var"##699" isa AbstractArray
                                        end && ((ndims(var"##699") === 1 && length(var"##699") >= 1) && begin
                                                var"##700" = var"##699"[1]
                                                var"##701" = SubArray(var"##699", (2:length(var"##699"),))
                                                true
                                            end)))
                            var"##return#694" = let typevars = var"##701", name = var"##700"
                                    (name, typevars, nothing)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#695#715")))
                        end
                        if begin
                                    var"##702" = (var"##cache#697").value
                                    var"##702" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##702"[1] == :<: && (begin
                                            var"##703" = var"##702"[2]
                                            var"##703" isa AbstractArray
                                        end && (length(var"##703") === 2 && (begin
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
                                                    end && (var"##706"[1] == :curly && (begin
                                                                var"##707" = var"##706"[2]
                                                                var"##707" isa AbstractArray
                                                            end && ((ndims(var"##707") === 1 && length(var"##707") >= 1) && begin
                                                                    var"##708" = var"##707"[1]
                                                                    var"##709" = SubArray(var"##707", (2:length(var"##707"),))
                                                                    var"##710" = var"##703"[2]
                                                                    true
                                                                end))))))))
                            var"##return#694" = let typevars = var"##709", type = var"##710", name = var"##708"
                                    (name, typevars, type)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#695#715")))
                        end
                        if begin
                                    var"##711" = (var"##cache#697").value
                                    var"##711" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##711"[1] == :<: && (begin
                                            var"##712" = var"##711"[2]
                                            var"##712" isa AbstractArray
                                        end && (length(var"##712") === 2 && begin
                                                var"##713" = var"##712"[1]
                                                var"##714" = var"##712"[2]
                                                true
                                            end)))
                            var"##return#694" = let type = var"##714", name = var"##713"
                                    (name, [], type)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#695#715")))
                        end
                    end
                    if var"##696" isa Symbol
                        begin
                            var"##return#694" = let
                                    (ex, [], nothing)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#695#715")))
                        end
                    end
                    begin
                        var"##return#694" = let
                                throw(SyntaxError("expect struct got $(ex)", source))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#695#715")))
                    end
                    error("matching non-exhaustive, at #= none:136 =#")
                    $(Expr(:symboliclabel, Symbol("####final#695#715")))
                    var"##return#694"
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
                    var"##cache#719" = nothing
                end
                var"##718" = expr
                if var"##718" isa Expr
                    if begin
                                if var"##cache#719" === nothing
                                    var"##cache#719" = Some(((var"##718").head, (var"##718").args))
                                end
                                var"##720" = (var"##cache#719").value
                                var"##720" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##720"[1] == :const && (begin
                                        var"##721" = var"##720"[2]
                                        var"##721" isa AbstractArray
                                    end && (length(var"##721") === 1 && (begin
                                                begin
                                                    var"##cache#723" = nothing
                                                end
                                                var"##722" = var"##721"[1]
                                                var"##722" isa Expr
                                            end && (begin
                                                    if var"##cache#723" === nothing
                                                        var"##cache#723" = Some(((var"##722").head, (var"##722").args))
                                                    end
                                                    var"##724" = (var"##cache#723").value
                                                    var"##724" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##724"[1] == :(=) && (begin
                                                            var"##725" = var"##724"[2]
                                                            var"##725" isa AbstractArray
                                                        end && (length(var"##725") === 2 && (begin
                                                                    begin
                                                                        var"##cache#727" = nothing
                                                                    end
                                                                    var"##726" = var"##725"[1]
                                                                    var"##726" isa Expr
                                                                end && (begin
                                                                        if var"##cache#727" === nothing
                                                                            var"##cache#727" = Some(((var"##726").head, (var"##726").args))
                                                                        end
                                                                        var"##728" = (var"##cache#727").value
                                                                        var"##728" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                    end && (var"##728"[1] == :(::) && (begin
                                                                                var"##729" = var"##728"[2]
                                                                                var"##729" isa AbstractArray
                                                                            end && (length(var"##729") === 2 && (begin
                                                                                        var"##730" = var"##729"[1]
                                                                                        var"##730" isa Symbol
                                                                                    end && begin
                                                                                        var"##731" = var"##729"[2]
                                                                                        var"##732" = var"##725"[2]
                                                                                        true
                                                                                    end))))))))))))))
                        value = var"##732"
                        type = var"##731"
                        name = var"##730"
                        var"##return#716" = begin
                                default && return (; name, type, isconst = true, default = value)
                                throw(SyntaxError("default value syntax is not allowed", source))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#769")))
                    end
                    if begin
                                var"##733" = (var"##cache#719").value
                                var"##733" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##733"[1] == :const && (begin
                                        var"##734" = var"##733"[2]
                                        var"##734" isa AbstractArray
                                    end && (length(var"##734") === 1 && (begin
                                                begin
                                                    var"##cache#736" = nothing
                                                end
                                                var"##735" = var"##734"[1]
                                                var"##735" isa Expr
                                            end && (begin
                                                    if var"##cache#736" === nothing
                                                        var"##cache#736" = Some(((var"##735").head, (var"##735").args))
                                                    end
                                                    var"##737" = (var"##cache#736").value
                                                    var"##737" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##737"[1] == :(=) && (begin
                                                            var"##738" = var"##737"[2]
                                                            var"##738" isa AbstractArray
                                                        end && (length(var"##738") === 2 && (begin
                                                                    var"##739" = var"##738"[1]
                                                                    var"##739" isa Symbol
                                                                end && begin
                                                                    var"##740" = var"##738"[2]
                                                                    true
                                                                end)))))))))
                        value = var"##740"
                        name = var"##739"
                        var"##return#716" = begin
                                default && return (; name, type = Any, isconst = true, default = value)
                                throw(SyntaxError("default value syntax is not allowed", source))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#769")))
                    end
                    if begin
                                var"##741" = (var"##cache#719").value
                                var"##741" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##741"[1] == :(=) && (begin
                                        var"##742" = var"##741"[2]
                                        var"##742" isa AbstractArray
                                    end && (length(var"##742") === 2 && (begin
                                                begin
                                                    var"##cache#744" = nothing
                                                end
                                                var"##743" = var"##742"[1]
                                                var"##743" isa Expr
                                            end && (begin
                                                    if var"##cache#744" === nothing
                                                        var"##cache#744" = Some(((var"##743").head, (var"##743").args))
                                                    end
                                                    var"##745" = (var"##cache#744").value
                                                    var"##745" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##745"[1] == :(::) && (begin
                                                            var"##746" = var"##745"[2]
                                                            var"##746" isa AbstractArray
                                                        end && (length(var"##746") === 2 && (begin
                                                                    var"##747" = var"##746"[1]
                                                                    var"##747" isa Symbol
                                                                end && begin
                                                                    var"##748" = var"##746"[2]
                                                                    var"##749" = var"##742"[2]
                                                                    true
                                                                end)))))))))
                        value = var"##749"
                        type = var"##748"
                        name = var"##747"
                        var"##return#716" = begin
                                default && return (; name, type, isconst = false, default = value)
                                throw(SyntaxError("default value syntax is not allowed", source))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#769")))
                    end
                    if begin
                                var"##750" = (var"##cache#719").value
                                var"##750" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##750"[1] == :(=) && (begin
                                        var"##751" = var"##750"[2]
                                        var"##751" isa AbstractArray
                                    end && (length(var"##751") === 2 && (begin
                                                var"##752" = var"##751"[1]
                                                var"##752" isa Symbol
                                            end && begin
                                                var"##753" = var"##751"[2]
                                                true
                                            end))))
                        value = var"##753"
                        name = var"##752"
                        var"##return#716" = begin
                                default && return (; name, type = Any, isconst = false, default = value)
                                throw(SyntaxError("default value syntax is not allowed", source))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#769")))
                    end
                    if begin
                                var"##754" = (var"##cache#719").value
                                var"##754" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##754"[1] == :const && (begin
                                        var"##755" = var"##754"[2]
                                        var"##755" isa AbstractArray
                                    end && (length(var"##755") === 1 && (begin
                                                begin
                                                    var"##cache#757" = nothing
                                                end
                                                var"##756" = var"##755"[1]
                                                var"##756" isa Expr
                                            end && (begin
                                                    if var"##cache#757" === nothing
                                                        var"##cache#757" = Some(((var"##756").head, (var"##756").args))
                                                    end
                                                    var"##758" = (var"##cache#757").value
                                                    var"##758" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##758"[1] == :(::) && (begin
                                                            var"##759" = var"##758"[2]
                                                            var"##759" isa AbstractArray
                                                        end && (length(var"##759") === 2 && (begin
                                                                    var"##760" = var"##759"[1]
                                                                    var"##760" isa Symbol
                                                                end && begin
                                                                    var"##761" = var"##759"[2]
                                                                    true
                                                                end)))))))))
                        type = var"##761"
                        name = var"##760"
                        var"##return#716" = begin
                                default && return (; name, type, isconst = true, default = no_default)
                                return (; name, type, isconst = true)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#769")))
                    end
                    if begin
                                var"##762" = (var"##cache#719").value
                                var"##762" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##762"[1] == :const && (begin
                                        var"##763" = var"##762"[2]
                                        var"##763" isa AbstractArray
                                    end && (length(var"##763") === 1 && begin
                                            var"##764" = var"##763"[1]
                                            var"##764" isa Symbol
                                        end)))
                        name = var"##764"
                        var"##return#716" = begin
                                default && return (; name, type = Any, isconst = true, default = no_default)
                                return (; name, type = Any, isconst = true)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#769")))
                    end
                    if begin
                                var"##765" = (var"##cache#719").value
                                var"##765" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##765"[1] == :(::) && (begin
                                        var"##766" = var"##765"[2]
                                        var"##766" isa AbstractArray
                                    end && (length(var"##766") === 2 && (begin
                                                var"##767" = var"##766"[1]
                                                var"##767" isa Symbol
                                            end && begin
                                                var"##768" = var"##766"[2]
                                                true
                                            end))))
                        type = var"##768"
                        name = var"##767"
                        var"##return#716" = begin
                                default && return (; name, type, isconst = false, default = no_default)
                                return (; name, type, isconst = false)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#769")))
                    end
                end
                if var"##718" isa Symbol
                    begin
                        name = var"##718"
                        var"##return#716" = begin
                                default && return (; name, type = Any, isconst = false, default = no_default)
                                return (; name, type = Any, isconst = false)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#769")))
                    end
                end
                if var"##718" isa String
                    begin
                        var"##return#716" = begin
                                return expr
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#769")))
                    end
                end
                if var"##718" isa LineNumberNode
                    begin
                        var"##return#716" = begin
                                return expr
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#717#769")))
                    end
                end
                if is_function(expr)
                    var"##return#716" = begin
                            if name_only(expr) === typename
                                return JLFunction(expr)
                            else
                                return expr
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#717#769")))
                end
                begin
                    var"##return#716" = begin
                            return expr
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#717#769")))
                end
                error("matching non-exhaustive, at #= none:235 =#")
                $(Expr(:symboliclabel, Symbol("####final#717#769")))
                var"##return#716"
            end
        end
    function split_signature(call::Expr)
        if Meta.isexpr(call, :where)
            Expr(:where, split_signature(call.args[1]), call.args[2:end]...)
        elseif Meta.isexpr(call, :call)
            :(($Base).Tuple{($Base).typeof($(call.args[1])), $(arg2type.(call.args[2:end])...)})
        elseif Meta.isexpr(call, :(::))
            return split_signature(call.args[1])
        else
            error("invalid signature: $(call)")
        end
    end
    function arg2type(arg)
        let
            begin
                var"##cache#773" = nothing
            end
            var"##return#770" = nothing
            var"##772" = arg
            if var"##772" isa Expr
                if begin
                            if var"##cache#773" === nothing
                                var"##cache#773" = Some(((var"##772").head, (var"##772").args))
                            end
                            var"##774" = (var"##cache#773").value
                            var"##774" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##774"[1] == :(::) && (begin
                                    var"##775" = var"##774"[2]
                                    var"##775" isa AbstractArray
                                end && (length(var"##775") === 1 && begin
                                        var"##776" = var"##775"[1]
                                        true
                                    end)))
                    var"##return#770" = let type = var"##776"
                            type
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#771#793")))
                end
                if begin
                            var"##777" = (var"##cache#773").value
                            var"##777" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##777"[1] == :(::) && (begin
                                    var"##778" = var"##777"[2]
                                    var"##778" isa AbstractArray
                                end && (length(var"##778") === 2 && begin
                                        var"##779" = var"##778"[2]
                                        true
                                    end)))
                    var"##return#770" = let type = var"##779"
                            type
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#771#793")))
                end
                if begin
                            var"##780" = (var"##cache#773").value
                            var"##780" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##780"[1] == :... && (begin
                                    var"##781" = var"##780"[2]
                                    var"##781" isa AbstractArray
                                end && (length(var"##781") === 1 && (begin
                                            begin
                                                var"##cache#783" = nothing
                                            end
                                            var"##782" = var"##781"[1]
                                            var"##782" isa Expr
                                        end && (begin
                                                if var"##cache#783" === nothing
                                                    var"##cache#783" = Some(((var"##782").head, (var"##782").args))
                                                end
                                                var"##784" = (var"##cache#783").value
                                                var"##784" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##784"[1] == :(::) && (begin
                                                        var"##785" = var"##784"[2]
                                                        var"##785" isa AbstractArray
                                                    end && (length(var"##785") === 2 && begin
                                                            var"##786" = var"##785"[2]
                                                            true
                                                        end))))))))
                    var"##return#770" = let type = var"##786"
                            Core._expr(:curly, Core._expr(:., Base, $(Expr(:copyast, :($(QuoteNode(:(:Vararg))))))), type)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#771#793")))
                end
                if begin
                            var"##787" = (var"##cache#773").value
                            var"##787" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##787"[1] == :... && (begin
                                    var"##788" = var"##787"[2]
                                    var"##788" isa AbstractArray
                                end && length(var"##788") === 1))
                    var"##return#770" = let
                            Core._expr(:curly, Core._expr(:., Base, $(Expr(:copyast, :($(QuoteNode(:(:Vararg))))))), Any)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#771#793")))
                end
                if begin
                            var"##789" = (var"##cache#773").value
                            var"##789" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##789"[1] == :kw && (begin
                                    var"##790" = var"##789"[2]
                                    var"##790" isa AbstractArray
                                end && (length(var"##790") === 2 && begin
                                        var"##791" = var"##790"[1]
                                        var"##792" = var"##790"[2]
                                        true
                                    end)))
                    var"##return#770" = let arg = var"##791", value = var"##792"
                            arg2type(arg)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#771#793")))
                end
            end
            if var"##772" isa Symbol
                begin
                    var"##return#770" = let
                            Any
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#771#793")))
                end
            end
            begin
                var"##return#770" = let
                        error("invalid argument type: $(arg)")
                    end
                $(Expr(:symbolicgoto, Symbol("####final#771#793")))
            end
            error("matching non-exhaustive, at #= none:286 =#")
            $(Expr(:symboliclabel, Symbol("####final#771#793")))
            var"##return#770"
        end
    end
