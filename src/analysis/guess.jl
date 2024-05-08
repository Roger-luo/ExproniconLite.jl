
    #= none:1 =# Core.@doc "    guess_module(m, ex)\n\nGuess the module of given expression `ex` (of a module)\nin module `m`. If `ex` is not a module, or cannot be\ndetermined return `nothing`.\n" function guess_module(m::Module, ex)
            begin
                begin
                    var"##cache#472" = nothing
                end
                var"##471" = ex
                if var"##471" isa Expr
                    if begin
                                if var"##cache#472" === nothing
                                    var"##cache#472" = Some(((var"##471").head, (var"##471").args))
                                end
                                var"##473" = (var"##cache#472").value
                                var"##473" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##473"[1] == :. && (begin
                                        var"##474" = var"##473"[2]
                                        var"##474" isa AbstractArray
                                    end && (length(var"##474") === 2 && (begin
                                                var"##475" = var"##474"[1]
                                                var"##476" = var"##474"[2]
                                                var"##476" isa QuoteNode
                                            end && begin
                                                var"##477" = (var"##476").value
                                                true
                                            end))))
                        name = var"##475"
                        sub = var"##477"
                        var"##return#469" = begin
                                mod = guess_module(m, name)
                                if mod isa Module
                                    return guess_module(mod, sub)
                                else
                                    return ex
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#470#478")))
                    end
                end
                if var"##471" isa Symbol
                    if isdefined(m, ex)
                        var"##return#469" = begin
                                maybe_m = getproperty(m, ex)
                                maybe_m isa Module && return maybe_m
                                return ex
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#470#478")))
                    end
                end
                if var"##471" isa Module
                    begin
                        var"##return#469" = begin
                                return ex
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#470#478")))
                    end
                end
                begin
                    var"##return#469" = begin
                            return ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#470#478")))
                end
                error("matching non-exhaustive, at #= none:9 =#")
                $(Expr(:symboliclabel, Symbol("####final#470#478")))
                var"##return#469"
            end
        end
    #= none:28 =# Core.@doc "    guess_type(m::Module, ex)\n\nGuess the actual type of expression `ex` (of a type) in module `m`.\nReturns the type if it can be determined, otherwise returns the\nexpression. This function is used in [`compare_expr`](@ref).\n" function guess_type(m::Module, ex)
            begin
                begin
                    var"##cache#482" = nothing
                end
                var"##481" = ex
                if var"##481" isa Expr
                    if begin
                                if var"##cache#482" === nothing
                                    var"##cache#482" = Some(((var"##481").head, (var"##481").args))
                                end
                                var"##483" = (var"##cache#482").value
                                var"##483" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##483"[1] == :curly && (begin
                                        var"##484" = var"##483"[2]
                                        var"##484" isa AbstractArray
                                    end && ((ndims(var"##484") === 1 && length(var"##484") >= 1) && begin
                                            var"##485" = var"##484"[1]
                                            var"##486" = SubArray(var"##484", (2:length(var"##484"),))
                                            true
                                        end)))
                        typevars = var"##486"
                        name = var"##485"
                        var"##return#479" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#480#487")))
                    end
                end
                if var"##481" isa Symbol
                    begin
                        var"##return#479" = begin
                                isdefined(m, ex) || return ex
                                return getproperty(m, ex)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#480#487")))
                    end
                end
                if var"##481" isa Type
                    begin
                        var"##return#479" = begin
                                return ex
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#480#487")))
                    end
                end
                if var"##481" isa QuoteNode
                    begin
                        var"##return#479" = begin
                                return ex
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#480#487")))
                    end
                end
                begin
                    var"##return#479" = begin
                            return ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#480#487")))
                end
                error("matching non-exhaustive, at #= none:36 =#")
                $(Expr(:symboliclabel, Symbol("####final#480#487")))
                var"##return#479"
            end
        end
    function guess_value(m::Module, ex)
        let
            begin
                var"##cache#491" = nothing
            end
            var"##return#488" = nothing
            var"##490" = ex
            if var"##490" isa Expr
                if begin
                            if var"##cache#491" === nothing
                                var"##cache#491" = Some(((var"##490").head, (var"##490").args))
                            end
                            var"##492" = (var"##cache#491").value
                            var"##492" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##492"[1] == :. && (begin
                                    var"##493" = var"##492"[2]
                                    var"##493" isa AbstractArray
                                end && (length(var"##493") === 2 && (begin
                                            var"##494" = var"##493"[1]
                                            var"##495" = var"##493"[2]
                                            var"##495" isa QuoteNode
                                        end && begin
                                            var"##496" = (var"##495").value
                                            true
                                        end))))
                    var"##return#488" = let name = var"##494", sub = var"##496"
                            mod = guess_module(m, name)
                            if mod isa Module
                                return guess_value(mod, sub)
                            else
                                return ex
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#489#497")))
                end
            end
            if var"##490" isa Symbol
                begin
                    var"##return#488" = let
                            if isdefined(m, ex)
                                getfield(m, ex)
                            else
                                ex
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#489#497")))
                end
            end
            begin
                var"##return#488" = let
                        ex
                    end
                $(Expr(:symbolicgoto, Symbol("####final#489#497")))
            end
            error("matching non-exhaustive, at #= none:62 =#")
            $(Expr(:symboliclabel, Symbol("####final#489#497")))
            var"##return#488"
        end
    end
