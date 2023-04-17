
    #= none:1 =# Core.@doc "    JLFunction(ex::Expr)\n\nCreate a `JLFunction` object from a Julia function `Expr`.\n\n# Example\n\n```julia\njulia> JLFunction(:(f(x) = 2))\nf(x) = begin\n    #= REPL[37]:1 =#    \n    2    \nend\n```\n" function JLFunction(ex::Expr; source = nothing)
            (line, doc, expr) = split_doc(ex)
            if !(isnothing(doc))
                source = line
            end
            (generated, expr) = let
                    begin
                        var"##cache#514" = nothing
                    end
                    var"##return#511" = nothing
                    var"##513" = expr
                    if var"##513" isa Expr
                        if begin
                                    if var"##cache#514" === nothing
                                        var"##cache#514" = Some(((var"##513").head, (var"##513").args))
                                    end
                                    var"##515" = (var"##cache#514").value
                                    var"##515" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##515"[1] == :macrocall && (begin
                                            var"##516" = var"##515"[2]
                                            var"##516" isa AbstractArray
                                        end && (length(var"##516") === 3 && (begin
                                                    var"##517" = var"##516"[1]
                                                    var"##517" == GlobalRef(Base, Symbol("@generated"))
                                                end && begin
                                                    var"##518" = var"##516"[2]
                                                    var"##519" = var"##516"[3]
                                                    true
                                                end))))
                            var"##return#511" = let line = var"##518", expr = var"##519"
                                    (true, expr)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#512#534")))
                        end
                        if begin
                                    var"##520" = (var"##cache#514").value
                                    var"##520" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##520"[1] == :macrocall && (begin
                                            var"##521" = var"##520"[2]
                                            var"##521" isa AbstractArray
                                        end && (length(var"##521") === 3 && (begin
                                                    var"##522" = var"##521"[1]
                                                    var"##522" == Symbol("@generated")
                                                end && begin
                                                    var"##523" = var"##521"[2]
                                                    var"##524" = var"##521"[3]
                                                    true
                                                end))))
                            var"##return#511" = let line = var"##523", expr = var"##524"
                                    (true, expr)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#512#534")))
                        end
                        if begin
                                    var"##525" = (var"##cache#514").value
                                    var"##525" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                end && (var"##525"[1] == :macrocall && (begin
                                            var"##526" = var"##525"[2]
                                            var"##526" isa AbstractArray
                                        end && (length(var"##526") === 3 && (begin
                                                    begin
                                                        var"##cache#528" = nothing
                                                    end
                                                    var"##527" = var"##526"[1]
                                                    var"##527" isa Expr
                                                end && (begin
                                                        if var"##cache#528" === nothing
                                                            var"##cache#528" = Some(((var"##527").head, (var"##527").args))
                                                        end
                                                        var"##529" = (var"##cache#528").value
                                                        var"##529" isa (Tuple{Symbol, var2} where var2 <: AbstractArray)
                                                    end && (var"##529"[1] == :. && (begin
                                                                var"##530" = var"##529"[2]
                                                                var"##530" isa AbstractArray
                                                            end && (length(var"##530") === 2 && (var"##530"[1] == :Base && (begin
                                                                            var"##531" = var"##530"[2]
                                                                            var"##531" == QuoteNode(Symbol("@generated"))
                                                                        end && begin
                                                                            var"##532" = var"##526"[2]
                                                                            var"##533" = var"##526"[3]
                                                                            true
                                                                        end))))))))))
                            var"##return#511" = let line = var"##532", expr = var"##533"
                                    (true, expr)
                                end
                            $(Expr(:symbolicgoto, Symbol("####final#512#534")))
                        end
                    end
                    begin
                        var"##return#511" = let
                                (false, expr)
                            end
                        $(Expr(:symbolicgoto, Symbol("####final#512#534")))
                    end
                    error("matching non-exhaustive, at #= none:22 =#")
                    $(Expr(:symboliclabel, Symbol("####final#512#534")))
                    var"##return#511"
                end
            (head, call, body) = split_function(expr; source)
            (name, args, kw, whereparams, rettype) = split_function_head(call; source)
            JLFunction(head, name, args, kw, rettype, generated, whereparams, body, line, doc)
        end
    #= none:34 =# Core.@doc "    JLStruct(ex::Expr)\n\nCreate a `JLStruct` object from a Julia struct `Expr`.\n\n# Example\n\n```julia\njulia> JLStruct(:(struct Foo\n           x::Int\n       end))\nstruct Foo\n    #= REPL[38]:2 =#\n    x::Int\nend\n```\n" function JLStruct(ex::Expr; source = nothing)
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
    #= none:81 =# Core.@doc "    JLKwStruct(ex::Expr, typealias=nothing)\n\nCreate a `JLKwStruct` from given Julia struct `Expr`, with an option to attach\nan alias to this type name.\n\n# Example\n\n```julia\njulia> JLKwStruct(:(struct Foo\n           x::Int = 1\n       end))\n#= kw =# struct Foo\n    #= REPL[39]:2 =#\n    x::Int = 1\nend\n```\n" function JLKwStruct(ex::Expr, typealias = nothing; source = nothing)
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
    #= none:128 =# Core.@doc "    JLIfElse(ex::Expr)\n\nCreate a `JLIfElse` from given Julia ifelse `Expr`.\n\n# Example\n\n```julia\njulia> ex = :(if foo(x)\n             x = 1 + 1\n         elseif goo(x)\n             y = 1 + 2\n         else\n             error(\"abc\")\n         end)\n:(if foo(x)\n      #= REPL[41]:2 =#\n      x = 1 + 1\n  elseif #= REPL[41]:3 =# goo(x)\n      #= REPL[41]:4 =#\n      y = 1 + 2\n  else\n      #= REPL[41]:6 =#\n      error(\"abc\")\n  end)\n\njulia> JLIfElse(ex)\nif foo(x)\n    begin\n        #= REPL[41]:2 =#        \n        x = 1 + 1        \n    end\nelseif begin\n    #= REPL[41]:3 =#    \n    goo(x)    \nend\n    begin\n        #= REPL[41]:4 =#        \n        y = 1 + 2        \n    end\nelse\n    begin\n        #= REPL[41]:6 =#        \n        error(\"abc\")        \n    end\nend\n```\n" function JLIfElse(ex::Expr; source = nothing)
            ex.head === :if || throw(SyntaxError("expect an if ... elseif ... else ... end expression", source))
            (conds, stmts, otherwise) = split_ifelse(ex)
            return JLIfElse(conds, stmts, otherwise)
        end
    #= none:184 =# Core.@doc "    JLFor(ex::Expr)\n\nCreate a `JLFor` from given Julia for loop expression.\n\n# Example\n\n```julia\njulia> ex = @expr for i in 1:10, j in 1:j\n           M[i, j] += 1\n       end\n:(for i = 1:10, j = 1:j\n      #= REPL[3]:2 =#\n      M[i, j] += 1\n  end)\n\njulia> jl = JLFor(ex)\nfor i in 1 : 10,\n    j in 1 : j\n    #= loop body =#\n    begin\n        #= REPL[3]:2 =#        \n        M[i, j] += 1        \n    end\nend\n\njulia> jl.vars\n2-element Vector{Any}:\n :i\n :j\n\njulia> jl.iterators\n2-element Vector{Any}:\n :(1:10)\n :(1:j)\n```\n" function JLFor(ex::Expr)
            (vars, itrs, body) = split_forloop(ex)
            return JLFor(vars, itrs, body)
        end
