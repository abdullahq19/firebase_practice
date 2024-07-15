import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_practice/services/notification_service.dart';
import 'package:firebase_auth_practice/sign_out_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth_practice/firebase_options.dart';
import 'package:google_sign_in/google_sign_in.dart';

final NotificationService service = NotificationService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
  await service.initialize();
  // await FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
  // FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      log('User Signed Out');
    } else {
      log('User is signed in!');
      log('User uId: ${user.uid}');
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
  late final TextEditingController _emailController,
      _passwordController,
      _phoneController,
      _smsCodeController;
  bool isPassHidden = true;
  String verID = '';

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _phoneController = TextEditingController();
    _smsCodeController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _smsCodeController.dispose();
    super.dispose();
  }

  // Hides/Unhides entered password in the textfield
  void showPassword() {
    setState(() {
      isPassHidden = !isPassHidden;
    });
  }

  // Sign in with any email and password without verification
  Future<void> _signInWithEmailAndPassword(BuildContext context) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);

      _emailController.clear();
      _passwordController.clear();

      if (context.mounted) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const SignOutPage(),
        ));
      }
    } catch (e) {
      log(e.toString());
    }
  }

  // Sign in with google
  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final credentials = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);

      final auth = FirebaseAuth.instance;
      await auth.signInWithCredential(credentials);
      log('Signed in through Google Account');
      if (context.mounted) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const SignOutPage(),
        ));
      }
      var fcmToken = await FirebaseMessaging.instance.getToken();
      log(fcmToken.toString());
    } catch (e) {
      log('Google Sign In Exception: ${e.toString()}');
    }
  }

  // Sign in as a anonymous user
  Future<void> _signInAnonymously(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInAnonymously().then(
          (value) => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Signed in as a guest'))));
      if (context.mounted) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const SignOutPage(),
        ));
      }
    } catch (e) {
      log(e.toString());
    }
  }

  // Function for sending code to device for phone verfication
  Future<void> _verifyPhoneNumber(BuildContext context) async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _phoneController.text.toString(),
        verificationCompleted: (phoneAuthCredential) async {
          await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);
          if (context.mounted) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const SignOutPage(),
            ));
          }
        },
        verificationFailed: (error) => log(error.toString()),
        codeSent: (verificationId, forceResendingToken) async {
          setState(() {
            verID = verificationId;
          });
        },
        codeAutoRetrievalTimeout: (verificationId) {},
      );
    } catch (e) {
      log(e.toString());
    }
  }

  // Sign in with phone number
  Future<void> _signInWithPhone(BuildContext context) async {
    try {
      PhoneAuthCredential phoneCredentials = PhoneAuthProvider.credential(
          verificationId: verID, smsCode: _smsCodeController.text);
      await FirebaseAuth.instance.signInWithCredential(phoneCredentials);
      log('User signed in through phone number');
      if (context.mounted) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const SignOutPage(),
        ));
      }
    } catch (e) {
      log(e.toString());
    }
  }

  // Provides visibility Icon for hide/unhide password
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
              const SizedBox(
                height: 30,
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
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                              title: const Text('Phone Number Verification'),
                              content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Enter Phone Number to verify'),
                                    SizedBox(
                                      width: 300,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 200,
                                            child: TextFormField(
                                              controller: _phoneController,
                                              keyboardType: TextInputType.phone,
                                              decoration: InputDecoration(
                                                  hintText: '+92 3001234786',
                                                  fillColor:
                                                      Colors.grey.shade200,
                                                  suffix:
                                                      const Icon(Icons.phone),
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              width * 0.05))),
                                            ),
                                          ),
                                          IconButton(
                                              onPressed: () async {
                                                _verifyPhoneNumber(context);
                                              },
                                              icon: const Icon(Icons.send))
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    SizedBox(
                                      width: 200,
                                      child: TextFormField(
                                        controller: _smsCodeController,
                                        keyboardType: TextInputType.phone,
                                        decoration: InputDecoration(
                                            hintText: 'SMS code',
                                            fillColor: Colors.grey.shade200,
                                            suffix: const Icon(
                                                Icons.verified_user_outlined),
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        width * 0.05))),
                                      ),
                                    ),
                                    SizedBox(
                                        width: 200,
                                        child: OutlinedButton(
                                            onPressed: () async {
                                              _signInWithPhone(context);
                                            },
                                            child: const Text('Sign In')))
                                  ]));
                        },
                      );
                    },
                    child: Text(
                      'Sign In with Number',
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
                    IconButton(
                        padding: EdgeInsets.all(width * 0.05),
                        style: ButtonStyle(
                            elevation: const WidgetStatePropertyAll(2),
                            shadowColor:
                                const WidgetStatePropertyAll(Colors.black),
                            backgroundColor:
                                WidgetStatePropertyAll(Colors.grey.shade200)),
                        onPressed: () async {
                          _signInAnonymously(context);
                        },
                        icon: const Icon(FontAwesomeIcons.userSecret)),
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
