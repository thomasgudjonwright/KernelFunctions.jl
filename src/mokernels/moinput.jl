"""
    MOInputIsotopicByFeatures(x::AbstractVector, out_dim::Integer)

`MOInputIsotopicByFeatures(x, out_dim)` has length `out_dim * length(x)`.

```jldoctest
julia> x = [1, 2, 3];

julia> KernelFunctions.MOInputIsotopicByFeatures(x, 2)
6-element KernelFunctions.MOInputIsotopicByFeatures{Int64, Vector{Int64}}:
 (1, 1)
 (1, 2)
 (2, 1)
 (2, 2)
 (3, 1)
 (3, 2)
```

Accommodates modelling multi-dimensional output data where all outputs are always observed.

As shown above, an `MOInputIsotopicByFeatures` represents a vector of tuples.
The first `out_dim` elements represent all outputs for the first input, the second
`out_dim` elements represent the outputs for the second input, etc.

See [Inputs for Multiple Outputs](@ref) in the docs for more info.
"""
struct MOInputIsotopicByFeatures{S,T<:AbstractVector{S}} <: AbstractVector{Tuple{S,Int}}
    x::T
    out_dim::Int
end

"""
    MOInputIsotopicByOutputs(x::AbstractVector, out_dim::Integer)

`MOInputIsotopicByOutputs(x, out_dim)` has length `length(x) * out_dim`.

```jldoctest
julia> x = [1, 2, 3];

julia> KernelFunctions.MOInputIsotopicByOutputs(x, 2)
6-element KernelFunctions.MOInputIsotopicByOutputs{Int64, Vector{Int64}}:
 (1, 1)
 (2, 1)
 (3, 1)
 (1, 2)
 (2, 2)
 (3, 2)
```

Accommodates modelling multi-dimensional output data where all outputs are always observed.

As shown above, an `MOInputIsotopicByOutputs` represents a vector of tuples.
The first `length(x)` elements represent the inputs for the first output, the second
`length(x)` elements represent the inputs for the second output, etc.
"""
struct MOInputIsotopicByOutputs{S,T<:AbstractVector{S}} <: AbstractVector{Tuple{S,Int}}
    x::T
    out_dim::Int
end

const IsotopicMOInputs = Union{MOInputIsotopicByFeatures,MOInputIsotopicByOutputs}

function Base.getindex(inp::MOInputIsotopicByOutputs, ind::Integer)
    @boundscheck checkbounds(inp, ind)
    output_index, feature_index = fldmod1(ind, length(inp.x))
    feature = @inbounds inp.x[feature_index]
    return feature, output_index
end

function Base.getindex(inp::MOInputIsotopicByFeatures, ind::Integer)
    @boundscheck checkbounds(inp, ind)
    feature_index, output_index = fldmod1(ind, inp.out_dim)
    feature = @inbounds inp.x[feature_index]
    return feature, output_index
end

Base.size(inp::IsotopicMOInputs) = (inp.out_dim * length(inp.x),)

"""
    MOInput(x::AbstractVector, out_dim::Integer)
A data type to accommodate modelling multi-dimensional output data.
`MOInput(x, out_dim)` has length `length(x) * out_dim`.

```jldoctest
julia> x = [1, 2, 3];

julia> MOInput(x, 2)
6-element KernelFunctions.MOInputIsotopicByOutputs{Int64, Vector{Int64}}:
 (1, 1)
 (2, 1)
 (3, 1)
 (1, 2)
 (2, 2)
 (3, 2)
```
As shown above, an `MOInput` represents a vector of tuples.
The first `length(x)` elements represent the inputs for the first output, the second
`length(x)` elements represent the inputs for the second output, etc.
See [Inputs for Multiple Outputs](@ref) in the docs for more info.
"""
const MOInput = MOInputIsotopicByOutputs

"""
    isotopic_by_outputs(x::AbstractVector, out_dim::Integer)

Helper function to construct [`MOInputIsotopicByOutputs`](@ref).

```jldoctest isotopic_by_outputs
julia> x = [1, 2, 3];

julia> KernelFunctions.isotopic_by_outputs(x, 2) == KernelFunctions.MOInputIsotopicByOutputs(x, 2)
true
```
"""
isotopic_by_outputs(features, output_dim) = MOInputIsotopicByOutputs(features, output_dim)

"""
    isotopic_by_features(x::AbstractVector, out_dim::Integer)

Helper function to construct [`IsotopicByFeatures`](@ref).

```jldoctest isotopic_by_features
julia> x = [1, 2, 3];

julia> KernelFunctions.isotopic_by_features(x, 2) == KernelFunctions.MOInputIsotopicByFeatures(x, 2)
true
```
"""
isotopic_by_features(features, output_dim) = MOInputIsotopicByFeatures(features, output_dim)
