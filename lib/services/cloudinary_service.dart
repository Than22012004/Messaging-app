import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = 'douarfwpc';
  static const String uploadPreset = 'chat_unsigned';

  // ======================
  // UPLOAD IMAGE (CHAT)
  // ======================
  static Future<String?> uploadImage(File file) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..fields['resource_type'] = 'image'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return json.decode(body)['secure_url'];
    } else {
      print('Cloudinary error (image): $body');
      return null;
    }
  }

  // ======================
  // UPLOAD FILE (PDF, ZIP…)
  // ======================
  static Future<String?> uploadFile(File file) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/raw/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return json.decode(body)['secure_url'];
    } else {
      print('Cloudinary error (file): $body');
      return null;
    }
  }

  // ======================
  // UPLOAD AVATAR (USER)
  // ======================
  static Future<String?> uploadAvatar(File file, String uid) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = 'avatars'
      ..fields['public_id'] = uid
      ..fields['overwrite'] = 'true'
      ..fields['resource_type'] = 'image'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return json.decode(body)['secure_url'];
    } else {
      print('Cloudinary error (avatar): $body');
      return null;
    }
  }
}
