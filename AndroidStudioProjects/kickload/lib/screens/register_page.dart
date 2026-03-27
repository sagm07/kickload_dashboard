import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'sign_in.dart';
import 'dashboard_page.dart';
import 'local_user_store.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _orgNameController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  String? _selectedCountry;
  String? _selectedOrgType;
  double _passwordStrength = 0.0;
  Color _strengthColor = Colors.red;
  String _strengthLabel = '';

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final List<String> _countries = [
    'India', 'United States', 'United Kingdom', 'Canada',
    'Australia', 'Germany', 'France', 'Japan', 'Singapore', 'Other',
  ];

  final List<String> _orgTypes = [
    'Startup', 'Small Business', 'Enterprise',
    'Non-Profit', 'Educational', 'Government', 'Freelancer', 'Other',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();

    _passwordController.addListener(_checkStrength);
  }

  @override
  void dispose() {
    _animController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _orgNameController.dispose();
    super.dispose();
  }

  // ── Password strength ───────────────────────────────────────────────────────

  void _checkStrength() {
    final pw = _passwordController.text;
    double s = 0;
    if (pw.length >= 8) s += 0.25;
    if (pw.contains(RegExp(r'[A-Z]'))) s += 0.25;
    if (pw.contains(RegExp(r'[0-9]'))) s += 0.25;
    if (pw.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) s += 0.25;

    Color color;
    String label;
    if (s <= 0.25) {
      color = Colors.red;
      label = 'Weak';
    } else if (s <= 0.5) {
      color = Colors.orange;
      label = 'Fair';
    } else if (s <= 0.75) {
      color = Colors.yellow;
      label = 'Good';
    } else {
      color = const Color(0xFF4CAF50);
      label = 'Strong';
    }

    setState(() {
      _passwordStrength = s;
      _strengthColor = color;
      _strengthLabel = label;
    });
  }

  // ── Validators ──────────────────────────────────────────────────────────────

  String? _validateFullName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Full name is required';
    if (v.trim().length < 3) return 'Name must be at least 3 characters';
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(v.trim())) {
      return 'Name can only contain letters';
    }
    return null;
  }

  String? _validateCountry(String? v) {
    if (v == null || v.isEmpty) return 'Please select your country';
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final regex =
        RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(v.trim())) return 'Enter a valid email address';
    return null;
  }

  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Phone number is required';
    if (!RegExp(r'^\d{10}$').hasMatch(v.trim())) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Password must be at least 8 characters';
    if (!v.contains(RegExp(r'[A-Z]'))) {
      return 'Include at least one uppercase letter';
    }
    if (!v.contains(RegExp(r'[0-9]'))) return 'Include at least one number';
    return null;
  }

  String? _validateConfirmPassword(String? v) {
    if (v == null || v.isEmpty) return 'Please confirm your password';
    if (v != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  String? _validateOrgName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Organization name is required';
    if (v.trim().length < 2) return 'Enter a valid organization name';
    return null;
  }

  // ── Register logic ──────────────────────────────────────────────────────────

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();

    // Manually validate country dropdown
    if (_selectedCountry == null) {
      _showSnack('Please select your country', isError: true);
      return;
    }

    if (!_formKey.currentState!.validate()) {
      _showSnack('Please fix the errors above', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    // Save user locally
    LocalUserStore.saveUser({
      'fullName': _fullNameController.text.trim(),
      'country': _selectedCountry!,
      'email': _emailController.text.trim().toLowerCase(),
      'phone': _phoneController.text.trim(),
      'password': _passwordController.text,
      'orgName': _orgNameController.text.trim(),
      'orgType': _selectedOrgType ?? '',
    });

    setState(() => _isLoading = false);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DashboardPage(
          userName: _fullNameController.text.trim(),
          userEmail: _emailController.text.trim().toLowerCase(),
        ),
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7B5EA7), Color(0xFF6B4FBB), Color(0xFF5B3FA8)],
          ),
        ),
        child: Stack(
          children: [
            _circle(left: 80, top: 180, size: 70),
            _circle(right: 60, top: 140, size: 55),
            _circle(right: 60, bottom: 220, size: 40),
            _circle(left: 280, bottom: 300, size: 30),
            Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 420),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3D3A5C),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 40,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 36),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header
                            Center(
                              child: Column(children: [
                                _logo(),
                                const SizedBox(height: 12),
                                const Text('Kickload',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                const Text('Join us and start your journey',
                                    style: TextStyle(
                                        color: Color(0xFFB0AECB),
                                        fontSize: 14)),
                              ]),
                            ),
                            const SizedBox(height: 20),

                            // Progress bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: const LinearProgressIndicator(
                                value: 0.35,
                                backgroundColor: Color(0xFF5A566E),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                                minHeight: 4,
                              ),
                            ),
                            const SizedBox(height: 28),

                            // ── Personal Information ──────────────────────
                            _sectionHeader(
                              icon: Icons.person_outline_rounded,
                              title: 'Personal Information',
                              subtitle: 'Tell us about yourself',
                            ),
                            const SizedBox(height: 20),

                            _label('Full Name'),
                            const SizedBox(height: 8),
                            _field(
                              controller: _fullNameController,
                              hint: 'Enter your full name',
                              icon: Icons.person_outline,
                              validator: _validateFullName,
                              action: TextInputAction.next,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[a-zA-Z\s]')),
                              ],
                            ),
                            const SizedBox(height: 16),

                            _label('Country'),
                            const SizedBox(height: 8),
                            _dropdown(
                              value: _selectedCountry,
                              hint: 'Select your country',
                              items: _countries,
                              icon: Icons.language_outlined,
                              validator: _validateCountry,
                              onChanged: (v) =>
                                  setState(() => _selectedCountry = v),
                            ),
                            const SizedBox(height: 16),

                            _label('Email'),
                            const SizedBox(height: 8),
                            _field(
                              controller: _emailController,
                              hint: 'Enter your email',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: _validateEmail,
                              action: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),

                            _label('Phone'),
                            const SizedBox(height: 8),
                            _phoneField(),
                            const SizedBox(height: 28),

                            Divider(
                                color: Colors.white.withOpacity(0.1),
                                height: 1),
                            const SizedBox(height: 24),

                            // ── Security ──────────────────────────────────
                            _sectionHeader(
                              icon: Icons.shield_outlined,
                              title: 'Security',
                              subtitle: 'Create a strong password',
                            ),
                            const SizedBox(height: 20),

                            _label('Password'),
                            const SizedBox(height: 8),
                            _field(
                              controller: _passwordController,
                              hint: '••••••••',
                              icon: Icons.lock_outline,
                              obscure: _obscurePassword,
                              validator: _validatePassword,
                              action: TextInputAction.next,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: const Color(0xFF8884A8),
                                  size: 20,
                                ),
                                onPressed: () => setState(() =>
                                    _obscurePassword = !_obscurePassword),
                              ),
                            ),

                            // Strength bar
                            if (_passwordController.text.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: _passwordStrength,
                                        backgroundColor:
                                            const Color(0xFF5A566E),
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                _strengthColor),
                                        minHeight: 4,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    _strengthLabel,
                                    style: TextStyle(
                                        color: _strengthColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 16),

                            _label('Confirm Password'),
                            const SizedBox(height: 8),
                            _field(
                              controller: _confirmPasswordController,
                              hint: 'Confirm your password',
                              icon: Icons.lock_outline,
                              obscure: _obscureConfirm,
                              validator: _validateConfirmPassword,
                              action: TextInputAction.next,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: const Color(0xFF8884A8),
                                  size: 20,
                                ),
                                onPressed: () => setState(
                                    () => _obscureConfirm = !_obscureConfirm),
                              ),
                            ),
                            const SizedBox(height: 16),

                            _label('Organization Name'),
                            const SizedBox(height: 8),
                            _field(
                              controller: _orgNameController,
                              hint: 'Enter your organization name',
                              icon: Icons.business_outlined,
                              validator: _validateOrgName,
                              action: TextInputAction.done,
                              onSubmitted: (_) => _handleRegister(),
                            ),
                            const SizedBox(height: 16),

                            // Organization Type (optional)
                            const Row(children: [
                              Text('Organization Type ',
                                  style: TextStyle(
                                      color: Color(0xFFD0CEEA),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500)),
                              Text('(optional)',
                                  style: TextStyle(
                                      color: Color(0xFF8884A8), fontSize: 13)),
                            ]),
                            const SizedBox(height: 8),
                            _dropdown(
                              value: _selectedOrgType,
                              hint: 'Select organization type',
                              items: _orgTypes,
                              icon: Icons.business_center_outlined,
                              onChanged: (v) =>
                                  setState(() => _selectedOrgType = v),
                            ),
                            const SizedBox(height: 28),

                            Divider(
                                color: Colors.white.withOpacity(0.1),
                                height: 1),
                            const SizedBox(height: 20),

                            // ToS
                            Center(
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: const TextSpan(
                                  style: TextStyle(
                                      color: Color(0xFFB0AECB), fontSize: 13),
                                  children: [
                                    TextSpan(
                                        text:
                                            'By creating an account, you agree to our '),
                                    TextSpan(
                                        text: 'Terms of Service',
                                        style: TextStyle(
                                            color: Color(0xFF29C6D5),
                                            decoration:
                                                TextDecoration.underline)),
                                    TextSpan(text: '\nand '),
                                    TextSpan(
                                        text: 'Privacy Policy',
                                        style: TextStyle(
                                            color: Color(0xFF29C6D5),
                                            decoration:
                                                TextDecoration.underline)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Create Account button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed:
                                    _isLoading ? null : _handleRegister,
                                icon: const Icon(Icons.person_add_outlined,
                                    size: 20),
                                label: _isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5))
                                    : const Text('Create Account',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600)),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Sign in link
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 4,
                              runSpacing: 4,
                              children: [
                                const Text('Already have an account? ',
                                    style: TextStyle(
                                        color: Color(0xFFB0AECB),
                                        fontSize: 14)),
                                GestureDetector(
                                  onTap: () => Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const SignInPage()),
                                  ),
                                  child: const Text('Sign in',
                                      style: TextStyle(
                                          color: Color(0xFF29C6D5),
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Reusable helpers ────────────────────────────────────────────────────────

  Widget _logo() => Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: ClipOval(
          child: Image.asset('assets/logo.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                  Icons.bar_chart_rounded,
                  color: Color(0xFF00BCD4),
                  size: 28)),
        ),
      );

  Widget _sectionHeader(
      {required IconData icon,
      required String title,
      required String subtitle}) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: const Color(0xFFB0AECB), size: 22),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(subtitle,
            style: const TextStyle(
                color: Color(0xFF8884A8), fontSize: 13)),
      ]),
    ]);
  }

  Widget _label(String text) => Align(
        alignment: Alignment.centerLeft,
        child: Text(text,
            style: const TextStyle(
                color: Color(0xFFD0CEEA),
                fontSize: 14,
                fontWeight: FontWeight.w500)),
      );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
    TextInputAction action = TextInputAction.next,
    void Function(String)? onSubmitted,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      textInputAction: action,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      inputFormatters: inputFormatters,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF8884A8)),
        prefixIcon: Icon(icon, color: const Color(0xFF8884A8), size: 20),
        suffixIcon: suffix,
        errorStyle:
            const TextStyle(color: Color(0xFFFF6B6B), fontSize: 12),
      ),
    );
  }

  Widget _dropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required IconData icon,
    String? Function(String?)? validator,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF4A4770),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        dropdownColor: const Color(0xFF4A4770),
        icon: const Icon(Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF8884A8)),
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF8884A8), size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
        ),
        hint: Text(hint,
            style:
                const TextStyle(color: Color(0xFF8884A8), fontSize: 14)),
        items: items
            .map((c) => DropdownMenuItem(
                value: c,
                child:
                    Text(c, style: const TextStyle(color: Colors.white))))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _phoneField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF4A4770),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _phoneController.text.isNotEmpty &&
                  !RegExp(r'^\d{10}$').hasMatch(_phoneController.text.trim())
              ? const Color(0xFFFF6B6B)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(children: [
            const Text('🇮🇳', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            const Text('+91',
                style: TextStyle(color: Colors.white, fontSize: 14)),
            const SizedBox(width: 6),
            Container(
                width: 1, height: 20, color: const Color(0xFF8884A8)),
          ]),
        ),
        Expanded(
          child: TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: _validatePhone,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: const InputDecoration(
              hintText: 'Enter your phone number',
              hintStyle: TextStyle(color: Color(0xFF8884A8)),
              border: InputBorder.none,
              counterText: '',
              contentPadding:
                  EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              errorStyle:
                  TextStyle(color: Color(0xFFFF6B6B), fontSize: 12),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _circle(
      {double? left,
      double? right,
      double? top,
      double? bottom,
      required double size}) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.08)),
      ),
    );
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor:
          isError ? const Color(0xFFD32F2F) : const Color(0xFF29C6D5),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ));
  }
}
