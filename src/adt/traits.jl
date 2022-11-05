begin
    #= none:1 =# Core.@doc "    variants(::Type{T}) where T\n\nReturns the variant types of an algebra data type `T`.\n" function variants(::Type{T}) where T
            throw(ArgumentError("expect an adt type, got $(T)"))
        end
    #= none:10 =# Core.@doc "    variant_type(variant)\n\nReturns the variant type of an algebra data type instance `variant`.\n" function variant_type(variant)
            throw(ArgumentError("expect an instance of an ADT type, got $(variant)"))
        end
    #= none:19 =# Core.@doc "    adt_type(variant_type)\n\nReturns the algebra data type type of a variant type `variant_type`.\n" function adt_type(variant_type)
            throw(ArgumentError("expect a variant type, got $(variant_type)"))
        end
    #= none:28 =# Core.@doc "    variant_masks(variant_type)\n\nReturns the masks of a variant type.\n" function variant_masks(variant_type)
            throw(ArgumentError("expect a variant type, got $(typeof(variant_type))"))
        end
    #= none:37 =# Core.@doc "    variant_fieldnames(variant_type)\n\nReturns the field names of a variant type.\n" function variant_fieldnames(variant_type)
            throw(ArgumentError("expect a variant type, got $(typeof(variant_type))"))
        end
    #= none:46 =# Core.@doc "    variant_fieldname(variant_type, idx)\n\nReturns the `idx`-th field name of a variant type.\n" function variant_fieldname(variant_type, ::Int)
            throw(ArgumentError("expect a variant type, got $(typeof(variant_type))"))
        end
    #= none:55 =# Core.@doc "    variant_fieldtypes(variant_type)\n\nReturns the field types of a variant type.\n" function variant_fieldtypes(variant_type)
            throw(ArgumentError("expect a variant type, got $(typeof(variant_type))"))
        end
    #= none:64 =# Core.@doc "    variant_fieldtype(variant_type, idx)\n\nReturns the `idx`-th field type of a variant type.\n" function variant_fieldtype(variant_type, ::Int)
            throw(ArgumentError("expect a variant type, got $(typeof(variant_type))"))
        end
    #= none:73 =# Core.@doc "    variant_field_defaults(variant_type)\n\nReturns the field defaults of a variant type.\n" function variant_field_defaults(variant_type)
            throw(ArgumentError("expect a variant type, got $(typeof(variant_type))"))
        end
    #= none:82 =# Core.@doc "    variant_field_default(variant_type, idx)\n\nReturns the `idx`-th field default of a variant type.\n" function variant_field_default(variant_type, ::Int)
            throw(ArgumentError("expect a variant type, got $(typeof(variant_type))"))
        end
    function variant_typename(variant_type)
        throw(ArgumentError("expect a variant type, got $(typeof(variant_type))"))
    end
end
