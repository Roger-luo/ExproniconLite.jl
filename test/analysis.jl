
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
        end
    #= none:174 =# @testset "JLStruct(ex)" begin
            #= none:175 =# @test (JLField(; name = :x)).name === :x
            #= none:176 =# @test (JLField(; name = :x)).type === Any
            #= none:177 =# @test (JLStruct(; name = :Foo)).name === :Foo
            ex = :(struct Foo
                      x::Int
                  end)
            jlstruct = JLStruct(ex)
            println(jlstruct)
            #= none:185 =# @test jlstruct.name === :Foo
            #= none:186 =# @test jlstruct.ismutable === false
            #= none:187 =# @test length(jlstruct.fields) == 1
            #= none:188 =# @test (jlstruct.fields[1]).name === :x
            #= none:189 =# @test (jlstruct.fields[1]).type === :Int
            #= none:190 =# @test (jlstruct.fields[1]).line isa LineNumberNode
            #= none:191 =# @test codegen_ast(jlstruct) == ex
            ex = :(mutable struct Foo{T, S <: Real} <: AbstractArray
                      a::Float64
                      function foo(x, y, z)
                          new(1)
                      end
                  end)
            jlstruct = JLStruct(ex)
            println(jlstruct)
            #= none:203 =# @test jlstruct.ismutable == true
            #= none:204 =# @test jlstruct.name === :Foo
            #= none:205 =# @test jlstruct.typevars == Any[:T, :(S <: Real)]
            #= none:206 =# @test jlstruct.supertype == :AbstractArray
            #= none:207 =# @test jlstruct.misc[1] == (ex.args[3]).args[end]
            #= none:208 =# @test rm_lineinfo(codegen_ast(jlstruct)) == rm_lineinfo(ex)
            ex = quote
                    #= none:211 =# Core.@doc "Foo\n" struct Foo
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
            #= none:225 =# @test jlstruct.doc == "Foo\n"
            #= none:226 =# @test (jlstruct.fields[1]).doc == "xyz"
            #= none:227 =# @test (jlstruct.fields[2]).type === Any
            #= none:228 =# @test (jlstruct.constructors[1]).name === :Foo
            #= none:229 =# @test (jlstruct.constructors[1]).args[1] === :x
            #= none:230 =# @test jlstruct.misc[1] == :(1 + 1)
            ast = codegen_ast(jlstruct)
            #= none:232 =# @test ast.args[1] == GlobalRef(Core, Symbol("@doc"))
            #= none:233 =# @test ast.args[3] == "Foo\n"
            #= none:234 =# @test (ast.args[4]).head === :struct
            #= none:235 =# @test is_function(((ast.args[4]).args[end]).args[end - 1])
            println(jlstruct)
            #= none:238 =# @test_throws SyntaxError split_struct_name(:(function Foo end))
        end
    #= none:241 =# @testset "JLKwStruct" begin
            def = #= none:242 =# @expr(JLKwStruct, struct Trait
                    end)
            #= none:243 =# @test_expr codegen_ast_kwfn(def) == quote
                        nothing
                    end
            #= none:247 =# @test (JLKwField(; name = :x)).name === :x
            #= none:248 =# @test (JLKwField(; name = :x)).type === Any
            #= none:249 =# @test (JLKwStruct(; name = :Foo)).name === :Foo
            def = #= none:251 =# @expr(JLKwStruct, struct ConvertOption
                        include_defaults::Bool = false
                        exclude_nothing::Bool = false
                    end)
            #= none:256 =# @test_expr codegen_ast_kwfn(def, :create) == quote
                        function create(::Type{S}; include_defaults = false, exclude_nothing = false) where S <: ConvertOption
                            ConvertOption(include_defaults, exclude_nothing)
                        end
                        nothing
                    end
            def = #= none:263 =# @expr(JLKwStruct, struct Foo1{N, T}
                        x::T = 1
                    end)
            println(def)
            #= none:268 =# @test_expr codegen_ast_kwfn(def, :create) == quote
                        function create(::Type{S}; x = 1) where {N, T, S <: Foo1{N, T}}
                            Foo1{N, T}(x)
                        end
                        function create(::Type{S}; x = 1) where {N, S <: Foo1{N}}
                            Foo1{N}(x)
                        end
                    end
            #= none:277 =# @test_expr codegen_ast(def) == quote
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
            def = #= none:290 =# @expr(JLKwStruct, struct Foo2 <: AbstractFoo
                        x = 1
                        y::Int
                    end)
            #= none:295 =# @test_expr codegen_ast(def) == quote
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
                    #= none:307 =# Core.@doc "Foo\n" mutable struct Foo
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
            #= none:321 =# @test jlstruct.doc == "Foo\n"
            #= none:322 =# @test (jlstruct.fields[1]).doc == "abc"
            #= none:323 =# @test (jlstruct.fields[2]).name === :b
            #= none:324 =# @test (jlstruct.constructors[1]).name === :Foo
            #= none:325 =# @test jlstruct.misc[1] == :(1 + 1)
            println(jlstruct)
            def = #= none:328 =# @expr(JLKwStruct, struct Foo3
                        a::Int = 1
                        Foo3(; a = 1) = begin
                                new(a)
                            end
                    end)
            #= none:333 =# @test_expr codegen_ast(def) == quote
                        struct Foo3
                            a::Int
                            Foo3(; a = 1) = begin
                                    new(a)
                                end
                        end
                        nothing
                    end
            def = #= none:341 =# @expr(JLKwStruct, struct Potts{Q}
                        L::Int
                        beta::Float64 = 1.0
                        neighbors::Neighbors = square_lattice_neighbors(L)
                    end)
            #= none:347 =# @test_expr codegen_ast_kwfn(def, :create) == quote
                        function create(::Type{S}; L, beta = 1.0, neighbors = square_lattice_neighbors(L)) where {Q, S <: Potts{Q}}
                            Potts{Q}(L, beta, neighbors)
                        end
                        nothing
                    end
            def = #= none:354 =# @expr(JLKwStruct, struct Flatten
                        x = 1
                        begin
                            y = 1
                        end
                    end)
            #= none:361 =# @test (def.fields[1]).name === :x
            #= none:362 =# @test (def.fields[2]).name === :y
        end
    #= none:365 =# @test sprint(showerror, AnalysisError("a", "b")) == "expect a expression, got b."
    #= none:367 =# @testset "JLIfElse" begin
            jl = JLIfElse()
            jl[:(foo(x))] = :(x = 1 + 1)
            jl[:(goo(x))] = :(y = 1 + 2)
            jl.otherwise = :(error("abc"))
            println(jl)
            ex = codegen_ast(jl)
            dst = JLIfElse(ex)
            #= none:376 =# @test_expr dst[:(foo(x))] == :(x = 1 + 1)
            #= none:377 =# @test_expr dst[:(goo(x))] == :(y = 1 + 2)
            #= none:378 =# @test_expr dst.otherwise == :(error("abc"))
        end
    #= none:381 =# @testset "JLFor" begin
            ex = :(for i = 1:10, j = 1:20, k = 1:10
                      1 + 1
                  end)
            jl = JLFor(ex)
            println(jl)
            #= none:388 =# @test codegen_ast(jl) == ex
            jl = JLFor(; vars = [:x], iterators = [:itr], kernel = :(x + 1))
            ex = codegen_ast(jl)
            #= none:392 =# @test ex.head === :for
            #= none:393 =# @test (ex.args[1]).args[1] == :(x = itr)
            #= none:394 =# @test ex.args[2] == :(x + 1)
            ex = :(for i = 1:10
                      1 + 1
                  end)
            jl = JLFor(ex)
            println(jl)
            #= none:401 =# @test jl.vars == [:i]
            #= none:402 =# @test jl.iterators == [:(1:10)]
        end
    #= none:405 =# @testset "is_matrix_expr" begin
            ex = #= none:406 =# @expr([1 2; 3 4])
            #= none:407 =# @test is_matrix_expr(ex) == true
            ex = #= none:408 =# @expr([1 2 3 4])
            #= none:409 =# @test is_matrix_expr(ex) == true
            ex = #= none:411 =# @expr(Float64[1 2; 3 4])
            #= none:412 =# @test is_matrix_expr(ex) == true
            ex = #= none:413 =# @expr([1 2 3 4])
            #= none:414 =# @test is_matrix_expr(ex) == true
            for ex = [#= none:418 =# @expr([1, 2, 3, 4]), #= none:419 =# @expr([1, 2, 3, 4]), #= none:420 =# @expr(Float64[1, 2, 3, 4])]
                #= none:422 =# @test is_matrix_expr(ex) == false
            end
            for ex = [#= none:426 =# @expr([1 2;;; 3 4;;; 4 5]), #= none:427 =# @expr(Float64[1 2;;; 3 4;;; 4 5])]
                #= none:429 =# @static if VERSION > v"1.7-"
                        #= none:430 =# @test is_matrix_expr(ex) == false
                    else
                        #= none:432 =# @test is_matrix_expr(ex) == true
                    end
            end
        end
    #= none:437 =# @testset "assert_equal_expr" begin
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
            #= none:451 =# @test_throws ExprNotEqual assert_equal_expr(Main, lhs, rhs)
            #= none:453 =# @test sprint(showerror, ExprNotEqual(Int64, :Int)) == "expression not equal due to:\n  lhs: Int64::DataType\n  rhs: :Int::Symbol\n"
            #= none:459 =# @test sprint(showerror, ExprNotEqual(empty_line, :Int)) == "expression not equal due to:\n  lhs: <empty line>\n  rhs: :Int::Symbol\n"
        end
    #= none:466 =# @testset "compare_expr" begin
            #= none:467 =# @test compare_expr(:(Vector{Int}), Vector{Int})
            #= none:468 =# @test compare_expr(:(Vector{Int}), :(Vector{$(nameof(Int))}))
            #= none:469 =# @test compare_expr(:(NotDefined{Int}), :(NotDefined{$(nameof(Int))}))
            #= none:470 =# @test compare_expr(:(NotDefined{Int, Float64}), :(NotDefined{$(nameof(Int)), Float64}))
            #= none:471 =# @test compare_expr(LineNumberNode(1, :foo), LineNumberNode(1, :foo))
        end
    #= none:474 =# @testset "guess_module" begin
            #= none:475 =# @test guess_module(Main, Base) === Base
            #= none:476 =# @test guess_module(Main, :Base) === Base
            #= none:477 =# @test guess_module(Main, :(1 + 1)) == :(1 + 1)
        end
    #= none:480 =# @testset "guess_type" begin
            #= none:481 =# @test guess_type(Main, Int) === Int
            #= none:482 =# @test guess_type(Main, :Int) === Int
            #= none:483 =# @test guess_type(Main, :Foo) === :Foo
            #= none:484 =# @test guess_type(Main, :(Array{Int, 1})) === Array{Int, 1}
            #= none:486 =# @test guess_type(Main, :(Array{<:Real, 1})) == :(Array{<:Real, 1})
        end
    #= none:489 =# @static if VERSION > v"1.8-"
            #= none:490 =# @testset "const <field> = <value>" begin
                    include("analysis/const.jl")
                end
        end
    #= none:495 =# @testset "check" begin
            include("analysis/check.jl")
        end
    #= none:499 =# @testset "compare" begin
            include("analysis/compare.jl")
        end
    #= none:503 =# @testset "generated" begin
            include("analysis/generated.jl")
        end
