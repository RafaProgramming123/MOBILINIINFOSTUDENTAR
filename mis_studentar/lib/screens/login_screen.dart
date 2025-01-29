import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'calendar_screen.dart';
import 'package:mis_studentar/service/auth_service.dart'; // Import the AuthService
import 'package:mis_studentar/providers/DataProvider.dart';
import 'package:provider/provider.dart';
import 'package:mis_studentar/providers/password_visibility_provider.dart'; // Import the PasswordVisibilityProvider

class LoginScreen extends StatelessWidget {
  final TextEditingController indexController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService(); // Create an instance of AuthService

  @override
  Widget build(BuildContext context) {
    final passwordVisibilityProvider = Provider.of<PasswordVisibilityProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Login',
              style: TextStyle(
                color: Colors.cyanAccent,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            _buildTextField(
              controller: indexController,
              hintText: 'Type your index',
              icon: Icons.person,
            ),
            SizedBox(height: 20),
            _buildPasswordTextField(
              controller: passwordController,
              hintText: 'Type your password',
              icon: Icons.lock,
              obscureText: passwordVisibilityProvider.isObscure,
              onVisibilityToggle: passwordVisibilityProvider.toggleVisibility,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                String index = indexController.text.trim();
                String password = passwordController.text.trim();

                // Call the login method from AuthService
                String? result = await _authService.login(index, password, context);

                if (result == 'Success') {
                  Provider.of<DataStore>(context, listen: false).fetchData();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => CalendarScreen()),
                  );
                } else {
                  // Show an error message if login fails
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result ?? 'Login failed'),
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
                'LOGIN',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: Text(
                "Don't have an account? Sign Up",
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

  Widget _buildPasswordTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required bool obscureText,
    required VoidCallback onVisibilityToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: onVisibilityToggle,
        ),
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