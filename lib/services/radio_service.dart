import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/radio.dart';

class RadioService {
  final CollectionReference radioCollection =
      FirebaseFirestore.instance.collection('radios');

  Future<void> addRadio(Radio radio) async {
    await radioCollection.doc(radio.id).set(radio.toMap());
  }

  Future<Radio> getRadioById(String id) async {
    DocumentSnapshot doc = await radioCollection.doc(id).get();
    return Radio.fromDocument(doc);
  }

  Stream<List<Radio>> getRadios() {
    return radioCollection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Radio.fromDocument(doc)).toList());
  }
}