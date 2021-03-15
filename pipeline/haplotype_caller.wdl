
workflow haplotype_caller {
    String sample_name
    File ref_fasta
    File ref_fasta_fai
    File ref_fasta_dict
    File bam
    Int threads
    
    call haplotype_caller_bam {
        input:
            sample_name = sample_name,
            in_bam = bam,
            ref_fasta = ref_fasta,
            ref_fasta_fai = ref_fasta_fai,
            ref_fasta_dict = ref_fasta_dict,
            threads = threads
    }
}

task haplotype_caller_bam {
    String sample_name
    File in_bam
    File ref_fasta
    File ref_fasta_fai
    File ref_fasta_dict
    Int threads
    command <<<
        /usr/gitc/gatk --java-options "-Xmx8g" HaplotypeCaller \
            -R ${ref_fasta} \
            -I ${in_bam} \
            -O ${sample_name}.vcf \
            --seconds-between-progress-updates 60 \
  	    --native-pair-hmm-threads ${threads}
    >>>
    runtime {
        cpu: threads
        memory: "32G"
        docker: "us.gcr.io/broad-gotc-prod/genomes-in-the-cloud:2.4.7-1603303710"
        disks: "local-disk 100 SSD"
    }
    output {
        File out_vcf = "${sample_name}.vcf"
    }
}

