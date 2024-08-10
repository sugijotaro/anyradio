import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/radio.dart';

class RadioService {
  final CollectionReference _radiosCollection =
      FirebaseFirestore.instance.collection('radios');

  Stream<List<Radio>> getRadios() {
    return _radiosCollection
        .orderBy('uploadDate', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Radio.fromDocument(doc)).toList(),
        );
  }

  Future<Radio?> getRadioById(String id) async {
    final doc = await _radiosCollection.doc(id).get();
    if (doc.exists) {
      return Radio.fromDocument(doc);
    }
    return null;
  }

  Future<void> incrementPlayCount(String radioId) async {
    final docRef = _radiosCollection.doc(radioId);
    await docRef.update({
      'playCount': FieldValue.increment(1),
      'lastPlayed': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteRadio(String radioId) async {
    final docRef = _radiosCollection.doc(radioId);
    await docRef.delete();
  }
}
