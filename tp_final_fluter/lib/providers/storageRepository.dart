import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

/// Représente une image récupérée depuis Firebase Storage.
class StorageImage {
  final String name;
  final String path;
  final String downloadUrl;
  final int? sizeBytes;
  final DateTime? updatedAt;
  final String? contentType;

  const StorageImage({
    required this.name,
    required this.path,
    required this.downloadUrl,
    this.sizeBytes,
    this.updatedAt,
    this.contentType,
  });
}

class StorageService {
  final FirebaseStorage _storage;

  StorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  Future<String> uploadFile({
      required File file,
      required String path, // ex : image/{roomID}/{roundId}/{playerId}.jpeg
      String contentType = 'image/jpeg',
  })async {
    final ref = _storage.ref(path);
    await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
    return await ref.getDownloadURL();
  }

  /// Récupère l'URL de téléchargement d'une image à partir de son chemin exact.
  /// Ex: path = 'rooms/abc123/cover.jpg'
  Future<String> getImageUrl(String path) async {
    try {
      return await _storage.ref(path).getDownloadURL();
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        throw Exception('Image introuvable au chemin: $path');
      }
      throw Exception('Erreur Storage (${e.code}): ${e.message}');
    }
  }

  /// Liste toutes les images présentes dans un dossier (non récursif).
  /// Ex: folderPath = 'rooms/abc123'
  Future<List<StorageImage>> listImagesInFolder(String folderPath) async {
    try {
      final result = await _storage.ref(folderPath).listAll();

      // Récupère l'URL + métadonnées de chaque fichier en parallèle
      final images = await Future.wait(
        result.items.map((ref) async {
          final url = await ref.getDownloadURL();
          final metadata = await ref.getMetadata();

          return StorageImage(
            name: ref.name,
            path: ref.fullPath,
            downloadUrl: url,
            sizeBytes: metadata.size,
            updatedAt: metadata.updated,
            contentType: metadata.contentType,
          );
        }),
      );

      return images;
    } on FirebaseException catch (e) {
      throw Exception('Erreur lors du listing (${e.code}): ${e.message}');
    }
  }

  /// Liste uniquement les URLs (plus rapide si tu n'as pas besoin des métadonnées).
  Future<List<String>> listImageUrlsInFolder(String folderPath) async {
    try {
      final result = await _storage.ref(folderPath).listAll();
      return await Future.wait(result.items.map((ref) => ref.getDownloadURL()));
    } on FirebaseException catch (e) {
      throw Exception('Erreur lors du listing (${e.code}): ${e.message}');
    }
  }

  /// Récupère une image sous forme de bytes (utile pour cache local, traitement, etc.)
  /// maxSizeBytes protège contre le téléchargement de fichiers trop volumineux (défaut 10 Mo).
  Future<List<int>> getImageBytes(String path, {int maxSizeBytes = 10 * 1024 * 1024}) async {
    try {
      final data = await _storage.ref(path).getData(maxSizeBytes);
      if (data == null) {
        throw Exception('Aucune donnée retournée pour: $path');
      }
      return data;
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        throw Exception('Image introuvable au chemin: $path');
      }
      throw Exception('Erreur Storage (${e.code}): ${e.message}');
    }
  }

  /// Vérifie si une image existe à ce chemin sans lever d'exception.
  Future<bool> imageExists(String path) async {
    try {
      await _storage.ref(path).getMetadata();
      return true;
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') return false;
      rethrow;
    }
  }

  /// Supprime une image.
  Future<void> deleteImage(String path) async {
    try {
      await _storage.ref(path).delete();
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') return; // déjà supprimée, on ignore
      throw Exception('Erreur suppression (${e.code}): ${e.message}');
    }
  }
}