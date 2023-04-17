
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
                    var"##cache#1326" = nothing
                end
                var"##return#1323" = nothing
                var"##1325" = body
                if var"##1325" isa Expr && (begin
                                if var"##cache#1326" === nothing
                                    var"##cache#1326" = Some(((var"##1325").head, (var"##1325").args))
                                end
                                var"##1327" = (var"##cache#1326").value
                                var"##1327" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1327"[1] == :block && (begin
                                        var"##1328" = var"##1327"[2]
                                        var"##1328" isa AbstractArray
                                    end && ((ndims(var"##1328") === 1 && length(var"##1328") >= 0) && begin
                                            var"##1329" = SubArray(var"##1328", (1:length(var"##1328"),))
                                            true
                                        end))))
                    var"##return#1323" = let stmts = var"##1329"
                            stmts
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1324#1330")))
                end
                begin
                    var"##return#1323" = let
                            (body,)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1324#1330")))
                end
                error("matching non-exhaustive, at #= none:18 =#")
                $(Expr(:symboliclabel, Symbol("####final#1324#1330")))
                var"##return#1323"
            end
    end
    const expr_infix_wide = Set{Symbol}([:(=), :+=, :-=, :*=, :/=, :\=, :^=, :&=, :|=, :÷=, :%=, :>>>=, :>>=, :<<=, :.=, :.+=, :.-=, :.*=, :./=, :.\=, :.^=, :.&=, :.|=, :.÷=, :.%=, :.>>>=, :.>>=, :.<<=, :&&, :||, :<:, :$=, :⊻=, :>:, :-->])
