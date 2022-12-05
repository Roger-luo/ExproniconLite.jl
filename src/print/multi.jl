begin
    #= none:1 =# Base.@kwdef mutable struct PrinterState
            indent::Int = 0
            level::Int = 0
            no_first_line_indent::Bool = false
            block::Bool = true
            quoted::Bool = false
        end
    function with(f, ps::PrinterState, name::Symbol, new)
        old = getfield(ps, name)
        setfield!(ps, name, new)
        f()
        setfield!(ps, name, old)
        return
    end
    struct Printer{IO_t <: IO}
        io::IO_t
        color::ColorScheme
        line::Bool
        always_begin_end::Bool
        state::PrinterState
    end
    function Printer(io::IO; indent::Int = get(io, :indent, 0), color::ColorScheme = Monokai256(), line::Bool = false, always_begin_end = false, root::Bool = true)
        state = PrinterState(; indent, level = if root
                        0
                    else
                        1
                    end)
        Printer(io, color, line, always_begin_end, state)
    end
    function (p::Printer)(ex)
        c = p.color
        inline = InlinePrinter(p.io, color = c, line = p.line)
        print(xs...) = begin
                Base.print(p.io, xs...)
            end
        println(xs...) = begin
                Base.println(p.io, xs...)
            end
        printstyled(xs...; kw...) = begin
                Base.printstyled(p.io, xs...; kw...)
            end
        keyword(s) = begin
                printstyled(s, color = c.keyword)
            end
        tab() = begin
                print(" " ^ p.state.indent)
            end
        leading_tab() = begin
                p.state.no_first_line_indent || tab()
            end
        function indent(f; size::Int = 4, level::Int = 1)
            with(p.state, :level, p.state.level + level) do 
                with(f, p.state, :indent, p.state.indent + size)
            end
        end
        function print_stmts(stmts; leading_indent::Bool = true)
            first_line = true
            if !(p.line)
                stmts = filter(!is_line_no, stmts)
            end
            for (i, stmt) = enumerate(stmts)
                if !leading_indent && first_line
                    first_line = false
                else
                    tab()
                end
                no_first_line_indent() do 
                    p(stmt)
                end
                if i < length(stmts)
                    println()
                end
            end
        end
        noblock(f) = begin
                with(f, p.state, :block, false)
            end
        quoted(f) = begin
                with(f, p.state, :quoted, true)
            end
        is_root() = begin
                p.state.level == 0
            end
        no_first_line_indent(f) = begin
                with(f, p.state, :no_first_line_indent, true)
            end
        function print_if(cond, body, otherwise = nothing)
            stmts = split_body(body)
            leading_tab()
            keyword("if ")
            inline(cond)
            println()
            indent() do 
                print_stmts(stmts)
            end
            isnothing(otherwise) || print_else(otherwise)
            println()
            tab()
            keyword("end")
        end
        function print_else(otherwise)
            println()
            Meta.isexpr(otherwise, :elseif) && return p(otherwise)
            tab()
            keyword("else")
            println()
            let
                cache_1 = nothing
                return_1 = nothing
                x_1 = otherwise
                if x_1 isa Expr && (begin
                                if cache_1 === nothing
                                    cache_1 = Some((x_1.head, x_1.args))
                                end
                                x_2 = cache_1.value
                                x_2 isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (x_2[1] == :block && (begin
                                        x_3 = x_2[2]
                                        x_3 isa AbstractArray
                                    end && ((ndims(x_3) === 1 && length(x_3) >= 0) && begin
                                            x_4 = (SubArray)(x_3, (1:length(x_3),))
                                            true
                                        end))))
                    return_1 = let stmts = x_4
                            indent() do 
                                print_stmts(stmts)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#1004_1")))
                end
                return_1 = let
                        indent() do 
                            tab()
                            no_first_line_indent() do 
                                p(otherwise)
                            end
                        end
                    end
                $(Expr(:symbolicgoto, Symbol("##final#1004_1")))
                (error)("matching non-exhaustive, at #= none:97 =#")
                $(Expr(:symboliclabel, Symbol("##final#1004_1")))
                return_1
            end
        end
        function print_elseif(cond, body, line = nothing, otherwise = nothing)
            stmts = split_body(body)
            tab()
            keyword("elseif ")
            isnothing(line) || p.line && begin
                        inline(line)
                        print(" ")
                    end
            inline(cond)
            println()
            indent() do 
                print_stmts(stmts)
            end
            isnothing(otherwise) || print_else(otherwise)
        end
        function print_function(head, call, body)
            stmts = split_body(body)
            leading_tab()
            keyword("$(head) ")
            inline(call)
            println()
            indent() do 
                print_stmts(stmts)
            end
            println()
            tab()
            keyword("end")
        end
        function split_body(body)
            return let
                    cache_2 = nothing
                    return_2 = nothing
                    x_5 = body
                    if x_5 isa Expr && (begin
                                    if cache_2 === nothing
                                        cache_2 = Some((x_5.head, x_5.args))
                                    end
                                    x_6 = cache_2.value
                                    x_6 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                end && (x_6[1] == :block && (begin
                                            x_7 = x_6[2]
                                            x_7 isa AbstractArray
                                        end && ((ndims(x_7) === 1 && length(x_7) >= 0) && begin
                                                x_8 = (SubArray)(x_7, (1:length(x_7),))
                                                true
                                            end))))
                        return_2 = let stmts = x_8
                                stmts
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#1012_1")))
                    end
                    return_2 = let
                            (body,)
                        end
                    $(Expr(:symbolicgoto, Symbol("##final#1012_1")))
                    (error)("matching non-exhaustive, at #= none:132 =#")
                    $(Expr(:symboliclabel, Symbol("##final#1012_1")))
                    return_2
                end
        end
        function print_try(body)
            body == false && return
            stmts = split_body(body)
            leading_tab()
            keyword("try")
            println()
            indent() do 
                print_stmts(stmts)
            end
        end
        function print_catch(body, vars)
            body == false && return
            stmts = split_body(body)
            println()
            tab()
            keyword("catch")
            if vars != false
                print(" ")
                inline(vars)
            end
            println()
            indent() do 
                print_stmts(stmts)
            end
        end
        function print_finally(body)
            body == false && return
            stmts = split_body(body)
            println()
            tab()
            keyword("finally")
            println()
            indent() do 
                print_stmts(stmts)
            end
        end
        function print_macrocall(name, line, args)
            leading_tab()
            p.line && begin
                    inline(line)
                    print(" ")
                end
            with(inline.state, :macrocall, true) do 
                inline(name)
            end
            p.state.level += 1
            foreach(args) do arg
                print(" ")
                p(arg)
            end
        end
        function print_switch(item, line, stmts)
            leading_tab()
            p.line && begin
                    inline(line)
                    print(" ")
                end
            any(stmts) do stmt
                    let
                        cache_3 = nothing
                        return_3 = nothing
                        x_9 = stmt
                        if x_9 isa Expr && (begin
                                        if cache_3 === nothing
                                            cache_3 = Some((x_9.head, x_9.args))
                                        end
                                        x_10 = cache_3.value
                                        x_10 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                    end && (x_10[1] == :macrocall && (begin
                                                x_11 = x_10[2]
                                                x_11 isa AbstractArray
                                            end && ((ndims(x_11) === 1 && length(x_11) >= 1) && begin
                                                    x_12 = x_11[1]
                                                    x_12 == Symbol("@case")
                                                end))))
                            return_3 = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("##final#1020_1")))
                        end
                        return_3 = let
                                false
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#1020_1")))
                        (error)("matching non-exhaustive, at #= none:187 =#")
                        $(Expr(:symboliclabel, Symbol("##final#1020_1")))
                        return_3
                    end
                end || return print_macrocall("@switch", line, (item, Expr(:block, stmts...)))
            is_case(stmt) = begin
                    let
                        cache_4 = nothing
                        return_4 = nothing
                        x_13 = stmt
                        if x_13 isa Expr && (begin
                                        if cache_4 === nothing
                                            cache_4 = Some((x_13.head, x_13.args))
                                        end
                                        x_14 = cache_4.value
                                        x_14 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                    end && (x_14[1] == :macrocall && (begin
                                                x_15 = x_14[2]
                                                x_15 isa AbstractArray
                                            end && ((ndims(x_15) === 1 && length(x_15) >= 1) && begin
                                                    x_16 = x_15[1]
                                                    x_16 == Symbol("@case")
                                                end))))
                            return_4 = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("##final#1028_1")))
                        end
                        return_4 = let
                                false
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#1028_1")))
                        (error)("matching non-exhaustive, at #= none:193 =#")
                        $(Expr(:symboliclabel, Symbol("##final#1028_1")))
                        return_4
                    end
                end
            keyword("@switch ")
            p(item)
            keyword(" begin")
            println()
            indent() do 
                ptr = 1
                while ptr <= length(stmts)
                    stmt = stmts[ptr]
                    let
                        cache_5 = nothing
                        return_5 = nothing
                        x_17 = stmt
                        if x_17 isa Expr && (begin
                                        if cache_5 === nothing
                                            cache_5 = Some((x_17.head, x_17.args))
                                        end
                                        x_18 = cache_5.value
                                        x_18 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                    end && (x_18[1] == :macrocall && (begin
                                                x_19 = x_18[2]
                                                x_19 isa AbstractArray
                                            end && (length(x_19) === 3 && (begin
                                                        x_20 = x_19[1]
                                                        x_20 == Symbol("@case")
                                                    end && begin
                                                        x_21 = x_19[2]
                                                        x_22 = x_19[3]
                                                        true
                                                    end)))))
                            return_5 = let pattern = x_22, line = x_21
                                    tab()
                                    keyword("@case ")
                                    inline(pattern)
                                    case_ptr = ptr + 1
                                    case_ptr <= length(stmts) || continue
                                    case_stmt = stmts[case_ptr]
                                    indent() do 
                                        while case_ptr <= length(stmts)
                                            case_stmt = stmts[case_ptr]
                                            if is_case(case_stmt)
                                                case_ptr -= 1
                                                break
                                            end
                                            tab()
                                            no_first_line_indent() do 
                                                p(case_stmt)
                                            end
                                            println()
                                            case_ptr += 1
                                        end
                                    end
                                    ptr = case_ptr
                                end
                            $(Expr(:symbolicgoto, Symbol("##final#1036_1")))
                        end
                        return_5 = let
                                p(stmt)
                                println()
                            end
                        $(Expr(:symbolicgoto, Symbol("##final#1036_1")))
                        (error)("matching non-exhaustive, at #= none:203 =#")
                        $(Expr(:symboliclabel, Symbol("##final#1036_1")))
                        return_5
                    end
                    ptr += 1
                end
            end
            println()
            tab()
            keyword("end")
        end
        cache_6 = nothing
        x_23 = ex
        if x_23 isa Expr
            if begin
                        if cache_6 === nothing
                            cache_6 = Some((x_23.head, x_23.args))
                        end
                        x_24 = cache_6.value
                        x_24 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_24[1] == :block && (begin
                                x_25 = x_24[2]
                                x_25 isa AbstractArray
                            end && ((ndims(x_25) === 1 && length(x_25) >= 0) && begin
                                    x_26 = (SubArray)(x_25, (1:length(x_25),))
                                    true
                                end)))
                stmts = x_26
                return_6 = begin
                        leading_tab()
                        show_begin_end = if p.always_begin_end
                                true
                            else
                                !(is_root())
                            end
                        if show_begin_end
                            if p.state.quoted
                                keyword("quote")
                            else
                                keyword("begin")
                            end
                            println()
                        end
                        indent(size = if show_begin_end
                                    4
                                else
                                    0
                                end, level = 0) do 
                            print_stmts(stmts; leading_indent = show_begin_end)
                        end
                        show_begin_end && begin
                                println()
                                tab()
                                keyword("end")
                            end
                    end
                $(Expr(:symbolicgoto, Symbol("##final#1046_1")))
            end
            if begin
                        x_27 = cache_6.value
                        x_27 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_27[1] == :quote && (begin
                                x_28 = x_27[2]
                                x_28 isa AbstractArray
                            end && (length(x_28) === 1 && (begin
                                        cache_7 = nothing
                                        x_29 = x_28[1]
                                        x_29 isa Expr
                                    end && (begin
                                            if cache_7 === nothing
                                                cache_7 = Some((x_29.head, x_29.args))
                                            end
                                            x_30 = cache_7.value
                                            x_30 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                        end && (x_30[1] == :block && (begin
                                                    x_31 = x_30[2]
                                                    x_31 isa AbstractArray
                                                end && ((ndims(x_31) === 1 && length(x_31) >= 0) && begin
                                                        x_32 = (SubArray)(x_31, (1:length(x_31),))
                                                        let stmts = x_32
                                                            is_root()
                                                        end
                                                    end))))))))
                stmts = x_32
                return_6 = begin
                        leading_tab()
                        keyword("quote")
                        println()
                        indent(size = 4) do 
                            print_stmts(stmts)
                        end
                        println()
                        tab()
                        keyword("end")
                    end
                $(Expr(:symbolicgoto, Symbol("##final#1046_1")))
            end
            if begin
                        x_33 = cache_6.value
                        x_33 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_33[1] == :quote && (begin
                                x_34 = x_33[2]
                                x_34 isa AbstractArray
                            end && (length(x_34) === 1 && (begin
                                        cache_8 = nothing
                                        x_35 = x_34[1]
                                        x_35 isa Expr
                                    end && (begin
                                            if cache_8 === nothing
                                                cache_8 = Some((x_35.head, x_35.args))
                                            end
                                            x_36 = cache_8.value
                                            x_36 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                        end && (x_36[1] == :block && (begin
                                                    x_37 = x_36[2]
                                                    x_37 isa AbstractArray
                                                end && ((ndims(x_37) === 1 && length(x_37) >= 0) && begin
                                                        x_38 = (SubArray)(x_37, (1:length(x_37),))
                                                        true
                                                    end))))))))
                stmts = x_38
                return_6 = begin
                        leading_tab()
                        keyword("quote")
                        println()
                        indent(size = if p.state.quoted
                                    4
                                else
                                    0
                                end) do 
                            p.state.quoted && begin
                                    tab()
                                    keyword("quote")
                                    println()
                                end
                            indent() do 
                                quoted() do 
                                    print_stmts(stmts; leading_indent = !(is_root()))
                                end
                            end
                            p.state.quoted && begin
                                    println()
                                    tab()
                                    keyword("end")
                                end
                        end
                        println()
                        tab()
                        keyword("end")
                    end
                $(Expr(:symbolicgoto, Symbol("##final#1046_1")))
            end
            if begin
                        x_39 = cache_6.value
                        x_39 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_39[1] == :quote && (begin
                                x_40 = x_39[2]
                                x_40 isa AbstractArray
                            end && (length(x_40) === 1 && begin
                                    x_41 = x_40[1]
                                    true
                                end)))
                code = x_41
                return_6 = begin
                        is_root() || begin
                                leading_tab()
                                keyword("quote")
                                println()
                            end
                        indent(size = if is_root()
                                    0
                                else
                                    4
                                end) do 
                            quoted() do 
                                tab()
                                no_first_line_indent() do 
                                    p(code)
                                end
                            end
                        end
                        is_root() || begin
                                println()
                                tab()
                                keyword("end")
                            end
                    end
                $(Expr(:symbolicgoto, Symbol("##final#1046_1")))
            end
            if begin
                        x_42 = cache_6.value
                        x_42 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_42[1] == :let && (begin
                                x_43 = x_42[2]
                                x_43 isa AbstractArray
                            end && (length(x_43) === 2 && (begin
                                        cache_9 = nothing
                                        x_44 = x_43[1]
                                        x_44 isa Expr
                                    end && (begin
                                            if cache_9 === nothing
                                                cache_9 = Some((x_44.head, x_44.args))
                                            end
                                            x_45 = cache_9.value
                                            x_45 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                        end && (x_45[1] == :block && (begin
                                                    x_46 = x_45[2]
                                                    x_46 isa AbstractArray
                                                end && ((ndims(x_46) === 1 && length(x_46) >= 0) && (begin
                                                            x_47 = (SubArray)(x_46, (1:length(x_46),))
                                                            cache_10 = nothing
                                                            x_48 = x_43[2]
                                                            x_48 isa Expr
                                                        end && (begin
                                                                if cache_10 === nothing
                                                                    cache_10 = Some((x_48.head, x_48.args))
                                                                end
                                                                x_49 = cache_10.value
                                                                x_49 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                            end && (x_49[1] == :block && (begin
                                                                        x_50 = x_49[2]
                                                                        x_50 isa AbstractArray
                                                                    end && ((ndims(x_50) === 1 && length(x_50) >= 0) && begin
                                                                            x_51 = (SubArray)(x_50, (1:length(x_50),))
                                                                            true
                                                                        end)))))))))))))
                args = x_47
                stmts = x_51
                return_6 = begin
                        leading_tab()
                        keyword("let ")
                        inline(args...)
                        println()
                        indent() do 
                            print_stmts(stmts)
                        end
                        println()
                        keyword("end")
                    end
                $(Expr(:symbolicgoto, Symbol("##final#1046_1")))
            end
            if begin
                        x_52 = cache_6.value
                        x_52 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_52[1] == :if && (begin
                                x_53 = x_52[2]
                                x_53 isa AbstractArray
                            end && (length(x_53) === 2 && begin
                                    x_54 = x_53[1]
                                    x_55 = x_53[2]
                                    true
                                end)))
                cond = x_54
                body = x_55
                return_6 = begin
                        print_if(cond, body)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#1046_1")))
            end
            if begin
                        x_56 = cache_6.value
                        x_56 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_56[1] == :if && (begin
                                x_57 = x_56[2]
                                x_57 isa AbstractArray
                            end && (length(x_57) === 3 && begin
                                    x_58 = x_57[1]
                                    x_59 = x_57[2]
                                    x_60 = x_57[3]
                                    true
                                end)))
                cond = x_58
                body = x_59
                otherwise = x_60
                return_6 = begin
                        print_if(cond, body, otherwise)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#1046_1")))
            end
            if begin
                        x_61 = cache_6.value
                        x_61 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_61[1] == :elseif && (begin
                                x_62 = x_61[2]
                                x_62 isa AbstractArray
                            end && (length(x_62) === 2 && (begin
                                        cache_11 = nothing
                                        x_63 = x_62[1]
                                        x_63 isa Expr
                                    end && (begin
                                            if cache_11 === nothing
                                                cache_11 = Some((x_63.head, x_63.args))
                                            end
                                            x_64 = cache_11.value
                                            x_64 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                        end && (x_64[1] == :block && (begin
                                                    x_65 = x_64[2]
                                                    x_65 isa AbstractArray
                                                end && (length(x_65) === 2 && begin
                                                        x_66 = x_65[1]
                                                        x_67 = x_65[2]
                                                        x_68 = x_62[2]
                                                        true
                                                    end))))))))
                line = x_66
                cond = x_67
                body = x_68
                return_6 = begin
                        print_elseif(cond, body, line)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#1046_1")))
            end
            if begin
                        x_69 = cache_6.value
                        x_69 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_69[1] == :elseif && (begin
                                x_70 = x_69[2]
                                x_70 isa AbstractArray
                            end && (length(x_70) === 2 && begin
                                    x_71 = x_70[1]
                                    x_72 = x_70[2]
                                    true
                                end)))
                cond = x_71
                body = x_72
                return_6 = begin
                        print_elseif(cond, body)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#1046_1")))
            end
            if begin
                        x_73 = cache_6.value
                        x_73 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_73[1] == :elseif && (begin
                                x_74 = x_73[2]
                                x_74 isa AbstractArray
                            end && (length(x_74) === 3 && (begin
                                        cache_12 = nothing
                                        x_75 = x_74[1]
                                        x_75 isa Expr
                                    end && (begin
                                            if cache_12 === nothing
                                                cache_12 = Some((x_75.head, x_75.args))
                                            end
                                            x_76 = cache_12.value
                                            x_76 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                        end && (x_76[1] == :block && (begin
                                                    x_77 = x_76[2]
                                                    x_77 isa AbstractArray
                                                end && (length(x_77) === 2 && begin
                                                        x_78 = x_77[1]
                                                        x_79 = x_77[2]
                                                        x_80 = x_74[2]
                                                        x_81 = x_74[3]
                                                        true
                                                    end))))))))
                line = x_78
                cond = x_79
                body = x_80
                otherwise = x_81
                return_6 = begin
                        print_elseif(cond, body, line, otherwise)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#1046_1")))
            end
            if begin
                        x_82 = cache_6.value
                        x_82 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_82[1] == :elseif && (begin
                                x_83 = x_82[2]
                                x_83 isa AbstractArray
                            end && (length(x_83) === 3 && begin
                                    x_84 = x_83[1]
                                    x_85 = x_83[2]
                                    x_86 = x_83[3]
                                    true
                                end)))
                cond = x_84
                body = x_85
                otherwise = x_86
                return_6 = begin
                        print_elseif(cond, body, nothing, otherwise)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#1046_1")))
            end
            if begin
                        x_87 = cache_6.value
                        x_87 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_87[1] == :for && (begin
                                x_88 = x_87[2]
                                x_88 isa AbstractArray
                            end && (length(x_88) === 2 && begin
                                    x_89 = x_88[1]
                                    x_90 = x_88[2]
                                    true
                                end)))
                body = x_90
                iteration = x_89
                return_6 = begin
                        leading_tab()
                        keyword("for ")
                        inline(split_body(iteration)...)
                        println()
                        stmts = split_body(body)
                        indent() do 
                            print_stmts(stmts)
                        end
                        println()
                        tab()
                        keyword("end")
                    end
                $(Expr(:symbolicgoto, Symbol("##final#1046_1")))
            end
            if begin
                        x_91 = cache_6.value
                        x_91 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_91[1] == :while && (begin
                                x_92 = x_91[2]
                                x_92 isa AbstractArray
                            end && (length(x_92) === 2 && begin
                                    x_93 = x_92[1]
                                    x_94 = x_92[2]
                                    true
                                end)))
                cond = x_93
                body = x_94
                return_6 = begin
                        leading_tab()
                        keyword("while ")
                        inline(cond)
                        println()
                        stmts = split_body(body)
                        indent() do 
                            print_stmts(stmts)
                        end
                        println()
                        tab()
                        keyword("end")
                    end
                $(Expr(:symbolicgoto, Symbol("##final#1046_1")))
            end
            if begin
                        x_95 = cache_6.value
                        x_95 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_95[1] == :(=) && (begin
                                x_96 = x_95[2]
                                x_96 isa AbstractArray
                            end && (length(x_96) === 2 && (begin
                                        x_97 = x_96[1]
                                        cache_13 = nothing
                                        x_98 = x_96[2]
                                        x_98 isa Expr
                                    end && (begin
                                            if cache_13 === nothing
                                                cache_13 = Some((x_98.head, x_98.args))
                                            end
                                            x_99 = cache_13.value
                                            x_99 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                        end && (x_99[1] == :block && (begin
                                                    x_100 = x_99[2]
                                                    x_100 isa AbstractArray
                                                end && (length(x_100) === 2 && (begin
                                                            x_101 = x_100[1]
                                                            cache_14 = nothing
                                                            x_102 = x_100[2]
                                                            x_102 isa Expr
                                                        end && (begin
                                                                if cache_14 === nothing
                                                                    cache_14 = Some((x_102.head, x_102.args))
                                                                end
                                                                x_103 = cache_14.value
                                                                x_103 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                            end && (x_103[1] == :if && (begin
                                                                        x_104 = x_103[2]
                                                                        x_104 isa AbstractArray
                                                                    end && ((ndims(x_104) === 1 && length(x_104) >= 0) && let line = x_101, lhs = x_97
                                                                            is_line_no(line)
                                                                        end)))))))))))))
                line = x_101
                lhs = x_97
                return_6 = begin
                        leading_tab()
                        inline(lhs)
                        keyword(" = ")
                        inline(line)
                        p(ex.args[2])
                    end
                $(Expr(:symbolicgoto, Symbol("##final#1046_1")))
            end
            if begin
                        x_105 = cache_6.value
                        x_105 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_105[1] == :(=) && (begin
                                x_106 = x_105[2]
                                x_106 isa AbstractArray
                            end && (length(x_106) === 2 && (begin
                                        x_107 = x_106[1]
                                        cache_15 = nothing
                                        x_108 = x_106[2]
                                        x_108 isa Expr
                                    end && (begin
                                            if cache_15 === nothing
                                                cache_15 = Some((x_108.head, x_108.args))
                                            end
                                            x_109 = cache_15.value
                                            x_109 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                        end && (x_109[1] == :block && (begin
                                                    x_110 = x_109[2]
                                                    x_110 isa AbstractArray
                                                end && (length(x_110) === 2 && begin
                                                        x_111 = x_110[1]
                                                        x_112 = x_110[2]
                                                        let rhs = x_112, line = x_111, lhs = x_107
                                                            is_line_no(line)
                                                        end
                                                    end))))))))
                rhs = x_112
                line = x_111
                lhs = x_107
                return_6 = begin
                        leading_tab()
                        inline(ex)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#1046_1")))
            end
            if begin
                        x_113 = cache_6.value
                        x_113 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_113[1] == :(=) && (begin
                                x_114 = x_113[2]
                                x_114 isa AbstractArray
                            end && (length(x_114) === 2 && begin
                                    x_115 = x_114[1]
                                    x_116 = x_114[2]
                                    true
                                end)))
                rhs = x_116
                lhs = x_115
                return_6 = begin
                        leading_tab()
                        inline(lhs)
                        print(" = ")
                        p(rhs)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#1046_1")))
            end
            if begin
                        x_117 = cache_6.value
                        x_117 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_117[1] == :function && (begin
                                x_118 = x_117[2]
                                x_118 isa AbstractArray
                            end && (length(x_118) === 2 && begin
                                    x_119 = x_118[1]
                                    x_120 = x_118[2]
                                    true
                                end)))
                call = x_119
                body = x_120
                return_6 = begin
                        print_function(:function, call, body)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#1046_1")))
            end
            if begin
                        x_121 = cache_6.value
                        x_121 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_121[1] == :-> && (begin
                                x_122 = x_121[2]
                                x_122 isa AbstractArray
                            end && (length(x_122) === 2 && begin
                                    x_123 = x_122[1]
                                    x_124 = x_122[2]
                                    true
                                end)))
                call = x_123
                body = x_124
                return_6 = begin
                        leading_tab()
                        inline(call)
                        keyword(" -> ")
                        p(body)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#1046_1")))
            end
            if begin
                        x_125 = cache_6.value
                        x_125 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_125[1] == :macro && (begin
                                x_126 = x_125[2]
                                x_126 isa AbstractArray
                            end && (length(x_126) === 2 && begin
                                    x_127 = x_126[1]
                                    x_128 = x_126[2]
                                    true
                                end)))
                call = x_127
                body = x_128
                return_6 = begin
                        print_function(:macro, call, body)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#1046_1")))
            end
            if begin
                        x_129 = cache_6.value
                        x_129 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_129[1] == :macrocall && (begin
                                x_130 = x_129[2]
                                x_130 isa AbstractArray
                            end && (length(x_130) === 4 && (begin
                                        x_131 = x_130[1]
                                        x_131 == Symbol("@switch")
                                    end && (begin
                                            x_132 = x_130[2]
                                            x_133 = x_130[3]
                                            cache_16 = nothing
                                            x_134 = x_130[4]
                                            x_134 isa Expr
                                        end && (begin
                                                if cache_16 === nothing
                                                    cache_16 = Some((x_134.head, x_134.args))
                                                end
                                                x_135 = cache_16.value
                                                x_135 isa Tuple{Symbol, var2} where var2<:AbstractArray
                                            end && (x_135[1] == :block && (begin
                                                        x_136 = x_135[2]
                                                        x_136 isa AbstractArray
                                                    end && ((ndims(x_136) === 1 && length(x_136) >= 0) && begin
                                                            x_137 = (SubArray)(x_136, (1:length(x_136),))
                                                            true
                                                        end)))))))))
                item = x_133
                line = x_132
                stmts = x_137
                return_6 = begin
                        print_switch(item, line, stmts)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#1046_1")))
            end
            if begin
                        x_138 = cache_6.value
                        x_138 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_138[1] == :macrocall && (begin
                                x_139 = x_138[2]
                                x_139 isa AbstractArray
                            end && (length(x_139) === 4 && (begin
                                        x_140 = x_139[1]
                                        x_140 == GlobalRef(Core, Symbol("@doc"))
                                    end && begin
                                        x_141 = x_139[2]
                                        x_142 = x_139[3]
                                        x_143 = x_139[4]
                                        true
                                    end))))
                line = x_141
                code = x_143
                doc = x_142
                return_6 = begin
                        leading_tab()
                        p.line && begin
                                inline(line)
                                println()
                            end
                        printstyled("\"\"\"\n", color = c.string)
                        for line = eachsplit(doc, '\n')
                            tab()
                            printstyled(line, color = c.string)
                            println()
                        end
                        tab()
                        printstyled("\"\"\"\n", color = c.string)
                        tab()
                        no_first_line_indent() do 
                            p(code)
                        end
                    end
                $(Expr(:symbolicgoto, Symbol("##final#1046_1")))
            end
            if begin
                        x_144 = cache_6.value
                        x_144 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_144[1] == :macrocall && (begin
                                x_145 = x_144[2]
                                x_145 isa AbstractArray
                            end && ((ndims(x_145) === 1 && length(x_145) >= 2) && begin
                                    x_146 = x_145[1]
                                    x_147 = x_145[2]
                                    x_148 = (SubArray)(x_145, (3:length(x_145),))
                                    true
                                end)))
                line = x_147
                name = x_146
                args = x_148
                return_6 = begin
                        print_macrocall(name, line, args)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#1046_1")))
            end
            if begin
                        x_149 = cache_6.value
                        x_149 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_149[1] == :struct && (begin
                                x_150 = x_149[2]
                                x_150 isa AbstractArray
                            end && (length(x_150) === 3 && begin
                                    x_151 = x_150[1]
                                    x_152 = x_150[2]
                                    x_153 = x_150[3]
                                    true
                                end)))
                ismutable = x_151
                body = x_153
                head = x_152
                return_6 = begin
                        stmts = split_body(body)
                        leading_tab()
                        keyword(if ismutable
                                "mutable struct"
                            else
                                "struct"
                            end)
                        print(" ")
                        inline(head)
                        println()
                        indent(level = 0) do 
                            print_stmts(stmts)
                        end
                        println()
                        tab()
                        keyword("end")
                    end
                $(Expr(:symbolicgoto, Symbol("##final#1046_1")))
            end
            if begin
                        x_154 = cache_6.value
                        x_154 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_154[1] == :try && (begin
                                x_155 = x_154[2]
                                x_155 isa AbstractArray
                            end && (length(x_155) === 3 && begin
                                    x_156 = x_155[1]
                                    x_157 = x_155[2]
                                    x_158 = x_155[3]
                                    true
                                end)))
                catch_vars = x_157
                catch_body = x_158
                try_body = x_156
                return_6 = begin
                        print_try(try_body)
                        print_catch(catch_body, catch_vars)
                        println()
                        tab()
                        keyword("end")
                    end
                $(Expr(:symbolicgoto, Symbol("##final#1046_1")))
            end
            if begin
                        x_159 = cache_6.value
                        x_159 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_159[1] == :try && (begin
                                x_160 = x_159[2]
                                x_160 isa AbstractArray
                            end && (length(x_160) === 4 && begin
                                    x_161 = x_160[1]
                                    x_162 = x_160[2]
                                    x_163 = x_160[3]
                                    x_164 = x_160[4]
                                    true
                                end)))
                catch_vars = x_162
                catch_body = x_163
                try_body = x_161
                finally_body = x_164
                return_6 = begin
                        print_try(try_body)
                        print_catch(catch_body, catch_vars)
                        print_finally(finally_body)
                        println()
                        tab()
                        keyword("end")
                    end
                $(Expr(:symbolicgoto, Symbol("##final#1046_1")))
            end
            if begin
                        x_165 = cache_6.value
                        x_165 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_165[1] == :try && (begin
                                x_166 = x_165[2]
                                x_166 isa AbstractArray
                            end && (length(x_166) === 5 && begin
                                    x_167 = x_166[1]
                                    x_168 = x_166[2]
                                    x_169 = x_166[3]
                                    x_170 = x_166[4]
                                    x_171 = x_166[5]
                                    true
                                end)))
                catch_vars = x_168
                catch_body = x_169
                try_body = x_167
                finally_body = x_170
                else_body = x_171
                return_6 = begin
                        print_try(try_body)
                        print_catch(catch_body, catch_vars)
                        stmts = split_body(else_body)
                        println()
                        tab()
                        keyword("else")
                        println()
                        indent() do 
                            print_stmts(stmts)
                        end
                        print_finally(finally_body)
                        println()
                        tab()
                        keyword("end")
                    end
                $(Expr(:symbolicgoto, Symbol("##final#1046_1")))
            end
            if begin
                        x_172 = cache_6.value
                        x_172 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_172[1] == :module && (begin
                                x_173 = x_172[2]
                                x_173 isa AbstractArray
                            end && (length(x_173) === 3 && begin
                                    x_174 = x_173[1]
                                    x_175 = x_173[2]
                                    x_176 = x_173[3]
                                    true
                                end)))
                name = x_175
                body = x_176
                notbare = x_174
                return_6 = begin
                        leading_tab()
                        keyword(if notbare
                                "module "
                            else
                                "baremodule "
                            end)
                        inline(name)
                        println()
                        stmts = split_body(body)
                        indent() do 
                            print_stmts(stmts)
                        end
                        println()
                        tab()
                        keyword("end")
                    end
                $(Expr(:symbolicgoto, Symbol("##final#1046_1")))
            end
            if begin
                        x_177 = cache_6.value
                        x_177 isa Tuple{Symbol, var2} where var2<:AbstractArray
                    end && (x_177[1] == :const && (begin
                                x_178 = x_177[2]
                                x_178 isa AbstractArray
                            end && (length(x_178) === 1 && begin
                                    x_179 = x_178[1]
                                    true
                                end)))
                code = x_179
                return_6 = begin
                        leading_tab()
                        keyword("const ")
                        p(code)
                    end
                $(Expr(:symbolicgoto, Symbol("##final#1046_1")))
            end
        end
        return_6 = begin
                inline(ex)
            end
        $(Expr(:symbolicgoto, Symbol("##final#1046_1")))
        (error)("matching non-exhaustive, at #= none:235 =#")
        $(Expr(:symboliclabel, Symbol("##final#1046_1")))
        return_6
        return
    end
    #= none:410 =# Core.@doc "    print_expr([io::IO], ex; kw...)\n\nPrint a given expression. `ex` can be a `Expr` or a syntax type `JLExpr`.\n" print_expr(io::IO, ex; kw...) = begin
                (Printer(io; kw...))(ex)
            end
    print_expr(ex; kw...) = begin
            print_expr(stdout, ex; kw...)
        end
end
