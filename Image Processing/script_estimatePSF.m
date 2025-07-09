clearvars;
close all;

i=1;

%Objective with GRIn lens
data_dir = "Y:\michael\_technical\230131-zeiss-2P-GRIn-beads\bead1-920";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = -2205 - (-2295); %Z-coordinate of displacement for 920 channel (um)
exp(i).um_per_pixel = 53/512;
exp(i).crop_margins = 80;
i=i+1;
data_dir = "Y:\michael\_technical\230131-zeiss-2P-GRIn-beads\bead1-920-2";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = -2205 - (-2295); %Z-coordinate of displacement for 920 channel (um)
exp(i).um_per_pixel = 53/512;
exp(i).crop_margins = 80;
i=i+1;
data_dir = "Y:\michael\_technical\230131-zeiss-2P-GRIn-beads\bead1-1064";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = -2205 - (-2295); %Z-coordinate of displacement for 920 channel (um)
exp(i).um_per_pixel = 53/512;
exp(i).crop_margins = 80;
i=i+1;

data_dir = "Y:\michael\_technical\230201-zeiss-2P-GRIn-beads\bead2-920";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = -1961 - (-2220); %Z-coordinate of displacement for 920 channel (um)
exp(i).um_per_pixel = 52/512;
exp(i).crop_margins = 80;
i=i+1;
data_dir = "Y:\michael\_technical\230201-zeiss-2P-GRIn-beads\bead2-1064";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = -1961 - (-2220); %Z-coordinate of displacement for 920 channel (um)
exp(i).um_per_pixel = 52/512;
exp(i).crop_margins = 80;
i=i+1;
data_dir = "Y:\michael\_technical\230201-zeiss-2P-GRIn-beads\bead3-920";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = -2020 - (-2220); %Z-coordinate of displacement for 920 channel (um)
exp(i).um_per_pixel = 53/512;
exp(i).crop_margins = 80;
i=i+1;
data_dir = "Y:\michael\_technical\230201-zeiss-2P-GRIn-beads\bead3-1064";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = -2020 - (-2220); %Z-coordinate of displacement for 920 channel (um)
exp(i).um_per_pixel = 53/512;
exp(i).crop_margins = 80;
i=i+1;

%Exclude--something was wrong--look at projections...
% data_dir = "Y:\michael\_technical\230201-leica-2P-GRIn-beads\bead1-920";
% dir_str = split(data_dir,filesep)';
% exp(i).dir = fullfile(dir_str{:});
% exp(i).sessionID = join(dir_str(end-1:end),'-');
% exp(i).depth = -2990 - (-3200); %Z-coordinate of displacement for 920 channel (um)
% exp(i).um_per_pixel = 62/512;
% exp(i).crop_margins = 80;
% i=i+1;
% data_dir = "Y:\michael\_technical\230201-leica-2P-GRIn-beads\bead1-1064";
% dir_str = split(data_dir,filesep)';
% exp(i).dir = fullfile(dir_str{:});
% exp(i).sessionID = join(dir_str(end-1:end),'-');
% exp(i).depth = -2990 - (-3200); %Z-coordinate of displacement for 920 channel (um)
% exp(i).um_per_pixel = 62/512;
% exp(i).crop_margins = 80;
% i=i+1;
% data_dir = "Y:\michael\_technical\230201-leica-2P-GRIn-beads\bead2-920";
% dir_str = split(data_dir,filesep)';
% exp(i).dir = fullfile(dir_str{:});
% exp(i).sessionID = join(dir_str(end-1:end),'-');
% exp(i).depth = -2760 - (-3200); %Z-coordinate of displacement for 920 channel (um)
% exp(i).um_per_pixel = 62/512;
% exp(i).crop_margins = 80;
% i=i+1;
% data_dir = "Y:\michael\_technical\230201-leica-2P-GRIn-beads\bead2-1064";
% dir_str = split(data_dir,filesep)';
% exp(i).dir = fullfile(dir_str{:});
% exp(i).sessionID = join(dir_str(end-1:end),'-');
% exp(i).depth = -2760 - (-3200); %Z-coordinate of displacement for 920 channel (um)
% exp(i).um_per_pixel = 62/512;
% exp(i).crop_margins = 80;
% i=i+1;
% data_dir = "Y:\michael\_technical\230201-leica-2P-GRIn-beads\bead2-1064-2";
% dir_str = split(data_dir,filesep)';
% exp(i).dir = fullfile(dir_str{:});
% exp(i).sessionID = join(dir_str(end-1:end),'-');
% exp(i).depth = -2760 - (-3200); %Z-coordinate of displacement for 920 channel (um)
% exp(i).um_per_pixel = 62/512;
% exp(i).crop_margins = 80;
% i=i+1;
% data_dir = "Y:\michael\_technical\230201-leica-2P-GRIn-beads\bead3-920";
% dir_str = split(data_dir,filesep)';
% exp(i).dir = fullfile(dir_str{:});
% exp(i).sessionID = join(dir_str(end-1:end),'-');
% exp(i).depth = -2870 - (-3200); %Z-coordinate of displacement for 920 channel (um)
% exp(i).um_per_pixel = 62/512;
% exp(i).crop_margins = 80;
% i=i+1;
% data_dir = "Y:\michael\_technical\230201-leica-2P-GRIn-beads\bead3-920-2";
% dir_str = split(data_dir,filesep)';
% exp(i).dir = fullfile(dir_str{:});
% exp(i).sessionID = join(dir_str(end-1:end),'-');
% exp(i).depth = -2870 - (-3200); %Z-coordinate of displacement for 920 channel (um)
% exp(i).um_per_pixel = 62/512;
% exp(i).crop_margins = 80;
% i=i+1;
% data_dir = "Y:\michael\_technical\230201-leica-2P-GRIn-beads\bead3-920-3";
% dir_str = split(data_dir,filesep)';
% exp(i).dir = fullfile(dir_str{:});
% exp(i).sessionID = join(dir_str(end-1:end),'-');
% exp(i).depth = -2870 - (-3200); %Z-coordinate of displacement for 920 channel (um)
% exp(i).um_per_pixel = 62/512;
% exp(i).crop_margins = 80;
% i=i+1;
% data_dir = "Y:\michael\_technical\230201-leica-2P-GRIn-beads\bead3-1064";
% dir_str = split(data_dir,filesep)';
% exp(i).dir = fullfile(dir_str{:});
% exp(i).sessionID = join(dir_str(end-1:end),'-');
% exp(i).depth = -2870 - (-3200); %Z-coordinate of displacement for 920 channel (um)
% exp(i).um_per_pixel = 62/512;
% exp(i).crop_margins = 80;
% i=i+1;

data_dir = "Y:\michael\_technical\230202-leica-2P-GRIn-beads\bead1-920";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = -2980 - (-3200); %Z-coordinate of displacement for 920 channel (um)
exp(i).um_per_pixel = 62/256;
exp(i).crop_margins = 40;
i=i+1;
data_dir = "Y:\michael\_technical\230202-leica-2P-GRIn-beads\bead1-920-2";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = -2980 - (-3200); %Z-coordinate of displacement for 920 channel (um)
exp(i).um_per_pixel = 62/256;
exp(i).crop_margins = 40;
i=i+1;
data_dir = "Y:\michael\_technical\230202-leica-2P-GRIn-beads\bead1-1064";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = -2980 - (-3200); %Z-coordinate of displacement for 920 channel (um)
exp(i).um_per_pixel = 62/256;
exp(i).crop_margins = 40;
i=i+1;
data_dir = "Y:\michael\_technical\230202-leica-2P-GRIn-beads\bead2-920";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = -2895 - (-3200); %Z-coordinate of displacement for 1064 channel (um)
exp(i).um_per_pixel = 64/256;
exp(i).crop_margins = 40;
i=i+1;
data_dir = "Y:\michael\_technical\230202-leica-2P-GRIn-beads\bead2-1064";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = -2895 - (-3200); %Z-coordinate of displacement for 1064 channel (um)
exp(i).um_per_pixel = 64/256;
exp(i).crop_margins = 40;
i=i+1;
data_dir = "Y:\michael\_technical\230202-leica-2P-GRIn-beads\bead2-1064-2";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = -2895 - (-3200); %Z-coordinate of displacement for 1064 channel (um)
exp(i).um_per_pixel = 64/256;
exp(i).crop_margins = 40;
i=i+1;

data_dir = "Y:\michael\_technical\230202-olympus-2P-GRIn-beads\bead1-920";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = -1962 - (-2100); %Z-coordinate of displacement for 920 channel (um)
exp(i).um_per_pixel = 55/256;
exp(i).crop_margins = 40;
i=i+1;
data_dir = "Y:\michael\_technical\230202-olympus-2P-GRIn-beads\bead1-920-2";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = -1962 - (-2100); %Z-coordinate of displacement for 920 channel (um)
exp(i).um_per_pixel = 55/256;
exp(i).crop_margins = 40;
i=i+1;
data_dir = "Y:\michael\_technical\230202-olympus-2P-GRIn-beads\bead1-1064";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = -1962 - (-2100); %Z-coordinate of displacement for 920 channel (um)
exp(i).um_per_pixel = 55/256;
exp(i).crop_margins = 40;
i=i+1;
data_dir = "Y:\michael\_technical\230202-olympus-2P-GRIn-beads\bead2-920";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = -1800 - (-2100); %Z-coordinate of displacement for 1064 channel (um)
exp(i).um_per_pixel = 56/256;
exp(i).crop_margins = 40;
i=i+1;
data_dir = "Y:\michael\_technical\230202-olympus-2P-GRIn-beads\bead2-1064";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = -1800 - (-2100); %Z-coordinate of displacement for 1064 channel (um)
exp(i).um_per_pixel = 56/256;
exp(i).crop_margins = 40;
i=i+1;
data_dir = "Y:\michael\_technical\230202-olympus-2P-GRIn-beads\bead2-1064-2";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = -1800 - (-2100); %Z-coordinate of displacement for 1064 channel (um)
exp(i).um_per_pixel = 56/256;
exp(i).crop_margins = 40;
i=i+1;

%Objective Alone
data_dir = "Y:\michael\_technical\230131-zeiss-nogrinlens\bead1-920";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = NaN; %Z-coordinate of bottom slice (um)
exp(i).um_per_pixel = 51/512;
exp(i).crop_margins = 80;
i=i+1;
data_dir = "Y:\michael\_technical\230131-zeiss-nogrinlens\bead1-1064";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = NaN; %Z-coordinate of bottom slice (um)
exp(i).um_per_pixel = 51/512;
exp(i).crop_margins = 80;
i=i+1;
data_dir = "Y:\michael\_technical\230131-zeiss-nogrinlens\bead2-920";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = NaN; %Z-coordinate of bottom slice (um)
exp(i).um_per_pixel = 51/512;
exp(i).crop_margins = 80;
i=i+1;
data_dir = "Y:\michael\_technical\230131-zeiss-nogrinlens\bead2-1064";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = NaN; %Z-coordinate of bottom slice (um)
exp(i).um_per_pixel = 51/512;
exp(i).crop_margins = 80;
i=i+1;

data_dir = "Y:\michael\_technical\230207-zeiss-nogrinlens\bead1-920";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = NaN; %Z-coordinate of bottom slice (um)
exp(i).um_per_pixel = 51/256;
exp(i).crop_margins = 40;
i=i+1;
data_dir = "Y:\michael\_technical\230207-zeiss-nogrinlens\bead1-1064";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = NaN; %Z-coordinate of bottom slice (um)
exp(i).um_per_pixel = 51/256;
exp(i).crop_margins = 40;
i=i+1;
data_dir = "Y:\michael\_technical\230207-zeiss-nogrinlens\bead1-920-2";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = NaN; %Z-coordinate of bottom slice (um)
exp(i).um_per_pixel = 51/256;
exp(i).crop_margins = 40;
i=i+1;
data_dir = "Y:\michael\_technical\230207-zeiss-nogrinlens\bead2-1064";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = NaN; %Z-coordinate of bottom slice (um)
exp(i).um_per_pixel = 51/256;
exp(i).crop_margins = 40;
i=i+1;
data_dir = "Y:\michael\_technical\230207-zeiss-nogrinlens\bead2-920";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = NaN; %Z-coordinate of bottom slice (um)
exp(i).um_per_pixel = 51/256;
exp(i).crop_margins = 40;
i=i+1;
data_dir = "Y:\michael\_technical\230207-zeiss-nogrinlens\bead2-1064-2";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = NaN; %Z-coordinate of bottom slice (um)
exp(i).um_per_pixel = 51/256;
exp(i).crop_margins = 40;
i=i+1;
data_dir = "Y:\michael\_technical\230207-zeiss-nogrinlens\bead3-920";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = NaN; %Z-coordinate of bottom slice (um)
exp(i).um_per_pixel = 51/256;
exp(i).crop_margins = 40;
i=i+1;
data_dir = "Y:\michael\_technical\230207-zeiss-nogrinlens\bead3-1064";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = NaN; %Z-coordinate of bottom slice (um)
exp(i).um_per_pixel = 51/256;
exp(i).crop_margins = 40;
i=i+1;
data_dir = "Y:\michael\_technical\230207-zeiss-nogrinlens\bead3-920-2";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = NaN; %Z-coordinate of bottom slice (um)
exp(i).um_per_pixel = 51/256;
exp(i).crop_margins = 40;
i=i+1;

% data_dir = "Y:\michael\_technical\230203-leica-nogrinlens\bead1-920"; %Excl. for calculating offsets
% dir_str = split(data_dir,filesep)';
% exp(i).dir = fullfile(dir_str{:});
% exp(i).sessionID = join(dir_str(end-1:end),'-');
% exp(i).depth = NaN; %Z-coordinate of bottom slice (um)
% exp(i).um_per_pixel = 62/256;
% exp(i).crop_margins = 40;
% i=i+1;
data_dir = "Y:\michael\_technical\230203-leica-nogrinlens\bead2-920";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = NaN; %Z-coordinate of bottom slice (um)
exp(i).um_per_pixel = 62/256;
exp(i).crop_margins = 40;
i=i+1;
data_dir = "Y:\michael\_technical\230203-leica-nogrinlens\bead2-1064";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = NaN; %Z-coordinate of bottom slice (um)
exp(i).um_per_pixel = 62/256;
exp(i).crop_margins = 40;
i=i+1;
data_dir = "Y:\michael\_technical\230203-leica-nogrinlens\bead3-920";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = NaN; %Z-coordinate of bottom slice (um)
exp(i).um_per_pixel = 62/256;
exp(i).crop_margins = 40;
i=i+1;
data_dir = "Y:\michael\_technical\230203-leica-nogrinlens\bead3-1064";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = NaN; %Z-coordinate of bottom slice (um)
exp(i).um_per_pixel = 62/256;
exp(i).crop_margins = 40;
i=i+1;

data_dir = "Y:\michael\_technical\230206-olympus-nogrinlens\bead1-920";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = NaN; %Z-coordinate of bottom slice (um)
exp(i).um_per_pixel = 55.5/256;
exp(i).crop_margins = 40;
i=i+1;
data_dir = "Y:\michael\_technical\230206-olympus-nogrinlens\bead1-1064";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = NaN; %Z-coordinate of bottom slice (um)
exp(i).um_per_pixel = 55.5/256;
exp(i).crop_margins = 40;
i=i+1;
data_dir = "Y:\michael\_technical\230206-olympus-nogrinlens\bead1-920-2"; % *Exclude from offset analysis--controller error prior to imaging seems to have shifted the z-coordinate
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = NaN; %Z-coordinate of bottom slice (um)
exp(i).um_per_pixel = 55.5/256;
exp(i).crop_margins = 40;
i=i+1;
data_dir = "Y:\michael\_technical\230206-olympus-nogrinlens\bead2-1064";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = NaN; %Z-coordinate of bottom slice (um)
exp(i).um_per_pixel = 55.5/256;
exp(i).crop_margins = 40;
i=i+1;
data_dir = "Y:\michael\_technical\230206-olympus-nogrinlens\bead2-920";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = NaN; %Z-coordinate of bottom slice (um)
exp(i).um_per_pixel = 55.5/256;
exp(i).crop_margins = 40;
i=i+1;
data_dir = "Y:\michael\_technical\230206-olympus-nogrinlens\bead2-1064-2";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = NaN; %Z-coordinate of bottom slice (um)
exp(i).um_per_pixel = 55.5/256;
exp(i).crop_margins = 40;
i=i+1;
data_dir = "Y:\michael\_technical\230206-olympus-nogrinlens\bead3-920";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = NaN; %Z-coordinate of bottom slice (um)
exp(i).um_per_pixel = 55.5/256;
exp(i).crop_margins = 40;
i=i+1;
data_dir = "Y:\michael\_technical\230206-olympus-nogrinlens\bead3-1064";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = NaN; %Z-coordinate of bottom slice (um)
exp(i).um_per_pixel = 55.5/256;
exp(i).crop_margins = 40;
i=i+1;
data_dir = "Y:\michael\_technical\230206-olympus-nogrinlens\bead3-920-2";
dir_str = split(data_dir,filesep)';
exp(i).dir = fullfile(dir_str{:});
exp(i).sessionID = join(dir_str(end-1:end),'-');
exp(i).depth = NaN; %Z-coordinate of bottom slice (um)
exp(i).um_per_pixel = 55.5/256;
exp(i).crop_margins = 40;
i=i+1;

calc_psf = true;
fig_summaryPSF = false;
fig_summary = true;

%% Loop through all datasets
if calc_psf
    tic
    for i = 1:numel(exp)
        %Estimate PSF
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

%% Summary
sessionID = @(key) contains(cellfun(@char,{exp(:).sessionID},'UniformOutput',false), key);
idx.beam1 = sessionID("920");
idx.beam2 = sessionID("1064");
fields = ["bead1","bead2","bead3","nogrinlens","zeiss","leica","olympus"];
for i=1:numel(fields)
    idx.(fields(i)) = sessionID(fields(i));
end
clear sessionID

i=1;
summary(i).title = 'zeiss-grintech-2p-lens-920nm';
summary(i).idx = idx.beam1 & ~idx.nogrinlens & idx.zeiss; i=i+1;
summary(i).title = 'zeiss-grintech-2p-lens-1064nm';
summary(i).idx = idx.beam2 & ~idx.nogrinlens & idx.zeiss; i=i+1;
summary(i).title = 'leica-grintech-2p-lens-920nm';
summary(i).idx = idx.beam1 & ~idx.nogrinlens & idx.leica; i=i+1;
summary(i).title = 'leica-grintech-2p-lens-1064nm';
summary(i).idx = idx.beam2 & ~idx.nogrinlens & idx.leica; i=i+1;
summary(i).title = 'olympus-grintech-2p-lens-920nm';
summary(i).idx = idx.beam1 & ~idx.nogrinlens & idx.olympus; i=i+1;
summary(i).title = 'olympus-grintech-2p-lens-1064nm';
summary(i).idx = idx.beam2 & ~idx.nogrinlens & idx.olympus; i=i+1;

summary(i).title = 'zeiss-nogrinlens-920nm';
summary(i).idx = idx.beam1 & idx.nogrinlens & idx.zeiss; i=i+1;
summary(i).title = 'zeiss-nogrinlens-1064nm';
summary(i).idx = idx.beam2 & idx.nogrinlens & idx.zeiss; i=i+1;
summary(i).title = 'leica-nogrinlens-920nm';
summary(i).idx = idx.beam1 & idx.nogrinlens & idx.leica; i=i+1;
summary(i).title = 'leica-nogrinlens-1064nm';
summary(i).idx = idx.beam2 & idx.nogrinlens & idx.leica; i=i+1;
summary(i).title = 'olympus-nogrinlens-920nm';
summary(i).idx = idx.beam1 & idx.nogrinlens & idx.olympus; i=i+1;
summary(i).title = 'olympus-nogrinlens-1064nm';
summary(i).idx = idx.beam2 & idx.nogrinlens & idx.olympus; i=i+1;

if fig_summaryPSF
    for i = 1:numel(summary)
        idx = find(summary(i).idx);
        for j = 1:numel(idx)
            data_dir = fileparts(exp(idx(j)).dir);
            data = load(fullfile(data_dir,exp(idx(j)).sessionID),'psf','depth'); %
            data.psf.depth = data.depth;
            psf(j) = data.psf;
        end
        fig(i) = plotSummaryPSF( psf, summary(i).title );
        clearvars psf
    end
    save_multiplePlots(fig,fullfile(fileparts(data_dir)));
end

%Figure: Summary of PSF and Offsets
%   Six swarms each for 920-nm, 1064-nm, Offsets
titles = ["PSF-920-nm","PSF-1064-nm","PSF-Z-Offsets"];
if fig_summary
    for i = 1:numel(summary)
        idx = find(summary(i).idx);
        for j = 1:numel(idx)
            data_dir = fileparts(exp(idx(j)).dir);
            data(j) = load(fullfile(data_dir,exp(idx(j)).sessionID),'psf','sessionID');
        end
        %Find replicates from same bead and average
        fields = ["x","y","z"];
        fwhm(i) = struct("x",NaN(numel(idx),1),"y",NaN(numel(idx),1),"z",NaN(numel(idx),1));
        loc{i} = NaN(numel(idx),1);
        for j = 1:numel([data.sessionID]')
            sessionID_str = split(data(j).sessionID,'-');
            if any([data.sessionID]==join([sessionID_str',"2"],'-')) %Has duplicates
                repIdx=[find([data.sessionID]==join([sessionID_str',"2"],'-')),j];
                for k = 1:numel(fields)
                    fwhm(i).(fields(k))(j) = ...
                        mean([data(repIdx(1)).psf.(fields(k)).fwhm,...
                        data(repIdx(2)).psf.(fields(k)).fwhm]);

                end
                loc{i}(j) = mean([data(repIdx(1)).psf.(fields(k)).loc,...
                        data(repIdx(2)).psf.(fields(k)).loc]);
            elseif any(sessionID_str=='2') %Duplicates
                continue
            else
                for k = 1:numel(fields)
                    fwhm(i).(fields(k))(j) = data(j).psf.(fields(k)).fwhm;
                end
                loc{i}(j) = data(j).psf.(fields(k)).loc;
            end
        end
        %Remove NaNs
        for k = 1:numel(fields)
            fwhm(i).(fields(k)) = fwhm(i).(fields(k))(~isnan(fwhm(i).(fields(k))));
        end
        loc{i} = loc{i}(~isnan(loc{i}));
        clearvars data
    end

    %Get Z-Offsets from PSF peaks
    beam1Idx = find(contains({summary(:).title},'920nm'));
    for i = 1:numel(beam1Idx)
        sessionID = split(summary(beam1Idx(i)).title,'-');
        sessionID = strjoin(sessionID(~ismember(sessionID,{'920nm'})),'-');
        idx = [beam1Idx(i),find(ismember({summary(:).title},[sessionID,'-1064nm']))];
        offset{i} = loc{idx(1)}-loc{idx(2)};
        offsetID(i) = string(sessionID);
        clear sessionID
    end
    figs = fig_summary_psf_offsets(fwhm, offset, string({summary(:).title}), offsetID, titles);
    save_multiplePlots(figs,fullfile(fileparts(data_dir)));
end
%-------------------Older Measurements prior to Standardizing Technique-----------------------------

% %221219 1P-lens
% %Y:\michael\_2p-stim\221219 1P beads\green-chan-bead-1-0_25pwr
% dir_str = ["Y:","michael","_technical","221219 1P beads","green-chan-bead-1-0_25pwr"];
% exp(i).dir = fullfile(dir_str{:});
% exp(i).sessionID = join(dir_str(end-1:end),'-');
% exp(i).depth = 2760; %Z-coordinate of bottom slice (um)
% exp(i).um_per_pixel = 80/512;
% exp(i).crop_margins = [204,105,120];
% i=i+1;
% %Y:\michael\_2p-stim\221219 1P beads\green-chan-bead-1-0_5pwr
% dir_str = ["Y:","michael","_technical","221219 1P beads","green-chan-bead-1-0_5pwr"];
% exp(i).dir = fullfile(dir_str{:});
% exp(i).sessionID = join(dir_str(end-1:end),'-');
% exp(i).depth = 2730; %Depth from most superficial imaging plane (um)
% exp(i).um_per_pixel = 80/512;
% exp(i).crop_margins = [184,40,120];
% i=i+1;
% %Y:\michael\_2p-stim\221219 1P beads\red-chan-bead-1
% dir_str = ["Y:","michael","_technical","221219 1P beads","red-chan-bead-1"];
% exp(i).dir = fullfile(dir_str{:});
% exp(i).sessionID = join(dir_str(end-1:end),'-');
% exp(i).depth = 2755; %Z-coordinate of bottom slice (um)
% exp(i).um_per_pixel = 128/512;
% exp(i).crop_margins = [182,203,80];
% i=i+1;

% % 'Y:\michael\_2p-stim\221221-2p-grin-lens\920-2'
% % Depth from most superficial imaging plane: 275 um
% dir_str = ["Y:","michael","_technical","221221-2p-grin-lens","920-2"];
% exp(i).dir = fullfile(dir_str{:});
% exp(i).sessionID = join(dir_str(end-1:end),'-');
% exp(i).depth = 2975-(3300); %Z-coordinate of bottom slice (um) relative to most superficial image
% exp(i).um_per_pixel = 40/512;
% exp(i).crop_margins = [212,239,60];
% i=i+1;
% % 'Y:\michael\_2p-stim\221221-2p-grin-lens\1064'
% dir_str = ["Y:","michael","_technical","221221-2p-grin-lens","1064"];
% exp(i).dir = fullfile(dir_str{:});
% exp(i).sessionID = join(dir_str(end-1:end),'-');
% exp(i).depth = 2975-(3300); %Z-coordinate of bottom slice (um)
% exp(i).um_per_pixel = 64/512;
% exp(i).crop_margins = [208,234,60];
% i=i+1;
%
% %Y:\michael\_2p-stim\221222-2p-grin-lens\bead1-920
% dir_str = ["Y:","michael","_technical","221222-2p-grin-lens","bead1-920"];
% exp(i).dir = fullfile(dir_str{:});
% exp(i).sessionID = join(dir_str(end-1:end),'-');
% exp(i).depth = 2905-(3150); %Z-coordinate of bottom slice (um)
% exp(i).um_per_pixel = 40/512;
% exp(i).crop_margins = [245,127,80];
% i=i+1;
% %Y:\michael\_2p-stim\221222-2p-grin-lens\bead1-1064
% dir_str = ["Y:","michael","_technical","221222-2p-grin-lens","bead1-1064"];
% exp(i).dir = fullfile(dir_str{:});
% exp(i).sessionID = join(dir_str(end-1:end),'-');
% exp(i).depth = 2930-(3150); %Z-coordinate of bottom slice (um)
% exp(i).um_per_pixel = 64/512;
% exp(i).crop_margins = [231,209,60];
% i=i+1;
%
% %Y:\michael\_2p-stim\221223-2p-grin-lens\bead1-920
% dir_str = ["Y:","michael","_technical","221223-2p-grin-lens","bead1-920"];
% exp(i).dir = fullfile(dir_str{:});
% exp(i).sessionID = join(dir_str(end-1:end),'-');
% exp(i).depth = 2830-(3240); %Z-coordinate of bottom slice (um)
% exp(i).um_per_pixel = 40/512;
% exp(i).crop_margins = [108,130,120];
% i=i+1;
% %Y:\michael\_2p-stim\221223-2p-grin-lens\bead1-1064
% dir_str = ["Y:","michael","_technical","221223-2p-grin-lens","bead1-1064"];
% exp(i).dir = fullfile(dir_str{:});
% exp(i).sessionID = join(dir_str(end-1:end),'-');
% exp(i).depth = 2930-(3240); %Z-coordinate of bottom slice (um)
% exp(i).um_per_pixel = 37/512;
% exp(i).crop_margins = [176,196,80];
% i=i+1;
% %Y:\michael\_2p-stim\221223-2p-grin-lens\bead2-920
% dir_str = ["Y:","michael","_technical","221223-2p-grin-lens","bead2-920"];
% exp(i).dir = fullfile(dir_str{:});
% exp(i).sessionID = join(dir_str(end-1:end),'-');
% exp(i).depth = 2830-(3240); %Z-coordinate of bottom slice (um)
% exp(i).um_per_pixel = 40/512;
% exp(i).crop_margins = [166,182,120];
% i=i+1;
% %Y:\michael\_2p-stim\221223-2p-grin-lens\bead2-1064
% dir_str = ["Y:","michael","_technical","221223-2p-grin-lens","bead2-1064"];
% exp(i).dir = fullfile(dir_str{:});
% exp(i).sessionID = join(dir_str(end-1:end),'-');
% exp(i).depth = 2930-(3240); %Z-coordinate of bottom slice (um)
% exp(i).um_per_pixel = 37/512;
% exp(i).crop_margins = [196,217,80];
% i=i+1;
% %Y:\michael\_2p-stim\221223-2p-grin-lens\bead2-1064-0_5percent-pwr
% dir_str = ["Y:","michael","_technical","221223-2p-grin-lens","bead2-1064-0_5percent-pwr"];
% exp(i).dir = fullfile(dir_str{:});
% exp(i).sessionID = join(dir_str(end-1:end),'-');
% exp(i).depth = 2930-(3240); %Z-coordinate of bottom slice (um)
% exp(i).um_per_pixel = 37/512;
% exp(i).crop_margins = [189,220,80];
% i=i+1;
%
% %Y:\michael\_technical\230106-2p-beads-zstacks-920\bead1-920
% dir_str = ["Y:","michael","_technical","230106-2p-beads-zstacks-920","bead1-920"];
% exp(i).dir = fullfile(dir_str{:});
% exp(i).sessionID = join(dir_str(end-1:end),'-');
% exp(i).depth = -2265-(-2420); %Z-coordinate of bottom slice (um)
% exp(i).um_per_pixel = 70/512;
% exp(i).crop_margins = [214,260,120];
% i=i+1;
%
% %Y:\michael\_technical\230109-2p-beads-920\bead1-920
% dir_str = ["Y:","michael","_technical","230109-2p-beads-920","bead1-920"];
% exp(i).dir = fullfile(dir_str{:});
% exp(i).sessionID = join(dir_str(end-1:end),'-');
% exp(i).depth = -2165-(-2500); %Z-coordinate of bottom slice (um)
% exp(i).um_per_pixel = 70/512;
% exp(i).crop_margins = [91,181,120];
% i=i+1;
%
% %Y:\michael\_technical\230111-2p-beads\bead1-920
% dir_str = ["Y:","michael","_technical","230111-2p-beads","bead1-920"];
% exp(i).dir = fullfile(dir_str{:});
% exp(i).sessionID = join(dir_str(end-1:end),'-');
% exp(i).depth = -2113-(-2500); %Z-coordinate of bottom slice (um)
% exp(i).um_per_pixel = 70/512;
% exp(i).crop_margins = [214,206,80];
% i=i+1;
% %Y:\michael\_technical\230111-2p-beads\bead1-1064
% dir_str = ["Y:","michael","_technical","230111-2p-beads","bead1-1064"];
% exp(i).dir = fullfile(dir_str{:});
% exp(i).sessionID = join(dir_str(end-1:end),'-');
% exp(i).depth = -2140-(-2500); %Z-coordinate of bottom slice (um)
% exp(i).um_per_pixel = 70/512;
% exp(i).crop_margins = [226,217,80];
% i=i+1;
%
% %Y:\michael\_technical\230112-2p-beads\bead1-920 %Same prep as 230111
% dir_str = ["Y:","michael","_technical","230112-2p-beads","bead1-920"];
% exp(i).dir = fullfile(dir_str{:});
% exp(i).sessionID = join(dir_str(end-1:end),'-');
% exp(i).depth = -2045-(-2700); %Z-coordinate of bottom slice (um)
% exp(i).um_per_pixel = 70/512;
% exp(i).crop_margins = [274,201,60];
% i=i+1;
% %Y:\michael\_technical\230112-2p-beads\bead1-1064
% dir_str = ["Y:","michael","_technical","230112-2p-beads","bead1-1064"];
% exp(i).dir = fullfile(dir_str{:});
% exp(i).sessionID = join(dir_str(end-1:end),'-');
% exp(i).depth = -2045-(-2700); %Z-coordinate of bottom slice (um)
% exp(i).um_per_pixel = 70/512;
% exp(i).crop_margins = [232,216,60];
% i=i+1;
% %Y:\michael\_technical\230112-2p-beads\bead2-920 %Same prep as 230111
% dir_str = ["Y:","michael","_technical","230112-2p-beads","bead2-920"];
% exp(i).dir = fullfile(dir_str{:});
% exp(i).sessionID = join(dir_str(end-1:end),'-');
% exp(i).depth = -2250-(-2700); %Z-coordinate of bottom slice (um)
% exp(i).um_per_pixel = 70/512;
% exp(i).crop_margins = [201,211,100];
% i=i+1;
% %Y:\michael\_technical\230112-2p-beads\bead2-1064
% dir_str = ["Y:","michael","_technical","230112-2p-beads","bead2-1064"];
% exp(i).dir = fullfile(dir_str{:});
% exp(i).sessionID = join(dir_str(end-1:end),'-');
% exp(i).depth = -2250-(-2700); %Z-coordinate of bottom slice (um)
% exp(i).um_per_pixel = 70/512;
% exp(i).crop_margins = [214,226,100];
% i=i+1;
%Y:\michael\_technical\230112-2p-beads\bead3-920 %Might have accidentally used dual-wavelength??
% dir_str = ["Y:","michael","_technical","230112-2p-beads","bead3-920"];
% exp(i).dir = fullfile(dir_str{:});
% exp(i).sessionID = join(dir_str(end-1:end),'-');
% exp(i).depth = -2185-(-2700); %Z-coordinate of bottom slice (um)
% exp(i).um_per_pixel = 70/512;
% exp(i).crop_margins = [205,210,100];
% i=i+1;
% %Y:\michael\_technical\230112-2p-beads\bead3-1064
% dir_str = ["Y:","michael","_technical","230112-2p-beads","bead3-1064"];
% exp(i).dir = fullfile(dir_str{:});
% exp(i).sessionID = join(dir_str(end-1:end),'-');
% exp(i).depth = -2185-(-2700); %Z-coordinate of bottom slice (um)
% exp(i).um_per_pixel = 70/512;
% exp(i).crop_margins = [227,217,100];
% i=i+1;
%
% %Y:\michael\_technical\230112-2p-beads-nogrinlens\bead1-920
% dir_str = ["Y:","michael","_technical","230112-2p-beads-nogrinlens","bead1-920"];
% exp(i).dir = fullfile(dir_str{:});
% exp(i).sessionID = join(dir_str(end-1:end),'-');
% exp(i).depth = NaN; %Z-coordinate of bottom slice (um)
% exp(i).um_per_pixel = 70/512;
% exp(i).crop_margins = [214,218,80];
% i=i+1;
% %Y:\michael\_technical\230112-2p-beads-nogrinlens\bead1-1064
% dir_str = ["Y:","michael","_technical","230112-2p-beads-nogrinlens","bead1-1064"];
% exp(i).dir = fullfile(dir_str{:});
% exp(i).sessionID = join(dir_str(end-1:end),'-');
% exp(i).depth = NaN; %Z-coordinate of bottom slice (um)
% exp(i).um_per_pixel = 70/512;
% exp(i).crop_margins = [229,230,80];
% i=i+1;
%
% %Y:\michael\_technical\230113-2p-beads-nogrinlens\bead1-920
% dir_str = ["Y:","michael","_technical","230113-2p-beads-nogrinlens","bead1-920"];
% exp(i).dir = fullfile(dir_str{:});
% exp(i).sessionID = join(dir_str(end-1:end),'-');
% exp(i).depth = NaN; %Z-coordinate of bottom slice (um)
% exp(i).um_per_pixel = 70/512;
% exp(i).crop_margins = [200,232,80];
% i=i+1;
% %Y:\michael\_technical\230113-2p-beads-nogrinlens\bead1-1064
% dir_str = ["Y:","michael","_technical","230113-2p-beads-nogrinlens","bead1-1064"];
% exp(i).dir = fullfile(dir_str{:});
% exp(i).sessionID = join(dir_str(end-1:end),'-');
% exp(i).depth = NaN; %Z-coordinate of bottom slice (um)
% exp(i).um_per_pixel = 70/512;
% exp(i).crop_margins = [206,245,80];
% i=i+1;
% %Y:\michael\_technical\230113-2p-beads-nogrinlens\bead2-920
% dir_str = ["Y:","michael","_technical","230113-2p-beads-nogrinlens","bead2-920"];
% exp(i).dir = fullfile(dir_str{:});
% exp(i).sessionID = join(dir_str(end-1:end),'-');
% exp(i).depth = NaN; %Z-coordinate of bottom slice (um)
% exp(i).um_per_pixel = 70/512;
% exp(i).crop_margins = [200,213,80];
% i=i+1;
%Y:\michael\_technical\230113-2p-beads-nogrinlens\bead2-1064
% dir_str = ["Y:","michael","_technical","230113-2p-beads-nogrinlens","bead2-1064"];
% exp(i).dir = fullfile(dir_str{:});
% exp(i).sessionID = join(dir_str(end-1:end),'-');
% exp(i).depth = NaN; %Z-coordinate of bottom slice (um)
% exp(i).um_per_pixel = 70/512;
% exp(i).crop_margins = [201,208,80];
% i=i+1;
%-----------------------------------------------------------
