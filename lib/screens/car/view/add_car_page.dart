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

String? downloadURL;

class AddCarPage extends StatefulWidget {
  const AddCarPage({super.key});

  @override
  State<AddCarPage> createState() => _AddCarPageState();
}

class _AddCarPageState extends State<AddCarPage>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _makeController,
      _modelController,
      _typeController,
      _colorController;

  final DatabaseService databaseService = DatabaseService();
  File? _image;
  ImagePicker picker = ImagePicker();
  String? fcmToken;

  @override
  void initState() {
    super.initState();
    _makeController = TextEditingController();
    _modelController = TextEditingController();
    _typeController = TextEditingController();
    _colorController = TextEditingController();
  }

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _typeController.dispose();
    _colorController.dispose();
    super.dispose();
  }

// Sign out from account functionj
  Future<void> signOutFromAccount(BuildContext context) async {
    try {
      const CircularProgressIndicator();
      await FirebaseAuth.instance.signOut().then((value) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Sign out Successfully'),
            duration: Duration(seconds: 1)));
      });
    } catch (e) {
      log(e.toString());
    }
  }

// Adding a car
  Future<void> addCar() async {
    try {
      if (_makeController.text.isNotEmpty &&
          _modelController.text.isNotEmpty &&
          _typeController.text.isNotEmpty &&
          _colorController.text.isNotEmpty) {
        final car = Car(
            make: _makeController.text,
            color: _colorController.text,
            model: int.parse(_modelController.text),
            type: _typeController.text);
        var inserted = await databaseService.addCar(car).then(
              (value) =>
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Data added successfully'),
                duration: Duration(seconds: 1),
              )),
            );
        log('Data inserted: $inserted');
      }
    } catch (e) {
      log(e.toString());
    }
  }

// Uploading an image from image picker
  Future<void> uploadImage(File? image) async {
    try {
      if (image != null) {
        final storageRef = FirebaseStorage.instance.ref();
        var ref = storageRef
            .child('Image/image${DateTime.now().millisecondsSinceEpoch}');
        var uploadTask = ref.putFile(image).snapshotEvents;
        uploadTask.listen(
          (event) async {
            switch (event.state) {
              case TaskState.running:
                log('Uploaded ${(event.bytesTransferred / event.totalBytes * 100).toStringAsFixed(0)}%');
                break;
              case TaskState.success:
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Image Uploaded Successfully'),
                  duration: Duration(seconds: 1),
                ));
                final downloadURL = await ref.getDownloadURL();
                await service.showNotification(downloadURL);
              default:
                log('default state of uploading image task');
            }
          },
        );
      }
    } catch (e) {
      log(e.toString());
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
              child: IconButton(
                onPressed: () async {
                  signOutFromAccount(context);
                },
                icon: const Icon(Icons.logout_rounded),
              ))
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
                  controller: _makeController,
                  decoration: InputDecoration(
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      helperText: 'Make',
                      hintText: 'Enter the make company',
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(15))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _modelController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      helperText: 'Model',
                      hintText: 'Enter the model',
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(15))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _typeController,
                  decoration: InputDecoration(
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      helperText: 'Type',
                      hintText: 'Enter the type',
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(15))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _colorController,
                  decoration: InputDecoration(
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      helperText: 'Color',
                      hintText: 'Enter the color',
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(15))),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              SizedBox(
                  width: 350,
                  height: 50,
                  child: TextButton(
                      style: ButtonStyle(
                          backgroundColor:
                              WidgetStatePropertyAll(Colors.purple.shade50)),
                      onPressed: addCar,
                      child: const Text('Add Car'))),
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
