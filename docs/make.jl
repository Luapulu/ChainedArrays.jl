using ChainedArrays
using Documenter

makedocs(;
    modules=[ChainedArrays],
    authors="Paul Nemec <paul.nemec@tum.de> and contributors",
    repo="https://github.com/Luapulu/ChainedArrays.jl/blob/{commit}{path}#L{line}",
    sitename="ChainedArrays.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://Luapulu.github.io/ChainedArrays.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/Luapulu/ChainedArrays.jl",
)
