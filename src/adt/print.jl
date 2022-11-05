begin
    tab(n) = begin
            " " ^ n
        end
    splitlines(s::String) = begin
            split(s, '\n')
        end
    function Base.show(io::IO, mime::MIME"text/plain", def::ADTTypeDef)
        printstyled(io, "@adt "; color = :cyan)
        def.m === Main || print(io, def.m, ".")
        print(io, def.name)
        if !(isempty(def.typevars))
            print(io, "{")
            join(io, def.typevars, ", ")
            print(io, "}")
        end
        if def.supertype !== nothing
            print(io, " <: ")
            print(io, def.supertype)
        end
        print(io, tab(1))
        printstyled(io, "begin"; color = :light_red)
        println(io)
        for (i, variant) = enumerate(def.variants)
            show(IOContext(io, :indent => 4), mime, variant)
            println(io)
            if i < length(def.variants)
                println(io)
            end
        end
        printstyled(io, "end"; color = :light_red)
        return
    end
    function Base.show(io::IO, ::MIME"text/plain", def::Variant)
        indent = get(io, :indent, 0)
        print(io, tab(indent))
        if def.type == :singleton
            print(io, def.name)
        elseif def.type == :call
            print(io, def.name, "(")
            for (i, type) = enumerate(def.fieldtypes)
                printstyled(io, "::"; color = :light_black)
                printstyled(io, type; color = :cyan)
                if i < length(def.fieldtypes)
                    print(io, ", ")
                end
            end
            print(io, ")")
        else
            if def.ismutable
                print(io, "mutable ")
            end
            printstyled(io, "struct "; color = :light_red)
            println(io, def.name)
            for (i, fieldname) = enumerate(def.fieldnames)
                type = def.fieldtypes[i]
                print(io, tab(indent + 4), fieldname)
                if type != Any
                    printstyled(io, "::"; color = :light_black)
                    printstyled(io, type; color = :cyan)
                end
                default = def.field_defaults[i]
                if default !== no_default
                    print(io, " = ")
                    print(io, default)
                end
                println(io)
            end
            printstyled(io, tab(indent), "end"; color = :light_red)
        end
        return
    end
    function Base.show(io::IO, ::MIME"text/plain", info::EmitInfo)
        color = get(io, :color, false)
        println(io, "EmitInfo:")
        print(io, tab(2), "typename: ")
        printstyled(io, info.typename; color = :cyan)
        println(io)
        print(io, tab(2), "ismutable: ")
        printstyled(io, info.ismutable; color = :light_magenta)
        println(io)
        println(io, tab(2), "fields: ")
        for (name, type) = zip(info.fieldnames, info.fieldtypes)
            print(io, tab(4), name)
            printstyled(io, "::"; color = :light_black)
            printstyled(io, type; color = :cyan)
            println(io)
        end
        println(io)
        println(io, tab(2), "variants:")
        variants = sort(collect(keys(info.variant_masks)); by = (x->begin
                            x.name
                        end))
        variant_lines_nocolor = map(variants) do variant
                buf = IOBuffer()
                show(IOContext(buf, :color => false), (MIME"text/plain")(), variant)
                splitlines(String(take!(buf)))
            end
        max_line_width = maximum(variant_lines_nocolor) do lines
                maximum(length, lines)
            end
        for (idx, variant) = enumerate(variants)
            buf = IOBuffer()
            show(IOContext(buf, :color => color), (MIME"text/plain")(), variant)
            lines = splitlines(String(take!(buf)))
            padding = (max_line_width - length((variant_lines_nocolor[idx])[1])) + 4
            mask = info.variant_masks[variant]
            print(io, tab(4), lines[1], tab(1))
            printstyled(io, '-' ^ (padding - 2); color = :light_black)
            print(io, " [")
            join(io, mask, ", ")
            print(io, "]")
            if !(length(lines) == 1 && idx == length(variants))
                println(io)
            end
            for line_idx = 2:length(lines)
                print(io, tab(4), lines[line_idx])
                if !(idx == length(variants) && line_idx == length(lines))
                    println(io)
                end
            end
        end
        return
    end
end
