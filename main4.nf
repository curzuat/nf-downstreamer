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
    pth 'coregulation*'
    
    """
    java -Xmx${params.mem_coreg -16}g -Xms${params.mem_coreg -16}g -XX:ParallelGCThreads=2 \
    -jar $params.downstreamer \
    --mode CONVERT_TXT \
    --gwas $decomposition \
    --output dummy

    java -Xmx${params.mem_coreg -16}g -Xms${params.mem_coreg -16}g -XX:ParallelGCThreads=2 \
    -jar $params.downstreamer \
    --mode CORRELATE_GENES \
    --gwas dummy \
    --corZscore \
    --normalizeEigenvectors \
    --genes $params.reference_ensembl \
    --output coregulation
    """

}