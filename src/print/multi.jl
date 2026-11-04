
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
                    var"##cache#1043" = nothing
                end
                var"##return#1040" = nothing
                var"##1042" = otherwise
                if var"##1042" isa Expr && (begin
                                if var"##cache#1043" === nothing
                                    var"##cache#1043" = Some(((var"##1042").head, (var"##1042").args))
                                end
                                var"##1044" = (var"##cache#1043").value
                                var"##1044" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1044"[1] == :block && (begin
                                        var"##1045" = var"##1044"[2]
                                        var"##1045" isa AbstractArray
                                    end && ((ndims(var"##1045") === 1 && length(var"##1045") >= 0) && begin
                                            var"##1046" = SubArray(var"##1045", (1:length(var"##1045"),))
                                            true
                                        end))))
                    var"##return#1040" = let stmts = var"##1046"
                            indent() do
                                print_stmts(stmts)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1041#1047")))
                end
                begin
                    var"##return#1040" = let
                            indent() do
                                tab()
                                no_first_line_indent() do
                                    p(otherwise)
                                end
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1041#1047")))
                end
                error("matching non-exhaustive, at #= none:98 =#")
                $(Expr(:symboliclabel, Symbol("####final#1041#1047")))
                var"##return#1040"
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
                            var"##cache#1051" = nothing
                        end
                        var"##return#1048" = nothing
                        var"##1050" = stmt
                        if var"##1050" isa Expr && (begin
                                        if var"##cache#1051" === nothing
                                            var"##cache#1051" = Some(((var"##1050").head, (var"##1050").args))
                                        end
                                        var"##1052" = (var"##cache#1051").value
                                        var"##1052" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##1052"[1] == :macrocall && (begin
                                                var"##1053" = var"##1052"[2]
                                                var"##1053" isa AbstractArray
                                            end && ((ndims(var"##1053") === 1 && length(var"##1053") >= 1) && begin
                                                    var"##1054" = var"##1053"[1]
                                                    var"##1054" == Symbol("@case")
                                                end))))
                            var"##return#1048" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1049#1055")))
                        end
                        begin
                            var"##return#1048" = let
                                    false
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1049#1055")))
                        end
                        error("matching non-exhaustive, at #= none:181 =#")
                        $(Expr(:symboliclabel, Symbol("####final#1049#1055")))
                        var"##return#1048"
                    end
                end || return print_macrocall("@switch", line, (item, Expr(:block, stmts...)))
            is_case(stmt) = begin
                    let
                        begin
                            var"##cache#1059" = nothing
                        end
                        var"##return#1056" = nothing
                        var"##1058" = stmt
                        if var"##1058" isa Expr && (begin
                                        if var"##cache#1059" === nothing
                                            var"##cache#1059" = Some(((var"##1058").head, (var"##1058").args))
                                        end
                                        var"##1060" = (var"##cache#1059").value
                                        var"##1060" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##1060"[1] == :macrocall && (begin
                                                var"##1061" = var"##1060"[2]
                                                var"##1061" isa AbstractArray
                                            end && ((ndims(var"##1061") === 1 && length(var"##1061") >= 1) && begin
                                                    var"##1062" = var"##1061"[1]
                                                    var"##1062" == Symbol("@case")
                                                end))))
                            var"##return#1056" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1057#1063")))
                        end
                        begin
                            var"##return#1056" = let
                                    false
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1057#1063")))
                        end
                        error("matching non-exhaustive, at #= none:187 =#")
                        $(Expr(:symboliclabel, Symbol("####final#1057#1063")))
                        var"##return#1056"
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
                            var"##cache#1067" = nothing
                        end
                        var"##return#1064" = nothing
                        var"##1066" = stmt
                        if var"##1066" isa Expr && (begin
                                        if var"##cache#1067" === nothing
                                            var"##cache#1067" = Some(((var"##1066").head, (var"##1066").args))
                                        end
                                        var"##1068" = (var"##cache#1067").value
                                        var"##1068" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##1068"[1] == :macrocall && (begin
                                                var"##1069" = var"##1068"[2]
                                                var"##1069" isa AbstractArray
                                            end && (length(var"##1069") === 3 && (begin
                                                        var"##1070" = var"##1069"[1]
                                                        var"##1070" == Symbol("@case")
                                                    end && begin
                                                        var"##1071" = var"##1069"[2]
                                                        var"##1072" = var"##1069"[3]
                                                        true
                                                    end)))))
                            var"##return#1064" = let pattern = var"##1072", line = var"##1071"
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
                            $(Expr(:symbolicgoto, Symbol("####final#1065#1073")))
                        end
                        begin
                            var"##return#1064" = let
                                    p(stmt)
                                    println()
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1065#1073")))
                        end
                        error("matching non-exhaustive, at #= none:197 =#")
                        $(Expr(:symboliclabel, Symbol("####final#1065#1073")))
                        var"##return#1064"
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
                var"##cache#1077" = nothing
            end
            var"##1076" = ex
            if var"##1076" isa String
                begin
                    var"##return#1074" = begin
                            leading_tab()
                            occursin('\n', ex) || return inline(ex)
                            printstyled("\"\"\"\n", color = c.string)
                            tab()
                            print_multi_lines(ex)
                            printstyled("\"\"\"", color = c.string)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1075#1282")))
                end
            end
            if var"##1076" isa Expr
                if begin
                            if var"##cache#1077" === nothing
                                var"##cache#1077" = Some(((var"##1076").head, (var"##1076").args))
                            end
                            var"##1078" = (var"##cache#1077").value
                            var"##1078" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1078"[1] == :string && (begin
                                    var"##1079" = var"##1078"[2]
                                    var"##1079" isa AbstractArray
                                end && ((ndims(var"##1079") === 1 && length(var"##1079") >= 0) && begin
                                        var"##1080" = SubArray(var"##1079", (1:length(var"##1079"),))
                                        true
                                    end)))
                    args = var"##1080"
                    var"##return#1074" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1075#1282")))
                end
                if begin
                            var"##1081" = (var"##cache#1077").value
                            var"##1081" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1081"[1] == :block && (begin
                                    var"##1082" = var"##1081"[2]
                                    var"##1082" isa AbstractArray
                                end && ((ndims(var"##1082") === 1 && length(var"##1082") >= 0) && begin
                                        var"##1083" = SubArray(var"##1082", (1:length(var"##1082"),))
                                        true
                                    end)))
                    stmts = var"##1083"
                    var"##return#1074" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1075#1282")))
                end
                if begin
                            var"##1084" = (var"##cache#1077").value
                            var"##1084" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1084"[1] == :quote && (begin
                                    var"##1085" = var"##1084"[2]
                                    var"##1085" isa AbstractArray
                                end && (length(var"##1085") === 1 && (begin
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
                                                    end && ((ndims(var"##1089") === 1 && length(var"##1089") >= 0) && begin
                                                            var"##1090" = SubArray(var"##1089", (1:length(var"##1089"),))
                                                            let stmts = var"##1090"
                                                                is_root()
                                                            end
                                                        end))))))))
                    stmts = var"##1090"
                    var"##return#1074" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1075#1282")))
                end
                if begin
                            var"##1091" = (var"##cache#1077").value
                            var"##1091" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1091"[1] == :quote && (begin
                                    var"##1092" = var"##1091"[2]
                                    var"##1092" isa AbstractArray
                                end && (length(var"##1092") === 1 && (begin
                                            begin
                                                var"##cache#1094" = nothing
                                            end
                                            var"##1093" = var"##1092"[1]
                                            var"##1093" isa Expr
                                        end && (begin
                                                if var"##cache#1094" === nothing
                                                    var"##cache#1094" = Some(((var"##1093").head, (var"##1093").args))
                                                end
                                                var"##1095" = (var"##cache#1094").value
                                                var"##1095" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1095"[1] == :block && (begin
                                                        var"##1096" = var"##1095"[2]
                                                        var"##1096" isa AbstractArray
                                                    end && ((ndims(var"##1096") === 1 && length(var"##1096") >= 0) && begin
                                                            var"##1097" = SubArray(var"##1096", (1:length(var"##1096"),))
                                                            true
                                                        end))))))))
                    stmts = var"##1097"
                    var"##return#1074" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1075#1282")))
                end
                if begin
                            var"##1098" = (var"##cache#1077").value
                            var"##1098" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1098"[1] == :quote && (begin
                                    var"##1099" = var"##1098"[2]
                                    var"##1099" isa AbstractArray
                                end && (length(var"##1099") === 1 && begin
                                        var"##1100" = var"##1099"[1]
                                        true
                                    end)))
                    code = var"##1100"
                    var"##return#1074" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1075#1282")))
                end
                if begin
                            var"##1101" = (var"##cache#1077").value
                            var"##1101" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1101"[1] == :let && (begin
                                    var"##1102" = var"##1101"[2]
                                    var"##1102" isa AbstractArray
                                end && (length(var"##1102") === 2 && (begin
                                            begin
                                                var"##cache#1104" = nothing
                                            end
                                            var"##1103" = var"##1102"[1]
                                            var"##1103" isa Expr
                                        end && (begin
                                                if var"##cache#1104" === nothing
                                                    var"##cache#1104" = Some(((var"##1103").head, (var"##1103").args))
                                                end
                                                var"##1105" = (var"##cache#1104").value
                                                var"##1105" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1105"[1] == :block && (begin
                                                        var"##1106" = var"##1105"[2]
                                                        var"##1106" isa AbstractArray
                                                    end && ((ndims(var"##1106") === 1 && length(var"##1106") >= 0) && (begin
                                                                var"##1107" = SubArray(var"##1106", (1:length(var"##1106"),))
                                                                begin
                                                                    var"##cache#1109" = nothing
                                                                end
                                                                var"##1108" = var"##1102"[2]
                                                                var"##1108" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1109" === nothing
                                                                        var"##cache#1109" = Some(((var"##1108").head, (var"##1108").args))
                                                                    end
                                                                    var"##1110" = (var"##cache#1109").value
                                                                    var"##1110" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1110"[1] == :block && (begin
                                                                            var"##1111" = var"##1110"[2]
                                                                            var"##1111" isa AbstractArray
                                                                        end && ((ndims(var"##1111") === 1 && length(var"##1111") >= 0) && begin
                                                                                var"##1112" = SubArray(var"##1111", (1:length(var"##1111"),))
                                                                                true
                                                                            end)))))))))))))
                    args = var"##1107"
                    stmts = var"##1112"
                    var"##return#1074" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1075#1282")))
                end
                if begin
                            var"##1113" = (var"##cache#1077").value
                            var"##1113" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1113"[1] == :if && (begin
                                    var"##1114" = var"##1113"[2]
                                    var"##1114" isa AbstractArray
                                end && (length(var"##1114") === 2 && begin
                                        var"##1115" = var"##1114"[1]
                                        var"##1116" = var"##1114"[2]
                                        true
                                    end)))
                    cond = var"##1115"
                    body = var"##1116"
                    var"##return#1074" = begin
                            print_if(cond, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1075#1282")))
                end
                if begin
                            var"##1117" = (var"##cache#1077").value
                            var"##1117" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1117"[1] == :if && (begin
                                    var"##1118" = var"##1117"[2]
                                    var"##1118" isa AbstractArray
                                end && (length(var"##1118") === 3 && begin
                                        var"##1119" = var"##1118"[1]
                                        var"##1120" = var"##1118"[2]
                                        var"##1121" = var"##1118"[3]
                                        true
                                    end)))
                    cond = var"##1119"
                    body = var"##1120"
                    otherwise = var"##1121"
                    var"##return#1074" = begin
                            print_if(cond, body, otherwise)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1075#1282")))
                end
                if begin
                            var"##1122" = (var"##cache#1077").value
                            var"##1122" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1122"[1] == :elseif && (begin
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
                                                    end && (length(var"##1127") === 2 && begin
                                                            var"##1128" = var"##1127"[1]
                                                            var"##1129" = var"##1127"[2]
                                                            var"##1130" = var"##1123"[2]
                                                            true
                                                        end))))))))
                    line = var"##1128"
                    cond = var"##1129"
                    body = var"##1130"
                    var"##return#1074" = begin
                            print_elseif(cond, body, line)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1075#1282")))
                end
                if begin
                            var"##1131" = (var"##cache#1077").value
                            var"##1131" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1131"[1] == :elseif && (begin
                                    var"##1132" = var"##1131"[2]
                                    var"##1132" isa AbstractArray
                                end && (length(var"##1132") === 2 && begin
                                        var"##1133" = var"##1132"[1]
                                        var"##1134" = var"##1132"[2]
                                        true
                                    end)))
                    cond = var"##1133"
                    body = var"##1134"
                    var"##return#1074" = begin
                            print_elseif(cond, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1075#1282")))
                end
                if begin
                            var"##1135" = (var"##cache#1077").value
                            var"##1135" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1135"[1] == :elseif && (begin
                                    var"##1136" = var"##1135"[2]
                                    var"##1136" isa AbstractArray
                                end && (length(var"##1136") === 3 && (begin
                                            begin
                                                var"##cache#1138" = nothing
                                            end
                                            var"##1137" = var"##1136"[1]
                                            var"##1137" isa Expr
                                        end && (begin
                                                if var"##cache#1138" === nothing
                                                    var"##cache#1138" = Some(((var"##1137").head, (var"##1137").args))
                                                end
                                                var"##1139" = (var"##cache#1138").value
                                                var"##1139" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1139"[1] == :block && (begin
                                                        var"##1140" = var"##1139"[2]
                                                        var"##1140" isa AbstractArray
                                                    end && (length(var"##1140") === 2 && begin
                                                            var"##1141" = var"##1140"[1]
                                                            var"##1142" = var"##1140"[2]
                                                            var"##1143" = var"##1136"[2]
                                                            var"##1144" = var"##1136"[3]
                                                            true
                                                        end))))))))
                    line = var"##1141"
                    cond = var"##1142"
                    body = var"##1143"
                    otherwise = var"##1144"
                    var"##return#1074" = begin
                            print_elseif(cond, body, line, otherwise)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1075#1282")))
                end
                if begin
                            var"##1145" = (var"##cache#1077").value
                            var"##1145" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1145"[1] == :elseif && (begin
                                    var"##1146" = var"##1145"[2]
                                    var"##1146" isa AbstractArray
                                end && (length(var"##1146") === 3 && begin
                                        var"##1147" = var"##1146"[1]
                                        var"##1148" = var"##1146"[2]
                                        var"##1149" = var"##1146"[3]
                                        true
                                    end)))
                    cond = var"##1147"
                    body = var"##1148"
                    otherwise = var"##1149"
                    var"##return#1074" = begin
                            print_elseif(cond, body, nothing, otherwise)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1075#1282")))
                end
                if begin
                            var"##1150" = (var"##cache#1077").value
                            var"##1150" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1150"[1] == :for && (begin
                                    var"##1151" = var"##1150"[2]
                                    var"##1151" isa AbstractArray
                                end && (length(var"##1151") === 2 && begin
                                        var"##1152" = var"##1151"[1]
                                        var"##1153" = var"##1151"[2]
                                        true
                                    end)))
                    body = var"##1153"
                    iteration = var"##1152"
                    var"##return#1074" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1075#1282")))
                end
                if begin
                            var"##1154" = (var"##cache#1077").value
                            var"##1154" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1154"[1] == :while && (begin
                                    var"##1155" = var"##1154"[2]
                                    var"##1155" isa AbstractArray
                                end && (length(var"##1155") === 2 && begin
                                        var"##1156" = var"##1155"[1]
                                        var"##1157" = var"##1155"[2]
                                        true
                                    end)))
                    cond = var"##1156"
                    body = var"##1157"
                    var"##return#1074" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1075#1282")))
                end
                if begin
                            var"##1158" = (var"##cache#1077").value
                            var"##1158" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1158"[1] == :(=) && (begin
                                    var"##1159" = var"##1158"[2]
                                    var"##1159" isa AbstractArray
                                end && (length(var"##1159") === 2 && (begin
                                            var"##1160" = var"##1159"[1]
                                            begin
                                                var"##cache#1162" = nothing
                                            end
                                            var"##1161" = var"##1159"[2]
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
                                                    end && (length(var"##1164") === 2 && (begin
                                                                var"##1165" = var"##1164"[1]
                                                                begin
                                                                    var"##cache#1167" = nothing
                                                                end
                                                                var"##1166" = var"##1164"[2]
                                                                var"##1166" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1167" === nothing
                                                                        var"##cache#1167" = Some(((var"##1166").head, (var"##1166").args))
                                                                    end
                                                                    var"##1168" = (var"##cache#1167").value
                                                                    var"##1168" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1168"[1] == :if && (begin
                                                                            var"##1169" = var"##1168"[2]
                                                                            var"##1169" isa AbstractArray
                                                                        end && ((ndims(var"##1169") === 1 && length(var"##1169") >= 0) && let line = var"##1165", lhs = var"##1160"
                                                                                is_line_no(line)
                                                                            end)))))))))))))
                    line = var"##1165"
                    lhs = var"##1160"
                    var"##return#1074" = begin
                            leading_tab()
                            inline(lhs)
                            keyword(" = ")
                            inline(line)
                            p(ex.args[2])
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1075#1282")))
                end
                if begin
                            var"##1170" = (var"##cache#1077").value
                            var"##1170" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1170"[1] == :(=) && (begin
                                    var"##1171" = var"##1170"[2]
                                    var"##1171" isa AbstractArray
                                end && (length(var"##1171") === 2 && (begin
                                            var"##1172" = var"##1171"[1]
                                            begin
                                                var"##cache#1174" = nothing
                                            end
                                            var"##1173" = var"##1171"[2]
                                            var"##1173" isa Expr
                                        end && (begin
                                                if var"##cache#1174" === nothing
                                                    var"##cache#1174" = Some(((var"##1173").head, (var"##1173").args))
                                                end
                                                var"##1175" = (var"##cache#1174").value
                                                var"##1175" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1175"[1] == :block && (begin
                                                        var"##1176" = var"##1175"[2]
                                                        var"##1176" isa AbstractArray
                                                    end && (length(var"##1176") === 2 && begin
                                                            var"##1177" = var"##1176"[1]
                                                            var"##1178" = var"##1176"[2]
                                                            let rhs = var"##1178", line = var"##1177", lhs = var"##1172"
                                                                is_line_no(line)
                                                            end
                                                        end))))))))
                    rhs = var"##1178"
                    line = var"##1177"
                    lhs = var"##1172"
                    var"##return#1074" = begin
                            leading_tab()
                            inline(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1075#1282")))
                end
                if begin
                            var"##1179" = (var"##cache#1077").value
                            var"##1179" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1179"[1] == :(=) && (begin
                                    var"##1180" = var"##1179"[2]
                                    var"##1180" isa AbstractArray
                                end && (length(var"##1180") === 2 && begin
                                        var"##1181" = var"##1180"[1]
                                        var"##1182" = var"##1180"[2]
                                        true
                                    end)))
                    rhs = var"##1182"
                    lhs = var"##1181"
                    var"##return#1074" = begin
                            leading_tab()
                            inline(lhs)
                            print(" = ")
                            p(rhs)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1075#1282")))
                end
                if begin
                            var"##1183" = (var"##cache#1077").value
                            var"##1183" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1183"[1] == :function && (begin
                                    var"##1184" = var"##1183"[2]
                                    var"##1184" isa AbstractArray
                                end && (length(var"##1184") === 2 && begin
                                        var"##1185" = var"##1184"[1]
                                        var"##1186" = var"##1184"[2]
                                        true
                                    end)))
                    call = var"##1185"
                    body = var"##1186"
                    var"##return#1074" = begin
                            print_function(:function, call, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1075#1282")))
                end
                if begin
                            var"##1187" = (var"##cache#1077").value
                            var"##1187" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1187"[1] == :-> && (begin
                                    var"##1188" = var"##1187"[2]
                                    var"##1188" isa AbstractArray
                                end && (length(var"##1188") === 2 && begin
                                        var"##1189" = var"##1188"[1]
                                        var"##1190" = var"##1188"[2]
                                        true
                                    end)))
                    call = var"##1189"
                    body = var"##1190"
                    var"##return#1074" = begin
                            leading_tab()
                            inline(call)
                            keyword(" -> ")
                            p(body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1075#1282")))
                end
                if begin
                            var"##1191" = (var"##cache#1077").value
                            var"##1191" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1191"[1] == :do && (begin
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
                                            end && (var"##1196"[1] == :-> && (begin
                                                        var"##1197" = var"##1196"[2]
                                                        var"##1197" isa AbstractArray
                                                    end && (length(var"##1197") === 2 && (begin
                                                                begin
                                                                    var"##cache#1199" = nothing
                                                                end
                                                                var"##1198" = var"##1197"[1]
                                                                var"##1198" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1199" === nothing
                                                                        var"##cache#1199" = Some(((var"##1198").head, (var"##1198").args))
                                                                    end
                                                                    var"##1200" = (var"##cache#1199").value
                                                                    var"##1200" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1200"[1] == :tuple && (begin
                                                                            var"##1201" = var"##1200"[2]
                                                                            var"##1201" isa AbstractArray
                                                                        end && ((ndims(var"##1201") === 1 && length(var"##1201") >= 0) && begin
                                                                                var"##1202" = SubArray(var"##1201", (1:length(var"##1201"),))
                                                                                var"##1203" = var"##1197"[2]
                                                                                true
                                                                            end)))))))))))))
                    call = var"##1193"
                    args = var"##1202"
                    body = var"##1203"
                    var"##return#1074" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1075#1282")))
                end
                if begin
                            var"##1204" = (var"##cache#1077").value
                            var"##1204" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1204"[1] == :macro && (begin
                                    var"##1205" = var"##1204"[2]
                                    var"##1205" isa AbstractArray
                                end && (length(var"##1205") === 2 && begin
                                        var"##1206" = var"##1205"[1]
                                        var"##1207" = var"##1205"[2]
                                        true
                                    end)))
                    call = var"##1206"
                    body = var"##1207"
                    var"##return#1074" = begin
                            print_function(:macro, call, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1075#1282")))
                end
                if begin
                            var"##1208" = (var"##cache#1077").value
                            var"##1208" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1208"[1] == :macrocall && (begin
                                    var"##1209" = var"##1208"[2]
                                    var"##1209" isa AbstractArray
                                end && (length(var"##1209") === 4 && (begin
                                            var"##1210" = var"##1209"[1]
                                            var"##1210" == Symbol("@switch")
                                        end && (begin
                                                var"##1211" = var"##1209"[2]
                                                var"##1212" = var"##1209"[3]
                                                begin
                                                    var"##cache#1214" = nothing
                                                end
                                                var"##1213" = var"##1209"[4]
                                                var"##1213" isa Expr
                                            end && (begin
                                                    if var"##cache#1214" === nothing
                                                        var"##cache#1214" = Some(((var"##1213").head, (var"##1213").args))
                                                    end
                                                    var"##1215" = (var"##cache#1214").value
                                                    var"##1215" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1215"[1] == :block && (begin
                                                            var"##1216" = var"##1215"[2]
                                                            var"##1216" isa AbstractArray
                                                        end && ((ndims(var"##1216") === 1 && length(var"##1216") >= 0) && begin
                                                                var"##1217" = SubArray(var"##1216", (1:length(var"##1216"),))
                                                                true
                                                            end)))))))))
                    item = var"##1212"
                    line = var"##1211"
                    stmts = var"##1217"
                    var"##return#1074" = begin
                            print_switch(item, line, stmts)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1075#1282")))
                end
                if begin
                            var"##1218" = (var"##cache#1077").value
                            var"##1218" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1218"[1] == :macrocall && (begin
                                    var"##1219" = var"##1218"[2]
                                    var"##1219" isa AbstractArray
                                end && (length(var"##1219") === 4 && (begin
                                            var"##1220" = var"##1219"[1]
                                            var"##1220" == GlobalRef(Core, Symbol("@doc"))
                                        end && begin
                                            var"##1221" = var"##1219"[2]
                                            var"##1222" = var"##1219"[3]
                                            var"##1223" = var"##1219"[4]
                                            true
                                        end))))
                    line = var"##1221"
                    code = var"##1223"
                    doc = var"##1222"
                    var"##return#1074" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1075#1282")))
                end
                if begin
                            var"##1224" = (var"##cache#1077").value
                            var"##1224" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1224"[1] == :macrocall && (begin
                                    var"##1225" = var"##1224"[2]
                                    var"##1225" isa AbstractArray
                                end && ((ndims(var"##1225") === 1 && length(var"##1225") >= 2) && begin
                                        var"##1226" = var"##1225"[1]
                                        var"##1227" = var"##1225"[2]
                                        var"##1228" = SubArray(var"##1225", (3:length(var"##1225"),))
                                        true
                                    end)))
                    line = var"##1227"
                    name = var"##1226"
                    args = var"##1228"
                    var"##return#1074" = begin
                            print_macrocall(name, line, args)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1075#1282")))
                end
                if begin
                            var"##1229" = (var"##cache#1077").value
                            var"##1229" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1229"[1] == :struct && (begin
                                    var"##1230" = var"##1229"[2]
                                    var"##1230" isa AbstractArray
                                end && (length(var"##1230") === 3 && begin
                                        var"##1231" = var"##1230"[1]
                                        var"##1232" = var"##1230"[2]
                                        var"##1233" = var"##1230"[3]
                                        true
                                    end)))
                    ismutable = var"##1231"
                    body = var"##1233"
                    head = var"##1232"
                    var"##return#1074" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1075#1282")))
                end
                if begin
                            var"##1234" = (var"##cache#1077").value
                            var"##1234" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1234"[1] == :try && (begin
                                    var"##1235" = var"##1234"[2]
                                    var"##1235" isa AbstractArray
                                end && (length(var"##1235") === 3 && begin
                                        var"##1236" = var"##1235"[1]
                                        var"##1237" = var"##1235"[2]
                                        var"##1238" = var"##1235"[3]
                                        true
                                    end)))
                    catch_vars = var"##1237"
                    catch_body = var"##1238"
                    try_body = var"##1236"
                    var"##return#1074" = begin
                            print_try(try_body)
                            print_catch(catch_body, catch_vars)
                            println()
                            tab()
                            keyword("end")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1075#1282")))
                end
                if begin
                            var"##1239" = (var"##cache#1077").value
                            var"##1239" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1239"[1] == :try && (begin
                                    var"##1240" = var"##1239"[2]
                                    var"##1240" isa AbstractArray
                                end && (length(var"##1240") === 4 && begin
                                        var"##1241" = var"##1240"[1]
                                        var"##1242" = var"##1240"[2]
                                        var"##1243" = var"##1240"[3]
                                        var"##1244" = var"##1240"[4]
                                        true
                                    end)))
                    catch_vars = var"##1242"
                    catch_body = var"##1243"
                    try_body = var"##1241"
                    finally_body = var"##1244"
                    var"##return#1074" = begin
                            print_try(try_body)
                            print_catch(catch_body, catch_vars)
                            print_finally(finally_body)
                            println()
                            tab()
                            keyword("end")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1075#1282")))
                end
                if begin
                            var"##1245" = (var"##cache#1077").value
                            var"##1245" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1245"[1] == :try && (begin
                                    var"##1246" = var"##1245"[2]
                                    var"##1246" isa AbstractArray
                                end && (length(var"##1246") === 5 && begin
                                        var"##1247" = var"##1246"[1]
                                        var"##1248" = var"##1246"[2]
                                        var"##1249" = var"##1246"[3]
                                        var"##1250" = var"##1246"[4]
                                        var"##1251" = var"##1246"[5]
                                        true
                                    end)))
                    catch_vars = var"##1248"
                    catch_body = var"##1249"
                    try_body = var"##1247"
                    finally_body = var"##1250"
                    else_body = var"##1251"
                    var"##return#1074" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1075#1282")))
                end
                if begin
                            var"##1252" = (var"##cache#1077").value
                            var"##1252" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1252"[1] == :module && (begin
                                    var"##1253" = var"##1252"[2]
                                    var"##1253" isa AbstractArray
                                end && (length(var"##1253") === 3 && begin
                                        var"##1254" = var"##1253"[1]
                                        var"##1255" = var"##1253"[2]
                                        var"##1256" = var"##1253"[3]
                                        true
                                    end)))
                    name = var"##1255"
                    body = var"##1256"
                    notbare = var"##1254"
                    var"##return#1074" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1075#1282")))
                end
                if begin
                            var"##1257" = (var"##cache#1077").value
                            var"##1257" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1257"[1] == :const && (begin
                                    var"##1258" = var"##1257"[2]
                                    var"##1258" isa AbstractArray
                                end && (length(var"##1258") === 1 && begin
                                        var"##1259" = var"##1258"[1]
                                        true
                                    end)))
                    code = var"##1259"
                    var"##return#1074" = begin
                            leading_tab()
                            keyword("const ")
                            p(code)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1075#1282")))
                end
                if begin
                            var"##1260" = (var"##cache#1077").value
                            var"##1260" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1260"[1] == :return && (begin
                                    var"##1261" = var"##1260"[2]
                                    var"##1261" isa AbstractArray
                                end && (length(var"##1261") === 1 && (begin
                                            begin
                                                var"##cache#1263" = nothing
                                            end
                                            var"##1262" = var"##1261"[1]
                                            var"##1262" isa Expr
                                        end && (begin
                                                if var"##cache#1263" === nothing
                                                    var"##cache#1263" = Some(((var"##1262").head, (var"##1262").args))
                                                end
                                                var"##1264" = (var"##cache#1263").value
                                                var"##1264" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1264"[1] == :tuple && (begin
                                                        var"##1265" = var"##1264"[2]
                                                        var"##1265" isa AbstractArray
                                                    end && ((ndims(var"##1265") === 1 && length(var"##1265") >= 1) && (begin
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
                                                                end && (var"##1268"[1] == :parameters && (begin
                                                                            var"##1269" = var"##1268"[2]
                                                                            var"##1269" isa AbstractArray
                                                                        end && (ndims(var"##1269") === 1 && length(var"##1269") >= 0)))))))))))))
                    var"##return#1074" = begin
                            inline(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1075#1282")))
                end
                if begin
                            var"##1270" = (var"##cache#1077").value
                            var"##1270" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1270"[1] == :return && (begin
                                    var"##1271" = var"##1270"[2]
                                    var"##1271" isa AbstractArray
                                end && (length(var"##1271") === 1 && (begin
                                            begin
                                                var"##cache#1273" = nothing
                                            end
                                            var"##1272" = var"##1271"[1]
                                            var"##1272" isa Expr
                                        end && (begin
                                                if var"##cache#1273" === nothing
                                                    var"##cache#1273" = Some(((var"##1272").head, (var"##1272").args))
                                                end
                                                var"##1274" = (var"##cache#1273").value
                                                var"##1274" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1274"[1] == :tuple && (begin
                                                        var"##1275" = var"##1274"[2]
                                                        var"##1275" isa AbstractArray
                                                    end && (ndims(var"##1275") === 1 && length(var"##1275") >= 0))))))))
                    var"##return#1074" = begin
                            inline(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1075#1282")))
                end
                if begin
                            var"##1276" = (var"##cache#1077").value
                            var"##1276" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1276"[1] == :return && (begin
                                    var"##1277" = var"##1276"[2]
                                    var"##1277" isa AbstractArray
                                end && (length(var"##1277") === 1 && begin
                                        var"##1278" = var"##1277"[1]
                                        true
                                    end)))
                    code = var"##1278"
                    var"##return#1074" = begin
                            leading_tab()
                            keyword("return ")
                            p(code)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1075#1282")))
                end
                if begin
                            var"##1279" = (var"##cache#1077").value
                            var"##1279" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1279"[1] == :toplevel && (begin
                                    var"##1280" = var"##1279"[2]
                                    var"##1280" isa AbstractArray
                                end && (length(var"##1280") === 1 && begin
                                        var"##1281" = var"##1280"[1]
                                        true
                                    end)))
                    code = var"##1281"
                    var"##return#1074" = begin
                            leading_tab()
                            printstyled("#= meta: toplevel =#", color = c.comment)
                            println()
                            p(code)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1075#1282")))
                end
            end
            begin
                var"##return#1074" = begin
                        inline(ex)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#1075#1282")))
            end
            error("matching non-exhaustive, at #= none:246 =#")
            $(Expr(:symboliclabel, Symbol("####final#1075#1282")))
            var"##return#1074"
        end
        return nothing
    end
    #= none:468 =# Core.@doc "    print_expr([io::IO], ex; kw...)\n\nPrint a given expression. `ex` can be a `Expr` or a syntax type `JLExpr`.\n" print_expr(io::IO, ex; kw...) = begin
                (Printer(io; kw...))(ex)
            end
    print_expr(ex; kw...) = begin
            print_expr(stdout, ex; kw...)
        end
