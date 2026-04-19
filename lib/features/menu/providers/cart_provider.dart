import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shalmoneh_app/features/menu/data/models/cart_item_model.dart';

/// Provider للسلة — يدير عناصر السلة عبر كل التطبيق
final cartProvider = NotifierProvider<CartNotifier, List<CartItemModel>>(
  CartNotifier.new,
);

/// Provider لعدد العناصر في السلة (للـ Badge)
final cartCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).fold(0, (sum, item) => sum + item.quantity);
});

/// Provider للمجموع الكلي
final cartTotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).fold(0.0, (sum, item) => sum + item.totalPrice);
});

class CartNotifier extends Notifier<List<CartItemModel>> {
  @override
  List<CartItemModel> build() => [];

  /// إضافة عنصر للسلة
  void addItem(CartItemModel item) {
    state = [...state, item];
  }

  /// تعديل الكمية
  void updateQuantity(String itemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(itemId);
      return;
    }
    state = state.map((item) {
      if (item.id == itemId) {
        item.quantity = newQuantity;
        return item;
      }
      return item;
    }).toList();
    // Force rebuild
    state = [...state];
  }

  /// حذف عنصر
  void removeItem(String itemId) {
    state = state.where((item) => item.id != itemId).toList();
  }

  /// تفريغ السلة
  void clearCart() {
    state = [];
  }

  /// هل السلة فارغة؟
  bool get isEmpty => state.isEmpty;

  /// عدد العناصر
  int get itemCount => state.fold(0, (sum, item) => sum + item.quantity);
}
