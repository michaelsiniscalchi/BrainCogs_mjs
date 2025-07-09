function stack = cropStack( stack, margins )

%Scalar value for symmetric margins
if isscalar(margins)
    margins = repmat(margins,1,4); %[top, bottom, left, right]
elseif numel(margins)==3 %[top, left, width_out]
    bottom = size(stack,1) - margins(1) - margins(3); %Img_height - top margin - output_height
    right = size(stack,2) - margins(2) - margins(3);
    margins = [margins(1), bottom, margins(2), right];
end

%Crop image stack to within specified margins
[nY,nX] = size(stack,[1,2]);
tblr = [1,nY,1,nX] + margins.*[1,-1,1,-1];
stack = stack(tblr(1):tblr(2),tblr(3):tblr(4),:);


