def main():
    # Your code here
    file_path = "./input.txt"  # Replace with the actual file path
    with open(file_path, "r") as file:
        data = file.read()
        # Process the data here
        print(data)

if __name__ == "__main__":
    main()