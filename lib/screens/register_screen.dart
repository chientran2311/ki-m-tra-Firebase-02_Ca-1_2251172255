import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/customer_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipCodeController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _agreedToTerms = false; // Checkbox state

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  void _signup() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đồng ý với điều khoản dịch vụ')),
      );
      return;
    }

    try {
      // Ẩn bàn phím
      FocusScope.of(context).unfocus();

      CustomerModel newCustomer = CustomerModel(
        customerId: '', // Sẽ được update trong provider
        email: _emailController.text.trim(),
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        postalCode: _zipCodeController.text.trim(),
        createdAt: DateTime.now(),
        isActive: true,
      );

      await Provider.of<AuthProvider>(context, listen: false).register(
      
        newCustomer
      );

      if (!mounted) return;
      // Sau khi đăng ký thành công, Firebase Auth tự động đăng nhập.
      // AuthWrapper ở main.dart sẽ bắt sự kiện này và chuyển vào Home.
      // Ta chỉ cần pop màn hình Register này ra (nếu nó đang đè lên Login)
      Navigator.of(context).pop(); 
      
    } catch (e) {
      if (!mounted) return;
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Lỗi đăng ký: ${e.toString().split(']').last}')),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthProvider>(context).isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Create Account", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "Join to access student exams and materials.",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 30),

                // FULL NAME
                _buildLabel("Full Name"),
                _buildInput(_fullNameController, "Jane Doe", icon: Icons.person_outline),
                
                // EMAIL
                const SizedBox(height: 16),
                _buildLabel("Email Address"),
                _buildInput(_emailController, "student@example.com", icon: Icons.email_outlined, inputType: TextInputType.emailAddress),

                // PASSWORD
                const SizedBox(height: 16),
                _buildLabel("Password"),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: _inputDecoration("••••••••").copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),
                  validator: (val) => (val != null && val.length < 6) ? "Mật khẩu quá ngắn" : null,
                ),

                // PHONE NUMBER
                const SizedBox(height: 16),
                _buildLabel("Phone Number"),
                // Giả lập Input có cờ (đơn giản hóa bằng prefix icon)
                _buildInput(_phoneController, "234 567 8900", icon: Icons.flag_outlined, inputType: TextInputType.phone),

                const SizedBox(height: 24),
                const Text("SHIPPING DETAILS", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                const SizedBox(height: 16),

                // ADDRESS
                _buildLabel("Address"),
                _buildInput(_addressController, "123 Campus Drive, Apt 4B"),

                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("City"),
                          _buildInput(_cityController, "New York"),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Zip Code"),
                          _buildInput(_zipCodeController, "10001", inputType: TextInputType.number),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // CHECKBOX TERMS
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _agreedToTerms,
                        activeColor: Colors.blue,
                        onChanged: (val) => setState(() => _agreedToTerms = val!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                          children: [
                            const TextSpan(text: "I agree to the "),
                            TextSpan(text: "Terms of Service", style: TextStyle(color: Colors.blue[600], fontWeight: FontWeight.bold)),
                            const TextSpan(text: " and "),
                            TextSpan(text: "Privacy Policy", style: TextStyle(color: Colors.blue[600], fontWeight: FontWeight.bold)),
                            const TextSpan(text: "."),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // REGISTER BUTTON
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _signup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("REGISTER", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                
                const SizedBox(height: 20),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? ", style: TextStyle(color: Colors.grey)),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(), // Quay lại Login
                        child: const Text("Log In", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 14)),
    );
  }

  Widget _buildInput(TextEditingController controller, String hint, {IconData? icon, TextInputType inputType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      decoration: _inputDecoration(hint, icon: icon),
      validator: (val) => (val == null || val.isEmpty) ? "Vui lòng nhập thông tin này" : null,
    );
  }

  InputDecoration _inputDecoration(String hint, {IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      prefixIcon: icon != null ? Icon(icon, color: Colors.grey[500], size: 20) : null,
      filled: true,
      fillColor: const Color(0xFFF8F9FA), // Màu nền xám nhạt như Login
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blue)),
    );
  }
}