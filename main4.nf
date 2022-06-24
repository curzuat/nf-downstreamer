Channel
    .fromPath(params.coreg_table)
    .splitCsv(header:true)
    .map{ row-> tuple(row.coreg_id, row.coregulation_model) }
    .set { prep_coregulation_model_in }

process prep_coregulation_model {

    publishDir "$params.bundle_dir/coreg_models/$datasetID/", mode: 'copy', saveAs: { filename -> "$filename" }
    
    input:
    tuple datasetID, decomposition from prep_coregulation_model_in

    output:
    path 'coregulation*'
    
    """
    java -Xmx${params.mem_step2 -16}g -Xms${params.mem_step2 -16}g -XX:ParallelGCThreads=2 \
    --mode CONVERT_TXT \
    --gwas $decomposition
    --output dummy

    java -Xmx${params.mem_step2 -16}g -Xms${params.mem_step2 -16}g -XX:ParallelGCThreads=2 \
    --mode CORRELATE_GENES \
    --gwas dummy \
    --corZscore \
    --normalizeEigenvectors \
    --genes $params.reference_ensembl\
    --output coregulation
    """

}