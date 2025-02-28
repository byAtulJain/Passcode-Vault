import 'package:flutter/material.dart';
import 'services/storage_service.dart';
import 'passcode.dart';

class EnterPinPage extends StatefulWidget {
  const EnterPinPage({super.key});

  @override
  _EnterPinPageState createState() => _EnterPinPageState();
}

class _EnterPinPageState extends State<EnterPinPage> {
  String _enteredPin = "";

  Future<void> _verifyPin() async {
    if (_enteredPin.length == 5) {
      bool isCorrect = await StorageService.verifyPin(_enteredPin);
      if (isCorrect) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const PasscodePage()));
      } else {
        setState(() => _enteredPin = "");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              backgroundColor: Colors.green,
              content: Text('Incorrect PIN! Try again.')),
        );
      }
    }
  }

  void _onKeyPressed(String value) {
    if (_enteredPin.length < 5) {
      setState(() {
        _enteredPin += value;
      });
      if (_enteredPin.length == 5) _verifyPin();
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
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildHeading(),
          const SizedBox(height: 20),
          const Text(
            "Enter your 5-digit PIN",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          _buildPinDots(),
          const SizedBox(height: 30),
          _buildKeypad(),
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
        'Enter PIN',
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
}
