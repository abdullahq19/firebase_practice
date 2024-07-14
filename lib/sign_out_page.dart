import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_practice/main.dart';
import 'package:firebase_auth_practice/model/car_model.dart';
import 'package:firebase_auth_practice/services/database_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';

class SignOutPage extends StatefulWidget {
  const SignOutPage({super.key});

  @override
  State<SignOutPage> createState() => _SignOutPageState();
}

class _SignOutPageState extends State<SignOutPage> {
  late final TextEditingController makeController,
      modelController,
      typeController,
      colorController;

  final DatabaseService databaseService = DatabaseService();
  File? _image;
  ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    makeController = TextEditingController();
    modelController = TextEditingController();
    typeController = TextEditingController();
    colorController = TextEditingController();
  }

  @override
  void dispose() {
    makeController.dispose();
    modelController.dispose();
    typeController.dispose();
    colorController.dispose();
    super.dispose();
  }

// Sign out from account function
  Future<void> signOutFromAccount(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      log(e.toString());
    }
  }

// ADDING A CAR
  Future<void> addCar() async {
    try {
      if (makeController.text.isNotEmpty &&
          modelController.text.isNotEmpty &&
          typeController.text.isNotEmpty &&
          colorController.text.isNotEmpty) {
        final car = Car(
            make: makeController.text,
            color: colorController.text,
            model: int.parse(modelController.text),
            type: typeController.text);
        var inserted = await databaseService.addCar(car).then(
              (value) => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data added successfully'))),
            );
        log('Data inserted: $inserted');
      }
    } catch (e) {
      log(e.toString());
    }
  }

// Uploading an image from image picker
  Future<void> uploadImage(File? image) async {
    if (image != null) {
      final storageRef = FirebaseStorage.instance.ref();
      var ref = storageRef
          .child('Image/image${DateTime.now().millisecondsSinceEpoch}');
      await ref.putFile(image);
    }
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        await service.requestPermission();
      },
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Out Page'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: ElevatedButton(
                onPressed: () async {
                  signOutFromAccount(context);
                },
                child: const Text('Sign Out')),
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: makeController,
                  decoration: const InputDecoration(
                      helperText: 'Make',
                      hintText: 'Enter the make company',
                      border: OutlineInputBorder()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: modelController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      helperText: 'Model',
                      hintText: 'Enter the model',
                      border: OutlineInputBorder()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: typeController,
                  decoration: const InputDecoration(
                      helperText: 'Type',
                      hintText: 'Enter the type',
                      border: OutlineInputBorder()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: colorController,
                  decoration: const InputDecoration(
                      helperText: 'Color',
                      hintText: 'Enter the color',
                      border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              SizedBox(
                  width: 350,
                  child: OutlinedButton(
                      onPressed: addCar, child: const Text('Add Car'))),
              const SizedBox(
                height: 30,
              ),
              GestureDetector(
                onTap: () async {
                  var pickedImage =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (pickedImage != null) {
                    _image = File(pickedImage.path);
                    log('Image picked');
                    uploadImage(_image);
                    log('Image Uploaded');
                  }
                },
                child: Container(
                  width: 300,
                  height: 70,
                  decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(15)),
                  child: const Icon(Icons.image),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
