
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
                    var"##cache#1269" = nothing
                end
                var"##return#1266" = nothing
                var"##1268" = body
                if var"##1268" isa Expr && (begin
                                if var"##cache#1269" === nothing
                                    var"##cache#1269" = Some(((var"##1268").head, (var"##1268").args))
                                end
                                var"##1270" = (var"##cache#1269").value
                                var"##1270" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1270"[1] == :block && (begin
                                        var"##1271" = var"##1270"[2]
                                        var"##1271" isa AbstractArray
                                    end && ((ndims(var"##1271") === 1 && length(var"##1271") >= 0) && begin
                                            var"##1272" = SubArray(var"##1271", (1:length(var"##1271"),))
                                            true
                                        end))))
                    var"##return#1266" = let stmts = var"##1272"
                            stmts
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1267#1273")))
                end
                begin
                    var"##return#1266" = let
                            (body,)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1267#1273")))
                end
                error("matching non-exhaustive, at #= none:18 =#")
                $(Expr(:symboliclabel, Symbol("####final#1267#1273")))
                var"##return#1266"
            end
    end
    const expr_infix_wide = Set{Symbol}([:(=), :+=, :-=, :*=, :/=, :\=, :^=, :&=, :|=, :÷=, :%=, :>>>=, :>>=, :<<=, :.=, :.+=, :.-=, :.*=, :./=, :.\=, :.^=, :.&=, :.|=, :.÷=, :.%=, :.>>>=, :.>>=, :.<<=, :&&, :||, :<:, :$=, :⊻=, :>:, :-->])
