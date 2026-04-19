import 'dart:math';
import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';
import '../config/env_config.dart';

/// قاعدة بيانات PostgreSQL — الإنتاج الحقيقي
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  late final Connection _conn;
  final _uuid = const Uuid();
  final _random = Random.secure();

  /// تهيئة الاتصال + إنشاء الجداول
  Future<void> initialize() async {
    final endpoint = Endpoint(
      host: EnvConfig.dbHost,
      port: EnvConfig.dbPort,
      database: EnvConfig.dbName,
      username: EnvConfig.dbUser,
      password: EnvConfig.dbPass,
    );

    _conn = await Connection.open(
      endpoint,
      settings: ConnectionSettings(sslMode: SslMode.disable),
    );
    print('✅ PostgreSQL connected: ${EnvConfig.dbHost}:${EnvConfig.dbPort}/${EnvConfig.dbName}');
  }

  String generateId() => _uuid.v4();
  String generateOtp() => List.generate(6, (_) => _random.nextInt(10)).join();
  String generateOrderNumber() => '#${DateTime.now().millisecondsSinceEpoch % 100000}';

  // ══════════════════════════════════════════
  //  User Operations
  // ══════════════════════════════════════════

  Future<Map<String, dynamic>?> getUserByPhone(String phone) async {
    final result = await _conn.execute(
      Sql.named('SELECT * FROM users WHERE phone = @phone AND is_active = true'),
      parameters: {'phone': phone},
    );
    if (result.isEmpty) return null;
    return _rowToMap(result.first, result.schema);
  }

  Future<Map<String, dynamic>?> getUserById(String id) async {
    final result = await _conn.execute(
      Sql.named('SELECT * FROM users WHERE id = @id::uuid'),
      parameters: {'id': id},
    );
    if (result.isEmpty) return null;
    return _rowToMap(result.first, result.schema);
  }

  Future<Map<String, dynamic>> createUser(String phone) async {
    final id = generateId();
    await _conn.execute(
      Sql.named('INSERT INTO users (id, phone) VALUES (@id::uuid, @phone)'),
      parameters: {'id': id, 'phone': phone},
    );

    // إنشاء رصيد ولاء + مكافأة تسجيل
    await _conn.execute(
      Sql.named('''INSERT INTO loyalty_balances (user_id, current_points, total_earned, level)
        VALUES (@id::uuid, 50, 50, 'برونزي')'''),
      parameters: {'id': id},
    );

    await _conn.execute(
      Sql.named('''INSERT INTO loyalty_transactions (user_id, points, type, description)
        VALUES (@id::uuid, 50, 'bonus', 'مكافأة تسجيل جديد 🎉')'''),
      parameters: {'id': id},
    );

    return (await getUserById(id))!;
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    final sets = <String>[];
    final params = <String, dynamic>{'id': id};

    if (data.containsKey('name')) {
      sets.add('name = @name');
      params['name'] = data['name'];
    }
    if (data.containsKey('email')) {
      sets.add('email = @email');
      params['email'] = data['email'];
    }
    if (data.containsKey('birth_date')) {
      sets.add('birth_date = @birth_date::date');
      params['birth_date'] = data['birth_date'];
    }

    if (sets.isEmpty) return;
    sets.add('updated_at = NOW()');

    await _conn.execute(
      Sql.named('UPDATE users SET ${sets.join(', ')} WHERE id = @id::uuid'),
      parameters: params,
    );
  }

  // ══════════════════════════════════════════
  //  Google Auth Operations
  // ══════════════════════════════════════════

  Future<Map<String, dynamic>?> getUserByGoogleId(String googleId) async {
    final result = await _conn.execute(
      Sql.named('SELECT * FROM users WHERE google_id = @google_id AND is_active = true'),
      parameters: {'google_id': googleId},
    );
    if (result.isEmpty) return null;
    return _rowToMap(result.first, result.schema);
  }

  Future<Map<String, dynamic>> createGoogleUser({
    required String googleId,
    required String email,
    String? name,
    String? avatarUrl,
  }) async {
    // تحقق أولاً: هل يوجد مستخدم بنفس الإيميل؟
    final existing = await _conn.execute(
      Sql.named('SELECT * FROM users WHERE email = @email AND is_active = true'),
      parameters: {'email': email},
    );

    if (existing.isNotEmpty) {
      // ربط حساب Google بالحساب الموجود
      final userId = _rowToMap(existing.first, existing.schema)['id'].toString();
      await _conn.execute(
        Sql.named('''UPDATE users SET google_id = @google_id, avatar_url = COALESCE(@avatar_url, avatar_url),
          name = COALESCE(@name, name), auth_provider = 'google', updated_at = NOW()
          WHERE id = @id::uuid'''),
        parameters: {'id': userId, 'google_id': googleId, 'avatar_url': avatarUrl, 'name': name},
      );
      return (await getUserById(userId))!;
    }

    // إنشاء مستخدم جديد
    final id = generateId();
    await _conn.execute(
      Sql.named('''INSERT INTO users (id, phone, email, name, google_id, avatar_url, auth_provider)
        VALUES (@id::uuid, @phone, @email, @name, @google_id, @avatar_url, 'google')'''),
      parameters: {
        'id': id,
        'phone': 'google_$googleId', // phone مطلوب (NOT NULL) — نستخدم معرف فريد
        'email': email,
        'name': name,
        'google_id': googleId,
        'avatar_url': avatarUrl,
      },
    );

    // مكافأة تسجيل جديد
    await _conn.execute(
      Sql.named('''INSERT INTO loyalty_balances (user_id, current_points, total_earned, level)
        VALUES (@id::uuid, 50, 50, 'برونزي')'''),
      parameters: {'id': id},
    );
    await _conn.execute(
      Sql.named('''INSERT INTO loyalty_transactions (user_id, points, type, description)
        VALUES (@id::uuid, 50, 'bonus', 'مكافأة تسجيل جديد 🎉')'''),
      parameters: {'id': id},
    );

    return (await getUserById(id))!;
  }

  // ══════════════════════════════════════════
  //  OTP Operations
  // ══════════════════════════════════════════

  Future<String> storeOtp(String phone) async {
    final otp = generateOtp();
    // إبطال أي OTP سابق
    await _conn.execute(
      Sql.named('UPDATE otp_codes SET is_used = true WHERE phone = @phone AND is_used = false'),
      parameters: {'phone': phone},
    );
    await _conn.execute(
      Sql.named('''INSERT INTO otp_codes (phone, code, expires_at)
        VALUES (@phone, @code, NOW() + INTERVAL '5 minutes')'''),
      parameters: {'phone': phone, 'code': otp},
    );
    return otp;
  }

  Future<bool> verifyOtp(String phone, String otp) async {
    final result = await _conn.execute(
      Sql.named('''SELECT id, code, attempts FROM otp_codes
        WHERE phone = @phone AND is_used = false AND expires_at > NOW()
        ORDER BY created_at DESC LIMIT 1'''),
      parameters: {'phone': phone},
    );
    if (result.isEmpty) return false;

    final row = _rowToMap(result.first, result.schema);
    final attempts = (row['attempts'] as int?) ?? 0;

    if (attempts >= 5) {
      await _conn.execute(
        Sql.named('UPDATE otp_codes SET is_used = true WHERE id = @id'),
        parameters: {'id': row['id']},
      );
      return false;
    }

    if (row['code'] != otp) {
      await _conn.execute(
        Sql.named('UPDATE otp_codes SET attempts = attempts + 1 WHERE id = @id'),
        parameters: {'id': row['id']},
      );
      return false;
    }

    // نجاح — تعليم كمستخدم
    await _conn.execute(
      Sql.named('UPDATE otp_codes SET is_used = true WHERE id = @id'),
      parameters: {'id': row['id']},
    );
    return true;
  }

  // ══════════════════════════════════════════
  //  Token Operations
  // ══════════════════════════════════════════

  Future<void> storeRefreshToken(String userId, String token, {String? device}) async {
    await _conn.execute(
      Sql.named('''INSERT INTO refresh_tokens (user_id, token, device_info, expires_at)
        VALUES (@uid::uuid, @token, @device, NOW() + INTERVAL '${EnvConfig.jwtRefreshExpiryDays} days')'''),
      parameters: {'uid': userId, 'token': token, 'device': device},
    );
  }

  Future<String?> validateRefreshToken(String token) async {
    final result = await _conn.execute(
      Sql.named('''SELECT user_id FROM refresh_tokens
        WHERE token = @token AND is_revoked = false AND expires_at > NOW()'''),
      parameters: {'token': token},
    );
    if (result.isEmpty) return null;
    return _rowToMap(result.first, result.schema)['user_id']?.toString();
  }

  Future<void> revokeRefreshToken(String token) async {
    await _conn.execute(
      Sql.named('UPDATE refresh_tokens SET is_revoked = true WHERE token = @token'),
      parameters: {'token': token},
    );
  }

  Future<void> revokeAllUserTokens(String userId) async {
    await _conn.execute(
      Sql.named('UPDATE refresh_tokens SET is_revoked = true WHERE user_id = @uid::uuid'),
      parameters: {'uid': userId},
    );
  }

  // ══════════════════════════════════════════
  //  Categories
  // ══════════════════════════════════════════

  Future<List<Map<String, dynamic>>> getCategories({bool activeOnly = true}) async {
    final where = activeOnly ? 'WHERE is_active = true' : '';
    final result = await _conn.execute('SELECT * FROM categories $where ORDER BY sort_order');
    return _resultToList(result);
  }

  // ══════════════════════════════════════════
  //  Products
  // ══════════════════════════════════════════

  Future<List<Map<String, dynamic>>> getProducts({
    String? categoryId,
    String? search,
    bool? popular,
    bool availableOnly = true,
  }) async {
    var where = <String>[];
    var params = <String, dynamic>{};

    if (availableOnly) where.add('p.is_available = true');
    if (categoryId != null) {
      where.add('p.category_id = @catId::uuid');
      params['catId'] = categoryId;
    }
    if (popular == true) where.add('p.is_popular = true');
    if (search != null && search.isNotEmpty) {
      where.add("(p.name ILIKE @search OR p.description ILIKE @search)");
      params['search'] = '%$search%';
    }

    final whereClause = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';

    final result = await _conn.execute(
      Sql.named('''SELECT p.*, c.name as category_name FROM products p
        JOIN categories c ON p.category_id = c.id
        $whereClause ORDER BY p.sort_order, p.name'''),
      parameters: params,
    );

    final products = _resultToList(result);

    // جلب الإضافات لكل منتج
    for (final product in products) {
      final addons = await _conn.execute(
        Sql.named('''SELECT a.* FROM addons a
          JOIN product_addons pa ON a.id = pa.addon_id
          WHERE pa.product_id = @pid::uuid AND a.is_available = true'''),
        parameters: {'pid': product['id'].toString()},
      );
      product['addons'] = _resultToList(addons);
    }

    return products;
  }

  Future<Map<String, dynamic>?> getProductById(String id) async {
    final result = await _conn.execute(
      Sql.named('SELECT p.*, c.name as category_name FROM products p JOIN categories c ON p.category_id = c.id WHERE p.id = @id::uuid'),
      parameters: {'id': id},
    );
    if (result.isEmpty) return null;

    final product = _rowToMap(result.first, result.schema);
    final addons = await _conn.execute(
      Sql.named('''SELECT a.* FROM addons a
        JOIN product_addons pa ON a.id = pa.addon_id
        WHERE pa.product_id = @pid::uuid AND a.is_available = true'''),
      parameters: {'pid': id},
    );
    product['addons'] = _resultToList(addons);
    return product;
  }

  // ══════════════════════════════════════════
  //  Orders
  // ══════════════════════════════════════════

  Future<Map<String, dynamic>> createOrder({
    required String userId,
    required String branchId,
    required String orderType,
    required List<Map<String, dynamic>> items,
    String? notes,
  }) async {
    final orderId = generateId();
    final orderNumber = generateOrderNumber();

    // حساب الأسعار من قاعدة البيانات (لا نثق بالعميل)
    double subtotal = 0;
    final processedItems = <Map<String, dynamic>>[];

    for (final item in items) {
      final product = await getProductById(item['product_id']);
      if (product == null) throw Exception('منتج غير موجود: ${item['product_id']}');

      final size = item['size'] ?? 'M';
      final unitPrice = _priceForSize(product, size);
      final quantity = (item['quantity'] as int?) ?? 1;

      // حساب إضافات
      double addonsPrice = 0;
      final addonIds = List<String>.from(item['addon_ids'] ?? []);
      final validAddons = <Map<String, dynamic>>[];

      for (final aid in addonIds) {
        final addonResult = await _conn.execute(
          Sql.named('SELECT * FROM addons WHERE id = @id::uuid AND is_available = true'),
          parameters: {'id': aid},
        );
        if (addonResult.isNotEmpty) {
          final addon = _rowToMap(addonResult.first, addonResult.schema);
          addonsPrice += (addon['price'] as num).toDouble();
          validAddons.add(addon);
        }
      }

      final totalPrice = (unitPrice + addonsPrice) * quantity;
      subtotal += totalPrice;

      processedItems.add({
        'product_id': item['product_id'],
        'product_name': product['name'],
        'size': size,
        'sugar_level': item['sugar_level'] ?? 2,
        'ice_level': item['ice_level'] ?? 2,
        'quantity': quantity,
        'unit_price': unitPrice,
        'addons_price': addonsPrice,
        'total_price': totalPrice,
        'notes': item['notes'],
        'addons': validAddons,
      });
    }

    final tax = subtotal * 0.16;
    final total = subtotal + tax;
    final loyaltyEarned = (total * 2).round(); // 1 نقطة / 0.5 JOD

    // إنشاء الطلب
    await _conn.execute(
      Sql.named('''INSERT INTO orders (id, order_number, user_id, branch_id, order_type, status, subtotal, tax, total, notes, estimated_time, loyalty_earned)
        VALUES (@id::uuid, @num, @uid::uuid, @bid::uuid, @type, 'confirmed', @sub, @tax, @total, @notes, '10-15 دقيقة', @loyalty)'''),
      parameters: {
        'id': orderId, 'num': orderNumber, 'uid': userId, 'bid': branchId,
        'type': orderType, 'sub': subtotal, 'tax': tax, 'total': total,
        'notes': notes, 'loyalty': loyaltyEarned,
      },
    );

    // إنشاء عناصر الطلب
    for (final item in processedItems) {
      final itemId = generateId();
      await _conn.execute(
        Sql.named('''INSERT INTO order_items (id, order_id, product_id, product_name, size, sugar_level, ice_level, quantity, unit_price, addons_price, total_price, notes)
          VALUES (@id::uuid, @oid::uuid, @pid::uuid, @pname, @size, @sugar, @ice, @qty, @unit, @addons, @total, @notes)'''),
        parameters: {
          'id': itemId, 'oid': orderId, 'pid': item['product_id'],
          'pname': item['product_name'], 'size': item['size'],
          'sugar': item['sugar_level'], 'ice': item['ice_level'],
          'qty': item['quantity'], 'unit': item['unit_price'],
          'addons': item['addons_price'], 'total': item['total_price'],
          'notes': item['notes'],
        },
      );

      // إضافات العنصر
      for (final addon in (item['addons'] as List)) {
        await _conn.execute(
          Sql.named('''INSERT INTO order_item_addons (order_item_id, addon_id, addon_name, addon_price)
            VALUES (@iid::uuid, @aid::uuid, @aname, @aprice)'''),
          parameters: {
            'iid': itemId, 'aid': addon['id'].toString(),
            'aname': addon['name'], 'aprice': addon['price'],
          },
        );
      }
    }

    // تحديث نقاط الولاء
    await _addLoyaltyPoints(userId, loyaltyEarned, 'earned', 'طلب $orderNumber', orderId);

    return {
      'id': orderId, 'order_number': orderNumber, 'status': 'confirmed',
      'subtotal': subtotal, 'tax': tax, 'total': total,
      'estimated_time': '10-15 دقيقة', 'loyalty_earned': loyaltyEarned,
      'items': processedItems,
    };
  }

  Future<List<Map<String, dynamic>>> getOrdersByUser(String userId) async {
    final result = await _conn.execute(
      Sql.named('''SELECT o.*, b.name as branch_name FROM orders o
        LEFT JOIN branches b ON o.branch_id = b.id
        WHERE o.user_id = @uid::uuid ORDER BY o.created_at DESC'''),
      parameters: {'uid': userId},
    );
    return _resultToList(result);
  }

  Future<Map<String, dynamic>?> getOrderById(String orderId, String userId) async {
    final result = await _conn.execute(
      Sql.named('SELECT o.*, b.name as branch_name FROM orders o LEFT JOIN branches b ON o.branch_id = b.id WHERE o.id = @id::uuid AND o.user_id = @uid::uuid'),
      parameters: {'id': orderId, 'uid': userId},
    );
    if (result.isEmpty) return null;

    final order = _rowToMap(result.first, result.schema);

    // جلب العناصر
    final itemsResult = await _conn.execute(
      Sql.named('SELECT * FROM order_items WHERE order_id = @oid::uuid'),
      parameters: {'oid': orderId},
    );
    final items = _resultToList(itemsResult);

    for (final item in items) {
      final addonsResult = await _conn.execute(
        Sql.named('SELECT * FROM order_item_addons WHERE order_item_id = @iid::uuid'),
        parameters: {'iid': item['id'].toString()},
      );
      item['addons'] = _resultToList(addonsResult);
    }
    order['items'] = items;
    return order;
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _conn.execute(
      Sql.named('UPDATE orders SET status = @status, updated_at = NOW() WHERE id = @id::uuid'),
      parameters: {'id': orderId, 'status': status},
    );
  }

  // ══════════════════════════════════════════
  //  Loyalty
  // ══════════════════════════════════════════

  Future<Map<String, dynamic>> getLoyaltyBalance(String userId) async {
    final result = await _conn.execute(
      Sql.named('SELECT * FROM loyalty_balances WHERE user_id = @uid::uuid'),
      parameters: {'uid': userId},
    );
    if (result.isEmpty) {
      return {'current_points': 0, 'total_earned': 0, 'total_redeemed': 0, 'level': 'برونزي'};
    }
    return _rowToMap(result.first, result.schema);
  }

  Future<List<Map<String, dynamic>>> getLoyaltyTransactions(String userId) async {
    final result = await _conn.execute(
      Sql.named('SELECT * FROM loyalty_transactions WHERE user_id = @uid::uuid ORDER BY created_at DESC LIMIT 50'),
      parameters: {'uid': userId},
    );
    return _resultToList(result);
  }

  Future<bool> redeemPoints(String userId, int points) async {
    final balance = await getLoyaltyBalance(userId);
    final current = (balance['current_points'] as int?) ?? 0;
    if (current < points) return false;

    await _conn.execute(
      Sql.named('''UPDATE loyalty_balances SET
        current_points = current_points - @pts,
        total_redeemed = total_redeemed + @pts,
        updated_at = NOW()
        WHERE user_id = @uid::uuid'''),
      parameters: {'uid': userId, 'pts': points},
    );

    await _conn.execute(
      Sql.named('''INSERT INTO loyalty_transactions (user_id, points, type, description)
        VALUES (@uid::uuid, @pts, 'redeemed', 'استبدال نقاط')'''),
      parameters: {'uid': userId, 'pts': -points},
    );
    return true;
  }

  Future<void> _addLoyaltyPoints(String userId, int points, String type, String desc, [String? orderId]) async {
    // تحديث الرصيد
    final existResult = await _conn.execute(
      Sql.named('SELECT user_id FROM loyalty_balances WHERE user_id = @uid::uuid'),
      parameters: {'uid': userId},
    );

    if (existResult.isEmpty) {
      await _conn.execute(
        Sql.named('''INSERT INTO loyalty_balances (user_id, current_points, total_earned)
          VALUES (@uid::uuid, @pts, @pts)'''),
        parameters: {'uid': userId, 'pts': points},
      );
    } else {
      await _conn.execute(
        Sql.named('''UPDATE loyalty_balances SET
          current_points = current_points + @pts,
          total_earned = total_earned + @pts,
          updated_at = NOW()
          WHERE user_id = @uid::uuid'''),
        parameters: {'uid': userId, 'pts': points},
      );
    }

    // تحديث المستوى
    final balance = await getLoyaltyBalance(userId);
    final totalEarned = (balance['total_earned'] as int?) ?? 0;
    String level = 'برونزي';
    if (totalEarned >= 600) level = 'بلاتيني';
    else if (totalEarned >= 300) level = 'ذهبي';
    else if (totalEarned >= 100) level = 'فضي';

    await _conn.execute(
      Sql.named('UPDATE loyalty_balances SET level = @level WHERE user_id = @uid::uuid'),
      parameters: {'uid': userId, 'level': level},
    );

    // تسجيل المعاملة
    final txParams = <String, dynamic>{
      'uid': userId, 'pts': points, 'type': type, 'desc': desc,
    };
    String orderCol = '';
    String orderVal = '';
    if (orderId != null) {
      orderCol = ', order_id';
      orderVal = ', @oid::uuid';
      txParams['oid'] = orderId;
    }
    await _conn.execute(
      Sql.named('''INSERT INTO loyalty_transactions (user_id, points, type, description$orderCol)
        VALUES (@uid::uuid, @pts, @type, @desc$orderVal)'''),
      parameters: txParams,
    );
  }

  // ══════════════════════════════════════════
  //  Favorites
  // ══════════════════════════════════════════

  Future<List<Map<String, dynamic>>> getFavorites(String userId) async {
    final result = await _conn.execute(
      Sql.named('''SELECT p.*, f.created_at as favorited_at FROM favorites f
        JOIN products p ON f.product_id = p.id
        WHERE f.user_id = @uid::uuid ORDER BY f.created_at DESC'''),
      parameters: {'uid': userId},
    );
    final products = _resultToList(result);
    for (final p in products) {
      final addons = await _conn.execute(
        Sql.named('''SELECT a.* FROM addons a JOIN product_addons pa ON a.id = pa.addon_id
          WHERE pa.product_id = @pid::uuid AND a.is_available = true'''),
        parameters: {'pid': p['id'].toString()},
      );
      p['addons'] = _resultToList(addons);
    }
    return products;
  }

  Future<void> addFavorite(String userId, String productId) async {
    await _conn.execute(
      Sql.named('INSERT INTO favorites (user_id, product_id) VALUES (@uid::uuid, @pid::uuid) ON CONFLICT DO NOTHING'),
      parameters: {'uid': userId, 'pid': productId},
    );
  }

  Future<void> removeFavorite(String userId, String productId) async {
    await _conn.execute(
      Sql.named('DELETE FROM favorites WHERE user_id = @uid::uuid AND product_id = @pid::uuid'),
      parameters: {'uid': userId, 'pid': productId},
    );
  }

  Future<List<String>> getFavoriteIds(String userId) async {
    final result = await _conn.execute(
      Sql.named('SELECT product_id FROM favorites WHERE user_id = @uid::uuid'),
      parameters: {'uid': userId},
    );
    return result.map((r) => r[0].toString()).toList();
  }

  // ══════════════════════════════════════════
  //  Branches
  // ══════════════════════════════════════════

  Future<List<Map<String, dynamic>>> getBranches({String? city, bool activeOnly = true}) async {
    var where = <String>[];
    var params = <String, dynamic>{};
    if (activeOnly) where.add('is_active = true');
    if (city != null) {
      where.add('city = @city');
      params['city'] = city;
    }
    final whereClause = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';
    final result = await _conn.execute(
      Sql.named('SELECT * FROM branches $whereClause ORDER BY name'),
      parameters: params,
    );
    return _resultToList(result);
  }

  Future<Map<String, dynamic>?> getBranchById(String id) async {
    final result = await _conn.execute(
      Sql.named('SELECT * FROM branches WHERE id = @id::uuid'),
      parameters: {'id': id},
    );
    if (result.isEmpty) return null;
    return _rowToMap(result.first, result.schema);
  }

  // ══════════════════════════════════════════
  //  Admin — إحصائيات
  // ══════════════════════════════════════════

  Future<Map<String, dynamic>> getAdminStats() async {
    final users = await _conn.execute("SELECT COUNT(*) FROM users WHERE is_active = true");
    final orders = await _conn.execute("SELECT COUNT(*), COALESCE(SUM(total),0) FROM orders");
    final todayOrders = await _conn.execute("SELECT COUNT(*), COALESCE(SUM(total),0) FROM orders WHERE created_at::date = CURRENT_DATE");
    final products = await _conn.execute("SELECT COUNT(*) FROM products WHERE is_available = true");

    return {
      'total_users': users.first[0],
      'total_orders': orders.first[0],
      'total_revenue': orders.first[1],
      'today_orders': todayOrders.first[0],
      'today_revenue': todayOrders.first[1],
      'active_products': products.first[0],
    };
  }

  Future<List<Map<String, dynamic>>> getAllOrders({String? status, int limit = 50}) async {
    var where = <String>[];
    var params = <String, dynamic>{};
    if (status != null) {
      where.add('o.status = @status');
      params['status'] = status;
    }
    final whereClause = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';
    final result = await _conn.execute(
      Sql.named('''SELECT o.*, u.name as user_name, u.phone as user_phone, b.name as branch_name
        FROM orders o JOIN users u ON o.user_id = u.id LEFT JOIN branches b ON o.branch_id = b.id
        $whereClause ORDER BY o.created_at DESC LIMIT $limit'''),
      parameters: params,
    );
    return _resultToList(result);
  }

  Future<List<Map<String, dynamic>>> getAllUsers({int limit = 100}) async {
    final result = await _conn.execute(
      'SELECT u.*, lb.current_points, lb.level FROM users u LEFT JOIN loyalty_balances lb ON u.id = lb.user_id ORDER BY u.created_at DESC LIMIT $limit',
    );
    return _resultToList(result);
  }

  // ══════════════════════════════════════════
  //  Admin — CRUD Products
  // ══════════════════════════════════════════

  Future<void> createProduct(Map<String, dynamic> data) async {
    final id = generateId();
    await _conn.execute(
      Sql.named('''INSERT INTO products (id, category_id, name, name_en, description, price_s, price_m, price_l, is_available, is_popular)
        VALUES (@id::uuid, @catId::uuid, @name, @nameEn, @desc, @ps, @pm, @pl, @avail, @pop)'''),
      parameters: {
        'id': id, 'catId': data['category_id'], 'name': data['name'],
        'nameEn': data['name_en'], 'desc': data['description'],
        'ps': data['price_s'], 'pm': data['price_m'], 'pl': data['price_l'],
        'avail': data['is_available'] ?? true, 'pop': data['is_popular'] ?? false,
      },
    );

    // ربط الإضافات
    final addonIds = List<String>.from(data['addon_ids'] ?? []);
    for (final aid in addonIds) {
      await _conn.execute(
        Sql.named('INSERT INTO product_addons (product_id, addon_id) VALUES (@pid::uuid, @aid::uuid) ON CONFLICT DO NOTHING'),
        parameters: {'pid': id, 'aid': aid},
      );
    }
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    final sets = <String>[];
    final params = <String, dynamic>{'id': id};

    for (final key in ['name', 'name_en', 'description', 'image_url']) {
      if (data.containsKey(key)) {
        sets.add('$key = @$key');
        params[key] = data[key];
      }
    }
    for (final key in ['price_s', 'price_m', 'price_l']) {
      if (data.containsKey(key)) {
        sets.add('$key = @$key');
        params[key] = data[key];
      }
    }
    for (final key in ['is_available', 'is_popular']) {
      if (data.containsKey(key)) {
        sets.add('$key = @$key');
        params[key] = data[key];
      }
    }
    if (data.containsKey('category_id')) {
      sets.add('category_id = @catId::uuid');
      params['catId'] = data['category_id'];
    }

    if (sets.isNotEmpty) {
      sets.add('updated_at = NOW()');
      await _conn.execute(
        Sql.named('UPDATE products SET ${sets.join(', ')} WHERE id = @id::uuid'),
        parameters: params,
      );
    }
  }

  Future<void> deleteProduct(String id) async {
    await _conn.execute(Sql.named('DELETE FROM products WHERE id = @id::uuid'), parameters: {'id': id});
  }

  // ══════════════════════════════════════════
  //  Helpers
  // ══════════════════════════════════════════

  double _priceForSize(Map<String, dynamic> product, String size) {
    switch (size.toUpperCase()) {
      case 'S': return (product['price_s'] as num).toDouble();
      case 'L': return (product['price_l'] as num).toDouble();
      default: return (product['price_m'] as num).toDouble();
    }
  }

  Map<String, dynamic> _rowToMap(ResultRow row, ResultSchema schema) {
    final map = <String, dynamic>{};
    for (var i = 0; i < schema.columns.length; i++) {
      final colName = schema.columns[i].columnName ?? 'col_$i';
      var value = row[i];
      // تحويل DateTime لـ ISO string (JSON لا يدعم DateTime مباشرة)
      if (value is DateTime) {
        value = value.toIso8601String();
      }
      map[colName] = value;
    }
    return map;
  }

  List<Map<String, dynamic>> _resultToList(Result result) {
    return result.map((row) => _rowToMap(row, result.schema)).toList();
  }
}
