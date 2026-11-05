
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
                    var"##cache#1049" = nothing
                end
                var"##return#1046" = nothing
                var"##1048" = otherwise
                if var"##1048" isa Expr && (begin
                                if var"##cache#1049" === nothing
                                    var"##cache#1049" = Some(((var"##1048").head, (var"##1048").args))
                                end
                                var"##1050" = (var"##cache#1049").value
                                var"##1050" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1050"[1] == :block && (begin
                                        var"##1051" = var"##1050"[2]
                                        var"##1051" isa AbstractArray
                                    end && ((ndims(var"##1051") === 1 && length(var"##1051") >= 0) && begin
                                            var"##1052" = SubArray(var"##1051", (1:length(var"##1051"),))
                                            true
                                        end))))
                    var"##return#1046" = let stmts = var"##1052"
                            indent() do
                                print_stmts(stmts)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1047#1053")))
                end
                begin
                    var"##return#1046" = let
                            indent() do
                                tab()
                                no_first_line_indent() do
                                    p(otherwise)
                                end
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1047#1053")))
                end
                error("matching non-exhaustive, at #= none:98 =#")
                $(Expr(:symboliclabel, Symbol("####final#1047#1053")))
                var"##return#1046"
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
                            var"##cache#1057" = nothing
                        end
                        var"##return#1054" = nothing
                        var"##1056" = stmt
                        if var"##1056" isa Expr && (begin
                                        if var"##cache#1057" === nothing
                                            var"##cache#1057" = Some(((var"##1056").head, (var"##1056").args))
                                        end
                                        var"##1058" = (var"##cache#1057").value
                                        var"##1058" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##1058"[1] == :macrocall && (begin
                                                var"##1059" = var"##1058"[2]
                                                var"##1059" isa AbstractArray
                                            end && ((ndims(var"##1059") === 1 && length(var"##1059") >= 1) && begin
                                                    var"##1060" = var"##1059"[1]
                                                    var"##1060" == Symbol("@case")
                                                end))))
                            var"##return#1054" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1055#1061")))
                        end
                        begin
                            var"##return#1054" = let
                                    false
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1055#1061")))
                        end
                        error("matching non-exhaustive, at #= none:181 =#")
                        $(Expr(:symboliclabel, Symbol("####final#1055#1061")))
                        var"##return#1054"
                    end
                end || return print_macrocall("@switch", line, (item, Expr(:block, stmts...)))
            is_case(stmt) = begin
                    let
                        begin
                            var"##cache#1065" = nothing
                        end
                        var"##return#1062" = nothing
                        var"##1064" = stmt
                        if var"##1064" isa Expr && (begin
                                        if var"##cache#1065" === nothing
                                            var"##cache#1065" = Some(((var"##1064").head, (var"##1064").args))
                                        end
                                        var"##1066" = (var"##cache#1065").value
                                        var"##1066" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##1066"[1] == :macrocall && (begin
                                                var"##1067" = var"##1066"[2]
                                                var"##1067" isa AbstractArray
                                            end && ((ndims(var"##1067") === 1 && length(var"##1067") >= 1) && begin
                                                    var"##1068" = var"##1067"[1]
                                                    var"##1068" == Symbol("@case")
                                                end))))
                            var"##return#1062" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1063#1069")))
                        end
                        begin
                            var"##return#1062" = let
                                    false
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1063#1069")))
                        end
                        error("matching non-exhaustive, at #= none:187 =#")
                        $(Expr(:symboliclabel, Symbol("####final#1063#1069")))
                        var"##return#1062"
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
                            var"##cache#1073" = nothing
                        end
                        var"##return#1070" = nothing
                        var"##1072" = stmt
                        if var"##1072" isa Expr && (begin
                                        if var"##cache#1073" === nothing
                                            var"##cache#1073" = Some(((var"##1072").head, (var"##1072").args))
                                        end
                                        var"##1074" = (var"##cache#1073").value
                                        var"##1074" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##1074"[1] == :macrocall && (begin
                                                var"##1075" = var"##1074"[2]
                                                var"##1075" isa AbstractArray
                                            end && (length(var"##1075") === 3 && (begin
                                                        var"##1076" = var"##1075"[1]
                                                        var"##1076" == Symbol("@case")
                                                    end && begin
                                                        var"##1077" = var"##1075"[2]
                                                        var"##1078" = var"##1075"[3]
                                                        true
                                                    end)))))
                            var"##return#1070" = let pattern = var"##1078", line = var"##1077"
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
                            $(Expr(:symbolicgoto, Symbol("####final#1071#1079")))
                        end
                        begin
                            var"##return#1070" = let
                                    p(stmt)
                                    println()
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1071#1079")))
                        end
                        error("matching non-exhaustive, at #= none:197 =#")
                        $(Expr(:symboliclabel, Symbol("####final#1071#1079")))
                        var"##return#1070"
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
                var"##cache#1083" = nothing
            end
            var"##1082" = ex
            if var"##1082" isa String
                begin
                    var"##return#1080" = begin
                            leading_tab()
                            occursin('\n', ex) || return inline(ex)
                            printstyled("\"\"\"\n", color = c.string)
                            tab()
                            print_multi_lines(ex)
                            printstyled("\"\"\"", color = c.string)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1081#1294")))
                end
            end
            if var"##1082" isa Expr
                if begin
                            if var"##cache#1083" === nothing
                                var"##cache#1083" = Some(((var"##1082").head, (var"##1082").args))
                            end
                            var"##1084" = (var"##cache#1083").value
                            var"##1084" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1084"[1] == :string && (begin
                                    var"##1085" = var"##1084"[2]
                                    var"##1085" isa AbstractArray
                                end && ((ndims(var"##1085") === 1 && length(var"##1085") >= 0) && begin
                                        var"##1086" = SubArray(var"##1085", (1:length(var"##1085"),))
                                        true
                                    end)))
                    args = var"##1086"
                    var"##return#1080" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1081#1294")))
                end
                if begin
                            var"##1087" = (var"##cache#1083").value
                            var"##1087" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1087"[1] == :block && (begin
                                    var"##1088" = var"##1087"[2]
                                    var"##1088" isa AbstractArray
                                end && ((ndims(var"##1088") === 1 && length(var"##1088") >= 0) && begin
                                        var"##1089" = SubArray(var"##1088", (1:length(var"##1088"),))
                                        true
                                    end)))
                    stmts = var"##1089"
                    var"##return#1080" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1081#1294")))
                end
                if begin
                            var"##1090" = (var"##cache#1083").value
                            var"##1090" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1090"[1] == :quote && (begin
                                    var"##1091" = var"##1090"[2]
                                    var"##1091" isa AbstractArray
                                end && (length(var"##1091") === 1 && (begin
                                            begin
                                                var"##cache#1093" = nothing
                                            end
                                            var"##1092" = var"##1091"[1]
                                            var"##1092" isa Expr
                                        end && (begin
                                                if var"##cache#1093" === nothing
                                                    var"##cache#1093" = Some(((var"##1092").head, (var"##1092").args))
                                                end
                                                var"##1094" = (var"##cache#1093").value
                                                var"##1094" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1094"[1] == :block && (begin
                                                        var"##1095" = var"##1094"[2]
                                                        var"##1095" isa AbstractArray
                                                    end && ((ndims(var"##1095") === 1 && length(var"##1095") >= 0) && begin
                                                            var"##1096" = SubArray(var"##1095", (1:length(var"##1095"),))
                                                            let stmts = var"##1096"
                                                                is_root()
                                                            end
                                                        end))))))))
                    stmts = var"##1096"
                    var"##return#1080" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1081#1294")))
                end
                if begin
                            var"##1097" = (var"##cache#1083").value
                            var"##1097" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1097"[1] == :quote && (begin
                                    var"##1098" = var"##1097"[2]
                                    var"##1098" isa AbstractArray
                                end && (length(var"##1098") === 1 && (begin
                                            begin
                                                var"##cache#1100" = nothing
                                            end
                                            var"##1099" = var"##1098"[1]
                                            var"##1099" isa Expr
                                        end && (begin
                                                if var"##cache#1100" === nothing
                                                    var"##cache#1100" = Some(((var"##1099").head, (var"##1099").args))
                                                end
                                                var"##1101" = (var"##cache#1100").value
                                                var"##1101" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1101"[1] == :block && (begin
                                                        var"##1102" = var"##1101"[2]
                                                        var"##1102" isa AbstractArray
                                                    end && ((ndims(var"##1102") === 1 && length(var"##1102") >= 0) && begin
                                                            var"##1103" = SubArray(var"##1102", (1:length(var"##1102"),))
                                                            true
                                                        end))))))))
                    stmts = var"##1103"
                    var"##return#1080" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1081#1294")))
                end
                if begin
                            var"##1104" = (var"##cache#1083").value
                            var"##1104" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1104"[1] == :quote && (begin
                                    var"##1105" = var"##1104"[2]
                                    var"##1105" isa AbstractArray
                                end && (length(var"##1105") === 1 && begin
                                        var"##1106" = var"##1105"[1]
                                        true
                                    end)))
                    code = var"##1106"
                    var"##return#1080" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1081#1294")))
                end
                if begin
                            var"##1107" = (var"##cache#1083").value
                            var"##1107" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1107"[1] == :let && (begin
                                    var"##1108" = var"##1107"[2]
                                    var"##1108" isa AbstractArray
                                end && (length(var"##1108") === 2 && (begin
                                            begin
                                                var"##cache#1110" = nothing
                                            end
                                            var"##1109" = var"##1108"[1]
                                            var"##1109" isa Expr
                                        end && (begin
                                                if var"##cache#1110" === nothing
                                                    var"##cache#1110" = Some(((var"##1109").head, (var"##1109").args))
                                                end
                                                var"##1111" = (var"##cache#1110").value
                                                var"##1111" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1111"[1] == :block && (begin
                                                        var"##1112" = var"##1111"[2]
                                                        var"##1112" isa AbstractArray
                                                    end && ((ndims(var"##1112") === 1 && length(var"##1112") >= 0) && (begin
                                                                var"##1113" = SubArray(var"##1112", (1:length(var"##1112"),))
                                                                begin
                                                                    var"##cache#1115" = nothing
                                                                end
                                                                var"##1114" = var"##1108"[2]
                                                                var"##1114" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1115" === nothing
                                                                        var"##cache#1115" = Some(((var"##1114").head, (var"##1114").args))
                                                                    end
                                                                    var"##1116" = (var"##cache#1115").value
                                                                    var"##1116" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1116"[1] == :block && (begin
                                                                            var"##1117" = var"##1116"[2]
                                                                            var"##1117" isa AbstractArray
                                                                        end && ((ndims(var"##1117") === 1 && length(var"##1117") >= 0) && begin
                                                                                var"##1118" = SubArray(var"##1117", (1:length(var"##1117"),))
                                                                                true
                                                                            end)))))))))))))
                    args = var"##1113"
                    stmts = var"##1118"
                    var"##return#1080" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1081#1294")))
                end
                if begin
                            var"##1119" = (var"##cache#1083").value
                            var"##1119" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1119"[1] == :if && (begin
                                    var"##1120" = var"##1119"[2]
                                    var"##1120" isa AbstractArray
                                end && (length(var"##1120") === 2 && begin
                                        var"##1121" = var"##1120"[1]
                                        var"##1122" = var"##1120"[2]
                                        true
                                    end)))
                    cond = var"##1121"
                    body = var"##1122"
                    var"##return#1080" = begin
                            print_if(cond, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1081#1294")))
                end
                if begin
                            var"##1123" = (var"##cache#1083").value
                            var"##1123" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1123"[1] == :if && (begin
                                    var"##1124" = var"##1123"[2]
                                    var"##1124" isa AbstractArray
                                end && (length(var"##1124") === 3 && begin
                                        var"##1125" = var"##1124"[1]
                                        var"##1126" = var"##1124"[2]
                                        var"##1127" = var"##1124"[3]
                                        true
                                    end)))
                    cond = var"##1125"
                    body = var"##1126"
                    otherwise = var"##1127"
                    var"##return#1080" = begin
                            print_if(cond, body, otherwise)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1081#1294")))
                end
                if begin
                            var"##1128" = (var"##cache#1083").value
                            var"##1128" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1128"[1] == :elseif && (begin
                                    var"##1129" = var"##1128"[2]
                                    var"##1129" isa AbstractArray
                                end && (length(var"##1129") === 2 && (begin
                                            begin
                                                var"##cache#1131" = nothing
                                            end
                                            var"##1130" = var"##1129"[1]
                                            var"##1130" isa Expr
                                        end && (begin
                                                if var"##cache#1131" === nothing
                                                    var"##cache#1131" = Some(((var"##1130").head, (var"##1130").args))
                                                end
                                                var"##1132" = (var"##cache#1131").value
                                                var"##1132" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1132"[1] == :block && (begin
                                                        var"##1133" = var"##1132"[2]
                                                        var"##1133" isa AbstractArray
                                                    end && (length(var"##1133") === 2 && begin
                                                            var"##1134" = var"##1133"[1]
                                                            var"##1135" = var"##1133"[2]
                                                            var"##1136" = var"##1129"[2]
                                                            true
                                                        end))))))))
                    line = var"##1134"
                    cond = var"##1135"
                    body = var"##1136"
                    var"##return#1080" = begin
                            print_elseif(cond, body, line)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1081#1294")))
                end
                if begin
                            var"##1137" = (var"##cache#1083").value
                            var"##1137" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1137"[1] == :elseif && (begin
                                    var"##1138" = var"##1137"[2]
                                    var"##1138" isa AbstractArray
                                end && (length(var"##1138") === 2 && begin
                                        var"##1139" = var"##1138"[1]
                                        var"##1140" = var"##1138"[2]
                                        true
                                    end)))
                    cond = var"##1139"
                    body = var"##1140"
                    var"##return#1080" = begin
                            print_elseif(cond, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1081#1294")))
                end
                if begin
                            var"##1141" = (var"##cache#1083").value
                            var"##1141" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1141"[1] == :elseif && (begin
                                    var"##1142" = var"##1141"[2]
                                    var"##1142" isa AbstractArray
                                end && (length(var"##1142") === 3 && (begin
                                            begin
                                                var"##cache#1144" = nothing
                                            end
                                            var"##1143" = var"##1142"[1]
                                            var"##1143" isa Expr
                                        end && (begin
                                                if var"##cache#1144" === nothing
                                                    var"##cache#1144" = Some(((var"##1143").head, (var"##1143").args))
                                                end
                                                var"##1145" = (var"##cache#1144").value
                                                var"##1145" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1145"[1] == :block && (begin
                                                        var"##1146" = var"##1145"[2]
                                                        var"##1146" isa AbstractArray
                                                    end && (length(var"##1146") === 2 && begin
                                                            var"##1147" = var"##1146"[1]
                                                            var"##1148" = var"##1146"[2]
                                                            var"##1149" = var"##1142"[2]
                                                            var"##1150" = var"##1142"[3]
                                                            true
                                                        end))))))))
                    line = var"##1147"
                    cond = var"##1148"
                    body = var"##1149"
                    otherwise = var"##1150"
                    var"##return#1080" = begin
                            print_elseif(cond, body, line, otherwise)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1081#1294")))
                end
                if begin
                            var"##1151" = (var"##cache#1083").value
                            var"##1151" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1151"[1] == :elseif && (begin
                                    var"##1152" = var"##1151"[2]
                                    var"##1152" isa AbstractArray
                                end && (length(var"##1152") === 3 && begin
                                        var"##1153" = var"##1152"[1]
                                        var"##1154" = var"##1152"[2]
                                        var"##1155" = var"##1152"[3]
                                        true
                                    end)))
                    cond = var"##1153"
                    body = var"##1154"
                    otherwise = var"##1155"
                    var"##return#1080" = begin
                            print_elseif(cond, body, nothing, otherwise)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1081#1294")))
                end
                if begin
                            var"##1156" = (var"##cache#1083").value
                            var"##1156" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1156"[1] == :for && (begin
                                    var"##1157" = var"##1156"[2]
                                    var"##1157" isa AbstractArray
                                end && (length(var"##1157") === 2 && begin
                                        var"##1158" = var"##1157"[1]
                                        var"##1159" = var"##1157"[2]
                                        true
                                    end)))
                    body = var"##1159"
                    iteration = var"##1158"
                    var"##return#1080" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1081#1294")))
                end
                if begin
                            var"##1160" = (var"##cache#1083").value
                            var"##1160" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1160"[1] == :while && (begin
                                    var"##1161" = var"##1160"[2]
                                    var"##1161" isa AbstractArray
                                end && (length(var"##1161") === 2 && begin
                                        var"##1162" = var"##1161"[1]
                                        var"##1163" = var"##1161"[2]
                                        true
                                    end)))
                    cond = var"##1162"
                    body = var"##1163"
                    var"##return#1080" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1081#1294")))
                end
                if begin
                            var"##1164" = (var"##cache#1083").value
                            var"##1164" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1164"[1] == :(=) && (begin
                                    var"##1165" = var"##1164"[2]
                                    var"##1165" isa AbstractArray
                                end && (length(var"##1165") === 2 && (begin
                                            var"##1166" = var"##1165"[1]
                                            begin
                                                var"##cache#1168" = nothing
                                            end
                                            var"##1167" = var"##1165"[2]
                                            var"##1167" isa Expr
                                        end && (begin
                                                if var"##cache#1168" === nothing
                                                    var"##cache#1168" = Some(((var"##1167").head, (var"##1167").args))
                                                end
                                                var"##1169" = (var"##cache#1168").value
                                                var"##1169" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1169"[1] == :block && (begin
                                                        var"##1170" = var"##1169"[2]
                                                        var"##1170" isa AbstractArray
                                                    end && (length(var"##1170") === 2 && (begin
                                                                var"##1171" = var"##1170"[1]
                                                                begin
                                                                    var"##cache#1173" = nothing
                                                                end
                                                                var"##1172" = var"##1170"[2]
                                                                var"##1172" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1173" === nothing
                                                                        var"##cache#1173" = Some(((var"##1172").head, (var"##1172").args))
                                                                    end
                                                                    var"##1174" = (var"##cache#1173").value
                                                                    var"##1174" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1174"[1] == :if && (begin
                                                                            var"##1175" = var"##1174"[2]
                                                                            var"##1175" isa AbstractArray
                                                                        end && ((ndims(var"##1175") === 1 && length(var"##1175") >= 0) && let line = var"##1171", lhs = var"##1166"
                                                                                is_line_no(line)
                                                                            end)))))))))))))
                    line = var"##1171"
                    lhs = var"##1166"
                    var"##return#1080" = begin
                            leading_tab()
                            inline(lhs)
                            keyword(" = ")
                            inline(line)
                            p(ex.args[2])
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1081#1294")))
                end
                if begin
                            var"##1176" = (var"##cache#1083").value
                            var"##1176" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1176"[1] == :(=) && (begin
                                    var"##1177" = var"##1176"[2]
                                    var"##1177" isa AbstractArray
                                end && (length(var"##1177") === 2 && (begin
                                            var"##1178" = var"##1177"[1]
                                            begin
                                                var"##cache#1180" = nothing
                                            end
                                            var"##1179" = var"##1177"[2]
                                            var"##1179" isa Expr
                                        end && (begin
                                                if var"##cache#1180" === nothing
                                                    var"##cache#1180" = Some(((var"##1179").head, (var"##1179").args))
                                                end
                                                var"##1181" = (var"##cache#1180").value
                                                var"##1181" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1181"[1] == :block && (begin
                                                        var"##1182" = var"##1181"[2]
                                                        var"##1182" isa AbstractArray
                                                    end && (length(var"##1182") === 2 && begin
                                                            var"##1183" = var"##1182"[1]
                                                            var"##1184" = var"##1182"[2]
                                                            let rhs = var"##1184", line = var"##1183", lhs = var"##1178"
                                                                is_line_no(line)
                                                            end
                                                        end))))))))
                    rhs = var"##1184"
                    line = var"##1183"
                    lhs = var"##1178"
                    var"##return#1080" = begin
                            leading_tab()
                            inline(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1081#1294")))
                end
                if begin
                            var"##1185" = (var"##cache#1083").value
                            var"##1185" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1185"[1] == :(=) && (begin
                                    var"##1186" = var"##1185"[2]
                                    var"##1186" isa AbstractArray
                                end && (length(var"##1186") === 2 && begin
                                        var"##1187" = var"##1186"[1]
                                        var"##1188" = var"##1186"[2]
                                        true
                                    end)))
                    rhs = var"##1188"
                    lhs = var"##1187"
                    var"##return#1080" = begin
                            leading_tab()
                            inline(lhs)
                            print(" = ")
                            p(rhs)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1081#1294")))
                end
                if begin
                            var"##1189" = (var"##cache#1083").value
                            var"##1189" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1189"[1] == :function && (begin
                                    var"##1190" = var"##1189"[2]
                                    var"##1190" isa AbstractArray
                                end && (length(var"##1190") === 2 && begin
                                        var"##1191" = var"##1190"[1]
                                        var"##1192" = var"##1190"[2]
                                        true
                                    end)))
                    call = var"##1191"
                    body = var"##1192"
                    var"##return#1080" = begin
                            print_function(:function, call, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1081#1294")))
                end
                if begin
                            var"##1193" = (var"##cache#1083").value
                            var"##1193" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1193"[1] == :-> && (begin
                                    var"##1194" = var"##1193"[2]
                                    var"##1194" isa AbstractArray
                                end && (length(var"##1194") === 2 && begin
                                        var"##1195" = var"##1194"[1]
                                        var"##1196" = var"##1194"[2]
                                        true
                                    end)))
                    call = var"##1195"
                    body = var"##1196"
                    var"##return#1080" = begin
                            leading_tab()
                            inline(call)
                            keyword(" -> ")
                            p(body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1081#1294")))
                end
                if begin
                            var"##1197" = (var"##cache#1083").value
                            var"##1197" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1197"[1] == :do && (begin
                                    var"##1198" = var"##1197"[2]
                                    var"##1198" isa AbstractArray
                                end && (length(var"##1198") === 2 && (begin
                                            var"##1199" = var"##1198"[1]
                                            begin
                                                var"##cache#1201" = nothing
                                            end
                                            var"##1200" = var"##1198"[2]
                                            var"##1200" isa Expr
                                        end && (begin
                                                if var"##cache#1201" === nothing
                                                    var"##cache#1201" = Some(((var"##1200").head, (var"##1200").args))
                                                end
                                                var"##1202" = (var"##cache#1201").value
                                                var"##1202" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1202"[1] == :-> && (begin
                                                        var"##1203" = var"##1202"[2]
                                                        var"##1203" isa AbstractArray
                                                    end && (length(var"##1203") === 2 && (begin
                                                                begin
                                                                    var"##cache#1205" = nothing
                                                                end
                                                                var"##1204" = var"##1203"[1]
                                                                var"##1204" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1205" === nothing
                                                                        var"##cache#1205" = Some(((var"##1204").head, (var"##1204").args))
                                                                    end
                                                                    var"##1206" = (var"##cache#1205").value
                                                                    var"##1206" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1206"[1] == :tuple && (begin
                                                                            var"##1207" = var"##1206"[2]
                                                                            var"##1207" isa AbstractArray
                                                                        end && ((ndims(var"##1207") === 1 && length(var"##1207") >= 0) && begin
                                                                                var"##1208" = SubArray(var"##1207", (1:length(var"##1207"),))
                                                                                var"##1209" = var"##1203"[2]
                                                                                true
                                                                            end)))))))))))))
                    call = var"##1199"
                    args = var"##1208"
                    body = var"##1209"
                    var"##return#1080" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1081#1294")))
                end
                if begin
                            var"##1210" = (var"##cache#1083").value
                            var"##1210" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1210"[1] == :macro && (begin
                                    var"##1211" = var"##1210"[2]
                                    var"##1211" isa AbstractArray
                                end && (length(var"##1211") === 2 && begin
                                        var"##1212" = var"##1211"[1]
                                        var"##1213" = var"##1211"[2]
                                        true
                                    end)))
                    call = var"##1212"
                    body = var"##1213"
                    var"##return#1080" = begin
                            print_function(:macro, call, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1081#1294")))
                end
                if begin
                            var"##1214" = (var"##cache#1083").value
                            var"##1214" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1214"[1] == :macrocall && (begin
                                    var"##1215" = var"##1214"[2]
                                    var"##1215" isa AbstractArray
                                end && (length(var"##1215") === 4 && (begin
                                            var"##1216" = var"##1215"[1]
                                            var"##1216" == Symbol("@switch")
                                        end && (begin
                                                var"##1217" = var"##1215"[2]
                                                var"##1218" = var"##1215"[3]
                                                begin
                                                    var"##cache#1220" = nothing
                                                end
                                                var"##1219" = var"##1215"[4]
                                                var"##1219" isa Expr
                                            end && (begin
                                                    if var"##cache#1220" === nothing
                                                        var"##cache#1220" = Some(((var"##1219").head, (var"##1219").args))
                                                    end
                                                    var"##1221" = (var"##cache#1220").value
                                                    var"##1221" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1221"[1] == :block && (begin
                                                            var"##1222" = var"##1221"[2]
                                                            var"##1222" isa AbstractArray
                                                        end && ((ndims(var"##1222") === 1 && length(var"##1222") >= 0) && begin
                                                                var"##1223" = SubArray(var"##1222", (1:length(var"##1222"),))
                                                                true
                                                            end)))))))))
                    item = var"##1218"
                    line = var"##1217"
                    stmts = var"##1223"
                    var"##return#1080" = begin
                            print_switch(item, line, stmts)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1081#1294")))
                end
                if begin
                            var"##1224" = (var"##cache#1083").value
                            var"##1224" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1224"[1] == :macrocall && (begin
                                    var"##1225" = var"##1224"[2]
                                    var"##1225" isa AbstractArray
                                end && (length(var"##1225") === 4 && (begin
                                            var"##1226" = var"##1225"[1]
                                            var"##1226" == GlobalRef(Core, Symbol("@doc"))
                                        end && begin
                                            var"##1227" = var"##1225"[2]
                                            var"##1228" = var"##1225"[3]
                                            var"##1229" = var"##1225"[4]
                                            true
                                        end))))
                    line = var"##1227"
                    code = var"##1229"
                    doc = var"##1228"
                    var"##return#1080" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1081#1294")))
                end
                if begin
                            var"##1230" = (var"##cache#1083").value
                            var"##1230" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1230"[1] == :macrocall && (begin
                                    var"##1231" = var"##1230"[2]
                                    var"##1231" isa AbstractArray
                                end && ((ndims(var"##1231") === 1 && length(var"##1231") >= 2) && begin
                                        var"##1232" = var"##1231"[1]
                                        var"##1233" = var"##1231"[2]
                                        var"##1234" = SubArray(var"##1231", (3:length(var"##1231"),))
                                        true
                                    end)))
                    line = var"##1233"
                    name = var"##1232"
                    args = var"##1234"
                    var"##return#1080" = begin
                            print_macrocall(name, line, args)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1081#1294")))
                end
                if begin
                            var"##1235" = (var"##cache#1083").value
                            var"##1235" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1235"[1] == :struct && (begin
                                    var"##1236" = var"##1235"[2]
                                    var"##1236" isa AbstractArray
                                end && (length(var"##1236") === 3 && begin
                                        var"##1237" = var"##1236"[1]
                                        var"##1238" = var"##1236"[2]
                                        var"##1239" = var"##1236"[3]
                                        true
                                    end)))
                    ismutable = var"##1237"
                    body = var"##1239"
                    head = var"##1238"
                    var"##return#1080" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1081#1294")))
                end
                if begin
                            var"##1240" = (var"##cache#1083").value
                            var"##1240" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1240"[1] == :try && (begin
                                    var"##1241" = var"##1240"[2]
                                    var"##1241" isa AbstractArray
                                end && (length(var"##1241") === 3 && begin
                                        var"##1242" = var"##1241"[1]
                                        var"##1243" = var"##1241"[2]
                                        var"##1244" = var"##1241"[3]
                                        true
                                    end)))
                    catch_vars = var"##1243"
                    catch_body = var"##1244"
                    try_body = var"##1242"
                    var"##return#1080" = begin
                            print_try(try_body)
                            print_catch(catch_body, catch_vars)
                            println()
                            tab()
                            keyword("end")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1081#1294")))
                end
                if begin
                            var"##1245" = (var"##cache#1083").value
                            var"##1245" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1245"[1] == :try && (begin
                                    var"##1246" = var"##1245"[2]
                                    var"##1246" isa AbstractArray
                                end && (length(var"##1246") === 4 && begin
                                        var"##1247" = var"##1246"[1]
                                        var"##1248" = var"##1246"[2]
                                        var"##1249" = var"##1246"[3]
                                        var"##1250" = var"##1246"[4]
                                        true
                                    end)))
                    catch_vars = var"##1248"
                    catch_body = var"##1249"
                    try_body = var"##1247"
                    finally_body = var"##1250"
                    var"##return#1080" = begin
                            print_try(try_body)
                            print_catch(catch_body, catch_vars)
                            print_finally(finally_body)
                            println()
                            tab()
                            keyword("end")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1081#1294")))
                end
                if begin
                            var"##1251" = (var"##cache#1083").value
                            var"##1251" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1251"[1] == :try && (begin
                                    var"##1252" = var"##1251"[2]
                                    var"##1252" isa AbstractArray
                                end && (length(var"##1252") === 5 && begin
                                        var"##1253" = var"##1252"[1]
                                        var"##1254" = var"##1252"[2]
                                        var"##1255" = var"##1252"[3]
                                        var"##1256" = var"##1252"[4]
                                        var"##1257" = var"##1252"[5]
                                        true
                                    end)))
                    catch_vars = var"##1254"
                    catch_body = var"##1255"
                    try_body = var"##1253"
                    finally_body = var"##1256"
                    else_body = var"##1257"
                    var"##return#1080" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1081#1294")))
                end
                if begin
                            var"##1258" = (var"##cache#1083").value
                            var"##1258" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1258"[1] == :module && (begin
                                    var"##1259" = var"##1258"[2]
                                    var"##1259" isa AbstractArray
                                end && (length(var"##1259") === 3 && begin
                                        var"##1260" = var"##1259"[1]
                                        var"##1261" = var"##1259"[2]
                                        var"##1262" = var"##1259"[3]
                                        true
                                    end)))
                    name = var"##1261"
                    body = var"##1262"
                    notbare = var"##1260"
                    var"##return#1080" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1081#1294")))
                end
                if begin
                            var"##1263" = (var"##cache#1083").value
                            var"##1263" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1263"[1] == :module && (begin
                                    var"##1264" = var"##1263"[2]
                                    var"##1264" isa AbstractArray
                                end && (length(var"##1264") === 4 && (begin
                                            var"##1265" = var"##1264"[1]
                                            var"##1265" isa VersionNumber
                                        end && begin
                                            var"##1266" = var"##1264"[2]
                                            var"##1267" = var"##1264"[3]
                                            var"##1268" = var"##1264"[4]
                                            true
                                        end))))
                    name = var"##1267"
                    body = var"##1268"
                    notbare = var"##1266"
                    var"##return#1080" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1081#1294")))
                end
                if begin
                            var"##1269" = (var"##cache#1083").value
                            var"##1269" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1269"[1] == :const && (begin
                                    var"##1270" = var"##1269"[2]
                                    var"##1270" isa AbstractArray
                                end && (length(var"##1270") === 1 && begin
                                        var"##1271" = var"##1270"[1]
                                        true
                                    end)))
                    code = var"##1271"
                    var"##return#1080" = begin
                            leading_tab()
                            keyword("const ")
                            p(code)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1081#1294")))
                end
                if begin
                            var"##1272" = (var"##cache#1083").value
                            var"##1272" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1272"[1] == :return && (begin
                                    var"##1273" = var"##1272"[2]
                                    var"##1273" isa AbstractArray
                                end && (length(var"##1273") === 1 && (begin
                                            begin
                                                var"##cache#1275" = nothing
                                            end
                                            var"##1274" = var"##1273"[1]
                                            var"##1274" isa Expr
                                        end && (begin
                                                if var"##cache#1275" === nothing
                                                    var"##cache#1275" = Some(((var"##1274").head, (var"##1274").args))
                                                end
                                                var"##1276" = (var"##cache#1275").value
                                                var"##1276" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1276"[1] == :tuple && (begin
                                                        var"##1277" = var"##1276"[2]
                                                        var"##1277" isa AbstractArray
                                                    end && ((ndims(var"##1277") === 1 && length(var"##1277") >= 1) && (begin
                                                                begin
                                                                    var"##cache#1279" = nothing
                                                                end
                                                                var"##1278" = var"##1277"[1]
                                                                var"##1278" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1279" === nothing
                                                                        var"##cache#1279" = Some(((var"##1278").head, (var"##1278").args))
                                                                    end
                                                                    var"##1280" = (var"##cache#1279").value
                                                                    var"##1280" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1280"[1] == :parameters && (begin
                                                                            var"##1281" = var"##1280"[2]
                                                                            var"##1281" isa AbstractArray
                                                                        end && (ndims(var"##1281") === 1 && length(var"##1281") >= 0)))))))))))))
                    var"##return#1080" = begin
                            inline(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1081#1294")))
                end
                if begin
                            var"##1282" = (var"##cache#1083").value
                            var"##1282" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1282"[1] == :return && (begin
                                    var"##1283" = var"##1282"[2]
                                    var"##1283" isa AbstractArray
                                end && (length(var"##1283") === 1 && (begin
                                            begin
                                                var"##cache#1285" = nothing
                                            end
                                            var"##1284" = var"##1283"[1]
                                            var"##1284" isa Expr
                                        end && (begin
                                                if var"##cache#1285" === nothing
                                                    var"##cache#1285" = Some(((var"##1284").head, (var"##1284").args))
                                                end
                                                var"##1286" = (var"##cache#1285").value
                                                var"##1286" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1286"[1] == :tuple && (begin
                                                        var"##1287" = var"##1286"[2]
                                                        var"##1287" isa AbstractArray
                                                    end && (ndims(var"##1287") === 1 && length(var"##1287") >= 0))))))))
                    var"##return#1080" = begin
                            inline(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1081#1294")))
                end
                if begin
                            var"##1288" = (var"##cache#1083").value
                            var"##1288" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1288"[1] == :return && (begin
                                    var"##1289" = var"##1288"[2]
                                    var"##1289" isa AbstractArray
                                end && (length(var"##1289") === 1 && begin
                                        var"##1290" = var"##1289"[1]
                                        true
                                    end)))
                    code = var"##1290"
                    var"##return#1080" = begin
                            leading_tab()
                            keyword("return ")
                            p(code)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1081#1294")))
                end
                if begin
                            var"##1291" = (var"##cache#1083").value
                            var"##1291" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1291"[1] == :toplevel && (begin
                                    var"##1292" = var"##1291"[2]
                                    var"##1292" isa AbstractArray
                                end && (length(var"##1292") === 1 && begin
                                        var"##1293" = var"##1292"[1]
                                        true
                                    end)))
                    code = var"##1293"
                    var"##return#1080" = begin
                            leading_tab()
                            printstyled("#= meta: toplevel =#", color = c.comment)
                            println()
                            p(code)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1081#1294")))
                end
            end
            begin
                var"##return#1080" = begin
                        inline(ex)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#1081#1294")))
            end
            error("matching non-exhaustive, at #= none:246 =#")
            $(Expr(:symboliclabel, Symbol("####final#1081#1294")))
            var"##return#1080"
        end
        return nothing
    end
    #= none:468 =# Core.@doc "    print_expr([io::IO], ex; kw...)\n\nPrint a given expression. `ex` can be a `Expr` or a syntax type `JLExpr`.\n" print_expr(io::IO, ex; kw...) = begin
                (Printer(io; kw...))(ex)
            end
    print_expr(ex; kw...) = begin
            print_expr(stdout, ex; kw...)
        end
