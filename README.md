
# Microsoft Fabric End-to-End Data Pipeline: Medallion Architecture

This repository contains the implementation of an end-to-end data engineering pipeline built entirely within **Microsoft Fabric**. Utilizing a Medallion Architecture, the project automates ingestion into a unified OneLake SaaS foundation, applies robust data quality transformations, and models the final serving layer into a high-performance Star Schema.

## 🚀 Fabric Architecture Overview

The pipeline leverages Microsoft Fabric's unified workspace components to move data seamlessly through three distinct layers:

### 1. 🥉 Bronze Layer (Raw Ingestion)
* **Fabric Component:** Lakehouse / Files
* **Mechanism:** Data is ingested from an external SQL Server via a dynamic, **metadata-driven Data Factory pipeline**.
* **Output:** 10 raw delta tables/files landed in their native format, preserving history.

### 2. 🥈 Silver Layer (Enrichment & Quality)
* **Fabric Component:** Lakehouse / Tables
* **Processing:** Handled via Fabric Notebooks (PySpark) or Dataflows Gen2 to cleanse, deduplicate, and standardize the raw data.
* **Quality Gates:** Applied data quality rules and appended system audit columns to ensure complete data lineage.
* **Output:** 5 cleaned and optimized Delta tables.

### 3. 🥇 Gold Layer (Analytical Modeling)
* **Fabric Component:** Synapse Data Warehouse / Semantic Model
* **Design:** Structured using a optimized **Star Schema** to enable lightning-fast **DirectLake** reporting in Power BI without data duplication.
* **Output:** 3 Dimension tables and 1 Fact table.

---

## 📊 Gold Layer Schema Design

The final data warehouse layer is modeled for optimal semantic performance:


```
┌─────────────────┐
│  dim_Customer   │
└────────┬────────┘
│ 1
│
│ *
┌────────┴────────┐         ┌─────────────────┐
│   fact_Sales    │*───────1│   dim_Product   │
└────────┬────────┘         └─────────────────┘
│ *
│
│ 1
┌────────┴────────┐
│    dim_Date     │
└─────────────────┘
```

### Managed Tables
* **Fact Table:** `fact_Sales`
* **Dimension Tables:**
  * `dim_Customer`
  * `dim_Product`
  * `dim_Date`

---

## 🔍 Verification & Testing

To quickly verify that the data has processed correctly through the Fabric pipeline into your Gold warehouse, you can execute this query using the Fabric SQL connection string or the built-in SQL query editor:

```sql
SELECT TOP 10 * FROM gold_fact_Sales;

```
## 🛠️ Microsoft Fabric Tech Stack
 * **Storage Foundation:** OneLake (Delta Parquet format)
 * **Orchestration:** Fabric Data Factory Pipelines (Metadata-driven)
 * **Transformation & Compute:** Fabric