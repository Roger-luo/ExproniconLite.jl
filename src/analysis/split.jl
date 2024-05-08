
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
                    $(Expr(:symbolicgoto, Symbol("####final#530#545")))
                end
                if begin
                            var"##537" = (var"##cache#532").value
                            var"##537" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##537"[1] == :(=) && (begin
                                    var"##538" = var"##537"[2]
                                    var"##538" isa AbstractArray
                                end && (length(var"##538") === 2 && begin
                                        var"##539" = var"##538"[1]
                                        var"##540" = var"##538"[2]
                                        true
                                    end)))
                    var"##return#529" = let call = var"##539", body = var"##540"
                            (:(=), call, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#530#545")))
                end
                if begin
                            var"##541" = (var"##cache#532").value
                            var"##541" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##541"[1] == :-> && (begin
                                    var"##542" = var"##541"[2]
                                    var"##542" isa AbstractArray
                                end && (length(var"##542") === 2 && begin
                                        var"##543" = var"##542"[1]
                                        var"##544" = var"##542"[2]
                                        true
                                    end)))
                    var"##return#529" = let call = var"##543", body = var"##544"
                            (:->, call, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#530#545")))
                end
            end
            begin
                var"##return#529" = let
                        nothing
                    end
                $(Expr(:symbolicgoto, Symbol("####final#530#545")))
            end
            error("matching non-exhaustive, at #= none:36 =#")
            $(Expr(:symboliclabel, Symbol("####final#530#545")))
            var"##return#529"
        end
    end
    #= none:45 =# Core.@doc "    split_function_head(ex::Expr) -> name, args, kw, whereparams, rettype\n\nSplit function head to name, arguments, keyword arguments and where parameters.\n" function split_function_head(ex::Expr; source = nothing)
            split_head_tuple = split_function_head_nothrow(ex)
            isnothing(split_head_tuple) && throw(SyntaxError("expect a function head, got $(ex)", source))
            split_head_tuple
        end
    function split_function_head_nothrow(ex::Expr)
        let
            begin
                var"##cache#549" = nothing
            end
            var"##return#546" = nothing
            var"##548" = ex
            if var"##548" isa Expr
                if begin
                            if var"##cache#549" === nothing
                                var"##cache#549" = Some(((var"##548").head, (var"##548").args))
                            end
                            var"##550" = (var"##cache#549").value
                            var"##550" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##550"[1] == :tuple && (begin
                                    var"##551" = var"##550"[2]
                                    var"##551" isa AbstractArray
                                end && ((ndims(var"##551") === 1 && length(var"##551") >= 1) && (begin
                                            begin
                                                var"##cache#553" = nothing
                                            end
                                            var"##552" = var"##551"[1]
                                            var"##552" isa Expr
                                        end && (begin
                                                if var"##cache#553" === nothing
                                                    var"##cache#553" = Some(((var"##552").head, (var"##552").args))
                                                end
                                                var"##554" = (var"##cache#553").value
                                                var"##554" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##554"[1] == :parameters && (begin
                                                        var"##555" = var"##554"[2]
                                                        var"##555" isa AbstractArray
                                                    end && ((ndims(var"##555") === 1 && length(var"##555") >= 0) && begin
                                                            var"##556" = SubArray(var"##555", (1:length(var"##555"),))
                                                            var"##557" = SubArray(var"##551", (2:length(var"##551"),))
                                                            true
                                                        end))))))))
                    var"##return#546" = let args = var"##557", kw = var"##556"
                            (nothing, args, kw, nothing, nothing)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#547#597")))
                end
                if begin
                            var"##558" = (var"##cache#549").value
                            var"##558" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##558"[1] == :tuple && (begin
                                    var"##559" = var"##558"[2]
                                    var"##559" isa AbstractArray
                                end && ((ndims(var"##559") === 1 && length(var"##559") >= 0) && begin
                                        var"##560" = SubArray(var"##559", (1:length(var"##559"),))
                                        true
                                    end)))
                    var"##return#546" = let args = var"##560"
                            (nothing, args, nothing, nothing, nothing)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#547#597")))
                end
                if begin
                            var"##561" = (var"##cache#549").value
                            var"##561" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##561"[1] == :call && (begin
                                    var"##562" = var"##561"[2]
                                    var"##562" isa AbstractArray
                                end && ((ndims(var"##562") === 1 && length(var"##562") >= 2) && (begin
                                            var"##563" = var"##562"[1]
                                            begin
                                                var"##cache#565" = nothing
                                            end
                                            var"##564" = var"##562"[2]
                                            var"##564" isa Expr
                                        end && (begin
                                                if var"##cache#565" === nothing
                                                    var"##cache#565" = Some(((var"##564").head, (var"##564").args))
                                                end
                                                var"##566" = (var"##cache#565").value
                                                var"##566" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##566"[1] == :parameters && (begin
                                                        var"##567" = var"##566"[2]
                                                        var"##567" isa AbstractArray
                                                    end && ((ndims(var"##567") === 1 && length(var"##567") >= 0) && begin
                                                            var"##568" = SubArray(var"##567", (1:length(var"##567"),))
                                                            var"##569" = SubArray(var"##562", (3:length(var"##562"),))
                                                            true
                                                        end))))))))
                    var"##return#546" = let name = var"##563", args = var"##569", kw = var"##568"
                            (name, args, kw, nothing, nothing)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#547#597")))
                end
                if begin
                            var"##570" = (var"##cache#549").value
                            var"##570" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##570"[1] == :call && (begin
                                    var"##571" = var"##570"[2]
                                    var"##571" isa AbstractArray
                                end && ((ndims(var"##571") === 1 && length(var"##571") >= 1) && begin
                                        var"##572" = var"##571"[1]
                                        var"##573" = SubArray(var"##571", (2:length(var"##571"),))
                                        true
                                    end)))
                    var"##return#546" = let name = var"##572", args = var"##573"
                            (name, args, nothing, nothing, nothing)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#547#597")))
                end
                if begin
                            var"##574" = (var"##cache#549").value
                            var"##574" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##574"[1] == :block && (begin
                                    var"##575" = var"##574"[2]
                                    var"##575" isa AbstractArray
                                end && (length(var"##575") === 3 && (begin
                                            var"##576" = var"##575"[1]
                                            var"##577" = var"##575"[2]
                                            var"##577" isa LineNumberNode
                                        end && (begin
                                                begin
                                                    var"##cache#579" = nothing
                                                end
                                                var"##578" = var"##575"[3]
                                                var"##578" isa Expr
                                            end && (begin
                                                    if var"##cache#579" === nothing
                                                        var"##cache#579" = Some(((var"##578").head, (var"##578").args))
                                                    end
                                                    var"##580" = (var"##cache#579").value
                                                    var"##580" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##580"[1] == :(=) && (begin
                                                            var"##581" = var"##580"[2]
                                                            var"##581" isa AbstractArray
                                                        end && (length(var"##581") === 2 && begin
                                                                var"##582" = var"##581"[1]
                                                                var"##583" = var"##581"[2]
                                                                true
                                                            end)))))))))
                    var"##return#546" = let value = var"##583", kw = var"##582", x = var"##576"
                            (nothing, Any[x], Any[Expr(:kw, kw, value)], nothing, nothing)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#547#597")))
                end
                if begin
                            var"##584" = (var"##cache#549").value
                            var"##584" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##584"[1] == :block && (begin
                                    var"##585" = var"##584"[2]
                                    var"##585" isa AbstractArray
                                end && (length(var"##585") === 3 && (begin
                                            var"##586" = var"##585"[1]
                                            var"##587" = var"##585"[2]
                                            var"##587" isa LineNumberNode
                                        end && begin
                                            var"##588" = var"##585"[3]
                                            true
                                        end))))
                    var"##return#546" = let kw = var"##588", x = var"##586"
                            (nothing, Any[x], Any[kw], nothing, nothing)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#547#597")))
                end
                if begin
                            var"##589" = (var"##cache#549").value
                            var"##589" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##589"[1] == :(::) && (begin
                                    var"##590" = var"##589"[2]
                                    var"##590" isa AbstractArray
                                end && (length(var"##590") === 2 && (begin
                                            var"##591" = var"##590"[1]
                                            var"##591" isa Expr
                                        end && begin
                                            var"##592" = var"##590"[2]
                                            true
                                        end))))
                    var"##return#546" = let call = var"##591", rettype = var"##592"
                            sub_tuple = split_function_head_nothrow(call)
                            isnothing(sub_tuple) && return nothing
                            (name, args, kw, whereparams, _) = split_function_head_nothrow(call)
                            (name, args, kw, whereparams, rettype)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#547#597")))
                end
                if begin
                            var"##593" = (var"##cache#549").value
                            var"##593" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##593"[1] == :where && (begin
                                    var"##594" = var"##593"[2]
                                    var"##594" isa AbstractArray
                                end && ((ndims(var"##594") === 1 && length(var"##594") >= 1) && begin
                                        var"##595" = var"##594"[1]
                                        var"##596" = SubArray(var"##594", (2:length(var"##594"),))
                                        true
                                    end)))
                    var"##return#546" = let call = var"##595", whereparams = var"##596"
                            sub_tuple = split_function_head_nothrow(call)
                            isnothing(sub_tuple) && return nothing
                            (name, args, kw, _, rettype) = sub_tuple
                            (name, args, kw, whereparams, rettype)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#547#597")))
                end
            end
            begin
                var"##return#546" = let
                        nothing
                    end
                $(Expr(:symbolicgoto, Symbol("####final#547#597")))
            end
            error("matching non-exhaustive, at #= none:57 =#")
            $(Expr(:symboliclabel, Symbol("####final#547#597")))
            var"##return#546"
        end
    end
    split_function_head_nothrow(s::Symbol) = begin
            (nothing, Any[s], nothing, nothing, nothing)
        end
    #= none:81 =# Core.@doc "    split_anonymous_function_head(ex::Expr) -> nothing, args, kw, whereparams, rettype\n\nSplit anonymous function head to arguments, keyword arguments and where parameters.\n" function split_anonymous_function_head(ex::Expr; source = nothing)
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
                var"##cache#601" = nothing
            end
            var"##return#598" = nothing
            var"##600" = ex
            if var"##600" isa Expr
                if begin
                            if var"##cache#601" === nothing
                                var"##cache#601" = Some(((var"##600").head, (var"##600").args))
                            end
                            var"##602" = (var"##cache#601").value
                            var"##602" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##602"[1] == :tuple && (begin
                                    var"##603" = var"##602"[2]
                                    var"##603" isa AbstractArray
                                end && ((ndims(var"##603") === 1 && length(var"##603") >= 1) && (begin
                                            begin
                                                var"##cache#605" = nothing
                                            end
                                            var"##604" = var"##603"[1]
                                            var"##604" isa Expr
                                        end && (begin
                                                if var"##cache#605" === nothing
                                                    var"##cache#605" = Some(((var"##604").head, (var"##604").args))
                                                end
                                                var"##606" = (var"##cache#605").value
                                                var"##606" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##606"[1] == :parameters && (begin
                                                        var"##607" = var"##606"[2]
                                                        var"##607" isa AbstractArray
                                                    end && ((ndims(var"##607") === 1 && length(var"##607") >= 0) && begin
                                                            var"##608" = SubArray(var"##607", (1:length(var"##607"),))
                                                            var"##609" = SubArray(var"##603", (2:length(var"##603"),))
                                                            true
                                                        end))))))))
                    var"##return#598" = let args = var"##609", kw = var"##608"
                            (nothing, args, kw, nothing, nothing)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#599#643")))
                end
                if begin
                            var"##610" = (var"##cache#601").value
                            var"##610" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##610"[1] == :tuple && (begin
                                    var"##611" = var"##610"[2]
                                    var"##611" isa AbstractArray
                                end && ((ndims(var"##611") === 1 && length(var"##611") >= 0) && begin
                                        var"##612" = SubArray(var"##611", (1:length(var"##611"),))
                                        true
                                    end)))
                    var"##return#598" = let args = var"##612"
                            (nothing, args, nothing, nothing, nothing)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#599#643")))
                end
                if begin
                            var"##613" = (var"##cache#601").value
                            var"##613" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##613"[1] == :block && (begin
                                    var"##614" = var"##613"[2]
                                    var"##614" isa AbstractArray
                                end && (length(var"##614") === 3 && (begin
                                            var"##615" = var"##614"[1]
                                            var"##616" = var"##614"[2]
                                            var"##616" isa LineNumberNode
                                        end && (begin
                                                begin
                                                    var"##cache#618" = nothing
                                                end
                                                var"##617" = var"##614"[3]
                                                var"##617" isa Expr
                                            end && (begin
                                                    if var"##cache#618" === nothing
                                                        var"##cache#618" = Some(((var"##617").head, (var"##617").args))
                                                    end
                                                    var"##619" = (var"##cache#618").value
                                                    var"##619" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##619"[1] == :(=) && (begin
                                                            var"##620" = var"##619"[2]
                                                            var"##620" isa AbstractArray
                                                        end && (length(var"##620") === 2 && begin
                                                                var"##621" = var"##620"[1]
                                                                var"##622" = var"##620"[2]
                                                                true
                                                            end)))))))))
                    var"##return#598" = let value = var"##622", kw = var"##621", x = var"##615"
                            (nothing, Any[x], Any[Expr(:kw, kw, value)], nothing, nothing)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#599#643")))
                end
                if begin
                            var"##623" = (var"##cache#601").value
                            var"##623" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##623"[1] == :block && (begin
                                    var"##624" = var"##623"[2]
                                    var"##624" isa AbstractArray
                                end && (length(var"##624") === 3 && (begin
                                            var"##625" = var"##624"[1]
                                            var"##626" = var"##624"[2]
                                            var"##626" isa LineNumberNode
                                        end && begin
                                            var"##627" = var"##624"[3]
                                            true
                                        end))))
                    var"##return#598" = let kw = var"##627", x = var"##625"
                            (nothing, Any[x], Any[kw], nothing, nothing)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#599#643")))
                end
                if begin
                            var"##628" = (var"##cache#601").value
                            var"##628" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##628"[1] == :(::) && (begin
                                    var"##629" = var"##628"[2]
                                    var"##629" isa AbstractArray
                                end && (length(var"##629") === 2 && (begin
                                            var"##630" = var"##629"[1]
                                            var"##630" isa Expr
                                        end && begin
                                            var"##631" = var"##629"[2]
                                            true
                                        end))))
                    var"##return#598" = let rettype = var"##631", fh = var"##630"
                            sub_tuple = split_anonymous_function_head_nothrow(fh)
                            isnothing(sub_tuple) && return nothing
                            (name, args, kw, whereparams, _) = sub_tuple
                            (name, args, kw, whereparams, rettype)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#599#643")))
                end
                if begin
                            var"##632" = (var"##cache#601").value
                            var"##632" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##632"[1] == :(::) && (begin
                                    var"##633" = var"##632"[2]
                                    var"##633" isa AbstractArray
                                end && (length(var"##633") === 2 && (begin
                                            var"##634" = var"##633"[1]
                                            var"##634" isa Symbol
                                        end && begin
                                            var"##635" = var"##633"[2]
                                            true
                                        end))))
                    var"##return#598" = let arg = var"##634", argtype = var"##635"
                            (nothing, Any[ex], nothing, nothing, nothing)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#599#643")))
                end
                if begin
                            var"##636" = (var"##cache#601").value
                            var"##636" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##636"[1] == :(::) && (begin
                                    var"##637" = var"##636"[2]
                                    var"##637" isa AbstractArray
                                end && (length(var"##637") === 1 && begin
                                        var"##638" = var"##637"[1]
                                        true
                                    end)))
                    var"##return#598" = let argtype = var"##638"
                            (nothing, Any[ex], nothing, nothing, nothing)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#599#643")))
                end
                if begin
                            var"##639" = (var"##cache#601").value
                            var"##639" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##639"[1] == :where && (begin
                                    var"##640" = var"##639"[2]
                                    var"##640" isa AbstractArray
                                end && ((ndims(var"##640") === 1 && length(var"##640") >= 1) && begin
                                        var"##641" = var"##640"[1]
                                        var"##642" = SubArray(var"##640", (2:length(var"##640"),))
                                        true
                                    end)))
                    var"##return#598" = let call = var"##641", whereparams = var"##642"
                            sub_tuple = split_anonymous_function_head_nothrow(call)
                            isnothing(sub_tuple) && return nothing
                            (name, args, kw, _, rettype) = sub_tuple
                            (name, args, kw, whereparams, rettype)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#599#643")))
                end
            end
            begin
                var"##return#598" = let
                        nothing
                    end
                $(Expr(:symbolicgoto, Symbol("####final#599#643")))
            end
            error("matching non-exhaustive, at #= none:96 =#")
            $(Expr(:symboliclabel, Symbol("####final#599#643")))
            var"##return#598"
        end
    end
    split_anonymous_function_head_nothrow(s::Symbol) = begin
            (nothing, Any[s], nothing, nothing, nothing)
        end
    #= none:120 =# Core.@doc "    split_struct_name(ex::Expr) -> name, typevars, supertype\n\nSplit the name, type parameters and supertype definition from `struct`\ndeclaration head.\n" function split_struct_name(#= none:126 =# @nospecialize(ex); source = nothing)
            return let
                    begin
                        var"##cache#647" = nothing
                    end
                    var"##return#644" = nothing
                    var"##646" = ex
                    if var"##646" isa Expr
                        if begin
                                    if var"##cache#647" === nothing
                                        var"##cache#647" = Some(((var"##646").head, (var"##646").args))
                                    end
                                    var"##648" = (var"##cache#647").value
                                    var"##648" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##648"[1] == :curly && (begin
                                            var"##649" = var"##648"[2]
                                            var"##649" isa AbstractArray
                                        end && ((ndims(var"##649") === 1 && length(var"##649") >= 1) && begin
                                                var"##650" = var"##649"[1]
                                                var"##651" = SubArray(var"##649", (2:length(var"##649"),))
                                                true
                                            end)))
                            var"##return#644" = let typevars = var"##651", name = var"##650"
                                    (name, typevars, nothing)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#645#665")))
                        end
                        if begin
                                    var"##652" = (var"##cache#647").value
                                    var"##652" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##652"[1] == :<: && (begin
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
                                                    end && (var"##656"[1] == :curly && (begin
                                                                var"##657" = var"##656"[2]
                                                                var"##657" isa AbstractArray
                                                            end && ((ndims(var"##657") === 1 && length(var"##657") >= 1) && begin
                                                                    var"##658" = var"##657"[1]
                                                                    var"##659" = SubArray(var"##657", (2:length(var"##657"),))
                                                                    var"##660" = var"##653"[2]
                                                                    true
                                                                end))))))))
                            var"##return#644" = let typevars = var"##659", type = var"##660", name = var"##658"
                                    (name, typevars, type)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#645#665")))
                        end
                        if begin
                                    var"##661" = (var"##cache#647").value
                                    var"##661" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##661"[1] == :<: && (begin
                                            var"##662" = var"##661"[2]
                                            var"##662" isa AbstractArray
                                        end && (length(var"##662") === 2 && begin
                                                var"##663" = var"##662"[1]
                                                var"##664" = var"##662"[2]
                                                true
                                            end)))
                            var"##return#644" = let type = var"##664", name = var"##663"
                                    (name, [], type)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#645#665")))
                        end
                    end
                    if var"##646" isa Symbol
                        begin
                            var"##return#644" = let
                                    (ex, [], nothing)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#645#665")))
                        end
                    end
                    begin
                        var"##return#644" = let
                                throw(SyntaxError("expect struct got $(ex)", source))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#645#665")))
                    end
                    error("matching non-exhaustive, at #= none:127 =#")
                    $(Expr(:symboliclabel, Symbol("####final#645#665")))
                    var"##return#644"
                end
        end
    #= none:136 =# Core.@doc "    split_struct(ex::Expr) -> ismutable, name, typevars, supertype, body\n\nSplit struct definition head and body.\n" function split_struct(ex::Expr; source = nothing)
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
    #= none:193 =# Core.@doc "    uninferrable_typevars(def::Union{JLStruct, JLKwStruct}; leading_inferable::Bool=true)\n\nReturn the type variables that are not inferrable in given struct definition.\n" function uninferrable_typevars(def::Union{JLStruct, JLKwStruct}; leading_inferable::Bool = true)
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
    #= none:218 =# Core.@doc "    split_field_if_match(typename::Symbol, expr, default::Bool=false)\n\nSplit the field definition if it matches the given type name.\nReturns `NamedTuple` with `name`, `type`, `default` and `isconst` fields\nif it matches, otherwise return `nothing`.\n" function split_field_if_match(typename::Symbol, expr, default::Bool = false; source = nothing)
            begin
                begin
                    var"##cache#669" = nothing
                end
                var"##668" = expr
                if var"##668" isa Expr
                    if begin
                                if var"##cache#669" === nothing
                                    var"##cache#669" = Some(((var"##668").head, (var"##668").args))
                                end
                                var"##670" = (var"##cache#669").value
                                var"##670" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##670"[1] == :const && (begin
                                        var"##671" = var"##670"[2]
                                        var"##671" isa AbstractArray
                                    end && (length(var"##671") === 1 && (begin
                                                begin
                                                    var"##cache#673" = nothing
                                                end
                                                var"##672" = var"##671"[1]
                                                var"##672" isa Expr
                                            end && (begin
                                                    if var"##cache#673" === nothing
                                                        var"##cache#673" = Some(((var"##672").head, (var"##672").args))
                                                    end
                                                    var"##674" = (var"##cache#673").value
                                                    var"##674" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##674"[1] == :(=) && (begin
                                                            var"##675" = var"##674"[2]
                                                            var"##675" isa AbstractArray
                                                        end && (length(var"##675") === 2 && (begin
                                                                    begin
                                                                        var"##cache#677" = nothing
                                                                    end
                                                                    var"##676" = var"##675"[1]
                                                                    var"##676" isa Expr
                                                                end && (begin
                                                                        if var"##cache#677" === nothing
                                                                            var"##cache#677" = Some(((var"##676").head, (var"##676").args))
                                                                        end
                                                                        var"##678" = (var"##cache#677").value
                                                                        var"##678" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                    end && (var"##678"[1] == :(::) && (begin
                                                                                var"##679" = var"##678"[2]
                                                                                var"##679" isa AbstractArray
                                                                            end && (length(var"##679") === 2 && (begin
                                                                                        var"##680" = var"##679"[1]
                                                                                        var"##680" isa Symbol
                                                                                    end && begin
                                                                                        var"##681" = var"##679"[2]
                                                                                        var"##682" = var"##675"[2]
                                                                                        true
                                                                                    end))))))))))))))
                        value = var"##682"
                        type = var"##681"
                        name = var"##680"
                        var"##return#666" = begin
                                default && return (; name, type, isconst = true, default = value)
                                throw(SyntaxError("default value syntax is not allowed", source))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#667#719")))
                    end
                    if begin
                                var"##683" = (var"##cache#669").value
                                var"##683" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##683"[1] == :const && (begin
                                        var"##684" = var"##683"[2]
                                        var"##684" isa AbstractArray
                                    end && (length(var"##684") === 1 && (begin
                                                begin
                                                    var"##cache#686" = nothing
                                                end
                                                var"##685" = var"##684"[1]
                                                var"##685" isa Expr
                                            end && (begin
                                                    if var"##cache#686" === nothing
                                                        var"##cache#686" = Some(((var"##685").head, (var"##685").args))
                                                    end
                                                    var"##687" = (var"##cache#686").value
                                                    var"##687" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##687"[1] == :(=) && (begin
                                                            var"##688" = var"##687"[2]
                                                            var"##688" isa AbstractArray
                                                        end && (length(var"##688") === 2 && (begin
                                                                    var"##689" = var"##688"[1]
                                                                    var"##689" isa Symbol
                                                                end && begin
                                                                    var"##690" = var"##688"[2]
                                                                    true
                                                                end)))))))))
                        value = var"##690"
                        name = var"##689"
                        var"##return#666" = begin
                                default && return (; name, type = Any, isconst = true, default = value)
                                throw(SyntaxError("default value syntax is not allowed", source))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#667#719")))
                    end
                    if begin
                                var"##691" = (var"##cache#669").value
                                var"##691" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##691"[1] == :(=) && (begin
                                        var"##692" = var"##691"[2]
                                        var"##692" isa AbstractArray
                                    end && (length(var"##692") === 2 && (begin
                                                begin
                                                    var"##cache#694" = nothing
                                                end
                                                var"##693" = var"##692"[1]
                                                var"##693" isa Expr
                                            end && (begin
                                                    if var"##cache#694" === nothing
                                                        var"##cache#694" = Some(((var"##693").head, (var"##693").args))
                                                    end
                                                    var"##695" = (var"##cache#694").value
                                                    var"##695" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##695"[1] == :(::) && (begin
                                                            var"##696" = var"##695"[2]
                                                            var"##696" isa AbstractArray
                                                        end && (length(var"##696") === 2 && (begin
                                                                    var"##697" = var"##696"[1]
                                                                    var"##697" isa Symbol
                                                                end && begin
                                                                    var"##698" = var"##696"[2]
                                                                    var"##699" = var"##692"[2]
                                                                    true
                                                                end)))))))))
                        value = var"##699"
                        type = var"##698"
                        name = var"##697"
                        var"##return#666" = begin
                                default && return (; name, type, isconst = false, default = value)
                                throw(SyntaxError("default value syntax is not allowed", source))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#667#719")))
                    end
                    if begin
                                var"##700" = (var"##cache#669").value
                                var"##700" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##700"[1] == :(=) && (begin
                                        var"##701" = var"##700"[2]
                                        var"##701" isa AbstractArray
                                    end && (length(var"##701") === 2 && (begin
                                                var"##702" = var"##701"[1]
                                                var"##702" isa Symbol
                                            end && begin
                                                var"##703" = var"##701"[2]
                                                true
                                            end))))
                        value = var"##703"
                        name = var"##702"
                        var"##return#666" = begin
                                default && return (; name, type = Any, isconst = false, default = value)
                                throw(SyntaxError("default value syntax is not allowed", source))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#667#719")))
                    end
                    if begin
                                var"##704" = (var"##cache#669").value
                                var"##704" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##704"[1] == :const && (begin
                                        var"##705" = var"##704"[2]
                                        var"##705" isa AbstractArray
                                    end && (length(var"##705") === 1 && (begin
                                                begin
                                                    var"##cache#707" = nothing
                                                end
                                                var"##706" = var"##705"[1]
                                                var"##706" isa Expr
                                            end && (begin
                                                    if var"##cache#707" === nothing
                                                        var"##cache#707" = Some(((var"##706").head, (var"##706").args))
                                                    end
                                                    var"##708" = (var"##cache#707").value
                                                    var"##708" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##708"[1] == :(::) && (begin
                                                            var"##709" = var"##708"[2]
                                                            var"##709" isa AbstractArray
                                                        end && (length(var"##709") === 2 && (begin
                                                                    var"##710" = var"##709"[1]
                                                                    var"##710" isa Symbol
                                                                end && begin
                                                                    var"##711" = var"##709"[2]
                                                                    true
                                                                end)))))))))
                        type = var"##711"
                        name = var"##710"
                        var"##return#666" = begin
                                default && return (; name, type, isconst = true, default = no_default)
                                return (; name, type, isconst = true)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#667#719")))
                    end
                    if begin
                                var"##712" = (var"##cache#669").value
                                var"##712" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##712"[1] == :const && (begin
                                        var"##713" = var"##712"[2]
                                        var"##713" isa AbstractArray
                                    end && (length(var"##713") === 1 && begin
                                            var"##714" = var"##713"[1]
                                            var"##714" isa Symbol
                                        end)))
                        name = var"##714"
                        var"##return#666" = begin
                                default && return (; name, type = Any, isconst = true, default = no_default)
                                return (; name, type = Any, isconst = true)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#667#719")))
                    end
                    if begin
                                var"##715" = (var"##cache#669").value
                                var"##715" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##715"[1] == :(::) && (begin
                                        var"##716" = var"##715"[2]
                                        var"##716" isa AbstractArray
                                    end && (length(var"##716") === 2 && (begin
                                                var"##717" = var"##716"[1]
                                                var"##717" isa Symbol
                                            end && begin
                                                var"##718" = var"##716"[2]
                                                true
                                            end))))
                        type = var"##718"
                        name = var"##717"
                        var"##return#666" = begin
                                default && return (; name, type, isconst = false, default = no_default)
                                return (; name, type, isconst = false)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#667#719")))
                    end
                end
                if var"##668" isa Symbol
                    begin
                        name = var"##668"
                        var"##return#666" = begin
                                default && return (; name, type = Any, isconst = false, default = no_default)
                                return (; name, type = Any, isconst = false)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#667#719")))
                    end
                end
                if var"##668" isa String
                    begin
                        var"##return#666" = begin
                                return expr
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#667#719")))
                    end
                end
                if var"##668" isa LineNumberNode
                    begin
                        var"##return#666" = begin
                                return expr
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#667#719")))
                    end
                end
                if is_function(expr)
                    var"##return#666" = begin
                            if name_only(expr) === typename
                                return JLFunction(expr)
                            else
                                return expr
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#667#719")))
                end
                begin
                    var"##return#666" = begin
                            return expr
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#667#719")))
                end
                error("matching non-exhaustive, at #= none:226 =#")
                $(Expr(:symboliclabel, Symbol("####final#667#719")))
                var"##return#666"
            end
        end
