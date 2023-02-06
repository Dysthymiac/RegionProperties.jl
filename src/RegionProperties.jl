module RegionProperties

export regionprops, bbox_to_view

using Images, CircularArrays, StaticArrays, OffsetArrays

include("utils.jl")
include("RegionProps.jl")

# include.(readdir(joinpath(@__DIR__, "properties/"), join=true))
include("properties/circularity.jl")
include("properties/ellipse.jl")
include("properties/perimeter.jl")

end # module RegionProps
