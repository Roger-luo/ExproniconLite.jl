
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
                    var"##cache#1140" = nothing
                end
                var"##return#1137" = nothing
                var"##1139" = otherwise
                if var"##1139" isa Expr && (begin
                                if var"##cache#1140" === nothing
                                    var"##cache#1140" = Some(((var"##1139").head, (var"##1139").args))
                                end
                                var"##1141" = (var"##cache#1140").value
                                var"##1141" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1141"[1] == :block && (begin
                                        var"##1142" = var"##1141"[2]
                                        var"##1142" isa AbstractArray
                                    end && ((ndims(var"##1142") === 1 && length(var"##1142") >= 0) && begin
                                            var"##1143" = SubArray(var"##1142", (1:length(var"##1142"),))
                                            true
                                        end))))
                    var"##return#1137" = let stmts = var"##1143"
                            indent() do 
                                print_stmts(stmts)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1138#1144")))
                end
                begin
                    var"##return#1137" = let
                            indent() do 
                                tab()
                                no_first_line_indent() do 
                                    p(otherwise)
                                end
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1138#1144")))
                end
                error("matching non-exhaustive, at #= none:98 =#")
                $(Expr(:symboliclabel, Symbol("####final#1138#1144")))
                var"##return#1137"
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
                            var"##cache#1148" = nothing
                        end
                        var"##return#1145" = nothing
                        var"##1147" = stmt
                        if var"##1147" isa Expr && (begin
                                        if var"##cache#1148" === nothing
                                            var"##cache#1148" = Some(((var"##1147").head, (var"##1147").args))
                                        end
                                        var"##1149" = (var"##cache#1148").value
                                        var"##1149" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##1149"[1] == :macrocall && (begin
                                                var"##1150" = var"##1149"[2]
                                                var"##1150" isa AbstractArray
                                            end && ((ndims(var"##1150") === 1 && length(var"##1150") >= 1) && begin
                                                    var"##1151" = var"##1150"[1]
                                                    var"##1151" == Symbol("@case")
                                                end))))
                            var"##return#1145" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1146#1152")))
                        end
                        begin
                            var"##return#1145" = let
                                    false
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1146#1152")))
                        end
                        error("matching non-exhaustive, at #= none:181 =#")
                        $(Expr(:symboliclabel, Symbol("####final#1146#1152")))
                        var"##return#1145"
                    end
                end || return print_macrocall("@switch", line, (item, Expr(:block, stmts...)))
            is_case(stmt) = begin
                    let
                        begin
                            var"##cache#1156" = nothing
                        end
                        var"##return#1153" = nothing
                        var"##1155" = stmt
                        if var"##1155" isa Expr && (begin
                                        if var"##cache#1156" === nothing
                                            var"##cache#1156" = Some(((var"##1155").head, (var"##1155").args))
                                        end
                                        var"##1157" = (var"##cache#1156").value
                                        var"##1157" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##1157"[1] == :macrocall && (begin
                                                var"##1158" = var"##1157"[2]
                                                var"##1158" isa AbstractArray
                                            end && ((ndims(var"##1158") === 1 && length(var"##1158") >= 1) && begin
                                                    var"##1159" = var"##1158"[1]
                                                    var"##1159" == Symbol("@case")
                                                end))))
                            var"##return#1153" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1154#1160")))
                        end
                        begin
                            var"##return#1153" = let
                                    false
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1154#1160")))
                        end
                        error("matching non-exhaustive, at #= none:187 =#")
                        $(Expr(:symboliclabel, Symbol("####final#1154#1160")))
                        var"##return#1153"
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
                            var"##cache#1164" = nothing
                        end
                        var"##return#1161" = nothing
                        var"##1163" = stmt
                        if var"##1163" isa Expr && (begin
                                        if var"##cache#1164" === nothing
                                            var"##cache#1164" = Some(((var"##1163").head, (var"##1163").args))
                                        end
                                        var"##1165" = (var"##cache#1164").value
                                        var"##1165" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##1165"[1] == :macrocall && (begin
                                                var"##1166" = var"##1165"[2]
                                                var"##1166" isa AbstractArray
                                            end && (length(var"##1166") === 3 && (begin
                                                        var"##1167" = var"##1166"[1]
                                                        var"##1167" == Symbol("@case")
                                                    end && begin
                                                        var"##1168" = var"##1166"[2]
                                                        var"##1169" = var"##1166"[3]
                                                        true
                                                    end)))))
                            var"##return#1161" = let pattern = var"##1169", line = var"##1168"
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
                            $(Expr(:symbolicgoto, Symbol("####final#1162#1170")))
                        end
                        begin
                            var"##return#1161" = let
                                    p(stmt)
                                    println()
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1162#1170")))
                        end
                        error("matching non-exhaustive, at #= none:197 =#")
                        $(Expr(:symboliclabel, Symbol("####final#1162#1170")))
                        var"##return#1161"
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
                var"##cache#1174" = nothing
            end
            var"##1173" = ex
            if var"##1173" isa Expr
                if begin
                            if var"##cache#1174" === nothing
                                var"##cache#1174" = Some(((var"##1173").head, (var"##1173").args))
                            end
                            var"##1175" = (var"##cache#1174").value
                            var"##1175" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1175"[1] == :string && (begin
                                    var"##1176" = var"##1175"[2]
                                    var"##1176" isa AbstractArray
                                end && ((ndims(var"##1176") === 1 && length(var"##1176") >= 0) && begin
                                        var"##1177" = SubArray(var"##1176", (1:length(var"##1176"),))
                                        true
                                    end)))
                    args = var"##1177"
                    var"##return#1171" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1172#1379")))
                end
                if begin
                            var"##1178" = (var"##cache#1174").value
                            var"##1178" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1178"[1] == :block && (begin
                                    var"##1179" = var"##1178"[2]
                                    var"##1179" isa AbstractArray
                                end && ((ndims(var"##1179") === 1 && length(var"##1179") >= 0) && begin
                                        var"##1180" = SubArray(var"##1179", (1:length(var"##1179"),))
                                        true
                                    end)))
                    stmts = var"##1180"
                    var"##return#1171" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1172#1379")))
                end
                if begin
                            var"##1181" = (var"##cache#1174").value
                            var"##1181" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1181"[1] == :quote && (begin
                                    var"##1182" = var"##1181"[2]
                                    var"##1182" isa AbstractArray
                                end && (length(var"##1182") === 1 && (begin
                                            begin
                                                var"##cache#1184" = nothing
                                            end
                                            var"##1183" = var"##1182"[1]
                                            var"##1183" isa Expr
                                        end && (begin
                                                if var"##cache#1184" === nothing
                                                    var"##cache#1184" = Some(((var"##1183").head, (var"##1183").args))
                                                end
                                                var"##1185" = (var"##cache#1184").value
                                                var"##1185" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1185"[1] == :block && (begin
                                                        var"##1186" = var"##1185"[2]
                                                        var"##1186" isa AbstractArray
                                                    end && ((ndims(var"##1186") === 1 && length(var"##1186") >= 0) && begin
                                                            var"##1187" = SubArray(var"##1186", (1:length(var"##1186"),))
                                                            let stmts = var"##1187"
                                                                is_root()
                                                            end
                                                        end))))))))
                    stmts = var"##1187"
                    var"##return#1171" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1172#1379")))
                end
                if begin
                            var"##1188" = (var"##cache#1174").value
                            var"##1188" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1188"[1] == :quote && (begin
                                    var"##1189" = var"##1188"[2]
                                    var"##1189" isa AbstractArray
                                end && (length(var"##1189") === 1 && (begin
                                            begin
                                                var"##cache#1191" = nothing
                                            end
                                            var"##1190" = var"##1189"[1]
                                            var"##1190" isa Expr
                                        end && (begin
                                                if var"##cache#1191" === nothing
                                                    var"##cache#1191" = Some(((var"##1190").head, (var"##1190").args))
                                                end
                                                var"##1192" = (var"##cache#1191").value
                                                var"##1192" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1192"[1] == :block && (begin
                                                        var"##1193" = var"##1192"[2]
                                                        var"##1193" isa AbstractArray
                                                    end && ((ndims(var"##1193") === 1 && length(var"##1193") >= 0) && begin
                                                            var"##1194" = SubArray(var"##1193", (1:length(var"##1193"),))
                                                            true
                                                        end))))))))
                    stmts = var"##1194"
                    var"##return#1171" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1172#1379")))
                end
                if begin
                            var"##1195" = (var"##cache#1174").value
                            var"##1195" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1195"[1] == :quote && (begin
                                    var"##1196" = var"##1195"[2]
                                    var"##1196" isa AbstractArray
                                end && (length(var"##1196") === 1 && begin
                                        var"##1197" = var"##1196"[1]
                                        true
                                    end)))
                    code = var"##1197"
                    var"##return#1171" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1172#1379")))
                end
                if begin
                            var"##1198" = (var"##cache#1174").value
                            var"##1198" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1198"[1] == :let && (begin
                                    var"##1199" = var"##1198"[2]
                                    var"##1199" isa AbstractArray
                                end && (length(var"##1199") === 2 && (begin
                                            begin
                                                var"##cache#1201" = nothing
                                            end
                                            var"##1200" = var"##1199"[1]
                                            var"##1200" isa Expr
                                        end && (begin
                                                if var"##cache#1201" === nothing
                                                    var"##cache#1201" = Some(((var"##1200").head, (var"##1200").args))
                                                end
                                                var"##1202" = (var"##cache#1201").value
                                                var"##1202" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1202"[1] == :block && (begin
                                                        var"##1203" = var"##1202"[2]
                                                        var"##1203" isa AbstractArray
                                                    end && ((ndims(var"##1203") === 1 && length(var"##1203") >= 0) && (begin
                                                                var"##1204" = SubArray(var"##1203", (1:length(var"##1203"),))
                                                                begin
                                                                    var"##cache#1206" = nothing
                                                                end
                                                                var"##1205" = var"##1199"[2]
                                                                var"##1205" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1206" === nothing
                                                                        var"##cache#1206" = Some(((var"##1205").head, (var"##1205").args))
                                                                    end
                                                                    var"##1207" = (var"##cache#1206").value
                                                                    var"##1207" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1207"[1] == :block && (begin
                                                                            var"##1208" = var"##1207"[2]
                                                                            var"##1208" isa AbstractArray
                                                                        end && ((ndims(var"##1208") === 1 && length(var"##1208") >= 0) && begin
                                                                                var"##1209" = SubArray(var"##1208", (1:length(var"##1208"),))
                                                                                true
                                                                            end)))))))))))))
                    args = var"##1204"
                    stmts = var"##1209"
                    var"##return#1171" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1172#1379")))
                end
                if begin
                            var"##1210" = (var"##cache#1174").value
                            var"##1210" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1210"[1] == :if && (begin
                                    var"##1211" = var"##1210"[2]
                                    var"##1211" isa AbstractArray
                                end && (length(var"##1211") === 2 && begin
                                        var"##1212" = var"##1211"[1]
                                        var"##1213" = var"##1211"[2]
                                        true
                                    end)))
                    cond = var"##1212"
                    body = var"##1213"
                    var"##return#1171" = begin
                            print_if(cond, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1172#1379")))
                end
                if begin
                            var"##1214" = (var"##cache#1174").value
                            var"##1214" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1214"[1] == :if && (begin
                                    var"##1215" = var"##1214"[2]
                                    var"##1215" isa AbstractArray
                                end && (length(var"##1215") === 3 && begin
                                        var"##1216" = var"##1215"[1]
                                        var"##1217" = var"##1215"[2]
                                        var"##1218" = var"##1215"[3]
                                        true
                                    end)))
                    cond = var"##1216"
                    body = var"##1217"
                    otherwise = var"##1218"
                    var"##return#1171" = begin
                            print_if(cond, body, otherwise)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1172#1379")))
                end
                if begin
                            var"##1219" = (var"##cache#1174").value
                            var"##1219" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1219"[1] == :elseif && (begin
                                    var"##1220" = var"##1219"[2]
                                    var"##1220" isa AbstractArray
                                end && (length(var"##1220") === 2 && (begin
                                            begin
                                                var"##cache#1222" = nothing
                                            end
                                            var"##1221" = var"##1220"[1]
                                            var"##1221" isa Expr
                                        end && (begin
                                                if var"##cache#1222" === nothing
                                                    var"##cache#1222" = Some(((var"##1221").head, (var"##1221").args))
                                                end
                                                var"##1223" = (var"##cache#1222").value
                                                var"##1223" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1223"[1] == :block && (begin
                                                        var"##1224" = var"##1223"[2]
                                                        var"##1224" isa AbstractArray
                                                    end && (length(var"##1224") === 2 && begin
                                                            var"##1225" = var"##1224"[1]
                                                            var"##1226" = var"##1224"[2]
                                                            var"##1227" = var"##1220"[2]
                                                            true
                                                        end))))))))
                    line = var"##1225"
                    cond = var"##1226"
                    body = var"##1227"
                    var"##return#1171" = begin
                            print_elseif(cond, body, line)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1172#1379")))
                end
                if begin
                            var"##1228" = (var"##cache#1174").value
                            var"##1228" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1228"[1] == :elseif && (begin
                                    var"##1229" = var"##1228"[2]
                                    var"##1229" isa AbstractArray
                                end && (length(var"##1229") === 2 && begin
                                        var"##1230" = var"##1229"[1]
                                        var"##1231" = var"##1229"[2]
                                        true
                                    end)))
                    cond = var"##1230"
                    body = var"##1231"
                    var"##return#1171" = begin
                            print_elseif(cond, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1172#1379")))
                end
                if begin
                            var"##1232" = (var"##cache#1174").value
                            var"##1232" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1232"[1] == :elseif && (begin
                                    var"##1233" = var"##1232"[2]
                                    var"##1233" isa AbstractArray
                                end && (length(var"##1233") === 3 && (begin
                                            begin
                                                var"##cache#1235" = nothing
                                            end
                                            var"##1234" = var"##1233"[1]
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
                                                    end && (length(var"##1237") === 2 && begin
                                                            var"##1238" = var"##1237"[1]
                                                            var"##1239" = var"##1237"[2]
                                                            var"##1240" = var"##1233"[2]
                                                            var"##1241" = var"##1233"[3]
                                                            true
                                                        end))))))))
                    line = var"##1238"
                    cond = var"##1239"
                    body = var"##1240"
                    otherwise = var"##1241"
                    var"##return#1171" = begin
                            print_elseif(cond, body, line, otherwise)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1172#1379")))
                end
                if begin
                            var"##1242" = (var"##cache#1174").value
                            var"##1242" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1242"[1] == :elseif && (begin
                                    var"##1243" = var"##1242"[2]
                                    var"##1243" isa AbstractArray
                                end && (length(var"##1243") === 3 && begin
                                        var"##1244" = var"##1243"[1]
                                        var"##1245" = var"##1243"[2]
                                        var"##1246" = var"##1243"[3]
                                        true
                                    end)))
                    cond = var"##1244"
                    body = var"##1245"
                    otherwise = var"##1246"
                    var"##return#1171" = begin
                            print_elseif(cond, body, nothing, otherwise)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1172#1379")))
                end
                if begin
                            var"##1247" = (var"##cache#1174").value
                            var"##1247" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1247"[1] == :for && (begin
                                    var"##1248" = var"##1247"[2]
                                    var"##1248" isa AbstractArray
                                end && (length(var"##1248") === 2 && begin
                                        var"##1249" = var"##1248"[1]
                                        var"##1250" = var"##1248"[2]
                                        true
                                    end)))
                    body = var"##1250"
                    iteration = var"##1249"
                    var"##return#1171" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1172#1379")))
                end
                if begin
                            var"##1251" = (var"##cache#1174").value
                            var"##1251" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1251"[1] == :while && (begin
                                    var"##1252" = var"##1251"[2]
                                    var"##1252" isa AbstractArray
                                end && (length(var"##1252") === 2 && begin
                                        var"##1253" = var"##1252"[1]
                                        var"##1254" = var"##1252"[2]
                                        true
                                    end)))
                    cond = var"##1253"
                    body = var"##1254"
                    var"##return#1171" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1172#1379")))
                end
                if begin
                            var"##1255" = (var"##cache#1174").value
                            var"##1255" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1255"[1] == :(=) && (begin
                                    var"##1256" = var"##1255"[2]
                                    var"##1256" isa AbstractArray
                                end && (length(var"##1256") === 2 && (begin
                                            var"##1257" = var"##1256"[1]
                                            begin
                                                var"##cache#1259" = nothing
                                            end
                                            var"##1258" = var"##1256"[2]
                                            var"##1258" isa Expr
                                        end && (begin
                                                if var"##cache#1259" === nothing
                                                    var"##cache#1259" = Some(((var"##1258").head, (var"##1258").args))
                                                end
                                                var"##1260" = (var"##cache#1259").value
                                                var"##1260" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1260"[1] == :block && (begin
                                                        var"##1261" = var"##1260"[2]
                                                        var"##1261" isa AbstractArray
                                                    end && (length(var"##1261") === 2 && (begin
                                                                var"##1262" = var"##1261"[1]
                                                                begin
                                                                    var"##cache#1264" = nothing
                                                                end
                                                                var"##1263" = var"##1261"[2]
                                                                var"##1263" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1264" === nothing
                                                                        var"##cache#1264" = Some(((var"##1263").head, (var"##1263").args))
                                                                    end
                                                                    var"##1265" = (var"##cache#1264").value
                                                                    var"##1265" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1265"[1] == :if && (begin
                                                                            var"##1266" = var"##1265"[2]
                                                                            var"##1266" isa AbstractArray
                                                                        end && ((ndims(var"##1266") === 1 && length(var"##1266") >= 0) && let line = var"##1262", lhs = var"##1257"
                                                                                is_line_no(line)
                                                                            end)))))))))))))
                    line = var"##1262"
                    lhs = var"##1257"
                    var"##return#1171" = begin
                            leading_tab()
                            inline(lhs)
                            keyword(" = ")
                            inline(line)
                            p(ex.args[2])
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1172#1379")))
                end
                if begin
                            var"##1267" = (var"##cache#1174").value
                            var"##1267" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1267"[1] == :(=) && (begin
                                    var"##1268" = var"##1267"[2]
                                    var"##1268" isa AbstractArray
                                end && (length(var"##1268") === 2 && (begin
                                            var"##1269" = var"##1268"[1]
                                            begin
                                                var"##cache#1271" = nothing
                                            end
                                            var"##1270" = var"##1268"[2]
                                            var"##1270" isa Expr
                                        end && (begin
                                                if var"##cache#1271" === nothing
                                                    var"##cache#1271" = Some(((var"##1270").head, (var"##1270").args))
                                                end
                                                var"##1272" = (var"##cache#1271").value
                                                var"##1272" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1272"[1] == :block && (begin
                                                        var"##1273" = var"##1272"[2]
                                                        var"##1273" isa AbstractArray
                                                    end && (length(var"##1273") === 2 && begin
                                                            var"##1274" = var"##1273"[1]
                                                            var"##1275" = var"##1273"[2]
                                                            let rhs = var"##1275", line = var"##1274", lhs = var"##1269"
                                                                is_line_no(line)
                                                            end
                                                        end))))))))
                    rhs = var"##1275"
                    line = var"##1274"
                    lhs = var"##1269"
                    var"##return#1171" = begin
                            leading_tab()
                            inline(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1172#1379")))
                end
                if begin
                            var"##1276" = (var"##cache#1174").value
                            var"##1276" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1276"[1] == :(=) && (begin
                                    var"##1277" = var"##1276"[2]
                                    var"##1277" isa AbstractArray
                                end && (length(var"##1277") === 2 && begin
                                        var"##1278" = var"##1277"[1]
                                        var"##1279" = var"##1277"[2]
                                        true
                                    end)))
                    rhs = var"##1279"
                    lhs = var"##1278"
                    var"##return#1171" = begin
                            leading_tab()
                            inline(lhs)
                            print(" = ")
                            p(rhs)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1172#1379")))
                end
                if begin
                            var"##1280" = (var"##cache#1174").value
                            var"##1280" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1280"[1] == :function && (begin
                                    var"##1281" = var"##1280"[2]
                                    var"##1281" isa AbstractArray
                                end && (length(var"##1281") === 2 && begin
                                        var"##1282" = var"##1281"[1]
                                        var"##1283" = var"##1281"[2]
                                        true
                                    end)))
                    call = var"##1282"
                    body = var"##1283"
                    var"##return#1171" = begin
                            print_function(:function, call, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1172#1379")))
                end
                if begin
                            var"##1284" = (var"##cache#1174").value
                            var"##1284" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1284"[1] == :-> && (begin
                                    var"##1285" = var"##1284"[2]
                                    var"##1285" isa AbstractArray
                                end && (length(var"##1285") === 2 && begin
                                        var"##1286" = var"##1285"[1]
                                        var"##1287" = var"##1285"[2]
                                        true
                                    end)))
                    call = var"##1286"
                    body = var"##1287"
                    var"##return#1171" = begin
                            leading_tab()
                            inline(call)
                            keyword(" -> ")
                            p(body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1172#1379")))
                end
                if begin
                            var"##1288" = (var"##cache#1174").value
                            var"##1288" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1288"[1] == :do && (begin
                                    var"##1289" = var"##1288"[2]
                                    var"##1289" isa AbstractArray
                                end && (length(var"##1289") === 2 && (begin
                                            var"##1290" = var"##1289"[1]
                                            begin
                                                var"##cache#1292" = nothing
                                            end
                                            var"##1291" = var"##1289"[2]
                                            var"##1291" isa Expr
                                        end && (begin
                                                if var"##cache#1292" === nothing
                                                    var"##cache#1292" = Some(((var"##1291").head, (var"##1291").args))
                                                end
                                                var"##1293" = (var"##cache#1292").value
                                                var"##1293" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1293"[1] == :-> && (begin
                                                        var"##1294" = var"##1293"[2]
                                                        var"##1294" isa AbstractArray
                                                    end && (length(var"##1294") === 2 && (begin
                                                                begin
                                                                    var"##cache#1296" = nothing
                                                                end
                                                                var"##1295" = var"##1294"[1]
                                                                var"##1295" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1296" === nothing
                                                                        var"##cache#1296" = Some(((var"##1295").head, (var"##1295").args))
                                                                    end
                                                                    var"##1297" = (var"##cache#1296").value
                                                                    var"##1297" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1297"[1] == :tuple && (begin
                                                                            var"##1298" = var"##1297"[2]
                                                                            var"##1298" isa AbstractArray
                                                                        end && ((ndims(var"##1298") === 1 && length(var"##1298") >= 0) && begin
                                                                                var"##1299" = SubArray(var"##1298", (1:length(var"##1298"),))
                                                                                var"##1300" = var"##1294"[2]
                                                                                true
                                                                            end)))))))))))))
                    call = var"##1290"
                    args = var"##1299"
                    body = var"##1300"
                    var"##return#1171" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1172#1379")))
                end
                if begin
                            var"##1301" = (var"##cache#1174").value
                            var"##1301" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1301"[1] == :macro && (begin
                                    var"##1302" = var"##1301"[2]
                                    var"##1302" isa AbstractArray
                                end && (length(var"##1302") === 2 && begin
                                        var"##1303" = var"##1302"[1]
                                        var"##1304" = var"##1302"[2]
                                        true
                                    end)))
                    call = var"##1303"
                    body = var"##1304"
                    var"##return#1171" = begin
                            print_function(:macro, call, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1172#1379")))
                end
                if begin
                            var"##1305" = (var"##cache#1174").value
                            var"##1305" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1305"[1] == :macrocall && (begin
                                    var"##1306" = var"##1305"[2]
                                    var"##1306" isa AbstractArray
                                end && (length(var"##1306") === 4 && (begin
                                            var"##1307" = var"##1306"[1]
                                            var"##1307" == Symbol("@switch")
                                        end && (begin
                                                var"##1308" = var"##1306"[2]
                                                var"##1309" = var"##1306"[3]
                                                begin
                                                    var"##cache#1311" = nothing
                                                end
                                                var"##1310" = var"##1306"[4]
                                                var"##1310" isa Expr
                                            end && (begin
                                                    if var"##cache#1311" === nothing
                                                        var"##cache#1311" = Some(((var"##1310").head, (var"##1310").args))
                                                    end
                                                    var"##1312" = (var"##cache#1311").value
                                                    var"##1312" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1312"[1] == :block && (begin
                                                            var"##1313" = var"##1312"[2]
                                                            var"##1313" isa AbstractArray
                                                        end && ((ndims(var"##1313") === 1 && length(var"##1313") >= 0) && begin
                                                                var"##1314" = SubArray(var"##1313", (1:length(var"##1313"),))
                                                                true
                                                            end)))))))))
                    item = var"##1309"
                    line = var"##1308"
                    stmts = var"##1314"
                    var"##return#1171" = begin
                            print_switch(item, line, stmts)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1172#1379")))
                end
                if begin
                            var"##1315" = (var"##cache#1174").value
                            var"##1315" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1315"[1] == :macrocall && (begin
                                    var"##1316" = var"##1315"[2]
                                    var"##1316" isa AbstractArray
                                end && (length(var"##1316") === 4 && (begin
                                            var"##1317" = var"##1316"[1]
                                            var"##1317" == GlobalRef(Core, Symbol("@doc"))
                                        end && begin
                                            var"##1318" = var"##1316"[2]
                                            var"##1319" = var"##1316"[3]
                                            var"##1320" = var"##1316"[4]
                                            true
                                        end))))
                    line = var"##1318"
                    code = var"##1320"
                    doc = var"##1319"
                    var"##return#1171" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1172#1379")))
                end
                if begin
                            var"##1321" = (var"##cache#1174").value
                            var"##1321" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1321"[1] == :macrocall && (begin
                                    var"##1322" = var"##1321"[2]
                                    var"##1322" isa AbstractArray
                                end && ((ndims(var"##1322") === 1 && length(var"##1322") >= 2) && begin
                                        var"##1323" = var"##1322"[1]
                                        var"##1324" = var"##1322"[2]
                                        var"##1325" = SubArray(var"##1322", (3:length(var"##1322"),))
                                        true
                                    end)))
                    line = var"##1324"
                    name = var"##1323"
                    args = var"##1325"
                    var"##return#1171" = begin
                            print_macrocall(name, line, args)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1172#1379")))
                end
                if begin
                            var"##1326" = (var"##cache#1174").value
                            var"##1326" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1326"[1] == :struct && (begin
                                    var"##1327" = var"##1326"[2]
                                    var"##1327" isa AbstractArray
                                end && (length(var"##1327") === 3 && begin
                                        var"##1328" = var"##1327"[1]
                                        var"##1329" = var"##1327"[2]
                                        var"##1330" = var"##1327"[3]
                                        true
                                    end)))
                    ismutable = var"##1328"
                    body = var"##1330"
                    head = var"##1329"
                    var"##return#1171" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1172#1379")))
                end
                if begin
                            var"##1331" = (var"##cache#1174").value
                            var"##1331" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1331"[1] == :try && (begin
                                    var"##1332" = var"##1331"[2]
                                    var"##1332" isa AbstractArray
                                end && (length(var"##1332") === 3 && begin
                                        var"##1333" = var"##1332"[1]
                                        var"##1334" = var"##1332"[2]
                                        var"##1335" = var"##1332"[3]
                                        true
                                    end)))
                    catch_vars = var"##1334"
                    catch_body = var"##1335"
                    try_body = var"##1333"
                    var"##return#1171" = begin
                            print_try(try_body)
                            print_catch(catch_body, catch_vars)
                            println()
                            tab()
                            keyword("end")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1172#1379")))
                end
                if begin
                            var"##1336" = (var"##cache#1174").value
                            var"##1336" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1336"[1] == :try && (begin
                                    var"##1337" = var"##1336"[2]
                                    var"##1337" isa AbstractArray
                                end && (length(var"##1337") === 4 && begin
                                        var"##1338" = var"##1337"[1]
                                        var"##1339" = var"##1337"[2]
                                        var"##1340" = var"##1337"[3]
                                        var"##1341" = var"##1337"[4]
                                        true
                                    end)))
                    catch_vars = var"##1339"
                    catch_body = var"##1340"
                    try_body = var"##1338"
                    finally_body = var"##1341"
                    var"##return#1171" = begin
                            print_try(try_body)
                            print_catch(catch_body, catch_vars)
                            print_finally(finally_body)
                            println()
                            tab()
                            keyword("end")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1172#1379")))
                end
                if begin
                            var"##1342" = (var"##cache#1174").value
                            var"##1342" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1342"[1] == :try && (begin
                                    var"##1343" = var"##1342"[2]
                                    var"##1343" isa AbstractArray
                                end && (length(var"##1343") === 5 && begin
                                        var"##1344" = var"##1343"[1]
                                        var"##1345" = var"##1343"[2]
                                        var"##1346" = var"##1343"[3]
                                        var"##1347" = var"##1343"[4]
                                        var"##1348" = var"##1343"[5]
                                        true
                                    end)))
                    catch_vars = var"##1345"
                    catch_body = var"##1346"
                    try_body = var"##1344"
                    finally_body = var"##1347"
                    else_body = var"##1348"
                    var"##return#1171" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1172#1379")))
                end
                if begin
                            var"##1349" = (var"##cache#1174").value
                            var"##1349" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1349"[1] == :module && (begin
                                    var"##1350" = var"##1349"[2]
                                    var"##1350" isa AbstractArray
                                end && (length(var"##1350") === 3 && begin
                                        var"##1351" = var"##1350"[1]
                                        var"##1352" = var"##1350"[2]
                                        var"##1353" = var"##1350"[3]
                                        true
                                    end)))
                    name = var"##1352"
                    body = var"##1353"
                    notbare = var"##1351"
                    var"##return#1171" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1172#1379")))
                end
                if begin
                            var"##1354" = (var"##cache#1174").value
                            var"##1354" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1354"[1] == :const && (begin
                                    var"##1355" = var"##1354"[2]
                                    var"##1355" isa AbstractArray
                                end && (length(var"##1355") === 1 && begin
                                        var"##1356" = var"##1355"[1]
                                        true
                                    end)))
                    code = var"##1356"
                    var"##return#1171" = begin
                            leading_tab()
                            keyword("const ")
                            p(code)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1172#1379")))
                end
                if begin
                            var"##1357" = (var"##cache#1174").value
                            var"##1357" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1357"[1] == :return && (begin
                                    var"##1358" = var"##1357"[2]
                                    var"##1358" isa AbstractArray
                                end && (length(var"##1358") === 1 && (begin
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
                                            end && (var"##1361"[1] == :tuple && (begin
                                                        var"##1362" = var"##1361"[2]
                                                        var"##1362" isa AbstractArray
                                                    end && ((ndims(var"##1362") === 1 && length(var"##1362") >= 1) && (begin
                                                                begin
                                                                    var"##cache#1364" = nothing
                                                                end
                                                                var"##1363" = var"##1362"[1]
                                                                var"##1363" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1364" === nothing
                                                                        var"##cache#1364" = Some(((var"##1363").head, (var"##1363").args))
                                                                    end
                                                                    var"##1365" = (var"##cache#1364").value
                                                                    var"##1365" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1365"[1] == :parameters && (begin
                                                                            var"##1366" = var"##1365"[2]
                                                                            var"##1366" isa AbstractArray
                                                                        end && (ndims(var"##1366") === 1 && length(var"##1366") >= 0)))))))))))))
                    var"##return#1171" = begin
                            inline(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1172#1379")))
                end
                if begin
                            var"##1367" = (var"##cache#1174").value
                            var"##1367" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1367"[1] == :return && (begin
                                    var"##1368" = var"##1367"[2]
                                    var"##1368" isa AbstractArray
                                end && (length(var"##1368") === 1 && (begin
                                            begin
                                                var"##cache#1370" = nothing
                                            end
                                            var"##1369" = var"##1368"[1]
                                            var"##1369" isa Expr
                                        end && (begin
                                                if var"##cache#1370" === nothing
                                                    var"##cache#1370" = Some(((var"##1369").head, (var"##1369").args))
                                                end
                                                var"##1371" = (var"##cache#1370").value
                                                var"##1371" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1371"[1] == :tuple && (begin
                                                        var"##1372" = var"##1371"[2]
                                                        var"##1372" isa AbstractArray
                                                    end && (ndims(var"##1372") === 1 && length(var"##1372") >= 0))))))))
                    var"##return#1171" = begin
                            inline(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1172#1379")))
                end
                if begin
                            var"##1373" = (var"##cache#1174").value
                            var"##1373" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1373"[1] == :return && (begin
                                    var"##1374" = var"##1373"[2]
                                    var"##1374" isa AbstractArray
                                end && (length(var"##1374") === 1 && begin
                                        var"##1375" = var"##1374"[1]
                                        true
                                    end)))
                    code = var"##1375"
                    var"##return#1171" = begin
                            leading_tab()
                            keyword("return ")
                            p(code)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1172#1379")))
                end
                if begin
                            var"##1376" = (var"##cache#1174").value
                            var"##1376" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1376"[1] == :toplevel && (begin
                                    var"##1377" = var"##1376"[2]
                                    var"##1377" isa AbstractArray
                                end && (length(var"##1377") === 1 && begin
                                        var"##1378" = var"##1377"[1]
                                        true
                                    end)))
                    code = var"##1378"
                    var"##return#1171" = begin
                            leading_tab()
                            printstyled("#= meta: toplevel =#", color = c.comment)
                            println()
                            p(code)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1172#1379")))
                end
            end
            if var"##1173" isa String
                begin
                    var"##return#1171" = begin
                            leading_tab()
                            occursin('\n', ex) || return inline(ex)
                            printstyled("\"\"\"\n", color = c.string)
                            tab()
                            print_multi_lines(ex)
                            printstyled("\"\"\"", color = c.string)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1172#1379")))
                end
            end
            begin
                var"##return#1171" = begin
                        inline(ex)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#1172#1379")))
            end
            error("matching non-exhaustive, at #= none:246 =#")
            $(Expr(:symboliclabel, Symbol("####final#1172#1379")))
            var"##return#1171"
        end
        return nothing
    end
    #= none:468 =# Core.@doc "    print_expr([io::IO], ex; kw...)\n\nPrint a given expression. `ex` can be a `Expr` or a syntax type `JLExpr`.\n" print_expr(io::IO, ex; kw...) = begin
                (Printer(io; kw...))(ex)
            end
    print_expr(ex; kw...) = begin
            print_expr(stdout, ex; kw...)
        end
