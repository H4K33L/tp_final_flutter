import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final storageRepositoryProvider = Provider((ref) => StorageRepository(FirebaseStorage.instance));

class StorageRepository {
  final FirebaseStorage _storage;
  StorageRepository(this._storage);

  Future<String> uploadImageFromUrl({
    required String imageUrl,
    required String path, // ex: 'rooms/{roomId}/cover.jpg'
  }) async {
    // 1. Télécharger l'image depuis l'URL
    final response = await http.get(Uri.parse(imageUrl));

    if (response.statusCode != 200) {
      throw Exception('Impossible de télécharger l\'image (${response.statusCode})');
    }

    final bytes = response.bodyBytes;

    // 2. Détecter le content-type (fallback sur jpeg si absent)
    final contentType = response.headers['content-type'] ?? 'image/jpeg';

    // 3. Upload vers Firebase Storage
    final ref = _storage.ref().child(path);
    final uploadTask = await ref.putData(
      bytes,
      SettableMetadata(contentType: contentType),
    );

    // 4. Récupérer l'URL de téléchargement Firebase
    final downloadUrl = await uploadTask.ref.getDownloadURL();
    print("AAAAAAAAAAAAAAAAAAAAAAA");
    print(downloadUrl);
    return downloadUrl;
  }
}