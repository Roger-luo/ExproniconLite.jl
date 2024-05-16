
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
                    var"##cache#1111" = nothing
                end
                var"##return#1108" = nothing
                var"##1110" = otherwise
                if var"##1110" isa Expr && (begin
                                if var"##cache#1111" === nothing
                                    var"##cache#1111" = Some(((var"##1110").head, (var"##1110").args))
                                end
                                var"##1112" = (var"##cache#1111").value
                                var"##1112" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1112"[1] == :block && (begin
                                        var"##1113" = var"##1112"[2]
                                        var"##1113" isa AbstractArray
                                    end && ((ndims(var"##1113") === 1 && length(var"##1113") >= 0) && begin
                                            var"##1114" = SubArray(var"##1113", (1:length(var"##1113"),))
                                            true
                                        end))))
                    var"##return#1108" = let stmts = var"##1114"
                            indent() do 
                                print_stmts(stmts)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1109#1115")))
                end
                begin
                    var"##return#1108" = let
                            indent() do 
                                tab()
                                no_first_line_indent() do 
                                    p(otherwise)
                                end
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1109#1115")))
                end
                error("matching non-exhaustive, at #= none:98 =#")
                $(Expr(:symboliclabel, Symbol("####final#1109#1115")))
                var"##return#1108"
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
                            var"##cache#1119" = nothing
                        end
                        var"##return#1116" = nothing
                        var"##1118" = stmt
                        if var"##1118" isa Expr && (begin
                                        if var"##cache#1119" === nothing
                                            var"##cache#1119" = Some(((var"##1118").head, (var"##1118").args))
                                        end
                                        var"##1120" = (var"##cache#1119").value
                                        var"##1120" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##1120"[1] == :macrocall && (begin
                                                var"##1121" = var"##1120"[2]
                                                var"##1121" isa AbstractArray
                                            end && ((ndims(var"##1121") === 1 && length(var"##1121") >= 1) && begin
                                                    var"##1122" = var"##1121"[1]
                                                    var"##1122" == Symbol("@case")
                                                end))))
                            var"##return#1116" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1117#1123")))
                        end
                        begin
                            var"##return#1116" = let
                                    false
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1117#1123")))
                        end
                        error("matching non-exhaustive, at #= none:181 =#")
                        $(Expr(:symboliclabel, Symbol("####final#1117#1123")))
                        var"##return#1116"
                    end
                end || return print_macrocall("@switch", line, (item, Expr(:block, stmts...)))
            is_case(stmt) = begin
                    let
                        begin
                            var"##cache#1127" = nothing
                        end
                        var"##return#1124" = nothing
                        var"##1126" = stmt
                        if var"##1126" isa Expr && (begin
                                        if var"##cache#1127" === nothing
                                            var"##cache#1127" = Some(((var"##1126").head, (var"##1126").args))
                                        end
                                        var"##1128" = (var"##cache#1127").value
                                        var"##1128" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##1128"[1] == :macrocall && (begin
                                                var"##1129" = var"##1128"[2]
                                                var"##1129" isa AbstractArray
                                            end && ((ndims(var"##1129") === 1 && length(var"##1129") >= 1) && begin
                                                    var"##1130" = var"##1129"[1]
                                                    var"##1130" == Symbol("@case")
                                                end))))
                            var"##return#1124" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1125#1131")))
                        end
                        begin
                            var"##return#1124" = let
                                    false
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1125#1131")))
                        end
                        error("matching non-exhaustive, at #= none:187 =#")
                        $(Expr(:symboliclabel, Symbol("####final#1125#1131")))
                        var"##return#1124"
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
                            var"##cache#1135" = nothing
                        end
                        var"##return#1132" = nothing
                        var"##1134" = stmt
                        if var"##1134" isa Expr && (begin
                                        if var"##cache#1135" === nothing
                                            var"##cache#1135" = Some(((var"##1134").head, (var"##1134").args))
                                        end
                                        var"##1136" = (var"##cache#1135").value
                                        var"##1136" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##1136"[1] == :macrocall && (begin
                                                var"##1137" = var"##1136"[2]
                                                var"##1137" isa AbstractArray
                                            end && (length(var"##1137") === 3 && (begin
                                                        var"##1138" = var"##1137"[1]
                                                        var"##1138" == Symbol("@case")
                                                    end && begin
                                                        var"##1139" = var"##1137"[2]
                                                        var"##1140" = var"##1137"[3]
                                                        true
                                                    end)))))
                            var"##return#1132" = let pattern = var"##1140", line = var"##1139"
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
                            $(Expr(:symbolicgoto, Symbol("####final#1133#1141")))
                        end
                        begin
                            var"##return#1132" = let
                                    p(stmt)
                                    println()
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1133#1141")))
                        end
                        error("matching non-exhaustive, at #= none:197 =#")
                        $(Expr(:symboliclabel, Symbol("####final#1133#1141")))
                        var"##return#1132"
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
                var"##cache#1145" = nothing
            end
            var"##1144" = ex
            if var"##1144" isa Expr
                if begin
                            if var"##cache#1145" === nothing
                                var"##cache#1145" = Some(((var"##1144").head, (var"##1144").args))
                            end
                            var"##1146" = (var"##cache#1145").value
                            var"##1146" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1146"[1] == :string && (begin
                                    var"##1147" = var"##1146"[2]
                                    var"##1147" isa AbstractArray
                                end && ((ndims(var"##1147") === 1 && length(var"##1147") >= 0) && begin
                                        var"##1148" = SubArray(var"##1147", (1:length(var"##1147"),))
                                        true
                                    end)))
                    args = var"##1148"
                    var"##return#1142" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1143#1350")))
                end
                if begin
                            var"##1149" = (var"##cache#1145").value
                            var"##1149" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1149"[1] == :block && (begin
                                    var"##1150" = var"##1149"[2]
                                    var"##1150" isa AbstractArray
                                end && ((ndims(var"##1150") === 1 && length(var"##1150") >= 0) && begin
                                        var"##1151" = SubArray(var"##1150", (1:length(var"##1150"),))
                                        true
                                    end)))
                    stmts = var"##1151"
                    var"##return#1142" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1143#1350")))
                end
                if begin
                            var"##1152" = (var"##cache#1145").value
                            var"##1152" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1152"[1] == :quote && (begin
                                    var"##1153" = var"##1152"[2]
                                    var"##1153" isa AbstractArray
                                end && (length(var"##1153") === 1 && (begin
                                            begin
                                                var"##cache#1155" = nothing
                                            end
                                            var"##1154" = var"##1153"[1]
                                            var"##1154" isa Expr
                                        end && (begin
                                                if var"##cache#1155" === nothing
                                                    var"##cache#1155" = Some(((var"##1154").head, (var"##1154").args))
                                                end
                                                var"##1156" = (var"##cache#1155").value
                                                var"##1156" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1156"[1] == :block && (begin
                                                        var"##1157" = var"##1156"[2]
                                                        var"##1157" isa AbstractArray
                                                    end && ((ndims(var"##1157") === 1 && length(var"##1157") >= 0) && begin
                                                            var"##1158" = SubArray(var"##1157", (1:length(var"##1157"),))
                                                            let stmts = var"##1158"
                                                                is_root()
                                                            end
                                                        end))))))))
                    stmts = var"##1158"
                    var"##return#1142" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1143#1350")))
                end
                if begin
                            var"##1159" = (var"##cache#1145").value
                            var"##1159" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1159"[1] == :quote && (begin
                                    var"##1160" = var"##1159"[2]
                                    var"##1160" isa AbstractArray
                                end && (length(var"##1160") === 1 && (begin
                                            begin
                                                var"##cache#1162" = nothing
                                            end
                                            var"##1161" = var"##1160"[1]
                                            var"##1161" isa Expr
                                        end && (begin
                                                if var"##cache#1162" === nothing
                                                    var"##cache#1162" = Some(((var"##1161").head, (var"##1161").args))
                                                end
                                                var"##1163" = (var"##cache#1162").value
                                                var"##1163" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1163"[1] == :block && (begin
                                                        var"##1164" = var"##1163"[2]
                                                        var"##1164" isa AbstractArray
                                                    end && ((ndims(var"##1164") === 1 && length(var"##1164") >= 0) && begin
                                                            var"##1165" = SubArray(var"##1164", (1:length(var"##1164"),))
                                                            true
                                                        end))))))))
                    stmts = var"##1165"
                    var"##return#1142" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1143#1350")))
                end
                if begin
                            var"##1166" = (var"##cache#1145").value
                            var"##1166" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1166"[1] == :quote && (begin
                                    var"##1167" = var"##1166"[2]
                                    var"##1167" isa AbstractArray
                                end && (length(var"##1167") === 1 && begin
                                        var"##1168" = var"##1167"[1]
                                        true
                                    end)))
                    code = var"##1168"
                    var"##return#1142" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1143#1350")))
                end
                if begin
                            var"##1169" = (var"##cache#1145").value
                            var"##1169" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1169"[1] == :let && (begin
                                    var"##1170" = var"##1169"[2]
                                    var"##1170" isa AbstractArray
                                end && (length(var"##1170") === 2 && (begin
                                            begin
                                                var"##cache#1172" = nothing
                                            end
                                            var"##1171" = var"##1170"[1]
                                            var"##1171" isa Expr
                                        end && (begin
                                                if var"##cache#1172" === nothing
                                                    var"##cache#1172" = Some(((var"##1171").head, (var"##1171").args))
                                                end
                                                var"##1173" = (var"##cache#1172").value
                                                var"##1173" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1173"[1] == :block && (begin
                                                        var"##1174" = var"##1173"[2]
                                                        var"##1174" isa AbstractArray
                                                    end && ((ndims(var"##1174") === 1 && length(var"##1174") >= 0) && (begin
                                                                var"##1175" = SubArray(var"##1174", (1:length(var"##1174"),))
                                                                begin
                                                                    var"##cache#1177" = nothing
                                                                end
                                                                var"##1176" = var"##1170"[2]
                                                                var"##1176" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1177" === nothing
                                                                        var"##cache#1177" = Some(((var"##1176").head, (var"##1176").args))
                                                                    end
                                                                    var"##1178" = (var"##cache#1177").value
                                                                    var"##1178" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1178"[1] == :block && (begin
                                                                            var"##1179" = var"##1178"[2]
                                                                            var"##1179" isa AbstractArray
                                                                        end && ((ndims(var"##1179") === 1 && length(var"##1179") >= 0) && begin
                                                                                var"##1180" = SubArray(var"##1179", (1:length(var"##1179"),))
                                                                                true
                                                                            end)))))))))))))
                    args = var"##1175"
                    stmts = var"##1180"
                    var"##return#1142" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1143#1350")))
                end
                if begin
                            var"##1181" = (var"##cache#1145").value
                            var"##1181" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1181"[1] == :if && (begin
                                    var"##1182" = var"##1181"[2]
                                    var"##1182" isa AbstractArray
                                end && (length(var"##1182") === 2 && begin
                                        var"##1183" = var"##1182"[1]
                                        var"##1184" = var"##1182"[2]
                                        true
                                    end)))
                    cond = var"##1183"
                    body = var"##1184"
                    var"##return#1142" = begin
                            print_if(cond, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1143#1350")))
                end
                if begin
                            var"##1185" = (var"##cache#1145").value
                            var"##1185" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1185"[1] == :if && (begin
                                    var"##1186" = var"##1185"[2]
                                    var"##1186" isa AbstractArray
                                end && (length(var"##1186") === 3 && begin
                                        var"##1187" = var"##1186"[1]
                                        var"##1188" = var"##1186"[2]
                                        var"##1189" = var"##1186"[3]
                                        true
                                    end)))
                    cond = var"##1187"
                    body = var"##1188"
                    otherwise = var"##1189"
                    var"##return#1142" = begin
                            print_if(cond, body, otherwise)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1143#1350")))
                end
                if begin
                            var"##1190" = (var"##cache#1145").value
                            var"##1190" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1190"[1] == :elseif && (begin
                                    var"##1191" = var"##1190"[2]
                                    var"##1191" isa AbstractArray
                                end && (length(var"##1191") === 2 && (begin
                                            begin
                                                var"##cache#1193" = nothing
                                            end
                                            var"##1192" = var"##1191"[1]
                                            var"##1192" isa Expr
                                        end && (begin
                                                if var"##cache#1193" === nothing
                                                    var"##cache#1193" = Some(((var"##1192").head, (var"##1192").args))
                                                end
                                                var"##1194" = (var"##cache#1193").value
                                                var"##1194" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1194"[1] == :block && (begin
                                                        var"##1195" = var"##1194"[2]
                                                        var"##1195" isa AbstractArray
                                                    end && (length(var"##1195") === 2 && begin
                                                            var"##1196" = var"##1195"[1]
                                                            var"##1197" = var"##1195"[2]
                                                            var"##1198" = var"##1191"[2]
                                                            true
                                                        end))))))))
                    line = var"##1196"
                    cond = var"##1197"
                    body = var"##1198"
                    var"##return#1142" = begin
                            print_elseif(cond, body, line)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1143#1350")))
                end
                if begin
                            var"##1199" = (var"##cache#1145").value
                            var"##1199" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1199"[1] == :elseif && (begin
                                    var"##1200" = var"##1199"[2]
                                    var"##1200" isa AbstractArray
                                end && (length(var"##1200") === 2 && begin
                                        var"##1201" = var"##1200"[1]
                                        var"##1202" = var"##1200"[2]
                                        true
                                    end)))
                    cond = var"##1201"
                    body = var"##1202"
                    var"##return#1142" = begin
                            print_elseif(cond, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1143#1350")))
                end
                if begin
                            var"##1203" = (var"##cache#1145").value
                            var"##1203" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1203"[1] == :elseif && (begin
                                    var"##1204" = var"##1203"[2]
                                    var"##1204" isa AbstractArray
                                end && (length(var"##1204") === 3 && (begin
                                            begin
                                                var"##cache#1206" = nothing
                                            end
                                            var"##1205" = var"##1204"[1]
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
                                                    end && (length(var"##1208") === 2 && begin
                                                            var"##1209" = var"##1208"[1]
                                                            var"##1210" = var"##1208"[2]
                                                            var"##1211" = var"##1204"[2]
                                                            var"##1212" = var"##1204"[3]
                                                            true
                                                        end))))))))
                    line = var"##1209"
                    cond = var"##1210"
                    body = var"##1211"
                    otherwise = var"##1212"
                    var"##return#1142" = begin
                            print_elseif(cond, body, line, otherwise)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1143#1350")))
                end
                if begin
                            var"##1213" = (var"##cache#1145").value
                            var"##1213" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1213"[1] == :elseif && (begin
                                    var"##1214" = var"##1213"[2]
                                    var"##1214" isa AbstractArray
                                end && (length(var"##1214") === 3 && begin
                                        var"##1215" = var"##1214"[1]
                                        var"##1216" = var"##1214"[2]
                                        var"##1217" = var"##1214"[3]
                                        true
                                    end)))
                    cond = var"##1215"
                    body = var"##1216"
                    otherwise = var"##1217"
                    var"##return#1142" = begin
                            print_elseif(cond, body, nothing, otherwise)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1143#1350")))
                end
                if begin
                            var"##1218" = (var"##cache#1145").value
                            var"##1218" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1218"[1] == :for && (begin
                                    var"##1219" = var"##1218"[2]
                                    var"##1219" isa AbstractArray
                                end && (length(var"##1219") === 2 && begin
                                        var"##1220" = var"##1219"[1]
                                        var"##1221" = var"##1219"[2]
                                        true
                                    end)))
                    body = var"##1221"
                    iteration = var"##1220"
                    var"##return#1142" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1143#1350")))
                end
                if begin
                            var"##1222" = (var"##cache#1145").value
                            var"##1222" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1222"[1] == :while && (begin
                                    var"##1223" = var"##1222"[2]
                                    var"##1223" isa AbstractArray
                                end && (length(var"##1223") === 2 && begin
                                        var"##1224" = var"##1223"[1]
                                        var"##1225" = var"##1223"[2]
                                        true
                                    end)))
                    cond = var"##1224"
                    body = var"##1225"
                    var"##return#1142" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1143#1350")))
                end
                if begin
                            var"##1226" = (var"##cache#1145").value
                            var"##1226" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1226"[1] == :(=) && (begin
                                    var"##1227" = var"##1226"[2]
                                    var"##1227" isa AbstractArray
                                end && (length(var"##1227") === 2 && (begin
                                            var"##1228" = var"##1227"[1]
                                            begin
                                                var"##cache#1230" = nothing
                                            end
                                            var"##1229" = var"##1227"[2]
                                            var"##1229" isa Expr
                                        end && (begin
                                                if var"##cache#1230" === nothing
                                                    var"##cache#1230" = Some(((var"##1229").head, (var"##1229").args))
                                                end
                                                var"##1231" = (var"##cache#1230").value
                                                var"##1231" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1231"[1] == :block && (begin
                                                        var"##1232" = var"##1231"[2]
                                                        var"##1232" isa AbstractArray
                                                    end && (length(var"##1232") === 2 && (begin
                                                                var"##1233" = var"##1232"[1]
                                                                begin
                                                                    var"##cache#1235" = nothing
                                                                end
                                                                var"##1234" = var"##1232"[2]
                                                                var"##1234" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1235" === nothing
                                                                        var"##cache#1235" = Some(((var"##1234").head, (var"##1234").args))
                                                                    end
                                                                    var"##1236" = (var"##cache#1235").value
                                                                    var"##1236" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1236"[1] == :if && (begin
                                                                            var"##1237" = var"##1236"[2]
                                                                            var"##1237" isa AbstractArray
                                                                        end && ((ndims(var"##1237") === 1 && length(var"##1237") >= 0) && let line = var"##1233", lhs = var"##1228"
                                                                                is_line_no(line)
                                                                            end)))))))))))))
                    line = var"##1233"
                    lhs = var"##1228"
                    var"##return#1142" = begin
                            leading_tab()
                            inline(lhs)
                            keyword(" = ")
                            inline(line)
                            p(ex.args[2])
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1143#1350")))
                end
                if begin
                            var"##1238" = (var"##cache#1145").value
                            var"##1238" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1238"[1] == :(=) && (begin
                                    var"##1239" = var"##1238"[2]
                                    var"##1239" isa AbstractArray
                                end && (length(var"##1239") === 2 && (begin
                                            var"##1240" = var"##1239"[1]
                                            begin
                                                var"##cache#1242" = nothing
                                            end
                                            var"##1241" = var"##1239"[2]
                                            var"##1241" isa Expr
                                        end && (begin
                                                if var"##cache#1242" === nothing
                                                    var"##cache#1242" = Some(((var"##1241").head, (var"##1241").args))
                                                end
                                                var"##1243" = (var"##cache#1242").value
                                                var"##1243" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1243"[1] == :block && (begin
                                                        var"##1244" = var"##1243"[2]
                                                        var"##1244" isa AbstractArray
                                                    end && (length(var"##1244") === 2 && begin
                                                            var"##1245" = var"##1244"[1]
                                                            var"##1246" = var"##1244"[2]
                                                            let rhs = var"##1246", line = var"##1245", lhs = var"##1240"
                                                                is_line_no(line)
                                                            end
                                                        end))))))))
                    rhs = var"##1246"
                    line = var"##1245"
                    lhs = var"##1240"
                    var"##return#1142" = begin
                            leading_tab()
                            inline(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1143#1350")))
                end
                if begin
                            var"##1247" = (var"##cache#1145").value
                            var"##1247" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1247"[1] == :(=) && (begin
                                    var"##1248" = var"##1247"[2]
                                    var"##1248" isa AbstractArray
                                end && (length(var"##1248") === 2 && begin
                                        var"##1249" = var"##1248"[1]
                                        var"##1250" = var"##1248"[2]
                                        true
                                    end)))
                    rhs = var"##1250"
                    lhs = var"##1249"
                    var"##return#1142" = begin
                            leading_tab()
                            inline(lhs)
                            print(" = ")
                            p(rhs)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1143#1350")))
                end
                if begin
                            var"##1251" = (var"##cache#1145").value
                            var"##1251" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1251"[1] == :function && (begin
                                    var"##1252" = var"##1251"[2]
                                    var"##1252" isa AbstractArray
                                end && (length(var"##1252") === 2 && begin
                                        var"##1253" = var"##1252"[1]
                                        var"##1254" = var"##1252"[2]
                                        true
                                    end)))
                    call = var"##1253"
                    body = var"##1254"
                    var"##return#1142" = begin
                            print_function(:function, call, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1143#1350")))
                end
                if begin
                            var"##1255" = (var"##cache#1145").value
                            var"##1255" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1255"[1] == :-> && (begin
                                    var"##1256" = var"##1255"[2]
                                    var"##1256" isa AbstractArray
                                end && (length(var"##1256") === 2 && begin
                                        var"##1257" = var"##1256"[1]
                                        var"##1258" = var"##1256"[2]
                                        true
                                    end)))
                    call = var"##1257"
                    body = var"##1258"
                    var"##return#1142" = begin
                            leading_tab()
                            inline(call)
                            keyword(" -> ")
                            p(body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1143#1350")))
                end
                if begin
                            var"##1259" = (var"##cache#1145").value
                            var"##1259" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1259"[1] == :do && (begin
                                    var"##1260" = var"##1259"[2]
                                    var"##1260" isa AbstractArray
                                end && (length(var"##1260") === 2 && (begin
                                            var"##1261" = var"##1260"[1]
                                            begin
                                                var"##cache#1263" = nothing
                                            end
                                            var"##1262" = var"##1260"[2]
                                            var"##1262" isa Expr
                                        end && (begin
                                                if var"##cache#1263" === nothing
                                                    var"##cache#1263" = Some(((var"##1262").head, (var"##1262").args))
                                                end
                                                var"##1264" = (var"##cache#1263").value
                                                var"##1264" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1264"[1] == :-> && (begin
                                                        var"##1265" = var"##1264"[2]
                                                        var"##1265" isa AbstractArray
                                                    end && (length(var"##1265") === 2 && (begin
                                                                begin
                                                                    var"##cache#1267" = nothing
                                                                end
                                                                var"##1266" = var"##1265"[1]
                                                                var"##1266" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1267" === nothing
                                                                        var"##cache#1267" = Some(((var"##1266").head, (var"##1266").args))
                                                                    end
                                                                    var"##1268" = (var"##cache#1267").value
                                                                    var"##1268" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1268"[1] == :tuple && (begin
                                                                            var"##1269" = var"##1268"[2]
                                                                            var"##1269" isa AbstractArray
                                                                        end && ((ndims(var"##1269") === 1 && length(var"##1269") >= 0) && begin
                                                                                var"##1270" = SubArray(var"##1269", (1:length(var"##1269"),))
                                                                                var"##1271" = var"##1265"[2]
                                                                                true
                                                                            end)))))))))))))
                    call = var"##1261"
                    args = var"##1270"
                    body = var"##1271"
                    var"##return#1142" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1143#1350")))
                end
                if begin
                            var"##1272" = (var"##cache#1145").value
                            var"##1272" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1272"[1] == :macro && (begin
                                    var"##1273" = var"##1272"[2]
                                    var"##1273" isa AbstractArray
                                end && (length(var"##1273") === 2 && begin
                                        var"##1274" = var"##1273"[1]
                                        var"##1275" = var"##1273"[2]
                                        true
                                    end)))
                    call = var"##1274"
                    body = var"##1275"
                    var"##return#1142" = begin
                            print_function(:macro, call, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1143#1350")))
                end
                if begin
                            var"##1276" = (var"##cache#1145").value
                            var"##1276" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1276"[1] == :macrocall && (begin
                                    var"##1277" = var"##1276"[2]
                                    var"##1277" isa AbstractArray
                                end && (length(var"##1277") === 4 && (begin
                                            var"##1278" = var"##1277"[1]
                                            var"##1278" == Symbol("@switch")
                                        end && (begin
                                                var"##1279" = var"##1277"[2]
                                                var"##1280" = var"##1277"[3]
                                                begin
                                                    var"##cache#1282" = nothing
                                                end
                                                var"##1281" = var"##1277"[4]
                                                var"##1281" isa Expr
                                            end && (begin
                                                    if var"##cache#1282" === nothing
                                                        var"##cache#1282" = Some(((var"##1281").head, (var"##1281").args))
                                                    end
                                                    var"##1283" = (var"##cache#1282").value
                                                    var"##1283" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1283"[1] == :block && (begin
                                                            var"##1284" = var"##1283"[2]
                                                            var"##1284" isa AbstractArray
                                                        end && ((ndims(var"##1284") === 1 && length(var"##1284") >= 0) && begin
                                                                var"##1285" = SubArray(var"##1284", (1:length(var"##1284"),))
                                                                true
                                                            end)))))))))
                    item = var"##1280"
                    line = var"##1279"
                    stmts = var"##1285"
                    var"##return#1142" = begin
                            print_switch(item, line, stmts)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1143#1350")))
                end
                if begin
                            var"##1286" = (var"##cache#1145").value
                            var"##1286" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1286"[1] == :macrocall && (begin
                                    var"##1287" = var"##1286"[2]
                                    var"##1287" isa AbstractArray
                                end && (length(var"##1287") === 4 && (begin
                                            var"##1288" = var"##1287"[1]
                                            var"##1288" == GlobalRef(Core, Symbol("@doc"))
                                        end && begin
                                            var"##1289" = var"##1287"[2]
                                            var"##1290" = var"##1287"[3]
                                            var"##1291" = var"##1287"[4]
                                            true
                                        end))))
                    line = var"##1289"
                    code = var"##1291"
                    doc = var"##1290"
                    var"##return#1142" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1143#1350")))
                end
                if begin
                            var"##1292" = (var"##cache#1145").value
                            var"##1292" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1292"[1] == :macrocall && (begin
                                    var"##1293" = var"##1292"[2]
                                    var"##1293" isa AbstractArray
                                end && ((ndims(var"##1293") === 1 && length(var"##1293") >= 2) && begin
                                        var"##1294" = var"##1293"[1]
                                        var"##1295" = var"##1293"[2]
                                        var"##1296" = SubArray(var"##1293", (3:length(var"##1293"),))
                                        true
                                    end)))
                    line = var"##1295"
                    name = var"##1294"
                    args = var"##1296"
                    var"##return#1142" = begin
                            print_macrocall(name, line, args)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1143#1350")))
                end
                if begin
                            var"##1297" = (var"##cache#1145").value
                            var"##1297" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1297"[1] == :struct && (begin
                                    var"##1298" = var"##1297"[2]
                                    var"##1298" isa AbstractArray
                                end && (length(var"##1298") === 3 && begin
                                        var"##1299" = var"##1298"[1]
                                        var"##1300" = var"##1298"[2]
                                        var"##1301" = var"##1298"[3]
                                        true
                                    end)))
                    ismutable = var"##1299"
                    body = var"##1301"
                    head = var"##1300"
                    var"##return#1142" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1143#1350")))
                end
                if begin
                            var"##1302" = (var"##cache#1145").value
                            var"##1302" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1302"[1] == :try && (begin
                                    var"##1303" = var"##1302"[2]
                                    var"##1303" isa AbstractArray
                                end && (length(var"##1303") === 3 && begin
                                        var"##1304" = var"##1303"[1]
                                        var"##1305" = var"##1303"[2]
                                        var"##1306" = var"##1303"[3]
                                        true
                                    end)))
                    catch_vars = var"##1305"
                    catch_body = var"##1306"
                    try_body = var"##1304"
                    var"##return#1142" = begin
                            print_try(try_body)
                            print_catch(catch_body, catch_vars)
                            println()
                            tab()
                            keyword("end")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1143#1350")))
                end
                if begin
                            var"##1307" = (var"##cache#1145").value
                            var"##1307" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1307"[1] == :try && (begin
                                    var"##1308" = var"##1307"[2]
                                    var"##1308" isa AbstractArray
                                end && (length(var"##1308") === 4 && begin
                                        var"##1309" = var"##1308"[1]
                                        var"##1310" = var"##1308"[2]
                                        var"##1311" = var"##1308"[3]
                                        var"##1312" = var"##1308"[4]
                                        true
                                    end)))
                    catch_vars = var"##1310"
                    catch_body = var"##1311"
                    try_body = var"##1309"
                    finally_body = var"##1312"
                    var"##return#1142" = begin
                            print_try(try_body)
                            print_catch(catch_body, catch_vars)
                            print_finally(finally_body)
                            println()
                            tab()
                            keyword("end")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1143#1350")))
                end
                if begin
                            var"##1313" = (var"##cache#1145").value
                            var"##1313" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1313"[1] == :try && (begin
                                    var"##1314" = var"##1313"[2]
                                    var"##1314" isa AbstractArray
                                end && (length(var"##1314") === 5 && begin
                                        var"##1315" = var"##1314"[1]
                                        var"##1316" = var"##1314"[2]
                                        var"##1317" = var"##1314"[3]
                                        var"##1318" = var"##1314"[4]
                                        var"##1319" = var"##1314"[5]
                                        true
                                    end)))
                    catch_vars = var"##1316"
                    catch_body = var"##1317"
                    try_body = var"##1315"
                    finally_body = var"##1318"
                    else_body = var"##1319"
                    var"##return#1142" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1143#1350")))
                end
                if begin
                            var"##1320" = (var"##cache#1145").value
                            var"##1320" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1320"[1] == :module && (begin
                                    var"##1321" = var"##1320"[2]
                                    var"##1321" isa AbstractArray
                                end && (length(var"##1321") === 3 && begin
                                        var"##1322" = var"##1321"[1]
                                        var"##1323" = var"##1321"[2]
                                        var"##1324" = var"##1321"[3]
                                        true
                                    end)))
                    name = var"##1323"
                    body = var"##1324"
                    notbare = var"##1322"
                    var"##return#1142" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1143#1350")))
                end
                if begin
                            var"##1325" = (var"##cache#1145").value
                            var"##1325" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1325"[1] == :const && (begin
                                    var"##1326" = var"##1325"[2]
                                    var"##1326" isa AbstractArray
                                end && (length(var"##1326") === 1 && begin
                                        var"##1327" = var"##1326"[1]
                                        true
                                    end)))
                    code = var"##1327"
                    var"##return#1142" = begin
                            leading_tab()
                            keyword("const ")
                            p(code)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1143#1350")))
                end
                if begin
                            var"##1328" = (var"##cache#1145").value
                            var"##1328" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1328"[1] == :return && (begin
                                    var"##1329" = var"##1328"[2]
                                    var"##1329" isa AbstractArray
                                end && (length(var"##1329") === 1 && (begin
                                            begin
                                                var"##cache#1331" = nothing
                                            end
                                            var"##1330" = var"##1329"[1]
                                            var"##1330" isa Expr
                                        end && (begin
                                                if var"##cache#1331" === nothing
                                                    var"##cache#1331" = Some(((var"##1330").head, (var"##1330").args))
                                                end
                                                var"##1332" = (var"##cache#1331").value
                                                var"##1332" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1332"[1] == :tuple && (begin
                                                        var"##1333" = var"##1332"[2]
                                                        var"##1333" isa AbstractArray
                                                    end && ((ndims(var"##1333") === 1 && length(var"##1333") >= 1) && (begin
                                                                begin
                                                                    var"##cache#1335" = nothing
                                                                end
                                                                var"##1334" = var"##1333"[1]
                                                                var"##1334" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1335" === nothing
                                                                        var"##cache#1335" = Some(((var"##1334").head, (var"##1334").args))
                                                                    end
                                                                    var"##1336" = (var"##cache#1335").value
                                                                    var"##1336" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1336"[1] == :parameters && (begin
                                                                            var"##1337" = var"##1336"[2]
                                                                            var"##1337" isa AbstractArray
                                                                        end && (ndims(var"##1337") === 1 && length(var"##1337") >= 0)))))))))))))
                    var"##return#1142" = begin
                            inline(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1143#1350")))
                end
                if begin
                            var"##1338" = (var"##cache#1145").value
                            var"##1338" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1338"[1] == :return && (begin
                                    var"##1339" = var"##1338"[2]
                                    var"##1339" isa AbstractArray
                                end && (length(var"##1339") === 1 && (begin
                                            begin
                                                var"##cache#1341" = nothing
                                            end
                                            var"##1340" = var"##1339"[1]
                                            var"##1340" isa Expr
                                        end && (begin
                                                if var"##cache#1341" === nothing
                                                    var"##cache#1341" = Some(((var"##1340").head, (var"##1340").args))
                                                end
                                                var"##1342" = (var"##cache#1341").value
                                                var"##1342" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1342"[1] == :tuple && (begin
                                                        var"##1343" = var"##1342"[2]
                                                        var"##1343" isa AbstractArray
                                                    end && (ndims(var"##1343") === 1 && length(var"##1343") >= 0))))))))
                    var"##return#1142" = begin
                            inline(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1143#1350")))
                end
                if begin
                            var"##1344" = (var"##cache#1145").value
                            var"##1344" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1344"[1] == :return && (begin
                                    var"##1345" = var"##1344"[2]
                                    var"##1345" isa AbstractArray
                                end && (length(var"##1345") === 1 && begin
                                        var"##1346" = var"##1345"[1]
                                        true
                                    end)))
                    code = var"##1346"
                    var"##return#1142" = begin
                            leading_tab()
                            keyword("return ")
                            p(code)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1143#1350")))
                end
                if begin
                            var"##1347" = (var"##cache#1145").value
                            var"##1347" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1347"[1] == :toplevel && (begin
                                    var"##1348" = var"##1347"[2]
                                    var"##1348" isa AbstractArray
                                end && (length(var"##1348") === 1 && begin
                                        var"##1349" = var"##1348"[1]
                                        true
                                    end)))
                    code = var"##1349"
                    var"##return#1142" = begin
                            leading_tab()
                            printstyled("#= meta: toplevel =#", color = c.comment)
                            println()
                            p(code)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1143#1350")))
                end
            end
            if var"##1144" isa String
                begin
                    var"##return#1142" = begin
                            leading_tab()
                            occursin('\n', ex) || return inline(ex)
                            printstyled("\"\"\"\n", color = c.string)
                            tab()
                            print_multi_lines(ex)
                            printstyled("\"\"\"", color = c.string)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1143#1350")))
                end
            end
            begin
                var"##return#1142" = begin
                        inline(ex)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#1143#1350")))
            end
            error("matching non-exhaustive, at #= none:246 =#")
            $(Expr(:symboliclabel, Symbol("####final#1143#1350")))
            var"##return#1142"
        end
        return nothing
    end
    #= none:468 =# Core.@doc "    print_expr([io::IO], ex; kw...)\n\nPrint a given expression. `ex` can be a `Expr` or a syntax type `JLExpr`.\n" print_expr(io::IO, ex; kw...) = begin
                (Printer(io; kw...))(ex)
            end
    print_expr(ex; kw...) = begin
            print_expr(stdout, ex; kw...)
        end
