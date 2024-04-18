"""
Arrays with fixed size and circular indexing.
"""
module CircularArrays

export AbstractCircularArray, AbstractCircularVector, AbstractCircularMatrix
export CircularArray, CircularVector, CircularMatrix

abstract type AbstractCircularArray{T,N} <: AbstractArray{T,N} end

const AbstractCircularVector{T} = AbstractCircularArray{T,1}
const AbstractCircularMatrix{T} = AbstractCircularArray{T,2}

Base.parent(arg::AbstractCircularArray) = arg.data

Base.IndexStyle(::Type{<:AbstractCircularArray}) = IndexCartesian()
Base.IndexStyle(::Type{<:AbstractCircularVector}) = IndexLinear()

@inline Base.getindex(arr::AbstractCircularArray, i::Int) = @inbounds getindex(parent(arr), mod(i, eachindex(IndexLinear(), parent(arr))))
@inline Base.getindex(arr::AbstractCircularArray{T,N}, I::Vararg{Int,N}) where {T,N} = @inbounds getindex(parent(arr), mod.(I, axes(parent(arr)))...)

@inline Base.setindex!(arr::AbstractCircularArray, v, i::Int) = @inbounds setindex!(parent(arr), v, mod(i, eachindex(IndexLinear(), parent(arr))))
@inline Base.setindex!(arr::AbstractCircularArray{T,N}, v, I::Vararg{Int,N}) where {T,N} = @inbounds setindex!(parent(arr), v, mod.(I, axes(parent(arr)))...)

@inline Base.size(arr::AbstractCircularArray) = size(parent(arr))
@inline Base.axes(arr::AbstractCircularArray) = axes(parent(arr))

@inline Base.iterate(arr::AbstractCircularArray, i...) = iterate(parent(arr), i...)

@inline Base.in(x, arr::AbstractCircularArray) = in(x, parent(arr))

@inline function Base.checkbounds(arr::AbstractCircularArray, I...)
    J = Base.to_indices(arr, I)
    length(J) == 1 || length(J) >= ndims(arr) || throw(BoundsError(arr, I))
    nothing
end

@inline Base.dataids(arr::AbstractCircularArray) = Base.dataids(parent(arr))

function Base.deleteat!(a::AbstractCircularVector, i::Integer)
    deleteat!(parent(a), mod(i, eachindex(IndexLinear(), parent(a))))
    a
end

function Base.deleteat!(a::AbstractCircularVector, inds)
    deleteat!(parent(a), sort!(unique(map(i -> mod(i, eachindex(IndexLinear(), parent(a))), inds))))
    a
end

function Base.insert!(a::AbstractCircularVector, i::Integer, item)
    insert!(parent(a), mod(i, eachindex(IndexLinear(), parent(a))), item)
    a
end

"""
    CircularArray{T, N, A} <: AbstractArray{T, N}

`N`-dimensional array backed by an `AbstractArray{T, N}` of type `A` with fixed size and circular indexing.

    array[index...] == array[mod1.(index, size)...]
"""
struct CircularArray{T,N,A} <: AbstractCircularArray{T,N}
    data::A
    CircularArray{T,N}(data::A) where A <: AbstractArray{T,N} where {T,N} = new{T,N,A}(data)
    CircularArray{T,N,A}(data::A) where A <: AbstractArray{T,N} where {T,N} = new{T,N,A}(data)
end

"""
    CircularVector{T,A} <: AbstractVector{T}

One-dimensional array backed by an `AbstractArray{T, 1}` of type `A` with fixed size and circular indexing.
Alias for [`CircularArray{T,1,A}`](@ref).

    array[index] == array[mod1(index, length)]
"""
const CircularVector{T} = CircularArray{T, 1}

"""
    CircularMatrix{T,A} <: AbstractMatrix{T}

Two-dimensional array backed by an `AbstractArray{T, 2}` of type `A` with fixed size and circular indexing.
Alias for [`CircularArray{T,2,A}`](@ref).
"""
const CircularMatrix{T} = CircularArray{T, 2}

"""
    CircularArray(data)

Create a `CircularArray` wrapping the array `data`.
"""
CircularArray(data::AbstractArray{T,N}) where {T,N} = CircularArray{T,N}(data)
CircularArray{T}(data::AbstractArray{T,N}) where {T,N} = CircularArray{T,N}(data)

"""
    CircularArray(def, size)

Create a `CircularArray` of size `size` filled with value `def`.
"""
CircularArray(def::T, size) where T = CircularArray(fill(def, size))

@inline Base.parent(arr::CircularArray) = arr.data
@inline Base.copy(arr::CircularArray) = CircularArray(copy(parent(arr)))

@inline _similar(arr::CircularArray, ::Type{T}, dims) where T = CircularArray(similar(parent(arr), T, dims))
@inline Base.similar(arr::CircularArray, ::Type{T}, dims::Tuple{Base.DimOrInd, Vararg{Base.DimOrInd}}) where T = _similar(arr, T, dims)
# Ambiguity resolution with Base
@inline Base.similar(arr::CircularArray, ::Type{T}, dims::Dims) where T = _similar(arr, T, dims)
@inline Base.similar(arr::CircularArray, ::Type{T}, dims::Tuple{Integer, Vararg{Integer}}) where T = _similar(arr, T, dims)
@inline Base.similar(arr::CircularArray, ::Type{T}, dims::Tuple{Union{Integer, Base.OneTo}, Vararg{Union{Integer, Base.OneTo}}}) where T = _similar(arr, T, dims)

@inline _similar(::Type{CircularArray{T,N,A}}, dims) where {T,N,A} = CircularArray{T,N}(similar(A, dims))
@inline Base.similar(CA::Type{CircularArray{T,N,A}}, dims::Tuple{Base.DimOrInd, Vararg{Base.DimOrInd}}) where {T,N,A} = _similar(CA, dims)
# Ambiguity resolution with Base
@inline Base.similar(CA::Type{CircularArray{T,N,A}}, dims::Dims) where {T,N,A} = _similar(CA, dims)
@inline Base.similar(CA::Type{CircularArray{T,N,A}}, dims::Tuple{Union{Integer, Base.OneTo}, Vararg{Union{Integer, Base.OneTo}}}) where {T,N,A} = _similar(CA, dims)

@inline Broadcast.BroadcastStyle(::Type{CircularArray{T,N,A}}) where {T,N,A} = Broadcast.ArrayStyle{CircularArray{T,N,A}}()
@inline Base.similar(bc::Broadcast.Broadcasted{Broadcast.ArrayStyle{CircularArray{T,N,A}}}, ::Type{ElType}) where {T,N,A,ElType} = CircularArray(similar(convert(Broadcast.Broadcasted{typeof(Broadcast.BroadcastStyle(A))}, bc), ElType))

function Base.showarg(io::IO, arr::CircularArray, toplevel)
    print(io, ndims(arr) == 1 ? "CircularVector(" : "CircularArray(")
    Base.showarg(io, parent(arr), false)
    print(io, ')')
    # toplevel && print(io, " with eltype ", eltype(arr))
end

"""
    CircularVector(data)

Create a `CircularVector` wrapping the array `data`.
"""
CircularVector(data::AbstractArray{T, 1}) where T = CircularVector{T}(data)

"""
    CircularMatrix(data)

Create a `CircularMatrix` wrapping the array `data`.
"""
CircularMatrix(data::AbstractArray{T, 2}) where T = CircularMatrix{T}(data)


"""
    CircularVector(def, size)

Create a `CircularVector` of size `size` filled with value `def`.
"""
CircularVector(def::T, size::Int) where T = CircularVector{T}(fill(def, size))

"""
    CircularMatrix(def, size)

Create a `CircularMatrix` of size `size` filled with value `def`.
"""
CircularMatrix(def::T, size::NTuple{2, Integer}) where T = CircularMatrix{T}(fill(def, size))

Base.empty(::CircularVector{T}, ::Type{U}=T) where {T,U} = CircularVector{U}(U[])
Base.empty!(a::CircularVector) = (empty!(parent(a)); a)
Base.push!(a::CircularVector, x...) = (push!(parent(a), x...); a)
Base.append!(a::CircularVector, items) = (append!(parent(a), items); a)
Base.resize!(a::CircularVector, nl::Integer) = (resize!(parent(a), nl); a)
Base.pop!(a::CircularVector) = pop!(parent(a))
Base.sizehint!(a::CircularVector, sz::Integer) = (sizehint!(parent(a), sz); a)

end
