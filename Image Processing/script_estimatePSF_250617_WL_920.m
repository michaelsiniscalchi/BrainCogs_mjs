clearvars;
close all;

i=1;

%Objective Alone
data_dir = "Y:\michael\_technical\250619-alignment\bead1"; 
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = -30; %Z-coordinate of bottom slice (um)
exp(i).um_per_pixel = 25/512; %99.9% zoom
exp(i).crop_margins = 80;
i=i+1;
data_dir = "Y:\michael\_technical\250619-alignment\bead2";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = -30; %Z-coordinate of bottom slice (um)
exp(i).um_per_pixel = 25/512;
exp(i).crop_margins = 80;


calc_psf = true;
fig_summaryPSF = true;
fig_summary = true;

%% Loop through all datasets
if calc_psf
    tic
    for i = 1:numel(exp)
   
        %Estimate PSF
        % img = processSlicesPSF( data_dir, crop_margins, um_per_pixel );
         [ psf, img ] =...
            estimatePSF( exp(i).dir, 512, exp(i).crop_margins, 95, exp(i).um_per_pixel);
        %Generate figure and save
        fig = plotPSF(psf, img, exp(i).sessionID);
        save_dir = fileparts(exp(i).dir); %Save in main data dir
        save_multiplePlots(fig, save_dir);
        %Save results and metadata
        expData = exp(i);
        save(fullfile(save_dir,exp(i).sessionID),'psf','img');
        save(fullfile(save_dir,exp(i).sessionID),'-struct','expData','-append');
        saveTiff(int16(img.slices), img.tags, fullfile(save_dir,join([exp(i).sessionID, '-slices.tif'],'')));
        clearvars psf img
    end
    toc;
end