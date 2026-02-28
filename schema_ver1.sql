-- Enable UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =========================
-- USERS
-- =========================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    global_role TEXT DEFAULT 'USER',
    created_at TIMESTAMP DEFAULT NOW()
);

-- =========================
-- PROJECTS
-- =========================
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    owner_id UUID REFERENCES users(id),
    status TEXT DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT NOW()
);

-- =========================
-- PROJECT MEMBERS (Multi-tenant role)
-- =========================
CREATE TABLE project_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    role TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(project_id, user_id)
);

-- =========================
-- ORDERS (Revenue)
-- =========================
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    amount NUMERIC(15,2) NOT NULL,
    currency TEXT DEFAULT 'VND',
    status TEXT DEFAULT 'PENDING',
    source TEXT,
    metadata JSONB,
    created_at TIMESTAMP DEFAULT NOW()
);

-- =========================
-- TRANSACTIONS (Webhook Raw)
-- =========================
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    provider TEXT NOT NULL,
    raw_payload JSONB NOT NULL,
    matched_order_id UUID REFERENCES orders(id),
    status TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- =========================
-- EXPENSES
-- =========================
CREATE TABLE expenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    category TEXT,
    amount NUMERIC(15,2) NOT NULL,
    note TEXT,
    expense_date DATE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- =========================
-- EMAIL LOGS
-- =========================
CREATE TABLE email_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    provider_id TEXT,
    to_email TEXT,
    subject TEXT,
    status TEXT,
    opened_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

-- =========================
-- CONTENT POSTS
-- =========================
CREATE TABLE content_posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    platform TEXT,
    content TEXT,
    status TEXT DEFAULT 'DRAFT',
    scheduled_at TIMESTAMP,
    posted_at TIMESTAMP,
    metrics JSONB,
    created_at TIMESTAMP DEFAULT NOW()
);

-- =========================
-- AI CONTEXT
-- =========================
CREATE TABLE ai_context (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    type TEXT,
    data JSONB,
    updated_at TIMESTAMP DEFAULT NOW()
);

-- =========================
-- INDEXING FOR PERFORMANCE
-- =========================
CREATE INDEX idx_orders_project ON orders(project_id);
CREATE INDEX idx_expenses_project ON expenses(project_id);
CREATE INDEX idx_transactions_project ON transactions(project_id);
CREATE INDEX idx_email_logs_project ON email_logs(project_id);
CREATE INDEX idx_content_posts_project ON content_posts(project_id);
CREATE INDEX idx_ai_context_project ON ai_context(project_id);