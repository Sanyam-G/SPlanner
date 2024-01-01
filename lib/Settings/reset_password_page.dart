import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _mailSent = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                ),
              if (_isLoading)
                const CircularProgressIndicator()
              else if (_mailSent)
                Column(
                  children: [
                    const Text(
                      'Password reset email sent.',
                      style: TextStyle(
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Please check your email (including spam folder) and follow the instructions in the email to reset your password.',
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _mailSent = false;
                        });
                      },
                      child: const Text('Resend Email'),
                    ),
                  ],
                )
              else
                ElevatedButton(
                  onPressed: _resetPassword,
                  child: const Text('Reset Password'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      try {
        final email = _emailController.text.trim();
        final user = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
        if (user.isEmpty) {
          setState(() {
            _errorMessage = 'Account does not exist';
          });
          return;
        }
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(email).get();
        setState(() {
          _mailSent = true;
        });
      } on FirebaseAuthException catch (_) {
        setState(() {
          _errorMessage = 'Something went wrong';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
