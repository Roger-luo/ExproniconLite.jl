begin
    function compile_adt_pattern(t, self, type_params, type_args, args)
        isempty(type_params) || return begin
                    call = Expr(:call, t, args...)
                    ann = Expr(:curly, t, type_args...)
                    self(Where(call, ann, type_params))
                end
        true
        x_1 = args
        if x_1 isa AbstractArray && ((ndims(x_1) === 1 && length(x_1) >= 1) && (begin
                            cache_1 = nothing
                            x_2 = x_1[1]
                            x_2 isa Expr
                        end && (begin
                                if cache_1 === nothing
                                    cache_1 = Some((x_2.head, x_2.args))
                                end
                                x_3 = cache_1.value
                                x_3 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_3[1] == :parameters && (begin
                                        x_4 = x_3[2]
                                        x_4 isa AbstractArray
                                    end && ((ndims(x_4) === 1 && length(x_4) >= 0) && begin
                                            x_5 = (SubArray)(x_4, (1:length(x_4),))
                                            x_6 = (SubArray)(x_1, (2:length(x_1),))
                                            true
                                        end))))))
            args = x_6
            kwargs = x_5
            return_1 = begin
                end
            $(Expr(:symbolicgoto, Symbol("##final#624_1")))
        end
        if kwargs_1 = [], true
            kwargs = kwargs_1
            return_1 = begin
                end
            $(Expr(:symbolicgoto, Symbol("##final#624_1")))
        end
        (error)("matching non-exhaustive, at #= none:8 =#")
        $(Expr(:symboliclabel, Symbol("##final#624_1")))
        return_1
        partial_field_names = Symbol[]
        patterns = Function[]
        all_field_names = variant_fieldnames(t)
        n_args = length(args)
        true
        x_7 = args
        if all((Meta.isexpr(arg, :kw) for arg = args))
            return_2 = begin
                    for arg = args
                        field_name = arg.args[1]
                        field_name in all_field_names || error("$(t) has no field $(field_name)")
                        push!(partial_field_names, field_name)
                        push!(patterns, self(arg.args[2]))
                    end
                end
            $(Expr(:symbolicgoto, Symbol("##final#635_1")))
        end
        if length(all_field_names) === n_args
            return_2 = begin
                    args = replace(args, $(Expr(:copyast, :($(QuoteNode(:(_...)))))) => :_)
                    append!(patterns, map(self, args))
                    append!(partial_field_names, all_field_names)
                end
            $(Expr(:symbolicgoto, Symbol("##final#635_1")))
        end
        if x_7 isa AbstractArray && (length(x_7) === 1 && (begin
                            cache_2 = nothing
                            x_8 = x_7[1]
                            x_8 isa Expr
                        end && (begin
                                if cache_2 === nothing
                                    cache_2 = Some((x_8.head, x_8.args))
                                end
                                x_9 = cache_2.value
                                x_9 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_9[1] == :... && (begin
                                        x_10 = x_9[2]
                                        x_10 isa AbstractArray
                                    end && (length(x_10) === 1 && x_10[1] == :_))))))
            return_2 = begin
                    partial_field_names = Symbol[]
                    patterns = Function[]
                end
            $(Expr(:symbolicgoto, Symbol("##final#635_1")))
        end
        if length(args) == 0
            return_2 = begin
                end
            $(Expr(:symbolicgoto, Symbol("##final#635_1")))
        end
        if length(args) !== length(all_field_names)
            return_2 = begin
                    error("count of positional fields should be same as " * "the fields: $(join(all_field_names, ", "))")
                end
            $(Expr(:symbolicgoto, Symbol("##final#635_1")))
        end
        return_2 = begin
            end
        $(Expr(:symbolicgoto, Symbol("##final#635_1")))
        (error)("matching non-exhaustive, at #= none:19 =#")
        $(Expr(:symboliclabel, Symbol("##final#635_1")))
        return_2
        for e = kwargs
            cache_3 = nothing
            x_11 = e
            if x_11 isa Expr
                if begin
                            if cache_3 === nothing
                                cache_3 = Some((x_11.head, x_11.args))
                            end
                            x_12 = cache_3.value
                            x_12 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_12[1] == :kw && (begin
                                    x_13 = x_12[2]
                                    x_13 isa AbstractArray
                                end && (length(x_13) === 2 && (begin
                                            x_14 = x_13[1]
                                            x_14 isa Symbol
                                        end && begin
                                            x_15 = x_13[2]
                                            true
                                        end))))
                    value = x_15
                    key = x_14
                    return_3 = begin
                            key in all_field_names || error("unknown field name $(key) for $(t) when field punnning.")
                            push!(partial_field_names, key)
                            push!(patterns, and([P_capture(key), self(value)]))
                            continue
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#643_1")))
                end
            end
            if x_11 isa Symbol
                return_3 = begin
                        e in all_field_names || error("unknown field name $(e) for $(t) when field punnning.")
                        push!(partial_field_names, e)
                        push!(patterns, P_capture(e))
                        continue
                    end
                $(Expr(:symbolicgoto, Symbol("##final#643_1")))
            end
            return_3 = begin
                    error("unknown sub-pattern $(e) in $(t)")
                end
            $(Expr(:symbolicgoto, Symbol("##final#643_1")))
            (error)("matching non-exhaustive, at #= none:43 =#")
            $(Expr(:symboliclabel, Symbol("##final#643_1")))
            return_3
        end
        ret = struct_decons(adt_type(t), partial_field_names, patterns)
        isempty(type_args) && return ret
        return and([self(Expr(:(::), Expr(:curly, t, type_args...))), ret])
    end
    function struct_decons(t, partial_fields, ps, prepr::AbstractString = repr(t))
        function tcons(_...)
            t
        end
        comp = MLStyle.Record.PComp(prepr, tcons; )
        function extract(sub::Any, i::Int, ::Any, ::Any)
            quote
                $(xcall(Base, :getproperty, sub, QuoteNode(partial_fields[i])))
            end
        end
        MLStyle.Record.decons(comp, extract, ps)
    end
end
