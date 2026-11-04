
    #= none:1 =# Core.@doc "    guess_module(m, ex)\n\nGuess the module of given expression `ex` (of a module)\nin module `m`. If `ex` is not a module, or cannot be\ndetermined return `nothing`.\n" function guess_module(m::Module, ex)
            begin
                begin
                    var"##cache#406" = nothing
                end
                var"##405" = ex
                if var"##405" isa Symbol
                    if isdefined(m, ex)
                        var"##return#403" = begin
                                maybe_m = getproperty(m, ex)
                                maybe_m isa Module && return maybe_m
                                return ex
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#404#412")))
                    end
                end
                if var"##405" isa Expr
                    if begin
                                if var"##cache#406" === nothing
                                    var"##cache#406" = Some(((var"##405").head, (var"##405").args))
                                end
                                var"##407" = (var"##cache#406").value
                                var"##407" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##407"[1] == :. && (begin
                                        var"##408" = var"##407"[2]
                                        var"##408" isa AbstractArray
                                    end && (length(var"##408") === 2 && (begin
                                                var"##409" = var"##408"[1]
                                                var"##410" = var"##408"[2]
                                                var"##410" isa QuoteNode
                                            end && begin
                                                var"##411" = (var"##410").value
                                                true
                                            end))))
                        name = var"##409"
                        sub = var"##411"
                        var"##return#403" = begin
                                mod = guess_module(m, name)
                                if mod isa Module
                                    return guess_module(mod, sub)
                                else
                                    return ex
                                end
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#404#412")))
                    end
                end
                if var"##405" isa Module
                    begin
                        var"##return#403" = begin
                                return ex
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#404#412")))
                    end
                end
                begin
                    var"##return#403" = begin
                            return ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#404#412")))
                end
                error("matching non-exhaustive, at #= none:9 =#")
                $(Expr(:symboliclabel, Symbol("####final#404#412")))
                var"##return#403"
            end
        end
    #= none:28 =# Core.@doc "    guess_type(m::Module, ex)\n\nGuess the actual type of expression `ex` (of a type) in module `m`.\nReturns the type if it can be determined, otherwise returns the\nexpression. This function is used in [`compare_expr`](@ref).\n" function guess_type(m::Module, ex)
            begin
                begin
                    var"##cache#416" = nothing
                end
                var"##415" = ex
                if var"##415" isa Symbol
                    begin
                        var"##return#413" = begin
                                isdefined(m, ex) || return ex
                                return getproperty(m, ex)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#414#421")))
                    end
                end
                if var"##415" isa Expr
                    if begin
                                if var"##cache#416" === nothing
                                    var"##cache#416" = Some(((var"##415").head, (var"##415").args))
                                end
                                var"##417" = (var"##cache#416").value
                                var"##417" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##417"[1] == :curly && (begin
                                        var"##418" = var"##417"[2]
                                        var"##418" isa AbstractArray
                                    end && ((ndims(var"##418") === 1 && length(var"##418") >= 1) && begin
                                            var"##419" = var"##418"[1]
                                            var"##420" = SubArray(var"##418", (2:length(var"##418"),))
                                            true
                                        end)))
                        typevars = var"##420"
                        name = var"##419"
                        var"##return#413" = begin
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
                        $(Expr(:symbolicgoto, Symbol("####final#414#421")))
                    end
                end
                if var"##415" isa QuoteNode
                    begin
                        var"##return#413" = begin
                                return ex
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#414#421")))
                    end
                end
                if var"##415" isa Type
                    begin
                        var"##return#413" = begin
                                return ex
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#414#421")))
                    end
                end
                begin
                    var"##return#413" = begin
                            return ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#414#421")))
                end
                error("matching non-exhaustive, at #= none:36 =#")
                $(Expr(:symboliclabel, Symbol("####final#414#421")))
                var"##return#413"
            end
        end
    function guess_value(m::Module, ex)
        let
            begin
                var"##cache#425" = nothing
            end
            var"##return#422" = nothing
            var"##424" = ex
            if var"##424" isa Symbol
                begin
                    var"##return#422" = let
                            if isdefined(m, ex)
                                getfield(m, ex)
                            else
                                ex
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#423#431")))
                end
            end
            if var"##424" isa Expr
                if begin
                            if var"##cache#425" === nothing
                                var"##cache#425" = Some(((var"##424").head, (var"##424").args))
                            end
                            var"##426" = (var"##cache#425").value
                            var"##426" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##426"[1] == :. && (begin
                                    var"##427" = var"##426"[2]
                                    var"##427" isa AbstractArray
                                end && (length(var"##427") === 2 && (begin
                                            var"##428" = var"##427"[1]
                                            var"##429" = var"##427"[2]
                                            var"##429" isa QuoteNode
                                        end && begin
                                            var"##430" = (var"##429").value
                                            true
                                        end))))
                    var"##return#422" = let name = var"##428", sub = var"##430"
                            mod = guess_module(m, name)
                            if mod isa Module
                                return guess_value(mod, sub)
                            else
                                return ex
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#423#431")))
                end
            end
            begin
                var"##return#422" = let
                        ex
                    end
                $(Expr(:symbolicgoto, Symbol("####final#423#431")))
            end
            error("matching non-exhaustive, at #= none:62 =#")
            $(Expr(:symboliclabel, Symbol("####final#423#431")))
            var"##return#422"
        end
    end
