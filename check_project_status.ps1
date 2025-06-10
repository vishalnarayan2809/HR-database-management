#!/usr/bin/env pwsh
# HR Database Project - Status Check Script
# Run this script to verify all project files are in place

Write-Host "HR Database Project - File Structure Validation" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green
Write-Host ""

$ProjectRoot = "c:\Users\guruk\SQL\hr-database-project-1"

# Define expected files and directories
$ExpectedStructure = @{
    "Core Files" = @(
        "README.md",
        "VALIDATION_GUIDE.md"
    )
    "Schema Files" = @(
        "schemas\locations.sql",
        "schemas\jobs.sql", 
        "schemas\departments.sql",
        "schemas\employees.sql",
        "schemas\salary_history.sql",
        "schemas\performance_reviews.sql"
    )
    "Sample Data" = @(
        "data\sample_locations.sql",
        "data\sample_jobs.sql",
        "data\sample_departments.sql", 
        "data\sample_employees.sql",
        "data\sample_salary_history.sql",
        "data\sample_performance_reviews.sql"
    )
    "Views" = @(
        "views\employee_details.sql",
        "views\department_summary.sql",
        "views\salary_bands.sql"
    )
    "Procedures" = @(
        "procedures\hire_employee.sql",
        "procedures\update_salary.sql",
        "procedures\department_transfer.sql"
    )
    "Scripts" = @(
        "scripts\setup_database.sql",
        "scripts\reset_database.sql",
        "scripts\test_database.sql",
        "scripts\comprehensive_test.sql"
    )
    "Queries" = @(
        "queries\employee_reports.sql",
        "queries\salary_analysis.sql",
        "queries\performance_queries.sql",
        "queries\department_analytics.sql"
    )
    "Migrations" = @(
        "migrations\001_initial_schema.sql",
        "migrations\002_add_indexes.sql",
        "migrations\003_add_constraints.sql"
    )
    "Documentation" = @(
        "docs\database_design.md",
        "docs\ERD_diagram.md",
        "docs\ERD_simple.md",
        "docs\ERD_visual.md",
        "docs\ERD_interactive.md",
        "docs\ERD_creation_guide.md",
        "docs\api_documentation.md"
    )
}

$TotalFiles = 0
$MissingFiles = 0
$PresentFiles = 0

# Check each category
foreach ($Category in $ExpectedStructure.Keys) {
    Write-Host "$Category:" -ForegroundColor Yellow
    
    foreach ($File in $ExpectedStructure[$Category]) {
        $FullPath = Join-Path $ProjectRoot $File
        $TotalFiles++
        
        if (Test-Path $FullPath) {
            Write-Host "  ✅ $File" -ForegroundColor Green
            $PresentFiles++
        } else {
            Write-Host "  ❌ $File (MISSING)" -ForegroundColor Red
            $MissingFiles++
        }
    }
    Write-Host ""
}

# Summary
Write-Host "Project Status Summary:" -ForegroundColor Cyan
Write-Host "======================" -ForegroundColor Cyan
Write-Host "Total Expected Files: $TotalFiles" -ForegroundColor White
Write-Host "Files Present: $PresentFiles" -ForegroundColor Green
Write-Host "Files Missing: $MissingFiles" -ForegroundColor Red

$CompletionPercentage = [math]::Round(($PresentFiles / $TotalFiles) * 100, 1)
Write-Host "Completion: $CompletionPercentage%" -ForegroundColor $(if ($CompletionPercentage -eq 100) { "Green" } elseif ($CompletionPercentage -ge 90) { "Yellow" } else { "Red" })

Write-Host ""

# Additional checks
Write-Host "Additional Validation:" -ForegroundColor Cyan
Write-Host "=====================" -ForegroundColor Cyan

# Check if main directories exist
$MainDirs = @("schemas", "data", "views", "procedures", "scripts", "queries", "migrations", "docs")
foreach ($Dir in $MainDirs) {
    $DirPath = Join-Path $ProjectRoot $Dir
    if (Test-Path $DirPath -PathType Container) {
        Write-Host "  ✅ Directory: $Dir" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Directory: $Dir (MISSING)" -ForegroundColor Red
    }
}

Write-Host ""

# Check file sizes (basic validation)
Write-Host "File Size Validation:" -ForegroundColor Cyan
Write-Host "====================" -ForegroundColor Cyan

$ImportantFiles = @(
    "README.md",
    "scripts\setup_database.sql",
    "scripts\comprehensive_test.sql"
)

foreach ($File in $ImportantFiles) {
    $FullPath = Join-Path $ProjectRoot $File
    if (Test-Path $FullPath) {
        $Size = (Get-Item $FullPath).Length
        if ($Size -gt 1000) {  # At least 1KB
            Write-Host "  ✅ $File ($([math]::Round($Size/1024, 1)) KB)" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️  $File ($Size bytes - seems small)" -ForegroundColor Yellow
        }
    }
}

Write-Host ""

# PostgreSQL check
Write-Host "PostgreSQL Availability:" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan

try {
    $PsqlVersion = & psql --version 2>$null
    if ($PsqlVersion) {
        Write-Host "  ✅ PostgreSQL CLI available: $($PsqlVersion[0])" -ForegroundColor Green
        
        # Try to connect to a database (this will likely fail without credentials, but shows availability)
        Write-Host "  ℹ️  To test database connection, run:" -ForegroundColor Blue
        Write-Host "     psql -h localhost -U postgres -d postgres" -ForegroundColor Gray
    }
} catch {
    Write-Host "  ❌ PostgreSQL (psql) not found in PATH" -ForegroundColor Red
    Write-Host "  ℹ️  Install PostgreSQL and add to PATH to use the database" -ForegroundColor Blue
    Write-Host "  ℹ️  See VALIDATION_GUIDE.md for installation instructions" -ForegroundColor Blue
}

Write-Host ""

# Final recommendations
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "==========" -ForegroundColor Cyan

if ($MissingFiles -eq 0) {
    Write-Host "  ✅ All project files are present!" -ForegroundColor Green
    Write-Host "  📖 Read VALIDATION_GUIDE.md for setup instructions" -ForegroundColor Blue
    Write-Host "  🗄️  Install PostgreSQL if not already installed" -ForegroundColor Blue
    Write-Host "  🚀 Run: psql -d hr_database -f scripts/setup_database.sql" -ForegroundColor Blue
} else {
    Write-Host "  ⚠️  Some files are missing. Please check the project structure." -ForegroundColor Yellow
    Write-Host "  📁 Ensure all files are properly downloaded/created" -ForegroundColor Blue
}

Write-Host ""
Write-Host "For detailed setup instructions, see:" -ForegroundColor White
Write-Host "  📖 README.md - Project overview and usage" -ForegroundColor Gray
Write-Host "  📋 VALIDATION_GUIDE.md - Complete setup guide" -ForegroundColor Gray
Write-Host "  🎨 docs/ERD_creation_guide.md - ERD visualization guide" -ForegroundColor Gray

Write-Host ""
Write-Host "Project validation complete!" -ForegroundColor Green
