using ExproniconLite
using Documenter
using DocumenterMarkdown

makedocs(;
    modules=[ExproniconLite],
    authors="Roger-luo <rogerluo.rl18@gmail.com> and contributors",
    repo="https://github.com/Roger-luo/ExproniconLite.jl/blob/{commit}{path}#{line}",
    sitename="ExproniconLite.jl",
    format=Markdown(),
    build=pkgdir(ExproniconLite, "docs_build"),
    doctest=false,
    source = "src",
    pages=[
        "API Reference" => "api.md",
    ],
)
