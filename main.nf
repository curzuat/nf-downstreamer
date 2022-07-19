Channel
    .fromPath(params.gwas_table)
    .splitCsv(header:true)
    .map{ row-> tuple(row.gwasID) }
    .set { downstreamer_step1_in }

//Channel
//                .fromPath(params.gwas_dir)
//                .map { x -> tuple(x.baseName) }
//      .set { downstreamer_step1_in }

process downstreamer_step1 {

    publishDir "$params.bundle_dir_scratch/step1/$datasetID/", mode: 'copy', saveAs: { filename -> "$filename" }
    
    input:
    tuple datasetID from downstreamer_step1_in

    output:
    path 'ds_step1*'
    
    """
        java -Xmx${params.mem_step1 -16}g -Xms${params.mem_step1 -16}g -XX:ParallelGCThreads=2 \
        -jar $params.downstreamer \
        --mode STEP1 \
        --gwas $params.bundle_dir_scratch/summary_statistics/binary_matrix/$datasetID/pvalue \
        --genes $params.reference_ensembl \
    --genePruningR $params.gene_pruning \
        --referenceGenotypes $params.reference_genotypes \
        --referenceSamples $params.reference_samples \
        --referenceGenotypeFormat $params.reference_type \
        --variantCorrelation $params.variant_pruning \
        --window $params.gene_window \
        --permutations $params.permutations \
        --permutationFDR $params.permutation_fdr \
        --permutationGeneCorrelations $params.permutation_genecor \
        --permutationPathwayEnrichment $params.permutation_pathway \
        --permutationsRescue $params.permutation_rescue \
    --threads ${params.cores_step1 -2} \
        $params.miscelaneous \
        --output ds_step1
    """

}