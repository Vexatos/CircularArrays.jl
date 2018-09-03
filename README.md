# CircularArrays.jl - Multi-dimensional arrays with fixed size and circular indexing

CircularArrays.jl is a small package adding the `CircularArray{T, N}` type which can be backed by any `AbstractArray{T, N}`. A `CircularArray` has a fixed size and features circular indexing across all dimensions: Indexing and assigning beyond its bounds is possible, as the end of the array is considered adjacent to its start; indices less than 1 are possible too. Iterators will still stop at the end of the array, and indexing using ranges is only possible with ranges within the bounds of the backing array.

The `CircularVector{T}` type is added as an alias for `CircularArray{T, 1}`.

```julia
# CircularArrays use mod1 for their circular behaviour.
array[index] == array[mod1(index, size)]
```

The following functions are provided.

```julia
# Initialize a CircularArray backed by any AbstractArray.
CircularArray(arr::AbstractArray{T, N}) where {T, N}
# Initialize a CircularArray with default values and the specified dimensions.
CircularArray(initialValue::T, dims...) where T
# Alternative functions for one-dimensional circular arrays.
CircularVector(arr::AbstractArray{T, 1}) where T
CircularVector(initialValue::T, size::Int) where T
```

### License

CircularArrays.jl is licensed under the [MIT license](LICENSE.md). By using or interacting with this software in any way, you agree to the license of this software.