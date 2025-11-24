import 'package:flutter/material.dart';
import 'package:frontend/widgets/widget/bottom.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/widgets/widget/_buildInputField.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SinginPage extends StatefulWidget {
  const SinginPage({super.key});

  @override
  State<SinginPage> createState() => _SinginPageState();
}

class _SinginPageState extends State<SinginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false; // Loading indicator

  @override
  void initState() {
    super.initState();
    // Run token verification after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      verifyToken();
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }


  void verifyToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) return;

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('http://10.0.2.2:3000/token/verify');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'token': token}),
          )
          .timeout(const Duration(seconds: 5));

      if (!mounted) return;

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['message'] == 'success') {
        if (data['user']['username'] != null) {
          prefs.setString('username', data['user']['username']);
        }
        if (data['user']['email'] != null) {
          prefs.setString('email', data['user']['email']);
        }
        // Check role - use both 'id-role' and 'id_role' for compatibility
        final roleId = data['user']['id-role'] ?? data['user']['id_role'];
        if(roleId == 1){
          Navigator.pushReplacementNamed(context, '/Admin');
        } else if(roleId == 2){
          Navigator.pushReplacementNamed(context, '/Teacher');
        } else if(roleId == 3){
          Navigator.pushReplacementNamed(context, '/Student');
        }

      
      }
    } catch (e) {
    
      prefs.remove('token');
      prefs.remove('username');
      prefs.remove('email');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Check your email and password',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http
          .post(
            Uri.parse('http://10.0.2.2:3000/signin'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 5));

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200 && data['message'] == 'success') {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', data['token']);
        if (data['user']['username'] != null) {
          prefs.setString('username', data['user']['username']);
        }
        if (data['user']['email'] != null) {
          prefs.setString('email', data['user']['email']);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Login successful'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        // Check role - use both 'id-role' and 'id_role' for compatibility
        final roleId = data['user']['id-role'] ?? data['user']['id_role'];
        if(roleId == 1){
          Navigator.pushReplacementNamed(context, '/Admin');
        } else if(roleId == 2){
          Navigator.pushReplacementNamed(context, '/Teacher');
        } else if(roleId == 3){
          Navigator.pushReplacementNamed(context, '/Student');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['message'] ?? 'Invalid email or password',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Problem with server',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      // Illustration Section
                      Container(
                        height: size.height * 0.35,
                        alignment: Alignment.center,
                        child: Image.asset(
                          'assets/undraw_access_account_re_8spm (1) 1.png',
                          fit: BoxFit.contain,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.account_circle,
                              size: 200,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.3),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Hello, Login to continue using our app',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: size.height * 0.05),
                      BuildInputField(
                        hintText: 'Enter your email',
                        controller: emailController,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email or phone number';
                          }
                          final emailRegex =
                              RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          final phoneRegex = RegExp(r'^[0-9]{8,15}$');
                          final cleanValue =
                              value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
                          if (!emailRegex.hasMatch(value) &&
                              !phoneRegex.hasMatch(cleanValue)) {
                            return 'Please enter a valid email or phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      BuildInputField(
                        hintText: 'Password',
                        controller: passwordController,
                        icon: Icons.lock_outline,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onBackground
                                    .withOpacity(0.8),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Bottom(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await login(
                              emailController.text,
                              passwordController.text,
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onBackground
                                  .withOpacity(0.8),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/signup');
                            },
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.05),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black38,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
