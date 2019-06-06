import 'package:flutter/material.dart';
import 'package:myapp/firebase/authentication.dart';
import 'package:myapp/firebase/database_manager.dart';
import 'home_page.dart';

class LogInPage extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<LogInPage> {
  String _email;
  String _password;
  final formKey = GlobalKey<FormState>();
  static final key = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xE4000000),
              Colors.pink,
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
                onPressed: () => Navigator.pop(
                      context,
                      false,
                    ),
              ),
            ),
            Padding(
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
                    "Log In With FaceBook",
                    style: TextStyle(
                      fontSize: 20.0,
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
                    "Log In With Google",
                    style: TextStyle(
                      fontSize: 20.0,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 60),
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
                        cursorColor: Colors.pink,
                        decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                            ),
                          ),
                          labelText: "Email",
                          labelStyle: TextStyle(
                            color: Colors.pink,
                            fontSize: 18,
                          ),
                        ),
                        validator: (value) =>
                            value.isEmpty ? 'Email can\'t be empty' : null,
                        onSaved: (value) => _email = value,
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
                        cursorColor: Colors.pink,
                        decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                            ),
                          ),
                          labelText: "Password",
                          labelStyle: TextStyle(
                            color: Colors.pink,
                            fontSize: 18,
                          ),
                        ),
                        validator: (value) =>
                            value.isEmpty ? 'Password can\'t be empty' : null,
                        onSaved: (value) => _password = value,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 20),
                      child: GestureDetector(
                        onTap: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          signInWithEmailAndPass(key);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 60.0,
                          decoration: BoxDecoration(
                            color: Colors.pink,
                            borderRadius: BorderRadius.circular(40.0),
                          ),
                          child: Text(
                            "Log In",
                            style: TextStyle(
                              fontSize: 20.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void signInWithEmailAndPass(final key) {
    showLoadingBar();
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      FirebaseAuthentication.logInWithEmail(_email, _password).then((user) {
        if (user != null) {
          FirebaseDatabaseManager.syncUser(user.uid).then((a) {
            Navigator.of(context, rootNavigator: true).pop('dialog');
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(),
                ));
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
                        valueColor:
                            new AlwaysStoppedAnimation<Color>(Colors.pink),
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
