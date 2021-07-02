import os
import random
import numpy as np
import pandas as pd
from psychopy import visual, core, event

N_BLK = 4
TRIAL_PER_BLK = 40
SCR_PER_TRIAL = 22
STIM_PATH = 'testpi'
STIM_KEYS = [f'Stim_{i}' for i in range(1, SCR_PER_TRIAL + 1)]
TARGETS = tuple([chr(i) for i in range(97, 97 + 26) if i not in (98, 105, 111, 122)]) # Excluding B, I, O, Z
RESPONSE_KEYS = [*TARGETS, 'escape']
dm = pd.read_csv('design_matrix.csv')
ON_DUR = input('Stimulus on duration (default to 0.1): ')
ON_DUR = float(ON_DUR) if ON_DUR else 0.1

def FNAME(idx):
    return os.path.join(STIM_PATH, f'{int(idx) if isinstance(idx, float) else idx}.png')

def show_stimulus(win: visual.Window, stimulus: visual.BaseVisualStim, on: float, off: float):
    stimulus.draw()
    on_ts = win.flip()
    if on:
        while core.getTime() - on_ts <= on:
            pass
        off_ts = win.flip()
        if off:
            while core.getTime() - off_ts <= off:
                pass

def wait_key(win: visual.Window, RESPONSE_KEYS=None):
    key = event.waitKeys()[0]
    while RESPONSE_KEYS and (key not in RESPONSE_KEYS):
        key = event.waitKeys()[0]
    if 'escape' in key:
        win.close()
        dm.to_csv('result_matrix_final.csv', index=False)
        raise RuntimeError
    return key

def show_stimulus_for_key(win: visual.Window, stimulus: visual.BaseVisualStim, blank: float, RESPONSE_KEYS=None):
    stimulus.draw()
    win.flip()
    key = wait_key(win, RESPONSE_KEYS)
    if blank:
        win.flip()
        ts = core.getTime()
        while core.getTime() - ts <= blank:
            pass
    return key

class MainStim(object):
    def __init__(self, dm: pd.DataFrame, win: visual.Window) -> None:
        self.win = win
        self.block_id = 1
        self.stimuli = np.array(
            [visual.ImageStim(win, image=FNAME(idx)) for idx in dm.loc[:, STIM_KEYS].to_numpy().reshape(-1)
            ]).reshape(N_BLK, TRIAL_PER_BLK, SCR_PER_TRIAL)

    def __iter__(self):
        return iter(self.stimuli)

win = visual.Window(color='#808080', fullscr=True, allowGUI=False)
fixation = visual.ImageStim(win, image=FNAME(0))
Q1 = visual.TextStim(win, '任务1：报告您看到的第一个字母', pos=(0, 0))
Q2 = visual.TextStim(win, '任务2：报告您看到的第二个字母', pos=(0, 0))

mouse = event.Mouse(visible=False)
stimuli = MainStim(dm, win)
for i, block in enumerate(stimuli):
    sinstructions = visual.TextStim(win, '''实验开始，您会看到中央的绿色十字注视点，
    按任意键后，屏幕会开始呈现一系列数字和字母。
    请您忽略出现的数字，记下出现的两个字母并按键反应。
    在您确定了解任务后，按任意键以开始。
    ''', pos=(-0.30, 0))
    show_stimulus_for_key(win, sinstructions, 2)
    for j, trial in enumerate(block):
        show_stimulus_for_key(win, fixation, 1 + random.random())
        for stimulus in trial:
            stimulus.draw()
            on_ts = win.flip()
            while core.getTime() - on_ts <= ON_DUR:
                pass

        key1 = TARGETS.index(show_stimulus_for_key(win, Q1, 0, RESPONSE_KEYS)) + 1
        key2 = TARGETS.index(show_stimulus_for_key(win, Q2, 0, RESPONSE_KEYS)) + 1
        dm.loc[i * TRIAL_PER_BLK + j, ['T1_R', 'T2_R']] = [key1, key2]
        win.flip()
    
    dm.to_csv(f'result_matrix_{i + 1}.csv')
    if i < N_BLK - 1:
        einstructions = visual.TextStim(win, f'''您已经完成了第{i + 1}轮实验。请您稍事休息，
        按任意键后等待半分钟开始下一轮实验。
        ''', pos=(-0.10, 0))
        show_stimulus_for_key(win, einstructions, 30)

mouse.setVisible(True)
show_stimulus(win, visual.TextStim(win, '实验结束，程序将稍后退出。', pos=(0, 0)), 3, 0)
dm['T1_ACC'], dm['T2_ACC'] = (dm['T1'] == dm['T1_R'], dm['T2'] == dm['T2_R'])
dm.to_csv('result_matrix_final.csv', index=False)
win.close()