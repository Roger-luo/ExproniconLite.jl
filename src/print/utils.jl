
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
                    var"##cache#1309" = nothing
                end
                var"##return#1306" = nothing
                var"##1308" = body
                if var"##1308" isa Expr && (begin
                                if var"##cache#1309" === nothing
                                    var"##cache#1309" = Some(((var"##1308").head, (var"##1308").args))
                                end
                                var"##1310" = (var"##cache#1309").value
                                var"##1310" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1310"[1] == :block && (begin
                                        var"##1311" = var"##1310"[2]
                                        var"##1311" isa AbstractArray
                                    end && ((ndims(var"##1311") === 1 && length(var"##1311") >= 0) && begin
                                            var"##1312" = SubArray(var"##1311", (1:length(var"##1311"),))
                                            true
                                        end))))
                    var"##return#1306" = let stmts = var"##1312"
                            stmts
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1307#1313")))
                end
                begin
                    var"##return#1306" = let
                            (body,)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1307#1313")))
                end
                error("matching non-exhaustive, at #= none:18 =#")
                $(Expr(:symboliclabel, Symbol("####final#1307#1313")))
                var"##return#1306"
            end
    end
    const expr_infix_wide = Set{Symbol}([:(=), :+=, :-=, :*=, :/=, :\=, :^=, :&=, :|=, :÷=, :%=, :>>>=, :>>=, :<<=, :.=, :.+=, :.-=, :.*=, :./=, :.\=, :.^=, :.&=, :.|=, :.÷=, :.%=, :.>>>=, :.>>=, :.<<=, :&&, :||, :<:, :$=, :⊻=, :>:, :-->])
