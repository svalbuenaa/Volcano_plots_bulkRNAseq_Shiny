# Volcano Plot Generator (Shiny App)

This Shiny web application allows you to easily generate customizable volcano plots from your bulk-RNAseq Differential Expression Gene (DEG) analysis data. Simply upload your CSV file, set your desired thresholds, and customize the plot's appearance.

---

### Features

* **Interactive Upload**: Upload your DEG analysis results in a `.csv` format.
* **Customizable Thresholds**: Adjust p-value and log2FoldChange thresholds to define significantly expressed genes.
* **Dynamic Plotting**: Instantly visualize changes with an interactive volcano plot.
* **Plot Customization**:
    * Set a custom plot title.
    * Choose from a variety of `ggplot2` themes.
* **Download Options**: Save your generated volcano plot in multiple formats (PNG, JPG, PDF, EPS, TIFF, BMP, SVG) with customizable dimensions.

---

### How to Use

1.  **Launch the App**:
    If you have R and Shiny installed, you can run this application directly from your R environment:

    ```R
    library(shiny)
    runApp() # Point this to the directory containing app.R
    ```

    Alternatively, you can deploy it to a Shiny server.

2.  **Upload Your Data**:
    Click on "Choose CSV File with DEG analysis" in the sidebar. Select your CSV file. **Your CSV file must contain the following columns (case-sensitive):**
    * `Gene`: Gene names or identifiers.
    * `padj`: Adjusted p-values (e.g., FDR, BH-adjusted p-values).
    * `log2FoldChange`: Log2 fold change values.

3.  **Set Thresholds**:
    Enter your desired **p-value** threshold (default: `0.05`). Make sure that all p-values in the padj column, as well as your selected padj threshold, are numeric
    Enter your desired **log2FoldChange** threshold (default: `2`). Make sure that all Fold change values in the log2FoldChange column, as well as your selected log2FoldChange threshold, are numeric

4.  **Customize Plot (Optional)**:
    Provide a **Plot title** in the designated text box.
    Select a **Plot theme** from the dropdown menu to change the visual style of your plot.

5.  **Download Your Plot**:
    Specify the **Plot width** and **Plot height** in inches.
    Choose your preferred **Save format** (e.g., PNG, PDF).
    Click the "Download" button to save the plot to your local machine.

---

### Requirements

This Shiny app requires the following R packages:

* `shiny`
* `tidyverse`

You can install them using the following commands in R:

```R
install.packages("shiny")
install.packages("tidyverse")
```


# Understanding Volcano Plots and Differential Gene Expression

This section provides a curated list of resources to help you understand the concepts behind volcano plots and differential gene expression analysis, including adjusted p-values and log2 fold change.

---

## What is a Volcano Plot?

A volcano plot is a type of scatter plot that is commonly used to visualize the results of differential expression analysis, such as from RNA-seq experiments. It helps in quickly identifying genes that are both significantly differentially expressed and have a large magnitude of change.

* **X-axis (Log2 Fold Change)**: Represents the magnitude of gene expression change between two conditions.
* **Y-axis (-log10(Adjusted P-value))**: Represents the statistical significance of the change. The negative logarithm is used so that smaller p-values (more significant) appear higher on the plot.

### Learn more about Volcano Plots:

* **RNA-Seq Blog: Tutorial – visualization of rna-seq results with volcano plot**: A straightforward introduction to volcano plots and their interpretation.
    * [Link](https://www.rna-seqblog.com/tutorial-visualization-of-rna-seq-results-with-volcano-plot/)

---

## Understanding Log2 Fold Change (Log2FC)

Log2 Fold Change quantifies the magnitude of expression difference between two conditions. Taking the logarithm (base 2) of the fold change makes the data more symmetrical and easier to interpret, especially for visualization tools like volcano plots.

* A Log2FC of 1 means the gene expression doubled.
* A Log2FC of -1 means the gene expression halved.
* A Log2FC of 0 means no change in expression.

### Learn more about Log2 Fold Change:

* **OlvTools: What is fold change? What is logFC?**: Explains fold change and logFC with simple examples.
    * [Link](https://olvtools.com/en/rnaseq/help/fold-change)

---

## Understanding Adjusted P-values

When performing differential expression analysis, you are conducting thousands of statistical tests (one for each gene). This increases the likelihood of false positives by chance (the "multiple testing problem"). Adjusted p-values (often called q-values or False Discovery Rate - FDR) account for this by controlling the expected proportion of false discoveries among the genes identified as significant.

### Learn more about Adjusted P-values:

* **Medium: Why should we report adjusted p-values in differential expression analysis?**: A comprehensive explanation of why adjusted p-values are necessary and how they differ from raw p-values.
    * [Link](https://medium.com/@tylergenegross97/why-should-we-report-adjusted-p-values-in-differential-expression-analysis-1390d5d548d9)

---

## Learn more about Interpreting DEG Analysis Results

* **Bioconductor RNA-seq Workflow: Gene-level exploratory analysis and differential expression**: A detailed workflow using popular R/Bioconductor packages for RNA-seq analysis.
    * [Link](https://master.bioconductor.org/packages/release/workflows/vignettes/rnaseqGene/inst/doc/rnaseqGene.html)

---