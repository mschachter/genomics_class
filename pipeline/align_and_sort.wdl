# based on code from: https://www.rc.virginia.edu/userinfo/howtos/rivanna/wdl-bioinformatics/

workflow bwa_mem {
    String sample_name
    File r1fastq
    File r2fastq
    File ref_fasta
    File ref_fasta_amb
    File ref_fasta_sa
    File ref_fasta_bwt
    File ref_fasta_ann
    File ref_fasta_pac
    
    call align {
        input:
            sample_name = sample_name,
            r1fastq = r1fastq,
            r2fastq = r2fastq,
            ref_fasta = ref_fasta,
            ref_fasta_amb = ref_fasta_amb,
            ref_fasta_sa = ref_fasta_sa,
            ref_fasta_bwt = ref_fasta_bwt,
            ref_fasta_ann = ref_fasta_ann,
            ref_fasta_pac = ref_fasta_pac
    }
    
    #call sort_bam {
    #    input:
    #        sample_name = sample_name,
    #        in_bam = align.out_bam
    #}
}

# Alignment task: use bwa mem to align paired reads, output to bam file
task align {
    String sample_name
    File r1fastq
    File r2fastq
    File ref_fasta
    File ref_fasta_amb
    File ref_fasta_sa
    File ref_fasta_bwt
    File ref_fasta_ann
    File ref_fasta_pac
    Int threads
    command {
        /usr/gitc/bwa mem -M -t ${threads} ${ref_fasta} ${r1fastq} ${r2fastq} > ${sample_name}.sam
    }
    runtime {
        cpu: threads
        memory: "32G"
        docker: "us.gcr.io/broad-gotc-prod/genomes-in-the-cloud:2.4.7-1603303710"
        disks: "local-disk 100 SSD"
    }
    output {
        File out_bam = "${sample_name}.sam"
    }
}

## 2. This task will sort bam file by coordinate and create an index
task sort_bam {
    String sample_name
    File insam
    command <<<
        java -jar $EBROOTPICARD/picard.jar \
            SortSam \
            I=${insam} \
            O=${sample_name}.hg38-bwamem.sorted.bam \
            SORT_ORDER=coordinate \
            CREATE_INDEX=true
    >>>
    output {
        File outbam = "${sample_name}.hg38-bwamem.sorted.bam"
        File outbamidx = "${sample_name}.hg38-bwamem.sorted.bai"
    }
}

