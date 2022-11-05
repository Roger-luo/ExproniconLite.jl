begin
    #= none:1 =# Core.@doc "    guess_module(m, ex)\n\nGuess the module of given expression `ex` (of a module)\nin module `m`. If `ex` is not a module, or cannot be\ndetermined return `nothing`.\n" function guess_module(m::Module, ex)
            cache_1 = nothing
            x_1 = ex
            if x_1 isa Expr
                if begin
                            if cache_1 === nothing
                                cache_1 = Some((x_1.head, x_1.args))
                            end
                            x_2 = cache_1.value
                            x_2 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_2[1] == :. && (begin
                                    x_3 = x_2[2]
                                    x_3 isa AbstractArray
                                end && (length(x_3) === 2 && (begin
                                            x_4 = x_3[1]
                                            x_5 = x_3[2]
                                            x_5 isa QuoteNode
                                        end && begin
                                            x_6 = x_5.value
                                            true
                                        end))))
                    name = x_4
                    sub = x_6
                    return_1 = begin
                            mod = guess_module(m, name)
                            if mod isa Module
                                return guess_module(mod, sub)
                            else
                                return ex
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#888_1")))
                end
            end
            if x_1 isa Symbol
                if isdefined(m, ex)
                    return_1 = begin
                            maybe_m = getproperty(m, ex)
                            maybe_m isa Module && return maybe_m
                            return ex
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#888_1")))
                end
            end
            if x_1 isa Module
                return_1 = begin
                        return ex
                    end
                $(Expr(:symbolicgoto, Symbol("##final#888_1")))
            end
            return_1 = begin
                    return ex
                end
            $(Expr(:symbolicgoto, Symbol("##final#888_1")))
            (error)("matching non-exhaustive, at #= none:9 =#")
            $(Expr(:symboliclabel, Symbol("##final#888_1")))
            return_1
        end
    #= none:28 =# Core.@doc "    guess_type(m::Module, ex)\n\nGuess the actual type of expression `ex` (of a type) in module `m`.\nReturns the type if it can be determined, otherwise returns the\nexpression. This function is used in [`compare_expr`](@ref).\n" function guess_type(m::Module, ex)
            cache_2 = nothing
            x_7 = ex
            if x_7 isa Expr
                if begin
                            if cache_2 === nothing
                                cache_2 = Some((x_7.head, x_7.args))
                            end
                            x_8 = cache_2.value
                            x_8 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_8[1] == :curly && (begin
                                    x_9 = x_8[2]
                                    x_9 isa AbstractArray
                                end && ((ndims(x_9) === 1 && length(x_9) >= 1) && begin
                                        x_10 = x_9[1]
                                        x_11 = (SubArray)(x_9, (2:length(x_9),))
                                        true
                                    end)))
                    typevars = x_11
                    name = x_10
                    return_2 = begin
                            type = guess_type(m, name)
                            typevars = map(typevars) do typevar
                                    guess_type(m, typevar)
                                end
                            if type isa Type && all(is_valid_typevar, typevars)
                                return type{typevars...}
                            else
                                return ex
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#898_1")))
                end
            end
            if x_7 isa Symbol
                return_2 = begin
                        isdefined(m, ex) || return ex
                        return getproperty(m, ex)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#898_1")))
            end
            if x_7 isa Type
                return_2 = begin
                        return ex
                    end
                $(Expr(:symbolicgoto, Symbol("##final#898_1")))
            end
            return_2 = begin
                    return ex
                end
            $(Expr(:symbolicgoto, Symbol("##final#898_1")))
            (error)("matching non-exhaustive, at #= none:36 =#")
            $(Expr(:symboliclabel, Symbol("##final#898_1")))
            return_2
        end
end
