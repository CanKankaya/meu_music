import 'package:flutter/material.dart';
import 'package:meu_music/services/auth.dart';
import 'package:meu_music/widgets/custom_button.dart';
import 'package:meu_music/widgets/custom_form_field.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/';

  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  final _focusName = FocusNode();
  final _focusSurname = FocusNode();
  final _focusEmail = FocusNode();
  final _focusPhoneNumber = FocusNode();
  final _focusStudentId = FocusNode();
  final _focusPassword = FocusNode();

  var isLoading = false;
  var isRegister = false;
  var obscureText = true;

  @override
  void initState() {
    super.initState();

    _focusName.addListener(_onFocusChange);
    _focusSurname.addListener(_onFocusChange);
    _focusEmail.addListener(_onFocusChange);
    _focusPhoneNumber.addListener(_onFocusChange);
    _focusStudentId.addListener(_onFocusChange);
    _focusPassword.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusName.removeListener(_onFocusChange);
    _focusSurname.removeListener(_onFocusChange);
    _focusEmail.removeListener(_onFocusChange);
    _focusPhoneNumber.removeListener(_onFocusChange);
    _focusStudentId.removeListener(_onFocusChange);
    _focusPassword.removeListener(_onFocusChange);
    _focusName.dispose();
    _focusSurname.dispose();
    _focusEmail.dispose();
    _focusPhoneNumber.dispose();
    _focusStudentId.dispose();
    _focusPassword.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _focusName;
      _focusSurname;
      _focusEmail;
      _focusPhoneNumber;
      _focusStudentId;
      _focusPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login/Register Screen'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          children: [
            const SizedBox(height: 16),
            CustomFormField(
              focus: _focusEmail,
              hintText: 'Email',
              inputType: TextInputType.emailAddress,
              controller: _emailController,
            ),
            const SizedBox(height: 16),
            CustomFormField(
              focus: _focusPassword,
              hintText: 'Sifre',
              inputType: TextInputType.visiblePassword,
              controller: _passwordController,
              obscureText: obscureText,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    obscureText = !obscureText;
                  });
                },
                icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
              ),
            ),
            const SizedBox(height: 16),
            if (isRegister)
              Column(
                children: [
                  CustomFormField(
                    focus: _focusName,
                    hintText: 'Ad',
                    inputType: TextInputType.name,
                    controller: _nameController,
                  ),
                  const SizedBox(height: 16),
                  CustomFormField(
                    focus: _focusSurname,
                    hintText: 'Soyad',
                    inputType: TextInputType.name,
                    controller: _surnameController,
                  ),
                  const SizedBox(height: 16),
                  CustomFormField(
                    focus: _focusPhoneNumber,
                    hintText: 'Telefon Numarasi',
                    inputType: TextInputType.phone,
                    controller: _phoneNumberController,
                  ),
                  const SizedBox(height: 16),
                  CustomFormField(
                    focus: _focusStudentId,
                    hintText: 'Student ID',
                    inputType: TextInputType.number,
                    controller: _studentIdController,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            CustomButton(
              onPressed: isLoading
                  ? null
                  : isRegister
                      ? () async {
                          setState(() {
                            isLoading = true;
                          });
                          var result = await register(
                            _emailController.text,
                            _passwordController.text,
                            _nameController.text,
                            _surnameController.text,
                            _phoneNumberController.text,
                            _studentIdController.text,
                          );
                          if (result == null) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                            });
                          } else {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result),
                                ),
                              );
                            });
                          }
                          setState(() {
                            isLoading = false;
                          });
                        }
                      : () async {
                          setState(() {
                            isLoading = true;
                          });
                          var result = await login(
                            _emailController.text,
                            _passwordController.text,
                          );
                          if (result == null) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result ?? 'Login successful'),
                                ),
                              );
                            });
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                            });
                          } else {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result),
                                ),
                              );
                            });
                          }
                          setState(() {
                            isLoading = false;
                          });
                        },
              text: isRegister ? 'Register' : 'Login',
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: isLoading
                  ? () {}
                  : () async {
                      setState(() {
                        isRegister = !isRegister;
                      });
                    },
              child: Text(isRegister ? 'Already have an account? Login' : 'Register'),
            ),
          ],
        ),
      ),
    );
  }
}
