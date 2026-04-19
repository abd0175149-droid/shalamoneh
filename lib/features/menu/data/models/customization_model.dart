/// أحجام المشروب
enum DrinkSize { S, M, L }

/// مستويات السكر
enum SugarLevel { none, light, medium, extra }

/// مستويات الثلج
enum IceLevel { none, light, medium, extra }

/// نوع الاستلام
enum OrderType { pickup, dineIn }

/// حالة الطلب
enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  completed,
  cancelled,
}

// ══════════════════════════════════════════
//  تسميات عربية
// ══════════════════════════════════════════

extension DrinkSizeExt on DrinkSize {
  String get label {
    switch (this) {
      case DrinkSize.S: return 'صغير';
      case DrinkSize.M: return 'وسط';
      case DrinkSize.L: return 'كبير';
    }
  }
  String get shortLabel {
    switch (this) {
      case DrinkSize.S: return 'S';
      case DrinkSize.M: return 'M';
      case DrinkSize.L: return 'L';
    }
  }
}

extension SugarLevelExt on SugarLevel {
  String get label {
    switch (this) {
      case SugarLevel.none: return 'بدون';
      case SugarLevel.light: return 'خفيف';
      case SugarLevel.medium: return 'وسط';
      case SugarLevel.extra: return 'زيادة';
    }
  }
}

extension IceLevelExt on IceLevel {
  String get label {
    switch (this) {
      case IceLevel.none: return 'بدون';
      case IceLevel.light: return 'خفيف';
      case IceLevel.medium: return 'وسط';
      case IceLevel.extra: return 'زيادة';
    }
  }
}

extension OrderTypeExt on OrderType {
  String get label {
    switch (this) {
      case OrderType.pickup: return 'استلام من الفرع';
      case OrderType.dineIn: return 'تناول في المحل';
    }
  }
}

extension OrderStatusExt on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending: return 'قيد الانتظار';
      case OrderStatus.confirmed: return 'تم التأكيد';
      case OrderStatus.preparing: return 'قيد التحضير';
      case OrderStatus.ready: return 'جاهز للاستلام';
      case OrderStatus.completed: return 'مكتمل';
      case OrderStatus.cancelled: return 'ملغي';
    }
  }
}
