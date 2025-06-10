# HR Database - Simplified Relationship Diagram

## Quick Reference ERD

```
                    HR DATABASE RELATIONSHIPS
                           
    LOCATIONS                         JOBS
    ┌─────────┐                    ┌─────────┐
    │location │                    │ job_id  │
    │  _id    │                    │         │
    │(PK)     │                    │ (PK)    │
    └────┬────┘                    └────┬────┘
         │                              │
         │ 1:N                          │ 1:N
         ▼                              ▼
    ┌─────────────────────────────────────────┐
    │           DEPARTMENTS                   │
    │  ┌─────────────────────────────────┐    │
    │  │department_id (PK)               │    │
    │  │location_id (FK) ◄─────────────────────┘
    │  │parent_department_id (FK) ◄─┐    │
    │  │manager_id (FK) ◄─────────┐ │    │
    │  └─────────────────────────┬─┴─┘    │
    └────────────────────────────┼────────┘
                                 │ 1:N
                                 ▼
    ┌─────────────────────────────────────────┐
    │              EMPLOYEES                  │
    │  ┌─────────────────────────────────┐    │
    │  │employee_id (PK)                 │    │
    │  │job_id (FK) ◄────────────────────────────┘
    │  │department_id (FK) ◄─────────────┘    │
    │  │manager_id (FK) ◄─┐                   │
    │  │location_id (FK) ◄┼───────────────────┘
    │  └─────────────────┬─┴───────────────────┘
    └────────────────────┼─────────────────────┘
                         │ 1:N
                         ▼
    ┌─────────────────────────────────────────┐
    │          SALARY_HISTORY                 │
    │  ┌─────────────────────────────────┐    │
    │  │salary_history_id (PK)           │    │
    │  │employee_id (FK) ◄───────────────┘    │
    │  │approved_by (FK) ◄─────────────────────┘
    │  └─────────────────────────────────┘
    └─────────────────────────────────────────┘
                         
    ┌─────────────────────────────────────────┐
    │        PERFORMANCE_REVIEWS              │
    │  ┌─────────────────────────────────┐    │
    │  │review_id (PK)                   │    │
    │  │employee_id (FK) ◄───────────────┘    │
    │  │reviewer_id (FK) ◄─────────────────────┘
    │  │approved_by (FK) ◄─────────────────────┘
    │  └─────────────────────────────────┘
    └─────────────────────────────────────────┘
```

## Relationship Summary

| Primary Entity | Related Entity | Type | Description |
|---------------|---------------|------|-------------|
| **LOCATIONS** | departments | 1:N | Each location hosts multiple departments |
| **LOCATIONS** | employees | 1:N | Each location has multiple employees |
| **JOBS** | employees | 1:N | Each job can be held by multiple employees |
| **DEPARTMENTS** | employees | 1:N | Each department contains multiple employees |
| **DEPARTMENTS** | departments | 1:N | Department hierarchy (parent-child) |
| **EMPLOYEES** | departments | 1:1 | Each department has one manager (employee) |
| **EMPLOYEES** | employees | 1:N | Manager-subordinate hierarchy |
| **EMPLOYEES** | salary_history | 1:N | Each employee has salary change history |
| **EMPLOYEES** | performance_reviews | 1:N | Each employee has multiple reviews |

## Key Design Patterns

### 1. Hub-and-Spoke Model
- **EMPLOYEES** is the central hub
- All other entities relate directly or indirectly to employees
- Enables efficient querying and reporting

### 2. Hierarchical Structures
- **Departments**: parent_department_id creates org chart
- **Employees**: manager_id creates reporting structure
- Self-referencing relationships with proper constraints

### 3. Historical Tracking
- **SALARY_HISTORY**: Complete compensation timeline
- **PERFORMANCE_REVIEWS**: Regular evaluation cycles
- Audit trails for compliance and analysis

### 4. Reference Data Separation
- **LOCATIONS**: Geographic/facility data
- **JOBS**: Position definitions and salary ranges
- Normalized to reduce redundancy and ensure consistency

### 5. Circular Dependency Resolution
- **Problem**: Departments need managers (employees), employees need departments
- **Solution**: Create departments first, add manager FK constraint after employees exist
- Maintains referential integrity while solving chicken-and-egg problem

## Data Flow Examples

### Employee Onboarding
```
1. Location exists → 2. Job defined → 3. Department created → 
4. Employee hired → 5. Salary history created → 6. Department manager assigned
```

### Performance Management
```
Employee → Performance Review → Reviewer (Employee) → 
Approval (Manager/HR) → Salary Adjustment → Salary History
```

### Organizational Reporting
```
Location → Department → Employee → Job Title + Salary + Performance
```

This simplified diagram shows the core relationships that drive the HR database functionality.
