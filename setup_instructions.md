# Setup Instructions

This document provides the setup and execution steps for the PostgreSQL → Hevo → Snowflake workflow used in **HEVO Assessment II**.  
It assumes you are running a Windows environment with Docker, PostgreSQL, and Snowflake access already configured.

---

## 🧱 1. Prerequisites

### **Installed Tools**
- **Docker Desktop** (latest version)
- **PostgreSQL 15 Docker Image**
- **Git**
- **Snowflake Account** (Trial or Corporate)
- **Hevo Data Account** (Trial or Corporate)

### *Start PostgreSQL with Docker*
```
docker run -d ^
  --name hevo_pg ^
  -e POSTGRES_USER=hevo_user ^
  -e POSTGRES_PASSWORD=HevoPass123! ^
  -e POSTGRES_DB=hevo_db ^
  -p 5432:5432 ^
  postgres:15
```
Confirm the container is running:
```
docker ps
```

# Connect to PostgreSQL

Access the PostgreSQL shell inside the container:
```
docker exec -it hevo_pg psql -U hevo_user -d hevo_db
```
You should see:
```
hevo_db=#
```
# Create Database Schema and Load Data

Run the DDL scripts sequentially from the ddl_sql folder:
```
psql -U hevo_user -d hevo_db -f ddl_sql/01_create_tables.sql
psql -U hevo_user -d hevo_db -f ddl_sql/02_insert_data.sql
psql -U hevo_user -d hevo_db -f ddl_sql/03_create_publication.sql
```

Verify table creation:
```
\dt assignment2.*
```
Expected tables:
```
assignment2 | customers_raw
assignment2 | orders_raw
assignment2 | products_raw
assignment2 | country_dim
```

Check sample data:
```
SELECT * FROM assignment2.customers_raw LIMIT 5;
```

# Hevo Data Pipeline (Simulation)

Due to tunneling restrictions from the local Docker environment, live Hevo → PostgreSQL connection could not be demonstrated.
The following steps describe the intended configuration.

Add Source → `PostgreSQL`

Host: `localhost or your machine IP`

Port: `5432`

Database: `hevo_db`

User: `hevo_user` | Password: `HevoPass123!`

Replication: `Logical`

Publication: `hevo_pub_assignment2`

2. Add Destination → Snowflake

Provide account, warehouse, database, and schema details.

3. Tables to Ingest

`customers_raw`

`orders_raw`

`products_raw`

`country_dim`

4. Expected Result

Once validated, Hevo would replicate these tables into your Snowflake schema in real time.

# Snowflake Transformations

Open Snowflake → Worksheets and run:
```
CREATE SCHEMA IF NOT EXISTS assignment2;
USE SCHEMA assignment2;
```

Execute the transformation script after replacing RAW_SCHEMA with your actual Hevo schema:
```
\i transformations/10_snowflake_cleaning.sql
```

Verify outputs:
```
SELECT * FROM final_dataset LIMIT 10;
```

Validation Queries
```
-- Verify duplicates removed
SELECT customer_id, COUNT(*) 
FROM customers_dedup 
GROUP BY customer_id 
HAVING COUNT(*) > 1;

-- Check orphan orders
SELECT * FROM final_dataset WHERE customer_email = 'Orphan Customer';

-- Check for null or negative amounts
SELECT * FROM final_dataset WHERE amount IS NULL OR amount < 0;
```

###Assumptions

Missing email/phone → Invalid Customer

Unmapped countries → defaulted to ISO standard

Negative amounts → 0

Null amounts → median per customer

Currency conversion rates:

USD = 1.00

INR = 0.012

SGD = 0.73

EUR = 1.10

# Troubleshooting

a. Connection Refused
Description: Container not running.
Resolution: Start container → docker start hevo_pg.

b. Tunnel Validation Failure
Description: Hevo cannot access local Docker PostgreSQL.
Resolution: Use cloud PostgreSQL or document SQL workflow locally (as done in this project).

c. Authentication Error
Description: Incorrect credentials or authentication method.
Resolution: Validate via psql -U hevo_user -d hevo_db.

d. Schema/Table Not Found
Description: Transformations run before DDL.
Resolution: Re-execute scripts from ddl_sql.

e. Port Conflict (5432 in use)
Description: Existing PostgreSQL service using port 5432.
Resolution: Stop local service or use -p 5433:5432.

# Cleanup

To stop and remove the PostgreSQL container:
```
docker stop hevo_pg
docker rm hevo_pg
```

# Author

Arundhathi Balaraj

Prepared for the Hevo Data – Customer Experience Engineering Assessment II.
