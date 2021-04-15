using MLStyle
using ExproniconLite
using Documenter
using ANSIColoredPrinters
using DocThemeIndigo

indigo = DocThemeIndigo.install(ExproniconLite)

makedocs(;
    modules=[ExproniconLite],
    authors="Roger-luo <rogerluo.rl18@gmail.com> and contributors",
    repo="https://github.com/Roger-luo/ExproniconLite.jl/blob/{commit}{path}#{line}",
    sitename="ExproniconLite.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://Roger-luo.github.io/ExproniconLite.jl",
        assets=String[indigo, "assets/default.css"],
    ),
    pages=[
        "Quick Start" => "index.md",
        "Case Study" => "case.md",
        "API Reference" => "reference.md",
    ],
)

deploydocs(;
    repo="github.com/Roger-luo/ExproniconLite.jl",
)
