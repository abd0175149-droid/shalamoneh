-- ═══════════════════════════════════════════════════
--  Shalmoneh Database — Initial Schema (PostgreSQL)
--  Version: 2.0.0
-- ═══════════════════════════════════════════════════

-- 1. المستخدمون
CREATE TABLE IF NOT EXISTS users (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone       VARCHAR(20) NOT NULL UNIQUE,
    name        VARCHAR(100),
    email       VARCHAR(255),
    birth_date  DATE,
    is_admin    BOOLEAN DEFAULT false,
    is_active   BOOLEAN DEFAULT true,
    created_at  TIMESTAMPTZ DEFAULT NOW(),
    updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- 2. رموز OTP
CREATE TABLE IF NOT EXISTS otp_codes (
    id          SERIAL PRIMARY KEY,
    phone       VARCHAR(20) NOT NULL,
    code        VARCHAR(6) NOT NULL,
    attempts    INT DEFAULT 0,
    is_used     BOOLEAN DEFAULT false,
    expires_at  TIMESTAMPTZ NOT NULL,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_otp_phone ON otp_codes(phone, is_used);

-- 3. Refresh Tokens
CREATE TABLE IF NOT EXISTS refresh_tokens (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token       TEXT NOT NULL UNIQUE,
    device_info TEXT,
    is_revoked  BOOLEAN DEFAULT false,
    expires_at  TIMESTAMPTZ NOT NULL,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_tokens_user ON refresh_tokens(user_id);

-- 4. التصنيفات
CREATE TABLE IF NOT EXISTS categories (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name        VARCHAR(100) NOT NULL,
    name_en     VARCHAR(100),
    icon        VARCHAR(10),
    image_url   TEXT,
    sort_order  INT DEFAULT 0,
    is_active   BOOLEAN DEFAULT true,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- 5. المنتجات
CREATE TABLE IF NOT EXISTS products (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id  UUID NOT NULL REFERENCES categories(id),
    name         VARCHAR(200) NOT NULL,
    name_en      VARCHAR(200),
    description  TEXT,
    image_url    TEXT,
    price_s      DECIMAL(10,3) NOT NULL,
    price_m      DECIMAL(10,3) NOT NULL,
    price_l      DECIMAL(10,3) NOT NULL,
    is_available BOOLEAN DEFAULT true,
    is_popular   BOOLEAN DEFAULT false,
    sort_order   INT DEFAULT 0,
    created_at   TIMESTAMPTZ DEFAULT NOW(),
    updated_at   TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_id);

-- 6. الإضافات
CREATE TABLE IF NOT EXISTS addons (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name         VARCHAR(100) NOT NULL,
    name_en      VARCHAR(100),
    price        DECIMAL(10,3) NOT NULL,
    is_available BOOLEAN DEFAULT true,
    created_at   TIMESTAMPTZ DEFAULT NOW()
);

-- 7. ربط منتج × إضافة
CREATE TABLE IF NOT EXISTS product_addons (
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    addon_id   UUID NOT NULL REFERENCES addons(id) ON DELETE CASCADE,
    PRIMARY KEY (product_id, addon_id)
);

-- 8. الفروع
CREATE TABLE IF NOT EXISTS branches (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name           VARCHAR(200) NOT NULL,
    address        TEXT,
    city           VARCHAR(100),
    country        VARCHAR(100) DEFAULT 'الأردن',
    latitude       DECIMAL(10,7),
    longitude      DECIMAL(10,7),
    phone          VARCHAR(20),
    working_hours  VARCHAR(100),
    is_24h         BOOLEAN DEFAULT false,
    is_active      BOOLEAN DEFAULT true,
    created_at     TIMESTAMPTZ DEFAULT NOW()
);

-- 9. الطلبات
CREATE TABLE IF NOT EXISTS orders (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_number   VARCHAR(20) NOT NULL UNIQUE,
    user_id        UUID NOT NULL REFERENCES users(id),
    branch_id      UUID REFERENCES branches(id),
    order_type     VARCHAR(20) DEFAULT 'pickup',
    status         VARCHAR(20) DEFAULT 'pending',
    subtotal       DECIMAL(10,3) NOT NULL DEFAULT 0,
    tax            DECIMAL(10,3) DEFAULT 0,
    discount       DECIMAL(10,3) DEFAULT 0,
    total          DECIMAL(10,3) NOT NULL DEFAULT 0,
    notes          TEXT,
    estimated_time VARCHAR(50),
    loyalty_earned INT DEFAULT 0,
    created_at     TIMESTAMPTZ DEFAULT NOW(),
    updated_at     TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_orders_user ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);

-- 10. عناصر الطلب
CREATE TABLE IF NOT EXISTS order_items (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id     UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id   UUID NOT NULL REFERENCES products(id),
    product_name VARCHAR(200),
    size         VARCHAR(5) NOT NULL DEFAULT 'M',
    sugar_level  INT DEFAULT 2,
    ice_level    INT DEFAULT 2,
    quantity     INT DEFAULT 1,
    unit_price   DECIMAL(10,3) NOT NULL,
    addons_price DECIMAL(10,3) DEFAULT 0,
    total_price  DECIMAL(10,3) NOT NULL,
    notes        TEXT
);

-- 11. إضافات عناصر الطلب
CREATE TABLE IF NOT EXISTS order_item_addons (
    id            SERIAL PRIMARY KEY,
    order_item_id UUID NOT NULL REFERENCES order_items(id) ON DELETE CASCADE,
    addon_id      UUID NOT NULL REFERENCES addons(id),
    addon_name    VARCHAR(100),
    addon_price   DECIMAL(10,3)
);

-- 12. رصيد الولاء
CREATE TABLE IF NOT EXISTS loyalty_balances (
    user_id        UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    current_points INT DEFAULT 0,
    total_earned   INT DEFAULT 0,
    total_redeemed INT DEFAULT 0,
    level          VARCHAR(20) DEFAULT 'برونزي',
    updated_at     TIMESTAMPTZ DEFAULT NOW()
);

-- 13. معاملات الولاء
CREATE TABLE IF NOT EXISTS loyalty_transactions (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES users(id),
    order_id    UUID REFERENCES orders(id),
    points      INT NOT NULL,
    type        VARCHAR(20) NOT NULL,
    description TEXT,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_loyalty_user ON loyalty_transactions(user_id);

-- 14. المفضلات
CREATE TABLE IF NOT EXISTS favorites (
    user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (user_id, product_id)
);

-- ═══════════════════════════════════════════════════
--  Seed Data — البيانات الأولية
-- ═══════════════════════════════════════════════════

-- التصنيفات
INSERT INTO categories (id, name, name_en, icon, sort_order) VALUES
    ('c0000001-0000-0000-0000-000000000001', 'عصائر طبيعية', 'Fresh Juices', '🍊', 1),
    ('c0000001-0000-0000-0000-000000000002', 'مكس شلمونة', 'Shalmoneh Mix', '🥤', 2),
    ('c0000001-0000-0000-0000-000000000003', 'ساخن', 'Hot Drinks', '☕', 3),
    ('c0000001-0000-0000-0000-000000000004', 'حلى', 'Desserts', '🍰', 4)
ON CONFLICT (id) DO NOTHING;

-- الإضافات
INSERT INTO addons (id, name, name_en, price) VALUES
    ('a0000001-0000-0000-0000-000000000001', 'نوتيلا', 'Nutella', 0.750),
    ('a0000001-0000-0000-0000-000000000002', 'لوتس', 'Lotus', 0.750),
    ('a0000001-0000-0000-0000-000000000003', 'كراميل', 'Caramel', 0.500),
    ('a0000001-0000-0000-0000-000000000004', 'فراولة', 'Strawberry', 0.500),
    ('a0000001-0000-0000-0000-000000000005', 'كريمة مخفوقة', 'Whipped Cream', 0.500),
    ('a0000001-0000-0000-0000-000000000006', 'شوكولاتة', 'Chocolate', 0.750),
    ('a0000001-0000-0000-0000-000000000007', 'بروتين', 'Protein', 1.000)
ON CONFLICT (id) DO NOTHING;

-- المنتجات — عصائر طبيعية
INSERT INTO products (id, category_id, name, name_en, description, price_s, price_m, price_l, is_popular) VALUES
    ('e0000001-0000-0000-0000-000000000001', 'c0000001-0000-0000-0000-000000000001', 'عصير برتقال طبيعي', 'Fresh Orange Juice', 'عصير برتقال طازج 100% طبيعي بدون سكر مضاف', 1.500, 2.000, 2.750, true),
    ('e0000001-0000-0000-0000-000000000002', 'c0000001-0000-0000-0000-000000000001', 'عصير ليمون بالنعناع', 'Lemon Mint', 'ليمون طازج مع أوراق نعناع منعشة', 1.250, 1.750, 2.500, true),
    ('e0000001-0000-0000-0000-000000000003', 'c0000001-0000-0000-0000-000000000001', 'عصير رمان', 'Pomegranate Juice', 'عصير رمان طبيعي غني بمضادات الأكسدة', 2.000, 2.750, 3.500, false),
    ('e0000001-0000-0000-0000-000000000004', 'c0000001-0000-0000-0000-000000000001', 'عصير جزر وبرتقال', 'Carrot Orange', 'مزيج صحي من الجزر والبرتقال الطازج', 1.750, 2.250, 3.000, false),
    ('e0000001-0000-0000-0000-000000000005', 'c0000001-0000-0000-0000-000000000001', 'عصير تفاح أخضر', 'Green Apple', 'تفاح أخضر طازج منعش ومفيد', 1.500, 2.000, 2.750, false)
ON CONFLICT (id) DO NOTHING;

-- المنتجات — مكس شلمونة
INSERT INTO products (id, category_id, name, name_en, description, price_s, price_m, price_l, is_popular) VALUES
    ('e0000001-0000-0000-0000-000000000006', 'c0000001-0000-0000-0000-000000000002', 'شلمونة سبيشل', 'Shalmoneh Special', 'خلطتنا السرية من الفواكه الاستوائية المميزة', 2.500, 3.250, 4.000, true),
    ('e0000001-0000-0000-0000-000000000007', 'c0000001-0000-0000-0000-000000000002', 'مانجو باشن', 'Mango Passion', 'مانجو طازج مع فاكهة الباشن فروت', 2.250, 3.000, 3.750, true),
    ('e0000001-0000-0000-0000-000000000008', 'c0000001-0000-0000-0000-000000000002', 'بيري بلاست', 'Berry Blast', 'مزيج من التوت والفراولة والبلوبيري', 2.500, 3.250, 4.000, false),
    ('e0000001-0000-0000-0000-000000000009', 'c0000001-0000-0000-0000-000000000002', 'تروبيكال سموذي', 'Tropical Smoothie', 'أناناس وموز وجوز الهند الاستوائي', 2.750, 3.500, 4.250, false)
ON CONFLICT (id) DO NOTHING;

-- المنتجات — ساخن
INSERT INTO products (id, category_id, name, name_en, description, price_s, price_m, price_l, is_popular) VALUES
    ('e0000001-0000-0000-0000-000000000010', 'c0000001-0000-0000-0000-000000000003', 'سحلب شلمونة', 'Shalmoneh Sahlab', 'سحلب كريمي مع مكسرات وقرفة', 1.750, 2.250, 3.000, true),
    ('e0000001-0000-0000-0000-000000000011', 'c0000001-0000-0000-0000-000000000003', 'شوكولاتة ساخنة', 'Hot Chocolate', 'شوكولاتة بلجيكية فاخرة ساخنة', 2.000, 2.750, 3.500, false)
ON CONFLICT (id) DO NOTHING;

-- المنتجات — حلى
INSERT INTO products (id, category_id, name, name_en, description, price_s, price_m, price_l, is_popular) VALUES
    ('e0000001-0000-0000-0000-000000000012', 'c0000001-0000-0000-0000-000000000004', 'وافل شلمونة', 'Shalmoneh Waffle', 'وافل مقرمش مع صوص الشوكولاتة والفواكه', 2.500, 3.500, 4.500, true),
    ('e0000001-0000-0000-0000-000000000013', 'c0000001-0000-0000-0000-000000000004', 'كنافة بالقشطة', 'Kunafa', 'كنافة ناعمة محشوة بالقشطة العربية', 2.000, 3.000, 4.000, false)
ON CONFLICT (id) DO NOTHING;

-- ربط المنتجات بالإضافات
INSERT INTO product_addons (product_id, addon_id) VALUES
    ('e0000001-0000-0000-0000-000000000001', 'a0000001-0000-0000-0000-000000000007'),
    ('e0000001-0000-0000-0000-000000000003', 'a0000001-0000-0000-0000-000000000007'),
    ('e0000001-0000-0000-0000-000000000004', 'a0000001-0000-0000-0000-000000000007'),
    ('e0000001-0000-0000-0000-000000000006', 'a0000001-0000-0000-0000-000000000001'),
    ('e0000001-0000-0000-0000-000000000006', 'a0000001-0000-0000-0000-000000000002'),
    ('e0000001-0000-0000-0000-000000000006', 'a0000001-0000-0000-0000-000000000005'),
    ('e0000001-0000-0000-0000-000000000006', 'a0000001-0000-0000-0000-000000000006'),
    ('e0000001-0000-0000-0000-000000000007', 'a0000001-0000-0000-0000-000000000005'),
    ('e0000001-0000-0000-0000-000000000007', 'a0000001-0000-0000-0000-000000000006'),
    ('e0000001-0000-0000-0000-000000000008', 'a0000001-0000-0000-0000-000000000001'),
    ('e0000001-0000-0000-0000-000000000008', 'a0000001-0000-0000-0000-000000000004'),
    ('e0000001-0000-0000-0000-000000000008', 'a0000001-0000-0000-0000-000000000005'),
    ('e0000001-0000-0000-0000-000000000009', 'a0000001-0000-0000-0000-000000000005'),
    ('e0000001-0000-0000-0000-000000000009', 'a0000001-0000-0000-0000-000000000007'),
    ('e0000001-0000-0000-0000-000000000010', 'a0000001-0000-0000-0000-000000000001'),
    ('e0000001-0000-0000-0000-000000000010', 'a0000001-0000-0000-0000-000000000002'),
    ('e0000001-0000-0000-0000-000000000010', 'a0000001-0000-0000-0000-000000000003'),
    ('e0000001-0000-0000-0000-000000000011', 'a0000001-0000-0000-0000-000000000005'),
    ('e0000001-0000-0000-0000-000000000011', 'a0000001-0000-0000-0000-000000000001'),
    ('e0000001-0000-0000-0000-000000000012', 'a0000001-0000-0000-0000-000000000001'),
    ('e0000001-0000-0000-0000-000000000012', 'a0000001-0000-0000-0000-000000000002'),
    ('e0000001-0000-0000-0000-000000000012', 'a0000001-0000-0000-0000-000000000004'),
    ('e0000001-0000-0000-0000-000000000012', 'a0000001-0000-0000-0000-000000000006')
ON CONFLICT DO NOTHING;

-- الفروع
INSERT INTO branches (id, name, address, city, country, latitude, longitude, phone, working_hours) VALUES
    ('b0000001-0000-0000-0000-000000000001', 'فرع الشميساني', 'شارع الشريف ناصر بن جميل', 'عمان', 'الأردن', 31.9661000, 35.9102000, '06-5XXX001', '8:00 AM - 12:00 AM'),
    ('b0000001-0000-0000-0000-000000000002', 'فرع عبدون', 'دوار عبدون، بجانب كوزمو', 'عمان', 'الأردن', 31.9544000, 35.8823000, '06-5XXX002', '8:00 AM - 12:00 AM'),
    ('b0000001-0000-0000-0000-000000000003', 'فرع الجاردنز', 'شارع وصفي التل، الجاردنز', 'عمان', 'الأردن', 31.9715000, 35.8958000, '06-5XXX003', '24 ساعة'),
    ('b0000001-0000-0000-0000-000000000004', 'فرع إربد', 'شارع الجامعة، إربد', 'إربد', 'الأردن', 32.5568000, 35.8469000, '02-7XXX001', '8:00 AM - 11:00 PM'),
    ('b0000001-0000-0000-0000-000000000005', 'فرع الرياض', 'حي العليا، الرياض', 'الرياض', 'السعودية', 24.7136000, 46.6753000, '+966-5XXX001', '9:00 AM - 1:00 AM')
ON CONFLICT (id) DO NOTHING;
