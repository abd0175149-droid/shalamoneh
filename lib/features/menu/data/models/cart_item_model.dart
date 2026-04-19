import 'package:shalmoneh_app/features/menu/data/models/product_model.dart';
import 'package:shalmoneh_app/features/menu/data/models/customization_model.dart';

/// عنصر في السلة — منتج + تخصيصات + كمية + سعر محسوب
class CartItemModel {
  final String id;
  final ProductModel product;
  final DrinkSize selectedSize;
  final SugarLevel sugarLevel;
  final IceLevel iceLevel;
  final List<AddonModel> selectedAddons;
  int quantity;
  final String? notes;

  CartItemModel({
    required this.id,
    required this.product,
    this.selectedSize = DrinkSize.M,
    this.sugarLevel = SugarLevel.medium,
    this.iceLevel = IceLevel.medium,
    this.selectedAddons = const [],
    this.quantity = 1,
    this.notes,
  });

  /// سعر الحجم المختار
  double get sizePrice => product.priceForSize(selectedSize.shortLabel);

  /// مجموع أسعار الإضافات
  double get addonsPrice =>
      selectedAddons.fold(0.0, (sum, addon) => sum + addon.price);

  /// السعر الإجمالي = (سعر الحجم + الإضافات) × الكمية
  double get totalPrice => (sizePrice + addonsPrice) * quantity;

  /// وصف التخصيص
  String get customizationSummary {
    final parts = <String>[];
    parts.add(selectedSize.label);
    parts.add('سكر ${sugarLevel.label}');
    parts.add('ثلج ${iceLevel.label}');
    if (selectedAddons.isNotEmpty) {
      parts.add(selectedAddons.map((a) => a.name).join('، '));
    }
    return parts.join(' • ');
  }

  CartItemModel copyWith({
    DrinkSize? selectedSize,
    SugarLevel? sugarLevel,
    IceLevel? iceLevel,
    List<AddonModel>? selectedAddons,
    int? quantity,
    String? notes,
  }) {
    return CartItemModel(
      id: id,
      product: product,
      selectedSize: selectedSize ?? this.selectedSize,
      sugarLevel: sugarLevel ?? this.sugarLevel,
      iceLevel: iceLevel ?? this.iceLevel,
      selectedAddons: selectedAddons ?? this.selectedAddons,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
    );
  }
}
