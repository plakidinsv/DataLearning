import os

def clean_file():
    folder=r"E://Courses//Metamarketing 2022"
    source = os.listdir(folder)
    for file in source:
        if file.startswith('['):            
            filename_new=file[91:]
            os.rename(os.path.join(folder, file), os.path.join(folder, filename_new))

clean_file()