# 🏭 AdventureWorksLT — Microsoft Fabric End-to-End Data Engineering Pipeline

> A production-grade Medallion Architecture built on Microsoft Fabric, demonstrating enterprise-level data engineering patterns from on-premises ingestion to Power BI reporting.

---

## 📌 Project Summary

This project implements a complete **Bronze → Silver → Gold medallion architecture** on **Microsoft Fabric** using the AdventureWorksLT dataset as the source. It simulates a real-world hybrid cloud data engineering scenario where data flows from an on-premises SQL Server database to a cloud-native analytics platform.

The pipeline ingests 10 business tables, applies data quality transformations, builds a star schema for analytics, and delivers insights through a Power BI report — all following industry-standard patterns used in production environments.

---

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                    SOURCE LAYER                                   │
│         SQL Server (Local) — AdventureWorksLT2025                │
│         10 SalesLT tables (Customer, Product, Orders...)         │
└─────────────────────┬────────────────────────────────────────────┘
                      │
                      │ On-Premises Data Gateway
                      ▼
┌──────────────────────────────────────────────────────────────────┐
│                    BRONZE LAYER                                   │
│         lh_bronze_adventureworks (Fabric Lakehouse)              │
│         Metadata-driven pipeline: Lookup → ForEach → Copy        │
│         10 Delta tables ingested dynamically                     │
│         Raw data preserved as-is (no transformations)           │
└─────────────────────┬────────────────────────────────────────────┘
                      │
                      │ SQL Analytics Endpoint (T-SQL Views)
                      ▼
┌──────────────────────────────────────────────────────────────────┐
│                    SILVER LAYER                                   │
│         5 SQL Views with data quality transformations            │
│         ✔ Null checks & business rule filtering                 │
│         ✔ Data type casting (datetime → date)                   │
│         ✔ Derived columns (FullName, TotalAmount, LineTotal)    │
│         ✔ Audit columns (ingestion_timestamp, source_system)    │
└─────────────────────┬────────────────────────────────────────────┘
                      │
                      │ SQL Views — Star Schema Design
                      ▼
┌──────────────────────────────────────────────────────────────────┐
│                    GOLD LAYER                                     │
│         Star Schema optimized for BI consumption                 │
│         ✔ gold_dim_Customer                                     │
│         ✔ gold_dim_Product (joined with ProductCategory)        │
│         ✔ gold_dim_Date (with Year, Month, Quarter, FiscalYear) │
│         ✔ gold_fact_Sales (grain: one order line item)          │
└─────────────────────┬────────────────────────────────────────────┘
                      │
                      │ Power BI Semantic Model
                      ▼
┌──────────────────────────────────────────────────────────────────┐
│                    REPORTING LAYER                                │
│         sm_gold_adventureworks (Semantic Model)                  │
│         rpt_adventureworks_sales (Power BI Report)               │
│         ✔ Sales by Month (Line Chart)                           │
│         ✔ Sales by Product Category (Bar Chart)                 │
│         ✔ Top Customers by Sales (Table Visual)                 │
└──────────────────────────────────────────────────────────────────┘
```

---

## 🛠️ Tech Stack

| Component | Technology |
|-----------|-----------|
| Source Database | SQL Server (Local), AdventureWorksLT2025 |
| Cloud Connectivity | Microsoft Fabric On-Premises Data Gateway |
| Ingestion | Fabric Data Pipeline (Lookup + ForEach + Copy Data) |
| Storage Format | Delta Lake (Parquet + Transaction Log) |
| Bronze Storage | Microsoft Fabric Lakehouse |
| Transformation | SQL Analytics Endpoint (T-SQL Views) |
| Semantic Model | Microsoft Fabric Power BI Semantic Model |
| Reporting | Power BI (Fabric-native) |
| Version Control | Azure DevOps + GitHub |
| Certification | Microsoft AZ-900 |

---

## 📂 Repository Structure

```
adventureworks-fabric-pipeline/
│
├── bronze/
│   └── pipeline_design.md          # Metadata-driven pipeline explanation
│
├── silver/
│   └── silver_views.sql            # All 5 Silver transformation views
│
├── gold/
│   └── gold_views.sql              # All 4 Gold star schema views
│
├── screenshots/                    # Project screenshots
│   ├── bronze_pipeline.png
│   ├── silver_views.png
│   ├── gold_schema.png
│   └── powerbi_report.png
│
└── README.md
```

---

## 🔑 Key Engineering Decisions

### 1. Metadata-Driven Bronze Ingestion
Rather than creating one Copy Activity per table (hardcoded approach), implemented a **Lookup → ForEach → parameterized Copy Data** pattern.

- **Lookup activity** queries `INFORMATION_SCHEMA.TABLES` to fetch all `SalesLT` schema tables dynamically
- **ForEach activity** iterates over each table with `@activity('lkp_get_tables').output.value`
- **Copy Data activity** uses dynamic SQL `@{concat('SELECT * FROM ', item().TABLE_SCHEMA, '.', item().TABLE_NAME)}` as source query
- Destination table name is dynamically constructed: `@{concat(item().TABLE_SCHEMA, '_', item().TABLE_NAME)}`

**Why this matters:** Adding a new source table requires zero pipeline changes — the pipeline scales automatically.

---

### 2. SQL Views for Silver and Gold Layers
Used T-SQL views via Fabric's SQL Analytics Endpoint instead of materializing data at every layer.

**Benefits:**
- New Bronze data is immediately visible in Silver and Gold — no re-run of transformation jobs needed
- Compute is only consumed when data is queried (cost-efficient)
- Views are lightweight and always reflect the latest Bronze data
- Same medallion logic as PySpark notebooks, implemented in T-SQL

---

### 3. Star Schema Design in Gold
Designed a proper **star schema** following Kimball dimensional modeling principles:

| Table | Type | Grain |
|-------|------|-------|
| `gold_fact_Sales` | Fact | One order line item |
| `gold_dim_Customer` | Dimension | One customer |
| `gold_dim_Product` | Dimension | One product (with category joined) |
| `gold_dim_Date` | Dimension | One calendar date |

Relationships defined in Power BI semantic model for optimal query performance.

---

### 4. On-Premises Data Gateway
Configured Fabric's **On-Premises Data Gateway** to establish secure connectivity between the local SQL Server and the cloud Fabric Lakehouse — the same pattern used in enterprise hybrid cloud architectures.

**Key configuration:** Enabled "Allow this connection to be used with on-premises data gateways" on the Lakehouse destination connection to support gateway-based copy activities.

---

### 5. Audit Columns for Data Lineage
Every Silver view includes:
- `ingestion_timestamp` — when the data was processed (`GETDATE()`)
- `source_system` — where the data came from (`'AdventureWorksLT2025'`)

This supports **data lineage tracking** and is a standard production practice.

---

## 📊 Tables Ingested (Bronze Layer)

| Table | Rows (approx.) | Description |
|-------|---------------|-------------|
| SalesLT_Customer | 847 | Customer master data |
| SalesLT_Address | 450 | Address information |
| SalesLT_CustomerAddress | 417 | Customer-address mapping |
| SalesLT_Product | 295 | Product catalog |
| SalesLT_ProductCategory | 41 | Product category hierarchy |
| SalesLT_ProductDescription | 762 | Multilingual product descriptions |
| SalesLT_ProductModel | 128 | Product model information |
| SalesLT_ProductModelProductDescription | 762 | Model-description mapping |
| SalesLT_SalesOrderHeader | 32 | Order headers |
| SalesLT_SalesOrderDetail | 542 | Order line items |

---

## 🔄 Silver Layer Transformations

| View | Key Transformations |
|------|-------------------|
| `silver_Customer` | FullName derived column, null CustomerID filter, audit columns |
| `silver_Product` | Business rule (ListPrice > 0), column rename, type casting |
| `silver_ProductCategory` | CategoryName rename, null filter, audit columns |
| `silver_SalesOrderHeader` | TotalAmount calculated (SubTotal + TaxAmt + Freight), date casting |
| `silver_SalesOrderDetail` | LineTotal calculated (OrderQty × UnitPrice), DiscountedLineTotal |

---

## ⭐ Gold Layer — Star Schema

```
                    gold_dim_Date
                         │
                         │ DateKey
                         ▼
gold_dim_Customer ──── gold_fact_Sales ──── gold_dim_Product
   (CustomerID)      (one order line)        (ProductID)
```

---

## 🚀 How to Run

1. Restore `AdventureWorksLT2025.bak` to a local SQL Server instance
2. Install and configure Microsoft Fabric On-Premises Data Gateway
3. Create Fabric Lakehouse: `lh_bronze_adventureworks`
4. Import and run pipeline: `pl_bronze_ingest_adventureworks`
5. Execute Silver views in SQL Analytics Endpoint
6. Execute Gold views in SQL Analytics Endpoint
7. Create Power BI semantic model on Gold views
8. Open Power BI report: `rpt_adventureworks_sales`

---

## 📝 Interview Talking Points

- *"I used a metadata-driven pipeline so adding new tables requires zero code changes — the Lookup activity dynamically discovers all SalesLT tables at runtime."*
- *"Silver views provide live transformations — any Bronze update is immediately reflected in Silver and Gold without re-running jobs."*
- *"The star schema in Gold follows Kimball dimensional modeling — fact table at grain of one order line, with conformed dimensions for Customer, Product, and Date."*
- *"I configured On-Premises Data Gateway for hybrid cloud connectivity — same pattern used in enterprise environments where source data can't move to the cloud directly."*

---

## 👤 Author

**Gagan Babbira**  
Aspiring Data Engineer | Bengaluru, India  
Microsoft AZ-900 Certified  
Skills: Microsoft Fabric · Azure · Databricks · PySpark · SQL · Delta Lake · Apache Airflow · Docker  

---

