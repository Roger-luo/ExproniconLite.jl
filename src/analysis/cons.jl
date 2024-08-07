
    #= none:1 =# Core.@doc "    JLFunction(ex::Expr)\n\nCreate a `JLFunction` object from a Julia function `Expr`.\n\n# Example\n\n```julia\njulia> JLFunction(:(f(x) = 2))\nf(x) = begin\n    #= REPL[37]:1 =#    \n    2    \nend\n```\n" function JLFunction(ex::Expr; source = nothing)
            (line, doc, expr) = split_doc(ex)
            if !(isnothing(doc))
                source = line
            end
            (generated, expr) = let
                    begin
                        var"##cache#449" = nothing
                    end
                    var"##return#446" = nothing
                    var"##448" = expr
                    if var"##448" isa Expr
                        if begin
                                    if var"##cache#449" === nothing
                                        var"##cache#449" = Some(((var"##448").head, (var"##448").args))
                                    end
                                    var"##450" = (var"##cache#449").value
                                    var"##450" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##450"[1] == :macrocall && (begin
                                            var"##451" = var"##450"[2]
                                            var"##451" isa AbstractArray
                                        end && (length(var"##451") === 3 && (begin
                                                    var"##452" = var"##451"[1]
                                                    var"##452" == GlobalRef(Base, Symbol("@generated"))
                                                end && begin
                                                    var"##453" = var"##451"[2]
                                                    var"##454" = var"##451"[3]
                                                    true
                                                end))))
                            var"##return#446" = let line = var"##453", expr = var"##454"
                                    (true, expr)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#447#469")))
                        end
                        if begin
                                    var"##455" = (var"##cache#449").value
                                    var"##455" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##455"[1] == :macrocall && (begin
                                            var"##456" = var"##455"[2]
                                            var"##456" isa AbstractArray
                                        end && (length(var"##456") === 3 && (begin
                                                    var"##457" = var"##456"[1]
                                                    var"##457" == Symbol("@generated")
                                                end && begin
                                                    var"##458" = var"##456"[2]
                                                    var"##459" = var"##456"[3]
                                                    true
                                                end))))
                            var"##return#446" = let line = var"##458", expr = var"##459"
                                    (true, expr)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#447#469")))
                        end
                        if begin
                                    var"##460" = (var"##cache#449").value
                                    var"##460" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##460"[1] == :macrocall && (begin
                                            var"##461" = var"##460"[2]
                                            var"##461" isa AbstractArray
                                        end && (length(var"##461") === 3 && (begin
                                                    begin
                                                        var"##cache#463" = nothing
                                                    end
                                                    var"##462" = var"##461"[1]
                                                    var"##462" isa Expr
                                                end && (begin
                                                        if var"##cache#463" === nothing
                                                            var"##cache#463" = Some(((var"##462").head, (var"##462").args))
                                                        end
                                                        var"##464" = (var"##cache#463").value
                                                        var"##464" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                    end && (var"##464"[1] == :. && (begin
                                                                var"##465" = var"##464"[2]
                                                                var"##465" isa AbstractArray
                                                            end && (length(var"##465") === 2 && (var"##465"[1] == :Base && (begin
                                                                            var"##466" = var"##465"[2]
                                                                            var"##466" == QuoteNode(Symbol("@generated"))
                                                                        end && begin
                                                                            var"##467" = var"##461"[2]
                                                                            var"##468" = var"##461"[3]
                                                                            true
                                                                        end))))))))))
                            var"##return#446" = let line = var"##467", expr = var"##468"
                                    (true, expr)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#447#469")))
                        end
                    end
                    begin
                        var"##return#446" = let
                                (false, expr)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#447#469")))
                    end
                    error("matching non-exhaustive, at #= none:22 =#")
                    $(Expr(:symboliclabel, Symbol("####final#447#469")))
                    var"##return#446"
                end
            (head, call, body) = split_function(expr; source)
            (name, args, kw, whereparams, rettype) = let
                    true
                    var"##return#470" = nothing
                    var"##472" = head
                    if var"##472" == :->
                        var"##return#470" = let
                                split_anonymous_function_head(call; source)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#471#473")))
                    end
                    begin
                        var"##return#470" = let h = var"##472"
                                split_function_head(call; source)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#471#473")))
                    end
                    error("matching non-exhaustive, at #= none:30 =#")
                    $(Expr(:symboliclabel, Symbol("####final#471#473")))
                    var"##return#470"
                end
            JLFunction(head, name, args, kw, rettype, generated, whereparams, body, line, doc)
        end
    #= none:37 =# Core.@doc "    JLStruct(ex::Expr)\n\nCreate a `JLStruct` object from a Julia struct `Expr`.\n\n# Example\n\n```julia\njulia> JLStruct(:(struct Foo\n           x::Int\n       end))\nstruct Foo\n    #= REPL[38]:2 =#\n    x::Int\nend\n```\n" function JLStruct(ex::Expr; source = nothing)
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
    #= none:84 =# Core.@doc "    JLKwStruct(ex::Expr, typealias=nothing)\n\nCreate a `JLKwStruct` from given Julia struct `Expr`, with an option to attach\nan alias to this type name.\n\n# Example\n\n```julia\njulia> JLKwStruct(:(struct Foo\n           x::Int = 1\n       end))\n#= kw =# struct Foo\n    #= REPL[39]:2 =#\n    x::Int = 1\nend\n```\n" function JLKwStruct(ex::Expr, typealias = nothing; source = nothing)
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
    #= none:131 =# Core.@doc "    JLIfElse(ex::Expr)\n\nCreate a `JLIfElse` from given Julia ifelse `Expr`.\n\n# Example\n\n```julia\njulia> ex = :(if foo(x)\n             x = 1 + 1\n         elseif goo(x)\n             y = 1 + 2\n         else\n             error(\"abc\")\n         end)\n:(if foo(x)\n      #= REPL[41]:2 =#\n      x = 1 + 1\n  elseif #= REPL[41]:3 =# goo(x)\n      #= REPL[41]:4 =#\n      y = 1 + 2\n  else\n      #= REPL[41]:6 =#\n      error(\"abc\")\n  end)\n\njulia> JLIfElse(ex)\nif foo(x)\n    begin\n        #= REPL[41]:2 =#        \n        x = 1 + 1        \n    end\nelseif begin\n    #= REPL[41]:3 =#    \n    goo(x)    \nend\n    begin\n        #= REPL[41]:4 =#        \n        y = 1 + 2        \n    end\nelse\n    begin\n        #= REPL[41]:6 =#        \n        error(\"abc\")        \n    end\nend\n```\n" function JLIfElse(ex::Expr; source = nothing)
            ex.head === :if || throw(SyntaxError("expect an if ... elseif ... else ... end expression", source))
            (conds, stmts, otherwise) = split_ifelse(ex)
            return JLIfElse(conds, stmts, otherwise)
        end
    #= none:187 =# Core.@doc "    JLFor(ex::Expr)\n\nCreate a `JLFor` from given Julia for loop expression.\n\n# Example\n\n```julia\njulia> ex = @expr for i in 1:10, j in 1:j\n           M[i, j] += 1\n       end\n:(for i = 1:10, j = 1:j\n      #= REPL[3]:2 =#\n      M[i, j] += 1\n  end)\n\njulia> jl = JLFor(ex)\nfor i in 1 : 10,\n    j in 1 : j\n    #= loop body =#\n    begin\n        #= REPL[3]:2 =#        \n        M[i, j] += 1        \n    end\nend\n\njulia> jl.vars\n2-element Vector{Any}:\n :i\n :j\n\njulia> jl.iterators\n2-element Vector{Any}:\n :(1:10)\n :(1:j)\n```\n" function JLFor(ex::Expr)
            (vars, itrs, body) = split_forloop(ex)
            return JLFor(vars, itrs, body)
        end
