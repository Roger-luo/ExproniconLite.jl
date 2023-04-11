
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
                    var"##cache#1294" = nothing
                end
                var"##return#1291" = nothing
                var"##1293" = body
                if var"##1293" isa Expr && (begin
                                if var"##cache#1294" === nothing
                                    var"##cache#1294" = Some(((var"##1293").head, (var"##1293").args))
                                end
                                var"##1295" = (var"##cache#1294").value
                                var"##1295" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1295"[1] == :block && (begin
                                        var"##1296" = var"##1295"[2]
                                        var"##1296" isa AbstractArray
                                    end && ((ndims(var"##1296") === 1 && length(var"##1296") >= 0) && begin
                                            var"##1297" = SubArray(var"##1296", (1:length(var"##1296"),))
                                            true
                                        end))))
                    var"##return#1291" = let stmts = var"##1297"
                            stmts
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1292#1298")))
                end
                begin
                    var"##return#1291" = let
                            (body,)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1292#1298")))
                end
                error("matching non-exhaustive, at #= none:18 =#")
                $(Expr(:symboliclabel, Symbol("####final#1292#1298")))
                var"##return#1291"
            end
    end
    const expr_infix_wide = Set{Symbol}([:(=), :+=, :-=, :*=, :/=, :\=, :^=, :&=, :|=, :÷=, :%=, :>>>=, :>>=, :<<=, :.=, :.+=, :.-=, :.*=, :./=, :.\=, :.^=, :.&=, :.|=, :.÷=, :.%=, :.>>>=, :.>>=, :.<<=, :&&, :||, :<:, :$=, :⊻=, :>:, :-->])
