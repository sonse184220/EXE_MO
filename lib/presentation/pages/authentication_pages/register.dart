import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inner_child_app/core/utils/notify_another_flushbar.dart';
import 'package:inner_child_app/domain/entities/auth/user_register_model.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/dependency_injection/injection.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends ConsumerState<RegisterPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _headerController;
  // late final Animation<double> _headerAnimation;
  bool _isAnyFieldFocused = false;
  bool _isSelectingDate = false;
  bool _isSelectingGender = false;
  bool _isPickingImage = false;

  // Create FocusNodes for all input fields
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final FocusNode _fullNameFocus = FocusNode();
  final FocusNode _phoneNumberFocus = FocusNode();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedGender;
  File? _profileImage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Error message strings
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _fullNameError;
  String? _phoneNumberError;
  String? _dateOfBirthError;
  String? _genderError;

  // Form validation state
  final _formKey = GlobalKey<FormState>();

  bool get isValidData {
    return _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null &&
        _fullNameError == null &&
        _phoneNumberError == null &&
        _dateOfBirthError == null &&
        _genderError == null;
  }

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: 1.0,
    );

    // Add listeners to all focus nodes
    _emailFocus.addListener(_handleFocusChange);
    _passwordFocus.addListener(_handleFocusChange);
    _confirmPasswordFocus.addListener(_handleFocusChange);
    _fullNameFocus.addListener(_handleFocusChange);
    _phoneNumberFocus.addListener(_handleFocusChange);
  }

  // Validate all form fields
  bool _validateForm() {
    bool isValid = true;
    List<String> errorMessages = [];

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final phoneRegex = RegExp(
      r'^\+?[0-9]{7,15}$',
    ); // Accepts intl & local formats

    // Reset all errors
    setState(() {
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _fullNameError = null;
      _phoneNumberError = null;
      _dateOfBirthError = null;
      _genderError = null;
    });

    // Email
    if (_emailController.text.isEmpty) {
      _emailError = 'Email is required';
      errorMessages.add(_emailError!);
      isValid = false;
    } else if (!emailRegex.hasMatch(_emailController.text)) {
      _emailError = 'Email is not valid';
      errorMessages.add(_emailError!);
      isValid = false;
    }

    // Password
    final password = _passwordController.text;
    if (password.isEmpty) {
      _passwordError = 'Password is required';
      errorMessages.add(_passwordError!);
      isValid = false;
    } else if (password.length < 5 || password.length > 100) {
      _passwordError = 'Password must be 5-100 characters';
      errorMessages.add(_passwordError!);
      isValid = false;
    }

    // Confirm Password
    final confirmPassword = _confirmPasswordController.text;
    if (confirmPassword.isEmpty) {
      _confirmPasswordError = 'Confirm password is required';
      errorMessages.add(_confirmPasswordError!);
      isValid = false;
    } else if (password != confirmPassword) {
      _confirmPasswordError = 'Password and confirm password do not match';
      errorMessages.add(_confirmPasswordError!);
      isValid = false;
    }

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
    if (_selectedDate == null) {
      _dateOfBirthError = 'Date of birth is required';
      errorMessages.add(_dateOfBirthError!);
      isValid = false;
    } else {
      final minDate = DateTime(1800, 1, 1);
      final maxDate = DateTime(2100, 12, 31);
      if (_selectedDate!.isBefore(minDate) || _selectedDate!.isAfter(maxDate)) {
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
      Notify.showFlushbar('Please fix the following: ${errorMessages.first}', isError: true);
    }

    // Update UI with setState
    setState(() {});

    return isValid;
  }

  void _handleFocusChange() {
    bool isAnyFieldActive =
        _emailFocus.hasFocus ||
        _passwordFocus.hasFocus ||
        _confirmPasswordFocus.hasFocus ||
        _fullNameFocus.hasFocus ||
        _phoneNumberFocus.hasFocus ||
        _isSelectingDate ||
        _isSelectingGender ||
        _isPickingImage;

    if (isAnyFieldActive != _isAnyFieldFocused) {
      setState(() {
        _isAnyFieldFocused = isAnyFieldActive;
      });

      if (_isAnyFieldFocused) {
        _headerController.reverse();
      } else {
        _headerController.forward();
      }
    }
  }

  @override
  void dispose() {
    // Dispose all focus nodes
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _fullNameFocus.dispose();
    _phoneNumberFocus.dispose();

    _headerController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    setState(() {
      _isSelectingDate = true;
    });
    _handleFocusChange();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate ?? DateTime.now().subtract(const Duration(days: 6570)),
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

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
    _handleFocusChange();
  }

  Future<void> _pickImage() async {
    setState(() {
      _isPickingImage = true;
    });
    _handleFocusChange();

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }

    _handleFocusChange();
  }

  @override
  Widget build(BuildContext context) {
    final authUseCase = ref.read(authUseCaseProvider);

    // Listen for keyboard visibility changes
    // final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isAnyFieldFocused &&
          _selectedGender == null &&
          _selectedDate == null) {
        _headerController.forward();
      }
    });

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();

        // Reset gender and date if previously selected
        setState(() {
          _isPickingImage = false;
          _isSelectingGender = false;
          _isSelectingDate = false;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: SafeArea(
        child:  Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Animated Header Section
                  SizeTransition(
                    sizeFactor: _headerController,
                    axisAlignment: -1.0, // Grow from top
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // App Logo
                        Container(
                          width: 70,
                          height: 80,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/appLogo.png'),
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),

                        // Welcome Text section
                        Container(
                          margin: const EdgeInsets.only(top: 20, bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Join us for a Healthier, Happier You',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Profile Picture Section
                          Center(
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      shape: BoxShape.circle,
                                      image:
                                          _profileImage != null
                                              ? DecorationImage(
                                                image: FileImage(
                                                  _profileImage!,
                                                ),
                                                fit: BoxFit.cover,
                                              )
                                              : null,
                                    ),
                                    child:
                                        _profileImage == null
                                            ? const Icon(
                                              Icons.add_a_photo,
                                              size: 40,
                                              color: Colors.grey,
                                            )
                                            : null,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Add Profile Picture (Optional)',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          //Input Fields Section
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Email
                              TextFormField(
                                controller: _emailController,
                                focusNode: _emailFocus,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  hintText: 'Email Address *',
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  prefixIcon: const Icon(
                                    Icons.email,
                                    color: Colors.grey,
                                  ),
                                  errorText: _emailError,
                                ),
                                onChanged: (value) {
                                  if (_emailError != null) {
                                    setState(() {
                                      _emailError = null;
                                    });
                                  }
                                },
                              ),
                              const SizedBox(height: 16),

                              // Password
                              TextFormField(
                                controller: _passwordController,
                                focusNode: _passwordFocus,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  hintText: 'Password *',
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  prefixIcon: const Icon(
                                    Icons.lock,
                                    color: Colors.grey,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  errorText: _passwordError,
                                ),
                                onChanged: (value) {
                                  if (_passwordError != null) {
                                    setState(() {
                                      _passwordError = null;
                                    });
                                  }
                                  // Check confirm password match if it's already filled
                                  if (_confirmPasswordController
                                      .text
                                      .isNotEmpty) {
                                    setState(() {
                                      _confirmPasswordError =
                                          _confirmPasswordController.text !=
                                                  value
                                              ? 'Passwords do not match'
                                              : null;
                                    });
                                  }
                                },
                              ),
                              const SizedBox(height: 16),

                              // Confirm Password
                              TextFormField(
                                controller: _confirmPasswordController,
                                focusNode: _confirmPasswordFocus,
                                obscureText: _obscureConfirmPassword,
                                decoration: InputDecoration(
                                  hintText: 'Confirm Password *',
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  prefixIcon: const Icon(
                                    Icons.lock_outline,
                                    color: Colors.grey,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword;
                                      });
                                    },
                                  ),
                                  errorText: _confirmPasswordError,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _confirmPasswordError =
                                        value != _passwordController.text
                                            ? 'Passwords do not match'
                                            : null;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),

                              // Full Name
                              TextFormField(
                                controller: _fullNameController,
                                focusNode: _fullNameFocus,
                                decoration: InputDecoration(
                                  hintText: 'Full Name *',
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  prefixIcon: const Icon(
                                    Icons.person,
                                    color: Colors.grey,
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
                              const SizedBox(height: 16),

                              // Date of Birth - Button to show date picker
                              GestureDetector(
                                onTap: () => _selectDate(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        _dateOfBirthError != null
                                            ? Border.all(color: Colors.red)
                                            : null,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        _selectedDate == null
                                            ? 'Date of Birth'
                                            : DateFormat(
                                              'MMM dd, yyyy',
                                            ).format(_selectedDate!),
                                        style: TextStyle(
                                          color:
                                              _selectedDate == null
                                                  ? Colors.grey[600]
                                                  : Colors.black87,
                                          fontSize: 16,
                                        ),
                                      ),
                                      if (_dateOfBirthError != null)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8.0,
                                            left: 16.0,
                                          ),
                                          child: Text(
                                            _dateOfBirthError!,
                                            style: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Gender Dropdown
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      _genderError != null
                                          ? Border.all(color: Colors.red)
                                          : null,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.person_outline,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          hint: const Text('Select Gender *'),
                                          value: _selectedGender,
                                          isExpanded: true,
                                          icon: const Icon(
                                            Icons.arrow_drop_down,
                                          ),
                                          items:
                                              _genderOptions.map((
                                                String gender,
                                              ) {
                                                return DropdownMenuItem<String>(
                                                  value: gender,
                                                  child: Text(gender),
                                                );
                                              }).toList(),
                                          onTap: () {
                                            setState(() {
                                              _isSelectingGender = true;
                                            });
                                            _handleFocusChange();
                                          },
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              _selectedGender = newValue;
                                              _isSelectingGender = false;
                                              _genderError = null;
                                            });
                                            _handleFocusChange();
                                          },
                                        ),
                                      ),
                                    ),
                                    if (_genderError != null)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8.0,
                                          left: 16.0,
                                        ),
                                        child: Text(
                                          _genderError!,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Phone Number
                              TextFormField(
                                controller: _phoneNumberController,
                                focusNode: _phoneNumberFocus,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  hintText: 'Phone Number',
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  prefixIcon: const Icon(
                                    Icons.phone,
                                    color: Colors.grey,
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
                            ],
                          ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Register Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () async {
                      if (_validateForm()) {
                        try {
                          var user = UserRegisterModel(
                            _fullNameController.text,
                            _emailController.text,
                            _passwordController.text,
                            _confirmPasswordController.text,
                            _selectedDate!,
                            _selectedGender.toString(),
                            _phoneNumberController.text,
                          );
                          final result = await authUseCase.register(user);
                          if (result.isSuccess) {
                            // Show success toast/snackbar
                            Notify.showFlushbar( "Registration successful!", isError: false);
                          } else {
                            // Show error toast/snackbar with result.error
                            Notify.showFlushbar( "Registration fail!", isError: true);
                          }
                        } catch (e) {
                          // Show error message with flushbar
                          Notify.showFlushbar( "Error: $e", isError: true);
                        }
                      }
                    },
                    child: const Text(
                      'REGISTER',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 5),

                  // Sign in option
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Already have an account?",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'SIGN IN',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.arrow_right_alt,
                          size: 28,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
