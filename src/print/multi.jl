
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
                    var"##cache#1064" = nothing
                end
                var"##return#1061" = nothing
                var"##1063" = otherwise
                if var"##1063" isa Expr && (begin
                                if var"##cache#1064" === nothing
                                    var"##cache#1064" = Some(((var"##1063").head, (var"##1063").args))
                                end
                                var"##1065" = (var"##cache#1064").value
                                var"##1065" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1065"[1] == :block && (begin
                                        var"##1066" = var"##1065"[2]
                                        var"##1066" isa AbstractArray
                                    end && ((ndims(var"##1066") === 1 && length(var"##1066") >= 0) && begin
                                            var"##1067" = SubArray(var"##1066", (1:length(var"##1066"),))
                                            true
                                        end))))
                    var"##return#1061" = let stmts = var"##1067"
                            indent() do 
                                print_stmts(stmts)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1062#1068")))
                end
                begin
                    var"##return#1061" = let
                            indent() do 
                                tab()
                                no_first_line_indent() do 
                                    p(otherwise)
                                end
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1062#1068")))
                end
                error("matching non-exhaustive, at #= none:98 =#")
                $(Expr(:symboliclabel, Symbol("####final#1062#1068")))
                var"##return#1061"
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
                            var"##cache#1072" = nothing
                        end
                        var"##return#1069" = nothing
                        var"##1071" = stmt
                        if var"##1071" isa Expr && (begin
                                        if var"##cache#1072" === nothing
                                            var"##cache#1072" = Some(((var"##1071").head, (var"##1071").args))
                                        end
                                        var"##1073" = (var"##cache#1072").value
                                        var"##1073" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##1073"[1] == :macrocall && (begin
                                                var"##1074" = var"##1073"[2]
                                                var"##1074" isa AbstractArray
                                            end && ((ndims(var"##1074") === 1 && length(var"##1074") >= 1) && begin
                                                    var"##1075" = var"##1074"[1]
                                                    var"##1075" == Symbol("@case")
                                                end))))
                            var"##return#1069" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1070#1076")))
                        end
                        begin
                            var"##return#1069" = let
                                    false
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1070#1076")))
                        end
                        error("matching non-exhaustive, at #= none:181 =#")
                        $(Expr(:symboliclabel, Symbol("####final#1070#1076")))
                        var"##return#1069"
                    end
                end || return print_macrocall("@switch", line, (item, Expr(:block, stmts...)))
            is_case(stmt) = begin
                    let
                        begin
                            var"##cache#1080" = nothing
                        end
                        var"##return#1077" = nothing
                        var"##1079" = stmt
                        if var"##1079" isa Expr && (begin
                                        if var"##cache#1080" === nothing
                                            var"##cache#1080" = Some(((var"##1079").head, (var"##1079").args))
                                        end
                                        var"##1081" = (var"##cache#1080").value
                                        var"##1081" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##1081"[1] == :macrocall && (begin
                                                var"##1082" = var"##1081"[2]
                                                var"##1082" isa AbstractArray
                                            end && ((ndims(var"##1082") === 1 && length(var"##1082") >= 1) && begin
                                                    var"##1083" = var"##1082"[1]
                                                    var"##1083" == Symbol("@case")
                                                end))))
                            var"##return#1077" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1078#1084")))
                        end
                        begin
                            var"##return#1077" = let
                                    false
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1078#1084")))
                        end
                        error("matching non-exhaustive, at #= none:187 =#")
                        $(Expr(:symboliclabel, Symbol("####final#1078#1084")))
                        var"##return#1077"
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
                            var"##cache#1088" = nothing
                        end
                        var"##return#1085" = nothing
                        var"##1087" = stmt
                        if var"##1087" isa Expr && (begin
                                        if var"##cache#1088" === nothing
                                            var"##cache#1088" = Some(((var"##1087").head, (var"##1087").args))
                                        end
                                        var"##1089" = (var"##cache#1088").value
                                        var"##1089" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##1089"[1] == :macrocall && (begin
                                                var"##1090" = var"##1089"[2]
                                                var"##1090" isa AbstractArray
                                            end && (length(var"##1090") === 3 && (begin
                                                        var"##1091" = var"##1090"[1]
                                                        var"##1091" == Symbol("@case")
                                                    end && begin
                                                        var"##1092" = var"##1090"[2]
                                                        var"##1093" = var"##1090"[3]
                                                        true
                                                    end)))))
                            var"##return#1085" = let pattern = var"##1093", line = var"##1092"
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
                            $(Expr(:symbolicgoto, Symbol("####final#1086#1094")))
                        end
                        begin
                            var"##return#1085" = let
                                    p(stmt)
                                    println()
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1086#1094")))
                        end
                        error("matching non-exhaustive, at #= none:197 =#")
                        $(Expr(:symboliclabel, Symbol("####final#1086#1094")))
                        var"##return#1085"
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
                var"##cache#1098" = nothing
            end
            var"##1097" = ex
            if var"##1097" isa Expr
                if begin
                            if var"##cache#1098" === nothing
                                var"##cache#1098" = Some(((var"##1097").head, (var"##1097").args))
                            end
                            var"##1099" = (var"##cache#1098").value
                            var"##1099" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1099"[1] == :string && (begin
                                    var"##1100" = var"##1099"[2]
                                    var"##1100" isa AbstractArray
                                end && ((ndims(var"##1100") === 1 && length(var"##1100") >= 0) && begin
                                        var"##1101" = SubArray(var"##1100", (1:length(var"##1100"),))
                                        true
                                    end)))
                    args = var"##1101"
                    var"##return#1095" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1096#1300")))
                end
                if begin
                            var"##1102" = (var"##cache#1098").value
                            var"##1102" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1102"[1] == :block && (begin
                                    var"##1103" = var"##1102"[2]
                                    var"##1103" isa AbstractArray
                                end && ((ndims(var"##1103") === 1 && length(var"##1103") >= 0) && begin
                                        var"##1104" = SubArray(var"##1103", (1:length(var"##1103"),))
                                        true
                                    end)))
                    stmts = var"##1104"
                    var"##return#1095" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1096#1300")))
                end
                if begin
                            var"##1105" = (var"##cache#1098").value
                            var"##1105" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1105"[1] == :quote && (begin
                                    var"##1106" = var"##1105"[2]
                                    var"##1106" isa AbstractArray
                                end && (length(var"##1106") === 1 && (begin
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
                                                    end && ((ndims(var"##1110") === 1 && length(var"##1110") >= 0) && begin
                                                            var"##1111" = SubArray(var"##1110", (1:length(var"##1110"),))
                                                            let stmts = var"##1111"
                                                                is_root()
                                                            end
                                                        end))))))))
                    stmts = var"##1111"
                    var"##return#1095" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1096#1300")))
                end
                if begin
                            var"##1112" = (var"##cache#1098").value
                            var"##1112" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1112"[1] == :quote && (begin
                                    var"##1113" = var"##1112"[2]
                                    var"##1113" isa AbstractArray
                                end && (length(var"##1113") === 1 && (begin
                                            begin
                                                var"##cache#1115" = nothing
                                            end
                                            var"##1114" = var"##1113"[1]
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
                                                        end))))))))
                    stmts = var"##1118"
                    var"##return#1095" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1096#1300")))
                end
                if begin
                            var"##1119" = (var"##cache#1098").value
                            var"##1119" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1119"[1] == :quote && (begin
                                    var"##1120" = var"##1119"[2]
                                    var"##1120" isa AbstractArray
                                end && (length(var"##1120") === 1 && begin
                                        var"##1121" = var"##1120"[1]
                                        true
                                    end)))
                    code = var"##1121"
                    var"##return#1095" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1096#1300")))
                end
                if begin
                            var"##1122" = (var"##cache#1098").value
                            var"##1122" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1122"[1] == :let && (begin
                                    var"##1123" = var"##1122"[2]
                                    var"##1123" isa AbstractArray
                                end && (length(var"##1123") === 2 && (begin
                                            begin
                                                var"##cache#1125" = nothing
                                            end
                                            var"##1124" = var"##1123"[1]
                                            var"##1124" isa Expr
                                        end && (begin
                                                if var"##cache#1125" === nothing
                                                    var"##cache#1125" = Some(((var"##1124").head, (var"##1124").args))
                                                end
                                                var"##1126" = (var"##cache#1125").value
                                                var"##1126" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1126"[1] == :block && (begin
                                                        var"##1127" = var"##1126"[2]
                                                        var"##1127" isa AbstractArray
                                                    end && ((ndims(var"##1127") === 1 && length(var"##1127") >= 0) && (begin
                                                                var"##1128" = SubArray(var"##1127", (1:length(var"##1127"),))
                                                                begin
                                                                    var"##cache#1130" = nothing
                                                                end
                                                                var"##1129" = var"##1123"[2]
                                                                var"##1129" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1130" === nothing
                                                                        var"##cache#1130" = Some(((var"##1129").head, (var"##1129").args))
                                                                    end
                                                                    var"##1131" = (var"##cache#1130").value
                                                                    var"##1131" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1131"[1] == :block && (begin
                                                                            var"##1132" = var"##1131"[2]
                                                                            var"##1132" isa AbstractArray
                                                                        end && ((ndims(var"##1132") === 1 && length(var"##1132") >= 0) && begin
                                                                                var"##1133" = SubArray(var"##1132", (1:length(var"##1132"),))
                                                                                true
                                                                            end)))))))))))))
                    args = var"##1128"
                    stmts = var"##1133"
                    var"##return#1095" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1096#1300")))
                end
                if begin
                            var"##1134" = (var"##cache#1098").value
                            var"##1134" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1134"[1] == :if && (begin
                                    var"##1135" = var"##1134"[2]
                                    var"##1135" isa AbstractArray
                                end && (length(var"##1135") === 2 && begin
                                        var"##1136" = var"##1135"[1]
                                        var"##1137" = var"##1135"[2]
                                        true
                                    end)))
                    cond = var"##1136"
                    body = var"##1137"
                    var"##return#1095" = begin
                            print_if(cond, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1096#1300")))
                end
                if begin
                            var"##1138" = (var"##cache#1098").value
                            var"##1138" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1138"[1] == :if && (begin
                                    var"##1139" = var"##1138"[2]
                                    var"##1139" isa AbstractArray
                                end && (length(var"##1139") === 3 && begin
                                        var"##1140" = var"##1139"[1]
                                        var"##1141" = var"##1139"[2]
                                        var"##1142" = var"##1139"[3]
                                        true
                                    end)))
                    cond = var"##1140"
                    body = var"##1141"
                    otherwise = var"##1142"
                    var"##return#1095" = begin
                            print_if(cond, body, otherwise)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1096#1300")))
                end
                if begin
                            var"##1143" = (var"##cache#1098").value
                            var"##1143" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1143"[1] == :elseif && (begin
                                    var"##1144" = var"##1143"[2]
                                    var"##1144" isa AbstractArray
                                end && (length(var"##1144") === 2 && (begin
                                            begin
                                                var"##cache#1146" = nothing
                                            end
                                            var"##1145" = var"##1144"[1]
                                            var"##1145" isa Expr
                                        end && (begin
                                                if var"##cache#1146" === nothing
                                                    var"##cache#1146" = Some(((var"##1145").head, (var"##1145").args))
                                                end
                                                var"##1147" = (var"##cache#1146").value
                                                var"##1147" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1147"[1] == :block && (begin
                                                        var"##1148" = var"##1147"[2]
                                                        var"##1148" isa AbstractArray
                                                    end && (length(var"##1148") === 2 && begin
                                                            var"##1149" = var"##1148"[1]
                                                            var"##1150" = var"##1148"[2]
                                                            var"##1151" = var"##1144"[2]
                                                            true
                                                        end))))))))
                    line = var"##1149"
                    cond = var"##1150"
                    body = var"##1151"
                    var"##return#1095" = begin
                            print_elseif(cond, body, line)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1096#1300")))
                end
                if begin
                            var"##1152" = (var"##cache#1098").value
                            var"##1152" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1152"[1] == :elseif && (begin
                                    var"##1153" = var"##1152"[2]
                                    var"##1153" isa AbstractArray
                                end && (length(var"##1153") === 2 && begin
                                        var"##1154" = var"##1153"[1]
                                        var"##1155" = var"##1153"[2]
                                        true
                                    end)))
                    cond = var"##1154"
                    body = var"##1155"
                    var"##return#1095" = begin
                            print_elseif(cond, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1096#1300")))
                end
                if begin
                            var"##1156" = (var"##cache#1098").value
                            var"##1156" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1156"[1] == :elseif && (begin
                                    var"##1157" = var"##1156"[2]
                                    var"##1157" isa AbstractArray
                                end && (length(var"##1157") === 3 && (begin
                                            begin
                                                var"##cache#1159" = nothing
                                            end
                                            var"##1158" = var"##1157"[1]
                                            var"##1158" isa Expr
                                        end && (begin
                                                if var"##cache#1159" === nothing
                                                    var"##cache#1159" = Some(((var"##1158").head, (var"##1158").args))
                                                end
                                                var"##1160" = (var"##cache#1159").value
                                                var"##1160" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1160"[1] == :block && (begin
                                                        var"##1161" = var"##1160"[2]
                                                        var"##1161" isa AbstractArray
                                                    end && (length(var"##1161") === 2 && begin
                                                            var"##1162" = var"##1161"[1]
                                                            var"##1163" = var"##1161"[2]
                                                            var"##1164" = var"##1157"[2]
                                                            var"##1165" = var"##1157"[3]
                                                            true
                                                        end))))))))
                    line = var"##1162"
                    cond = var"##1163"
                    body = var"##1164"
                    otherwise = var"##1165"
                    var"##return#1095" = begin
                            print_elseif(cond, body, line, otherwise)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1096#1300")))
                end
                if begin
                            var"##1166" = (var"##cache#1098").value
                            var"##1166" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1166"[1] == :elseif && (begin
                                    var"##1167" = var"##1166"[2]
                                    var"##1167" isa AbstractArray
                                end && (length(var"##1167") === 3 && begin
                                        var"##1168" = var"##1167"[1]
                                        var"##1169" = var"##1167"[2]
                                        var"##1170" = var"##1167"[3]
                                        true
                                    end)))
                    cond = var"##1168"
                    body = var"##1169"
                    otherwise = var"##1170"
                    var"##return#1095" = begin
                            print_elseif(cond, body, nothing, otherwise)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1096#1300")))
                end
                if begin
                            var"##1171" = (var"##cache#1098").value
                            var"##1171" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1171"[1] == :for && (begin
                                    var"##1172" = var"##1171"[2]
                                    var"##1172" isa AbstractArray
                                end && (length(var"##1172") === 2 && begin
                                        var"##1173" = var"##1172"[1]
                                        var"##1174" = var"##1172"[2]
                                        true
                                    end)))
                    body = var"##1174"
                    iteration = var"##1173"
                    var"##return#1095" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1096#1300")))
                end
                if begin
                            var"##1175" = (var"##cache#1098").value
                            var"##1175" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1175"[1] == :while && (begin
                                    var"##1176" = var"##1175"[2]
                                    var"##1176" isa AbstractArray
                                end && (length(var"##1176") === 2 && begin
                                        var"##1177" = var"##1176"[1]
                                        var"##1178" = var"##1176"[2]
                                        true
                                    end)))
                    cond = var"##1177"
                    body = var"##1178"
                    var"##return#1095" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1096#1300")))
                end
                if begin
                            var"##1179" = (var"##cache#1098").value
                            var"##1179" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1179"[1] == :(=) && (begin
                                    var"##1180" = var"##1179"[2]
                                    var"##1180" isa AbstractArray
                                end && (length(var"##1180") === 2 && (begin
                                            var"##1181" = var"##1180"[1]
                                            begin
                                                var"##cache#1183" = nothing
                                            end
                                            var"##1182" = var"##1180"[2]
                                            var"##1182" isa Expr
                                        end && (begin
                                                if var"##cache#1183" === nothing
                                                    var"##cache#1183" = Some(((var"##1182").head, (var"##1182").args))
                                                end
                                                var"##1184" = (var"##cache#1183").value
                                                var"##1184" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1184"[1] == :block && (begin
                                                        var"##1185" = var"##1184"[2]
                                                        var"##1185" isa AbstractArray
                                                    end && (length(var"##1185") === 2 && (begin
                                                                var"##1186" = var"##1185"[1]
                                                                begin
                                                                    var"##cache#1188" = nothing
                                                                end
                                                                var"##1187" = var"##1185"[2]
                                                                var"##1187" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1188" === nothing
                                                                        var"##cache#1188" = Some(((var"##1187").head, (var"##1187").args))
                                                                    end
                                                                    var"##1189" = (var"##cache#1188").value
                                                                    var"##1189" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1189"[1] == :if && (begin
                                                                            var"##1190" = var"##1189"[2]
                                                                            var"##1190" isa AbstractArray
                                                                        end && ((ndims(var"##1190") === 1 && length(var"##1190") >= 0) && let line = var"##1186", lhs = var"##1181"
                                                                                is_line_no(line)
                                                                            end)))))))))))))
                    line = var"##1186"
                    lhs = var"##1181"
                    var"##return#1095" = begin
                            leading_tab()
                            inline(lhs)
                            keyword(" = ")
                            inline(line)
                            p(ex.args[2])
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1096#1300")))
                end
                if begin
                            var"##1191" = (var"##cache#1098").value
                            var"##1191" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1191"[1] == :(=) && (begin
                                    var"##1192" = var"##1191"[2]
                                    var"##1192" isa AbstractArray
                                end && (length(var"##1192") === 2 && (begin
                                            var"##1193" = var"##1192"[1]
                                            begin
                                                var"##cache#1195" = nothing
                                            end
                                            var"##1194" = var"##1192"[2]
                                            var"##1194" isa Expr
                                        end && (begin
                                                if var"##cache#1195" === nothing
                                                    var"##cache#1195" = Some(((var"##1194").head, (var"##1194").args))
                                                end
                                                var"##1196" = (var"##cache#1195").value
                                                var"##1196" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1196"[1] == :block && (begin
                                                        var"##1197" = var"##1196"[2]
                                                        var"##1197" isa AbstractArray
                                                    end && (length(var"##1197") === 2 && begin
                                                            var"##1198" = var"##1197"[1]
                                                            var"##1199" = var"##1197"[2]
                                                            let rhs = var"##1199", line = var"##1198", lhs = var"##1193"
                                                                is_line_no(line)
                                                            end
                                                        end))))))))
                    rhs = var"##1199"
                    line = var"##1198"
                    lhs = var"##1193"
                    var"##return#1095" = begin
                            leading_tab()
                            inline(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1096#1300")))
                end
                if begin
                            var"##1200" = (var"##cache#1098").value
                            var"##1200" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1200"[1] == :(=) && (begin
                                    var"##1201" = var"##1200"[2]
                                    var"##1201" isa AbstractArray
                                end && (length(var"##1201") === 2 && begin
                                        var"##1202" = var"##1201"[1]
                                        var"##1203" = var"##1201"[2]
                                        true
                                    end)))
                    rhs = var"##1203"
                    lhs = var"##1202"
                    var"##return#1095" = begin
                            leading_tab()
                            inline(lhs)
                            print(" = ")
                            p(rhs)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1096#1300")))
                end
                if begin
                            var"##1204" = (var"##cache#1098").value
                            var"##1204" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1204"[1] == :function && (begin
                                    var"##1205" = var"##1204"[2]
                                    var"##1205" isa AbstractArray
                                end && (length(var"##1205") === 2 && begin
                                        var"##1206" = var"##1205"[1]
                                        var"##1207" = var"##1205"[2]
                                        true
                                    end)))
                    call = var"##1206"
                    body = var"##1207"
                    var"##return#1095" = begin
                            print_function(:function, call, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1096#1300")))
                end
                if begin
                            var"##1208" = (var"##cache#1098").value
                            var"##1208" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1208"[1] == :-> && (begin
                                    var"##1209" = var"##1208"[2]
                                    var"##1209" isa AbstractArray
                                end && (length(var"##1209") === 2 && begin
                                        var"##1210" = var"##1209"[1]
                                        var"##1211" = var"##1209"[2]
                                        true
                                    end)))
                    call = var"##1210"
                    body = var"##1211"
                    var"##return#1095" = begin
                            leading_tab()
                            inline(call)
                            keyword(" -> ")
                            p(body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1096#1300")))
                end
                if begin
                            var"##1212" = (var"##cache#1098").value
                            var"##1212" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1212"[1] == :do && (begin
                                    var"##1213" = var"##1212"[2]
                                    var"##1213" isa AbstractArray
                                end && (length(var"##1213") === 2 && (begin
                                            var"##1214" = var"##1213"[1]
                                            begin
                                                var"##cache#1216" = nothing
                                            end
                                            var"##1215" = var"##1213"[2]
                                            var"##1215" isa Expr
                                        end && (begin
                                                if var"##cache#1216" === nothing
                                                    var"##cache#1216" = Some(((var"##1215").head, (var"##1215").args))
                                                end
                                                var"##1217" = (var"##cache#1216").value
                                                var"##1217" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1217"[1] == :-> && (begin
                                                        var"##1218" = var"##1217"[2]
                                                        var"##1218" isa AbstractArray
                                                    end && (length(var"##1218") === 2 && (begin
                                                                begin
                                                                    var"##cache#1220" = nothing
                                                                end
                                                                var"##1219" = var"##1218"[1]
                                                                var"##1219" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1220" === nothing
                                                                        var"##cache#1220" = Some(((var"##1219").head, (var"##1219").args))
                                                                    end
                                                                    var"##1221" = (var"##cache#1220").value
                                                                    var"##1221" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1221"[1] == :tuple && (begin
                                                                            var"##1222" = var"##1221"[2]
                                                                            var"##1222" isa AbstractArray
                                                                        end && ((ndims(var"##1222") === 1 && length(var"##1222") >= 0) && begin
                                                                                var"##1223" = SubArray(var"##1222", (1:length(var"##1222"),))
                                                                                var"##1224" = var"##1218"[2]
                                                                                true
                                                                            end)))))))))))))
                    call = var"##1214"
                    args = var"##1223"
                    body = var"##1224"
                    var"##return#1095" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1096#1300")))
                end
                if begin
                            var"##1225" = (var"##cache#1098").value
                            var"##1225" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1225"[1] == :macro && (begin
                                    var"##1226" = var"##1225"[2]
                                    var"##1226" isa AbstractArray
                                end && (length(var"##1226") === 2 && begin
                                        var"##1227" = var"##1226"[1]
                                        var"##1228" = var"##1226"[2]
                                        true
                                    end)))
                    call = var"##1227"
                    body = var"##1228"
                    var"##return#1095" = begin
                            print_function(:macro, call, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1096#1300")))
                end
                if begin
                            var"##1229" = (var"##cache#1098").value
                            var"##1229" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1229"[1] == :macrocall && (begin
                                    var"##1230" = var"##1229"[2]
                                    var"##1230" isa AbstractArray
                                end && (length(var"##1230") === 4 && (begin
                                            var"##1231" = var"##1230"[1]
                                            var"##1231" == Symbol("@switch")
                                        end && (begin
                                                var"##1232" = var"##1230"[2]
                                                var"##1233" = var"##1230"[3]
                                                begin
                                                    var"##cache#1235" = nothing
                                                end
                                                var"##1234" = var"##1230"[4]
                                                var"##1234" isa Expr
                                            end && (begin
                                                    if var"##cache#1235" === nothing
                                                        var"##cache#1235" = Some(((var"##1234").head, (var"##1234").args))
                                                    end
                                                    var"##1236" = (var"##cache#1235").value
                                                    var"##1236" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1236"[1] == :block && (begin
                                                            var"##1237" = var"##1236"[2]
                                                            var"##1237" isa AbstractArray
                                                        end && ((ndims(var"##1237") === 1 && length(var"##1237") >= 0) && begin
                                                                var"##1238" = SubArray(var"##1237", (1:length(var"##1237"),))
                                                                true
                                                            end)))))))))
                    item = var"##1233"
                    line = var"##1232"
                    stmts = var"##1238"
                    var"##return#1095" = begin
                            print_switch(item, line, stmts)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1096#1300")))
                end
                if begin
                            var"##1239" = (var"##cache#1098").value
                            var"##1239" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1239"[1] == :macrocall && (begin
                                    var"##1240" = var"##1239"[2]
                                    var"##1240" isa AbstractArray
                                end && (length(var"##1240") === 4 && (begin
                                            var"##1241" = var"##1240"[1]
                                            var"##1241" == GlobalRef(Core, Symbol("@doc"))
                                        end && begin
                                            var"##1242" = var"##1240"[2]
                                            var"##1243" = var"##1240"[3]
                                            var"##1244" = var"##1240"[4]
                                            true
                                        end))))
                    line = var"##1242"
                    code = var"##1244"
                    doc = var"##1243"
                    var"##return#1095" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1096#1300")))
                end
                if begin
                            var"##1245" = (var"##cache#1098").value
                            var"##1245" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1245"[1] == :macrocall && (begin
                                    var"##1246" = var"##1245"[2]
                                    var"##1246" isa AbstractArray
                                end && ((ndims(var"##1246") === 1 && length(var"##1246") >= 2) && begin
                                        var"##1247" = var"##1246"[1]
                                        var"##1248" = var"##1246"[2]
                                        var"##1249" = SubArray(var"##1246", (3:length(var"##1246"),))
                                        true
                                    end)))
                    line = var"##1248"
                    name = var"##1247"
                    args = var"##1249"
                    var"##return#1095" = begin
                            print_macrocall(name, line, args)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1096#1300")))
                end
                if begin
                            var"##1250" = (var"##cache#1098").value
                            var"##1250" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1250"[1] == :struct && (begin
                                    var"##1251" = var"##1250"[2]
                                    var"##1251" isa AbstractArray
                                end && (length(var"##1251") === 3 && begin
                                        var"##1252" = var"##1251"[1]
                                        var"##1253" = var"##1251"[2]
                                        var"##1254" = var"##1251"[3]
                                        true
                                    end)))
                    ismutable = var"##1252"
                    body = var"##1254"
                    head = var"##1253"
                    var"##return#1095" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1096#1300")))
                end
                if begin
                            var"##1255" = (var"##cache#1098").value
                            var"##1255" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1255"[1] == :try && (begin
                                    var"##1256" = var"##1255"[2]
                                    var"##1256" isa AbstractArray
                                end && (length(var"##1256") === 3 && begin
                                        var"##1257" = var"##1256"[1]
                                        var"##1258" = var"##1256"[2]
                                        var"##1259" = var"##1256"[3]
                                        true
                                    end)))
                    catch_vars = var"##1258"
                    catch_body = var"##1259"
                    try_body = var"##1257"
                    var"##return#1095" = begin
                            print_try(try_body)
                            print_catch(catch_body, catch_vars)
                            println()
                            tab()
                            keyword("end")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1096#1300")))
                end
                if begin
                            var"##1260" = (var"##cache#1098").value
                            var"##1260" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1260"[1] == :try && (begin
                                    var"##1261" = var"##1260"[2]
                                    var"##1261" isa AbstractArray
                                end && (length(var"##1261") === 4 && begin
                                        var"##1262" = var"##1261"[1]
                                        var"##1263" = var"##1261"[2]
                                        var"##1264" = var"##1261"[3]
                                        var"##1265" = var"##1261"[4]
                                        true
                                    end)))
                    catch_vars = var"##1263"
                    catch_body = var"##1264"
                    try_body = var"##1262"
                    finally_body = var"##1265"
                    var"##return#1095" = begin
                            print_try(try_body)
                            print_catch(catch_body, catch_vars)
                            print_finally(finally_body)
                            println()
                            tab()
                            keyword("end")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1096#1300")))
                end
                if begin
                            var"##1266" = (var"##cache#1098").value
                            var"##1266" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1266"[1] == :try && (begin
                                    var"##1267" = var"##1266"[2]
                                    var"##1267" isa AbstractArray
                                end && (length(var"##1267") === 5 && begin
                                        var"##1268" = var"##1267"[1]
                                        var"##1269" = var"##1267"[2]
                                        var"##1270" = var"##1267"[3]
                                        var"##1271" = var"##1267"[4]
                                        var"##1272" = var"##1267"[5]
                                        true
                                    end)))
                    catch_vars = var"##1269"
                    catch_body = var"##1270"
                    try_body = var"##1268"
                    finally_body = var"##1271"
                    else_body = var"##1272"
                    var"##return#1095" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1096#1300")))
                end
                if begin
                            var"##1273" = (var"##cache#1098").value
                            var"##1273" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1273"[1] == :module && (begin
                                    var"##1274" = var"##1273"[2]
                                    var"##1274" isa AbstractArray
                                end && (length(var"##1274") === 3 && begin
                                        var"##1275" = var"##1274"[1]
                                        var"##1276" = var"##1274"[2]
                                        var"##1277" = var"##1274"[3]
                                        true
                                    end)))
                    name = var"##1276"
                    body = var"##1277"
                    notbare = var"##1275"
                    var"##return#1095" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1096#1300")))
                end
                if begin
                            var"##1278" = (var"##cache#1098").value
                            var"##1278" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1278"[1] == :const && (begin
                                    var"##1279" = var"##1278"[2]
                                    var"##1279" isa AbstractArray
                                end && (length(var"##1279") === 1 && begin
                                        var"##1280" = var"##1279"[1]
                                        true
                                    end)))
                    code = var"##1280"
                    var"##return#1095" = begin
                            leading_tab()
                            keyword("const ")
                            p(code)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1096#1300")))
                end
                if begin
                            var"##1281" = (var"##cache#1098").value
                            var"##1281" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1281"[1] == :return && (begin
                                    var"##1282" = var"##1281"[2]
                                    var"##1282" isa AbstractArray
                                end && (length(var"##1282") === 1 && (begin
                                            begin
                                                var"##cache#1284" = nothing
                                            end
                                            var"##1283" = var"##1282"[1]
                                            var"##1283" isa Expr
                                        end && (begin
                                                if var"##cache#1284" === nothing
                                                    var"##cache#1284" = Some(((var"##1283").head, (var"##1283").args))
                                                end
                                                var"##1285" = (var"##cache#1284").value
                                                var"##1285" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1285"[1] == :tuple && (begin
                                                        var"##1286" = var"##1285"[2]
                                                        var"##1286" isa AbstractArray
                                                    end && ((ndims(var"##1286") === 1 && length(var"##1286") >= 1) && (begin
                                                                begin
                                                                    var"##cache#1288" = nothing
                                                                end
                                                                var"##1287" = var"##1286"[1]
                                                                var"##1287" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1288" === nothing
                                                                        var"##cache#1288" = Some(((var"##1287").head, (var"##1287").args))
                                                                    end
                                                                    var"##1289" = (var"##cache#1288").value
                                                                    var"##1289" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1289"[1] == :parameters && (begin
                                                                            var"##1290" = var"##1289"[2]
                                                                            var"##1290" isa AbstractArray
                                                                        end && (ndims(var"##1290") === 1 && length(var"##1290") >= 0)))))))))))))
                    var"##return#1095" = begin
                            inline(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1096#1300")))
                end
                if begin
                            var"##1291" = (var"##cache#1098").value
                            var"##1291" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1291"[1] == :return && (begin
                                    var"##1292" = var"##1291"[2]
                                    var"##1292" isa AbstractArray
                                end && (length(var"##1292") === 1 && (begin
                                            begin
                                                var"##cache#1294" = nothing
                                            end
                                            var"##1293" = var"##1292"[1]
                                            var"##1293" isa Expr
                                        end && (begin
                                                if var"##cache#1294" === nothing
                                                    var"##cache#1294" = Some(((var"##1293").head, (var"##1293").args))
                                                end
                                                var"##1295" = (var"##cache#1294").value
                                                var"##1295" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1295"[1] == :tuple && (begin
                                                        var"##1296" = var"##1295"[2]
                                                        var"##1296" isa AbstractArray
                                                    end && (ndims(var"##1296") === 1 && length(var"##1296") >= 0))))))))
                    var"##return#1095" = begin
                            inline(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1096#1300")))
                end
                if begin
                            var"##1297" = (var"##cache#1098").value
                            var"##1297" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1297"[1] == :return && (begin
                                    var"##1298" = var"##1297"[2]
                                    var"##1298" isa AbstractArray
                                end && (length(var"##1298") === 1 && begin
                                        var"##1299" = var"##1298"[1]
                                        true
                                    end)))
                    code = var"##1299"
                    var"##return#1095" = begin
                            leading_tab()
                            keyword("return ")
                            p(code)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1096#1300")))
                end
            end
            if var"##1097" isa String
                begin
                    var"##return#1095" = begin
                            leading_tab()
                            occursin('\n', ex) || return inline(ex)
                            printstyled("\"\"\"\n", color = c.string)
                            tab()
                            print_multi_lines(ex)
                            printstyled("\"\"\"", color = c.string)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1096#1300")))
                end
            end
            begin
                var"##return#1095" = begin
                        inline(ex)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#1096#1300")))
            end
            error("matching non-exhaustive, at #= none:246 =#")
            $(Expr(:symboliclabel, Symbol("####final#1096#1300")))
            var"##return#1095"
        end
        return nothing
    end
    #= none:464 =# Core.@doc "    print_expr([io::IO], ex; kw...)\n\nPrint a given expression. `ex` can be a `Expr` or a syntax type `JLExpr`.\n" print_expr(io::IO, ex; kw...) = begin
                (Printer(io; kw...))(ex)
            end
    print_expr(ex; kw...) = begin
            print_expr(stdout, ex; kw...)
        end
