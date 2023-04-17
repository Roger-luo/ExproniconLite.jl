
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
                    var"##cache#1086" = nothing
                end
                var"##return#1083" = nothing
                var"##1085" = otherwise
                if var"##1085" isa Expr && (begin
                                if var"##cache#1086" === nothing
                                    var"##cache#1086" = Some(((var"##1085").head, (var"##1085").args))
                                end
                                var"##1087" = (var"##cache#1086").value
                                var"##1087" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1087"[1] == :block && (begin
                                        var"##1088" = var"##1087"[2]
                                        var"##1088" isa AbstractArray
                                    end && ((ndims(var"##1088") === 1 && length(var"##1088") >= 0) && begin
                                            var"##1089" = SubArray(var"##1088", (1:length(var"##1088"),))
                                            true
                                        end))))
                    var"##return#1083" = let stmts = var"##1089"
                            indent() do 
                                print_stmts(stmts)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1084#1090")))
                end
                begin
                    var"##return#1083" = let
                            indent() do 
                                tab()
                                no_first_line_indent() do 
                                    p(otherwise)
                                end
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1084#1090")))
                end
                error("matching non-exhaustive, at #= none:98 =#")
                $(Expr(:symboliclabel, Symbol("####final#1084#1090")))
                var"##return#1083"
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
                            var"##cache#1094" = nothing
                        end
                        var"##return#1091" = nothing
                        var"##1093" = stmt
                        if var"##1093" isa Expr && (begin
                                        if var"##cache#1094" === nothing
                                            var"##cache#1094" = Some(((var"##1093").head, (var"##1093").args))
                                        end
                                        var"##1095" = (var"##cache#1094").value
                                        var"##1095" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##1095"[1] == :macrocall && (begin
                                                var"##1096" = var"##1095"[2]
                                                var"##1096" isa AbstractArray
                                            end && ((ndims(var"##1096") === 1 && length(var"##1096") >= 1) && begin
                                                    var"##1097" = var"##1096"[1]
                                                    var"##1097" == Symbol("@case")
                                                end))))
                            var"##return#1091" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1092#1098")))
                        end
                        begin
                            var"##return#1091" = let
                                    false
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1092#1098")))
                        end
                        error("matching non-exhaustive, at #= none:181 =#")
                        $(Expr(:symboliclabel, Symbol("####final#1092#1098")))
                        var"##return#1091"
                    end
                end || return print_macrocall("@switch", line, (item, Expr(:block, stmts...)))
            is_case(stmt) = begin
                    let
                        begin
                            var"##cache#1102" = nothing
                        end
                        var"##return#1099" = nothing
                        var"##1101" = stmt
                        if var"##1101" isa Expr && (begin
                                        if var"##cache#1102" === nothing
                                            var"##cache#1102" = Some(((var"##1101").head, (var"##1101").args))
                                        end
                                        var"##1103" = (var"##cache#1102").value
                                        var"##1103" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##1103"[1] == :macrocall && (begin
                                                var"##1104" = var"##1103"[2]
                                                var"##1104" isa AbstractArray
                                            end && ((ndims(var"##1104") === 1 && length(var"##1104") >= 1) && begin
                                                    var"##1105" = var"##1104"[1]
                                                    var"##1105" == Symbol("@case")
                                                end))))
                            var"##return#1099" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1100#1106")))
                        end
                        begin
                            var"##return#1099" = let
                                    false
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1100#1106")))
                        end
                        error("matching non-exhaustive, at #= none:187 =#")
                        $(Expr(:symboliclabel, Symbol("####final#1100#1106")))
                        var"##return#1099"
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
                            var"##cache#1110" = nothing
                        end
                        var"##return#1107" = nothing
                        var"##1109" = stmt
                        if var"##1109" isa Expr && (begin
                                        if var"##cache#1110" === nothing
                                            var"##cache#1110" = Some(((var"##1109").head, (var"##1109").args))
                                        end
                                        var"##1111" = (var"##cache#1110").value
                                        var"##1111" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##1111"[1] == :macrocall && (begin
                                                var"##1112" = var"##1111"[2]
                                                var"##1112" isa AbstractArray
                                            end && (length(var"##1112") === 3 && (begin
                                                        var"##1113" = var"##1112"[1]
                                                        var"##1113" == Symbol("@case")
                                                    end && begin
                                                        var"##1114" = var"##1112"[2]
                                                        var"##1115" = var"##1112"[3]
                                                        true
                                                    end)))))
                            var"##return#1107" = let pattern = var"##1115", line = var"##1114"
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
                            $(Expr(:symbolicgoto, Symbol("####final#1108#1116")))
                        end
                        begin
                            var"##return#1107" = let
                                    p(stmt)
                                    println()
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1108#1116")))
                        end
                        error("matching non-exhaustive, at #= none:197 =#")
                        $(Expr(:symboliclabel, Symbol("####final#1108#1116")))
                        var"##return#1107"
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
                var"##cache#1120" = nothing
            end
            var"##1119" = ex
            if var"##1119" isa Expr
                if begin
                            if var"##cache#1120" === nothing
                                var"##cache#1120" = Some(((var"##1119").head, (var"##1119").args))
                            end
                            var"##1121" = (var"##cache#1120").value
                            var"##1121" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1121"[1] == :string && (begin
                                    var"##1122" = var"##1121"[2]
                                    var"##1122" isa AbstractArray
                                end && ((ndims(var"##1122") === 1 && length(var"##1122") >= 0) && begin
                                        var"##1123" = SubArray(var"##1122", (1:length(var"##1122"),))
                                        true
                                    end)))
                    args = var"##1123"
                    var"##return#1117" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1118#1322")))
                end
                if begin
                            var"##1124" = (var"##cache#1120").value
                            var"##1124" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1124"[1] == :block && (begin
                                    var"##1125" = var"##1124"[2]
                                    var"##1125" isa AbstractArray
                                end && ((ndims(var"##1125") === 1 && length(var"##1125") >= 0) && begin
                                        var"##1126" = SubArray(var"##1125", (1:length(var"##1125"),))
                                        true
                                    end)))
                    stmts = var"##1126"
                    var"##return#1117" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1118#1322")))
                end
                if begin
                            var"##1127" = (var"##cache#1120").value
                            var"##1127" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1127"[1] == :quote && (begin
                                    var"##1128" = var"##1127"[2]
                                    var"##1128" isa AbstractArray
                                end && (length(var"##1128") === 1 && (begin
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
                                                    end && ((ndims(var"##1132") === 1 && length(var"##1132") >= 0) && begin
                                                            var"##1133" = SubArray(var"##1132", (1:length(var"##1132"),))
                                                            let stmts = var"##1133"
                                                                is_root()
                                                            end
                                                        end))))))))
                    stmts = var"##1133"
                    var"##return#1117" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1118#1322")))
                end
                if begin
                            var"##1134" = (var"##cache#1120").value
                            var"##1134" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1134"[1] == :quote && (begin
                                    var"##1135" = var"##1134"[2]
                                    var"##1135" isa AbstractArray
                                end && (length(var"##1135") === 1 && (begin
                                            begin
                                                var"##cache#1137" = nothing
                                            end
                                            var"##1136" = var"##1135"[1]
                                            var"##1136" isa Expr
                                        end && (begin
                                                if var"##cache#1137" === nothing
                                                    var"##cache#1137" = Some(((var"##1136").head, (var"##1136").args))
                                                end
                                                var"##1138" = (var"##cache#1137").value
                                                var"##1138" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1138"[1] == :block && (begin
                                                        var"##1139" = var"##1138"[2]
                                                        var"##1139" isa AbstractArray
                                                    end && ((ndims(var"##1139") === 1 && length(var"##1139") >= 0) && begin
                                                            var"##1140" = SubArray(var"##1139", (1:length(var"##1139"),))
                                                            true
                                                        end))))))))
                    stmts = var"##1140"
                    var"##return#1117" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1118#1322")))
                end
                if begin
                            var"##1141" = (var"##cache#1120").value
                            var"##1141" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1141"[1] == :quote && (begin
                                    var"##1142" = var"##1141"[2]
                                    var"##1142" isa AbstractArray
                                end && (length(var"##1142") === 1 && begin
                                        var"##1143" = var"##1142"[1]
                                        true
                                    end)))
                    code = var"##1143"
                    var"##return#1117" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1118#1322")))
                end
                if begin
                            var"##1144" = (var"##cache#1120").value
                            var"##1144" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1144"[1] == :let && (begin
                                    var"##1145" = var"##1144"[2]
                                    var"##1145" isa AbstractArray
                                end && (length(var"##1145") === 2 && (begin
                                            begin
                                                var"##cache#1147" = nothing
                                            end
                                            var"##1146" = var"##1145"[1]
                                            var"##1146" isa Expr
                                        end && (begin
                                                if var"##cache#1147" === nothing
                                                    var"##cache#1147" = Some(((var"##1146").head, (var"##1146").args))
                                                end
                                                var"##1148" = (var"##cache#1147").value
                                                var"##1148" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1148"[1] == :block && (begin
                                                        var"##1149" = var"##1148"[2]
                                                        var"##1149" isa AbstractArray
                                                    end && ((ndims(var"##1149") === 1 && length(var"##1149") >= 0) && (begin
                                                                var"##1150" = SubArray(var"##1149", (1:length(var"##1149"),))
                                                                begin
                                                                    var"##cache#1152" = nothing
                                                                end
                                                                var"##1151" = var"##1145"[2]
                                                                var"##1151" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1152" === nothing
                                                                        var"##cache#1152" = Some(((var"##1151").head, (var"##1151").args))
                                                                    end
                                                                    var"##1153" = (var"##cache#1152").value
                                                                    var"##1153" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1153"[1] == :block && (begin
                                                                            var"##1154" = var"##1153"[2]
                                                                            var"##1154" isa AbstractArray
                                                                        end && ((ndims(var"##1154") === 1 && length(var"##1154") >= 0) && begin
                                                                                var"##1155" = SubArray(var"##1154", (1:length(var"##1154"),))
                                                                                true
                                                                            end)))))))))))))
                    args = var"##1150"
                    stmts = var"##1155"
                    var"##return#1117" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1118#1322")))
                end
                if begin
                            var"##1156" = (var"##cache#1120").value
                            var"##1156" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1156"[1] == :if && (begin
                                    var"##1157" = var"##1156"[2]
                                    var"##1157" isa AbstractArray
                                end && (length(var"##1157") === 2 && begin
                                        var"##1158" = var"##1157"[1]
                                        var"##1159" = var"##1157"[2]
                                        true
                                    end)))
                    cond = var"##1158"
                    body = var"##1159"
                    var"##return#1117" = begin
                            print_if(cond, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1118#1322")))
                end
                if begin
                            var"##1160" = (var"##cache#1120").value
                            var"##1160" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1160"[1] == :if && (begin
                                    var"##1161" = var"##1160"[2]
                                    var"##1161" isa AbstractArray
                                end && (length(var"##1161") === 3 && begin
                                        var"##1162" = var"##1161"[1]
                                        var"##1163" = var"##1161"[2]
                                        var"##1164" = var"##1161"[3]
                                        true
                                    end)))
                    cond = var"##1162"
                    body = var"##1163"
                    otherwise = var"##1164"
                    var"##return#1117" = begin
                            print_if(cond, body, otherwise)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1118#1322")))
                end
                if begin
                            var"##1165" = (var"##cache#1120").value
                            var"##1165" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1165"[1] == :elseif && (begin
                                    var"##1166" = var"##1165"[2]
                                    var"##1166" isa AbstractArray
                                end && (length(var"##1166") === 2 && (begin
                                            begin
                                                var"##cache#1168" = nothing
                                            end
                                            var"##1167" = var"##1166"[1]
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
                                                    end && (length(var"##1170") === 2 && begin
                                                            var"##1171" = var"##1170"[1]
                                                            var"##1172" = var"##1170"[2]
                                                            var"##1173" = var"##1166"[2]
                                                            true
                                                        end))))))))
                    line = var"##1171"
                    cond = var"##1172"
                    body = var"##1173"
                    var"##return#1117" = begin
                            print_elseif(cond, body, line)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1118#1322")))
                end
                if begin
                            var"##1174" = (var"##cache#1120").value
                            var"##1174" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1174"[1] == :elseif && (begin
                                    var"##1175" = var"##1174"[2]
                                    var"##1175" isa AbstractArray
                                end && (length(var"##1175") === 2 && begin
                                        var"##1176" = var"##1175"[1]
                                        var"##1177" = var"##1175"[2]
                                        true
                                    end)))
                    cond = var"##1176"
                    body = var"##1177"
                    var"##return#1117" = begin
                            print_elseif(cond, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1118#1322")))
                end
                if begin
                            var"##1178" = (var"##cache#1120").value
                            var"##1178" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1178"[1] == :elseif && (begin
                                    var"##1179" = var"##1178"[2]
                                    var"##1179" isa AbstractArray
                                end && (length(var"##1179") === 3 && (begin
                                            begin
                                                var"##cache#1181" = nothing
                                            end
                                            var"##1180" = var"##1179"[1]
                                            var"##1180" isa Expr
                                        end && (begin
                                                if var"##cache#1181" === nothing
                                                    var"##cache#1181" = Some(((var"##1180").head, (var"##1180").args))
                                                end
                                                var"##1182" = (var"##cache#1181").value
                                                var"##1182" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1182"[1] == :block && (begin
                                                        var"##1183" = var"##1182"[2]
                                                        var"##1183" isa AbstractArray
                                                    end && (length(var"##1183") === 2 && begin
                                                            var"##1184" = var"##1183"[1]
                                                            var"##1185" = var"##1183"[2]
                                                            var"##1186" = var"##1179"[2]
                                                            var"##1187" = var"##1179"[3]
                                                            true
                                                        end))))))))
                    line = var"##1184"
                    cond = var"##1185"
                    body = var"##1186"
                    otherwise = var"##1187"
                    var"##return#1117" = begin
                            print_elseif(cond, body, line, otherwise)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1118#1322")))
                end
                if begin
                            var"##1188" = (var"##cache#1120").value
                            var"##1188" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1188"[1] == :elseif && (begin
                                    var"##1189" = var"##1188"[2]
                                    var"##1189" isa AbstractArray
                                end && (length(var"##1189") === 3 && begin
                                        var"##1190" = var"##1189"[1]
                                        var"##1191" = var"##1189"[2]
                                        var"##1192" = var"##1189"[3]
                                        true
                                    end)))
                    cond = var"##1190"
                    body = var"##1191"
                    otherwise = var"##1192"
                    var"##return#1117" = begin
                            print_elseif(cond, body, nothing, otherwise)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1118#1322")))
                end
                if begin
                            var"##1193" = (var"##cache#1120").value
                            var"##1193" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1193"[1] == :for && (begin
                                    var"##1194" = var"##1193"[2]
                                    var"##1194" isa AbstractArray
                                end && (length(var"##1194") === 2 && begin
                                        var"##1195" = var"##1194"[1]
                                        var"##1196" = var"##1194"[2]
                                        true
                                    end)))
                    body = var"##1196"
                    iteration = var"##1195"
                    var"##return#1117" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1118#1322")))
                end
                if begin
                            var"##1197" = (var"##cache#1120").value
                            var"##1197" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1197"[1] == :while && (begin
                                    var"##1198" = var"##1197"[2]
                                    var"##1198" isa AbstractArray
                                end && (length(var"##1198") === 2 && begin
                                        var"##1199" = var"##1198"[1]
                                        var"##1200" = var"##1198"[2]
                                        true
                                    end)))
                    cond = var"##1199"
                    body = var"##1200"
                    var"##return#1117" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1118#1322")))
                end
                if begin
                            var"##1201" = (var"##cache#1120").value
                            var"##1201" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1201"[1] == :(=) && (begin
                                    var"##1202" = var"##1201"[2]
                                    var"##1202" isa AbstractArray
                                end && (length(var"##1202") === 2 && (begin
                                            var"##1203" = var"##1202"[1]
                                            begin
                                                var"##cache#1205" = nothing
                                            end
                                            var"##1204" = var"##1202"[2]
                                            var"##1204" isa Expr
                                        end && (begin
                                                if var"##cache#1205" === nothing
                                                    var"##cache#1205" = Some(((var"##1204").head, (var"##1204").args))
                                                end
                                                var"##1206" = (var"##cache#1205").value
                                                var"##1206" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1206"[1] == :block && (begin
                                                        var"##1207" = var"##1206"[2]
                                                        var"##1207" isa AbstractArray
                                                    end && (length(var"##1207") === 2 && (begin
                                                                var"##1208" = var"##1207"[1]
                                                                begin
                                                                    var"##cache#1210" = nothing
                                                                end
                                                                var"##1209" = var"##1207"[2]
                                                                var"##1209" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1210" === nothing
                                                                        var"##cache#1210" = Some(((var"##1209").head, (var"##1209").args))
                                                                    end
                                                                    var"##1211" = (var"##cache#1210").value
                                                                    var"##1211" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1211"[1] == :if && (begin
                                                                            var"##1212" = var"##1211"[2]
                                                                            var"##1212" isa AbstractArray
                                                                        end && ((ndims(var"##1212") === 1 && length(var"##1212") >= 0) && let line = var"##1208", lhs = var"##1203"
                                                                                is_line_no(line)
                                                                            end)))))))))))))
                    line = var"##1208"
                    lhs = var"##1203"
                    var"##return#1117" = begin
                            leading_tab()
                            inline(lhs)
                            keyword(" = ")
                            inline(line)
                            p(ex.args[2])
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1118#1322")))
                end
                if begin
                            var"##1213" = (var"##cache#1120").value
                            var"##1213" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1213"[1] == :(=) && (begin
                                    var"##1214" = var"##1213"[2]
                                    var"##1214" isa AbstractArray
                                end && (length(var"##1214") === 2 && (begin
                                            var"##1215" = var"##1214"[1]
                                            begin
                                                var"##cache#1217" = nothing
                                            end
                                            var"##1216" = var"##1214"[2]
                                            var"##1216" isa Expr
                                        end && (begin
                                                if var"##cache#1217" === nothing
                                                    var"##cache#1217" = Some(((var"##1216").head, (var"##1216").args))
                                                end
                                                var"##1218" = (var"##cache#1217").value
                                                var"##1218" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1218"[1] == :block && (begin
                                                        var"##1219" = var"##1218"[2]
                                                        var"##1219" isa AbstractArray
                                                    end && (length(var"##1219") === 2 && begin
                                                            var"##1220" = var"##1219"[1]
                                                            var"##1221" = var"##1219"[2]
                                                            let rhs = var"##1221", line = var"##1220", lhs = var"##1215"
                                                                is_line_no(line)
                                                            end
                                                        end))))))))
                    rhs = var"##1221"
                    line = var"##1220"
                    lhs = var"##1215"
                    var"##return#1117" = begin
                            leading_tab()
                            inline(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1118#1322")))
                end
                if begin
                            var"##1222" = (var"##cache#1120").value
                            var"##1222" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1222"[1] == :(=) && (begin
                                    var"##1223" = var"##1222"[2]
                                    var"##1223" isa AbstractArray
                                end && (length(var"##1223") === 2 && begin
                                        var"##1224" = var"##1223"[1]
                                        var"##1225" = var"##1223"[2]
                                        true
                                    end)))
                    rhs = var"##1225"
                    lhs = var"##1224"
                    var"##return#1117" = begin
                            leading_tab()
                            inline(lhs)
                            print(" = ")
                            p(rhs)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1118#1322")))
                end
                if begin
                            var"##1226" = (var"##cache#1120").value
                            var"##1226" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1226"[1] == :function && (begin
                                    var"##1227" = var"##1226"[2]
                                    var"##1227" isa AbstractArray
                                end && (length(var"##1227") === 2 && begin
                                        var"##1228" = var"##1227"[1]
                                        var"##1229" = var"##1227"[2]
                                        true
                                    end)))
                    call = var"##1228"
                    body = var"##1229"
                    var"##return#1117" = begin
                            print_function(:function, call, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1118#1322")))
                end
                if begin
                            var"##1230" = (var"##cache#1120").value
                            var"##1230" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1230"[1] == :-> && (begin
                                    var"##1231" = var"##1230"[2]
                                    var"##1231" isa AbstractArray
                                end && (length(var"##1231") === 2 && begin
                                        var"##1232" = var"##1231"[1]
                                        var"##1233" = var"##1231"[2]
                                        true
                                    end)))
                    call = var"##1232"
                    body = var"##1233"
                    var"##return#1117" = begin
                            leading_tab()
                            inline(call)
                            keyword(" -> ")
                            p(body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1118#1322")))
                end
                if begin
                            var"##1234" = (var"##cache#1120").value
                            var"##1234" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1234"[1] == :do && (begin
                                    var"##1235" = var"##1234"[2]
                                    var"##1235" isa AbstractArray
                                end && (length(var"##1235") === 2 && (begin
                                            var"##1236" = var"##1235"[1]
                                            begin
                                                var"##cache#1238" = nothing
                                            end
                                            var"##1237" = var"##1235"[2]
                                            var"##1237" isa Expr
                                        end && (begin
                                                if var"##cache#1238" === nothing
                                                    var"##cache#1238" = Some(((var"##1237").head, (var"##1237").args))
                                                end
                                                var"##1239" = (var"##cache#1238").value
                                                var"##1239" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1239"[1] == :-> && (begin
                                                        var"##1240" = var"##1239"[2]
                                                        var"##1240" isa AbstractArray
                                                    end && (length(var"##1240") === 2 && (begin
                                                                begin
                                                                    var"##cache#1242" = nothing
                                                                end
                                                                var"##1241" = var"##1240"[1]
                                                                var"##1241" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1242" === nothing
                                                                        var"##cache#1242" = Some(((var"##1241").head, (var"##1241").args))
                                                                    end
                                                                    var"##1243" = (var"##cache#1242").value
                                                                    var"##1243" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1243"[1] == :tuple && (begin
                                                                            var"##1244" = var"##1243"[2]
                                                                            var"##1244" isa AbstractArray
                                                                        end && ((ndims(var"##1244") === 1 && length(var"##1244") >= 0) && begin
                                                                                var"##1245" = SubArray(var"##1244", (1:length(var"##1244"),))
                                                                                var"##1246" = var"##1240"[2]
                                                                                true
                                                                            end)))))))))))))
                    call = var"##1236"
                    args = var"##1245"
                    body = var"##1246"
                    var"##return#1117" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1118#1322")))
                end
                if begin
                            var"##1247" = (var"##cache#1120").value
                            var"##1247" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1247"[1] == :macro && (begin
                                    var"##1248" = var"##1247"[2]
                                    var"##1248" isa AbstractArray
                                end && (length(var"##1248") === 2 && begin
                                        var"##1249" = var"##1248"[1]
                                        var"##1250" = var"##1248"[2]
                                        true
                                    end)))
                    call = var"##1249"
                    body = var"##1250"
                    var"##return#1117" = begin
                            print_function(:macro, call, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1118#1322")))
                end
                if begin
                            var"##1251" = (var"##cache#1120").value
                            var"##1251" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1251"[1] == :macrocall && (begin
                                    var"##1252" = var"##1251"[2]
                                    var"##1252" isa AbstractArray
                                end && (length(var"##1252") === 4 && (begin
                                            var"##1253" = var"##1252"[1]
                                            var"##1253" == Symbol("@switch")
                                        end && (begin
                                                var"##1254" = var"##1252"[2]
                                                var"##1255" = var"##1252"[3]
                                                begin
                                                    var"##cache#1257" = nothing
                                                end
                                                var"##1256" = var"##1252"[4]
                                                var"##1256" isa Expr
                                            end && (begin
                                                    if var"##cache#1257" === nothing
                                                        var"##cache#1257" = Some(((var"##1256").head, (var"##1256").args))
                                                    end
                                                    var"##1258" = (var"##cache#1257").value
                                                    var"##1258" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1258"[1] == :block && (begin
                                                            var"##1259" = var"##1258"[2]
                                                            var"##1259" isa AbstractArray
                                                        end && ((ndims(var"##1259") === 1 && length(var"##1259") >= 0) && begin
                                                                var"##1260" = SubArray(var"##1259", (1:length(var"##1259"),))
                                                                true
                                                            end)))))))))
                    item = var"##1255"
                    line = var"##1254"
                    stmts = var"##1260"
                    var"##return#1117" = begin
                            print_switch(item, line, stmts)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1118#1322")))
                end
                if begin
                            var"##1261" = (var"##cache#1120").value
                            var"##1261" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1261"[1] == :macrocall && (begin
                                    var"##1262" = var"##1261"[2]
                                    var"##1262" isa AbstractArray
                                end && (length(var"##1262") === 4 && (begin
                                            var"##1263" = var"##1262"[1]
                                            var"##1263" == GlobalRef(Core, Symbol("@doc"))
                                        end && begin
                                            var"##1264" = var"##1262"[2]
                                            var"##1265" = var"##1262"[3]
                                            var"##1266" = var"##1262"[4]
                                            true
                                        end))))
                    line = var"##1264"
                    code = var"##1266"
                    doc = var"##1265"
                    var"##return#1117" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1118#1322")))
                end
                if begin
                            var"##1267" = (var"##cache#1120").value
                            var"##1267" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1267"[1] == :macrocall && (begin
                                    var"##1268" = var"##1267"[2]
                                    var"##1268" isa AbstractArray
                                end && ((ndims(var"##1268") === 1 && length(var"##1268") >= 2) && begin
                                        var"##1269" = var"##1268"[1]
                                        var"##1270" = var"##1268"[2]
                                        var"##1271" = SubArray(var"##1268", (3:length(var"##1268"),))
                                        true
                                    end)))
                    line = var"##1270"
                    name = var"##1269"
                    args = var"##1271"
                    var"##return#1117" = begin
                            print_macrocall(name, line, args)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1118#1322")))
                end
                if begin
                            var"##1272" = (var"##cache#1120").value
                            var"##1272" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1272"[1] == :struct && (begin
                                    var"##1273" = var"##1272"[2]
                                    var"##1273" isa AbstractArray
                                end && (length(var"##1273") === 3 && begin
                                        var"##1274" = var"##1273"[1]
                                        var"##1275" = var"##1273"[2]
                                        var"##1276" = var"##1273"[3]
                                        true
                                    end)))
                    ismutable = var"##1274"
                    body = var"##1276"
                    head = var"##1275"
                    var"##return#1117" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1118#1322")))
                end
                if begin
                            var"##1277" = (var"##cache#1120").value
                            var"##1277" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1277"[1] == :try && (begin
                                    var"##1278" = var"##1277"[2]
                                    var"##1278" isa AbstractArray
                                end && (length(var"##1278") === 3 && begin
                                        var"##1279" = var"##1278"[1]
                                        var"##1280" = var"##1278"[2]
                                        var"##1281" = var"##1278"[3]
                                        true
                                    end)))
                    catch_vars = var"##1280"
                    catch_body = var"##1281"
                    try_body = var"##1279"
                    var"##return#1117" = begin
                            print_try(try_body)
                            print_catch(catch_body, catch_vars)
                            println()
                            tab()
                            keyword("end")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1118#1322")))
                end
                if begin
                            var"##1282" = (var"##cache#1120").value
                            var"##1282" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1282"[1] == :try && (begin
                                    var"##1283" = var"##1282"[2]
                                    var"##1283" isa AbstractArray
                                end && (length(var"##1283") === 4 && begin
                                        var"##1284" = var"##1283"[1]
                                        var"##1285" = var"##1283"[2]
                                        var"##1286" = var"##1283"[3]
                                        var"##1287" = var"##1283"[4]
                                        true
                                    end)))
                    catch_vars = var"##1285"
                    catch_body = var"##1286"
                    try_body = var"##1284"
                    finally_body = var"##1287"
                    var"##return#1117" = begin
                            print_try(try_body)
                            print_catch(catch_body, catch_vars)
                            print_finally(finally_body)
                            println()
                            tab()
                            keyword("end")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1118#1322")))
                end
                if begin
                            var"##1288" = (var"##cache#1120").value
                            var"##1288" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1288"[1] == :try && (begin
                                    var"##1289" = var"##1288"[2]
                                    var"##1289" isa AbstractArray
                                end && (length(var"##1289") === 5 && begin
                                        var"##1290" = var"##1289"[1]
                                        var"##1291" = var"##1289"[2]
                                        var"##1292" = var"##1289"[3]
                                        var"##1293" = var"##1289"[4]
                                        var"##1294" = var"##1289"[5]
                                        true
                                    end)))
                    catch_vars = var"##1291"
                    catch_body = var"##1292"
                    try_body = var"##1290"
                    finally_body = var"##1293"
                    else_body = var"##1294"
                    var"##return#1117" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1118#1322")))
                end
                if begin
                            var"##1295" = (var"##cache#1120").value
                            var"##1295" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1295"[1] == :module && (begin
                                    var"##1296" = var"##1295"[2]
                                    var"##1296" isa AbstractArray
                                end && (length(var"##1296") === 3 && begin
                                        var"##1297" = var"##1296"[1]
                                        var"##1298" = var"##1296"[2]
                                        var"##1299" = var"##1296"[3]
                                        true
                                    end)))
                    name = var"##1298"
                    body = var"##1299"
                    notbare = var"##1297"
                    var"##return#1117" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1118#1322")))
                end
                if begin
                            var"##1300" = (var"##cache#1120").value
                            var"##1300" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1300"[1] == :const && (begin
                                    var"##1301" = var"##1300"[2]
                                    var"##1301" isa AbstractArray
                                end && (length(var"##1301") === 1 && begin
                                        var"##1302" = var"##1301"[1]
                                        true
                                    end)))
                    code = var"##1302"
                    var"##return#1117" = begin
                            leading_tab()
                            keyword("const ")
                            p(code)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1118#1322")))
                end
                if begin
                            var"##1303" = (var"##cache#1120").value
                            var"##1303" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1303"[1] == :return && (begin
                                    var"##1304" = var"##1303"[2]
                                    var"##1304" isa AbstractArray
                                end && (length(var"##1304") === 1 && (begin
                                            begin
                                                var"##cache#1306" = nothing
                                            end
                                            var"##1305" = var"##1304"[1]
                                            var"##1305" isa Expr
                                        end && (begin
                                                if var"##cache#1306" === nothing
                                                    var"##cache#1306" = Some(((var"##1305").head, (var"##1305").args))
                                                end
                                                var"##1307" = (var"##cache#1306").value
                                                var"##1307" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1307"[1] == :tuple && (begin
                                                        var"##1308" = var"##1307"[2]
                                                        var"##1308" isa AbstractArray
                                                    end && ((ndims(var"##1308") === 1 && length(var"##1308") >= 1) && (begin
                                                                begin
                                                                    var"##cache#1310" = nothing
                                                                end
                                                                var"##1309" = var"##1308"[1]
                                                                var"##1309" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1310" === nothing
                                                                        var"##cache#1310" = Some(((var"##1309").head, (var"##1309").args))
                                                                    end
                                                                    var"##1311" = (var"##cache#1310").value
                                                                    var"##1311" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1311"[1] == :parameters && (begin
                                                                            var"##1312" = var"##1311"[2]
                                                                            var"##1312" isa AbstractArray
                                                                        end && (ndims(var"##1312") === 1 && length(var"##1312") >= 0)))))))))))))
                    var"##return#1117" = begin
                            inline(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1118#1322")))
                end
                if begin
                            var"##1313" = (var"##cache#1120").value
                            var"##1313" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1313"[1] == :return && (begin
                                    var"##1314" = var"##1313"[2]
                                    var"##1314" isa AbstractArray
                                end && (length(var"##1314") === 1 && (begin
                                            begin
                                                var"##cache#1316" = nothing
                                            end
                                            var"##1315" = var"##1314"[1]
                                            var"##1315" isa Expr
                                        end && (begin
                                                if var"##cache#1316" === nothing
                                                    var"##cache#1316" = Some(((var"##1315").head, (var"##1315").args))
                                                end
                                                var"##1317" = (var"##cache#1316").value
                                                var"##1317" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1317"[1] == :tuple && (begin
                                                        var"##1318" = var"##1317"[2]
                                                        var"##1318" isa AbstractArray
                                                    end && (ndims(var"##1318") === 1 && length(var"##1318") >= 0))))))))
                    var"##return#1117" = begin
                            inline(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1118#1322")))
                end
                if begin
                            var"##1319" = (var"##cache#1120").value
                            var"##1319" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1319"[1] == :return && (begin
                                    var"##1320" = var"##1319"[2]
                                    var"##1320" isa AbstractArray
                                end && (length(var"##1320") === 1 && begin
                                        var"##1321" = var"##1320"[1]
                                        true
                                    end)))
                    code = var"##1321"
                    var"##return#1117" = begin
                            leading_tab()
                            keyword("return ")
                            p(code)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1118#1322")))
                end
            end
            if var"##1119" isa String
                begin
                    var"##return#1117" = begin
                            leading_tab()
                            occursin('\n', ex) || return inline(ex)
                            printstyled("\"\"\"\n", color = c.string)
                            tab()
                            print_multi_lines(ex)
                            printstyled("\"\"\"", color = c.string)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1118#1322")))
                end
            end
            begin
                var"##return#1117" = begin
                        inline(ex)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#1118#1322")))
            end
            error("matching non-exhaustive, at #= none:246 =#")
            $(Expr(:symboliclabel, Symbol("####final#1118#1322")))
            var"##return#1117"
        end
        return nothing
    end
    #= none:464 =# Core.@doc "    print_expr([io::IO], ex; kw...)\n\nPrint a given expression. `ex` can be a `Expr` or a syntax type `JLExpr`.\n" print_expr(io::IO, ex; kw...) = begin
                (Printer(io; kw...))(ex)
            end
    print_expr(ex; kw...) = begin
            print_expr(stdout, ex; kw...)
        end
