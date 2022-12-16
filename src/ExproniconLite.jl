module ExproniconLite
#= /Users/roger/Code/Julia/Expronicon/src/expand.jl:106 =# @static if !(isdefined(#= /Users/roger/Code/Julia/Expronicon/src/expand.jl:106 =# @__MODULE__(), :include_generated))
        function _include_generated(_path::String)
            #= /Users/roger/Code/Julia/Expronicon/src/expand.jl:108 =# Base.@_noinline_meta
            mod = #= /Users/roger/Code/Julia/Expronicon/src/expand.jl:109 =# @__MODULE__()
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
#= /Users/roger/Code/Julia/Expronicon/src/expand.jl:133 =# @static if VERSION < v"1.3"
        macro var_str(x)
            Symbol(x)
        end
    end
export NoDefault, JLExpr, JLFor, JLIfElse, JLFunction, JLField, JLKwField, JLStruct, JLKwStruct, @expr, @test_expr, compare_expr, AnalysisError, is_function, is_kw_function, is_struct, is_tuple, is_splat, is_ifelse, is_for, is_field, is_field_default, is_datatype_expr, is_matrix_expr, split_function, split_function_head, split_struct, split_struct_name, split_ifelse, uninferrable_typevars, has_symbol, is_literal, is_gensym, alias_gensym, has_kwfn_constructor, has_plain_constructor, guess_type, guess_module, Substitute, no_default, prettify, rm_lineinfo, flatten_blocks, name_only, annotations_only, rm_annotations, rm_single_block, rm_nothing, substitute, eval_interp, eval_literal, renumber_gensym, expr_map, nexprs, codegen_ast, codegen_ast_kwfn, codegen_ast_kwfn_plain, codegen_ast_kwfn_infer, codegen_ast_struct, codegen_ast_struct_head, codegen_ast_struct_body, struct_name_plain, struct_name_without_inferable, xtuple, xnamedtuple, xcall, xpush, xgetindex, xfirst, xlast, xprint, xprintln, xmap, xmapreduce, xiterate, print_inline, print_expr, sprint_expr
#= none:59 =# @static if !(#= none:59 =# @isdefined(eachsplit))
        eachsplit(s, pat) = begin
                split(s, pat)
            end
    end
include("types.jl")
_include_generated("transform.jl")
_include_generated("analysis/analysis.jl")
include("codegen.jl")
_include_generated("print/print.jl")
end
