import os
import shutil

def delete_directory(dir_path):
    # Vérifier si le répertoire existe
    if os.path.exists(dir_path):
        try:
            # Utiliser shutil.rmtree pour supprimer le répertoire et son contenu
            shutil.rmtree(dir_path)
            print(f"Le répertoire '{dir_path}' a été supprimé avec succès!")
        except Exception as e:
            print(f"Erreur lors de la suppression du répertoire '{dir_path}'. Détails: {e}")
    else:
        print(f"Le répertoire '{dir_path}' n'existe pas!")

if __name__ == "__main__":
    directory_to_delete = "../infra/"
    delete_directory(directory_to_delete)