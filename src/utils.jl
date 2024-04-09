unzip(a) = map(x->getfield.(a, x), fieldnames(eltype(a)))

function bbox_to_view(box, img, preserve_indices=false)
    view_box = @view img[box]
    if preserve_indices
        return OffsetArray(view_box, box)
    else
        return view_box    
    end
end

index_to_point(idx) = idx |> Tuple |> SVector

indices_to_points(idx) = reduce(hcat, index_to_point.(idx))