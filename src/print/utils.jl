
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
                    var"##cache#1284" = nothing
                end
                var"##return#1281" = nothing
                var"##1283" = body
                if var"##1283" isa Expr && (begin
                                if var"##cache#1284" === nothing
                                    var"##cache#1284" = Some(((var"##1283").head, (var"##1283").args))
                                end
                                var"##1285" = (var"##cache#1284").value
                                var"##1285" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1285"[1] == :block && (begin
                                        var"##1286" = var"##1285"[2]
                                        var"##1286" isa AbstractArray
                                    end && ((ndims(var"##1286") === 1 && length(var"##1286") >= 0) && begin
                                            var"##1287" = SubArray(var"##1286", (1:length(var"##1286"),))
                                            true
                                        end))))
                    var"##return#1281" = let stmts = var"##1287"
                            stmts
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1282#1288")))
                end
                begin
                    var"##return#1281" = let
                            (body,)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1282#1288")))
                end
                error("matching non-exhaustive, at #= none:18 =#")
                $(Expr(:symboliclabel, Symbol("####final#1282#1288")))
                var"##return#1281"
            end
    end
    const expr_infix_wide = Set{Symbol}([:(=), :+=, :-=, :*=, :/=, :\=, :^=, :&=, :|=, :÷=, :%=, :>>>=, :>>=, :<<=, :.=, :.+=, :.-=, :.*=, :./=, :.\=, :.^=, :.&=, :.|=, :.÷=, :.%=, :.>>>=, :.>>=, :.<<=, :&&, :||, :<:, :$=, :⊻=, :>:, :-->])
