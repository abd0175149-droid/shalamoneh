import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';

import '../lib/config/env_config.dart';
import '../lib/controllers/auth_controller.dart';
import '../lib/controllers/menu_controller.dart' as menu;
import '../lib/controllers/orders_controller.dart';
import '../lib/controllers/loyalty_controller.dart';
import '../lib/controllers/branches_controller.dart';
import '../lib/controllers/favorites_controller.dart';
import '../lib/controllers/admin_controller.dart';
import '../lib/middleware/auth_middleware.dart';
import '../lib/services/database_service.dart';

/// 🚀 سيرفر شلمونة — Dart Shelf + PostgreSQL Backend
void main(List<String> args) async {
  // تحميل متغيرات البيئة
  await EnvConfig.load();

  // تهيئة قاعدة البيانات
  final db = DatabaseService();
  try {
    await db.initialize();
  } catch (e) {
    print('❌ Database connection failed: $e');
    print('   تأكد من تشغيل PostgreSQL وصحة بيانات .env');
    exit(1);
  }

  // Controllers
  final authCtrl = AuthController(db);
  final menuCtrl = menu.MenuController(db);
  final ordersCtrl = OrdersController(db);
  final loyaltyCtrl = LoyaltyController(db);
  final branchesCtrl = BranchesController(db);
  final favoritesCtrl = FavoritesController(db);
  final adminCtrl = AdminController(db);

  // Router
  final router = Router();

  // ══════════════════════════════════════════
  //  Auth Routes (عامة)
  // ══════════════════════════════════════════
  router.post('/api/auth/send-otp', authCtrl.sendOtp);
  router.post('/api/auth/verify-otp', authCtrl.verifyOtp);
  router.post('/api/auth/refresh-token', authCtrl.refreshToken);
  router.post('/api/auth/google', authCtrl.signInWithGoogle);

  // Auth Routes (محمية)
  router.get('/api/auth/profile', Pipeline()
      .addMiddleware(authMiddleware(db))
      .addHandler(authCtrl.getProfile));
  router.put('/api/auth/profile', Pipeline()
      .addMiddleware(authMiddleware(db))
      .addHandler(authCtrl.updateProfile));
  router.post('/api/auth/logout', Pipeline()
      .addMiddleware(authMiddleware(db))
      .addHandler(authCtrl.logout));

  // ══════════════════════════════════════════
  //  Menu Routes (عامة)
  // ══════════════════════════════════════════
  router.get('/api/categories', menuCtrl.getCategories);
  router.get('/api/products', menuCtrl.getProducts);
  router.get('/api/products/<id>', (Request req, String id) => menuCtrl.getProductById(req, id));

  // ══════════════════════════════════════════
  //  Orders Routes (محمية)
  // ══════════════════════════════════════════
  router.post('/api/orders', Pipeline()
      .addMiddleware(authMiddleware(db))
      .addHandler(ordersCtrl.createOrder));
  router.get('/api/orders', Pipeline()
      .addMiddleware(authMiddleware(db))
      .addHandler(ordersCtrl.getOrders));
  router.get('/api/orders/<id>', (Request req, String id) async {
    final mw = authMiddleware(db);
    final handler = mw((r) => ordersCtrl.getOrderById(r, id));
    return handler(req);
  });

  // ══════════════════════════════════════════
  //  Loyalty Routes (محمية)
  // ══════════════════════════════════════════
  router.get('/api/loyalty/balance', Pipeline()
      .addMiddleware(authMiddleware(db))
      .addHandler(loyaltyCtrl.getBalance));
  router.get('/api/loyalty/transactions', Pipeline()
      .addMiddleware(authMiddleware(db))
      .addHandler(loyaltyCtrl.getTransactions));
  router.post('/api/loyalty/redeem', Pipeline()
      .addMiddleware(authMiddleware(db))
      .addHandler(loyaltyCtrl.redeem));

  // ══════════════════════════════════════════
  //  Favorites Routes (محمية)
  // ══════════════════════════════════════════
  router.get('/api/favorites', Pipeline()
      .addMiddleware(authMiddleware(db))
      .addHandler(favoritesCtrl.getFavorites));
  router.get('/api/favorites/ids', Pipeline()
      .addMiddleware(authMiddleware(db))
      .addHandler(favoritesCtrl.getFavoriteIds));
  router.post('/api/favorites', Pipeline()
      .addMiddleware(authMiddleware(db))
      .addHandler(favoritesCtrl.addFavorite));
  router.delete('/api/favorites/<productId>', (Request req, String productId) async {
    final mw = authMiddleware(db);
    final handler = mw((r) => favoritesCtrl.removeFavorite(r, productId));
    return handler(req);
  });

  // ══════════════════════════════════════════
  //  Branches Routes (عامة)
  // ══════════════════════════════════════════
  router.get('/api/branches', branchesCtrl.getBranches);
  router.get('/api/branches/<id>', (Request req, String id) => branchesCtrl.getBranchById(req, id));

  // ══════════════════════════════════════════
  //  Admin Routes (محمية + أدمن)
  // ══════════════════════════════════════════
  router.get('/api/admin/stats', Pipeline()
      .addMiddleware(authMiddleware(db))
      .addMiddleware(adminMiddleware(db))
      .addHandler(adminCtrl.getStats));
  router.get('/api/admin/orders', Pipeline()
      .addMiddleware(authMiddleware(db))
      .addMiddleware(adminMiddleware(db))
      .addHandler(adminCtrl.getOrders));
  router.put('/api/admin/orders/<id>/status', (Request req, String id) async {
    final mw1 = authMiddleware(db);
    final mw2 = adminMiddleware(db);
    final handler = mw1(mw2((r) => adminCtrl.updateOrderStatus(r, id)));
    return handler(req);
  });
  router.get('/api/admin/users', Pipeline()
      .addMiddleware(authMiddleware(db))
      .addMiddleware(adminMiddleware(db))
      .addHandler(adminCtrl.getUsers));
  router.get('/api/admin/products', Pipeline()
      .addMiddleware(authMiddleware(db))
      .addMiddleware(adminMiddleware(db))
      .addHandler(adminCtrl.getProducts));
  router.post('/api/admin/products', Pipeline()
      .addMiddleware(authMiddleware(db))
      .addMiddleware(adminMiddleware(db))
      .addHandler(adminCtrl.createProduct));
  router.put('/api/admin/products/<id>', (Request req, String id) async {
    final mw1 = authMiddleware(db);
    final mw2 = adminMiddleware(db);
    final handler = mw1(mw2((r) => adminCtrl.updateProduct(r, id)));
    return handler(req);
  });
  router.delete('/api/admin/products/<id>', (Request req, String id) async {
    final mw1 = authMiddleware(db);
    final mw2 = adminMiddleware(db);
    final handler = mw1(mw2((r) => adminCtrl.deleteProduct(r, id)));
    return handler(req);
  });
  router.get('/api/admin/categories', Pipeline()
      .addMiddleware(authMiddleware(db))
      .addMiddleware(adminMiddleware(db))
      .addHandler(adminCtrl.getCategories));

  // ══════════════════════════════════════════
  //  Health Check
  // ══════════════════════════════════════════
  router.get('/api/health', (Request req) {
    return Response.ok(
      '{"status":"ok","version":"2.0.0","database":"postgresql"}',
      headers: {'content-type': 'application/json'},
    );
  });

  // ══════════════════════════════════════════
  //  Admin Panel (Static Files)
  // ══════════════════════════════════════════
  final adminDir = Directory('admin');
  Handler? adminHandler;
  if (adminDir.existsSync()) {
    adminHandler = createStaticHandler('admin', defaultDocument: 'index.html');
  }

  // ══════════════════════════════════════════
  //  Flutter Web App (Static Files)
  // ══════════════════════════════════════════
  final webDir = Directory('web');
  Handler? webHandler;
  if (webDir.existsSync()) {
    webHandler = createStaticHandler('web', defaultDocument: 'index.html');
    print('📱 Flutter Web App found at /web directory');
  }

  // Pipeline
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addMiddleware(_addSecurityHeaders())
      .addHandler((Request request) {
    final path = request.url.path;

    // API routes → Router
    if (path.startsWith('api/') || path == 'api') {
      return router.call(request);
    }

    // Admin panel → /admin/
    if (path.startsWith('admin') && adminHandler != null) {
      return adminHandler!(request.change(path: 'admin'));
    }

    // Flutter Web App → كل شيء آخر
    if (webHandler != null) {
      return webHandler!(request);
    }

    return router.call(request);
  });

  // Start Server
  final port = EnvConfig.port;
  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
  print('');
  print('═══════════════════════════════════════════════');
  print('  🥤 Shalmoneh API Server v2.0');
  print('  📍 http://localhost:${server.port}');
  print('  📋 Health: http://localhost:${server.port}/api/health');
  print('  🛠 Admin:  http://localhost:${server.port}/admin/');
  print('  📱 Web:    http://localhost:${server.port}/');
  print('  🐘 DB: ${EnvConfig.dbHost}:${EnvConfig.dbPort}/${EnvConfig.dbName}');
  print('  📱 SMS: ${EnvConfig.isTwilioConfigured ? "Twilio ✅" : "Dev Mode (Console) ⚠️"}');
  print('═══════════════════════════════════════════════');
  print('');
}

/// Middleware لإضافة security headers
/// COOP: same-origin-allow-popups → ضروري لـ Google Sign-In popup
Middleware _addSecurityHeaders() {
  return (Handler innerHandler) {
    return (Request request) async {
      final response = await innerHandler(request);
      return response.change(headers: {
        'Cross-Origin-Opener-Policy': 'same-origin-allow-popups',
      });
    };
  };
}
