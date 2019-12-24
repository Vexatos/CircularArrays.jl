# CircularArrays.jl - Multi-dimensional arrays with fixed size and circular indexing

CircularArrays.jl is a small package adding the `CircularArray{T, N}` type which can be backed by any `AbstractArray{T, N}`. A `CircularArray` has a fixed size and features circular indexing across all dimensions: Indexing and assigning beyond its bounds in both directions is possible, as the end of the array is considered adjacent to its start. `CircularArray`s have the same `axes` as the underlying backing array, and iterators only iterate over these indices.

The `CircularVector{T}` type is added as an alias for `CircularArray{T, 1}`.

The following constructors are provided.

```julia
# Initialize a CircularArray backed by any AbstractArray.
CircularArray(arr::AbstractArray{T, N}) where {T, N}
# Initialize a CircularArray with default values and the specified dimensions.
CircularArray(initialValue::T, dims...) where T
# Alternative functions for one-dimensional circular arrays.
CircularVector(arr::AbstractArray{T, 1}) where T
CircularVector(initialValue::T, size::Int) where T
```

### Examples

```julia
julia> using CircularArrays
julia> a = CircularArray([1,2,3]);
julia> a[0:4]
5-element CircularArray{Int64,1}:
 3
 1
 2
 3
 1
julia> using OffsetArrays
julia> i = OffsetArray(1:5,-2:2);
julia> a[i]
5-element CircularArray{Int64,1} with indices -2:2:
 1
 2
 3
 1
 2
```


### License

CircularArrays.jl is licensed under the [MIT license](LICENSE.md). By using or interacting with this software in any way, you agree to the license of this software.
