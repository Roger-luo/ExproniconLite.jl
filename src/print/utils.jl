
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
                    var"##cache#1298" = nothing
                end
                var"##return#1295" = nothing
                var"##1297" = body
                if var"##1297" isa Expr && (begin
                                if var"##cache#1298" === nothing
                                    var"##cache#1298" = Some(((var"##1297").head, (var"##1297").args))
                                end
                                var"##1299" = (var"##cache#1298").value
                                var"##1299" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1299"[1] == :block && (begin
                                        var"##1300" = var"##1299"[2]
                                        var"##1300" isa AbstractArray
                                    end && ((ndims(var"##1300") === 1 && length(var"##1300") >= 0) && begin
                                            var"##1301" = SubArray(var"##1300", (1:length(var"##1300"),))
                                            true
                                        end))))
                    var"##return#1295" = let stmts = var"##1301"
                            stmts
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1296#1302")))
                end
                begin
                    var"##return#1295" = let
                            (body,)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1296#1302")))
                end
                error("matching non-exhaustive, at #= none:18 =#")
                $(Expr(:symboliclabel, Symbol("####final#1296#1302")))
                var"##return#1295"
            end
    end
    const expr_infix_wide = Set{Symbol}([:(=), :+=, :-=, :*=, :/=, :\=, :^=, :&=, :|=, :÷=, :%=, :>>>=, :>>=, :<<=, :.=, :.+=, :.-=, :.*=, :./=, :.\=, :.^=, :.&=, :.|=, :.÷=, :.%=, :.>>>=, :.>>=, :.<<=, :&&, :||, :<:, :$=, :⊻=, :>:, :-->])
