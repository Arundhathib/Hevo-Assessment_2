# Hevo-Assessment_2

## 🧭 Project Overview

This assignment demonstrates an end-to-end data engineering workflow, including:
- **Data modeling and ingestion** in PostgreSQL (via Docker)
- **Pipeline replication setup** using Hevo Data (logical replication)
- **Transformation and cleaning** in Snowflake using SQL

Due to tunneling restrictions, the live pipeline connection could not be demonstrated.  
However, the entire logic, transformations, and validation flow have been fully implemented and shared through SQL scripts for transparency.


---

## ⚙️ Setup Instructions

### **1. PostgreSQL Setup (Local Docker Container)**
1. Verify Docker Desktop is running.  
2. Open PowerShell (Admin) and check existing container:
   ```powershell
   docker ps

3. Connect to PostgreSQL:
```
docker exec -it hevo_pg psql -U hevo_user -d hevo_db
```
4. Inside psql, run the following scripts sequentially:
```
\i 'ddl_sql/01_create_tables.sql';
\i 'ddl_sql/02_insert_data.sql';
\i 'ddl_sql/03_create_publication.sql';
```
### **2. Hevo Data Setup (Pipeline Simulation)**
Since tunneling could not be established:
  The PostgreSQL → Hevo connection setup was tested locally but not validated externally.
  The Hevo pipeline, model, and transformation logic have been documented in this repository for reference.

### **3. Snowflake Setup (Transformation & Validation)**
1. Open Snowflake → Worksheets.
2. Replace RAW_SCHEMA in the script with your actual schema name (e.g., HEVO_DB.PUBLIC).
3. Execute:
```
\i 'transformations/10_snowflake_cleaning.sql';
```
4. Verify the final dataset:
```
SELECT * FROM final_dataset LIMIT 10;
```

### Data Transformation Flow
Step 1:
Description: Deduplicated customer records by retaining only the latest entry per customer_id based on the updated_at or created_at timestamps. Normalized email addresses to lowercase and cleaned phone numbers to a standard 10-digit numeric format.
Output: customers_dedup

Step 2:
Description: Standardized and mapped inconsistent country values (e.g., “usa”, “UnitedStates”, “IND”) to valid ISO country codes using a helper mapping table. Added a validity flag to identify invalid or incomplete customer records.
Output: customers_clean

Step 3:
Description: Cleaned and standardized order data by removing exact duplicates, replacing null or negative amounts with valid values, and converting all currencies to USD using fixed exchange rates. Handled missing currencies and ensured consistent casing for all entries.
Output: orders_clean

Step 4:
Description: Standardized product names and categories by converting to proper casing and identified inactive products (active_flag = 'N') as “Discontinued Product.”
Output: products_clean

Step 5:
Description: Joined customer, order, and product data into a unified dataset. Handled missing customer or product references by assigning placeholder values such as “Orphan Customer” or “Unknown Product.” Ensured final dataset contains all relevant enriched information for analysis.
Output: final_dataset

### Validation Queries
```
-- Verify duplicates removed
SELECT customer_id, COUNT(*) FROM customers_dedup GROUP BY customer_id HAVING COUNT(*) > 1;

-- Check orphan orders
SELECT * FROM final_dataset WHERE customer_email = 'Orphan Customer';

-- Confirm no negative or null amounts
SELECT * FROM final_dataset WHERE amount < 0 OR amount IS NULL;
```

### Assumptions

Missing or invalid email/phone → Marked as Invalid Customer
Missing country codes → Mapped using standardized ISO format
Negative amounts → Set to 0
Null amounts → Replaced with median amount per customer
Currency conversion rates:

USD = 1.00
INR = 0.012
SGD = 0.73
EUR = 1.10

### Known Issues and Workarounds
1️. Connectivity and Tunnel Validation Errors

Issue: Difficulty establishing a secure tunnel between local PostgreSQL (Docker) and Hevo.
Description:
Hevo required a publicly reachable database for validation. Multiple tunneling utilities—Ngrok, Cloudflared, LocalXpose, Loophole, and localhost.run—were tested but failed due to blocked TCP forwarding, unstable connections, or authentication mismatches.
Workaround:
All DDL, DML, and transformation scripts were verified locally and uploaded to GitHub to ensure transparency of the entire workflow.

2. Authentication and Table Discovery Errors

Issue: Hevo “Unable to connect” and “No tables found for ingestion.”
Description:
PostgreSQL credentials worked locally but failed via tunnels due to dropped TCP sessions.
Workaround:
Verified table presence using \dt and information_schema.tables in psql. Proceeded with local validation and static documentation instead of live ingestion.

3️. Tool-Specific Restrictions

Issue: Local tunneling utilities blocked or unstable on Windows.
Description:

Cloudflared required verified domain ownership.

LocalXpose was blocked by Windows Defender.

localhost.run and serveo disconnected during authentication.
Workaround:
Used Cloudflared “Quick Tunnel” for brief testing, but eventually simulated Hevo ingestion locally.

4️. Loom Video Not Recorded

Description:
A Loom walkthrough could not be created because the live Hevo ↔ PostgreSQL tunnel connection was never established.
Workaround:
Instead of a video demo, all transformation logic and verification queries have been clearly documented in this repository.

## 🎥 Loom Video
Not recorded due to tunneling restrictions — full workflow and SQL logic documented above.

### Outcome

Despite connectivity limitations, all functional objectives—data preparation, cleaning, transformation, and validation—were fully achieved and documented.
This ensures complete review transparency even without a live tunnel or video demonstration.

### Final Outcome

The repository demonstrates:
End-to-end data design and cleaning logic for all four datasets.
SQL transformations implementing the required business rules.
Verified local results that align with expected Hevo → Snowflake ingestion outcomes.

### Author
Arundhathi Balaraj
Prepared for the Hevo Data Pipeline Assessment.
