/// Firestore Database Service
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/logger.dart';

/// Firestore Service
///
/// Provides basic CRUD operations for Firestore collections
/// This service acts as a thin wrapper around Firestore
/// and is used by Repository classes
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _log = Log.get('FirestoreService');

  /// Get Firestore instance
  FirebaseFirestore get firestore => _firestore;

  /// Set document (create or replace)
  Future<void> setDocument(
    String collection,
    String docId,
    Map<String, dynamic> data, {
    bool merge = false,
  }) async {
    try {
      _log.debug('Setting document: $collection/$docId');

      await _firestore
          .collection(collection)
          .doc(docId)
          .set(data, SetOptions(merge: merge));

      _log.debug('Document set successfully');
    } catch (e) {
      _log.error('Failed to set document: $collection/$docId', e);
      rethrow;
    }
  }

  /// Update document (partial update)
  Future<void> updateDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    try {
      _log.debug('Updating document: $collection/$docId');

      await _firestore.collection(collection).doc(docId).update(data);

      _log.debug('Document updated successfully');
    } catch (e) {
      _log.error('Failed to update document: $collection/$docId', e);
      rethrow;
    }
  }

  /// Get document
  Future<Map<String, dynamic>?> getDocument(
    String collection,
    String docId,
  ) async {
    try {
      _log.debug('Getting document: $collection/$docId');

      final doc = await _firestore.collection(collection).doc(docId).get();

      if (!doc.exists) {
        _log.debug('Document not found');
        return null;
      }

      return doc.data();
    } catch (e) {
      _log.error('Failed to get document: $collection/$docId', e);
      rethrow;
    }
  }

  /// Delete document
  Future<void> deleteDocument(
    String collection,
    String docId,
  ) async {
    try {
      _log.debug('Deleting document: $collection/$docId');

      await _firestore.collection(collection).doc(docId).delete();

      _log.debug('Document deleted successfully');
    } catch (e) {
      _log.error('Failed to delete document: $collection/$docId', e);
      rethrow;
    }
  }

  /// Watch document (real-time updates)
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchDocument(
    String collection,
    String docId,
  ) {
    _log.debug('Watching document: $collection/$docId');

    return _firestore.collection(collection).doc(docId).snapshots();
  }

  /// Get collection (returns QueryDocumentSnapshot for ID access)
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getCollectionDocs(
    String collection, {
    Query<Map<String, dynamic>>? Function(CollectionReference<Map<String, dynamic>>)? queryBuilder,
  }) async {
    try {
      _log.debug('Getting collection: $collection');

      CollectionReference<Map<String, dynamic>> ref = _firestore.collection(collection);

      Query<Map<String, dynamic>> query = queryBuilder?.call(ref) ?? ref;

      final snapshot = await query.get();

      return snapshot.docs;
    } catch (e) {
      _log.error('Failed to get collection: $collection', e);
      rethrow;
    }
  }

  /// Get collection (legacy - returns data with ID embedded)
  Future<List<Map<String, dynamic>>> getCollection(
    String collection, {
    Query<Map<String, dynamic>>? Function(CollectionReference<Map<String, dynamic>>)? queryBuilder,
  }) async {
    try {
      _log.debug('Getting collection: $collection');

      CollectionReference<Map<String, dynamic>> ref = _firestore.collection(collection);

      Query<Map<String, dynamic>> query = queryBuilder?.call(ref) ?? ref;

      final snapshot = await query.get();

      // Include document ID in the data
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Add ID to data
        return data;
      }).toList();
    } catch (e) {
      _log.error('Failed to get collection: $collection', e);
      rethrow;
    }
  }

  /// Watch collection (real-time updates)
  Stream<QuerySnapshot<Map<String, dynamic>>> watchCollection(
    String collection, {
    Query<Map<String, dynamic>>? Function(CollectionReference<Map<String, dynamic>>)? queryBuilder,
  }) {
    _log.debug('Watching collection: $collection');

    CollectionReference<Map<String, dynamic>> ref = _firestore.collection(collection);

    Query<Map<String, dynamic>> query = queryBuilder?.call(ref) ?? ref;

    return query.snapshots();
  }

  /// Run transaction
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) updateFunction,
  ) async {
    try {
      _log.debug('Running transaction');

      return await _firestore.runTransaction(updateFunction);
    } catch (e) {
      _log.error('Transaction failed', e);
      rethrow;
    }
  }

  /// Batch write
  WriteBatch batch() {
    _log.debug('Creating batch');
    return _firestore.batch();
  }

  /// Commit batch
  Future<void> commitBatch(WriteBatch batch) async {
    try {
      _log.debug('Committing batch');

      await batch.commit();

      _log.debug('Batch committed successfully');
    } catch (e) {
      _log.error('Batch commit failed', e);
      rethrow;
    }
  }

  /// Query builder helpers

  /// Where equals
  Query<Map<String, dynamic>> whereEquals(
    Query<Map<String, dynamic>> query,
    String field,
    dynamic value,
  ) {
    return query.where(field, isEqualTo: value);
  }

  /// Where in
  Query<Map<String, dynamic>> whereIn(
    Query<Map<String, dynamic>> query,
    String field,
    List<dynamic> values,
  ) {
    return query.where(field, whereIn: values);
  }

  /// Where array contains
  Query<Map<String, dynamic>> whereArrayContains(
    Query<Map<String, dynamic>> query,
    String field,
    dynamic value,
  ) {
    return query.where(field, arrayContains: value);
  }

  /// Order by
  Query<Map<String, dynamic>> orderBy(
    Query<Map<String, dynamic>> query,
    String field, {
    bool descending = false,
  }) {
    return query.orderBy(field, descending: descending);
  }

  /// Limit
  Query<Map<String, dynamic>> limit(
    Query<Map<String, dynamic>> query,
    int count,
  ) {
    return query.limit(count);
  }

  /// Where greater than
  Query<Map<String, dynamic>> whereGreaterThan(
    Query<Map<String, dynamic>> query,
    String field,
    dynamic value,
  ) {
    return query.where(field, isGreaterThan: value);
  }

  /// Where less than
  Query<Map<String, dynamic>> whereLessThan(
    Query<Map<String, dynamic>> query,
    String field,
    dynamic value,
  ) {
    return query.where(field, isLessThan: value);
  }

  /// Where greater than or equal
  Query<Map<String, dynamic>> whereGreaterThanOrEqual(
    Query<Map<String, dynamic>> query,
    String field,
    dynamic value,
  ) {
    return query.where(field, isGreaterThanOrEqualTo: value);
  }

  /// Where less than or equal
  Query<Map<String, dynamic>> whereLessThanOrEqual(
    Query<Map<String, dynamic>> query,
    String field,
    dynamic value,
  ) {
    return query.where(field, isLessThanOrEqualTo: value);
  }
}
