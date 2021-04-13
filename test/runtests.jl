using ExproniconLite
using Documenter
using Test

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
    include("printing.jl")
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

doctest(ExproniconLite)
