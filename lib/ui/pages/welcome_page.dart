import 'package:flutter/material.dart';
import 'package:myapp/ui/decorations/app_icon.dart';
import 'sign_in_page.dart';
import 'log_in_page.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              "assets/images/sign_in_pic.png",
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                top: 120.0,
                bottom: 25,
              ),
              child: AppIcon(),
            ),
            Text(
              "My Music",
              style: TextStyle(
                fontSize: 40.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40.0,
                      vertical: 15.0,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LogInPage(),
                            ));
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
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40.0,
                      vertical: 15.0,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignInPage(),
                            ));
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: 60.0,
                        decoration: BoxDecoration(
                          color: Colors.pink,
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                        child: Text(
                          "Sign In",
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
