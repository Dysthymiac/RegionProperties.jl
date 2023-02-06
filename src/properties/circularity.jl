function add_component_circularity!(rp::RegionProps, _)
    perimeter = @! rp.perimeter
    area = @! rp.area
    return rp.circularity = (4π .* area)./(perimeter.^2)
end
@add_named_component circularity add_component_circularity!

function add_component_equiv_diameter!(rp::RegionProps, _)
    area = @! rp.area
    return rp.equiv_diameter = .√(4 .* area ./ π)
end
@add_named_component equiv_diameter add_component_equiv_diameter!

