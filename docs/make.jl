using ExproniconLite
using Documenter

DocMeta.setdocmeta!(ExproniconLite, :DocTestSetup, :(using ExproniconLite); recursive=true)

makedocs(;
    modules=[ExproniconLite],
    authors="Roger-Luo <rogerluo.rl18@gmail.com> and contributors",
    repo="https://github.com/Roger-luo/ExproniconLite.jl/blob/{commit}{path}#{line}",
    sitename="ExproniconLite.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://Roger-luo.github.io/ExproniconLite.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/Roger-luo/ExproniconLite.jl",
)
