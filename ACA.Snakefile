import os
import sys


def extract_names():
    names = []
    directory = "input/"
    for filename in os.listdir(directory):
        if filename.endswith(".fasta"):
            # Remove ".fasta" extension and add the name to the list
            names.append(filename[:-6])
    return names


rule all:
    input:
        expand("output/weblogo/{name}.png", name=extract_names())


rule blastp:
    input:
        "input/{name}.fasta"
    output:
        "output/blast_results/{name}.txt"
    threads: 5

    shell:
        """
        #export BLASTDB=$BLASTDB:/project/bilyeu_soybean_genomic_merge/anserm/weblogos/database/
        blastp -query {input} -db /project/bilyeu_soybean_genomic_merge/anserm/weblogos/database/nr -outfmt "6 delim=  qseqid sseqid sgi sacc staxid ssciname sseq pident" -num_threads {threads} | awk '!genus_seen[$6]++ && $6 != "Glycine"' > {output}
        """

rule blast_sort:
    input:
        "output/blast_results/{name}.txt"
    output:
        "output/blast_sorted/{name}.txt"
    shell:
        """
        awk '{{ print $NF,$0 }}' {input} | sort -k1,1 -nr | cut -f2- -d$'\t' > {output}
        
        """



rule get_seq:
    input:
        "output/blast_sorted/{name}.txt"
    output:
        "output/blast_seq/{name}.fasta"
    shell:
        """

        set +e

        head -n 100 {input} | while read -r line; do entry_name=$(echo "$line" | awk '{{print $3}}'); blastdbcmd -db /project/bilyeu_soybean_genomic_merge/anserm/weblogos/database/nr -entry "$entry_name"; done > {output}
        
        exitcode=$?

        if [ $exitcode != 0 ]
        then
            touch {output}
            exit 0
        else
            exit $exitcode
        fi

        """


rule merge_seq:
    input:
        file1="output/split_fasta/{name}.fasta",
        file2="output/blast_seq/{name}.fasta"
    output:
        "output/complete_seq/{name}.fasta"
    shell:
        """
        cat {input.file1} {input.file2}  > {output}
        """


rule msa:
    input:
        "output/complete_seq/{name}.fasta"
    output:
        "output/msa_results/{name}.fa"
    shell:
        """
        set +e
        
        clustalo -i {input} --infmt=a2m=fa -o {output} -v
        
        exitcode=$?
        if [ $exitcode != 0 ]
        then
            touch {output}
            exit 0
        else
            exit $exitcode
        fi
        """



rule process:
    input:
        "output/msa_results/{name}.fa"
    output:
        "output/processed_msa/{name}.fa"
    shell:
        """
        set -euo pipefail
        python scripts/process_fasta.py {input} {output} || touch {output}
        """


rule ncbi_format:
    input:
        "output/split_fasta/{name}.fasta"
    output:
        "output/ncbi_format/{name}.txt"
    shell:
        """
        set -euo pipefail
        python scripts/ncbi_format.py {input} {output} || touch {output}
        """


rule weblogo:
    input:
        "output/processed_msa/{name}.fa"
    output:
        file1="output/coordinates/{name}.txt",
        file2="output/weblogo/{name}.png"
    shell:
        """
        set +e

        input_b=$(basename {input} .fa)
        input_b_no_ext=${{input_b%.fa}}
        result="$(sed -n '2p' {input} | awk 'BEGIN {{FS=""; OFS=","; count=1}} {{for (i=1;i<=NF;i++) {{$i = ($i == "-") ? "-" : count++;}}}} 1' | awk 'BEGIN {{FS=","; OFS=","}} {{for (i=1;i<=NF;i++) {{$i = ($i == "-" || ($i % 5 == 0 && $i > 0)) ? $i : " ";}}}} 1')"
        echo "$result" > {output.file1}
        weblogo -D fasta --annotate "$result" -f {input} -c chemistry --title "$input_b_no_ext" --errorbars NO --resolution 600 -F png -o {output.file2}

        exitcode=$?
        if [ $exitcode != 0 ]
        then
            touch {output.file1}
            touch {output.file2}
            exit 0
        else
            exit $exitcode
        fi

        """
