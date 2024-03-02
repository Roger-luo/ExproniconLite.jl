
    #= none:1 =# Core.@doc "    split_doc(ex::Expr) -> line, doc, expr\n\nSplit doc string from given expression.\n" function split_doc(ex::Expr)
            begin
                begin
                    var"##cache#504" = nothing
                end
                var"##503" = ex
                if var"##503" isa Expr
                    if begin
                                if var"##cache#504" === nothing
                                    var"##cache#504" = Some(((var"##503").head, (var"##503").args))
                                end
                                var"##505" = (var"##cache#504").value
                                var"##505" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##505"[1] == :macrocall && (begin
                                        var"##506" = var"##505"[2]
                                        var"##506" isa AbstractArray
                                    end && (length(var"##506") === 4 && (begin
                                                var"##507" = var"##506"[1]
                                                var"##507" == GlobalRef(Core, Symbol("@doc"))
                                            end && begin
                                                var"##508" = var"##506"[2]
                                                var"##509" = var"##506"[3]
                                                var"##510" = var"##506"[4]
                                                true
                                            end))))
                        line = var"##508"
                        expr = var"##510"
                        doc = var"##509"
                        var"##return#501" = begin
                                return (line, doc, expr)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#502#531")))
                    end
                    if begin
                                var"##511" = (var"##cache#504").value
                                var"##511" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##511"[1] == :macrocall && (begin
                                        var"##512" = var"##511"[2]
                                        var"##512" isa AbstractArray
                                    end && (length(var"##512") === 4 && (begin
                                                var"##513" = var"##512"[1]
                                                var"##513" == Symbol("@doc")
                                            end && begin
                                                var"##514" = var"##512"[2]
                                                var"##515" = var"##512"[3]
                                                var"##516" = var"##512"[4]
                                                true
                                            end))))
                        line = var"##514"
                        expr = var"##516"
                        doc = var"##515"
                        var"##return#501" = begin
                                return (line, doc, expr)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#502#531")))
                    end
                    if begin
                                var"##517" = (var"##cache#504").value
                                var"##517" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##517"[1] == :macrocall && (begin
                                        var"##518" = var"##517"[2]
                                        var"##518" isa AbstractArray
                                    end && (length(var"##518") === 4 && (begin
                                                begin
                                                    var"##cache#520" = nothing
                                                end
                                                var"##519" = var"##518"[1]
                                                var"##519" isa Expr
                                            end && (begin
                                                    if var"##cache#520" === nothing
                                                        var"##cache#520" = Some(((var"##519").head, (var"##519").args))
                                                    end
                                                    var"##521" = (var"##cache#520").value
                                                    var"##521" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##521"[1] == :. && (begin
                                                            var"##522" = var"##521"[2]
                                                            var"##522" isa AbstractArray
                                                        end && (length(var"##522") === 2 && (var"##522"[1] == :Core && (begin
                                                                        var"##523" = var"##522"[2]
                                                                        var"##523" == QuoteNode(Symbol("@doc"))
                                                                    end && begin
                                                                        var"##524" = var"##518"[2]
                                                                        var"##525" = var"##518"[3]
                                                                        var"##526" = var"##518"[4]
                                                                        true
                                                                    end))))))))))
                        line = var"##524"
                        expr = var"##526"
                        doc = var"##525"
                        var"##return#501" = begin
                                return (line, doc, expr)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#502#531")))
                    end
                    if begin
                                var"##527" = (var"##cache#504").value
                                var"##527" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##527"[1] == :block && (begin
                                        var"##528" = var"##527"[2]
                                        var"##528" isa AbstractArray
                                    end && (length(var"##528") === 2 && (begin
                                                var"##529" = var"##528"[1]
                                                var"##529" isa LineNumberNode
                                            end && begin
                                                var"##530" = var"##528"[2]
                                                true
                                            end))))
                        stmt = var"##530"
                        var"##return#501" = begin
                                (line, doc, expr) = split_doc(stmt)
                                return (line, doc, expr)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#502#531")))
                    end
                end
                begin
                    var"##return#501" = begin
                            return (nothing, nothing, ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#502#531")))
                end
                error("matching non-exhaustive, at #= none:7 =#")
                $(Expr(:symboliclabel, Symbol("####final#502#531")))
                var"##return#501"
            end
        end
    #= none:24 =# Core.@doc "    split_function(ex::Expr) -> head, call, body\n\nSplit function head declaration with function body.\n" function split_function(ex::Expr; source = nothing)
            let
                begin
                    var"##cache#535" = nothing
                end
                var"##return#532" = nothing
                var"##534" = ex
                if var"##534" isa Expr
                    if begin
                                if var"##cache#535" === nothing
                                    var"##cache#535" = Some(((var"##534").head, (var"##534").args))
                                end
                                var"##536" = (var"##cache#535").value
                                var"##536" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##536"[1] == :function && (begin
                                        var"##537" = var"##536"[2]
                                        var"##537" isa AbstractArray
                                    end && (length(var"##537") === 2 && begin
                                            var"##538" = var"##537"[1]
                                            var"##539" = var"##537"[2]
                                            true
                                        end)))
                        var"##return#532" = let call = var"##538", body = var"##539"
                                (:function, call, body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#533#548")))
                    end
                    if begin
                                var"##540" = (var"##cache#535").value
                                var"##540" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##540"[1] == :(=) && (begin
                                        var"##541" = var"##540"[2]
                                        var"##541" isa AbstractArray
                                    end && (length(var"##541") === 2 && begin
                                            var"##542" = var"##541"[1]
                                            var"##543" = var"##541"[2]
                                            true
                                        end)))
                        var"##return#532" = let call = var"##542", body = var"##543"
                                (:(=), call, body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#533#548")))
                    end
                    if begin
                                var"##544" = (var"##cache#535").value
                                var"##544" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##544"[1] == :-> && (begin
                                        var"##545" = var"##544"[2]
                                        var"##545" isa AbstractArray
                                    end && (length(var"##545") === 2 && begin
                                            var"##546" = var"##545"[1]
                                            var"##547" = var"##545"[2]
                                            true
                                        end)))
                        var"##return#532" = let call = var"##546", body = var"##547"
                                (:->, call, body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#533#548")))
                    end
                end
                begin
                    var"##return#532" = let
                            throw(SyntaxError("expect a function expr, got $(ex)", source))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#533#548")))
                end
                error("matching non-exhaustive, at #= none:30 =#")
                $(Expr(:symboliclabel, Symbol("####final#533#548")))
                var"##return#532"
            end
        end
    #= none:38 =# Core.@doc "    split_function_head(ex::Expr) -> name, args, kw, whereparams, rettype\n\nSplit function head to name, arguments, keyword arguments and where parameters.\n" function split_function_head(ex::Expr; source = nothing)
            let
                begin
                    var"##cache#552" = nothing
                end
                var"##return#549" = nothing
                var"##551" = ex
                if var"##551" isa Expr
                    if begin
                                if var"##cache#552" === nothing
                                    var"##cache#552" = Some(((var"##551").head, (var"##551").args))
                                end
                                var"##553" = (var"##cache#552").value
                                var"##553" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##553"[1] == :tuple && (begin
                                        var"##554" = var"##553"[2]
                                        var"##554" isa AbstractArray
                                    end && ((ndims(var"##554") === 1 && length(var"##554") >= 1) && (begin
                                                begin
                                                    var"##cache#556" = nothing
                                                end
                                                var"##555" = var"##554"[1]
                                                var"##555" isa Expr
                                            end && (begin
                                                    if var"##cache#556" === nothing
                                                        var"##cache#556" = Some(((var"##555").head, (var"##555").args))
                                                    end
                                                    var"##557" = (var"##cache#556").value
                                                    var"##557" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##557"[1] == :parameters && (begin
                                                            var"##558" = var"##557"[2]
                                                            var"##558" isa AbstractArray
                                                        end && ((ndims(var"##558") === 1 && length(var"##558") >= 0) && begin
                                                                var"##559" = SubArray(var"##558", (1:length(var"##558"),))
                                                                var"##560" = SubArray(var"##554", (2:length(var"##554"),))
                                                                true
                                                            end))))))))
                        var"##return#549" = let args = var"##560", kw = var"##559"
                                (nothing, args, kw, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#550#600")))
                    end
                    if begin
                                var"##561" = (var"##cache#552").value
                                var"##561" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##561"[1] == :tuple && (begin
                                        var"##562" = var"##561"[2]
                                        var"##562" isa AbstractArray
                                    end && ((ndims(var"##562") === 1 && length(var"##562") >= 0) && begin
                                            var"##563" = SubArray(var"##562", (1:length(var"##562"),))
                                            true
                                        end)))
                        var"##return#549" = let args = var"##563"
                                (nothing, args, nothing, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#550#600")))
                    end
                    if begin
                                var"##564" = (var"##cache#552").value
                                var"##564" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##564"[1] == :call && (begin
                                        var"##565" = var"##564"[2]
                                        var"##565" isa AbstractArray
                                    end && ((ndims(var"##565") === 1 && length(var"##565") >= 2) && (begin
                                                var"##566" = var"##565"[1]
                                                begin
                                                    var"##cache#568" = nothing
                                                end
                                                var"##567" = var"##565"[2]
                                                var"##567" isa Expr
                                            end && (begin
                                                    if var"##cache#568" === nothing
                                                        var"##cache#568" = Some(((var"##567").head, (var"##567").args))
                                                    end
                                                    var"##569" = (var"##cache#568").value
                                                    var"##569" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##569"[1] == :parameters && (begin
                                                            var"##570" = var"##569"[2]
                                                            var"##570" isa AbstractArray
                                                        end && ((ndims(var"##570") === 1 && length(var"##570") >= 0) && begin
                                                                var"##571" = SubArray(var"##570", (1:length(var"##570"),))
                                                                var"##572" = SubArray(var"##565", (3:length(var"##565"),))
                                                                true
                                                            end))))))))
                        var"##return#549" = let name = var"##566", args = var"##572", kw = var"##571"
                                (name, args, kw, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#550#600")))
                    end
                    if begin
                                var"##573" = (var"##cache#552").value
                                var"##573" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##573"[1] == :call && (begin
                                        var"##574" = var"##573"[2]
                                        var"##574" isa AbstractArray
                                    end && ((ndims(var"##574") === 1 && length(var"##574") >= 1) && begin
                                            var"##575" = var"##574"[1]
                                            var"##576" = SubArray(var"##574", (2:length(var"##574"),))
                                            true
                                        end)))
                        var"##return#549" = let name = var"##575", args = var"##576"
                                (name, args, nothing, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#550#600")))
                    end
                    if begin
                                var"##577" = (var"##cache#552").value
                                var"##577" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##577"[1] == :block && (begin
                                        var"##578" = var"##577"[2]
                                        var"##578" isa AbstractArray
                                    end && (length(var"##578") === 3 && (begin
                                                var"##579" = var"##578"[1]
                                                var"##580" = var"##578"[2]
                                                var"##580" isa LineNumberNode
                                            end && (begin
                                                    begin
                                                        var"##cache#582" = nothing
                                                    end
                                                    var"##581" = var"##578"[3]
                                                    var"##581" isa Expr
                                                end && (begin
                                                        if var"##cache#582" === nothing
                                                            var"##cache#582" = Some(((var"##581").head, (var"##581").args))
                                                        end
                                                        var"##583" = (var"##cache#582").value
                                                        var"##583" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                    end && (var"##583"[1] == :(=) && (begin
                                                                var"##584" = var"##583"[2]
                                                                var"##584" isa AbstractArray
                                                            end && (length(var"##584") === 2 && begin
                                                                    var"##585" = var"##584"[1]
                                                                    var"##586" = var"##584"[2]
                                                                    true
                                                                end)))))))))
                        var"##return#549" = let value = var"##586", kw = var"##585", x = var"##579"
                                (nothing, Any[x], Any[Expr(:kw, kw, value)], nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#550#600")))
                    end
                    if begin
                                var"##587" = (var"##cache#552").value
                                var"##587" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##587"[1] == :block && (begin
                                        var"##588" = var"##587"[2]
                                        var"##588" isa AbstractArray
                                    end && (length(var"##588") === 3 && (begin
                                                var"##589" = var"##588"[1]
                                                var"##590" = var"##588"[2]
                                                var"##590" isa LineNumberNode
                                            end && begin
                                                var"##591" = var"##588"[3]
                                                true
                                            end))))
                        var"##return#549" = let kw = var"##591", x = var"##589"
                                (nothing, Any[x], Any[kw], nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#550#600")))
                    end
                    if begin
                                var"##592" = (var"##cache#552").value
                                var"##592" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##592"[1] == :(::) && (begin
                                        var"##593" = var"##592"[2]
                                        var"##593" isa AbstractArray
                                    end && (length(var"##593") === 2 && (begin
                                                var"##594" = var"##593"[1]
                                                var"##594" isa Expr
                                            end && begin
                                                var"##595" = var"##593"[2]
                                                true
                                            end))))
                        var"##return#549" = let call = var"##594", rettype = var"##595"
                                (name, args, kw, whereparams, _) = split_function_head(call)
                                (name, args, kw, whereparams, rettype)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#550#600")))
                    end
                    if begin
                                var"##596" = (var"##cache#552").value
                                var"##596" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##596"[1] == :where && (begin
                                        var"##597" = var"##596"[2]
                                        var"##597" isa AbstractArray
                                    end && ((ndims(var"##597") === 1 && length(var"##597") >= 1) && begin
                                            var"##598" = var"##597"[1]
                                            var"##599" = SubArray(var"##597", (2:length(var"##597"),))
                                            true
                                        end)))
                        var"##return#549" = let call = var"##598", whereparams = var"##599"
                                (name, args, kw, _, rettype) = split_function_head(call)
                                (name, args, kw, whereparams, rettype)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#550#600")))
                    end
                end
                begin
                    var"##return#549" = let
                            throw(SyntaxError("expect a function head, got $(ex)", source))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#550#600")))
                end
                error("matching non-exhaustive, at #= none:44 =#")
                $(Expr(:symboliclabel, Symbol("####final#550#600")))
                var"##return#549"
            end
        end
    split_function_head(s::Symbol; source = nothing) = begin
            (nothing, Any[s], nothing, nothing, nothing)
        end
    #= none:64 =# Core.@doc "    split_anonymous_function_head(ex::Expr) -> nothing, args, kw, whereparams, rettype\n\nSplit anonymous function head to arguments, keyword arguments and where parameters.\n" function split_anonymous_function_head(ex::Expr; source = nothing)
            let
                begin
                    var"##cache#604" = nothing
                end
                var"##return#601" = nothing
                var"##603" = ex
                if var"##603" isa Expr
                    if begin
                                if var"##cache#604" === nothing
                                    var"##cache#604" = Some(((var"##603").head, (var"##603").args))
                                end
                                var"##605" = (var"##cache#604").value
                                var"##605" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##605"[1] == :tuple && (begin
                                        var"##606" = var"##605"[2]
                                        var"##606" isa AbstractArray
                                    end && ((ndims(var"##606") === 1 && length(var"##606") >= 1) && (begin
                                                begin
                                                    var"##cache#608" = nothing
                                                end
                                                var"##607" = var"##606"[1]
                                                var"##607" isa Expr
                                            end && (begin
                                                    if var"##cache#608" === nothing
                                                        var"##cache#608" = Some(((var"##607").head, (var"##607").args))
                                                    end
                                                    var"##609" = (var"##cache#608").value
                                                    var"##609" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##609"[1] == :parameters && (begin
                                                            var"##610" = var"##609"[2]
                                                            var"##610" isa AbstractArray
                                                        end && ((ndims(var"##610") === 1 && length(var"##610") >= 0) && begin
                                                                var"##611" = SubArray(var"##610", (1:length(var"##610"),))
                                                                var"##612" = SubArray(var"##606", (2:length(var"##606"),))
                                                                true
                                                            end))))))))
                        var"##return#601" = let args = var"##612", kw = var"##611"
                                (nothing, args, kw, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#602#646")))
                    end
                    if begin
                                var"##613" = (var"##cache#604").value
                                var"##613" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##613"[1] == :tuple && (begin
                                        var"##614" = var"##613"[2]
                                        var"##614" isa AbstractArray
                                    end && ((ndims(var"##614") === 1 && length(var"##614") >= 0) && begin
                                            var"##615" = SubArray(var"##614", (1:length(var"##614"),))
                                            true
                                        end)))
                        var"##return#601" = let args = var"##615"
                                (nothing, args, nothing, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#602#646")))
                    end
                    if begin
                                var"##616" = (var"##cache#604").value
                                var"##616" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##616"[1] == :block && (begin
                                        var"##617" = var"##616"[2]
                                        var"##617" isa AbstractArray
                                    end && (length(var"##617") === 3 && (begin
                                                var"##618" = var"##617"[1]
                                                var"##619" = var"##617"[2]
                                                var"##619" isa LineNumberNode
                                            end && (begin
                                                    begin
                                                        var"##cache#621" = nothing
                                                    end
                                                    var"##620" = var"##617"[3]
                                                    var"##620" isa Expr
                                                end && (begin
                                                        if var"##cache#621" === nothing
                                                            var"##cache#621" = Some(((var"##620").head, (var"##620").args))
                                                        end
                                                        var"##622" = (var"##cache#621").value
                                                        var"##622" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                    end && (var"##622"[1] == :(=) && (begin
                                                                var"##623" = var"##622"[2]
                                                                var"##623" isa AbstractArray
                                                            end && (length(var"##623") === 2 && begin
                                                                    var"##624" = var"##623"[1]
                                                                    var"##625" = var"##623"[2]
                                                                    true
                                                                end)))))))))
                        var"##return#601" = let value = var"##625", kw = var"##624", x = var"##618"
                                (nothing, Any[x], Any[Expr(:kw, kw, value)], nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#602#646")))
                    end
                    if begin
                                var"##626" = (var"##cache#604").value
                                var"##626" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##626"[1] == :block && (begin
                                        var"##627" = var"##626"[2]
                                        var"##627" isa AbstractArray
                                    end && (length(var"##627") === 3 && (begin
                                                var"##628" = var"##627"[1]
                                                var"##629" = var"##627"[2]
                                                var"##629" isa LineNumberNode
                                            end && begin
                                                var"##630" = var"##627"[3]
                                                true
                                            end))))
                        var"##return#601" = let kw = var"##630", x = var"##628"
                                (nothing, Any[x], Any[kw], nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#602#646")))
                    end
                    if begin
                                var"##631" = (var"##cache#604").value
                                var"##631" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##631"[1] == :(::) && (begin
                                        var"##632" = var"##631"[2]
                                        var"##632" isa AbstractArray
                                    end && (length(var"##632") === 2 && (begin
                                                var"##633" = var"##632"[1]
                                                var"##633" isa Expr
                                            end && begin
                                                var"##634" = var"##632"[2]
                                                true
                                            end))))
                        var"##return#601" = let rettype = var"##634", fh = var"##633"
                                (name, args, kw, whereparams, _) = split_anonymous_function_head(fh)
                                (name, args, kw, whereparams, rettype)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#602#646")))
                    end
                    if begin
                                var"##635" = (var"##cache#604").value
                                var"##635" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##635"[1] == :(::) && (begin
                                        var"##636" = var"##635"[2]
                                        var"##636" isa AbstractArray
                                    end && (length(var"##636") === 2 && (begin
                                                var"##637" = var"##636"[1]
                                                var"##637" isa Symbol
                                            end && begin
                                                var"##638" = var"##636"[2]
                                                true
                                            end))))
                        var"##return#601" = let arg = var"##637", argtype = var"##638"
                                (nothing, Any[ex], nothing, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#602#646")))
                    end
                    if begin
                                var"##639" = (var"##cache#604").value
                                var"##639" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##639"[1] == :(::) && (begin
                                        var"##640" = var"##639"[2]
                                        var"##640" isa AbstractArray
                                    end && (length(var"##640") === 1 && begin
                                            var"##641" = var"##640"[1]
                                            true
                                        end)))
                        var"##return#601" = let argtype = var"##641"
                                (nothing, Any[ex], nothing, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#602#646")))
                    end
                    if begin
                                var"##642" = (var"##cache#604").value
                                var"##642" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##642"[1] == :where && (begin
                                        var"##643" = var"##642"[2]
                                        var"##643" isa AbstractArray
                                    end && ((ndims(var"##643") === 1 && length(var"##643") >= 1) && begin
                                            var"##644" = var"##643"[1]
                                            var"##645" = SubArray(var"##643", (2:length(var"##643"),))
                                            true
                                        end)))
                        var"##return#601" = let call = var"##644", whereparams = var"##645"
                                (name, args, kw, _, rettype) = split_anonymous_function_head(call)
                                (name, args, kw, whereparams, rettype)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#602#646")))
                    end
                end
                begin
                    var"##return#601" = let
                            throw(SyntaxError("expect an anonymous function head, got $(ex)", source))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#602#646")))
                end
                error("matching non-exhaustive, at #= none:70 =#")
                $(Expr(:symboliclabel, Symbol("####final#602#646")))
                var"##return#601"
            end
        end
    split_anonymous_function_head(s::Symbol; source = nothing) = begin
            (nothing, Any[s], nothing, nothing, nothing)
        end
    #= none:89 =# Core.@doc "    split_struct_name(ex::Expr) -> name, typevars, supertype\n\nSplit the name, type parameters and supertype definition from `struct`\ndeclaration head.\n" function split_struct_name(#= none:95 =# @nospecialize(ex); source = nothing)
            return let
                    begin
                        var"##cache#650" = nothing
                    end
                    var"##return#647" = nothing
                    var"##649" = ex
                    if var"##649" isa Expr
                        if begin
                                    if var"##cache#650" === nothing
                                        var"##cache#650" = Some(((var"##649").head, (var"##649").args))
                                    end
                                    var"##651" = (var"##cache#650").value
                                    var"##651" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##651"[1] == :curly && (begin
                                            var"##652" = var"##651"[2]
                                            var"##652" isa AbstractArray
                                        end && ((ndims(var"##652") === 1 && length(var"##652") >= 1) && begin
                                                var"##653" = var"##652"[1]
                                                var"##654" = SubArray(var"##652", (2:length(var"##652"),))
                                                true
                                            end)))
                            var"##return#647" = let typevars = var"##654", name = var"##653"
                                    (name, typevars, nothing)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#648#668")))
                        end
                        if begin
                                    var"##655" = (var"##cache#650").value
                                    var"##655" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##655"[1] == :<: && (begin
                                            var"##656" = var"##655"[2]
                                            var"##656" isa AbstractArray
                                        end && (length(var"##656") === 2 && (begin
                                                    begin
                                                        var"##cache#658" = nothing
                                                    end
                                                    var"##657" = var"##656"[1]
                                                    var"##657" isa Expr
                                                end && (begin
                                                        if var"##cache#658" === nothing
                                                            var"##cache#658" = Some(((var"##657").head, (var"##657").args))
                                                        end
                                                        var"##659" = (var"##cache#658").value
                                                        var"##659" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                    end && (var"##659"[1] == :curly && (begin
                                                                var"##660" = var"##659"[2]
                                                                var"##660" isa AbstractArray
                                                            end && ((ndims(var"##660") === 1 && length(var"##660") >= 1) && begin
                                                                    var"##661" = var"##660"[1]
                                                                    var"##662" = SubArray(var"##660", (2:length(var"##660"),))
                                                                    var"##663" = var"##656"[2]
                                                                    true
                                                                end))))))))
                            var"##return#647" = let typevars = var"##662", type = var"##663", name = var"##661"
                                    (name, typevars, type)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#648#668")))
                        end
                        if begin
                                    var"##664" = (var"##cache#650").value
                                    var"##664" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##664"[1] == :<: && (begin
                                            var"##665" = var"##664"[2]
                                            var"##665" isa AbstractArray
                                        end && (length(var"##665") === 2 && begin
                                                var"##666" = var"##665"[1]
                                                var"##667" = var"##665"[2]
                                                true
                                            end)))
                            var"##return#647" = let type = var"##667", name = var"##666"
                                    (name, [], type)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#648#668")))
                        end
                    end
                    if var"##649" isa Symbol
                        begin
                            var"##return#647" = let
                                    (ex, [], nothing)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#648#668")))
                        end
                    end
                    begin
                        var"##return#647" = let
                                throw(SyntaxError("expect struct got $(ex)", source))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#648#668")))
                    end
                    error("matching non-exhaustive, at #= none:96 =#")
                    $(Expr(:symboliclabel, Symbol("####final#648#668")))
                    var"##return#647"
                end
        end
    #= none:105 =# Core.@doc "    split_struct(ex::Expr) -> ismutable, name, typevars, supertype, body\n\nSplit struct definition head and body.\n" function split_struct(ex::Expr; source = nothing)
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
    #= none:162 =# Core.@doc "    uninferrable_typevars(def::Union{JLStruct, JLKwStruct}; leading_inferable::Bool=true)\n\nReturn the type variables that are not inferrable in given struct definition.\n" function uninferrable_typevars(def::Union{JLStruct, JLKwStruct}; leading_inferable::Bool = true)
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
    #= none:187 =# Core.@doc "    split_field_if_match(typename::Symbol, expr, default::Bool=false)\n\nSplit the field definition if it matches the given type name.\nReturns `NamedTuple` with `name`, `type`, `default` and `isconst` fields\nif it matches, otherwise return `nothing`.\n" function split_field_if_match(typename::Symbol, expr, default::Bool = false; source = nothing)
            begin
                begin
                    var"##cache#672" = nothing
                end
                var"##671" = expr
                if var"##671" isa Expr
                    if begin
                                if var"##cache#672" === nothing
                                    var"##cache#672" = Some(((var"##671").head, (var"##671").args))
                                end
                                var"##673" = (var"##cache#672").value
                                var"##673" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##673"[1] == :const && (begin
                                        var"##674" = var"##673"[2]
                                        var"##674" isa AbstractArray
                                    end && (length(var"##674") === 1 && (begin
                                                begin
                                                    var"##cache#676" = nothing
                                                end
                                                var"##675" = var"##674"[1]
                                                var"##675" isa Expr
                                            end && (begin
                                                    if var"##cache#676" === nothing
                                                        var"##cache#676" = Some(((var"##675").head, (var"##675").args))
                                                    end
                                                    var"##677" = (var"##cache#676").value
                                                    var"##677" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##677"[1] == :(=) && (begin
                                                            var"##678" = var"##677"[2]
                                                            var"##678" isa AbstractArray
                                                        end && (length(var"##678") === 2 && (begin
                                                                    begin
                                                                        var"##cache#680" = nothing
                                                                    end
                                                                    var"##679" = var"##678"[1]
                                                                    var"##679" isa Expr
                                                                end && (begin
                                                                        if var"##cache#680" === nothing
                                                                            var"##cache#680" = Some(((var"##679").head, (var"##679").args))
                                                                        end
                                                                        var"##681" = (var"##cache#680").value
                                                                        var"##681" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                    end && (var"##681"[1] == :(::) && (begin
                                                                                var"##682" = var"##681"[2]
                                                                                var"##682" isa AbstractArray
                                                                            end && (length(var"##682") === 2 && (begin
                                                                                        var"##683" = var"##682"[1]
                                                                                        var"##683" isa Symbol
                                                                                    end && begin
                                                                                        var"##684" = var"##682"[2]
                                                                                        var"##685" = var"##678"[2]
                                                                                        true
                                                                                    end))))))))))))))
                        value = var"##685"
                        type = var"##684"
                        name = var"##683"
                        var"##return#669" = begin
                                default && return (; name, type, isconst = true, default = value)
                                throw(SyntaxError("default value syntax is not allowed", source))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#670#722")))
                    end
                    if begin
                                var"##686" = (var"##cache#672").value
                                var"##686" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##686"[1] == :const && (begin
                                        var"##687" = var"##686"[2]
                                        var"##687" isa AbstractArray
                                    end && (length(var"##687") === 1 && (begin
                                                begin
                                                    var"##cache#689" = nothing
                                                end
                                                var"##688" = var"##687"[1]
                                                var"##688" isa Expr
                                            end && (begin
                                                    if var"##cache#689" === nothing
                                                        var"##cache#689" = Some(((var"##688").head, (var"##688").args))
                                                    end
                                                    var"##690" = (var"##cache#689").value
                                                    var"##690" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##690"[1] == :(=) && (begin
                                                            var"##691" = var"##690"[2]
                                                            var"##691" isa AbstractArray
                                                        end && (length(var"##691") === 2 && (begin
                                                                    var"##692" = var"##691"[1]
                                                                    var"##692" isa Symbol
                                                                end && begin
                                                                    var"##693" = var"##691"[2]
                                                                    true
                                                                end)))))))))
                        value = var"##693"
                        name = var"##692"
                        var"##return#669" = begin
                                default && return (; name, type = Any, isconst = true, default = value)
                                throw(SyntaxError("default value syntax is not allowed", source))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#670#722")))
                    end
                    if begin
                                var"##694" = (var"##cache#672").value
                                var"##694" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##694"[1] == :(=) && (begin
                                        var"##695" = var"##694"[2]
                                        var"##695" isa AbstractArray
                                    end && (length(var"##695") === 2 && (begin
                                                begin
                                                    var"##cache#697" = nothing
                                                end
                                                var"##696" = var"##695"[1]
                                                var"##696" isa Expr
                                            end && (begin
                                                    if var"##cache#697" === nothing
                                                        var"##cache#697" = Some(((var"##696").head, (var"##696").args))
                                                    end
                                                    var"##698" = (var"##cache#697").value
                                                    var"##698" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##698"[1] == :(::) && (begin
                                                            var"##699" = var"##698"[2]
                                                            var"##699" isa AbstractArray
                                                        end && (length(var"##699") === 2 && (begin
                                                                    var"##700" = var"##699"[1]
                                                                    var"##700" isa Symbol
                                                                end && begin
                                                                    var"##701" = var"##699"[2]
                                                                    var"##702" = var"##695"[2]
                                                                    true
                                                                end)))))))))
                        value = var"##702"
                        type = var"##701"
                        name = var"##700"
                        var"##return#669" = begin
                                default && return (; name, type, isconst = false, default = value)
                                throw(SyntaxError("default value syntax is not allowed", source))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#670#722")))
                    end
                    if begin
                                var"##703" = (var"##cache#672").value
                                var"##703" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##703"[1] == :(=) && (begin
                                        var"##704" = var"##703"[2]
                                        var"##704" isa AbstractArray
                                    end && (length(var"##704") === 2 && (begin
                                                var"##705" = var"##704"[1]
                                                var"##705" isa Symbol
                                            end && begin
                                                var"##706" = var"##704"[2]
                                                true
                                            end))))
                        value = var"##706"
                        name = var"##705"
                        var"##return#669" = begin
                                default && return (; name, type = Any, isconst = false, default = value)
                                throw(SyntaxError("default value syntax is not allowed", source))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#670#722")))
                    end
                    if begin
                                var"##707" = (var"##cache#672").value
                                var"##707" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##707"[1] == :const && (begin
                                        var"##708" = var"##707"[2]
                                        var"##708" isa AbstractArray
                                    end && (length(var"##708") === 1 && (begin
                                                begin
                                                    var"##cache#710" = nothing
                                                end
                                                var"##709" = var"##708"[1]
                                                var"##709" isa Expr
                                            end && (begin
                                                    if var"##cache#710" === nothing
                                                        var"##cache#710" = Some(((var"##709").head, (var"##709").args))
                                                    end
                                                    var"##711" = (var"##cache#710").value
                                                    var"##711" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##711"[1] == :(::) && (begin
                                                            var"##712" = var"##711"[2]
                                                            var"##712" isa AbstractArray
                                                        end && (length(var"##712") === 2 && (begin
                                                                    var"##713" = var"##712"[1]
                                                                    var"##713" isa Symbol
                                                                end && begin
                                                                    var"##714" = var"##712"[2]
                                                                    true
                                                                end)))))))))
                        type = var"##714"
                        name = var"##713"
                        var"##return#669" = begin
                                default && return (; name, type, isconst = true, default = no_default)
                                return (; name, type, isconst = true)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#670#722")))
                    end
                    if begin
                                var"##715" = (var"##cache#672").value
                                var"##715" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##715"[1] == :const && (begin
                                        var"##716" = var"##715"[2]
                                        var"##716" isa AbstractArray
                                    end && (length(var"##716") === 1 && begin
                                            var"##717" = var"##716"[1]
                                            var"##717" isa Symbol
                                        end)))
                        name = var"##717"
                        var"##return#669" = begin
                                default && return (; name, type = Any, isconst = true, default = no_default)
                                return (; name, type = Any, isconst = true)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#670#722")))
                    end
                    if begin
                                var"##718" = (var"##cache#672").value
                                var"##718" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##718"[1] == :(::) && (begin
                                        var"##719" = var"##718"[2]
                                        var"##719" isa AbstractArray
                                    end && (length(var"##719") === 2 && (begin
                                                var"##720" = var"##719"[1]
                                                var"##720" isa Symbol
                                            end && begin
                                                var"##721" = var"##719"[2]
                                                true
                                            end))))
                        type = var"##721"
                        name = var"##720"
                        var"##return#669" = begin
                                default && return (; name, type, isconst = false, default = no_default)
                                return (; name, type, isconst = false)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#670#722")))
                    end
                end
                if var"##671" isa Symbol
                    begin
                        name = var"##671"
                        var"##return#669" = begin
                                default && return (; name, type = Any, isconst = false, default = no_default)
                                return (; name, type = Any, isconst = false)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#670#722")))
                    end
                end
                if var"##671" isa String
                    begin
                        var"##return#669" = begin
                                return expr
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#670#722")))
                    end
                end
                if var"##671" isa LineNumberNode
                    begin
                        var"##return#669" = begin
                                return expr
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#670#722")))
                    end
                end
                if is_function(expr)
                    var"##return#669" = begin
                            if name_only(expr) === typename
                                return JLFunction(expr)
                            else
                                return expr
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#670#722")))
                end
                begin
                    var"##return#669" = begin
                            return expr
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#670#722")))
                end
                error("matching non-exhaustive, at #= none:195 =#")
                $(Expr(:symboliclabel, Symbol("####final#670#722")))
                var"##return#669"
            end
        end
