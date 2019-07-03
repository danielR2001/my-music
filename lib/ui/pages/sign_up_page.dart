import 'package:flutter/material.dart';
import 'package:myapp/firebase/authentication.dart';
import 'package:myapp/firebase/database_manager.dart';
import 'package:myapp/global_variables/global_variables.dart';
import 'package:myapp/main.dart';
import 'package:myapp/models/user.dart';
import 'home_page.dart';
import 'root_page.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final formKey = GlobalKey<FormState>();
  final key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        FocusScope.of(context).requestFocus(FocusNode());
        final form = formKey.currentState;
        form.save();
        Navigator.pop(
          context,
          false,
        );
      },
      child: Scaffold(
        key: key,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xE4000000),
                GlobalVariables.pinkColor,
              ],
              begin: FractionalOffset.bottomRight,
              stops: [0.7, 1.0],
              end: FractionalOffset.topLeft,
            ),
          ),
          child: ListView(
            children: <Widget>[
              Padding(
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
                      FocusScope.of(context).requestFocus(FocusNode());
                      final form = formKey.currentState;
                      form.save();
                      Navigator.pop(
                        context,
                        false,
                      );
                    }),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 20,
                ),
                child: Text(
                  "Hello! Let`s sign up",
                  style: TextStyle(
                    fontSize: 25.0,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xff3b5998),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ListTile(
                    leading: Text(
                      "Sign up With FaceBook",
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Container(
                      width: 35.0,
                      height: 35.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          image: ExactAssetImage(
                            "assets/images/facebook_logo.png",
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ListTile(
                    leading: Text(
                      "Sign up With Google",
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Container(
                      width: 35.0,
                      height: 35.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          image: ExactAssetImage(
                            "assets/images/google_logo.png",
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white,
                          ),
                        ),
                        child: SizedBox()),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 60),
                    child: Text(
                      "or",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  Expanded(
                    child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white,
                          ),
                        ),
                        child: SizedBox()),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: <Widget>[
                      Theme(
                        data: ThemeData(
                          hintColor: Colors.white,
                        ),
                        child: TextFormField(
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          cursorColor: GlobalVariables.pinkColor,
                          decoration: InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                              ),
                            ),
                            labelText: "Email",
                            labelStyle: TextStyle(
                              color: GlobalVariables.pinkColor,
                              fontSize: 18,
                            ),
                          ),
                          onFieldSubmitted: (value) => print(value),
                          initialValue: signUpEmail != null ? signUpEmail : "",
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) =>
                              value.isEmpty ? 'Email can\'t be empty' : null,
                          onSaved: (value) => signUpEmail = value,
                        ),
                      ),
                      Theme(
                        data: ThemeData(
                          hintColor: Colors.white,
                        ),
                        child: TextFormField(
                          obscureText: true,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          cursorColor: GlobalVariables.pinkColor,
                          decoration: InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                              ),
                            ),
                            labelText: "Password",
                            labelStyle: TextStyle(
                              color: GlobalVariables.pinkColor,
                              fontSize: 18,
                            ),
                          ),
                          initialValue:
                              signUpPassword != null ? signUpPassword : "",
                          validator: (value) =>
                              value.isEmpty ? 'Password can\'t be empty' : null,
                          onSaved: (value) => signUpPassword = value,
                        ),
                      ),
                      Theme(
                        data: ThemeData(
                          hintColor: Colors.white,
                        ),
                        child: TextFormField(
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          cursorColor: GlobalVariables.pinkColor,
                          decoration: InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                              ),
                            ),
                            labelText: "User name",
                            labelStyle: TextStyle(
                              color: GlobalVariables.pinkColor,
                              fontSize: 18,
                            ),
                          ),
                          initialValue: userName != null ? userName : "",
                          validator: (value) => value.isEmpty
                              ? 'User name can\'t be empty'
                              : null,
                          onSaved: (value) => userName = value,
                        ),
                      ),
                      signInButtonOrVerify()
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void signInWithEmailAndPass() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      if (signUpPassword.length >= 6 && checkForValidEmail(signUpEmail)) {
        showLoadingBar();
        FirebaseAuthentication.signInWithEmail(signUpEmail, signUpPassword)
            .then(
          (user) {
            if (user != null) {
              setState(() {
                signIn = false;
              });
              Navigator.of(context, rootNavigator: true).pop('dialog');
              showAlertDialog();
            } else {
              Navigator.of(context, rootNavigator: true).pop('dialog');
              key.currentState.showSnackBar(
                SnackBar(
                  duration: Duration(seconds: 5),
                  content: Text("This email is already in use!"),
                ),
              );
            }
          },
        );
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

  bool checkForValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }

  Padding signInButtonOrVerify() {
    if (signIn) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
            signInWithEmailAndPass();
          },
          child: Container(
            alignment: Alignment.center,
            height: 60.0,
            decoration: BoxDecoration(
              color: GlobalVariables.pinkColor,
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
            tryToSignIn();
          },
          child: Container(
            alignment: Alignment.center,
            height: 60.0,
            decoration: BoxDecoration(
              color: GlobalVariables.pinkColor,
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

  void tryToSignIn() {
    showLoadingBar();
    FirebaseAuthentication.userReload().then(
      (isEmailVerified) {
        if (isEmailVerified) {
          FirebaseAuthentication.currentUser().then((user) {
            currentUser = User(userName, user.uid, true);
            FirebaseDatabaseManager.saveUser();
            Navigator.of(context, rootNavigator: true).pop('dialog');
            FirebaseDatabaseManager.syncUser(user.uid, false).then((a) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(),
                ),
              );
            });
          });
        } else {
          Navigator.of(context, rootNavigator: true).pop('dialog');
          key.currentState.showSnackBar(
            SnackBar(
              duration: Duration(seconds: 5),
              content: Text("Email isn't verified!"),
            ),
          );
        }
      },
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
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Center(
                    child: new SizedBox(
                      height: 50.0,
                      width: 50.0,
                      child: new CircularProgressIndicator(
                        value: null,
                        strokeWidth: 3.0,
                        valueColor: new AlwaysStoppedAnimation<Color>(
                            GlobalVariables.pinkColor),
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

  void showAlertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(
            "Hii " + userName + "!",
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
}
