
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
                    var"##cache#1044" = nothing
                end
                var"##return#1041" = nothing
                var"##1043" = otherwise
                if var"##1043" isa Expr && (begin
                                if var"##cache#1044" === nothing
                                    var"##cache#1044" = Some(((var"##1043").head, (var"##1043").args))
                                end
                                var"##1045" = (var"##cache#1044").value
                                var"##1045" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##1045"[1] == :block && (begin
                                        var"##1046" = var"##1045"[2]
                                        var"##1046" isa AbstractArray
                                    end && ((ndims(var"##1046") === 1 && length(var"##1046") >= 0) && begin
                                            var"##1047" = SubArray(var"##1046", (1:length(var"##1046"),))
                                            true
                                        end))))
                    var"##return#1041" = let stmts = var"##1047"
                            indent() do 
                                print_stmts(stmts)
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1042#1048")))
                end
                begin
                    var"##return#1041" = let
                            indent() do 
                                tab()
                                no_first_line_indent() do 
                                    p(otherwise)
                                end
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1042#1048")))
                end
                error("matching non-exhaustive, at #= none:98 =#")
                $(Expr(:symboliclabel, Symbol("####final#1042#1048")))
                var"##return#1041"
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
                            var"##cache#1052" = nothing
                        end
                        var"##return#1049" = nothing
                        var"##1051" = stmt
                        if var"##1051" isa Expr && (begin
                                        if var"##cache#1052" === nothing
                                            var"##cache#1052" = Some(((var"##1051").head, (var"##1051").args))
                                        end
                                        var"##1053" = (var"##cache#1052").value
                                        var"##1053" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##1053"[1] == :macrocall && (begin
                                                var"##1054" = var"##1053"[2]
                                                var"##1054" isa AbstractArray
                                            end && ((ndims(var"##1054") === 1 && length(var"##1054") >= 1) && begin
                                                    var"##1055" = var"##1054"[1]
                                                    var"##1055" == Symbol("@case")
                                                end))))
                            var"##return#1049" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1050#1056")))
                        end
                        begin
                            var"##return#1049" = let
                                    false
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1050#1056")))
                        end
                        error("matching non-exhaustive, at #= none:181 =#")
                        $(Expr(:symboliclabel, Symbol("####final#1050#1056")))
                        var"##return#1049"
                    end
                end || return print_macrocall("@switch", line, (item, Expr(:block, stmts...)))
            is_case(stmt) = begin
                    let
                        begin
                            var"##cache#1060" = nothing
                        end
                        var"##return#1057" = nothing
                        var"##1059" = stmt
                        if var"##1059" isa Expr && (begin
                                        if var"##cache#1060" === nothing
                                            var"##cache#1060" = Some(((var"##1059").head, (var"##1059").args))
                                        end
                                        var"##1061" = (var"##cache#1060").value
                                        var"##1061" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##1061"[1] == :macrocall && (begin
                                                var"##1062" = var"##1061"[2]
                                                var"##1062" isa AbstractArray
                                            end && ((ndims(var"##1062") === 1 && length(var"##1062") >= 1) && begin
                                                    var"##1063" = var"##1062"[1]
                                                    var"##1063" == Symbol("@case")
                                                end))))
                            var"##return#1057" = let
                                    true
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1058#1064")))
                        end
                        begin
                            var"##return#1057" = let
                                    false
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1058#1064")))
                        end
                        error("matching non-exhaustive, at #= none:187 =#")
                        $(Expr(:symboliclabel, Symbol("####final#1058#1064")))
                        var"##return#1057"
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
                            var"##cache#1068" = nothing
                        end
                        var"##return#1065" = nothing
                        var"##1067" = stmt
                        if var"##1067" isa Expr && (begin
                                        if var"##cache#1068" === nothing
                                            var"##cache#1068" = Some(((var"##1067").head, (var"##1067").args))
                                        end
                                        var"##1069" = (var"##cache#1068").value
                                        var"##1069" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                    end && (var"##1069"[1] == :macrocall && (begin
                                                var"##1070" = var"##1069"[2]
                                                var"##1070" isa AbstractArray
                                            end && (length(var"##1070") === 3 && (begin
                                                        var"##1071" = var"##1070"[1]
                                                        var"##1071" == Symbol("@case")
                                                    end && begin
                                                        var"##1072" = var"##1070"[2]
                                                        var"##1073" = var"##1070"[3]
                                                        true
                                                    end)))))
                            var"##return#1065" = let pattern = var"##1073", line = var"##1072"
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
                            $(Expr(:symbolicgoto, Symbol("####final#1066#1074")))
                        end
                        begin
                            var"##return#1065" = let
                                    p(stmt)
                                    println()
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#1066#1074")))
                        end
                        error("matching non-exhaustive, at #= none:197 =#")
                        $(Expr(:symboliclabel, Symbol("####final#1066#1074")))
                        var"##return#1065"
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
                var"##cache#1078" = nothing
            end
            var"##1077" = ex
            if var"##1077" isa Expr
                if begin
                            if var"##cache#1078" === nothing
                                var"##cache#1078" = Some(((var"##1077").head, (var"##1077").args))
                            end
                            var"##1079" = (var"##cache#1078").value
                            var"##1079" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1079"[1] == :string && (begin
                                    var"##1080" = var"##1079"[2]
                                    var"##1080" isa AbstractArray
                                end && ((ndims(var"##1080") === 1 && length(var"##1080") >= 0) && begin
                                        var"##1081" = SubArray(var"##1080", (1:length(var"##1080"),))
                                        true
                                    end)))
                    args = var"##1081"
                    var"##return#1075" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1076#1280")))
                end
                if begin
                            var"##1082" = (var"##cache#1078").value
                            var"##1082" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1082"[1] == :block && (begin
                                    var"##1083" = var"##1082"[2]
                                    var"##1083" isa AbstractArray
                                end && ((ndims(var"##1083") === 1 && length(var"##1083") >= 0) && begin
                                        var"##1084" = SubArray(var"##1083", (1:length(var"##1083"),))
                                        true
                                    end)))
                    stmts = var"##1084"
                    var"##return#1075" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1076#1280")))
                end
                if begin
                            var"##1085" = (var"##cache#1078").value
                            var"##1085" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1085"[1] == :quote && (begin
                                    var"##1086" = var"##1085"[2]
                                    var"##1086" isa AbstractArray
                                end && (length(var"##1086") === 1 && (begin
                                            begin
                                                var"##cache#1088" = nothing
                                            end
                                            var"##1087" = var"##1086"[1]
                                            var"##1087" isa Expr
                                        end && (begin
                                                if var"##cache#1088" === nothing
                                                    var"##cache#1088" = Some(((var"##1087").head, (var"##1087").args))
                                                end
                                                var"##1089" = (var"##cache#1088").value
                                                var"##1089" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1089"[1] == :block && (begin
                                                        var"##1090" = var"##1089"[2]
                                                        var"##1090" isa AbstractArray
                                                    end && ((ndims(var"##1090") === 1 && length(var"##1090") >= 0) && begin
                                                            var"##1091" = SubArray(var"##1090", (1:length(var"##1090"),))
                                                            let stmts = var"##1091"
                                                                is_root()
                                                            end
                                                        end))))))))
                    stmts = var"##1091"
                    var"##return#1075" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1076#1280")))
                end
                if begin
                            var"##1092" = (var"##cache#1078").value
                            var"##1092" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1092"[1] == :quote && (begin
                                    var"##1093" = var"##1092"[2]
                                    var"##1093" isa AbstractArray
                                end && (length(var"##1093") === 1 && (begin
                                            begin
                                                var"##cache#1095" = nothing
                                            end
                                            var"##1094" = var"##1093"[1]
                                            var"##1094" isa Expr
                                        end && (begin
                                                if var"##cache#1095" === nothing
                                                    var"##cache#1095" = Some(((var"##1094").head, (var"##1094").args))
                                                end
                                                var"##1096" = (var"##cache#1095").value
                                                var"##1096" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1096"[1] == :block && (begin
                                                        var"##1097" = var"##1096"[2]
                                                        var"##1097" isa AbstractArray
                                                    end && ((ndims(var"##1097") === 1 && length(var"##1097") >= 0) && begin
                                                            var"##1098" = SubArray(var"##1097", (1:length(var"##1097"),))
                                                            true
                                                        end))))))))
                    stmts = var"##1098"
                    var"##return#1075" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1076#1280")))
                end
                if begin
                            var"##1099" = (var"##cache#1078").value
                            var"##1099" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1099"[1] == :quote && (begin
                                    var"##1100" = var"##1099"[2]
                                    var"##1100" isa AbstractArray
                                end && (length(var"##1100") === 1 && begin
                                        var"##1101" = var"##1100"[1]
                                        true
                                    end)))
                    code = var"##1101"
                    var"##return#1075" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1076#1280")))
                end
                if begin
                            var"##1102" = (var"##cache#1078").value
                            var"##1102" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1102"[1] == :let && (begin
                                    var"##1103" = var"##1102"[2]
                                    var"##1103" isa AbstractArray
                                end && (length(var"##1103") === 2 && (begin
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
                                                    end && ((ndims(var"##1107") === 1 && length(var"##1107") >= 0) && (begin
                                                                var"##1108" = SubArray(var"##1107", (1:length(var"##1107"),))
                                                                begin
                                                                    var"##cache#1110" = nothing
                                                                end
                                                                var"##1109" = var"##1103"[2]
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
                                                                                true
                                                                            end)))))))))))))
                    args = var"##1108"
                    stmts = var"##1113"
                    var"##return#1075" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1076#1280")))
                end
                if begin
                            var"##1114" = (var"##cache#1078").value
                            var"##1114" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1114"[1] == :if && (begin
                                    var"##1115" = var"##1114"[2]
                                    var"##1115" isa AbstractArray
                                end && (length(var"##1115") === 2 && begin
                                        var"##1116" = var"##1115"[1]
                                        var"##1117" = var"##1115"[2]
                                        true
                                    end)))
                    cond = var"##1116"
                    body = var"##1117"
                    var"##return#1075" = begin
                            print_if(cond, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1076#1280")))
                end
                if begin
                            var"##1118" = (var"##cache#1078").value
                            var"##1118" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1118"[1] == :if && (begin
                                    var"##1119" = var"##1118"[2]
                                    var"##1119" isa AbstractArray
                                end && (length(var"##1119") === 3 && begin
                                        var"##1120" = var"##1119"[1]
                                        var"##1121" = var"##1119"[2]
                                        var"##1122" = var"##1119"[3]
                                        true
                                    end)))
                    cond = var"##1120"
                    body = var"##1121"
                    otherwise = var"##1122"
                    var"##return#1075" = begin
                            print_if(cond, body, otherwise)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1076#1280")))
                end
                if begin
                            var"##1123" = (var"##cache#1078").value
                            var"##1123" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1123"[1] == :elseif && (begin
                                    var"##1124" = var"##1123"[2]
                                    var"##1124" isa AbstractArray
                                end && (length(var"##1124") === 2 && (begin
                                            begin
                                                var"##cache#1126" = nothing
                                            end
                                            var"##1125" = var"##1124"[1]
                                            var"##1125" isa Expr
                                        end && (begin
                                                if var"##cache#1126" === nothing
                                                    var"##cache#1126" = Some(((var"##1125").head, (var"##1125").args))
                                                end
                                                var"##1127" = (var"##cache#1126").value
                                                var"##1127" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1127"[1] == :block && (begin
                                                        var"##1128" = var"##1127"[2]
                                                        var"##1128" isa AbstractArray
                                                    end && (length(var"##1128") === 2 && begin
                                                            var"##1129" = var"##1128"[1]
                                                            var"##1130" = var"##1128"[2]
                                                            var"##1131" = var"##1124"[2]
                                                            true
                                                        end))))))))
                    line = var"##1129"
                    cond = var"##1130"
                    body = var"##1131"
                    var"##return#1075" = begin
                            print_elseif(cond, body, line)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1076#1280")))
                end
                if begin
                            var"##1132" = (var"##cache#1078").value
                            var"##1132" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1132"[1] == :elseif && (begin
                                    var"##1133" = var"##1132"[2]
                                    var"##1133" isa AbstractArray
                                end && (length(var"##1133") === 2 && begin
                                        var"##1134" = var"##1133"[1]
                                        var"##1135" = var"##1133"[2]
                                        true
                                    end)))
                    cond = var"##1134"
                    body = var"##1135"
                    var"##return#1075" = begin
                            print_elseif(cond, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1076#1280")))
                end
                if begin
                            var"##1136" = (var"##cache#1078").value
                            var"##1136" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1136"[1] == :elseif && (begin
                                    var"##1137" = var"##1136"[2]
                                    var"##1137" isa AbstractArray
                                end && (length(var"##1137") === 3 && (begin
                                            begin
                                                var"##cache#1139" = nothing
                                            end
                                            var"##1138" = var"##1137"[1]
                                            var"##1138" isa Expr
                                        end && (begin
                                                if var"##cache#1139" === nothing
                                                    var"##cache#1139" = Some(((var"##1138").head, (var"##1138").args))
                                                end
                                                var"##1140" = (var"##cache#1139").value
                                                var"##1140" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1140"[1] == :block && (begin
                                                        var"##1141" = var"##1140"[2]
                                                        var"##1141" isa AbstractArray
                                                    end && (length(var"##1141") === 2 && begin
                                                            var"##1142" = var"##1141"[1]
                                                            var"##1143" = var"##1141"[2]
                                                            var"##1144" = var"##1137"[2]
                                                            var"##1145" = var"##1137"[3]
                                                            true
                                                        end))))))))
                    line = var"##1142"
                    cond = var"##1143"
                    body = var"##1144"
                    otherwise = var"##1145"
                    var"##return#1075" = begin
                            print_elseif(cond, body, line, otherwise)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1076#1280")))
                end
                if begin
                            var"##1146" = (var"##cache#1078").value
                            var"##1146" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1146"[1] == :elseif && (begin
                                    var"##1147" = var"##1146"[2]
                                    var"##1147" isa AbstractArray
                                end && (length(var"##1147") === 3 && begin
                                        var"##1148" = var"##1147"[1]
                                        var"##1149" = var"##1147"[2]
                                        var"##1150" = var"##1147"[3]
                                        true
                                    end)))
                    cond = var"##1148"
                    body = var"##1149"
                    otherwise = var"##1150"
                    var"##return#1075" = begin
                            print_elseif(cond, body, nothing, otherwise)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1076#1280")))
                end
                if begin
                            var"##1151" = (var"##cache#1078").value
                            var"##1151" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1151"[1] == :for && (begin
                                    var"##1152" = var"##1151"[2]
                                    var"##1152" isa AbstractArray
                                end && (length(var"##1152") === 2 && begin
                                        var"##1153" = var"##1152"[1]
                                        var"##1154" = var"##1152"[2]
                                        true
                                    end)))
                    body = var"##1154"
                    iteration = var"##1153"
                    var"##return#1075" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1076#1280")))
                end
                if begin
                            var"##1155" = (var"##cache#1078").value
                            var"##1155" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1155"[1] == :while && (begin
                                    var"##1156" = var"##1155"[2]
                                    var"##1156" isa AbstractArray
                                end && (length(var"##1156") === 2 && begin
                                        var"##1157" = var"##1156"[1]
                                        var"##1158" = var"##1156"[2]
                                        true
                                    end)))
                    cond = var"##1157"
                    body = var"##1158"
                    var"##return#1075" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1076#1280")))
                end
                if begin
                            var"##1159" = (var"##cache#1078").value
                            var"##1159" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1159"[1] == :(=) && (begin
                                    var"##1160" = var"##1159"[2]
                                    var"##1160" isa AbstractArray
                                end && (length(var"##1160") === 2 && (begin
                                            var"##1161" = var"##1160"[1]
                                            begin
                                                var"##cache#1163" = nothing
                                            end
                                            var"##1162" = var"##1160"[2]
                                            var"##1162" isa Expr
                                        end && (begin
                                                if var"##cache#1163" === nothing
                                                    var"##cache#1163" = Some(((var"##1162").head, (var"##1162").args))
                                                end
                                                var"##1164" = (var"##cache#1163").value
                                                var"##1164" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1164"[1] == :block && (begin
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
                                                                end && (var"##1169"[1] == :if && (begin
                                                                            var"##1170" = var"##1169"[2]
                                                                            var"##1170" isa AbstractArray
                                                                        end && ((ndims(var"##1170") === 1 && length(var"##1170") >= 0) && let line = var"##1166", lhs = var"##1161"
                                                                                is_line_no(line)
                                                                            end)))))))))))))
                    line = var"##1166"
                    lhs = var"##1161"
                    var"##return#1075" = begin
                            leading_tab()
                            inline(lhs)
                            keyword(" = ")
                            inline(line)
                            p(ex.args[2])
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1076#1280")))
                end
                if begin
                            var"##1171" = (var"##cache#1078").value
                            var"##1171" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1171"[1] == :(=) && (begin
                                    var"##1172" = var"##1171"[2]
                                    var"##1172" isa AbstractArray
                                end && (length(var"##1172") === 2 && (begin
                                            var"##1173" = var"##1172"[1]
                                            begin
                                                var"##cache#1175" = nothing
                                            end
                                            var"##1174" = var"##1172"[2]
                                            var"##1174" isa Expr
                                        end && (begin
                                                if var"##cache#1175" === nothing
                                                    var"##cache#1175" = Some(((var"##1174").head, (var"##1174").args))
                                                end
                                                var"##1176" = (var"##cache#1175").value
                                                var"##1176" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1176"[1] == :block && (begin
                                                        var"##1177" = var"##1176"[2]
                                                        var"##1177" isa AbstractArray
                                                    end && (length(var"##1177") === 2 && begin
                                                            var"##1178" = var"##1177"[1]
                                                            var"##1179" = var"##1177"[2]
                                                            let rhs = var"##1179", line = var"##1178", lhs = var"##1173"
                                                                is_line_no(line)
                                                            end
                                                        end))))))))
                    rhs = var"##1179"
                    line = var"##1178"
                    lhs = var"##1173"
                    var"##return#1075" = begin
                            leading_tab()
                            inline(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1076#1280")))
                end
                if begin
                            var"##1180" = (var"##cache#1078").value
                            var"##1180" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1180"[1] == :(=) && (begin
                                    var"##1181" = var"##1180"[2]
                                    var"##1181" isa AbstractArray
                                end && (length(var"##1181") === 2 && begin
                                        var"##1182" = var"##1181"[1]
                                        var"##1183" = var"##1181"[2]
                                        true
                                    end)))
                    rhs = var"##1183"
                    lhs = var"##1182"
                    var"##return#1075" = begin
                            leading_tab()
                            inline(lhs)
                            print(" = ")
                            p(rhs)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1076#1280")))
                end
                if begin
                            var"##1184" = (var"##cache#1078").value
                            var"##1184" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1184"[1] == :function && (begin
                                    var"##1185" = var"##1184"[2]
                                    var"##1185" isa AbstractArray
                                end && (length(var"##1185") === 2 && begin
                                        var"##1186" = var"##1185"[1]
                                        var"##1187" = var"##1185"[2]
                                        true
                                    end)))
                    call = var"##1186"
                    body = var"##1187"
                    var"##return#1075" = begin
                            print_function(:function, call, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1076#1280")))
                end
                if begin
                            var"##1188" = (var"##cache#1078").value
                            var"##1188" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1188"[1] == :-> && (begin
                                    var"##1189" = var"##1188"[2]
                                    var"##1189" isa AbstractArray
                                end && (length(var"##1189") === 2 && begin
                                        var"##1190" = var"##1189"[1]
                                        var"##1191" = var"##1189"[2]
                                        true
                                    end)))
                    call = var"##1190"
                    body = var"##1191"
                    var"##return#1075" = begin
                            leading_tab()
                            inline(call)
                            keyword(" -> ")
                            p(body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1076#1280")))
                end
                if begin
                            var"##1192" = (var"##cache#1078").value
                            var"##1192" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1192"[1] == :do && (begin
                                    var"##1193" = var"##1192"[2]
                                    var"##1193" isa AbstractArray
                                end && (length(var"##1193") === 2 && (begin
                                            var"##1194" = var"##1193"[1]
                                            begin
                                                var"##cache#1196" = nothing
                                            end
                                            var"##1195" = var"##1193"[2]
                                            var"##1195" isa Expr
                                        end && (begin
                                                if var"##cache#1196" === nothing
                                                    var"##cache#1196" = Some(((var"##1195").head, (var"##1195").args))
                                                end
                                                var"##1197" = (var"##cache#1196").value
                                                var"##1197" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1197"[1] == :-> && (begin
                                                        var"##1198" = var"##1197"[2]
                                                        var"##1198" isa AbstractArray
                                                    end && (length(var"##1198") === 2 && (begin
                                                                begin
                                                                    var"##cache#1200" = nothing
                                                                end
                                                                var"##1199" = var"##1198"[1]
                                                                var"##1199" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1200" === nothing
                                                                        var"##cache#1200" = Some(((var"##1199").head, (var"##1199").args))
                                                                    end
                                                                    var"##1201" = (var"##cache#1200").value
                                                                    var"##1201" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1201"[1] == :tuple && (begin
                                                                            var"##1202" = var"##1201"[2]
                                                                            var"##1202" isa AbstractArray
                                                                        end && ((ndims(var"##1202") === 1 && length(var"##1202") >= 0) && begin
                                                                                var"##1203" = SubArray(var"##1202", (1:length(var"##1202"),))
                                                                                var"##1204" = var"##1198"[2]
                                                                                true
                                                                            end)))))))))))))
                    call = var"##1194"
                    args = var"##1203"
                    body = var"##1204"
                    var"##return#1075" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1076#1280")))
                end
                if begin
                            var"##1205" = (var"##cache#1078").value
                            var"##1205" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1205"[1] == :macro && (begin
                                    var"##1206" = var"##1205"[2]
                                    var"##1206" isa AbstractArray
                                end && (length(var"##1206") === 2 && begin
                                        var"##1207" = var"##1206"[1]
                                        var"##1208" = var"##1206"[2]
                                        true
                                    end)))
                    call = var"##1207"
                    body = var"##1208"
                    var"##return#1075" = begin
                            print_function(:macro, call, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1076#1280")))
                end
                if begin
                            var"##1209" = (var"##cache#1078").value
                            var"##1209" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1209"[1] == :macrocall && (begin
                                    var"##1210" = var"##1209"[2]
                                    var"##1210" isa AbstractArray
                                end && (length(var"##1210") === 4 && (begin
                                            var"##1211" = var"##1210"[1]
                                            var"##1211" == Symbol("@switch")
                                        end && (begin
                                                var"##1212" = var"##1210"[2]
                                                var"##1213" = var"##1210"[3]
                                                begin
                                                    var"##cache#1215" = nothing
                                                end
                                                var"##1214" = var"##1210"[4]
                                                var"##1214" isa Expr
                                            end && (begin
                                                    if var"##cache#1215" === nothing
                                                        var"##cache#1215" = Some(((var"##1214").head, (var"##1214").args))
                                                    end
                                                    var"##1216" = (var"##cache#1215").value
                                                    var"##1216" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##1216"[1] == :block && (begin
                                                            var"##1217" = var"##1216"[2]
                                                            var"##1217" isa AbstractArray
                                                        end && ((ndims(var"##1217") === 1 && length(var"##1217") >= 0) && begin
                                                                var"##1218" = SubArray(var"##1217", (1:length(var"##1217"),))
                                                                true
                                                            end)))))))))
                    item = var"##1213"
                    line = var"##1212"
                    stmts = var"##1218"
                    var"##return#1075" = begin
                            print_switch(item, line, stmts)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1076#1280")))
                end
                if begin
                            var"##1219" = (var"##cache#1078").value
                            var"##1219" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1219"[1] == :macrocall && (begin
                                    var"##1220" = var"##1219"[2]
                                    var"##1220" isa AbstractArray
                                end && (length(var"##1220") === 4 && (begin
                                            var"##1221" = var"##1220"[1]
                                            var"##1221" == GlobalRef(Core, Symbol("@doc"))
                                        end && begin
                                            var"##1222" = var"##1220"[2]
                                            var"##1223" = var"##1220"[3]
                                            var"##1224" = var"##1220"[4]
                                            true
                                        end))))
                    line = var"##1222"
                    code = var"##1224"
                    doc = var"##1223"
                    var"##return#1075" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1076#1280")))
                end
                if begin
                            var"##1225" = (var"##cache#1078").value
                            var"##1225" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1225"[1] == :macrocall && (begin
                                    var"##1226" = var"##1225"[2]
                                    var"##1226" isa AbstractArray
                                end && ((ndims(var"##1226") === 1 && length(var"##1226") >= 2) && begin
                                        var"##1227" = var"##1226"[1]
                                        var"##1228" = var"##1226"[2]
                                        var"##1229" = SubArray(var"##1226", (3:length(var"##1226"),))
                                        true
                                    end)))
                    line = var"##1228"
                    name = var"##1227"
                    args = var"##1229"
                    var"##return#1075" = begin
                            print_macrocall(name, line, args)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1076#1280")))
                end
                if begin
                            var"##1230" = (var"##cache#1078").value
                            var"##1230" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1230"[1] == :struct && (begin
                                    var"##1231" = var"##1230"[2]
                                    var"##1231" isa AbstractArray
                                end && (length(var"##1231") === 3 && begin
                                        var"##1232" = var"##1231"[1]
                                        var"##1233" = var"##1231"[2]
                                        var"##1234" = var"##1231"[3]
                                        true
                                    end)))
                    ismutable = var"##1232"
                    body = var"##1234"
                    head = var"##1233"
                    var"##return#1075" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1076#1280")))
                end
                if begin
                            var"##1235" = (var"##cache#1078").value
                            var"##1235" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1235"[1] == :try && (begin
                                    var"##1236" = var"##1235"[2]
                                    var"##1236" isa AbstractArray
                                end && (length(var"##1236") === 3 && begin
                                        var"##1237" = var"##1236"[1]
                                        var"##1238" = var"##1236"[2]
                                        var"##1239" = var"##1236"[3]
                                        true
                                    end)))
                    catch_vars = var"##1238"
                    catch_body = var"##1239"
                    try_body = var"##1237"
                    var"##return#1075" = begin
                            print_try(try_body)
                            print_catch(catch_body, catch_vars)
                            println()
                            tab()
                            keyword("end")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1076#1280")))
                end
                if begin
                            var"##1240" = (var"##cache#1078").value
                            var"##1240" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1240"[1] == :try && (begin
                                    var"##1241" = var"##1240"[2]
                                    var"##1241" isa AbstractArray
                                end && (length(var"##1241") === 4 && begin
                                        var"##1242" = var"##1241"[1]
                                        var"##1243" = var"##1241"[2]
                                        var"##1244" = var"##1241"[3]
                                        var"##1245" = var"##1241"[4]
                                        true
                                    end)))
                    catch_vars = var"##1243"
                    catch_body = var"##1244"
                    try_body = var"##1242"
                    finally_body = var"##1245"
                    var"##return#1075" = begin
                            print_try(try_body)
                            print_catch(catch_body, catch_vars)
                            print_finally(finally_body)
                            println()
                            tab()
                            keyword("end")
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1076#1280")))
                end
                if begin
                            var"##1246" = (var"##cache#1078").value
                            var"##1246" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1246"[1] == :try && (begin
                                    var"##1247" = var"##1246"[2]
                                    var"##1247" isa AbstractArray
                                end && (length(var"##1247") === 5 && begin
                                        var"##1248" = var"##1247"[1]
                                        var"##1249" = var"##1247"[2]
                                        var"##1250" = var"##1247"[3]
                                        var"##1251" = var"##1247"[4]
                                        var"##1252" = var"##1247"[5]
                                        true
                                    end)))
                    catch_vars = var"##1249"
                    catch_body = var"##1250"
                    try_body = var"##1248"
                    finally_body = var"##1251"
                    else_body = var"##1252"
                    var"##return#1075" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1076#1280")))
                end
                if begin
                            var"##1253" = (var"##cache#1078").value
                            var"##1253" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1253"[1] == :module && (begin
                                    var"##1254" = var"##1253"[2]
                                    var"##1254" isa AbstractArray
                                end && (length(var"##1254") === 3 && begin
                                        var"##1255" = var"##1254"[1]
                                        var"##1256" = var"##1254"[2]
                                        var"##1257" = var"##1254"[3]
                                        true
                                    end)))
                    name = var"##1256"
                    body = var"##1257"
                    notbare = var"##1255"
                    var"##return#1075" = begin
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
                    $(Expr(:symbolicgoto, Symbol("####final#1076#1280")))
                end
                if begin
                            var"##1258" = (var"##cache#1078").value
                            var"##1258" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1258"[1] == :const && (begin
                                    var"##1259" = var"##1258"[2]
                                    var"##1259" isa AbstractArray
                                end && (length(var"##1259") === 1 && begin
                                        var"##1260" = var"##1259"[1]
                                        true
                                    end)))
                    code = var"##1260"
                    var"##return#1075" = begin
                            leading_tab()
                            keyword("const ")
                            p(code)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1076#1280")))
                end
                if begin
                            var"##1261" = (var"##cache#1078").value
                            var"##1261" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1261"[1] == :return && (begin
                                    var"##1262" = var"##1261"[2]
                                    var"##1262" isa AbstractArray
                                end && (length(var"##1262") === 1 && (begin
                                            begin
                                                var"##cache#1264" = nothing
                                            end
                                            var"##1263" = var"##1262"[1]
                                            var"##1263" isa Expr
                                        end && (begin
                                                if var"##cache#1264" === nothing
                                                    var"##cache#1264" = Some(((var"##1263").head, (var"##1263").args))
                                                end
                                                var"##1265" = (var"##cache#1264").value
                                                var"##1265" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##1265"[1] == :tuple && (begin
                                                        var"##1266" = var"##1265"[2]
                                                        var"##1266" isa AbstractArray
                                                    end && ((ndims(var"##1266") === 1 && length(var"##1266") >= 1) && (begin
                                                                begin
                                                                    var"##cache#1268" = nothing
                                                                end
                                                                var"##1267" = var"##1266"[1]
                                                                var"##1267" isa Expr
                                                            end && (begin
                                                                    if var"##cache#1268" === nothing
                                                                        var"##cache#1268" = Some(((var"##1267").head, (var"##1267").args))
                                                                    end
                                                                    var"##1269" = (var"##cache#1268").value
                                                                    var"##1269" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##1269"[1] == :parameters && (begin
                                                                            var"##1270" = var"##1269"[2]
                                                                            var"##1270" isa AbstractArray
                                                                        end && (ndims(var"##1270") === 1 && length(var"##1270") >= 0)))))))))))))
                    var"##return#1075" = begin
                            inline(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1076#1280")))
                end
                if begin
                            var"##1271" = (var"##cache#1078").value
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
                                                    end && (ndims(var"##1276") === 1 && length(var"##1276") >= 0))))))))
                    var"##return#1075" = begin
                            inline(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1076#1280")))
                end
                if begin
                            var"##1277" = (var"##cache#1078").value
                            var"##1277" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##1277"[1] == :return && (begin
                                    var"##1278" = var"##1277"[2]
                                    var"##1278" isa AbstractArray
                                end && (length(var"##1278") === 1 && begin
                                        var"##1279" = var"##1278"[1]
                                        true
                                    end)))
                    code = var"##1279"
                    var"##return#1075" = begin
                            leading_tab()
                            keyword("return ")
                            p(code)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1076#1280")))
                end
            end
            if var"##1077" isa String
                begin
                    var"##return#1075" = begin
                            leading_tab()
                            occursin('\n', ex) || return inline(ex)
                            printstyled("\"\"\"\n", color = c.string)
                            tab()
                            print_multi_lines(ex)
                            printstyled("\"\"\"", color = c.string)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#1076#1280")))
                end
            end
            begin
                var"##return#1075" = begin
                        inline(ex)
                    end
                $(Expr(:symbolicgoto, Symbol("####final#1076#1280")))
            end
            error("matching non-exhaustive, at #= none:246 =#")
            $(Expr(:symboliclabel, Symbol("####final#1076#1280")))
            var"##return#1075"
        end
        return nothing
    end
    #= none:464 =# Core.@doc "    print_expr([io::IO], ex; kw...)\n\nPrint a given expression. `ex` can be a `Expr` or a syntax type `JLExpr`.\n" print_expr(io::IO, ex; kw...) = begin
                (Printer(io; kw...))(ex)
            end
    print_expr(ex; kw...) = begin
            print_expr(stdout, ex; kw...)
        end
