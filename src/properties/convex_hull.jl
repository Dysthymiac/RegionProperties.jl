# TODO: Fix this! 
function safe_convexhull(img) 
    function getboundarypoints(img)
        points = CartesianIndex{2}[]
        for j in axes(img, 2)
            v = Base.view(img, :, j)
            i1 = findfirst(v)
            if !isnothing(i1)
                i2 = findlast(v)
                push!(points, CartesianIndex(i1, j))
                if i1 != i2
                    push!(points, CartesianIndex(i2, j))
                end
            end
        end
        return points
    end
    points = getboundarypoints(img)
    if length(points) > 3
        return Tuple.(convexhull(img))
    else
        return []
    end
end


function add_component_convex_hull!(rp::RegionProps, component)
    boxes = @! rp.bounding_box
    
    views = [bbox_to_view(box, rp.label, true) .|> >(0) for box ∈ boxes]

    rp.convex_hull = safe_convexhull.(views)
    return rp[component]
end

@add_named_component convex_hull add_component_convex_hull!

function create_convex_image(box, chull, subscripts)
    result = OffsetArray(
        falses(box[2] .- box[1] .+ 1), 
        Base.splat(range).(box |> unzip)...)
    isempty(chull) && return result
    points = filter(p->inpolygon(p, vcat(chull, chull[1:1]))≠0, subscripts) .|> CartesianIndex
    result[points] .= true
    return result
end

function add_component_convex_image!(rp::RegionProps, component)
    boxes = @! rp.bounding_box
    convex_hulls = @! rp.convex_hull
    subscripts = @! rp.subscripts
    
    return rp.convex_image = create_convex_image.(boxes, convex_hulls, subscripts)
end

@add_named_component convex_image add_component_convex_image!

function add_component_convex_area!(rp::RegionProps, component)
    return rp.convex_area = sum.(@!(rp.convex_image))
end

@add_named_component convex_area add_component_convex_area!

function add_component_solidity!(rp::RegionProps, component)
    return rp.solidity = @!(rp.area)./@!(rp.convex_area)
end

@add_named_component solidity add_component_solidity!
