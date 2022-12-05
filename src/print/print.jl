begin
    _include_generated("utils.jl")
    _include_generated("colors.jl")
    _include_generated("inline.jl")
    _include_generated("multi.jl")
    Base.show(io::IO, def::JLExpr) = begin
            print_inline(io, def)
        end
    Base.show(io::IO, ::MIME"text/plain", def::JLExpr) = begin
            print_expr(io, def)
        end
    function (p::Printer)(def::JLExpr)
        p(codegen_ast(def))
    end
    function (p::InlinePrinter)(def::JLExpr)
        p(codegen_ast(def))
    end
    #= none:17 =# Core.@doc "    sprint_expr(ex; context=nothing, kw...)\n\nPrint given expression to `String`, see also [`print_expr`](@ref).\n" function sprint_expr(ex; context = nothing, kw...)
            buf = IOBuffer()
            if context === nothing
                print_expr(buf, ex; kw...)
            else
                print_expr(IOContext(buf, context), ex; kw...)
            end
            return String(take!(buf))
        end
end
