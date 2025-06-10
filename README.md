# Advanced HR Database SQL Project

A comprehensive Human Resources database management system built with PostgreSQL, designed to handle modern organizational needs including employee management, performance tracking, compensation analysis, and organizational hierarchy.

## 🚀 Features

### Core Functionality
- **Employee Management**: Complete employee lifecycle from hiring to termination
- **Organizational Structure**: Hierarchical department management with budget tracking
- **Performance Reviews**: Comprehensive performance evaluation system
- **Compensation Management**: Salary tracking with historical changes
- **Location Management**: Multi-location support with geographical data
- **Job Management**: Position definitions with salary ranges and categories

### Advanced Features
- **Salary Band Analysis**: Automated salary classification and gap analysis
- **Performance Analytics**: Comprehensive performance metrics and trends
- **Department Analytics**: Budget utilization, headcount, and efficiency metrics
- **Gender Pay Gap Analysis**: Built-in equity analysis tools
- **Turnover Analysis**: Employee retention and turnover metrics
- **Leadership Pipeline**: Identification of high-potential employees

### ERD Diagram
![My diagram](https://github.com/user-attachments/assets/bd7ffaaf-0d68-472c-9902-53631ae0d396)

    

## 📊 Database Schema

### Core Tables
- **`locations`**: Office locations and geographical information
- **`jobs`**: Job positions with salary ranges and requirements
- **`departments`**: Organizational structure with hierarchy support
- **`employees`**: Comprehensive employee information
- **`salary_history`**: Complete compensation change tracking
- **`performance_reviews`**: Employee performance evaluation records

### Entity-Relationship Diagrams


### Advanced Views
- **`employee_details`**: Consolidated employee information
- **`department_summary`**: Department metrics and analytics
- **`salary_bands`**: Salary analysis and band classification

### Stored Procedures
- **`hire_employee()`**: Complete employee onboarding process
- **`update_salary()`**: Salary change with validation and history tracking
- **`department_transfer()`**: Employee department transfer management

## 🏗️ Project Structure

```
hr-database-project/
├── README.md                    # Project documentation
├── schemas/                     # Database table definitions
│   ├── locations.sql           # Location management
│   ├── jobs.sql                # Job position definitions
│   ├── departments.sql         # Department hierarchy
│   ├── employees.sql           # Employee information
│   ├── salary_history.sql      # Compensation tracking
│   └── performance_reviews.sql # Performance evaluation
├── data/                       # Sample data for testing
│   ├── sample_locations.sql    # Global office locations
│   ├── sample_jobs.sql         # Various job positions
│   ├── sample_departments.sql  # Department structure
│   ├── sample_employees.sql    # Employee records
│   ├── sample_salary_history.sql # Salary change history
│   └── sample_performance_reviews.sql # Performance data
├── views/                      # Database views for reporting
│   ├── employee_details.sql    # Comprehensive employee view
│   ├── department_summary.sql  # Department analytics
│   └── salary_bands.sql        # Salary analysis view
├── procedures/                 # Stored procedures and functions
│   ├── hire_employee.sql       # Employee onboarding
│   ├── update_salary.sql       # Salary management
│   └── department_transfer.sql # Department transfers
├── queries/                    # Analysis and reporting queries
│   ├── employee_reports.sql    # Employee analytics
│   ├── salary_analysis.sql     # Compensation analysis
│   ├── performance_queries.sql # Performance analytics
│   └── department_analytics.sql # Department insights
├── migrations/                 # Database schema versioning
│   ├── 001_initial_schema.sql  # Initial database structure
│   ├── 002_add_indexes.sql     # Performance optimization
│   └── 003_add_constraints.sql # Data validation rules
├── scripts/                    # Database management scripts
│   ├── setup_database.sql      # Complete database setup
│   └── reset_database.sql      # Database reset utility
└── docs/                       # Comprehensive documentation
    ├── database_design.md      # Technical architecture
    └── api_documentation.md    # Usage guidelines
```

## 🚀 Quick Start

### Prerequisites
- PostgreSQL 12 or higher
- psql command-line tool
- Basic SQL knowledge

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/hr-database-project.git
   cd hr-database-project
   ```

2. **Create a new database** (using postgres superuser):
   ```bash
   psql -U postgres -c "CREATE DATABASE hr_database;"
   ```

3. **Run the setup script** (using postgres superuser):
   ```bash
   psql -U postgres -d hr_database -f scripts/setup_database.sql
   ```

4. **Verify installation** (using postgres superuser):
   ```bash
   psql -U postgres -d hr_database -c "SELECT COUNT(*) FROM employees;"
   psql -U postgres -d hr_database -c "SELECT COUNT(*) FROM departments;"
   ```

### Alternative Setup (Step by Step)

```bash
# 1. Create tables in dependency order (using postgres superuser)
psql -U postgres -d hr_database -f schemas/locations.sql
psql -U postgres -d hr_database -f schemas/jobs.sql
psql -U postgres -d hr_database -f schemas/departments.sql
psql -U postgres -d hr_database -f schemas/employees.sql
psql -U postgres -d hr_database -f schemas/salary_history.sql
psql -U postgres -d hr_database -f schemas/performance_reviews.sql

# 2. Add foreign key constraints
psql -U postgres -d hr_database -c "ALTER TABLE departments ADD CONSTRAINT fk_departments_manager FOREIGN KEY (manager_id) REFERENCES employees(employee_id);"

# 3. Load sample data
psql -U postgres -d hr_database -f data/sample_locations.sql
psql -U postgres -d hr_database -f data/sample_jobs.sql
psql -U postgres -d hr_database -f data/sample_departments.sql
psql -U postgres -d hr_database -f data/sample_employees.sql
psql -U postgres -d hr_database -f data/sample_salary_history.sql
psql -U postgres -d hr_database -f data/sample_performance_reviews.sql

# 4. Create views and procedures
psql -U postgres -d hr_database -f views/employee_details.sql
psql -U postgres -d hr_database -f views/department_summary.sql
psql -U postgres -d hr_database -f views/salary_bands.sql
psql -U postgres -d hr_database -f procedures/hire_employee.sql
psql -U postgres -d hr_database -f procedures/update_salary.sql
psql -U postgres -d hr_database -f procedures/department_transfer.sql
```

## 📈 Usage Examples

### Employee Management

```sql
-- Hire a new employee
SELECT hire_employee(
    'EMP021', 'John', 'Smith', 'john.smith@company.com', '555-0141',
    '2024-01-15', 1, 4, 4, 1, 75000.00, 'Full-time',
    '1990-05-20', 'Male', 'Jane Smith', '555-0142'
);

-- Update employee salary
SELECT update_salary(1, 90000.00, 'Annual Review', '2024-01-01', 3, 'Performance-based increase');

-- Transfer employee to new department
SELECT department_transfer(1, 8, 12, 5, '2024-02-01', 'Career development opportunity', 3);
```

### Analytics and Reporting

```sql
-- Department performance overview
SELECT * FROM department_summary ORDER BY total_employees DESC;

-- Salary band analysis
SELECT salary_band, COUNT(*), AVG(current_salary) 
FROM salary_bands 
GROUP BY salary_band 
ORDER BY AVG(current_salary);

-- High performers identification
SELECT employee_name, job_title, overall_rating, current_salary
FROM employee_details ed
JOIN performance_reviews pr ON ed.employee_id = pr.employee_id
WHERE pr.overall_rating >= 4 AND pr.status = 'Completed'
ORDER BY pr.overall_rating DESC, ed.current_salary DESC;
```

### Advanced Analytics

```sql
-- Gender pay gap analysis by department
\i queries/salary_analysis.sql

-- Performance trends by department
\i queries/performance_queries.sql

-- Department efficiency metrics
\i queries/department_analytics.sql
```

## 🎯 Key Capabilities

### Human Resources Management
- Complete employee lifecycle management
- Hierarchical organizational structure
- Multi-location workforce support
- Comprehensive performance tracking

### Analytics and Insights
- **Compensation Analysis**: Salary bands, pay equity, market positioning
- **Performance Analytics**: Rating distributions, improvement tracking
- **Organizational Metrics**: Department efficiency, budget utilization
- **Workforce Planning**: Turnover analysis, succession planning

### Data Quality and Integrity
- Comprehensive data validation
- Referential integrity enforcement
- Audit trail maintenance
- Automated timestamp management

## 🔧 Advanced Features

### Performance Optimization
- Strategic indexing for common queries
- Optimized views for reporting
- Efficient foreign key relationships
- Query performance monitoring

### Scalability
- Designed for organizations of all sizes
- Supports hierarchical department structures
- Multi-location architecture
- Historical data preservation

### Security and Compliance
- Role-based access control ready
- Sensitive data protection
- Audit trail compliance
- Data retention policies

## 🧪 Testing and Validation

### Comprehensive Testing
Run the complete test suite to validate your database setup:

```bash
# Run comprehensive database tests
psql -U postgres -d hr_database -f scripts/comprehensive_test.sql
```

This test script validates:
- ✅ Table structure and constraints
- ✅ Foreign key relationships
- ✅ Sample data integrity
- ✅ View functionality
- ✅ Stored procedure execution
- ✅ Data quality checks
- ✅ Business logic validation
- ✅ Performance index usage
- ✅ Hierarchy circular reference detection

### Quick Validation
For basic validation, run:

```bash
# Basic database validation
psql -U postgres -d hr_database -f scripts/test_database.sql
```

### Reset Database
To reset the database to a clean state:

```bash
# Reset database (removes all data)
psql -U postgres -d hr_database -f scripts/reset_database.sql
```

## 📚 Documentation

- **[Database Design](docs/database_design.md)**: Comprehensive technical architecture
- **[Entity-Relationship Diagrams](docs/ERD_visual.md)**: Visual database structure
  - [Interactive Mermaid ERD](docs/ERD_visual.md) - For GitHub/GitLab rendering
  - [Detailed ASCII ERD](docs/ERD_diagram.md) - Complete relationship matrix
  - [Quick Reference ERD](docs/ERD_simple.md) - Simplified overview
- **[API Documentation](docs/api_documentation.md)**: Procedure and function reference
- **Sample Queries**: Pre-built analytical queries in `/queries` directory
- **Migration Scripts**: Database versioning and updates

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow PostgreSQL best practices
- Include comprehensive comments
- Add sample data for new features
- Update documentation accordingly
- Test all changes thoroughly

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by real-world HR database requirements
- Built using PostgreSQL best practices
- Designed for educational and professional use
- Community-driven development approach

## 📞 Support

For questions, issues, or contributions:
- Open an issue on GitHub
- Review the documentation in `/docs`
- Check existing queries in `/queries`
- Examine sample data for usage examples

---

**Built with ❤️ for HR professionals and database developers**
