# scripts/split_fasta.py

import os
def split_fasta(input_file, output_directory="split_fasta"):
    os.makedirs(output_directory, exist_ok=True)
    
    with open(input_file, 'r') as infile:
        lines = infile.readlines()

        current_sequence = ''
        current_header = None

        for line in lines:
            if line.startswith('>'):
                if current_header is not None and '1.p' in current_header and 'Glyma.1' in current_header:
                    # Write the current sequence to a new file
                    output_filename = os.path.join(output_directory, f"{current_header.strip()[1:16]}.fasta")
                    with open(output_filename, 'w') as outfile:
                        outfile.write(current_header)
                        outfile.write(current_sequence + '\n')

                current_header = line
                current_sequence = ''
            else:
                current_sequence += line.strip()

        # Check if the last header contains "1.p" and write to a new file
        if current_header is not None and '1.p' in current_header and 'Glyma.1' in current_header:
            output_filename = os.path.join(output_directory, f"{current_header.strip()[1:16]}.fasta")
            with open(output_filename, 'w') as outfile:
                outfile.write(current_header)
                outfile.write(current_sequence + '\n')


