Channel
    .fromPath(params.gwas_links)
    .splitCsv(header:true)
    .map{ row-> tuple(row.gwasID, row.link)}
    .set { download_gwas_in }


process downstreamer_download_gwas {

    publishDir "$params.bundle_dir/summary_statistics/text/", mode: 'copy', saveAs: { filename -> "${datasetID}.txt" }
    
    input:
    tuple datasetID, gwas_link from download_gwas_in

    output:
    path 'summary_statistics.txt'
    
    """
    #!/usr/bin/env Rscript
    download.file("$gwas_link", "dummy.gz", method="wget")
    gwas_id <- "$datasetID"
    library(data.table)
    m <- fread("dummy.gz")
    n <- m[,.(hm_rsid,p_value)]
    colnames(n) <- c(gwas_id,gwas_id)
    fwrite(n,"summary_statistics.txt",sep="\t")
    """

}