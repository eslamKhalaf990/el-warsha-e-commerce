import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:warsha_commerce/utils/const_values.dart';
import 'package:warsha_commerce/utils/default_footer.dart';
import 'package:warsha_commerce/view_models/customers_v_m.dart';
import 'package:warsha_commerce/view_models/user_v_m.dart';
import 'package:warsha_commerce/views/sign_in/login.dart';
import 'package:warsha_commerce/views/sign_in/sign_up.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  void initState() {
    super.initState();
    // Refresh user data when profile is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userVM = Provider.of<UserViewModel>(context, listen: false);
      if (userVM.token != "-") {
        userVM.fetchCustomerInfo();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CustomerVM, UserViewModel>(
      builder: (context, customerVM, userVM, child) {
        bool isAuthenticated = userVM.token != "-";

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            foregroundColor: const Color(0xFF222222),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              isAuthenticated ? 'الملف الشخصي' : 'تسجيل الدخول',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
              ),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool isDesktop = constraints.maxWidth > 900;
                
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? constraints.maxWidth * 0.1 : 16.0,
                    vertical: 24,
                  ),
                  child: Center(
                    child: Container(
                      constraints: BoxConstraints(maxWidth: isDesktop ? 1000 : 600),
                      child: Column(
                        children: [
                          isAuthenticated 
                              ? _buildProfileInfo(userVM, isDesktop)
                              : _buildAuthForms(customerVM, isDesktop),
                          const DefaultFooter(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileInfo(UserViewModel userVM, bool isDesktop) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Side: Profile Header
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildProfileHeader(userVM),
                const SizedBox(height: 24),
                _buildLogoutButton(userVM),
              ],
            ),
          ),
          const SizedBox(width: 40),
          // Right Side: Detailed Info
          Expanded(
            flex: 3,
            child: _buildInfoCard(userVM),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildProfileHeader(userVM),
        const SizedBox(height: 32),
        _buildInfoCard(userVM),
        const SizedBox(height: 32),
        _buildLogoutButton(userVM),
      ],
    );
  }

  Widget _buildProfileHeader(UserViewModel userVM) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF222222), width: 2),
              ),
              child: const CircleAvatar(
                radius: 60,
                backgroundColor: Color(0xFFF1F3F5),
                child: Icon(Iconsax.user_copy, size: 60, color: Color(0xFF222222)),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF222222),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.edit_2_copy, size: 18, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          userVM.name,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        ),
        const SizedBox(height: 4),
        Text(
          userVM.email,
          style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w400),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(UserViewModel userVM) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: () => userVM.logout(),
        icon: const Icon(Iconsax.logout_copy, size: 20),
        label: const Text('تسجيل الخروج', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.red,
          elevation: 0,
          side: const BorderSide(color: Colors.red, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: Constants.BORDER_RADIUS_5,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(UserViewModel userVM) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: Constants.BORDER_RADIUS_5,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Iconsax.personalcard_copy, size: 22),
              SizedBox(width: 12),
              Text(
                'المعلومات الشخصية',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoRow(Iconsax.call_copy, 'رقم الهاتف', userVM.phone),
          const Divider(height: 40, thickness: 1, color: Color(0xFFF1F3F5)),
          _buildInfoRow(Iconsax.location_copy, 'المحافظة', userVM.governorate),
          const Divider(height: 40, thickness: 1, color: Color(0xFFF1F3F5)),
          _buildInfoRow(Iconsax.home_copy, 'العنوان', userVM.address),
          const Divider(height: 40, thickness: 1, color: Color(0xFFF1F3F5)),
          _buildInfoRow(Iconsax.verify_copy, 'حالة الحساب', 'مفعل', isVerified: true),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isVerified = false}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF222222)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    value, 
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF222222))
                  ),
                  if (isVerified) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.verified, size: 16, color: Colors.blue),
                  ]
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAuthForms(CustomerVM customerVM, bool isDesktop) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Icon(Iconsax.user_add_copy, size: 60, color: Color(0xFF222222)),
        const SizedBox(height: 16),
        const Text(
          'مرحباً بك في ورشة',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF222222),
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'قم بتسجيل الدخول لمتابعة طلباتك والاستمتاع بمميزاتنا',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        const SizedBox(height: 40),
        Container(
          width: isDesktop ? 500 : double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: Constants.BORDER_RADIUS_5,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
              // Enhanced Tab Selector
              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: Constants.BORDER_RADIUS_5,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTabButton(
                        'تسجيل الدخول', 
                        customerVM.isLogin, 
                        () => customerVM.toggleLogin(true)
                      ),
                    ),
                    Expanded(
                      child: _buildTabButton(
                        'حساب جديد', 
                        !customerVM.isLogin, 
                        () => customerVM.toggleLogin(false)
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: customerVM.isLogin ? LoginForm() : SignUpForm(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF222222) : Colors.transparent,
          borderRadius: Constants.BORDER_RADIUS_5,
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ] : [],
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}
