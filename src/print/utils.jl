
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
                    var"##cache#1286" = nothing
                end
                var"##return#1283" = nothing
                var"##1285" = body
                if var"##1285" isa Expr && (begin
                                if var"##cache#1286" === nothing
                                    var"##cache#1286" = Some(((var"##1285").head, (var"##1285").args))
                                end
                                var"##1287" = (var"##cache#1286").value
                                var"##1287" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1287"[1] == :block && (begin
                                        var"##1288" = var"##1287"[2]
                                        var"##1288" isa AbstractArray
                                    end && ((ndims(var"##1288") === 1 && length(var"##1288") >= 0) && begin
                                            var"##1289" = SubArray(var"##1288", (1:length(var"##1288"),))
                                            true
                                        end))))
                    var"##return#1283" = let stmts = var"##1289"
                            stmts
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1284#1290")))
                end
                begin
                    var"##return#1283" = let
                            (body,)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1284#1290")))
                end
                error("matching non-exhaustive, at #= none:18 =#")
                $(Expr(:symboliclabel, Symbol("####final#1284#1290")))
                var"##return#1283"
            end
    end
    const expr_infix_wide = Set{Symbol}([:(=), :+=, :-=, :*=, :/=, :\=, :^=, :&=, :|=, :÷=, :%=, :>>>=, :>>=, :<<=, :.=, :.+=, :.-=, :.*=, :./=, :.\=, :.^=, :.&=, :.|=, :.÷=, :.%=, :.>>>=, :.>>=, :.<<=, :&&, :||, :<:, :$=, :⊻=, :>:, :-->])
