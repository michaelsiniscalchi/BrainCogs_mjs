%%%screenROIs_batch.m
%
%PURPOSE: Creates a figure for each ROI from a longitudinal imaging experiment.
%               Displays image of local mean projection and plots F(t).
%AUTHOR: MJ Siniscalchi 190219
%
%--------------------------------------------------------------------------

clearvars;

%Params
data_dir = 'X:\michael\network-batch\rois\';
subject_ID = {'m173'}; %User enters subject name, or other string to use as filter for dirs to search
segWidth = 80; %width of viewing box in pixels

for j = 1:numel(subject_ID)
    %Search for ROI directories
    temp = dir(fullfile(data_dir,['*' subject_ID{j} '*']));
    for i = 1:numel(temp)
        dirs.sessions{i,:} = fullfile(data_dir,temp(i).name);
    end

    % MAT file to save all ROIs from a given subject
    master_file = fullfile(data_dir,['master_rois_' subject_ID{j} '.mat']); %Master ROI file
    
    %Find existing ROI directories
    for i = 1:numel(dirs.sessions)
        temp = dir(fullfile(dirs.sessions{i},'ROI*.tif'));
        temp = temp(temp.isdir); %Get only the directories
        if ~isempty(temp)
            dirs.roi(i,:) = string(fullfile(dirs.sessions{i},temp.name));
        end
    end
    dirs.roi = dirs.roi(~ismissing(dirs.roi)); %Filter sessions with ROIs

    %Get mean projection from each imaging session
    for i = 1:numel(dirs.roi)
        S = load(fullfile(dirs.roi{i},'roiData.mat'),'mean_proj','filename');
        mean_proj{i}= S.mean_proj;
        fname_stack{i,:} = S.filename;
    end

    %% Get frame segment and boundaries surrounding each ROI from each session

    %Get ROI data from all sessions
    S = getMasterROIs(dirs.roi,master_file); %Saves as 'master_rois_('subject_ID{j}').mat'
    [nX,nY,~] = size(mean_proj{1});

    for i = 1:numel(S.cell_ID)
        frameSegment(i).cell_ID = S.cell_ID{i};
        %Label with imaging date
        [startIdx,endIdx] = regexp(S.fname_stack{i},'\d{6}');
        frameSegment(i).date = S.fname_stack{i}(startIdx:endIdx);

        [Y,X] = find(S.bw{i});
        %Get X and Y boundaries of pixel region
        x = round(mean(X) + [-(segWidth-1)/2, (segWidth-1)/2]);
        y = round(mean(Y) + [-(segWidth-1)/2, (segWidth-1)/2]);
        %Set values outside frame to nearest pixel
        x = max([x;1,1]); x = min([x;nX,nX]);
        y = max([y;1,1]); y = min([y;nY,nY]);
        %Get frame segment and ROI boundaries
        proj = mean_proj{strcmp(fname_stack,S.fname_stack{i})};
        frameSegment(i).pix = proj(y(1):y(2),x(1):x(2));
        frameSegment(i).centroid = [mean(X) mean(Y)]; %Centroid of ROI in xy
        cellMask = S.bw{i}(y(1):y(2),x(1):x(2)); %Mask within segment
        %Pad segments overlapping limit of FOV with zeros
        if any(size(frameSegment(i).pix) < segWidth)
            pix = frameSegment(i).pix;
            [m,n] = size(pix);
            padX = [0, segWidth - n]; %Syntax for padarray(): (d1, d2)
            padY = [segWidth - m, 0];
            if x(2)==nX %Right edge
                pix = padarray(pix,padX,0,'post');
                cellMask = padarray(cellMask,padX,0,'post');
            elseif x(1)==1 %Left edge
                pix = padarray(pix,padX,0,'pre');
                cellMask = padarray(cellMask,padX,0,'pre');
            end
            if y(2)==nY %Bottom
                pix = padarray(pix,padY,0,'post');
                cellMask = padarray(cellMask,padY,0,'post');
            elseif y(1)==1 %Top
                pix = padarray(pix,padY,0,'pre');
                cellMask = padarray(cellMask,padY,0,'pre');
            end
            frameSegment(i).pix = pix;
        end
        bounds = bwboundaries(cellMask); %Boundaries of logical mask for current ROI
        frameSegment(i).roi = [bounds{1}(:,2) bounds{1}(:,1)]; %Boundary coordinates in xy
    end
    save(master_file,'frameSegment','-append');

    %% Create figure for each series of frame segments
    save_dir = fullfile(data_dir,['master_rois_' subject_ID{j}]);
    mkdir(save_dir);
    for i = 1:numel(frameSegment)
        f = figure('Visible','on','NumberTitle','off');

        %Subplot for each session
        nRows = 10; %For grid of subplots
        p = subplot(2,1,1);
        imagesc(frameSegment(i).pix); hold on
        plot(frameSegment(i).roi(:,1),frameSegment(i).roi(:,2),'r');
        p.YTickLabel = []; p.XTickLabel = [];
        p.Title.String = [frameSegment(i).date,' ','Cell ',frameSegment(i).cell_ID];
        axis square;

        q = subplot(2,1,2);
        plot(S.cellf{i}); hold on;
        q.YTickLabel = []; q.XTickLabel = [];

        f.Name = [frameSegment(i).date ' cell_' frameSegment(i).cell_ID];
        save_name = fullfile(save_dir,f.Name);
        savefig(f,save_name);
        saveas(f,save_name,'tif')
        close(f);
    end
    clearvars -except data_dir subject_ID segWidth j
end