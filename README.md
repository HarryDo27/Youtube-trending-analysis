# Data Lakehouse with Snowflake  

##  Project Overview  
This project implements a **Data Lakehouse architecture** on **Snowflake** using YouTube Trending Video data. The aim is to ingest, clean, transform, and analyse large-scale datasets (CSV + JSON) stored on Microsoft Azure, while delivering both **analytical insights** and a **business recommendation**.  

Dataset: [YouTube Trending Video Dataset](https://www.kaggle.com/rsrishav/youtube-trending-video-dataset)  
Period: **2020-08-12 → 2024-04-15**  
Regions: **IN, US, GB, DE, CA, FR, BR, MX, KR, JP**  

---

## Tech Stack & Tools  
- **Snowflake** – Data Lakehouse, SQL transformations  
- **Microsoft Azure Storage** – Cloud data storage and staging  
- **SQL** – Data ingestion, cleaning, and analysis  
- **UUID Functions & Row Numbering** – Deduplication and unique identifiers  
- **Data Formats** – CSV, JSON  

---

## Project Structure  
- **part_1.sql** → Data ingestion and table creation (external tables, staging, final combined table)  
- **part_2.sql** → Data cleaning and deduplication (handling NULLs, duplicates, integrity checks)  
- **part_3.sql** → Data analysis queries (most viewed videos, likes ratio, category trends, channel performance)  
- **part_4.sql** → Business question queries (category recommendations for new YouTube channels)  
- **Report.pdf / Report.docx** → Handover report with explanations, screenshots, answers, and business recommendation  

---

## Key Steps  

### 1. Data Ingestion  
- Uploaded CSV and JSON files to **Azure Blob Storage**  
- Created Snowflake database `assignment_1` and stage `stage_assignment`  
- Built external tables `ex_table_youtube_trending` and `ex_table_youtube_category`  
- Loaded into structured tables `table_youtube_trending`, `table_youtube_category`  
- Combined into `table_youtube_final` with **UUID identifiers** → **2,667,041 rows**  

### 2. Data Cleaning  
- Identified duplicate category titles across countries  
- Found category titles appearing in only one region  
- Replaced NULL category titles with correct mappings  
- Removed invalid records (e.g., video_id = `#NAME?`)  
- Deduplicated by keeping **highest view_count per video/country/date**  
- Final row count → **2,597,494 rows**  

### 3. Data Analysis  
- Retrieved **top 13 most viewed Gaming videos** per country (2024-04-01)  
- Counted distinct “BTS” videos per country  
- Identified **most viewed videos per year-month-country** with calculated **likes ratio**  
- Found most common categories by distinct video count (pre-2022)  
- Determined channel with **highest number of distinct videos ×10**  

### 4. Business Recommendation  
- Recommended **“Gaming” category** for launching a new YouTube channel in the US (excluding Music & Entertainment).  
- Highlighted that results vary by region → strategy should be adapted per country.  

---

## Deliverables  
- `part_1.sql` → Data ingestion  
- `part_2.sql` → Data cleaning  
- `part_3.sql` → Data analysis  
- `part_4.sql` → Business queries  

 
