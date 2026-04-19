#!/bin/bash
# ═══════════════════════════════════════
# Shalmoneh — سكربت النشر على السيرفر
# ═══════════════════════════════════════

set -e

echo "🥤 Shalmoneh Deployment Script"
echo "═══════════════════════════════"

PROJECT_DIR="/home/sysadmin/shalmoneh"
REPO_URL="$1"

# ─── 1. Clone/Pull Repository ───
if [ -d "$PROJECT_DIR" ]; then
    echo "📥 Updating existing project..."
    cd "$PROJECT_DIR"
    git pull origin main
else
    if [ -z "$REPO_URL" ]; then
        echo "❌ Usage: ./deploy.sh <github-repo-url>"
        exit 1
    fi
    echo "📥 Cloning repository..."
    git clone "$REPO_URL" "$PROJECT_DIR"
    cd "$PROJECT_DIR"
fi

# ─── 2. إنشاء .env إنتاجي (أول مرة فقط) ───
if [ ! -f "$PROJECT_DIR/.env" ]; then
    echo "📝 Creating production .env..."
    cat > "$PROJECT_DIR/.env" << 'EOF'
DB_PASS=Sh4lm0n3h_2026_Pr0d!
JWT_SECRET=shalmoneh_jwt_prod_CHANGE_THIS_NOW_2026
ADMIN_PHONE=+962799999999
EOF
    echo "⚠️  Edit .env with your real secrets: nano $PROJECT_DIR/.env"
fi

# ─── 3. Build & Run ───
echo "🐳 Building Docker images..."
docker compose build --no-cache

echo "🚀 Starting containers..."
docker compose up -d

# ─── 4. انتظار PostgreSQL ───
echo "⏳ Waiting for database..."
sleep 10

# ─── 5. تعيين أدمن ───
echo "👑 Setting admin user..."
docker exec shalmoneh-db psql -U shalmoneh_user -d shalmoneh -c \
    "UPDATE users SET is_admin = true WHERE phone = '+962799999999';" 2>/dev/null || true

# ─── 6. التحقق ───
echo ""
echo "🔍 Checking health..."
sleep 3
curl -s http://localhost:4050/api/health | python3 -m json.tool 2>/dev/null || echo "⚠️ API not ready yet, wait a few seconds"

echo ""
echo "═══════════════════════════════════════════════"
echo "  ✅ Shalmoneh deployed successfully!"
echo "  📍 API: http://localhost:4050"
echo "  🛠  Admin: http://localhost:4050/admin/"
echo "  🐘 DB: localhost:5434"
echo ""
echo "  📋 Next: Add to Cloudflare Tunnel"
echo "═══════════════════════════════════════════════"
