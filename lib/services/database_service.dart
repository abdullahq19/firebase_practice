import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_practice/model/car_model.dart';

class DatabaseService {
  static DatabaseService? _instance;

  DatabaseService._();

  factory DatabaseService() => _instance ??= DatabaseService._();

  static const _carCollectionName = 'cars';

  final carCollection =
      FirebaseFirestore.instance.collection(_carCollectionName);

  Future<bool> addCar(Car car) async {
    try {
      await carCollection.doc().set(car.toMap());
    } catch (e) {
      return false;
    }
    return false;
  }

  Future<bool> deleteCar(String make) async {
    try {
      await carCollection.doc(make).delete();
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  Future<bool> updateCar(Car car) async {
    try {
      await carCollection.doc(car.make).update(car.toMap());
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  Future<List<Car>> getCars() async {
    var carCollections = await carCollection.get();
    var carList =
        carCollections.docs.map((e) => Car.fromMap(e.data())).toList();
    return carList;
  }
}
