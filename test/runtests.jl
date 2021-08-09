using CircularArrays
using OffsetArrays
using Test

@testset "index style" begin
    @test IndexStyle(CircularArray) == IndexCartesian()
    @test IndexStyle(CircularVector) == IndexLinear()
end

@testset "construction" begin
    @testset "construction ($T)" for T = (Float64, Int)
        data = rand(T,10)
        arrays = [CircularVector(data), CircularVector{T}(data),
                CircularArray(data), CircularArray{T}(data), CircularArray{T,1}(data)]
        @test all(a == first(arrays) for a in arrays)
        @test all(a isa CircularVector{T,Vector{T}} for a in arrays)
    end
end

@testset "type stability" begin
    @testset "type stability $(n)d" for n in 1:10
        a = CircularArray(fill(1, ntuple(_->1, n)))

        @test @inferred(a[1]) isa Int64
        @test @inferred(a[[1]]) isa CircularVector{Int64}
        @test @inferred(a[[1]']) isa CircularArray{Int64,2}
        @test @inferred(axes(a)) isa Tuple{Vararg{AbstractUnitRange}}
        @test @inferred(similar(a)) isa typeof(a)
        @test @inferred(a[a]) isa typeof(a)
    end
end

@testset "display" begin
    @testset "display $(n)d" for n in 1:3
        data = rand(Int64, ntuple(_->3, n))
        v1 = CircularArray(data)
        io = IOBuffer()
        io_compare = IOBuffer()

        print(io, v1)
        print(io_compare, data)
        @test String(take!(io)) == String(take!(io_compare))

        print(io, summary(v1))
        print(io_compare, summary(data))

        text = String(take!(io_compare))
        text = replace(text, " Vector" => " CircularVector")
        text = replace(text, " Matrix" => " CircularArray")
        text = replace(text, " Array" => (n == 1 ? " CircularVector" : " CircularArray"))
        text = replace(text, r"{.+}" => "(::$(string(typeof(data))))")
        @test String(take!(io)) == text
    end
end

@testset "vector" begin
    data = rand(Int64, 5)
    v1 = CircularVector(data)

    @test size(v1, 1) == 5
    @test parent(v1) == data
    @test typeof(v1) == CircularVector{Int64,Vector{Int64}}
    @test isa(v1, CircularVector)
    @test isa(v1, AbstractVector{Int})
    @test !isa(v1, AbstractVector{String})
    @test v1[2] == v1[2 + length(v1)]

    @test IndexStyle(v1) == IndexStyle(typeof(v1)) == IndexLinear()
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

    @testset "deleteat!" begin
        @test deleteat!(CircularVector([1, 2, 3]), 5) == CircularVector([1, 3])
        @test deleteat!(CircularVector([1, 2, 3, 4]), 1:5:10) == CircularVector([3, 4])
        @test deleteat!(CircularVector([1, 2, 3, 4]), [1, 5]) == CircularVector([2, 3, 4])
        @test deleteat!(CircularVector([1, 2, 3, 4]), (1, 5)) == CircularVector([2, 3, 4])
        @test deleteat!(CircularVector([1, 2, 3, 4]), (1, 6)) == CircularVector([3, 4])
        @test deleteat!(CircularVector([1, 2, 3, 4]), (1, 3, 5)) == CircularVector([2, 4])
        @test deleteat!(CircularVector([1, 2, 3, 4]), (1, 5, 7)) == CircularVector([2, 4])
    end

    @testset "doubly circular" begin
        a = CircularVector([1, 2, 3, 4, 5])
        b = CircularVector(a)

        @test all(a[i] == b[i] for i in -50:50)
    end

    v3 = @inferred(map(x -> x+1, CircularArray([1, 2, 3, 4])))
    @test v3 == CircularArray([2, 3, 4, 5])
    @test similar(v3, Base.OneTo(4)) isa typeof(v3)
end

@testset "matrix" begin
    b_arr = [2 4 6 8; 10 12 14 16; 18 20 22 24]
    a1 = CircularArray(b_arr)
    @test size(a1) == (3, 4)
    @test parent(a1) == b_arr
    @test a1[2, 3] == 14
    @test a1[2, Int32(3)] == 14
    a1[2, 3] = 17
    @test a1[2, 3] == 17
    @test a1[-1, 7] == 17
    @test a1[CartesianIndex(-1, 7)] == 17
    @test a1[-1:5, 4:10][1, 4] == 17
    @test a1[:, -1:-1][2, 1] == 17
    a1[CartesianIndex(-2, 7)] = 99
    @test a1[1, 3] == 99

    a1[18] = 9
    @test a1[18] == a1[-6] == a1[6] == a1[3,2] == a1[0,6] == b_arr[3,2] == b_arr[6] == 9

    @test IndexStyle(a1) == IndexStyle(typeof(a1)) == IndexCartesian()
    @test a1[3] == a1[3,1]
    @test a1[Int32(4)] == a1[1,2]
    @test a1[-1] == a1[length(a1)-1]

    @test a1[2, 3, 1] == 17 # trailing index
    @test a1[2, 3, 99] == 17
    @test a1[2, 3, :] == [17]

    @test !isa(a1, CircularVector)
    @test !isa(a1, AbstractVector)
    @test isa(a1, AbstractArray)

    @test size(reshape(a1, (2, 2, 3))) == (2, 2, 3)

    a2 = CircularArray(4, (2, 3))
    @test isa(a2, CircularArray{Int, 2})

    @testset "doubly circular" begin
        a = CircularArray(b_arr)
        da = CircularArray(a)

        @test all(a[i, j] == da[i, j] for i in -8:8, j in -8:8)
        @test all(a[i] == da[i] for i in -50:50)
    end
end

@testset "3-array" begin
    t3 = collect(reshape('a':'x', 2,3,4))
    c3 = CircularArray(t3)

    @test parent(c3) == t3

    @test c3[1,3,3] == c3[3,3,3] == c3[3,3,7] == c3[3,3,7,1]

    c3[3,3,7] = 'Z'
    @test t3[1,3,3] == 'Z'

    @test c3[3, CartesianIndex(3,7)] == 'Z'
    c3[Int32(3), CartesianIndex(3,7)] = 'ζ'
    @test t3[1,3,3] == 'ζ'

    c3[34] = 'J'
    @test c3[34] == c3[-38] == c3[10] == c3[2,2,2] == c3[4,5,6] == t3[2,2,2] == t3[10] == 'J'

    @test vec(c3[:, [CartesianIndex()], 1, 5]) == vec(t3[:, 1, 1])

    @test IndexStyle(c3) == IndexStyle(typeof(c3)) == IndexCartesian()
    @test c3[-1] == t3[length(t3)-1]

    @test_throws BoundsError c3[2,3] # too few indices
    @test_throws BoundsError c3[CartesianIndex(2,3)]

    @testset "doubly circular" begin
        c = CircularArray(t3)
        dc = CircularArray(c)

        @test all(c[i, j, k] == dc[i, j, k] for i in -5:5, j in -5:5, k in -5:5)
        @test all(c[i] == dc[i] for i in -50:50)
    end
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

    @test @inferred(similar(a)) isa CircularVector

    circ_a = circshift(a,3)
    @test axes(circ_a) == axes(a)
    @test circ_a[1:5] == 1:5

    j = OffsetArray([true,false,true],1)
    @test a[j] == [5,2]

    data = reshape(1:9,3,3)
    a = CircularArray(OffsetArray(data,-1,-1))
    @test collect(a) == data
    @test all(a[x,y] == data[mod1(x+1,3),mod1(y+1,3)] for x=-10:10, y=-10:10)
    @test a[i,1] == CircularArray(OffsetArray([5,6,4,5,6],-2:2))
    @test a[CartesianIndex.(i,i)] == CircularArray(OffsetArray([5,9,1,5,9],-2:2))
    @test a[a .> 4] == 5:9
end
