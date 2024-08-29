import os
import sys

def find_long_lines(file_path, max_length=512, crop_length=250):
    """
    Finds lines longer than max_length and prints the first crop_length characters of each.

    :param file_path: Path to the text file to be checked.
    :param max_length: The maximum length of a line to check for. Default is 512 characters.
    :param crop_length: The number of characters to show from the start of long lines. Default is 50 characters.
    """
    if not os.path.isfile(file_path):
        print(f"File not found: {file_path}")
        return

    try:
        with open(file_path, 'r') as file:
            for line_number, line in enumerate(file, 1):
                if len(line) > max_length:
                    cropped_line = line[:crop_length]
                    print(f"Line {line_number} exceeds {max_length} characters: {cropped_line}...")
    except Exception as e:
        print(f"An error occurred while processing the file: {e}")

if __name__ == "__main__":
    # Ensure correct number of arguments
    if len(sys.argv) != 3:
        print("Usage: python find_long_lines.py <file_path> <symbol_threshold>  ")
        sys.exit(1)

    try:
        # Parse command-line arguments
        file_path = sys.argv[1]
        symbol_threshold = int(sys.argv[2])  # Convert threshold to an integer

        # Call the find_long_lines function with the provided arguments
        find_long_lines(file_path, max_length=symbol_threshold)
    except ValueError:
        print("The symbol threshold must be an integer.")
        sys.exit(1)
    except Exception as e:
        print(f"Unexpected error: {e}")
        sys.exit(1)
