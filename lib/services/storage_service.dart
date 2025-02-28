import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../models/credential.dart';

class StorageService {
  static const String fileName = 'value.enc';
  static const String pinFileName = 'pin.enc';

  static Future<void> savePin(String pin) async {
    try {
      final path = await _storagePath;
      final file = File('$path/$pinFileName');

      final encryptedPin = encryptData(pin);
      await file.writeAsString(encryptedPin);
      print('PIN saved securely.');
    } catch (e) {
      print('Error saving PIN: $e');
    }
  }

  static Future<String?> loadPin() async {
    try {
      final path = await _storagePath;
      final file = File('$path/$pinFileName');

      if (await file.exists()) {
        final encryptedPin = await file.readAsString();
        return decryptData(encryptedPin);
      }
    } catch (e) {
      print('Error loading PIN: $e');
    }
    return null;
  }

  static Future<bool> verifyPin(String enteredPin) async {
    final storedPin = await loadPin();
    return storedPin == enteredPin;
  }

  // 32-byte (256-bit) key and 16-byte IV
  static final _key = encrypt.Key.fromUtf8('12345678901234567890123456789012');
  static final _iv = encrypt.IV.fromUtf8('1234567890123456');

  static final _encrypter = encrypt.Encrypter(
    encrypt.AES(
      _key,
      mode: encrypt.AESMode.cbc,
    ),
  );

  static String encryptData(String data) {
    try {
      // Wrap the data in a JSON object with a version number
      final wrappedData = jsonEncode({
        'version': 1,
        'data': data,
      });

      final encrypted = _encrypter.encrypt(wrappedData, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      print('Encryption error: $e');
      rethrow;
    }
  }

  static String decryptData(String encryptedData) {
    try {
      final encrypted = encrypt.Encrypted.fromBase64(encryptedData);
      final decrypted = _encrypter.decrypt(encrypted, iv: _iv);

      // Unwrap the data from the JSON object
      final wrapped = jsonDecode(decrypted);
      return wrapped['data'] as String;
    } catch (e) {
      print('Decryption error: $e');
      rethrow;
    }
  }

  static Future<String> get _storagePath async {
    if (Platform.isAndroid) {
      Directory? directory = await getExternalStorageDirectory();
      String newPath = "";
      List<String> paths = directory!.path.split("/");
      for (int x = 1; x < paths.length; x++) {
        String folder = paths[x];
        if (folder != "Android") {
          newPath += "/" + folder;
        } else {
          break;
        }
      }
      // newPath = newPath + "/PasscodeVault";
      newPath = newPath +
          "/Android/com.passcode.manager/data/DO NOT DELETE THIS FOLDER";

      directory = Directory(newPath);

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      return directory.path;
    } else {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
  }

  static Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.manageExternalStorage.status;
      if (status.isGranted) return true;

      final result = await Permission.manageExternalStorage.request();
      return result.isGranted;
    }
    return true;
  }

  static Future<void> saveCredentials(List<Credential> credentials) async {
    try {
      final path = await _storagePath;
      final file = File('$path/$fileName');

      // Convert credentials to JSON string
      final data = jsonEncode(credentials.map((e) => e.toJson()).toList());

      // Encrypt the data
      final encryptedData = encryptData(data);

      // Save encrypted data
      await file.writeAsString(encryptedData);
      print('Saved encrypted data to: ${file.path}');
    } catch (e) {
      print('Error saving credentials: $e');
      rethrow;
    }
  }

  static Future<List<Credential>> loadCredentials() async {
    try {
      final path = await _storagePath;
      final file = File('$path/$fileName');

      if (await file.exists()) {
        // Read encrypted data
        final encryptedData = await file.readAsString();

        // Decrypt the data
        final decryptedData = decryptData(encryptedData);

        // Parse JSON and convert to credentials
        final List<dynamic> jsonData = jsonDecode(decryptedData);
        final credentials =
            jsonData.map((e) => Credential.fromJson(e)).toList();

        print('Successfully loaded ${credentials.length} credentials');
        return credentials;
      }
    } catch (e) {
      print('Error loading credentials: $e');
    }
    return [];
  }

  static Future<bool> verifyFileIntegrity() async {
    try {
      final path = await _storagePath;
      final file = File('$path/$fileName');

      if (await file.exists()) {
        // Read encrypted data
        final encryptedData = await file.readAsString();

        // Try to decrypt and parse
        final decryptedData = decryptData(encryptedData);
        jsonDecode(decryptedData);

        return true;
      }
      return true; // File doesn't exist yet
    } catch (e) {
      print('File integrity check failed: $e');
      return false;
    }
  }

  static Future<void> deleteCredential(
      String heading, String email, String password) async {
    try {
      // Load current credentials
      final currentCredentials = await loadCredentials();

      // Remove the credential matching all fields
      final updatedCredentials = currentCredentials
          .where((c) => !(c.heading == heading &&
              c.email == email &&
              c.password == password))
          .toList();

      // Save the updated list back to file
      await saveCredentials(updatedCredentials);

      print('Successfully deleted credential: $heading');
    } catch (e) {
      print('Error deleting credential: $e');
      rethrow;
    }
  }
}
