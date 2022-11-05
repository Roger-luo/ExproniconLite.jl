begin
    #= none:5 =# Base.@kwdef struct Variant
            type::Symbol
            name::Symbol
            ismutable::Bool = false
            fieldnames::Vector{Symbol} = Symbol[]
            field_defaults::Vector{Any} = map((_->begin
                            no_default
                        end), fieldnames)
            fieldtypes::Vector{Any} = map((_->begin
                            Any
                        end), fieldnames)
            lineinfo::Maybe{LineNumberNode} = nothing
            function Variant(type, name, ismutable, fieldnames, field_defaults, fieldtypes, lineinfo)
                if type == :struct
                    if length(fieldnames) != length(fieldtypes)
                        throw(ArgumentError("length of fieldnames and fieldtypes must be equal"))
                    end
                    if length(fieldnames) != length(field_defaults)
                        throw(ArgumentError("length of fieldnames and field_defaults must be equal"))
                    end
                elseif type == :call
                    isempty(fieldtypes) && throw(ArgumentError("call type must have at least one fieldtype"))
                    isempty(fieldnames) || throw(ArgumentError("cannot have named field for call syntax variant"))
                    isempty(field_defaults) || throw(ArgumentError("cannot have default value for call syntax variant"))
                end
                new(type, name, ismutable, fieldnames, field_defaults, fieldtypes, lineinfo)
            end
        end
    #= none:36 =# Base.@kwdef struct ADTTypeDef
            m::Module = Main
            name::Symbol
            typevars::Vector{Any} = Any[]
            supertype::Any = nothing
            variants::Vector{Variant}
        end
    function Variant(ex, lineinfo = nothing)
        cache_1 = nothing
        x_1 = ex
        if x_1 isa Expr
            if begin
                        if cache_1 === nothing
                            cache_1 = Some((x_1.head, x_1.args))
                        end
                        x_2 = cache_1.value
                        x_2 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_2[1] == :call && (begin
                                x_3 = x_2[2]
                                x_3 isa AbstractArray
                            end && ((ndims(x_3) === 1 && length(x_3) >= 1) && begin
                                    x_4 = x_3[1]
                                    x_5 = (SubArray)(x_3, (2:length(x_3),))
                                    true
                                end)))
                name = x_4
                args = x_5
                return_1 = begin
                        foreach(args) do arg
                            Meta.isexpr(arg, :(::)) && length(arg.args) == 1 || throw(ArgumentError("expect ::<type> in call syntax variant, got $(arg)"))
                        end
                        Variant(type = :call, name = name, fieldtypes = annotations_only.(args))
                    end
                $(Expr(:symbolicgoto, Symbol("##final#652_1")))
            end
            if begin
                        x_6 = cache_1.value
                        x_6 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_6[1] == :struct && (begin
                                x_7 = x_6[2]
                                x_7 isa AbstractArray
                            end && (ndims(x_7) === 1 && length(x_7) >= 0)))
                return_1 = begin
                        def = JLKwStruct(ex)
                        Variant(; type = :struct, name = def.name, ismutable = def.ismutable, fieldnames = map((x->begin
                                            x.name
                                        end), def.fields), field_defaults = map((x->begin
                                            x.default
                                        end), def.fields), fieldtypes = map((x->begin
                                            x.type
                                        end), def.fields), lineinfo)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#652_1")))
            end
        end
        if x_1 isa Symbol
            return_1 = begin
                    Variant(type = :singleton, name = ex)
                end
            $(Expr(:symbolicgoto, Symbol("##final#652_1")))
        end
        return_1 = begin
                throw(ArgumentError("unknown variant syntax: $(ex)"))
            end
        $(Expr(:symbolicgoto, Symbol("##final#652_1")))
        (error)("matching non-exhaustive, at #= none:51 =#")
        $(Expr(:symboliclabel, Symbol("##final#652_1")))
        return_1
    end
    function adt_split_head(head)
        cache_2 = nothing
        x_8 = head
        if x_8 isa Expr
            if begin
                        if cache_2 === nothing
                            cache_2 = Some((x_8.head, x_8.args))
                        end
                        x_9 = cache_2.value
                        x_9 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_9[1] == :curly && (begin
                                x_10 = x_9[2]
                                x_10 isa AbstractArray
                            end && ((ndims(x_10) === 1 && length(x_10) >= 1) && begin
                                    x_11 = x_10[1]
                                    x_12 = (SubArray)(x_10, (2:length(x_10),))
                                    true
                                end)))
                typevars = x_12
                name = x_11
                return_2 = begin
                        supertype = nothing
                    end
                $(Expr(:symbolicgoto, Symbol("##final#663_1")))
            end
            if begin
                        x_13 = cache_2.value
                        x_13 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_13[1] == :<: && (begin
                                x_14 = x_13[2]
                                x_14 isa AbstractArray
                            end && (length(x_14) === 2 && (begin
                                        cache_3 = nothing
                                        x_15 = x_14[1]
                                        x_15 isa Expr
                                    end && (begin
                                            if cache_3 === nothing
                                                cache_3 = Some((x_15.head, x_15.args))
                                            end
                                            x_16 = cache_3.value
                                            x_16 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                        end && (x_16[1] == :curly && (begin
                                                    x_17 = x_16[2]
                                                    x_17 isa AbstractArray
                                                end && ((ndims(x_17) === 1 && length(x_17) >= 1) && begin
                                                        x_18 = x_17[1]
                                                        x_19 = (SubArray)(x_17, (2:length(x_17),))
                                                        x_20 = x_14[2]
                                                        true
                                                    end))))))))
                typevars = x_19
                name = x_18
                supertype = x_20
                return_2 = begin
                    end
                $(Expr(:symbolicgoto, Symbol("##final#663_1")))
            end
            if begin
                        x_21 = cache_2.value
                        x_21 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_21[1] == :<: && (begin
                                x_22 = x_21[2]
                                x_22 isa AbstractArray
                            end && (length(x_22) === 2 && begin
                                    x_23 = x_22[1]
                                    x_24 = x_22[2]
                                    true
                                end)))
                name = x_23
                supertype = x_24
                return_2 = begin
                        typevars = []
                    end
                $(Expr(:symbolicgoto, Symbol("##final#663_1")))
            end
        end
        if x_8 isa Symbol
            return_2 = begin
                    name = head
                    typevars = []
                    supertype = nothing
                end
            $(Expr(:symbolicgoto, Symbol("##final#663_1")))
        end
        return_2 = begin
                throw(ArgumentError("unknown ADT syntax: $(head)"))
            end
        $(Expr(:symbolicgoto, Symbol("##final#663_1")))
        (error)("matching non-exhaustive, at #= none:77 =#")
        $(Expr(:symboliclabel, Symbol("##final#663_1")))
        return_2
        return (name, typevars, supertype)
    end
    function ADTTypeDef(m::Module, head, body::Expr)
        variants = Variant[]
        lineinfo = nothing
        for ex = body.args
            if ex isa LineNumberNode
                lineinfo = ex
            else
                push!(variants, Variant(ex, lineinfo))
                lineinfo = nothing
            end
        end
        return ADTTypeDef(m, adt_split_head(head)..., variants)
    end
    function Base.:(==)(a::Variant, b::Variant)
        a.type == b.type && (a.name == b.name && (a.ismutable == b.ismutable && (a.fieldnames == b.fieldnames && a.fieldtypes == b.fieldtypes)))
    end
end
