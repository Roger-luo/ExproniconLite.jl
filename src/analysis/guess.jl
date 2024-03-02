
    #= none:1 =# Core.@doc "    guess_module(m, ex)\n\nGuess the module of given expression `ex` (of a module)\nin module `m`. If `ex` is not a module, or cannot be\ndetermined return `nothing`.\n" function guess_module(m::Module, ex)
            begin
                begin
                    var"##cache#475" = nothing
                end
                var"##474" = ex
                if var"##474" isa Expr
                    if begin
                                if var"##cache#475" === nothing
                                    var"##cache#475" = Some(((var"##474").head, (var"##474").args))
                                end
                                var"##476" = (var"##cache#475").value
                                var"##476" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##476"[1] == :. && (begin
                                        var"##477" = var"##476"[2]
                                        var"##477" isa AbstractArray
                                    end && (length(var"##477") === 2 && (begin
                                                var"##478" = var"##477"[1]
                                                var"##479" = var"##477"[2]
                                                var"##479" isa QuoteNode
                                            end && begin
                                                var"##480" = (var"##479").value
                                                true
                                            end))))
                        name = var"##478"
                        sub = var"##480"
                        var"##return#472" = begin
                                mod = guess_module(m, name)
                                if mod isa Module
                                    return guess_module(mod, sub)
                                else
                                    return ex
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#473#481")))
                    end
                end
                if var"##474" isa Symbol
                    if isdefined(m, ex)
                        var"##return#472" = begin
                                maybe_m = getproperty(m, ex)
                                maybe_m isa Module && return maybe_m
                                return ex
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#473#481")))
                    end
                end
                if var"##474" isa Module
                    begin
                        var"##return#472" = begin
                                return ex
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#473#481")))
                    end
                end
                begin
                    var"##return#472" = begin
                            return ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#473#481")))
                end
                error("matching non-exhaustive, at #= none:9 =#")
                $(Expr(:symboliclabel, Symbol("####final#473#481")))
                var"##return#472"
            end
        end
    #= none:28 =# Core.@doc "    guess_type(m::Module, ex)\n\nGuess the actual type of expression `ex` (of a type) in module `m`.\nReturns the type if it can be determined, otherwise returns the\nexpression. This function is used in [`compare_expr`](@ref).\n" function guess_type(m::Module, ex)
            begin
                begin
                    var"##cache#485" = nothing
                end
                var"##484" = ex
                if var"##484" isa Expr
                    if begin
                                if var"##cache#485" === nothing
                                    var"##cache#485" = Some(((var"##484").head, (var"##484").args))
                                end
                                var"##486" = (var"##cache#485").value
                                var"##486" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##486"[1] == :curly && (begin
                                        var"##487" = var"##486"[2]
                                        var"##487" isa AbstractArray
                                    end && ((ndims(var"##487") === 1 && length(var"##487") >= 1) && begin
                                            var"##488" = var"##487"[1]
                                            var"##489" = SubArray(var"##487", (2:length(var"##487"),))
                                            true
                                        end)))
                        typevars = var"##489"
                        name = var"##488"
                        var"##return#482" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#483#490")))
                    end
                end
                if var"##484" isa Symbol
                    begin
                        var"##return#482" = begin
                                isdefined(m, ex) || return ex
                                return getproperty(m, ex)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#483#490")))
                    end
                end
                if var"##484" isa Type
                    begin
                        var"##return#482" = begin
                                return ex
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#483#490")))
                    end
                end
                if var"##484" isa QuoteNode
                    begin
                        var"##return#482" = begin
                                return ex
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#483#490")))
                    end
                end
                begin
                    var"##return#482" = begin
                            return ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#483#490")))
                end
                error("matching non-exhaustive, at #= none:36 =#")
                $(Expr(:symboliclabel, Symbol("####final#483#490")))
                var"##return#482"
            end
        end
    function guess_value(m::Module, ex)
        let
            begin
                var"##cache#494" = nothing
            end
            var"##return#491" = nothing
            var"##493" = ex
            if var"##493" isa Expr
                if begin
                            if var"##cache#494" === nothing
                                var"##cache#494" = Some(((var"##493").head, (var"##493").args))
                            end
                            var"##495" = (var"##cache#494").value
                            var"##495" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##495"[1] == :. && (begin
                                    var"##496" = var"##495"[2]
                                    var"##496" isa AbstractArray
                                end && (length(var"##496") === 2 && (begin
                                            var"##497" = var"##496"[1]
                                            var"##498" = var"##496"[2]
                                            var"##498" isa QuoteNode
                                        end && begin
                                            var"##499" = (var"##498").value
                                            true
                                        end))))
                    var"##return#491" = let name = var"##497", sub = var"##499"
                            mod = guess_module(m, name)
                            if mod isa Module
                                return guess_value(mod, sub)
                            else
                                return ex
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#492#500")))
                end
            end
            if var"##493" isa Symbol
                begin
                    var"##return#491" = let
                            if isdefined(m, ex)
                                getfield(m, ex)
                            else
                                ex
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#492#500")))
                end
            end
            begin
                var"##return#491" = let
                        ex
                    end
                $(Expr(:symbolicgoto, Symbol("####final#492#500")))
            end
            error("matching non-exhaustive, at #= none:62 =#")
            $(Expr(:symboliclabel, Symbol("####final#492#500")))
            var"##return#491"
        end
    end
