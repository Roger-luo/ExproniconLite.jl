
    #= none:1 =# Core.@doc "    JLFunction(ex::Expr)\n\nCreate a `JLFunction` object from a Julia function `Expr`.\n\n# Example\n\n```julia\njulia> JLFunction(:(f(x) = 2))\nf(x) = begin\n    #= REPL[37]:1 =#    \n    2    \nend\n```\n" function JLFunction(ex::Expr)
            (line, doc, expr) = split_doc(ex)
            (head, call, body) = split_function(expr)
            (name, args, kw, whereparams, rettype) = split_function_head(call)
            JLFunction(head, name, args, kw, rettype, whereparams, body, line, doc)
        end
    #= none:23 =# Core.@doc "    JLStruct(ex::Expr)\n\nCreate a `JLStruct` object from a Julia struct `Expr`.\n\n# Example\n\n```julia\njulia> JLStruct(:(struct Foo\n           x::Int\n       end))\nstruct Foo\n    #= REPL[38]:2 =#\n    x::Int\nend\n```\n" function JLStruct(ex::Expr)
            (line, doc, expr) = split_doc(ex)
            (ismutable, typename, typevars, supertype, body) = split_struct(expr)
            (fields, constructors, misc) = (JLField[], JLFunction[], [])
            (field_doc, field_line) = (nothing, nothing)
            body = flatten_blocks(body)
            for each = body.args
                m = split_field_if_match(typename, each)
                if m isa String
                    field_doc = m
                elseif m isa LineNumberNode
                    field_line = m
                elseif m isa NamedTuple
                    push!(fields, JLField(; m..., doc = field_doc, line = field_line))
                    (field_doc, field_line) = (nothing, nothing)
                elseif m isa JLFunction
                    push!(constructors, m)
                else
                    push!(misc, m)
                end
            end
            JLStruct(typename, ismutable, typevars, supertype, fields, constructors, line, doc, misc)
        end
    #= none:67 =# Core.@doc "    JLKwStruct(ex::Expr, typealias=nothing)\n\nCreate a `JLKwStruct` from given Julia struct `Expr`, with an option to attach\nan alias to this type name.\n\n# Example\n\n```julia\njulia> JLKwStruct(:(struct Foo\n           x::Int = 1\n       end))\n#= kw =# struct Foo\n    #= REPL[39]:2 =#\n    x::Int = 1\nend\n```\n" function JLKwStruct(ex::Expr, typealias = nothing)
            (line, doc, expr) = split_doc(ex)
            (ismutable, typename, typevars, supertype, body) = split_struct(expr)
            (fields, constructors, misc) = (JLKwField[], JLFunction[], [])
            (field_doc, field_line) = (nothing, nothing)
            body = flatten_blocks(body)
            for each = body.args
                m = split_field_if_match(typename, each, true)
                if m isa String
                    field_doc = m
                elseif m isa LineNumberNode
                    field_line = m
                elseif m isa NamedTuple
                    field = JLKwField(; m..., doc = field_doc, line = field_line)
                    push!(fields, field)
                    (field_doc, field_line) = (nothing, nothing)
                elseif m isa JLFunction
                    push!(constructors, m)
                else
                    push!(misc, m)
                end
            end
            JLKwStruct(typename, typealias, ismutable, typevars, supertype, fields, constructors, line, doc, misc)
        end
    #= none:111 =# Core.@doc "    JLIfElse(ex::Expr)\n\nCreate a `JLIfElse` from given Julia ifelse `Expr`.\n\n# Example\n\n```julia\njulia> ex = :(if foo(x)\n             x = 1 + 1\n         elseif goo(x)\n             y = 1 + 2\n         else\n             error(\"abc\")\n         end)\n:(if foo(x)\n      #= REPL[41]:2 =#\n      x = 1 + 1\n  elseif #= REPL[41]:3 =# goo(x)\n      #= REPL[41]:4 =#\n      y = 1 + 2\n  else\n      #= REPL[41]:6 =#\n      error(\"abc\")\n  end)\n\njulia> JLIfElse(ex)\nif foo(x)\n    begin\n        #= REPL[41]:2 =#        \n        x = 1 + 1        \n    end\nelseif begin\n    #= REPL[41]:3 =#    \n    goo(x)    \nend\n    begin\n        #= REPL[41]:4 =#        \n        y = 1 + 2        \n    end\nelse\n    begin\n        #= REPL[41]:6 =#        \n        error(\"abc\")        \n    end\nend\n```\n" function JLIfElse(ex::Expr)
            ex.head === :if || error("expect an if ... elseif ... else ... end expression")
            (conds, stmts, otherwise) = split_ifelse(ex)
            return JLIfElse(conds, stmts, otherwise)
        end
    #= none:165 =# Core.@doc "    JLFor(ex::Expr)\n\nCreate a `JLFor` from given Julia for loop expression.\n\n# Example\n\n```julia\njulia> ex = @expr for i in 1:10, j in 1:j\n           M[i, j] += 1\n       end\n:(for i = 1:10, j = 1:j\n      #= REPL[3]:2 =#\n      M[i, j] += 1\n  end)\n\njulia> jl = JLFor(ex)\nfor i in 1 : 10,\n    j in 1 : j\n    #= loop body =#\n    begin\n        #= REPL[3]:2 =#        \n        M[i, j] += 1        \n    end\nend\n\njulia> jl.vars\n2-element Vector{Any}:\n :i\n :j\n\njulia> jl.iterators\n2-element Vector{Any}:\n :(1:10)\n :(1:j)\n```\n" function JLFor(ex::Expr)
            (vars, itrs, body) = split_forloop(ex)
            return JLFor(vars, itrs, body)
        end
