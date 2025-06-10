-- Enhanced jobs table with additional fields for comprehensive job management
CREATE TABLE jobs (
    job_id SERIAL PRIMARY KEY,
    job_title VARCHAR(255) NOT NULL UNIQUE,
    job_description TEXT,
    min_salary DECIMAL(10, 2) NOT NULL,
    max_salary DECIMAL(10, 2) NOT NULL,
    job_category VARCHAR(100),
    experience_level VARCHAR(50) CHECK (experience_level IN ('Entry', 'Junior', 'Mid', 'Senior', 'Executive')),
    employment_type VARCHAR(50) DEFAULT 'Full-time' CHECK (employment_type IN ('Full-time', 'Part-time', 'Contract', 'Temporary')),
    is_active BOOLEAN DEFAULT TRUE,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_salary_range CHECK (max_salary >= min_salary)
);

-- Create indexes for better performance
CREATE INDEX idx_jobs_category ON jobs(job_category);
CREATE INDEX idx_jobs_level ON jobs(experience_level);
CREATE INDEX idx_jobs_active ON jobs(is_active);