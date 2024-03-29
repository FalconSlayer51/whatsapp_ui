import 'package:flutter/material.dart';
import 'package:whatsapp_ui/auth/screens/login_screen.dart';
import 'package:whatsapp_ui/colors.dart';
import 'package:whatsapp_ui/common/customButton.dart';
import '../../../common/customButton.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({Key? key}) : super(key: key);

  void navigateToLoginScreen(BuildContext context) {
    Navigator.pushNamed(context, LoginScreen.routName);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: 800,
            width: 600,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                const Text(
                  'Welcome to WhatsApp',
                  style: TextStyle(
                    fontSize: 33,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Poppins",
                  ),
                ),
                SizedBox(height: size.height / 9),
                Image.asset(
                  'assets/images/bg.png',
                  height: 340,
                  width: 340,
                  color: tabColor,
                ),
                SizedBox(height: size.height / 9),
                const Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Text(
                    'Read our Privacy Policy. Tap "Agree and continue" to accept the Terms of Service.',
                    style: TextStyle(color: Colors.grey, fontFamily: "Poppins"),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: size.width * 0.75,
                  child: CustomButton(
                    text: 'AGREE AND CONTINUE',
                    onPressed: () => navigateToLoginScreen(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
