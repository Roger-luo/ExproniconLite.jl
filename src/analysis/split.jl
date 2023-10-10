
    #= none:1 =# Core.@doc "    split_doc(ex::Expr) -> line, doc, expr\n\nSplit doc string from given expression.\n" function split_doc(ex::Expr)
            begin
                begin
                    var"##cache#500" = nothing
                end
                var"##499" = ex
                if var"##499" isa Expr
                    if begin
                                if var"##cache#500" === nothing
                                    var"##cache#500" = Some(((var"##499").head, (var"##499").args))
                                end
                                var"##501" = (var"##cache#500").value
                                var"##501" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##501"[1] == :macrocall && (begin
                                        var"##502" = var"##501"[2]
                                        var"##502" isa AbstractArray
                                    end && (length(var"##502") === 4 && (begin
                                                var"##503" = var"##502"[1]
                                                var"##503" == GlobalRef(Core, Symbol("@doc"))
                                            end && begin
                                                var"##504" = var"##502"[2]
                                                var"##505" = var"##502"[3]
                                                var"##506" = var"##502"[4]
                                                true
                                            end))))
                        line = var"##504"
                        expr = var"##506"
                        doc = var"##505"
                        var"##return#497" = begin
                                return (line, doc, expr)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#498#527")))
                    end
                    if begin
                                var"##507" = (var"##cache#500").value
                                var"##507" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##507"[1] == :macrocall && (begin
                                        var"##508" = var"##507"[2]
                                        var"##508" isa AbstractArray
                                    end && (length(var"##508") === 4 && (begin
                                                var"##509" = var"##508"[1]
                                                var"##509" == Symbol("@doc")
                                            end && begin
                                                var"##510" = var"##508"[2]
                                                var"##511" = var"##508"[3]
                                                var"##512" = var"##508"[4]
                                                true
                                            end))))
                        line = var"##510"
                        expr = var"##512"
                        doc = var"##511"
                        var"##return#497" = begin
                                return (line, doc, expr)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#498#527")))
                    end
                    if begin
                                var"##513" = (var"##cache#500").value
                                var"##513" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##513"[1] == :macrocall && (begin
                                        var"##514" = var"##513"[2]
                                        var"##514" isa AbstractArray
                                    end && (length(var"##514") === 4 && (begin
                                                begin
                                                    var"##cache#516" = nothing
                                                end
                                                var"##515" = var"##514"[1]
                                                var"##515" isa Expr
                                            end && (begin
                                                    if var"##cache#516" === nothing
                                                        var"##cache#516" = Some(((var"##515").head, (var"##515").args))
                                                    end
                                                    var"##517" = (var"##cache#516").value
                                                    var"##517" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##517"[1] == :. && (begin
                                                            var"##518" = var"##517"[2]
                                                            var"##518" isa AbstractArray
                                                        end && (length(var"##518") === 2 && (var"##518"[1] == :Core && (begin
                                                                        var"##519" = var"##518"[2]
                                                                        var"##519" == QuoteNode(Symbol("@doc"))
                                                                    end && begin
                                                                        var"##520" = var"##514"[2]
                                                                        var"##521" = var"##514"[3]
                                                                        var"##522" = var"##514"[4]
                                                                        true
                                                                    end))))))))))
                        line = var"##520"
                        expr = var"##522"
                        doc = var"##521"
                        var"##return#497" = begin
                                return (line, doc, expr)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#498#527")))
                    end
                    if begin
                                var"##523" = (var"##cache#500").value
                                var"##523" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##523"[1] == :block && (begin
                                        var"##524" = var"##523"[2]
                                        var"##524" isa AbstractArray
                                    end && (length(var"##524") === 2 && (begin
                                                var"##525" = var"##524"[1]
                                                var"##525" isa LineNumberNode
                                            end && begin
                                                var"##526" = var"##524"[2]
                                                true
                                            end))))
                        stmt = var"##526"
                        var"##return#497" = begin
                                (line, doc, expr) = split_doc(stmt)
                                return (line, doc, expr)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#498#527")))
                    end
                end
                begin
                    var"##return#497" = begin
                            return (nothing, nothing, ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#498#527")))
                end
                error("matching non-exhaustive, at #= none:7 =#")
                $(Expr(:symboliclabel, Symbol("####final#498#527")))
                var"##return#497"
            end
        end
    #= none:24 =# Core.@doc "    split_function(ex::Expr) -> head, call, body\n\nSplit function head declaration with function body.\n" function split_function(ex::Expr; source = nothing)
            let
                begin
                    var"##cache#531" = nothing
                end
                var"##return#528" = nothing
                var"##530" = ex
                if var"##530" isa Expr
                    if begin
                                if var"##cache#531" === nothing
                                    var"##cache#531" = Some(((var"##530").head, (var"##530").args))
                                end
                                var"##532" = (var"##cache#531").value
                                var"##532" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##532"[1] == :function && (begin
                                        var"##533" = var"##532"[2]
                                        var"##533" isa AbstractArray
                                    end && (length(var"##533") === 2 && begin
                                            var"##534" = var"##533"[1]
                                            var"##535" = var"##533"[2]
                                            true
                                        end)))
                        var"##return#528" = let call = var"##534", body = var"##535"
                                (:function, call, body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#529#544")))
                    end
                    if begin
                                var"##536" = (var"##cache#531").value
                                var"##536" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##536"[1] == :(=) && (begin
                                        var"##537" = var"##536"[2]
                                        var"##537" isa AbstractArray
                                    end && (length(var"##537") === 2 && begin
                                            var"##538" = var"##537"[1]
                                            var"##539" = var"##537"[2]
                                            true
                                        end)))
                        var"##return#528" = let call = var"##538", body = var"##539"
                                (:(=), call, body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#529#544")))
                    end
                    if begin
                                var"##540" = (var"##cache#531").value
                                var"##540" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##540"[1] == :-> && (begin
                                        var"##541" = var"##540"[2]
                                        var"##541" isa AbstractArray
                                    end && (length(var"##541") === 2 && begin
                                            var"##542" = var"##541"[1]
                                            var"##543" = var"##541"[2]
                                            true
                                        end)))
                        var"##return#528" = let call = var"##542", body = var"##543"
                                (:->, call, body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#529#544")))
                    end
                end
                begin
                    var"##return#528" = let
                            throw(SyntaxError("expect a function expr, got $(ex)", source))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#529#544")))
                end
                error("matching non-exhaustive, at #= none:30 =#")
                $(Expr(:symboliclabel, Symbol("####final#529#544")))
                var"##return#528"
            end
        end
    #= none:38 =# Core.@doc "    split_function_head(ex::Expr) -> name, args, kw, whereparams, rettype\n\nSplit function head to name, arguments, keyword arguments and where parameters.\n" function split_function_head(ex::Expr; source = nothing)
            let
                begin
                    var"##cache#548" = nothing
                end
                var"##return#545" = nothing
                var"##547" = ex
                if var"##547" isa Expr
                    if begin
                                if var"##cache#548" === nothing
                                    var"##cache#548" = Some(((var"##547").head, (var"##547").args))
                                end
                                var"##549" = (var"##cache#548").value
                                var"##549" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##549"[1] == :tuple && (begin
                                        var"##550" = var"##549"[2]
                                        var"##550" isa AbstractArray
                                    end && ((ndims(var"##550") === 1 && length(var"##550") >= 1) && (begin
                                                begin
                                                    var"##cache#552" = nothing
                                                end
                                                var"##551" = var"##550"[1]
                                                var"##551" isa Expr
                                            end && (begin
                                                    if var"##cache#552" === nothing
                                                        var"##cache#552" = Some(((var"##551").head, (var"##551").args))
                                                    end
                                                    var"##553" = (var"##cache#552").value
                                                    var"##553" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##553"[1] == :parameters && (begin
                                                            var"##554" = var"##553"[2]
                                                            var"##554" isa AbstractArray
                                                        end && ((ndims(var"##554") === 1 && length(var"##554") >= 0) && begin
                                                                var"##555" = SubArray(var"##554", (1:length(var"##554"),))
                                                                var"##556" = SubArray(var"##550", (2:length(var"##550"),))
                                                                true
                                                            end))))))))
                        var"##return#545" = let args = var"##556", kw = var"##555"
                                (nothing, args, kw, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#546#603")))
                    end
                    if begin
                                var"##557" = (var"##cache#548").value
                                var"##557" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##557"[1] == :tuple && (begin
                                        var"##558" = var"##557"[2]
                                        var"##558" isa AbstractArray
                                    end && ((ndims(var"##558") === 1 && length(var"##558") >= 0) && begin
                                            var"##559" = SubArray(var"##558", (1:length(var"##558"),))
                                            true
                                        end)))
                        var"##return#545" = let args = var"##559"
                                (nothing, args, nothing, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#546#603")))
                    end
                    if begin
                                var"##560" = (var"##cache#548").value
                                var"##560" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##560"[1] == :call && (begin
                                        var"##561" = var"##560"[2]
                                        var"##561" isa AbstractArray
                                    end && ((ndims(var"##561") === 1 && length(var"##561") >= 2) && (begin
                                                var"##562" = var"##561"[1]
                                                begin
                                                    var"##cache#564" = nothing
                                                end
                                                var"##563" = var"##561"[2]
                                                var"##563" isa Expr
                                            end && (begin
                                                    if var"##cache#564" === nothing
                                                        var"##cache#564" = Some(((var"##563").head, (var"##563").args))
                                                    end
                                                    var"##565" = (var"##cache#564").value
                                                    var"##565" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##565"[1] == :parameters && (begin
                                                            var"##566" = var"##565"[2]
                                                            var"##566" isa AbstractArray
                                                        end && ((ndims(var"##566") === 1 && length(var"##566") >= 0) && begin
                                                                var"##567" = SubArray(var"##566", (1:length(var"##566"),))
                                                                var"##568" = SubArray(var"##561", (3:length(var"##561"),))
                                                                true
                                                            end))))))))
                        var"##return#545" = let name = var"##562", args = var"##568", kw = var"##567"
                                (name, args, kw, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#546#603")))
                    end
                    if begin
                                var"##569" = (var"##cache#548").value
                                var"##569" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##569"[1] == :call && (begin
                                        var"##570" = var"##569"[2]
                                        var"##570" isa AbstractArray
                                    end && ((ndims(var"##570") === 1 && length(var"##570") >= 1) && begin
                                            var"##571" = var"##570"[1]
                                            var"##572" = SubArray(var"##570", (2:length(var"##570"),))
                                            true
                                        end)))
                        var"##return#545" = let name = var"##571", args = var"##572"
                                (name, args, nothing, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#546#603")))
                    end
                    if begin
                                var"##573" = (var"##cache#548").value
                                var"##573" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##573"[1] == :block && (begin
                                        var"##574" = var"##573"[2]
                                        var"##574" isa AbstractArray
                                    end && (length(var"##574") === 3 && (begin
                                                var"##575" = var"##574"[1]
                                                var"##576" = var"##574"[2]
                                                var"##576" isa LineNumberNode
                                            end && (begin
                                                    begin
                                                        var"##cache#578" = nothing
                                                    end
                                                    var"##577" = var"##574"[3]
                                                    var"##577" isa Expr
                                                end && (begin
                                                        if var"##cache#578" === nothing
                                                            var"##cache#578" = Some(((var"##577").head, (var"##577").args))
                                                        end
                                                        var"##579" = (var"##cache#578").value
                                                        var"##579" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                    end && (var"##579"[1] == :(=) && (begin
                                                                var"##580" = var"##579"[2]
                                                                var"##580" isa AbstractArray
                                                            end && (length(var"##580") === 2 && begin
                                                                    var"##581" = var"##580"[1]
                                                                    var"##582" = var"##580"[2]
                                                                    true
                                                                end)))))))))
                        var"##return#545" = let value = var"##582", kw = var"##581", x = var"##575"
                                (nothing, Any[x], Any[Expr(:kw, kw, value)], nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#546#603")))
                    end
                    if begin
                                var"##583" = (var"##cache#548").value
                                var"##583" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##583"[1] == :block && (begin
                                        var"##584" = var"##583"[2]
                                        var"##584" isa AbstractArray
                                    end && (length(var"##584") === 3 && (begin
                                                var"##585" = var"##584"[1]
                                                var"##586" = var"##584"[2]
                                                var"##586" isa LineNumberNode
                                            end && begin
                                                var"##587" = var"##584"[3]
                                                true
                                            end))))
                        var"##return#545" = let kw = var"##587", x = var"##585"
                                (nothing, Any[x], Any[kw], nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#546#603")))
                    end
                    if begin
                                var"##588" = (var"##cache#548").value
                                var"##588" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##588"[1] == :(::) && (begin
                                        var"##589" = var"##588"[2]
                                        var"##589" isa AbstractArray
                                    end && (length(var"##589") === 2 && (begin
                                                var"##590" = var"##589"[1]
                                                var"##590" isa Expr
                                            end && begin
                                                var"##591" = var"##589"[2]
                                                true
                                            end))))
                        var"##return#545" = let call = var"##590", rettype = var"##591"
                                (name, args, kw, whereparams, _) = split_function_head(call)
                                (name, args, kw, whereparams, rettype)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#546#603")))
                    end
                    if begin
                                var"##592" = (var"##cache#548").value
                                var"##592" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##592"[1] == :(::) && (begin
                                        var"##593" = var"##592"[2]
                                        var"##593" isa AbstractArray
                                    end && (length(var"##593") === 2 && (begin
                                                var"##594" = var"##593"[1]
                                                var"##594" isa Symbol
                                            end && begin
                                                var"##595" = var"##593"[2]
                                                true
                                            end))))
                        var"##return#545" = let arg = var"##594", argtype = var"##595"
                                (nothing, Any[ex], nothing, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#546#603")))
                    end
                    if begin
                                var"##596" = (var"##cache#548").value
                                var"##596" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##596"[1] == :(::) && (begin
                                        var"##597" = var"##596"[2]
                                        var"##597" isa AbstractArray
                                    end && (length(var"##597") === 1 && begin
                                            var"##598" = var"##597"[1]
                                            true
                                        end)))
                        var"##return#545" = let argtype = var"##598"
                                (nothing, Any[ex], nothing, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#546#603")))
                    end
                    if begin
                                var"##599" = (var"##cache#548").value
                                var"##599" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##599"[1] == :where && (begin
                                        var"##600" = var"##599"[2]
                                        var"##600" isa AbstractArray
                                    end && ((ndims(var"##600") === 1 && length(var"##600") >= 1) && begin
                                            var"##601" = var"##600"[1]
                                            var"##602" = SubArray(var"##600", (2:length(var"##600"),))
                                            true
                                        end)))
                        var"##return#545" = let call = var"##601", whereparams = var"##602"
                                (name, args, kw, _, rettype) = split_function_head(call)
                                (name, args, kw, whereparams, rettype)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#546#603")))
                    end
                end
                begin
                    var"##return#545" = let
                            throw(SyntaxError("expect a function head, got $(ex)", source))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#546#603")))
                end
                error("matching non-exhaustive, at #= none:44 =#")
                $(Expr(:symboliclabel, Symbol("####final#546#603")))
                var"##return#545"
            end
        end
    split_function_head(s::Symbol; source = nothing) = begin
            (nothing, Any[s], nothing, nothing, nothing)
        end
    #= none:65 =# Core.@doc "    split_struct_name(ex::Expr) -> name, typevars, supertype\n\nSplit the name, type parameters and supertype definition from `struct`\ndeclaration head.\n" function split_struct_name(#= none:71 =# @nospecialize(ex); source = nothing)
            return let
                    begin
                        var"##cache#607" = nothing
                    end
                    var"##return#604" = nothing
                    var"##606" = ex
                    if var"##606" isa Expr
                        if begin
                                    if var"##cache#607" === nothing
                                        var"##cache#607" = Some(((var"##606").head, (var"##606").args))
                                    end
                                    var"##608" = (var"##cache#607").value
                                    var"##608" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##608"[1] == :curly && (begin
                                            var"##609" = var"##608"[2]
                                            var"##609" isa AbstractArray
                                        end && ((ndims(var"##609") === 1 && length(var"##609") >= 1) && begin
                                                var"##610" = var"##609"[1]
                                                var"##611" = SubArray(var"##609", (2:length(var"##609"),))
                                                true
                                            end)))
                            var"##return#604" = let typevars = var"##611", name = var"##610"
                                    (name, typevars, nothing)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#605#625")))
                        end
                        if begin
                                    var"##612" = (var"##cache#607").value
                                    var"##612" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##612"[1] == :<: && (begin
                                            var"##613" = var"##612"[2]
                                            var"##613" isa AbstractArray
                                        end && (length(var"##613") === 2 && (begin
                                                    begin
                                                        var"##cache#615" = nothing
                                                    end
                                                    var"##614" = var"##613"[1]
                                                    var"##614" isa Expr
                                                end && (begin
                                                        if var"##cache#615" === nothing
                                                            var"##cache#615" = Some(((var"##614").head, (var"##614").args))
                                                        end
                                                        var"##616" = (var"##cache#615").value
                                                        var"##616" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                    end && (var"##616"[1] == :curly && (begin
                                                                var"##617" = var"##616"[2]
                                                                var"##617" isa AbstractArray
                                                            end && ((ndims(var"##617") === 1 && length(var"##617") >= 1) && begin
                                                                    var"##618" = var"##617"[1]
                                                                    var"##619" = SubArray(var"##617", (2:length(var"##617"),))
                                                                    var"##620" = var"##613"[2]
                                                                    true
                                                                end))))))))
                            var"##return#604" = let typevars = var"##619", type = var"##620", name = var"##618"
                                    (name, typevars, type)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#605#625")))
                        end
                        if begin
                                    var"##621" = (var"##cache#607").value
                                    var"##621" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##621"[1] == :<: && (begin
                                            var"##622" = var"##621"[2]
                                            var"##622" isa AbstractArray
                                        end && (length(var"##622") === 2 && begin
                                                var"##623" = var"##622"[1]
                                                var"##624" = var"##622"[2]
                                                true
                                            end)))
                            var"##return#604" = let type = var"##624", name = var"##623"
                                    (name, [], type)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#605#625")))
                        end
                    end
                    if var"##606" isa Symbol
                        begin
                            var"##return#604" = let
                                    (ex, [], nothing)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#605#625")))
                        end
                    end
                    begin
                        var"##return#604" = let
                                throw(SyntaxError("expect struct got $(ex)", source))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#605#625")))
                    end
                    error("matching non-exhaustive, at #= none:72 =#")
                    $(Expr(:symboliclabel, Symbol("####final#605#625")))
                    var"##return#604"
                end
        end
    #= none:81 =# Core.@doc "    split_struct(ex::Expr) -> ismutable, name, typevars, supertype, body\n\nSplit struct definition head and body.\n" function split_struct(ex::Expr; source = nothing)
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
    #= none:138 =# Core.@doc "    uninferrable_typevars(def::Union{JLStruct, JLKwStruct}; leading_inferable::Bool=true)\n\nReturn the type variables that are not inferrable in given struct definition.\n" function uninferrable_typevars(def::Union{JLStruct, JLKwStruct}; leading_inferable::Bool = true)
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
    #= none:163 =# Core.@doc "    split_field_if_match(typename::Symbol, expr, default::Bool=false)\n\nSplit the field definition if it matches the given type name.\nReturns `NamedTuple` with `name`, `type`, `default` and `isconst` fields\nif it matches, otherwise return `nothing`.\n" function split_field_if_match(typename::Symbol, expr, default::Bool = false; source = nothing)
            begin
                begin
                    var"##cache#629" = nothing
                end
                var"##628" = expr
                if var"##628" isa Expr
                    if begin
                                if var"##cache#629" === nothing
                                    var"##cache#629" = Some(((var"##628").head, (var"##628").args))
                                end
                                var"##630" = (var"##cache#629").value
                                var"##630" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##630"[1] == :const && (begin
                                        var"##631" = var"##630"[2]
                                        var"##631" isa AbstractArray
                                    end && (length(var"##631") === 1 && (begin
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
                                                end && (var"##634"[1] == :(=) && (begin
                                                            var"##635" = var"##634"[2]
                                                            var"##635" isa AbstractArray
                                                        end && (length(var"##635") === 2 && (begin
                                                                    begin
                                                                        var"##cache#637" = nothing
                                                                    end
                                                                    var"##636" = var"##635"[1]
                                                                    var"##636" isa Expr
                                                                end && (begin
                                                                        if var"##cache#637" === nothing
                                                                            var"##cache#637" = Some(((var"##636").head, (var"##636").args))
                                                                        end
                                                                        var"##638" = (var"##cache#637").value
                                                                        var"##638" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                    end && (var"##638"[1] == :(::) && (begin
                                                                                var"##639" = var"##638"[2]
                                                                                var"##639" isa AbstractArray
                                                                            end && (length(var"##639") === 2 && (begin
                                                                                        var"##640" = var"##639"[1]
                                                                                        var"##640" isa Symbol
                                                                                    end && begin
                                                                                        var"##641" = var"##639"[2]
                                                                                        var"##642" = var"##635"[2]
                                                                                        true
                                                                                    end))))))))))))))
                        value = var"##642"
                        type = var"##641"
                        name = var"##640"
                        var"##return#626" = begin
                                default && return (; name, type, isconst = true, default = value)
                                throw(SyntaxError("default value syntax is not allowed", source))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#627#679")))
                    end
                    if begin
                                var"##643" = (var"##cache#629").value
                                var"##643" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##643"[1] == :const && (begin
                                        var"##644" = var"##643"[2]
                                        var"##644" isa AbstractArray
                                    end && (length(var"##644") === 1 && (begin
                                                begin
                                                    var"##cache#646" = nothing
                                                end
                                                var"##645" = var"##644"[1]
                                                var"##645" isa Expr
                                            end && (begin
                                                    if var"##cache#646" === nothing
                                                        var"##cache#646" = Some(((var"##645").head, (var"##645").args))
                                                    end
                                                    var"##647" = (var"##cache#646").value
                                                    var"##647" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##647"[1] == :(=) && (begin
                                                            var"##648" = var"##647"[2]
                                                            var"##648" isa AbstractArray
                                                        end && (length(var"##648") === 2 && (begin
                                                                    var"##649" = var"##648"[1]
                                                                    var"##649" isa Symbol
                                                                end && begin
                                                                    var"##650" = var"##648"[2]
                                                                    true
                                                                end)))))))))
                        value = var"##650"
                        name = var"##649"
                        var"##return#626" = begin
                                default && return (; name, type = Any, isconst = true, default = value)
                                throw(SyntaxError("default value syntax is not allowed", source))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#627#679")))
                    end
                    if begin
                                var"##651" = (var"##cache#629").value
                                var"##651" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##651"[1] == :(=) && (begin
                                        var"##652" = var"##651"[2]
                                        var"##652" isa AbstractArray
                                    end && (length(var"##652") === 2 && (begin
                                                begin
                                                    var"##cache#654" = nothing
                                                end
                                                var"##653" = var"##652"[1]
                                                var"##653" isa Expr
                                            end && (begin
                                                    if var"##cache#654" === nothing
                                                        var"##cache#654" = Some(((var"##653").head, (var"##653").args))
                                                    end
                                                    var"##655" = (var"##cache#654").value
                                                    var"##655" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##655"[1] == :(::) && (begin
                                                            var"##656" = var"##655"[2]
                                                            var"##656" isa AbstractArray
                                                        end && (length(var"##656") === 2 && (begin
                                                                    var"##657" = var"##656"[1]
                                                                    var"##657" isa Symbol
                                                                end && begin
                                                                    var"##658" = var"##656"[2]
                                                                    var"##659" = var"##652"[2]
                                                                    true
                                                                end)))))))))
                        value = var"##659"
                        type = var"##658"
                        name = var"##657"
                        var"##return#626" = begin
                                default && return (; name, type, isconst = false, default = value)
                                throw(SyntaxError("default value syntax is not allowed", source))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#627#679")))
                    end
                    if begin
                                var"##660" = (var"##cache#629").value
                                var"##660" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##660"[1] == :(=) && (begin
                                        var"##661" = var"##660"[2]
                                        var"##661" isa AbstractArray
                                    end && (length(var"##661") === 2 && (begin
                                                var"##662" = var"##661"[1]
                                                var"##662" isa Symbol
                                            end && begin
                                                var"##663" = var"##661"[2]
                                                true
                                            end))))
                        value = var"##663"
                        name = var"##662"
                        var"##return#626" = begin
                                default && return (; name, type = Any, isconst = false, default = value)
                                throw(SyntaxError("default value syntax is not allowed", source))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#627#679")))
                    end
                    if begin
                                var"##664" = (var"##cache#629").value
                                var"##664" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##664"[1] == :const && (begin
                                        var"##665" = var"##664"[2]
                                        var"##665" isa AbstractArray
                                    end && (length(var"##665") === 1 && (begin
                                                begin
                                                    var"##cache#667" = nothing
                                                end
                                                var"##666" = var"##665"[1]
                                                var"##666" isa Expr
                                            end && (begin
                                                    if var"##cache#667" === nothing
                                                        var"##cache#667" = Some(((var"##666").head, (var"##666").args))
                                                    end
                                                    var"##668" = (var"##cache#667").value
                                                    var"##668" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##668"[1] == :(::) && (begin
                                                            var"##669" = var"##668"[2]
                                                            var"##669" isa AbstractArray
                                                        end && (length(var"##669") === 2 && (begin
                                                                    var"##670" = var"##669"[1]
                                                                    var"##670" isa Symbol
                                                                end && begin
                                                                    var"##671" = var"##669"[2]
                                                                    true
                                                                end)))))))))
                        type = var"##671"
                        name = var"##670"
                        var"##return#626" = begin
                                default && return (; name, type, isconst = true, default = no_default)
                                return (; name, type, isconst = true)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#627#679")))
                    end
                    if begin
                                var"##672" = (var"##cache#629").value
                                var"##672" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##672"[1] == :const && (begin
                                        var"##673" = var"##672"[2]
                                        var"##673" isa AbstractArray
                                    end && (length(var"##673") === 1 && begin
                                            var"##674" = var"##673"[1]
                                            var"##674" isa Symbol
                                        end)))
                        name = var"##674"
                        var"##return#626" = begin
                                default && return (; name, type = Any, isconst = true, default = no_default)
                                return (; name, type = Any, isconst = true)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#627#679")))
                    end
                    if begin
                                var"##675" = (var"##cache#629").value
                                var"##675" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##675"[1] == :(::) && (begin
                                        var"##676" = var"##675"[2]
                                        var"##676" isa AbstractArray
                                    end && (length(var"##676") === 2 && (begin
                                                var"##677" = var"##676"[1]
                                                var"##677" isa Symbol
                                            end && begin
                                                var"##678" = var"##676"[2]
                                                true
                                            end))))
                        type = var"##678"
                        name = var"##677"
                        var"##return#626" = begin
                                default && return (; name, type, isconst = false, default = no_default)
                                return (; name, type, isconst = false)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#627#679")))
                    end
                end
                if var"##628" isa Symbol
                    begin
                        name = var"##628"
                        var"##return#626" = begin
                                default && return (; name, type = Any, isconst = false, default = no_default)
                                return (; name, type = Any, isconst = false)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#627#679")))
                    end
                end
                if var"##628" isa String
                    begin
                        var"##return#626" = begin
                                return expr
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#627#679")))
                    end
                end
                if var"##628" isa LineNumberNode
                    begin
                        var"##return#626" = begin
                                return expr
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#627#679")))
                    end
                end
                if is_function(expr)
                    var"##return#626" = begin
                            if name_only(expr) === typename
                                return JLFunction(expr)
                            else
                                return expr
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#627#679")))
                end
                begin
                    var"##return#626" = begin
                            return expr
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#627#679")))
                end
                error("matching non-exhaustive, at #= none:171 =#")
                $(Expr(:symboliclabel, Symbol("####final#627#679")))
                var"##return#626"
            end
        end
