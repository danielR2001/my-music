import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/ui/custom_classes/custom_colors.dart';
import 'package:myapp/ui/pages/base_page.dart';
import 'package:myapp/core/view_models/page_models/login_model.dart';

class LoginPage extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return BasePage<LoginModel>(
      builder: (context, model, child) => WillPopScope(
        onWillPop: () {
          FocusScope.of(context).requestFocus(FocusNode());
          final form = formKey.currentState;
          form.save();
          Navigator.pop(
            context,
            false,
          );
          return Future.value(false);
        },
        child: Scaffold(
          key: key,
          resizeToAvoidBottomPadding: false,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple,
                  CustomColors.pinkColor,
                ],
                begin: FractionalOffset.bottomRight,
                stops: [0.4, 1.0],
                end: FractionalOffset.topLeft,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      drawBackButton(),
                    ],
                  ),
                  drawWelcomeBack(),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 80, right: 20, left: 20),
                    child: Column(
                      children: <Widget>[
                        Form(
                          key: formKey,
                          child: Column(
                            children: <Widget>[
                              drawEmailTextFiled(model),
                              drawPasswordTextFiled(model),
                              drawLoginButton(model),
                            ],
                          ),
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

  //* ui
  Widget drawBackButton() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 10.0,
        top: 10.0,
      ),
      child: IconButton(
          alignment: Alignment.topLeft,
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            final form = formKey.currentState;
            form.save();
            if (MediaQuery.of(context).viewInsets.bottom != 0) {
              SystemChannels.textInput.invokeMethod('TextInput.hide').then((a) {
                Navigator.pop(
                  context,
                  false,
                );
              });
            } else {
              Navigator.pop(
                context,
                false,
              );
            }
          }),
    );
  }

  Widget drawWelcomeBack() {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 20,
      ),
      child: Text(
        "Welcome Back!",
        style: TextStyle(
          fontSize: 25.0,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget drawEmailTextFiled(LoginModel model) {
    return TextFormField(
      style: TextStyle(
        color: Colors.white,
        fontSize: 18,
      ),
      cursorColor: CustomColors.pinkColor,
      decoration: InputDecoration(
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white,
          ),
        ),
        labelText: "Email",
        labelStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        errorStyle: TextStyle(
          color: CustomColors.pinkColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      keyboardType: TextInputType.emailAddress,
      initialValue: model.password,
      validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
      onSaved: (value) => model.setEmail = value,
    );
  }

  Widget drawPasswordTextFiled(LoginModel model) {
    return TextFormField(
      obscureText: true,
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
      ),
      cursorColor: CustomColors.pinkColor,
      decoration: InputDecoration(
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white,
          ),
        ),
        labelText: "Password",
        labelStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        errorStyle: TextStyle(
          color: CustomColors.pinkColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      initialValue: model.email,
      validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
      onSaved: (value) => model.setPassword = value,
    );
  }

  Widget drawLoginButton(LoginModel model) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
          login(model);
        },
        child: Container(
          alignment: Alignment.center,
          height: 60.0,
          decoration: BoxDecoration(
            color: CustomColors.pinkColor,
            borderRadius: BorderRadius.circular(40.0),
          ),
          child: Text(
            "Log In",
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void showLoadingBar() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SimpleDialog(
          contentPadding: EdgeInsets.all(0.0),
          backgroundColor: Colors.transparent,
          children: <Widget>[
            Container(
              width: 60.0,
              height: 60.0,
              alignment: AlignmentDirectional.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: SizedBox(
                      height: 50.0,
                      width: 50.0,
                      child: CircularProgressIndicator(
                        value: null,
                        strokeWidth: 3.0,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            CustomColors.pinkColor),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }

  void hideLoadingBar() {
    Navigator.of(context, rootNavigator: true).pop('dialog');
  }

  //* core
  Future login(LoginModel model) async {
    bool response;
    final form = formKey.currentState;
    if (form.validate()) {
      showLoadingBar();
      form.save();
      FirebaseUser firebaseUser = await model.signInWithEmailAndPassword();
      if (firebaseUser != null) {
        response = await model.login(firebaseUser);
      } else {
        response = false;
      }
      if (response) {
        hideLoadingBar();
        Navigator.pushNamed(
          context,
          "/home",
        );
      } else {
        hideLoadingBar();
        key.currentState.showSnackBar(
          SnackBar(
            duration: Duration(seconds: 5),
            content: Text(
                "Email/password is incorrect! or you didn't verify your email"),
          ),
        );
      }
    }
  }

  bool checkForValidEmail(String email, LoginModel model) {
    return model.checkForValidEmail(email);
  }
}
