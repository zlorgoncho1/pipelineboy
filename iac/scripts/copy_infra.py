import os
import shutil

def copy_tf_files(source_dir, dest_dir):
    if not os.path.exists(source_dir):
        print(f"Source directory '{source_dir}' does not exist!")
        return
    
    if not os.path.exists(dest_dir):
        os.makedirs(dest_dir)
        print(f"Destination directory '{dest_dir}' created!")

    for filename in os.listdir(source_dir):
        if filename.endswith(".tf") or filename.endswith(".tfvars"):
            source_path = os.path.join(source_dir, filename)
            dest_path = os.path.join(dest_dir, filename)
            
            shutil.copy2(source_path, dest_path)
            print(f"Copied {filename} from '{source_dir}' to '{dest_dir}'")

if __name__ == "__main__":
    source_directory = "../terraform/"
    destination_directory = "../infra/"

    copy_tf_files(source_directory, destination_directory)
