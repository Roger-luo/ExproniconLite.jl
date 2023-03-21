
    #= none:1 =# Core.@doc "    is_valid_typevar(typevar)\n\nCheck if the given typevar is a valid typevar.\n\n!!! note\n    This function is based on [this discourse post](https://discourse.julialang.org/t/what-are-valid-type-parameters/471).\n" function is_valid_typevar(typevar)
            let
                true
                var"##return#292" = nothing
                var"##294" = typevar
                if var"##294" isa TypeVar
                    begin
                        var"##return#292" = let
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#293#295")))
                    end
                end
                if var"##294" isa Type
                    begin
                        var"##return#292" = let
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#293#295")))
                    end
                end
                if var"##294" isa QuoteNode
                    begin
                        var"##return#292" = let
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#293#295")))
                    end
                end
                if isbitstype(typeof(typevar))
                    var"##return#292" = let
                            true
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#293#295")))
                end
                if var"##294" isa Tuple
                    var"##return#292" = let
                            all((x->begin
                                        x isa Symbol || isbitstype(typeof(x))
                                    end), typevar)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#293#295")))
                end
                begin
                    var"##return#292" = let
                            false
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#293#295")))
                end
                error("matching non-exhaustive, at #= none:10 =#")
                $(Expr(:symboliclabel, Symbol("####final#293#295")))
                var"##return#292"
            end
        end
    #= none:20 =# Core.@doc "    is_literal(x)\n\nCheck if `x` is a literal value.\n" function is_literal(x)
            !(x isa Expr || (x isa Symbol || x isa GlobalRef))
        end
    #= none:29 =# Core.@doc "    is_tuple(ex)\n\nCheck if `ex` is a tuple expression, i.e. `:((a,b,c))`\n" is_tuple(x) = begin
                Meta.isexpr(x, :tuple)
            end
    #= none:36 =# Core.@doc "    is_splat(ex)\n\nCheck if `ex` is a splat expression, i.e. `:(f(x)...)`\n" is_splat(x) = begin
                Meta.isexpr(x, :...)
            end
    #= none:43 =# Core.@doc "    is_gensym(s)\n\nCheck if `s` is generated by `gensym`.\n\n!!! note\n    Borrowed from [MacroTools](https://github.com/FluxML/MacroTools.jl).\n" is_gensym(s::Symbol) = begin
                occursin("#", string(s))
            end
    is_gensym(s) = begin
            false
        end
    #= none:54 =# Core.@doc "    support_default(f)\n\nCheck if field type `f` supports default value.\n" support_default(f) = begin
                false
            end
    support_default(f::JLKwField) = begin
            true
        end
    #= none:62 =# Core.@doc "    has_symbol(ex, name::Symbol)\n\nCheck if `ex` contains symbol `name`.\n" function has_symbol(#= none:67 =# @nospecialize(ex), name::Symbol)
            ex isa Symbol && return ex === name
            ex isa Expr || return false
            return any((x->begin
                            has_symbol(x, name)
                        end), ex.args)
        end
    #= none:73 =# Core.@doc "    has_kwfn_constructor(def[, name = struct_name_plain(def)])\n\nCheck if the struct definition contains keyword function constructor of `name`.\nThe constructor name to check by default is the plain constructor which does\nnot infer any type variables and requires user to input all type variables.\nSee also [`struct_name_plain`](@ref).\n" function has_kwfn_constructor(def, name = struct_name_plain(def))
            any(def.constructors) do fn::JLFunction
                isempty(fn.args) && fn.name == name
            end
        end
    #= none:87 =# Core.@doc "    has_plain_constructor(def, name = struct_name_plain(def))\n\nCheck if the struct definition contains the plain constructor of `name`.\nBy default the name is the inferable name [`struct_name_plain`](@ref).\n\n# Example\n\n```julia\ndef = @expr JLKwStruct struct Foo{T, N}\n    x::Int\n    y::N\n\n    Foo{T, N}(x, y) where {T, N} = new{T, N}(x, y)\nend\n\nhas_plain_constructor(def) # true\n\ndef = @expr JLKwStruct struct Foo{T, N}\n    x::T\n    y::N\n\n    Foo(x, y) = new{typeof(x), typeof(y)}(x, y)\nend\n\nhas_plain_constructor(def) # false\n```\n\nthe arguments must have no type annotations.\n\n```julia\ndef = @expr JLKwStruct struct Foo{T, N}\n    x::T\n    y::N\n\n    Foo{T, N}(x::T, y::N) where {T, N} = new{T, N}(x, y)\nend\n\nhas_plain_constructor(def) # false\n```\n" function has_plain_constructor(def, name = struct_name_plain(def))
            any(def.constructors) do fn::JLFunction
                fn.name == name || return false
                fn.kwargs === nothing || return false
                length(def.fields) == length(fn.args) || return false
                for (f, x) = zip(def.fields, fn.args)
                    f.name === x || return false
                end
                return true
            end
        end
    #= none:140 =# Core.@doc "    is_function(def)\n\nCheck if given object is a function expression.\n" function is_function(#= none:145 =# @nospecialize(def))
            let
                begin
                    var"##cache#299" = nothing
                end
                var"##return#296" = nothing
                var"##298" = def
                if var"##298" isa Expr
                    if begin
                                if var"##cache#299" === nothing
                                    var"##cache#299" = Some(((var"##298").head, (var"##298").args))
                                end
                                var"##300" = (var"##cache#299").value
                                var"##300" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##300"[1] == :function && (begin
                                        var"##301" = var"##300"[2]
                                        var"##301" isa AbstractArray
                                    end && length(var"##301") === 2))
                        var"##return#296" = let
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#297#306")))
                    end
                    if begin
                                var"##302" = (var"##cache#299").value
                                var"##302" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##302"[1] == :(=) && (begin
                                        var"##303" = var"##302"[2]
                                        var"##303" isa AbstractArray
                                    end && length(var"##303") === 2))
                        var"##return#296" = let
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#297#306")))
                    end
                    if begin
                                var"##304" = (var"##cache#299").value
                                var"##304" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##304"[1] == :-> && (begin
                                        var"##305" = var"##304"[2]
                                        var"##305" isa AbstractArray
                                    end && length(var"##305") === 2))
                        var"##return#296" = let
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#297#306")))
                    end
                end
                if var"##298" isa JLFunction
                    begin
                        var"##return#296" = let
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#297#306")))
                    end
                end
                begin
                    var"##return#296" = let
                            false
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#297#306")))
                end
                error("matching non-exhaustive, at #= none:146 =#")
                $(Expr(:symboliclabel, Symbol("####final#297#306")))
                var"##return#296"
            end
        end
    #= none:155 =# Core.@doc "    is_kw_function(def)\n\nCheck if a given function definition supports keyword arguments.\n" function is_kw_function(#= none:160 =# @nospecialize(def))
            is_function(def) || return false
            if def isa JLFunction
                return def.kwargs !== nothing
            end
            (_, call, _) = split_function(def)
            let
                begin
                    var"##cache#310" = nothing
                end
                var"##return#307" = nothing
                var"##309" = call
                if var"##309" isa Expr
                    if begin
                                if var"##cache#310" === nothing
                                    var"##cache#310" = Some(((var"##309").head, (var"##309").args))
                                end
                                var"##311" = (var"##cache#310").value
                                var"##311" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##311"[1] == :tuple && (begin
                                        var"##312" = var"##311"[2]
                                        var"##312" isa AbstractArray
                                    end && ((ndims(var"##312") === 1 && length(var"##312") >= 1) && (begin
                                                begin
                                                    var"##cache#314" = nothing
                                                end
                                                var"##313" = var"##312"[1]
                                                var"##313" isa Expr
                                            end && (begin
                                                    if var"##cache#314" === nothing
                                                        var"##cache#314" = Some(((var"##313").head, (var"##313").args))
                                                    end
                                                    var"##315" = (var"##cache#314").value
                                                    var"##315" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##315"[1] == :parameters && (begin
                                                            var"##316" = var"##315"[2]
                                                            var"##316" isa AbstractArray
                                                        end && (ndims(var"##316") === 1 && length(var"##316") >= 0))))))))
                        var"##return#307" = let
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#308#326")))
                    end
                    if begin
                                var"##317" = (var"##cache#310").value
                                var"##317" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##317"[1] == :call && (begin
                                        var"##318" = var"##317"[2]
                                        var"##318" isa AbstractArray
                                    end && ((ndims(var"##318") === 1 && length(var"##318") >= 2) && (begin
                                                begin
                                                    var"##cache#320" = nothing
                                                end
                                                var"##319" = var"##318"[2]
                                                var"##319" isa Expr
                                            end && (begin
                                                    if var"##cache#320" === nothing
                                                        var"##cache#320" = Some(((var"##319").head, (var"##319").args))
                                                    end
                                                    var"##321" = (var"##cache#320").value
                                                    var"##321" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##321"[1] == :parameters && (begin
                                                            var"##322" = var"##321"[2]
                                                            var"##322" isa AbstractArray
                                                        end && (ndims(var"##322") === 1 && length(var"##322") >= 0))))))))
                        var"##return#307" = let
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#308#326")))
                    end
                    if begin
                                var"##323" = (var"##cache#310").value
                                var"##323" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##323"[1] == :block && (begin
                                        var"##324" = var"##323"[2]
                                        var"##324" isa AbstractArray
                                    end && (length(var"##324") === 3 && begin
                                            var"##325" = var"##324"[2]
                                            var"##325" isa LineNumberNode
                                        end)))
                        var"##return#307" = let
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#308#326")))
                    end
                end
                begin
                    var"##return#307" = let
                            false
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#308#326")))
                end
                error("matching non-exhaustive, at #= none:168 =#")
                $(Expr(:symboliclabel, Symbol("####final#308#326")))
                var"##return#307"
            end
        end
    #= none:176 =# @deprecate is_kw_fn(def) is_kw_function(def)
    #= none:177 =# @deprecate is_fn(def) is_function(def)
    #= none:179 =# Core.@doc "    is_struct(ex)\n\nCheck if `ex` is a struct expression.\n" function is_struct(#= none:184 =# @nospecialize(ex))
            ex isa Expr || return false
            return ex.head === :struct
        end
    #= none:189 =# Core.@doc "    is_struct_not_kw_struct(ex)\n\nCheck if `ex` is a struct expression excluding keyword struct syntax.\n" function is_struct_not_kw_struct(ex)
            is_struct(ex) || return false
            body = ex.args[3]
            body isa Expr && body.head === :block || return false
            any(is_field_default, body.args) && return false
            return true
        end
    #= none:202 =# Core.@doc "    is_ifelse(ex)\n\nCheck if `ex` is an `if ... elseif ... else ... end` expression.\n" function is_ifelse(#= none:207 =# @nospecialize(ex))
            ex isa Expr || return false
            return ex.head === :if
        end
    #= none:212 =# Core.@doc "    is_for(ex)\n\nCheck if `ex` is a `for` loop expression.\n" function is_for(#= none:217 =# @nospecialize(ex))
            ex isa Expr || return false
            return ex.head === :for
        end
    #= none:222 =# Core.@doc "    is_field(ex)\n\nCheck if `ex` is a valid field expression.\n" function is_field(#= none:227 =# @nospecialize(ex))
            let
                begin
                    var"##cache#330" = nothing
                end
                var"##return#327" = nothing
                var"##329" = ex
                if var"##329" isa Expr
                    if begin
                                if var"##cache#330" === nothing
                                    var"##cache#330" = Some(((var"##329").head, (var"##329").args))
                                end
                                var"##331" = (var"##cache#330").value
                                var"##331" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##331"[1] == :(=) && (begin
                                        var"##332" = var"##331"[2]
                                        var"##332" isa AbstractArray
                                    end && (length(var"##332") === 2 && (begin
                                                begin
                                                    var"##cache#334" = nothing
                                                end
                                                var"##333" = var"##332"[1]
                                                var"##333" isa Expr
                                            end && (begin
                                                    if var"##cache#334" === nothing
                                                        var"##cache#334" = Some(((var"##333").head, (var"##333").args))
                                                    end
                                                    var"##335" = (var"##cache#334").value
                                                    var"##335" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##335"[1] == :(::) && (begin
                                                            var"##336" = var"##335"[2]
                                                            var"##336" isa AbstractArray
                                                        end && (length(var"##336") === 2 && begin
                                                                var"##337" = var"##336"[1]
                                                                var"##338" = var"##336"[2]
                                                                var"##339" = var"##332"[2]
                                                                true
                                                            end))))))))
                        var"##return#327" = let default = var"##339", type = var"##338", name = var"##337"
                                false
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#328#348")))
                    end
                    if begin
                                var"##340" = (var"##cache#330").value
                                var"##340" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##340"[1] == :(=) && (begin
                                        var"##341" = var"##340"[2]
                                        var"##341" isa AbstractArray
                                    end && (length(var"##341") === 2 && (begin
                                                var"##342" = var"##341"[1]
                                                var"##342" isa Symbol
                                            end && begin
                                                var"##343" = var"##341"[2]
                                                true
                                            end))))
                        var"##return#327" = let default = var"##343", name = var"##342"
                                false
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#328#348")))
                    end
                    if begin
                                var"##344" = (var"##cache#330").value
                                var"##344" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##344"[1] == :(::) && (begin
                                        var"##345" = var"##344"[2]
                                        var"##345" isa AbstractArray
                                    end && (length(var"##345") === 2 && begin
                                            var"##346" = var"##345"[1]
                                            var"##347" = var"##345"[2]
                                            true
                                        end)))
                        var"##return#327" = let type = var"##347", name = var"##346"
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#328#348")))
                    end
                end
                if var"##329" isa Symbol
                    begin
                        var"##return#327" = let name = var"##329"
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#328#348")))
                    end
                end
                begin
                    var"##return#327" = let
                            false
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#328#348")))
                end
                error("matching non-exhaustive, at #= none:228 =#")
                $(Expr(:symboliclabel, Symbol("####final#328#348")))
                var"##return#327"
            end
        end
    #= none:237 =# Core.@doc "    is_field_default(ex)\n\nCheck if `ex` is a `<field expr> = <default expr>` expression.\n" function is_field_default(#= none:242 =# @nospecialize(ex))
            let
                begin
                    var"##cache#352" = nothing
                end
                var"##return#349" = nothing
                var"##351" = ex
                if var"##351" isa Expr
                    if begin
                                if var"##cache#352" === nothing
                                    var"##cache#352" = Some(((var"##351").head, (var"##351").args))
                                end
                                var"##353" = (var"##cache#352").value
                                var"##353" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##353"[1] == :(=) && (begin
                                        var"##354" = var"##353"[2]
                                        var"##354" isa AbstractArray
                                    end && (length(var"##354") === 2 && (begin
                                                begin
                                                    var"##cache#356" = nothing
                                                end
                                                var"##355" = var"##354"[1]
                                                var"##355" isa Expr
                                            end && (begin
                                                    if var"##cache#356" === nothing
                                                        var"##cache#356" = Some(((var"##355").head, (var"##355").args))
                                                    end
                                                    var"##357" = (var"##cache#356").value
                                                    var"##357" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##357"[1] == :(::) && (begin
                                                            var"##358" = var"##357"[2]
                                                            var"##358" isa AbstractArray
                                                        end && (length(var"##358") === 2 && begin
                                                                var"##359" = var"##358"[1]
                                                                var"##360" = var"##358"[2]
                                                                var"##361" = var"##354"[2]
                                                                true
                                                            end))))))))
                        var"##return#349" = let default = var"##361", type = var"##360", name = var"##359"
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#350#366")))
                    end
                    if begin
                                var"##362" = (var"##cache#352").value
                                var"##362" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##362"[1] == :(=) && (begin
                                        var"##363" = var"##362"[2]
                                        var"##363" isa AbstractArray
                                    end && (length(var"##363") === 2 && (begin
                                                var"##364" = var"##363"[1]
                                                var"##364" isa Symbol
                                            end && begin
                                                var"##365" = var"##363"[2]
                                                true
                                            end))))
                        var"##return#349" = let default = var"##365", name = var"##364"
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#350#366")))
                    end
                end
                begin
                    var"##return#349" = let
                            false
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#350#366")))
                end
                error("matching non-exhaustive, at #= none:243 =#")
                $(Expr(:symboliclabel, Symbol("####final#350#366")))
                var"##return#349"
            end
        end
    #= none:250 =# Core.@doc "    is_datatype_expr(ex)\n\nCheck if `ex` is an expression for a concrete `DataType`, e.g\n`where` is not allowed in the expression.\n" function is_datatype_expr(#= none:256 =# @nospecialize(ex))
            let
                begin
                    var"##cache#370" = nothing
                end
                var"##return#367" = nothing
                var"##369" = ex
                if var"##369" isa GlobalRef
                    begin
                        var"##return#367" = let
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#368#384")))
                    end
                end
                if var"##369" isa Expr
                    if begin
                                if var"##cache#370" === nothing
                                    var"##cache#370" = Some(((var"##369").head, (var"##369").args))
                                end
                                var"##371" = (var"##cache#370").value
                                var"##371" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##371"[1] == :curly && (begin
                                        var"##372" = var"##371"[2]
                                        var"##372" isa AbstractArray
                                    end && (length(var"##372") === 2 && (begin
                                                begin
                                                    var"##cache#374" = nothing
                                                end
                                                var"##373" = var"##372"[2]
                                                var"##373" isa Expr
                                            end && (begin
                                                    if var"##cache#374" === nothing
                                                        var"##cache#374" = Some(((var"##373").head, (var"##373").args))
                                                    end
                                                    var"##375" = (var"##cache#374").value
                                                    var"##375" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##375"[1] == :... && (begin
                                                            var"##376" = var"##375"[2]
                                                            var"##376" isa AbstractArray
                                                        end && length(var"##376") === 1)))))))
                        var"##return#367" = let
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#368#384")))
                    end
                    if begin
                                var"##377" = (var"##cache#370").value
                                var"##377" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##377"[1] == :. && (begin
                                        var"##378" = var"##377"[2]
                                        var"##378" isa AbstractArray
                                    end && (length(var"##378") === 2 && (begin
                                                var"##379" = var"##378"[2]
                                                var"##379" isa QuoteNode
                                            end && begin
                                                var"##380" = (var"##379").value
                                                true
                                            end))))
                        var"##return#367" = let b = var"##380"
                                is_datatype_expr(b)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#368#384")))
                    end
                    if begin
                                var"##381" = (var"##cache#370").value
                                var"##381" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##381"[1] == :curly && (begin
                                        var"##382" = var"##381"[2]
                                        var"##382" isa AbstractArray
                                    end && ((ndims(var"##382") === 1 && length(var"##382") >= 0) && begin
                                            var"##383" = SubArray(var"##382", (1:length(var"##382"),))
                                            true
                                        end)))
                        var"##return#367" = let args = var"##383"
                                all(is_datatype_expr, args)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#368#384")))
                    end
                end
                if var"##369" isa Symbol
                    begin
                        var"##return#367" = let
                                true
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#368#384")))
                    end
                end
                begin
                    var"##return#367" = let
                            false
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#368#384")))
                end
                error("matching non-exhaustive, at #= none:257 =#")
                $(Expr(:symboliclabel, Symbol("####final#368#384")))
                var"##return#367"
            end
        end
    #= none:267 =# Core.@doc "    is_matrix_expr(ex)\n\nCheck if `ex` is an expression for a `Matrix`.\n" function is_matrix_expr(#= none:272 =# @nospecialize(ex))
            Meta.isexpr(ex, :hcat) && return true
            if Meta.isexpr(ex, :typed_vcat)
                args = ex.args[2:end]
            elseif Meta.isexpr(ex, :vcat)
                args = ex.args
            else
                return false
            end
            for row = args
                Meta.isexpr(row, :row) || return false
            end
            return true
        end
