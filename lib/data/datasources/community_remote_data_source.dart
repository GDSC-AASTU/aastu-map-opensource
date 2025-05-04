import 'package:aastu_map/data/models/club_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityRemoteDataSource {
  final FirebaseFirestore _firestore;

  CommunityRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<ClubModel>> getAllCommunities() async {
    try {
      final communityCollection =
          await _firestore.collection('communities').get();
      return communityCollection.docs.map((doc) {
        return ClubModel.fromSnapshot(doc);
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
