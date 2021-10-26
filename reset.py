import os

def main():
    for file in os.listdir("downloads"):
        # print(file)
        os.remove(os.path.join("downloads", file))

    for folder in os.listdir("servers"):
        # print(folder)
        for file in os.listdir(os.path.join("servers", folder)):
            # print(file)
            os.remove(os.path.join("servers", folder, file))
        os.rmdir(os.path.join("servers", folder))

if __name__ == "__main__":
    main()