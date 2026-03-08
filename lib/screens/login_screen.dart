import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/auth_service.dart';
import 'owner_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  final _loginUserController = TextEditingController();
  final _loginPassController = TextEditingController();
  final _regUserController = TextEditingController();
  final _regPassController = TextEditingController();
  final _ownerPassController = TextEditingController();

  bool _showLogin = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: AppConstants.primaryColor.withValues(alpha: 0.4),
        ),
        child: Stack(
          children: [
            _buildFloatingFlowers(),
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Container(
                  constraints: BoxConstraints(maxWidth: 420),
                  child: _showLogin ? _buildLoginForm() : _buildRegisterForm(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingFlowers() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: List.generate(5, (index) {
            final flowers = ['🌸', '🌺', '🌷', '🌹', '💐'];
            final positions = [
              [30.0, 80.0],
              [200.0, 150.0],
              [100.0, 400.0],
              [280.0, 300.0],
              [50.0, 550.0],
            ];
            return Positioned(
              left: positions[index][0],
              top: positions[index][1],
              child: Text(
                flowers[index],
                style: TextStyle(
                  fontSize: (24 + index * 4).toDouble(),
                  color: Colors.white24,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Card(
      elevation: 20,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: Colors.white.withValues(alpha: 0.95),
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Form(
          key: _loginFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🌸 Owner Login',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
              ),
              SizedBox(height: 30),
              TextFormField(
                controller: _loginUserController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (val) =>
                    val!.isEmpty ? 'Username is required' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _loginPassController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (val) =>
                    val!.isEmpty ? 'Password is required' : null,
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text('Login'),
                ),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => _showLogin = false),
                child: Text.rich(
                  TextSpan(
                    text: 'No account? ',
                    children: [
                      TextSpan(
                        text: 'Register',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Card(
      elevation: 20,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: Colors.white.withValues(alpha: 0.95),
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Form(
          key: _registerFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🌸 Register New Owner',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
              ),
              SizedBox(height: 30),
              TextFormField(
                controller: _regUserController,
                decoration: InputDecoration(
                  labelText: 'New Username',
                  prefixIcon: Icon(Icons.person_add),
                ),
                validator: (val) =>
                    val!.isEmpty ? 'Username is required' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _regPassController,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                validator: (val) =>
                    val!.isEmpty ? 'Password is required' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _ownerPassController,
                decoration: InputDecoration(
                  labelText: 'Owner Password (Required)',
                  prefixIcon: Icon(Icons.vpn_key),
                ),
                obscureText: true,
                validator: (val) =>
                    val!.isEmpty ? 'Owner password is required' : null,
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text('Create Account'),
                ),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => _showLogin = true),
                child: Text.rich(
                  TextSpan(
                    text: 'Already have an account? ',
                    children: [
                      TextSpan(
                        text: 'Login',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await _authService.login(
      _loginUserController.text.trim(),
      _loginPassController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login successful!')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OwnerDashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Invalid username or password!')));
    }
  }

  Future<void> _handleRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await _authService.register(
      _regUserController.text.trim(),
      _regPassController.text.trim(),
      _ownerPassController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Account created successfully!')));
      setState(() => _showLogin = true);
      _regUserController.clear();
      _regPassController.clear();
      _ownerPassController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed. Check owner password.')),
      );
    }
  }

  @override
  void dispose() {
    _loginUserController.dispose();
    _loginPassController.dispose();
    _regUserController.dispose();
    _regPassController.dispose();
    _ownerPassController.dispose();
    super.dispose();
  }
}
