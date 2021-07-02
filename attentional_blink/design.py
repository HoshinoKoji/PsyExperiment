import random
import numpy as np
import pandas as pd
from collections.abc import Iterable

def neighbour_ind_sampling(series: Iterable, n: int):
    output = [random.choice(series)]
    while len(output) < n:
        last = output[len(output) - 1]
        new = last
        while last == new:
            new = random.choice(series)
        output.append(new)

    return output

# Initialize design matrix
N_BLK = 4
TRIAL_PER_BLK = 40
SCR_PER_TRIAL = 22
STIM_KEYS = [f'Stim_{i}' for i in range(1, SCR_PER_TRIAL + 1)]
dm = pd.DataFrame(columns=[
    'BlockID', 'TrialID', 'T1_Position', 'LagPosition', 'T1', 'T2', 'T1_R', 'T2_R', 'T1_ACC', 'T2_ACC', *STIM_KEYS
])

# Generate design
# BlockID: 1, 1, 1, ..., 2, 2, ..., 4, 4
# TrialID: 1, 2, 3, 4, ..., 40, 1, 2, ..., 39, 40
# T1_Position: {7, 8, 9, 10, 11}
# LagPosition: {1, 2, 3, 4, 5, 6, 7, 8}
dm['BlockID'] = np.repeat([i for i in range(1, N_BLK + 1)], TRIAL_PER_BLK)
dm['TrialID'] = np.tile([i for i in range(1, TRIAL_PER_BLK + 1)], N_BLK)

TARGETS = np.arange(1, 23)
DISTRACTORS = np.arange(23, 29)
T1_POSITION = np.arange(7, 12)
LAG_POSITION = np.arange(1, 9)
CONDITIONS = np.reshape([[(i, j) for i in T1_POSITION] for j in LAG_POSITION], [40, 2]) # T1_P, LagP
for i in range(1, N_BLK + 1):
    np.random.shuffle(CONDITIONS)
    dm.loc[dm['BlockID'] == i, 'T1_Position'] = CONDITIONS.T[0]
    dm.loc[dm['BlockID'] == i, 'LagPosition'] = CONDITIONS.T[1]

# Per-trial design
for i in range(N_BLK * TRIAL_PER_BLK):
    # Determining targets
    t1, t2 = np.random.choice(TARGETS, size=2, replace=False)
    dm.loc[i, ['T1', 'T2']] = [t1, t2]
    t1_p, lag_p = dm.loc[i, ['T1_Position', 'LagPosition']]
    
    # Determining stimuli array
    stimuli = neighbour_ind_sampling(DISTRACTORS, SCR_PER_TRIAL)
    stimuli[t1_p - 1] = t1
    stimuli[t1_p + lag_p - 1] = t2
    dm.loc[i, STIM_KEYS] = stimuli

def generate():
    dm.to_csv('design_matrix.csv', index=None)

if __name__ == '__main__':
    generate()