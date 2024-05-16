
    function mapjoin(f, xs, sep = ", ")
        for (i, x) = enumerate(xs)
            f(x)
            if i != length(xs)
                f(sep)
            end
        end
        return nothing
    end
    function is_line_no(x)
        x isa LineNumberNode && return true
        x isa Expr && (x.head == :line && return true)
        return false
    end
    function split_body(body)
        return let
                begin
                    var"##cache#1354" = nothing
                end
                var"##return#1351" = nothing
                var"##1353" = body
                if var"##1353" isa Expr && (begin
                                if var"##cache#1354" === nothing
                                    var"##cache#1354" = Some(((var"##1353").head, (var"##1353").args))
                                end
                                var"##1355" = (var"##cache#1354").value
                                var"##1355" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1355"[1] == :block && (begin
                                        var"##1356" = var"##1355"[2]
                                        var"##1356" isa AbstractArray
                                    end && ((ndims(var"##1356") === 1 && length(var"##1356") >= 0) && begin
                                            var"##1357" = SubArray(var"##1356", (1:length(var"##1356"),))
                                            true
                                        end))))
                    var"##return#1351" = let stmts = var"##1357"
                            stmts
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1352#1358")))
                end
                begin
                    var"##return#1351" = let
                            (body,)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1352#1358")))
                end
                error("matching non-exhaustive, at #= none:18 =#")
                $(Expr(:symboliclabel, Symbol("####final#1352#1358")))
                var"##return#1351"
            end
    end
    const expr_infix_wide = Set{Symbol}([:(=), :+=, :-=, :*=, :/=, :\=, :^=, :&=, :|=, :÷=, :%=, :>>>=, :>>=, :<<=, :.=, :.+=, :.-=, :.*=, :./=, :.\=, :.^=, :.&=, :.|=, :.÷=, :.%=, :.>>>=, :.>>=, :.<<=, :&&, :||, :<:, :$=, :⊻=, :>:, :-->])
