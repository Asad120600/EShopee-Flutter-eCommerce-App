import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app_flutter/models/Address.dart';
import 'package:e_commerce_app_flutter/services/authentification/authentification_service.dart';

class UserDatabaseHelper {
  static const String NEW_ADDRESS_ADDED_SUCCESSFULLY =
      "New address added successfully";
  static const String ADDRESS_DELETED_SUCCESSFULLY =
      "Address deleted successfully";
  static const String ADDRESS_UPDATED_SUCCESSFULLY =
      "Address updated successfully";

  static const String USERS_COLLECTION_NAME = "users";
  static const String ADDRESSES_COLLECTION_NAME = "addresses";
  UserDatabaseHelper._privateConstructor();
  static UserDatabaseHelper _instance =
      UserDatabaseHelper._privateConstructor();
  factory UserDatabaseHelper() {
    return _instance;
  }
  FirebaseFirestore _firebaseFirestore;
  FirebaseFirestore get firestore {
    if (_firebaseFirestore == null) {
      _firebaseFirestore = FirebaseFirestore.instance;
    }
    return _firebaseFirestore;
  }

  Future<List> getAddressesListForCurrentUser() async {
    String uid = AuthentificationService().currentUser.uid;
    final snapshot = await firestore
        .collection(USERS_COLLECTION_NAME)
        .doc(uid)
        .collection(ADDRESSES_COLLECTION_NAME)
        .get();
    final List<Address> addresses =
        snapshot.docs.map((e) => Address.fromMap(e.data(), id: e.id)).toList();

    return addresses;
  }

  Future<String> addAddressForCurrentUser(Address address) async {
    String uid = AuthentificationService().currentUser.uid;

    try {
      final addressesCollectionReference = firestore
          .collection(USERS_COLLECTION_NAME)
          .doc(uid)
          .collection(ADDRESSES_COLLECTION_NAME);
      await addressesCollectionReference.add(address.toMap());
      return NEW_ADDRESS_ADDED_SUCCESSFULLY;
    } on Exception catch (e) {
      return e.toString();
    }
  }

  Future<String> deleteAddressForCurrentUser(String id) async {
    String uid = AuthentificationService().currentUser.uid;
    try {
      final addressDocReference = firestore
          .collection(USERS_COLLECTION_NAME)
          .doc(uid)
          .collection(ADDRESSES_COLLECTION_NAME)
          .doc(id);
      await addressDocReference.delete();
      return ADDRESS_DELETED_SUCCESSFULLY;
    } on Exception catch (e) {
      return e.toString();
    }
  }

  Future<String> updateAddressForCurrentUser(Address address) async {
    String uid = AuthentificationService().currentUser.uid;
    try {
      final addressDocReference = firestore
          .collection(USERS_COLLECTION_NAME)
          .doc(uid)
          .collection(ADDRESSES_COLLECTION_NAME)
          .doc(address.id);
      await addressDocReference.update(address.toMap());
      return ADDRESS_UPDATED_SUCCESSFULLY;
    } on Exception catch (e) {
      return e.toString();
    }
  }

  Stream<QuerySnapshot> get currentUserAddressesStream {
    String uid = AuthentificationService().currentUser.uid;
    return firestore
        .collection(USERS_COLLECTION_NAME)
        .doc(uid)
        .collection(ADDRESSES_COLLECTION_NAME)
        .snapshots();
  }
}