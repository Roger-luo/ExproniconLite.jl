
    #= none:2 =# Base.@kwdef mutable struct PrinterState
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
        return nothing
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
                begin
                    var"##cache#1026" = nothing
                end
                var"##return#1023" = nothing
                var"##1025" = otherwise
                if var"##1025" isa Expr && (begin
                                if var"##cache#1026" === nothing
                                    var"##cache#1026" = Some(((var"##1025").head, (var"##1025").args))
                                end
                                var"##1027" = (var"##cache#1026").value
                                var"##1027" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1027"[1] == :block && (begin
                                        var"##1028" = var"##1027"[2]
                                        var"##1028" isa AbstractArray
                                    end && ((ndims(var"##1028") === 1 && length(var"##1028") >= 0) && begin
                                            var"##1029" = SubArray(var"##1028", (1:length(var"##1028"),))
                                            true
                                        end))))
                    var"##return#1023" = let stmts = var"##1029"
                            indent() do 
                                print_stmts(stmts)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1024#1030")))
                end
                begin
                    var"##return#1023" = let
                            indent() do 
                                tab()
                                no_first_line_indent() do 
                                    p(otherwise)
                                end
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1024#1030")))
                end
                error("matching non-exhaustive, at #= none:98 =#")
                $(Expr(:symboliclabel, Symbol("####final#1024#1030")))
                var"##return#1023"
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
        function print_try(body)
            body == false && return nothing
            stmts = split_body(body)
            leading_tab()
            keyword("try")
            println()
            indent() do 
                print_stmts(stmts)
            end
        end
        function print_catch(body, vars)
            body == false && return nothing
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
            body == false && return nothing
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
                        begin
                            var"##cache#1034" = nothing
                        end
                        var"##return#1031" = nothing
                        var"##1033" = stmt
                        if var"##1033" isa Expr && (begin
                                        if var"##cache#1034" === nothing
                                            var"##cache#1034" = Some(((var"##1033").head, (var"##1033").args))
                                        end
                                        var"##1035" = (var"##cache#1034").value
                                        var"##1035" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##1035"[1] == :macrocall && (begin
                                                var"##1036" = var"##1035"[2]
                                                var"##1036" isa AbstractArray
                                            end && ((ndims(var"##1036") === 1 && length(var"##1036") >= 1) && begin
                                                    var"##1037" = var"##1036"[1]
                                                    var"##1037" == Symbol("@case")
                                                end))))
                            var"##return#1031" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1032#1038")))
                        end
                        begin
                            var"##return#1031" = let
                                    false
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1032#1038")))
                        end
                        error("matching non-exhaustive, at #= none:181 =#")
                        $(Expr(:symboliclabel, Symbol("####final#1032#1038")))
                        var"##return#1031"
                    end
                end || return print_macrocall("@switch", line, (item, Expr(:block, stmts...)))
            is_case(stmt) = begin
                    let
                        begin
                            var"##cache#1042" = nothing
                        end
                        var"##return#1039" = nothing
                        var"##1041" = stmt
                        if var"##1041" isa Expr && (begin
                                        if var"##cache#1042" === nothing
                                            var"##cache#1042" = Some(((var"##1041").head, (var"##1041").args))
                                        end
                                        var"##1043" = (var"##cache#1042").value
                                        var"##1043" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##1043"[1] == :macrocall && (begin
                                                var"##1044" = var"##1043"[2]
                                                var"##1044" isa AbstractArray
                                            end && ((ndims(var"##1044") === 1 && length(var"##1044") >= 1) && begin
                                                    var"##1045" = var"##1044"[1]
                                                    var"##1045" == Symbol("@case")
                                                end))))
                            var"##return#1039" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1040#1046")))
                        end
                        begin
                            var"##return#1039" = let
                                    false
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1040#1046")))
                        end
                        error("matching non-exhaustive, at #= none:187 =#")
                        $(Expr(:symboliclabel, Symbol("####final#1040#1046")))
                        var"##return#1039"
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
                        begin
                            var"##cache#1050" = nothing
                        end
                        var"##return#1047" = nothing
                        var"##1049" = stmt
                        if var"##1049" isa Expr && (begin
                                        if var"##cache#1050" === nothing
                                            var"##cache#1050" = Some(((var"##1049").head, (var"##1049").args))
                                        end
                                        var"##1051" = (var"##cache#1050").value
                                        var"##1051" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##1051"[1] == :macrocall && (begin
                                                var"##1052" = var"##1051"[2]
                                                var"##1052" isa AbstractArray
                                            end && (length(var"##1052") === 3 && (begin
                                                        var"##1053" = var"##1052"[1]
                                                        var"##1053" == Symbol("@case")
                                                    end && begin
                                                        var"##1054" = var"##1052"[2]
                                                        var"##1055" = var"##1052"[3]
                                                        true
                                                    end)))))
                            var"##return#1047" = let pattern = var"##1055", line = var"##1054"
                                    tab()
                                    keyword("@case ")
                                    inline(pattern)
                                    println()
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
                            $(Expr(:symbolicgoto, Symbol("####final#1048#1056")))
                        end
                        begin
                            var"##return#1047" = let
                                    p(stmt)
                                    println()
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1048#1056")))
                        end
                        error("matching non-exhaustive, at #= none:197 =#")
                        $(Expr(:symboliclabel, Symbol("####final#1048#1056")))
                        var"##return#1047"
                    end
                    ptr += 1
                end
            end
            println()
            tab()
            keyword("end")
        end
        function print_multi_lines(s::AbstractString)
            buf = IOBuffer(s)
            line_buf = IOBuffer()
            while !(eof(buf))
                ch = read(buf, Char)
                if ch == '\n'
                    printstyled(String(take!(line_buf)), color = c.string)
                    println()
                    tab()
                else
                    ch in ('$',) && write(line_buf, '\\')
                    write(line_buf, ch)
                end
            end
            last_line = String(take!(line_buf))
            isempty(last_line) || printstyled(last_line, color = c.string)
        end
        begin
            begin
                var"##cache#1060" = nothing
            end
            var"##1059" = ex
            if var"##1059" isa Expr
                if begin
                            if var"##cache#1060" === nothing
                                var"##cache#1060" = Some(((var"##1059").head, (var"##1059").args))
                            end
                            var"##1061" = (var"##cache#1060").value
                            var"##1061" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1061"[1] == :string && (begin
                                    var"##1062" = var"##1061"[2]
                                    var"##1062" isa AbstractArray
                                end && ((ndims(var"##1062") === 1 && length(var"##1062") >= 0) && begin
                                        var"##1063" = SubArray(var"##1062", (1:length(var"##1062"),))
                                        true
                                    end)))
                    args = var"##1063"
                    var"##return#1057" = begin
                            leading_tab()
                            any((arg->begin
                                            arg isa AbstractString && occursin('\n', arg)
                                        end), args) || return inline(ex)
                            printstyled("\"\"\"\n", color = c.string)
                            tab()
                            for arg = args
                                if arg isa AbstractString
                                    print_multi_lines(arg)
                                elseif arg isa Symbol
                                    keyword("\$")
                                    inline(arg)
                                else
                                    keyword("\$")
                                    print("(")
                                    inline(arg)
                                    print(")")
                                end
                            end
                            printstyled("\"\"\"", color = c.string)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1058#1262")))
                end
                if begin
                            var"##1064" = (var"##cache#1060").value
                            var"##1064" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1064"[1] == :block && (begin
                                    var"##1065" = var"##1064"[2]
                                    var"##1065" isa AbstractArray
                                end && ((ndims(var"##1065") === 1 && length(var"##1065") >= 0) && begin
                                        var"##1066" = SubArray(var"##1065", (1:length(var"##1065"),))
                                        true
                                    end)))
                    stmts = var"##1066"
                    var"##return#1057" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1058#1262")))
                end
                if begin
                            var"##1067" = (var"##cache#1060").value
                            var"##1067" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1067"[1] == :quote && (begin
                                    var"##1068" = var"##1067"[2]
                                    var"##1068" isa AbstractArray
                                end && (length(var"##1068") === 1 && (begin
                                            begin
                                                var"##cache#1070" = nothing
                                            end
                                            var"##1069" = var"##1068"[1]
                                            var"##1069" isa Expr
                                        end && (begin
                                                if var"##cache#1070" === nothing
                                                    var"##cache#1070" = Some(((var"##1069").head, (var"##1069").args))
                                                end
                                                var"##1071" = (var"##cache#1070").value
                                                var"##1071" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1071"[1] == :block && (begin
                                                        var"##1072" = var"##1071"[2]
                                                        var"##1072" isa AbstractArray
                                                    end && ((ndims(var"##1072") === 1 && length(var"##1072") >= 0) && begin
                                                            var"##1073" = SubArray(var"##1072", (1:length(var"##1072"),))
                                                            let stmts = var"##1073"
                                                                is_root()
                                                            end
                                                        end))))))))
                    stmts = var"##1073"
                    var"##return#1057" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1058#1262")))
                end
                if begin
                            var"##1074" = (var"##cache#1060").value
                            var"##1074" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1074"[1] == :quote && (begin
                                    var"##1075" = var"##1074"[2]
                                    var"##1075" isa AbstractArray
                                end && (length(var"##1075") === 1 && (begin
                                            begin
                                                var"##cache#1077" = nothing
                                            end
                                            var"##1076" = var"##1075"[1]
                                            var"##1076" isa Expr
                                        end && (begin
                                                if var"##cache#1077" === nothing
                                                    var"##cache#1077" = Some(((var"##1076").head, (var"##1076").args))
                                                end
                                                var"##1078" = (var"##cache#1077").value
                                                var"##1078" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1078"[1] == :block && (begin
                                                        var"##1079" = var"##1078"[2]
                                                        var"##1079" isa AbstractArray
                                                    end && ((ndims(var"##1079") === 1 && length(var"##1079") >= 0) && begin
                                                            var"##1080" = SubArray(var"##1079", (1:length(var"##1079"),))
                                                            true
                                                        end))))))))
                    stmts = var"##1080"
                    var"##return#1057" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1058#1262")))
                end
                if begin
                            var"##1081" = (var"##cache#1060").value
                            var"##1081" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1081"[1] == :quote && (begin
                                    var"##1082" = var"##1081"[2]
                                    var"##1082" isa AbstractArray
                                end && (length(var"##1082") === 1 && begin
                                        var"##1083" = var"##1082"[1]
                                        true
                                    end)))
                    code = var"##1083"
                    var"##return#1057" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1058#1262")))
                end
                if begin
                            var"##1084" = (var"##cache#1060").value
                            var"##1084" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1084"[1] == :let && (begin
                                    var"##1085" = var"##1084"[2]
                                    var"##1085" isa AbstractArray
                                end && (length(var"##1085") === 2 && (begin
                                            begin
                                                var"##cache#1087" = nothing
                                            end
                                            var"##1086" = var"##1085"[1]
                                            var"##1086" isa Expr
                                        end && (begin
                                                if var"##cache#1087" === nothing
                                                    var"##cache#1087" = Some(((var"##1086").head, (var"##1086").args))
                                                end
                                                var"##1088" = (var"##cache#1087").value
                                                var"##1088" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1088"[1] == :block && (begin
                                                        var"##1089" = var"##1088"[2]
                                                        var"##1089" isa AbstractArray
                                                    end && ((ndims(var"##1089") === 1 && length(var"##1089") >= 0) && (begin
                                                                var"##1090" = SubArray(var"##1089", (1:length(var"##1089"),))
                                                                begin
                                                                    var"##cache#1092" = nothing
                                                                end
                                                                var"##1091" = var"##1085"[2]
                                                                var"##1091" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1092" === nothing
                                                                        var"##cache#1092" = Some(((var"##1091").head, (var"##1091").args))
                                                                    end
                                                                    var"##1093" = (var"##cache#1092").value
                                                                    var"##1093" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1093"[1] == :block && (begin
                                                                            var"##1094" = var"##1093"[2]
                                                                            var"##1094" isa AbstractArray
                                                                        end && ((ndims(var"##1094") === 1 && length(var"##1094") >= 0) && begin
                                                                                var"##1095" = SubArray(var"##1094", (1:length(var"##1094"),))
                                                                                true
                                                                            end)))))))))))))
                    args = var"##1090"
                    stmts = var"##1095"
                    var"##return#1057" = begin
                            leading_tab()
                            keyword("let ")
                            isempty(args) || inline(args...)
                            println()
                            indent() do 
                                print_stmts(stmts)
                            end
                            println()
                            tab()
                            keyword("end")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1058#1262")))
                end
                if begin
                            var"##1096" = (var"##cache#1060").value
                            var"##1096" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1096"[1] == :if && (begin
                                    var"##1097" = var"##1096"[2]
                                    var"##1097" isa AbstractArray
                                end && (length(var"##1097") === 2 && begin
                                        var"##1098" = var"##1097"[1]
                                        var"##1099" = var"##1097"[2]
                                        true
                                    end)))
                    cond = var"##1098"
                    body = var"##1099"
                    var"##return#1057" = begin
                            print_if(cond, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1058#1262")))
                end
                if begin
                            var"##1100" = (var"##cache#1060").value
                            var"##1100" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1100"[1] == :if && (begin
                                    var"##1101" = var"##1100"[2]
                                    var"##1101" isa AbstractArray
                                end && (length(var"##1101") === 3 && begin
                                        var"##1102" = var"##1101"[1]
                                        var"##1103" = var"##1101"[2]
                                        var"##1104" = var"##1101"[3]
                                        true
                                    end)))
                    cond = var"##1102"
                    body = var"##1103"
                    otherwise = var"##1104"
                    var"##return#1057" = begin
                            print_if(cond, body, otherwise)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1058#1262")))
                end
                if begin
                            var"##1105" = (var"##cache#1060").value
                            var"##1105" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1105"[1] == :elseif && (begin
                                    var"##1106" = var"##1105"[2]
                                    var"##1106" isa AbstractArray
                                end && (length(var"##1106") === 2 && (begin
                                            begin
                                                var"##cache#1108" = nothing
                                            end
                                            var"##1107" = var"##1106"[1]
                                            var"##1107" isa Expr
                                        end && (begin
                                                if var"##cache#1108" === nothing
                                                    var"##cache#1108" = Some(((var"##1107").head, (var"##1107").args))
                                                end
                                                var"##1109" = (var"##cache#1108").value
                                                var"##1109" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1109"[1] == :block && (begin
                                                        var"##1110" = var"##1109"[2]
                                                        var"##1110" isa AbstractArray
                                                    end && (length(var"##1110") === 2 && begin
                                                            var"##1111" = var"##1110"[1]
                                                            var"##1112" = var"##1110"[2]
                                                            var"##1113" = var"##1106"[2]
                                                            true
                                                        end))))))))
                    line = var"##1111"
                    cond = var"##1112"
                    body = var"##1113"
                    var"##return#1057" = begin
                            print_elseif(cond, body, line)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1058#1262")))
                end
                if begin
                            var"##1114" = (var"##cache#1060").value
                            var"##1114" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1114"[1] == :elseif && (begin
                                    var"##1115" = var"##1114"[2]
                                    var"##1115" isa AbstractArray
                                end && (length(var"##1115") === 2 && begin
                                        var"##1116" = var"##1115"[1]
                                        var"##1117" = var"##1115"[2]
                                        true
                                    end)))
                    cond = var"##1116"
                    body = var"##1117"
                    var"##return#1057" = begin
                            print_elseif(cond, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1058#1262")))
                end
                if begin
                            var"##1118" = (var"##cache#1060").value
                            var"##1118" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1118"[1] == :elseif && (begin
                                    var"##1119" = var"##1118"[2]
                                    var"##1119" isa AbstractArray
                                end && (length(var"##1119") === 3 && (begin
                                            begin
                                                var"##cache#1121" = nothing
                                            end
                                            var"##1120" = var"##1119"[1]
                                            var"##1120" isa Expr
                                        end && (begin
                                                if var"##cache#1121" === nothing
                                                    var"##cache#1121" = Some(((var"##1120").head, (var"##1120").args))
                                                end
                                                var"##1122" = (var"##cache#1121").value
                                                var"##1122" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1122"[1] == :block && (begin
                                                        var"##1123" = var"##1122"[2]
                                                        var"##1123" isa AbstractArray
                                                    end && (length(var"##1123") === 2 && begin
                                                            var"##1124" = var"##1123"[1]
                                                            var"##1125" = var"##1123"[2]
                                                            var"##1126" = var"##1119"[2]
                                                            var"##1127" = var"##1119"[3]
                                                            true
                                                        end))))))))
                    line = var"##1124"
                    cond = var"##1125"
                    body = var"##1126"
                    otherwise = var"##1127"
                    var"##return#1057" = begin
                            print_elseif(cond, body, line, otherwise)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1058#1262")))
                end
                if begin
                            var"##1128" = (var"##cache#1060").value
                            var"##1128" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1128"[1] == :elseif && (begin
                                    var"##1129" = var"##1128"[2]
                                    var"##1129" isa AbstractArray
                                end && (length(var"##1129") === 3 && begin
                                        var"##1130" = var"##1129"[1]
                                        var"##1131" = var"##1129"[2]
                                        var"##1132" = var"##1129"[3]
                                        true
                                    end)))
                    cond = var"##1130"
                    body = var"##1131"
                    otherwise = var"##1132"
                    var"##return#1057" = begin
                            print_elseif(cond, body, nothing, otherwise)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1058#1262")))
                end
                if begin
                            var"##1133" = (var"##cache#1060").value
                            var"##1133" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1133"[1] == :for && (begin
                                    var"##1134" = var"##1133"[2]
                                    var"##1134" isa AbstractArray
                                end && (length(var"##1134") === 2 && begin
                                        var"##1135" = var"##1134"[1]
                                        var"##1136" = var"##1134"[2]
                                        true
                                    end)))
                    body = var"##1136"
                    iteration = var"##1135"
                    var"##return#1057" = begin
                            leading_tab()
                            inline.state.loop_iterator = true
                            preced = inline.state.precedence
                            inline.state.precedence = 0
                            keyword("for ")
                            inline(split_body(iteration)...)
                            println()
                            inline.state.loop_iterator = false
                            inline.state.precedence = preced
                            stmts = split_body(body)
                            indent() do 
                                print_stmts(stmts)
                            end
                            println()
                            tab()
                            keyword("end")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1058#1262")))
                end
                if begin
                            var"##1137" = (var"##cache#1060").value
                            var"##1137" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1137"[1] == :while && (begin
                                    var"##1138" = var"##1137"[2]
                                    var"##1138" isa AbstractArray
                                end && (length(var"##1138") === 2 && begin
                                        var"##1139" = var"##1138"[1]
                                        var"##1140" = var"##1138"[2]
                                        true
                                    end)))
                    cond = var"##1139"
                    body = var"##1140"
                    var"##return#1057" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1058#1262")))
                end
                if begin
                            var"##1141" = (var"##cache#1060").value
                            var"##1141" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1141"[1] == :(=) && (begin
                                    var"##1142" = var"##1141"[2]
                                    var"##1142" isa AbstractArray
                                end && (length(var"##1142") === 2 && (begin
                                            var"##1143" = var"##1142"[1]
                                            begin
                                                var"##cache#1145" = nothing
                                            end
                                            var"##1144" = var"##1142"[2]
                                            var"##1144" isa Expr
                                        end && (begin
                                                if var"##cache#1145" === nothing
                                                    var"##cache#1145" = Some(((var"##1144").head, (var"##1144").args))
                                                end
                                                var"##1146" = (var"##cache#1145").value
                                                var"##1146" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1146"[1] == :block && (begin
                                                        var"##1147" = var"##1146"[2]
                                                        var"##1147" isa AbstractArray
                                                    end && (length(var"##1147") === 2 && (begin
                                                                var"##1148" = var"##1147"[1]
                                                                begin
                                                                    var"##cache#1150" = nothing
                                                                end
                                                                var"##1149" = var"##1147"[2]
                                                                var"##1149" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1150" === nothing
                                                                        var"##cache#1150" = Some(((var"##1149").head, (var"##1149").args))
                                                                    end
                                                                    var"##1151" = (var"##cache#1150").value
                                                                    var"##1151" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1151"[1] == :if && (begin
                                                                            var"##1152" = var"##1151"[2]
                                                                            var"##1152" isa AbstractArray
                                                                        end && ((ndims(var"##1152") === 1 && length(var"##1152") >= 0) && let line = var"##1148", lhs = var"##1143"
                                                                                is_line_no(line)
                                                                            end)))))))))))))
                    line = var"##1148"
                    lhs = var"##1143"
                    var"##return#1057" = begin
                            leading_tab()
                            inline(lhs)
                            keyword(" = ")
                            inline(line)
                            p(ex.args[2])
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1058#1262")))
                end
                if begin
                            var"##1153" = (var"##cache#1060").value
                            var"##1153" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1153"[1] == :(=) && (begin
                                    var"##1154" = var"##1153"[2]
                                    var"##1154" isa AbstractArray
                                end && (length(var"##1154") === 2 && (begin
                                            var"##1155" = var"##1154"[1]
                                            begin
                                                var"##cache#1157" = nothing
                                            end
                                            var"##1156" = var"##1154"[2]
                                            var"##1156" isa Expr
                                        end && (begin
                                                if var"##cache#1157" === nothing
                                                    var"##cache#1157" = Some(((var"##1156").head, (var"##1156").args))
                                                end
                                                var"##1158" = (var"##cache#1157").value
                                                var"##1158" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1158"[1] == :block && (begin
                                                        var"##1159" = var"##1158"[2]
                                                        var"##1159" isa AbstractArray
                                                    end && (length(var"##1159") === 2 && begin
                                                            var"##1160" = var"##1159"[1]
                                                            var"##1161" = var"##1159"[2]
                                                            let rhs = var"##1161", line = var"##1160", lhs = var"##1155"
                                                                is_line_no(line)
                                                            end
                                                        end))))))))
                    rhs = var"##1161"
                    line = var"##1160"
                    lhs = var"##1155"
                    var"##return#1057" = begin
                            leading_tab()
                            inline(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1058#1262")))
                end
                if begin
                            var"##1162" = (var"##cache#1060").value
                            var"##1162" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1162"[1] == :(=) && (begin
                                    var"##1163" = var"##1162"[2]
                                    var"##1163" isa AbstractArray
                                end && (length(var"##1163") === 2 && begin
                                        var"##1164" = var"##1163"[1]
                                        var"##1165" = var"##1163"[2]
                                        true
                                    end)))
                    rhs = var"##1165"
                    lhs = var"##1164"
                    var"##return#1057" = begin
                            leading_tab()
                            inline(lhs)
                            print(" = ")
                            p(rhs)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1058#1262")))
                end
                if begin
                            var"##1166" = (var"##cache#1060").value
                            var"##1166" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1166"[1] == :function && (begin
                                    var"##1167" = var"##1166"[2]
                                    var"##1167" isa AbstractArray
                                end && (length(var"##1167") === 2 && begin
                                        var"##1168" = var"##1167"[1]
                                        var"##1169" = var"##1167"[2]
                                        true
                                    end)))
                    call = var"##1168"
                    body = var"##1169"
                    var"##return#1057" = begin
                            print_function(:function, call, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1058#1262")))
                end
                if begin
                            var"##1170" = (var"##cache#1060").value
                            var"##1170" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1170"[1] == :-> && (begin
                                    var"##1171" = var"##1170"[2]
                                    var"##1171" isa AbstractArray
                                end && (length(var"##1171") === 2 && begin
                                        var"##1172" = var"##1171"[1]
                                        var"##1173" = var"##1171"[2]
                                        true
                                    end)))
                    call = var"##1172"
                    body = var"##1173"
                    var"##return#1057" = begin
                            leading_tab()
                            inline(call)
                            keyword(" -> ")
                            p(body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1058#1262")))
                end
                if begin
                            var"##1174" = (var"##cache#1060").value
                            var"##1174" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1174"[1] == :do && (begin
                                    var"##1175" = var"##1174"[2]
                                    var"##1175" isa AbstractArray
                                end && (length(var"##1175") === 2 && (begin
                                            var"##1176" = var"##1175"[1]
                                            begin
                                                var"##cache#1178" = nothing
                                            end
                                            var"##1177" = var"##1175"[2]
                                            var"##1177" isa Expr
                                        end && (begin
                                                if var"##cache#1178" === nothing
                                                    var"##cache#1178" = Some(((var"##1177").head, (var"##1177").args))
                                                end
                                                var"##1179" = (var"##cache#1178").value
                                                var"##1179" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1179"[1] == :-> && (begin
                                                        var"##1180" = var"##1179"[2]
                                                        var"##1180" isa AbstractArray
                                                    end && (length(var"##1180") === 2 && (begin
                                                                begin
                                                                    var"##cache#1182" = nothing
                                                                end
                                                                var"##1181" = var"##1180"[1]
                                                                var"##1181" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1182" === nothing
                                                                        var"##cache#1182" = Some(((var"##1181").head, (var"##1181").args))
                                                                    end
                                                                    var"##1183" = (var"##cache#1182").value
                                                                    var"##1183" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1183"[1] == :tuple && (begin
                                                                            var"##1184" = var"##1183"[2]
                                                                            var"##1184" isa AbstractArray
                                                                        end && ((ndims(var"##1184") === 1 && length(var"##1184") >= 0) && begin
                                                                                var"##1185" = SubArray(var"##1184", (1:length(var"##1184"),))
                                                                                var"##1186" = var"##1180"[2]
                                                                                true
                                                                            end)))))))))))))
                    call = var"##1176"
                    args = var"##1185"
                    body = var"##1186"
                    var"##return#1057" = begin
                            leading_tab()
                            inline(call)
                            keyword(" do ")
                            isempty(args) || inline(args...)
                            println()
                            stmts = split_body(body)
                            indent() do 
                                print_stmts(stmts)
                            end
                            println()
                            tab()
                            keyword("end")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1058#1262")))
                end
                if begin
                            var"##1187" = (var"##cache#1060").value
                            var"##1187" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1187"[1] == :macro && (begin
                                    var"##1188" = var"##1187"[2]
                                    var"##1188" isa AbstractArray
                                end && (length(var"##1188") === 2 && begin
                                        var"##1189" = var"##1188"[1]
                                        var"##1190" = var"##1188"[2]
                                        true
                                    end)))
                    call = var"##1189"
                    body = var"##1190"
                    var"##return#1057" = begin
                            print_function(:macro, call, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1058#1262")))
                end
                if begin
                            var"##1191" = (var"##cache#1060").value
                            var"##1191" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1191"[1] == :macrocall && (begin
                                    var"##1192" = var"##1191"[2]
                                    var"##1192" isa AbstractArray
                                end && (length(var"##1192") === 4 && (begin
                                            var"##1193" = var"##1192"[1]
                                            var"##1193" == Symbol("@switch")
                                        end && (begin
                                                var"##1194" = var"##1192"[2]
                                                var"##1195" = var"##1192"[3]
                                                begin
                                                    var"##cache#1197" = nothing
                                                end
                                                var"##1196" = var"##1192"[4]
                                                var"##1196" isa Expr
                                            end && (begin
                                                    if var"##cache#1197" === nothing
                                                        var"##cache#1197" = Some(((var"##1196").head, (var"##1196").args))
                                                    end
                                                    var"##1198" = (var"##cache#1197").value
                                                    var"##1198" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1198"[1] == :block && (begin
                                                            var"##1199" = var"##1198"[2]
                                                            var"##1199" isa AbstractArray
                                                        end && ((ndims(var"##1199") === 1 && length(var"##1199") >= 0) && begin
                                                                var"##1200" = SubArray(var"##1199", (1:length(var"##1199"),))
                                                                true
                                                            end)))))))))
                    item = var"##1195"
                    line = var"##1194"
                    stmts = var"##1200"
                    var"##return#1057" = begin
                            print_switch(item, line, stmts)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1058#1262")))
                end
                if begin
                            var"##1201" = (var"##cache#1060").value
                            var"##1201" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1201"[1] == :macrocall && (begin
                                    var"##1202" = var"##1201"[2]
                                    var"##1202" isa AbstractArray
                                end && (length(var"##1202") === 4 && (begin
                                            var"##1203" = var"##1202"[1]
                                            var"##1203" == GlobalRef(Core, Symbol("@doc"))
                                        end && begin
                                            var"##1204" = var"##1202"[2]
                                            var"##1205" = var"##1202"[3]
                                            var"##1206" = var"##1202"[4]
                                            true
                                        end))))
                    line = var"##1204"
                    code = var"##1206"
                    doc = var"##1205"
                    var"##return#1057" = begin
                            leading_tab()
                            p.line && begin
                                    inline(line)
                                    println()
                                end
                            no_first_line_indent() do 
                                p(doc)
                            end
                            println()
                            tab()
                            no_first_line_indent() do 
                                p(code)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1058#1262")))
                end
                if begin
                            var"##1207" = (var"##cache#1060").value
                            var"##1207" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1207"[1] == :macrocall && (begin
                                    var"##1208" = var"##1207"[2]
                                    var"##1208" isa AbstractArray
                                end && ((ndims(var"##1208") === 1 && length(var"##1208") >= 2) && begin
                                        var"##1209" = var"##1208"[1]
                                        var"##1210" = var"##1208"[2]
                                        var"##1211" = SubArray(var"##1208", (3:length(var"##1208"),))
                                        true
                                    end)))
                    line = var"##1210"
                    name = var"##1209"
                    args = var"##1211"
                    var"##return#1057" = begin
                            print_macrocall(name, line, args)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1058#1262")))
                end
                if begin
                            var"##1212" = (var"##cache#1060").value
                            var"##1212" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1212"[1] == :struct && (begin
                                    var"##1213" = var"##1212"[2]
                                    var"##1213" isa AbstractArray
                                end && (length(var"##1213") === 3 && begin
                                        var"##1214" = var"##1213"[1]
                                        var"##1215" = var"##1213"[2]
                                        var"##1216" = var"##1213"[3]
                                        true
                                    end)))
                    ismutable = var"##1214"
                    body = var"##1216"
                    head = var"##1215"
                    var"##return#1057" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1058#1262")))
                end
                if begin
                            var"##1217" = (var"##cache#1060").value
                            var"##1217" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1217"[1] == :try && (begin
                                    var"##1218" = var"##1217"[2]
                                    var"##1218" isa AbstractArray
                                end && (length(var"##1218") === 3 && begin
                                        var"##1219" = var"##1218"[1]
                                        var"##1220" = var"##1218"[2]
                                        var"##1221" = var"##1218"[3]
                                        true
                                    end)))
                    catch_vars = var"##1220"
                    catch_body = var"##1221"
                    try_body = var"##1219"
                    var"##return#1057" = begin
                            print_try(try_body)
                            print_catch(catch_body, catch_vars)
                            println()
                            tab()
                            keyword("end")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1058#1262")))
                end
                if begin
                            var"##1222" = (var"##cache#1060").value
                            var"##1222" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1222"[1] == :try && (begin
                                    var"##1223" = var"##1222"[2]
                                    var"##1223" isa AbstractArray
                                end && (length(var"##1223") === 4 && begin
                                        var"##1224" = var"##1223"[1]
                                        var"##1225" = var"##1223"[2]
                                        var"##1226" = var"##1223"[3]
                                        var"##1227" = var"##1223"[4]
                                        true
                                    end)))
                    catch_vars = var"##1225"
                    catch_body = var"##1226"
                    try_body = var"##1224"
                    finally_body = var"##1227"
                    var"##return#1057" = begin
                            print_try(try_body)
                            print_catch(catch_body, catch_vars)
                            print_finally(finally_body)
                            println()
                            tab()
                            keyword("end")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1058#1262")))
                end
                if begin
                            var"##1228" = (var"##cache#1060").value
                            var"##1228" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1228"[1] == :try && (begin
                                    var"##1229" = var"##1228"[2]
                                    var"##1229" isa AbstractArray
                                end && (length(var"##1229") === 5 && begin
                                        var"##1230" = var"##1229"[1]
                                        var"##1231" = var"##1229"[2]
                                        var"##1232" = var"##1229"[3]
                                        var"##1233" = var"##1229"[4]
                                        var"##1234" = var"##1229"[5]
                                        true
                                    end)))
                    catch_vars = var"##1231"
                    catch_body = var"##1232"
                    try_body = var"##1230"
                    finally_body = var"##1233"
                    else_body = var"##1234"
                    var"##return#1057" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1058#1262")))
                end
                if begin
                            var"##1235" = (var"##cache#1060").value
                            var"##1235" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1235"[1] == :module && (begin
                                    var"##1236" = var"##1235"[2]
                                    var"##1236" isa AbstractArray
                                end && (length(var"##1236") === 3 && begin
                                        var"##1237" = var"##1236"[1]
                                        var"##1238" = var"##1236"[2]
                                        var"##1239" = var"##1236"[3]
                                        true
                                    end)))
                    name = var"##1238"
                    body = var"##1239"
                    notbare = var"##1237"
                    var"##return#1057" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1058#1262")))
                end
                if begin
                            var"##1240" = (var"##cache#1060").value
                            var"##1240" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1240"[1] == :const && (begin
                                    var"##1241" = var"##1240"[2]
                                    var"##1241" isa AbstractArray
                                end && (length(var"##1241") === 1 && begin
                                        var"##1242" = var"##1241"[1]
                                        true
                                    end)))
                    code = var"##1242"
                    var"##return#1057" = begin
                            leading_tab()
                            keyword("const ")
                            p(code)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1058#1262")))
                end
                if begin
                            var"##1243" = (var"##cache#1060").value
                            var"##1243" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1243"[1] == :return && (begin
                                    var"##1244" = var"##1243"[2]
                                    var"##1244" isa AbstractArray
                                end && (length(var"##1244") === 1 && (begin
                                            begin
                                                var"##cache#1246" = nothing
                                            end
                                            var"##1245" = var"##1244"[1]
                                            var"##1245" isa Expr
                                        end && (begin
                                                if var"##cache#1246" === nothing
                                                    var"##cache#1246" = Some(((var"##1245").head, (var"##1245").args))
                                                end
                                                var"##1247" = (var"##cache#1246").value
                                                var"##1247" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1247"[1] == :tuple && (begin
                                                        var"##1248" = var"##1247"[2]
                                                        var"##1248" isa AbstractArray
                                                    end && ((ndims(var"##1248") === 1 && length(var"##1248") >= 1) && (begin
                                                                begin
                                                                    var"##cache#1250" = nothing
                                                                end
                                                                var"##1249" = var"##1248"[1]
                                                                var"##1249" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1250" === nothing
                                                                        var"##cache#1250" = Some(((var"##1249").head, (var"##1249").args))
                                                                    end
                                                                    var"##1251" = (var"##cache#1250").value
                                                                    var"##1251" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1251"[1] == :parameters && (begin
                                                                            var"##1252" = var"##1251"[2]
                                                                            var"##1252" isa AbstractArray
                                                                        end && (ndims(var"##1252") === 1 && length(var"##1252") >= 0)))))))))))))
                    var"##return#1057" = begin
                            inline(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1058#1262")))
                end
                if begin
                            var"##1253" = (var"##cache#1060").value
                            var"##1253" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1253"[1] == :return && (begin
                                    var"##1254" = var"##1253"[2]
                                    var"##1254" isa AbstractArray
                                end && (length(var"##1254") === 1 && (begin
                                            begin
                                                var"##cache#1256" = nothing
                                            end
                                            var"##1255" = var"##1254"[1]
                                            var"##1255" isa Expr
                                        end && (begin
                                                if var"##cache#1256" === nothing
                                                    var"##cache#1256" = Some(((var"##1255").head, (var"##1255").args))
                                                end
                                                var"##1257" = (var"##cache#1256").value
                                                var"##1257" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1257"[1] == :tuple && (begin
                                                        var"##1258" = var"##1257"[2]
                                                        var"##1258" isa AbstractArray
                                                    end && (ndims(var"##1258") === 1 && length(var"##1258") >= 0))))))))
                    var"##return#1057" = begin
                            inline(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1058#1262")))
                end
                if begin
                            var"##1259" = (var"##cache#1060").value
                            var"##1259" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1259"[1] == :return && (begin
                                    var"##1260" = var"##1259"[2]
                                    var"##1260" isa AbstractArray
                                end && (length(var"##1260") === 1 && begin
                                        var"##1261" = var"##1260"[1]
                                        true
                                    end)))
                    code = var"##1261"
                    var"##return#1057" = begin
                            leading_tab()
                            keyword("return ")
                            p(code)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1058#1262")))
                end
            end
            if var"##1059" isa String
                begin
                    var"##return#1057" = begin
                            leading_tab()
                            occursin('\n', ex) || return inline(ex)
                            printstyled("\"\"\"\n", color = c.string)
                            tab()
                            print_multi_lines(ex)
                            printstyled("\"\"\"", color = c.string)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1058#1262")))
                end
            end
            begin
                var"##return#1057" = begin
                        inline(ex)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#1058#1262")))
            end
            error("matching non-exhaustive, at #= none:246 =#")
            $(Expr(:symboliclabel, Symbol("####final#1058#1262")))
            var"##return#1057"
        end
        return nothing
    end
    #= none:464 =# Core.@doc "    print_expr([io::IO], ex; kw...)\n\nPrint a given expression. `ex` can be a `Expr` or a syntax type `JLExpr`.\n" print_expr(io::IO, ex; kw...) = begin
                (Printer(io; kw...))(ex)
            end
    print_expr(ex; kw...) = begin
            print_expr(stdout, ex; kw...)
        end
