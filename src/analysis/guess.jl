
    #= none:1 =# Core.@doc "    guess_module(m, ex)\n\nGuess the module of given expression `ex` (of a module)\nin module `m`. If `ex` is not a module, or cannot be\ndetermined return `nothing`.\n" function guess_module(m::Module, ex)
            begin
                begin
                    var"##cache#538" = nothing
                end
                var"##537" = ex
                if var"##537" isa Expr
                    if begin
                                if var"##cache#538" === nothing
                                    var"##cache#538" = Some(((var"##537").head, (var"##537").args))
                                end
                                var"##539" = (var"##cache#538").value
                                var"##539" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##539"[1] == :. && (begin
                                        var"##540" = var"##539"[2]
                                        var"##540" isa AbstractArray
                                    end && (length(var"##540") === 2 && (begin
                                                var"##541" = var"##540"[1]
                                                var"##542" = var"##540"[2]
                                                var"##542" isa QuoteNode
                                            end && begin
                                                var"##543" = (var"##542").value
                                                true
                                            end))))
                        name = var"##541"
                        sub = var"##543"
                        var"##return#535" = begin
                                mod = guess_module(m, name)
                                if mod isa Module
                                    return guess_module(mod, sub)
                                else
                                    return ex
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#536#544")))
                    end
                end
                if var"##537" isa Symbol
                    if isdefined(m, ex)
                        var"##return#535" = begin
                                maybe_m = getproperty(m, ex)
                                maybe_m isa Module && return maybe_m
                                return ex
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#536#544")))
                    end
                end
                if var"##537" isa Module
                    begin
                        var"##return#535" = begin
                                return ex
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#536#544")))
                    end
                end
                begin
                    var"##return#535" = begin
                            return ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#536#544")))
                end
                error("matching non-exhaustive, at #= none:9 =#")
                $(Expr(:symboliclabel, Symbol("####final#536#544")))
                var"##return#535"
            end
        end
    #= none:28 =# Core.@doc "    guess_type(m::Module, ex)\n\nGuess the actual type of expression `ex` (of a type) in module `m`.\nReturns the type if it can be determined, otherwise returns the\nexpression. This function is used in [`compare_expr`](@ref).\n" function guess_type(m::Module, ex)
            begin
                begin
                    var"##cache#548" = nothing
                end
                var"##547" = ex
                if var"##547" isa Expr
                    if begin
                                if var"##cache#548" === nothing
                                    var"##cache#548" = Some(((var"##547").head, (var"##547").args))
                                end
                                var"##549" = (var"##cache#548").value
                                var"##549" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##549"[1] == :curly && (begin
                                        var"##550" = var"##549"[2]
                                        var"##550" isa AbstractArray
                                    end && ((ndims(var"##550") === 1 && length(var"##550") >= 1) && begin
                                            var"##551" = var"##550"[1]
                                            var"##552" = SubArray(var"##550", (2:length(var"##550"),))
                                            true
                                        end)))
                        typevars = var"##552"
                        name = var"##551"
                        var"##return#545" = begin
                                type = guess_type(m, name)
                                typevars = map(typevars) do typevar
                                        guess_type(m, typevar)
                                    end
                                if type === Union
                                    all((x->begin
                                                    x isa Type
                                                end), typevars) || return ex
                                    return Union{typevars...}
                                elseif type isa Type && all(is_valid_typevar, typevars)
                                    return type{typevars...}
                                else
                                    return ex
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#546#553")))
                    end
                end
                if var"##547" isa Symbol
                    begin
                        var"##return#545" = begin
                                isdefined(m, ex) || return ex
                                return getproperty(m, ex)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#546#553")))
                    end
                end
                if var"##547" isa Type
                    begin
                        var"##return#545" = begin
                                return ex
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#546#553")))
                    end
                end
                if var"##547" isa QuoteNode
                    begin
                        var"##return#545" = begin
                                return ex
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#546#553")))
                    end
                end
                begin
                    var"##return#545" = begin
                            return ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#546#553")))
                end
                error("matching non-exhaustive, at #= none:36 =#")
                $(Expr(:symboliclabel, Symbol("####final#546#553")))
                var"##return#545"
            end
        end
    function guess_value(m::Module, ex)
        let
            begin
                var"##cache#557" = nothing
            end
            var"##return#554" = nothing
            var"##556" = ex
            if var"##556" isa Expr
                if begin
                            if var"##cache#557" === nothing
                                var"##cache#557" = Some(((var"##556").head, (var"##556").args))
                            end
                            var"##558" = (var"##cache#557").value
                            var"##558" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##558"[1] == :. && (begin
                                    var"##559" = var"##558"[2]
                                    var"##559" isa AbstractArray
                                end && (length(var"##559") === 2 && (begin
                                            var"##560" = var"##559"[1]
                                            var"##561" = var"##559"[2]
                                            var"##561" isa QuoteNode
                                        end && begin
                                            var"##562" = (var"##561").value
                                            true
                                        end))))
                    var"##return#554" = let name = var"##560", sub = var"##562"
                            mod = guess_module(m, name)
                            if mod isa Module
                                return guess_value(mod, sub)
                            else
                                return ex
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#555#563")))
                end
            end
            if var"##556" isa Symbol
                begin
                    var"##return#554" = let
                            if isdefined(m, ex)
                                getfield(m, ex)
                            else
                                ex
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#555#563")))
                end
            end
            begin
                var"##return#554" = let
                        ex
                    end
                $(Expr(:symbolicgoto, Symbol("####final#555#563")))
            end
            error("matching non-exhaustive, at #= none:62 =#")
            $(Expr(:symboliclabel, Symbol("####final#555#563")))
            var"##return#554"
        end
    end
