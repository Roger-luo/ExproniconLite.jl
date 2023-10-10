
    #= none:1 =# Core.@doc "    guess_module(m, ex)\n\nGuess the module of given expression `ex` (of a module)\nin module `m`. If `ex` is not a module, or cannot be\ndetermined return `nothing`.\n" function guess_module(m::Module, ex)
            begin
                begin
                    var"##cache#471" = nothing
                end
                var"##470" = ex
                if var"##470" isa Expr
                    if begin
                                if var"##cache#471" === nothing
                                    var"##cache#471" = Some(((var"##470").head, (var"##470").args))
                                end
                                var"##472" = (var"##cache#471").value
                                var"##472" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##472"[1] == :. && (begin
                                        var"##473" = var"##472"[2]
                                        var"##473" isa AbstractArray
                                    end && (length(var"##473") === 2 && (begin
                                                var"##474" = var"##473"[1]
                                                var"##475" = var"##473"[2]
                                                var"##475" isa QuoteNode
                                            end && begin
                                                var"##476" = (var"##475").value
                                                true
                                            end))))
                        name = var"##474"
                        sub = var"##476"
                        var"##return#468" = begin
                                mod = guess_module(m, name)
                                if mod isa Module
                                    return guess_module(mod, sub)
                                else
                                    return ex
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#469#477")))
                    end
                end
                if var"##470" isa Symbol
                    if isdefined(m, ex)
                        var"##return#468" = begin
                                maybe_m = getproperty(m, ex)
                                maybe_m isa Module && return maybe_m
                                return ex
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#469#477")))
                    end
                end
                if var"##470" isa Module
                    begin
                        var"##return#468" = begin
                                return ex
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#469#477")))
                    end
                end
                begin
                    var"##return#468" = begin
                            return ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#469#477")))
                end
                error("matching non-exhaustive, at #= none:9 =#")
                $(Expr(:symboliclabel, Symbol("####final#469#477")))
                var"##return#468"
            end
        end
    #= none:28 =# Core.@doc "    guess_type(m::Module, ex)\n\nGuess the actual type of expression `ex` (of a type) in module `m`.\nReturns the type if it can be determined, otherwise returns the\nexpression. This function is used in [`compare_expr`](@ref).\n" function guess_type(m::Module, ex)
            begin
                begin
                    var"##cache#481" = nothing
                end
                var"##480" = ex
                if var"##480" isa Expr
                    if begin
                                if var"##cache#481" === nothing
                                    var"##cache#481" = Some(((var"##480").head, (var"##480").args))
                                end
                                var"##482" = (var"##cache#481").value
                                var"##482" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##482"[1] == :curly && (begin
                                        var"##483" = var"##482"[2]
                                        var"##483" isa AbstractArray
                                    end && ((ndims(var"##483") === 1 && length(var"##483") >= 1) && begin
                                            var"##484" = var"##483"[1]
                                            var"##485" = SubArray(var"##483", (2:length(var"##483"),))
                                            true
                                        end)))
                        typevars = var"##485"
                        name = var"##484"
                        var"##return#478" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#479#486")))
                    end
                end
                if var"##480" isa Symbol
                    begin
                        var"##return#478" = begin
                                isdefined(m, ex) || return ex
                                return getproperty(m, ex)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#479#486")))
                    end
                end
                if var"##480" isa Type
                    begin
                        var"##return#478" = begin
                                return ex
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#479#486")))
                    end
                end
                if var"##480" isa QuoteNode
                    begin
                        var"##return#478" = begin
                                return ex
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#479#486")))
                    end
                end
                begin
                    var"##return#478" = begin
                            return ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#479#486")))
                end
                error("matching non-exhaustive, at #= none:36 =#")
                $(Expr(:symboliclabel, Symbol("####final#479#486")))
                var"##return#478"
            end
        end
    function guess_value(m::Module, ex)
        let
            begin
                var"##cache#490" = nothing
            end
            var"##return#487" = nothing
            var"##489" = ex
            if var"##489" isa Expr
                if begin
                            if var"##cache#490" === nothing
                                var"##cache#490" = Some(((var"##489").head, (var"##489").args))
                            end
                            var"##491" = (var"##cache#490").value
                            var"##491" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##491"[1] == :. && (begin
                                    var"##492" = var"##491"[2]
                                    var"##492" isa AbstractArray
                                end && (length(var"##492") === 2 && (begin
                                            var"##493" = var"##492"[1]
                                            var"##494" = var"##492"[2]
                                            var"##494" isa QuoteNode
                                        end && begin
                                            var"##495" = (var"##494").value
                                            true
                                        end))))
                    var"##return#487" = let name = var"##493", sub = var"##495"
                            mod = guess_module(m, name)
                            if mod isa Module
                                return guess_value(mod, sub)
                            else
                                return ex
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#488#496")))
                end
            end
            if var"##489" isa Symbol
                begin
                    var"##return#487" = let
                            if isdefined(m, ex)
                                getfield(m, ex)
                            else
                                ex
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#488#496")))
                end
            end
            begin
                var"##return#487" = let
                        ex
                    end
                $(Expr(:symbolicgoto, Symbol("####final#488#496")))
            end
            error("matching non-exhaustive, at #= none:62 =#")
            $(Expr(:symboliclabel, Symbol("####final#488#496")))
            var"##return#487"
        end
    end
