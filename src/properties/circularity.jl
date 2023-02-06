function add_component_circularity!(rp::RegionProps, _)
    perimeter = @! rp.perimeter
    area = @! rp.area
    return rp.circularity = (4π .* area)./(perimeter.^2)
end
@add_named_component circularity add_component_circularity!

