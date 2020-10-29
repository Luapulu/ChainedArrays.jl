using ChainedArrays
using Test

@testset "ChainedArrays.jl" begin
    v = ChainedVector([1, 2, 3], [4], [5, 6, 7, 8, 9, 10])

    @test all(v .== 1:10)
    @test collect(x for x in v) == 1:10

    @test v[7] == 7

    @test v[1:5] == 1:5

    @test (v[3] = 10; v[3] == 10)

    @test (v[4:10] .= 1:7; v[4:10] == 1:7)
end
