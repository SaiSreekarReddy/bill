import charset_normalizer
import os

def detect_encoding(file_path):
    with open(file_path, 'rb') as file:
        raw_data = file.read()
        result = charset_normalizer.detect(raw_data)
        encoding = result.get('encoding')
        confidence = result.get('confidence')
        print(f"Detected encoding: {encoding} (confidence: {confidence})")
        return encoding if confidence > 0.5 else None

def read_and_save_as_utf8(file_path, encoding):
    try:
        # Read file with detected encoding
        with open(file_path, 'r', encoding=encoding) as file:
            content = file.read()

        # Re-save file as UTF-8
        utf8_path = f"{os.path.splitext(file_path)[0]}_utf8.txt"
        with open(utf8_path, 'w', encoding='utf-8') as utf8_file:
            utf8_file.write(content)
        
        print(f"File re-saved in UTF-8 format at: {utf8_path}")
        return utf8_path
    except UnicodeDecodeError as e:
        print(f"Error reading file with encoding {encoding}: {e}")
        return None

def main():
    file_path = input("Enter the path to your file: ")
    encoding = detect_encoding(file_path)
    
    if encoding:
        utf8_path = read_and_save_as_utf8(file_path, encoding)
        if utf8_path:
            print("\nFile successfully converted to UTF-8.")
        else:
            print("Failed to re-save the file in UTF-8.")
    else:
        print("Could not determine encoding with sufficient confidence.")

if __name__ == "__main__":
    main()
