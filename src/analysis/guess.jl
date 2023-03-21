
    #= none:1 =# Core.@doc "    guess_module(m, ex)\n\nGuess the module of given expression `ex` (of a module)\nin module `m`. If `ex` is not a module, or cannot be\ndetermined return `nothing`.\n" function guess_module(m::Module, ex)
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
                            end && (var"##507"[1] == :. && (begin
                                        var"##508" = var"##507"[2]
                                        var"##508" isa AbstractArray
                                    end && (length(var"##508") === 2 && (begin
                                                var"##509" = var"##508"[1]
                                                var"##510" = var"##508"[2]
                                                var"##510" isa QuoteNode
                                            end && begin
                                                var"##511" = (var"##510").value
                                                true
                                            end))))
                        name = var"##509"
                        sub = var"##511"
                        var"##return#503" = begin
                                mod = guess_module(m, name)
                                if mod isa Module
                                    return guess_module(mod, sub)
                                else
                                    return ex
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#504#512")))
                    end
                end
                if var"##505" isa Symbol
                    if isdefined(m, ex)
                        var"##return#503" = begin
                                maybe_m = getproperty(m, ex)
                                maybe_m isa Module && return maybe_m
                                return ex
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#504#512")))
                    end
                end
                if var"##505" isa Module
                    begin
                        var"##return#503" = begin
                                return ex
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#504#512")))
                    end
                end
                begin
                    var"##return#503" = begin
                            return ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#504#512")))
                end
                error("matching non-exhaustive, at #= none:9 =#")
                $(Expr(:symboliclabel, Symbol("####final#504#512")))
                var"##return#503"
            end
        end
    #= none:28 =# Core.@doc "    guess_type(m::Module, ex)\n\nGuess the actual type of expression `ex` (of a type) in module `m`.\nReturns the type if it can be determined, otherwise returns the\nexpression. This function is used in [`compare_expr`](@ref).\n" function guess_type(m::Module, ex)
            begin
                begin
                    var"##cache#516" = nothing
                end
                var"##515" = ex
                if var"##515" isa Expr
                    if begin
                                if var"##cache#516" === nothing
                                    var"##cache#516" = Some(((var"##515").head, (var"##515").args))
                                end
                                var"##517" = (var"##cache#516").value
                                var"##517" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##517"[1] == :curly && (begin
                                        var"##518" = var"##517"[2]
                                        var"##518" isa AbstractArray
                                    end && ((ndims(var"##518") === 1 && length(var"##518") >= 1) && begin
                                            var"##519" = var"##518"[1]
                                            var"##520" = SubArray(var"##518", (2:length(var"##518"),))
                                            true
                                        end)))
                        typevars = var"##520"
                        name = var"##519"
                        var"##return#513" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#514#521")))
                    end
                end
                if var"##515" isa Symbol
                    begin
                        var"##return#513" = begin
                                isdefined(m, ex) || return ex
                                return getproperty(m, ex)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#514#521")))
                    end
                end
                if var"##515" isa Type
                    begin
                        var"##return#513" = begin
                                return ex
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#514#521")))
                    end
                end
                if var"##515" isa QuoteNode
                    begin
                        var"##return#513" = begin
                                return ex
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#514#521")))
                    end
                end
                begin
                    var"##return#513" = begin
                            return ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#514#521")))
                end
                error("matching non-exhaustive, at #= none:36 =#")
                $(Expr(:symboliclabel, Symbol("####final#514#521")))
                var"##return#513"
            end
        end
