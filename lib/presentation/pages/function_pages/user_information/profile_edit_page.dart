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
    late final AuthUsecase authUseCase;
    final TextEditingController _fullNameController = TextEditingController();
    final TextEditingController _phoneNumberController = TextEditingController();
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _dateController = TextEditingController();
    final TextEditingController _addressController = TextEditingController();

    DateTime? _selectedBirthDate;
    String? _selectedGender;
    File? _profileImage;

    String? _fullNameError;
    String? _phoneNumberError;
    String? _dateOfBirthError;
    String? _genderError;

    final List<String> _genderOptions = [
      'Male',
      'Female',
      'Other',
    ];

    @override
    void initState() {
      super.initState();

      authUseCase = ref.read(authUseCaseProvider);
      // Pre-fill with example data - in a real app, you'd get this from your user profile
      _fullNameController.text = "Lewis Mariyati";
      _phoneNumberController.text = "81218991001";
      _emailController.text = "lewismariyati187@gmail.com";
      _addressController.text =
          "Pattimura Road 12, Sukomoro Regency, Nganjuk City";
      _selectedGender = "Male"; // Set default gender
    }

    Future<void> _pickImage() async {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
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
        _selectedBirthDate ?? DateTime.now().subtract(const Duration(days: 6570)),
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
        if (_selectedBirthDate!.isBefore(minDate) || _selectedBirthDate!.isAfter(maxDate)) {
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
        NotifyAnotherFlushBar.showFlushbar(
            'Please fix the following: ${errorMessages.first}',
            isError: true);
      }

      return isValid;
    }

    Future<void> _submitForm() async {
      if (!_validateForm()) {
        return;
      }

      try {
        // setState(() {
        //   _isLoading = true;
        // });

        final userData = ProfileEditModel(
          fullName: _fullNameController.text,
          phoneNumber: _phoneNumberController.text,
          gender: _selectedGender!,
          dateOfBirth: _selectedBirthDate!,
          address: _addressController.text,
          profileImage: _profileImage,
        );

        final result = await authUseCase.editProfile(userData);

        // setState(() {
        //   _isLoading = false;
        // });

        // if (result.success) {
        //   _successNotify();
        // } else {
        //   NotifyAnotherFlushBar.showFlushbar(
        //       result.message ?? 'Failed to update profile',
        //       isError: true);
        // }
      } catch (e) {
        // setState(() {
        //   _isLoading = false;
        // });
        NotifyAnotherFlushBar.showFlushbar(
            'An error occurred: ${e.toString()}', isError: true);
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: GestureDetector(
          // Dismiss keyboard when tapping outside of text fields
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return
                // SingleChildScrollView(
                // child:
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 5),
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
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios,
                                color: Colors.blue,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            // Centered title
                            Align(
                              alignment: Alignment.center,
                              child: const Text(
                                'Edit Profile',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),

                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 20),

                                // Profile Image
                                Center(
                                  child: Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 50,
                                        backgroundImage:
                                            _profileImage != null
                                                ? FileImage(_profileImage!)
                                                    as ImageProvider
                                                : AssetImage(
                                                  "assets/profile_image.jpg",
                                                ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: GestureDetector(
                                          onTap: _pickImage,
                                          child: Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.deepOrange,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.camera_alt,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 30),

                                // Personal Information Section
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.deepOrange,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Personal Information",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 20),

                                // Full Name
                                Text(
                                  "Fullname",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                SizedBox(height: 8),
                                TextFormField(
                                  controller: _fullNameController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 15,
                                    ),
                                    errorText: _fullNameError,
                                  ),
                                  onChanged: (value) {
                                    if (_fullNameError != null) {
                                      setState(() {
                                        _fullNameError = null;
                                      });
                                    }
                                  },
                                ),

                                SizedBox(height: 20),

                                // Gender Selection
                                Text(
                                  "Gender",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                SizedBox(height: 8),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  decoration: BoxDecoration(
                                    // border: Border.all(
                                    //   color: Colors.grey.shade300,
                                    // ),
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                    _genderError != null
                                        ? Border.all(color: Colors.red)
                                        : Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton2<String>(
                                      isExpanded: true,
                                      hint: Text("Select Gender"),
                                      items:
                                          _genderOptions.map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                      value: _selectedGender,
                                      onChanged: (newValue) {
                                        setState(() {
                                          _selectedGender = newValue;
                                          _genderError = null;
                                        });
                                      },
                                      buttonStyleData: ButtonStyleData(),
                                      dropdownStyleData: DropdownStyleData(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (_genderError != null)
                                  Padding(
                                    padding:
                                    const EdgeInsets.only(top: 5, left: 12),
                                    child: Text(
                                      _genderError!,
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),

                                SizedBox(height: 20),

                                // Phone Number
                                Text(
                                  "Phone Number",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                SizedBox(height: 8),
                                TextFormField(
                                  controller: _phoneNumberController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 15,
                                    ),
                                    errorText: _phoneNumberError,
                                  ),
                                  onChanged: (value) {
                                    if (_phoneNumberError != null) {
                                      setState(() {
                                        _phoneNumberError = null;
                                      });
                                    }
                                  },
                                ),

                                SizedBox(height: 20),

                                // Email Address
                                Text(
                                  "Email Address",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                SizedBox(height: 8),
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 15,
                                    ),
                                  ),
                                ),

                                SizedBox(height: 20),

                                // Date of Birth
                                Text(
                                  "Date of Birth",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                SizedBox(height: 8),
                                TextFormField(
                                  controller: _dateController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 15,
                                    ),
                                    hintText: "DD/MM/YY",
                                    suffixIcon: Icon(Icons.calendar_today),
                                  ),
                                  onTap: () async {
                                    final DateTime? picked = await showDatePicker(
                                      context: context,
                                      initialDate:
                                          _selectedBirthDate ?? DateTime.now(),
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime.now(),
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

                                SizedBox(height: 30),

                                // Address & Location Section
                                // Row(
                                //   children: [
                                //     Container(
                                //       padding: EdgeInsets.all(8),
                                //       decoration: BoxDecoration(
                                //         color: Colors.deepOrange,
                                //         shape: BoxShape.circle,
                                //       ),
                                //       child: Icon(
                                //         Icons.location_on,
                                //         color: Colors.white,
                                //         size: 16,
                                //       ),
                                //     ),
                                //     SizedBox(width: 10),
                                //     Text(
                                //       "Address & Location",
                                //       style: TextStyle(
                                //         fontWeight: FontWeight.bold,
                                //         fontSize: 16,
                                //       ),
                                //     ),
                                //   ],
                                // ),

                                SizedBox(height: 20),

                                // Home Address
                                Text(
                                  "Home Address",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                SizedBox(height: 8),
                                TextFormField(
                                  controller: _addressController,
                                  maxLines: 2,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 15,
                                    ),
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 12.0,
                                        right: 8.0,
                                      ),
                                      child: Icon(Icons.home, color: Colors.grey),
                                    ),
                                  ),
                                ),

                                SizedBox(height: 30),

                                // Security Section - Link to change password
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.deepOrange,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.security,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Security",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 20),

                                // Change Password Button
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => PasswordChangePage()));
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Change Password",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Icon(Icons.chevron_right),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        // Save Changes Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Save profile changes
                              // ScaffoldMessenger.of(context).showSnackBar(
                              //   SnackBar(
                              //     content: Text('Profile updated successfully'),
                              //   ),
                              // );
                              _submitForm();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              "Save Changes",
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
                )
                // )
                ;
              },
            ),
          ),
        ),
      );
    }

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
