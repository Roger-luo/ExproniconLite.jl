begin
    #= none:2 =# Core.@doc "    eval_interp(m::Module, ex)\n\nevaluate the interpolation operator in `ex` inside given module `m`.\n" function eval_interp(m::Module, ex)
            ex isa Expr || return ex
            if ex.head === :$
                x = ex.args[1]
                if x isa Symbol && isdefined(m, x)
                    return Base.eval(m, x)
                else
                    return ex
                end
            end
            return Expr(ex.head, map((x->begin
                                eval_interp(m, x)
                            end), ex.args)...)
        end
    #= none:20 =# Core.@doc "    eval_literal(m::Module, ex)\n\nEvaluate the literal values and insert them back to the expression.\nThe literal value can be checked via [`is_literal`](@ref).\n" function eval_literal(m::Module, ex)
            ex isa Expr || return ex
            if ex.head === :call && all(is_literal, ex.args[2:end])
                return Base.eval(m, ex)
            end
            return Expr(ex.head, map((x->begin
                                eval_literal(m, x)
                            end), ex.args)...)
        end
    replace_symbol(x::Symbol, name::Symbol, value) = begin
            if x === name
                value
            else
                x
            end
        end
    replace_symbol(x, ::Symbol, value) = begin
            x
        end
    function replace_symbol(ex::Expr, name::Symbol, value)
        Expr(ex.head, map((x->begin
                        replace_symbol(x, name, value)
                    end), ex.args)...)
    end
    #= none:41 =# Core.@doc "    subtitute(ex::Expr, old=>new)\n\nSubtitute the old symbol `old` with `new`.\n" function subtitute(ex::Expr, replace::Pair)
            (name, value) = replace
            return replace_symbol(ex, name, value)
        end
    #= none:51 =# Core.@doc "    name_only(ex)\n\nRemove everything else leaving just names, currently supports\nfunction calls, type with type variables, subtype operator `<:`\nand type annotation `::`.\n\n# Example\n\n```julia\njulia> using Expronicon\n\njulia> name_only(:(sin(2)))\n:sin\n\njulia> name_only(:(Foo{Int}))\n:Foo\n\njulia> name_only(:(Foo{Int} <: Real))\n:Foo\n\njulia> name_only(:(x::Int))\n:x\n```\n" function name_only(#= none:76 =# @nospecialize(ex))
            ex isa Symbol && return ex
            ex isa QuoteNode && return ex.value
            ex isa Expr || error("unsupported expression $(ex)")
            ex.head in [:call, :curly, :<:, :(::), :where, :function, :kw, :(=), :->] && return name_only(ex.args[1])
            ex.head === :. && return name_only(ex.args[2])
            error("unsupported expression $(ex)")
        end
    #= none:85 =# Core.@doc "    rm_lineinfo(ex)\n\nRemove `LineNumberNode` in a given expression.\n\n!!! tips\n\n    the `LineNumberNode` inside macro calls won't be removed since\n    the `macrocall` expression requires a `LineNumberNode`. See also\n    [issues/#9](https://github.com/Roger-luo/Expronicon.jl/issues/9).\n" function rm_lineinfo(ex)
            let
                var"##cache#730" = nothing
                var"##return#727" = nothing
                var"##729" = ex
                if var"##729" isa Expr
                    if begin
                                if var"##cache#730" === nothing
                                    var"##cache#730" = Some(((var"##729").head, (var"##729").args))
                                end
                                var"##731" = (var"##cache#730").value
                                var"##731" isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (var"##731"[1] == :macrocall && (begin
                                        var"##732" = var"##731"[2]
                                        var"##732" isa AbstractArray
                                    end && ((ndims(var"##732") === 1 && length(var"##732") >= 2) && begin
                                            var"##733" = var"##732"[1]
                                            var"##734" = var"##732"[2]
                                            var"##735" = (SubArray)(var"##732", (3:length(var"##732"),))
                                            true
                                        end)))
                        var"##return#727" = let line = var"##734", name = var"##733", args = var"##735"
                                Expr(:macrocall, name, line, map(rm_lineinfo, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#728#740")))
                    end
                    if begin
                                var"##736" = (var"##cache#730").value
                                var"##736" isa Tuple{var1, var2} where {var2<:AbstractArray, var1}
                            end && (begin
                                    var"##737" = var"##736"[1]
                                    var"##738" = var"##736"[2]
                                    var"##738" isa AbstractArray
                                end && ((ndims(var"##738") === 1 && length(var"##738") >= 0) && begin
                                        var"##739" = (SubArray)(var"##738", (1:length(var"##738"),))
                                        true
                                    end))
                        var"##return#727" = let args = var"##739", head = var"##737"
                                Expr(head, map(rm_lineinfo, filter((x->begin
                                                    !(x isa LineNumberNode)
                                                end), args))...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#728#740")))
                    end
                end
                var"##return#727" = let
                        ex
                    end
                $(Expr(:symbolicgoto, Symbol("####final#728#740")))
                (error)("matching non-exhaustive, at #= none:97 =#")
                $(Expr(:symboliclabel, Symbol("####final#728#740")))
                var"##return#727"
            end
        end
    #= none:104 =# Core.@doc "    prettify(ex)\n\nPrettify given expression, remove all `LineNumberNode` and\nextra code blocks.\n\n!!! tips\n\n    the `LineNumberNode` inside macro calls won't be removed since\n    the `macrocall` expression requires a `LineNumberNode`. See also\n    [issues/#9](https://github.com/Roger-luo/Expronicon.jl/issues/9).\n" function prettify(ex)
            ex isa Expr || return ex
            for _ = 1:10
                curr = prettify_pass(ex)
                ex == curr && break
                ex = curr
            end
            return ex
        end
    function prettify_pass(ex)
        ex = rm_lineinfo(ex)
        ex = flatten_blocks(ex)
        ex = rm_nothing(ex)
        ex = rm_single_block(ex)
        return ex
    end
    #= none:134 =# Core.@doc "    flatten_blocks(ex)\n\nRemove hierachical expression blocks.\n" function flatten_blocks(ex)
            ex isa Expr || return ex
            ex.head === :block || return Expr(ex.head, map(_flatten_blocks, ex.args)...)
            has_block = any(ex.args) do x
                    x isa Expr && x.head === :block
                end
            if has_block
                return flatten_blocks(_flatten_blocks(ex))
            end
            return Expr(ex.head, map(flatten_blocks, ex.args)...)
        end
    function _flatten_blocks(ex)
        ex isa Expr || return ex
        ex.head === :block || return Expr(ex.head, map(flatten_blocks, ex.args)...)
        args = []
        for stmt = ex.args
            if stmt isa Expr && stmt.head === :block
                for each = stmt.args
                    push!(args, flatten_blocks(each))
                end
            else
                push!(args, flatten_blocks(stmt))
            end
        end
        return Expr(:block, args...)
    end
    #= none:169 =# Core.@doc "    rm_nothing(ex)\n\nRemove the constant value `nothing` in given expression `ex`.\n" function rm_nothing(ex)
            let
                var"##cache#744" = nothing
                var"##return#741" = nothing
                var"##743" = ex
                if var"##743" isa Expr
                    if begin
                                if var"##cache#744" === nothing
                                    var"##cache#744" = Some(((var"##743").head, (var"##743").args))
                                end
                                var"##745" = (var"##cache#744").value
                                var"##745" isa Tuple{Symbol, var2} where var2<:AbstractArray
                            end && (var"##745"[1] == :block && (begin
                                        var"##746" = var"##745"[2]
                                        var"##746" isa AbstractArray
                                    end && ((ndims(var"##746") === 1 && length(var"##746") >= 0) && begin
                                            var"##747" = (SubArray)(var"##746", (1:length(var"##746"),))
                                            true
                                        end)))
                        var"##return#741" = let args = var"##747"
                                Expr(:block, filter((x->begin
                                                x !== nothing
                                            end), args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#742#752")))
                    end
                    if begin
                                var"##748" = (var"##cache#744").value
                                var"##748" isa Tuple{var1, var2} where {var2<:AbstractArray, var1}
                            end && (begin
                                    var"##749" = var"##748"[1]
                                    var"##750" = var"##748"[2]
                                    var"##750" isa AbstractArray
                                end && ((ndims(var"##750") === 1 && length(var"##750") >= 0) && begin
                                        var"##751" = (SubArray)(var"##750", (1:length(var"##750"),))
                                        true
                                    end))
                        var"##return#741" = let args = var"##751", head = var"##749"
                                Expr(head, map(rm_nothing, args)...)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#742#752")))
                    end
                end
                var"##return#741" = let
                        ex
                    end
                $(Expr(:symbolicgoto, Symbol("####final#742#752")))
                (error)("matching non-exhaustive, at #= none:175 =#")
                $(Expr(:symboliclabel, Symbol("####final#742#752")))
                var"##return#741"
            end
        end
    function rm_single_block(ex)
        let
            var"##cache#756" = nothing
            var"##return#753" = nothing
            var"##755" = ex
            if var"##755" isa Expr
                if begin
                            if var"##cache#756" === nothing
                                var"##cache#756" = Some(((var"##755").head, (var"##755").args))
                            end
                            var"##757" = (var"##cache#756").value
                            var"##757" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##757"[1] == :(=) && (begin
                                    var"##758" = var"##757"[2]
                                    var"##758" isa AbstractArray
                                end && (ndims(var"##758") === 1 && length(var"##758") >= 0)))
                    var"##return#753" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#754#821")))
                end
                if begin
                            var"##759" = (var"##cache#756").value
                            var"##759" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##759"[1] == :-> && (begin
                                    var"##760" = var"##759"[2]
                                    var"##760" isa AbstractArray
                                end && (ndims(var"##760") === 1 && length(var"##760") >= 0)))
                    var"##return#753" = let
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#754#821")))
                end
                if begin
                            var"##761" = (var"##cache#756").value
                            var"##761" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##761"[1] == :quote && (begin
                                    var"##762" = var"##761"[2]
                                    var"##762" isa AbstractArray
                                end && ((ndims(var"##762") === 1 && length(var"##762") >= 0) && begin
                                        var"##763" = (SubArray)(var"##762", (1:length(var"##762"),))
                                        true
                                    end)))
                    var"##return#753" = let xs = var"##763"
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#754#821")))
                end
                if begin
                            var"##764" = (var"##cache#756").value
                            var"##764" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##764"[1] == :block && (begin
                                    var"##765" = var"##764"[2]
                                    var"##765" isa AbstractArray
                                end && (length(var"##765") === 1 && (begin
                                            var"##cache#767" = nothing
                                            var"##766" = var"##765"[1]
                                            var"##766" isa Expr
                                        end && (begin
                                                if var"##cache#767" === nothing
                                                    var"##cache#767" = Some(((var"##766").head, (var"##766").args))
                                                end
                                                var"##768" = (var"##cache#767").value
                                                var"##768" isa Tuple{Symbol, var2} where var2<:AbstractArray
                                            end && (var"##768"[1] == :quote && (begin
                                                        var"##769" = var"##768"[2]
                                                        var"##769" isa AbstractArray
                                                    end && ((ndims(var"##769") === 1 && length(var"##769") >= 0) && begin
                                                            var"##770" = (SubArray)(var"##769", (1:length(var"##769"),))
                                                            true
                                                        end))))))))
                    var"##return#753" = let xs = var"##770"
                            ex
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#754#821")))
                end
                if begin
                            var"##771" = (var"##cache#756").value
                            var"##771" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##771"[1] == :try && (begin
                                    var"##772" = var"##771"[2]
                                    var"##772" isa AbstractArray
                                end && (length(var"##772") === 4 && (begin
                                            var"##cache#774" = nothing
                                            var"##773" = var"##772"[1]
                                            var"##773" isa Expr
                                        end && (begin
                                                if var"##cache#774" === nothing
                                                    var"##cache#774" = Some(((var"##773").head, (var"##773").args))
                                                end
                                                var"##775" = (var"##cache#774").value
                                                var"##775" isa Tuple{Symbol, var2} where var2<:AbstractArray
                                            end && (var"##775"[1] == :block && (begin
                                                        var"##776" = var"##775"[2]
                                                        var"##776" isa AbstractArray
                                                    end && ((ndims(var"##776") === 1 && length(var"##776") >= 0) && (begin
                                                                var"##777" = (SubArray)(var"##776", (1:length(var"##776"),))
                                                                var"##772"[2] === false
                                                            end && (var"##772"[3] === false && (begin
                                                                        var"##cache#779" = nothing
                                                                        var"##778" = var"##772"[4]
                                                                        var"##778" isa Expr
                                                                    end && (begin
                                                                            if var"##cache#779" === nothing
                                                                                var"##cache#779" = Some(((var"##778").head, (var"##778").args))
                                                                            end
                                                                            var"##780" = (var"##cache#779").value
                                                                            var"##780" isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                                        end && (var"##780"[1] == :block && (begin
                                                                                    var"##781" = var"##780"[2]
                                                                                    var"##781" isa AbstractArray
                                                                                end && ((ndims(var"##781") === 1 && length(var"##781") >= 0) && begin
                                                                                        var"##782" = (SubArray)(var"##781", (1:length(var"##781"),))
                                                                                        true
                                                                                    end)))))))))))))))
                    var"##return#753" = let try_stmts = var"##777", finally_stmts = var"##782"
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), false, false, Expr(:block, rm_single_block.(finally_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#754#821")))
                end
                if begin
                            var"##783" = (var"##cache#756").value
                            var"##783" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##783"[1] == :try && (begin
                                    var"##784" = var"##783"[2]
                                    var"##784" isa AbstractArray
                                end && (length(var"##784") === 3 && (begin
                                            var"##cache#786" = nothing
                                            var"##785" = var"##784"[1]
                                            var"##785" isa Expr
                                        end && (begin
                                                if var"##cache#786" === nothing
                                                    var"##cache#786" = Some(((var"##785").head, (var"##785").args))
                                                end
                                                var"##787" = (var"##cache#786").value
                                                var"##787" isa Tuple{Symbol, var2} where var2<:AbstractArray
                                            end && (var"##787"[1] == :block && (begin
                                                        var"##788" = var"##787"[2]
                                                        var"##788" isa AbstractArray
                                                    end && ((ndims(var"##788") === 1 && length(var"##788") >= 0) && (begin
                                                                var"##789" = (SubArray)(var"##788", (1:length(var"##788"),))
                                                                var"##790" = var"##784"[2]
                                                                var"##cache#792" = nothing
                                                                var"##791" = var"##784"[3]
                                                                var"##791" isa Expr
                                                            end && (begin
                                                                    if var"##cache#792" === nothing
                                                                        var"##cache#792" = Some(((var"##791").head, (var"##791").args))
                                                                    end
                                                                    var"##793" = (var"##cache#792").value
                                                                    var"##793" isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                                end && (var"##793"[1] == :block && (begin
                                                                            var"##794" = var"##793"[2]
                                                                            var"##794" isa AbstractArray
                                                                        end && ((ndims(var"##794") === 1 && length(var"##794") >= 0) && begin
                                                                                var"##795" = (SubArray)(var"##794", (1:length(var"##794"),))
                                                                                true
                                                                            end)))))))))))))
                    var"##return#753" = let try_stmts = var"##789", catch_stmts = var"##795", catch_var = var"##790"
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), catch_var, Expr(:block, rm_single_block.(catch_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#754#821")))
                end
                if begin
                            var"##796" = (var"##cache#756").value
                            var"##796" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##796"[1] == :try && (begin
                                    var"##797" = var"##796"[2]
                                    var"##797" isa AbstractArray
                                end && (length(var"##797") === 4 && (begin
                                            var"##cache#799" = nothing
                                            var"##798" = var"##797"[1]
                                            var"##798" isa Expr
                                        end && (begin
                                                if var"##cache#799" === nothing
                                                    var"##cache#799" = Some(((var"##798").head, (var"##798").args))
                                                end
                                                var"##800" = (var"##cache#799").value
                                                var"##800" isa Tuple{Symbol, var2} where var2<:AbstractArray
                                            end && (var"##800"[1] == :block && (begin
                                                        var"##801" = var"##800"[2]
                                                        var"##801" isa AbstractArray
                                                    end && ((ndims(var"##801") === 1 && length(var"##801") >= 0) && (begin
                                                                var"##802" = (SubArray)(var"##801", (1:length(var"##801"),))
                                                                var"##803" = var"##797"[2]
                                                                var"##cache#805" = nothing
                                                                var"##804" = var"##797"[3]
                                                                var"##804" isa Expr
                                                            end && (begin
                                                                    if var"##cache#805" === nothing
                                                                        var"##cache#805" = Some(((var"##804").head, (var"##804").args))
                                                                    end
                                                                    var"##806" = (var"##cache#805").value
                                                                    var"##806" isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                                end && (var"##806"[1] == :block && (begin
                                                                            var"##807" = var"##806"[2]
                                                                            var"##807" isa AbstractArray
                                                                        end && ((ndims(var"##807") === 1 && length(var"##807") >= 0) && (begin
                                                                                    var"##808" = (SubArray)(var"##807", (1:length(var"##807"),))
                                                                                    var"##cache#810" = nothing
                                                                                    var"##809" = var"##797"[4]
                                                                                    var"##809" isa Expr
                                                                                end && (begin
                                                                                        if var"##cache#810" === nothing
                                                                                            var"##cache#810" = Some(((var"##809").head, (var"##809").args))
                                                                                        end
                                                                                        var"##811" = (var"##cache#810").value
                                                                                        var"##811" isa Tuple{Symbol, var2} where var2<:AbstractArray
                                                                                    end && (var"##811"[1] == :block && (begin
                                                                                                var"##812" = var"##811"[2]
                                                                                                var"##812" isa AbstractArray
                                                                                            end && ((ndims(var"##812") === 1 && length(var"##812") >= 0) && begin
                                                                                                    var"##813" = (SubArray)(var"##812", (1:length(var"##812"),))
                                                                                                    true
                                                                                                end))))))))))))))))))
                    var"##return#753" = let try_stmts = var"##802", catch_stmts = var"##808", catch_var = var"##803", finally_stmts = var"##813"
                            Expr(:try, Expr(:block, rm_single_block.(try_stmts)...), catch_var, Expr(:block, rm_single_block.(catch_stmts)...), Expr(:block, rm_single_block.(finally_stmts)...))
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#754#821")))
                end
                if begin
                            var"##814" = (var"##cache#756").value
                            var"##814" isa Tuple{Symbol, var2} where var2<:AbstractArray
                        end && (var"##814"[1] == :block && (begin
                                    var"##815" = var"##814"[2]
                                    var"##815" isa AbstractArray
                                end && (length(var"##815") === 1 && begin
                                        var"##816" = var"##815"[1]
                                        true
                                    end)))
                    var"##return#753" = let stmt = var"##816"
                            stmt
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#754#821")))
                end
                if begin
                            var"##817" = (var"##cache#756").value
                            var"##817" isa Tuple{var1, var2} where {var2<:AbstractArray, var1}
                        end && (begin
                                var"##818" = var"##817"[1]
                                var"##819" = var"##817"[2]
                                var"##819" isa AbstractArray
                            end && ((ndims(var"##819") === 1 && length(var"##819") >= 0) && begin
                                    var"##820" = (SubArray)(var"##819", (1:length(var"##819"),))
                                    true
                                end))
                    var"##return#753" = let args = var"##820", head = var"##818"
                            Expr(head, map(rm_single_block, args)...)
                        end
                    $(Expr(:symbolicgoto, Symbol("####final#754#821")))
                end
            end
            var"##return#753" = let
                    ex
                end
            $(Expr(:symbolicgoto, Symbol("####final#754#821")))
            (error)("matching non-exhaustive, at #= none:183 =#")
            $(Expr(:symboliclabel, Symbol("####final#754#821")))
            var"##return#753"
        end
    end
    #= none:211 =# Core.@doc "    rm_annotations(x)\n\nRemove type annotation of given expression.\n" function rm_annotations(x)
            x isa Expr || return x
            if x.head == :(::)
                if length(x.args) == 1
                    return gensym("::$(x.args[1])")
                else
                    return x.args[1]
                end
            elseif x.head in [:(=), :kw]
                return rm_annotations(x.args[1])
            else
                return Expr(x.head, map(rm_annotations, x.args)...)
            end
        end
end
