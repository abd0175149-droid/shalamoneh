-- ═══════════════════════════════════════════════════
--  Migration 002: Google Sign-In Support
-- ═══════════════════════════════════════════════════

-- إضافة حقول Google للمستخدمين
ALTER TABLE users ADD COLUMN IF NOT EXISTS google_id VARCHAR(255) UNIQUE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS avatar_url TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS auth_provider VARCHAR(20) DEFAULT 'phone';

-- Index للبحث السريع بـ google_id
CREATE INDEX IF NOT EXISTS idx_users_google_id ON users(google_id) WHERE google_id IS NOT NULL;
