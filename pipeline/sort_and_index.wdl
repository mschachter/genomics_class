# based on code from: https://www.rc.virginia.edu/userinfo/howtos/rivanna/wdl-bioinformatics/

workflow sort_and_index {
    String sample_name
    File sam
    Int threads
    
    call sort_sam {
        input:
            sample_name = sample_name,
            in_sam = sam
            threads = threads
    }
}

task sort_sam {
    String sample_name
    File in_sam
    Int threads
    command <<<
        java -jar /usr/gitc/picard.jar \
            SortSam \
            I=${in_sam} \
            O=${sample_name}.hg38-bwamem.sorted.bam \
            SORT_ORDER=coordinate \
            CREATE_INDEX=true
    >>>
    runtime {
        cpu: threads
        memory: "32G"
        docker: "us.gcr.io/broad-gotc-prod/genomes-in-the-cloud:2.4.7-1603303710"
        disks: "local-disk 100 SSD"
    }
    output {
        File out_bam = "${sample_name}.hg38-bwamem.sorted.bam"
        File out_bam_index = "${sample_name}.hg38-bwamem.sorted.bai"
    }
}

