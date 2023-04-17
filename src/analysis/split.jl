
    #= none:1 =# Core.@doc "    split_doc(ex::Expr) -> line, doc, expr\n\nSplit doc string from given expression.\n" function split_doc(ex::Expr)
            begin
                begin
                    var"##cache#567" = nothing
                end
                var"##566" = ex
                if var"##566" isa Expr
                    if begin
                                if var"##cache#567" === nothing
                                    var"##cache#567" = Some(((var"##566").head, (var"##566").args))
                                end
                                var"##568" = (var"##cache#567").value
                                var"##568" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##568"[1] == :macrocall && (begin
                                        var"##569" = var"##568"[2]
                                        var"##569" isa AbstractArray
                                    end && (length(var"##569") === 4 && (begin
                                                var"##570" = var"##569"[1]
                                                var"##570" == GlobalRef(Core, Symbol("@doc"))
                                            end && begin
                                                var"##571" = var"##569"[2]
                                                var"##572" = var"##569"[3]
                                                var"##573" = var"##569"[4]
                                                true
                                            end))))
                        line = var"##571"
                        expr = var"##573"
                        doc = var"##572"
                        var"##return#564" = begin
                                return (line, doc, expr)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#565#594")))
                    end
                    if begin
                                var"##574" = (var"##cache#567").value
                                var"##574" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##574"[1] == :macrocall && (begin
                                        var"##575" = var"##574"[2]
                                        var"##575" isa AbstractArray
                                    end && (length(var"##575") === 4 && (begin
                                                var"##576" = var"##575"[1]
                                                var"##576" == Symbol("@doc")
                                            end && begin
                                                var"##577" = var"##575"[2]
                                                var"##578" = var"##575"[3]
                                                var"##579" = var"##575"[4]
                                                true
                                            end))))
                        line = var"##577"
                        expr = var"##579"
                        doc = var"##578"
                        var"##return#564" = begin
                                return (line, doc, expr)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#565#594")))
                    end
                    if begin
                                var"##580" = (var"##cache#567").value
                                var"##580" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##580"[1] == :macrocall && (begin
                                        var"##581" = var"##580"[2]
                                        var"##581" isa AbstractArray
                                    end && (length(var"##581") === 4 && (begin
                                                begin
                                                    var"##cache#583" = nothing
                                                end
                                                var"##582" = var"##581"[1]
                                                var"##582" isa Expr
                                            end && (begin
                                                    if var"##cache#583" === nothing
                                                        var"##cache#583" = Some(((var"##582").head, (var"##582").args))
                                                    end
                                                    var"##584" = (var"##cache#583").value
                                                    var"##584" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##584"[1] == :. && (begin
                                                            var"##585" = var"##584"[2]
                                                            var"##585" isa AbstractArray
                                                        end && (length(var"##585") === 2 && (var"##585"[1] == :Core && (begin
                                                                        var"##586" = var"##585"[2]
                                                                        var"##586" == QuoteNode(Symbol("@doc"))
                                                                    end && begin
                                                                        var"##587" = var"##581"[2]
                                                                        var"##588" = var"##581"[3]
                                                                        var"##589" = var"##581"[4]
                                                                        true
                                                                    end))))))))))
                        line = var"##587"
                        expr = var"##589"
                        doc = var"##588"
                        var"##return#564" = begin
                                return (line, doc, expr)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#565#594")))
                    end
                    if begin
                                var"##590" = (var"##cache#567").value
                                var"##590" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##590"[1] == :block && (begin
                                        var"##591" = var"##590"[2]
                                        var"##591" isa AbstractArray
                                    end && (length(var"##591") === 2 && (begin
                                                var"##592" = var"##591"[1]
                                                var"##592" isa LineNumberNode
                                            end && begin
                                                var"##593" = var"##591"[2]
                                                true
                                            end))))
                        stmt = var"##593"
                        var"##return#564" = begin
                                (line, doc, expr) = split_doc(stmt)
                                return (line, doc, expr)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#565#594")))
                    end
                end
                begin
                    var"##return#564" = begin
                            return (nothing, nothing, ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#565#594")))
                end
                error("matching non-exhaustive, at #= none:7 =#")
                $(Expr(:symboliclabel, Symbol("####final#565#594")))
                var"##return#564"
            end
        end
    #= none:24 =# Core.@doc "    split_function(ex::Expr) -> head, call, body\n\nSplit function head declaration with function body.\n" function split_function(ex::Expr; source = nothing)
            let
                begin
                    var"##cache#598" = nothing
                end
                var"##return#595" = nothing
                var"##597" = ex
                if var"##597" isa Expr
                    if begin
                                if var"##cache#598" === nothing
                                    var"##cache#598" = Some(((var"##597").head, (var"##597").args))
                                end
                                var"##599" = (var"##cache#598").value
                                var"##599" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##599"[1] == :function && (begin
                                        var"##600" = var"##599"[2]
                                        var"##600" isa AbstractArray
                                    end && (length(var"##600") === 2 && begin
                                            var"##601" = var"##600"[1]
                                            var"##602" = var"##600"[2]
                                            true
                                        end)))
                        var"##return#595" = let call = var"##601", body = var"##602"
                                (:function, call, body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#596#611")))
                    end
                    if begin
                                var"##603" = (var"##cache#598").value
                                var"##603" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##603"[1] == :(=) && (begin
                                        var"##604" = var"##603"[2]
                                        var"##604" isa AbstractArray
                                    end && (length(var"##604") === 2 && begin
                                            var"##605" = var"##604"[1]
                                            var"##606" = var"##604"[2]
                                            true
                                        end)))
                        var"##return#595" = let call = var"##605", body = var"##606"
                                (:(=), call, body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#596#611")))
                    end
                    if begin
                                var"##607" = (var"##cache#598").value
                                var"##607" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##607"[1] == :-> && (begin
                                        var"##608" = var"##607"[2]
                                        var"##608" isa AbstractArray
                                    end && (length(var"##608") === 2 && begin
                                            var"##609" = var"##608"[1]
                                            var"##610" = var"##608"[2]
                                            true
                                        end)))
                        var"##return#595" = let call = var"##609", body = var"##610"
                                (:->, call, body)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#596#611")))
                    end
                end
                begin
                    var"##return#595" = let
                            throw(SyntaxError("expect a function expr, got $(ex)", source))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#596#611")))
                end
                error("matching non-exhaustive, at #= none:30 =#")
                $(Expr(:symboliclabel, Symbol("####final#596#611")))
                var"##return#595"
            end
        end
    #= none:38 =# Core.@doc "    split_function_head(ex::Expr) -> name, args, kw, whereparams, rettype\n\nSplit function head to name, arguments, keyword arguments and where parameters.\n" function split_function_head(ex::Expr; source = nothing)
            let
                begin
                    var"##cache#615" = nothing
                end
                var"##return#612" = nothing
                var"##614" = ex
                if var"##614" isa Expr
                    if begin
                                if var"##cache#615" === nothing
                                    var"##cache#615" = Some(((var"##614").head, (var"##614").args))
                                end
                                var"##616" = (var"##cache#615").value
                                var"##616" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##616"[1] == :tuple && (begin
                                        var"##617" = var"##616"[2]
                                        var"##617" isa AbstractArray
                                    end && ((ndims(var"##617") === 1 && length(var"##617") >= 1) && (begin
                                                begin
                                                    var"##cache#619" = nothing
                                                end
                                                var"##618" = var"##617"[1]
                                                var"##618" isa Expr
                                            end && (begin
                                                    if var"##cache#619" === nothing
                                                        var"##cache#619" = Some(((var"##618").head, (var"##618").args))
                                                    end
                                                    var"##620" = (var"##cache#619").value
                                                    var"##620" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##620"[1] == :parameters && (begin
                                                            var"##621" = var"##620"[2]
                                                            var"##621" isa AbstractArray
                                                        end && ((ndims(var"##621") === 1 && length(var"##621") >= 0) && begin
                                                                var"##622" = SubArray(var"##621", (1:length(var"##621"),))
                                                                var"##623" = SubArray(var"##617", (2:length(var"##617"),))
                                                                true
                                                            end))))))))
                        var"##return#612" = let args = var"##623", kw = var"##622"
                                (nothing, args, kw, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#613#663")))
                    end
                    if begin
                                var"##624" = (var"##cache#615").value
                                var"##624" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##624"[1] == :tuple && (begin
                                        var"##625" = var"##624"[2]
                                        var"##625" isa AbstractArray
                                    end && ((ndims(var"##625") === 1 && length(var"##625") >= 0) && begin
                                            var"##626" = SubArray(var"##625", (1:length(var"##625"),))
                                            true
                                        end)))
                        var"##return#612" = let args = var"##626"
                                (nothing, args, nothing, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#613#663")))
                    end
                    if begin
                                var"##627" = (var"##cache#615").value
                                var"##627" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##627"[1] == :call && (begin
                                        var"##628" = var"##627"[2]
                                        var"##628" isa AbstractArray
                                    end && ((ndims(var"##628") === 1 && length(var"##628") >= 2) && (begin
                                                var"##629" = var"##628"[1]
                                                begin
                                                    var"##cache#631" = nothing
                                                end
                                                var"##630" = var"##628"[2]
                                                var"##630" isa Expr
                                            end && (begin
                                                    if var"##cache#631" === nothing
                                                        var"##cache#631" = Some(((var"##630").head, (var"##630").args))
                                                    end
                                                    var"##632" = (var"##cache#631").value
                                                    var"##632" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##632"[1] == :parameters && (begin
                                                            var"##633" = var"##632"[2]
                                                            var"##633" isa AbstractArray
                                                        end && ((ndims(var"##633") === 1 && length(var"##633") >= 0) && begin
                                                                var"##634" = SubArray(var"##633", (1:length(var"##633"),))
                                                                var"##635" = SubArray(var"##628", (3:length(var"##628"),))
                                                                true
                                                            end))))))))
                        var"##return#612" = let name = var"##629", args = var"##635", kw = var"##634"
                                (name, args, kw, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#613#663")))
                    end
                    if begin
                                var"##636" = (var"##cache#615").value
                                var"##636" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##636"[1] == :call && (begin
                                        var"##637" = var"##636"[2]
                                        var"##637" isa AbstractArray
                                    end && ((ndims(var"##637") === 1 && length(var"##637") >= 1) && begin
                                            var"##638" = var"##637"[1]
                                            var"##639" = SubArray(var"##637", (2:length(var"##637"),))
                                            true
                                        end)))
                        var"##return#612" = let name = var"##638", args = var"##639"
                                (name, args, nothing, nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#613#663")))
                    end
                    if begin
                                var"##640" = (var"##cache#615").value
                                var"##640" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##640"[1] == :block && (begin
                                        var"##641" = var"##640"[2]
                                        var"##641" isa AbstractArray
                                    end && (length(var"##641") === 3 && (begin
                                                var"##642" = var"##641"[1]
                                                var"##643" = var"##641"[2]
                                                var"##643" isa LineNumberNode
                                            end && (begin
                                                    begin
                                                        var"##cache#645" = nothing
                                                    end
                                                    var"##644" = var"##641"[3]
                                                    var"##644" isa Expr
                                                end && (begin
                                                        if var"##cache#645" === nothing
                                                            var"##cache#645" = Some(((var"##644").head, (var"##644").args))
                                                        end
                                                        var"##646" = (var"##cache#645").value
                                                        var"##646" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                    end && (var"##646"[1] == :(=) && (begin
                                                                var"##647" = var"##646"[2]
                                                                var"##647" isa AbstractArray
                                                            end && (length(var"##647") === 2 && begin
                                                                    var"##648" = var"##647"[1]
                                                                    var"##649" = var"##647"[2]
                                                                    true
                                                                end)))))))))
                        var"##return#612" = let value = var"##649", kw = var"##648", x = var"##642"
                                (nothing, Any[x], Any[Expr(:kw, kw, value)], nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#613#663")))
                    end
                    if begin
                                var"##650" = (var"##cache#615").value
                                var"##650" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##650"[1] == :block && (begin
                                        var"##651" = var"##650"[2]
                                        var"##651" isa AbstractArray
                                    end && (length(var"##651") === 3 && (begin
                                                var"##652" = var"##651"[1]
                                                var"##653" = var"##651"[2]
                                                var"##653" isa LineNumberNode
                                            end && begin
                                                var"##654" = var"##651"[3]
                                                true
                                            end))))
                        var"##return#612" = let kw = var"##654", x = var"##652"
                                (nothing, Any[x], Any[kw], nothing, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#613#663")))
                    end
                    if begin
                                var"##655" = (var"##cache#615").value
                                var"##655" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##655"[1] == :(::) && (begin
                                        var"##656" = var"##655"[2]
                                        var"##656" isa AbstractArray
                                    end && (length(var"##656") === 2 && begin
                                            var"##657" = var"##656"[1]
                                            var"##658" = var"##656"[2]
                                            true
                                        end)))
                        var"##return#612" = let call = var"##657", rettype = var"##658"
                                (name, args, kw, whereparams, _) = split_function_head(call)
                                (name, args, kw, whereparams, rettype)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#613#663")))
                    end
                    if begin
                                var"##659" = (var"##cache#615").value
                                var"##659" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##659"[1] == :where && (begin
                                        var"##660" = var"##659"[2]
                                        var"##660" isa AbstractArray
                                    end && ((ndims(var"##660") === 1 && length(var"##660") >= 1) && begin
                                            var"##661" = var"##660"[1]
                                            var"##662" = SubArray(var"##660", (2:length(var"##660"),))
                                            true
                                        end)))
                        var"##return#612" = let call = var"##661", whereparams = var"##662"
                                (name, args, kw, _, rettype) = split_function_head(call)
                                (name, args, kw, whereparams, rettype)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#613#663")))
                    end
                end
                begin
                    var"##return#612" = let
                            throw(SyntaxError("expect a function head, got $(ex)", source))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#613#663")))
                end
                error("matching non-exhaustive, at #= none:44 =#")
                $(Expr(:symboliclabel, Symbol("####final#613#663")))
                var"##return#612"
            end
        end
    #= none:63 =# Core.@doc "    split_struct_name(ex::Expr) -> name, typevars, supertype\n\nSplit the name, type parameters and supertype definition from `struct`\ndeclaration head.\n" function split_struct_name(#= none:69 =# @nospecialize(ex); source = nothing)
            return let
                    begin
                        var"##cache#667" = nothing
                    end
                    var"##return#664" = nothing
                    var"##666" = ex
                    if var"##666" isa Expr
                        if begin
                                    if var"##cache#667" === nothing
                                        var"##cache#667" = Some(((var"##666").head, (var"##666").args))
                                    end
                                    var"##668" = (var"##cache#667").value
                                    var"##668" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##668"[1] == :curly && (begin
                                            var"##669" = var"##668"[2]
                                            var"##669" isa AbstractArray
                                        end && ((ndims(var"##669") === 1 && length(var"##669") >= 1) && begin
                                                var"##670" = var"##669"[1]
                                                var"##671" = SubArray(var"##669", (2:length(var"##669"),))
                                                true
                                            end)))
                            var"##return#664" = let typevars = var"##671", name = var"##670"
                                    (name, typevars, nothing)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#665#685")))
                        end
                        if begin
                                    var"##672" = (var"##cache#667").value
                                    var"##672" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##672"[1] == :<: && (begin
                                            var"##673" = var"##672"[2]
                                            var"##673" isa AbstractArray
                                        end && (length(var"##673") === 2 && (begin
                                                    begin
                                                        var"##cache#675" = nothing
                                                    end
                                                    var"##674" = var"##673"[1]
                                                    var"##674" isa Expr
                                                end && (begin
                                                        if var"##cache#675" === nothing
                                                            var"##cache#675" = Some(((var"##674").head, (var"##674").args))
                                                        end
                                                        var"##676" = (var"##cache#675").value
                                                        var"##676" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                    end && (var"##676"[1] == :curly && (begin
                                                                var"##677" = var"##676"[2]
                                                                var"##677" isa AbstractArray
                                                            end && ((ndims(var"##677") === 1 && length(var"##677") >= 1) && begin
                                                                    var"##678" = var"##677"[1]
                                                                    var"##679" = SubArray(var"##677", (2:length(var"##677"),))
                                                                    var"##680" = var"##673"[2]
                                                                    true
                                                                end))))))))
                            var"##return#664" = let typevars = var"##679", type = var"##680", name = var"##678"
                                    (name, typevars, type)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#665#685")))
                        end
                        if begin
                                    var"##681" = (var"##cache#667").value
                                    var"##681" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##681"[1] == :<: && (begin
                                            var"##682" = var"##681"[2]
                                            var"##682" isa AbstractArray
                                        end && (length(var"##682") === 2 && begin
                                                var"##683" = var"##682"[1]
                                                var"##684" = var"##682"[2]
                                                true
                                            end)))
                            var"##return#664" = let type = var"##684", name = var"##683"
                                    (name, [], type)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#665#685")))
                        end
                    end
                    if var"##666" isa Symbol
                        begin
                            var"##return#664" = let
                                    (ex, [], nothing)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#665#685")))
                        end
                    end
                    begin
                        var"##return#664" = let
                                throw(SyntaxError("expect struct got $(ex)", source))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#665#685")))
                    end
                    error("matching non-exhaustive, at #= none:70 =#")
                    $(Expr(:symboliclabel, Symbol("####final#665#685")))
                    var"##return#664"
                end
        end
    #= none:79 =# Core.@doc "    split_struct(ex::Expr) -> ismutable, name, typevars, supertype, body\n\nSplit struct definition head and body.\n" function split_struct(ex::Expr; source = nothing)
            ex.head === :struct || throw(SyntaxError("expect a struct expr, got $(ex)", source))
            (name, typevars, supertype) = split_struct_name(ex.args[2]; source)
            body = ex.args[3]
            return (ex.args[1], name, typevars, supertype, body)
        end
    function split_ifelse(ex::Expr)
        (conds, stmts) = ([], [])
        otherwise = split_ifelse!((conds, stmts), ex)
        return (conds, stmts, otherwise)
    end
    function split_ifelse!((conds, stmts), ex::Expr)
        ex.head in [:if, :elseif] || return ex
        push!(conds, ex.args[1])
        push!(stmts, ex.args[2])
        if length(ex.args) == 3
            return split_ifelse!((conds, stmts), ex.args[3])
        end
        return nothing
    end
    function split_forloop(ex::Expr)
        ex.head === :for || error("expect a for loop expr, got $(ex)")
        lhead = ex.args[1]
        lbody = ex.args[2]
        return (split_for_head(lhead)..., lbody)
    end
    function split_for_head(ex::Expr)
        if ex.head === :block
            (vars, itrs) = ([], [])
            for each = ex.args
                each isa Expr || continue
                (var, itr) = split_single_for_head(each)
                push!(vars, var)
                push!(itrs, itr)
            end
            return (vars, itrs)
        else
            (var, itr) = split_single_for_head(ex)
            return (Any[var], Any[itr])
        end
    end
    function split_single_for_head(ex::Expr)
        ex.head === :(=) || error("expect a single loop head, got $(ex)")
        return (ex.args[1], ex.args[2])
    end
    #= none:136 =# Core.@doc "    uninferrable_typevars(def::Union{JLStruct, JLKwStruct}; leading_inferable::Bool=true)\n\nReturn the type variables that are not inferrable in given struct definition.\n" function uninferrable_typevars(def::Union{JLStruct, JLKwStruct}; leading_inferable::Bool = true)
            typevars = name_only.(def.typevars)
            field_types = [field.type for field = def.fields]
            if leading_inferable
                idx = findfirst(typevars) do t
                        !(any(map((f->begin
                                            has_symbol(f, t)
                                        end), field_types)))
                    end
                idx === nothing && return []
            else
                idx = 0
            end
            uninferrable = typevars[1:idx]
            for T = typevars[idx + 1:end]
                any(map((f->begin
                                    has_symbol(f, T)
                                end), field_types)) || push!(uninferrable, T)
            end
            return uninferrable
        end
    #= none:161 =# Core.@doc "    split_field_if_match(typename::Symbol, expr, default::Bool=false)\n\nSplit the field definition if it matches the given type name.\nReturns `NamedTuple` with `name`, `type`, `default` and `isconst` fields\nif it matches, otherwise return `nothing`.\n" function split_field_if_match(typename::Symbol, expr, default::Bool = false; source = nothing)
            begin
                begin
                    var"##cache#689" = nothing
                end
                var"##688" = expr
                if var"##688" isa Expr
                    if begin
                                if var"##cache#689" === nothing
                                    var"##cache#689" = Some(((var"##688").head, (var"##688").args))
                                end
                                var"##690" = (var"##cache#689").value
                                var"##690" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##690"[1] == :const && (begin
                                        var"##691" = var"##690"[2]
                                        var"##691" isa AbstractArray
                                    end && (length(var"##691") === 1 && (begin
                                                begin
                                                    var"##cache#693" = nothing
                                                end
                                                var"##692" = var"##691"[1]
                                                var"##692" isa Expr
                                            end && (begin
                                                    if var"##cache#693" === nothing
                                                        var"##cache#693" = Some(((var"##692").head, (var"##692").args))
                                                    end
                                                    var"##694" = (var"##cache#693").value
                                                    var"##694" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##694"[1] == :(=) && (begin
                                                            var"##695" = var"##694"[2]
                                                            var"##695" isa AbstractArray
                                                        end && (length(var"##695") === 2 && (begin
                                                                    begin
                                                                        var"##cache#697" = nothing
                                                                    end
                                                                    var"##696" = var"##695"[1]
                                                                    var"##696" isa Expr
                                                                end && (begin
                                                                        if var"##cache#697" === nothing
                                                                            var"##cache#697" = Some(((var"##696").head, (var"##696").args))
                                                                        end
                                                                        var"##698" = (var"##cache#697").value
                                                                        var"##698" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                    end && (var"##698"[1] == :(::) && (begin
                                                                                var"##699" = var"##698"[2]
                                                                                var"##699" isa AbstractArray
                                                                            end && (length(var"##699") === 2 && (begin
                                                                                        var"##700" = var"##699"[1]
                                                                                        var"##700" isa Symbol
                                                                                    end && begin
                                                                                        var"##701" = var"##699"[2]
                                                                                        var"##702" = var"##695"[2]
                                                                                        true
                                                                                    end))))))))))))))
                        value = var"##702"
                        type = var"##701"
                        name = var"##700"
                        var"##return#686" = begin
                                default && return (; name, type, isconst = true, default = value)
                                throw(SyntaxError("default value syntax is not allowed", source))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#687#739")))
                    end
                    if begin
                                var"##703" = (var"##cache#689").value
                                var"##703" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##703"[1] == :const && (begin
                                        var"##704" = var"##703"[2]
                                        var"##704" isa AbstractArray
                                    end && (length(var"##704") === 1 && (begin
                                                begin
                                                    var"##cache#706" = nothing
                                                end
                                                var"##705" = var"##704"[1]
                                                var"##705" isa Expr
                                            end && (begin
                                                    if var"##cache#706" === nothing
                                                        var"##cache#706" = Some(((var"##705").head, (var"##705").args))
                                                    end
                                                    var"##707" = (var"##cache#706").value
                                                    var"##707" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##707"[1] == :(=) && (begin
                                                            var"##708" = var"##707"[2]
                                                            var"##708" isa AbstractArray
                                                        end && (length(var"##708") === 2 && (begin
                                                                    var"##709" = var"##708"[1]
                                                                    var"##709" isa Symbol
                                                                end && begin
                                                                    var"##710" = var"##708"[2]
                                                                    true
                                                                end)))))))))
                        value = var"##710"
                        name = var"##709"
                        var"##return#686" = begin
                                default && return (; name, type = Any, isconst = true, default = value)
                                throw(SyntaxError("default value syntax is not allowed", source))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#687#739")))
                    end
                    if begin
                                var"##711" = (var"##cache#689").value
                                var"##711" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##711"[1] == :(=) && (begin
                                        var"##712" = var"##711"[2]
                                        var"##712" isa AbstractArray
                                    end && (length(var"##712") === 2 && (begin
                                                begin
                                                    var"##cache#714" = nothing
                                                end
                                                var"##713" = var"##712"[1]
                                                var"##713" isa Expr
                                            end && (begin
                                                    if var"##cache#714" === nothing
                                                        var"##cache#714" = Some(((var"##713").head, (var"##713").args))
                                                    end
                                                    var"##715" = (var"##cache#714").value
                                                    var"##715" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##715"[1] == :(::) && (begin
                                                            var"##716" = var"##715"[2]
                                                            var"##716" isa AbstractArray
                                                        end && (length(var"##716") === 2 && (begin
                                                                    var"##717" = var"##716"[1]
                                                                    var"##717" isa Symbol
                                                                end && begin
                                                                    var"##718" = var"##716"[2]
                                                                    var"##719" = var"##712"[2]
                                                                    true
                                                                end)))))))))
                        value = var"##719"
                        type = var"##718"
                        name = var"##717"
                        var"##return#686" = begin
                                default && return (; name, type, isconst = false, default = value)
                                throw(SyntaxError("default value syntax is not allowed", source))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#687#739")))
                    end
                    if begin
                                var"##720" = (var"##cache#689").value
                                var"##720" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##720"[1] == :(=) && (begin
                                        var"##721" = var"##720"[2]
                                        var"##721" isa AbstractArray
                                    end && (length(var"##721") === 2 && (begin
                                                var"##722" = var"##721"[1]
                                                var"##722" isa Symbol
                                            end && begin
                                                var"##723" = var"##721"[2]
                                                true
                                            end))))
                        value = var"##723"
                        name = var"##722"
                        var"##return#686" = begin
                                default && return (; name, type = Any, isconst = false, default = value)
                                throw(SyntaxError("default value syntax is not allowed", source))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#687#739")))
                    end
                    if begin
                                var"##724" = (var"##cache#689").value
                                var"##724" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##724"[1] == :const && (begin
                                        var"##725" = var"##724"[2]
                                        var"##725" isa AbstractArray
                                    end && (length(var"##725") === 1 && (begin
                                                begin
                                                    var"##cache#727" = nothing
                                                end
                                                var"##726" = var"##725"[1]
                                                var"##726" isa Expr
                                            end && (begin
                                                    if var"##cache#727" === nothing
                                                        var"##cache#727" = Some(((var"##726").head, (var"##726").args))
                                                    end
                                                    var"##728" = (var"##cache#727").value
                                                    var"##728" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##728"[1] == :(::) && (begin
                                                            var"##729" = var"##728"[2]
                                                            var"##729" isa AbstractArray
                                                        end && (length(var"##729") === 2 && (begin
                                                                    var"##730" = var"##729"[1]
                                                                    var"##730" isa Symbol
                                                                end && begin
                                                                    var"##731" = var"##729"[2]
                                                                    true
                                                                end)))))))))
                        type = var"##731"
                        name = var"##730"
                        var"##return#686" = begin
                                default && return (; name, type, isconst = true, default = no_default)
                                return (; name, type, isconst = true)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#687#739")))
                    end
                    if begin
                                var"##732" = (var"##cache#689").value
                                var"##732" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##732"[1] == :const && (begin
                                        var"##733" = var"##732"[2]
                                        var"##733" isa AbstractArray
                                    end && (length(var"##733") === 1 && begin
                                            var"##734" = var"##733"[1]
                                            var"##734" isa Symbol
                                        end)))
                        name = var"##734"
                        var"##return#686" = begin
                                default && return (; name, type = Any, isconst = true, default = no_default)
                                return (; name, type = Any, isconst = true)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#687#739")))
                    end
                    if begin
                                var"##735" = (var"##cache#689").value
                                var"##735" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##735"[1] == :(::) && (begin
                                        var"##736" = var"##735"[2]
                                        var"##736" isa AbstractArray
                                    end && (length(var"##736") === 2 && (begin
                                                var"##737" = var"##736"[1]
                                                var"##737" isa Symbol
                                            end && begin
                                                var"##738" = var"##736"[2]
                                                true
                                            end))))
                        type = var"##738"
                        name = var"##737"
                        var"##return#686" = begin
                                default && return (; name, type, isconst = false, default = no_default)
                                return (; name, type, isconst = false)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#687#739")))
                    end
                end
                if var"##688" isa Symbol
                    begin
                        name = var"##688"
                        var"##return#686" = begin
                                default && return (; name, type = Any, isconst = false, default = no_default)
                                return (; name, type = Any, isconst = false)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#687#739")))
                    end
                end
                if var"##688" isa String
                    begin
                        var"##return#686" = begin
                                return expr
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#687#739")))
                    end
                end
                if var"##688" isa LineNumberNode
                    begin
                        var"##return#686" = begin
                                return expr
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#687#739")))
                    end
                end
                if is_function(expr)
                    var"##return#686" = begin
                            if name_only(expr) === typename
                                return JLFunction(expr)
                            else
                                return expr
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#687#739")))
                end
                begin
                    var"##return#686" = begin
                            return expr
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#687#739")))
                end
                error("matching non-exhaustive, at #= none:169 =#")
                $(Expr(:symboliclabel, Symbol("####final#687#739")))
                var"##return#686"
            end
        end
