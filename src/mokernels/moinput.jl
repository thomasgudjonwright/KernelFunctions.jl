"""
    IsotopicByFeatures(x::AbstractVector, out_dim::Integer)

`IsotopicByFeatures(x, out_dim)` has length `length(x) * out_dim`.

```jldoctest
julia> x = [1, 2, 3];

julia> IsotopicByFeatures(x, 2)
6-element IsotopicByFeatures{Vector{Int64}}:
 (1, 1)
 (2, 1)
 (3, 1)
 (1, 2)
 (2, 2)
 (3, 2)
```

An abstract type to accomodate modelling multi-dimensional output data. There are two
subtypes that each specify a unique ordering of the dimensions.

As shown above, an `IsotopicByFeatures` represents a vector of tuples.
The first `length(x)` elements represent the inputs for the first output, the second
`length(x)` elements represent the inputs for the second output, etc.

See [Inputs for Multiple Outputs](@ref) in the docs for more info.
"""

struct IsotopicByFeatures{S,T<:AbstractVector{S}} <: AbstractVector{Tuple{T,Int}}
    x::T
    out_dim::Int
end

"""
    IsotopicByOutputs(x::AbstractVector, out_dim::Integer)

`IsotopicByOutputs(x, out_dim)` has length `out_dim * length(x)`.

```jldoctest
julia> x = [1, 2, 3];

julia> IsotopicByOutputs(x, 2)
6-element IsotopicByOutputs{Vector{Int64}}:
 (1, 1)
 (1, 2)
 (2, 1)
 (2, 2)
 (3, 1)
 (3, 2)
```

As shown above, an `IsotopicByOutputs` represents a vector of tuples.
The first `out_dim` elements represent all outputs for the first input, the second
`out_dim` elements represent the outputs for the second input, etc.
"""

struct IsotopicByOutputs{S,T<:AbstractVector{S}} <: AbstractVector{Tuple{T,Int}}
    x::T
    out_dim::Int
end

const IsotopicMOInputs = Union{IsotopicByFeatures, IsotopicByOutputs}

function Base.getindex(inp::IsotopicByOutputs, ind::Integer)
    @boundscheck checkbounds(inp, ind)
    output_index, feature_index = fldmod1(ind, length(inp.x))
    feature = @inbounds inp.x[feature_index]
    return feature, output_index
end

function Base.getindex(inp::IsotopicByFeatures, ind::Integer)
    @boundscheck checkbounds(inp, ind)
    feature_index, output_index = fldmod1(ind, inp.out_dim)
    feature = @inbounds inp.x[feature_index]
    return feature, output_index
end

Base.size(inp::IsotopicMOInputs) = (inp.out_dim * length(inp.x),)

Base.iterate(inp::IsotopicMOInputs) = (inp[1], 1)
function Base.iterate(inp::IsotopicMOInputs, state)
    return (state < length(inp)) ? (inp[state + 1], state + 1) : nothing
end
