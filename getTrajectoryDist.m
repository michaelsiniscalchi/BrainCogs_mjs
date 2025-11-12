function trajectories = getTrajectoryDist(subjects)

S = subjects; 

trajectories = struct();
for i = 1:numel(S)
        
    traj = struct(); 
    choice = ["left","right"];
    
            for j = 1:numel(S(i).sessions)
                %Session Date
                traj(j).session_date = ...
                    S(i).trialData(j).session_date;
                for k = 1:numel(choice)
                    %Define trial subset for analysis
                    trialIdx.(choice(k)) = ...
                        S(i).trials(j).(choice(k)) &... %                         S(i).trials(j).correct &...
                        S(i).trials(j).forward &...
                        ~S(i).trials(j).exclude; 
                    
                    [traj(j).(choice(k)), trialIdx.(choice(k))] = getTrajectoryStats(S(i),j,trialIdx.(choice(k)));
                    
                end
                
                %Session info
                nBlocks = numel(traj(j).left.x_trajectory); %Blocks with different maze length
                for k = 1:nBlocks
                    traj(j).nLeft(k) = size(traj(j).left.x_trajectory(k).data,2);
                    traj(j).nRight(k) = size(traj(j).right.x_trajectory(k).data,2);
                    traj(j).level(k) = S(i).sessions.level(k);
                    traj(j).maze_length(k) = size(traj(j).left.x_trajectory(k).data,1);
                    traj(j).maxSkidAngle(k) =...
                        str2double(S(i).logs(j).version(end).mazes(S(i).logs(j).block(k).mazeID).variable.maxSkidAngle);
                end
            end
   
    trajectories.(S(i).ID) = traj;
end

    function [ stats, trialIdx ] = getTrajectoryStats(subj,sessionIdx,trialIdx)
        
        vars = ["x_trajectory","theta_trajectory"];
        
        for i = 1:numel(vars)
            
            %Data in cells to accommodate sessions with more than one level
            data = subj.trialData(sessionIdx).(vars(i));
            if ~iscell(data)
                data = {data};
            end
            
            %Convert from cumulative to relative view angle 
            if vars(i)=="theta_trajectory"
                data = cellfun(@angleMPiPi,data,'UniformOutput',false);
            end
            
            %Convert trial indices to cell
            if ~iscell(trialIdx)
                tempIdx = trialIdx;
                trialIdx = cell(numel(data));
                trialIdx{1} = tempIdx(1:size(data{1},2));
                for j = 2:numel(data)
                    trialIdx{j} = tempIdx(size(data{j-1},2) + 1:size(data{j},2));
                end
            end
            
            for j = 1:numel(data)
                %Raw data from specified sessions
                stats.(vars(i))(j).data =...
                    data{j}(:,trialIdx{j});
                %Mean
                stats.(vars(i))(j).mean =...
                    mean(data{j}(:,trialIdx{j}),2);
                %Standard Deviation
                stats.(vars(i))(j).std =...
                    std(data{j}(:,trialIdx{j}),0,2);
                %5-number summary
                p = [9,25,50,75,91];
                stats.(vars(i))(j).fiveNumSummary =...
                    prctile(data{j}(:,trialIdx{j}),p,2);
            end

        end