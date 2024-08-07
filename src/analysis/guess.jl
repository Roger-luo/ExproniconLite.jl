
    #= none:1 =# Core.@doc "    guess_module(m, ex)\n\nGuess the module of given expression `ex` (of a module)\nin module `m`. If `ex` is not a module, or cannot be\ndetermined return `nothing`.\n" function guess_module(m::Module, ex)
            begin
                begin
                    var"##cache#477" = nothing
                end
                var"##476" = ex
                if var"##476" isa Expr
                    if begin
                                if var"##cache#477" === nothing
                                    var"##cache#477" = Some(((var"##476").head, (var"##476").args))
                                end
                                var"##478" = (var"##cache#477").value
                                var"##478" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##478"[1] == :. && (begin
                                        var"##479" = var"##478"[2]
                                        var"##479" isa AbstractArray
                                    end && (length(var"##479") === 2 && (begin
                                                var"##480" = var"##479"[1]
                                                var"##481" = var"##479"[2]
                                                var"##481" isa QuoteNode
                                            end && begin
                                                var"##482" = (var"##481").value
                                                true
                                            end))))
                        name = var"##480"
                        sub = var"##482"
                        var"##return#474" = begin
                                mod = guess_module(m, name)
                                if mod isa Module
                                    return guess_module(mod, sub)
                                else
                                    return ex
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#475#483")))
                    end
                end
                if var"##476" isa Symbol
                    if isdefined(m, ex)
                        var"##return#474" = begin
                                maybe_m = getproperty(m, ex)
                                maybe_m isa Module && return maybe_m
                                return ex
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#475#483")))
                    end
                end
                if var"##476" isa Module
                    begin
                        var"##return#474" = begin
                                return ex
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#475#483")))
                    end
                end
                begin
                    var"##return#474" = begin
                            return ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#475#483")))
                end
                error("matching non-exhaustive, at #= none:9 =#")
                $(Expr(:symboliclabel, Symbol("####final#475#483")))
                var"##return#474"
            end
        end
    #= none:28 =# Core.@doc "    guess_type(m::Module, ex)\n\nGuess the actual type of expression `ex` (of a type) in module `m`.\nReturns the type if it can be determined, otherwise returns the\nexpression. This function is used in [`compare_expr`](@ref).\n" function guess_type(m::Module, ex)
            begin
                begin
                    var"##cache#487" = nothing
                end
                var"##486" = ex
                if var"##486" isa Expr
                    if begin
                                if var"##cache#487" === nothing
                                    var"##cache#487" = Some(((var"##486").head, (var"##486").args))
                                end
                                var"##488" = (var"##cache#487").value
                                var"##488" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##488"[1] == :curly && (begin
                                        var"##489" = var"##488"[2]
                                        var"##489" isa AbstractArray
                                    end && ((ndims(var"##489") === 1 && length(var"##489") >= 1) && begin
                                            var"##490" = var"##489"[1]
                                            var"##491" = SubArray(var"##489", (2:length(var"##489"),))
                                            true
                                        end)))
                        typevars = var"##491"
                        name = var"##490"
                        var"##return#484" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#485#492")))
                    end
                end
                if var"##486" isa Symbol
                    begin
                        var"##return#484" = begin
                                isdefined(m, ex) || return ex
                                return getproperty(m, ex)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#485#492")))
                    end
                end
                if var"##486" isa Type
                    begin
                        var"##return#484" = begin
                                return ex
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#485#492")))
                    end
                end
                if var"##486" isa QuoteNode
                    begin
                        var"##return#484" = begin
                                return ex
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#485#492")))
                    end
                end
                begin
                    var"##return#484" = begin
                            return ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#485#492")))
                end
                error("matching non-exhaustive, at #= none:36 =#")
                $(Expr(:symboliclabel, Symbol("####final#485#492")))
                var"##return#484"
            end
        end
    function guess_value(m::Module, ex)
        let
            begin
                var"##cache#496" = nothing
            end
            var"##return#493" = nothing
            var"##495" = ex
            if var"##495" isa Expr
                if begin
                            if var"##cache#496" === nothing
                                var"##cache#496" = Some(((var"##495").head, (var"##495").args))
                            end
                            var"##497" = (var"##cache#496").value
                            var"##497" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##497"[1] == :. && (begin
                                    var"##498" = var"##497"[2]
                                    var"##498" isa AbstractArray
                                end && (length(var"##498") === 2 && (begin
                                            var"##499" = var"##498"[1]
                                            var"##500" = var"##498"[2]
                                            var"##500" isa QuoteNode
                                        end && begin
                                            var"##501" = (var"##500").value
                                            true
                                        end))))
                    var"##return#493" = let name = var"##499", sub = var"##501"
                            mod = guess_module(m, name)
                            if mod isa Module
                                return guess_value(mod, sub)
                            else
                                return ex
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#494#502")))
                end
            end
            if var"##495" isa Symbol
                begin
                    var"##return#493" = let
                            if isdefined(m, ex)
                                getfield(m, ex)
                            else
                                ex
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#494#502")))
                end
            end
            begin
                var"##return#493" = let
                        ex
                    end
                $(Expr(:symbolicgoto, Symbol("####final#494#502")))
            end
            error("matching non-exhaustive, at #= none:62 =#")
            $(Expr(:symboliclabel, Symbol("####final#494#502")))
            var"##return#493"
        end
    end
