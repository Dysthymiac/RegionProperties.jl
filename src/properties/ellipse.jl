function add_component_ellipse!(rp::RegionProps, component)
    all_points = (reduce(hcat, SVector.(points)) for points ∈ @!(rp.subscripts))
    centroids = SVector.(@! rp.centroid)

    major = zeros(length(points))
    minor = zeros(length(points))
    orientations = zeros(length(points))

    for (i, (centroid, points)) ∈ enumerate(zip(centroids, all_points))
        x = points[2, :] .- centroid[2]
        y = -(points[1, :] .- centroid[1])

        uxx = mean(x.^2) + 1/12
        uyy = mean(y.^2) + 1/12
        uxy = mean(x.*y)
        common = √((uxx .- uyy).^2 .+ 4 .* uxy.^2)
        major[i] = 2√2 * √(uxx + uyy + common)
        minor[i] = 2√2 * √(uxx + uyy - common)
        if uyy > uxx
            num = uyy - uxx + √((uyy - uxx)^2 + 4*uxy^2)
            den = 2*uxy
        else
            num = 2*uxy
            den = uxx - uyy + √((uxx - uyy)^2 + 4*uxy^2)
        end
        orientations[i] = atan(num, den)

    end

    rp.minor_axis_length = minor
    rp.major_axis_length = major
    rp.orientation = orientations
    return rp[component]
end

@add_named_component minor_axis_length add_component_ellipse!
@add_named_component major_axis_length add_component_ellipse!
@add_named_component orientation add_component_ellipse!

function add_component_eccentricity!(rp::RegionProps, component)
    major = @! rp.major_axis_length
    minor = @! rp.minor_axis_length
    rp.eccentricity = 2 .* .√((major./2).^2 - (minor./2).^2)./major
    return rp[component]
end

@add_named_component eccentricity add_component_eccentricity!

