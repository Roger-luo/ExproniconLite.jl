using ExproniconLite
using Documenter
using Test
using Aqua
Aqua.test_all(ExproniconLite)

@test_expr quote
    x + 1
    $nothing
end == quote
    x + 1
    $nothing
end

@testset "@test_expr" begin
    @test_expr quote
        x + 1
        $nothing
    end == quote
        x + 1
        $nothing
    end
end

@testset "printings" begin
    include("print/inline.jl")
    include("print/multi.jl")
    include("print/old.jl")

    @static if VERSION > v"1.8-"
        include("print/lts.jl")
    end
end

@testset "analysis" begin
    include("analysis.jl")
end

@testset "transform" begin
    include("transform.jl")
end

@testset "match" begin
    nothing
end

@testset "codegen" begin
    include("codegen.jl")
end

@testset "adt" begin
    nothing
end

# this feature is only available for 1.6+
@static if VERSION > v"1.6-" && Sys.isunix()
    @testset "expand" begin
        nothing
    end
end

DocMeta.setdocmeta!(ExproniconLite, :DocTestSetup, :(using ExproniconLite); recursive=true)
doctest(ExproniconLite)
