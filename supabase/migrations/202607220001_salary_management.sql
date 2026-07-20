-- Create salary_profiles table
CREATE TABLE salary_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    staff_id UUID NOT NULL REFERENCES staff(id) ON DELETE CASCADE,
    designation TEXT NOT NULL,
    basic_salary NUMERIC(12, 2) NOT NULL CHECK (basic_salary >= 0),
    effective_from DATE NOT NULL,
    effective_to DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Create salary_advances table
CREATE TABLE salary_advances (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    staff_id UUID NOT NULL REFERENCES staff(id) ON DELETE CASCADE,
    amount NUMERIC(12, 2) NOT NULL CHECK (amount > 0),
    reason TEXT,
    advance_date DATE NOT NULL DEFAULT CURRENT_DATE,
    is_adjusted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Create salary_payrolls table
CREATE TABLE salary_payrolls (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    staff_id UUID NOT NULL REFERENCES staff(id) ON DELETE CASCADE,
    month INTEGER NOT NULL CHECK (month BETWEEN 1 AND 12),
    year INTEGER NOT NULL CHECK (year >= 2000),
    working_days INTEGER NOT NULL CHECK (working_days >= 0),
    present_days INTEGER NOT NULL CHECK (present_days >= 0),
    leave_days INTEGER NOT NULL CHECK (leave_days >= 0),
    basic_salary NUMERIC(12, 2) NOT NULL CHECK (basic_salary >= 0),
    attendance_deduction NUMERIC(12, 2) NOT NULL DEFAULT 0,
    advance_deduction NUMERIC(12, 2) NOT NULL DEFAULT 0,
    net_salary NUMERIC(12, 2) NOT NULL CHECK (net_salary >= 0),
    payment_status TEXT NOT NULL DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'partial')),
    payment_mode TEXT CHECK (payment_mode IN ('cash', 'upi', 'bank_transfer', 'cheque')),
    payment_date TIMESTAMP WITH TIME ZONE,
    remarks TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(staff_id, month, year)
);

-- Add indexes
CREATE INDEX idx_salary_profiles_staff ON salary_profiles(staff_id);
CREATE INDEX idx_salary_advances_staff ON salary_advances(staff_id);
CREATE INDEX idx_salary_payrolls_staff ON salary_payrolls(staff_id);
CREATE INDEX idx_salary_payrolls_month_year ON salary_payrolls(month, year);

-- Enable RLS
ALTER TABLE salary_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE salary_advances ENABLE ROW LEVEL SECURITY;
ALTER TABLE salary_payrolls ENABLE ROW LEVEL SECURITY;

-- Policies (Assuming authenticated users can read/write for now)
CREATE POLICY "Enable read for authenticated users" ON salary_profiles FOR SELECT TO authenticated USING (true);
CREATE POLICY "Enable all for authenticated users" ON salary_profiles FOR ALL TO authenticated USING (true);
CREATE POLICY "Enable read for authenticated users" ON salary_advances FOR SELECT TO authenticated USING (true);
CREATE POLICY "Enable all for authenticated users" ON salary_advances FOR ALL TO authenticated USING (true);
CREATE POLICY "Enable read for authenticated users" ON salary_payrolls FOR SELECT TO authenticated USING (true);
CREATE POLICY "Enable all for authenticated users" ON salary_payrolls FOR ALL TO authenticated USING (true);

-- Updated_at trigger for salary_profiles
CREATE TRIGGER update_salary_profiles_updated_at
    BEFORE UPDATE ON salary_profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
