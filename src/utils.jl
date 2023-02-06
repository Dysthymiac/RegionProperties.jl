unzip(a) = map(x->getfield.(a, x), fieldnames(eltype(a)))

function bbox_to_view(box, img, preserve_indices=false)
    axes = Base.splat(range).(box |> unzip)
    view_box = @view img[axes...]
    if preserve_indices
        return OffsetArray(view_box, axes...)
    else
        return view_box    
    end
end