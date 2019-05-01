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
  final formKey = new GlobalKey<FormState>();
  static final key = new GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: key,
      body: Container(
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
            colors: [
              Color(0xE4000000),
              Colors.pink,
            ],
            begin: FractionalOffset.bottomRight,
            stops: [0.7, 1.0],
            end: FractionalOffset.topLeft,
          ),
        ),
        child: new ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                left: 10.0,
                top: 10.0,
              ),
              child: new IconButton(
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
              child: new Text(
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
                child: new ListTile(
                  leading: new Text(
                    "Log In With FaceBook",
                    style: new TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: new Container(
                    width: 35.0,
                    height: 35.0,
                    decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      image: new DecorationImage(
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
                child: new ListTile(
                  leading: new Text(
                    "Log In With Google",
                    style: new TextStyle(
                      fontSize: 20.0,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: new Container(
                    width: 35.0,
                    height: 35.0,
                    decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      image: new DecorationImage(
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
            new Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                        ),
                      ),
                      child: new SizedBox()),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 60),
                  child: new Text(
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
                      child: new SizedBox()),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: new Form(
                key: formKey,
                child: new Column(
                  children: <Widget>[
                    Theme(
                      data: new ThemeData(
                        hintColor: Colors.white,
                      ),
                      child: new TextFormField(
                        style: new TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        cursorColor: Colors.pink,
                        decoration: new InputDecoration(
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
                      data: new ThemeData(
                        hintColor: Colors.white,
                      ),
                      child: new TextFormField(
                        obscureText: true,
                        style: new TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        cursorColor: Colors.pink,
                        decoration: new InputDecoration(
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
                          FocusScope.of(context).requestFocus(new FocusNode());
                          // SystemChannels.textInput.invokeMethod('TextInput.hide');
                          signInWithEmailAndPass(key);
                        },
                        child: new Container(
                          alignment: Alignment.center,
                          height: 60.0,
                          decoration: new BoxDecoration(
                            color: Colors.pink,
                            borderRadius: new BorderRadius.circular(40.0),
                          ),
                          child: new Text(
                            "Log In",
                            style: new TextStyle(
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
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      FirebaseAuthentication.logInWithEmail(_email, _password).then((user) {
        if (user != null) {
          FirebaseDatabaseManager.syncUser(user.uid);
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(0),
              ));
        } else {
          key.currentState.showSnackBar(
            new SnackBar(
              duration: new Duration(seconds: 5),
              content: new Text("Email or password is incorrect!"),
            ),
          );
        }
      });
    }
  }

  bool checkForValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }
}
