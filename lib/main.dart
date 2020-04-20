import 'dart:async';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(home: LogoApp()));
}

class AnimatedLogo extends AnimatedWidget {
  static final _opacityTween = Tween<double>(begin: 0.1, end: 1);
  static final _sizeTween = Tween<double>(begin: 0, end: 300);

  AnimatedLogo({Key key, Animation<double> animation})
      : super(key: key, listenable: animation);

  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    return Center(
        child: Opacity(
            opacity: _opacityTween.evaluate(animation),
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              height: _sizeTween.evaluate(animation) * 2,
              width: _sizeTween.evaluate(animation) * 2,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/name.png'),
                  fit: BoxFit.fill,
                ),
                shape: BoxShape.circle,
              ),
            )));
  }
}

class LogoApp extends StatefulWidget {
  _LogoAppState createState() => _LogoAppState();
}

class _LogoAppState extends State<LogoApp> with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
    animation = CurvedAnimation(parent: controller, curve: Curves.easeIn)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      });
    controller.forward();
    Future.delayed(Duration(seconds: 3)).then((_) {
      Navigator.of(context).push(_createRoute('Menu'));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/Background.jpg"),
                fit: BoxFit.fill)),
        child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Hero(
              tag: "logo-image",
              child: AnimatedLogo(animation: animation),
            )));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

Route _createRoute(String routePage) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) {
      if (routePage == 'Menu') {
        return WebViewExample();
      } else {
        return SupportExample();
      }
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(0.0, 1.0);
      var end = Offset.zero;
      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

class Constants {
  static const String Support = 'Support Us';
  static const String Share = 'Share';
  static const AboutUs = 'About Us';
  static const Privacy = 'Privacy Policy';

  static List<Map<String, IconData>> choices = [
    {
      'Support Us': Icons.supervisor_account,
    },
    {
      'Share': Icons.share,
    },
    {
      'About Us': Icons.info,
    },
    {
      'Privacy Policy': Icons.verified_user,
    },
  ];
}

class ConstantsSupport {
  static const String Menu = 'Menu';
  static const String Share = 'Share';
  static const AboutUs = 'About Us';
  static const Privacy = 'Privacy Policy';

  static List<Map<String, IconData>> choices = [
    {
      'Menu': Icons.menu,
    },
    {
      'Share': Icons.share,
    },
    {
      'About Us': Icons.info,
    },
    {
      'Privacy Policy': Icons.verified_user,
    },
  ];
}

class WebViewExample extends StatefulWidget {
  WebViewExample({Key key}) : super(key: key);
  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  // final Completer<WebViewController> _controller =
  //     Completer<WebViewController>();
  WebViewController _controller;

  String _networkStatus = '';
  Connectivity connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> subscription;

  @override
  void initState() {
    super.initState();
    checkConnectivity();
  }

  Future<bool> _onWillPop() {
    return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Are you sure?'),
            content: Text('Do you want to exit an App'),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              FlatButton(
                onPressed: () => exit(0),
                /*Navigator.of(context).pop(true)*/
                child: Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void checkConnectivity() async {
    // Subscribe to the connectivity change
    subscription =
        connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      var conn = getConnectionValue(result);
      setState(() {
        _networkStatus = conn;
      });
    });
  }

  String getConnectionValue(var connectivityResult) {
    String status = '';
    switch (connectivityResult) {
      case ConnectivityResult.mobile:
        status = 'Mobile';
        break;
      case ConnectivityResult.wifi:
        status = 'Wi-Fi';
        break;
      case ConnectivityResult.none:
        status = 'None';
        break;
      default:
        status = 'None';
        break;
    }
    return status;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
            backgroundColor: Colors.blue,
            appBar: new AppBar(
              title: new Text('nCovLive'),
              elevation: 0.0,
              automaticallyImplyLeading: false,
              actions: <Widget>[
                PopupMenuButton<String>(
                  onSelected: choiceAction,
                  itemBuilder: (BuildContext context) {
                    return Constants.choices.map((Map<String, IconData> map) {
                      return PopupMenuItem<String>(
                        value: map.keys.first,
                        child: ListTile(
                            leading: Icon(map[map.keys.first]),
                            title: Text(map.keys.first)),
                      );
                    }).toList();
                  },
                )
              ],
            ),
            // We're using a Builder here so we have a context that is below the Scaffold
            // to allow calling Scaffold.of(context) so we can show a snackbar.
            body: Hero(
                tag: "logo-image",
                child: Container(
                    child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                      topLeft: Radius.circular(30)),
                  child: Builder(builder: (BuildContext context) {
                    if (_networkStatus != 'None') {
                      return WebView(
                        initialUrl: 'http://www.thecovid19tracker.live',
                        javascriptMode: JavascriptMode.unrestricted,
                        onWebViewCreated:
                            (WebViewController webViewController) {
                          _controller = webViewController;
                        },
                        javascriptChannels: <JavascriptChannel>[
                          _toasterJavascriptChannel(context),
                        ].toSet(),
                        onPageStarted: (String url) {
                          //print('Page started loading: $url');
                        },
                        onPageFinished: (String url) {
                          //print('Page finished loading: $url');
                        },
                        gestureNavigationEnabled: true,
                      );
                    } else {
                      return Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image:
                                    AssetImage("assets/images/noInternet.jpg"),
                                fit: BoxFit.fill)),
                      );
                    }
                  }),
                )))));
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }

  void choiceAction(String choice) {
    if (_networkStatus != 'None') {
      if (choice == Constants.Support) {
        Navigator.of(context).push(_createRoute('Support'));
      } else if (choice == Constants.Share) {
        share(context);
      } else if (choice == Constants.AboutUs) {
        DialogUtils.aboutUsDialog(context,
            title: "About Us",
            okBtnText: "Ok",
            okBtnFunction: () => Navigator.pop(
                context) /* call method in which you have write your logic and save process  */
            );
      } else if (choice == ConstantsSupport.Privacy) {
        DialogUtils.privacyDialog(context,
            title: "Privacy Policy",
            okBtnText: "Ok",
            okBtnFunction: () => Navigator.pop(
                context) /* call method in which you have write your logic and save process  */
            );
      }
    }
  }

  share(BuildContext context) {
    final RenderBox box = context.findRenderObject();

    Share.share("http://www.thecovid19tracker.live",
        subject: 'Visit to get information about Covid-19 Data',
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }
}

class SupportExample extends StatefulWidget {
  @override
  _SupportExampleState createState() => _SupportExampleState();
}

class _SupportExampleState extends State<SupportExample> {
  // final Completer<WebViewController> _controller =
  //     Completer<WebViewController>();
  WebViewController _controller;

  String _networkStatus = '';
  Connectivity connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> subscription;

  @override
  void initState() {
    super.initState();
    checkConnectivity();
  }

  Future<bool> _onWillPop() {
    return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Are you sure?'),
            content: Text('Do you want to exit an App'),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              FlatButton(
                onPressed: () => exit(0),
                /*Navigator.of(context).pop(true)*/
                child: Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void checkConnectivity() async {
    // Subscribe to the connectivity change
    subscription =
        connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      var conn = getConnectionValue(result);
      setState(() {
        _networkStatus = conn;
      });
    });
  }

  String getConnectionValue(var connectivityResult) {
    String status = '';
    switch (connectivityResult) {
      case ConnectivityResult.mobile:
        status = 'Mobile';
        break;
      case ConnectivityResult.wifi:
        status = 'Wi-Fi';
        break;
      case ConnectivityResult.none:
        status = 'None';
        break;
      default:
        status = 'None';
        break;
    }
    return status;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
            backgroundColor: Colors.blue,
            appBar: new AppBar(
              title: new Text('nCovLive'),
              elevation: 0.0,
              automaticallyImplyLeading: false,
              actions: <Widget>[
                PopupMenuButton<String>(
                  onSelected: choiceAction,
                  itemBuilder: (BuildContext context) {
                    return ConstantsSupport.choices
                        .map((Map<String, IconData> map) {
                      return PopupMenuItem<String>(
                        value: map.keys.first,
                        child: ListTile(
                          leading: Icon(map[map.keys.first]),
                          title: Text(map.keys.first),
                        ),
                      );
                    }).toList();
                  },
                )
              ],
            ),
            // We're using a Builder here so we have a context that is below the Scaffold
            // to allow calling Scaffold.of(context) so we can show a snackbar.
            body: Hero(
                tag: "logo-image",
                child: Container(
                    child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                      topLeft: Radius.circular(30)),
                  child: Builder(builder: (BuildContext context) {
                    if (_networkStatus != 'None') {
                      return WebView(
                        initialUrl: 'https://www.payunow.com/bandanasur?',
                        javascriptMode: JavascriptMode.unrestricted,
                        onWebViewCreated:
                            (WebViewController webViewController) {
                          _controller = webViewController;
                        },
                        javascriptChannels: <JavascriptChannel>[
                          _toasterJavascriptChannel(context),
                        ].toSet(),
                        onPageStarted: (String url) {
                          //print('Page started loading: $url');
                        },
                        onPageFinished: (String url) {
                          //print('Page finished loading: $url');
                        },
                        gestureNavigationEnabled: true,
                      );
                    } else {
                      return Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image:
                                    AssetImage("assets/images/noInternet.jpg"),
                                fit: BoxFit.fill)),
                      );
                    }
                  }),
                )))));
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }

  void choiceAction(String choice) {
    if (_networkStatus != 'None') {
      if (choice == ConstantsSupport.Menu) {
        Navigator.of(context).push(_createRoute('Menu'));
      } else if (choice == ConstantsSupport.Share) {
        share(context);
      } else if (choice == ConstantsSupport.AboutUs) {
        DialogUtils.aboutUsDialog(context,
            title: "About Us",
            okBtnText: "Ok",
            okBtnFunction: () => Navigator.pop(
                context) /* call method in which you have write your logic and save process  */
            );
      } else if (choice == ConstantsSupport.Privacy) {
        DialogUtils.privacyDialog(context,
            title: "Privacy Policy",
            okBtnText: "Ok",
            okBtnFunction: () => Navigator.pop(
                context) /* call method in which you have write your logic and save process  */
            );
      }
    }
  }

  share(BuildContext context) {
    final RenderBox box = context.findRenderObject();

    Share.share("https://www.payunow.com/bandanasur?",
        subject: 'Buy me a coffee.',
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }
}

class DialogUtils {
  static DialogUtils _instance = new DialogUtils.internal();

  DialogUtils.internal();

  factory DialogUtils() => _instance;

  static void aboutUsDialog(BuildContext context,
      {@required String title,
      String okBtnText = "Ok",
      String cancelBtnText = "Cancel",
      @required Function okBtnFunction}) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text(title, textAlign: TextAlign.center),
            content: Container(
              child: Column(
                children: <Widget>[
                  Center(
                    child: new RichText(
                      text: new TextSpan(
                        children: [
                          new TextSpan(
                            text: 'nCovLive app is powered by',
                            style: new TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          new TextSpan(
                            text: ' www.thecovid19tracker.live ',
                            style: new TextStyle(
                              fontWeight: FontWeight.bold,
                              decorationStyle: TextDecorationStyle.dashed,
                              color: Colors.blue,
                              decorationColor: Colors.redAccent,
                              fontStyle: FontStyle.italic,
                              fontSize: 18,
                            ),
                            recognizer: new TapGestureRecognizer()
                              ..onTap = () {
                                launch('http://www.thecovid19tracker.live/');
                              },
                          ),
                          new TextSpan(
                            text:
                                "and tracks the spread of the coronavirus (COVID-19) pandemic worldwide. The dedicated page for India offers a snapshot of the confirmed cases, deaths, cured patients and number of tests conducted till date. Also, it archives data daily (Historic Data) which is believed to be helpful for analysing data.",
                            style: new TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Center(
                      child: RichText(
                    textAlign: TextAlign.center,
                    text: new TextSpan(children: [
                      new TextSpan(
                        text: 'Developed by\n',
                        style: new TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black),
                      ),
                      new TextSpan(
                        text: ' Rajarshi Sur\nDebjoyti Louha\n',
                        style: new TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ]),
                  )),
                  SizedBox(height: 10),
                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: new TextSpan(
                        children: [
                          new TextSpan(
                              text: 'Version: v1.0.0\n',
                              style: new TextStyle(
                                  color: Colors.black, fontSize: 18)),
                          new TextSpan(
                            text: 'Made with ❤ in India',
                            style: new TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              Container(
                child: FlatButton(
                  child: Text(okBtnText),
                  onPressed: okBtnFunction,
                ),
              ),
            ],
          );
        });
  }

  static void privacyDialog(BuildContext context,
      {@required String title,
      String okBtnText = "Ok",
      String cancelBtnText = "Cancel",
      @required Function okBtnFunction}) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text(title, textAlign: TextAlign.center),
            content: Container(
                height: MediaQuery.of(context).size.height / 3,
                width: MediaQuery.of(context).size.width / 2,
                child: Center(
                  child: new RichText(
                    text: new TextSpan(
                      children: [
                        new TextSpan(
                          text:
                              "We don’t collect or store your data. We physically can't. We have nowhere to store it. We don't even have a server database to store it.",
                          style: new TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              foreground: Paint()
                                ..style = PaintingStyle.fill
                                ..strokeWidth = 2
                                ..color = Colors.black),
                        ),
                      ],
                    ),
                  ),
                )),
            actions: <Widget>[
              Container(
                child: FlatButton(
                  child: Text(okBtnText),
                  onPressed: okBtnFunction,
                ),
              ),
            ],
          );
        });
  }
}
