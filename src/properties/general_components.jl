function add_component_image!(rp::RegionProps, component)
    return rp.image = [bbox_to_view(box, rp.label, true) .|> >(0) for box ∈ @!(rp.bounding_box)]
end

@add_named_component image add_component_image!

function add_component_extent!(rp::RegionProps, component)
    box_area(box) = prod(box[2] .- box[1] .+ 1)
    return rp.extent = box_area.(@! rp.bounding_box) ./ @!(rp.area)
end

@add_named_component extent add_component_extent!

function create_extrema_vector(points)
    min_y, max_y = extrema(points[1, :])
    min_x, max_x = extrema(points[2, :])
    
    top_points = findall(points[1, :] .== min_y)
    bot_points = findall(points[1, :] .== max_y)
    
    left_points = findall(points[2, :] .== min_x)
    right_points = findall(points[2, :] .== max_x)
    
    find_filter(points, dim, filter, f) = points[:, filter[f(points[dim, filter])[2]]]
    top_left = find_filter(points, 2, top_points, findmin)
    top_right = find_filter(points, 2, top_points, findmax)
    right_top = find_filter(points, 1, right_points, findmin)
    right_bot = find_filter(points, 1, right_points, findmax)
    bot_right = find_filter(points, 2, bot_points, findmax)
    bot_left = find_filter(points, 2, bot_points, findmin)
    left_bot = find_filter(points, 1, left_points, findmax)
    left_top = find_filter(points, 1, left_points, findmin)
    return hcat(top_left, top_right, right_top, right_bot, bot_right, bot_left, left_bot, left_top)
end

function add_component_extrema!(rp::RegionProps, component)

    points = indices_to_points.(@! rp.subscripts)

    return rp.extrema = create_extrema_vector.(points)
end

@add_named_component extrema add_component_extrema!
