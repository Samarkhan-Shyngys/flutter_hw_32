import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'forgot_password_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _authService = AuthService();

  // Контроллеры для Login
  final _loginEmailCtrl = TextEditingController();
  final _loginPasswordCtrl = TextEditingController();
  final _loginFormKey = GlobalKey<FormState>();

  // Контроллеры для Register
  final _regNameCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPasswordCtrl = TextEditingController();
  final _regFormKey = GlobalKey<FormState>();

  bool _loginLoading = false;
  bool _registerLoading = false;
  bool _googleLoading = false;
  bool _loginPasswordHidden = true;
  bool _regPasswordHidden = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailCtrl.dispose();
    _loginPasswordCtrl.dispose();
    _regNameCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPasswordCtrl.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _login() async {
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() => _loginLoading = true);
    try {
      await _authService.signIn(
        email: _loginEmailCtrl.text.trim(),
        password: _loginPasswordCtrl.text,
      );
    } on FirebaseAuthException catch (e) {
      _showError(AuthService.getErrorMessage(e.code));
    } finally {
      if (mounted) setState(() => _loginLoading = false);
    }
  }

  Future<void> _register() async {
    if (!_regFormKey.currentState!.validate()) return;
    setState(() => _registerLoading = true);
    try {
      await _authService.register(
        email: _regEmailCtrl.text.trim(),
        password: _regPasswordCtrl.text,
        displayName: _regNameCtrl.text.trim(),
      );
      _showSuccess('Аккаунт успешно создан!');
    } on FirebaseAuthException catch (e) {
      _showError(AuthService.getErrorMessage(e.code));
    } finally {
      if (mounted) setState(() => _registerLoading = false);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() => _googleLoading = true);
    try {
      final result = await _authService.signInWithGoogle();
      if (result == null) return; // пользователь отменил
    } on FirebaseAuthException catch (e) {
      _showError(AuthService.getErrorMessage(e.code));
    } catch (_) {
      _showError('Ошибка Google Sign-In');
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              const Icon(Icons.lock_outline, size: 72, color: Colors.deepPurple),
              const SizedBox(height: 16),
              Text(
                'Firebase Auth',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Войти'),
                  Tab(text: 'Регистрация'),
                ],
                labelColor: Colors.deepPurple,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.deepPurple,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 380,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildLoginForm(),
                    _buildRegisterForm(),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('или', style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),
              _googleLoading
                  ? const CircularProgressIndicator()
                  : OutlinedButton.icon(
                      onPressed: _googleSignIn,
                      icon: const Icon(Icons.g_mobiledata, size: 28),
                      label: const Text('Войти через Google'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        side: const BorderSide(color: Colors.grey),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _loginEmailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (v) =>
                v == null || v.isEmpty ? 'Введите email' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _loginPasswordCtrl,
            obscureText: _loginPasswordHidden,
            decoration: InputDecoration(
              labelText: 'Пароль',
              prefixIcon: const Icon(Icons.lock_outlined),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_loginPasswordHidden
                    ? Icons.visibility_off
                    : Icons.visibility),
                onPressed: () =>
                    setState(() => _loginPasswordHidden = !_loginPasswordHidden),
              ),
            ),
            validator: (v) =>
                v == null || v.isEmpty ? 'Введите пароль' : null,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ForgotPasswordScreen()),
              ),
              child: const Text('Забыли пароль?'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _loginLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: _loginLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Войти'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Form(
      key: _regFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _regNameCtrl,
            decoration: const InputDecoration(
              labelText: 'Имя',
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(),
            ),
            validator: (v) =>
                v == null || v.isEmpty ? 'Введите имя' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _regEmailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (v) =>
                v == null || v.isEmpty ? 'Введите email' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _regPasswordCtrl,
            obscureText: _regPasswordHidden,
            decoration: InputDecoration(
              labelText: 'Пароль',
              prefixIcon: const Icon(Icons.lock_outlined),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_regPasswordHidden
                    ? Icons.visibility_off
                    : Icons.visibility),
                onPressed: () =>
                    setState(() => _regPasswordHidden = !_regPasswordHidden),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Введите пароль';
              if (v.length < 6) return 'Минимум 6 символов';
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _registerLoading ? null : _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: _registerLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Создать аккаунт'),
            ),
          ),
        ],
      ),
    );
  }
}
