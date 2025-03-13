import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AgreementPage extends StatelessWidget {
  const AgreementPage({super.key});

  void _handleAccept(BuildContext context) async {
    final status = await Permission.manageExternalStorage.request();

    if (status.isGranted) {
      Navigator.pushReplacementNamed(context, '/setPin');
    } else {
      _showPermissionDeniedDialog(context);
    }
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 3),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Permission Denied",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                "Storage permission is necessary to store and secure your credentials. "
                "You can enable it from settings to proceed.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, height: 1.4),
              ),
              const SizedBox(height: 20),
              _buildDialogButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          border: Border.all(color: Colors.black, width: 2),
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
          "OK",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHeader(),
              const SizedBox(height: 30),
              _buildContentBox(
                "Why We Need Storage Access:",
                "We require access to your device's storage to securely store your credentials. "
                    "If you uninstall the app, your data will remain stored securely on your device. "
                    "When you reinstall the app, your credentials will be restored automatically.",
              ),
              const SizedBox(height: 20),
              _buildContentBox(
                "Privacy Policy:",
                "We respect your privacy. We do not collect, share, or access your data in any way. "
                    "All data is stored securely on your device and cannot be accessed by third parties.",
              ),
              const SizedBox(height: 40),
              _buildAcceptButton(context), // ✅ Only Accept Button
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.yellow[300],
        border: Border.all(color: Colors.black, width: 3),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: const Text(
        "Terms & Conditions",
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w900,
          color: Colors.black,
          letterSpacing: 0.4,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildContentBox(String title, String description) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 3),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleAccept(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.green[400],
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
        child: Center(
          child: const Text(
            "Accept",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
