-- Supabase SQL Schema for School Management System

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Function to execute arbitrary SQL (Required for migrations and SQL Editor)
-- This version is designed to handle both data-modifying commands and selection queries.
DROP FUNCTION IF EXISTS exec_sql(text);
CREATE OR REPLACE FUNCTION exec_sql(sql_query text)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    result jsonb;
BEGIN
    -- For selection queries, we try to capture the result set as JSON
    IF sql_query ILIKE 'select%' THEN
        EXECUTE 'SELECT jsonb_agg(t) FROM (' || sql_query || ') t' INTO result;
        RETURN result;
    ELSE
        -- For other commands, we just execute and return a success status
        EXECUTE sql_query;
        RETURN jsonb_build_object('status', 'success');
    END IF;
EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object('status', 'error', 'message', SQLERRM);
END;
$$;

-- Master Data Management
CREATE TABLE IF NOT EXISTS academic_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    year TEXT UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS classes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS sections (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS castes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS religions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS titles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS subjects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS genders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- School Profile & Settings
CREATE TABLE IF NOT EXISTS school_profile (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_name TEXT NOT NULL,
    contact_number TEXT,
    gst_number TEXT,
    registration_number TEXT,
    school_email TEXT,
    current_academic_session TEXT,
    school_address TEXT,
    school_logo_url TEXT,
    principal_signature_url TEXT,
    class_teacher_signature_url TEXT,
    official_stamp_url TEXT,
    tax_percentage NUMERIC DEFAULT 0,
    warden_id TEXT,
    warden_password TEXT,
    fee_qr_url TEXT,
    fee_upi_id TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS camera_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    camera_name TEXT NOT NULL,
    camera_url TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Front Office Module
CREATE TABLE IF NOT EXISTS enquiries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_name TEXT NOT NULL,
    father_name TEXT,
    mobile TEXT NOT NULL,
    class TEXT,
    source TEXT,
    date DATE DEFAULT CURRENT_DATE,
    description TEXT,
    status TEXT DEFAULT 'Pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS visitors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    mobile TEXT NOT NULL,
    role TEXT,
    purpose TEXT,
    qualification TEXT,
    note TEXT,
    date DATE DEFAULT CURRENT_DATE,
    in_time TEXT,
    out_time TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS complaints (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    complainant_name TEXT NOT NULL,
    complaint_type TEXT,
    source TEXT,
    date DATE DEFAULT CURRENT_DATE,
    description TEXT,
    status TEXT DEFAULT 'Pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Student Management
CREATE TABLE IF NOT EXISTS students (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id TEXT UNIQUE NOT NULL,
    title TEXT,
    first_name TEXT NOT NULL,
    surname TEXT NOT NULL,
    student_type TEXT DEFAULT 'Old',
    academic_session TEXT,
    class_name TEXT NOT NULL,
    section_name TEXT NOT NULL,
    roll_number TEXT,
    caste TEXT,
    category TEXT,
    religion TEXT,
    gender TEXT,
    date_of_birth DATE,
    blood_group TEXT,
    email TEXT,
    aadhaar_number TEXT,
    pan_number TEXT,
    passport_number TEXT,
    father_name TEXT,
    mother_name TEXT,
    father_mobile TEXT,
    mother_mobile TEXT,
    father_income TEXT,
    father_source_of_income TEXT,
    mother_income TEXT,
    mother_source_of_income TEXT,
    residential_address TEXT,
    emergency_contact TEXT,
    local_guardian_contact TEXT,
    allergies TEXT,
    disability TEXT DEFAULT 'No',
    disability_details TEXT,
    photo_url TEXT,
    relations JSONB DEFAULT '[]',
    documents JSONB DEFAULT '[]',
    admission_date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Leave Management
CREATE TABLE IF NOT EXISTS leave_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id_text TEXT, -- The ST-XXXX ID
    student_name TEXT,
    class_name TEXT,
    section_name TEXT,
    start_date DATE,
    end_date DATE,
    reason TEXT,
    status TEXT DEFAULT 'Pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Calendar Module
CREATE TABLE IF NOT EXISTS calendar_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    event_date DATE NOT NULL,
    event_type TEXT DEFAULT 'event',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Fee Management
CREATE TABLE IF NOT EXISTS fee_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS fee_master (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    class_name TEXT NOT NULL,
    fee_type TEXT NOT NULL,
    amount NUMERIC NOT NULL,
    frequency TEXT NOT NULL, -- 'Monthly', 'Yearly', etc.
    student_type TEXT NOT NULL, -- 'New', 'Old', 'Both'
    academic_session TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS fee_collections (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id TEXT NOT NULL,
    student_name TEXT,
    class TEXT,
    section TEXT,
    fee_type TEXT,
    amount NUMERIC NOT NULL,
    discount NUMERIC DEFAULT 0,
    discount_reason TEXT,
    scholarship NUMERIC DEFAULT 0,
    fine NUMERIC DEFAULT 0,
    total_paid NUMERIC NOT NULL,
    payment_mode TEXT,
    transaction_id TEXT,
    invoice_number TEXT,
    collected_by TEXT,
    month TEXT,
    date DATE DEFAULT CURRENT_DATE,
    due_date DATE,
    status TEXT, -- 'Paid', 'Partial', 'Due'
    breakdown JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS contra_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    type TEXT NOT NULL, -- 'Bank to Cash', 'Cash to Bank', 'Bank Adjustment', 'Cash Adjustment'
    amount NUMERIC NOT NULL,
    reference TEXT,
    date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Finance Module (Income & Expense)
CREATE TABLE IF NOT EXISTS income_heads (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS expense_heads (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS incomes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    income_head TEXT,
    invoice_number TEXT,
    date DATE DEFAULT CURRENT_DATE,
    amount NUMERIC NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS expenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    expense_head TEXT,
    invoice_number TEXT,
    date DATE DEFAULT CURRENT_DATE,
    amount NUMERIC NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User Management
CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY, -- Using staff_id or student_id as ID
    username TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    password TEXT NOT NULL DEFAULT '123',
    role TEXT NOT NULL,
    permissions JSONB DEFAULT '[]',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Human Resource
CREATE TABLE IF NOT EXISTS departments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS designations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS staff (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    staff_id TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    surname TEXT NOT NULL,
    date_of_birth DATE,
    email TEXT,
    mobile TEXT,
    role TEXT NOT NULL,
    department TEXT,
    designation TEXT,
    joining_date DATE DEFAULT CURRENT_DATE,
    photo TEXT,
    status TEXT DEFAULT 'Active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS staff_leave_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    staff_id TEXT NOT NULL,
    staff_name TEXT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    reason TEXT,
    status TEXT DEFAULT 'Pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS staff_attendance (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    staff_id TEXT NOT NULL,
    staff_name TEXT,
    role TEXT,
    attendance_date DATE DEFAULT CURRENT_DATE,
    attendance_time TIME DEFAULT CURRENT_TIME,
    method TEXT, -- 'Manual', 'QR', etc.
    status TEXT, -- 'Present', 'Absent', etc.
    ip_address TEXT,
    location TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Notice Board
CREATE TABLE IF NOT EXISTS notices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT DEFAULT 'Info', -- 'Info', 'Warning', 'Success', 'Fee'
    target_roles JSONB, -- Array of roles
    date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Communication Templates
CREATE TABLE IF NOT EXISTS communication_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT UNIQUE NOT NULL,
    type TEXT NOT NULL, -- 'WhatsApp', 'SMS', 'Email'
    body TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Academics
CREATE TABLE IF NOT EXISTS time_table (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    class_name TEXT NOT NULL,
    section_name TEXT NOT NULL,
    day TEXT NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    subject TEXT NOT NULL,
    teacher_name TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS teacher_assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    academic_session TEXT NOT NULL,
    class_name TEXT NOT NULL,
    section_name TEXT NOT NULL,
    class_teacher_name TEXT,
    subject_teacher_assignments JSONB, -- Array of {subject, teacher}
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS syllabus (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    class_name TEXT NOT NULL,
    subject TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    file_url TEXT,
    posted_date DATE DEFAULT CURRENT_DATE,
    status TEXT DEFAULT 'Not Started',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS homework (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    class_name TEXT NOT NULL,
    section_name TEXT NOT NULL,
    subject TEXT NOT NULL,
    title TEXT NOT NULL,
    instructions TEXT,
    due_date DATE,
    file_url TEXT,
    posted_date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Student Attendance
CREATE TABLE IF NOT EXISTS student_attendance (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id TEXT NOT NULL,
    student_name TEXT,
    class_name TEXT,
    section_name TEXT,
    attendance_date DATE DEFAULT CURRENT_DATE,
    status TEXT, -- 'Present', 'Absent', 'Late', etc.
    period TEXT, -- 'Morning', 'Afternoon', etc.
    method TEXT, -- 'Manual', 'QR'
    ip_address TEXT,
    location TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Examination
CREATE TABLE IF NOT EXISTS exams (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    exam_name TEXT UNIQUE NOT NULL,
    exam_type TEXT DEFAULT 'Main',
    start_date DATE,
    end_date DATE,
    status TEXT DEFAULT 'Upcoming',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS exam_schedules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    exam_name TEXT NOT NULL,
    class_name TEXT NOT NULL,
    section_name TEXT NOT NULL,
    subject TEXT NOT NULL,
    exam_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    room_number TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS exam_results (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    exam_name TEXT NOT NULL,
    student_id TEXT NOT NULL,
    subject TEXT NOT NULL,
    marks_obtained NUMERIC,
    max_marks NUMERIC,
    feedback TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS report_card_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    template_name TEXT UNIQUE NOT NULL,
    terms JSONB, -- Array of terms and their sub-columns
    subjects JSONB, -- Array of subjects
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS report_cards (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id TEXT NOT NULL,
    template_id UUID REFERENCES report_card_templates(id),
    term_data JSONB, -- Nested object for term marks
    result TEXT,
    aggregate NUMERIC,
    percentage NUMERIC,
    rank TEXT,
    promotion_status TEXT,
    teacher_comments TEXT,
    is_published BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Hostel Management
CREATE TABLE IF NOT EXISTS hostel_rooms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    room_number TEXT UNIQUE NOT NULL,
    floor TEXT,
    category TEXT,
    price_per_month NUMERIC DEFAULT 0,
    capacity INTEGER DEFAULT 4,
    room_type TEXT DEFAULT 'Non-AC',
    gender TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS hostel_staff (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    role TEXT DEFAULT 'Warden',
    mobile TEXT,
    email TEXT,
    shift TEXT DEFAULT 'Day',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS hostel_beds (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    room_id UUID REFERENCES hostel_rooms(id) ON DELETE CASCADE,
    bed_number TEXT NOT NULL,
    status TEXT DEFAULT 'Available', -- 'Available', 'Occupied', 'Maintenance'
    student_id TEXT, -- References student_id from students table
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS hostel_attendance (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id TEXT NOT NULL,
    student_name TEXT,
    room_number TEXT,
    attendance_date DATE DEFAULT CURRENT_DATE,
    status TEXT,
    ip_address TEXT,
    location TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Initial Data Seeding
INSERT INTO academic_sessions (year) VALUES 
('2023-24'), ('2024-25'), ('2025-26'), ('2026-27'), ('2027-28'), ('2028-29')
ON CONFLICT (year) DO NOTHING;

INSERT INTO classes (name) VALUES 
('LKG'), ('UKG'), ('Class 1'), ('Class 2'), ('Class 3'), ('Class 4'), 
('Class 5'), ('Class 6'), ('Class 7'), ('Class 8'), ('Class 9'), 
('Class 10'), ('Class 11'), ('Class 12')
ON CONFLICT (name) DO NOTHING;

INSERT INTO sections (name) VALUES ('A'), ('B'), ('C'), ('D')
ON CONFLICT (name) DO NOTHING;

INSERT INTO categories (name) VALUES ('General'), ('OBC'), ('SC'), ('ST')
ON CONFLICT (name) DO NOTHING;

INSERT INTO castes (name) VALUES ('Hindu'), ('Muslim'), ('Sikh'), ('Christian')
ON CONFLICT (name) DO NOTHING;

INSERT INTO religions (name) VALUES 
('Hinduism'), ('Islam'), ('Sikhism'), ('Christianity'), ('Buddhism'), ('Jainism')
ON CONFLICT (name) DO NOTHING;

INSERT INTO titles (name) VALUES ('Mr.'), ('Miss'), ('Mrs.')
ON CONFLICT (name) DO NOTHING;

INSERT INTO genders (name) VALUES ('Male'), ('Female'), ('Others')
ON CONFLICT (name) DO NOTHING;

INSERT INTO subjects (name) VALUES 
('Mathematics'), ('Science'), ('English'), ('Social Studies'), ('Hindi'), ('Computer Science')
ON CONFLICT (name) DO NOTHING;

-- Enable Row Level Security (RLS) and Add Granular Policies
DO $$
DECLARE
    t text;
BEGIN
    FOR t IN 
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_type = 'BASE TABLE'
    LOOP
        -- Enable RLS
        EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', t);
        
        -- Drop the old blanket policy if it exists
        EXECUTE format('DROP POLICY IF EXISTS "Allow All" ON public.%I', t);
        
        -- 1. SELECT: Allow read access
        EXECUTE format('DROP POLICY IF EXISTS "Allow Select" ON public.%I', t);
        EXECUTE format('CREATE POLICY "Allow Select" ON public.%I FOR SELECT USING (true)', t);
        
        -- 2. INSERT: Allow write access
        EXECUTE format('DROP POLICY IF EXISTS "Allow Insert" ON public.%I', t);
        EXECUTE format('CREATE POLICY "Allow Insert" ON public.%I FOR INSERT WITH CHECK (auth.role() = ''anon'' OR auth.role() = ''authenticated'')', t);
        
        -- 3. UPDATE: Allow update access
        EXECUTE format('DROP POLICY IF EXISTS "Allow Update" ON public.%I', t);
        EXECUTE format('CREATE POLICY "Allow Update" ON public.%I FOR UPDATE USING (auth.role() = ''anon'' OR auth.role() = ''authenticated'') WITH CHECK (auth.role() = ''anon'' OR auth.role() = ''authenticated'')', t);
        
        -- 4. DELETE: Allow delete access
        EXECUTE format('DROP POLICY IF EXISTS "Allow Delete" ON public.%I', t);
        EXECUTE format('CREATE POLICY "Allow Delete" ON public.%I FOR DELETE USING (auth.role() = ''anon'' OR auth.role() = ''authenticated'')', t);
    END LOOP;
END $$;
-- 1. Add missing columns to students table
ALTER TABLE IF EXISTS public.students 
ADD COLUMN IF NOT EXISTS disability_details TEXT;

-- 2. Add missing columns to school_profile table
ALTER TABLE IF EXISTS public.school_profile 
ADD COLUMN IF NOT EXISTS fee_qr_url TEXT,
ADD COLUMN IF NOT EXISTS fee_upi_id TEXT;

-- 3. Ensure RLS policies allow authenticated/anonymous access for these operations
DO $$
DECLARE
    t text;
BEGIN
    FOR t IN 
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_type = 'BASE TABLE'
    LOOP
        -- Enable RLS
        EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', t);
        
        -- SELECT: Allow read access
        EXECUTE format('DROP POLICY IF EXISTS "Allow Select" ON public.%I', t);
        EXECUTE format('CREATE POLICY "Allow Select" ON public.%I FOR SELECT USING (true)', t);
        
        -- INSERT: Allow write access
        EXECUTE format('DROP POLICY IF EXISTS "Allow Insert" ON public.%I', t);
        EXECUTE format('CREATE POLICY "Allow Insert" ON public.%I FOR INSERT WITH CHECK (auth.role() = ''anon'' OR auth.role() = ''authenticated'')', t);
        
        -- UPDATE: Allow update access
        EXECUTE format('DROP POLICY IF EXISTS "Allow Update" ON public.%I', t);
        EXECUTE format('CREATE POLICY "Allow Update" ON public.%I FOR UPDATE USING (auth.role() = ''anon'' OR auth.role() = ''authenticated'') WITH CHECK (auth.role() = ''anon'' OR auth.role() = ''authenticated'')', t);
        
        -- DELETE: Allow delete access
        EXECUTE format('DROP POLICY IF EXISTS "Allow Delete" ON public.%I', t);
        EXECUTE format('CREATE POLICY "Allow Delete" ON public.%I FOR DELETE USING (auth.role() = ''anon'' OR auth.role() = ''authenticated'')', t);
    END LOOP;
END $$;
-- 1. Add missing columns to students table
ALTER TABLE IF EXISTS public.students 
ADD COLUMN IF NOT EXISTS photo_url TEXT,
ADD COLUMN IF NOT EXISTS disability_details TEXT,
ADD COLUMN IF NOT EXISTS documents JSONB DEFAULT '[]';

-- 2. Add missing columns to school_profile table
ALTER TABLE IF EXISTS public.school_profile 
ADD COLUMN IF NOT EXISTS fee_qr_url TEXT,
ADD COLUMN IF NOT EXISTS fee_upi_id TEXT;

-- 3. Refresh the schema cache (Reload PostgREST)
-- After running this, go to Settings -> API and click "Reload PostgREST" 
-- if the error persists.
-- Final Schema Fixes and Column Additions
-- Run this to ensure all required columns exist for Student Registration and Settings

-- 1. Add missing columns to students table
ALTER TABLE IF EXISTS public.students 
ADD COLUMN IF NOT EXISTS photo_url TEXT,
ADD COLUMN IF NOT EXISTS disability_details TEXT,
ADD COLUMN IF NOT EXISTS documents JSONB DEFAULT '[]',
ADD COLUMN IF NOT EXISTS relations JSONB DEFAULT '[]';

-- 2. Add missing columns to school_profile table
ALTER TABLE IF EXISTS public.school_profile 
ADD COLUMN IF NOT EXISTS fee_qr_url TEXT,
ADD COLUMN IF NOT EXISTS fee_upi_id TEXT;

-- 3. Ensure RLS policies are applied to all tables
DO $$
DECLARE
    t text;
BEGIN
    FOR t IN 
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_type = 'BASE TABLE'
    LOOP
        EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', t);
        
        EXECUTE format('DROP POLICY IF EXISTS "Allow Select" ON public.%I', t);
        EXECUTE format('CREATE POLICY "Allow Select" ON public.%I FOR SELECT USING (true)', t);
        
        EXECUTE format('DROP POLICY IF EXISTS "Allow Insert" ON public.%I', t);
        EXECUTE format('CREATE POLICY "Allow Insert" ON public.%I FOR INSERT WITH CHECK (auth.role() = ''anon'' OR auth.role() = ''authenticated'')', t);
        
        EXECUTE format('DROP POLICY IF EXISTS "Allow Update" ON public.%I', t);
        EXECUTE format('CREATE POLICY "Allow Update" ON public.%I FOR UPDATE USING (auth.role() = ''anon'' OR auth.role() = ''authenticated'') WITH CHECK (auth.role() = ''anon'' OR auth.role() = ''authenticated'')', t);
        
        EXECUTE format('DROP POLICY IF EXISTS "Allow Delete" ON public.%I', t);
        EXECUTE format('CREATE POLICY "Allow Delete" ON public.%I FOR DELETE USING (auth.role() = ''anon'' OR auth.role() = ''authenticated'')', t);
    END LOOP;
END $$;
-- Comprehensive Staff Table Schema Update
ALTER TABLE staff 
ADD COLUMN IF NOT EXISTS documents JSONB DEFAULT '[]'::jsonb,
ADD COLUMN IF NOT EXISTS residential_address TEXT,
ADD COLUMN IF NOT EXISTS login_id TEXT,
ADD COLUMN IF NOT EXISTS login_password TEXT,
ADD COLUMN IF NOT EXISTS father_name TEXT,
ADD COLUMN IF NOT EXISTS mother_name TEXT,
ADD COLUMN IF NOT EXISTS date_of_birth TEXT,
ADD COLUMN IF NOT EXISTS joining_date TEXT,
ADD COLUMN IF NOT EXISTS emergency_contact TEXT,
ADD COLUMN IF NOT EXISTS gender TEXT,
ADD COLUMN IF NOT EXISTS qualification TEXT,
ADD COLUMN IF NOT EXISTS experience TEXT,
ADD COLUMN IF NOT EXISTS photo TEXT,
ADD COLUMN IF NOT EXISTS staff_id TEXT,
ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'Active',
ADD COLUMN IF NOT EXISTS department TEXT,
ADD COLUMN IF NOT EXISTS designation TEXT;
