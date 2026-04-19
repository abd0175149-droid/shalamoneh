import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shalmoneh_app/core/theme/app_colors.dart';
import 'package:shalmoneh_app/core/constants/app_sizes.dart';
import 'package:shalmoneh_app/core/network/api_client.dart';
import 'package:shalmoneh_app/core/network/api_endpoints.dart';
import 'package:shalmoneh_app/features/menu/providers/cart_provider.dart';
import 'package:shalmoneh_app/features/menu/data/models/customization_model.dart';

/// شاشة تأكيد الطلب — نوع الاستلام + اختيار فرع + ملخص + إرسال حقيقي عبر API
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  OrderType _orderType = OrderType.pickup;
  String? _selectedBranchId;
  String _selectedBranchName = '';
  bool _isProcessing = false;
  bool _isLoadingBranches = true;
  List<Map<String, dynamic>> _branches = [];
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  /// جلب الفروع من API
  Future<void> _loadBranches() async {
    try {
      final response = await apiClient.get(ApiEndpoints.branches);
      if (response.success && response.data != null) {
        final list = response.data as List<dynamic>;
        setState(() {
          _branches = list.map((e) => e as Map<String, dynamic>).toList();
          if (_branches.isNotEmpty) {
            _selectedBranchId = _branches[0]['id']?.toString();
            _selectedBranchName = _branches[0]['name']?.toString() ?? '';
          }
          _isLoadingBranches = false;
        });
      } else {
        setState(() => _isLoadingBranches = false);
      }
    } catch (e) {
      // Fallback: فروع ثابتة
      setState(() {
        _branches = [
          {'id': 'default', 'name': 'فرع الشميساني'},
          {'id': 'default2', 'name': 'فرع عبدون'},
        ];
        _selectedBranchId = 'default';
        _selectedBranchName = 'فرع الشميساني';
        _isLoadingBranches = false;
      });
    }
  }

  /// إرسال الطلب عبر API
  Future<void> _placeOrder() async {
    setState(() => _isProcessing = true);

    try {
      final cartItems = ref.read(cartProvider);

      // بناء payload الطلب
      final orderPayload = {
        'branch_id': _selectedBranchId,
        'order_type': _orderType == OrderType.pickup ? 'pickup' : 'dine_in',
        'notes': _notesController.text.trim(),
        'items': cartItems.map((item) => {
          'product_id': item.product.id,
          'size': item.selectedSize.shortLabel,
          'quantity': item.quantity,
          'sugar_level': item.sugarLevel.name,
          'ice_level': item.iceLevel.name,
          'addons': item.selectedAddons.map((a) => a.id).toList(),
          'notes': item.notes,
        }).toList(),
      };

      final response = await apiClient.post(
        ApiEndpoints.orders,
        body: orderPayload,
      );

      if (!mounted) return;
      setState(() => _isProcessing = false);

      if (response.success) {
        final orderData = response.data as Map<String, dynamic>?;
        final orderNumber = orderData?['order_number'] ?? '#${DateTime.now().millisecondsSinceEpoch % 10000}';

        // تفريغ السلة
        ref.read(cartProvider.notifier).clearCart();

        // عرض شاشة النجاح
        _showSuccessDialog(orderNumber.toString());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'خطأ في إرسال الطلب'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في الاتصال: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showSuccessDialog(String orderNumber) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLG)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 50),
              ),
              const SizedBox(height: AppSizes.paddingMD),
              Text('تم تأكيد الطلب! ✅',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  )),
              const SizedBox(height: AppSizes.paddingSM),
              Text('رقم الطلب: $orderNumber',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryYellow,
                    fontWeight: FontWeight.w700,
                  )),
              const SizedBox(height: AppSizes.paddingSM),
              Text('الوقت المتوقع: 10-15 دقيقة',
                  style: Theme.of(context).textTheme.bodyMedium),
              Text('الفرع: $_selectedBranchName',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: AppSizes.paddingLG),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context); // إغلاق Dialog
                  Navigator.pop(context); // إغلاق Checkout
                  Navigator.pop(context); // إغلاق Cart
                },
                child: Container(
                  width: double.infinity,
                  height: AppSizes.buttonHeight,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                  ),
                  child: const Center(
                    child: Text('العودة للرئيسية 🏠',
                        style: TextStyle(color: AppColors.onPrimary,
                            fontWeight: FontWeight.w700, fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final cartTotal = ref.watch(cartTotalProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('تأكيد الطلب', style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
        )),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── نوع الاستلام ───
            Text('نوع الاستلام', style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            )),
            const SizedBox(height: AppSizes.paddingSM),
            Row(
              children: OrderType.values.map((type) {
                final isSelected = _orderType == type;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _orderType = type),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMD),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryYellow
                            : (isDark ? AppColors.darkCard : AppColors.lightCard),
                        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                        border: isSelected ? null : Border.all(
                          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            type == OrderType.pickup
                                ? Icons.takeout_dining_rounded
                                : Icons.restaurant_rounded,
                            color: isSelected ? AppColors.onPrimary
                                : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                          ),
                          const SizedBox(height: 4),
                          Text(type.label, style: theme.textTheme.labelMedium?.copyWith(
                            color: isSelected ? AppColors.onPrimary : null,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          )),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSizes.paddingLG),

            // ─── اختيار الفرع من API ───
            Text('الفرع', style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            )),
            const SizedBox(height: AppSizes.paddingSM),
            _isLoadingBranches
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryYellow))
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                      border: Border.all(
                        color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedBranchId,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down_rounded),
                        items: _branches.map((b) => DropdownMenuItem(
                          value: b['id']?.toString(),
                          child: Text(b['name']?.toString() ?? ''),
                        )).toList(),
                        onChanged: (v) {
                          if (v != null) {
                            final branch = _branches.firstWhere((b) => b['id']?.toString() == v);
                            setState(() {
                              _selectedBranchId = v;
                              _selectedBranchName = branch['name']?.toString() ?? '';
                            });
                          }
                        },
                      ),
                    ),
                  ),
            const SizedBox(height: AppSizes.paddingLG),

            // ─── ملخص الطلب ───
            Text('ملخص الطلب', style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            )),
            const SizedBox(height: AppSizes.paddingSM),
            ...cartItems.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.paddingSM),
              child: Row(
                children: [
                  Text('${item.quantity}x', style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.primaryYellow, fontWeight: FontWeight.w700,
                  )),
                  const SizedBox(width: AppSizes.paddingSM),
                  Expanded(child: Text(item.product.name, style: theme.textTheme.bodyMedium)),
                  Text('${item.totalPrice.toStringAsFixed(2)} JOD',
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            )),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('المجموع', style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                )),
                Text('${cartTotal.toStringAsFixed(2)} JOD', style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.primaryYellow, fontWeight: FontWeight.w800,
                )),
              ],
            ),
            const SizedBox(height: AppSizes.paddingLG),

            // ─── ملاحظات ───
            Text('ملاحظات إضافية', style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            )),
            const SizedBox(height: AppSizes.paddingSM),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'أي ملاحظات خاصة بالطلب...',
              ),
            ),
            const SizedBox(height: AppSizes.paddingXL),

            // ─── زر تأكيد ───
            GestureDetector(
              onTap: _isProcessing ? null : _placeOrder,
              child: Container(
                width: double.infinity,
                height: AppSizes.buttonHeight,
                decoration: BoxDecoration(
                  gradient: _isProcessing ? null : AppColors.primaryGradient,
                  color: _isProcessing ? (isDark ? AppColors.darkCard : AppColors.lightDivider) : null,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                  boxShadow: _isProcessing ? null : [
                    BoxShadow(
                      color: AppColors.primaryYellow.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: _isProcessing
                      ? const SizedBox(width: 24, height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5,
                              color: AppColors.primaryYellow))
                      : const Text('تأكيد وإرسال الطلب ✅',
                          style: TextStyle(color: AppColors.onPrimary,
                              fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.paddingLG),
          ],
        ),
      ),
    );
  }
}
