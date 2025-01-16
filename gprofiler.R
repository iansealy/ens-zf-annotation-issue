#!/usr/bin/env Rscript

suppressPackageStartupMessages(suppressWarnings(library(tidyverse)))
suppressPackageStartupMessages(suppressWarnings(library(gprofiler2)))

options(width = 120)

genes <- read_lines("sig-gene-list.txt")

urls = c(
    "http://biit.cs.ut.ee/gprofiler_archive3/e109_eg56_p17",
    "http://biit.cs.ut.ee/gprofiler_archive3/e110_eg57_p18",
    "http://biit.cs.ut.ee/gprofiler"
)

pdf(NULL)
version <- 108
for (url in urls) {
    version <- version + 1
    set_base_url(url)
    query <- list(genes)
    names(query) <- paste("Ensembl", version, sep=" ")
    gostres <- gost(query=query, organism="drerio", sources="GO")
    print(c(gostres$meta$version, nrow(gostres$result)))
    print(gostres$result[c("term_id", "term_name")])
    p <- gostplot(gostres, capped=FALSE, interactive=FALSE)
    pngname <- paste0("gprofiler", version, ".png")
    publish_gostplot(p, highlight_terms=gostres$result[1:10, "term_id"], 
        width=NA, height=NA, filename=pngname)
}
