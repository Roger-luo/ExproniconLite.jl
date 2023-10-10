
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
                    var"##cache#1266" = nothing
                end
                var"##return#1263" = nothing
                var"##1265" = body
                if var"##1265" isa Expr && (begin
                                if var"##cache#1266" === nothing
                                    var"##cache#1266" = Some(((var"##1265").head, (var"##1265").args))
                                end
                                var"##1267" = (var"##cache#1266").value
                                var"##1267" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1267"[1] == :block && (begin
                                        var"##1268" = var"##1267"[2]
                                        var"##1268" isa AbstractArray
                                    end && ((ndims(var"##1268") === 1 && length(var"##1268") >= 0) && begin
                                            var"##1269" = SubArray(var"##1268", (1:length(var"##1268"),))
                                            true
                                        end))))
                    var"##return#1263" = let stmts = var"##1269"
                            stmts
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1264#1270")))
                end
                begin
                    var"##return#1263" = let
                            (body,)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1264#1270")))
                end
                error("matching non-exhaustive, at #= none:18 =#")
                $(Expr(:symboliclabel, Symbol("####final#1264#1270")))
                var"##return#1263"
            end
    end
    const expr_infix_wide = Set{Symbol}([:(=), :+=, :-=, :*=, :/=, :\=, :^=, :&=, :|=, :÷=, :%=, :>>>=, :>>=, :<<=, :.=, :.+=, :.-=, :.*=, :./=, :.\=, :.^=, :.&=, :.|=, :.÷=, :.%=, :.>>>=, :.>>=, :.<<=, :&&, :||, :<:, :$=, :⊻=, :>:, :-->])
