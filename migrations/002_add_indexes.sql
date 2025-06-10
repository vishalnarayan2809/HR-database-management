-- Migration to add performance indexes for HR database

-- Indexes for employees table
CREATE INDEX idx_employees_department ON employees(department_id);
CREATE INDEX idx_employees_manager ON employees(manager_id);
CREATE INDEX idx_employees_job ON employees(job_id);
CREATE INDEX idx_employees_location ON employees(location_id);
CREATE INDEX idx_employees_hire_date ON employees(hire_date);
CREATE INDEX idx_employees_status ON employees(employment_status);
CREATE INDEX idx_employees_active ON employees(is_active);
CREATE INDEX idx_employees_name ON employees(first_name, last_name);
CREATE INDEX idx_employees_email ON employees(email);
CREATE INDEX idx_employees_employee_number ON employees(employee_number);

-- Indexes for departments table
CREATE INDEX idx_departments_parent ON departments(parent_department_id);
CREATE INDEX idx_departments_manager ON departments(manager_id);
CREATE INDEX idx_departments_location ON departments(location_id);
CREATE INDEX idx_departments_active ON departments(is_active);
CREATE INDEX idx_departments_code ON departments(department_code);

-- Indexes for jobs table
CREATE INDEX idx_jobs_category ON jobs(job_category);
CREATE INDEX idx_jobs_level ON jobs(experience_level);
CREATE INDEX idx_jobs_active ON jobs(is_active);
CREATE INDEX idx_jobs_title ON jobs(job_title);

-- Indexes for locations table
CREATE INDEX idx_locations_city ON locations(city);
CREATE INDEX idx_locations_country ON locations(country);
CREATE INDEX idx_locations_active ON locations(is_active);
CREATE INDEX idx_locations_region ON locations(region);

-- Indexes for salary_history table
CREATE INDEX idx_salary_history_employee ON salary_history(employee_id);
CREATE INDEX idx_salary_history_effective_date ON salary_history(effective_date);
CREATE INDEX idx_salary_history_approver ON salary_history(approved_by);
CREATE UNIQUE INDEX idx_salary_history_active ON salary_history(employee_id) WHERE end_date IS NULL;

-- Indexes for performance_reviews table
CREATE INDEX idx_performance_reviews_employee ON performance_reviews(employee_id);
CREATE INDEX idx_performance_reviews_reviewer ON performance_reviews(reviewer_id);
CREATE INDEX idx_performance_reviews_review_date ON performance_reviews(review_date);
CREATE INDEX idx_performance_reviews_status ON performance_reviews(status);
CREATE INDEX idx_performance_reviews_period ON performance_reviews(review_period_start, review_period_end);
CREATE INDEX idx_performance_reviews_overall_rating ON performance_reviews(overall_rating);
CREATE INDEX idx_performance_reviews_type ON performance_reviews(review_type);