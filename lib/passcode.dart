import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:passcode/settings_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'add_credential.dart';
import 'credential_card.dart';
import 'models/credential.dart';
import 'services/storage_service.dart';

class PasscodePage extends StatefulWidget {
  const PasscodePage({super.key});

  @override
  State<PasscodePage> createState() => _PasscodePageState();
}

class _PasscodePageState extends State<PasscodePage> {
  List<Credential> credentials = [];
  List<Credential> filteredCredentials = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkPermissionAndLoad();
    searchController.addListener(_filterCredentials);
    checkForUpdate();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> checkForUpdate() async {
    print('checking for Update');
    InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        if (info.updateAvailability == UpdateAvailability.updateAvailable) {
          print('update available');
          update();
        }
      });
    }).catchError((e) {
      print(e.toString());
    });
  }

  void update() async {
    print('Updating');
    await InAppUpdate.startFlexibleUpdate();
    InAppUpdate.completeFlexibleUpdate().then((_) {}).catchError((e) {
      print(e.toString());
    });
  }

  void _filterCredentials() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredCredentials = credentials.where((credential) {
        final heading = credential.heading.toLowerCase();
        final email = credential.email.toLowerCase();
        return heading.contains(query) || email.contains(query);
      }).toList();
    });
  }

  Future<void> _checkPermissionAndLoad() async {
    setState(() => isLoading = true);

    try {
      // Check for storage permission
      final status = await Permission.manageExternalStorage.status;

      if (status.isGranted) {
        // If permission is already granted, load credentials
        await _loadCredentials();
      } else {
        // Request permission
        final result = await Permission.manageExternalStorage.request();
        if (result.isGranted) {
          // Permission granted, load credentials
          await _loadCredentials();
        } else {
          // Permission denied, show dialog and keep app in loading state
          if (mounted) {
            _showPermissionDialog(true);
          }
        }
      }
    } catch (e) {
      print('Error checking permissions: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showPermissionDialog(bool isRequired) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: !isRequired,
      builder: (context) => WillPopScope(
        onWillPop: () async => !isRequired,
        child: AlertDialog(
          title: const Text('Storage Permission Required'),
          content: const Text(
            'This app needs storage permission to securely save your credentials. '
            'Please grant the permission to continue using the app.',
          ),
          actions: [
            if (!isRequired)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await openAppSettings();
                // Wait a bit for settings to update
                await Future.delayed(const Duration(seconds: 1));
                _checkPermissionAndLoad();
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadCredentials() async {
    try {
      // First verify file integrity
      final isFileValid = await StorageService.verifyFileIntegrity();
      if (!isFileValid) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: const Text(
                'The credentials file appears to be corrupted or tampered with. '
                'For security reasons, you may need to reset your credentials.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      credentials = [];
                      isLoading = false;
                    });
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          return;
        }
      }

      final loadedCredentials = await StorageService.loadCredentials();
      if (mounted) {
        setState(() {
          credentials = loadedCredentials;
          filteredCredentials = loadedCredentials;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading credentials: $e');
      if (mounted) {
        setState(() => isLoading = false);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text(
              'There was an error loading your credentials. '
              'Please try again later.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _showAddCredentialSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddCredentialSheet(
        onCredentialAdded: _loadCredentials,
      ),
    );
  }

  void _navigateToSettingsPage(BuildContext context) {
    Navigator.of(context).push(_createRoute());
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const SettingsPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F0F0),
        appBar: AppBar(
          scrolledUnderElevation: 0,
          title: const Text(
            'PASSCODE VAULT',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
              fontSize: 24,
              letterSpacing: 1,
            ),
          ),
          backgroundColor: const Color(0xFFFFE566),
          elevation: 0,
          shape: const Border(
            bottom: BorderSide(color: Colors.black, width: 4),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.menu,
                size: 28,
              ),
              onPressed: () => _navigateToSettingsPage(context),
            ),
          ],
        ),
        body: isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading credentials...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: ListView(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF83F18B),
                        border: Border.all(color: Colors.black, width: 3),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(5, 5),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black, width: 2),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black,
                                  offset: Offset(2, 2),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.search, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              decoration: const InputDecoration(
                                hintText: 'Search credentials...',
                                hintStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 12),
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (filteredCredentials.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            'No credentials saved yet.\nTap + to add new credentials.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    else
                      ...filteredCredentials
                          .map((credential) => Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: CredentialCard(
                                  heading: credential.heading,
                                  email: credential.email,
                                  password: credential.password,
                                  color: Color(credential.color),
                                  onCredentialAdded: _loadCredentials,
                                ),
                              ))
                          .toList(),
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
        floatingActionButton: GestureDetector(
          onTap: () => _showAddCredentialSheet(context),
          child: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE566),
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
            child: Material(
              color: Colors.transparent,
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Icon(
                  Icons.add,
                  size: 30,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
