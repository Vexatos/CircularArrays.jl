"""
Arrays with fixed size and circular indexing.
"""
module CircularArrays

export CircularArray, CircularVector

"""
    CircularArray{T, N, A} <: AbstractArray{T, N}

`N`-dimensional array backed by an `AbstractArray{T, N}` of type `A` with fixed size and circular indexing.

    array[index...] == array[mod1.(index, size)...]
"""
struct CircularArray{T, N, A} <: AbstractArray{T, N}
    data::A
    CircularArray{T,N}(data::AbstractArray{T,N}) where {T,N} = new{T,N,typeof(data)}(data)
end

"""
    CircularVector{T,A} <: AbstractVector{T}

One-dimensional array backed by an `AbstractArray{T, 1}` of type `A` with fixed size and circular indexing.
Alias for [`CircularArray{T,1,A}`](@ref).

    array[index] == array[mod1(index, length)]
"""
const CircularVector{T} = CircularArray{T, 1}

CircularArray(data::AbstractArray{T,N}) where {T,N} = CircularArray{T,N}(data)
CircularArray{T}(data::AbstractArray{T,N}) where {T,N} = CircularArray{T,N}(data)
CircularArray(def::T, size) where T = CircularArray(fill(def, size))

@inline Base.getindex(arr::CircularArray, i::Int) = @inbounds getindex(arr.data, mod1(i, length(arr.data)))
@inline Base.getindex(arr::CircularArray{T,N,A}, I::Vararg{<:Int,N}) where {T,N,A} = @inbounds getindex(arr.data, map(mod, I, axes(arr.data))...)

@inline Base.setindex!(arr::CircularArray, v, i::Int) = @inbounds setindex!(arr.data, v, mod1(i, length(arr.data)))
@inline Base.setindex!(arr::CircularArray{T,N,A}, v, I::Vararg{<:Int,N}) where {T,N,A} = @inbounds setindex!(arr.data, v, map(mod, I, axes(arr.data))...)

@inline Base.size(arr::CircularArray) = size(arr.data)
@inline Base.axes(arr::CircularArray) = axes(arr.data)
Base.parent(arr::CircularArray) = arr.data

@inline function Base.checkbounds(arr::CircularArray, I...)
    J = Base.to_indices(arr, I)
    length(J) == 1 || length(J) >= ndims(arr) || throw(BoundsError(arr, I))
    nothing
end

@inline _similar(arr::CircularArray, ::Type{T}, dims) where T = CircularArray(similar(arr.data,T,dims))
@inline Base.similar(arr::CircularArray, ::Type{T}, dims::Tuple{Base.DimOrInd, Vararg{Base.DimOrInd}}) where T = _similar(arr,T,dims)
# Ambiguity resolution with Base
@inline Base.similar(arr::CircularArray, ::Type{T}, dims::Tuple{Int64,Vararg{Int64}}) where T = _similar(arr,T,dims)

CircularVector(data::AbstractArray{T, 1}) where T = CircularVector{T}(data)
CircularVector(def::T, size::Int) where T = CircularVector{T}(fill(def, size))

Base.IndexStyle(::Type{CircularArray{T,N,A}}) where {T,N,A} = IndexCartesian()
Base.IndexStyle(::Type{<:CircularVector}) = IndexLinear()

function Base.showarg(io::IO, arr::CircularArray, toplevel)
    print(io, ndims(arr) == 1 ? "CircularVector(" : "CircularArray(")
    Base.showarg(io, parent(arr), false)
    print(io, ')')
    # toplevel && print(io, " with eltype ", eltype(arr))
end

function Base.deleteat!(a::CircularVector, i::Integer)
    deleteat!(a.data, mod(i, eachindex(a.data)))
    a
end

function Base.deleteat!(a::CircularVector, inds)
    deleteat!(a.data, sort!(unique(map(i -> mod(i, eachindex(a.data))))))
    a
end

end
