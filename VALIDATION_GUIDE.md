# HR Database Project - Validation and Setup Guide

## Prerequisites Check

Before running the HR Database project, ensure you have:

### 1. PostgreSQL Installation
**Windows:**
- Download from: https://www.postgresql.org/download/windows/
- Recommended version: PostgreSQL 13 or higher
- Include pgAdmin 4 for GUI management

**Installation Commands (Windows PowerShell as Administrator):**
```powershell
# Using Chocolatey
choco install postgresql

# Using Scoop
scoop install postgresql

# Using winget
winget install PostgreSQL.PostgreSQL
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
```

**macOS:**
```bash
# Using Homebrew
brew install postgresql
```

### 2. Database Creation
After PostgreSQL installation:

```sql
-- Connect to PostgreSQL as superuser
psql -U postgres

-- Create database and user
CREATE DATABASE hr_database;
CREATE USER hr_admin WITH ENCRYPTED PASSWORD 'secure_password';
GRANT ALL PRIVILEGES ON DATABASE hr_database TO hr_admin;

-- Connect to the new database
\c hr_database;

-- Grant schema permissions
GRANT ALL ON SCHEMA public TO hr_admin;
```

## Quick Setup Validation

### 1. Check PostgreSQL Service
```powershell
# Windows - Check service status
Get-Service postgresql*

# Windows - Start service if needed
Start-Service postgresql-x64-13  # Adjust version number
```

```bash
# Linux - Check service status
sudo systemctl status postgresql

# Linux - Start service if needed
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

### 2. Test Database Connection
```bash
# Test connection
psql -h localhost -p 5432 -U hr_admin -d hr_database

# If successful, you should see:
# hr_database=>
```

## Project Setup Steps

### Step 1: Complete Database Setup
```bash
# Navigate to project directory
cd "c:\Users\guruk\SQL\hr-database-project-1"

# Run complete setup (using corrected script)
psql -U postgres -d hr_database -f scripts/setup_database_corrected.sql

# Alternative: Use the manual step-by-step approach shown above
```

### Step 2: Validate Installation
```bash
# Run comprehensive tests
psql -U postgres -d hr_database -f scripts/comprehensive_test.sql

# Check specific components
psql -U postgres -d hr_database -f scripts/test_database.sql
```

### Step 3: Verify Sample Data
```sql
-- Quick data verification
SELECT 'employees' as table_name, count(*) as records FROM employees
UNION ALL
SELECT 'departments' as table_name, count(*) as records FROM departments
UNION ALL
SELECT 'locations' as table_name, count(*) as records FROM locations
UNION ALL
SELECT 'jobs' as table_name, count(*) as records FROM jobs
UNION ALL
SELECT 'salary_history' as table_name, count(*) as records FROM salary_history
UNION ALL
SELECT 'performance_reviews' as table_name, count(*) as records FROM performance_reviews;
```

## Expected Results After Setup

### Tables Created (6 total):
- ✅ locations (8 records)
- ✅ jobs (20 records)  
- ✅ departments (14 records)
- ✅ employees (20 records)
- ✅ salary_history (30+ records)
- ✅ performance_reviews (20+ records)

### Views Created (3 total):
- ✅ employee_details
- ✅ department_summary
- ✅ salary_bands

### Stored Procedures (3 total):
- ✅ hire_employee()
- ✅ update_salary()
- ✅ department_transfer()

### Indexes (10+ total):
- ✅ Primary key indexes
- ✅ Foreign key indexes
- ✅ Performance optimization indexes

## Troubleshooting Common Issues

### Issue 1: "psql command not found"
**Solution:**
```powershell
# Windows - Add PostgreSQL to PATH
$env:PATH += ";C:\Program Files\PostgreSQL\13\bin"

# Or permanently add to system PATH:
# System Properties > Environment Variables > PATH > Add PostgreSQL bin directory
```

### Issue 2: "Connection refused"
**Solutions:**
1. Check PostgreSQL service is running
2. Verify port 5432 is not blocked
3. Check postgresql.conf for listen_addresses
4. Verify pg_hba.conf authentication settings

### Issue 3: "Permission denied"
**Solutions:**
1. Create database with proper user permissions
2. Grant necessary privileges on schema
3. Run as database superuser if needed

### Issue 4: "Foreign key constraint violations"
**Solutions:**
1. Use the complete setup script (handles dependencies)
2. If running manually, follow the correct order:
   - Tables: locations → jobs → departments → employees → salary_history → performance_reviews
   - Add manager_id constraint after employees table is populated

### Issue 5: "Function does not exist"
**Solutions:**
1. Ensure all procedure files are executed
2. Check for syntax errors in procedure definitions
3. Verify PostgreSQL version compatibility (use 13+)

## Manual Verification Steps

### 1. Check Table Structure
```sql
-- List all tables
\dt

-- Describe specific table
\d employees

-- Check foreign key constraints
SELECT 
    conname AS constraint_name,
    conrelid::regclass AS table_name,
    confrelid::regclass AS referenced_table
FROM pg_constraint 
WHERE contype = 'f';
```

### 2. Test Relationships
```sql
-- Test employee-department relationship
SELECT 
    e.first_name, 
    e.last_name, 
    d.department_name 
FROM employees e 
JOIN departments d ON e.department_id = d.department_id 
LIMIT 5;

-- Test manager hierarchy
SELECT 
    e.first_name || ' ' || e.last_name as employee,
    m.first_name || ' ' || m.last_name as manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id
WHERE e.manager_id IS NOT NULL
LIMIT 5;
```

### 3. Test Views
```sql
-- Test employee_details view
SELECT * FROM employee_details LIMIT 3;

-- Test department_summary view
SELECT * FROM department_summary LIMIT 3;

-- Test salary_bands view
SELECT * FROM salary_bands LIMIT 3;
```

### 4. Test Procedures
```sql
-- Test hire_employee procedure
SELECT hire_employee(
    'TEST999',
    'Jane',
    'Doe', 
    'jane.doe@test.com',
    '555-TEST',
    1, -- job_id
    1, -- department_id  
    1, -- manager_id
    1, -- location_id
    60000.00,
    'Test hiring'
);

-- Verify the hire worked
SELECT * FROM employees WHERE employee_number = 'TEST999';

-- Clean up test data
DELETE FROM salary_history WHERE employee_id = (SELECT employee_id FROM employees WHERE employee_number = 'TEST999');
DELETE FROM employees WHERE employee_number = 'TEST999';
```

## Performance Optimization

### Check Index Usage
```sql
-- Check if indexes are being used
EXPLAIN (ANALYZE, BUFFERS) 
SELECT * FROM employees WHERE department_id = 1;

-- Show index statistics
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan as times_used,
    idx_tup_read as tuples_read,
    idx_tup_fetch as tuples_fetched
FROM pg_stat_user_indexes 
ORDER BY idx_scan DESC;
```

### Monitor Query Performance
```sql
-- Enable query performance tracking
ALTER SYSTEM SET track_activities = on;
ALTER SYSTEM SET track_counts = on;
ALTER SYSTEM SET track_io_timing = on;
SELECT pg_reload_conf();

-- View slow queries (if pg_stat_statements extension is available)
-- SELECT query, total_time, calls, mean_time 
-- FROM pg_stat_statements 
-- ORDER BY total_time DESC 
-- LIMIT 10;
```

## Production Deployment Considerations

### Security
1. **Change default passwords**
2. **Create dedicated database users with minimal privileges**
3. **Enable SSL connections**
4. **Configure proper authentication in pg_hba.conf**

### Backup Strategy
```bash
# Regular backup
pg_dump -h localhost -U hr_admin -d hr_database > hr_backup_$(date +%Y%m%d).sql

# Compressed backup
pg_dump -h localhost -U hr_admin -d hr_database | gzip > hr_backup_$(date +%Y%m%d).sql.gz
```

### Monitoring
1. **Set up database monitoring**
2. **Configure log rotation**
3. **Monitor disk space usage**
4. **Track connection counts**

## Next Steps

After successful setup:
1. ✅ Explore the sample queries in `/queries` directory
2. ✅ Review the ERD documentation in `/docs`
3. ✅ Customize the schema for your specific needs
4. ✅ Set up regular backups
5. ✅ Configure monitoring and alerting
6. ✅ Consider additional security measures

## Getting Help

If you encounter issues:
1. Check PostgreSQL logs (usually in data/log directory)
2. Review the comprehensive test output for specific errors
3. Consult PostgreSQL documentation
4. Check the project's GitHub issues
5. Review the detailed documentation in `/docs` directory

The HR Database project is designed to be robust and well-documented. Following this guide should result in a fully functional HR database system ready for development or production use.
