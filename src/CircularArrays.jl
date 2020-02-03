"""
Arrays with fixed size and circular indexing.
"""
module CircularArrays

export CircularArray, CircularVector

"""
    CircularArray{T, N} <: AbstractArray{T, N}

`N`-dimensional array backed by an AbstractArray{T, N} with fixed size and circular indexing.

    array[index] == array[mod1(index, size)]
"""
struct CircularArray{T, N, A} <: AbstractArray{T, N}
    data::A
    CircularArray{T,N}(data::AbstractArray{T,N}) where {T,N} = new{T,N,typeof(data)}(data)
end

"""
    CircularVector{T} <: AbstractVector{T}

One-dimensional array backed by an AbstractArray{T, 1} with fixed size and circular indexing.
Alias for [`CircularArray{T,1}`](@ref).

    array[index] == array[mod1(index, size)]
"""
const CircularVector{T} = CircularArray{T, 1}

@inline clamp_bounds(arr::CircularArray, I::Tuple{Vararg{Int}})::AbstractArray{Int, 1} = map(Base.splat(mod), zip(I, axes(arr.data)))

CircularArray(data::AbstractArray{T,N}) where {T,N} = CircularArray{T,N}(data)
CircularArray{T}(data::AbstractArray{T,N}) where {T,N} = CircularArray{T,N}(data)
CircularArray(def::T, size) where T = CircularArray(fill(def, size))

@inline Base.getindex(arr::CircularArray, i::Int) = @inbounds getindex(arr.data, mod(i, Base.axes1(arr.data)))
@inline Base.setindex!(arr::CircularArray, v, i::Int) = @inbounds setindex!(arr.data, v, mod(i, Base.axes1(arr.data)))
@inline Base.getindex(arr::CircularArray, I::Vararg{Int}) = @inbounds getindex(arr.data, clamp_bounds(arr, I)...)
@inline Base.setindex!(arr::CircularArray, v, I::Vararg{Int}) = @inbounds setindex!(arr.data, v, clamp_bounds(arr, I)...)
@inline Base.size(arr::CircularArray) = size(arr.data)
@inline Base.axes(arr::CircularArray) = axes(arr.data)

@inline Base.checkbounds(::CircularArray, _...) = nothing

@inline _similar(arr::CircularArray, ::Type{T}, dims) where T = CircularArray(similar(arr.data,T,dims))
@inline Base.similar(arr::CircularArray, ::Type{T}, dims::Tuple{Base.DimOrInd, Vararg{Base.DimOrInd}}) where T = _similar(arr,T,dims)
# Ambiguity resolution with Base
@inline Base.similar(arr::CircularArray, ::Type{T}, dims::Tuple{Int64,Vararg{Int64}}) where T = _similar(arr,T,dims)
# Ambiguity resolution with a type-pirating OffsetArrays method. See OffsetArrays issue #87.
# Ambiguity is triggered in the case similar(arr) where arr.data::OffsetArray.
# The OffsetAxis definition is copied from OffsetArrays.
const OffsetAxis = Union{Integer, UnitRange, Base.OneTo, Base.IdentityUnitRange, Colon}
@inline Base.similar(arr::CircularArray, ::Type{T}, dims::Tuple{OffsetAxis, Vararg{OffsetAxis}}) where T = _similar(arr,T,dims)

CircularVector(data::AbstractArray{T, 1}) where T = CircularVector{T}(data)
CircularVector(def::T, size::Int) where T = CircularVector{T}(fill(def, size))

Base.IndexStyle(::Type{<:CircularVector}) = IndexLinear()

end
