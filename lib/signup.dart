import 'package:flutter/material.dart';
import 'package:flutter_application_1/login.dart';
//import 'package:flutter_session_jwt/flutter_session_jwt.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isNotValidate = false;
  bool error = false;
  String err = "";

  void registerUser() async {
    if (nameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty) {
      var regBody = {
        "name": nameController.text,
        "email": emailController.text,
        "password": passwordController.text
      };
      var response = await http.post(
          // use your own pc's ip adress or use 10.0.2.2 for emulators
          Uri.parse("http://192.168.1.70:3000/api/users/register"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(regBody));

      if (response.statusCode == 200) {
        //var jsonResponse = jsonDecode(response.body);
        String? authToken = response.headers["x-auth-token"];
        print("Token received: $authToken");
        if (!mounted) return; // ✅ Prevents error if widget is unmounted
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
        /* Navigator.push(
            context, MaterialPageRoute(builder: (context) => Login())); */
      } else {
        setState(() {
          error = true;
          err = response.body;
        });
        print("Error: ${response.body}");
      }
    } else {
      setState(() {
        _isNotValidate = true;
      });
    }
  }

  void opensignin() {
    Navigator.of(context).pushReplacementNamed('login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurpleAccent,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'SIGN UP',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 40,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                            border: InputBorder.none, hintText: 'name'),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                            border: InputBorder.none, hintText: 'email'),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                            border: InputBorder.none, hintText: 'password'),
                      ),
                    ),
                  ),
                ),
                error
                    ? Text(
                        err,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red),
                      )
                    : _isNotValidate
                        ? Text(
                            "enter valide data",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.red),
                          )
                        : SizedBox.shrink(),
                SizedBox(
                  height: 20,
                ),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(15)),
                      child: Center(
                        child: GestureDetector(
                          onTap: () => {registerUser()},
                          child: Text(
                            'Register',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurpleAccent),
                          ),
                        ),
                      ),
                    )),
                SizedBox(
                  height: 12,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'you have an account? ',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    GestureDetector(
                      onTap: opensignin,
                      child: Text(
                        'Sign in now',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.greenAccent),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
