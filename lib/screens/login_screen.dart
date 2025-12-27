import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'register_screen.dart';
import '../services/seeding_service.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Ẩn bàn phím để trải nghiệm tốt hơn
      FocusScope.of(context).unfocus();
      
      await Provider.of<AuthProvider>(context, listen: false).login(
        _emailController.text.trim(),
        
      );
      // AuthWrapper ở main.dart sẽ tự động chuyển trang khi login thành công
    } catch (e) {
      if (!mounted) return;
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Đăng nhập thất bại: ${e.toString().split(']').last.trim()}'),
      //     backgroundColor: Colors.red,
      //     behavior: SnackBarBehavior.floating,
      //   ),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthProvider>(context).isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 1. LOGO SECTION
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9C4), // Màu vàng nhạt nền icon
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shopping_bag, size: 40, color: Color(0xFFFFC107)), // Icon màu vàng đậm
                  ),
                  const SizedBox(height: 24),
                  
                  // 2. WELCOME TEXT
                  const Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign in to continue shopping',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  SizedBox(
  width: double.infinity,
  child: OutlinedButton.icon(
    icon: const Icon(Icons.cloud_upload, color: Colors.red),
    label: const Text(
      "SEED DATA (Chỉ bấm 1 lần)",
      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
    ),
    style: OutlinedButton.styleFrom(
      side: const BorderSide(color: Colors.red),
    ),
    onPressed: () async {
      // Import file services/seeding_service.dart ở đầu file
      // import '../../services/seeding_service.dart';
      
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đang tạo dữ liệu... Vui lòng đợi!")),
        );
        
        await SeedingService().seedData();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Đã tạo xong 5 Customers, 15 Products, 8 Orders!"),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red),
        );
      }
    },
  ),
),
                  // 3. INPUT FIELDS
                  // Email Field
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Email', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700])),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                      prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA), // Màu nền xám cực nhạt
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none, // Bỏ viền mặc định
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                    ),
                    validator: (value) =>
                        (value == null || !value.contains('@')) ? 'Email không hợp lệ' : null,
                  ),
                  
                  const SizedBox(height: 20),

                  // Password Field
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Password', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700])),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                      prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                    ),
                    validator: (value) =>
                        (value == null || value.length < 6) ? 'Mật khẩu phải trên 6 ký tự' : null,
                  ),

                  // Forgot Password Link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Tính năng này chưa yêu cầu trong đề, để trống hoặc hiện thông báo
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tính năng Reset Password chưa yêu cầu")));
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  // 4. LOGIN BUTTON
                  isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue, // Màu xanh chủ đạo
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'LOGIN',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                  
                  const SizedBox(height: 24),

                  // 5. SIGN UP LINK
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterScreen()),
                          );
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}