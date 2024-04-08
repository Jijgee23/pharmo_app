import 'package:flutter/material.dart';

class VerifyEmailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Email'),
      ),
      body: VerifyEmailForm(),
    );
  }
}

class VerifyEmailForm extends StatefulWidget {
  @override
  _VerifyEmailFormState createState() => _VerifyEmailFormState();
}

class _VerifyEmailFormState extends State<VerifyEmailForm> {
  final TextEditingController _emailController = TextEditingController();
  bool _isVerifying = false;

  void _verifyEmail() {
    // Send verification email logic goes here
    // Set _isVerifying to true while waiting for response

    // For demo purposes, simulate a delay
    setState(() {
      _isVerifying = true;
    });
    Future.delayed(Duration(seconds: 2), () {
      // Once verification is done, navigate to next screen or show a message
      setState(() {
        _isVerifying = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Verification email sent to ${_emailController.text}'),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isVerifying ? null : _verifyEmail,
            child: _isVerifying
                ? CircularProgressIndicator()
                : Text('Send Verification Email'),
          ),
        ],
      ),
    );
  }
}
