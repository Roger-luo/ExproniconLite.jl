
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
                    var"##cache#1304" = nothing
                end
                var"##return#1301" = nothing
                var"##1303" = body
                if var"##1303" isa Expr && (begin
                                if var"##cache#1304" === nothing
                                    var"##cache#1304" = Some(((var"##1303").head, (var"##1303").args))
                                end
                                var"##1305" = (var"##cache#1304").value
                                var"##1305" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1305"[1] == :block && (begin
                                        var"##1306" = var"##1305"[2]
                                        var"##1306" isa AbstractArray
                                    end && ((ndims(var"##1306") === 1 && length(var"##1306") >= 0) && begin
                                            var"##1307" = SubArray(var"##1306", (1:length(var"##1306"),))
                                            true
                                        end))))
                    var"##return#1301" = let stmts = var"##1307"
                            stmts
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1302#1308")))
                end
                begin
                    var"##return#1301" = let
                            (body,)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1302#1308")))
                end
                error("matching non-exhaustive, at #= none:18 =#")
                $(Expr(:symboliclabel, Symbol("####final#1302#1308")))
                var"##return#1301"
            end
    end
    const expr_infix_wide = Set{Symbol}([:(=), :+=, :-=, :*=, :/=, :\=, :^=, :&=, :|=, :÷=, :%=, :>>>=, :>>=, :<<=, :.=, :.+=, :.-=, :.*=, :./=, :.\=, :.^=, :.&=, :.|=, :.÷=, :.%=, :.>>>=, :.>>=, :.<<=, :&&, :||, :<:, :$=, :⊻=, :>:, :-->])
