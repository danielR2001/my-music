import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/ui/custom_classes/custom_colors.dart';
import 'package:myapp/ui/pages/base_page.dart';
import 'package:myapp/core/view_models/page_models/sign_up_model.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final formKey = GlobalKey<FormState>();
  final key = GlobalKey<ScaffoldState>();
  bool signIn = true;

  @override
  Widget build(BuildContext context) {
    return BasePage<SignUpModel>(
      builder: (context, model, child) => WillPopScope(
        onWillPop: () {
          FocusScope.of(context).requestFocus(FocusNode());
          final form = formKey.currentState;
          form.save();
          Navigator.pop(
            context,
          );
          return Future.value(false);
        },
        child: Scaffold(
          key: key,
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
              child: ListView(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 10.0,
                              top: 10.0,
                            ),
                            child: drawBackButton(),
                          ),
                        ],
                      ),
                      drawLetsSignUp(),
                      Padding(
                        padding: const EdgeInsets.only(top: 80),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Form(
                                key: formKey,
                                child: Column(
                                  children: <Widget>[
                                    drawEmailTextFiled(model),
                                    drawPasswordTextFiled(model),
                                    drawNameTextFiled(model),
                                    signInOrVerifyButton(model)
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //* widgets
  Widget drawBackButton() {
    return IconButton(
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
      },
    );
  }

  Widget drawLetsSignUp() {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 0,
      ),
      child: Text(
        "Hello! Let`s sign up",
        style: TextStyle(
          fontSize: 25.0,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget drawEmailTextFiled(SignUpModel model) {
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
          fillColor: Colors.white),
      onFieldSubmitted: (value) => print(value),
      initialValue: model.email,
      keyboardType: TextInputType.emailAddress,
      validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
      onSaved: (value) => model.setEmail = value,
    );
  }

  Widget drawPasswordTextFiled(SignUpModel model) {
    return TextFormField(
      obscureText: true,
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
      initialValue: model.password,
      validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
      onSaved: (value) => model.setPassword = value,
    );
  }

  Widget drawNameTextFiled(SignUpModel model) {
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
        labelText: "User name",
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
      initialValue: model.userName,
      validator: (value) => value.isEmpty ? 'User name can\'t be empty' : null,
      onSaved: (value) => model.setUserName = value,
    );
  }

  Widget signInOrVerifyButton(SignUpModel model) {
    if (signIn) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
            signInWithEmailAndPass(model);
          },
          child: Container(
            alignment: Alignment.center,
            height: 60.0,
            decoration: BoxDecoration(
              color: CustomColors.pinkColor,
              borderRadius: BorderRadius.circular(40.0),
            ),
            child: Text(
              "Sign Up",
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: GestureDetector(
          onTap: () {
            checkIfVerified(model);
          },
          child: Container(
            alignment: Alignment.center,
            height: 60.0,
            decoration: BoxDecoration(
              color: CustomColors.pinkColor,
              borderRadius: BorderRadius.circular(40.0),
            ),
            child: Text(
              "Continue",
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

  void showAlertDialog(SignUpModel model) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(
            "Hii " + model.userName + "!",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Text(
                "Email verification was sent to you. Verify your email and then comeback and click the continue button to complete the sign up.",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
          backgroundColor: Colors.grey[850],
        );
      },
    );
  }

  //* core
  Future signInWithEmailAndPass(SignUpModel model) async {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      if (model.email.length >= 6 && checkForValidEmail(model.email, model)) {
        showLoadingBar();
        bool response = await model.signInWithEmail();
        if (response) {
          hideLoadingBar();
          setState(() {
            signIn = false;
          });
          showAlertDialog(model);
        } else {
          hideLoadingBar();
          key.currentState.showSnackBar(
            SnackBar(
              duration: Duration(seconds: 5),
              content: Text("This email is already in use!"),
            ),
          );
        }
      } else {
        key.currentState.showSnackBar(
          SnackBar(
            duration: Duration(seconds: 5),
            content: Text(
                "Email is not valid! Or password is shorter than 6 symbols"),
          ),
        );
      }
    }
  }

  Future<void> checkIfVerified(SignUpModel model) async {
    showLoadingBar();
    bool isEmailVerified = await model.checkIfVerified();
    if (isEmailVerified) {
      await model.signUp();
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
          content: Text("Email isn't verified!"),
        ),
      );
    }
  }

  bool checkForValidEmail(String email,SignUpModel model) {
    return model.checkForValidEmail(email);
  }
}
