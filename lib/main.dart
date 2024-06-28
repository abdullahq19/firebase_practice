import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_practice/sign_out_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth_practice/firebase_options.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      log('User Signed Out');
    } else {
      log('User is signed in!');
      log('User uId: ${user.uid}, Email: ${user.email ?? 'No Email'}');
    }
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool isPassHidden = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void showPassword() {
    setState(() {
      isPassHidden = !isPassHidden;
    });
  }

  Future<void> _signInWithEmailAndPassword(BuildContext context) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);

      _emailController.clear();
      _passwordController.clear();

      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const SignOutPage(),
      ));
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final credentials = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);

      await FirebaseAuth.instance.signInWithCredential(credentials);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SignOutPage(),
          ));
    } catch (e) {
      log('Google Sign In Exception: ${e.toString()}');
    }
  }

  Icon _visibilityIcon() {
    return isPassHidden
        ? const Icon(Icons.visibility)
        : const Icon(Icons.visibility_off);
  }

  @override
  Widget build(BuildContext context) {
    final Size(:width, :height) = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Firebase Authentication'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Align(
                widthFactor: 2.5,
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Sign In',
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: height * 0.1),
              SizedBox(
                width: width * 0.9,
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                      hintText: 'Email',
                      fillColor: Colors.grey.shade200,
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(width * 0.05))),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: height * 0.05),
                child: SizedBox(
                  width: width * 0.9,
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: isPassHidden,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                        hintText: 'Password',
                        fillColor: Colors.grey.shade200,
                        prefixIcon: const Icon(Icons.key),
                        suffix: GestureDetector(
                          onTap: showPassword,
                          child: _visibilityIcon(),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(width * 0.05))),
                  ),
                ),
              ),
              SizedBox(
                width: width * 0.8,
                child: FilledButton(
                    style: ButtonStyle(
                        padding: WidgetStatePropertyAll(
                            EdgeInsets.all(width * 0.03)),
                        backgroundColor:
                            WidgetStatePropertyAll(Colors.purple.shade100)),
                    onPressed: () async {
                      _signInWithEmailAndPassword(context);
                    },
                    child: Text(
                      'Sign In',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    )),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: height * 0.05),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                        padding: EdgeInsets.all(width * 0.05),
                        style: ButtonStyle(
                            elevation: const WidgetStatePropertyAll(2),
                            shadowColor:
                                const WidgetStatePropertyAll(Colors.black),
                            backgroundColor:
                                WidgetStatePropertyAll(Colors.grey.shade200)),
                        onPressed: () async {
                          _signInWithGoogle(context);
                        },
                        icon: const Icon(FontAwesomeIcons.google)),
                    IconButton(
                        padding: EdgeInsets.all(width * 0.05),
                        style: ButtonStyle(
                            elevation: const WidgetStatePropertyAll(2),
                            shadowColor:
                                const WidgetStatePropertyAll(Colors.black),
                            backgroundColor:
                                WidgetStatePropertyAll(Colors.grey.shade200)),
                        onPressed: () {},
                        icon: const Icon(FontAwesomeIcons.facebookF)),
                    IconButton(
                        padding: EdgeInsets.all(width * 0.05),
                        style: ButtonStyle(
                            elevation: const WidgetStatePropertyAll(2),
                            shadowColor:
                                const WidgetStatePropertyAll(Colors.black),
                            backgroundColor:
                                WidgetStatePropertyAll(Colors.grey.shade200)),
                        onPressed: () {},
                        icon: const Icon(FontAwesomeIcons.xTwitter)),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
