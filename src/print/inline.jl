begin
    #= none:1 =# Base.@kwdef mutable struct InlinePrinterState
            type::Bool = false
            symbol::Bool = false
            call::Bool = false
            macrocall::Bool = false
            quoted::Bool = false
            keyword::Bool = false
            block::Bool = true
            precedence::Int = 0
        end
    function with(f::Function, p::InlinePrinterState, name::Symbol, new)
        old = getfield(p, name)
        setfield!(p, name, new)
        f()
        setfield!(p, name, old)
    end
    struct InlinePrinter{IO_t <: IO}
        io::IO_t
        color::ColorScheme
        line::Bool
        state::InlinePrinterState
    end
    function InlinePrinter(io::IO; color::ColorScheme = Monokai256(), line::Bool = false)
        InlinePrinter(io, color, line, InlinePrinterState())
    end
    function (p::InlinePrinter)(x, xs...; delim = ", ")
        p(x)
        for x = xs
            printstyled(p.io, delim; color = p.color.keyword)
            p(x)
        end
    end
    function (p::InlinePrinter)(expr)
        c = p.color
        print(xs...) = begin
                Base.print(p.io, xs...)
            end
        printstyled(xs...; kw...) = begin
                Base.printstyled(p.io, xs...; kw...)
            end
        function join(xs, delim = ", ")
            if !(p.line)
                xs = filter(!is_line_no, xs)
            end
            for (i, x) = enumerate(xs)
                p(x)
                i < length(xs) && keyword(delim)
            end
        end
        function print_braces(xs, open, close, delim = ", ")
            print(open)
            join(xs, delim)
            print(close)
        end
        string(s) = begin
                printstyled('"', s, '"', color = c.string)
            end
        keyword(s) = begin
                printstyled(s, color = c.keyword)
            end
        function symbol(ex)
            color = if p.state.type
                    c.type
                elseif p.state.quoted
                    c.quoted
                elseif p.state.call
                    c.call
                elseif p.state.macrocall
                    c.macrocall
                else
                    :normal
                end
            is_gensym(ex) && printstyled("var\""; color = color)
            printstyled(ex, color = color)
            is_gensym(ex) && printstyled("\""; color = color)
        end
        quoted(ex) = begin
                with((()->begin
                            p(ex)
                        end), p.state, :quoted, true)
            end
        type(ex) = begin
                with((()->begin
                            p(ex)
                        end), p.state, :type, true)
            end
        call(ex) = begin
                with((()->begin
                            p(ex)
                        end), p.state, :call, true)
            end
        macrocall(ex) = begin
                with((()->begin
                            p(ex)
                        end), p.state, :macrocall, true)
            end
        noblock(ex) = begin
                with((()->begin
                            p(ex)
                        end), p.state, :block, false)
            end
        block(ex) = begin
                with((()->begin
                            p(ex)
                        end), p.state, :block, true)
            end
        function precedence(f, s)
            if s isa Int
                preced = s
            else
                preced = Base.operator_precedence(s)
            end
            p.state.precedence >= preced && print('(')
            with(f, p.state, :precedence, preced)
            p.state.precedence >= preced && print(')')
        end
        function print_expr(ex)
            cache_1 = nothing
            x_1 = ex
            if x_1 isa GlobalRef
                return_1 = begin
                        p(ex.mod)
                        keyword(".")
                        p(ex.name)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#775_1")))
            end
            if x_1 isa Nothing
                return_1 = begin
                        printstyled("nothing", color = c.number)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#775_1")))
            end
            if x_1 isa Symbol
                return_1 = begin
                        symbol(ex)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#775_1")))
            end
            if x_1 isa Expr
                if begin
                            if cache_1 === nothing
                                cache_1 = Some((x_1.head, x_1.args))
                            end
                            x_2 = cache_1.value
                            x_2 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_2[1] == :line && (begin
                                    x_3 = x_2[2]
                                    x_3 isa AbstractArray
                                end && (length(x_3) === 2 && begin
                                        x_4 = x_3[1]
                                        x_5 = x_3[2]
                                        true
                                    end)))
                    line = x_5
                    file = x_4
                    return_1 = begin
                            p.line || return
                            printstyled("#= $(file):$(line) =#", color = c.line)
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_6 = cache_1.value
                            x_6 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_6[1] == :kw && (begin
                                    x_7 = x_6[2]
                                    x_7 isa AbstractArray
                                end && (length(x_7) === 2 && begin
                                        x_8 = x_7[1]
                                        x_9 = x_7[2]
                                        true
                                    end)))
                    k = x_8
                    v = x_9
                    return_1 = begin
                            p(k)
                            print(" = ")
                            p(v)
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_10 = cache_1.value
                            x_10 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_10[1] == :(=) && (begin
                                    x_11 = x_10[2]
                                    x_11 isa AbstractArray
                                end && (length(x_11) === 2 && (begin
                                            x_12 = x_11[1]
                                            cache_2 = nothing
                                            x_13 = x_11[2]
                                            x_13 isa Expr
                                        end && (begin
                                                if cache_2 === nothing
                                                    cache_2 = Some((x_13.head, x_13.args))
                                                end
                                                x_14 = cache_2.value
                                                x_14 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                            end && (x_14[1] == :block && (begin
                                                        x_15 = x_14[2]
                                                        x_15 isa AbstractArray
                                                    end && ((ndims(x_15) === 1 && length(x_15) >= 0) && begin
                                                            x_16 = (SubArray)(x_15, (1:length(x_15),))
                                                            true
                                                        end))))))))
                    k = x_12
                    stmts = x_16
                    return_1 = begin
                            if length(stmts) == 2 && count(!is_line_no, stmts) == 1
                                p(k)
                                keyword(" = ")
                                p.line && (is_line_no(stmts[1]) && p(stmts[1]))
                                p(stmts[end])
                            else
                                p(k)
                                keyword(" = ")
                                p(ex.args[2])
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_17 = cache_1.value
                            x_17 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_17[1] == :(=) && (begin
                                    x_18 = x_17[2]
                                    x_18 isa AbstractArray
                                end && (length(x_18) === 2 && begin
                                        x_19 = x_18[1]
                                        x_20 = x_18[2]
                                        true
                                    end)))
                    k = x_19
                    v = x_20
                    return_1 = begin
                            p(k)
                            print(" = ")
                            p(v)
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_21 = cache_1.value
                            x_21 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_21[1] == :... && (begin
                                    x_22 = x_21[2]
                                    x_22 isa AbstractArray
                                end && (length(x_22) === 1 && begin
                                        x_23 = x_22[1]
                                        true
                                    end)))
                    name = x_23
                    return_1 = begin
                            precedence(:...) do 
                                p(name)
                                keyword("...")
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_24 = cache_1.value
                            x_24 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_24[1] == :& && (begin
                                    x_25 = x_24[2]
                                    x_25 isa AbstractArray
                                end && (length(x_25) === 1 && begin
                                        x_26 = x_25[1]
                                        true
                                    end)))
                    name = x_26
                    return_1 = begin
                            precedence(:&) do 
                                keyword("&")
                                p(name)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_27 = cache_1.value
                            x_27 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_27[1] == :(::) && (begin
                                    x_28 = x_27[2]
                                    x_28 isa AbstractArray
                                end && (length(x_28) === 1 && begin
                                        x_29 = x_28[1]
                                        true
                                    end)))
                    t = x_29
                    return_1 = begin
                            precedence(:(::)) do 
                                keyword("::")
                                type(t)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_30 = cache_1.value
                            x_30 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_30[1] == :(::) && (begin
                                    x_31 = x_30[2]
                                    x_31 isa AbstractArray
                                end && (length(x_31) === 2 && begin
                                        x_32 = x_31[1]
                                        x_33 = x_31[2]
                                        true
                                    end)))
                    name = x_32
                    t = x_33
                    return_1 = begin
                            precedence(:(::)) do 
                                p(name)
                                keyword("::")
                                type(t)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_34 = cache_1.value
                            x_34 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_34[1] == :$ && (begin
                                    x_35 = x_34[2]
                                    x_35 isa AbstractArray
                                end && (length(x_35) === 1 && begin
                                        x_36 = x_35[1]
                                        true
                                    end)))
                    name = x_36
                    return_1 = begin
                            precedence(:$) do 
                                keyword('$')
                                print("(")
                                p(name)
                                print(")")
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_37 = cache_1.value
                            x_37 isa Tuple{var1, var2} where {var2<:AbstractArray, var1}
                        end && (begin
                                x_38 = x_37[1]
                                x_39 = x_37[2]
                                x_39 isa AbstractArray
                            end && (length(x_39) === 2 && begin
                                    x_40 = x_39[1]
                                    x_41 = x_39[2]
                                    let rhs = x_41, lhs = x_40, head = x_38
                                        head in expr_infix_wide
                                    end
                                end))
                    rhs = x_41
                    lhs = x_40
                    head = x_38
                    return_1 = begin
                            precedence(head) do 
                                p(lhs)
                                keyword(" $(head) ")
                                p(rhs)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_42 = cache_1.value
                            x_42 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_42[1] == :. && (begin
                                    x_43 = x_42[2]
                                    x_43 isa AbstractArray
                                end && (length(x_43) === 1 && begin
                                        x_44 = x_43[1]
                                        true
                                    end)))
                    name = x_44
                    return_1 = begin
                            print(name)
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_45 = cache_1.value
                            x_45 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_45[1] == :. && (begin
                                    x_46 = x_45[2]
                                    x_46 isa AbstractArray
                                end && (length(x_46) === 2 && (begin
                                            x_47 = x_46[1]
                                            x_48 = x_46[2]
                                            x_48 isa QuoteNode
                                        end && begin
                                            x_49 = x_48.value
                                            true
                                        end))))
                    name = x_49
                    object = x_47
                    return_1 = begin
                            precedence(:.) do 
                                p(object)
                                keyword(".")
                                p(name)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_50 = cache_1.value
                            x_50 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_50[1] == :<: && (begin
                                    x_51 = x_50[2]
                                    x_51 isa AbstractArray
                                end && (length(x_51) === 2 && begin
                                        x_52 = x_51[1]
                                        x_53 = x_51[2]
                                        true
                                    end)))
                    type = x_52
                    supertype = x_53
                    return_1 = begin
                            precedence(:<:) do 
                                p(type)
                                keyword(" <: ")
                                p(supertype)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_54 = cache_1.value
                            x_54 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_54[1] == :call && (begin
                                    x_55 = x_54[2]
                                    x_55 isa AbstractArray
                                end && ((ndims(x_55) === 1 && length(x_55) >= 1) && (x_55[1] == :(:) && begin
                                            x_56 = (SubArray)(x_55, (2:length(x_55),))
                                            true
                                        end))))
                    args = x_56
                    return_1 = begin
                            precedence(:(:)) do 
                                join(args, ":")
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_57 = cache_1.value
                            x_57 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_57[1] == :call && (begin
                                    x_58 = x_57[2]
                                    x_58 isa AbstractArray
                                end && ((ndims(x_58) === 1 && length(x_58) >= 2) && (begin
                                            x_59 = x_58[1]
                                            cache_3 = nothing
                                            x_60 = x_58[2]
                                            x_60 isa Expr
                                        end && (begin
                                                if cache_3 === nothing
                                                    cache_3 = Some((x_60.head, x_60.args))
                                                end
                                                x_61 = cache_3.value
                                                x_61 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                            end && (x_61[1] == :parameters && (begin
                                                        x_62 = x_61[2]
                                                        x_62 isa AbstractArray
                                                    end && ((ndims(x_62) === 1 && length(x_62) >= 0) && begin
                                                            x_63 = (SubArray)(x_62, (1:length(x_62),))
                                                            x_64 = (SubArray)(x_58, (3:length(x_58),))
                                                            true
                                                        end))))))))
                    f = x_59
                    args = x_64
                    kwargs = x_63
                    return_1 = begin
                            call(f)
                            print("(")
                            join(args)
                            keyword("; ")
                            join(kwargs)
                            print(")")
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_65 = cache_1.value
                            x_65 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_65[1] == :call && (begin
                                    x_66 = x_65[2]
                                    x_66 isa AbstractArray
                                end && (length(x_66) === 2 && (begin
                                            x_67 = x_66[1]
                                            x_67 isa Symbol
                                        end && begin
                                            x_68 = x_66[2]
                                            let f = x_67, arg = x_68
                                                Base.isunaryoperator(f)
                                            end
                                        end))))
                    f = x_67
                    arg = x_68
                    return_1 = begin
                            precedence(typemax(Int)) do 
                                keyword(f)
                                p(arg)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_69 = cache_1.value
                            x_69 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_69[1] == :call && (begin
                                    x_70 = x_69[2]
                                    x_70 isa AbstractArray
                                end && ((ndims(x_70) === 1 && length(x_70) >= 1) && (begin
                                            x_71 = x_70[1]
                                            x_71 isa Symbol
                                        end && begin
                                            x_72 = (SubArray)(x_70, (2:length(x_70),))
                                            let f = x_71, args = x_72
                                                Base.isbinaryoperator(f)
                                            end
                                        end))))
                    f = x_71
                    args = x_72
                    return_1 = begin
                            precedence(f) do 
                                join(args, " $(f) ")
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_73 = cache_1.value
                            x_73 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_73[1] == :call && (begin
                                    x_74 = x_73[2]
                                    x_74 isa AbstractArray
                                end && ((ndims(x_74) === 1 && length(x_74) >= 1) && begin
                                        x_75 = x_74[1]
                                        x_76 = (SubArray)(x_74, (2:length(x_74),))
                                        true
                                    end)))
                    f = x_75
                    args = x_76
                    return_1 = begin
                            call(f)
                            print_braces(args, "(", ")")
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_77 = cache_1.value
                            x_77 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_77[1] == :tuple && (begin
                                    x_78 = x_77[2]
                                    x_78 isa AbstractArray
                                end && ((ndims(x_78) === 1 && length(x_78) >= 0) && begin
                                        x_79 = (SubArray)(x_78, (1:length(x_78),))
                                        true
                                    end)))
                    args = x_79
                    return_1 = begin
                            print_braces(args, "(", ")")
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_80 = cache_1.value
                            x_80 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_80[1] == :curly && (begin
                                    x_81 = x_80[2]
                                    x_81 isa AbstractArray
                                end && ((ndims(x_81) === 1 && length(x_81) >= 1) && begin
                                        x_82 = x_81[1]
                                        x_83 = (SubArray)(x_81, (2:length(x_81),))
                                        true
                                    end)))
                    args = x_83
                    t = x_82
                    return_1 = begin
                            with(p.state, :type, true) do 
                                p(t)
                                print_braces(args, "{", "}")
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_84 = cache_1.value
                            x_84 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_84[1] == :vect && (begin
                                    x_85 = x_84[2]
                                    x_85 isa AbstractArray
                                end && ((ndims(x_85) === 1 && length(x_85) >= 0) && begin
                                        x_86 = (SubArray)(x_85, (1:length(x_85),))
                                        true
                                    end)))
                    args = x_86
                    return_1 = begin
                            print_braces(args, "[", "]")
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_87 = cache_1.value
                            x_87 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_87[1] == :hcat && (begin
                                    x_88 = x_87[2]
                                    x_88 isa AbstractArray
                                end && ((ndims(x_88) === 1 && length(x_88) >= 0) && begin
                                        x_89 = (SubArray)(x_88, (1:length(x_88),))
                                        true
                                    end)))
                    args = x_89
                    return_1 = begin
                            print_braces(args, "[", "]", " ")
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_90 = cache_1.value
                            x_90 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_90[1] == :typed_hcat && (begin
                                    x_91 = x_90[2]
                                    x_91 isa AbstractArray
                                end && ((ndims(x_91) === 1 && length(x_91) >= 1) && begin
                                        x_92 = x_91[1]
                                        x_93 = (SubArray)(x_91, (2:length(x_91),))
                                        true
                                    end)))
                    args = x_93
                    t = x_92
                    return_1 = begin
                            type(t)
                            print_braces(args, "[", "]", " ")
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_94 = cache_1.value
                            x_94 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_94[1] == :vcat && (begin
                                    x_95 = x_94[2]
                                    x_95 isa AbstractArray
                                end && ((ndims(x_95) === 1 && length(x_95) >= 0) && begin
                                        x_96 = (SubArray)(x_95, (1:length(x_95),))
                                        true
                                    end)))
                    args = x_96
                    return_1 = begin
                            print_braces(args, "[", "]", "; ")
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_97 = cache_1.value
                            x_97 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_97[1] == :ncat && (begin
                                    x_98 = x_97[2]
                                    x_98 isa AbstractArray
                                end && ((ndims(x_98) === 1 && length(x_98) >= 1) && begin
                                        x_99 = x_98[1]
                                        x_100 = (SubArray)(x_98, (2:length(x_98),))
                                        true
                                    end)))
                    n = x_99
                    args = x_100
                    return_1 = begin
                            print_braces(args, "[", "]", ";" ^ n * " ")
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_101 = cache_1.value
                            x_101 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_101[1] == :ref && (begin
                                    x_102 = x_101[2]
                                    x_102 isa AbstractArray
                                end && ((ndims(x_102) === 1 && length(x_102) >= 1) && begin
                                        x_103 = x_102[1]
                                        x_104 = (SubArray)(x_102, (2:length(x_102),))
                                        true
                                    end)))
                    args = x_104
                    object = x_103
                    return_1 = begin
                            p(object)
                            print_braces(args, "[", "]")
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_105 = cache_1.value
                            x_105 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_105[1] == :-> && (begin
                                    x_106 = x_105[2]
                                    x_106 isa AbstractArray
                                end && (length(x_106) === 2 && (begin
                                            x_107 = x_106[1]
                                            cache_4 = nothing
                                            x_108 = x_106[2]
                                            x_108 isa Expr
                                        end && (begin
                                                if cache_4 === nothing
                                                    cache_4 = Some((x_108.head, x_108.args))
                                                end
                                                x_109 = cache_4.value
                                                x_109 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                            end && (x_109[1] == :block && (begin
                                                        x_110 = x_109[2]
                                                        x_110 isa AbstractArray
                                                    end && (length(x_110) === 2 && begin
                                                            x_111 = x_110[1]
                                                            x_112 = x_110[2]
                                                            true
                                                        end))))))))
                    line = x_111
                    code = x_112
                    args = x_107
                    return_1 = begin
                            p(args)
                            keyword(" -> ")
                            p.line && begin
                                    print("(")
                                    p(line)
                                    print(" ")
                                end
                            p(code)
                            p.line && print(")")
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_113 = cache_1.value
                            x_113 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_113[1] == :-> && (begin
                                    x_114 = x_113[2]
                                    x_114 isa AbstractArray
                                end && (length(x_114) === 2 && begin
                                        x_115 = x_114[1]
                                        x_116 = x_114[2]
                                        true
                                    end)))
                    args = x_115
                    body = x_116
                    return_1 = begin
                            p(args)
                            keyword(" -> ")
                            print("(")
                            noblock(body)
                            print(")")
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_117 = cache_1.value
                            x_117 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_117[1] == :quote && (begin
                                    x_118 = x_117[2]
                                    x_118 isa AbstractArray
                                end && ((ndims(x_118) === 1 && length(x_118) >= 0) && begin
                                        x_119 = (SubArray)(x_118, (1:length(x_118),))
                                        true
                                    end)))
                    args = x_119
                    return_1 = begin
                            keyword("quote ")
                            with(p.state, :block, false) do 
                                join(args, "; ")
                            end
                            keyword(" end")
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_120 = cache_1.value
                            x_120 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_120[1] == :string && (begin
                                    x_121 = x_120[2]
                                    x_121 isa AbstractArray
                                end && ((ndims(x_121) === 1 && length(x_121) >= 0) && begin
                                        x_122 = (SubArray)(x_121, (1:length(x_121),))
                                        true
                                    end)))
                    args = x_122
                    return_1 = begin
                            printstyled("\"", color = c.string)
                            foreach(args) do x
                                x isa AbstractString && return printstyled(x; color = c.string)
                                keyword('$')
                                x isa Symbol && return p(x)
                                print("(")
                                p(x)
                                print(")")
                            end
                            printstyled("\"", color = c.string)
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_123 = cache_1.value
                            x_123 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_123[1] == :block && (begin
                                    x_124 = x_123[2]
                                    x_124 isa AbstractArray
                                end && ((ndims(x_124) === 1 && length(x_124) >= 0) && begin
                                        x_125 = (SubArray)(x_124, (1:length(x_124),))
                                        let args = x_125
                                            length(args) == 2 && (is_line_no(args[1]) && is_line_no(args[2]))
                                        end
                                    end)))
                    args = x_125
                    return_1 = begin
                            p(args[1])
                            print(" ")
                            p(args[2])
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_126 = cache_1.value
                            x_126 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_126[1] == :block && (begin
                                    x_127 = x_126[2]
                                    x_127 isa AbstractArray
                                end && ((ndims(x_127) === 1 && length(x_127) >= 0) && begin
                                        x_128 = (SubArray)(x_127, (1:length(x_127),))
                                        let args = x_128
                                            length(args) == 2 && is_line_no(args[1])
                                        end
                                    end)))
                    args = x_128
                    return_1 = begin
                            p(args[1])
                            print(" ")
                            noblock(args[2])
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_129 = cache_1.value
                            x_129 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_129[1] == :block && (begin
                                    x_130 = x_129[2]
                                    x_130 isa AbstractArray
                                end && ((ndims(x_130) === 1 && length(x_130) >= 0) && begin
                                        x_131 = (SubArray)(x_130, (1:length(x_130),))
                                        let args = x_131
                                            length(args) == 2 && is_line_no(args[2])
                                        end
                                    end)))
                    args = x_131
                    return_1 = begin
                            noblock(args[1])
                            print(" ")
                            p(args[2])
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_132 = cache_1.value
                            x_132 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_132[1] == :block && (begin
                                    x_133 = x_132[2]
                                    x_133 isa AbstractArray
                                end && ((ndims(x_133) === 1 && length(x_133) >= 0) && begin
                                        x_134 = (SubArray)(x_133, (1:length(x_133),))
                                        let args = x_134
                                            length(args) == 2
                                        end
                                    end)))
                    args = x_134
                    return_1 = begin
                            print("(")
                            noblock(args[1])
                            keyword("; ")
                            noblock(args[2])
                            print(")")
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_135 = cache_1.value
                            x_135 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_135[1] == :block && (begin
                                    x_136 = x_135[2]
                                    x_136 isa AbstractArray
                                end && ((ndims(x_136) === 1 && length(x_136) >= 0) && begin
                                        x_137 = (SubArray)(x_136, (1:length(x_136),))
                                        true
                                    end)))
                    args = x_137
                    return_1 = begin
                            p.state.block && keyword("begin ")
                            with(p.state, :block, true) do 
                                join(args, "; ")
                            end
                            p.state.block && keyword(" end")
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_138 = cache_1.value
                            x_138 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_138[1] == :let && (begin
                                    x_139 = x_138[2]
                                    x_139 isa AbstractArray
                                end && (length(x_139) === 2 && (begin
                                            cache_5 = nothing
                                            x_140 = x_139[1]
                                            x_140 isa Expr
                                        end && (begin
                                                if cache_5 === nothing
                                                    cache_5 = Some((x_140.head, x_140.args))
                                                end
                                                x_141 = cache_5.value
                                                x_141 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                            end && (x_141[1] == :block && (begin
                                                        x_142 = x_141[2]
                                                        x_142 isa AbstractArray
                                                    end && ((ndims(x_142) === 1 && length(x_142) >= 0) && begin
                                                            x_143 = (SubArray)(x_142, (1:length(x_142),))
                                                            x_144 = x_139[2]
                                                            true
                                                        end))))))))
                    args = x_143
                    body = x_144
                    return_1 = begin
                            keyword("let ")
                            join(args, ", ")
                            keyword("; ")
                            noblock(body)
                            keyword("; end")
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_145 = cache_1.value
                            x_145 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_145[1] == :macrocall && (begin
                                    x_146 = x_145[2]
                                    x_146 isa AbstractArray
                                end && ((ndims(x_146) === 1 && length(x_146) >= 2) && begin
                                        x_147 = x_146[1]
                                        x_148 = x_146[2]
                                        x_149 = (SubArray)(x_146, (3:length(x_146),))
                                        true
                                    end)))
                    f = x_147
                    line = x_148
                    args = x_149
                    return_1 = begin
                            p.line && printstyled(line, color = c.comment)
                            macrocall(f)
                            print_braces(args, "(", ")")
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_150 = cache_1.value
                            x_150 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_150[1] == :return && (begin
                                    x_151 = x_150[2]
                                    x_151 isa AbstractArray
                                end && (length(x_151) === 1 && (begin
                                            cache_6 = nothing
                                            x_152 = x_151[1]
                                            x_152 isa Expr
                                        end && (begin
                                                if cache_6 === nothing
                                                    cache_6 = Some((x_152.head, x_152.args))
                                                end
                                                x_153 = cache_6.value
                                                x_153 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                            end && (x_153[1] == :tuple && (begin
                                                        x_154 = x_153[2]
                                                        x_154 isa AbstractArray
                                                    end && ((ndims(x_154) === 1 && length(x_154) >= 0) && begin
                                                            x_155 = (SubArray)(x_154, (1:length(x_154),))
                                                            true
                                                        end))))))))
                    args = x_155
                    return_1 = begin
                            keyword("return ")
                            join(args)
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_156 = cache_1.value
                            x_156 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_156[1] == :return && (begin
                                    x_157 = x_156[2]
                                    x_157 isa AbstractArray
                                end && ((ndims(x_157) === 1 && length(x_157) >= 0) && begin
                                        x_158 = (SubArray)(x_157, (1:length(x_157),))
                                        true
                                    end)))
                    args = x_158
                    return_1 = begin
                            keyword("return ")
                            join(args)
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_159 = cache_1.value
                            x_159 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_159[1] == :module && (begin
                                    x_160 = x_159[2]
                                    x_160 isa AbstractArray
                                end && (length(x_160) === 3 && begin
                                        x_161 = x_160[1]
                                        x_162 = x_160[2]
                                        x_163 = x_160[3]
                                        true
                                    end)))
                    bare = x_161
                    name = x_162
                    body = x_163
                    return_1 = begin
                            if bare
                                keyword("module ")
                            else
                                keyword("baremodule ")
                            end
                            p(name)
                            print("; ")
                            noblock(body)
                            keyword(" end")
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_164 = cache_1.value
                            x_164 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_164[1] == :using && (begin
                                    x_165 = x_164[2]
                                    x_165 isa AbstractArray
                                end && ((ndims(x_165) === 1 && length(x_165) >= 0) && begin
                                        x_166 = (SubArray)(x_165, (1:length(x_165),))
                                        true
                                    end)))
                    args = x_166
                    return_1 = begin
                            keyword("using ")
                            join(args)
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_167 = cache_1.value
                            x_167 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_167[1] == :import && (begin
                                    x_168 = x_167[2]
                                    x_168 isa AbstractArray
                                end && ((ndims(x_168) === 1 && length(x_168) >= 0) && begin
                                        x_169 = (SubArray)(x_168, (1:length(x_168),))
                                        true
                                    end)))
                    args = x_169
                    return_1 = begin
                            keyword("import ")
                            join(args)
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_170 = cache_1.value
                            x_170 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_170[1] == :as && (begin
                                    x_171 = x_170[2]
                                    x_171 isa AbstractArray
                                end && (length(x_171) === 2 && begin
                                        x_172 = x_171[1]
                                        x_173 = x_171[2]
                                        true
                                    end)))
                    name = x_172
                    alias = x_173
                    return_1 = begin
                            p(name)
                            keyword(" as ")
                            p(alias)
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_174 = cache_1.value
                            x_174 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_174[1] == :export && (begin
                                    x_175 = x_174[2]
                                    x_175 isa AbstractArray
                                end && ((ndims(x_175) === 1 && length(x_175) >= 0) && begin
                                        x_176 = (SubArray)(x_175, (1:length(x_175),))
                                        true
                                    end)))
                    args = x_176
                    return_1 = begin
                            keyword("export ")
                            join(args)
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_177 = cache_1.value
                            x_177 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_177[1] == :(:) && (begin
                                    x_178 = x_177[2]
                                    x_178 isa AbstractArray
                                end && ((ndims(x_178) === 1 && length(x_178) >= 1) && begin
                                        x_179 = x_178[1]
                                        x_180 = (SubArray)(x_178, (2:length(x_178),))
                                        true
                                    end)))
                    args = x_180
                    head = x_179
                    return_1 = begin
                            p(head)
                            keyword(": ")
                            join(args)
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_181 = cache_1.value
                            x_181 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_181[1] == :where && (begin
                                    x_182 = x_181[2]
                                    x_182 isa AbstractArray
                                end && ((ndims(x_182) === 1 && length(x_182) >= 1) && begin
                                        x_183 = x_182[1]
                                        x_184 = (SubArray)(x_182, (2:length(x_182),))
                                        true
                                    end)))
                    body = x_183
                    whereparams = x_184
                    return_1 = begin
                            p(body)
                            keyword(" where ")
                            with(p.state, :type, true) do 
                                join(whereparams, ", ")
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_185 = cache_1.value
                            x_185 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_185[1] == :for && (begin
                                    x_186 = x_185[2]
                                    x_186 isa AbstractArray
                                end && (length(x_186) === 2 && begin
                                        x_187 = x_186[1]
                                        x_188 = x_186[2]
                                        true
                                    end)))
                    body = x_188
                    iteration = x_187
                    return_1 = begin
                            keyword("for ")
                            noblock(iteration)
                            keyword("; ")
                            noblock(body)
                            keyword("; end")
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_189 = cache_1.value
                            x_189 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_189[1] == :while && (begin
                                    x_190 = x_189[2]
                                    x_190 isa AbstractArray
                                end && (length(x_190) === 2 && begin
                                        x_191 = x_190[1]
                                        x_192 = x_190[2]
                                        true
                                    end)))
                    body = x_192
                    condition = x_191
                    return_1 = begin
                            keyword("while ")
                            noblock(condition)
                            keyword("; ")
                            noblock(body)
                            keyword("; end")
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_193 = cache_1.value
                            x_193 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_193[1] == :if && (begin
                                    x_194 = x_193[2]
                                    x_194 isa AbstractArray
                                end && (length(x_194) === 2 && begin
                                        x_195 = x_194[1]
                                        x_196 = x_194[2]
                                        true
                                    end)))
                    body = x_196
                    condition = x_195
                    return_1 = begin
                            keyword("if ")
                            noblock(condition)
                            keyword("; ")
                            noblock(body)
                            keyword("; end")
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_197 = cache_1.value
                            x_197 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_197[1] == :if && (begin
                                    x_198 = x_197[2]
                                    x_198 isa AbstractArray
                                end && (length(x_198) === 3 && begin
                                        x_199 = x_198[1]
                                        x_200 = x_198[2]
                                        x_201 = x_198[3]
                                        true
                                    end)))
                    body = x_200
                    elsebody = x_201
                    condition = x_199
                    return_1 = begin
                            keyword("if ")
                            noblock(condition)
                            keyword("; ")
                            noblock(body)
                            keyword("; ")
                            Meta.isexpr(elsebody, :elseif) || keyword("else ")
                            noblock(elsebody)
                            keyword("; end")
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_202 = cache_1.value
                            x_202 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_202[1] == :elseif && (begin
                                    x_203 = x_202[2]
                                    x_203 isa AbstractArray
                                end && (length(x_203) === 2 && begin
                                        x_204 = x_203[1]
                                        x_205 = x_203[2]
                                        true
                                    end)))
                    body = x_205
                    condition = x_204
                    return_1 = begin
                            keyword("elseif ")
                            noblock(condition)
                            keyword("; ")
                            noblock(body)
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_206 = cache_1.value
                            x_206 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_206[1] == :elseif && (begin
                                    x_207 = x_206[2]
                                    x_207 isa AbstractArray
                                end && (length(x_207) === 3 && begin
                                        x_208 = x_207[1]
                                        x_209 = x_207[2]
                                        x_210 = x_207[3]
                                        true
                                    end)))
                    body = x_209
                    elsebody = x_210
                    condition = x_208
                    return_1 = begin
                            keyword("elseif ")
                            noblock(condition)
                            keyword("; ")
                            noblock(body)
                            keyword("; else ")
                            noblock(elsebody)
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_211 = cache_1.value
                            x_211 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_211[1] == :try && (begin
                                    x_212 = x_211[2]
                                    x_212 isa AbstractArray
                                end && (length(x_212) === 3 && begin
                                        x_213 = x_212[1]
                                        x_214 = x_212[2]
                                        x_215 = x_212[3]
                                        true
                                    end)))
                    catch_vars = x_214
                    catch_body = x_215
                    try_body = x_213
                    return_1 = begin
                            keyword("try ")
                            noblock(try_body)
                            keyword("; ")
                            catch_vars == false || begin
                                    keyword("catch ")
                                    noblock(catch_vars)
                                end
                            catch_vars == false || begin
                                    keyword("; ")
                                    noblock(catch_body)
                                end
                            keyword("; end")
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_216 = cache_1.value
                            x_216 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_216[1] == :try && (begin
                                    x_217 = x_216[2]
                                    x_217 isa AbstractArray
                                end && (length(x_217) === 4 && begin
                                        x_218 = x_217[1]
                                        x_219 = x_217[2]
                                        x_220 = x_217[3]
                                        x_221 = x_217[4]
                                        true
                                    end)))
                    catch_vars = x_219
                    catch_body = x_220
                    try_body = x_218
                    finally_body = x_221
                    return_1 = begin
                            keyword("try ")
                            noblock(try_body)
                            keyword("; ")
                            catch_vars == false || begin
                                    keyword("catch ")
                                    noblock(catch_vars)
                                end
                            catch_vars == false || begin
                                    keyword("; ")
                                    noblock(catch_body)
                                end
                            finally_body == false || begin
                                    keyword("; finally ")
                                    noblock(finally_body)
                                end
                            keyword("; end")
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_222 = cache_1.value
                            x_222 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_222[1] == :try && (begin
                                    x_223 = x_222[2]
                                    x_223 isa AbstractArray
                                end && (length(x_223) === 5 && begin
                                        x_224 = x_223[1]
                                        x_225 = x_223[2]
                                        x_226 = x_223[3]
                                        x_227 = x_223[4]
                                        x_228 = x_223[5]
                                        true
                                    end)))
                    catch_vars = x_225
                    catch_body = x_226
                    try_body = x_224
                    finally_body = x_227
                    else_body = x_228
                    return_1 = begin
                            keyword("try ")
                            noblock(try_body)
                            keyword("; ")
                            catch_vars == false || begin
                                    keyword("catch ")
                                    noblock(catch_vars)
                                end
                            catch_vars == false || begin
                                    keyword("; ")
                                    noblock(catch_body)
                                end
                            keyword("; else ")
                            noblock(else_body)
                            finally_body == false || begin
                                    keyword("; finally ")
                                    noblock(finally_body)
                                end
                            keyword("; end")
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_229 = cache_1.value
                            x_229 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_229[1] == :struct && (begin
                                    x_230 = x_229[2]
                                    x_230 isa AbstractArray
                                end && (length(x_230) === 3 && begin
                                        x_231 = x_230[1]
                                        x_232 = x_230[2]
                                        x_233 = x_230[3]
                                        true
                                    end)))
                    ismutable = x_231
                    name = x_232
                    body = x_233
                    return_1 = begin
                            if ismutable
                                keyword("mutable struct ")
                            else
                                keyword("struct ")
                            end
                            p(name)
                            keyword("; ")
                            noblock(body)
                            keyword("; end")
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_234 = cache_1.value
                            x_234 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_234[1] == :primitive && (begin
                                    x_235 = x_234[2]
                                    x_235 isa AbstractArray
                                end && (length(x_235) === 2 && begin
                                        x_236 = x_235[1]
                                        x_237 = x_235[2]
                                        true
                                    end)))
                    name = x_236
                    size = x_237
                    return_1 = begin
                            keyword("primitive ")
                            p(name)
                            print(" ")
                            p(size)
                            keyword(" end")
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_238 = cache_1.value
                            x_238 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_238[1] == :meta && (begin
                                    x_239 = x_238[2]
                                    x_239 isa AbstractArray
                                end && (length(x_239) === 1 && x_239[1] == :inline)))
                    return_1 = begin
                            macrocall(GlobalRef(Base, Symbol("@_inline_meta")))
                            keyword(";")
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_240 = cache_1.value
                            x_240 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_240[1] == :symboliclabel && (begin
                                    x_241 = x_240[2]
                                    x_241 isa AbstractArray
                                end && (length(x_241) === 1 && begin
                                        x_242 = x_241[1]
                                        true
                                    end)))
                    label = x_242
                    return_1 = begin
                            macrocall(GlobalRef(Base, Symbol("@label")))
                            print(" ")
                            p(label)
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_243 = cache_1.value
                            x_243 isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (x_243[1] == :symbolicgoto && (begin
                                    x_244 = x_243[2]
                                    x_244 isa AbstractArray
                                end && (length(x_244) === 1 && begin
                                        x_245 = x_244[1]
                                        true
                                    end)))
                    label = x_245
                    return_1 = begin
                            macrocall(GlobalRef(Base, Symbol("@goto")))
                            print(" ")
                            p(label)
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
                if begin
                            x_246 = cache_1.value
                            x_246 isa Tuple{var1, var2} where {var2<:AbstractArray, var1}
                        end && (begin
                                x_247 = x_246[1]
                                x_248 = x_246[2]
                                x_248 isa AbstractArray
                            end && ((ndims(x_248) === 1 && length(x_248) >= 0) && begin
                                    x_249 = (SubArray)(x_248, (1:length(x_248),))
                                    true
                                end))
                    args = x_249
                    head = x_247
                    return_1 = begin
                            keyword('$')
                            print("(")
                            printstyled(:Expr, color = c.call)
                            print("(")
                            keyword(":")
                            printstyled(head, color = c.symbol)
                            print(", ")
                            join(args)
                            print("))")
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#775_1")))
                end
            end
            if x_1 isa QuoteNode
                return_1 = begin
                        if Base.isidentifier(ex.value)
                            keyword(":")
                            quoted(ex.value)
                        else
                            keyword('$')
                            print("(")
                            printstyled("QuoteNode", color = c.call)
                            print("(")
                            quoted(ex.value)
                            print("))")
                        end
                    end
                $(Expr(:symbolicgoto, Symbol("##final#775_1")))
            end
            if x_1 isa String
                return_1 = begin
                        string(ex)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#775_1")))
            end
            if x_1 isa Number
                return_1 = begin
                        printstyled(ex, color = c.number)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#775_1")))
            end
            if x_1 isa LineNumberNode
                return_1 = begin
                        p.line || return
                        printstyled("#= $(ex.file):$(ex.line) =#", color = c.line)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#775_1")))
            end
            return_1 = begin
                    print(ex)
                end
            $(Expr(:symbolicgoto, Symbol("##final#775_1")))
            (error)("matching non-exhaustive, at #= none:100 =#")
            $(Expr(:symboliclabel, Symbol("##final#775_1")))
            return_1
        end
        print_expr(expr)
        return
    end
    #= none:357 =# Core.@doc "    print_expr([io::IO], ex; kw...)\n\nPrint a given expression within one line.\n`ex` can be a `Expr` or a syntax type `JLExpr`.\n" print_inline(io::IO, expr; kw...) = begin
                (InlinePrinter(io; kw...))(expr)
            end
    print_inline(expr; kw...) = begin
            (InlinePrinter(stdout; kw...))(expr)
        end
end
