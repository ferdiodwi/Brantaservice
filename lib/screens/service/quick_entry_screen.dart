import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/service_provider.dart';
import '../../providers/customer_provider.dart';
import '../../data/models/service.dart';
import '../../data/models/customer.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/utils/formatters.dart';

/// QuickEntryScreen - Form untuk menambah service baru
class QuickEntryScreen extends ConsumerStatefulWidget {
  const QuickEntryScreen({super.key});

  @override
  ConsumerState<QuickEntryScreen> createState() => _QuickEntryScreenState();
}

class _QuickEntryScreenState extends ConsumerState<QuickEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;
  
  // Customer info controllers
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  
  // Device info controllers
  final _deviceModelController = TextEditingController();
  final _deviceColorController = TextEditingController();
  final _imeiController = TextEditingController();
  final _serialController = TextEditingController();
  String _selectedBrand = 'Apple';
  
  // Problem info controllers
  final _problemController = TextEditingController();
  final _estimatedCostController = TextEditingController();
  final _notesController = TextEditingController();
  
  // Existing customer
  Customer? _selectedCustomer;
  bool _isNewCustomer = true;
  
  final List<String> _brands = [
    'Apple', 'Samsung', 'Xiaomi', 'Oppo', 'Vivo', 
    'Realme', 'Huawei', 'OnePlus', 'Google', 'Other'
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _deviceModelController.dispose();
    _deviceColorController.dispose();
    _imeiController.dispose();
    _serialController.dispose();
    _problemController.dispose();
    _estimatedCostController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return BackButtonListener(
      onBackButtonPressed: () async {
        _showExitConfirmation(context);
        return true;
      },
      child: Scaffold(
        // backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(l10n.translate('entry_title')),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => _showExitConfirmation(context),
          ),
        ),
        body: Column(
        children: [
          // Progress Indicator
          _StepIndicator(currentStep: _currentStep),
          
          // Form Pages
          Expanded(
            child: Form(
              key: _formKey,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentStep = index),
                children: [
                  _buildCustomerStep(),
                  _buildDeviceStep(),
                  _buildProblemStep(),
                  _buildReviewStep(),
                ],
              ),
            ),
          ),
          
          // Navigation Buttons
          _buildNavigationButtons(),
        ],
      ),
      ),
    );
  }

  /// Step 1: Customer Information
  Widget _buildCustomerStep() {
    final customers = ref.watch(customerProvider);
    final l10n = AppLocalizations.of(context)!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.translate('entry_step_customer'), style: AppTypography.headingXS.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          )),
          const Gap(8),
          Text(
            l10n.translate('entry_step_customer_desc'),
            style: AppTypography.bodySM.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const Gap(24),
          
          // Customer type toggle
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isNewCustomer = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _isNewCustomer ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          l10n.translate('entry_type_new'),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _isNewCustomer ? AppColors.white : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isNewCustomer = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_isNewCustomer ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          l10n.translate('entry_type_existing'),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: !_isNewCustomer ? AppColors.white : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Gap(24),
          
          if (_isNewCustomer) ...[
            // New customer form
            TextFormField(
              controller: _customerNameController,
              decoration: InputDecoration(
                labelText: l10n.translate('entry_field_name'),
                hintText: l10n.translate('entry_field_name_hint'),
                prefixIcon: const Icon(Icons.person_outline_rounded),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.translate('entry_error_customer_name');
                }
                return null;
              },
            ),
            const Gap(16),
            TextFormField(
              controller: _customerPhoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: l10n.translate('entry_field_phone'),
                hintText: '08xxxxxxxxxx',
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.translate('entry_error_phone');
                }
                return null;
              },
            ),
          ] else ...[
            // Existing customer search
            if (customers.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.people_outline_rounded,
                        size: 64,
                        color: AppColors.textTertiary.withOpacity(0.5),
                      ),
                      const Gap(16),
                      Text(
                        l10n.translate('entry_empty_customer'),
                        style: AppTypography.bodyMD.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: customers.length,
                itemBuilder: (context, index) {
                  final customer = customers[index];
                  final isSelected = _selectedCustomer?.id == customer.id;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withOpacity(0.1) : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: ListTile(
                      onTap: () {
                        setState(() {
                          _selectedCustomer = customer;
                          _customerNameController.text = customer.name;
                          _customerPhoneController.text = customer.phoneNumber;
                        });
                      },
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Text(
                          customer.initials,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(customer.name, style: AppTypography.labelLG),
                      subtitle: Text(customer.phoneNumber),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                          : null,
                    ),
                  );
                },
              ),
          ],
        ],
      ),
    );
  }

  /// Step 2: Device Information
  Widget _buildDeviceStep() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.translate('entry_step_device'), style: AppTypography.headingXS.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          )),
          const Gap(8),
          Text(
            l10n.translate('entry_step_device_desc'),
            style: AppTypography.bodySM.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const Gap(24),
          
          // Brand Selection
          Text(l10n.translate('entry_label_brand'), style: AppTypography.labelMD),
          const Gap(8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _brands.map((brand) {
              final isSelected = _selectedBrand == brand;
              return GestureDetector(
                onTap: () => setState(() => _selectedBrand = brand),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Text(
                    brand,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isSelected ? AppColors.white : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const Gap(20),
          
          TextFormField(
            controller: _deviceModelController,
            decoration: InputDecoration(
              labelText: l10n.translate('entry_field_model'),
              hintText: l10n.translate('entry_field_model_hint'),
              prefixIcon: const Icon(Icons.phone_android_rounded),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.translate('entry_error_model');
              }
              return null;
            },
          ),
          const Gap(16),
          
          TextFormField(
            controller: _deviceColorController,
            decoration: InputDecoration(
              labelText: l10n.translate('entry_field_color'),
              hintText: l10n.translate('entry_field_color_hint'),
              prefixIcon: const Icon(Icons.palette_outlined),
            ),
          ),
          const Gap(16),
          
          TextFormField(
            controller: _imeiController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: '${l10n.translate('entry_field_imei')} (${l10n.translate('common_optional')})',
              hintText: l10n.translate('entry_field_imei_hint'),
              prefixIcon: const Icon(Icons.numbers_rounded),
            ),
          ),
          const Gap(16),
          
          TextFormField(
            controller: _serialController,
            decoration: InputDecoration(
              labelText: '${l10n.translate('entry_field_serial')} (${l10n.translate('common_optional')})',
              hintText: l10n.translate('entry_field_serial_hint'),
              prefixIcon: const Icon(Icons.qr_code_rounded),
            ),
          ),
        ],
      ),
    );
  }

  /// Step 3: Problem Description
  Widget _buildProblemStep() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.translate('entry_step_problem'), style: AppTypography.headingXS.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          )),
          const Gap(8),
          Text(
            l10n.translate('entry_step_problem_desc'),
            style: AppTypography.bodySM.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const Gap(24),
          
          TextFormField(
            controller: _problemController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: l10n.translate('entry_field_problem'),
              hintText: l10n.translate('entry_field_problem_hint'),
              alignLabelWithHint: true,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.translate('entry_error_problem');
              }
              return null;
            },
          ),
          const Gap(16),
          
          TextFormField(
            controller: _estimatedCostController,
            keyboardType: TextInputType.number,
            inputFormatters: [ThousandSeparatorInputFormatter()],
            decoration: InputDecoration(
              labelText: l10n.translate('entry_field_cost'),
              hintText: '0',
              prefixText: 'Rp ',
              prefixIcon: const Icon(Icons.attach_money_rounded),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.translate('entry_error_cost');
              }
              return null;
            },
          ),
          const Gap(16),
          
          TextFormField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: l10n.translate('entry_field_notes'),
              hintText: l10n.translate('entry_field_notes_hint'),
              alignLabelWithHint: true,
            ),
          ),
          const Gap(24),
          
          // Quick problem tags
          Text(l10n.translate('entry_label_tags'), style: AppTypography.labelMD),
          const Gap(12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              {'key': 'entry_tag_screen_crack'},
              {'key': 'entry_tag_battery'},
              {'key': 'entry_tag_charging'},
              {'key': 'entry_tag_water'},
              {'key': 'entry_tag_software'},
              {'key': 'entry_tag_camera'},
            ].map((tagData) {
              final tag = l10n.translate(tagData['key']!);
              return _QuickTag(
                label: tag,
                onTap: () {
                  if (_problemController.text.isNotEmpty) {
                    _problemController.text += ', $tag';
                  } else {
                    _problemController.text = tag;
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Step 4: Review
  Widget _buildReviewStep() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.translate('entry_step_review'), style: AppTypography.headingXS.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          )),
          const Gap(8),
          Text(
            l10n.translate('entry_step_review_desc'),
            style: AppTypography.bodySM.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const Gap(24),
          
          // Customer Card
          _ReviewCard(
            title: l10n.translate('entry_review_customer'),
            icon: Icons.person_rounded,
            children: [
              _ReviewRow(label: l10n.translate('entry_review_name'), value: _customerNameController.text),
              _ReviewRow(label: l10n.translate('entry_review_phone'), value: _customerPhoneController.text),
            ],
          ),
          const Gap(16),
          
          // Device Card
          _ReviewCard(
            title: l10n.translate('entry_review_device'),
            icon: Icons.phone_android_rounded,
            children: [
              _ReviewRow(label: l10n.translate('entry_review_brand'), value: _selectedBrand),
              _ReviewRow(label: l10n.translate('entry_review_model'), value: _deviceModelController.text),
              if (_deviceColorController.text.isNotEmpty)
                _ReviewRow(label: l10n.translate('entry_review_color'), value: _deviceColorController.text),
              if (_imeiController.text.isNotEmpty)
                _ReviewRow(label: l10n.translate('entry_review_imei'), value: _imeiController.text),
            ],
          ),
          const Gap(16),
          
          // Problem Card
          _ReviewCard(
            title: l10n.translate('entry_review_problem'),
            icon: Icons.build_rounded,
            children: [
              _ReviewRow(label: l10n.translate('entry_review_issue'), value: _problemController.text),
              _ReviewRow(
                label: l10n.translate('entry_review_cost'),
                value: 'Rp ${_estimatedCostController.text}',
                isHighlighted: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).bottomAppBarTheme.color ?? Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: Text(l10n.translate('entry_btn_back')),
              ),
            ),
          if (_currentStep > 0) const Gap(16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _currentStep < 3 ? _nextStep : _submitService,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _currentStep < 3 ? l10n.translate('entry_btn_continue') : l10n.translate('entry_btn_create'),
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    final l10n = AppLocalizations.of(context)!;
    if (_currentStep == 0) {
      if (_isNewCustomer) {
        if (_customerNameController.text.isEmpty || 
            _customerPhoneController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.translate('entry_error_customer_info'))),
          );
          return;
        }
      } else if (_selectedCustomer == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.translate('entry_error_customer_info'))),
        );
        return;
      }
    }
    
    if (_currentStep == 1 && _deviceModelController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('entry_error_device_info'))),
      );
      return;
    }
    
    if (_currentStep == 2) {
      if (_problemController.text.isEmpty || 
          _estimatedCostController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.translate('entry_error_problem_info'))),
        );
        return;
      }
    }
    
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousStep() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _submitService() async {
    final uuid = const Uuid();
    final l10n = AppLocalizations.of(context)!;
    String customerId;
    
    // Create or get customer
    if (_isNewCustomer) {
      customerId = uuid.v4();
      final newCustomer = Customer(
        id: customerId,
        name: _customerNameController.text.trim(),
        phoneNumber: _customerPhoneController.text.trim(),
        createdAt: DateTime.now(),
      );
      await ref.read(customerProvider.notifier).addCustomer(newCustomer);
    } else {
      customerId = _selectedCustomer!.id;
    }
    
    // Parse estimated cost
    final estimatedCost = double.tryParse(
      _estimatedCostController.text.replaceAll(RegExp(r'[^0-9]'), '')
    ) ?? 0.0;
    
    // Create service
    final service = Service(
      id: uuid.v4(),
      customerId: customerId,
      customerName: _customerNameController.text.trim(),
      customerPhone: _customerPhoneController.text.trim(),
      deviceBrand: _selectedBrand,
      deviceModel: _deviceModelController.text.trim(),
      deviceColor: _deviceColorController.text.trim().isNotEmpty 
          ? _deviceColorController.text.trim() 
          : null,
      imei: _imeiController.text.trim().isNotEmpty 
          ? _imeiController.text.trim() 
          : null,
      serialNumber: _serialController.text.trim().isNotEmpty 
          ? _serialController.text.trim() 
          : null,
      problemDescription: _problemController.text.trim(),
      estimatedCost: estimatedCost,
      notes: _notesController.text.trim().isNotEmpty 
          ? _notesController.text.trim() 
          : null,
      status: ServiceStatus.checkIn,
      createdAt: DateTime.now(),
    );
    
    await ref.read(serviceProvider.notifier).addService(service);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.translate('entry_msg_success')),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/');
    }
  }

  void _showExitConfirmation(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.translate('entry_dialog_discard_title')),
        content: Text(l10n.translate('entry_dialog_discard_content')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.translate('dialog_cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.translate('entry_dialog_discard_action')),
          ),
        ],
      ),
    );
  }
}

/// Step Indicator Widget
class _StepIndicator extends StatelessWidget {
  final int currentStep;
  
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index <= currentStep;
          final isCompleted = index < currentStep;
          
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check_rounded, size: 16, color: AppColors.white)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isActive ? AppColors.white : Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                  ),
                ),
                if (index < 3)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: index < currentStep ? AppColors.primary : AppColors.surfaceVariant,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

/// Quick Tag Widget
class _QuickTag extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  
  const _QuickTag({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTypography.bodySM.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// Review Card Widget
class _ReviewCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  
  const _ReviewCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),
              const Gap(12),
              Text(title, style: AppTypography.labelLG.copyWith(color: Theme.of(context).colorScheme.onSurface)),
            ],
          ),
          const Gap(16),
          ...children,
        ],
      ),
    );
  }
}

/// Review Row Widget
class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlighted;
  
  const _ReviewRow({
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTypography.bodySM.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: isHighlighted
                  ? AppTypography.labelMD.copyWith(color: AppColors.primary)
                  : AppTypography.bodySM.copyWith(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
