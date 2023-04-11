
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
                    var"##cache#1054" = nothing
                end
                var"##return#1051" = nothing
                var"##1053" = otherwise
                if var"##1053" isa Expr && (begin
                                if var"##cache#1054" === nothing
                                    var"##cache#1054" = Some(((var"##1053").head, (var"##1053").args))
                                end
                                var"##1055" = (var"##cache#1054").value
                                var"##1055" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1055"[1] == :block && (begin
                                        var"##1056" = var"##1055"[2]
                                        var"##1056" isa AbstractArray
                                    end && ((ndims(var"##1056") === 1 && length(var"##1056") >= 0) && begin
                                            var"##1057" = SubArray(var"##1056", (1:length(var"##1056"),))
                                            true
                                        end))))
                    var"##return#1051" = let stmts = var"##1057"
                            indent() do 
                                print_stmts(stmts)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1052#1058")))
                end
                begin
                    var"##return#1051" = let
                            indent() do 
                                tab()
                                no_first_line_indent() do 
                                    p(otherwise)
                                end
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1052#1058")))
                end
                error("matching non-exhaustive, at #= none:98 =#")
                $(Expr(:symboliclabel, Symbol("####final#1052#1058")))
                var"##return#1051"
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
                            var"##cache#1062" = nothing
                        end
                        var"##return#1059" = nothing
                        var"##1061" = stmt
                        if var"##1061" isa Expr && (begin
                                        if var"##cache#1062" === nothing
                                            var"##cache#1062" = Some(((var"##1061").head, (var"##1061").args))
                                        end
                                        var"##1063" = (var"##cache#1062").value
                                        var"##1063" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##1063"[1] == :macrocall && (begin
                                                var"##1064" = var"##1063"[2]
                                                var"##1064" isa AbstractArray
                                            end && ((ndims(var"##1064") === 1 && length(var"##1064") >= 1) && begin
                                                    var"##1065" = var"##1064"[1]
                                                    var"##1065" == Symbol("@case")
                                                end))))
                            var"##return#1059" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1060#1066")))
                        end
                        begin
                            var"##return#1059" = let
                                    false
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1060#1066")))
                        end
                        error("matching non-exhaustive, at #= none:181 =#")
                        $(Expr(:symboliclabel, Symbol("####final#1060#1066")))
                        var"##return#1059"
                    end
                end || return print_macrocall("@switch", line, (item, Expr(:block, stmts...)))
            is_case(stmt) = begin
                    let
                        begin
                            var"##cache#1070" = nothing
                        end
                        var"##return#1067" = nothing
                        var"##1069" = stmt
                        if var"##1069" isa Expr && (begin
                                        if var"##cache#1070" === nothing
                                            var"##cache#1070" = Some(((var"##1069").head, (var"##1069").args))
                                        end
                                        var"##1071" = (var"##cache#1070").value
                                        var"##1071" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##1071"[1] == :macrocall && (begin
                                                var"##1072" = var"##1071"[2]
                                                var"##1072" isa AbstractArray
                                            end && ((ndims(var"##1072") === 1 && length(var"##1072") >= 1) && begin
                                                    var"##1073" = var"##1072"[1]
                                                    var"##1073" == Symbol("@case")
                                                end))))
                            var"##return#1067" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1068#1074")))
                        end
                        begin
                            var"##return#1067" = let
                                    false
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1068#1074")))
                        end
                        error("matching non-exhaustive, at #= none:187 =#")
                        $(Expr(:symboliclabel, Symbol("####final#1068#1074")))
                        var"##return#1067"
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
                            var"##cache#1078" = nothing
                        end
                        var"##return#1075" = nothing
                        var"##1077" = stmt
                        if var"##1077" isa Expr && (begin
                                        if var"##cache#1078" === nothing
                                            var"##cache#1078" = Some(((var"##1077").head, (var"##1077").args))
                                        end
                                        var"##1079" = (var"##cache#1078").value
                                        var"##1079" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##1079"[1] == :macrocall && (begin
                                                var"##1080" = var"##1079"[2]
                                                var"##1080" isa AbstractArray
                                            end && (length(var"##1080") === 3 && (begin
                                                        var"##1081" = var"##1080"[1]
                                                        var"##1081" == Symbol("@case")
                                                    end && begin
                                                        var"##1082" = var"##1080"[2]
                                                        var"##1083" = var"##1080"[3]
                                                        true
                                                    end)))))
                            var"##return#1075" = let pattern = var"##1083", line = var"##1082"
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
                            $(Expr(:symbolicgoto, Symbol("####final#1076#1084")))
                        end
                        begin
                            var"##return#1075" = let
                                    p(stmt)
                                    println()
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1076#1084")))
                        end
                        error("matching non-exhaustive, at #= none:197 =#")
                        $(Expr(:symboliclabel, Symbol("####final#1076#1084")))
                        var"##return#1075"
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
                var"##cache#1088" = nothing
            end
            var"##1087" = ex
            if var"##1087" isa Expr
                if begin
                            if var"##cache#1088" === nothing
                                var"##cache#1088" = Some(((var"##1087").head, (var"##1087").args))
                            end
                            var"##1089" = (var"##cache#1088").value
                            var"##1089" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1089"[1] == :string && (begin
                                    var"##1090" = var"##1089"[2]
                                    var"##1090" isa AbstractArray
                                end && ((ndims(var"##1090") === 1 && length(var"##1090") >= 0) && begin
                                        var"##1091" = SubArray(var"##1090", (1:length(var"##1090"),))
                                        true
                                    end)))
                    args = var"##1091"
                    var"##return#1085" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1086#1290")))
                end
                if begin
                            var"##1092" = (var"##cache#1088").value
                            var"##1092" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1092"[1] == :block && (begin
                                    var"##1093" = var"##1092"[2]
                                    var"##1093" isa AbstractArray
                                end && ((ndims(var"##1093") === 1 && length(var"##1093") >= 0) && begin
                                        var"##1094" = SubArray(var"##1093", (1:length(var"##1093"),))
                                        true
                                    end)))
                    stmts = var"##1094"
                    var"##return#1085" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1086#1290")))
                end
                if begin
                            var"##1095" = (var"##cache#1088").value
                            var"##1095" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1095"[1] == :quote && (begin
                                    var"##1096" = var"##1095"[2]
                                    var"##1096" isa AbstractArray
                                end && (length(var"##1096") === 1 && (begin
                                            begin
                                                var"##cache#1098" = nothing
                                            end
                                            var"##1097" = var"##1096"[1]
                                            var"##1097" isa Expr
                                        end && (begin
                                                if var"##cache#1098" === nothing
                                                    var"##cache#1098" = Some(((var"##1097").head, (var"##1097").args))
                                                end
                                                var"##1099" = (var"##cache#1098").value
                                                var"##1099" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1099"[1] == :block && (begin
                                                        var"##1100" = var"##1099"[2]
                                                        var"##1100" isa AbstractArray
                                                    end && ((ndims(var"##1100") === 1 && length(var"##1100") >= 0) && begin
                                                            var"##1101" = SubArray(var"##1100", (1:length(var"##1100"),))
                                                            let stmts = var"##1101"
                                                                is_root()
                                                            end
                                                        end))))))))
                    stmts = var"##1101"
                    var"##return#1085" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1086#1290")))
                end
                if begin
                            var"##1102" = (var"##cache#1088").value
                            var"##1102" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1102"[1] == :quote && (begin
                                    var"##1103" = var"##1102"[2]
                                    var"##1103" isa AbstractArray
                                end && (length(var"##1103") === 1 && (begin
                                            begin
                                                var"##cache#1105" = nothing
                                            end
                                            var"##1104" = var"##1103"[1]
                                            var"##1104" isa Expr
                                        end && (begin
                                                if var"##cache#1105" === nothing
                                                    var"##cache#1105" = Some(((var"##1104").head, (var"##1104").args))
                                                end
                                                var"##1106" = (var"##cache#1105").value
                                                var"##1106" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1106"[1] == :block && (begin
                                                        var"##1107" = var"##1106"[2]
                                                        var"##1107" isa AbstractArray
                                                    end && ((ndims(var"##1107") === 1 && length(var"##1107") >= 0) && begin
                                                            var"##1108" = SubArray(var"##1107", (1:length(var"##1107"),))
                                                            true
                                                        end))))))))
                    stmts = var"##1108"
                    var"##return#1085" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1086#1290")))
                end
                if begin
                            var"##1109" = (var"##cache#1088").value
                            var"##1109" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1109"[1] == :quote && (begin
                                    var"##1110" = var"##1109"[2]
                                    var"##1110" isa AbstractArray
                                end && (length(var"##1110") === 1 && begin
                                        var"##1111" = var"##1110"[1]
                                        true
                                    end)))
                    code = var"##1111"
                    var"##return#1085" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1086#1290")))
                end
                if begin
                            var"##1112" = (var"##cache#1088").value
                            var"##1112" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1112"[1] == :let && (begin
                                    var"##1113" = var"##1112"[2]
                                    var"##1113" isa AbstractArray
                                end && (length(var"##1113") === 2 && (begin
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
                                                    end && ((ndims(var"##1117") === 1 && length(var"##1117") >= 0) && (begin
                                                                var"##1118" = SubArray(var"##1117", (1:length(var"##1117"),))
                                                                begin
                                                                    var"##cache#1120" = nothing
                                                                end
                                                                var"##1119" = var"##1113"[2]
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
                                                                            end)))))))))))))
                    args = var"##1118"
                    stmts = var"##1123"
                    var"##return#1085" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1086#1290")))
                end
                if begin
                            var"##1124" = (var"##cache#1088").value
                            var"##1124" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1124"[1] == :if && (begin
                                    var"##1125" = var"##1124"[2]
                                    var"##1125" isa AbstractArray
                                end && (length(var"##1125") === 2 && begin
                                        var"##1126" = var"##1125"[1]
                                        var"##1127" = var"##1125"[2]
                                        true
                                    end)))
                    cond = var"##1126"
                    body = var"##1127"
                    var"##return#1085" = begin
                            print_if(cond, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1086#1290")))
                end
                if begin
                            var"##1128" = (var"##cache#1088").value
                            var"##1128" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1128"[1] == :if && (begin
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
                    var"##return#1085" = begin
                            print_if(cond, body, otherwise)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1086#1290")))
                end
                if begin
                            var"##1133" = (var"##cache#1088").value
                            var"##1133" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1133"[1] == :elseif && (begin
                                    var"##1134" = var"##1133"[2]
                                    var"##1134" isa AbstractArray
                                end && (length(var"##1134") === 2 && (begin
                                            begin
                                                var"##cache#1136" = nothing
                                            end
                                            var"##1135" = var"##1134"[1]
                                            var"##1135" isa Expr
                                        end && (begin
                                                if var"##cache#1136" === nothing
                                                    var"##cache#1136" = Some(((var"##1135").head, (var"##1135").args))
                                                end
                                                var"##1137" = (var"##cache#1136").value
                                                var"##1137" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1137"[1] == :block && (begin
                                                        var"##1138" = var"##1137"[2]
                                                        var"##1138" isa AbstractArray
                                                    end && (length(var"##1138") === 2 && begin
                                                            var"##1139" = var"##1138"[1]
                                                            var"##1140" = var"##1138"[2]
                                                            var"##1141" = var"##1134"[2]
                                                            true
                                                        end))))))))
                    line = var"##1139"
                    cond = var"##1140"
                    body = var"##1141"
                    var"##return#1085" = begin
                            print_elseif(cond, body, line)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1086#1290")))
                end
                if begin
                            var"##1142" = (var"##cache#1088").value
                            var"##1142" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1142"[1] == :elseif && (begin
                                    var"##1143" = var"##1142"[2]
                                    var"##1143" isa AbstractArray
                                end && (length(var"##1143") === 2 && begin
                                        var"##1144" = var"##1143"[1]
                                        var"##1145" = var"##1143"[2]
                                        true
                                    end)))
                    cond = var"##1144"
                    body = var"##1145"
                    var"##return#1085" = begin
                            print_elseif(cond, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1086#1290")))
                end
                if begin
                            var"##1146" = (var"##cache#1088").value
                            var"##1146" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1146"[1] == :elseif && (begin
                                    var"##1147" = var"##1146"[2]
                                    var"##1147" isa AbstractArray
                                end && (length(var"##1147") === 3 && (begin
                                            begin
                                                var"##cache#1149" = nothing
                                            end
                                            var"##1148" = var"##1147"[1]
                                            var"##1148" isa Expr
                                        end && (begin
                                                if var"##cache#1149" === nothing
                                                    var"##cache#1149" = Some(((var"##1148").head, (var"##1148").args))
                                                end
                                                var"##1150" = (var"##cache#1149").value
                                                var"##1150" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1150"[1] == :block && (begin
                                                        var"##1151" = var"##1150"[2]
                                                        var"##1151" isa AbstractArray
                                                    end && (length(var"##1151") === 2 && begin
                                                            var"##1152" = var"##1151"[1]
                                                            var"##1153" = var"##1151"[2]
                                                            var"##1154" = var"##1147"[2]
                                                            var"##1155" = var"##1147"[3]
                                                            true
                                                        end))))))))
                    line = var"##1152"
                    cond = var"##1153"
                    body = var"##1154"
                    otherwise = var"##1155"
                    var"##return#1085" = begin
                            print_elseif(cond, body, line, otherwise)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1086#1290")))
                end
                if begin
                            var"##1156" = (var"##cache#1088").value
                            var"##1156" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1156"[1] == :elseif && (begin
                                    var"##1157" = var"##1156"[2]
                                    var"##1157" isa AbstractArray
                                end && (length(var"##1157") === 3 && begin
                                        var"##1158" = var"##1157"[1]
                                        var"##1159" = var"##1157"[2]
                                        var"##1160" = var"##1157"[3]
                                        true
                                    end)))
                    cond = var"##1158"
                    body = var"##1159"
                    otherwise = var"##1160"
                    var"##return#1085" = begin
                            print_elseif(cond, body, nothing, otherwise)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1086#1290")))
                end
                if begin
                            var"##1161" = (var"##cache#1088").value
                            var"##1161" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1161"[1] == :for && (begin
                                    var"##1162" = var"##1161"[2]
                                    var"##1162" isa AbstractArray
                                end && (length(var"##1162") === 2 && begin
                                        var"##1163" = var"##1162"[1]
                                        var"##1164" = var"##1162"[2]
                                        true
                                    end)))
                    body = var"##1164"
                    iteration = var"##1163"
                    var"##return#1085" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1086#1290")))
                end
                if begin
                            var"##1165" = (var"##cache#1088").value
                            var"##1165" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1165"[1] == :while && (begin
                                    var"##1166" = var"##1165"[2]
                                    var"##1166" isa AbstractArray
                                end && (length(var"##1166") === 2 && begin
                                        var"##1167" = var"##1166"[1]
                                        var"##1168" = var"##1166"[2]
                                        true
                                    end)))
                    cond = var"##1167"
                    body = var"##1168"
                    var"##return#1085" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1086#1290")))
                end
                if begin
                            var"##1169" = (var"##cache#1088").value
                            var"##1169" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1169"[1] == :(=) && (begin
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
                                            end && (var"##1174"[1] == :block && (begin
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
                                                                end && (var"##1179"[1] == :if && (begin
                                                                            var"##1180" = var"##1179"[2]
                                                                            var"##1180" isa AbstractArray
                                                                        end && ((ndims(var"##1180") === 1 && length(var"##1180") >= 0) && let line = var"##1176", lhs = var"##1171"
                                                                                is_line_no(line)
                                                                            end)))))))))))))
                    line = var"##1176"
                    lhs = var"##1171"
                    var"##return#1085" = begin
                            leading_tab()
                            inline(lhs)
                            keyword(" = ")
                            inline(line)
                            p(ex.args[2])
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1086#1290")))
                end
                if begin
                            var"##1181" = (var"##cache#1088").value
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
                                                    end && (length(var"##1187") === 2 && begin
                                                            var"##1188" = var"##1187"[1]
                                                            var"##1189" = var"##1187"[2]
                                                            let rhs = var"##1189", line = var"##1188", lhs = var"##1183"
                                                                is_line_no(line)
                                                            end
                                                        end))))))))
                    rhs = var"##1189"
                    line = var"##1188"
                    lhs = var"##1183"
                    var"##return#1085" = begin
                            leading_tab()
                            inline(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1086#1290")))
                end
                if begin
                            var"##1190" = (var"##cache#1088").value
                            var"##1190" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1190"[1] == :(=) && (begin
                                    var"##1191" = var"##1190"[2]
                                    var"##1191" isa AbstractArray
                                end && (length(var"##1191") === 2 && begin
                                        var"##1192" = var"##1191"[1]
                                        var"##1193" = var"##1191"[2]
                                        true
                                    end)))
                    rhs = var"##1193"
                    lhs = var"##1192"
                    var"##return#1085" = begin
                            leading_tab()
                            inline(lhs)
                            print(" = ")
                            p(rhs)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1086#1290")))
                end
                if begin
                            var"##1194" = (var"##cache#1088").value
                            var"##1194" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1194"[1] == :function && (begin
                                    var"##1195" = var"##1194"[2]
                                    var"##1195" isa AbstractArray
                                end && (length(var"##1195") === 2 && begin
                                        var"##1196" = var"##1195"[1]
                                        var"##1197" = var"##1195"[2]
                                        true
                                    end)))
                    call = var"##1196"
                    body = var"##1197"
                    var"##return#1085" = begin
                            print_function(:function, call, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1086#1290")))
                end
                if begin
                            var"##1198" = (var"##cache#1088").value
                            var"##1198" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1198"[1] == :-> && (begin
                                    var"##1199" = var"##1198"[2]
                                    var"##1199" isa AbstractArray
                                end && (length(var"##1199") === 2 && begin
                                        var"##1200" = var"##1199"[1]
                                        var"##1201" = var"##1199"[2]
                                        true
                                    end)))
                    call = var"##1200"
                    body = var"##1201"
                    var"##return#1085" = begin
                            leading_tab()
                            inline(call)
                            keyword(" -> ")
                            p(body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1086#1290")))
                end
                if begin
                            var"##1202" = (var"##cache#1088").value
                            var"##1202" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1202"[1] == :do && (begin
                                    var"##1203" = var"##1202"[2]
                                    var"##1203" isa AbstractArray
                                end && (length(var"##1203") === 2 && (begin
                                            var"##1204" = var"##1203"[1]
                                            begin
                                                var"##cache#1206" = nothing
                                            end
                                            var"##1205" = var"##1203"[2]
                                            var"##1205" isa Expr
                                        end && (begin
                                                if var"##cache#1206" === nothing
                                                    var"##cache#1206" = Some(((var"##1205").head, (var"##1205").args))
                                                end
                                                var"##1207" = (var"##cache#1206").value
                                                var"##1207" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1207"[1] == :-> && (begin
                                                        var"##1208" = var"##1207"[2]
                                                        var"##1208" isa AbstractArray
                                                    end && (length(var"##1208") === 2 && (begin
                                                                begin
                                                                    var"##cache#1210" = nothing
                                                                end
                                                                var"##1209" = var"##1208"[1]
                                                                var"##1209" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1210" === nothing
                                                                        var"##cache#1210" = Some(((var"##1209").head, (var"##1209").args))
                                                                    end
                                                                    var"##1211" = (var"##cache#1210").value
                                                                    var"##1211" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1211"[1] == :tuple && (begin
                                                                            var"##1212" = var"##1211"[2]
                                                                            var"##1212" isa AbstractArray
                                                                        end && ((ndims(var"##1212") === 1 && length(var"##1212") >= 0) && begin
                                                                                var"##1213" = SubArray(var"##1212", (1:length(var"##1212"),))
                                                                                var"##1214" = var"##1208"[2]
                                                                                true
                                                                            end)))))))))))))
                    call = var"##1204"
                    args = var"##1213"
                    body = var"##1214"
                    var"##return#1085" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1086#1290")))
                end
                if begin
                            var"##1215" = (var"##cache#1088").value
                            var"##1215" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1215"[1] == :macro && (begin
                                    var"##1216" = var"##1215"[2]
                                    var"##1216" isa AbstractArray
                                end && (length(var"##1216") === 2 && begin
                                        var"##1217" = var"##1216"[1]
                                        var"##1218" = var"##1216"[2]
                                        true
                                    end)))
                    call = var"##1217"
                    body = var"##1218"
                    var"##return#1085" = begin
                            print_function(:macro, call, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1086#1290")))
                end
                if begin
                            var"##1219" = (var"##cache#1088").value
                            var"##1219" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1219"[1] == :macrocall && (begin
                                    var"##1220" = var"##1219"[2]
                                    var"##1220" isa AbstractArray
                                end && (length(var"##1220") === 4 && (begin
                                            var"##1221" = var"##1220"[1]
                                            var"##1221" == Symbol("@switch")
                                        end && (begin
                                                var"##1222" = var"##1220"[2]
                                                var"##1223" = var"##1220"[3]
                                                begin
                                                    var"##cache#1225" = nothing
                                                end
                                                var"##1224" = var"##1220"[4]
                                                var"##1224" isa Expr
                                            end && (begin
                                                    if var"##cache#1225" === nothing
                                                        var"##cache#1225" = Some(((var"##1224").head, (var"##1224").args))
                                                    end
                                                    var"##1226" = (var"##cache#1225").value
                                                    var"##1226" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1226"[1] == :block && (begin
                                                            var"##1227" = var"##1226"[2]
                                                            var"##1227" isa AbstractArray
                                                        end && ((ndims(var"##1227") === 1 && length(var"##1227") >= 0) && begin
                                                                var"##1228" = SubArray(var"##1227", (1:length(var"##1227"),))
                                                                true
                                                            end)))))))))
                    item = var"##1223"
                    line = var"##1222"
                    stmts = var"##1228"
                    var"##return#1085" = begin
                            print_switch(item, line, stmts)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1086#1290")))
                end
                if begin
                            var"##1229" = (var"##cache#1088").value
                            var"##1229" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1229"[1] == :macrocall && (begin
                                    var"##1230" = var"##1229"[2]
                                    var"##1230" isa AbstractArray
                                end && (length(var"##1230") === 4 && (begin
                                            var"##1231" = var"##1230"[1]
                                            var"##1231" == GlobalRef(Core, Symbol("@doc"))
                                        end && begin
                                            var"##1232" = var"##1230"[2]
                                            var"##1233" = var"##1230"[3]
                                            var"##1234" = var"##1230"[4]
                                            true
                                        end))))
                    line = var"##1232"
                    code = var"##1234"
                    doc = var"##1233"
                    var"##return#1085" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1086#1290")))
                end
                if begin
                            var"##1235" = (var"##cache#1088").value
                            var"##1235" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1235"[1] == :macrocall && (begin
                                    var"##1236" = var"##1235"[2]
                                    var"##1236" isa AbstractArray
                                end && ((ndims(var"##1236") === 1 && length(var"##1236") >= 2) && begin
                                        var"##1237" = var"##1236"[1]
                                        var"##1238" = var"##1236"[2]
                                        var"##1239" = SubArray(var"##1236", (3:length(var"##1236"),))
                                        true
                                    end)))
                    line = var"##1238"
                    name = var"##1237"
                    args = var"##1239"
                    var"##return#1085" = begin
                            print_macrocall(name, line, args)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1086#1290")))
                end
                if begin
                            var"##1240" = (var"##cache#1088").value
                            var"##1240" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1240"[1] == :struct && (begin
                                    var"##1241" = var"##1240"[2]
                                    var"##1241" isa AbstractArray
                                end && (length(var"##1241") === 3 && begin
                                        var"##1242" = var"##1241"[1]
                                        var"##1243" = var"##1241"[2]
                                        var"##1244" = var"##1241"[3]
                                        true
                                    end)))
                    ismutable = var"##1242"
                    body = var"##1244"
                    head = var"##1243"
                    var"##return#1085" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1086#1290")))
                end
                if begin
                            var"##1245" = (var"##cache#1088").value
                            var"##1245" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1245"[1] == :try && (begin
                                    var"##1246" = var"##1245"[2]
                                    var"##1246" isa AbstractArray
                                end && (length(var"##1246") === 3 && begin
                                        var"##1247" = var"##1246"[1]
                                        var"##1248" = var"##1246"[2]
                                        var"##1249" = var"##1246"[3]
                                        true
                                    end)))
                    catch_vars = var"##1248"
                    catch_body = var"##1249"
                    try_body = var"##1247"
                    var"##return#1085" = begin
                            print_try(try_body)
                            print_catch(catch_body, catch_vars)
                            println()
                            tab()
                            keyword("end")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1086#1290")))
                end
                if begin
                            var"##1250" = (var"##cache#1088").value
                            var"##1250" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1250"[1] == :try && (begin
                                    var"##1251" = var"##1250"[2]
                                    var"##1251" isa AbstractArray
                                end && (length(var"##1251") === 4 && begin
                                        var"##1252" = var"##1251"[1]
                                        var"##1253" = var"##1251"[2]
                                        var"##1254" = var"##1251"[3]
                                        var"##1255" = var"##1251"[4]
                                        true
                                    end)))
                    catch_vars = var"##1253"
                    catch_body = var"##1254"
                    try_body = var"##1252"
                    finally_body = var"##1255"
                    var"##return#1085" = begin
                            print_try(try_body)
                            print_catch(catch_body, catch_vars)
                            print_finally(finally_body)
                            println()
                            tab()
                            keyword("end")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1086#1290")))
                end
                if begin
                            var"##1256" = (var"##cache#1088").value
                            var"##1256" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1256"[1] == :try && (begin
                                    var"##1257" = var"##1256"[2]
                                    var"##1257" isa AbstractArray
                                end && (length(var"##1257") === 5 && begin
                                        var"##1258" = var"##1257"[1]
                                        var"##1259" = var"##1257"[2]
                                        var"##1260" = var"##1257"[3]
                                        var"##1261" = var"##1257"[4]
                                        var"##1262" = var"##1257"[5]
                                        true
                                    end)))
                    catch_vars = var"##1259"
                    catch_body = var"##1260"
                    try_body = var"##1258"
                    finally_body = var"##1261"
                    else_body = var"##1262"
                    var"##return#1085" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1086#1290")))
                end
                if begin
                            var"##1263" = (var"##cache#1088").value
                            var"##1263" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1263"[1] == :module && (begin
                                    var"##1264" = var"##1263"[2]
                                    var"##1264" isa AbstractArray
                                end && (length(var"##1264") === 3 && begin
                                        var"##1265" = var"##1264"[1]
                                        var"##1266" = var"##1264"[2]
                                        var"##1267" = var"##1264"[3]
                                        true
                                    end)))
                    name = var"##1266"
                    body = var"##1267"
                    notbare = var"##1265"
                    var"##return#1085" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1086#1290")))
                end
                if begin
                            var"##1268" = (var"##cache#1088").value
                            var"##1268" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1268"[1] == :const && (begin
                                    var"##1269" = var"##1268"[2]
                                    var"##1269" isa AbstractArray
                                end && (length(var"##1269") === 1 && begin
                                        var"##1270" = var"##1269"[1]
                                        true
                                    end)))
                    code = var"##1270"
                    var"##return#1085" = begin
                            leading_tab()
                            keyword("const ")
                            p(code)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1086#1290")))
                end
                if begin
                            var"##1271" = (var"##cache#1088").value
                            var"##1271" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1271"[1] == :return && (begin
                                    var"##1272" = var"##1271"[2]
                                    var"##1272" isa AbstractArray
                                end && (length(var"##1272") === 1 && (begin
                                            begin
                                                var"##cache#1274" = nothing
                                            end
                                            var"##1273" = var"##1272"[1]
                                            var"##1273" isa Expr
                                        end && (begin
                                                if var"##cache#1274" === nothing
                                                    var"##cache#1274" = Some(((var"##1273").head, (var"##1273").args))
                                                end
                                                var"##1275" = (var"##cache#1274").value
                                                var"##1275" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1275"[1] == :tuple && (begin
                                                        var"##1276" = var"##1275"[2]
                                                        var"##1276" isa AbstractArray
                                                    end && ((ndims(var"##1276") === 1 && length(var"##1276") >= 1) && (begin
                                                                begin
                                                                    var"##cache#1278" = nothing
                                                                end
                                                                var"##1277" = var"##1276"[1]
                                                                var"##1277" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1278" === nothing
                                                                        var"##cache#1278" = Some(((var"##1277").head, (var"##1277").args))
                                                                    end
                                                                    var"##1279" = (var"##cache#1278").value
                                                                    var"##1279" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1279"[1] == :parameters && (begin
                                                                            var"##1280" = var"##1279"[2]
                                                                            var"##1280" isa AbstractArray
                                                                        end && (ndims(var"##1280") === 1 && length(var"##1280") >= 0)))))))))))))
                    var"##return#1085" = begin
                            inline(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1086#1290")))
                end
                if begin
                            var"##1281" = (var"##cache#1088").value
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
                                                    end && (ndims(var"##1286") === 1 && length(var"##1286") >= 0))))))))
                    var"##return#1085" = begin
                            inline(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1086#1290")))
                end
                if begin
                            var"##1287" = (var"##cache#1088").value
                            var"##1287" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1287"[1] == :return && (begin
                                    var"##1288" = var"##1287"[2]
                                    var"##1288" isa AbstractArray
                                end && (length(var"##1288") === 1 && begin
                                        var"##1289" = var"##1288"[1]
                                        true
                                    end)))
                    code = var"##1289"
                    var"##return#1085" = begin
                            leading_tab()
                            keyword("return ")
                            p(code)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1086#1290")))
                end
            end
            if var"##1087" isa String
                begin
                    var"##return#1085" = begin
                            leading_tab()
                            occursin('\n', ex) || return inline(ex)
                            printstyled("\"\"\"\n", color = c.string)
                            tab()
                            print_multi_lines(ex)
                            printstyled("\"\"\"", color = c.string)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1086#1290")))
                end
            end
            begin
                var"##return#1085" = begin
                        inline(ex)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#1086#1290")))
            end
            error("matching non-exhaustive, at #= none:246 =#")
            $(Expr(:symboliclabel, Symbol("####final#1086#1290")))
            var"##return#1085"
        end
        return nothing
    end
    #= none:464 =# Core.@doc "    print_expr([io::IO], ex; kw...)\n\nPrint a given expression. `ex` can be a `Expr` or a syntax type `JLExpr`.\n" print_expr(io::IO, ex; kw...) = begin
                (Printer(io; kw...))(ex)
            end
    print_expr(ex; kw...) = begin
            print_expr(stdout, ex; kw...)
        end
