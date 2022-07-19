gwas = Channel
    .fromPath(params.gwas_table)
    .splitCsv(header:true)
    .map{ row-> tuple(row.gwasID) }

Channel
    .fromPath(params.coreg_table)
    .splitCsv(header:true)
    .map{ row-> tuple(row.coreg_id) }
    .combine(gwas)
//    .view()
    .set { downstreamer_step2_in }


process downstreamer_step2 {

    publishDir "$params.bundle_dir_scratch/step2/$coregID/$datasetID/", mode: 'copy', saveAs: { filename -> "$filename" }
    
    input:
    tuple coregID, datasetID from downstreamer_step2_in

    output:
    path ('ds_step2.log')
    path ('ds_step2_enrichtments.xlsx')

    //when:
    //params.step2 != "NOT_SPECIFIED"
    
    """
        java -Xmx${params.mem_step2 -16}g -Xms${params.mem_step2 -16}g -XX:ParallelGCThreads=2 \
        -jar $params.downstreamer \
        --mode STEP2 \
        --gwas $params.bundle_dir_scratch/summary_statistics/binary_matrix/$datasetID/pvalue \
        --referenceGenotypes $params.reference_genotypes \
        --stepOneOutput $params.bundle_dir_scratch/step1/$datasetID/ds_step1 \
        --pathwayDatabase $coregID=$params.bundle_dir_scratch/coreg_models/$coregID/coregulation \
        --genes $params.reference_ensembl \
        --genePruningR $params.gene_pruning \
        --geneCorrelationWindow $params.gene_cor_window \
        --permutationFDR $params.permutation_fdr \
        --permutationGeneCorrelations $params.permutation_genecor \
        --permutationPathwayEnrichment $params.permutation_pathway \
        --threads ${params.cores_step2 -2} \
        $params.miscelaneous_step2 \
        --output ds_step2
    """

}