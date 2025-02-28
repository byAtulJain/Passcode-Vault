import 'package:flutter/material.dart';
import 'models/credential.dart';
import 'services/storage_service.dart';

class EditCredentialSheet extends StatefulWidget {
  final Credential credential;
  final Function onCredentialUpdated;

  const EditCredentialSheet({
    super.key,
    required this.credential,
    required this.onCredentialUpdated,
  });

  @override
  State<EditCredentialSheet> createState() => _EditCredentialSheetState();
}

class _EditCredentialSheetState extends State<EditCredentialSheet> {
  late TextEditingController _headingController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _showPassword = false;
  bool _showErrorMessage = false;

  @override
  void initState() {
    super.initState();
    _headingController = TextEditingController(text: widget.credential.heading);
    _emailController = TextEditingController(text: widget.credential.email);
    _passwordController =
        TextEditingController(text: widget.credential.password);
  }

  Future<void> _updateCredential() async {
    if (_headingController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() {
        _showErrorMessage = true;
      });
      return;
    }

    // Load existing credentials
    List<Credential> credentials = await StorageService.loadCredentials();

    // Find and update the credential
    final updatedCredential = Credential(
      heading: _headingController.text,
      email: _emailController.text,
      password: _passwordController.text,
      color: widget.credential.color,
    );

    final index = credentials.indexWhere((c) =>
        c.heading == widget.credential.heading &&
        c.email == widget.credential.email &&
        c.password == widget.credential.password);
    if (index != -1) {
      credentials[index] = updatedCredential;
      await StorageService.saveCredentials(credentials);
      widget.onCredentialUpdated();
      if (mounted) Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Credential updated successfully',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.green[200],
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.black, width: 2),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF0F0F0),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: Colors.black, width: 3),
          left: BorderSide(color: Colors.black, width: 3),
          right: BorderSide(color: Colors.black, width: 3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Edit Credential',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
                'Title Here*', Icons.title, _headingController, false),
            const SizedBox(height: 16),
            _buildTextField(
                'Email/Username*', Icons.email, _emailController, false),
            const SizedBox(height: 16),
            _buildTextField(
                'Password/Pin*', Icons.lock, _passwordController, true),
            const SizedBox(height: 24),
            if (_showErrorMessage)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    border: Border.all(color: Colors.red, width: 2),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(2, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: const Text(
                    'Please fill in all fields',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFE566),
                border: Border.all(color: Colors.black, width: 3),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(9),
                  onTap: _updateCredential,
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Update Credential',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, IconData icon,
      TextEditingController controller, bool isPassword) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 3),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF91F48F),
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: isPassword && !_showPassword,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                suffixIcon: isPassword
                    ? IconButton(
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () =>
                            setState(() => _showPassword = !_showPassword),
                      )
                    : null,
              ),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
