from flask import Blueprint, render_template, redirect, session
from db import get_connection

advisor_bp = Blueprint("advisor", __name__)


@advisor_bp.route("/advisor/dashboard")
def advisor_dashboard():

    if session.get("role") != "advisor":
        return "Unauthorized", 403
    
    advisor_id = session.get("advisor_id")
    
    conn = get_connection()
    cursor = conn.cursor()

    # Get pending registrations from assigned students
    cursor.execute("""
    SELECT
        r.registration_id,
        s.full_name,
        s.student_id,
        c.course_name,
        c.course_code,
        r.status,
        r.registration_date
    FROM registration r
    JOIN students s ON r.student_id = s.student_id
    JOIN student_advisor_assignment saa ON s.student_id = saa.student_id
    JOIN semester_courses sc ON r.sem_course_id = sc.sem_course_id
    JOIN courses c ON sc.course_id = c.course_id
    WHERE saa.faculty_id = :fid
    AND r.status = 'Pending'
    ORDER BY r.registration_date ASC
    """, {"fid": advisor_id})

    registrations = cursor.fetchall()
    
    # Get statistics
    cursor.execute("""
        SELECT COUNT(DISTINCT saa.student_id)
        FROM student_advisor_assignment saa
        WHERE saa.faculty_id = :fid
    """, {"fid": advisor_id})
    
    total_students = cursor.fetchone()[0]
    
    cursor.execute("""
        SELECT COUNT(*)
        FROM registration r
        JOIN students s ON r.student_id = s.student_id
        JOIN student_advisor_assignment saa ON s.student_id = saa.student_id
        WHERE saa.faculty_id = :fid AND r.status = 'Pending'
    """, {"fid": advisor_id})
    
    pending_count = cursor.fetchone()[0]
    
    cursor.close()
    conn.close()

    return render_template(
        "advisor_dashboard.html",
        registrations=registrations,
        total_students=total_students,
        pending_count=pending_count
    )


@advisor_bp.route("/advisor/approve/<reg_id>")
def approve(reg_id):

    if session.get("role") != "advisor":
        return "Unauthorized", 403

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
    UPDATE registration
    SET status='Active'
    WHERE registration_id=:id
    """, {"id": reg_id})

    conn.commit()
    cursor.close()
    conn.close()

    return redirect("/advisor/dashboard")


@advisor_bp.route("/advisor/reject/<reg_id>", methods=["POST"])
def reject(reg_id):

    if session.get("role") != "advisor":
        return "Unauthorized", 403

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
    DELETE FROM registration
    WHERE registration_id = :id
    """, {"id": reg_id})

    conn.commit()
    cursor.close()
    conn.close()

    return redirect("/advisor/dashboard")


@advisor_bp.route("/advisor/attendance")
def advisor_attendance():

    if session.get("role") != "advisor":
        return "Unauthorized", 403
    
    advisor_id = session.get("advisor_id")

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
    SELECT
        s.full_name,
        s.student_id,
        c.course_name,
        c.course_code,
        a.att_date,
        a.status,
        COUNT(*) as total_classes
    FROM attendance a
    JOIN registration r ON a.registration_id = r.registration_id
    JOIN students s ON r.student_id = s.student_id
    JOIN student_advisor_assignment saa ON s.student_id = saa.student_id
    JOIN semester_courses sc ON r.sem_course_id = sc.sem_course_id
    JOIN courses c ON sc.course_id = c.course_id
    WHERE saa.faculty_id = :fid
    GROUP BY s.full_name, s.student_id, c.course_name, c.course_code, 
             a.att_date, a.status
    ORDER BY a.att_date DESC
    """, {"fid": advisor_id})

    data = cursor.fetchall()
    cursor.close()
    conn.close()

    return render_template("advisor_attendance.html", data=data)


@advisor_bp.route("/advisor/results")
def advisor_results():

    if session.get("role") != "advisor":
        return "Unauthorized", 403
    
    advisor_id = session.get("advisor_id")

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
    SELECT
        s.full_name,
        s.student_id,
        c.course_name,
        c.course_code,
        res.marks_obtained,
        res.total_marks,
        res.grade
    FROM results res
    JOIN registration r ON res.registration_id = r.registration_id
    JOIN students s ON r.student_id = s.student_id
    JOIN student_advisor_assignment saa ON s.student_id = saa.student_id
    JOIN semester_courses sc ON r.sem_course_id = sc.sem_course_id
    JOIN courses c ON sc.course_id = c.course_id
    WHERE saa.faculty_id = :fid
    ORDER BY s.full_name, c.course_code
    """, {"fid": advisor_id})

    results = cursor.fetchall()
    cursor.close()
    conn.close()

    return render_template("advisor_results.html", results=results)


# ==================== NEW: MY STUDENTS ====================

@advisor_bp.route("/advisor/my-students")
def my_students():
    """View all students assigned to this advisor"""
    
    if session.get("role") != "advisor":
        return "Unauthorized", 403
    
    advisor_id = session.get("advisor_id")
    
    conn = get_connection()
    cursor = conn.cursor()
    
    cursor.execute("""
        SELECT 
            s.student_id,
            s.full_name,
            s.email,
            d.department_name,
            saa.assignment_date
        FROM student_advisor_assignment saa
        JOIN students s ON saa.student_id = s.student_id
        JOIN departments d ON s.department_id = d.department_id
        WHERE saa.faculty_id = :fid
        ORDER BY s.full_name
    """, {"fid": advisor_id})
    
    students = cursor.fetchall()
    cursor.close()
    conn.close()
    
    return render_template(
        "advisor_my_students.html",
        students=students
    )


@advisor_bp.route("/advisor/student-details/<student_id>")
def student_details(student_id):
    """View detailed information for a student assigned to this advisor"""
    
    if session.get("role") != "advisor":
        return "Unauthorized", 403
    
    advisor_id = session.get("advisor_id")
    
    conn = get_connection()
    cursor = conn.cursor()
    
    # Verify student is assigned to this advisor
    cursor.execute("""
        SELECT s.student_id, s.full_name, s.email, s.phone,
               s.dob, s.enrollment_date, d.department_name
        FROM students s
        JOIN departments d ON s.department_id = d.department_id
        JOIN student_advisor_assignment saa ON s.student_id = saa.student_id
        WHERE s.student_id = :sid AND saa.faculty_id = :fid
    """, {"sid": student_id, "fid": advisor_id})
    
    student = cursor.fetchone()
    
    if not student:
        cursor.close()
        conn.close()
        return "Unauthorized", 403
    
    # Get student registrations and course details
    cursor.execute("""
        SELECT 
            c.course_name,
            c.course_code,
            r.status,
            r.registration_date,
            f.faculty_name,
            COALESCE(res.grade, 'N/A') as grade,
            COUNT(a.attendance_id) as attendance_count
        FROM registration r
        JOIN semester_courses sc ON r.sem_course_id = sc.sem_course_id
        JOIN courses c ON sc.course_id = c.course_id
        JOIN faculties f ON sc.faculty_id = f.faculty_id
        LEFT JOIN results res ON r.registration_id = res.registration_id
        LEFT JOIN attendance a ON r.registration_id = a.registration_id
        WHERE r.student_id = :sid
        GROUP BY c.course_name, c.course_code, r.status, r.registration_date,
                 f.faculty_name, res.grade
        ORDER BY r.registration_date DESC
    """, {"sid": student_id})
    
    courses = cursor.fetchall()
    cursor.close()
    conn.close()
    
    return render_template(
        "advisor_student_details.html",
        student=student,
        courses=courses
    )