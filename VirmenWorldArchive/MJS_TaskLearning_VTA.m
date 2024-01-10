function [mazes, criteria, globalSettings, vr] = MJS_TaskLearning_VTA(vr)

% Mazes 1--5, L-Maze for navigation/motor training; 
%   Maze 3, Final length; intro "gauntlet" with view-angle restriction in start segment  
%   Maze 4, intro Friction and Air Puffs 
% Maze 6, Sensory Maze 
% Maze 7, Alternation Maze
% Maze 8, Alternation with ATT segment lengths
% Maze 9, Sensory with ATT segment lengths

%_________________________________________ 1 _____ 2 _____ 3 _____ 4 _____ 5 _____ 6 _____ 7 ______ 8 ______ 9 ______     
  mazes     = struct( 'lStart'          , {    10  ,  10   ,   50  ,  50   ,  50   ,  50   ,   50   ,   30   ,   30  } ... Length of start segment in meters (where typically view angle is fixed)
                    , 'lCue'            , {    20  ,  70   ,   90  ,  90   ,  90   ,  90   ,   90   ,  200   ,  200  }    ... Length of cue segment (m)
                    , 'lMemory'         , {     5  ,   5   ,   10  ,  10   ,  10   ,  10   ,   10   ,  100   ,  100  }    ... Length of segment following cue segment where no cues present (m)
                    , 'forcedChoice'    , {  true  , true  , true  , true  , true  , false , false  , false  , false }   ...
                    , 'alternateTrials' , { false  , false , false , false , false , false ,  true  ,  true  , false }   ...
                    , 'tri_turnHint'    , { false  , false , false , false , false , false , false  , false  , false }   ... Distal visual cue
                    , 'turnHint_Mem'    , { false  , false , false , false , false , false , false  , false  , false }   ... If true, distal cue disappears during memory segment                 
                    , 'cueDuration'     , {  -1    , -1    , -1    , -1    , -1    , nan   , nan    , nan    , nan   }   ... In seconds (nan: permanent cues; inf: cues dissappear in mem segment)
                    , 'cueVisibleAt'    , { inf    , inf   , inf   , inf   , inf   ,  10   ,  10    ,  10    ,  10   }   ... Distance from which cue is visible
                    , 'cueProbability'  , { inf    , inf   , inf   , inf   , inf   , inf   , inf    , inf    , inf   }   ... Ratio of salient/distractor cues
                    , 'cueDensityPerM'  , {   3    ,   3   ,   3   ,   3   ,   3   , 4.2   , 4.2    , 4.2    , 4.2   }   ... Maximal number of towers/m
                    , 'puffDuration'    , { nan    , nan   , nan   , nan   , nan   , nan   , nan    , nan    , nan   }   ... Duration of air puff in ms
                    , 'maxSkidAngle'    , { inf    , inf   , 0.25  , 0.25  , 0.1   , 0.25  , 0.25   , 0.25   , 0.25  }   ... Maximum permitted view angle in pi*rad for progress along Y-axis of main stem 
                    , 'friction'        , { 0      , 0     , 0     , 1     , 1     , 1     , 1      , 1      , 1     }   ... Proportional reduction in displacement if collision detected 
                    , 'antiFraction'    , { 0      , 0     , 0     , 0     , 0     , 0     , 0      , 0      , 0     }   ... fraction of trials with inverted reward condition
                    , 'timeLimit'       , { inf    , inf   , inf   , inf   , inf   , inf   , inf    , inf    , inf   }   ... Time limit for session in minutes, or inf
                    , 'world'           , { 1      , 1     , 1     , 1     , 1     , 1     , 1      , 1      , 1     }   ... index in vr.worlds
                    );
              
                
  criteria  = struct( 'numTrials'       , {  25    ,  50   , 100   , 100   ,  100  ,  100  ,  100   ,  100   ,  100  }   ... Minimum number of trials the mouse must spend above performance 
                    , 'numTrialsPerMin' , {   0    ,   2   ,   5   ,   5   ,    9  ,    9  ,    9   ,    9   ,    9  }   ... Number of trials required per minute to be considered maintaining "good" performance 
                    , 'criteriaNTrials' , { inf    , inf   , 100   , 100   ,  100  ,  100  ,  100   ,  100   ,  100  }   ... Number of trials in the running window used to measure performance for deciding whether to advance to the next maze
                    , 'warmupNTrials'   , {  []    ,  []   ,  []   ,  []   ,   []  ,   []  ,   []   ,   []   ,   []  }   ...
                    , 'numSessions'     , {   0    ,   0   ,   0   ,   0   , 1000  , 1000  , 1000   , 1000   , 1000  }   ... Minimum number of sessions the navigator must have above criteria before advancing
                    , 'performance'     , {   0    ,   0   , 0.8   , 0.8   , 0.95  , 0.95  , 0.95   , 0.95   , 0.95  }   ... Minimum performance criterion to advance maze
                    , 'maxBias'         , { inf    , inf   , 0.2   , 0.2   , 0.1   , 0.1   , 0.1    , 0.1    , 0.1   }   ... Max allowed side bias to advance
                    , 'warmupMaze'      , {  []    ,  []   , []    , []    , []    , []    , []     , []     , []    }   ... Index of Virmen world in vr.worlds for the warmup maze for that particular main maze, which occurs at the start of a given session
                    , 'warmupPerform'   , {  []    ,  []   , []    , []    , []    , 0.95  , 0.95   , 0.95   , 0.95  }   ... Minimum performance during warmup to advance to mainMaze
                    , 'warmupBias'      , {  []    ,  []   , []    , []    , []    , 0.1   , 0.1    , 0.1    , 0.1   }   ... Max allowed side bias allowed during warmup to advance to main maze
                    , 'warmupMotor'     , {  []    ,  []   , []    , []    , []    , 0.95  , 0.95   , 0.95   , 0.95  }   ... ??
                    , 'easyBlock'       , { nan    , nan   , nan   , nan   , nan   , nan   , nan    , nan    , nan   }   ... maze ID of easy block    
                    , 'easyBlockNTrials', {  []    ,  []   , []    , []    , []    , []    , []     , []     , []    }   ... number of trials in easy block   
                    , 'numBlockTrials'  , {  []    ,  []   , []    , []    , []    , []    , []     , []     , []    }   ... performance threshold to go into easy block
                    , 'blockPerform'    , { 0.7    , 0.7   , 0.7   , 0.7   , 0.7   , 0.7   , 0.7    , 0.7    , 0.7   }   ...
                    );

  globalSettings          = {'cueMinSeparation', 12, 'fracDuplicated', 0.5, 'trialDuplication', 4};
  vr.numMazesInProtocol   = numel(mazes);
  vr.stimulusGenerator    = @PoissonStimulusTrain_mjs;
  vr.stimulusParameters   = {'cueVisibleAt', 'cueDensityPerM', 'cueProbability','nCueSlots','cueMinSeparation'};
  vr.inheritedVariables   = {'timeLimit'}; %{'cueDuration','cueVisibleAt','lStart','lCue','lMemory','maxSkidAngle','timeLimit'}

  
  if nargout < 1
    figure; plot([mazes.lStart] + [mazes.lCue] + [mazes.lMemory], 'linewidth',1.5); xlabel('Shaping step'); ylabel('Maze length (cm)'); grid on;
    hold on; plot([mazes.lMemory], 'linewidth',1.5); legend({'total', 'memory'}, 'Location', 'east'); grid on;
    figure; plot([mazes.lMemory] ./ [mazes.lCue], 'linewidth',1.5); xlabel('Shaping step'); ylabel('L(memory) / L(cue)'); grid on;
    figure; plot([mazes.cueDensityPerM], 'linewidth',1.5); set(gca,'ylim',[0 6.5]); xlabel('Shaping step'); ylabel('Tower density (count/m)'); grid on;
    hold on; plot([mazes.cueDensityPerM] .* (1 - 1./(1 + exp([mazes.cueProbability]))), 'linewidth',1.5);
    hold on; plot([mazes.cueDensityPerM] .* (1./(1 + exp([mazes.cueProbability]))), 'linewidth',1.5);
    hold on; plot([1 numel(mazes)], [1 1].*(100/globalSettings{2}), 'linewidth',1.5, 'linestyle','--');
    legend({'\rho_{L} + \rho_{R}', '\rho_{salient}', '\rho_{distract}', '(maximum)'}, 'location', 'northwest');
    
    [muSalient, muDistract] = poissonCueDensity([mazes.cueDensityPerM], [mazes.cueProbability]);
    disp(significantDigits([muSalient; muDistract] * mazes(end-1).lCue/100, 2));
  end

end
