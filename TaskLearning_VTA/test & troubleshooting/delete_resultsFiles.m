
for i=1:numel(expData)
    delete(mat_file.img_beh(i));
     delete(mat_file.results.cellFluo(i));
end