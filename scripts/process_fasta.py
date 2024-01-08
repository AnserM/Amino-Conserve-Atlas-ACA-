def process_lines(input_file, output_file):
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
            lines = infile.readlines()

            #############fix the new line separations in the blast output fasta and save as a list##########
            cleaned_data = []
            current_sequence = ''
            current_header = None
            for line in lines:
                if line.startswith('>'):
                    if current_header is not None:
                        cleaned_data.append(current_header)
                        cleaned_data.append(current_sequence)
                    current_header = line
                    current_sequence = ''
                else:
                    current_sequence += line.strip()

            if current_header is not None:
                cleaned_data.append(current_header)
                cleaned_data.append(current_sequence)

            #############get the number of leading and trailing dashes in the query sequence############
            first_sequence = ''

            first_sequence = cleaned_data[1]
            leading_dashes = len(first_sequence) - len(first_sequence.lstrip('-'))
            trailing_dashes = len(first_sequence) - len(first_sequence.rstrip('-'))

            ############remove that the leading and trailing dashes from all sequences##############

            for i, line in enumerate(cleaned_data):
                if i % 2 == 1 and trailing_dashes != 0:
                    modified_line = line[leading_dashes:-trailing_dashes]
                    outfile.write(modified_line + '\n')
                elif i % 2 == 1 and trailing_dashes == 0: 
                    modified_line = line[leading_dashes:]
                    outfile.write(modified_line + '\n')
                else:
                    outfile.write(line)
                

# Command-line execution
if __name__ == "__main__":
    import sys

    if len(sys.argv) != 3:
        print("Usage: python process_fasta.py input_file output_file")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]

    process_lines(input_file, output_file)
