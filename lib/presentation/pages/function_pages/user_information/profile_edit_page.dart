import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/core/utils/notify_another_flushbar.dart';
import 'package:inner_child_app/domain/entities/auth/profile_edit_model.dart';
import 'package:inner_child_app/domain/usecases/auth_usecase.dart';
import 'package:inner_child_app/presentation/pages/function_pages/user_information/password_change_page.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({super.key});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  late final AuthUsecase _authUseCase;
  bool _isSubmitting = false;

  bool _isLoading = true;
  ProfileEditModel? _profileData;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String? _pictureProfile;

  DateTime? _selectedBirthDate;
  String? _selectedGender;
  File? _profileImage;

  String? _fullNameError;
  String? _phoneNumberError;
  String? _dateOfBirthError;
  String? _genderError;

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();

    _authUseCase = ref.read(authUseCaseProvider);
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final result =
          await _authUseCase.getPersonalDetail(); // returns UserProfile

      final profile = result.data!;

      setState(() {
        _profileData = profile;
        _fullNameController.text = profile.fullName ?? '';
        _phoneNumberController.text = profile.phoneNumber ?? '';
        _emailController.text = profile.email ?? '';
        _selectedGender = profile.gender;
        _selectedBirthDate = profile.dateOfBirth;
        if (_selectedBirthDate != null) {
          _dateController.text = DateFormat(
            'dd/MM/yyyy',
          ).format(_selectedBirthDate!);
        }
        _pictureProfile = profile.profilePicture;
        _isLoading = false;
      });
    } catch (e) {
      _isLoading = false;
      _profileData == null;
      Notify.showFlushbar(
        'Failed to load profile: ${e.toString()}',
        isError: true,
      );
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final File file = File(image.path);
      final int fileSizeInBytes = await file.length();
      final double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

      if (fileSizeInMB > 10) {
        // Show alert if file exceeds 10MB
        if (context.mounted) {
          Notify.showFlushbar(
            'Image exceeds the 10MB limit. Please choose a smaller file.',
            isError: true,
          );
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(
          //     content: Text(),
          //     backgroundColor: Colors.red,
          //   ),
          // );
        }
        return;
      }

      setState(() {
        _profileImage = file;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    // setState(() {
    //   _isSelectingDate = true;
    // });
    // _handleFocusChange();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedBirthDate ??
          DateTime.now().subtract(const Duration(days: 6570)),
      // Default to 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.brown,
            colorScheme: const ColorScheme.light(primary: Colors.brown),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
    // _handleFocusChange();
  }

  bool _validateForm() {
    bool isValid = true;
    List<String> errorMessages = [];

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final phoneRegex = RegExp(
      r'^\+?[0-9]{7,15}$',
    ); // Accepts intl & local formats

    // Reset all errors
    setState(() {
      _fullNameError = null;
      _phoneNumberError = null;
      _dateOfBirthError = null;
      _genderError = null;
    });

    // // We're not showing password fields in the UI but they're in the validation
    // // You can add them to the UI if needed
    //
    // // Password checks (if we decide to implement password change)
    // if (_passwordController.text.isNotEmpty) {
    //   final password = _passwordController.text;
    //   if (password.length < 5 || password.length > 100) {
    //     _passwordError = 'Password must be 5-100 characters';
    //     errorMessages.add(_passwordError!);
    //     isValid = false;
    //   }
    //
    //   // Confirm Password (only validate if password field has a value)
    //   final confirmPassword = _confirmPasswordController.text;
    //   if (confirmPassword.isEmpty) {
    //     _confirmPasswordError = 'Confirm password is required';
    //     errorMessages.add(_confirmPasswordError!);
    //     isValid = false;
    //   } else if (password != confirmPassword) {
    //     _confirmPasswordError = 'Password and confirm password do not match';
    //     errorMessages.add(_confirmPasswordError!);
    //     isValid = false;
    //   }
    // }

    // Full Name
    final fullName = _fullNameController.text;
    if (fullName.isEmpty) {
      _fullNameError = 'Full name is required';
      errorMessages.add(_fullNameError!);
      isValid = false;
    } else if (fullName.length < 4 || fullName.length > 25) {
      _fullNameError = 'Fullname must be 4-25 characters';
      errorMessages.add(_fullNameError!);
      isValid = false;
    }

    // Date of Birth
    if (_selectedBirthDate == null) {
      _dateOfBirthError = 'Date of birth is required';
      errorMessages.add(_dateOfBirthError!);
      isValid = false;
    } else {
      final minDate = DateTime(1800, 1, 1);
      final maxDate = DateTime(2100, 12, 31);
      if (_selectedBirthDate!.isBefore(minDate) ||
          _selectedBirthDate!.isAfter(maxDate)) {
        _dateOfBirthError =
            'Date of birth must be between 01/01/1800 and 12/31/2100';
        errorMessages.add(_dateOfBirthError!);
        isValid = false;
      }
    }

    // Gender
    if (_selectedGender == null) {
      _genderError = 'Gender is required';
      errorMessages.add(_genderError!);
      isValid = false;
    }

    // Phone Number
    final phone = _phoneNumberController.text;
    if (phone.isEmpty) {
      _phoneNumberError = 'Phone number is required';
      errorMessages.add(_phoneNumberError!);
      isValid = false;
    } else if (!phoneRegex.hasMatch(phone)) {
      _phoneNumberError = 'Invalid phone number';
      errorMessages.add(_phoneNumberError!);
      isValid = false;
    }

    // Show flushbar with the first error message if any
    if (errorMessages.isNotEmpty) {
      Notify.showFlushbar(
        'Please fix the following: ${errorMessages.first}',
        isError: true,
      );
    }

    return isValid;
  }


  Future<void> _submitForm() async {
    if (!_validateForm()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final userData = ProfileEditModel(
        fullName: _fullNameController.text,
        phoneNumber: _phoneNumberController.text,
        gender: _selectedGender!,
        dateOfBirth: _selectedBirthDate!,
        profileImage: _profileImage,
      );

      final result = await _authUseCase.editProfile(userData);

      if (result.isSuccess) {
        Notify.showFlushbar('Profile updated successfully');
        await _loadProfile(); // Reload profile data after successful update

        // Optional: Navigate back or show success state
        if (mounted) {
          Navigator.of(context).pop(); // Go back to previous screen
        }
      } else {
        _showErrorWithRetry(
          result.error ?? 'Failed to update profile',
              () => _submitForm(), // Retry callback
        );
      }
    } catch (e) {
      _showErrorWithRetry(
        'An error occurred: ${e.toString()}',
            () => _submitForm(), // Retry callback
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showErrorWithRetry(String message, VoidCallback retryCallback) {
    // Show error notification
    Notify.showFlushbar(message, isError: true);

    // Optional: Show dialog with retry option
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Error',
            style: TextStyle(
              fontFamily: 'League Spartan',
              fontWeight: FontWeight.bold,
              color: Color(0xFFE37083), // RASPBERRY
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: Colors.black87,
            ),
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF89B7C2), // SPRING SKY
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                retryCallback(); // Retry the operation
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE37083), // RASPBERRY
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA), // Light background
        body: GestureDetector(
          // Dismiss keyboard when tapping outside of text fields
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Container(
                  width: double.infinity,
                  // margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF89B7C2).withOpacity(0.1), // SPRING SKY shadow
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button and title
                      Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          // Back button on the left
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF89B7C2).withOpacity(0.1), // SPRING SKY
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios,
                                color: Color(0xFF89B7C2), // SPRING SKY
                                size: 20,
                              ),
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                          // Centered title
                          Align(
                            alignment: Alignment.center,
                            child: const Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontFamily: 'League Spartan',
                                color: Color(0xFFE37083), // RASPBERRY
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ],
                      ),

                      _isLoading
                          ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xFFFFB876), // PAPAYA
                          ),
                        ),
                      )
                          : _profileData == null
                          ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Failed to load profile.',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                color: Color(0xFFE37083), // RASPBERRY
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFB876), // PAPAYA
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text(
                                "Retry",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                          : Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 24),

                              // Profile Image
                              Center(
                                child: Stack(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFFFFB876), // PAPAYA
                                            const Color(0xFFF49AA2), // ICE CREAM
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        radius: 50,
                                        backgroundColor: Colors.white,
                                        child: CircleAvatar(
                                          radius: 46,
                                          backgroundImage:
                                          _profileImage != null
                                              ? FileImage(_profileImage!)
                                              : (_pictureProfile != null
                                              ? NetworkImage(
                                            _pictureProfile!,
                                          )
                                          as ImageProvider
                                              : const AssetImage(
                                            "assets/images/user_avt.png",
                                          )),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: _pickImage,
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                const Color(0xFFFFCB7C), // SUNSHINE
                                                const Color(0xFFFFB876), // PAPAYA
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFFFFB876).withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Personal Information Section
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFFF49AA2), // ICE CREAM
                                          const Color(0xFFE37083), // RASPBERRY
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    "Personal Information",
                                    style: TextStyle(
                                      fontFamily: 'League Spartan',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Color(0xFFE37083), // RASPBERRY
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // Full Name
                              const Text(
                                "Fullname",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _fullNameController,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: const Color(0xFF89B7C2).withOpacity(0.3), // SPRING SKY
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: const Color(0xFF89B7C2).withOpacity(0.3), // SPRING SKY
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFFFB876), // PAPAYA
                                      width: 2,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE37083), // RASPBERRY
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  errorText: _fullNameError,
                                  errorStyle: const TextStyle(
                                    fontFamily: 'Inter',
                                    color: Color(0xFFE37083), // RASPBERRY
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFF89B7C2).withOpacity(0.05), // SPRING SKY tint
                                ),
                                onChanged: (value) {
                                  if (_fullNameError != null) {
                                    setState(() {
                                      _fullNameError = null;
                                    });
                                  }
                                },
                              ),

                              const SizedBox(height: 20),

                              // Gender Selection
                              const Text(
                                "Gender",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: _genderError != null
                                      ? Border.all(
                                    color: const Color(0xFFE37083), // RASPBERRY
                                    width: 2,
                                  )
                                      : Border.all(
                                    color: const Color(0xFF89B7C2).withOpacity(0.3), // SPRING SKY
                                  ),
                                  color: const Color(0xFF89B7C2).withOpacity(0.05), // SPRING SKY tint
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2<String>(
                                    isExpanded: true,
                                    hint: const Text(
                                      "Select Gender",
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        color: Colors.grey,
                                      ),
                                    ),
                                    items: _genderOptions.map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 16,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    value: _selectedGender,
                                    onChanged: (newValue) {
                                      setState(() {
                                        _selectedGender = newValue;
                                        _genderError = null;
                                      });
                                    },
                                    buttonStyleData: const ButtonStyleData(
                                      height: 50,
                                    ),
                                    dropdownStyleData: DropdownStyleData(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF89B7C2).withOpacity(0.1),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                    ),
                                    iconStyleData: const IconStyleData(
                                      icon: Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Color(0xFFFFB876), // PAPAYA
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (_genderError != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 5,
                                    left: 12,
                                  ),
                                  child: Text(
                                    _genderError!,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      color: Color(0xFFE37083), // RASPBERRY
                                      fontSize: 12,
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 20),

                              // Phone Number
                              const Text(
                                "Phone Number",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _phoneNumberController,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: const Color(0xFF89B7C2).withOpacity(0.3), // SPRING SKY
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: const Color(0xFF89B7C2).withOpacity(0.3), // SPRING SKY
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFFFB876), // PAPAYA
                                      width: 2,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE37083), // RASPBERRY
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  errorText: _phoneNumberError,
                                  errorStyle: const TextStyle(
                                    fontFamily: 'Inter',
                                    color: Color(0xFFE37083), // RASPBERRY
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFF89B7C2).withOpacity(0.05), // SPRING SKY tint
                                ),
                                onChanged: (value) {
                                  if (_phoneNumberError != null) {
                                    setState(() {
                                      _phoneNumberError = null;
                                    });
                                  }
                                },
                              ),

                              const SizedBox(height: 20),

                              // Email Address
                              const Text(
                                "Email Address",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: const Color(0xFF89B7C2).withOpacity(0.3), // SPRING SKY
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: const Color(0xFF89B7C2).withOpacity(0.3), // SPRING SKY
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFFFB876), // PAPAYA
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFF89B7C2).withOpacity(0.05), // SPRING SKY tint
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Date of Birth
                              const Text(
                                "Date of Birth",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _dateController,
                                readOnly: true,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: const Color(0xFF89B7C2).withOpacity(0.3), // SPRING SKY
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: const Color(0xFF89B7C2).withOpacity(0.3), // SPRING SKY
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFFFB876), // PAPAYA
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  hintText: "DD/MM/YY",
                                  hintStyle: const TextStyle(
                                    fontFamily: 'Inter',
                                    color: Colors.grey,
                                  ),
                                  suffixIcon: Container(
                                    margin: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFCB7C).withOpacity(0.2), // SUNSHINE
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.calendar_today,
                                      color: Color(0xFFFFB876), // PAPAYA
                                      size: 20,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFF89B7C2).withOpacity(0.05), // SPRING SKY tint
                                ),
                                onTap: () async {
                                  final DateTime? picked =
                                  await showDatePicker(
                                    context: context,
                                    initialDate:
                                    _selectedBirthDate ??
                                        DateTime.now(),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now(),
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: const ColorScheme.light(
                                            primary: Color(0xFFFFB876), // PAPAYA
                                            onPrimary: Colors.white,
                                            surface: Colors.white,
                                            onSurface: Colors.black,
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (picked != null &&
                                      picked != _selectedBirthDate) {
                                    setState(() {
                                      _selectedBirthDate = picked;
                                      _dateController.text = DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(picked);
                                    });
                                  }
                                },
                              ),

                              const SizedBox(height: 20),

                              // Home Address
                              const Text(
                                "Home Address",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Security Section - Link to change password
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFFA8BF8A), // MEADOW
                                          const Color(0xFF89B7C2), // SPRING SKY
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.security,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    "Security",
                                    style: TextStyle(
                                      fontFamily: 'League Spartan',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Color(0xFFA8BF8A), // MEADOW
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Change Password Button
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => PasswordChangePage(),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFFA8BF8A).withOpacity(0.1), // MEADOW
                                        const Color(0xFF89B7C2).withOpacity(0.1), // SPRING SKY
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    border: Border.all(
                                      color: const Color(0xFFA8BF8A).withOpacity(0.3), // MEADOW
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Change Password",
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: Color(0xFF2C3E50),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFA8BF8A).withOpacity(0.2), // MEADOW
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Icon(
                                          Icons.chevron_right,
                                          color: Color(0xFFA8BF8A), // MEADOW
                                          size: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Save Changes Button
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: _isSubmitting
                              ? LinearGradient(
                            colors: [Colors.grey.shade400, Colors.grey.shade500],
                          )
                              : LinearGradient(
                            colors: [
                              const Color(0xFFFFB876), // PAPAYA
                              const Color(0xFFE37083), // RASPBERRY
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _isSubmitting
                              ? []
                              : [
                            BoxShadow(
                              color: const Color(0xFFFFB876).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitForm, // Disable when submitting
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSubmitting
                              ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Saving...',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          )
                              : const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }


// Helper method to show error with retry option
//   void _showErrorWithRetry(String message, VoidCallback retryCallback) {
//     // Show error notification
//     Notify.showFlushbar(message, isError: true);
//
//     // Optional: Show dialog with retry option
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Error'),
//           content: Text(message),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 retryCallback(); // Retry the operation
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.deepOrange,
//               ),
//               child: const Text(
//                 'Retry',
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
  @override
  // Widget build(BuildContext context) {
  //   return SafeArea(
  //     child: Scaffold(
  //       body: GestureDetector(
  //         // Dismiss keyboard when tapping outside of text fields
  //         onTap: () {
  //           FocusScope.of(context).unfocus();
  //         },
  //         child: LayoutBuilder(
  //           builder: (context, constraints) {
  //             return
  //             // SingleChildScrollView(
  //             // child:
  //             ConstrainedBox(
  //               constraints: BoxConstraints(minHeight: constraints.maxHeight),
  //               child: Container(
  //                 width: double.infinity,
  //                 padding: const EdgeInsets.all(20),
  //                 decoration: BoxDecoration(
  //                   color: Colors.white,
  //                   borderRadius: BorderRadius.circular(16),
  //                   boxShadow: [
  //                     BoxShadow(
  //                       color: Colors.black12,
  //                       blurRadius: 10,
  //                       offset: Offset(0, 5),
  //                     ),
  //                   ],
  //                 ),
  //                 child: Column(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     // Back button and title
  //                     Stack(
  //                       alignment: Alignment.centerLeft,
  //                       children: [
  //                         // Back button on the left
  //                         IconButton(
  //                           icon: const Icon(
  //                             Icons.arrow_back_ios,
  //                             color: Colors.blue,
  //                           ),
  //                           padding: EdgeInsets.zero,
  //                           constraints: const BoxConstraints(),
  //                           onPressed: () => Navigator.of(context).pop(),
  //                         ),
  //                         // Centered title
  //                         Align(
  //                           alignment: Alignment.center,
  //                           child: const Text(
  //                             'Edit Profile',
  //                             style: TextStyle(
  //                               color: Colors.black,
  //                               fontWeight: FontWeight.bold,
  //                               fontSize: 20,
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //
  //                     _isLoading
  //                         ? const Center(child: CircularProgressIndicator())
  //                         : _profileData == null
  //                         ? Center(
  //                           child: Column(
  //                             mainAxisAlignment: MainAxisAlignment.center,
  //                             children: [
  //                               const Text(
  //                                 'Failed to load profile.',
  //                                 style: TextStyle(fontSize: 16),
  //                               ),
  //                               const SizedBox(height: 10),
  //                               ElevatedButton(
  //                                 onPressed: _loadProfile,
  //                                 style: ElevatedButton.styleFrom(
  //                                   backgroundColor: Colors.deepOrange,
  //                                 ),
  //                                 child: const Text("Retry"),
  //                               ),
  //                             ],
  //                           ),
  //                         )
  //                         : Expanded(
  //                           child: SingleChildScrollView(
  //                             child: Column(
  //                               crossAxisAlignment: CrossAxisAlignment.start,
  //                               children: [
  //                                 SizedBox(height: 20),
  //
  //                                 // Profile Image
  //                                 Center(
  //                                   child: Stack(
  //                                     children: [
  //                                       CircleAvatar(
  //                                         radius: 50,
  //                                         backgroundImage:
  //                                             _profileImage != null
  //                                                 ? FileImage(_profileImage!)
  //                                                 : (_pictureProfile != null
  //                                                     ? NetworkImage(
  //                                                           _pictureProfile!,
  //                                                         )
  //                                                         as ImageProvider
  //                                                     : AssetImage(
  //                                                       "assets/images/user_avt.png",
  //                                                     )),
  //                                         // backgroundImage:
  //                                         //     _profileImage != null
  //                                         //         ? FileImage(_profileImage!)
  //                                         //             as ImageProvider
  //                                         //         : AssetImage(
  //                                         //           "assets/profile_image.jpg",
  //                                         //         ),
  //                                       ),
  //                                       Positioned(
  //                                         bottom: 0,
  //                                         right: 0,
  //                                         child: GestureDetector(
  //                                           onTap: _pickImage,
  //                                           child: Container(
  //                                             padding: EdgeInsets.all(8),
  //                                             decoration: BoxDecoration(
  //                                               color: Colors.deepOrange,
  //                                               shape: BoxShape.circle,
  //                                             ),
  //                                             child: Icon(
  //                                               Icons.camera_alt,
  //                                               color: Colors.white,
  //                                               size: 16,
  //                                             ),
  //                                           ),
  //                                         ),
  //                                       ),
  //                                     ],
  //                                   ),
  //                                 ),
  //
  //                                 SizedBox(height: 30),
  //
  //                                 // Personal Information Section
  //                                 Row(
  //                                   children: [
  //                                     Container(
  //                                       padding: EdgeInsets.all(8),
  //                                       decoration: BoxDecoration(
  //                                         color: Colors.deepOrange,
  //                                         shape: BoxShape.circle,
  //                                       ),
  //                                       child: Icon(
  //                                         Icons.person,
  //                                         color: Colors.white,
  //                                         size: 16,
  //                                       ),
  //                                     ),
  //                                     SizedBox(width: 10),
  //                                     Text(
  //                                       "Personal Information",
  //                                       style: TextStyle(
  //                                         fontWeight: FontWeight.bold,
  //                                         fontSize: 16,
  //                                       ),
  //                                     ),
  //                                   ],
  //                                 ),
  //
  //                                 SizedBox(height: 20),
  //
  //                                 // Full Name
  //                                 Text(
  //                                   "Fullname",
  //                                   style: TextStyle(
  //                                     fontWeight: FontWeight.w500,
  //                                   ),
  //                                 ),
  //                                 SizedBox(height: 8),
  //                                 TextFormField(
  //                                   controller: _fullNameController,
  //                                   decoration: InputDecoration(
  //                                     border: OutlineInputBorder(
  //                                       borderRadius: BorderRadius.circular(8),
  //                                       borderSide: BorderSide(
  //                                         color: Colors.grey.shade300,
  //                                       ),
  //                                     ),
  //                                     contentPadding: EdgeInsets.symmetric(
  //                                       horizontal: 15,
  //                                       vertical: 15,
  //                                     ),
  //                                     errorText: _fullNameError,
  //                                   ),
  //                                   onChanged: (value) {
  //                                     if (_fullNameError != null) {
  //                                       setState(() {
  //                                         _fullNameError = null;
  //                                       });
  //                                     }
  //                                   },
  //                                 ),
  //
  //                                 SizedBox(height: 20),
  //
  //                                 // Gender Selection
  //                                 Text(
  //                                   "Gender",
  //                                   style: TextStyle(
  //                                     fontWeight: FontWeight.w500,
  //                                   ),
  //                                 ),
  //                                 SizedBox(height: 8),
  //                                 Container(
  //                                   padding: EdgeInsets.symmetric(
  //                                     horizontal: 15,
  //                                   ),
  //                                   decoration: BoxDecoration(
  //                                     // border: Border.all(
  //                                     //   color: Colors.grey.shade300,
  //                                     // ),
  //                                     borderRadius: BorderRadius.circular(8),
  //                                     border:
  //                                         _genderError != null
  //                                             ? Border.all(color: Colors.red)
  //                                             : Border.all(
  //                                               color: Colors.grey.shade300,
  //                                             ),
  //                                   ),
  //                                   child: DropdownButtonHideUnderline(
  //                                     child: DropdownButton2<String>(
  //                                       isExpanded: true,
  //                                       hint: Text("Select Gender"),
  //                                       items:
  //                                           _genderOptions.map((String value) {
  //                                             return DropdownMenuItem<String>(
  //                                               value: value,
  //                                               child: Text(value),
  //                                             );
  //                                           }).toList(),
  //                                       value: _selectedGender,
  //                                       onChanged: (newValue) {
  //                                         setState(() {
  //                                           _selectedGender = newValue;
  //                                           _genderError = null;
  //                                         });
  //                                       },
  //                                       buttonStyleData: ButtonStyleData(),
  //                                       dropdownStyleData: DropdownStyleData(
  //                                         decoration: BoxDecoration(
  //                                           borderRadius: BorderRadius.circular(
  //                                             12,
  //                                           ),
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 ),
  //                                 if (_genderError != null)
  //                                   Padding(
  //                                     padding: const EdgeInsets.only(
  //                                       top: 5,
  //                                       left: 12,
  //                                     ),
  //                                     child: Text(
  //                                       _genderError!,
  //                                       style: TextStyle(
  //                                         color: Colors.red,
  //                                         fontSize: 12,
  //                                       ),
  //                                     ),
  //                                   ),
  //
  //                                 SizedBox(height: 20),
  //
  //                                 // Phone Number
  //                                 Text(
  //                                   "Phone Number",
  //                                   style: TextStyle(
  //                                     fontWeight: FontWeight.w500,
  //                                   ),
  //                                 ),
  //                                 SizedBox(height: 8),
  //                                 TextFormField(
  //                                   controller: _phoneNumberController,
  //                                   keyboardType: TextInputType.phone,
  //                                   decoration: InputDecoration(
  //                                     border: OutlineInputBorder(
  //                                       borderRadius: BorderRadius.circular(8),
  //                                       borderSide: BorderSide(
  //                                         color: Colors.grey.shade300,
  //                                       ),
  //                                     ),
  //                                     contentPadding: EdgeInsets.symmetric(
  //                                       horizontal: 15,
  //                                       vertical: 15,
  //                                     ),
  //                                     errorText: _phoneNumberError,
  //                                   ),
  //                                   onChanged: (value) {
  //                                     if (_phoneNumberError != null) {
  //                                       setState(() {
  //                                         _phoneNumberError = null;
  //                                       });
  //                                     }
  //                                   },
  //                                 ),
  //
  //                                 SizedBox(height: 20),
  //
  //                                 // Email Address
  //                                 Text(
  //                                   "Email Address",
  //                                   style: TextStyle(
  //                                     fontWeight: FontWeight.w500,
  //                                   ),
  //                                 ),
  //                                 SizedBox(height: 8),
  //                                 TextFormField(
  //                                   controller: _emailController,
  //                                   keyboardType: TextInputType.emailAddress,
  //                                   decoration: InputDecoration(
  //                                     border: OutlineInputBorder(
  //                                       borderRadius: BorderRadius.circular(8),
  //                                       borderSide: BorderSide(
  //                                         color: Colors.grey.shade300,
  //                                       ),
  //                                     ),
  //                                     contentPadding: EdgeInsets.symmetric(
  //                                       horizontal: 15,
  //                                       vertical: 15,
  //                                     ),
  //                                   ),
  //                                 ),
  //
  //                                 SizedBox(height: 20),
  //
  //                                 // Date of Birth
  //                                 Text(
  //                                   "Date of Birth",
  //                                   style: TextStyle(
  //                                     fontWeight: FontWeight.w500,
  //                                   ),
  //                                 ),
  //                                 SizedBox(height: 8),
  //                                 TextFormField(
  //                                   controller: _dateController,
  //                                   readOnly: true,
  //                                   decoration: InputDecoration(
  //                                     border: OutlineInputBorder(
  //                                       borderRadius: BorderRadius.circular(8),
  //                                       borderSide: BorderSide(
  //                                         color: Colors.grey.shade300,
  //                                       ),
  //                                     ),
  //                                     contentPadding: EdgeInsets.symmetric(
  //                                       horizontal: 15,
  //                                       vertical: 15,
  //                                     ),
  //                                     hintText: "DD/MM/YY",
  //                                     suffixIcon: Icon(Icons.calendar_today),
  //                                   ),
  //                                   onTap: () async {
  //                                     final DateTime? picked =
  //                                         await showDatePicker(
  //                                           context: context,
  //                                           initialDate:
  //                                               _selectedBirthDate ??
  //                                               DateTime.now(),
  //                                           firstDate: DateTime(1900),
  //                                           lastDate: DateTime.now(),
  //                                         );
  //                                     if (picked != null &&
  //                                         picked != _selectedBirthDate) {
  //                                       setState(() {
  //                                         _selectedBirthDate = picked;
  //                                         _dateController.text = DateFormat(
  //                                           'dd/MM/yyyy',
  //                                         ).format(picked);
  //                                       });
  //                                     }
  //                                   },
  //                                 ),
  //
  //                                 SizedBox(height: 20),
  //
  //                                 // Home Address
  //                                 Text(
  //                                   "Home Address",
  //                                   style: TextStyle(
  //                                     fontWeight: FontWeight.w500,
  //                                   ),
  //                                 ),
  //
  //                                 // SizedBox(height: 8),
  //                                 // TextFormField(
  //                                 //   controller: _addressController,
  //                                 //   maxLines: 2,
  //                                 //   decoration: InputDecoration(
  //                                 //     border: OutlineInputBorder(
  //                                 //       borderRadius: BorderRadius.circular(8),
  //                                 //       borderSide: BorderSide(
  //                                 //         color: Colors.grey.shade300,
  //                                 //       ),
  //                                 //     ),
  //                                 //     contentPadding: EdgeInsets.symmetric(
  //                                 //       horizontal: 15,
  //                                 //       vertical: 15,
  //                                 //     ),
  //                                 //     prefixIcon: Padding(
  //                                 //       padding: const EdgeInsets.only(
  //                                 //         left: 12.0,
  //                                 //         right: 8.0,
  //                                 //       ),
  //                                 //       child: Icon(Icons.home, color: Colors.grey),
  //                                 //     ),
  //                                 //   ),
  //                                 // ),
  //                                 SizedBox(height: 30),
  //
  //                                 // Security Section - Link to change password
  //                                 Row(
  //                                   children: [
  //                                     Container(
  //                                       padding: EdgeInsets.all(8),
  //                                       decoration: BoxDecoration(
  //                                         color: Colors.deepOrange,
  //                                         shape: BoxShape.circle,
  //                                       ),
  //                                       child: Icon(
  //                                         Icons.security,
  //                                         color: Colors.white,
  //                                         size: 16,
  //                                       ),
  //                                     ),
  //                                     SizedBox(width: 10),
  //                                     Text(
  //                                       "Security",
  //                                       style: TextStyle(
  //                                         fontWeight: FontWeight.bold,
  //                                         fontSize: 16,
  //                                       ),
  //                                     ),
  //                                   ],
  //                                 ),
  //
  //                                 SizedBox(height: 20),
  //
  //                                 // Change Password Button
  //                                 GestureDetector(
  //                                   onTap: () {
  //                                     Navigator.push(
  //                                       context,
  //                                       MaterialPageRoute(
  //                                         builder:
  //                                             (context) => PasswordChangePage(),
  //                                       ),
  //                                     );
  //                                   },
  //                                   child: Container(
  //                                     padding: EdgeInsets.all(15),
  //                                     decoration: BoxDecoration(
  //                                       border: Border.all(
  //                                         color: Colors.grey.shade300,
  //                                       ),
  //                                       borderRadius: BorderRadius.circular(8),
  //                                     ),
  //                                     child: Row(
  //                                       mainAxisAlignment:
  //                                           MainAxisAlignment.spaceBetween,
  //                                       children: [
  //                                         Text(
  //                                           "Change Password",
  //                                           style: TextStyle(
  //                                             fontWeight: FontWeight.bold,
  //                                           ),
  //                                         ),
  //                                         Icon(Icons.chevron_right),
  //                                       ],
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                     SizedBox(height: 20),
  //                     // Save Changes Button
  //                     SizedBox(
  //                       width: double.infinity,
  //                       child: ElevatedButton(
  //                         onPressed: _isSubmitting ? null : _submitForm, // Disable when submitting
  //                         style: ElevatedButton.styleFrom(
  //                           backgroundColor: _isSubmitting ? Colors.grey : Colors.deepOrange,
  //                           padding: const EdgeInsets.symmetric(vertical: 15),
  //                           shape: RoundedRectangleBorder(
  //                             borderRadius: BorderRadius.circular(8),
  //                           ),
  //                         ),
  //                         child: _isSubmitting
  //                             ? const Row(
  //                           mainAxisAlignment: MainAxisAlignment.center,
  //                           children: [
  //                             SizedBox(
  //                               width: 20,
  //                               height: 20,
  //                               child: CircularProgressIndicator(
  //                                 strokeWidth: 2,
  //                                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
  //                               ),
  //                             ),
  //                             SizedBox(width: 10),
  //                             Text(
  //                               'Saving...',
  //                               style: TextStyle(
  //                                 color: Colors.white,
  //                                 fontWeight: FontWeight.bold,
  //                               ),
  //                             ),
  //                           ],
  //                         )
  //                             : const Text(
  //                           'Save Changes',
  //                           style: TextStyle(
  //                             color: Colors.white,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                     // SizedBox(
  //                     //   width: double.infinity,
  //                     //   child: ElevatedButton(
  //                     //     onPressed: () {
  //                     //       _submitForm();
  //                     //     },
  //                     //     style: ElevatedButton.styleFrom(
  //                     //       backgroundColor: Colors.deepOrange,
  //                     //       padding: EdgeInsets.symmetric(vertical: 15),
  //                     //       shape: RoundedRectangleBorder(
  //                     //         borderRadius: BorderRadius.circular(8),
  //                     //       ),
  //                     //     ),
  //                     //     child: Text(
  //                     //       "Save Changes",
  //                     //       style: TextStyle(
  //                     //         color: Colors.white,
  //                     //         fontWeight: FontWeight.bold,
  //                     //       ),
  //                     //     ),
  //                     //   ),
  //                     // ),
  //                   ],
  //                 ),
  //               ),
  //             )
  //             // )
  //             ;
  //           },
  //         ),
  //       ),
  //     ),
  //   );
  // }

  void _successNotify() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.1 * 255).round()),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Icon
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, color: Colors.white, size: 30),
                ),

                SizedBox(height: 20),

                // Success Message
                Text(
                  "Profile successfully updated",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 10),

                // Description
                Text(
                  "Congratulations 🎉, your profile has been successfully updated. Enjoy your next trip on our app.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700, height: 1.5),
                ),

                SizedBox(height: 20),

                // Okay Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Okay, Thanks",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
