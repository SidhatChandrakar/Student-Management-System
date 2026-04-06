from flask import Blueprint, render_template, request, redirect, session
from db import get_connection

student_bp = Blueprint("student", __name__)


# @student_bp.route("/login")
# def login_page():
#     return render_template("login.html")


@student_bp.route("/student/login", methods=["POST"])
def login():

    student_id = request.form["student_id"]
    password = request.form["password"]
    session_type = request.form["session"]
    year = request.form["year"]

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
    SELECT student_id
    FROM students
    WHERE student_id=:id AND password_hash=:pw
    """, {"id": student_id, "pw": password})

    user = cursor.fetchone()

    if user:
        session["student_id"] = student_id
        session["session_type"] = session_type
        session["year"] = year
        session["role"] = "student"
        cursor.close()
        conn.close()
        return redirect("/student/dashboard")

    cursor.close()
    conn.close()
    return "Invalid login"

@student_bp.route("/student/dashboard")
def dashboard():

    if session.get("role") != "student":
        return "Unauthorized", 403

    student_id = session.get("student_id")
    session_type = session.get("session_type")
    year = session.get("year")

    conn = get_connection()
    cursor = conn.cursor()

    # Get student info
    cursor.execute("""
        SELECT full_name, email, department_id
        FROM students
        WHERE student_id = :sid
    """, {"sid": student_id})
    
    student_info = cursor.fetchone()

    # Get semester ID for this year and session
    cursor.execute("""
        SELECT semester_id
        FROM semesters
        WHERE yr = :yr AND sess = :sess
    """, {"yr": year, "sess": session_type})
    
    semester = cursor.fetchone()
    semester_id = semester[0] if semester else None

    # Courses offered in this semester
    if semester_id:
        cursor.execute("""
        SELECT
        sc.sem_course_id,
        c.course_code,
        c.course_name,
        c.credits,
        f.faculty_name
        FROM semester_courses sc
        JOIN courses c ON sc.course_id = c.course_id
        JOIN faculties f ON sc.faculty_id = f.faculty_id
        WHERE sc.semester_id = :sem_id
        ORDER BY c.course_code
        """, {"sem_id": semester_id})
    else:
        cursor.execute("SELECT 1 WHERE 0=1")  # Empty result
    
    courses = cursor.fetchall()

    # Courses already registered by this student
    cursor.execute("""
    SELECT sem_course_id, status
    FROM registration
    WHERE student_id = :sid
    """, {"sid": student_id})

    registered = cursor.fetchall()
    registered_dict = {r[0]: r[1] for r in registered}

    # Student's course details with attendance, grades, and advisor approval status
    cursor.execute("""
    SELECT
        c.course_name,
        c.course_code,
        r.status,
        COUNT(a.attendance_id) as attendance_count,
        COALESCE(res.grade, 'N/A') as grade,
        f.faculty_name,
        r.registration_date
    FROM registration r
    JOIN semester_courses sc ON r.sem_course_id = sc.sem_course_id
    JOIN courses c ON sc.course_id = c.course_id
    JOIN faculties f ON sc.faculty_id = f.faculty_id
    LEFT JOIN attendance a ON r.registration_id = a.registration_id
    LEFT JOIN results res ON r.registration_id = res.registration_id
    WHERE r.student_id = :sid
    GROUP BY c.course_name, c.course_code, r.status, f.faculty_name, 
             r.registration_date, res.grade
    ORDER BY r.registration_date DESC
    """, {"sid": student_id})

    results = cursor.fetchall()
    
    cursor.close()
    conn.close()

    return render_template(
        "student_dashboard.html",
        student_name=student_info[0] if student_info else "Student",
        courses=courses,
        registered=registered_dict,
        results=results,
        session_type=session_type,
        year=year
    )

@student_bp.route("/student/register/<sem_course_id>")
def register(sem_course_id):

    if session.get("role") != "student":
        return "Unauthorized", 403

    student_id = session["student_id"]

    conn = get_connection()
    cursor = conn.cursor()

    # Check if already registered
    cursor.execute("""
    SELECT registration_id
    FROM registration
    WHERE student_id = :sid AND sem_course_id = :cid
    """, {"sid": student_id, "cid": sem_course_id})

    if cursor.fetchone():
        cursor.close()
        conn.close()
        return redirect("/student/dashboard")

    # Insert with Pending status
    cursor.execute("""
    INSERT INTO registration
    (student_id, sem_course_id, registration_date, status)
    VALUES (:sid,:cid,SYSDATE,'Pending')
    """, {"sid": student_id, "cid": sem_course_id})

    conn.commit()
    cursor.close()
    conn.close()

    return redirect("/student/dashboard")

@student_bp.route("/student/register", methods=["POST"])
def register_courses():

    if session.get("role") != "student":
        return "Unauthorized", 403

    student_id = session.get("student_id")
    selected_courses = request.form.getlist("courses")

    conn = get_connection()
    cursor = conn.cursor()

    for sem_course_id in selected_courses:

        # Check if already registered
        cursor.execute("""
        SELECT registration_id
        FROM registration
        WHERE student_id = :sid
        AND sem_course_id = :cid
        """, {"sid": student_id, "cid": sem_course_id})

        existing = cursor.fetchone()

        # Only insert if not already registered
        if not existing:

            cursor.execute("""
            INSERT INTO registration
            (student_id, sem_course_id, registration_date, status)
            VALUES (:sid, :cid, SYSDATE, 'Pending')
            """, {"sid": student_id, "cid": sem_course_id})

    conn.commit()
    cursor.close()
    conn.close()

    return redirect("/student/dashboard")