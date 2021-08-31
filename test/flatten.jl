@testset "flatten" begin
    @testset "Reals" begin
        test_flatten_interface(1.0)

        @testset "Integers" begin
            test_flatten_interface(1)
            @test isempty(first(flatten(1)))
        end
    end

    @testset "AbstractArrays" begin
        test_flatten_interface(randn(10))
        test_flatten_interface(randn(5, 4))
        test_flatten_interface([randn(5) for _ in 1:3])

        # Prevent regression of https://github.com/invenia/ParameterHandling.jl/issues/31
        @testset for v in [[1, 2, 3], sparse([1, 0, 3])]
            test_flatten_interface(v)
            @test length(first(flatten(v))) == 0
        end
    end

    @testset "SparseMatrixCSC" begin
        test_flatten_interface(sprand(10, 10, 0.5))
    end

    @testset "Tuple" begin
        test_flatten_interface((1.0, 2.0); check_inferred=tuple_infers)

        test_flatten_interface((1.0, (2.0, 3.0), randn(5)); check_inferred=tuple_infers)
    end

    @testset "NamedTuple" begin
        test_flatten_interface(
            (a=1.0, b=(2.0, 3.0), c=(e=5.0,)); check_inferred=tuple_infers
        )
    end

    @testset "Dict" begin
        test_flatten_interface(Dict(:a => 4.0, :b => 5.0); check_inferred=false)
    end
end

@testset "flatten_only" begin
    @testset "Reals" begin
        x = Tagged{:a}(1.0)
        test_flatten_only_interface(x, Val(:a))
        @test !isempty(first(flatten_only(x, Val(:a))))
        @test isempty(first(flatten_only(x, Val(:b))))
    end

    @testset "AbstractArrays" begin
        test_flatten_only_interface(Tagged{:a}(randn(10)), Val(:a))
        test_flatten_only_interface(Tagged{:a}(randn(5, 4)), Val(:a))
        test_flatten_only_interface(Tagged{:a}([randn(5) for _ in 1:3]), Val(:a))
    end

    @testset "SparseMatrixCSC" begin
        test_flatten_only_interface(Tagged{:a}(sprand(10, 10, 0.5)), Val(:a))
    end

    @testset "Tuple" begin
        test_flatten_only_interface(Tagged{:a}((1.0, 2.0)), Val(:a); check_inferred=tuple_infers)

        test_flatten_only_interface(
            Tagged{:a}((1.0, (2.0, 3.0), randn(5))), Val(:a); check_inferred=tuple_infers,
        )
    end

    @testset "NamedTuple" begin
        test_flatten_only_interface(
            (a=Tagged{:a}(1.0), b=(2.0, 3.0), c=(e=Tagged{:a}(5.0),)), Val(:a); check_inferred=tuple_infers,
        )
    end

    @testset "Dict" begin
        test_flatten_only_interface(Dict(:a => Tagged{:a}(4.0), :b => 5.0), Val(:a); check_inferred=false)
    end

    @testset "Multiple Tags" begin
        x = (a=Tagged{:a}(1.0), b=(2.0, Tagged{:b}(3.0)), c=(e=Tagged{(:a, :b)}(5.0),))
        @test first(flatten_only(x, :a)) == [1.0, 5.0]
        @test first(flatten_only(x, :b)) == [3.0, 5.0]
        @test isempty(first(flatten_only(x, :c)))
    end
end
