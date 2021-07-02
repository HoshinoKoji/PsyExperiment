% This file is for generating design matrix.
% Output should include:
%   1. Trial ID -> TrialID
%   2. Block ID -> BlockID
%   3. Location of reference images -> RefLoc
%   4. Numbers of test/detection images -> nTestDots
%   5. Paths of reference images -> RefPaths
%   6. Paths of test images -> TestPaths
%   7. Subject responses -> Responses
%   8. Subject response time -> RT
%   9. Whether detection stimuli are reported to be more -> TestMore
%   10. Correct responses -> CorrectResponses

clear; close all;

% Preset parameters
nTrial = 350;
nBlock = 5;
nRefDots = 10;
conditions = [5; 6; 8; 10; 12; 16; 20];
refTemplate = 'stimuli/main/ref_images/img_%02d_%03d.png';
testTemplate = 'stimuli/main/test_images/img_%02d_%03d.png';
testStimID = repmat(451: 500, [1, length(conditions)]);

% Trial ID and block ID
TrialID = transpose(1: nTrial);
BlockID = sort(repmat(transpose(1: nBlock), [nTrial / nBlock, 1]));

% Position of reference images, 0 for left and 1 for right
RefLoc = repmat([0; 1], [nTrial / 2, 1]);
RefLoc = RefLoc(randperm(nTrial));

% Numbers of test images, and paths of stimuli
nTestDots = repmat(conditions, [nTrial / length(conditions), 1]);
RefPaths = cell(350, 1);
TestPaths = cell(350, 1);
for i = 1: nTrial
    RefPaths{i} = sprintf(refTemplate, nRefDots, i);
    TestPaths{i} = sprintf(testTemplate, nTestDots(i), testStimID(i));
end

% Shuffle nTestDots, RefPaths and TestPaths
newOrders = randperm(350);
nTestDots = nTestDots(newOrders);
RefPaths = RefPaths(newOrders);
TestPaths = TestPaths(newOrders);

% Subject reponses(0/1), correct responses(0/1), response time, and correctness(0/1)
Responses = ones([nTrial, 1]) * (-1);
RT = ones([nTrial, 1]) * (-1);
TestMore = ones([nTrial, 1]) * (-1);
CorrectReponses = xor(RefLoc, (nRefDots < nTestDots));

% Export to csv file
matrix = table(TrialID, BlockID, RefLoc, nTestDots, RefPaths, TestPaths, Responses, RT, TestMore, CorrectReponses);
writetable(matrix, 'DesignMatrix.csv', 'WriteVariableName', true);