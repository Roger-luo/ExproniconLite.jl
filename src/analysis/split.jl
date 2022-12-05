begin
    #= none:1 =# Core.@doc "    split_doc(ex::Expr) -> line, doc, expr\n\nSplit doc string from given expression.\n" function split_doc(ex::Expr)
            if ex.head === :macrocall && ex.args[1] == GlobalRef(Core, Symbol("@doc"))
                return (ex.args[2], ex.args[3], ex.args[4])
            else
                return (nothing, nothing, ex)
            end
        end
    #= none:14 =# Core.@doc "    split_function(ex::Expr) -> head, call, body\n\nSplit function head declaration with function body.\n" function split_function(ex::Expr)
            let
                cache_1 = nothing
                return_1 = nothing
                x_1 = ex
                if x_1 isa Expr
                    if begin
                                if cache_1 === nothing
                                    cache_1 = Some((x_1.head, x_1.args))
                                end
                                x_2 = cache_1.value
                                x_2 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_2[1] == :function && (begin
                                        x_3 = x_2[2]
                                        x_3 isa AbstractArray
                                    end && (length(x_3) === 2 && begin
                                            x_4 = x_3[1]
                                            x_5 = x_3[2]
                                            true
                                        end)))
                        return_1 = let call = x_4, body = x_5
                                (:function, call, body)
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#630_1")))
                    end
                    if begin
                                x_6 = cache_1.value
                                x_6 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_6[1] == :(=) && (begin
                                        x_7 = x_6[2]
                                        x_7 isa AbstractArray
                                    end && (length(x_7) === 2 && begin
                                            x_8 = x_7[1]
                                            x_9 = x_7[2]
                                            true
                                        end)))
                        return_1 = let call = x_8, body = x_9
                                (:(=), call, body)
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#630_1")))
                    end
                    if begin
                                x_10 = cache_1.value
                                x_10 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_10[1] == :-> && (begin
                                        x_11 = x_10[2]
                                        x_11 isa AbstractArray
                                    end && (length(x_11) === 2 && begin
                                            x_12 = x_11[1]
                                            x_13 = x_11[2]
                                            true
                                        end)))
                        return_1 = let call = x_12, body = x_13
                                (:->, call, body)
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#630_1")))
                    end
                end
                return_1 = let
                        anlys_error("function", ex)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#630_1")))
                (error)("matching non-exhaustive, at #= none:20 =#")
                $(Expr(:symboliclabel, Symbol("##final#630_1")))
                return_1
            end
        end
    #= none:28 =# Core.@doc "    split_function_head(ex::Expr) -> name, args, kw, whereparams, rettype\n\nSplit function head to name, arguments, keyword arguments and where parameters.\n" function split_function_head(ex::Expr)
            let
                cache_2 = nothing
                return_2 = nothing
                x_14 = ex
                if x_14 isa Expr
                    if begin
                                if cache_2 === nothing
                                    cache_2 = Some((x_14.head, x_14.args))
                                end
                                x_15 = cache_2.value
                                x_15 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_15[1] == :tuple && (begin
                                        x_16 = x_15[2]
                                        x_16 isa AbstractArray
                                    end && ((ndims(x_16) === 1 && length(x_16) >= 1) && (begin
                                                cache_3 = nothing
                                                x_17 = x_16[1]
                                                x_17 isa Expr
                                            end && (begin
                                                    if cache_3 === nothing
                                                        cache_3 = Some((x_17.head, x_17.args))
                                                    end
                                                    x_18 = cache_3.value
                                                    x_18 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                end && (x_18[1] == :parameters && (begin
                                                            x_19 = x_18[2]
                                                            x_19 isa AbstractArray
                                                        end && ((ndims(x_19) === 1 && length(x_19) >= 0) && begin
                                                                x_20 = (SubArray)(x_19, (1:length(x_19),))
                                                                x_21 = (SubArray)(x_16, (2:length(x_16),))
                                                                true
                                                            end))))))))
                        return_2 = let args = x_21, kw = x_20
                                (nothing, args, kw, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#647_1")))
                    end
                    if begin
                                x_22 = cache_2.value
                                x_22 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_22[1] == :tuple && (begin
                                        x_23 = x_22[2]
                                        x_23 isa AbstractArray
                                    end && ((ndims(x_23) === 1 && length(x_23) >= 0) && begin
                                            x_24 = (SubArray)(x_23, (1:length(x_23),))
                                            true
                                        end)))
                        return_2 = let args = x_24
                                (nothing, args, nothing, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#647_1")))
                    end
                    if begin
                                x_25 = cache_2.value
                                x_25 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_25[1] == :call && (begin
                                        x_26 = x_25[2]
                                        x_26 isa AbstractArray
                                    end && ((ndims(x_26) === 1 && length(x_26) >= 2) && (begin
                                                x_27 = x_26[1]
                                                cache_4 = nothing
                                                x_28 = x_26[2]
                                                x_28 isa Expr
                                            end && (begin
                                                    if cache_4 === nothing
                                                        cache_4 = Some((x_28.head, x_28.args))
                                                    end
                                                    x_29 = cache_4.value
                                                    x_29 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                end && (x_29[1] == :parameters && (begin
                                                            x_30 = x_29[2]
                                                            x_30 isa AbstractArray
                                                        end && ((ndims(x_30) === 1 && length(x_30) >= 0) && begin
                                                                x_31 = (SubArray)(x_30, (1:length(x_30),))
                                                                x_32 = (SubArray)(x_26, (3:length(x_26),))
                                                                true
                                                            end))))))))
                        return_2 = let name = x_27, args = x_32, kw = x_31
                                (name, args, kw, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#647_1")))
                    end
                    if begin
                                x_33 = cache_2.value
                                x_33 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_33[1] == :call && (begin
                                        x_34 = x_33[2]
                                        x_34 isa AbstractArray
                                    end && ((ndims(x_34) === 1 && length(x_34) >= 1) && begin
                                            x_35 = x_34[1]
                                            x_36 = (SubArray)(x_34, (2:length(x_34),))
                                            true
                                        end)))
                        return_2 = let name = x_35, args = x_36
                                (name, args, nothing, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#647_1")))
                    end
                    if begin
                                x_37 = cache_2.value
                                x_37 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_37[1] == :block && (begin
                                        x_38 = x_37[2]
                                        x_38 isa AbstractArray
                                    end && (length(x_38) === 3 && (begin
                                                x_39 = x_38[1]
                                                x_40 = x_38[2]
                                                x_40 isa LineNumberNode
                                            end && (begin
                                                    cache_5 = nothing
                                                    x_41 = x_38[3]
                                                    x_41 isa Expr
                                                end && (begin
                                                        if cache_5 === nothing
                                                            cache_5 = Some((x_41.head, x_41.args))
                                                        end
                                                        x_42 = cache_5.value
                                                        x_42 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                    end && (x_42[1] == :(=) && (begin
                                                                x_43 = x_42[2]
                                                                x_43 isa AbstractArray
                                                            end && (length(x_43) === 2 && begin
                                                                    x_44 = x_43[1]
                                                                    x_45 = x_43[2]
                                                                    true
                                                                end)))))))))
                        return_2 = let value = x_45, kw = x_44, x = x_39
                                (nothing, Any[x], Any[Expr(:kw, kw, value)], nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#647_1")))
                    end
                    if begin
                                x_46 = cache_2.value
                                x_46 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_46[1] == :block && (begin
                                        x_47 = x_46[2]
                                        x_47 isa AbstractArray
                                    end && (length(x_47) === 3 && (begin
                                                x_48 = x_47[1]
                                                x_49 = x_47[2]
                                                x_49 isa LineNumberNode
                                            end && begin
                                                x_50 = x_47[3]
                                                true
                                            end))))
                        return_2 = let kw = x_50, x = x_48
                                (nothing, Any[x], Any[kw], nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#647_1")))
                    end
                    if begin
                                x_51 = cache_2.value
                                x_51 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_51[1] == :(::) && (begin
                                        x_52 = x_51[2]
                                        x_52 isa AbstractArray
                                    end && (length(x_52) === 2 && begin
                                            x_53 = x_52[1]
                                            x_54 = x_52[2]
                                            true
                                        end)))
                        return_2 = let call = x_53, rettype = x_54
                                (name, args, kw, whereparams, _) = split_function_head(call)
                                (name, args, kw, whereparams, rettype)
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#647_1")))
                    end
                    if begin
                                x_55 = cache_2.value
                                x_55 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_55[1] == :where && (begin
                                        x_56 = x_55[2]
                                        x_56 isa AbstractArray
                                    end && ((ndims(x_56) === 1 && length(x_56) >= 1) && begin
                                            x_57 = x_56[1]
                                            x_58 = (SubArray)(x_56, (2:length(x_56),))
                                            true
                                        end)))
                        return_2 = let call = x_57, whereparams = x_58
                                (name, args, kw, _, rettype) = split_function_head(call)
                                (name, args, kw, whereparams, rettype)
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#647_1")))
                    end
                end
                return_2 = let
                        anlys_error("function head expr", ex)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#647_1")))
                (error)("matching non-exhaustive, at #= none:34 =#")
                $(Expr(:symboliclabel, Symbol("##final#647_1")))
                return_2
            end
        end
    #= none:53 =# Core.@doc "    split_struct_name(ex::Expr) -> name, typevars, supertype\n\nSplit the name, type parameters and supertype definition from `struct`\ndeclaration head.\n" function split_struct_name(#= none:59 =# @nospecialize(ex))
            return let
                    cache_6 = nothing
                    return_3 = nothing
                    x_59 = ex
                    if x_59 isa Expr
                        if begin
                                    if cache_6 === nothing
                                        cache_6 = Some((x_59.head, x_59.args))
                                    end
                                    x_60 = cache_6.value
                                    x_60 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                end && (x_60[1] == :curly && (begin
                                            x_61 = x_60[2]
                                            x_61 isa AbstractArray
                                        end && ((ndims(x_61) === 1 && length(x_61) >= 1) && begin
                                                x_62 = x_61[1]
                                                x_63 = (SubArray)(x_61, (2:length(x_61),))
                                                true
                                            end)))
                            return_3 = let typevars = x_63, name = x_62
                                    (name, typevars, nothing)
                                end
                            $(Expr(:symbolicgoto, Symbol("##final#699_1")))
                        end
                        if begin
                                    x_64 = cache_6.value
                                    x_64 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                end && (x_64[1] == :<: && (begin
                                            x_65 = x_64[2]
                                            x_65 isa AbstractArray
                                        end && (length(x_65) === 2 && (begin
                                                    cache_7 = nothing
                                                    x_66 = x_65[1]
                                                    x_66 isa Expr
                                                end && (begin
                                                        if cache_7 === nothing
                                                            cache_7 = Some((x_66.head, x_66.args))
                                                        end
                                                        x_67 = cache_7.value
                                                        x_67 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                    end && (x_67[1] == :curly && (begin
                                                                x_68 = x_67[2]
                                                                x_68 isa AbstractArray
                                                            end && ((ndims(x_68) === 1 && length(x_68) >= 1) && begin
                                                                    x_69 = x_68[1]
                                                                    x_70 = (SubArray)(x_68, (2:length(x_68),))
                                                                    x_71 = x_65[2]
                                                                    true
                                                                end))))))))
                            return_3 = let typevars = x_70, type = x_71, name = x_69
                                    (name, typevars, type)
                                end
                            $(Expr(:symbolicgoto, Symbol("##final#699_1")))
                        end
                        if begin
                                    x_72 = cache_6.value
                                    x_72 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                end && (x_72[1] == :<: && (begin
                                            x_73 = x_72[2]
                                            x_73 isa AbstractArray
                                        end && (length(x_73) === 2 && begin
                                                x_74 = x_73[1]
                                                x_75 = x_73[2]
                                                true
                                            end)))
                            return_3 = let type = x_75, name = x_74
                                    (name, [], type)
                                end
                            $(Expr(:symbolicgoto, Symbol("##final#699_1")))
                        end
                    end
                    if x_59 isa Symbol
                        return_3 = let
                                (ex, [], nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#699_1")))
                    end
                    return_3 = let
                            anlys_error("struct", ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#699_1")))
                    (error)("matching non-exhaustive, at #= none:60 =#")
                    $(Expr(:symboliclabel, Symbol("##final#699_1")))
                    return_3
                end
        end
    #= none:69 =# Core.@doc "    split_struct(ex::Expr) -> ismutable, name, typevars, supertype, body\n\nSplit struct definition head and body.\n" function split_struct(ex::Expr)
            ex.head === :struct || error("expect a struct expr, got $(ex)")
            (name, typevars, supertype) = split_struct_name(ex.args[2])
            body = ex.args[3]
            return (ex.args[1], name, typevars, supertype, body)
        end
    function split_ifelse(ex::Expr)
        (conds, stmts) = ([], [])
        otherwise = split_ifelse!((conds, stmts), ex)
        return (conds, stmts, otherwise)
    end
    function split_ifelse!((conds, stmts), ex::Expr)
        ex.head in [:if, :elseif] || return ex
        push!(conds, ex.args[1])
        push!(stmts, ex.args[2])
        if length(ex.args) == 3
            return split_ifelse!((conds, stmts), ex.args[3])
        end
        return
    end
    function split_forloop(ex::Expr)
        ex.head === :for || error("expect a for loop expr, got $(ex)")
        lhead = ex.args[1]
        lbody = ex.args[2]
        return (split_for_head(lhead)..., lbody)
    end
    function split_for_head(ex::Expr)
        if ex.head === :block
            (vars, itrs) = ([], [])
            for each = ex.args
                each isa Expr || continue
                (var, itr) = split_single_for_head(each)
                push!(vars, var)
                push!(itrs, itr)
            end
            return (vars, itrs)
        else
            (var, itr) = split_single_for_head(ex)
            return (Any[var], Any[itr])
        end
    end
    function split_single_for_head(ex::Expr)
        ex.head === :(=) || error("expect a single loop head, got $(ex)")
        return (ex.args[1], ex.args[2])
    end
    #= none:126 =# Core.@doc "    uninferrable_typevars(def::Union{JLStruct, JLKwStruct}; leading_inferable::Bool=true)\n\nReturn the type variables that are not inferrable in given struct definition.\n" function uninferrable_typevars(def::Union{JLStruct, JLKwStruct}; leading_inferable::Bool = true)
            typevars = name_only.(def.typevars)
            field_types = [field.type for field = def.fields]
            if leading_inferable
                idx = findfirst(typevars) do t
                        !(any(map((f->begin
                                            has_symbol(f, t)
                                        end), field_types)))
                    end
                idx === nothing && return []
            else
                idx = 0
            end
            uninferrable = typevars[1:idx]
            for T = typevars[idx + 1:end]
                any(map((f->begin
                                    has_symbol(f, T)
                                end), field_types)) || push!(uninferrable, T)
            end
            return uninferrable
        end
    #= none:151 =# Core.@doc "    split_field_if_match(typename::Symbol, expr, default::Bool=false)\n\nSplit the field definition if it matches the given type name.\nReturns `NamedTuple` with `name`, `type`, `default` and `isconst` fields\nif it matches, otherwise return `nothing`.\n" function split_field_if_match(typename::Symbol, expr, default::Bool = false)
            cache_8 = nothing
            x_76 = expr
            if x_76 isa Expr
                if begin
                            if cache_8 === nothing
                                cache_8 = Some((x_76.head, x_76.args))
                            end
                            x_77 = cache_8.value
                            x_77 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_77[1] == :const && (begin
                                    x_78 = x_77[2]
                                    x_78 isa AbstractArray
                                end && (length(x_78) === 1 && (begin
                                            cache_9 = nothing
                                            x_79 = x_78[1]
                                            x_79 isa Expr
                                        end && (begin
                                                if cache_9 === nothing
                                                    cache_9 = Some((x_79.head, x_79.args))
                                                end
                                                x_80 = cache_9.value
                                                x_80 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                            end && (x_80[1] == :(=) && (begin
                                                        x_81 = x_80[2]
                                                        x_81 isa AbstractArray
                                                    end && (length(x_81) === 2 && (begin
                                                                cache_10 = nothing
                                                                x_82 = x_81[1]
                                                                x_82 isa Expr
                                                            end && (begin
                                                                    if cache_10 === nothing
                                                                        cache_10 = Some((x_82.head, x_82.args))
                                                                    end
                                                                    x_83 = cache_10.value
                                                                    x_83 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                                end && (x_83[1] == :(::) && (begin
                                                                            x_84 = x_83[2]
                                                                            x_84 isa AbstractArray
                                                                        end && (length(x_84) === 2 && (begin
                                                                                    x_85 = x_84[1]
                                                                                    x_85 isa Symbol
                                                                                end && begin
                                                                                    x_86 = x_84[2]
                                                                                    x_87 = x_81[2]
                                                                                    true
                                                                                end))))))))))))))
                    value = x_87
                    type = x_86
                    name = x_85
                    return_4 = begin
                            default && return (; name, type, isconst = true, default = value)
                            throw(ArgumentError("default value syntax is not allowed"))
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#721_1")))
                end
                if begin
                            x_88 = cache_8.value
                            x_88 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_88[1] == :const && (begin
                                    x_89 = x_88[2]
                                    x_89 isa AbstractArray
                                end && (length(x_89) === 1 && (begin
                                            cache_11 = nothing
                                            x_90 = x_89[1]
                                            x_90 isa Expr
                                        end && (begin
                                                if cache_11 === nothing
                                                    cache_11 = Some((x_90.head, x_90.args))
                                                end
                                                x_91 = cache_11.value
                                                x_91 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                            end && (x_91[1] == :(=) && (begin
                                                        x_92 = x_91[2]
                                                        x_92 isa AbstractArray
                                                    end && (length(x_92) === 2 && (begin
                                                                x_93 = x_92[1]
                                                                x_93 isa Symbol
                                                            end && begin
                                                                x_94 = x_92[2]
                                                                true
                                                            end)))))))))
                    value = x_94
                    name = x_93
                    return_4 = begin
                            default && return (; name, type = Any, isconst = true, default = value)
                            throw(ArgumentError("default value syntax is not allowed"))
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#721_1")))
                end
                if begin
                            x_95 = cache_8.value
                            x_95 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_95[1] == :(=) && (begin
                                    x_96 = x_95[2]
                                    x_96 isa AbstractArray
                                end && (length(x_96) === 2 && (begin
                                            cache_12 = nothing
                                            x_97 = x_96[1]
                                            x_97 isa Expr
                                        end && (begin
                                                if cache_12 === nothing
                                                    cache_12 = Some((x_97.head, x_97.args))
                                                end
                                                x_98 = cache_12.value
                                                x_98 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                            end && (x_98[1] == :(::) && (begin
                                                        x_99 = x_98[2]
                                                        x_99 isa AbstractArray
                                                    end && (length(x_99) === 2 && (begin
                                                                x_100 = x_99[1]
                                                                x_100 isa Symbol
                                                            end && begin
                                                                x_101 = x_99[2]
                                                                x_102 = x_96[2]
                                                                true
                                                            end)))))))))
                    value = x_102
                    type = x_101
                    name = x_100
                    return_4 = begin
                            default && return (; name, type, isconst = false, default = value)
                            throw(ArgumentError("default value syntax is not allowed"))
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#721_1")))
                end
                if begin
                            x_103 = cache_8.value
                            x_103 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_103[1] == :(=) && (begin
                                    x_104 = x_103[2]
                                    x_104 isa AbstractArray
                                end && (length(x_104) === 2 && (begin
                                            x_105 = x_104[1]
                                            x_105 isa Symbol
                                        end && begin
                                            x_106 = x_104[2]
                                            true
                                        end))))
                    value = x_106
                    name = x_105
                    return_4 = begin
                            default && return (; name, type = Any, isconst = false, default = value)
                            throw(ArgumentError("default value syntax is not allowed"))
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#721_1")))
                end
                if begin
                            x_107 = cache_8.value
                            x_107 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_107[1] == :const && (begin
                                    x_108 = x_107[2]
                                    x_108 isa AbstractArray
                                end && (length(x_108) === 1 && (begin
                                            cache_13 = nothing
                                            x_109 = x_108[1]
                                            x_109 isa Expr
                                        end && (begin
                                                if cache_13 === nothing
                                                    cache_13 = Some((x_109.head, x_109.args))
                                                end
                                                x_110 = cache_13.value
                                                x_110 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                            end && (x_110[1] == :(::) && (begin
                                                        x_111 = x_110[2]
                                                        x_111 isa AbstractArray
                                                    end && (length(x_111) === 2 && (begin
                                                                x_112 = x_111[1]
                                                                x_112 isa Symbol
                                                            end && begin
                                                                x_113 = x_111[2]
                                                                true
                                                            end)))))))))
                    type = x_113
                    name = x_112
                    return_4 = begin
                            default && return (; name, type, isconst = true, default = no_default)
                            return (; name, type, isconst = true)
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#721_1")))
                end
                if begin
                            x_114 = cache_8.value
                            x_114 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_114[1] == :const && (begin
                                    x_115 = x_114[2]
                                    x_115 isa AbstractArray
                                end && (length(x_115) === 1 && begin
                                        x_116 = x_115[1]
                                        x_116 isa Symbol
                                    end)))
                    name = x_116
                    return_4 = begin
                            default && return (; name, type = Any, isconst = true, default = no_default)
                            return (; name, type = Any, isconst = true)
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#721_1")))
                end
                if begin
                            x_117 = cache_8.value
                            x_117 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_117[1] == :(::) && (begin
                                    x_118 = x_117[2]
                                    x_118 isa AbstractArray
                                end && (length(x_118) === 2 && (begin
                                            x_119 = x_118[1]
                                            x_119 isa Symbol
                                        end && begin
                                            x_120 = x_118[2]
                                            true
                                        end))))
                    type = x_120
                    name = x_119
                    return_4 = begin
                            default && return (; name, type, isconst = false, default = no_default)
                            return (; name, type, isconst = false)
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#721_1")))
                end
            end
            if x_76 isa Symbol
                name = x_76
                return_4 = begin
                        default && return (; name, type = Any, isconst = false, default = no_default)
                        return (; name, type = Any, isconst = false)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#721_1")))
            end
            if x_76 isa String
                return_4 = begin
                        return expr
                    end
                $(Expr(:symbolicgoto, Symbol("##final#721_1")))
            end
            if x_76 isa LineNumberNode
                return_4 = begin
                        return expr
                    end
                $(Expr(:symbolicgoto, Symbol("##final#721_1")))
            end
            if is_function(expr)
                return_4 = begin
                        if name_only(expr) === typename
                            return JLFunction(expr)
                        else
                            return expr
                        end
                    end
                $(Expr(:symbolicgoto, Symbol("##final#721_1")))
            end
            return_4 = begin
                    return expr
                end
            $(Expr(:symbolicgoto, Symbol("##final#721_1")))
            (error)("matching non-exhaustive, at #= none:159 =#")
            $(Expr(:symboliclabel, Symbol("##final#721_1")))
            return_4
        end
end
