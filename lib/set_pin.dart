import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'services/storage_service.dart';

class SetPinPage extends StatefulWidget {
  const SetPinPage({super.key});

  @override
  _SetPinPageState createState() => _SetPinPageState();
}

class _SetPinPageState extends State<SetPinPage> {
  String _enteredPin = "";
  bool _isLoading = true; // Manage loading state

  @override
  void initState() {
    super.initState();
    _checkPermissionAndProceed();
  }

  Future<void> _checkPermissionAndProceed() async {
    setState(() => _isLoading = true);

    try {
      final status = await Permission.manageExternalStorage.status;

      if (!status.isGranted) {
        final result = await Permission.manageExternalStorage.request();
        if (!result.isGranted) {
          _showPermissionDialog();
          return;
        }
      }

      // 🔹 Reload PIN after permission is granted
      _reloadPin();
    } catch (e) {
      print("Error checking permission: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _reloadPin() async {
    final storedPin = await StorageService.loadPin();
    if (storedPin != null && storedPin.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/enterPin');
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Storage Permission Required"),
        content: const Text(
          "This app needs storage permission to securely save your PIN. Please grant the permission to proceed.",
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
              Future.delayed(
                  const Duration(seconds: 1), _checkPermissionAndProceed);
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  Future<void> _savePin() async {
    if (_enteredPin.length != 5) return;

    await StorageService.savePin(_enteredPin);
    Navigator.pushReplacementNamed(context, '/enterPin');
  }

  void _onKeyPressed(String value) {
    if (_enteredPin.length < 5) {
      setState(() {
        _enteredPin += value;
      });
    }
  }

  void _onDelete() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF0F0F0),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildHeading(),
          const SizedBox(height: 20),
          const Text(
            "Create a 5-digit PIN",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          _buildPinDots(),
          const SizedBox(height: 30),
          _buildKeypad(),
          const SizedBox(height: 20),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildHeading() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
      decoration: BoxDecoration(
        color: const Color(0xFF38E70E),
        border: Border.all(color: Colors.black, width: 3),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
      ),
      child: const Text(
        'Set PIN',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        5,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index < _enteredPin.length ? Colors.black : Colors.grey[400],
            border: Border.all(color: Colors.black, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: List.generate(4, (rowIndex) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (colIndex) {
            int number = rowIndex * 3 + colIndex + 1;
            if (rowIndex == 3) {
              if (colIndex == 0) return const SizedBox(width: 80);
              if (colIndex == 1) number = 0;
              if (colIndex == 2) return _buildKeyButton("⌫", _onDelete);
            }
            return _buildKeyButton("$number", () => _onKeyPressed("$number"));
          }),
        );
      }),
    );
  }

  Widget _buildKeyButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFFFFE566),
          border: Border.all(color: Colors.black, width: 3),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(4, 4))
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _savePin,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
        decoration: BoxDecoration(
          color: _enteredPin.length == 5 ? Colors.green : Colors.grey,
          border: Border.all(color: Colors.black, width: 3),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(4, 4))
          ],
        ),
        child: const Text(
          "Save PIN",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
    );
  }
}
