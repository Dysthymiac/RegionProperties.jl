module RegionProperties

export regionprops, index_to_point, indices_to_points, get_available_properties

using Images
using CircularArrays, StaticArrays, OffsetArrays, StructArrays
using Statistics, PolygonOps

include("utils.jl")
include("RegionProps.jl")

include.(readdir(joinpath(@__DIR__, "properties/"), join=true))


end # module RegionProps
