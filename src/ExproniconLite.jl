module ExproniconLite
export NoDefault, JLExpr, JLFor, JLIfElse, JLFunction, JLField, JLKwField, JLStruct, JLKwStruct, @expr, @test_expr, compare_expr, compare_vars, AnalysisError, is_function, is_kw_function, is_struct, is_ifelse, is_for, is_field, is_field_default, split_function, split_function_head, split_struct, split_struct_name, split_ifelse, annotations, uninferrable_typevars, has_symbol, is_literal, has_kwfn_constructor, has_plain_constructor, no_default, prettify, rm_lineinfo, flatten_blocks, name_only, rm_annotations, rm_single_block, rm_nothing, replace_symbol, subtitute, eval_interp, eval_literal, codegen_ast, codegen_ast_kwfn, codegen_ast_kwfn_plain, codegen_ast_kwfn_infer, codegen_ast_struct, codegen_ast_struct_head, codegen_ast_struct_body, construct_method_plain, construct_method_inferable, struct_name_plain, struct_name_without_inferable, xtuple, xnamedtuple, xcall, xpush, xfirst, xlast, xprint, xprintln, xmap, xmapreduce, xiterate, print_expr, sprint_expr

if VERSION < v"1.3"
    macro var_str(x)
        Symbol(x)
    end
end

include("types.jl")
#= /home/roger/code/julia/Expronicon/src/expand.jl:99 =# @static if !(isdefined(#= /home/roger/code/julia/Expronicon/src/expand.jl:99 =# @__MODULE__(), :include_generated))
        function include_generated(m::Module, path::String)
            raw = read(path, String)
            ex = Base.include_string(m, "quote $(raw) end", path)
            m.eval(m.eval(ex))
            return
        end
    end
include_generated(#= /home/roger/code/julia/Expronicon/src/expand.jl:113 =# @__MODULE__(), joinpath(#= /home/roger/code/julia/Expronicon/src/expand.jl:113 =# @__DIR__(), "transform.jl"))
include_generated(#= /home/roger/code/julia/Expronicon/src/expand.jl:117 =# @__MODULE__(), joinpath(#= /home/roger/code/julia/Expronicon/src/expand.jl:117 =# @__DIR__(), "analysis.jl"))
include("codegen.jl")
include_generated(#= /home/roger/code/julia/Expronicon/src/expand.jl:117 =# @__MODULE__(), joinpath(#= /home/roger/code/julia/Expronicon/src/expand.jl:117 =# @__DIR__(), "printing.jl"))
end
