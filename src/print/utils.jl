
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
                    var"##cache#1383" = nothing
                end
                var"##return#1380" = nothing
                var"##1382" = body
                if var"##1382" isa Expr && (begin
                                if var"##cache#1383" === nothing
                                    var"##cache#1383" = Some(((var"##1382").head, (var"##1382").args))
                                end
                                var"##1384" = (var"##cache#1383").value
                                var"##1384" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1384"[1] == :block && (begin
                                        var"##1385" = var"##1384"[2]
                                        var"##1385" isa AbstractArray
                                    end && ((ndims(var"##1385") === 1 && length(var"##1385") >= 0) && begin
                                            var"##1386" = SubArray(var"##1385", (1:length(var"##1385"),))
                                            true
                                        end))))
                    var"##return#1380" = let stmts = var"##1386"
                            stmts
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1381#1387")))
                end
                begin
                    var"##return#1380" = let
                            (body,)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1381#1387")))
                end
                error("matching non-exhaustive, at #= none:18 =#")
                $(Expr(:symboliclabel, Symbol("####final#1381#1387")))
                var"##return#1380"
            end
    end
    const expr_infix_wide = Set{Symbol}([:(=), :+=, :-=, :*=, :/=, :\=, :^=, :&=, :|=, :÷=, :%=, :>>>=, :>>=, :<<=, :.=, :.+=, :.-=, :.*=, :./=, :.\=, :.^=, :.&=, :.|=, :.÷=, :.%=, :.>>>=, :.>>=, :.<<=, :&&, :||, :<:, :$=, :⊻=, :>:, :-->])
