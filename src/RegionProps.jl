struct RegionProps{T1}
    label::T1
    computed_components::Dict{Symbol, Any}

    function RegionProps(img) 
        label = label_components(img)
        new{typeof(label)}(label, Dict{Symbol, Any}())
    end
end

add_std_component!(f) = function add_component(rp, component) 
    rp.computed_components[component] = f(rp.label)[2:end]
end

names_to_functions = (
    bounding_box = add_std_component!(component_boxes),
    centroid = add_std_component!(component_centroids),
    area = add_std_component!(component_lengths),
    indices = add_std_component!(component_indices),
    subscripts = add_std_component!(component_subscripts))

macro add_named_component(name_expr, expr)
    println("Adding $name_expr")
    :(names_to_functions = (;names_to_functions..., $name_expr=$expr)) |> esc
end

function add_component!(rp::RegionProps, component)
    
    names_to_functions[component](rp, component)
    return rp[component]
end

function get_add_component!(rp::RegionProps, component)
    !haskey(rp, component) && add_component!(rp, component)
    return rp[component]
end

getproperty!(rp::RegionProps, component::Symbol) = get_add_component!(rp::RegionProps, component)

macro !(expr)
    if (expr.head === :.) || (expr.head === :ref)
        obj = esc(expr.args[1])
        comp = esc(expr.args[2])
        return :(getproperty!($obj, $comp))
    else
        return expr
    end
end

function Base.getproperty(rp::RegionProps, component::Symbol)
    component ∈ (:label, :computed_components) && return getfield(rp, component)
    rp.computed_components[component]
end
Base.setproperty!(rp::RegionProps, component::Symbol, value) = rp.computed_components[component] = value
Base.haskey(rp::RegionProps, key) = haskey(rp.computed_components, key)
Base.push!(rp::RegionProps, pair) = push!(rp.computed_components, pair)
Base.getindex(rp::RegionProps, i) = getproperty(rp, i)
Base.setindex(rp::RegionProps, v, i) = setproperty!(rp, i, v)

function regionprops(img, properties...)
    rp = RegionProps(img)
    vals = (@!(rp[property]) for property ∈ properties)
    return map((vals...)->(; Pair.(properties, vals)...), vals...)
end