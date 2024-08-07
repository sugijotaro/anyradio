import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/radio.dart';

class RadioService {
  final CollectionReference _radioCollection =
      FirebaseFirestore.instance.collection('radios');

  Stream<List<Radio>> getRadios() {
    return _radioCollection
        .orderBy('uploadDate', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Radio.fromDocument(doc)).toList(),
        );
  }

  Future<Radio> getRadioById(String id) async {
    DocumentSnapshot doc = await _radioCollection.doc(id).get();
    return Radio.fromDocument(doc);
  }
}
