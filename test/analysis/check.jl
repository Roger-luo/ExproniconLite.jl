using Test
using ExproniconLite

@test is_tuple(:((a, b, c)))
@test is_splat(:(f(x)...))
