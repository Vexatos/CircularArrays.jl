using CircularArrays
using Test

v1 = CircularVector(rand(Int64, 5))

@test IndexStyle(CircularArray) == IndexCartesian()
@test IndexStyle(CircularVector) == IndexLinear()

@test size(v1, 1) == 5
@test typeof(v1) == CircularVector{Int64}
@test isa(v1, CircularVector)
@test isa(v1, AbstractVector{Int})
@test !isa(v1, AbstractVector{String})
@test v1[2] == v1[2 + length(v1)]
v1[2] = 0
v1[3] = 0
@test v1[2] == v1[3]
@test_throws MethodError v1[2] = "Hello"

v2 = CircularVector("abcde", 5)

@test prod(v2) == "abcde"^5

@test_throws MethodError push!(v1, 15)

b_arr = [2 4 6 8; 10 12 14 16; 18 20 22 24]
a1 = CircularArray(b_arr)
@test size(a1) == (3, 4)
@test a1[2, 3] == 14
a1[2, 3] = 17
@test a1[2, 3] == 17
@test !isa(a1, CircularVector)
@test !isa(a1, AbstractVector)
@test isa(a1, AbstractArray)

@test size(reshape(a1, (2, 2, 3))) == (2, 2, 3)

a2 = CircularArray(4, (2, 3))
@test isa(a2, CircularArray{Int, 2})
