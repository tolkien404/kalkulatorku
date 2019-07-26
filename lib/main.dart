import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Kalkulator",
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

///Layout
class CalculatorLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark
        .copyWith(statusBarColor: Color.fromARGB(200, 225, 189, 51)));
    final mainState = MainState.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Kalkulator"),
        backgroundColor: Color.fromARGB(225, 225, 189, 51),
      ),
      body: Container(
        color: Color.fromARGB(225, 225, 189, 51),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: ClipPath(
                clipper: BottomWaveClipper(),
                child: Container(
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: EdgeInsets.all(10.0),
                          alignment: Alignment.centerRight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                mainState.inputValue ?? '0',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 48.0,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                child: Row(
                  children: <Widget>[
                    myButton(''),
                    myButton(''),
                    myButton('c'),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                child: Column(
                  mainAxisAlignment : MainAxisAlignment.start,
                  children: <Widget>[
                    myButton('789/'),
                    myButton('456x'),
                    myButton('123-'),
                    myButton('.0=+'),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget myButton(String name) {
    List<String> token = name.split("");
    return Expanded(
      child: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: token
              .map((e) => CalcButton(
                    keyvalue:
                        e == 'c' ? 'DEL' : e == '<' ? '' : e == '%' ? '' : e,
                  ))
              .toList(),
        ),
      ),
    );
  }
}

///Button Action
class CalcButton extends StatelessWidget {
  CalcButton({this.keyvalue});

  final String keyvalue;

  @override
  Widget build(BuildContext context) {
    final mainState = MainState.of(context);
    return Expanded(
      flex: 1,
      child: FlatButton(
        shape: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1.0,
          style: BorderStyle.solid,
        ),
        color: Colors.transparent,
        child: Text(
          keyvalue,
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 36.0,
            color: Colors.white,
            fontStyle: FontStyle.normal,
          ),
        ),
        onPressed: () {
          mainState.onPressed(keyvalue);
        },
      ),
    );
  }
}

///Onpressed Action
class _MainPageState extends State<MainPage> {
  String inputString = "";
  double prevValue;
  String value = "";
  String op = 'z';

  bool isNumber(String str) {
    if (str == null) {
      return true;
    }
    return double.parse(str, (e) => null) != null;
  }

  void onPressed(keyvalue) {
    switch (keyvalue) {
      case "DEL":
        op = null;
        prevValue = 0.0;
        value = "";
        setState(() => inputString = "");
        break;
      case ".":
      case "%":
      case "_":
      case "+/-":
        break;
      case "x":
      case "+":
      case "-":
      case "/":
        op = keyvalue;
        value = '';
        prevValue = double.parse(inputString);
        setState(() {
          inputString = inputString + keyvalue;
        });
        break;
      case "=":
        if (op != null) {
          setState(() {
            switch (op) {
              case "x":
                inputString =
                    (prevValue * double.parse(value)).toStringAsFixed(0);
                break;
              case "+":
                inputString =
                    (prevValue + double.parse(value)).toStringAsFixed(0);
                break;
              case "-":
                inputString =
                    (prevValue - double.parse(value)).toStringAsFixed(0);
                break;
              case "/":
                inputString =
                    (prevValue / double.parse(value)).toStringAsFixed(2);
                break;
            }
          });
          op = null;
          prevValue = double.parse(inputString);
          value = '';
          break;
        }
        break;
      default:
        if (isNumber(keyvalue)) {
          if (op != null) {
            setState(() => inputString = inputString + keyvalue);
            value = value + keyvalue;
          } else {
            setState(() => inputString = "" + keyvalue);
            op = 'z';
          }
        } else {
          onPressed(keyvalue);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainState(
      inputValue: inputString,
      prevValue: prevValue,
      value: value,
      op: op,
      onPressed: onPressed,
      child: CalculatorLayout(),
    );
  }
}

class MainState extends InheritedWidget {
  MainState({
    Key key,
    this.inputValue,
    this.prevValue,
    this.value,
    this.op,
    this.onPressed,
    Widget child,
  }) : super(key: key, child: child);

  final String inputValue;
  final double prevValue;
  final String value;
  final String op;
  final Function onPressed;

  static MainState of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(MainState);
  }

  @override
  bool updateShouldNotify(MainState oldWidget) {
    return inputValue != oldWidget.inputValue;
  }
}

///Layout Wave
class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = new Path();
    path.lineTo(0.0, size.height - 20);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 30.0);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint =
        Offset(size.width - (size.width / 3.25), size.height - 65);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height - 40);
    path.lineTo(size.width, 0.0);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
