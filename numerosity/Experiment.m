% Experiment settings
nTrial = 350;
nBlock = 5;
nRefDots = 10;
conditions = [5; 6; 8; 10; 12; 16; 20];

% Load design matrix
matrix = readtable('DesignMatrix.csv');

% PTB setup
PsychDefaultSetup(2);
KbName('UnifyKeyNames');
LKEY = KbName('f');
RKEY = KbName('j');
ESCKEY = KbName('escape');

Screen('Preference', 'SkipSyncTests', 2);
Screen('Preference','VisualDebugLevel', 4);
Screen('Preference','SuppressAllWarnings', 1);
screenNumber = max(Screen('Screens'));
% [wptr, rect] = Screen('OpenWindow', screenNumber, [128, 128, 128], [0, 0, 960, 540]);
[wptr, rect] = Screen('OpenWindow', screenNumber, [128, 128, 128]);
[x_ctr, y_ctr] = RectCenter(rect);
HideCursor;
Priority(2);

% Load instructions and stimuli
instr_start = Screen('MakeTexture', wptr, imresize(imread('stimuli/instr_start.jpg'), rect(4: -1: 3)));
instr_block_end = Screen('MakeTexture', wptr, imresize(imread('stimuli/instr_block_end.jpg'), rect(4: -1: 3)));
instr_end = Screen('MakeTexture', wptr, imresize(imread('stimuli/instr_end.jpg'), rect(4: -1: 3)));
fix_texture = Screen('MakeTexture', wptr, imresize(imread('stimuli/fixation.jpg'), rect(4: -1: 3)));

% Clear keyboard cache
while KbCheck; end

% Show starting instructions
Screen('DrawTexture', wptr, instr_start);
Screen('Flip', wptr);
while ~KbCheck; end

% Loop for blocks
for curr_block = 1: nBlock
   % Make textures
   block_matrix = matrix(matrix.BlockID == curr_block, :);
   stim_l = zeros(nTrial / nBlock, 1);
   stim_r = zeros(nTrial / nBlock, 1);
   for curr_trial = 1: (nTrial / nBlock)
       stim_ = [Screen('MakeTexture', wptr, imread(block_matrix.RefPaths{curr_trial})), ...
                Screen('MakeTexture', wptr, imread(block_matrix.TestPaths{curr_trial}))];
       stim_l(curr_trial) = stim_(block_matrix.RefLoc(curr_trial) + 1);
       stim_r(curr_trial) = stim_(2 - block_matrix.RefLoc(curr_trial));
   end
   
   WaitSecs(1.000);
   % Loop for trials within one block
   for curr_trial = 1: (nTrial / nBlock)
       % Blank for 1500ms, and prepare fixation
       blank_t0 = Screen('Flip', wptr);
       mid_rect = Screen('Rect', fix_texture);
       Screen('DrawTexture', wptr, fix_texture, mid_rect, [x_ctr - 200, y_ctr - 200, x_ctr + 200, y_ctr + 200]);
       while GetSecs - blank_t0 <= 1.500, end
       
       % Fixation for 1000-1500ms, and prepare stimuli
       fix_t0 = Screen('Flip', wptr);
       fixation_time = rand * 0.5 + 1;
       l_rect = Screen('Rect', stim_l(curr_trial));
       r_rect = Screen('Rect', stim_r(curr_trial));
       Screen('DrawTexture', wptr, stim_l(curr_trial), l_rect, [x_ctr - 336, y_ctr - 112, x_ctr - 112, y_ctr + 112]);
       Screen('DrawTexture', wptr, stim_r(curr_trial), r_rect, [x_ctr + 112, y_ctr - 112, x_ctr + 336, y_ctr + 112]);
       while GetSecs - fix_t0 <= fixation_time, end
       
       % Show stimuli for 200ms, and waiting for response
       stim_t0 = Screen('Flip', wptr);
       stim_exists = true;
       while true
          [keyIsDown, keyTS, keyCode] = KbCheck;
          if keyIsDown && keyCode(ESCKEY), sca; error('Stopped.');
          elseif keyIsDown && keyCode(LKEY), response = 0; RT = keyTS - stim_t0; break;
          elseif keyIsDown && keyCode(RKEY), response = 1; RT = keyTS - stim_t0; break;
          % elseif keyIsDown, RT = keyTS - stim_t0; break;
          end
          if stim_exists && (GetSecs - stim_t0 >= 0.200), Screen('Flip', wptr); stim_exists = false; end
       end
       block_matrix.Responses(curr_trial) = response;
       block_matrix.RT(curr_trial) = RT;
   end
   
   % Save collected responses in current block to file
   writetable(block_matrix, sprintf('Behaviour_block_%d.csv', curr_block), 'WriteVariableName', true);
   
   % Have a rest
   if curr_block ~= nBlock
       % Clear keyboard cache
       while KbCheck(); end
       Screen('DrawTexture', wptr, instr_block_end);
       Screen('Flip', wptr);
       while ~KbCheck; end
   end
end

% Save all responses to file
writetable(matrix, 'Behaviour_all.csv', 'WriteVariableName', true);

% Show ending instructions
Screen('DrawTexture', wptr, instr_end);
Screen('Flip', wptr);
ShowCursor;
WaitSecs(5);
sca;