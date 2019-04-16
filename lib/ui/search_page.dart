import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController textEditingController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new Container(
        alignment: Alignment.centerLeft,
        color: Color(0xFA000000),
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                top: 20,
                right: 20,
              ),
              child: Container(
                color: Colors.grey[850],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new IconButton(
                      iconSize: 20,
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Flexible(
                      child: Container(
                        decoration: BoxDecoration(),
                        child: new TextField(
                          controller: textEditingController,
                          autofocus: true,
                          obscureText: false,
                          style: new TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          cursorColor: Colors.pink,
                          decoration: new InputDecoration.collapsed(
                            hintText: "Search",
                            hintStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                            filled: true,
                            fillColor: Color(0xE400000),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Container(
            //   decoration: BoxDecoration(
            //     color: Colors.grey[850],
            //   ),
            //   child: new TextField(
            //     obscureText: false,
            //     style: new TextStyle(
            //       color: Colors.white,
            //     ),
            //     cursorColor: Colors.pink,
            //     decoration: new InputDecoration(
            //       filled: true,
            //       fillColor: Color(0xE400000),
            //       focusedBorder: OutlineInputBorder(
            //         borderRadius: BorderRadius.circular(30.0),
            //         borderSide: BorderSide(
            //           color: Colors.transparent,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),

            // new IconButton(
            //   icon: Icon(
            //     Icons.arrow_back_ios,
            //     color: Colors.white,
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}
