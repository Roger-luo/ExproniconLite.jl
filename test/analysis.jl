
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
            ex = :(function (x::Int,; $(Expr(:(=), :kw, 1)))
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
            #= none:131 =# @test_expr JLFunction function (x::Int,; $(Expr(:(=), :kw, 1)))
                end
            ex = :(struct Foo
                  end)
            #= none:134 =# @test_throws SyntaxError JLFunction(ex)
            ex = :(#= none:135 =# @foo(2, 3))
            #= none:136 =# @test_throws SyntaxError split_function_head(ex)
            ex = :(Foo(; a = 1) = begin
                          new(a)
                      end)
            #= none:139 =# @test (JLFunction(ex)).kwargs[1] == Expr(:kw, :a, 1)
            #= none:141 =# @test_expr JLFunction function (f(x::T; a = 10)::Int) where T
                    return x
                end
            #= none:145 =# @test_expr JLFunction f(x::Int)::Int = begin
                        x
                    end
        end
    #= none:148 =# @testset "JLStruct(ex)" begin
            #= none:149 =# @test (JLField(; name = :x)).name === :x
            #= none:150 =# @test (JLField(; name = :x)).type === Any
            #= none:151 =# @test (JLStruct(; name = :Foo)).name === :Foo
            ex = :(struct Foo
                      x::Int
                  end)
            jlstruct = JLStruct(ex)
            println(jlstruct)
            #= none:159 =# @test jlstruct.name === :Foo
            #= none:160 =# @test jlstruct.ismutable === false
            #= none:161 =# @test length(jlstruct.fields) == 1
            #= none:162 =# @test (jlstruct.fields[1]).name === :x
            #= none:163 =# @test (jlstruct.fields[1]).type === :Int
            #= none:164 =# @test (jlstruct.fields[1]).line isa LineNumberNode
            #= none:165 =# @test codegen_ast(jlstruct) == ex
            ex = :(mutable struct Foo{T, S <: Real} <: AbstractArray
                      a::Float64
                      function foo(x, y, z)
                          new(1)
                      end
                  end)
            jlstruct = JLStruct(ex)
            println(jlstruct)
            #= none:177 =# @test jlstruct.ismutable == true
            #= none:178 =# @test jlstruct.name === :Foo
            #= none:179 =# @test jlstruct.typevars == Any[:T, :(S <: Real)]
            #= none:180 =# @test jlstruct.supertype == :AbstractArray
            #= none:181 =# @test jlstruct.misc[1] == (ex.args[3]).args[end]
            #= none:182 =# @test rm_lineinfo(codegen_ast(jlstruct)) == rm_lineinfo(ex)
            ex = quote
                    #= none:185 =# Core.@doc "Foo\n" struct Foo
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
            #= none:199 =# @test jlstruct.doc == "Foo\n"
            #= none:200 =# @test (jlstruct.fields[1]).doc == "xyz"
            #= none:201 =# @test (jlstruct.fields[2]).type === Any
            #= none:202 =# @test (jlstruct.constructors[1]).name === :Foo
            #= none:203 =# @test (jlstruct.constructors[1]).args[1] === :x
            #= none:204 =# @test jlstruct.misc[1] == :(1 + 1)
            ast = codegen_ast(jlstruct)
            #= none:206 =# @test ast.args[1] == GlobalRef(Core, Symbol("@doc"))
            #= none:207 =# @test ast.args[3] == "Foo\n"
            #= none:208 =# @test (ast.args[4]).head === :struct
            #= none:209 =# @test is_function(((ast.args[4]).args[end]).args[end - 1])
            println(jlstruct)
            #= none:212 =# @test_throws SyntaxError split_struct_name(:(function Foo end))
        end
    #= none:215 =# @testset "JLKwStruct" begin
            def = #= none:216 =# @expr(JLKwStruct, struct Trait
                    end)
            #= none:217 =# @test_expr codegen_ast_kwfn(def) == quote
                        nothing
                    end
            #= none:221 =# @test (JLKwField(; name = :x)).name === :x
            #= none:222 =# @test (JLKwField(; name = :x)).type === Any
            #= none:223 =# @test (JLKwStruct(; name = :Foo)).name === :Foo
            def = #= none:225 =# @expr(JLKwStruct, struct ConvertOption
                        include_defaults::Bool = false
                        exclude_nothing::Bool = false
                    end)
            #= none:230 =# @test_expr codegen_ast_kwfn(def, :create) == quote
                        function create(::Type{S}; include_defaults = false, exclude_nothing = false) where S <: ConvertOption
                            ConvertOption(include_defaults, exclude_nothing)
                        end
                        nothing
                    end
            def = #= none:237 =# @expr(JLKwStruct, struct Foo1{N, T}
                        x::T = 1
                    end)
            println(def)
            #= none:242 =# @test_expr codegen_ast_kwfn(def, :create) == quote
                        function create(::Type{S}; x = 1) where {N, T, S <: Foo1{N, T}}
                            Foo1{N, T}(x)
                        end
                        function create(::Type{S}; x = 1) where {N, S <: Foo1{N}}
                            Foo1{N}(x)
                        end
                    end
            #= none:251 =# @test_expr codegen_ast(def) == quote
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
            def = #= none:264 =# @expr(JLKwStruct, struct Foo2 <: AbstractFoo
                        x = 1
                        y::Int
                    end)
            #= none:269 =# @test_expr codegen_ast(def) == quote
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
                    #= none:281 =# Core.@doc "Foo\n" mutable struct Foo
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
            #= none:295 =# @test jlstruct.doc == "Foo\n"
            #= none:296 =# @test (jlstruct.fields[1]).doc == "abc"
            #= none:297 =# @test (jlstruct.fields[2]).name === :b
            #= none:298 =# @test (jlstruct.constructors[1]).name === :Foo
            #= none:299 =# @test jlstruct.misc[1] == :(1 + 1)
            println(jlstruct)
            def = #= none:302 =# @expr(JLKwStruct, struct Foo3
                        a::Int = 1
                        Foo3(; a = 1) = begin
                                new(a)
                            end
                    end)
            #= none:307 =# @test_expr codegen_ast(def) == quote
                        struct Foo3
                            a::Int
                            Foo3(; a = 1) = begin
                                    new(a)
                                end
                        end
                        nothing
                    end
            def = #= none:315 =# @expr(JLKwStruct, struct Potts{Q}
                        L::Int
                        beta::Float64 = 1.0
                        neighbors::Neighbors = square_lattice_neighbors(L)
                    end)
            #= none:321 =# @test_expr codegen_ast_kwfn(def, :create) == quote
                        function create(::Type{S}; L, beta = 1.0, neighbors = square_lattice_neighbors(L)) where {Q, S <: Potts{Q}}
                            Potts{Q}(L, beta, neighbors)
                        end
                        nothing
                    end
            def = #= none:328 =# @expr(JLKwStruct, struct Flatten
                        x = 1
                        begin
                            y = 1
                        end
                    end)
            #= none:335 =# @test (def.fields[1]).name === :x
            #= none:336 =# @test (def.fields[2]).name === :y
        end
    #= none:339 =# @test sprint(showerror, AnalysisError("a", "b")) == "expect a expression, got b."
    #= none:341 =# @testset "JLIfElse" begin
            jl = JLIfElse()
            jl[:(foo(x))] = :(x = 1 + 1)
            jl[:(goo(x))] = :(y = 1 + 2)
            jl.otherwise = :(error("abc"))
            println(jl)
            ex = codegen_ast(jl)
            dst = JLIfElse(ex)
            #= none:350 =# @test_expr dst[:(foo(x))] == :(x = 1 + 1)
            #= none:351 =# @test_expr dst[:(goo(x))] == :(y = 1 + 2)
            #= none:352 =# @test_expr dst.otherwise == :(error("abc"))
        end
    #= none:355 =# @testset "JLFor" begin
            ex = :(for i = 1:10, j = 1:20, k = 1:10
                      1 + 1
                  end)
            jl = JLFor(ex)
            println(jl)
            #= none:362 =# @test codegen_ast(jl) == ex
            jl = JLFor(; vars = [:x], iterators = [:itr], kernel = :(x + 1))
            ex = codegen_ast(jl)
            #= none:366 =# @test ex.head === :for
            #= none:367 =# @test (ex.args[1]).args[1] == :(x = itr)
            #= none:368 =# @test ex.args[2] == :(x + 1)
            ex = :(for i = 1:10
                      1 + 1
                  end)
            jl = JLFor(ex)
            println(jl)
            #= none:375 =# @test jl.vars == [:i]
            #= none:376 =# @test jl.iterators == [:(1:10)]
        end
    #= none:379 =# @testset "is_matrix_expr" begin
            ex = #= none:380 =# @expr([1 2; 3 4])
            #= none:381 =# @test is_matrix_expr(ex) == true
            ex = #= none:382 =# @expr([1 2 3 4])
            #= none:383 =# @test is_matrix_expr(ex) == true
            ex = #= none:385 =# @expr(Float64[1 2; 3 4])
            #= none:386 =# @test is_matrix_expr(ex) == true
            ex = #= none:387 =# @expr([1 2 3 4])
            #= none:388 =# @test is_matrix_expr(ex) == true
            for ex = [#= none:392 =# @expr([1, 2, 3, 4]), #= none:393 =# @expr([1, 2, 3, 4]), #= none:394 =# @expr(Float64[1, 2, 3, 4])]
                #= none:396 =# @test is_matrix_expr(ex) == false
            end
            for ex = [#= none:400 =# @expr([1 2;;; 3 4;;; 4 5]), #= none:401 =# @expr(Float64[1 2;;; 3 4;;; 4 5])]
                #= none:403 =# @static if VERSION > v"1.7-"
                        #= none:404 =# @test is_matrix_expr(ex) == false
                    else
                        #= none:406 =# @test is_matrix_expr(ex) == true
                    end
            end
        end
    #= none:411 =# @testset "assert_equal_expr" begin
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
            #= none:425 =# @test_throws ExprNotEqual assert_equal_expr(Main, lhs, rhs)
            #= none:427 =# @test sprint(showerror, ExprNotEqual(Int64, :Int)) == "expression not equal due to:\n  lhs: Int64::DataType\n  rhs: :Int::Symbol\n"
            #= none:433 =# @test sprint(showerror, ExprNotEqual(empty_line, :Int)) == "expression not equal due to:\n  lhs: <empty line>\n  rhs: :Int::Symbol\n"
        end
    #= none:440 =# @testset "compare_expr" begin
            #= none:441 =# @test compare_expr(:(Vector{Int}), Vector{Int})
            #= none:442 =# @test compare_expr(:(Vector{Int}), :(Vector{$(nameof(Int))}))
            #= none:443 =# @test compare_expr(:(NotDefined{Int}), :(NotDefined{$(nameof(Int))}))
            #= none:444 =# @test compare_expr(:(NotDefined{Int, Float64}), :(NotDefined{$(nameof(Int)), Float64}))
            #= none:445 =# @test compare_expr(LineNumberNode(1, :foo), LineNumberNode(1, :foo))
        end
    #= none:448 =# @testset "guess_module" begin
            #= none:449 =# @test guess_module(Main, Base) === Base
            #= none:450 =# @test guess_module(Main, :Base) === Base
            #= none:451 =# @test guess_module(Main, :(1 + 1)) == :(1 + 1)
        end
    #= none:454 =# @testset "guess_type" begin
            #= none:455 =# @test guess_type(Main, Int) === Int
            #= none:456 =# @test guess_type(Main, :Int) === Int
            #= none:457 =# @test guess_type(Main, :Foo) === :Foo
            #= none:458 =# @test guess_type(Main, :(Array{Int, 1})) === Array{Int, 1}
            #= none:460 =# @test guess_type(Main, :(Array{<:Real, 1})) == :(Array{<:Real, 1})
        end
    #= none:463 =# @static if VERSION > v"1.8-"
            #= none:464 =# @testset "const <field> = <value>" begin
                    include("analysis/const.jl")
                end
        end
    #= none:469 =# @testset "check" begin
            include("analysis/check.jl")
        end
    #= none:473 =# @testset "compare" begin
            include("analysis/compare.jl")
        end
    #= none:477 =# @testset "generated" begin
            include("analysis/generated.jl")
        end
