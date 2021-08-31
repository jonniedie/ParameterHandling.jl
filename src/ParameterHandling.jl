module ParameterHandling

using Bijectors
using Compat: only
using ChainRulesCore
using LinearAlgebra
using SparseArrays

export Tagged, flatten, flatten_only, positive, bounded, fixed, deferred, orthogonal, positive_definite

include("flatten.jl")
include("parameters.jl")

include("test_utils.jl")

end # module
