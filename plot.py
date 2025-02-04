#!/usr/bin/env python
"""Plot summary graphs."""

import pandas as pd
import seaborn.objects as so

summary = pd.read_table("annotation-summary.tsv")
plot = (
    so.Plot(summary, x="Ensembl Version", y="Gene Count", color="Annotated To")
    .add(so.Bar(), so.Dodge())
    .label(title="Number of Annotated Genes by Ensembl Version")
)
plot.save("annotation-summary.png", bbox_inches="tight")

summary = pd.read_table("source-summary.tsv")
plot = (
    so.Plot(summary, x="Ensembl Version", y="Gene Count", color="Source")
    .add(so.Bar(), so.Stack())
    .label(title="Source of Gene Names by Ensembl Version")
)
plot.save("source-summary.png", bbox_inches="tight")

summary = pd.read_table("same-name-summary.tsv")
plot = (
    so.Plot(summary, x="Ensembl Version", y="Gene Count")
    .add(so.Bar())
    .label(title="Number of Genes With Same Name As In Ensembl 108")
)
plot.save("same-name-summary.png", bbox_inches="tight")

summary = pd.read_table("gprofiler-go-summary.tsv")
plot = (
    so.Plot(summary, x="Ensembl Version", y="Gene Count")
    .add(so.Bar())
    .scale(x=so.Continuous().tick(every=1))
    .label(title="Number of Genes With GO Terms Annotated In g:Profiler")
)
plot.save("gprofiler-go-summary.png", bbox_inches="tight")
