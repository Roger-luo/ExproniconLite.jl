begin
    mutable struct Reference{T}
        data::T
        (Reference{T}() where T) = begin
                new{T}()
            end
        Reference(x) = begin
                new{typeof(x)}(x)
            end
    end
    #= none:9 =# @inline (Base.pointer(r::Reference{T}) where T) = begin
                Ptr{T}(pointer_from_objref(r))
            end
    #= none:10 =# @inline (load(p::Ptr{Reference{T}}) where T) = begin
                getfield(ccall(:jl_value_ptr, Ref{Reference{T}}, (Ptr{Cvoid},), unsafe_load(Base.unsafe_convert(Ptr{Ptr{Cvoid}}, p))), :data)
            end
    function undef_value(type)
        if type isa Type && type <: Number
            return type(0)
        elseif isbitstype(type)
            return load(pointer(Reference{T}()))
        else
            return nothing
        end
    end
end
