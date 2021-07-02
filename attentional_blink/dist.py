import os
import shutil
import design

sub_id = input('Subject ID: ')
sub_dir = f'sub{sub_id}'
if not os.path.isdir(sub_dir):
    os.mkdir(sub_dir)

print('Generating design matrix...')
design.generate()

print('Copying files...')
shutil.copy('main.py', os.path.join(sub_dir, 'main.py'))
shutil.copytree('testpi', os.path.join(sub_dir, 'testpi'))
shutil.copy('design_matrix.csv', os.path.join(sub_dir, 'design_matrix.csv'))