import chardet

def detect_encoding(file_path):
    # Read the first 1024 bytes to guess encoding
    with open(file_path, 'rb') as file:
        raw_data = file.read(1024)
        result = chardet.detect(raw_data)
        encoding = result['encoding']
        confidence = result['confidence']
        print(f"Detected encoding: {encoding} (confidence: {confidence})")
        return encoding

def read_file_with_encoding(file_path, encoding):
    try:
        with open(file_path, 'r', encoding=encoding) as file:
            content = file.read()
            print("\nFile content:\n")
            print(content)
    except UnicodeDecodeError as e:
        print(f"Error reading file with encoding {encoding}: {e}")

def main():
    file_path = input("Enter the path to your file: ")
    encoding = detect_encoding(file_path)
    
    if encoding:
        read_file_with_encoding(file_path, encoding)
    else:
        print("Could not determine encoding.")

if __name__ == "__main__":
    main()
