
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
                    var"##cache#1066" = nothing
                end
                var"##return#1063" = nothing
                var"##1065" = otherwise
                if var"##1065" isa Expr && (begin
                                if var"##cache#1066" === nothing
                                    var"##cache#1066" = Some(((var"##1065").head, (var"##1065").args))
                                end
                                var"##1067" = (var"##cache#1066").value
                                var"##1067" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1067"[1] == :block && (begin
                                        var"##1068" = var"##1067"[2]
                                        var"##1068" isa AbstractArray
                                    end && ((ndims(var"##1068") === 1 && length(var"##1068") >= 0) && begin
                                            var"##1069" = SubArray(var"##1068", (1:length(var"##1068"),))
                                            true
                                        end))))
                    var"##return#1063" = let stmts = var"##1069"
                            indent() do 
                                print_stmts(stmts)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1064#1070")))
                end
                begin
                    var"##return#1063" = let
                            indent() do 
                                tab()
                                no_first_line_indent() do 
                                    p(otherwise)
                                end
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1064#1070")))
                end
                error("matching non-exhaustive, at #= none:98 =#")
                $(Expr(:symboliclabel, Symbol("####final#1064#1070")))
                var"##return#1063"
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
                            var"##cache#1074" = nothing
                        end
                        var"##return#1071" = nothing
                        var"##1073" = stmt
                        if var"##1073" isa Expr && (begin
                                        if var"##cache#1074" === nothing
                                            var"##cache#1074" = Some(((var"##1073").head, (var"##1073").args))
                                        end
                                        var"##1075" = (var"##cache#1074").value
                                        var"##1075" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##1075"[1] == :macrocall && (begin
                                                var"##1076" = var"##1075"[2]
                                                var"##1076" isa AbstractArray
                                            end && ((ndims(var"##1076") === 1 && length(var"##1076") >= 1) && begin
                                                    var"##1077" = var"##1076"[1]
                                                    var"##1077" == Symbol("@case")
                                                end))))
                            var"##return#1071" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1072#1078")))
                        end
                        begin
                            var"##return#1071" = let
                                    false
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1072#1078")))
                        end
                        error("matching non-exhaustive, at #= none:181 =#")
                        $(Expr(:symboliclabel, Symbol("####final#1072#1078")))
                        var"##return#1071"
                    end
                end || return print_macrocall("@switch", line, (item, Expr(:block, stmts...)))
            is_case(stmt) = begin
                    let
                        begin
                            var"##cache#1082" = nothing
                        end
                        var"##return#1079" = nothing
                        var"##1081" = stmt
                        if var"##1081" isa Expr && (begin
                                        if var"##cache#1082" === nothing
                                            var"##cache#1082" = Some(((var"##1081").head, (var"##1081").args))
                                        end
                                        var"##1083" = (var"##cache#1082").value
                                        var"##1083" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##1083"[1] == :macrocall && (begin
                                                var"##1084" = var"##1083"[2]
                                                var"##1084" isa AbstractArray
                                            end && ((ndims(var"##1084") === 1 && length(var"##1084") >= 1) && begin
                                                    var"##1085" = var"##1084"[1]
                                                    var"##1085" == Symbol("@case")
                                                end))))
                            var"##return#1079" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1080#1086")))
                        end
                        begin
                            var"##return#1079" = let
                                    false
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1080#1086")))
                        end
                        error("matching non-exhaustive, at #= none:187 =#")
                        $(Expr(:symboliclabel, Symbol("####final#1080#1086")))
                        var"##return#1079"
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
                            var"##cache#1090" = nothing
                        end
                        var"##return#1087" = nothing
                        var"##1089" = stmt
                        if var"##1089" isa Expr && (begin
                                        if var"##cache#1090" === nothing
                                            var"##cache#1090" = Some(((var"##1089").head, (var"##1089").args))
                                        end
                                        var"##1091" = (var"##cache#1090").value
                                        var"##1091" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##1091"[1] == :macrocall && (begin
                                                var"##1092" = var"##1091"[2]
                                                var"##1092" isa AbstractArray
                                            end && (length(var"##1092") === 3 && (begin
                                                        var"##1093" = var"##1092"[1]
                                                        var"##1093" == Symbol("@case")
                                                    end && begin
                                                        var"##1094" = var"##1092"[2]
                                                        var"##1095" = var"##1092"[3]
                                                        true
                                                    end)))))
                            var"##return#1087" = let pattern = var"##1095", line = var"##1094"
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
                            $(Expr(:symbolicgoto, Symbol("####final#1088#1096")))
                        end
                        begin
                            var"##return#1087" = let
                                    p(stmt)
                                    println()
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1088#1096")))
                        end
                        error("matching non-exhaustive, at #= none:197 =#")
                        $(Expr(:symboliclabel, Symbol("####final#1088#1096")))
                        var"##return#1087"
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
                var"##cache#1100" = nothing
            end
            var"##1099" = ex
            if var"##1099" isa Expr
                if begin
                            if var"##cache#1100" === nothing
                                var"##cache#1100" = Some(((var"##1099").head, (var"##1099").args))
                            end
                            var"##1101" = (var"##cache#1100").value
                            var"##1101" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1101"[1] == :string && (begin
                                    var"##1102" = var"##1101"[2]
                                    var"##1102" isa AbstractArray
                                end && ((ndims(var"##1102") === 1 && length(var"##1102") >= 0) && begin
                                        var"##1103" = SubArray(var"##1102", (1:length(var"##1102"),))
                                        true
                                    end)))
                    args = var"##1103"
                    var"##return#1097" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1098#1305")))
                end
                if begin
                            var"##1104" = (var"##cache#1100").value
                            var"##1104" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1104"[1] == :block && (begin
                                    var"##1105" = var"##1104"[2]
                                    var"##1105" isa AbstractArray
                                end && ((ndims(var"##1105") === 1 && length(var"##1105") >= 0) && begin
                                        var"##1106" = SubArray(var"##1105", (1:length(var"##1105"),))
                                        true
                                    end)))
                    stmts = var"##1106"
                    var"##return#1097" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1098#1305")))
                end
                if begin
                            var"##1107" = (var"##cache#1100").value
                            var"##1107" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1107"[1] == :quote && (begin
                                    var"##1108" = var"##1107"[2]
                                    var"##1108" isa AbstractArray
                                end && (length(var"##1108") === 1 && (begin
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
                                                    end && ((ndims(var"##1112") === 1 && length(var"##1112") >= 0) && begin
                                                            var"##1113" = SubArray(var"##1112", (1:length(var"##1112"),))
                                                            let stmts = var"##1113"
                                                                is_root()
                                                            end
                                                        end))))))))
                    stmts = var"##1113"
                    var"##return#1097" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1098#1305")))
                end
                if begin
                            var"##1114" = (var"##cache#1100").value
                            var"##1114" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1114"[1] == :quote && (begin
                                    var"##1115" = var"##1114"[2]
                                    var"##1115" isa AbstractArray
                                end && (length(var"##1115") === 1 && (begin
                                            begin
                                                var"##cache#1117" = nothing
                                            end
                                            var"##1116" = var"##1115"[1]
                                            var"##1116" isa Expr
                                        end && (begin
                                                if var"##cache#1117" === nothing
                                                    var"##cache#1117" = Some(((var"##1116").head, (var"##1116").args))
                                                end
                                                var"##1118" = (var"##cache#1117").value
                                                var"##1118" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1118"[1] == :block && (begin
                                                        var"##1119" = var"##1118"[2]
                                                        var"##1119" isa AbstractArray
                                                    end && ((ndims(var"##1119") === 1 && length(var"##1119") >= 0) && begin
                                                            var"##1120" = SubArray(var"##1119", (1:length(var"##1119"),))
                                                            true
                                                        end))))))))
                    stmts = var"##1120"
                    var"##return#1097" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1098#1305")))
                end
                if begin
                            var"##1121" = (var"##cache#1100").value
                            var"##1121" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1121"[1] == :quote && (begin
                                    var"##1122" = var"##1121"[2]
                                    var"##1122" isa AbstractArray
                                end && (length(var"##1122") === 1 && begin
                                        var"##1123" = var"##1122"[1]
                                        true
                                    end)))
                    code = var"##1123"
                    var"##return#1097" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1098#1305")))
                end
                if begin
                            var"##1124" = (var"##cache#1100").value
                            var"##1124" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1124"[1] == :let && (begin
                                    var"##1125" = var"##1124"[2]
                                    var"##1125" isa AbstractArray
                                end && (length(var"##1125") === 2 && (begin
                                            begin
                                                var"##cache#1127" = nothing
                                            end
                                            var"##1126" = var"##1125"[1]
                                            var"##1126" isa Expr
                                        end && (begin
                                                if var"##cache#1127" === nothing
                                                    var"##cache#1127" = Some(((var"##1126").head, (var"##1126").args))
                                                end
                                                var"##1128" = (var"##cache#1127").value
                                                var"##1128" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1128"[1] == :block && (begin
                                                        var"##1129" = var"##1128"[2]
                                                        var"##1129" isa AbstractArray
                                                    end && ((ndims(var"##1129") === 1 && length(var"##1129") >= 0) && (begin
                                                                var"##1130" = SubArray(var"##1129", (1:length(var"##1129"),))
                                                                begin
                                                                    var"##cache#1132" = nothing
                                                                end
                                                                var"##1131" = var"##1125"[2]
                                                                var"##1131" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1132" === nothing
                                                                        var"##cache#1132" = Some(((var"##1131").head, (var"##1131").args))
                                                                    end
                                                                    var"##1133" = (var"##cache#1132").value
                                                                    var"##1133" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1133"[1] == :block && (begin
                                                                            var"##1134" = var"##1133"[2]
                                                                            var"##1134" isa AbstractArray
                                                                        end && ((ndims(var"##1134") === 1 && length(var"##1134") >= 0) && begin
                                                                                var"##1135" = SubArray(var"##1134", (1:length(var"##1134"),))
                                                                                true
                                                                            end)))))))))))))
                    args = var"##1130"
                    stmts = var"##1135"
                    var"##return#1097" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1098#1305")))
                end
                if begin
                            var"##1136" = (var"##cache#1100").value
                            var"##1136" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1136"[1] == :if && (begin
                                    var"##1137" = var"##1136"[2]
                                    var"##1137" isa AbstractArray
                                end && (length(var"##1137") === 2 && begin
                                        var"##1138" = var"##1137"[1]
                                        var"##1139" = var"##1137"[2]
                                        true
                                    end)))
                    cond = var"##1138"
                    body = var"##1139"
                    var"##return#1097" = begin
                            print_if(cond, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1098#1305")))
                end
                if begin
                            var"##1140" = (var"##cache#1100").value
                            var"##1140" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1140"[1] == :if && (begin
                                    var"##1141" = var"##1140"[2]
                                    var"##1141" isa AbstractArray
                                end && (length(var"##1141") === 3 && begin
                                        var"##1142" = var"##1141"[1]
                                        var"##1143" = var"##1141"[2]
                                        var"##1144" = var"##1141"[3]
                                        true
                                    end)))
                    cond = var"##1142"
                    body = var"##1143"
                    otherwise = var"##1144"
                    var"##return#1097" = begin
                            print_if(cond, body, otherwise)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1098#1305")))
                end
                if begin
                            var"##1145" = (var"##cache#1100").value
                            var"##1145" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1145"[1] == :elseif && (begin
                                    var"##1146" = var"##1145"[2]
                                    var"##1146" isa AbstractArray
                                end && (length(var"##1146") === 2 && (begin
                                            begin
                                                var"##cache#1148" = nothing
                                            end
                                            var"##1147" = var"##1146"[1]
                                            var"##1147" isa Expr
                                        end && (begin
                                                if var"##cache#1148" === nothing
                                                    var"##cache#1148" = Some(((var"##1147").head, (var"##1147").args))
                                                end
                                                var"##1149" = (var"##cache#1148").value
                                                var"##1149" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1149"[1] == :block && (begin
                                                        var"##1150" = var"##1149"[2]
                                                        var"##1150" isa AbstractArray
                                                    end && (length(var"##1150") === 2 && begin
                                                            var"##1151" = var"##1150"[1]
                                                            var"##1152" = var"##1150"[2]
                                                            var"##1153" = var"##1146"[2]
                                                            true
                                                        end))))))))
                    line = var"##1151"
                    cond = var"##1152"
                    body = var"##1153"
                    var"##return#1097" = begin
                            print_elseif(cond, body, line)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1098#1305")))
                end
                if begin
                            var"##1154" = (var"##cache#1100").value
                            var"##1154" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1154"[1] == :elseif && (begin
                                    var"##1155" = var"##1154"[2]
                                    var"##1155" isa AbstractArray
                                end && (length(var"##1155") === 2 && begin
                                        var"##1156" = var"##1155"[1]
                                        var"##1157" = var"##1155"[2]
                                        true
                                    end)))
                    cond = var"##1156"
                    body = var"##1157"
                    var"##return#1097" = begin
                            print_elseif(cond, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1098#1305")))
                end
                if begin
                            var"##1158" = (var"##cache#1100").value
                            var"##1158" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1158"[1] == :elseif && (begin
                                    var"##1159" = var"##1158"[2]
                                    var"##1159" isa AbstractArray
                                end && (length(var"##1159") === 3 && (begin
                                            begin
                                                var"##cache#1161" = nothing
                                            end
                                            var"##1160" = var"##1159"[1]
                                            var"##1160" isa Expr
                                        end && (begin
                                                if var"##cache#1161" === nothing
                                                    var"##cache#1161" = Some(((var"##1160").head, (var"##1160").args))
                                                end
                                                var"##1162" = (var"##cache#1161").value
                                                var"##1162" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1162"[1] == :block && (begin
                                                        var"##1163" = var"##1162"[2]
                                                        var"##1163" isa AbstractArray
                                                    end && (length(var"##1163") === 2 && begin
                                                            var"##1164" = var"##1163"[1]
                                                            var"##1165" = var"##1163"[2]
                                                            var"##1166" = var"##1159"[2]
                                                            var"##1167" = var"##1159"[3]
                                                            true
                                                        end))))))))
                    line = var"##1164"
                    cond = var"##1165"
                    body = var"##1166"
                    otherwise = var"##1167"
                    var"##return#1097" = begin
                            print_elseif(cond, body, line, otherwise)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1098#1305")))
                end
                if begin
                            var"##1168" = (var"##cache#1100").value
                            var"##1168" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1168"[1] == :elseif && (begin
                                    var"##1169" = var"##1168"[2]
                                    var"##1169" isa AbstractArray
                                end && (length(var"##1169") === 3 && begin
                                        var"##1170" = var"##1169"[1]
                                        var"##1171" = var"##1169"[2]
                                        var"##1172" = var"##1169"[3]
                                        true
                                    end)))
                    cond = var"##1170"
                    body = var"##1171"
                    otherwise = var"##1172"
                    var"##return#1097" = begin
                            print_elseif(cond, body, nothing, otherwise)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1098#1305")))
                end
                if begin
                            var"##1173" = (var"##cache#1100").value
                            var"##1173" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1173"[1] == :for && (begin
                                    var"##1174" = var"##1173"[2]
                                    var"##1174" isa AbstractArray
                                end && (length(var"##1174") === 2 && begin
                                        var"##1175" = var"##1174"[1]
                                        var"##1176" = var"##1174"[2]
                                        true
                                    end)))
                    body = var"##1176"
                    iteration = var"##1175"
                    var"##return#1097" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1098#1305")))
                end
                if begin
                            var"##1177" = (var"##cache#1100").value
                            var"##1177" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1177"[1] == :while && (begin
                                    var"##1178" = var"##1177"[2]
                                    var"##1178" isa AbstractArray
                                end && (length(var"##1178") === 2 && begin
                                        var"##1179" = var"##1178"[1]
                                        var"##1180" = var"##1178"[2]
                                        true
                                    end)))
                    cond = var"##1179"
                    body = var"##1180"
                    var"##return#1097" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1098#1305")))
                end
                if begin
                            var"##1181" = (var"##cache#1100").value
                            var"##1181" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1181"[1] == :(=) && (begin
                                    var"##1182" = var"##1181"[2]
                                    var"##1182" isa AbstractArray
                                end && (length(var"##1182") === 2 && (begin
                                            var"##1183" = var"##1182"[1]
                                            begin
                                                var"##cache#1185" = nothing
                                            end
                                            var"##1184" = var"##1182"[2]
                                            var"##1184" isa Expr
                                        end && (begin
                                                if var"##cache#1185" === nothing
                                                    var"##cache#1185" = Some(((var"##1184").head, (var"##1184").args))
                                                end
                                                var"##1186" = (var"##cache#1185").value
                                                var"##1186" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1186"[1] == :block && (begin
                                                        var"##1187" = var"##1186"[2]
                                                        var"##1187" isa AbstractArray
                                                    end && (length(var"##1187") === 2 && (begin
                                                                var"##1188" = var"##1187"[1]
                                                                begin
                                                                    var"##cache#1190" = nothing
                                                                end
                                                                var"##1189" = var"##1187"[2]
                                                                var"##1189" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1190" === nothing
                                                                        var"##cache#1190" = Some(((var"##1189").head, (var"##1189").args))
                                                                    end
                                                                    var"##1191" = (var"##cache#1190").value
                                                                    var"##1191" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1191"[1] == :if && (begin
                                                                            var"##1192" = var"##1191"[2]
                                                                            var"##1192" isa AbstractArray
                                                                        end && ((ndims(var"##1192") === 1 && length(var"##1192") >= 0) && let line = var"##1188", lhs = var"##1183"
                                                                                is_line_no(line)
                                                                            end)))))))))))))
                    line = var"##1188"
                    lhs = var"##1183"
                    var"##return#1097" = begin
                            leading_tab()
                            inline(lhs)
                            keyword(" = ")
                            inline(line)
                            p(ex.args[2])
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1098#1305")))
                end
                if begin
                            var"##1193" = (var"##cache#1100").value
                            var"##1193" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1193"[1] == :(=) && (begin
                                    var"##1194" = var"##1193"[2]
                                    var"##1194" isa AbstractArray
                                end && (length(var"##1194") === 2 && (begin
                                            var"##1195" = var"##1194"[1]
                                            begin
                                                var"##cache#1197" = nothing
                                            end
                                            var"##1196" = var"##1194"[2]
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
                                                    end && (length(var"##1199") === 2 && begin
                                                            var"##1200" = var"##1199"[1]
                                                            var"##1201" = var"##1199"[2]
                                                            let rhs = var"##1201", line = var"##1200", lhs = var"##1195"
                                                                is_line_no(line)
                                                            end
                                                        end))))))))
                    rhs = var"##1201"
                    line = var"##1200"
                    lhs = var"##1195"
                    var"##return#1097" = begin
                            leading_tab()
                            inline(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1098#1305")))
                end
                if begin
                            var"##1202" = (var"##cache#1100").value
                            var"##1202" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1202"[1] == :(=) && (begin
                                    var"##1203" = var"##1202"[2]
                                    var"##1203" isa AbstractArray
                                end && (length(var"##1203") === 2 && begin
                                        var"##1204" = var"##1203"[1]
                                        var"##1205" = var"##1203"[2]
                                        true
                                    end)))
                    rhs = var"##1205"
                    lhs = var"##1204"
                    var"##return#1097" = begin
                            leading_tab()
                            inline(lhs)
                            print(" = ")
                            p(rhs)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1098#1305")))
                end
                if begin
                            var"##1206" = (var"##cache#1100").value
                            var"##1206" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1206"[1] == :function && (begin
                                    var"##1207" = var"##1206"[2]
                                    var"##1207" isa AbstractArray
                                end && (length(var"##1207") === 2 && begin
                                        var"##1208" = var"##1207"[1]
                                        var"##1209" = var"##1207"[2]
                                        true
                                    end)))
                    call = var"##1208"
                    body = var"##1209"
                    var"##return#1097" = begin
                            print_function(:function, call, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1098#1305")))
                end
                if begin
                            var"##1210" = (var"##cache#1100").value
                            var"##1210" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1210"[1] == :-> && (begin
                                    var"##1211" = var"##1210"[2]
                                    var"##1211" isa AbstractArray
                                end && (length(var"##1211") === 2 && begin
                                        var"##1212" = var"##1211"[1]
                                        var"##1213" = var"##1211"[2]
                                        true
                                    end)))
                    call = var"##1212"
                    body = var"##1213"
                    var"##return#1097" = begin
                            leading_tab()
                            inline(call)
                            keyword(" -> ")
                            p(body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1098#1305")))
                end
                if begin
                            var"##1214" = (var"##cache#1100").value
                            var"##1214" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1214"[1] == :do && (begin
                                    var"##1215" = var"##1214"[2]
                                    var"##1215" isa AbstractArray
                                end && (length(var"##1215") === 2 && (begin
                                            var"##1216" = var"##1215"[1]
                                            begin
                                                var"##cache#1218" = nothing
                                            end
                                            var"##1217" = var"##1215"[2]
                                            var"##1217" isa Expr
                                        end && (begin
                                                if var"##cache#1218" === nothing
                                                    var"##cache#1218" = Some(((var"##1217").head, (var"##1217").args))
                                                end
                                                var"##1219" = (var"##cache#1218").value
                                                var"##1219" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1219"[1] == :-> && (begin
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
                                                                end && (var"##1223"[1] == :tuple && (begin
                                                                            var"##1224" = var"##1223"[2]
                                                                            var"##1224" isa AbstractArray
                                                                        end && ((ndims(var"##1224") === 1 && length(var"##1224") >= 0) && begin
                                                                                var"##1225" = SubArray(var"##1224", (1:length(var"##1224"),))
                                                                                var"##1226" = var"##1220"[2]
                                                                                true
                                                                            end)))))))))))))
                    call = var"##1216"
                    args = var"##1225"
                    body = var"##1226"
                    var"##return#1097" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1098#1305")))
                end
                if begin
                            var"##1227" = (var"##cache#1100").value
                            var"##1227" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1227"[1] == :macro && (begin
                                    var"##1228" = var"##1227"[2]
                                    var"##1228" isa AbstractArray
                                end && (length(var"##1228") === 2 && begin
                                        var"##1229" = var"##1228"[1]
                                        var"##1230" = var"##1228"[2]
                                        true
                                    end)))
                    call = var"##1229"
                    body = var"##1230"
                    var"##return#1097" = begin
                            print_function(:macro, call, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1098#1305")))
                end
                if begin
                            var"##1231" = (var"##cache#1100").value
                            var"##1231" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1231"[1] == :macrocall && (begin
                                    var"##1232" = var"##1231"[2]
                                    var"##1232" isa AbstractArray
                                end && (length(var"##1232") === 4 && (begin
                                            var"##1233" = var"##1232"[1]
                                            var"##1233" == Symbol("@switch")
                                        end && (begin
                                                var"##1234" = var"##1232"[2]
                                                var"##1235" = var"##1232"[3]
                                                begin
                                                    var"##cache#1237" = nothing
                                                end
                                                var"##1236" = var"##1232"[4]
                                                var"##1236" isa Expr
                                            end && (begin
                                                    if var"##cache#1237" === nothing
                                                        var"##cache#1237" = Some(((var"##1236").head, (var"##1236").args))
                                                    end
                                                    var"##1238" = (var"##cache#1237").value
                                                    var"##1238" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1238"[1] == :block && (begin
                                                            var"##1239" = var"##1238"[2]
                                                            var"##1239" isa AbstractArray
                                                        end && ((ndims(var"##1239") === 1 && length(var"##1239") >= 0) && begin
                                                                var"##1240" = SubArray(var"##1239", (1:length(var"##1239"),))
                                                                true
                                                            end)))))))))
                    item = var"##1235"
                    line = var"##1234"
                    stmts = var"##1240"
                    var"##return#1097" = begin
                            print_switch(item, line, stmts)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1098#1305")))
                end
                if begin
                            var"##1241" = (var"##cache#1100").value
                            var"##1241" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1241"[1] == :macrocall && (begin
                                    var"##1242" = var"##1241"[2]
                                    var"##1242" isa AbstractArray
                                end && (length(var"##1242") === 4 && (begin
                                            var"##1243" = var"##1242"[1]
                                            var"##1243" == GlobalRef(Core, Symbol("@doc"))
                                        end && begin
                                            var"##1244" = var"##1242"[2]
                                            var"##1245" = var"##1242"[3]
                                            var"##1246" = var"##1242"[4]
                                            true
                                        end))))
                    line = var"##1244"
                    code = var"##1246"
                    doc = var"##1245"
                    var"##return#1097" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1098#1305")))
                end
                if begin
                            var"##1247" = (var"##cache#1100").value
                            var"##1247" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1247"[1] == :macrocall && (begin
                                    var"##1248" = var"##1247"[2]
                                    var"##1248" isa AbstractArray
                                end && ((ndims(var"##1248") === 1 && length(var"##1248") >= 2) && begin
                                        var"##1249" = var"##1248"[1]
                                        var"##1250" = var"##1248"[2]
                                        var"##1251" = SubArray(var"##1248", (3:length(var"##1248"),))
                                        true
                                    end)))
                    line = var"##1250"
                    name = var"##1249"
                    args = var"##1251"
                    var"##return#1097" = begin
                            print_macrocall(name, line, args)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1098#1305")))
                end
                if begin
                            var"##1252" = (var"##cache#1100").value
                            var"##1252" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1252"[1] == :struct && (begin
                                    var"##1253" = var"##1252"[2]
                                    var"##1253" isa AbstractArray
                                end && (length(var"##1253") === 3 && begin
                                        var"##1254" = var"##1253"[1]
                                        var"##1255" = var"##1253"[2]
                                        var"##1256" = var"##1253"[3]
                                        true
                                    end)))
                    ismutable = var"##1254"
                    body = var"##1256"
                    head = var"##1255"
                    var"##return#1097" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1098#1305")))
                end
                if begin
                            var"##1257" = (var"##cache#1100").value
                            var"##1257" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1257"[1] == :try && (begin
                                    var"##1258" = var"##1257"[2]
                                    var"##1258" isa AbstractArray
                                end && (length(var"##1258") === 3 && begin
                                        var"##1259" = var"##1258"[1]
                                        var"##1260" = var"##1258"[2]
                                        var"##1261" = var"##1258"[3]
                                        true
                                    end)))
                    catch_vars = var"##1260"
                    catch_body = var"##1261"
                    try_body = var"##1259"
                    var"##return#1097" = begin
                            print_try(try_body)
                            print_catch(catch_body, catch_vars)
                            println()
                            tab()
                            keyword("end")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1098#1305")))
                end
                if begin
                            var"##1262" = (var"##cache#1100").value
                            var"##1262" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1262"[1] == :try && (begin
                                    var"##1263" = var"##1262"[2]
                                    var"##1263" isa AbstractArray
                                end && (length(var"##1263") === 4 && begin
                                        var"##1264" = var"##1263"[1]
                                        var"##1265" = var"##1263"[2]
                                        var"##1266" = var"##1263"[3]
                                        var"##1267" = var"##1263"[4]
                                        true
                                    end)))
                    catch_vars = var"##1265"
                    catch_body = var"##1266"
                    try_body = var"##1264"
                    finally_body = var"##1267"
                    var"##return#1097" = begin
                            print_try(try_body)
                            print_catch(catch_body, catch_vars)
                            print_finally(finally_body)
                            println()
                            tab()
                            keyword("end")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1098#1305")))
                end
                if begin
                            var"##1268" = (var"##cache#1100").value
                            var"##1268" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1268"[1] == :try && (begin
                                    var"##1269" = var"##1268"[2]
                                    var"##1269" isa AbstractArray
                                end && (length(var"##1269") === 5 && begin
                                        var"##1270" = var"##1269"[1]
                                        var"##1271" = var"##1269"[2]
                                        var"##1272" = var"##1269"[3]
                                        var"##1273" = var"##1269"[4]
                                        var"##1274" = var"##1269"[5]
                                        true
                                    end)))
                    catch_vars = var"##1271"
                    catch_body = var"##1272"
                    try_body = var"##1270"
                    finally_body = var"##1273"
                    else_body = var"##1274"
                    var"##return#1097" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1098#1305")))
                end
                if begin
                            var"##1275" = (var"##cache#1100").value
                            var"##1275" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1275"[1] == :module && (begin
                                    var"##1276" = var"##1275"[2]
                                    var"##1276" isa AbstractArray
                                end && (length(var"##1276") === 3 && begin
                                        var"##1277" = var"##1276"[1]
                                        var"##1278" = var"##1276"[2]
                                        var"##1279" = var"##1276"[3]
                                        true
                                    end)))
                    name = var"##1278"
                    body = var"##1279"
                    notbare = var"##1277"
                    var"##return#1097" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1098#1305")))
                end
                if begin
                            var"##1280" = (var"##cache#1100").value
                            var"##1280" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1280"[1] == :const && (begin
                                    var"##1281" = var"##1280"[2]
                                    var"##1281" isa AbstractArray
                                end && (length(var"##1281") === 1 && begin
                                        var"##1282" = var"##1281"[1]
                                        true
                                    end)))
                    code = var"##1282"
                    var"##return#1097" = begin
                            leading_tab()
                            keyword("const ")
                            p(code)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1098#1305")))
                end
                if begin
                            var"##1283" = (var"##cache#1100").value
                            var"##1283" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1283"[1] == :return && (begin
                                    var"##1284" = var"##1283"[2]
                                    var"##1284" isa AbstractArray
                                end && (length(var"##1284") === 1 && (begin
                                            begin
                                                var"##cache#1286" = nothing
                                            end
                                            var"##1285" = var"##1284"[1]
                                            var"##1285" isa Expr
                                        end && (begin
                                                if var"##cache#1286" === nothing
                                                    var"##cache#1286" = Some(((var"##1285").head, (var"##1285").args))
                                                end
                                                var"##1287" = (var"##cache#1286").value
                                                var"##1287" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1287"[1] == :tuple && (begin
                                                        var"##1288" = var"##1287"[2]
                                                        var"##1288" isa AbstractArray
                                                    end && ((ndims(var"##1288") === 1 && length(var"##1288") >= 1) && (begin
                                                                begin
                                                                    var"##cache#1290" = nothing
                                                                end
                                                                var"##1289" = var"##1288"[1]
                                                                var"##1289" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1290" === nothing
                                                                        var"##cache#1290" = Some(((var"##1289").head, (var"##1289").args))
                                                                    end
                                                                    var"##1291" = (var"##cache#1290").value
                                                                    var"##1291" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1291"[1] == :parameters && (begin
                                                                            var"##1292" = var"##1291"[2]
                                                                            var"##1292" isa AbstractArray
                                                                        end && (ndims(var"##1292") === 1 && length(var"##1292") >= 0)))))))))))))
                    var"##return#1097" = begin
                            inline(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1098#1305")))
                end
                if begin
                            var"##1293" = (var"##cache#1100").value
                            var"##1293" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1293"[1] == :return && (begin
                                    var"##1294" = var"##1293"[2]
                                    var"##1294" isa AbstractArray
                                end && (length(var"##1294") === 1 && (begin
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
                                                    end && (ndims(var"##1298") === 1 && length(var"##1298") >= 0))))))))
                    var"##return#1097" = begin
                            inline(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1098#1305")))
                end
                if begin
                            var"##1299" = (var"##cache#1100").value
                            var"##1299" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1299"[1] == :return && (begin
                                    var"##1300" = var"##1299"[2]
                                    var"##1300" isa AbstractArray
                                end && (length(var"##1300") === 1 && begin
                                        var"##1301" = var"##1300"[1]
                                        true
                                    end)))
                    code = var"##1301"
                    var"##return#1097" = begin
                            leading_tab()
                            keyword("return ")
                            p(code)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1098#1305")))
                end
                if begin
                            var"##1302" = (var"##cache#1100").value
                            var"##1302" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1302"[1] == :toplevel && (begin
                                    var"##1303" = var"##1302"[2]
                                    var"##1303" isa AbstractArray
                                end && (length(var"##1303") === 1 && begin
                                        var"##1304" = var"##1303"[1]
                                        true
                                    end)))
                    code = var"##1304"
                    var"##return#1097" = begin
                            leading_tab()
                            printstyled("#= meta: toplevel =#", color = c.comment)
                            println()
                            p(code)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1098#1305")))
                end
            end
            if var"##1099" isa String
                begin
                    var"##return#1097" = begin
                            leading_tab()
                            occursin('\n', ex) || return inline(ex)
                            printstyled("\"\"\"\n", color = c.string)
                            tab()
                            print_multi_lines(ex)
                            printstyled("\"\"\"", color = c.string)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1098#1305")))
                end
            end
            begin
                var"##return#1097" = begin
                        inline(ex)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#1098#1305")))
            end
            error("matching non-exhaustive, at #= none:246 =#")
            $(Expr(:symboliclabel, Symbol("####final#1098#1305")))
            var"##return#1097"
        end
        return nothing
    end
    #= none:468 =# Core.@doc "    print_expr([io::IO], ex; kw...)\n\nPrint a given expression. `ex` can be a `Expr` or a syntax type `JLExpr`.\n" print_expr(io::IO, ex; kw...) = begin
                (Printer(io; kw...))(ex)
            end
    print_expr(ex; kw...) = begin
            print_expr(stdout, ex; kw...)
        end
