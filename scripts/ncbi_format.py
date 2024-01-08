def ncbi_format(input_file, output_file, line_interval=60, chars_per_group=10):
    try:
        with open(input_file, 'r') as file:
            # Read the second line from the file
            lines = file.readlines()
            if len(lines) < 2:
                raise ValueError("File must have at least two lines.")

            input_str = lines[1].strip()

        formatted_lines = []
        for i in range(0, len(input_str), line_interval):
            groups = [input_str[j:j + chars_per_group] for j in range(i, min(i + line_interval, len(input_str)), chars_per_group)]
            formatted_line = f"{i + 1:6d} {' '.join(groups)}"
            formatted_lines.append(formatted_line)

        formatted_text = '\n'.join(formatted_lines)

        # Save the formatted text to the output file
        with open(output_file, 'w') as outfile:
            outfile.write(formatted_text)

        print(f"Formatted text saved to {output_file_path}")
    except Exception as e:
        print(f"An error occurred: {e}")



# Command-line execution
if __name__ == "__main__":
    import sys

    if len(sys.argv) != 3:
        print("Usage: python process_fasta.py input_file output_file")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]

    ncbi_format(input_file, output_file, line_interval=60, chars_per_group=10)
