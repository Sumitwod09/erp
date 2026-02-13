import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/services/nhost_service.dart';
import '../models/business_model.dart';

class BusinessProfileScreen extends ConsumerStatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  ConsumerState<BusinessProfileScreen> createState() =>
      _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends ConsumerState<BusinessProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _websiteController;

  bool _isLoading = true;
  String? _error;
  String? _businessId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _websiteController = TextEditingController();
    _loadBusinessData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _loadBusinessData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = NhostService.currentUser;
      if (user == null) throw Exception('User not logged in');

      // fetch business_id from user
      final userQuery = gql('''
        query GetUser(\$id: uuid!) {
          ${AppConstants.usersTable}_by_pk(id: \$id) {
            business_id
          }
        }
      ''');

      final userResult = await NhostService.graphqlClient.query(
        QueryOptions(
          document: userQuery,
          variables: {'id': user.id},
        ),
      );

      if (userResult.hasException) {
        throw Exception(userResult.exception.toString());
      }

      final businessId =
          userResult.data?['${AppConstants.usersTable}_by_pk']['business_id'];
      if (businessId == null) throw Exception('Business not found');
      _businessId = businessId;

      // Fetch business data
      final businessQuery = gql('''
        query GetBusiness(\$id: uuid!) {
          ${AppConstants.businessesTable}_by_pk(id: \$id) {
            id
            name
            address
            phone
            email
            website
          }
        }
      ''');

      final businessResult = await NhostService.graphqlClient.query(
        QueryOptions(
          document: businessQuery,
          variables: {'id': businessId},
        ),
      );

      if (businessResult.hasException) {
        throw Exception(businessResult.exception.toString());
      }

      final businessData =
          businessResult.data?['${AppConstants.businessesTable}_by_pk'];
      if (businessData == null) throw Exception('Business data not found');

      final business = Business.fromJson(businessData);

      _nameController.text = business.name;
      _addressController.text = business.address ?? '';
      _phoneController.text = business.phone ?? '';
      _emailController.text = business.email ?? '';
      _websiteController.text = business.website ?? '';
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveBusinessData() async {
    if (!_formKey.currentState!.validate()) return;
    if (_businessId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final mutation = gql('''
        mutation UpdateBusiness(\$id: uuid!, \$name: String!, \$address: String, \$phone: String, \$email: String, \$website: String) {
          update_${AppConstants.businessesTable}_by_pk(
            pk_columns: {id: \$id},
            _set: {
              name: \$name,
              address: \$address,
              phone: \$phone,
              email: \$email,
              website: \$website
            }
          ) {
            id
          }
        }
      ''');

      final result = await NhostService.graphqlClient.mutate(
        MutationOptions(
          document: mutation,
          variables: {
            'id': _businessId,
            'name': _nameController.text.trim(),
            'address': _addressController.text.trim(),
            'phone': _phoneController.text.trim(),
            'email': _emailController.text.trim(),
            'website': _websiteController.text.trim(),
          },
        ),
      );

      if (result.hasException) throw Exception(result.exception.toString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Business profile updated successfully'),
              backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to update: $e'),
              backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
            child: Text('Error: $_error',
                style: const TextStyle(color: AppColors.error))),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.neutralGrey,
      appBar: AppBar(
        title: const Text('Business Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spaceLg),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(AppConstants.spaceXl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Company Details',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeXl,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceLg),

                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                      labelText: 'Business Name', border: OutlineInputBorder()),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: AppConstants.spaceMd),

                // Address
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                      labelText: 'Address', border: OutlineInputBorder()),
                  maxLines: 3,
                ),
                const SizedBox(height: AppConstants.spaceMd),

                // Contact Info
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                            labelText: 'Phone', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spaceMd),
                    Expanded(
                      child: TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                            labelText: 'Email', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spaceMd),

                // Website
                TextFormField(
                  controller: _websiteController,
                  decoration: const InputDecoration(
                      labelText: 'Website', border: OutlineInputBorder()),
                ),
                const SizedBox(height: AppConstants.spaceXl),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveBusinessData,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: AppConstants.spaceMd),
                    ),
                    child: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
