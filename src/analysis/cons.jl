
    #= none:1 =# Core.@doc "    JLCall(ex::Expr)\n\nConvert a Julia call expression to `JLCall`.\n\n# Examples\n```julia\nex = :(f(x, y; z=1))\njlcall = JLCall(ex)  # creates JLCall with func=:f, args=[:x, :y], kwargs=[:(z=1)]\n```\n" function JLCall(ex::Expr)
            (name, args, kw) = let
                    begin
                        var"##cache#360" = nothing
                    end
                    var"##return#357" = nothing
                    var"##359" = ex
                    if var"##359" isa Expr && (begin
                                    if var"##cache#360" === nothing
                                        var"##cache#360" = Some(((var"##359").head, (var"##359").args))
                                    end
                                    var"##361" = (var"##cache#360").value
                                    var"##361" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##361"[1] == :call && (begin
                                            var"##362" = var"##361"[2]
                                            var"##362" isa AbstractArray
                                        end && ((ndims(var"##362") === 1 && length(var"##362") >= 2) && (begin
                                                    var"##363" = var"##362"[1]
                                                    begin
                                                        var"##cache#365" = nothing
                                                    end
                                                    var"##364" = var"##362"[2]
                                                    var"##364" isa Expr
                                                end && (begin
                                                        if var"##cache#365" === nothing
                                                            var"##cache#365" = Some(((var"##364").head, (var"##364").args))
                                                        end
                                                        var"##366" = (var"##cache#365").value
                                                        var"##366" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                    end && (var"##366"[1] == :parameters && (begin
                                                                var"##367" = var"##366"[2]
                                                                var"##367" isa AbstractArray
                                                            end && ((ndims(var"##367") === 1 && length(var"##367") >= 0) && begin
                                                                    var"##368" = SubArray(var"##367", (1:length(var"##367"),))
                                                                    var"##369" = SubArray(var"##362", (3:length(var"##362"),))
                                                                    true
                                                                end)))))))))
                        var"##return#357" = let name = var"##363", args = var"##369", kw = var"##368"
                                (name, args, kw)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#358#374")))
                    end
                    if var"##359" isa Expr && (begin
                                    if var"##cache#360" === nothing
                                        var"##cache#360" = Some(((var"##359").head, (var"##359").args))
                                    end
                                    var"##370" = (var"##cache#360").value
                                    var"##370" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##370"[1] == :call && (begin
                                            var"##371" = var"##370"[2]
                                            var"##371" isa AbstractArray
                                        end && ((ndims(var"##371") === 1 && length(var"##371") >= 1) && begin
                                                var"##372" = var"##371"[1]
                                                var"##373" = SubArray(var"##371", (2:length(var"##371"),))
                                                true
                                            end))))
                        var"##return#357" = let name = var"##372", args = var"##373"
                                (name, args, nothing)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#358#374")))
                    end
                    error("matching non-exhaustive, at #= none:13 =#")
                    $(Expr(:symboliclabel, Symbol("####final#358#374")))
                    var"##return#357"
                end
            JLCall(name, args, kw)
        end
    #= none:20 =# Core.@doc "    JLFunction(ex::Expr)\n\nCreate a `JLFunction` object from a Julia function `Expr`.\n\n# Example\n\n```julia\njulia> JLFunction(:(f(x) = 2))\nf(x) = begin\n    #= REPL[37]:1 =#    \n    2    \nend\n```\n" function JLFunction(ex::Expr; source = nothing)
            (line, doc, expr) = split_doc(ex)
            if !(isnothing(doc))
                source = line
            end
            (generated, expr) = let
                    begin
                        var"##cache#378" = nothing
                    end
                    var"##return#375" = nothing
                    var"##377" = expr
                    if var"##377" isa Expr
                        if begin
                                    if var"##cache#378" === nothing
                                        var"##cache#378" = Some(((var"##377").head, (var"##377").args))
                                    end
                                    var"##379" = (var"##cache#378").value
                                    var"##379" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##379"[1] == :macrocall && (begin
                                            var"##380" = var"##379"[2]
                                            var"##380" isa AbstractArray
                                        end && (length(var"##380") === 3 && (begin
                                                    var"##381" = var"##380"[1]
                                                    var"##381" == GlobalRef(Base, Symbol("@generated"))
                                                end && begin
                                                    var"##382" = var"##380"[2]
                                                    var"##383" = var"##380"[3]
                                                    true
                                                end))))
                            var"##return#375" = let line = var"##382", expr = var"##383"
                                    (true, expr)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#376#398")))
                        end
                        if begin
                                    var"##384" = (var"##cache#378").value
                                    var"##384" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##384"[1] == :macrocall && (begin
                                            var"##385" = var"##384"[2]
                                            var"##385" isa AbstractArray
                                        end && (length(var"##385") === 3 && (begin
                                                    var"##386" = var"##385"[1]
                                                    var"##386" == Symbol("@generated")
                                                end && begin
                                                    var"##387" = var"##385"[2]
                                                    var"##388" = var"##385"[3]
                                                    true
                                                end))))
                            var"##return#375" = let line = var"##387", expr = var"##388"
                                    (true, expr)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#376#398")))
                        end
                        if begin
                                    var"##389" = (var"##cache#378").value
                                    var"##389" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##389"[1] == :macrocall && (begin
                                            var"##390" = var"##389"[2]
                                            var"##390" isa AbstractArray
                                        end && (length(var"##390") === 3 && (begin
                                                    begin
                                                        var"##cache#392" = nothing
                                                    end
                                                    var"##391" = var"##390"[1]
                                                    var"##391" isa Expr
                                                end && (begin
                                                        if var"##cache#392" === nothing
                                                            var"##cache#392" = Some(((var"##391").head, (var"##391").args))
                                                        end
                                                        var"##393" = (var"##cache#392").value
                                                        var"##393" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                    end && (var"##393"[1] == :. && (begin
                                                                var"##394" = var"##393"[2]
                                                                var"##394" isa AbstractArray
                                                            end && (length(var"##394") === 2 && (var"##394"[1] == :Base && (begin
                                                                            var"##395" = var"##394"[2]
                                                                            var"##395" == QuoteNode(Symbol("@generated"))
                                                                        end && begin
                                                                            var"##396" = var"##390"[2]
                                                                            var"##397" = var"##390"[3]
                                                                            true
                                                                        end))))))))))
                            var"##return#375" = let line = var"##396", expr = var"##397"
                                    (true, expr)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#376#398")))
                        end
                    end
                    begin
                        var"##return#375" = let
                                (false, expr)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#376#398")))
                    end
                    error("matching non-exhaustive, at #= none:41 =#")
                    $(Expr(:symboliclabel, Symbol("####final#376#398")))
                    var"##return#375"
                end
            (head, call, body) = split_function(expr; source)
            (name, args, kw, whereparams, rettype) = let
                    true
                    var"##return#399" = nothing
                    var"##401" = head
                    if var"##401" == :->
                        var"##return#399" = let
                                split_anonymous_function_head(call; source)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#400#402")))
                    end
                    begin
                        var"##return#399" = let h = var"##401"
                                split_function_head(call; source)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#400#402")))
                    end
                    error("matching non-exhaustive, at #= none:49 =#")
                    $(Expr(:symboliclabel, Symbol("####final#400#402")))
                    var"##return#399"
                end
            JLFunction(head, name, args, kw, rettype, generated, whereparams, body, line, doc)
        end
    #= none:56 =# Core.@doc "    JLStruct(ex::Expr)\n\nCreate a `JLStruct` object from a Julia struct `Expr`.\n\n# Example\n\n```julia\njulia> JLStruct(:(struct Foo\n           x::Int\n       end))\nstruct Foo\n    #= REPL[38]:2 =#\n    x::Int\nend\n```\n" function JLStruct(ex::Expr; source = nothing)
            (line, doc, expr) = split_doc(ex)
            if !(isnothing(doc))
                source = line
            end
            (ismutable, typename, typevars, supertype, body) = split_struct(expr; source)
            (fields, constructors, misc) = (JLField[], JLFunction[], [])
            (field_doc, field_source) = (nothing, source)
            body = flatten_blocks(body)
            for each = body.args
                m = split_field_if_match(typename, each; source = field_source)
                if m isa String
                    field_doc = m
                elseif m isa LineNumberNode
                    field_source = m
                elseif m isa NamedTuple
                    push!(fields, JLField(; m..., doc = field_doc, line = field_source))
                    (field_doc, field_source) = (nothing, nothing)
                elseif m isa JLFunction
                    push!(constructors, m)
                else
                    push!(misc, m)
                end
            end
            JLStruct(typename, ismutable, typevars, supertype, fields, constructors, line, doc, misc)
        end
    #= none:103 =# Core.@doc "    JLKwStruct(ex::Expr, typealias=nothing)\n\nCreate a `JLKwStruct` from given Julia struct `Expr`, with an option to attach\nan alias to this type name.\n\n# Example\n\n```julia\njulia> JLKwStruct(:(struct Foo\n           x::Int = 1\n       end))\n#= kw =# struct Foo\n    #= REPL[39]:2 =#\n    x::Int = 1\nend\n```\n" function JLKwStruct(ex::Expr, typealias = nothing; source = nothing)
            (line, doc, expr) = split_doc(ex)
            if !(isnothing(doc))
                source = line
            end
            (ismutable, typename, typevars, supertype, body) = split_struct(expr; source)
            (fields, constructors, misc) = (JLKwField[], JLFunction[], [])
            (field_doc, field_source) = (nothing, source)
            body = flatten_blocks(body)
            for each = body.args
                m = split_field_if_match(typename, each, true; source = field_source)
                if m isa String
                    field_doc = m
                elseif m isa LineNumberNode
                    field_source = m
                elseif m isa NamedTuple
                    field = JLKwField(; m..., doc = field_doc, line = field_source)
                    push!(fields, field)
                    (field_doc, field_source) = (nothing, nothing)
                elseif m isa JLFunction
                    push!(constructors, m)
                else
                    push!(misc, m)
                end
            end
            JLKwStruct(typename, typealias, ismutable, typevars, supertype, fields, constructors, line, doc, misc)
        end
    #= none:150 =# Core.@doc "    JLIfElse(ex::Expr)\n\nCreate a `JLIfElse` from given Julia ifelse `Expr`.\n\n# Example\n\n```julia\njulia> ex = :(if foo(x)\n             x = 1 + 1\n         elseif goo(x)\n             y = 1 + 2\n         else\n             error(\"abc\")\n         end)\n:(if foo(x)\n      #= REPL[41]:2 =#\n      x = 1 + 1\n  elseif #= REPL[41]:3 =# goo(x)\n      #= REPL[41]:4 =#\n      y = 1 + 2\n  else\n      #= REPL[41]:6 =#\n      error(\"abc\")\n  end)\n\njulia> JLIfElse(ex)\nif foo(x)\n    begin\n        #= REPL[41]:2 =#        \n        x = 1 + 1        \n    end\nelseif begin\n    #= REPL[41]:3 =#    \n    goo(x)    \nend\n    begin\n        #= REPL[41]:4 =#        \n        y = 1 + 2        \n    end\nelse\n    begin\n        #= REPL[41]:6 =#        \n        error(\"abc\")        \n    end\nend\n```\n" function JLIfElse(ex::Expr; source = nothing)
            ex.head === :if || throw(SyntaxError("expect an if ... elseif ... else ... end expression", source))
            (conds, stmts, otherwise) = split_ifelse(ex)
            return JLIfElse(conds, stmts, otherwise)
        end
    #= none:206 =# Core.@doc "    JLFor(ex::Expr)\n\nCreate a `JLFor` from given Julia for loop expression.\n\n# Example\n\n```julia\njulia> ex = @expr for i in 1:10, j in 1:j\n           M[i, j] += 1\n       end\n:(for i = 1:10, j = 1:j\n      #= REPL[3]:2 =#\n      M[i, j] += 1\n  end)\n\njulia> jl = JLFor(ex)\nfor i in 1 : 10,\n    j in 1 : j\n    #= loop body =#\n    begin\n        #= REPL[3]:2 =#        \n        M[i, j] += 1        \n    end\nend\n\njulia> jl.vars\n2-element Vector{Any}:\n :i\n :j\n\njulia> jl.iterators\n2-element Vector{Any}:\n :(1:10)\n :(1:j)\n```\n" function JLFor(ex::Expr)
            (vars, itrs, body) = split_forloop(ex)
            return JLFor(vars, itrs, body)
        end
