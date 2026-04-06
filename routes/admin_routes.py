from flask import Blueprint, render_template, request, send_file, redirect, session
from db import get_connection
from reportlab.pdfgen import canvas
import io

admin_bp = Blueprint("admin", __name__)


# Home route → shows enrollment page
@admin_bp.route("/admin/enroll-page", methods=["GET"])
def enroll_page():
    """Display student enrollment form with all departments"""
    
    conn = get_connection()
    cursor = conn.cursor()
    
    # Get all departments
    cursor.execute("SELECT department_id, department_name FROM departments ORDER BY department_name")
    departments = cursor.fetchall()
    
    cursor.close()
    conn.close()
    
    return render_template("admin_enroll.html", departments=departments)


# Handles student enrollment form submission
# Handles student enrollment form submission
@admin_bp.route("/admin/enroll", methods=["POST"])
def enroll_student():

    # Personal Details
    full_name = request.form.get("full_name")
    email = request.form.get("email")
    phone = request.form.get("phone")
    dob = request.form.get("dob")
    address = request.form.get("address")
    gender = request.form.get("gender")
    
    # Department
    department_id = request.form.get("department_id")
    
    # Educational Details - High School
    high_school_name = request.form.get("high_school_name")
    high_school_year = request.form.get("high_school_year")
    high_school_percentage = request.form.get("high_school_percentage")
    
    # Educational Details - Higher Secondary
    higher_sec_name = request.form.get("higher_sec_name")
    higher_sec_year = request.form.get("higher_sec_year")
    higher_sec_percentage = request.form.get("higher_sec_percentage")
    
    # Educational Details - UG (if PG student)
    ug_university = request.form.get("ug_university", "")
    ug_degree = request.form.get("ug_degree", "")
    ug_graduation_year = request.form.get("ug_graduation_year", "")
    ug_cgpa = request.form.get("ug_cgpa", "")
    
    # Password
    password = request.form.get("password")
    
    conn = get_connection()
    cursor = conn.cursor()

    try:
        # variable for RETURNING clause
        student_id_var = cursor.var(int)

        cursor.execute("""
            INSERT INTO students
            (full_name, email, phone, dob, address, department_id, enrollment_date, password_hash,
             gender, high_school_name, high_school_year, high_school_percentage,
             higher_sec_name, higher_sec_year, higher_sec_percentage,
             ug_university, ug_degree, ug_graduation_year, ug_cgpa)
            VALUES
            (:fn, :e, :ph, TO_DATE(:d,'YYYY-MM-DD'), :a, :dept, SYSDATE, :pw,
             :g, :hs_name, :hs_year, :hs_perc,
             :hsc_name, :hsc_year, :hsc_perc,
             :ug_univ, :ug_deg, :ug_grad_yr, :ug_cgpa_val)
            RETURNING student_id INTO :sid
        """, {
            "fn": full_name,
            "e": email,
            "ph": phone,
            "d": dob,
            "a": address,
            "dept": department_id,
            "pw": password,
            "g": gender,
            "hs_name": high_school_name,
            "hs_year": high_school_year,
            "hs_perc": high_school_percentage,
            "hsc_name": higher_sec_name,
            "hsc_year": higher_sec_year,
            "hsc_perc": higher_sec_percentage,
            "ug_univ": ug_university if ug_university else None,
            "ug_deg": ug_degree if ug_degree else None,
            "ug_grad_yr": ug_graduation_year if ug_graduation_year else None,
            "ug_cgpa_val": ug_cgpa if ug_cgpa else None,
            "sid": student_id_var
        })

        student_id = student_id_var.getvalue()[0]
        conn.commit()

        # -------- Generate PDF with Student ID and Credentials --------
        from reportlab.lib.pagesizes import letter
        from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer
        from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
        from reportlab.lib.units import inch
        from reportlab.lib import colors

        buffer = io.BytesIO()
        pdf = SimpleDocTemplate(buffer, pagesize=letter, topMargin=0.5*inch, bottomMargin=0.5*inch)
        
        elements = []
        styles = getSampleStyleSheet()
        
        # Title
        title_style = ParagraphStyle(
            'CustomTitle',
            parent=styles['Heading1'],
            fontSize=14,
            textColor=colors.HexColor('#1976d2'),
            spaceAfter=6,
            alignment=1  # Center
        )
        
        heading_style = ParagraphStyle(
            'CustomHeading',
            parent=styles['Heading2'],
            fontSize=11,
            textColor=colors.HexColor('#1565c0'),
            spaceAfter=6,
            spaceBefore=10
        )
        
        normal_style = ParagraphStyle(
            'CustomNormal',
            parent=styles['Normal'],
            fontSize=10,
            spaceAfter=4
        )

        # Add title
        elements.append(Paragraph("STUDENT ENROLLMENT APPLICATION & CREDENTIALS", title_style))
        elements.append(Spacer(1, 0.1*inch))

        # Personal Details Section
        elements.append(Paragraph("PERSONAL DETAILS", heading_style))
        personal_data = [
            [Paragraph("<b>Student ID:</b>", normal_style), Paragraph(f"{student_id}", normal_style)],
            [Paragraph("<b>Full Name:</b>", normal_style), Paragraph(f"{full_name}", normal_style)],
            [Paragraph("<b>Email:</b>", normal_style), Paragraph(f"{email}", normal_style)],
            [Paragraph("<b>Phone:</b>", normal_style), Paragraph(f"{phone}", normal_style)],
            [Paragraph("<b>Gender:</b>", normal_style), Paragraph(f"{gender}", normal_style)],
            [Paragraph("<b>Date of Birth:</b>", normal_style), Paragraph(f"{dob}", normal_style)],
            [Paragraph("<b>Address:</b>", normal_style), Paragraph(f"{address}", normal_style)],
        ]
        
        personal_table = Table(personal_data, colWidths=[2*inch, 4*inch])
        personal_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (0, -1), colors.HexColor('#e3f2fd')),
            ('TEXTCOLOR', (0, 0), (-1, -1), colors.black),
            ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
            ('FONTNAME', (0, 0), (-1, -1), 'Helvetica'),
            ('FONTSIZE', (0, 0), (-1, -1), 9),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
            ('GRID', (0, 0), (-1, -1), 0.5, colors.grey),
        ]))
        elements.append(personal_table)
        elements.append(Spacer(1, 0.15*inch))

        # Educational Details Section
        elements.append(Paragraph("EDUCATIONAL DETAILS", heading_style))
        
        edu_data = [
            [Paragraph("<b>High School:</b>", normal_style), ""],
            [Paragraph("  School Name:", normal_style), Paragraph(f"{high_school_name}", normal_style)],
            [Paragraph("  Graduation Year:", normal_style), Paragraph(f"{high_school_year}", normal_style)],
            [Paragraph("  Percentage:", normal_style), Paragraph(f"{high_school_percentage}%", normal_style)],
            [Paragraph("<b>Higher Secondary:</b>", normal_style), ""],
            [Paragraph("  School Name:", normal_style), Paragraph(f"{higher_sec_name}", normal_style)],
            [Paragraph("  Graduation Year:", normal_style), Paragraph(f"{higher_sec_year}", normal_style)],
            [Paragraph("  Percentage:", normal_style), Paragraph(f"{higher_sec_percentage}%", normal_style)],
        ]
        
        if ug_university:
            edu_data.extend([
                [Paragraph("<b>Undergraduate (UG):</b>", normal_style), ""],
                [Paragraph("  University:", normal_style), Paragraph(f"{ug_university}", normal_style)],
                [Paragraph("  Degree:", normal_style), Paragraph(f"{ug_degree}", normal_style)],
                [Paragraph("  Graduation Year:", normal_style), Paragraph(f"{ug_graduation_year}", normal_style)],
                [Paragraph("  CGPA:", normal_style), Paragraph(f"{ug_cgpa}", normal_style)],
            ])
        
        edu_table = Table(edu_data, colWidths=[2*inch, 4*inch])
        edu_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (0, -1), colors.HexColor('#f5f5f5')),
            ('TEXTCOLOR', (0, 0), (-1, -1), colors.black),
            ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
            ('FONTNAME', (0, 0), (-1, -1), 'Helvetica'),
            ('FONTSIZE', (0, 0), (-1, -1), 9),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
            ('GRID', (0, 0), (-1, -1), 0.5, colors.lightgrey),
        ]))
        elements.append(edu_table)
        elements.append(Spacer(1, 0.15*inch))

        # Credentials Section
        elements.append(Paragraph("LOGIN CREDENTIALS", heading_style))
        
        cred_data = [
            [Paragraph("<b>Username (Student ID):</b>", normal_style), Paragraph(f"{student_id}", normal_style)],
            [Paragraph("<b>Password:</b>", normal_style), Paragraph(f"{password}", normal_style)],
        ]
        
        cred_table = Table(cred_data, colWidths=[2*inch, 4*inch])
        cred_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (0, -1), colors.HexColor('#fff3e0')),
            ('TEXTCOLOR', (0, 0), (-1, -1), colors.black),
            ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
            ('FONTNAME', (0, 0), (-1, -1), 'Helvetica'),
            ('FONTSIZE', (0, 0), (-1, -1), 9),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
            ('GRID', (0, 0), (-1, -1), 1, colors.HexColor('#FF9800')),
        ]))
        elements.append(cred_table)
        elements.append(Spacer(1, 0.1*inch))

        # Important Instructions
        instructions_style = ParagraphStyle(
            'CustomInstructions',
            parent=styles['Normal'],
            fontSize=9,
            textColor=colors.HexColor('#c62828'),
            spaceAfter=3
        )
        
        elements.append(Paragraph("<b>IMPORTANT INSTRUCTIONS:</b>", instructions_style))
        elements.append(Paragraph("1. Keep this document safe and secure", instructions_style))
        elements.append(Paragraph("2. Use your Student ID to login to the portal", instructions_style))
        elements.append(Paragraph("3. Change your password after first login", instructions_style))
        elements.append(Paragraph("4. Contact admin in case of password issues", instructions_style))

        # Build PDF
        pdf.build(elements)
        buffer.seek(0)

        return send_file(
            buffer,
            as_attachment=True,
            download_name=f"student_enrollment_{student_id}.pdf",
            mimetype="application/pdf"
        )

    except Exception as e:
        conn.rollback()
        print(f"Error enrolling student: {str(e)}")
        return f"Error: {str(e)}", 400
    
    finally:
        cursor.close()
        conn.close()
# ==================== ADVISOR ASSIGNMENT ====================

@admin_bp.route("/admin/assign-advisor", methods=["GET"])
def assign_advisor_page():
    """Display advisor assignment form"""
    
    if session.get("role") != "admin":
        return "Unauthorized", 403
    
    conn = get_connection()
    cursor = conn.cursor()
    
    # Get all departments
    cursor.execute("SELECT department_id, department_name FROM departments ORDER BY department_name")
    departments = cursor.fetchall()
    
    # Get all advisors (faculty with is_advisor = 1)
    
    cursor.close()
    conn.close()
    
    return render_template(
        "assign_advisor.html",
        departments=departments
    )

@admin_bp.route("/admin/get-advisors-by-department", methods=["GET"])
def get_advisors_by_department():
    """Get all faculty members for a specific department (will set them as advisors)"""
    
    if session.get("role") != "admin":
        return "Unauthorized", 403
    
    department_id = request.args.get("department_id")
    
    if not department_id:
        return "", 400
    
    conn = get_connection()
    cursor = conn.cursor()
    
    # Get all faculty members from the department
    cursor.execute("""
        SELECT faculty_id, faculty_name, email, is_advisor
        FROM faculties 
        WHERE department_id = :dept_id
        ORDER BY faculty_name
    """, {"dept_id": department_id})
    
    faculty_members = cursor.fetchall()
    cursor.close()
    conn.close()
    
    # Return as HTML options
    html = '<option value="">Select a Faculty Member to Assign as Advisor</option>'
    for faculty in faculty_members:
        advisor_status = " ✓ (Already Advisor)" if faculty[3] == 1 else ""
        html += f'<option value="{faculty[0]}">{faculty[1]} (ID: {faculty[0]}){advisor_status}</option>'
    
    return html


@admin_bp.route("/admin/get-students-for-advisor", methods=["POST"])
def get_students_for_advisor():
    """Get students based on department, year, and session"""
    
    if session.get("role") != "admin":
        return "Unauthorized", 403
    
    department_id = request.form.get("department_id")
    faculty_id = request.form.get("faculty_id")
    year = request.form.get("year")
    session_type = request.form.get("session_type")
    
    if not department_id or not faculty_id:
        return redirect("/admin/assign-advisor")
    
    conn = get_connection()
    cursor = conn.cursor()
    
    # First, set the selected faculty as advisor if not already
    cursor.execute("""
        UPDATE faculties
        SET is_advisor = 1
        WHERE faculty_id = :fid
    """, {"fid": faculty_id})
    conn.commit()
    
    # Get faculty details
    cursor.execute("""
        SELECT faculty_id, faculty_name, email
        FROM faculties
        WHERE faculty_id = :fid
    """, {"fid": faculty_id})
    
    selected_faculty = cursor.fetchone()
    
    # Build query to get students with their program/course info
    query = """
        SELECT DISTINCT 
            s.student_id,
            s.full_name,
            s.email,
            d.department_name,
            COALESCE(f.faculty_name, 'Not Assigned') as advisor_name,
            p.program_name,
            COUNT(DISTINCT r.registration_id) as courses_registered
        FROM students s
        JOIN departments d ON s.department_id = d.department_id
        LEFT JOIN student_advisor_assignment saa ON s.student_id = saa.student_id
        LEFT JOIN faculties f ON saa.faculty_id = f.faculty_id
        LEFT JOIN programs p ON d.department_id = p.department_id
        LEFT JOIN registration r ON s.student_id = r.student_id
        WHERE s.department_id = :dept_id
    """
    
    params = {"dept_id": department_id}
    
    # If year and session provided, filter by semester
    if year and session_type:
        query += """
            AND s.student_id IN (
                SELECT DISTINCT r.student_id
                FROM registration r
                JOIN semester_courses sc ON r.sem_course_id = sc.sem_course_id
                JOIN semesters sem ON sc.semester_id = sem.semester_id
                WHERE sem.yr = :year AND sem.sess = :sess
            )
        """
        params["year"] = year
        params["sess"] = session_type
    
    query += " GROUP BY s.student_id, s.full_name, s.email, d.department_name, f.faculty_name, p.program_name ORDER BY s.full_name"
    
    cursor.execute(query, params)
    students = cursor.fetchall()
    cursor.close()
    conn.close()
    
    return render_template(
        "advisor_student_list.html",
        students=students,
        selected_faculty=selected_faculty,
        department_id=department_id,
        faculty_id=faculty_id,
        year=year,
        session_type=session_type
    )

@admin_bp.route("/admin/assign-advisor-submit", methods=["POST"])
def assign_advisor_submit():
    """Assign advisor to selected students and set them as advisor"""
    
    if session.get("role") != "admin":
        return "Unauthorized", 403
    
    faculty_id = request.form.get("faculty_id")
    student_ids = request.form.getlist("student_ids")
    department_id = request.form.get("department_id")
    year = request.form.get("year")
    session_type = request.form.get("session_type")
    
    if not faculty_id or not student_ids:
        return redirect("/admin/assign-advisor")
    
    conn = get_connection()
    cursor = conn.cursor()
    
    # Ensure faculty is marked as advisor
    cursor.execute("""
        UPDATE faculties
        SET is_advisor = 1
        WHERE faculty_id = :fid
    """, {"fid": faculty_id})
    
    success_count = 0
    
    for student_id in student_ids:
        try:
            # Check if assignment already exists
            cursor.execute("""
                SELECT student_id FROM student_advisor_assignment
                WHERE student_id = :sid
            """, {"sid": student_id})
            
            existing = cursor.fetchone()
            
            if existing:
                # Update existing
                cursor.execute("""
                    UPDATE student_advisor_assignment
                    SET faculty_id = :fid,
                        assignment_date = SYSDATE,
                        updated_at = SYSDATE
                    WHERE student_id = :sid
                """, {"fid": faculty_id, "sid": student_id})
            else:
                # Insert new
                cursor.execute("""
                    INSERT INTO student_advisor_assignment
                    (student_id, faculty_id, assignment_date, created_at, updated_at)
                    VALUES (:sid, :fid, SYSDATE, SYSDATE, SYSDATE)
                """, {"sid": student_id, "fid": faculty_id})
            
            success_count += 1
        
        except Exception as e:
            print(f"Error assigning student {student_id}: {str(e)}")
            continue
    
    conn.commit()
    cursor.close()
    conn.close()
    
    return render_template(
        "advisor_assignment_success.html",
        success_count=success_count,
        total_count=len(student_ids),
        faculty_id=faculty_id,
        department_id=department_id,
        year=year,
        session_type=session_type
    )
    
@admin_bp.route("/admin/view-advisor-assignments")
def view_advisor_assignments():
    """View all advisor assignments"""
    
    if session.get("role") != "admin":
        return "Unauthorized", 403
    
    conn = get_connection()
    cursor = conn.cursor()
    
    cursor.execute("""
        SELECT 
            f.faculty_id,
            f.faculty_name,
            f.email,
            COUNT(saa.student_id) as student_count,
            d.department_name
        FROM faculties f
        LEFT JOIN student_advisor_assignment saa ON f.faculty_id = saa.faculty_id
        LEFT JOIN departments d ON f.department_id = d.department_id
        WHERE f.is_advisor = 1
        GROUP BY f.faculty_id, f.faculty_name, f.email, d.department_name
        ORDER BY f.faculty_name
    """)
    
    assignments = cursor.fetchall()
    cursor.close()
    conn.close()
    
    return render_template(
        "view_advisor_assignment.html",
        assignments=assignments
    )


@admin_bp.route("/admin/advisor-details/<faculty_id>")
def advisor_details(faculty_id):
    """View students assigned to a specific advisor"""
    
    if session.get("role") != "admin":
        return "Unauthorized", 403
    
    conn = get_connection()
    cursor = conn.cursor()
    
    # Get advisor info
    cursor.execute("""
        SELECT faculty_id, faculty_name, email, phone
        FROM faculties
        WHERE faculty_id = :fid
    """, {"fid": faculty_id})
    
    advisor = cursor.fetchone()
    
    if not advisor:
        cursor.close()
        conn.close()
        return "Advisor not found", 404
    
    # Get assigned students
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
    """, {"fid": faculty_id})
    
    students = cursor.fetchall()
    cursor.close()
    conn.close()
    
    return render_template(
        "advisor_details.html",
        advisor=advisor,
        students=students
    )


@admin_bp.route("/admin/remove-advisor/<student_id>", methods=["POST"])
def remove_advisor(student_id):
    """Remove advisor assignment from a student"""
    
    if session.get("role") != "admin":
        return "Unauthorized", 403
    
    conn = get_connection()
    cursor = conn.cursor()
    
    cursor.execute("""
        DELETE FROM student_advisor_assignment
        WHERE student_id = :sid
    """, {"sid": student_id})
    
    conn.commit()
    cursor.close()
    conn.close()
    
    return redirect(f"/admin/advisor-details/{request.form.get('faculty_id')}")