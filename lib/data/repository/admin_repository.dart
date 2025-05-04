import 'package:aastu_map/data/models/about_aastu_model.dart';
import 'package:aastu_map/data/models/club_model.dart';
import 'package:aastu_map/data/models/developer_model.dart';
import 'package:aastu_map/data/models/event_model.dart';
import 'package:aastu_map/data/models/place_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AdminRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AdminRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  // Club operations
  Future<List<ClubModel>> getClubs() async {
    try {
      final snapshot = await _firestore.collection('clubs').get();
      return snapshot.docs
          .map((doc) => ClubModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching clubs: $e');
      return [];
    }
  }

  Future<ClubModel?> getClub(String id) async {
    try {
      final doc = await _firestore.collection('clubs').doc(id).get();
      if (doc.exists) {
        return ClubModel.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching club: $e');
      return null;
    }
  }

  Future<bool> addClub(ClubModel club) async {
    try {
      await _firestore.collection('clubs').doc().set(club.toJson());
      return true;
    } catch (e) {
      debugPrint('Error adding club: $e');
      return false;
    }
  }

  Future<bool> updateClub(ClubModel club) async {
    try {
      await _firestore.collection('clubs').doc(club.id).update(club.toJson());
      return true;
    } catch (e) {
      debugPrint('Error updating club: $e');
      return false;
    }
  }

  Future<bool> deleteClub(String id) async {
    try {
      await _firestore.collection('clubs').doc(id).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting club: $e');
      return false;
    }
  }

  // Place operations
  Future<List<PlaceModel>> getPlaces() async {
    try {
      final snapshot = await _firestore.collection('places').get();
      return snapshot.docs
          .map((doc) => PlaceModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching places: $e');
      return [];
    }
  }

  Future<PlaceModel?> getPlace(String id) async {
    try {
      final doc = await _firestore.collection('places').doc(id).get();
      if (doc.exists) {
        return PlaceModel.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching place: $e');
      return null;
    }
  }

  Future<bool> addPlace(PlaceModel place) async {
    try {
      await _firestore.collection('places').doc().set(place.toJson());
      return true;
    } catch (e) {
      debugPrint('Error adding place: $e');
      return false;
    }
  }

  Future<bool> updatePlace(PlaceModel place) async {
    try {
      await _firestore.collection('places').doc(place.id).update(place.toJson());
      return true;
    } catch (e) {
      debugPrint('Error updating place: $e');
      return false;
    }
  }

  Future<bool> deletePlace(String id) async {
    try {
      await _firestore.collection('places').doc(id).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting place: $e');
      return false;
    }
  }

  // Developer operations
  Future<List<DeveloperModel>> getDevelopers() async {
    try {
      final snapshot = await _firestore.collection('developers').get();
      return snapshot.docs
          .map((doc) => DeveloperModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching developers: $e');
      return [];
    }
  }

  Future<DeveloperModel?> getDeveloper(String id) async {
    try {
      final doc = await _firestore.collection('developers').doc(id).get();
      if (doc.exists) {
        return DeveloperModel.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching developer: $e');
      return null;
    }
  }

  Future<bool> addDeveloper(DeveloperModel developer) async {
    try {
      await _firestore.collection('developers').doc().set(developer.toJson());
      return true;
    } catch (e) {
      debugPrint('Error adding developer: $e');
      return false;
    }
  }

  Future<bool> updateDeveloper(DeveloperModel developer) async {
    try {
      await _firestore.collection('developers').doc(developer.id).update(developer.toJson());
      return true;
    } catch (e) {
      debugPrint('Error updating developer: $e');
      return false;
    }
  }

  Future<bool> deleteDeveloper(String id) async {
    try {
      await _firestore.collection('developers').doc(id).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting developer: $e');
      return false;
    }
  }

  // Event operations
  Future<List<EventModel>> getEvents() async {
    try {
      final snapshot = await _firestore.collection('events').get();
      return snapshot.docs
          .map((doc) => EventModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching events: $e');
      return [];
    }
  }

  Future<EventModel?> getEvent(String id) async {
    try {
      final doc = await _firestore.collection('events').doc(id).get();
      if (doc.exists) {
        return EventModel.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching event: $e');
      return null;
    }
  }

  Future<bool> addEvent(EventModel event) async {
    try {
      await _firestore.collection('events').doc().set(event.toJson());
      return true;
    } catch (e) {
      debugPrint('Error adding event: $e');
      return false;
    }
  }

  Future<bool> updateEvent(EventModel event) async {
    try {
      await _firestore.collection('events').doc(event.id).update(event.toJson());
      return true;
    } catch (e) {
      debugPrint('Error updating event: $e');
      return false;
    }
  }

  Future<bool> deleteEvent(String id) async {
    try {
      await _firestore.collection('events').doc(id).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting event: $e');
      return false;
    }
  }

  // About AASTU operations
  Future<List<AboutAastuModel>> getAboutAastuItems() async {
    try {
      final snapshot = await _firestore.collection('about_aastu').get();
      return snapshot.docs
          .map((doc) => AboutAastuModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching about AASTU items: $e');
      return [];
    }
  }

  Future<AboutAastuModel?> getAboutAastuItem(String id) async {
    try {
      final doc = await _firestore.collection('about_aastu').doc(id).get();
      if (doc.exists) {
        return AboutAastuModel.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching about AASTU item: $e');
      return null;
    }
  }

  Future<bool> addAboutAastuItem(AboutAastuModel item) async {
    try {
      await _firestore.collection('about_aastu').doc().set(item.toJson());
      return true;
    } catch (e) {
      debugPrint('Error adding about AASTU item: $e');
      return false;
    }
  }

  Future<bool> updateAboutAastuItem(AboutAastuModel item) async {
    try {
      await _firestore.collection('about_aastu').doc(item.id).update(item.toJson());
      return true;
    } catch (e) {
      debugPrint('Error updating about AASTU item: $e');
      return false;
    }
  }

  Future<bool> deleteAboutAastuItem(String id) async {
    try {
      await _firestore.collection('about_aastu').doc(id).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting about AASTU item: $e');
      return false;
    }
  }
} 