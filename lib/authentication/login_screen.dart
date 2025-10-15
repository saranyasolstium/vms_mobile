import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../decoration/buttons.dart';
import '../decoration/text_fields.dart';
import '../provider/auth_provider.dart';
import '../utilities/color.dart';
import '../utilities/fonts.dart';
import '../utilities/loaders.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController usernamecontrol = TextEditingController();
  TextEditingController passwordcontrol = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: CColors.dark,
      body: Stack(
        children: [
          SizedBox(
            height: 300,
            width: MediaQuery.of(context).size.width,
            child: Image.asset(
              "assets/images/loginbg.png",
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(
            height: size.height,
            width: size.width,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  topImage(),
                  const SizedBox(height: 12),
                  fields(),
                  designedBy(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget topImage() => SizedBox(
        height: 251,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              SizedBox(
                height: 125,
                width: 125,
                child: Image.asset("assets/images/logo.png"),
              ),
              textHeading("Login"),
              textSideHeading("To your account"),
            ],
          ),
        ),
      );

  Widget fields() => SizedBox(
        height: 347,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              const SizedBox(height: 38),
              authField("User Name", usernamecontrol, 50, TextInputType.text,
                  TextCapitalization.none),
              authFieldPass("Password", passwordcontrol, true),
              Consumer<AuthProvider>(builder: (_, provd, __) {
                return provd.authLoading
                    ? loading50Button()
                    : buttonPrimary(
                        "Login",
                        () => Provider.of<AuthProvider>(context, listen: false)
                            .login(context, usernamecontrol.text,
                                passwordcontrol.text, selected.toString()));
              }),
            ],
          ),
        ),
      );
  var selected;

  Widget designedBy() => SizedBox(
        height: 124,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            textDesc('Designed by'),
            const SizedBox(width: 12),
            textLink("Solstium")
          ],
        ),
      );
}
