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

### **Existing Setup**
From Assessment I, we already have:
- A Docker container running PostgreSQL (e.g., `hevo_pg`)
- A working user (`hevo_user`) and database (`hevo_db`)
- Verified local PostgreSQL access via `psql`
