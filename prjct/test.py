import os
import pandas as pd
from pathlib import Path


# with os.scandir('./Source') as source:
#     for file in source:
#         print(file)
'''
source = './Source'


for file in os.listdir(source):
    print((f'./Source{file}'))
    # print(file)


source = './Source'
s = os.listdir(source)
print(s)

l = pathlib.Path('./Source')
k = source.iterdir()
print(k)

df = pd.read_excel('./Source/05tbl08_2005.xls')
df.to_csv('./Source/05tbl08_2005.csv', index=False)

for file in os.listdir(source):
    df = pd.read_excel(f'./Source/{file}')
    tr = df.to_csv(f'./Source/{file}', index=False)
'''

source = os.listdir('./Source') # вынести в переменную
for file in source:
    if file.endswith('.xls'):
        cleanfilename=file.replace('.xls', '')
        df = pd.read_excel(f'./Source/{file}')
        csvname = cleanfilename + '.csv'
        df.to_csv(f'./Source/{csvname}', index = False)

