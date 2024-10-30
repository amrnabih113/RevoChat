import 'package:animation/UI/widgets/myicon.dart';
import 'package:animation/UI/widgets/mybutton.dart';
import 'package:animation/UI/widgets/mytextfield.dart';
import 'package:animation/bussiness_logic/bloc/auth_bloc.dart';
import 'package:animation/constants/colors.dart';
import 'package:animation/constants/functions.dart';
import 'package:animation/constants/strings.dart';
import 'package:animation/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            height: MediaQuery.sizeOf(context).height,
            width: MediaQuery.sizeOf(context).width,
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 50,
                ),
                Assets.images.logo.image(height: 100, width: 100),
                const SizedBox(
                  height: 40,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome Back,",
                        textAlign: TextAlign.start,
                        style: ConstantFuncs().mainTextStyle(),
                      ),
                      Text(
                        "Good to see you again.",
                        textAlign: TextAlign.start,
                        style: ConstantFuncs().secondaryTextStyle(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                MyTextField(
                  controller: _emailController,
                  isPassword: false,
                  hint: "Enter your Email",
                  icon: Icons.email_outlined,
                  label: "Email",
                  validator: ConstantFuncs().validateEmail,
                ),
                const SizedBox(height: 25),
                MyTextField(
                  controller: _passwordController,
                  isPassword: true,
                  hint: "Enter your Password",
                  icon: Icons.lock_outline_rounded,
                  label: "Password",
                  validator: ConstantFuncs().validatePassword,
                ),
                const SizedBox(height: 30),
                BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthLoggedIn) {
                      Navigator.pushReplacementNamed(context, homepage,arguments: state.user);
                    } else if (state is AuthFailure) {
                      ConstantFuncs()
                          .showErrorDialog(context, state.errorMassege);
                    }
                  },
                  builder: (context, state) {
                    return MyButton(
                      child: state is AuthLoading
                          ? const CircularProgressIndicator(color: white)
                          : const Text(
                              "Log In",
                              style: TextStyle(color: black, fontSize: 20),
                            ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          BlocProvider.of<AuthBloc>(context).add(LogInRequist(
                            _emailController.text,
                            _passwordController.text,
                          ));
                        }
                      },
                    );
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "- - Or sign in with - -",
                  textAlign: TextAlign.center,
                  style: ConstantFuncs().secondaryTextStyle(),
                ),
                const SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyIcon(
                        imageurl: "assets/images/google_logo.png",
                        onTap: () => BlocProvider.of<AuthBloc>(context)
                            .add(GoogleLoginRequest())),
                    MyIcon(
                      imageurl: "assets/images/facebook_logo.png",
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
