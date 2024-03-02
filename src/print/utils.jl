
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
                    var"##cache#1312" = nothing
                end
                var"##return#1309" = nothing
                var"##1311" = body
                if var"##1311" isa Expr && (begin
                                if var"##cache#1312" === nothing
                                    var"##cache#1312" = Some(((var"##1311").head, (var"##1311").args))
                                end
                                var"##1313" = (var"##cache#1312").value
                                var"##1313" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1313"[1] == :block && (begin
                                        var"##1314" = var"##1313"[2]
                                        var"##1314" isa AbstractArray
                                    end && ((ndims(var"##1314") === 1 && length(var"##1314") >= 0) && begin
                                            var"##1315" = SubArray(var"##1314", (1:length(var"##1314"),))
                                            true
                                        end))))
                    var"##return#1309" = let stmts = var"##1315"
                            stmts
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1310#1316")))
                end
                begin
                    var"##return#1309" = let
                            (body,)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1310#1316")))
                end
                error("matching non-exhaustive, at #= none:18 =#")
                $(Expr(:symboliclabel, Symbol("####final#1310#1316")))
                var"##return#1309"
            end
    end
    const expr_infix_wide = Set{Symbol}([:(=), :+=, :-=, :*=, :/=, :\=, :^=, :&=, :|=, :÷=, :%=, :>>>=, :>>=, :<<=, :.=, :.+=, :.-=, :.*=, :./=, :.\=, :.^=, :.&=, :.|=, :.÷=, :.%=, :.>>>=, :.>>=, :.<<=, :&&, :||, :<:, :$=, :⊻=, :>:, :-->])
