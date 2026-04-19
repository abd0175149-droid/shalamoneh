/// نموذج الفرع
class BranchModel {
  final String id;
  final String name;
  final String address;
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final String phone;
  final String workingHours;
  final bool isOpen;
  final double? distanceKm;

  const BranchModel({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.phone = '',
    this.workingHours = '8:00 AM - 12:00 AM',
    this.isOpen = true,
    this.distanceKm,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      city: json['city'] as String? ?? '',
      country: json['country'] as String? ?? 'الأردن',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      phone: json['phone'] as String? ?? '',
      workingHours: json['working_hours'] as String? ?? '8:00 AM - 12:00 AM',
      isOpen: json['is_open'] as bool? ?? true,
    );
  }
}

/// بيانات Mock للفروع
class MockBranches {
  MockBranches._();

  static final branches = [
    const BranchModel(
      id: 'b1', name: 'فرع الشميساني', address: 'شارع الشريف ناصر بن جميل',
      city: 'عمان', country: 'الأردن',
      latitude: 31.9661, longitude: 35.9102, phone: '06-5XXX001',
      isOpen: true, distanceKm: 1.2,
    ),
    const BranchModel(
      id: 'b2', name: 'فرع عبدون', address: 'دوار عبدون، بجانب كوزمو',
      city: 'عمان', country: 'الأردن',
      latitude: 31.9544, longitude: 35.8823, phone: '06-5XXX002',
      isOpen: true, distanceKm: 2.5,
    ),
    const BranchModel(
      id: 'b3', name: 'فرع الجاردنز', address: 'شارع وصفي التل، الجاردنز',
      city: 'عمان', country: 'الأردن',
      latitude: 31.9715, longitude: 35.8958, phone: '06-5XXX003',
      isOpen: true, distanceKm: 3.1,
    ),
    const BranchModel(
      id: 'b4', name: 'فرع المدينة الرياضية', address: 'بجانب مجمع الحسين',
      city: 'عمان', country: 'الأردن',
      latitude: 31.9875, longitude: 35.9287, phone: '06-5XXX004',
      isOpen: false, distanceKm: 4.0,
    ),
    const BranchModel(
      id: 'b5', name: 'فرع الجبيهة', address: 'مقابل الجامعة الأردنية',
      city: 'عمان', country: 'الأردن',
      latitude: 32.0183, longitude: 35.8714, phone: '06-5XXX005',
      isOpen: true, distanceKm: 5.3,
    ),
    const BranchModel(
      id: 'b6', name: 'فرع طبربور', address: 'شارع الاستقلال، طبربور',
      city: 'عمان', country: 'الأردن',
      latitude: 32.0031, longitude: 35.9601, phone: '06-5XXX006',
      isOpen: true, distanceKm: 6.8,
    ),
    const BranchModel(
      id: 'b7', name: 'فرع إربد', address: 'شارع الجامعة، إربد',
      city: 'إربد', country: 'الأردن',
      latitude: 32.5568, longitude: 35.8469, phone: '02-7XXX001',
      isOpen: true, distanceKm: 85.0,
    ),
    const BranchModel(
      id: 'b8', name: 'فرع الرياض', address: 'حي العليا، الرياض',
      city: 'الرياض', country: 'السعودية',
      latitude: 24.7136, longitude: 46.6753, phone: '+966-5XXX001',
      isOpen: true,
    ),
  ];

  /// الفروع القريبة (مرتبة بالمسافة)
  static List<BranchModel> get nearbyBranches {
    final sorted = List<BranchModel>.from(branches);
    sorted.sort((a, b) => (a.distanceKm ?? 999).compareTo(b.distanceKm ?? 999));
    return sorted;
  }

  /// الفروع المفتوحة فقط
  static List<BranchModel> get openBranches =>
      branches.where((b) => b.isOpen).toList();

  /// الفروع حسب المدينة
  static List<BranchModel> branchesByCity(String city) =>
      branches.where((b) => b.city == city).toList();

  /// المدن المتاحة
  static List<String> get cities =>
      branches.map((b) => b.city).toSet().toList();
}
