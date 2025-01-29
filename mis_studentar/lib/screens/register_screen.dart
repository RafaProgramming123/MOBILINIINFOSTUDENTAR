import 'package:flutter/material.dart';
import 'package:mis_studentar/service/auth_service.dart'; // Import the AuthService

class RegisterScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController indexController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService(); // Create an instance of AuthService

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Register',
              style: TextStyle(
                color: Colors.cyanAccent,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            _buildTextField(
              controller: emailController,
              hintText: 'Type your email',
              icon: Icons.email,
            ),
            SizedBox(height: 20),
            _buildTextField(
              controller: indexController,
              hintText: 'Type your index',
              icon: Icons.person,
            ),
            SizedBox(height: 20),
            _buildTextField(
              controller: passwordController,
              hintText: 'Type your password',
              icon: Icons.lock,
              obscureText: true,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                String email = emailController.text.trim();
                String index = indexController.text.trim();
                String password = passwordController.text.trim();

                // Call the register method from AuthService
                String? result = await _authService.register(email, password, index, context);

                if (result == 'Success') {
                  // Navigate back to the LoginScreen on successful registration
                  Navigator.pop(context);
                } else {
                  // Show an error message if registration fails
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result ?? 'Registration failed'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(
                'REGISTER',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Text(
                "Already have an account? Log in",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}