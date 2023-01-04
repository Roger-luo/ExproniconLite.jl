
    #= none:1 =# Core.@doc "    guess_module(m, ex)\n\nGuess the module of given expression `ex` (of a module)\nin module `m`. If `ex` is not a module, or cannot be\ndetermined return `nothing`.\n" function guess_module(m::Module, ex)
            begin
                begin
                    var"##cache#526" = nothing
                end
                var"##525" = ex
                if var"##525" isa Expr
                    if begin
                                if var"##cache#526" === nothing
                                    var"##cache#526" = Some(((var"##525").head, (var"##525").args))
                                end
                                var"##527" = (var"##cache#526").value
                                var"##527" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##527"[1] == :. && (begin
                                        var"##528" = var"##527"[2]
                                        var"##528" isa AbstractArray
                                    end && (length(var"##528") === 2 && (begin
                                                var"##529" = var"##528"[1]
                                                var"##530" = var"##528"[2]
                                                var"##530" isa QuoteNode
                                            end && begin
                                                var"##531" = (var"##530").value
                                                true
                                            end))))
                        name = var"##529"
                        sub = var"##531"
                        var"##return#523" = begin
                                mod = guess_module(m, name)
                                if mod isa Module
                                    return guess_module(mod, sub)
                                else
                                    return ex
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#524#532")))
                    end
                end
                if var"##525" isa Symbol
                    if isdefined(m, ex)
                        var"##return#523" = begin
                                maybe_m = getproperty(m, ex)
                                maybe_m isa Module && return maybe_m
                                return ex
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#524#532")))
                    end
                end
                if var"##525" isa Module
                    begin
                        var"##return#523" = begin
                                return ex
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#524#532")))
                    end
                end
                begin
                    var"##return#523" = begin
                            return ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#524#532")))
                end
                error("matching non-exhaustive, at #= none:9 =#")
                $(Expr(:symboliclabel, Symbol("####final#524#532")))
                var"##return#523"
            end
        end
    #= none:28 =# Core.@doc "    guess_type(m::Module, ex)\n\nGuess the actual type of expression `ex` (of a type) in module `m`.\nReturns the type if it can be determined, otherwise returns the\nexpression. This function is used in [`compare_expr`](@ref).\n" function guess_type(m::Module, ex)
            begin
                begin
                    var"##cache#536" = nothing
                end
                var"##535" = ex
                if var"##535" isa Expr
                    if begin
                                if var"##cache#536" === nothing
                                    var"##cache#536" = Some(((var"##535").head, (var"##535").args))
                                end
                                var"##537" = (var"##cache#536").value
                                var"##537" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##537"[1] == :curly && (begin
                                        var"##538" = var"##537"[2]
                                        var"##538" isa AbstractArray
                                    end && ((ndims(var"##538") === 1 && length(var"##538") >= 1) && begin
                                            var"##539" = var"##538"[1]
                                            var"##540" = SubArray(var"##538", (2:length(var"##538"),))
                                            true
                                        end)))
                        typevars = var"##540"
                        name = var"##539"
                        var"##return#533" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#534#541")))
                    end
                end
                if var"##535" isa Symbol
                    begin
                        var"##return#533" = begin
                                isdefined(m, ex) || return ex
                                return getproperty(m, ex)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#534#541")))
                    end
                end
                if var"##535" isa Type
                    begin
                        var"##return#533" = begin
                                return ex
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#534#541")))
                    end
                end
                if var"##535" isa QuoteNode
                    begin
                        var"##return#533" = begin
                                return ex
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#534#541")))
                    end
                end
                begin
                    var"##return#533" = begin
                            return ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#534#541")))
                end
                error("matching non-exhaustive, at #= none:36 =#")
                $(Expr(:symboliclabel, Symbol("####final#534#541")))
                var"##return#533"
            end
        end
