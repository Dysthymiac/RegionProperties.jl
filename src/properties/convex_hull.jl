# TODO: Rewrite convex hull yourself!
function convex_hull(perimeter)
    points = CartesianIndex.(perimeter)
    function right_oriented(ref, a, b)
        return (a[2] - ref[2]) * (b[1] - ref[1]) - (b[2] - ref[2]) * (a[1] - ref[1]) < 0
    end

    function collinear(a, b, c)
        return (a[2] - c[2]) * (b[1] - c[1]) - (b[2] - c[2]) * (a[1] - c[1]) == 0
    end

    dist2(a, b) = sum(abs2, (a - b).I)
    function angularsort!(points, ref)
        last_point = ref

        for i in eachindex(points)
            if points[i] == last_point
                deleteat!(points, i)
                break
            end
        end

        sort!(points; lt=(a, b) -> right_oriented(last_point, a, b))

        i = 0
        while i <= length(points)
            i = i + 1
            if i + 1 > length(points)
                break
            end

            if collinear(last_point, points[i], points[i + 1])
                if dist2(last_point, points[i]) < dist2(last_point, points[i + 1])
                    deleteat!(points, i)
                else
                    deleteat!(points, i + 1)
                end
                i = i - 1
            end
        end
    end
    last_point = points[1]
    for point in points
        if point[2] > last_point[2] || (point[2] == last_point[2] && point[1] > last_point[1])
            last_point = point
        end
    end
    angularsort!(points, last_point)
    
    convex_hull = CartesianIndex{2}[]
    if length(points) < 3
        return Tuple.(convex_hull)
    end
    push!(convex_hull, last_point)
    push!(convex_hull, points[1])
    push!(convex_hull, points[2])
    n_points = length(points)
    for i in 3:n_points
        while (
            right_oriented(convex_hull[end], convex_hull[end - 1], points[i]) ||
            collinear(convex_hull[end], convex_hull[end - 1], points[i])
        )
            pop!(convex_hull)
            if length(convex_hull) == 1
                return Tuple.(convex_hull)
            end
        end
        push!(convex_hull, points[i])
    end

    return Tuple.(convex_hull)
end

function add_component_convex_hull!(rp::RegionProps, component)
    perimeter_points = @! rp.perimeter_points
    
    rp.convex_hull = convex_hull.(perimeter_points)
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
