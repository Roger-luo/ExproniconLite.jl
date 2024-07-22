
    using Test
    using ExproniconLite
    using ExproniconLite: assert_equal_expr, ExprNotEqual, empty_line, guess_module, is_valid_typevar
    #= none:6 =# @testset "is_function" begin
            #= none:7 =# @test is_function(:(foo(x) = begin
                              x
                          end))
            #= none:8 =# @test is_function(:((x->begin
                              2x
                          end)))
        end
    #= none:11 =# @testset "is_datatype_expr" begin
            #= none:12 =# @test is_datatype_expr(:name)
            #= none:13 =# @test is_datatype_expr(GlobalRef(Main, :name))
            #= none:14 =# @test is_datatype_expr(:(Main.Reflected.OptionA))
            #= none:15 =# @test is_datatype_expr(Expr(:curly, :(Main.Reflected.OptionC), :(Core.Int64)))
            #= none:16 =# @test is_datatype_expr(:(struct Foo
                          end)) == false
            #= none:17 =# @test is_datatype_expr(:(Foo{T} where T)) == false
        end
    #= none:20 =# @testset "uninferrable_typevars" begin
            def = #= none:21 =# @expr(JLKwStruct, struct Inferable1{T}
                        x::Constaint{T, (<)(2)}
                    end)
            #= none:25 =# @test uninferrable_typevars(def) == []
            def = #= none:27 =# @expr(JLKwStruct, struct Inferable2{T}
                        x::Constaint{Float64, (<)(2)}
                    end)
            #= none:31 =# @test uninferrable_typevars(def) == [:T]
            def = #= none:33 =# @expr(JLKwStruct, struct Inferable3{T, N}
                        x::Int
                        y::N
                    end)
            #= none:37 =# @test uninferrable_typevars(def) == [:T]
            def = #= none:40 =# @expr(JLKwStruct, struct Inferable4{T, N}
                        x::T
                        y::N
                    end)
            #= none:44 =# @test uninferrable_typevars(def) == []
            def = #= none:46 =# @expr(JLKwStruct, struct Inferable5{T, N}
                        x::T
                        y::Float64
                    end)
            #= none:51 =# @test uninferrable_typevars(def) == [:T, :N]
            #= none:52 =# @test uninferrable_typevars(def; leading_inferable = false) == [:N]
        end
    #= none:55 =# @testset "has_plain_constructor" begin
            def = #= none:56 =# @expr(JLKwStruct, struct Foo1{T, N}
                        x::Int
                        y::N
                        (Foo1{T, N}(x, y) where {T, N}) = begin
                                new{T, N}(x, y)
                            end
                    end)
            #= none:62 =# @test has_plain_constructor(def) == true
            def = #= none:64 =# @expr(JLKwStruct, struct Foo2{T, N}
                        x::T
                        y::N
                        Foo2(x, y) = begin
                                new{typeof(x), typeof(y)}(x, y)
                            end
                    end)
            #= none:70 =# @test has_plain_constructor(def) == false
            def = #= none:72 =# @expr(JLKwStruct, struct Foo3{T, N}
                        x::Int
                        y::N
                        (Foo3{T}(x, y) where T) = begin
                                new{T, typeof(y)}(x, y)
                            end
                    end)
            #= none:78 =# @test has_plain_constructor(def) == false
            def = #= none:80 =# @expr(JLKwStruct, struct Foo4{T, N}
                        x::T
                        y::N
                        (Foo4{T, N}(x::T, y::N) where {T, N}) = begin
                                new{T, N}(x, y)
                            end
                    end)
            #= none:86 =# @test has_plain_constructor(def) == false
        end
    #= none:89 =# @testset "is_kw_function" begin
            #= none:90 =# @test is_kw_function(:(function foo(x::Int; kw = 1)
                      end))
            ex = :(function (x::Int,; kw = 1)
                  end)
            #= none:96 =# @test is_kw_function(ex)
            #= none:97 =# @test !(is_kw_function(true))
            #= none:99 =# @test !(is_kw_function(:(function foo(x::Int)
                          end)))
            #= none:104 =# @test !(is_kw_function(:(function (x::Int,)
                          end)))
        end
    #= none:110 =# @testset "JLFunction(ex)" begin
            jlfn = JLFunction()
            #= none:112 =# @test jlfn.name === nothing
            #= none:114 =# @test_expr JLFunction function foo(x::Int, y::Type{T}) where T <: Real
                    return x
                end
            def = #= none:118 =# @test_expr(JLFunction, function (x, y)
                        return 2
                    end)
            #= none:121 =# @test is_kw_function(def) == false
            def = #= none:123 =# @test_expr(JLFunction, function (x, y; kw = 2)
                        return "aaa"
                    end)
            #= none:126 =# @test is_kw_function(def) == true
            #= none:128 =# @test_expr JLFunction ((x, y)->begin
                        sin(x)
                    end)
            #= none:131 =# @test_expr JLFunction function (x::Int,; kw = 1)
                end
            ex = :(struct Foo
                  end)
            #= none:134 =# @test_throws SyntaxError JLFunction(ex)
            ex = :(#= none:135 =# @foo(2, 3))
            #= none:136 =# @test_throws SyntaxError split_function_head(ex)
            ex = :((foo(bar)->begin
                          bar
                      end))
            #= none:139 =# @test_throws SyntaxError JLFunction(ex)
            ex = :(Foo(; a = 1) = begin
                          new(a)
                      end)
            #= none:142 =# @test (JLFunction(ex)).kwargs[1] == Expr(:kw, :a, 1)
            #= none:144 =# @test_expr JLFunction function (f(x::T; a = 10)::Int) where T
                    return x
                end
            #= none:148 =# @test_expr JLFunction f(x::Int)::Int = begin
                        x
                    end
            ex = :((x->begin
                          x
                      end))
            #= none:151 =# @test (JLFunction(ex)).args == Any[:x]
            ex = :((x->begin
                          2x
                      end))
            #= none:154 =# @test (JLFunction(ex)).args == Any[:x]
            ex = :((x::Int->begin
                          2x
                      end))
            #= none:157 =# @test (JLFunction(ex)).args == Any[:(x::Int)]
            ex = :((::Int->begin
                          0
                      end))
            #= none:160 =# @test (JLFunction(ex)).args == Any[:(::Int)]
            ex = :(((x, y)::T->begin
                          x
                      end))
            jlf = JLFunction(ex)
            #= none:164 =# @test jlf.args == Any[:x, :y]
            #= none:165 =# @test jlf.rettype == :T
            ex = :((((x::T, y) where T)::T->begin
                          x
                      end))
            jlf = JLFunction(ex)
            #= none:169 =# @test jlf.whereparams == Any[:T]
            #= none:170 =# @test jlf.args == Any[:(x::T), :y]
            #= none:171 =# @test jlf.rettype == :T
            ex = quote
                    #= none:175 =# Core.@doc "foo $(bar)" f(x) = begin
                                x + 1
                            end
                end
            jlf = JLFunction(ex)
            #= none:180 =# @test jlf.doc == Expr(:string, "foo ", :bar)
        end
    #= none:183 =# @testset "JLStruct(ex)" begin
            #= none:184 =# @test (JLField(; name = :x)).name === :x
            #= none:185 =# @test (JLField(; name = :x)).type === Any
            #= none:186 =# @test (JLStruct(; name = :Foo)).name === :Foo
            ex = :(struct Foo
                      x::Int
                  end)
            jlstruct = JLStruct(ex)
            println(jlstruct)
            #= none:194 =# @test jlstruct.name === :Foo
            #= none:195 =# @test jlstruct.ismutable === false
            #= none:196 =# @test length(jlstruct.fields) == 1
            #= none:197 =# @test (jlstruct.fields[1]).name === :x
            #= none:198 =# @test (jlstruct.fields[1]).type === :Int
            #= none:199 =# @test (jlstruct.fields[1]).line isa LineNumberNode
            #= none:200 =# @test codegen_ast(jlstruct) == ex
            ex = :(mutable struct Foo{T, S <: Real} <: AbstractArray
                      a::Float64
                      function foo(x, y, z)
                          new(1)
                      end
                  end)
            jlstruct = JLStruct(ex)
            println(jlstruct)
            #= none:212 =# @test jlstruct.ismutable == true
            #= none:213 =# @test jlstruct.name === :Foo
            #= none:214 =# @test jlstruct.typevars == Any[:T, :(S <: Real)]
            #= none:215 =# @test jlstruct.supertype == :AbstractArray
            #= none:216 =# @test jlstruct.misc[1] == (ex.args[3]).args[end]
            #= none:217 =# @test rm_lineinfo(codegen_ast(jlstruct)) == rm_lineinfo(ex)
            ex = quote
                    #= none:220 =# Core.@doc "Foo\n" struct Foo
                            "xyz"
                            x::Int
                            y
                            Foo(x) = begin
                                    new(x)
                                end
                            1 + 1
                        end
                end
            ex = ex.args[2]
            jlstruct = JLStruct(ex)
            #= none:234 =# @test jlstruct.doc == "Foo\n"
            #= none:235 =# @test (jlstruct.fields[1]).doc == "xyz"
            #= none:236 =# @test (jlstruct.fields[2]).type === Any
            #= none:237 =# @test (jlstruct.constructors[1]).name === :Foo
            #= none:238 =# @test (jlstruct.constructors[1]).args[1] === :x
            #= none:239 =# @test jlstruct.misc[1] == :(1 + 1)
            ast = codegen_ast(jlstruct)
            #= none:241 =# @test ast.args[1] == GlobalRef(Core, Symbol("@doc"))
            #= none:242 =# @test ast.args[3] == "Foo\n"
            #= none:243 =# @test (ast.args[4]).head === :struct
            #= none:244 =# @test is_function(((ast.args[4]).args[end]).args[end - 1])
            println(jlstruct)
            #= none:247 =# @test_throws SyntaxError split_struct_name(:(function Foo end))
        end
    #= none:250 =# @testset "JLKwStruct" begin
            def = #= none:251 =# @expr(JLKwStruct, struct Trait
                    end)
            #= none:252 =# @test_expr codegen_ast_kwfn(def) == quote
                        nothing
                    end
            #= none:256 =# @test (JLKwField(; name = :x)).name === :x
            #= none:257 =# @test (JLKwField(; name = :x)).type === Any
            #= none:258 =# @test (JLKwStruct(; name = :Foo)).name === :Foo
            def = #= none:260 =# @expr(JLKwStruct, struct ConvertOption
                        include_defaults::Bool = false
                        exclude_nothing::Bool = false
                    end)
            #= none:265 =# @test_expr codegen_ast_kwfn(def, :create) == quote
                        function create(::Type{S}; include_defaults = false, exclude_nothing = false) where S <: ConvertOption
                            ConvertOption(include_defaults, exclude_nothing)
                        end
                        nothing
                    end
            def = #= none:272 =# @expr(JLKwStruct, struct Foo1{N, T}
                        x::T = 1
                    end)
            println(def)
            #= none:277 =# @test_expr codegen_ast_kwfn(def, :create) == quote
                        function create(::Type{S}; x = 1) where {N, T, S <: Foo1{N, T}}
                            Foo1{N, T}(x)
                        end
                        function create(::Type{S}; x = 1) where {N, S <: Foo1{N}}
                            Foo1{N}(x)
                        end
                    end
            #= none:286 =# @test_expr codegen_ast(def) == quote
                        struct Foo1{N, T}
                            x::T
                        end
                        function Foo1{N, T}(; x = 1) where {N, T}
                            Foo1{N, T}(x)
                        end
                        function Foo1{N}(; x = 1) where N
                            Foo1{N}(x)
                        end
                        nothing
                    end
            def = #= none:299 =# @expr(JLKwStruct, struct Foo2 <: AbstractFoo
                        x = 1
                        y::Int
                    end)
            #= none:304 =# @test_expr codegen_ast(def) == quote
                        struct Foo2 <: AbstractFoo
                            x
                            y::Int
                        end
                        function Foo2(; x = 1, y)
                            Foo2(x, y)
                        end
                        nothing
                    end
            ex = quote
                    #= none:316 =# Core.@doc "Foo\n" mutable struct Foo
                            "abc"
                            a::Int = 1
                            b
                            Foo(x) = begin
                                    new(x)
                                end
                            1 + 1
                        end
                end
            ex = ex.args[2]
            jlstruct = JLKwStruct(ex)
            #= none:330 =# @test jlstruct.doc == "Foo\n"
            #= none:331 =# @test (jlstruct.fields[1]).doc == "abc"
            #= none:332 =# @test (jlstruct.fields[2]).name === :b
            #= none:333 =# @test (jlstruct.constructors[1]).name === :Foo
            #= none:334 =# @test jlstruct.misc[1] == :(1 + 1)
            println(jlstruct)
            def = #= none:337 =# @expr(JLKwStruct, struct Foo3
                        a::Int = 1
                        Foo3(; a = 1) = begin
                                new(a)
                            end
                    end)
            #= none:342 =# @test_expr codegen_ast(def) == quote
                        struct Foo3
                            a::Int
                            Foo3(; a = 1) = begin
                                    new(a)
                                end
                        end
                        nothing
                    end
            def = #= none:350 =# @expr(JLKwStruct, struct Potts{Q}
                        L::Int
                        beta::Float64 = 1.0
                        neighbors::Neighbors = square_lattice_neighbors(L)
                    end)
            #= none:356 =# @test_expr codegen_ast_kwfn(def, :create) == quote
                        function create(::Type{S}; L, beta = 1.0, neighbors = square_lattice_neighbors(L)) where {Q, S <: Potts{Q}}
                            Potts{Q}(L, beta, neighbors)
                        end
                        nothing
                    end
            def = #= none:363 =# @expr(JLKwStruct, struct Flatten
                        x = 1
                        begin
                            y = 1
                        end
                    end)
            #= none:370 =# @test (def.fields[1]).name === :x
            #= none:371 =# @test (def.fields[2]).name === :y
        end
    #= none:374 =# @test sprint(showerror, AnalysisError("a", "b")) == "expect a expression, got b."
    #= none:376 =# @testset "JLIfElse" begin
            jl = JLIfElse()
            jl[:(foo(x))] = :(x = 1 + 1)
            jl[:(goo(x))] = :(y = 1 + 2)
            jl.otherwise = :(error("abc"))
            println(jl)
            ex = codegen_ast(jl)
            dst = JLIfElse(ex)
            #= none:385 =# @test_expr dst[:(foo(x))] == :(x = 1 + 1)
            #= none:386 =# @test_expr dst[:(goo(x))] == :(y = 1 + 2)
            #= none:387 =# @test_expr dst.otherwise == :(error("abc"))
        end
    #= none:390 =# @testset "JLFor" begin
            ex = :(for i = 1:10, j = 1:20, k = 1:10
                      1 + 1
                  end)
            jl = JLFor(ex)
            println(jl)
            #= none:397 =# @test codegen_ast(jl) == ex
            jl = JLFor(; vars = [:x], iterators = [:itr], kernel = :(x + 1))
            ex = codegen_ast(jl)
            #= none:401 =# @test ex.head === :for
            #= none:402 =# @test (ex.args[1]).args[1] == :(x = itr)
            #= none:403 =# @test ex.args[2] == :(x + 1)
            ex = :(for i = 1:10
                      1 + 1
                  end)
            jl = JLFor(ex)
            println(jl)
            #= none:410 =# @test jl.vars == [:i]
            #= none:411 =# @test jl.iterators == [:(1:10)]
        end
    #= none:414 =# @testset "is_matrix_expr" begin
            ex = #= none:415 =# @expr([1 2; 3 4])
            #= none:416 =# @test is_matrix_expr(ex) == true
            ex = #= none:417 =# @expr([1 2 3 4])
            #= none:418 =# @test is_matrix_expr(ex) == true
            ex = #= none:420 =# @expr(Float64[1 2; 3 4])
            #= none:421 =# @test is_matrix_expr(ex) == true
            ex = #= none:422 =# @expr([1 2 3 4])
            #= none:423 =# @test is_matrix_expr(ex) == true
            for ex = [#= none:427 =# @expr([1, 2, 3, 4]), #= none:428 =# @expr([1, 2, 3, 4]), #= none:429 =# @expr(Float64[1, 2, 3, 4])]
                #= none:431 =# @test is_matrix_expr(ex) == false
            end
            for ex = [#= none:435 =# @expr([1 2;;; 3 4;;; 4 5]), #= none:436 =# @expr(Float64[1 2;;; 3 4;;; 4 5])]
                #= none:438 =# @static if VERSION > v"1.7-"
                        #= none:439 =# @test is_matrix_expr(ex) == false
                    else
                        #= none:441 =# @test is_matrix_expr(ex) == true
                    end
            end
        end
    #= none:446 =# @testset "assert_equal_expr" begin
            lhs = quote
                    function foo(x)
                        x + 1
                    end
                end
            rhs = quote
                    function foo(x)
                        x + 1
                    end
                    nothing
                end
            #= none:460 =# @test_throws ExprNotEqual assert_equal_expr(Main, lhs, rhs)
            #= none:462 =# @test sprint(showerror, ExprNotEqual(Int64, :Int)) == "expression not equal due to:\n  lhs: Int64::DataType\n  rhs: :Int::Symbol\n"
            #= none:468 =# @test sprint(showerror, ExprNotEqual(empty_line, :Int)) == "expression not equal due to:\n  lhs: <empty line>\n  rhs: :Int::Symbol\n"
        end
    #= none:475 =# @testset "compare_expr" begin
            #= none:476 =# @test compare_expr(:(Vector{Int}), Vector{Int})
            #= none:477 =# @test compare_expr(:(Vector{Int}), :(Vector{$(nameof(Int))}))
            #= none:478 =# @test compare_expr(:(NotDefined{Int}), :(NotDefined{$(nameof(Int))}))
            #= none:479 =# @test compare_expr(:(NotDefined{Int, Float64}), :(NotDefined{$(nameof(Int)), Float64}))
            #= none:480 =# @test compare_expr(LineNumberNode(1, :foo), LineNumberNode(1, :foo))
        end
    #= none:483 =# @testset "guess_module" begin
            #= none:484 =# @test guess_module(Main, Base) === Base
            #= none:485 =# @test guess_module(Main, :Base) === Base
            #= none:486 =# @test guess_module(Main, :(1 + 1)) == :(1 + 1)
        end
    #= none:489 =# @testset "guess_type" begin
            #= none:490 =# @test guess_type(Main, Int) === Int
            #= none:491 =# @test guess_type(Main, :Int) === Int
            #= none:492 =# @test guess_type(Main, :Foo) === :Foo
            #= none:493 =# @test guess_type(Main, :(Array{Int, 1})) === Array{Int, 1}
            #= none:495 =# @test guess_type(Main, :(Array{<:Real, 1})) == :(Array{<:Real, 1})
        end
    #= none:498 =# @static if VERSION > v"1.8-"
            #= none:499 =# @testset "const <field> = <value>" begin
                    include("analysis/const.jl")
                end
        end
    #= none:504 =# @testset "check" begin
            include("analysis/check.jl")
        end
    #= none:508 =# @testset "compare" begin
            include("analysis/compare.jl")
        end
    #= none:512 =# @testset "generated" begin
            include("analysis/generated.jl")
        end
