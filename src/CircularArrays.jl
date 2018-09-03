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
struct CircularArray{T, N} <: AbstractArray{T, N}
    data::AbstractArray{T, N}
end

"""
    CircularVector{T} <: AbstractVector{T}

One-dimensional array backed by an AbstractArray{T, 1} with fixed size and circular indexing.
Alias for [`CircularArray{T,1}`](@ref).

    array[index] == array[mod1(index, size)]
"""
const CircularVector{T} = CircularArray{T, 1}

@inline clamp_bounds(arr::CircularArray, I::Tuple{Vararg{Int}})::AbstractArray{Int, 1} = map(dim -> mod1(I[dim], size(arr.data, dim)), eachindex(I))

CircularArray(def::T, size) where T = CircularArray(fill(def, size))

@inline Base.getindex(arr::CircularArray, i::Int) = @inbounds getindex(arr.data, mod1(i, size(arr.data, 1)))
@inline Base.setindex!(arr::CircularArray, v, i::Int) = @inbounds setindex!(arr.data, v, mod1(i, size(arr.data, 1)))
@inline Base.getindex(arr::CircularArray, I::Vararg{Int}) = @inbounds getindex(arr.data, clamp_bounds(arr, I)...)
@inline Base.setindex!(arr::CircularArray, v, I::Vararg{Int}) = @inbounds setindex!(arr.data, v, clamp_bounds(arr, I)...)
@inline Base.size(arr::CircularArray) = size(arr.data)

CircularVector(data::AbstractArray{T, 1}) where T = CircularVector{T}(data)
CircularVector(def::T, size::Int) where T = CircularVector{T}(fill(def, size))

Base.IndexStyle(::Type{<:CircularVector}) = IndexLinear()

end