import 'package:flutter/material.dart';
import 'register_page.dart';
import 'dashboard_page.dart';
import 'local_user_store.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Validators ──────────────────────────────────────────────────────────────

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final regex =
        RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(v.trim())) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  // ── Sign In logic ───────────────────────────────────────────────────────────

  Future<void> _handleSignIn() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    final user = LocalUserStore.getUser();

    if (user == null) {
      _done();
      _showSnack('No account found. Please register first.', isError: true);
      return;
    }

    final emailMatch =
        _emailController.text.trim().toLowerCase() == user['email'];
    final passwordMatch = _passwordController.text == user['password'];

    if (!emailMatch || !passwordMatch) {
      _done();
      _showSnack('Incorrect email or password.', isError: true);
      return;
    }

    _done();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DashboardPage(
          userName: user['fullName'] ?? 'User',
          userEmail: user['email'] ?? '',
        ),
      ),
    );
  }

  void _done() => setState(() => _isLoading = false);

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
                          horizontal: 36, vertical: 40),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _logo(),
                            const SizedBox(height: 16),
                            const Text('KickLoad',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.4)),
                            const SizedBox(height: 6),
                            const Text('Sign in to your account',
                                style: TextStyle(
                                    color: Color(0xFFB0AECB), fontSize: 14)),
                            const SizedBox(height: 32),

                            // Email
                            _label('Email Address'),
                            const SizedBox(height: 8),
                            _field(
                              controller: _emailController,
                              hint: 'Enter your email',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: _validateEmail,
                              action: TextInputAction.next,
                            ),
                            const SizedBox(height: 20),

                            // Password
                            _label('Password'),
                            const SizedBox(height: 8),
                            _field(
                              controller: _passwordController,
                              hint: '••••••••',
                              icon: Icons.lock_outline,
                              obscure: _obscurePassword,
                              validator: _validatePassword,
                              action: TextInputAction.done,
                              onSubmitted: (_) => _handleSignIn(),
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
                            const SizedBox(height: 12),

                            // Forgot password
                            TextButton(
                              onPressed: () =>
                                  _showSnack('Feature coming soon!'),
                              style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap),
                              child: const Text('Forgot password?',
                                  style: TextStyle(
                                      color: Color(0xFF29C6D5), fontSize: 14)),
                            ),
                            const SizedBox(height: 14),

                            // Remember me
                            Row(
                              children: [
                                SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: Checkbox(
                                    value: _rememberMe,
                                    onChanged: (v) => setState(
                                        () => _rememberMe = v ?? false),
                                    activeColor: const Color(0xFF29C6D5),
                                    checkColor: Colors.white,
                                    side: const BorderSide(
                                        color: Color(0xFF8884A8), width: 1.5),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(3)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text('Remember me',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14)),
                              ],
                            ),
                            const SizedBox(height: 22),

                            // Sign In button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleSignIn,
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5))
                                    : const Text('Sign in',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600)),
                              ),
                            ),
                            const SizedBox(height: 22),

                            // Create account
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 4,
                              runSpacing: 4,
                              children: [
                                const Text("Don't have an account? ",
                                    style: TextStyle(
                                        color: Color(0xFFB0AECB),
                                        fontSize: 14)),
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const RegisterPage()),
                                  ),
                                  child: const Text('Create account',
                                      style: TextStyle(
                                          color: Color(0xFF29C6D5),
                                          fontSize: 16,
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

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Widget _logo() => Container(
        width: 60,
        height: 60,
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
                  size: 32)),
        ),
      );

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
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      textInputAction: action,
      onFieldSubmitted: onSubmitted,
      validator: validator,
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
          color: Colors.white.withOpacity(0.08),
        ),
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
