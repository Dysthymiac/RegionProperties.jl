safe_sample(p, img) = checkbounds(Bool, img, p) && img[p]

function next_point(current, dirs, img, start_dir=1)
    for i ∈ start_dir:start_dir+length(dirs)-1
        next_p = current + dirs[i]
        safe_sample(next_p, img) && return (i, next_p)
    end
    return (0, current)
end

function find_perimeter_points(img)
    first = findfirst(img)
    points = [first]
    chain = Int64[]
    dirs = CircularArray(CartesianIndex.(
        [(-1, -1), (-1,  0), (-1,  1), ( 0,  1),
         ( 1,  1), ( 1,  0), ( 1, -1), ( 0, -1)]))
    dir, current = next_point(points[end], dirs, img)
    while current ≠ first
        push!(chain, dir)
        push!(points, current)
        dir, current = next_point(points[end], dirs, img, dir-3)
    end
    corner = chain .≠ CircularArray(chain)[0:end-1]
    perimeter = sum(iseven, chain, init=0)*0.980 + sum(isodd, chain, init=0)*1.406 - sum(corner, init=0)*0.091;

    return (perimeter, Tuple.(points))
end

function image_from_subscripts(subscripts, box)
    result = OffsetArray(
        falses(box[2] .- box[1] .+ 1), 
        Base.splat(range).(box |> unzip)...)
    result[CartesianIndex.(subscripts)] .= true
    return result
end

function add_component_perimeter!(rp::RegionProps, component)
    subs = @! rp.subscripts
    boxes = @! rp.bounding_box
    
    perimeters, points = unzip(find_perimeter_points.(image_from_subscripts.(subs, boxes)))
    rp.perimeter = perimeters
    rp.perimeter_points = points
    return rp[component]
end

@add_named_component perimeter add_component_perimeter!
@add_named_component perimeter_points add_component_perimeter!