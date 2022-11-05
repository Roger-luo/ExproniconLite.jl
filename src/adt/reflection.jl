begin
    function emit_reflection(def::ADTTypeDef, info::EmitInfo)
        quote
            $(emit_variants(def, info))
            $(emit_adt_type(def, info))
            $(emit_variant_type(def, info))
            $(emit_variant_masks(def, info))
            $(emit_variant_typename(def, info))
            $(emit_variant_fieldname(def, info))
            $(emit_variant_fieldtype(def, info))
            $(emit_variant_field_default(def, info))
            $(emit_variant_fieldnames(def, info))
            $(emit_variant_fieldtypes(def, info))
            $(emit_variant_field_defaults(def, info))
        end
    end
    function emit_variants(def::ADTTypeDef, ::EmitInfo)
        return quote
                function ($ADT).variants(::Type{<:$(def.name)})
                    return $(xtuple(map((x->begin
                x.name
            end), def.variants)...))
                end
            end
    end
    function emit_adt_type(def::ADTTypeDef, info::EmitInfo)
        return quote
                function ($ADT).adt_type(variant_type::$(info.typename))
                    return $(def.name)
                end
            end
    end
    function emit_variant_type(def::ADTTypeDef, ::EmitInfo)
        return quote
                #= none:35 =# @inline function ($ADT).variant_type(x::$(def.name))
                        return $(xvariant_type(:x))
                    end
            end
    end
    function emit_variant_masks(def::ADTTypeDef, info::EmitInfo)
        body = foreach_variant_type(:t, def, info) do variant
                xtuple(info.variant_masks[variant]...)
            end
        return quote
                #= none:47 =# @inline function ($ADT).variant_masks(t::$(info.typename))
                        $(codegen_ast(body))
                    end
                #= none:51 =# @inline function ($ADT).variant_masks(x::$(def.name))
                        ($ADT).variant_masks(($ADT).variant_type(x))
                    end
            end
    end
    function emit_variant_fieldnames(def::ADTTypeDef, info::EmitInfo)
        body = foreach_variant_type(:t, def, info) do variant
                if variant.type === :singleton || variant.type === :call
                    :(throw(ArgumentError("singleton variant or call variant has no field names")))
                else
                    xtuple(QuoteNode.(variant.fieldnames)...)
                end
            end
        return quote
                #= none:67 =# @inline function ($ADT).variant_fieldnames(t::$(info.typename))
                        $(codegen_ast(body))
                    end
                #= none:71 =# @inline function ($ADT).variant_fieldnames(x::$(def.name))
                        ($ADT).variant_fieldnames(($ADT).variant_type(x))
                    end
            end
    end
    function emit_variant_fieldname(def::ADTTypeDef, info::EmitInfo)
        return quote
                #= none:79 =# @inline function ($ADT).variant_fieldname(t::$(info.typename), idx::Int)
                        return (($ADT).variant_fieldnames(t))[idx]
                    end
                #= none:83 =# @inline function ($ADT).variant_fieldname(x::$(def.name), idx::Int)
                        return ($ADT).variant_fieldname(($ADT).variant_type(x), idx)
                    end
            end
    end
    function emit_variant_fieldtype(def::ADTTypeDef, info::EmitInfo)
        return quote
                #= none:91 =# @inline function ($ADT).variant_fieldtype(t::$(info.typename), idx::Int)
                        return (($ADT).variant_fieldtypes(t))[idx]
                    end
                #= none:95 =# @inline function ($ADT).variant_fieldtype(x::$(def.name), idx::Int)
                        return ($ADT).variant_fieldtype(($ADT).variant_type(x), idx)
                    end
            end
    end
    function emit_variant_field_default(def::ADTTypeDef, info::EmitInfo)
        return quote
                #= none:103 =# @inline function ($ADT).variant_field_default(t::$(info.typename), idx::Int)
                        return (($ADT).variant_field_defaults(t))[idx]
                    end
                #= none:107 =# @inline function ($ADT).variant_field_default(x::$(def.name), idx::Int)
                        return ($ADT).variant_field_default(($ADT).variant_type(x), idx)
                    end
            end
    end
    function emit_variant_fieldtypes(def::ADTTypeDef, info::EmitInfo)
        body = foreach_variant_type(:t, def, info) do variant
                xtuple(variant.fieldtypes...)
            end
        return quote
                #= none:119 =# @inline function ($ADT).variant_fieldtypes(t::$(info.typename))
                        $(codegen_ast(body))
                    end
                #= none:123 =# @inline function ($ADT).variant_fieldtypes(x::$(def.name))
                        ($ADT).variant_fieldtypes(($ADT).variant_type(x))
                    end
            end
    end
    function emit_variant_field_defaults(def::ADTTypeDef, info::EmitInfo)
        body = foreach_variant_type(:t, def, info) do variant
                xtuple(variant.field_defaults...)
            end
        return quote
                #= none:135 =# @inline function ($ADT).variant_field_defaults(t::$(info.typename))
                        $(codegen_ast(body))
                    end
                #= none:139 =# @inline function ($ADT).variant_field_defaults(x::$(def.name))
                        ($ADT).variant_field_defaults(($ADT).variant_type(x))
                    end
            end
    end
    function emit_variant_typename(def::ADTTypeDef, info::EmitInfo)
        body = foreach_variant_type(:t, def, info) do variant
                QuoteNode(variant.name)
            end
        return quote
                #= none:150 =# @inline function ($ADT).variant_typename(t::$(info.typename))
                        return $(codegen_ast(body))
                    end
                #= none:154 =# @inline function ($ADT).variant_typename(x::$(def.name))
                        return ($ADT).variant_typename(($ADT).variant_type(x))
                    end
            end
    end
end
