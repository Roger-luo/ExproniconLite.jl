
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
                    var"##cache#1379" = nothing
                end
                var"##return#1376" = nothing
                var"##1378" = body
                if var"##1378" isa Expr && (begin
                                if var"##cache#1379" === nothing
                                    var"##cache#1379" = Some(((var"##1378").head, (var"##1378").args))
                                end
                                var"##1380" = (var"##cache#1379").value
                                var"##1380" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1380"[1] == :block && (begin
                                        var"##1381" = var"##1380"[2]
                                        var"##1381" isa AbstractArray
                                    end && ((ndims(var"##1381") === 1 && length(var"##1381") >= 0) && begin
                                            var"##1382" = SubArray(var"##1381", (1:length(var"##1381"),))
                                            true
                                        end))))
                    var"##return#1376" = let stmts = var"##1382"
                            stmts
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1377#1383")))
                end
                begin
                    var"##return#1376" = let
                            (body,)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1377#1383")))
                end
                error("matching non-exhaustive, at #= none:18 =#")
                $(Expr(:symboliclabel, Symbol("####final#1377#1383")))
                var"##return#1376"
            end
    end
    const expr_infix_wide = Set{Symbol}([:(=), :+=, :-=, :*=, :/=, :\=, :^=, :&=, :|=, :÷=, :%=, :>>>=, :>>=, :<<=, :.=, :.+=, :.-=, :.*=, :./=, :.\=, :.^=, :.&=, :.|=, :.÷=, :.%=, :.>>>=, :.>>=, :.<<=, :&&, :||, :<:, :$=, :⊻=, :>:, :-->])
