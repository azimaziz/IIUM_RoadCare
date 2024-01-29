import 'package:flutter/material.dart';
import 'package:roadcare/pages/login/login_page.dart';
import 'package:roadcare/pages/login/register.dart';

class loginOrRegisterPage extends StatefulWidget {
  const loginOrRegisterPage({super.key});

  @override
  State<loginOrRegisterPage> createState() => _loginOrRegisterPage();
}

class _loginOrRegisterPage extends State<loginOrRegisterPage> {
  bool showLoginPage = true;

  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return loginPage(
        onTap: togglePages,
      );
    } else {
      return registerPage(
        onTap: togglePages,
      );
    }
  }
}