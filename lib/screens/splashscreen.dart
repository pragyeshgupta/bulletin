import 'package:flutter/material.dart';
import 'package:bulletin/screens/home.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  _navigateToHome() async{
    await Future.delayed(const Duration(milliseconds: 2000), (){});
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const Home()
      )
    );
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _navigateToHome();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bulletin-logo.png'),
        ),
      ),
    );
  }
}
