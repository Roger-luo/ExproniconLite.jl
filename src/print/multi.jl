
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
                    var"##cache#1136" = nothing
                end
                var"##return#1133" = nothing
                var"##1135" = otherwise
                if var"##1135" isa Expr && (begin
                                if var"##cache#1136" === nothing
                                    var"##cache#1136" = Some(((var"##1135").head, (var"##1135").args))
                                end
                                var"##1137" = (var"##cache#1136").value
                                var"##1137" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1137"[1] == :block && (begin
                                        var"##1138" = var"##1137"[2]
                                        var"##1138" isa AbstractArray
                                    end && ((ndims(var"##1138") === 1 && length(var"##1138") >= 0) && begin
                                            var"##1139" = SubArray(var"##1138", (1:length(var"##1138"),))
                                            true
                                        end))))
                    var"##return#1133" = let stmts = var"##1139"
                            indent() do 
                                print_stmts(stmts)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1134#1140")))
                end
                begin
                    var"##return#1133" = let
                            indent() do 
                                tab()
                                no_first_line_indent() do 
                                    p(otherwise)
                                end
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1134#1140")))
                end
                error("matching non-exhaustive, at #= none:98 =#")
                $(Expr(:symboliclabel, Symbol("####final#1134#1140")))
                var"##return#1133"
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
                            var"##cache#1144" = nothing
                        end
                        var"##return#1141" = nothing
                        var"##1143" = stmt
                        if var"##1143" isa Expr && (begin
                                        if var"##cache#1144" === nothing
                                            var"##cache#1144" = Some(((var"##1143").head, (var"##1143").args))
                                        end
                                        var"##1145" = (var"##cache#1144").value
                                        var"##1145" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##1145"[1] == :macrocall && (begin
                                                var"##1146" = var"##1145"[2]
                                                var"##1146" isa AbstractArray
                                            end && ((ndims(var"##1146") === 1 && length(var"##1146") >= 1) && begin
                                                    var"##1147" = var"##1146"[1]
                                                    var"##1147" == Symbol("@case")
                                                end))))
                            var"##return#1141" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1142#1148")))
                        end
                        begin
                            var"##return#1141" = let
                                    false
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1142#1148")))
                        end
                        error("matching non-exhaustive, at #= none:181 =#")
                        $(Expr(:symboliclabel, Symbol("####final#1142#1148")))
                        var"##return#1141"
                    end
                end || return print_macrocall("@switch", line, (item, Expr(:block, stmts...)))
            is_case(stmt) = begin
                    let
                        begin
                            var"##cache#1152" = nothing
                        end
                        var"##return#1149" = nothing
                        var"##1151" = stmt
                        if var"##1151" isa Expr && (begin
                                        if var"##cache#1152" === nothing
                                            var"##cache#1152" = Some(((var"##1151").head, (var"##1151").args))
                                        end
                                        var"##1153" = (var"##cache#1152").value
                                        var"##1153" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##1153"[1] == :macrocall && (begin
                                                var"##1154" = var"##1153"[2]
                                                var"##1154" isa AbstractArray
                                            end && ((ndims(var"##1154") === 1 && length(var"##1154") >= 1) && begin
                                                    var"##1155" = var"##1154"[1]
                                                    var"##1155" == Symbol("@case")
                                                end))))
                            var"##return#1149" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1150#1156")))
                        end
                        begin
                            var"##return#1149" = let
                                    false
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1150#1156")))
                        end
                        error("matching non-exhaustive, at #= none:187 =#")
                        $(Expr(:symboliclabel, Symbol("####final#1150#1156")))
                        var"##return#1149"
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
                            var"##cache#1160" = nothing
                        end
                        var"##return#1157" = nothing
                        var"##1159" = stmt
                        if var"##1159" isa Expr && (begin
                                        if var"##cache#1160" === nothing
                                            var"##cache#1160" = Some(((var"##1159").head, (var"##1159").args))
                                        end
                                        var"##1161" = (var"##cache#1160").value
                                        var"##1161" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##1161"[1] == :macrocall && (begin
                                                var"##1162" = var"##1161"[2]
                                                var"##1162" isa AbstractArray
                                            end && (length(var"##1162") === 3 && (begin
                                                        var"##1163" = var"##1162"[1]
                                                        var"##1163" == Symbol("@case")
                                                    end && begin
                                                        var"##1164" = var"##1162"[2]
                                                        var"##1165" = var"##1162"[3]
                                                        true
                                                    end)))))
                            var"##return#1157" = let pattern = var"##1165", line = var"##1164"
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
                            $(Expr(:symbolicgoto, Symbol("####final#1158#1166")))
                        end
                        begin
                            var"##return#1157" = let
                                    p(stmt)
                                    println()
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1158#1166")))
                        end
                        error("matching non-exhaustive, at #= none:197 =#")
                        $(Expr(:symboliclabel, Symbol("####final#1158#1166")))
                        var"##return#1157"
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
                var"##cache#1170" = nothing
            end
            var"##1169" = ex
            if var"##1169" isa Expr
                if begin
                            if var"##cache#1170" === nothing
                                var"##cache#1170" = Some(((var"##1169").head, (var"##1169").args))
                            end
                            var"##1171" = (var"##cache#1170").value
                            var"##1171" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1171"[1] == :string && (begin
                                    var"##1172" = var"##1171"[2]
                                    var"##1172" isa AbstractArray
                                end && ((ndims(var"##1172") === 1 && length(var"##1172") >= 0) && begin
                                        var"##1173" = SubArray(var"##1172", (1:length(var"##1172"),))
                                        true
                                    end)))
                    args = var"##1173"
                    var"##return#1167" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1168#1375")))
                end
                if begin
                            var"##1174" = (var"##cache#1170").value
                            var"##1174" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1174"[1] == :block && (begin
                                    var"##1175" = var"##1174"[2]
                                    var"##1175" isa AbstractArray
                                end && ((ndims(var"##1175") === 1 && length(var"##1175") >= 0) && begin
                                        var"##1176" = SubArray(var"##1175", (1:length(var"##1175"),))
                                        true
                                    end)))
                    stmts = var"##1176"
                    var"##return#1167" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1168#1375")))
                end
                if begin
                            var"##1177" = (var"##cache#1170").value
                            var"##1177" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1177"[1] == :quote && (begin
                                    var"##1178" = var"##1177"[2]
                                    var"##1178" isa AbstractArray
                                end && (length(var"##1178") === 1 && (begin
                                            begin
                                                var"##cache#1180" = nothing
                                            end
                                            var"##1179" = var"##1178"[1]
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
                                                    end && ((ndims(var"##1182") === 1 && length(var"##1182") >= 0) && begin
                                                            var"##1183" = SubArray(var"##1182", (1:length(var"##1182"),))
                                                            let stmts = var"##1183"
                                                                is_root()
                                                            end
                                                        end))))))))
                    stmts = var"##1183"
                    var"##return#1167" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1168#1375")))
                end
                if begin
                            var"##1184" = (var"##cache#1170").value
                            var"##1184" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1184"[1] == :quote && (begin
                                    var"##1185" = var"##1184"[2]
                                    var"##1185" isa AbstractArray
                                end && (length(var"##1185") === 1 && (begin
                                            begin
                                                var"##cache#1187" = nothing
                                            end
                                            var"##1186" = var"##1185"[1]
                                            var"##1186" isa Expr
                                        end && (begin
                                                if var"##cache#1187" === nothing
                                                    var"##cache#1187" = Some(((var"##1186").head, (var"##1186").args))
                                                end
                                                var"##1188" = (var"##cache#1187").value
                                                var"##1188" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1188"[1] == :block && (begin
                                                        var"##1189" = var"##1188"[2]
                                                        var"##1189" isa AbstractArray
                                                    end && ((ndims(var"##1189") === 1 && length(var"##1189") >= 0) && begin
                                                            var"##1190" = SubArray(var"##1189", (1:length(var"##1189"),))
                                                            true
                                                        end))))))))
                    stmts = var"##1190"
                    var"##return#1167" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1168#1375")))
                end
                if begin
                            var"##1191" = (var"##cache#1170").value
                            var"##1191" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1191"[1] == :quote && (begin
                                    var"##1192" = var"##1191"[2]
                                    var"##1192" isa AbstractArray
                                end && (length(var"##1192") === 1 && begin
                                        var"##1193" = var"##1192"[1]
                                        true
                                    end)))
                    code = var"##1193"
                    var"##return#1167" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1168#1375")))
                end
                if begin
                            var"##1194" = (var"##cache#1170").value
                            var"##1194" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1194"[1] == :let && (begin
                                    var"##1195" = var"##1194"[2]
                                    var"##1195" isa AbstractArray
                                end && (length(var"##1195") === 2 && (begin
                                            begin
                                                var"##cache#1197" = nothing
                                            end
                                            var"##1196" = var"##1195"[1]
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
                                                    end && ((ndims(var"##1199") === 1 && length(var"##1199") >= 0) && (begin
                                                                var"##1200" = SubArray(var"##1199", (1:length(var"##1199"),))
                                                                begin
                                                                    var"##cache#1202" = nothing
                                                                end
                                                                var"##1201" = var"##1195"[2]
                                                                var"##1201" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1202" === nothing
                                                                        var"##cache#1202" = Some(((var"##1201").head, (var"##1201").args))
                                                                    end
                                                                    var"##1203" = (var"##cache#1202").value
                                                                    var"##1203" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1203"[1] == :block && (begin
                                                                            var"##1204" = var"##1203"[2]
                                                                            var"##1204" isa AbstractArray
                                                                        end && ((ndims(var"##1204") === 1 && length(var"##1204") >= 0) && begin
                                                                                var"##1205" = SubArray(var"##1204", (1:length(var"##1204"),))
                                                                                true
                                                                            end)))))))))))))
                    args = var"##1200"
                    stmts = var"##1205"
                    var"##return#1167" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1168#1375")))
                end
                if begin
                            var"##1206" = (var"##cache#1170").value
                            var"##1206" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1206"[1] == :if && (begin
                                    var"##1207" = var"##1206"[2]
                                    var"##1207" isa AbstractArray
                                end && (length(var"##1207") === 2 && begin
                                        var"##1208" = var"##1207"[1]
                                        var"##1209" = var"##1207"[2]
                                        true
                                    end)))
                    cond = var"##1208"
                    body = var"##1209"
                    var"##return#1167" = begin
                            print_if(cond, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1168#1375")))
                end
                if begin
                            var"##1210" = (var"##cache#1170").value
                            var"##1210" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1210"[1] == :if && (begin
                                    var"##1211" = var"##1210"[2]
                                    var"##1211" isa AbstractArray
                                end && (length(var"##1211") === 3 && begin
                                        var"##1212" = var"##1211"[1]
                                        var"##1213" = var"##1211"[2]
                                        var"##1214" = var"##1211"[3]
                                        true
                                    end)))
                    cond = var"##1212"
                    body = var"##1213"
                    otherwise = var"##1214"
                    var"##return#1167" = begin
                            print_if(cond, body, otherwise)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1168#1375")))
                end
                if begin
                            var"##1215" = (var"##cache#1170").value
                            var"##1215" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1215"[1] == :elseif && (begin
                                    var"##1216" = var"##1215"[2]
                                    var"##1216" isa AbstractArray
                                end && (length(var"##1216") === 2 && (begin
                                            begin
                                                var"##cache#1218" = nothing
                                            end
                                            var"##1217" = var"##1216"[1]
                                            var"##1217" isa Expr
                                        end && (begin
                                                if var"##cache#1218" === nothing
                                                    var"##cache#1218" = Some(((var"##1217").head, (var"##1217").args))
                                                end
                                                var"##1219" = (var"##cache#1218").value
                                                var"##1219" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1219"[1] == :block && (begin
                                                        var"##1220" = var"##1219"[2]
                                                        var"##1220" isa AbstractArray
                                                    end && (length(var"##1220") === 2 && begin
                                                            var"##1221" = var"##1220"[1]
                                                            var"##1222" = var"##1220"[2]
                                                            var"##1223" = var"##1216"[2]
                                                            true
                                                        end))))))))
                    line = var"##1221"
                    cond = var"##1222"
                    body = var"##1223"
                    var"##return#1167" = begin
                            print_elseif(cond, body, line)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1168#1375")))
                end
                if begin
                            var"##1224" = (var"##cache#1170").value
                            var"##1224" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1224"[1] == :elseif && (begin
                                    var"##1225" = var"##1224"[2]
                                    var"##1225" isa AbstractArray
                                end && (length(var"##1225") === 2 && begin
                                        var"##1226" = var"##1225"[1]
                                        var"##1227" = var"##1225"[2]
                                        true
                                    end)))
                    cond = var"##1226"
                    body = var"##1227"
                    var"##return#1167" = begin
                            print_elseif(cond, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1168#1375")))
                end
                if begin
                            var"##1228" = (var"##cache#1170").value
                            var"##1228" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1228"[1] == :elseif && (begin
                                    var"##1229" = var"##1228"[2]
                                    var"##1229" isa AbstractArray
                                end && (length(var"##1229") === 3 && (begin
                                            begin
                                                var"##cache#1231" = nothing
                                            end
                                            var"##1230" = var"##1229"[1]
                                            var"##1230" isa Expr
                                        end && (begin
                                                if var"##cache#1231" === nothing
                                                    var"##cache#1231" = Some(((var"##1230").head, (var"##1230").args))
                                                end
                                                var"##1232" = (var"##cache#1231").value
                                                var"##1232" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1232"[1] == :block && (begin
                                                        var"##1233" = var"##1232"[2]
                                                        var"##1233" isa AbstractArray
                                                    end && (length(var"##1233") === 2 && begin
                                                            var"##1234" = var"##1233"[1]
                                                            var"##1235" = var"##1233"[2]
                                                            var"##1236" = var"##1229"[2]
                                                            var"##1237" = var"##1229"[3]
                                                            true
                                                        end))))))))
                    line = var"##1234"
                    cond = var"##1235"
                    body = var"##1236"
                    otherwise = var"##1237"
                    var"##return#1167" = begin
                            print_elseif(cond, body, line, otherwise)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1168#1375")))
                end
                if begin
                            var"##1238" = (var"##cache#1170").value
                            var"##1238" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1238"[1] == :elseif && (begin
                                    var"##1239" = var"##1238"[2]
                                    var"##1239" isa AbstractArray
                                end && (length(var"##1239") === 3 && begin
                                        var"##1240" = var"##1239"[1]
                                        var"##1241" = var"##1239"[2]
                                        var"##1242" = var"##1239"[3]
                                        true
                                    end)))
                    cond = var"##1240"
                    body = var"##1241"
                    otherwise = var"##1242"
                    var"##return#1167" = begin
                            print_elseif(cond, body, nothing, otherwise)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1168#1375")))
                end
                if begin
                            var"##1243" = (var"##cache#1170").value
                            var"##1243" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1243"[1] == :for && (begin
                                    var"##1244" = var"##1243"[2]
                                    var"##1244" isa AbstractArray
                                end && (length(var"##1244") === 2 && begin
                                        var"##1245" = var"##1244"[1]
                                        var"##1246" = var"##1244"[2]
                                        true
                                    end)))
                    body = var"##1246"
                    iteration = var"##1245"
                    var"##return#1167" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1168#1375")))
                end
                if begin
                            var"##1247" = (var"##cache#1170").value
                            var"##1247" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1247"[1] == :while && (begin
                                    var"##1248" = var"##1247"[2]
                                    var"##1248" isa AbstractArray
                                end && (length(var"##1248") === 2 && begin
                                        var"##1249" = var"##1248"[1]
                                        var"##1250" = var"##1248"[2]
                                        true
                                    end)))
                    cond = var"##1249"
                    body = var"##1250"
                    var"##return#1167" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1168#1375")))
                end
                if begin
                            var"##1251" = (var"##cache#1170").value
                            var"##1251" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1251"[1] == :(=) && (begin
                                    var"##1252" = var"##1251"[2]
                                    var"##1252" isa AbstractArray
                                end && (length(var"##1252") === 2 && (begin
                                            var"##1253" = var"##1252"[1]
                                            begin
                                                var"##cache#1255" = nothing
                                            end
                                            var"##1254" = var"##1252"[2]
                                            var"##1254" isa Expr
                                        end && (begin
                                                if var"##cache#1255" === nothing
                                                    var"##cache#1255" = Some(((var"##1254").head, (var"##1254").args))
                                                end
                                                var"##1256" = (var"##cache#1255").value
                                                var"##1256" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1256"[1] == :block && (begin
                                                        var"##1257" = var"##1256"[2]
                                                        var"##1257" isa AbstractArray
                                                    end && (length(var"##1257") === 2 && (begin
                                                                var"##1258" = var"##1257"[1]
                                                                begin
                                                                    var"##cache#1260" = nothing
                                                                end
                                                                var"##1259" = var"##1257"[2]
                                                                var"##1259" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1260" === nothing
                                                                        var"##cache#1260" = Some(((var"##1259").head, (var"##1259").args))
                                                                    end
                                                                    var"##1261" = (var"##cache#1260").value
                                                                    var"##1261" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1261"[1] == :if && (begin
                                                                            var"##1262" = var"##1261"[2]
                                                                            var"##1262" isa AbstractArray
                                                                        end && ((ndims(var"##1262") === 1 && length(var"##1262") >= 0) && let line = var"##1258", lhs = var"##1253"
                                                                                is_line_no(line)
                                                                            end)))))))))))))
                    line = var"##1258"
                    lhs = var"##1253"
                    var"##return#1167" = begin
                            leading_tab()
                            inline(lhs)
                            keyword(" = ")
                            inline(line)
                            p(ex.args[2])
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1168#1375")))
                end
                if begin
                            var"##1263" = (var"##cache#1170").value
                            var"##1263" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1263"[1] == :(=) && (begin
                                    var"##1264" = var"##1263"[2]
                                    var"##1264" isa AbstractArray
                                end && (length(var"##1264") === 2 && (begin
                                            var"##1265" = var"##1264"[1]
                                            begin
                                                var"##cache#1267" = nothing
                                            end
                                            var"##1266" = var"##1264"[2]
                                            var"##1266" isa Expr
                                        end && (begin
                                                if var"##cache#1267" === nothing
                                                    var"##cache#1267" = Some(((var"##1266").head, (var"##1266").args))
                                                end
                                                var"##1268" = (var"##cache#1267").value
                                                var"##1268" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1268"[1] == :block && (begin
                                                        var"##1269" = var"##1268"[2]
                                                        var"##1269" isa AbstractArray
                                                    end && (length(var"##1269") === 2 && begin
                                                            var"##1270" = var"##1269"[1]
                                                            var"##1271" = var"##1269"[2]
                                                            let rhs = var"##1271", line = var"##1270", lhs = var"##1265"
                                                                is_line_no(line)
                                                            end
                                                        end))))))))
                    rhs = var"##1271"
                    line = var"##1270"
                    lhs = var"##1265"
                    var"##return#1167" = begin
                            leading_tab()
                            inline(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1168#1375")))
                end
                if begin
                            var"##1272" = (var"##cache#1170").value
                            var"##1272" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1272"[1] == :(=) && (begin
                                    var"##1273" = var"##1272"[2]
                                    var"##1273" isa AbstractArray
                                end && (length(var"##1273") === 2 && begin
                                        var"##1274" = var"##1273"[1]
                                        var"##1275" = var"##1273"[2]
                                        true
                                    end)))
                    rhs = var"##1275"
                    lhs = var"##1274"
                    var"##return#1167" = begin
                            leading_tab()
                            inline(lhs)
                            print(" = ")
                            p(rhs)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1168#1375")))
                end
                if begin
                            var"##1276" = (var"##cache#1170").value
                            var"##1276" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1276"[1] == :function && (begin
                                    var"##1277" = var"##1276"[2]
                                    var"##1277" isa AbstractArray
                                end && (length(var"##1277") === 2 && begin
                                        var"##1278" = var"##1277"[1]
                                        var"##1279" = var"##1277"[2]
                                        true
                                    end)))
                    call = var"##1278"
                    body = var"##1279"
                    var"##return#1167" = begin
                            print_function(:function, call, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1168#1375")))
                end
                if begin
                            var"##1280" = (var"##cache#1170").value
                            var"##1280" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1280"[1] == :-> && (begin
                                    var"##1281" = var"##1280"[2]
                                    var"##1281" isa AbstractArray
                                end && (length(var"##1281") === 2 && begin
                                        var"##1282" = var"##1281"[1]
                                        var"##1283" = var"##1281"[2]
                                        true
                                    end)))
                    call = var"##1282"
                    body = var"##1283"
                    var"##return#1167" = begin
                            leading_tab()
                            inline(call)
                            keyword(" -> ")
                            p(body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1168#1375")))
                end
                if begin
                            var"##1284" = (var"##cache#1170").value
                            var"##1284" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1284"[1] == :do && (begin
                                    var"##1285" = var"##1284"[2]
                                    var"##1285" isa AbstractArray
                                end && (length(var"##1285") === 2 && (begin
                                            var"##1286" = var"##1285"[1]
                                            begin
                                                var"##cache#1288" = nothing
                                            end
                                            var"##1287" = var"##1285"[2]
                                            var"##1287" isa Expr
                                        end && (begin
                                                if var"##cache#1288" === nothing
                                                    var"##cache#1288" = Some(((var"##1287").head, (var"##1287").args))
                                                end
                                                var"##1289" = (var"##cache#1288").value
                                                var"##1289" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1289"[1] == :-> && (begin
                                                        var"##1290" = var"##1289"[2]
                                                        var"##1290" isa AbstractArray
                                                    end && (length(var"##1290") === 2 && (begin
                                                                begin
                                                                    var"##cache#1292" = nothing
                                                                end
                                                                var"##1291" = var"##1290"[1]
                                                                var"##1291" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1292" === nothing
                                                                        var"##cache#1292" = Some(((var"##1291").head, (var"##1291").args))
                                                                    end
                                                                    var"##1293" = (var"##cache#1292").value
                                                                    var"##1293" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1293"[1] == :tuple && (begin
                                                                            var"##1294" = var"##1293"[2]
                                                                            var"##1294" isa AbstractArray
                                                                        end && ((ndims(var"##1294") === 1 && length(var"##1294") >= 0) && begin
                                                                                var"##1295" = SubArray(var"##1294", (1:length(var"##1294"),))
                                                                                var"##1296" = var"##1290"[2]
                                                                                true
                                                                            end)))))))))))))
                    call = var"##1286"
                    args = var"##1295"
                    body = var"##1296"
                    var"##return#1167" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1168#1375")))
                end
                if begin
                            var"##1297" = (var"##cache#1170").value
                            var"##1297" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1297"[1] == :macro && (begin
                                    var"##1298" = var"##1297"[2]
                                    var"##1298" isa AbstractArray
                                end && (length(var"##1298") === 2 && begin
                                        var"##1299" = var"##1298"[1]
                                        var"##1300" = var"##1298"[2]
                                        true
                                    end)))
                    call = var"##1299"
                    body = var"##1300"
                    var"##return#1167" = begin
                            print_function(:macro, call, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1168#1375")))
                end
                if begin
                            var"##1301" = (var"##cache#1170").value
                            var"##1301" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1301"[1] == :macrocall && (begin
                                    var"##1302" = var"##1301"[2]
                                    var"##1302" isa AbstractArray
                                end && (length(var"##1302") === 4 && (begin
                                            var"##1303" = var"##1302"[1]
                                            var"##1303" == Symbol("@switch")
                                        end && (begin
                                                var"##1304" = var"##1302"[2]
                                                var"##1305" = var"##1302"[3]
                                                begin
                                                    var"##cache#1307" = nothing
                                                end
                                                var"##1306" = var"##1302"[4]
                                                var"##1306" isa Expr
                                            end && (begin
                                                    if var"##cache#1307" === nothing
                                                        var"##cache#1307" = Some(((var"##1306").head, (var"##1306").args))
                                                    end
                                                    var"##1308" = (var"##cache#1307").value
                                                    var"##1308" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1308"[1] == :block && (begin
                                                            var"##1309" = var"##1308"[2]
                                                            var"##1309" isa AbstractArray
                                                        end && ((ndims(var"##1309") === 1 && length(var"##1309") >= 0) && begin
                                                                var"##1310" = SubArray(var"##1309", (1:length(var"##1309"),))
                                                                true
                                                            end)))))))))
                    item = var"##1305"
                    line = var"##1304"
                    stmts = var"##1310"
                    var"##return#1167" = begin
                            print_switch(item, line, stmts)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1168#1375")))
                end
                if begin
                            var"##1311" = (var"##cache#1170").value
                            var"##1311" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1311"[1] == :macrocall && (begin
                                    var"##1312" = var"##1311"[2]
                                    var"##1312" isa AbstractArray
                                end && (length(var"##1312") === 4 && (begin
                                            var"##1313" = var"##1312"[1]
                                            var"##1313" == GlobalRef(Core, Symbol("@doc"))
                                        end && begin
                                            var"##1314" = var"##1312"[2]
                                            var"##1315" = var"##1312"[3]
                                            var"##1316" = var"##1312"[4]
                                            true
                                        end))))
                    line = var"##1314"
                    code = var"##1316"
                    doc = var"##1315"
                    var"##return#1167" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1168#1375")))
                end
                if begin
                            var"##1317" = (var"##cache#1170").value
                            var"##1317" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1317"[1] == :macrocall && (begin
                                    var"##1318" = var"##1317"[2]
                                    var"##1318" isa AbstractArray
                                end && ((ndims(var"##1318") === 1 && length(var"##1318") >= 2) && begin
                                        var"##1319" = var"##1318"[1]
                                        var"##1320" = var"##1318"[2]
                                        var"##1321" = SubArray(var"##1318", (3:length(var"##1318"),))
                                        true
                                    end)))
                    line = var"##1320"
                    name = var"##1319"
                    args = var"##1321"
                    var"##return#1167" = begin
                            print_macrocall(name, line, args)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1168#1375")))
                end
                if begin
                            var"##1322" = (var"##cache#1170").value
                            var"##1322" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1322"[1] == :struct && (begin
                                    var"##1323" = var"##1322"[2]
                                    var"##1323" isa AbstractArray
                                end && (length(var"##1323") === 3 && begin
                                        var"##1324" = var"##1323"[1]
                                        var"##1325" = var"##1323"[2]
                                        var"##1326" = var"##1323"[3]
                                        true
                                    end)))
                    ismutable = var"##1324"
                    body = var"##1326"
                    head = var"##1325"
                    var"##return#1167" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1168#1375")))
                end
                if begin
                            var"##1327" = (var"##cache#1170").value
                            var"##1327" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1327"[1] == :try && (begin
                                    var"##1328" = var"##1327"[2]
                                    var"##1328" isa AbstractArray
                                end && (length(var"##1328") === 3 && begin
                                        var"##1329" = var"##1328"[1]
                                        var"##1330" = var"##1328"[2]
                                        var"##1331" = var"##1328"[3]
                                        true
                                    end)))
                    catch_vars = var"##1330"
                    catch_body = var"##1331"
                    try_body = var"##1329"
                    var"##return#1167" = begin
                            print_try(try_body)
                            print_catch(catch_body, catch_vars)
                            println()
                            tab()
                            keyword("end")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1168#1375")))
                end
                if begin
                            var"##1332" = (var"##cache#1170").value
                            var"##1332" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1332"[1] == :try && (begin
                                    var"##1333" = var"##1332"[2]
                                    var"##1333" isa AbstractArray
                                end && (length(var"##1333") === 4 && begin
                                        var"##1334" = var"##1333"[1]
                                        var"##1335" = var"##1333"[2]
                                        var"##1336" = var"##1333"[3]
                                        var"##1337" = var"##1333"[4]
                                        true
                                    end)))
                    catch_vars = var"##1335"
                    catch_body = var"##1336"
                    try_body = var"##1334"
                    finally_body = var"##1337"
                    var"##return#1167" = begin
                            print_try(try_body)
                            print_catch(catch_body, catch_vars)
                            print_finally(finally_body)
                            println()
                            tab()
                            keyword("end")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1168#1375")))
                end
                if begin
                            var"##1338" = (var"##cache#1170").value
                            var"##1338" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1338"[1] == :try && (begin
                                    var"##1339" = var"##1338"[2]
                                    var"##1339" isa AbstractArray
                                end && (length(var"##1339") === 5 && begin
                                        var"##1340" = var"##1339"[1]
                                        var"##1341" = var"##1339"[2]
                                        var"##1342" = var"##1339"[3]
                                        var"##1343" = var"##1339"[4]
                                        var"##1344" = var"##1339"[5]
                                        true
                                    end)))
                    catch_vars = var"##1341"
                    catch_body = var"##1342"
                    try_body = var"##1340"
                    finally_body = var"##1343"
                    else_body = var"##1344"
                    var"##return#1167" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1168#1375")))
                end
                if begin
                            var"##1345" = (var"##cache#1170").value
                            var"##1345" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1345"[1] == :module && (begin
                                    var"##1346" = var"##1345"[2]
                                    var"##1346" isa AbstractArray
                                end && (length(var"##1346") === 3 && begin
                                        var"##1347" = var"##1346"[1]
                                        var"##1348" = var"##1346"[2]
                                        var"##1349" = var"##1346"[3]
                                        true
                                    end)))
                    name = var"##1348"
                    body = var"##1349"
                    notbare = var"##1347"
                    var"##return#1167" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1168#1375")))
                end
                if begin
                            var"##1350" = (var"##cache#1170").value
                            var"##1350" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1350"[1] == :const && (begin
                                    var"##1351" = var"##1350"[2]
                                    var"##1351" isa AbstractArray
                                end && (length(var"##1351") === 1 && begin
                                        var"##1352" = var"##1351"[1]
                                        true
                                    end)))
                    code = var"##1352"
                    var"##return#1167" = begin
                            leading_tab()
                            keyword("const ")
                            p(code)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1168#1375")))
                end
                if begin
                            var"##1353" = (var"##cache#1170").value
                            var"##1353" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1353"[1] == :return && (begin
                                    var"##1354" = var"##1353"[2]
                                    var"##1354" isa AbstractArray
                                end && (length(var"##1354") === 1 && (begin
                                            begin
                                                var"##cache#1356" = nothing
                                            end
                                            var"##1355" = var"##1354"[1]
                                            var"##1355" isa Expr
                                        end && (begin
                                                if var"##cache#1356" === nothing
                                                    var"##cache#1356" = Some(((var"##1355").head, (var"##1355").args))
                                                end
                                                var"##1357" = (var"##cache#1356").value
                                                var"##1357" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1357"[1] == :tuple && (begin
                                                        var"##1358" = var"##1357"[2]
                                                        var"##1358" isa AbstractArray
                                                    end && ((ndims(var"##1358") === 1 && length(var"##1358") >= 1) && (begin
                                                                begin
                                                                    var"##cache#1360" = nothing
                                                                end
                                                                var"##1359" = var"##1358"[1]
                                                                var"##1359" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1360" === nothing
                                                                        var"##cache#1360" = Some(((var"##1359").head, (var"##1359").args))
                                                                    end
                                                                    var"##1361" = (var"##cache#1360").value
                                                                    var"##1361" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1361"[1] == :parameters && (begin
                                                                            var"##1362" = var"##1361"[2]
                                                                            var"##1362" isa AbstractArray
                                                                        end && (ndims(var"##1362") === 1 && length(var"##1362") >= 0)))))))))))))
                    var"##return#1167" = begin
                            inline(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1168#1375")))
                end
                if begin
                            var"##1363" = (var"##cache#1170").value
                            var"##1363" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1363"[1] == :return && (begin
                                    var"##1364" = var"##1363"[2]
                                    var"##1364" isa AbstractArray
                                end && (length(var"##1364") === 1 && (begin
                                            begin
                                                var"##cache#1366" = nothing
                                            end
                                            var"##1365" = var"##1364"[1]
                                            var"##1365" isa Expr
                                        end && (begin
                                                if var"##cache#1366" === nothing
                                                    var"##cache#1366" = Some(((var"##1365").head, (var"##1365").args))
                                                end
                                                var"##1367" = (var"##cache#1366").value
                                                var"##1367" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1367"[1] == :tuple && (begin
                                                        var"##1368" = var"##1367"[2]
                                                        var"##1368" isa AbstractArray
                                                    end && (ndims(var"##1368") === 1 && length(var"##1368") >= 0))))))))
                    var"##return#1167" = begin
                            inline(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1168#1375")))
                end
                if begin
                            var"##1369" = (var"##cache#1170").value
                            var"##1369" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1369"[1] == :return && (begin
                                    var"##1370" = var"##1369"[2]
                                    var"##1370" isa AbstractArray
                                end && (length(var"##1370") === 1 && begin
                                        var"##1371" = var"##1370"[1]
                                        true
                                    end)))
                    code = var"##1371"
                    var"##return#1167" = begin
                            leading_tab()
                            keyword("return ")
                            p(code)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1168#1375")))
                end
                if begin
                            var"##1372" = (var"##cache#1170").value
                            var"##1372" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1372"[1] == :toplevel && (begin
                                    var"##1373" = var"##1372"[2]
                                    var"##1373" isa AbstractArray
                                end && (length(var"##1373") === 1 && begin
                                        var"##1374" = var"##1373"[1]
                                        true
                                    end)))
                    code = var"##1374"
                    var"##return#1167" = begin
                            leading_tab()
                            printstyled("#= meta: toplevel =#", color = c.comment)
                            println()
                            p(code)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1168#1375")))
                end
            end
            if var"##1169" isa String
                begin
                    var"##return#1167" = begin
                            leading_tab()
                            occursin('\n', ex) || return inline(ex)
                            printstyled("\"\"\"\n", color = c.string)
                            tab()
                            print_multi_lines(ex)
                            printstyled("\"\"\"", color = c.string)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1168#1375")))
                end
            end
            begin
                var"##return#1167" = begin
                        inline(ex)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#1168#1375")))
            end
            error("matching non-exhaustive, at #= none:246 =#")
            $(Expr(:symboliclabel, Symbol("####final#1168#1375")))
            var"##return#1167"
        end
        return nothing
    end
    #= none:468 =# Core.@doc "    print_expr([io::IO], ex; kw...)\n\nPrint a given expression. `ex` can be a `Expr` or a syntax type `JLExpr`.\n" print_expr(io::IO, ex; kw...) = begin
                (Printer(io; kw...))(ex)
            end
    print_expr(ex; kw...) = begin
            print_expr(stdout, ex; kw...)
        end
