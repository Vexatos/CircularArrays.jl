using CircularArrays
using OffsetArrays
using Test

@test IndexStyle(CircularArray) == IndexCartesian()
@test IndexStyle(CircularVector) == IndexLinear()

@testset "vector" begin
    data = rand(Int64, 5)
    v1 = CircularVector(data)

    @test size(v1, 1) == 5
    @test typeof(v1) == CircularVector{Int64}
    @test isa(v1, CircularVector)
    @test isa(v1, AbstractVector{Int})
    @test !isa(v1, AbstractVector{String})
    @test v1[2] == v1[2 + length(v1)]

    @test v1[0] == data[end]
    @test v1[-4:10] == [data; data; data]
    @test v1[-3:1][-1] == data[end]
    @test v1[[true,false,true,false,true]] == v1[[1,3,0]]

    v1copy = copy(v1)
    v1_2 = v1[2]
    v1[2] = 0
    v1[3] = 0
    @test v1[2] == v1[3] == 0
    @test v1copy[2] == v1_2
    @test v1copy[7] == v1_2
    @test_throws MethodError v1[2] = "Hello"

    v2 = CircularVector("abcde", 5)

    @test prod(v2) == "abcde"^5

    @test_throws MethodError push!(v1, 15)
end

@testset "matrix" begin
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
end

@testset "offset indices" begin
    i = OffsetArray(1:5,-3)
    a = CircularArray(i)
    @test axes(a) == axes(i)
    @test a[1] == 4
    @test a[10] == a[-10] == a[0] == 3
    @test a[-2:7] == [1:5; 1:5]
    @test a[0:9] == [3:5; 1:5; 1:2]
    @test a[1:10][-10] == 3
    @test a[i] == OffsetArray([4,5,1,2,3],-3)

    circ_a = circshift(a,3)
    @test axes(circ_a) == axes(a)
    @test circ_a[1:5] == 1:5

    j = OffsetArray([true,false,true],1)
    @test a[j] == [5,2]

    data = reshape(1:9,3,3)
    a = CircularArray(OffsetArray(data,-1,-1))
    @test collect(a) == data
    @test all(a[i,j] == data[mod1(i+1,3),mod1(j+1,3)] for i=-10:10, j=-10:10)
    @test a[i,1] == CircularArray(OffsetArray([5,6,4,5,6],-2:2))
    @test a[CartesianIndex.(i,i)] == CircularArray(OffsetArray([5,9,1,5,9],-2:2))
    @test a[a .> 4] == 5:9
end
