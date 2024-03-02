
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
                    var"##cache#1069" = nothing
                end
                var"##return#1066" = nothing
                var"##1068" = otherwise
                if var"##1068" isa Expr && (begin
                                if var"##cache#1069" === nothing
                                    var"##cache#1069" = Some(((var"##1068").head, (var"##1068").args))
                                end
                                var"##1070" = (var"##cache#1069").value
                                var"##1070" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1070"[1] == :block && (begin
                                        var"##1071" = var"##1070"[2]
                                        var"##1071" isa AbstractArray
                                    end && ((ndims(var"##1071") === 1 && length(var"##1071") >= 0) && begin
                                            var"##1072" = SubArray(var"##1071", (1:length(var"##1071"),))
                                            true
                                        end))))
                    var"##return#1066" = let stmts = var"##1072"
                            indent() do 
                                print_stmts(stmts)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1067#1073")))
                end
                begin
                    var"##return#1066" = let
                            indent() do 
                                tab()
                                no_first_line_indent() do 
                                    p(otherwise)
                                end
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1067#1073")))
                end
                error("matching non-exhaustive, at #= none:98 =#")
                $(Expr(:symboliclabel, Symbol("####final#1067#1073")))
                var"##return#1066"
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
                            var"##cache#1077" = nothing
                        end
                        var"##return#1074" = nothing
                        var"##1076" = stmt
                        if var"##1076" isa Expr && (begin
                                        if var"##cache#1077" === nothing
                                            var"##cache#1077" = Some(((var"##1076").head, (var"##1076").args))
                                        end
                                        var"##1078" = (var"##cache#1077").value
                                        var"##1078" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##1078"[1] == :macrocall && (begin
                                                var"##1079" = var"##1078"[2]
                                                var"##1079" isa AbstractArray
                                            end && ((ndims(var"##1079") === 1 && length(var"##1079") >= 1) && begin
                                                    var"##1080" = var"##1079"[1]
                                                    var"##1080" == Symbol("@case")
                                                end))))
                            var"##return#1074" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1075#1081")))
                        end
                        begin
                            var"##return#1074" = let
                                    false
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1075#1081")))
                        end
                        error("matching non-exhaustive, at #= none:181 =#")
                        $(Expr(:symboliclabel, Symbol("####final#1075#1081")))
                        var"##return#1074"
                    end
                end || return print_macrocall("@switch", line, (item, Expr(:block, stmts...)))
            is_case(stmt) = begin
                    let
                        begin
                            var"##cache#1085" = nothing
                        end
                        var"##return#1082" = nothing
                        var"##1084" = stmt
                        if var"##1084" isa Expr && (begin
                                        if var"##cache#1085" === nothing
                                            var"##cache#1085" = Some(((var"##1084").head, (var"##1084").args))
                                        end
                                        var"##1086" = (var"##cache#1085").value
                                        var"##1086" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##1086"[1] == :macrocall && (begin
                                                var"##1087" = var"##1086"[2]
                                                var"##1087" isa AbstractArray
                                            end && ((ndims(var"##1087") === 1 && length(var"##1087") >= 1) && begin
                                                    var"##1088" = var"##1087"[1]
                                                    var"##1088" == Symbol("@case")
                                                end))))
                            var"##return#1082" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1083#1089")))
                        end
                        begin
                            var"##return#1082" = let
                                    false
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1083#1089")))
                        end
                        error("matching non-exhaustive, at #= none:187 =#")
                        $(Expr(:symboliclabel, Symbol("####final#1083#1089")))
                        var"##return#1082"
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
                            var"##cache#1093" = nothing
                        end
                        var"##return#1090" = nothing
                        var"##1092" = stmt
                        if var"##1092" isa Expr && (begin
                                        if var"##cache#1093" === nothing
                                            var"##cache#1093" = Some(((var"##1092").head, (var"##1092").args))
                                        end
                                        var"##1094" = (var"##cache#1093").value
                                        var"##1094" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##1094"[1] == :macrocall && (begin
                                                var"##1095" = var"##1094"[2]
                                                var"##1095" isa AbstractArray
                                            end && (length(var"##1095") === 3 && (begin
                                                        var"##1096" = var"##1095"[1]
                                                        var"##1096" == Symbol("@case")
                                                    end && begin
                                                        var"##1097" = var"##1095"[2]
                                                        var"##1098" = var"##1095"[3]
                                                        true
                                                    end)))))
                            var"##return#1090" = let pattern = var"##1098", line = var"##1097"
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
                            $(Expr(:symbolicgoto, Symbol("####final#1091#1099")))
                        end
                        begin
                            var"##return#1090" = let
                                    p(stmt)
                                    println()
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1091#1099")))
                        end
                        error("matching non-exhaustive, at #= none:197 =#")
                        $(Expr(:symboliclabel, Symbol("####final#1091#1099")))
                        var"##return#1090"
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
                var"##cache#1103" = nothing
            end
            var"##1102" = ex
            if var"##1102" isa Expr
                if begin
                            if var"##cache#1103" === nothing
                                var"##cache#1103" = Some(((var"##1102").head, (var"##1102").args))
                            end
                            var"##1104" = (var"##cache#1103").value
                            var"##1104" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1104"[1] == :string && (begin
                                    var"##1105" = var"##1104"[2]
                                    var"##1105" isa AbstractArray
                                end && ((ndims(var"##1105") === 1 && length(var"##1105") >= 0) && begin
                                        var"##1106" = SubArray(var"##1105", (1:length(var"##1105"),))
                                        true
                                    end)))
                    args = var"##1106"
                    var"##return#1100" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1101#1308")))
                end
                if begin
                            var"##1107" = (var"##cache#1103").value
                            var"##1107" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1107"[1] == :block && (begin
                                    var"##1108" = var"##1107"[2]
                                    var"##1108" isa AbstractArray
                                end && ((ndims(var"##1108") === 1 && length(var"##1108") >= 0) && begin
                                        var"##1109" = SubArray(var"##1108", (1:length(var"##1108"),))
                                        true
                                    end)))
                    stmts = var"##1109"
                    var"##return#1100" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1101#1308")))
                end
                if begin
                            var"##1110" = (var"##cache#1103").value
                            var"##1110" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1110"[1] == :quote && (begin
                                    var"##1111" = var"##1110"[2]
                                    var"##1111" isa AbstractArray
                                end && (length(var"##1111") === 1 && (begin
                                            begin
                                                var"##cache#1113" = nothing
                                            end
                                            var"##1112" = var"##1111"[1]
                                            var"##1112" isa Expr
                                        end && (begin
                                                if var"##cache#1113" === nothing
                                                    var"##cache#1113" = Some(((var"##1112").head, (var"##1112").args))
                                                end
                                                var"##1114" = (var"##cache#1113").value
                                                var"##1114" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1114"[1] == :block && (begin
                                                        var"##1115" = var"##1114"[2]
                                                        var"##1115" isa AbstractArray
                                                    end && ((ndims(var"##1115") === 1 && length(var"##1115") >= 0) && begin
                                                            var"##1116" = SubArray(var"##1115", (1:length(var"##1115"),))
                                                            let stmts = var"##1116"
                                                                is_root()
                                                            end
                                                        end))))))))
                    stmts = var"##1116"
                    var"##return#1100" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1101#1308")))
                end
                if begin
                            var"##1117" = (var"##cache#1103").value
                            var"##1117" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1117"[1] == :quote && (begin
                                    var"##1118" = var"##1117"[2]
                                    var"##1118" isa AbstractArray
                                end && (length(var"##1118") === 1 && (begin
                                            begin
                                                var"##cache#1120" = nothing
                                            end
                                            var"##1119" = var"##1118"[1]
                                            var"##1119" isa Expr
                                        end && (begin
                                                if var"##cache#1120" === nothing
                                                    var"##cache#1120" = Some(((var"##1119").head, (var"##1119").args))
                                                end
                                                var"##1121" = (var"##cache#1120").value
                                                var"##1121" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1121"[1] == :block && (begin
                                                        var"##1122" = var"##1121"[2]
                                                        var"##1122" isa AbstractArray
                                                    end && ((ndims(var"##1122") === 1 && length(var"##1122") >= 0) && begin
                                                            var"##1123" = SubArray(var"##1122", (1:length(var"##1122"),))
                                                            true
                                                        end))))))))
                    stmts = var"##1123"
                    var"##return#1100" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1101#1308")))
                end
                if begin
                            var"##1124" = (var"##cache#1103").value
                            var"##1124" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1124"[1] == :quote && (begin
                                    var"##1125" = var"##1124"[2]
                                    var"##1125" isa AbstractArray
                                end && (length(var"##1125") === 1 && begin
                                        var"##1126" = var"##1125"[1]
                                        true
                                    end)))
                    code = var"##1126"
                    var"##return#1100" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1101#1308")))
                end
                if begin
                            var"##1127" = (var"##cache#1103").value
                            var"##1127" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1127"[1] == :let && (begin
                                    var"##1128" = var"##1127"[2]
                                    var"##1128" isa AbstractArray
                                end && (length(var"##1128") === 2 && (begin
                                            begin
                                                var"##cache#1130" = nothing
                                            end
                                            var"##1129" = var"##1128"[1]
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
                                                    end && ((ndims(var"##1132") === 1 && length(var"##1132") >= 0) && (begin
                                                                var"##1133" = SubArray(var"##1132", (1:length(var"##1132"),))
                                                                begin
                                                                    var"##cache#1135" = nothing
                                                                end
                                                                var"##1134" = var"##1128"[2]
                                                                var"##1134" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1135" === nothing
                                                                        var"##cache#1135" = Some(((var"##1134").head, (var"##1134").args))
                                                                    end
                                                                    var"##1136" = (var"##cache#1135").value
                                                                    var"##1136" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1136"[1] == :block && (begin
                                                                            var"##1137" = var"##1136"[2]
                                                                            var"##1137" isa AbstractArray
                                                                        end && ((ndims(var"##1137") === 1 && length(var"##1137") >= 0) && begin
                                                                                var"##1138" = SubArray(var"##1137", (1:length(var"##1137"),))
                                                                                true
                                                                            end)))))))))))))
                    args = var"##1133"
                    stmts = var"##1138"
                    var"##return#1100" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1101#1308")))
                end
                if begin
                            var"##1139" = (var"##cache#1103").value
                            var"##1139" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1139"[1] == :if && (begin
                                    var"##1140" = var"##1139"[2]
                                    var"##1140" isa AbstractArray
                                end && (length(var"##1140") === 2 && begin
                                        var"##1141" = var"##1140"[1]
                                        var"##1142" = var"##1140"[2]
                                        true
                                    end)))
                    cond = var"##1141"
                    body = var"##1142"
                    var"##return#1100" = begin
                            print_if(cond, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1101#1308")))
                end
                if begin
                            var"##1143" = (var"##cache#1103").value
                            var"##1143" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1143"[1] == :if && (begin
                                    var"##1144" = var"##1143"[2]
                                    var"##1144" isa AbstractArray
                                end && (length(var"##1144") === 3 && begin
                                        var"##1145" = var"##1144"[1]
                                        var"##1146" = var"##1144"[2]
                                        var"##1147" = var"##1144"[3]
                                        true
                                    end)))
                    cond = var"##1145"
                    body = var"##1146"
                    otherwise = var"##1147"
                    var"##return#1100" = begin
                            print_if(cond, body, otherwise)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1101#1308")))
                end
                if begin
                            var"##1148" = (var"##cache#1103").value
                            var"##1148" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1148"[1] == :elseif && (begin
                                    var"##1149" = var"##1148"[2]
                                    var"##1149" isa AbstractArray
                                end && (length(var"##1149") === 2 && (begin
                                            begin
                                                var"##cache#1151" = nothing
                                            end
                                            var"##1150" = var"##1149"[1]
                                            var"##1150" isa Expr
                                        end && (begin
                                                if var"##cache#1151" === nothing
                                                    var"##cache#1151" = Some(((var"##1150").head, (var"##1150").args))
                                                end
                                                var"##1152" = (var"##cache#1151").value
                                                var"##1152" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1152"[1] == :block && (begin
                                                        var"##1153" = var"##1152"[2]
                                                        var"##1153" isa AbstractArray
                                                    end && (length(var"##1153") === 2 && begin
                                                            var"##1154" = var"##1153"[1]
                                                            var"##1155" = var"##1153"[2]
                                                            var"##1156" = var"##1149"[2]
                                                            true
                                                        end))))))))
                    line = var"##1154"
                    cond = var"##1155"
                    body = var"##1156"
                    var"##return#1100" = begin
                            print_elseif(cond, body, line)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1101#1308")))
                end
                if begin
                            var"##1157" = (var"##cache#1103").value
                            var"##1157" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1157"[1] == :elseif && (begin
                                    var"##1158" = var"##1157"[2]
                                    var"##1158" isa AbstractArray
                                end && (length(var"##1158") === 2 && begin
                                        var"##1159" = var"##1158"[1]
                                        var"##1160" = var"##1158"[2]
                                        true
                                    end)))
                    cond = var"##1159"
                    body = var"##1160"
                    var"##return#1100" = begin
                            print_elseif(cond, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1101#1308")))
                end
                if begin
                            var"##1161" = (var"##cache#1103").value
                            var"##1161" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1161"[1] == :elseif && (begin
                                    var"##1162" = var"##1161"[2]
                                    var"##1162" isa AbstractArray
                                end && (length(var"##1162") === 3 && (begin
                                            begin
                                                var"##cache#1164" = nothing
                                            end
                                            var"##1163" = var"##1162"[1]
                                            var"##1163" isa Expr
                                        end && (begin
                                                if var"##cache#1164" === nothing
                                                    var"##cache#1164" = Some(((var"##1163").head, (var"##1163").args))
                                                end
                                                var"##1165" = (var"##cache#1164").value
                                                var"##1165" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1165"[1] == :block && (begin
                                                        var"##1166" = var"##1165"[2]
                                                        var"##1166" isa AbstractArray
                                                    end && (length(var"##1166") === 2 && begin
                                                            var"##1167" = var"##1166"[1]
                                                            var"##1168" = var"##1166"[2]
                                                            var"##1169" = var"##1162"[2]
                                                            var"##1170" = var"##1162"[3]
                                                            true
                                                        end))))))))
                    line = var"##1167"
                    cond = var"##1168"
                    body = var"##1169"
                    otherwise = var"##1170"
                    var"##return#1100" = begin
                            print_elseif(cond, body, line, otherwise)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1101#1308")))
                end
                if begin
                            var"##1171" = (var"##cache#1103").value
                            var"##1171" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1171"[1] == :elseif && (begin
                                    var"##1172" = var"##1171"[2]
                                    var"##1172" isa AbstractArray
                                end && (length(var"##1172") === 3 && begin
                                        var"##1173" = var"##1172"[1]
                                        var"##1174" = var"##1172"[2]
                                        var"##1175" = var"##1172"[3]
                                        true
                                    end)))
                    cond = var"##1173"
                    body = var"##1174"
                    otherwise = var"##1175"
                    var"##return#1100" = begin
                            print_elseif(cond, body, nothing, otherwise)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1101#1308")))
                end
                if begin
                            var"##1176" = (var"##cache#1103").value
                            var"##1176" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1176"[1] == :for && (begin
                                    var"##1177" = var"##1176"[2]
                                    var"##1177" isa AbstractArray
                                end && (length(var"##1177") === 2 && begin
                                        var"##1178" = var"##1177"[1]
                                        var"##1179" = var"##1177"[2]
                                        true
                                    end)))
                    body = var"##1179"
                    iteration = var"##1178"
                    var"##return#1100" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1101#1308")))
                end
                if begin
                            var"##1180" = (var"##cache#1103").value
                            var"##1180" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1180"[1] == :while && (begin
                                    var"##1181" = var"##1180"[2]
                                    var"##1181" isa AbstractArray
                                end && (length(var"##1181") === 2 && begin
                                        var"##1182" = var"##1181"[1]
                                        var"##1183" = var"##1181"[2]
                                        true
                                    end)))
                    cond = var"##1182"
                    body = var"##1183"
                    var"##return#1100" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1101#1308")))
                end
                if begin
                            var"##1184" = (var"##cache#1103").value
                            var"##1184" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1184"[1] == :(=) && (begin
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
                                            end && (var"##1189"[1] == :block && (begin
                                                        var"##1190" = var"##1189"[2]
                                                        var"##1190" isa AbstractArray
                                                    end && (length(var"##1190") === 2 && (begin
                                                                var"##1191" = var"##1190"[1]
                                                                begin
                                                                    var"##cache#1193" = nothing
                                                                end
                                                                var"##1192" = var"##1190"[2]
                                                                var"##1192" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1193" === nothing
                                                                        var"##cache#1193" = Some(((var"##1192").head, (var"##1192").args))
                                                                    end
                                                                    var"##1194" = (var"##cache#1193").value
                                                                    var"##1194" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1194"[1] == :if && (begin
                                                                            var"##1195" = var"##1194"[2]
                                                                            var"##1195" isa AbstractArray
                                                                        end && ((ndims(var"##1195") === 1 && length(var"##1195") >= 0) && let line = var"##1191", lhs = var"##1186"
                                                                                is_line_no(line)
                                                                            end)))))))))))))
                    line = var"##1191"
                    lhs = var"##1186"
                    var"##return#1100" = begin
                            leading_tab()
                            inline(lhs)
                            keyword(" = ")
                            inline(line)
                            p(ex.args[2])
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1101#1308")))
                end
                if begin
                            var"##1196" = (var"##cache#1103").value
                            var"##1196" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1196"[1] == :(=) && (begin
                                    var"##1197" = var"##1196"[2]
                                    var"##1197" isa AbstractArray
                                end && (length(var"##1197") === 2 && (begin
                                            var"##1198" = var"##1197"[1]
                                            begin
                                                var"##cache#1200" = nothing
                                            end
                                            var"##1199" = var"##1197"[2]
                                            var"##1199" isa Expr
                                        end && (begin
                                                if var"##cache#1200" === nothing
                                                    var"##cache#1200" = Some(((var"##1199").head, (var"##1199").args))
                                                end
                                                var"##1201" = (var"##cache#1200").value
                                                var"##1201" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1201"[1] == :block && (begin
                                                        var"##1202" = var"##1201"[2]
                                                        var"##1202" isa AbstractArray
                                                    end && (length(var"##1202") === 2 && begin
                                                            var"##1203" = var"##1202"[1]
                                                            var"##1204" = var"##1202"[2]
                                                            let rhs = var"##1204", line = var"##1203", lhs = var"##1198"
                                                                is_line_no(line)
                                                            end
                                                        end))))))))
                    rhs = var"##1204"
                    line = var"##1203"
                    lhs = var"##1198"
                    var"##return#1100" = begin
                            leading_tab()
                            inline(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1101#1308")))
                end
                if begin
                            var"##1205" = (var"##cache#1103").value
                            var"##1205" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1205"[1] == :(=) && (begin
                                    var"##1206" = var"##1205"[2]
                                    var"##1206" isa AbstractArray
                                end && (length(var"##1206") === 2 && begin
                                        var"##1207" = var"##1206"[1]
                                        var"##1208" = var"##1206"[2]
                                        true
                                    end)))
                    rhs = var"##1208"
                    lhs = var"##1207"
                    var"##return#1100" = begin
                            leading_tab()
                            inline(lhs)
                            print(" = ")
                            p(rhs)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1101#1308")))
                end
                if begin
                            var"##1209" = (var"##cache#1103").value
                            var"##1209" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1209"[1] == :function && (begin
                                    var"##1210" = var"##1209"[2]
                                    var"##1210" isa AbstractArray
                                end && (length(var"##1210") === 2 && begin
                                        var"##1211" = var"##1210"[1]
                                        var"##1212" = var"##1210"[2]
                                        true
                                    end)))
                    call = var"##1211"
                    body = var"##1212"
                    var"##return#1100" = begin
                            print_function(:function, call, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1101#1308")))
                end
                if begin
                            var"##1213" = (var"##cache#1103").value
                            var"##1213" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1213"[1] == :-> && (begin
                                    var"##1214" = var"##1213"[2]
                                    var"##1214" isa AbstractArray
                                end && (length(var"##1214") === 2 && begin
                                        var"##1215" = var"##1214"[1]
                                        var"##1216" = var"##1214"[2]
                                        true
                                    end)))
                    call = var"##1215"
                    body = var"##1216"
                    var"##return#1100" = begin
                            leading_tab()
                            inline(call)
                            keyword(" -> ")
                            p(body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1101#1308")))
                end
                if begin
                            var"##1217" = (var"##cache#1103").value
                            var"##1217" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1217"[1] == :do && (begin
                                    var"##1218" = var"##1217"[2]
                                    var"##1218" isa AbstractArray
                                end && (length(var"##1218") === 2 && (begin
                                            var"##1219" = var"##1218"[1]
                                            begin
                                                var"##cache#1221" = nothing
                                            end
                                            var"##1220" = var"##1218"[2]
                                            var"##1220" isa Expr
                                        end && (begin
                                                if var"##cache#1221" === nothing
                                                    var"##cache#1221" = Some(((var"##1220").head, (var"##1220").args))
                                                end
                                                var"##1222" = (var"##cache#1221").value
                                                var"##1222" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1222"[1] == :-> && (begin
                                                        var"##1223" = var"##1222"[2]
                                                        var"##1223" isa AbstractArray
                                                    end && (length(var"##1223") === 2 && (begin
                                                                begin
                                                                    var"##cache#1225" = nothing
                                                                end
                                                                var"##1224" = var"##1223"[1]
                                                                var"##1224" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1225" === nothing
                                                                        var"##cache#1225" = Some(((var"##1224").head, (var"##1224").args))
                                                                    end
                                                                    var"##1226" = (var"##cache#1225").value
                                                                    var"##1226" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1226"[1] == :tuple && (begin
                                                                            var"##1227" = var"##1226"[2]
                                                                            var"##1227" isa AbstractArray
                                                                        end && ((ndims(var"##1227") === 1 && length(var"##1227") >= 0) && begin
                                                                                var"##1228" = SubArray(var"##1227", (1:length(var"##1227"),))
                                                                                var"##1229" = var"##1223"[2]
                                                                                true
                                                                            end)))))))))))))
                    call = var"##1219"
                    args = var"##1228"
                    body = var"##1229"
                    var"##return#1100" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1101#1308")))
                end
                if begin
                            var"##1230" = (var"##cache#1103").value
                            var"##1230" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1230"[1] == :macro && (begin
                                    var"##1231" = var"##1230"[2]
                                    var"##1231" isa AbstractArray
                                end && (length(var"##1231") === 2 && begin
                                        var"##1232" = var"##1231"[1]
                                        var"##1233" = var"##1231"[2]
                                        true
                                    end)))
                    call = var"##1232"
                    body = var"##1233"
                    var"##return#1100" = begin
                            print_function(:macro, call, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1101#1308")))
                end
                if begin
                            var"##1234" = (var"##cache#1103").value
                            var"##1234" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1234"[1] == :macrocall && (begin
                                    var"##1235" = var"##1234"[2]
                                    var"##1235" isa AbstractArray
                                end && (length(var"##1235") === 4 && (begin
                                            var"##1236" = var"##1235"[1]
                                            var"##1236" == Symbol("@switch")
                                        end && (begin
                                                var"##1237" = var"##1235"[2]
                                                var"##1238" = var"##1235"[3]
                                                begin
                                                    var"##cache#1240" = nothing
                                                end
                                                var"##1239" = var"##1235"[4]
                                                var"##1239" isa Expr
                                            end && (begin
                                                    if var"##cache#1240" === nothing
                                                        var"##cache#1240" = Some(((var"##1239").head, (var"##1239").args))
                                                    end
                                                    var"##1241" = (var"##cache#1240").value
                                                    var"##1241" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1241"[1] == :block && (begin
                                                            var"##1242" = var"##1241"[2]
                                                            var"##1242" isa AbstractArray
                                                        end && ((ndims(var"##1242") === 1 && length(var"##1242") >= 0) && begin
                                                                var"##1243" = SubArray(var"##1242", (1:length(var"##1242"),))
                                                                true
                                                            end)))))))))
                    item = var"##1238"
                    line = var"##1237"
                    stmts = var"##1243"
                    var"##return#1100" = begin
                            print_switch(item, line, stmts)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1101#1308")))
                end
                if begin
                            var"##1244" = (var"##cache#1103").value
                            var"##1244" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1244"[1] == :macrocall && (begin
                                    var"##1245" = var"##1244"[2]
                                    var"##1245" isa AbstractArray
                                end && (length(var"##1245") === 4 && (begin
                                            var"##1246" = var"##1245"[1]
                                            var"##1246" == GlobalRef(Core, Symbol("@doc"))
                                        end && begin
                                            var"##1247" = var"##1245"[2]
                                            var"##1248" = var"##1245"[3]
                                            var"##1249" = var"##1245"[4]
                                            true
                                        end))))
                    line = var"##1247"
                    code = var"##1249"
                    doc = var"##1248"
                    var"##return#1100" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1101#1308")))
                end
                if begin
                            var"##1250" = (var"##cache#1103").value
                            var"##1250" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1250"[1] == :macrocall && (begin
                                    var"##1251" = var"##1250"[2]
                                    var"##1251" isa AbstractArray
                                end && ((ndims(var"##1251") === 1 && length(var"##1251") >= 2) && begin
                                        var"##1252" = var"##1251"[1]
                                        var"##1253" = var"##1251"[2]
                                        var"##1254" = SubArray(var"##1251", (3:length(var"##1251"),))
                                        true
                                    end)))
                    line = var"##1253"
                    name = var"##1252"
                    args = var"##1254"
                    var"##return#1100" = begin
                            print_macrocall(name, line, args)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1101#1308")))
                end
                if begin
                            var"##1255" = (var"##cache#1103").value
                            var"##1255" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1255"[1] == :struct && (begin
                                    var"##1256" = var"##1255"[2]
                                    var"##1256" isa AbstractArray
                                end && (length(var"##1256") === 3 && begin
                                        var"##1257" = var"##1256"[1]
                                        var"##1258" = var"##1256"[2]
                                        var"##1259" = var"##1256"[3]
                                        true
                                    end)))
                    ismutable = var"##1257"
                    body = var"##1259"
                    head = var"##1258"
                    var"##return#1100" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1101#1308")))
                end
                if begin
                            var"##1260" = (var"##cache#1103").value
                            var"##1260" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1260"[1] == :try && (begin
                                    var"##1261" = var"##1260"[2]
                                    var"##1261" isa AbstractArray
                                end && (length(var"##1261") === 3 && begin
                                        var"##1262" = var"##1261"[1]
                                        var"##1263" = var"##1261"[2]
                                        var"##1264" = var"##1261"[3]
                                        true
                                    end)))
                    catch_vars = var"##1263"
                    catch_body = var"##1264"
                    try_body = var"##1262"
                    var"##return#1100" = begin
                            print_try(try_body)
                            print_catch(catch_body, catch_vars)
                            println()
                            tab()
                            keyword("end")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1101#1308")))
                end
                if begin
                            var"##1265" = (var"##cache#1103").value
                            var"##1265" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1265"[1] == :try && (begin
                                    var"##1266" = var"##1265"[2]
                                    var"##1266" isa AbstractArray
                                end && (length(var"##1266") === 4 && begin
                                        var"##1267" = var"##1266"[1]
                                        var"##1268" = var"##1266"[2]
                                        var"##1269" = var"##1266"[3]
                                        var"##1270" = var"##1266"[4]
                                        true
                                    end)))
                    catch_vars = var"##1268"
                    catch_body = var"##1269"
                    try_body = var"##1267"
                    finally_body = var"##1270"
                    var"##return#1100" = begin
                            print_try(try_body)
                            print_catch(catch_body, catch_vars)
                            print_finally(finally_body)
                            println()
                            tab()
                            keyword("end")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1101#1308")))
                end
                if begin
                            var"##1271" = (var"##cache#1103").value
                            var"##1271" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1271"[1] == :try && (begin
                                    var"##1272" = var"##1271"[2]
                                    var"##1272" isa AbstractArray
                                end && (length(var"##1272") === 5 && begin
                                        var"##1273" = var"##1272"[1]
                                        var"##1274" = var"##1272"[2]
                                        var"##1275" = var"##1272"[3]
                                        var"##1276" = var"##1272"[4]
                                        var"##1277" = var"##1272"[5]
                                        true
                                    end)))
                    catch_vars = var"##1274"
                    catch_body = var"##1275"
                    try_body = var"##1273"
                    finally_body = var"##1276"
                    else_body = var"##1277"
                    var"##return#1100" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1101#1308")))
                end
                if begin
                            var"##1278" = (var"##cache#1103").value
                            var"##1278" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1278"[1] == :module && (begin
                                    var"##1279" = var"##1278"[2]
                                    var"##1279" isa AbstractArray
                                end && (length(var"##1279") === 3 && begin
                                        var"##1280" = var"##1279"[1]
                                        var"##1281" = var"##1279"[2]
                                        var"##1282" = var"##1279"[3]
                                        true
                                    end)))
                    name = var"##1281"
                    body = var"##1282"
                    notbare = var"##1280"
                    var"##return#1100" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1101#1308")))
                end
                if begin
                            var"##1283" = (var"##cache#1103").value
                            var"##1283" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1283"[1] == :const && (begin
                                    var"##1284" = var"##1283"[2]
                                    var"##1284" isa AbstractArray
                                end && (length(var"##1284") === 1 && begin
                                        var"##1285" = var"##1284"[1]
                                        true
                                    end)))
                    code = var"##1285"
                    var"##return#1100" = begin
                            leading_tab()
                            keyword("const ")
                            p(code)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1101#1308")))
                end
                if begin
                            var"##1286" = (var"##cache#1103").value
                            var"##1286" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1286"[1] == :return && (begin
                                    var"##1287" = var"##1286"[2]
                                    var"##1287" isa AbstractArray
                                end && (length(var"##1287") === 1 && (begin
                                            begin
                                                var"##cache#1289" = nothing
                                            end
                                            var"##1288" = var"##1287"[1]
                                            var"##1288" isa Expr
                                        end && (begin
                                                if var"##cache#1289" === nothing
                                                    var"##cache#1289" = Some(((var"##1288").head, (var"##1288").args))
                                                end
                                                var"##1290" = (var"##cache#1289").value
                                                var"##1290" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1290"[1] == :tuple && (begin
                                                        var"##1291" = var"##1290"[2]
                                                        var"##1291" isa AbstractArray
                                                    end && ((ndims(var"##1291") === 1 && length(var"##1291") >= 1) && (begin
                                                                begin
                                                                    var"##cache#1293" = nothing
                                                                end
                                                                var"##1292" = var"##1291"[1]
                                                                var"##1292" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1293" === nothing
                                                                        var"##cache#1293" = Some(((var"##1292").head, (var"##1292").args))
                                                                    end
                                                                    var"##1294" = (var"##cache#1293").value
                                                                    var"##1294" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1294"[1] == :parameters && (begin
                                                                            var"##1295" = var"##1294"[2]
                                                                            var"##1295" isa AbstractArray
                                                                        end && (ndims(var"##1295") === 1 && length(var"##1295") >= 0)))))))))))))
                    var"##return#1100" = begin
                            inline(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1101#1308")))
                end
                if begin
                            var"##1296" = (var"##cache#1103").value
                            var"##1296" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1296"[1] == :return && (begin
                                    var"##1297" = var"##1296"[2]
                                    var"##1297" isa AbstractArray
                                end && (length(var"##1297") === 1 && (begin
                                            begin
                                                var"##cache#1299" = nothing
                                            end
                                            var"##1298" = var"##1297"[1]
                                            var"##1298" isa Expr
                                        end && (begin
                                                if var"##cache#1299" === nothing
                                                    var"##cache#1299" = Some(((var"##1298").head, (var"##1298").args))
                                                end
                                                var"##1300" = (var"##cache#1299").value
                                                var"##1300" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1300"[1] == :tuple && (begin
                                                        var"##1301" = var"##1300"[2]
                                                        var"##1301" isa AbstractArray
                                                    end && (ndims(var"##1301") === 1 && length(var"##1301") >= 0))))))))
                    var"##return#1100" = begin
                            inline(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1101#1308")))
                end
                if begin
                            var"##1302" = (var"##cache#1103").value
                            var"##1302" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1302"[1] == :return && (begin
                                    var"##1303" = var"##1302"[2]
                                    var"##1303" isa AbstractArray
                                end && (length(var"##1303") === 1 && begin
                                        var"##1304" = var"##1303"[1]
                                        true
                                    end)))
                    code = var"##1304"
                    var"##return#1100" = begin
                            leading_tab()
                            keyword("return ")
                            p(code)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1101#1308")))
                end
                if begin
                            var"##1305" = (var"##cache#1103").value
                            var"##1305" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1305"[1] == :toplevel && (begin
                                    var"##1306" = var"##1305"[2]
                                    var"##1306" isa AbstractArray
                                end && (length(var"##1306") === 1 && begin
                                        var"##1307" = var"##1306"[1]
                                        true
                                    end)))
                    code = var"##1307"
                    var"##return#1100" = begin
                            leading_tab()
                            printstyled("#= meta: toplevel =#", color = c.comment)
                            println()
                            p(code)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1101#1308")))
                end
            end
            if var"##1102" isa String
                begin
                    var"##return#1100" = begin
                            leading_tab()
                            occursin('\n', ex) || return inline(ex)
                            printstyled("\"\"\"\n", color = c.string)
                            tab()
                            print_multi_lines(ex)
                            printstyled("\"\"\"", color = c.string)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1101#1308")))
                end
            end
            begin
                var"##return#1100" = begin
                        inline(ex)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#1101#1308")))
            end
            error("matching non-exhaustive, at #= none:246 =#")
            $(Expr(:symboliclabel, Symbol("####final#1101#1308")))
            var"##return#1100"
        end
        return nothing
    end
    #= none:468 =# Core.@doc "    print_expr([io::IO], ex; kw...)\n\nPrint a given expression. `ex` can be a `Expr` or a syntax type `JLExpr`.\n" print_expr(io::IO, ex; kw...) = begin
                (Printer(io; kw...))(ex)
            end
    print_expr(ex; kw...) = begin
            print_expr(stdout, ex; kw...)
        end
