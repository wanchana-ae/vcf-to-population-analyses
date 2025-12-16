import pandas as pd
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import os

#Get path dir contain script
script_dir = os.path.dirname(os.path.abspath(__file__))

#CWD to path dir contain script
os.chdir(script_dir)

# read csv
df = pd.read_csv('PCA.csv')

# create 3D
fig = plt.figure(figsize=(10, 8))
ax = fig.add_subplot(111, projection='3d')

# plot dot
ax.scatter(df['EV1'], df['EV2'], df['EV3'], c='blue', marker='o', s=100)

# change name 
ax.set_xlabel('EV1')
ax.set_ylabel('EV2')
ax.set_zlabel('EV3')
ax.set_title('3D PCA Plot')

# Label
for i, txt in enumerate(df['sample.id']):
    ax.text(df['EV1'][i], df['EV2'][i], df['EV3'][i], '%s' % (txt), size=10, zorder=1, color='k')

plt.show()