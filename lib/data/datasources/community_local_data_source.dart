import 'package:aastu_map/data/models/club_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityLocalDataSource {
  final FirebaseFirestore _firestore;

  CommunityLocalDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<ClubModel>> getAllCommunities() async {
    try {
      final communityCollection = await _firestore.collection('clubs').get();
      return communityCollection.docs.map((doc) {
        return ClubModel.fromSnapshot(doc);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> cacheCommunities(List<ClubModel> communities) async {
    // This method is no longer used with Firestore
  }

  Future<void> closeBox() async {
    // This method is no longer used with Firestore
  }
}
