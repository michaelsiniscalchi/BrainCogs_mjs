tif_paths = 'Y:\michael\241011-m834-maze7\241011-m834-maze7_00001_00225.tif';

[stack, tags, ImageDescription] =  loadtiffseq(...
        tif_paths); % load raw stack (.tif)