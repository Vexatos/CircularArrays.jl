"""
Arrays with fixed size and circular indexing.
"""
module CircularArrays

export CircularArray, CircularVector

"""
    CircularArray{T, N, A} <: AbstractArray{T, N}

`N`-dimensional array backed by an `AbstractArray{T, N}` of type `A` with fixed size and circular indexing.

    array[index] == array[mod1(index, size)]
"""
struct CircularArray{T, N, A} <: AbstractArray{T, N}
    data::A
    CircularArray{T,N}(data::AbstractArray{T,N}) where {T,N} = new{T,N,typeof(data)}(data)
end

"""
    CircularVector{T,A} <: AbstractVector{T}

One-dimensional array backed by an `AbstractArray{T, 1}` of type `A` with fixed size and circular indexing.
Alias for [`CircularArray{T,1,A}`](@ref).

    array[index] == array[mod1(index, size)]
"""
const CircularVector{T} = CircularArray{T, 1}

CircularArray(data::AbstractArray{T,N}) where {T,N} = CircularArray{T,N}(data)
CircularArray{T}(data::AbstractArray{T,N}) where {T,N} = CircularArray{T,N}(data)
CircularArray(def::T, size) where T = CircularArray(fill(def, size))

@inline Base.getindex(arr::CircularArray{T,N}, I::Vararg{<:Integer,N}) where {T,N} =
    @inbounds getindex(arr.data, mod.(I, axes(arr))...)
@inline Base.setindex!(arr::CircularArray{T,N}, v, I::Vararg{<:Integer,N}) where {T,N} =
    @inbounds setindex!(arr.data, v, mod.(I, axes(arr))...)
@inline Base.size(arr::CircularArray) = size(arr.data)
@inline Base.axes(arr::CircularArray) = axes(arr.data)
Base.parent(arr::CircularArray) = arr.data

@inline Base.checkbounds(::CircularArray, _...) = nothing

@inline _similar(arr::CircularArray, ::Type{T}, dims) where T = CircularArray(similar(arr.data,T,dims))
@inline Base.similar(arr::CircularArray, ::Type{T}, dims::Tuple{Base.DimOrInd, Vararg{Base.DimOrInd}}) where T = _similar(arr,T,dims)
# Ambiguity resolution with Base
@inline Base.similar(arr::CircularArray, ::Type{T}, dims::Tuple{Int64,Vararg{Int64}}) where T = _similar(arr,T,dims)

CircularVector(data::AbstractArray{T, 1}) where T = CircularVector{T}(data)
CircularVector(def::T, size::Int) where T = CircularVector{T}(fill(def, size))

Base.IndexStyle(::Type{<:CircularVector}) = IndexLinear()

end
