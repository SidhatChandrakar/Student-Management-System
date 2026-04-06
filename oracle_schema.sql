-- =====================================================
-- STUDENT REGISTRATION APP - ORACLE 21c SCHEMA (3NF)
-- FINAL WORKING VERSION
-- =====================================================

-- 1. DEPARTMENTS TABLE
CREATE TABLE departments (
    department_id    NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    department_name  VARCHAR2(100) UNIQUE NOT NULL,
    description      VARCHAR2(500),
    created_at       TIMESTAMP DEFAULT SYSDATE,
    updated_at       TIMESTAMP DEFAULT SYSDATE
);

-- 2. PROGRAM_OUTCOMES (PO)
CREATE TABLE program_outcomes (
    po_id           NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    po_code         VARCHAR2(10) UNIQUE NOT NULL,
    description     VARCHAR2(1000) NOT NULL,
    department_id   NUMBER NOT NULL,
    created_at      TIMESTAMP DEFAULT SYSDATE,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- 3. STUDENTS TABLE
CREATE TABLE students (
    student_id      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name       VARCHAR2(100) NOT NULL,
    email           VARCHAR2(100) UNIQUE NOT NULL,
    phone           VARCHAR2(15),
    dob             DATE NOT NULL,
    address         VARCHAR2(500),
    department_id   NUMBER NOT NULL,
    enrollment_date DATE NOT NULL,
    password_hash   VARCHAR2(255) NOT NULL,
    created_at      TIMESTAMP DEFAULT SYSDATE,
    updated_at      TIMESTAMP DEFAULT SYSDATE,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);
-- Add new columns to students table for educational details
ALTER TABLE students ADD (
    gender VARCHAR2(10),
    high_school_name VARCHAR2(255),
    high_school_year NUMBER(4),
    high_school_percentage NUMBER(5,2),
    higher_sec_name VARCHAR2(255),
    higher_sec_year NUMBER(4),
    higher_sec_percentage NUMBER(5,2),
    ug_university VARCHAR2(255),
    ug_degree VARCHAR2(100),
    ug_graduation_year NUMBER(4),
    ug_cgpa NUMBER(3,2)
);

COMMIT;

-- 4. FACULTIES TABLE
CREATE TABLE faculties (
    faculty_id      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    faculty_name    VARCHAR2(100) NOT NULL,
    email           VARCHAR2(100) UNIQUE NOT NULL,
    phone           VARCHAR2(15),
    department_id   NUMBER NOT NULL,
    specialization  VARCHAR2(100),
    password_hash   VARCHAR2(255) NOT NULL,
    is_advisor      NUMBER(1) DEFAULT 0,
    created_at      TIMESTAMP DEFAULT SYSDATE,
    updated_at      TIMESTAMP DEFAULT SYSDATE,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- 5. ASSESSMENT_TYPES TABLE
CREATE TABLE assessment_types (
    assessment_id   NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    assessment_name VARCHAR2(100) UNIQUE NOT NULL,
    description     VARCHAR2(500)
);

-- 6. COURSES TABLE
CREATE TABLE courses (
    course_id           NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    course_code         VARCHAR2(20) UNIQUE NOT NULL,
    course_name         VARCHAR2(100) NOT NULL,
    course_type         VARCHAR2(30) NOT NULL,
    lectures            NUMBER NOT NULL,
    tutorials           NUMBER NOT NULL,
    practicals          NUMBER NOT NULL,
    credits             NUMBER NOT NULL,
    department_id       NUMBER NOT NULL,
    course_content      VARCHAR2(4000),
    text_books          VARCHAR2(2000),
    reference_books     VARCHAR2(2000),
    prerequisites       VARCHAR2(500),
    course_description  VARCHAR2(1000),
    created_at          TIMESTAMP DEFAULT SYSDATE,
    updated_at          TIMESTAMP DEFAULT SYSDATE,
    FOREIGN KEY (department_id) REFERENCES departments(department_id),
    CONSTRAINT chk_course_type CHECK (course_type IN ('Theory', 'Lab', 'Practical', 'Project', 'Seminar'))
);

-- 7. COURSE_OUTCOMES TABLE
CREATE TABLE course_outcomes (
    co_id           NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    course_id       NUMBER NOT NULL,
    co_number       VARCHAR2(10) NOT NULL,
    description     VARCHAR2(1000) NOT NULL,
    bloom_level     VARCHAR2(20) NOT NULL,
    created_at      TIMESTAMP DEFAULT SYSDATE,
    FOREIGN KEY (course_id) REFERENCES courses(course_id),
    CONSTRAINT uk_course_co UNIQUE (course_id, co_number),
    CONSTRAINT chk_bloom_level CHECK (bloom_level IN ('Remember', 'Understand', 'Apply', 'Analyze', 'Evaluate', 'Create'))
);

-- 8. CO_PO_MAPPING TABLE
CREATE TABLE co_po_mapping (
    co_id           NUMBER NOT NULL,
    po_id           NUMBER NOT NULL,
    mapping_level   VARCHAR2(10) NOT NULL,
    created_at      TIMESTAMP DEFAULT SYSDATE,
    PRIMARY KEY (co_id, po_id),
    FOREIGN KEY (co_id) REFERENCES course_outcomes(co_id),
    FOREIGN KEY (po_id) REFERENCES program_outcomes(po_id),
    CONSTRAINT chk_mapping_level CHECK (mapping_level IN ('Low', 'Medium', 'High'))
);

-- 9. COURSE_ASSESSMENT TABLE
CREATE TABLE course_assessment (
    course_assess_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    course_id       NUMBER NOT NULL,
    assessment_id   NUMBER NOT NULL,
    max_marks       NUMBER NOT NULL,
    percentage      NUMBER(5,2) NOT NULL,
    created_at      TIMESTAMP DEFAULT SYSDATE,
    FOREIGN KEY (course_id) REFERENCES courses(course_id),
    FOREIGN KEY (assessment_id) REFERENCES assessment_types(assessment_id)
);

-- 10. SEMESTERS TABLE - FIXED VERSION
CREATE TABLE semesters (
    semester_id     NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    yr              NUMBER NOT NULL,
    sess            VARCHAR2(10) NOT NULL,
    semester_number NUMBER NOT NULL,
    start_dt        DATE NOT NULL,
    end_dt          DATE NOT NULL,
    created_at      TIMESTAMP DEFAULT SYSDATE,
    CONSTRAINT uk_semester UNIQUE (yr, sess),
    CONSTRAINT chk_session CHECK (sess IN ('Winter', 'Summer'))
);

-- 11. SEMESTER_COURSES TABLE
CREATE TABLE semester_courses (
    sem_course_id   NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    semester_id     NUMBER NOT NULL,
    course_id       NUMBER NOT NULL,
    faculty_id      NUMBER NOT NULL,
    capacity        NUMBER DEFAULT 60,
    created_at      TIMESTAMP DEFAULT SYSDATE,
    updated_at      TIMESTAMP DEFAULT SYSDATE,
    FOREIGN KEY (semester_id) REFERENCES semesters(semester_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id),
    FOREIGN KEY (faculty_id) REFERENCES faculties(faculty_id)
);

-- 12. STUDENT_ADVISOR_ASSIGNMENT TABLE
CREATE TABLE student_advisor_assignment (
    student_id      NUMBER PRIMARY KEY,
    faculty_id      NUMBER NOT NULL,
    assignment_date DATE NOT NULL,
    created_at      TIMESTAMP DEFAULT SYSDATE,
    updated_at      TIMESTAMP DEFAULT SYSDATE,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (faculty_id) REFERENCES faculties(faculty_id)
);

-- 13. REGISTRATION TABLE
CREATE TABLE registration (
    registration_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id      NUMBER NOT NULL,
    sem_course_id   NUMBER NOT NULL,
    registration_date DATE NOT NULL,
    status          VARCHAR2(15) DEFAULT 'Active',
    created_at      TIMESTAMP DEFAULT SYSDATE,
    updated_at      TIMESTAMP DEFAULT SYSDATE,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (sem_course_id) REFERENCES semester_courses(sem_course_id),
    CONSTRAINT uk_registration UNIQUE (student_id, sem_course_id),
    CONSTRAINT chk_reg_status CHECK (status IN ('Active', 'Dropped', 'Completed'))
);
ALTER TABLE registration
DROP CONSTRAINT chk_reg_status;

ALTER TABLE registration
ADD CONSTRAINT chk_reg_status
CHECK (status IN ('Pending','Active','Dropped','Completed'));
commit;
-- 14. ATTENDANCE TABLE
CREATE TABLE attendance (
    attendance_id   NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    registration_id NUMBER NOT NULL,
    att_date        DATE NOT NULL,
    status          VARCHAR2(10) NOT NULL,
    marked_by       NUMBER NOT NULL,
    created_at      TIMESTAMP DEFAULT SYSDATE,
    updated_at      TIMESTAMP DEFAULT SYSDATE,
    FOREIGN KEY (registration_id) REFERENCES registration(registration_id),
    FOREIGN KEY (marked_by) REFERENCES faculties(faculty_id),
    CONSTRAINT chk_att_status CHECK (status IN ('Present', 'Absent', 'Leave'))
);

-- 15. RESULTS TABLE
CREATE TABLE results (
    result_id       NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    registration_id NUMBER NOT NULL,
    marks_obtained  NUMBER(5,2) NOT NULL,
    total_marks     NUMBER(5,2) NOT NULL,
    grade           VARCHAR2(2),
    result_date     DATE NOT NULL,
    created_at      TIMESTAMP DEFAULT SYSDATE,
    updated_at      TIMESTAMP DEFAULT SYSDATE,
    FOREIGN KEY (registration_id) REFERENCES registration(registration_id),
    CONSTRAINT uk_results UNIQUE (registration_id)
);

-- 16. PROJECTS TABLE
CREATE TABLE projects (
    project_id      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    course_id       NUMBER NOT NULL,
    project_type    VARCHAR2(30) NOT NULL,
    min_team_size   NUMBER DEFAULT 1,
    max_team_size   NUMBER DEFAULT 1,
    min_marks       NUMBER DEFAULT 0,
    created_at      TIMESTAMP DEFAULT SYSDATE,
    FOREIGN KEY (course_id) REFERENCES courses(course_id),
    CONSTRAINT uk_project_course UNIQUE (course_id),
    CONSTRAINT chk_project_type CHECK (project_type IN ('Individual', 'Team'))
);

-- 17. PROJECT_OUTCOMES TABLE
CREATE TABLE project_outcomes (
    proj_outcome_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    project_id      NUMBER NOT NULL,
    outcome_number  VARCHAR2(10) NOT NULL,
    description     VARCHAR2(1000) NOT NULL,
    bloom_level     VARCHAR2(20) NOT NULL,
    created_at      TIMESTAMP DEFAULT SYSDATE,
    FOREIGN KEY (project_id) REFERENCES projects(project_id),
    CONSTRAINT uk_project_outcome UNIQUE (project_id, outcome_number),
    CONSTRAINT chk_proj_bloom_level CHECK (bloom_level IN ('Remember', 'Understand', 'Apply', 'Analyze', 'Evaluate', 'Create'))
);

-- 18. PROJECT_PO_MAPPING TABLE
CREATE TABLE project_po_mapping (
    proj_outcome_id NUMBER NOT NULL,
    po_id           NUMBER NOT NULL,
    mapping_level   VARCHAR2(10) NOT NULL,
    created_at      TIMESTAMP DEFAULT SYSDATE,
    PRIMARY KEY (proj_outcome_id, po_id),
    FOREIGN KEY (proj_outcome_id) REFERENCES project_outcomes(proj_outcome_id),
    FOREIGN KEY (po_id) REFERENCES program_outcomes(po_id),
    CONSTRAINT chk_proj_mapping_level CHECK (mapping_level IN ('Low', 'Medium', 'High'))
);

-- 19. PROJECT_REGISTRATION TABLE
CREATE TABLE project_registration (
    project_reg_id  NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id      NUMBER NOT NULL,
    sem_course_id   NUMBER NOT NULL,
    registration_date DATE NOT NULL,
    status          VARCHAR2(15) DEFAULT 'Active',
    created_at      TIMESTAMP DEFAULT SYSDATE,
    updated_at      TIMESTAMP DEFAULT SYSDATE,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (sem_course_id) REFERENCES semester_courses(sem_course_id),
    CONSTRAINT uk_project_registration UNIQUE (student_id, sem_course_id)
);

-- 20. PROJECT_RESULTS TABLE
CREATE TABLE project_results (
    project_result_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    project_reg_id    NUMBER NOT NULL,
    marks_obtained    NUMBER(5,2) NOT NULL,
    total_marks       NUMBER(5,2) NOT NULL,
    grade             VARCHAR2(2),
    result_date       DATE NOT NULL,
    comments          VARCHAR2(1000),
    created_at        TIMESTAMP DEFAULT SYSDATE,
    updated_at        TIMESTAMP DEFAULT SYSDATE,
    FOREIGN KEY (project_reg_id) REFERENCES project_registration(project_reg_id),
    CONSTRAINT uk_project_results UNIQUE (project_reg_id)
);

--inserting program table
CREATE TABLE programs (
program_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
program_name VARCHAR2(100) NOT NULL,
degree VARCHAR2(20) NOT NULL,
department_id NUMBER NOT NULL,
FOREIGN KEY (department_id) REFERENCES departments(department_id)
);
commit;

-- =====================================================
-- COMMIT ALL CHANGES
-- =====================================================

COMMIT;

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

SELECT table_name FROM user_tables 
WHERE table_name IN (
    'DEPARTMENTS', 'STUDENTS', 'FACULTIES', 'COURSES', 
    'COURSE_OUTCOMES', 'PROGRAM_OUTCOMES', 'CO_PO_MAPPING', 
    'SEMESTERS', 'SEMESTER_COURSES', 'REGISTRATION', 
    'ATTENDANCE', 'RESULTS', 'STUDENT_ADVISOR_ASSIGNMENT',
    'PROJECTS', 'PROJECT_OUTCOMES', 'PROJECT_PO_MAPPING',
    'PROJECT_REGISTRATION', 'PROJECT_RESULTS', 'ASSESSMENT_TYPES',
    'COURSE_ASSESSMENT'
)
ORDER BY table_name;

SELECT COUNT(*) as total_tables FROM user_tables 
WHERE table_name IN (
    'DEPARTMENTS', 'STUDENTS', 'FACULTIES', 'COURSES', 
    'COURSE_OUTCOMES', 'PROGRAM_OUTCOMES', 'CO_PO_MAPPING', 
    'SEMESTERS', 'SEMESTER_COURSES', 'REGISTRATION', 
    'ATTENDANCE', 'RESULTS', 'STUDENT_ADVISOR_ASSIGNMENT',
    'PROJECTS', 'PROJECT_OUTCOMES', 'PROJECT_PO_MAPPING',
    'PROJECT_REGISTRATION', 'PROJECT_RESULTS', 'ASSESSMENT_TYPES',
    'COURSE_ASSESSMENT'
);

