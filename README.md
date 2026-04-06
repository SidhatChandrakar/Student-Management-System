# Student-Management-System

A role-based student registration and management system built with Python, HTML, and Oracle Database. The application is organized into separate modules for admin, advisor, faculty, and student operations to keep the codebase clean, modular, and easy to maintain.

## Overview
This project provides a structured platform for managing student-related workflows such as registration, record handling, and role-specific interactions. It uses a modular architecture with clearly separated route files and database scripts.

## Features
- Role-based routing for:
  - Admin
  - Advisor
  - Faculty
  - Student
- Student registration and record management
- Modular Python project structure
- Oracle database schema and data insertion scripts
- HTML templates for the user interface

## Project Structure
```text
student_registration/
├── routes/
│   ├── admin_routes.py
│   ├── advisor_routes.py
│   ├── faculty_routes.py
│   └── student_routes.py
├── templates/
├── app.py
├── config.py
├── db.py
├── oracle_schema.sql
└── inserting_all.sql
