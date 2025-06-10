-- Migration to add additional constraints and data validation rules

-- Add check constraints for data quality
ALTER TABLE employees 
ADD CONSTRAINT chk_employees_salary_positive CHECK (current_salary > 0);

ALTER TABLE employees 
ADD CONSTRAINT chk_employees_hire_future CHECK (hire_date <= CURRENT_DATE);

ALTER TABLE jobs 
ADD CONSTRAINT chk_jobs_salary_minimum CHECK (min_salary > 0);

ALTER TABLE departments 
ADD CONSTRAINT chk_departments_budget_positive CHECK (budget IS NULL OR budget > 0);

-- Add additional unique constraints
ALTER TABLE departments 
ADD CONSTRAINT uq_departments_cost_center UNIQUE (cost_center);

ALTER TABLE locations 
ADD CONSTRAINT uq_locations_headquarters CHECK (
    NOT is_headquarters OR (
        SELECT COUNT(*) FROM locations WHERE is_headquarters = true
    ) <= 1
);

-- Add check constraints for performance reviews
ALTER TABLE performance_reviews 
ADD CONSTRAINT chk_reviews_dates CHECK (
    review_date IS NULL OR 
    review_date >= review_period_end
);

ALTER TABLE performance_reviews 
ADD CONSTRAINT chk_reviews_approval_dates CHECK (
    approval_date IS NULL OR 
    approval_date >= review_date
);

-- Add constraint to ensure salary history changes are logical
ALTER TABLE salary_history 
ADD CONSTRAINT chk_salary_history_dates CHECK (
    end_date IS NULL OR created_date <= end_date
);

-- Add constraint to prevent self-management
ALTER TABLE employees 
ADD CONSTRAINT chk_employees_not_self_manager CHECK (employee_id != manager_id);

-- Add constraint to prevent department self-parenting
ALTER TABLE departments 
ADD CONSTRAINT chk_departments_not_self_parent CHECK (department_id != parent_department_id);

-- Add triggers for automatic timestamp updates
CREATE OR REPLACE FUNCTION update_modified_date()
RETURNS TRIGGER AS $$
BEGIN
    NEW.modified_date = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add triggers to tables with modified_date columns
CREATE TRIGGER tr_employees_modified_date
    BEFORE UPDATE ON employees
    FOR EACH ROW
    EXECUTE FUNCTION update_modified_date();

CREATE TRIGGER tr_departments_modified_date
    BEFORE UPDATE ON departments
    FOR EACH ROW
    EXECUTE FUNCTION update_modified_date();

CREATE TRIGGER tr_jobs_modified_date
    BEFORE UPDATE ON jobs
    FOR EACH ROW
    EXECUTE FUNCTION update_modified_date();

CREATE TRIGGER tr_locations_modified_date
    BEFORE UPDATE ON locations
    FOR EACH ROW
    EXECUTE FUNCTION update_modified_date();

CREATE TRIGGER tr_performance_reviews_modified_date
    BEFORE UPDATE ON performance_reviews
    FOR EACH ROW
    EXECUTE FUNCTION update_modified_date();