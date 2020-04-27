"""
    LinearTransform(A::AbstractMatrix)

Apply the linear transformation realised by the matrix `A`.

The second dimension of `A` must match the number of features of the target.

# Examples

```julia-repl
julia> A = rand(10, 5)

julia> tr = LinearTransform(A)
```
"""
struct LinearTransform{T<:AbstractMatrix{<:Real}} <: Transform
    A::T
end

function set!(t::LinearTransform{<:AbstractMatrix{T}}, A::AbstractMatrix{T}) where {T<:Real}
    size(t.A) == size(A) || 
        error("Size of the given matrix $(size(A)) and the transformation matrix $(size(t.A)) are not the same")
    t.A .= A
end

(t::LinearTransform)(x::Real) = vec(t.A * x)
(t::LinearTransform)(x::AbstractVector{<:Real}) = t.A * x

Base.map(t::LinearTransform, x::AbstractVector{<:Real}) = ColVecs(t.A * x')
Base.map(t::LinearTransform, x::ColVecs) = ColVecs(t.A * x.X)
Base.map(t::LinearTransform, x::RowVecs) = RowVecs(x.X * t.A')

function Base.show(io::IO, t::LinearTransform)
    print(io::IO, "Linear transform (size(A) = ", size(t.A), ")")
end
