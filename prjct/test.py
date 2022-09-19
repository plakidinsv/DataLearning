import os
from pathlib import Path


# with os.scandir('./Source') as source:
#     for file in source:
#         print(file)

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