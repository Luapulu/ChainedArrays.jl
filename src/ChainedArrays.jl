module ChainedArrays

import Base: size, getindex, setindex!, (:), first, last

export ChainedVector

struct ChainedVector{T, N, A<:AbstractVector{T}} <: AbstractVector{T}
    chain::NTuple{N, A}
end

ChainedVector(vs::Vararg{A, N}) where {T, N, A<:AbstractVector{T}} = ChainedVector{T, N, A}(vs)

size(c::ChainedVector) = .+(size.(c.chain)...)

struct LinkIndex
    link::Int
    index::Int
end

getindex(c::ChainedVector, i::LinkIndex) = c.chain[i.link][i.index]
setindex!(c::ChainedVector, x, i::LinkIndex) = c.chain[i.link][i.index] = x

function tolinkindex(c::ChainedVector, i::Integer)
    s::Int, l = 0, 0
    while s < i
        s += size(c.chain[l += 1], 1)
    end
    return LinkIndex(l, i - s + length(c.chain[l]))
end

struct LinkIndices
    links::UnitRange{Int}
    indices::UnitRange{Int}
end

first(i::LinkIndices) = LinkIndex(first(i.links), first(i.indices))
last(i::LinkIndices) = LinkIndex(last(i.links), last(i.indices))

(:)(l1::LinkIndex, l2::LinkIndex) = LinkIndices(l1.link:l2.link, l1.index:l2.index)

function getindex(c::ChainedVector, i::LinkIndices)
    length(i.links) == 1 && return c.chain[first(i).link][i.indices]
    length(i.links) == 2 && return vcat(
        c.chain[first(i).link][first(i).index:end],
        c.chain[last(i).link][begin:last(i).index]
    )

    vs = Vector{Vector{eltype(eltype(c.chain))}}(undef, length(i.links))
    vs[begin] = c.chain[first(i).link][first(i).index:end]
    vs[end] = c.chain[last(i).link][begin:last(i).index]
    vs[begin + 1:end - 1] .= c.chain[first(i).link + 1:last(i).link - 1]
    return vcat(vs...)
end

function setindex!(c::ChainedVector, x, i::LinkIndices)
    length(i.links) == 1 && return setindex!(c.chain[first(i).link], x, i.indices)

    cl = c.chain[first(i).link]
    xl = lastindex(cl) - first(i).index + 1
    setindex!(cl, view(x, 1:xl), first(i).index:length(cl))

    for l in first(i).link + 1:last(i).link - 1
        cl = c.chain[l]
        setindex!(cl, view(x, xl+1:xl+length(cl)), :)
        xl += length(cl)
    end

    setindex!(c.chain[last(i).link], view(x, xl+1:length(x)), 1:last(i).index)

    return getindex(c, i)
end

tolinkindex(c::ChainedVector, r::AbstractUnitRange) =
    tolinkindex(c, first(r)):tolinkindex(c, last(r))

getindex(c::ChainedVector, I) = getindex(c, tolinkindex(c, I))
setindex!(c::ChainedVector, x, I) = setindex!(c, x, tolinkindex(c, I))

end
