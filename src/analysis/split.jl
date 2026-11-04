
    #= none:1 =# Core.@doc "    split_doc(ex::Expr) -> line, doc, expr\n\nSplit doc string from given expression.\n" function split_doc(ex)
            begin
                begin
                    var"##cache#435" = nothing
                end
                var"##434" = ex
                if var"##434" isa Expr
                    if begin
                                if var"##cache#435" === nothing
                                    var"##cache#435" = Some(((var"##434").head, (var"##434").args))
                                end
                                var"##436" = (var"##cache#435").value
                                var"##436" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##436"[1] == :macrocall && (begin
                                        var"##437" = var"##436"[2]
                                        var"##437" isa AbstractArray
                                    end && (length(var"##437") === 4 && (begin
                                                var"##438" = var"##437"[1]
                                                var"##438" == GlobalRef(Core, Symbol("@doc"))
                                            end && begin
                                                var"##439" = var"##437"[2]
                                                var"##440" = var"##437"[3]
                                                var"##441" = var"##437"[4]
                                                true
                                            end))))
                        line = var"##439"
                        expr = var"##441"
                        doc = var"##440"
                        var"##return#432" = begin
                                return (line, doc, expr)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#433#462")))
                    end
                    if begin
                                var"##442" = (var"##cache#435").value
                                var"##442" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##442"[1] == :macrocall && (begin
                                        var"##443" = var"##442"[2]
                                        var"##443" isa AbstractArray
                                    end && (length(var"##443") === 4 && (begin
                                                var"##444" = var"##443"[1]
                                                var"##444" == Symbol("@doc")
                                            end && begin
                                                var"##445" = var"##443"[2]
                                                var"##446" = var"##443"[3]
                                                var"##447" = var"##443"[4]
                                                true
                                            end))))
                        line = var"##445"
                        expr = var"##447"
                        doc = var"##446"
                        var"##return#432" = begin
                                return (line, doc, expr)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#433#462")))
                    end
                    if begin
                                var"##448" = (var"##cache#435").value
                                var"##448" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##448"[1] == :macrocall && (begin
                                        var"##449" = var"##448"[2]
                                        var"##449" isa AbstractArray
                                    end && (length(var"##449") === 4 && (begin
                                                begin
                                                    var"##cache#451" = nothing
                                                end
                                                var"##450" = var"##449"[1]
                                                var"##450" isa Expr
                                            end && (begin
                                                    if var"##cache#451" === nothing
                                                        var"##cache#451" = Some(((var"##450").head, (var"##450").args))
                                                    end
                                                    var"##452" = (var"##cache#451").value
                                                    var"##452" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##452"[1] == :. && (begin
                                                            var"##453" = var"##452"[2]
                                                            var"##453" isa AbstractArray
                                                        end && (length(var"##453") === 2 && (var"##453"[1] == :Core && (begin
                                                                        var"##454" = var"##453"[2]
                                                                        var"##454" == QuoteNode(Symbol("@doc"))
                                                                    end && begin
                                                                        var"##455" = var"##449"[2]
                                                                        var"##456" = var"##449"[3]
                                                                        var"##457" = var"##449"[4]
                                                                        true
                                                                    end))))))))))
                        line = var"##455"
                        expr = var"##457"
                        doc = var"##456"
                        var"##return#432" = begin
                                return (line, doc, expr)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#433#462")))
                    end
                    if begin
                                var"##458" = (var"##cache#435").value
                                var"##458" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##458"[1] == :block && (begin
                                        var"##459" = var"##458"[2]
                                        var"##459" isa AbstractArray
                                    end && (length(var"##459") === 2 && (begin
                                                var"##460" = var"##459"[1]
                                                var"##460" isa LineNumberNode
                                            end && begin
                                                var"##461" = var"##459"[2]
                                                true
                                            end))))
                        stmt = var"##461"
                        var"##return#432" = begin
                                (line, doc, expr) = split_doc(stmt)
                                return (line, doc, expr)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#433#462")))
                    end
                end
                begin
                    var"##return#432" = begin
                            return (nothing, nothing, ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#433#462")))
                end
                error("matching non-exhaustive, at #= none:7 =#")
                $(Expr(:symboliclabel, Symbol("####final#433#462")))
                var"##return#432"
            end
        end
    #= none:24 =# Core.@doc "    split_function(ex::Expr) -> head, call, body\n\nSplit function head declaration with function body.\n" function split_function(ex; source = nothing)
            ret = split_function_nothrow(ex)
            isnothing(ret) && throw(SyntaxError("expect a function expr, got $(ex)", source))
            ret
        end
    function split_function_nothrow(ex)
        let
            begin
                var"##cache#466" = nothing
            end
            var"##return#463" = nothing
            var"##465" = ex
            if var"##465" isa Expr
                if begin
                            if var"##cache#466" === nothing
                                var"##cache#466" = Some(((var"##465").head, (var"##465").args))
                            end
                            var"##467" = (var"##cache#466").value
                            var"##467" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##467"[1] == :function && (begin
                                    var"##468" = var"##467"[2]
                                    var"##468" isa AbstractArray
                                end && (length(var"##468") === 2 && begin
                                        var"##469" = var"##468"[1]
                                        var"##470" = var"##468"[2]
                                        true
                                    end)))
                    var"##return#463" = let call = var"##469", body = var"##470"
                            (:function, call, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#464#483")))
                end
                if begin
                            var"##471" = (var"##cache#466").value
                            var"##471" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##471"[1] == :function && (begin
                                    var"##472" = var"##471"[2]
                                    var"##472" isa AbstractArray
                                end && (length(var"##472") === 2 && begin
                                        var"##473" = var"##472"[1]
                                        var"##474" = var"##472"[2]
                                        true
                                    end)))
                    var"##return#463" = let call = var"##473", body = var"##474"
                            (:function, call, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#464#483")))
                end
                if begin
                            var"##475" = (var"##cache#466").value
                            var"##475" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##475"[1] == :(=) && (begin
                                    var"##476" = var"##475"[2]
                                    var"##476" isa AbstractArray
                                end && (length(var"##476") === 2 && begin
                                        var"##477" = var"##476"[1]
                                        var"##478" = var"##476"[2]
                                        true
                                    end)))
                    var"##return#463" = let call = var"##477", body = var"##478"
                            let
                                begin
                                    var"##cache#487" = nothing
                                end
                                var"##return#484" = nothing
                                var"##486" = call
                                if var"##486" isa Expr
                                    if begin
                                                if var"##cache#487" === nothing
                                                    var"##cache#487" = Some(((var"##486").head, (var"##486").args))
                                                end
                                                var"##488" = (var"##cache#487").value
                                                var"##488" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##488"[1] == :call && (begin
                                                        var"##489" = var"##488"[2]
                                                        var"##489" isa AbstractArray
                                                    end && ((ndims(var"##489") === 1 && length(var"##489") >= 1) && begin
                                                            var"##490" = var"##489"[1]
                                                            var"##491" = SubArray(var"##489", (2:length(var"##489"),))
                                                            true
                                                        end)))
                                        var"##return#484" = let f = var"##490", args = var"##491"
                                                true
                                            end
                                        $(Expr(:symbolicgoto, Symbol("####final#485#524")))
                                    end
                                    if begin
                                                var"##492" = (var"##cache#487").value
                                                var"##492" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##492"[1] == :(::) && (begin
                                                        var"##493" = var"##492"[2]
                                                        var"##493" isa AbstractArray
                                                    end && (length(var"##493") === 2 && (begin
                                                                begin
                                                                    var"##cache#495" = nothing
                                                                end
                                                                var"##494" = var"##493"[1]
                                                                var"##494" isa Expr
                                                            end && (begin
                                                                    if var"##cache#495" === nothing
                                                                        var"##cache#495" = Some(((var"##494").head, (var"##494").args))
                                                                    end
                                                                    var"##496" = (var"##cache#495").value
                                                                    var"##496" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##496"[1] == :call && (begin
                                                                            var"##497" = var"##496"[2]
                                                                            var"##497" isa AbstractArray
                                                                        end && ((ndims(var"##497") === 1 && length(var"##497") >= 1) && begin
                                                                                var"##498" = var"##497"[1]
                                                                                var"##499" = SubArray(var"##497", (2:length(var"##497"),))
                                                                                var"##500" = var"##493"[2]
                                                                                true
                                                                            end))))))))
                                        var"##return#484" = let f = var"##498", args = var"##499", rettype = var"##500"
                                                true
                                            end
                                        $(Expr(:symbolicgoto, Symbol("####final#485#524")))
                                    end
                                    if begin
                                                var"##501" = (var"##cache#487").value
                                                var"##501" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##501"[1] == :where && (begin
                                                        var"##502" = var"##501"[2]
                                                        var"##502" isa AbstractArray
                                                    end && ((ndims(var"##502") === 1 && length(var"##502") >= 1) && (begin
                                                                begin
                                                                    var"##cache#504" = nothing
                                                                end
                                                                var"##503" = var"##502"[1]
                                                                var"##503" isa Expr
                                                            end && (begin
                                                                    if var"##cache#504" === nothing
                                                                        var"##cache#504" = Some(((var"##503").head, (var"##503").args))
                                                                    end
                                                                    var"##505" = (var"##cache#504").value
                                                                    var"##505" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##505"[1] == :call && (begin
                                                                            var"##506" = var"##505"[2]
                                                                            var"##506" isa AbstractArray
                                                                        end && ((ndims(var"##506") === 1 && length(var"##506") >= 1) && begin
                                                                                var"##507" = var"##506"[1]
                                                                                var"##508" = SubArray(var"##506", (2:length(var"##506"),))
                                                                                var"##509" = SubArray(var"##502", (2:length(var"##502"),))
                                                                                true
                                                                            end))))))))
                                        var"##return#484" = let f = var"##507", params = var"##509", args = var"##508"
                                                true
                                            end
                                        $(Expr(:symbolicgoto, Symbol("####final#485#524")))
                                    end
                                    if begin
                                                var"##510" = (var"##cache#487").value
                                                var"##510" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##510"[1] == :where && (begin
                                                        var"##511" = var"##510"[2]
                                                        var"##511" isa AbstractArray
                                                    end && ((ndims(var"##511") === 1 && length(var"##511") >= 1) && (begin
                                                                begin
                                                                    var"##cache#513" = nothing
                                                                end
                                                                var"##512" = var"##511"[1]
                                                                var"##512" isa Expr
                                                            end && (begin
                                                                    if var"##cache#513" === nothing
                                                                        var"##cache#513" = Some(((var"##512").head, (var"##512").args))
                                                                    end
                                                                    var"##514" = (var"##cache#513").value
                                                                    var"##514" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                end && (var"##514"[1] == :(::) && (begin
                                                                            var"##515" = var"##514"[2]
                                                                            var"##515" isa AbstractArray
                                                                        end && (length(var"##515") === 2 && (begin
                                                                                    begin
                                                                                        var"##cache#517" = nothing
                                                                                    end
                                                                                    var"##516" = var"##515"[1]
                                                                                    var"##516" isa Expr
                                                                                end && (begin
                                                                                        if var"##cache#517" === nothing
                                                                                            var"##cache#517" = Some(((var"##516").head, (var"##516").args))
                                                                                        end
                                                                                        var"##518" = (var"##cache#517").value
                                                                                        var"##518" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                                    end && (var"##518"[1] == :call && (begin
                                                                                                var"##519" = var"##518"[2]
                                                                                                var"##519" isa AbstractArray
                                                                                            end && ((ndims(var"##519") === 1 && length(var"##519") >= 1) && begin
                                                                                                    var"##520" = var"##519"[1]
                                                                                                    var"##521" = SubArray(var"##519", (2:length(var"##519"),))
                                                                                                    var"##522" = var"##515"[2]
                                                                                                    var"##523" = SubArray(var"##511", (2:length(var"##511"),))
                                                                                                    true
                                                                                                end)))))))))))))
                                        var"##return#484" = let f = var"##520", params = var"##523", args = var"##521", rettype = var"##522"
                                                true
                                            end
                                        $(Expr(:symbolicgoto, Symbol("####final#485#524")))
                                    end
                                end
                                begin
                                    var"##return#484" = let
                                            return nothing
                                        end
                                    $(Expr(:symbolicgoto, Symbol("####final#485#524")))
                                end
                                error("matching non-exhaustive, at #= none:40 =#")
                                $(Expr(:symboliclabel, Symbol("####final#485#524")))
                                var"##return#484"
                            end
                            (:(=), call, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#464#483")))
                end
                if begin
                            var"##479" = (var"##cache#466").value
                            var"##479" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##479"[1] == :-> && (begin
                                    var"##480" = var"##479"[2]
                                    var"##480" isa AbstractArray
                                end && (length(var"##480") === 2 && begin
                                        var"##481" = var"##480"[1]
                                        var"##482" = var"##480"[2]
                                        true
                                    end)))
                    var"##return#463" = let call = var"##481", body = var"##482"
                            (:->, call, body)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#464#483")))
                end
            end
            begin
                var"##return#463" = let
                        nothing
                    end
                $(Expr(:symbolicgoto, Symbol("####final#464#483")))
            end
            error("matching non-exhaustive, at #= none:36 =#")
            $(Expr(:symboliclabel, Symbol("####final#464#483")))
            var"##return#463"
        end
    end
    #= none:54 =# Core.@doc "    split_function_head(ex::Expr) -> name, args, kw, whereparams, rettype\n\nSplit function head to name, arguments, keyword arguments and where parameters.\n" function split_function_head(ex::Expr; source = nothing)
            split_head_tuple = split_function_head_nothrow(ex)
            isnothing(split_head_tuple) && throw(SyntaxError("expect a function head, got $(ex)", source))
            split_head_tuple
        end
    #= none:65 =# Core.@doc "    split_kw_block_nothrow(ex::Expr) -> nothing, args, kw, nothing, nothing\n\nSplit the argument list of `(x; kw) -> body`, which Julia parses as a block holding `x` and `kw`.\nThe block also holds `LineNumberNode`s, which are ignored so that a block whose line numbers were\nremoved is split too. Return `nothing` when `ex` is no such block.\n" function split_kw_block_nothrow(ex::Expr)
            Meta.isexpr(ex, :block) || return nothing
            args = filter((x->begin
                            !(x isa LineNumberNode)
                        end), ex.args)
            length(args) == 2 || return nothing
            (x, kw) = args
            kw = if Meta.isexpr(kw, :(=), 2)
                    Expr(:kw, kw.args...)
                else
                    kw
                end
            return (nothing, Any[x], Any[kw], nothing, nothing)
        end
    function split_function_head_nothrow(ex::Expr)
        let
            begin
                var"##cache#528" = nothing
            end
            var"##return#525" = nothing
            var"##527" = ex
            if var"##527" isa Expr
                if begin
                            if var"##cache#528" === nothing
                                var"##cache#528" = Some(((var"##527").head, (var"##527").args))
                            end
                            var"##529" = (var"##cache#528").value
                            var"##529" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##529"[1] == :tuple && (begin
                                    var"##530" = var"##529"[2]
                                    var"##530" isa AbstractArray
                                end && ((ndims(var"##530") === 1 && length(var"##530") >= 1) && (begin
                                            begin
                                                var"##cache#532" = nothing
                                            end
                                            var"##531" = var"##530"[1]
                                            var"##531" isa Expr
                                        end && (begin
                                                if var"##cache#532" === nothing
                                                    var"##cache#532" = Some(((var"##531").head, (var"##531").args))
                                                end
                                                var"##533" = (var"##cache#532").value
                                                var"##533" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##533"[1] == :parameters && (begin
                                                        var"##534" = var"##533"[2]
                                                        var"##534" isa AbstractArray
                                                    end && ((ndims(var"##534") === 1 && length(var"##534") >= 0) && begin
                                                            var"##535" = SubArray(var"##534", (1:length(var"##534"),))
                                                            var"##536" = SubArray(var"##530", (2:length(var"##530"),))
                                                            true
                                                        end))))))))
                    var"##return#525" = let args = var"##536", kw = var"##535"
                            (nothing, args, kw, nothing, nothing)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#526#563")))
                end
                if begin
                            var"##537" = (var"##cache#528").value
                            var"##537" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##537"[1] == :tuple && (begin
                                    var"##538" = var"##537"[2]
                                    var"##538" isa AbstractArray
                                end && ((ndims(var"##538") === 1 && length(var"##538") >= 0) && begin
                                        var"##539" = SubArray(var"##538", (1:length(var"##538"),))
                                        true
                                    end)))
                    var"##return#525" = let args = var"##539"
                            (nothing, args, nothing, nothing, nothing)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#526#563")))
                end
                if begin
                            var"##540" = (var"##cache#528").value
                            var"##540" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##540"[1] == :call && (begin
                                    var"##541" = var"##540"[2]
                                    var"##541" isa AbstractArray
                                end && ((ndims(var"##541") === 1 && length(var"##541") >= 2) && (begin
                                            var"##542" = var"##541"[1]
                                            begin
                                                var"##cache#544" = nothing
                                            end
                                            var"##543" = var"##541"[2]
                                            var"##543" isa Expr
                                        end && (begin
                                                if var"##cache#544" === nothing
                                                    var"##cache#544" = Some(((var"##543").head, (var"##543").args))
                                                end
                                                var"##545" = (var"##cache#544").value
                                                var"##545" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##545"[1] == :parameters && (begin
                                                        var"##546" = var"##545"[2]
                                                        var"##546" isa AbstractArray
                                                    end && ((ndims(var"##546") === 1 && length(var"##546") >= 0) && begin
                                                            var"##547" = SubArray(var"##546", (1:length(var"##546"),))
                                                            var"##548" = SubArray(var"##541", (3:length(var"##541"),))
                                                            true
                                                        end))))))))
                    var"##return#525" = let name = var"##542", args = var"##548", kw = var"##547"
                            (name, args, kw, nothing, nothing)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#526#563")))
                end
                if begin
                            var"##549" = (var"##cache#528").value
                            var"##549" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##549"[1] == :call && (begin
                                    var"##550" = var"##549"[2]
                                    var"##550" isa AbstractArray
                                end && ((ndims(var"##550") === 1 && length(var"##550") >= 1) && begin
                                        var"##551" = var"##550"[1]
                                        var"##552" = SubArray(var"##550", (2:length(var"##550"),))
                                        true
                                    end)))
                    var"##return#525" = let name = var"##551", args = var"##552"
                            (name, args, nothing, nothing, nothing)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#526#563")))
                end
                if begin
                            var"##553" = (var"##cache#528").value
                            var"##553" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##553"[1] == :block && (begin
                                    var"##554" = var"##553"[2]
                                    var"##554" isa AbstractArray
                                end && (ndims(var"##554") === 1 && length(var"##554") >= 0)))
                    var"##return#525" = let
                            split_kw_block_nothrow(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#526#563")))
                end
                if begin
                            var"##555" = (var"##cache#528").value
                            var"##555" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##555"[1] == :(::) && (begin
                                    var"##556" = var"##555"[2]
                                    var"##556" isa AbstractArray
                                end && (length(var"##556") === 2 && (begin
                                            var"##557" = var"##556"[1]
                                            var"##557" isa Expr
                                        end && begin
                                            var"##558" = var"##556"[2]
                                            true
                                        end))))
                    var"##return#525" = let call = var"##557", rettype = var"##558"
                            sub_tuple = split_function_head_nothrow(call)
                            isnothing(sub_tuple) && return nothing
                            (name, args, kw, whereparams, _) = split_function_head_nothrow(call)
                            (name, args, kw, whereparams, rettype)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#526#563")))
                end
                if begin
                            var"##559" = (var"##cache#528").value
                            var"##559" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##559"[1] == :where && (begin
                                    var"##560" = var"##559"[2]
                                    var"##560" isa AbstractArray
                                end && ((ndims(var"##560") === 1 && length(var"##560") >= 1) && begin
                                        var"##561" = var"##560"[1]
                                        var"##562" = SubArray(var"##560", (2:length(var"##560"),))
                                        true
                                    end)))
                    var"##return#525" = let call = var"##561", whereparams = var"##562"
                            sub_tuple = split_function_head_nothrow(call)
                            isnothing(sub_tuple) && return nothing
                            (name, args, kw, _, rettype) = sub_tuple
                            (name, args, kw, whereparams, rettype)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#526#563")))
                end
            end
            begin
                var"##return#525" = let
                        nothing
                    end
                $(Expr(:symbolicgoto, Symbol("####final#526#563")))
            end
            error("matching non-exhaustive, at #= none:82 =#")
            $(Expr(:symboliclabel, Symbol("####final#526#563")))
            var"##return#525"
        end
    end
    split_function_head_nothrow(s::Symbol) = begin
            (nothing, Any[s], nothing, nothing, nothing)
        end
    #= none:105 =# Core.@doc "    split_anonymous_function_head(ex::Expr) -> nothing, args, kw, whereparams, rettype\n\nSplit anonymous function head to arguments, keyword arguments and where parameters.\n" function split_anonymous_function_head(ex::Expr; source = nothing)
            split_head_tuple = split_anonymous_function_head_nothrow(ex)
            isnothing(split_head_tuple) && throw(SyntaxError("expect an anonymous function head, got $(ex)", source))
            split_head_tuple
        end
    split_anonymous_function_head(ex::Symbol; source = nothing) = begin
            split_anonymous_function_head_nothrow(ex)
        end
    function split_anonymous_function_head_nothrow(ex::Expr)
        let
            begin
                var"##cache#567" = nothing
            end
            var"##return#564" = nothing
            var"##566" = ex
            if var"##566" isa Expr
                if begin
                            if var"##cache#567" === nothing
                                var"##cache#567" = Some(((var"##566").head, (var"##566").args))
                            end
                            var"##568" = (var"##cache#567").value
                            var"##568" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##568"[1] == :tuple && (begin
                                    var"##569" = var"##568"[2]
                                    var"##569" isa AbstractArray
                                end && ((ndims(var"##569") === 1 && length(var"##569") >= 1) && (begin
                                            begin
                                                var"##cache#571" = nothing
                                            end
                                            var"##570" = var"##569"[1]
                                            var"##570" isa Expr
                                        end && (begin
                                                if var"##cache#571" === nothing
                                                    var"##cache#571" = Some(((var"##570").head, (var"##570").args))
                                                end
                                                var"##572" = (var"##cache#571").value
                                                var"##572" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##572"[1] == :parameters && (begin
                                                        var"##573" = var"##572"[2]
                                                        var"##573" isa AbstractArray
                                                    end && ((ndims(var"##573") === 1 && length(var"##573") >= 0) && begin
                                                            var"##574" = SubArray(var"##573", (1:length(var"##573"),))
                                                            var"##575" = SubArray(var"##569", (2:length(var"##569"),))
                                                            true
                                                        end))))))))
                    var"##return#564" = let args = var"##575", kw = var"##574"
                            (nothing, args, kw, nothing, nothing)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#565#596")))
                end
                if begin
                            var"##576" = (var"##cache#567").value
                            var"##576" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##576"[1] == :tuple && (begin
                                    var"##577" = var"##576"[2]
                                    var"##577" isa AbstractArray
                                end && ((ndims(var"##577") === 1 && length(var"##577") >= 0) && begin
                                        var"##578" = SubArray(var"##577", (1:length(var"##577"),))
                                        true
                                    end)))
                    var"##return#564" = let args = var"##578"
                            (nothing, args, nothing, nothing, nothing)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#565#596")))
                end
                if begin
                            var"##579" = (var"##cache#567").value
                            var"##579" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##579"[1] == :block && (begin
                                    var"##580" = var"##579"[2]
                                    var"##580" isa AbstractArray
                                end && (ndims(var"##580") === 1 && length(var"##580") >= 0)))
                    var"##return#564" = let
                            split_kw_block_nothrow(ex)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#565#596")))
                end
                if begin
                            var"##581" = (var"##cache#567").value
                            var"##581" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##581"[1] == :(::) && (begin
                                    var"##582" = var"##581"[2]
                                    var"##582" isa AbstractArray
                                end && (length(var"##582") === 2 && (begin
                                            var"##583" = var"##582"[1]
                                            var"##583" isa Expr
                                        end && begin
                                            var"##584" = var"##582"[2]
                                            true
                                        end))))
                    var"##return#564" = let rettype = var"##584", fh = var"##583"
                            sub_tuple = split_anonymous_function_head_nothrow(fh)
                            isnothing(sub_tuple) && return nothing
                            (name, args, kw, whereparams, _) = sub_tuple
                            (name, args, kw, whereparams, rettype)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#565#596")))
                end
                if begin
                            var"##585" = (var"##cache#567").value
                            var"##585" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##585"[1] == :(::) && (begin
                                    var"##586" = var"##585"[2]
                                    var"##586" isa AbstractArray
                                end && (length(var"##586") === 2 && (begin
                                            var"##587" = var"##586"[1]
                                            var"##587" isa Symbol
                                        end && begin
                                            var"##588" = var"##586"[2]
                                            true
                                        end))))
                    var"##return#564" = let arg = var"##587", argtype = var"##588"
                            (nothing, Any[ex], nothing, nothing, nothing)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#565#596")))
                end
                if begin
                            var"##589" = (var"##cache#567").value
                            var"##589" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##589"[1] == :(::) && (begin
                                    var"##590" = var"##589"[2]
                                    var"##590" isa AbstractArray
                                end && (length(var"##590") === 1 && begin
                                        var"##591" = var"##590"[1]
                                        true
                                    end)))
                    var"##return#564" = let argtype = var"##591"
                            (nothing, Any[ex], nothing, nothing, nothing)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#565#596")))
                end
                if begin
                            var"##592" = (var"##cache#567").value
                            var"##592" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##592"[1] == :where && (begin
                                    var"##593" = var"##592"[2]
                                    var"##593" isa AbstractArray
                                end && ((ndims(var"##593") === 1 && length(var"##593") >= 1) && begin
                                        var"##594" = var"##593"[1]
                                        var"##595" = SubArray(var"##593", (2:length(var"##593"),))
                                        true
                                    end)))
                    var"##return#564" = let call = var"##594", whereparams = var"##595"
                            sub_tuple = split_anonymous_function_head_nothrow(call)
                            isnothing(sub_tuple) && return nothing
                            (name, args, kw, _, rettype) = sub_tuple
                            (name, args, kw, whereparams, rettype)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#565#596")))
                end
            end
            begin
                var"##return#564" = let
                        nothing
                    end
                $(Expr(:symbolicgoto, Symbol("####final#565#596")))
            end
            error("matching non-exhaustive, at #= none:120 =#")
            $(Expr(:symboliclabel, Symbol("####final#565#596")))
            var"##return#564"
        end
    end
    split_anonymous_function_head_nothrow(s::Symbol) = begin
            (nothing, Any[s], nothing, nothing, nothing)
        end
    #= none:143 =# Core.@doc "    split_struct_name(ex::Expr) -> name, typevars, supertype\n\nSplit the name, type parameters and supertype definition from `struct`\ndeclaration head.\n" function split_struct_name(#= none:149 =# @nospecialize(ex); source = nothing)
            return let
                    begin
                        var"##cache#600" = nothing
                    end
                    var"##return#597" = nothing
                    var"##599" = ex
                    if var"##599" isa Expr
                        if begin
                                    if var"##cache#600" === nothing
                                        var"##cache#600" = Some(((var"##599").head, (var"##599").args))
                                    end
                                    var"##601" = (var"##cache#600").value
                                    var"##601" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##601"[1] == :curly && (begin
                                            var"##602" = var"##601"[2]
                                            var"##602" isa AbstractArray
                                        end && ((ndims(var"##602") === 1 && length(var"##602") >= 1) && begin
                                                var"##603" = var"##602"[1]
                                                var"##604" = SubArray(var"##602", (2:length(var"##602"),))
                                                true
                                            end)))
                            var"##return#597" = let typevars = var"##604", name = var"##603"
                                    (name, typevars, nothing)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#598#618")))
                        end
                        if begin
                                    var"##605" = (var"##cache#600").value
                                    var"##605" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##605"[1] == :<: && (begin
                                            var"##606" = var"##605"[2]
                                            var"##606" isa AbstractArray
                                        end && (length(var"##606") === 2 && (begin
                                                    begin
                                                        var"##cache#608" = nothing
                                                    end
                                                    var"##607" = var"##606"[1]
                                                    var"##607" isa Expr
                                                end && (begin
                                                        if var"##cache#608" === nothing
                                                            var"##cache#608" = Some(((var"##607").head, (var"##607").args))
                                                        end
                                                        var"##609" = (var"##cache#608").value
                                                        var"##609" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                    end && (var"##609"[1] == :curly && (begin
                                                                var"##610" = var"##609"[2]
                                                                var"##610" isa AbstractArray
                                                            end && ((ndims(var"##610") === 1 && length(var"##610") >= 1) && begin
                                                                    var"##611" = var"##610"[1]
                                                                    var"##612" = SubArray(var"##610", (2:length(var"##610"),))
                                                                    var"##613" = var"##606"[2]
                                                                    true
                                                                end))))))))
                            var"##return#597" = let typevars = var"##612", type = var"##613", name = var"##611"
                                    (name, typevars, type)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#598#618")))
                        end
                        if begin
                                    var"##614" = (var"##cache#600").value
                                    var"##614" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##614"[1] == :<: && (begin
                                            var"##615" = var"##614"[2]
                                            var"##615" isa AbstractArray
                                        end && (length(var"##615") === 2 && begin
                                                var"##616" = var"##615"[1]
                                                var"##617" = var"##615"[2]
                                                true
                                            end)))
                            var"##return#597" = let type = var"##617", name = var"##616"
                                    (name, [], type)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#598#618")))
                        end
                    end
                    if var"##599" isa Symbol
                        begin
                            var"##return#597" = let
                                    (ex, [], nothing)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#598#618")))
                        end
                    end
                    begin
                        var"##return#597" = let
                                throw(SyntaxError("expect struct got $(ex)", source))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#598#618")))
                    end
                    error("matching non-exhaustive, at #= none:150 =#")
                    $(Expr(:symboliclabel, Symbol("####final#598#618")))
                    var"##return#597"
                end
        end
    #= none:159 =# Core.@doc "    split_struct(ex::Expr) -> ismutable, name, typevars, supertype, body\n\nSplit struct definition head and body.\n" function split_struct(ex::Expr; source = nothing)
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
    #= none:216 =# Core.@doc "    uninferrable_typevars(def::Union{JLStruct, JLKwStruct}; leading_inferable::Bool=true)\n\nReturn the type variables that are not inferrable in given struct definition.\n" function uninferrable_typevars(def::Union{JLStruct, JLKwStruct}; leading_inferable::Bool = true)
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
            for T = typevars[idx + 1:var"end"]
                any(map((f->begin
                                    has_symbol(f, T)
                                end), field_types)) || push!(uninferrable, T)
            end
            return uninferrable
        end
    #= none:241 =# Core.@doc "    split_field_if_match(typename::Symbol, expr, default::Bool=false)\n\nSplit the field definition if it matches the given type name.\nReturns `NamedTuple` with `name`, `type`, `default` and `isconst` fields\nif it matches, otherwise return `nothing`.\n" function split_field_if_match(typename::Symbol, expr, default::Bool = false; source = nothing)
            begin
                begin
                    var"##cache#622" = nothing
                end
                var"##621" = expr
                if var"##621" isa LineNumberNode
                    begin
                        var"##return#619" = begin
                                return expr
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#620#672")))
                    end
                end
                if var"##621" isa String
                    begin
                        var"##return#619" = begin
                                return expr
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#620#672")))
                    end
                end
                if var"##621" isa Expr
                    if begin
                                if var"##cache#622" === nothing
                                    var"##cache#622" = Some(((var"##621").head, (var"##621").args))
                                end
                                var"##623" = (var"##cache#622").value
                                var"##623" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##623"[1] == :const && (begin
                                        var"##624" = var"##623"[2]
                                        var"##624" isa AbstractArray
                                    end && (length(var"##624") === 1 && (begin
                                                begin
                                                    var"##cache#626" = nothing
                                                end
                                                var"##625" = var"##624"[1]
                                                var"##625" isa Expr
                                            end && (begin
                                                    if var"##cache#626" === nothing
                                                        var"##cache#626" = Some(((var"##625").head, (var"##625").args))
                                                    end
                                                    var"##627" = (var"##cache#626").value
                                                    var"##627" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##627"[1] == :(=) && (begin
                                                            var"##628" = var"##627"[2]
                                                            var"##628" isa AbstractArray
                                                        end && (length(var"##628") === 2 && (begin
                                                                    begin
                                                                        var"##cache#630" = nothing
                                                                    end
                                                                    var"##629" = var"##628"[1]
                                                                    var"##629" isa Expr
                                                                end && (begin
                                                                        if var"##cache#630" === nothing
                                                                            var"##cache#630" = Some(((var"##629").head, (var"##629").args))
                                                                        end
                                                                        var"##631" = (var"##cache#630").value
                                                                        var"##631" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                                    end && (var"##631"[1] == :(::) && (begin
                                                                                var"##632" = var"##631"[2]
                                                                                var"##632" isa AbstractArray
                                                                            end && (length(var"##632") === 2 && (begin
                                                                                        var"##633" = var"##632"[1]
                                                                                        var"##633" isa Symbol
                                                                                    end && begin
                                                                                        var"##634" = var"##632"[2]
                                                                                        var"##635" = var"##628"[2]
                                                                                        true
                                                                                    end))))))))))))))
                        value = var"##635"
                        type = var"##634"
                        name = var"##633"
                        var"##return#619" = begin
                                default && return (; name, type, isconst = true, default = value)
                                throw(SyntaxError("default value syntax is not allowed", source))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#620#672")))
                    end
                    if begin
                                var"##636" = (var"##cache#622").value
                                var"##636" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##636"[1] == :const && (begin
                                        var"##637" = var"##636"[2]
                                        var"##637" isa AbstractArray
                                    end && (length(var"##637") === 1 && (begin
                                                begin
                                                    var"##cache#639" = nothing
                                                end
                                                var"##638" = var"##637"[1]
                                                var"##638" isa Expr
                                            end && (begin
                                                    if var"##cache#639" === nothing
                                                        var"##cache#639" = Some(((var"##638").head, (var"##638").args))
                                                    end
                                                    var"##640" = (var"##cache#639").value
                                                    var"##640" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##640"[1] == :(=) && (begin
                                                            var"##641" = var"##640"[2]
                                                            var"##641" isa AbstractArray
                                                        end && (length(var"##641") === 2 && (begin
                                                                    var"##642" = var"##641"[1]
                                                                    var"##642" isa Symbol
                                                                end && begin
                                                                    var"##643" = var"##641"[2]
                                                                    true
                                                                end)))))))))
                        value = var"##643"
                        name = var"##642"
                        var"##return#619" = begin
                                default && return (; name, type = Any, isconst = true, default = value)
                                throw(SyntaxError("default value syntax is not allowed", source))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#620#672")))
                    end
                    if begin
                                var"##644" = (var"##cache#622").value
                                var"##644" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##644"[1] == :(=) && (begin
                                        var"##645" = var"##644"[2]
                                        var"##645" isa AbstractArray
                                    end && (length(var"##645") === 2 && (begin
                                                begin
                                                    var"##cache#647" = nothing
                                                end
                                                var"##646" = var"##645"[1]
                                                var"##646" isa Expr
                                            end && (begin
                                                    if var"##cache#647" === nothing
                                                        var"##cache#647" = Some(((var"##646").head, (var"##646").args))
                                                    end
                                                    var"##648" = (var"##cache#647").value
                                                    var"##648" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##648"[1] == :(::) && (begin
                                                            var"##649" = var"##648"[2]
                                                            var"##649" isa AbstractArray
                                                        end && (length(var"##649") === 2 && (begin
                                                                    var"##650" = var"##649"[1]
                                                                    var"##650" isa Symbol
                                                                end && begin
                                                                    var"##651" = var"##649"[2]
                                                                    var"##652" = var"##645"[2]
                                                                    true
                                                                end)))))))))
                        value = var"##652"
                        type = var"##651"
                        name = var"##650"
                        var"##return#619" = begin
                                default && return (; name, type, isconst = false, default = value)
                                throw(SyntaxError("default value syntax is not allowed", source))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#620#672")))
                    end
                    if begin
                                var"##653" = (var"##cache#622").value
                                var"##653" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##653"[1] == :(=) && (begin
                                        var"##654" = var"##653"[2]
                                        var"##654" isa AbstractArray
                                    end && (length(var"##654") === 2 && (begin
                                                var"##655" = var"##654"[1]
                                                var"##655" isa Symbol
                                            end && begin
                                                var"##656" = var"##654"[2]
                                                true
                                            end))))
                        value = var"##656"
                        name = var"##655"
                        var"##return#619" = begin
                                default && return (; name, type = Any, isconst = false, default = value)
                                throw(SyntaxError("default value syntax is not allowed", source))
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#620#672")))
                    end
                    if begin
                                var"##657" = (var"##cache#622").value
                                var"##657" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##657"[1] == :const && (begin
                                        var"##658" = var"##657"[2]
                                        var"##658" isa AbstractArray
                                    end && (length(var"##658") === 1 && (begin
                                                begin
                                                    var"##cache#660" = nothing
                                                end
                                                var"##659" = var"##658"[1]
                                                var"##659" isa Expr
                                            end && (begin
                                                    if var"##cache#660" === nothing
                                                        var"##cache#660" = Some(((var"##659").head, (var"##659").args))
                                                    end
                                                    var"##661" = (var"##cache#660").value
                                                    var"##661" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                end && (var"##661"[1] == :(::) && (begin
                                                            var"##662" = var"##661"[2]
                                                            var"##662" isa AbstractArray
                                                        end && (length(var"##662") === 2 && (begin
                                                                    var"##663" = var"##662"[1]
                                                                    var"##663" isa Symbol
                                                                end && begin
                                                                    var"##664" = var"##662"[2]
                                                                    true
                                                                end)))))))))
                        type = var"##664"
                        name = var"##663"
                        var"##return#619" = begin
                                default && return (; name, type, isconst = true, default = no_default)
                                return (; name, type, isconst = true)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#620#672")))
                    end
                    if begin
                                var"##665" = (var"##cache#622").value
                                var"##665" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##665"[1] == :const && (begin
                                        var"##666" = var"##665"[2]
                                        var"##666" isa AbstractArray
                                    end && (length(var"##666") === 1 && begin
                                            var"##667" = var"##666"[1]
                                            var"##667" isa Symbol
                                        end)))
                        name = var"##667"
                        var"##return#619" = begin
                                default && return (; name, type = Any, isconst = true, default = no_default)
                                return (; name, type = Any, isconst = true)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#620#672")))
                    end
                    if begin
                                var"##668" = (var"##cache#622").value
                                var"##668" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                            end && (var"##668"[1] == :(::) && (begin
                                        var"##669" = var"##668"[2]
                                        var"##669" isa AbstractArray
                                    end && (length(var"##669") === 2 && (begin
                                                var"##670" = var"##669"[1]
                                                var"##670" isa Symbol
                                            end && begin
                                                var"##671" = var"##669"[2]
                                                true
                                            end))))
                        type = var"##671"
                        name = var"##670"
                        var"##return#619" = begin
                                default && return (; name, type, isconst = false, default = no_default)
                                return (; name, type, isconst = false)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#620#672")))
                    end
                end
                if var"##621" isa Symbol
                    begin
                        name = var"##621"
                        var"##return#619" = begin
                                default && return (; name, type = Any, isconst = false, default = no_default)
                                return (; name, type = Any, isconst = false)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#620#672")))
                    end
                end
                if is_function(expr)
                    var"##return#619" = begin
                            if name_only(expr) === typename
                                return JLFunction(expr)
                            else
                                return expr
                            end
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#620#672")))
                end
                begin
                    var"##return#619" = begin
                            return expr
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#620#672")))
                end
                error("matching non-exhaustive, at #= none:249 =#")
                $(Expr(:symboliclabel, Symbol("####final#620#672")))
                var"##return#619"
            end
        end
    function split_signature(call::Expr)
        if Meta.isexpr(call, :where)
            Expr(:where, split_signature(call.args[1]), call.args[2:var"end"]...)
        elseif Meta.isexpr(call, :call)
            :(($Base).Tuple{($Base).typeof($(call.args[1])), $(arg2type.(call.args[2:var"end"])...)})
        elseif Meta.isexpr(call, :(::))
            return split_signature(call.args[1])
        else
            error("invalid signature: $(call)")
        end
    end
    function arg2type(arg)
        let
            begin
                var"##cache#676" = nothing
            end
            var"##return#673" = nothing
            var"##675" = arg
            if var"##675" isa Symbol
                begin
                    var"##return#673" = let
                            Any
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#674#696")))
                end
            end
            if var"##675" isa Expr
                if begin
                            if var"##cache#676" === nothing
                                var"##cache#676" = Some(((var"##675").head, (var"##675").args))
                            end
                            var"##677" = (var"##cache#676").value
                            var"##677" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##677"[1] == :(::) && (begin
                                    var"##678" = var"##677"[2]
                                    var"##678" isa AbstractArray
                                end && (length(var"##678") === 1 && begin
                                        var"##679" = var"##678"[1]
                                        true
                                    end)))
                    var"##return#673" = let type = var"##679"
                            type
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#674#696")))
                end
                if begin
                            var"##680" = (var"##cache#676").value
                            var"##680" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##680"[1] == :(::) && (begin
                                    var"##681" = var"##680"[2]
                                    var"##681" isa AbstractArray
                                end && (length(var"##681") === 2 && begin
                                        var"##682" = var"##681"[2]
                                        true
                                    end)))
                    var"##return#673" = let type = var"##682"
                            type
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#674#696")))
                end
                if begin
                            var"##683" = (var"##cache#676").value
                            var"##683" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##683"[1] == :... && (begin
                                    var"##684" = var"##683"[2]
                                    var"##684" isa AbstractArray
                                end && (length(var"##684") === 1 && (begin
                                            begin
                                                var"##cache#686" = nothing
                                            end
                                            var"##685" = var"##684"[1]
                                            var"##685" isa Expr
                                        end && (begin
                                                if var"##cache#686" === nothing
                                                    var"##cache#686" = Some(((var"##685").head, (var"##685").args))
                                                end
                                                var"##687" = (var"##cache#686").value
                                                var"##687" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                            end && (var"##687"[1] == :(::) && (begin
                                                        var"##688" = var"##687"[2]
                                                        var"##688" isa AbstractArray
                                                    end && (length(var"##688") === 2 && begin
                                                            var"##689" = var"##688"[2]
                                                            true
                                                        end))))))))
                    var"##return#673" = let type = var"##689"
                            Core._expr(:curly, Core._expr(:., Base, $(Expr(:copyast, :($(QuoteNode(:(:Vararg))))))), type)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#674#696")))
                end
                if begin
                            var"##690" = (var"##cache#676").value
                            var"##690" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##690"[1] == :... && (begin
                                    var"##691" = var"##690"[2]
                                    var"##691" isa AbstractArray
                                end && length(var"##691") === 1))
                    var"##return#673" = let
                            Core._expr(:curly, Core._expr(:., Base, $(Expr(:copyast, :($(QuoteNode(:(:Vararg))))))), Any)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#674#696")))
                end
                if begin
                            var"##692" = (var"##cache#676").value
                            var"##692" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                        end && (var"##692"[1] == :kw && (begin
                                    var"##693" = var"##692"[2]
                                    var"##693" isa AbstractArray
                                end && (length(var"##693") === 2 && begin
                                        var"##694" = var"##693"[1]
                                        var"##695" = var"##693"[2]
                                        true
                                    end)))
                    var"##return#673" = let arg = var"##694", value = var"##695"
                            arg2type(arg)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#674#696")))
                end
            end
            begin
                var"##return#673" = let
                        error("invalid argument type: $(arg)")
                    end
                $(Expr(:symbolicgoto, Symbol("####final#674#696")))
            end
            error("matching non-exhaustive, at #= none:300 =#")
            $(Expr(:symboliclabel, Symbol("####final#674#696")))
            var"##return#673"
        end
    end
