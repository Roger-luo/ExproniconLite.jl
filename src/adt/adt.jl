module ADT
#= /Users/roger/Code/Julia/Expronicon/src/expand.jl:114 =# @static if !(isdefined(#= /Users/roger/Code/Julia/Expronicon/src/expand.jl:114 =# @__MODULE__(), :include_generated))
        function _include_generated(_path::String)
            #= /Users/roger/Code/Julia/Expronicon/src/expand.jl:116 =# Base.@_noinline_meta
            mod = #= /Users/roger/Code/Julia/Expronicon/src/expand.jl:117 =# @__MODULE__()
            (path, prev) = Base._include_dependency(mod, _path)
            code = read(path, String)
            tls = task_local_storage()
            tls[:SOURCE_PATH] = path
            try
                ex = include_string(mod, "quote $(code) end", path)
                mod.eval(mod.eval(ex))
                return
            finally
                if prev === nothing
                    delete!(tls, :SOURCE_PATH)
                else
                    tls[:SOURCE_PATH] = prev
                end
            end
        end
    end
#= /Users/roger/Code/Julia/Expronicon/src/expand.jl:141 =# @static if VERSION < v"1.3"
        macro var_str(x)
            Symbol(x)
        end
    end
using MLStyle.MatchImpl: and, P_capture, guard
using ..ExproniconLite
using ..ExproniconLite: Maybe
_include_generated("utils.jl")
_include_generated("traits.jl")
include("types.jl")
_include_generated("emit.jl")
_include_generated("match.jl")
_include_generated("print.jl")
end
