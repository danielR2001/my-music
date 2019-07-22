import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/database/authentication.dart';
import 'package:myapp/database/database_manager.dart';
import 'package:myapp/global_variables/global_variables.dart';
import 'package:myapp/ui/pages/root_page.dart';
import 'home_page.dart';

class LogInPage extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<LogInPage> {
  final formKey = GlobalKey<FormState>();
  static final key = GlobalKey<ScaffoldState>();

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
        return Future.value(false);
      },
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        key: key,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.deepPurple,
                GlobalVariables.pinkColor,
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
                  padding: const EdgeInsets.only(top: 80, right: 20, left: 20),
                  child: Column(
                    children: <Widget>[
                      Form(
                        key: formKey,
                        child: Column(
                          children: <Widget>[
                            drawEmailTextFiled(),
                            drawPasswordTextFiled(),
                            drawLoginButton(),
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
    );
  }

  //* widgets
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

  Widget drawEmailTextFiled() {
    return TextFormField(
      style: TextStyle(
        color: Colors.white,
        fontSize: 18,
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
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        errorStyle: TextStyle(
          color: GlobalVariables.pinkColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      keyboardType: TextInputType.emailAddress,
      initialValue: loginInEmail != null ? loginInEmail : "",
      validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
      onSaved: (value) => loginInEmail = value,
    );
  }

  Widget drawPasswordTextFiled() {
    return TextFormField(
      obscureText: true,
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
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
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        errorStyle: TextStyle(
          color: GlobalVariables.pinkColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      initialValue: loginInPassword != null ? loginInPassword : "",
      validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
      onSaved: (value) => loginInPassword = value,
    );
  }

  Widget drawLoginButton() {
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

  //*methods
  void signInWithEmailAndPass() {
    final form = formKey.currentState;
    if (form.validate()) {
      showLoadingBar();
      form.save();
      FirebaseAuthentication.logInWithEmail(loginInEmail, loginInPassword)
          .then((user) {
        if (user != null) {
          FirebaseDatabaseManager.syncUser(user.uid).then((user) {
            if (user != null) {
              GlobalVariables.currentUser = user;
              GlobalVariables.manageLocalSongs
                  .checkIfStoragePermissionGranted()
                  .then((permissionGranted) {
                GlobalVariables.manageLocalSongs.initDirs().then((a) {
                  GlobalVariables.manageLocalSongs.syncDownloaded();
                  Navigator.of(context, rootNavigator: true).pop('dialog');
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(),
                      ));
                });
              });
            } else {
              Navigator.of(context, rootNavigator: true).pop('dialog');
              key.currentState.showSnackBar(
                SnackBar(
                  duration: Duration(seconds: 10),
                  content: Text(
                      "You didn't verify your email account! So go verify your email and then click the continue button in the sign up page."),
                ),
              );
            }
          });
        } else {
          Navigator.of(context, rootNavigator: true).pop('dialog');
          key.currentState.showSnackBar(
            SnackBar(
              duration: Duration(seconds: 5),
              content: Text("Email or password is incorrect!"),
            ),
          );
        }
      });
    }
  }

  bool checkForValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
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
}
