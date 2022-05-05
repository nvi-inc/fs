import psutil

def main():
    for p in psutil.process_iter():
        if "fesh2" in p.name():
            print(p)

if __name__ == "__main__":
    main()
