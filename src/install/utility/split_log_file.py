import os
import sys
import datetime
import logging
import tarfile

# Configure logging to console only
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[logging.StreamHandler(sys.stdout)]
)


def create_output_folder(base_folder):
    try:
        # Create a unique subfolder based on the current date and time
        timestamp = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
        output_folder = os.path.join(base_folder, timestamp)

        # Ensure the subfolder exists
        os.makedirs(output_folder, exist_ok=True)
        logging.info(f"Created output folder: {output_folder}")

        return output_folder
    except Exception as e:
        logging.error(f"Failed to create output folder {base_folder}: {e}")
        sys.exit(1)


def split_log_file_by_lines(file_path, lines_per_file, output_folder):
    try:
        with open(file_path, 'r') as f:
            base_name = os.path.basename(file_path)
            name, ext = os.path.splitext(base_name)

            for i, line in enumerate(f):
                if i % lines_per_file == 0:
                    output_file = os.path.join(output_folder, f"{name}_part_{i // lines_per_file + 1}{ext}")
                    out = open(output_file, 'w')
                    logging.info(f"Creating new split file: {output_file}")
                out.write(line)
            out.close()
            logging.info(f"Finished splitting file by lines: {file_path}")
    except Exception as e:
        logging.error(f"Failed to split file by lines: {e}")
        sys.exit(1)


def split_log_file_by_size(file_path, size_per_file_mb, output_folder):
    try:
        size_per_file = size_per_file_mb * 1024 * 1024  # Convert MB to bytes
        with open(file_path, 'r') as f:
            base_name = os.path.basename(file_path)
            name, ext = os.path.splitext(base_name)

            current_size = 0
            part_num = 1
            output_file = os.path.join(output_folder, f"{name}_part_{part_num}{ext}")
            out = open(output_file, 'w')
            logging.info(f"Creating new split file: {output_file}")

            for line in f:
                out.write(line)
                current_size += len(line.encode('utf-8'))  # Calculate the size of the line in bytes

                if current_size >= size_per_file:
                    out.close()
                    part_num += 1
                    output_file = os.path.join(output_folder, f"{name}_part_{part_num}{ext}")
                    out = open(output_file, 'w')
                    logging.info(f"Creating new split file: {output_file}")
                    current_size = 0

            out.close()
            logging.info(f"Finished splitting file by size: {file_path}")
    except Exception as e:
        logging.error(f"Failed to split file by size: {e}")
        sys.exit(1)


def create_tar_archive(output_folder, base_folder):
    try:
        tar_file = os.path.join(base_folder, f"{os.path.basename(output_folder)}.tar.gz")
        with tarfile.open(tar_file, "w:gz") as tar:
            tar.add(output_folder, arcname=os.path.basename(output_folder))
        logging.info(f"Created tar.gz archive: {tar_file}")
    except Exception as e:
        logging.error(f"Failed to create tar.gz archive: {e}")
        sys.exit(1)


def split_log_file(file_path, mode, value, output_base_folder='.'):
    try:
        if not os.path.exists(file_path):
            logging.error(f"The file does not exist: {file_path}")
            sys.exit(1)

        output_folder = create_output_folder(output_base_folder)

        if mode == 'lines':
            split_log_file_by_lines(file_path, value, output_folder)
        elif mode == 'mb':
            split_log_file_by_size(file_path, value, output_folder)
        else:
            logging.error(f"Invalid mode: {mode}. Use 'lines' to split by lines or 'mb' to split by size in megabytes.")
            sys.exit(1)

        # Print the resulting output folder
        logging.info(f"Output folder with split files: {output_folder}")

        # Create tar.gz archive of the output folder
        create_tar_archive(output_folder, output_base_folder)

    except Exception as e:
        logging.error(f"Failed to split the log file: {e}")
        sys.exit(1)


if __name__ == "__main__":
    # Ensure correct number of arguments
    if len(sys.argv) < 4 or len(sys.argv) > 5:
        logging.error("Usage: python split_log.py <file_path> <mode: 'lines' or 'mb'> <value> [<output_base_folder>]")
        sys.exit(1)

    try:
        # Parse command-line arguments
        log_file_path = sys.argv[1]
        mode = sys.argv[2]
        value = int(sys.argv[3])  # Convert value to an integer

        # If output_base_folder is provided, use it; otherwise, use current directory
        output_base_folder = sys.argv[4] if len(sys.argv) == 5 else '.'

        # Call the split_log_file function with the provided arguments
        split_log_file(log_file_path, mode, value, output_base_folder)
    except ValueError:
        logging.error("The value parameter must be an integer.")
        sys.exit(1)
    except Exception as e:
        logging.error(f"Unexpected error: {e}")
        sys.exit(1)
