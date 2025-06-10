# HR Database Entity-Relationship Diagram (ERD)

## Visual ERD Overview

```
                                    HR DATABASE ERD
                                         
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                  LOCATIONS                                      │
├─────────────────────────────────────────────────────────────────────────────────┤
│ PK  location_id (SERIAL)                                                       │
│     location_name (VARCHAR)                                                    │
│     street_address (VARCHAR)                                                   │
│     postal_code (VARCHAR)                                                      │
│     city (VARCHAR)                                                             │
│     state_province (VARCHAR)                                                   │
│     country (VARCHAR) DEFAULT 'INDIA'                                         │
│     region (VARCHAR)                                                           │
│     phone_number (VARCHAR)                                                     │
│     is_headquarters (BOOLEAN)                                                  │
│     is_active (BOOLEAN)                                                        │
│     created_date (TIMESTAMP)                                                   │
│     modified_date (TIMESTAMP)                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
              │
              │ 1:N
              ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                 DEPARTMENTS                                     │
├─────────────────────────────────────────────────────────────────────────────────┤
│ PK  department_id (SERIAL)                                                     │
│     department_name (VARCHAR)                                                  │
│     department_code (VARCHAR)                                                  │
│ FK  parent_department_id (INTEGER) → departments.department_id                 │
│ FK  manager_id (INTEGER) → employees.employee_id                               │
│ FK  location_id (INTEGER) → locations.location_id                              │
│     budget (DECIMAL)                                                           │
│     cost_center (VARCHAR)                                                      │
│     description (TEXT)                                                         │
│     is_active (BOOLEAN)                                                        │
│     created_date (TIMESTAMP)                                                   │
│     modified_date (TIMESTAMP)                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
              │                                    
              │ 1:N                              ┌─────────────────────────────────┐
              ▼                                  │             JOBS                │
┌─────────────────────────────────────────┬─────┤                                 │
│              EMPLOYEES                  │     ├─────────────────────────────────┤
├─────────────────────────────────────────┤     │ PK  job_id (SERIAL)             │
│ PK  employee_id (SERIAL)                │     │     job_title (VARCHAR)         │
│     employee_number (VARCHAR)           │     │     job_description (TEXT)      │
│     first_name (VARCHAR)                │     │     min_salary (DECIMAL)        │
│     last_name (VARCHAR)                 │     │     max_salary (DECIMAL)        │
│     email (VARCHAR)                     │     │     job_category (VARCHAR)      │
│     phone_number (VARCHAR)              │     │     experience_level (VARCHAR)  │
│     hire_date (DATE)                    │ ◄───┤     employment_type (VARCHAR)   │
│ FK  job_id (INTEGER) → jobs.job_id      │ N:1 │     is_active (BOOLEAN)         │
│ FK  department_id (INTEGER)             │     │     created_date (TIMESTAMP)    │
│ FK  manager_id (INTEGER) → self         │     │     modified_date (TIMESTAMP)   │
│ FK  location_id (INTEGER)               │     └─────────────────────────────────┘
│     current_salary (DECIMAL)            │
│     employment_status (VARCHAR)         │
│     employment_type (VARCHAR)           │
│     date_of_birth (DATE)                │
│     gender (VARCHAR)                    │
│     emergency_contact_name (VARCHAR)    │
│     emergency_contact_phone (VARCHAR)   │
│     termination_date (DATE)             │
│     termination_reason (TEXT)           │
│     is_active (BOOLEAN)                 │
│     created_date (TIMESTAMP)            │
│     modified_date (TIMESTAMP)           │
└─────────────────────────────────────────┘
              │
              │ 1:N
              ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                               SALARY_HISTORY                                    │
├─────────────────────────────────────────────────────────────────────────────────┤
│ PK  salary_history_id (SERIAL)                                                 │
│ FK  employee_id (INTEGER) → employees.employee_id                              │
│     old_salary (DECIMAL)                                                       │
│     new_salary (DECIMAL)                                                       │
│     salary_change_amount (DECIMAL)                                             │
│     salary_change_percentage (DECIMAL)                                         │
│     change_reason (VARCHAR)                                                    │
│     effective_date (DATE)                                                      │
│     end_date (DATE)                                                            │
│ FK  approved_by (INTEGER) → employees.employee_id                              │
│     notes (TEXT)                                                               │
│     created_date (TIMESTAMP)                                                   │
└─────────────────────────────────────────────────────────────────────────────────┘

              
┌─────────────────────────────────────────────────────────────────────────────────┐
│                            PERFORMANCE_REVIEWS                                 │
├─────────────────────────────────────────────────────────────────────────────────┤
│ PK  review_id (SERIAL)                                                         │
│ FK  employee_id (INTEGER) → employees.employee_id                              │
│ FK  reviewer_id (INTEGER) → employees.employee_id                              │
│     review_period_start (DATE)                                                 │
│     review_period_end (DATE)                                                   │
│     review_type (VARCHAR)                                                      │
│     overall_rating (INTEGER 1-5)                                              │
│     goals_achievement_rating (INTEGER 1-5)                                    │
│     technical_skills_rating (INTEGER 1-5)                                     │
│     communication_rating (INTEGER 1-5)                                        │
│     leadership_rating (INTEGER 1-5)                                           │
│     strengths (TEXT)                                                           │
│     areas_for_improvement (TEXT)                                               │
│     goals_for_next_period (TEXT)                                               │
│     development_plan (TEXT)                                                    │
│     reviewer_comments (TEXT)                                                   │
│     employee_comments (TEXT)                                                   │
│     status (VARCHAR)                                                           │
│     review_date (DATE)                                                         │
│     approval_date (DATE)                                                       │
│ FK  approved_by (INTEGER) → employees.employee_id                              │
│     created_date (TIMESTAMP)                                                   │
│     modified_date (TIMESTAMP)                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## Relationship Matrix

| FROM Table | TO Table | Relationship | Cardinality | Foreign Key |
|------------|----------|--------------|-------------|-------------|
| locations | departments | Has | 1:N | departments.location_id |
| locations | employees | Hosts | 1:N | employees.location_id |
| jobs | employees | Defines | 1:N | employees.job_id |
| departments | employees | Contains | 1:N | employees.department_id |
| departments | departments | Parent-Child | 1:N | departments.parent_department_id |
| employees | departments | Manages | 1:1 | departments.manager_id |
| employees | employees | Reports-To | 1:N | employees.manager_id |
| employees | salary_history | Has | 1:N | salary_history.employee_id |
| employees | salary_history | Approves | 1:N | salary_history.approved_by |
| employees | performance_reviews | Reviewed | 1:N | performance_reviews.employee_id |
| employees | performance_reviews | Reviews | 1:N | performance_reviews.reviewer_id |
| employees | performance_reviews | Approves | 1:N | performance_reviews.approved_by |

## Key Constraints & Business Rules

### Primary Keys
- All tables have auto-incrementing SERIAL primary keys
- Ensures unique record identification across the system

### Foreign Key Relationships
1. **employees.job_id** → **jobs.job_id** (Many employees can have same job)
2. **employees.department_id** → **departments.department_id** (Many employees per department)
3. **employees.location_id** → **locations.location_id** (Many employees per location)
4. **employees.manager_id** → **employees.employee_id** (Self-referencing hierarchy)
5. **departments.location_id** → **locations.location_id** (Department primary location)
6. **departments.parent_department_id** → **departments.department_id** (Hierarchical structure)
7. **departments.manager_id** → **employees.employee_id** (Department manager)
8. **salary_history.employee_id** → **employees.employee_id** (Salary tracking)
9. **salary_history.approved_by** → **employees.employee_id** (Approval tracking)
10. **performance_reviews.employee_id** → **employees.employee_id** (Review subject)
11. **performance_reviews.reviewer_id** → **employees.employee_id** (Review author)
12. **performance_reviews.approved_by** → **employees.employee_id** (Review approver)

### Unique Constraints
- **employees.email** (Unique corporate email addresses)
- **employees.employee_number** (Unique employee identifiers)
- **departments.department_name** (Unique department names)
- **departments.department_code** (Unique department codes)
- **jobs.job_title** (Unique job titles)
- **locations.is_headquarters** (Only one headquarters allowed)

### Check Constraints
- **salary_history.new_salary > 0** (Positive salary amounts)
- **employees.current_salary > 0** (Positive current salaries)
- **jobs.max_salary >= min_salary** (Logical salary ranges)
- **performance_reviews ratings 1-5** (Valid rating ranges)
- **employees.termination_date >= hire_date** (Logical employment dates)

### Self-Referencing Relationships
1. **Employees Manager Hierarchy**: employees.manager_id → employees.employee_id
2. **Department Hierarchy**: departments.parent_department_id → departments.department_id

### Circular Dependencies (Resolved)
- **Departments ↔ Employees**: Department has manager (employee), employee belongs to department
- **Resolution**: Create departments first without manager, add manager FK after employees exist

## Indexing Strategy

### Primary Indexes (Automatic)
- All primary keys automatically indexed

### Foreign Key Indexes
- All foreign key columns indexed for join performance

### Business Logic Indexes
- **employees(first_name, last_name)** - Name searches
- **employees(hire_date)** - Date range queries
- **employees(employment_status)** - Status filtering
- **salary_history(effective_date)** - Historical queries
- **performance_reviews(review_date)** - Review scheduling
- **locations(city, country)** - Geographic queries

### Unique Indexes
- **salary_history(employee_id) WHERE end_date IS NULL** - Active salary constraint

## Data Flow Patterns

### Employee Lifecycle
1. **Hire**: Insert into employees → Create initial salary_history record
2. **Salary Change**: Update employees.current_salary → Insert salary_history record
3. **Transfer**: Update employees.department_id/location_id
4. **Review**: Insert performance_reviews record
5. **Terminate**: Update employees with termination details

### Organizational Changes
1. **Department Creation**: Insert department → Assign location
2. **Manager Assignment**: Update department.manager_id
3. **Budget Updates**: Update department.budget
4. **Location Changes**: Update location details → Cascade to departments/employees

### Reporting Flows
1. **Employee Reports**: employees ⟷ jobs ⟷ departments ⟷ locations
2. **Salary Analysis**: employees ⟷ salary_history ⟷ jobs
3. **Performance Analytics**: employees ⟷ performance_reviews ⟷ departments
4. **Organizational Metrics**: departments ⟷ employees ⟷ locations

This ERD represents a comprehensive HR management system with robust data integrity, clear relationships, and scalable architecture for modern organizational needs.
