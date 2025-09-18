import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:my_shop/DichVu/pocketbase_client.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class DichVu {
  final PocketBase pb;
  final String userId;
  DichVu(this.pb, this.userId);

  static Future<DichVu> layUserId() async {
    final pb = await getPocketbaseInstance();
    final userId = pb.authStore.record!.id;
    return DichVu(pb, userId);
  }

  Future<String?> layIdSp(Map<String, dynamic> json, String tenBang) async {
    final maSp = json['maSp'];
    try {
      final record = await pb
          .collection(tenBang)
          .getFirstListItem("maSp='$maSp'");
      return record.id;
    } catch (e) {
      return null;
    }
  }

  Future<void> suaSp(
    Map<String, dynamic> json,
    String tenBang, {
    bool suaAnh = true,
  }) async {
    final dichVu = await DichVu.layUserId();
    final id = await dichVu.layIdSp(json, tenBang);
    if (suaAnh == true) {
      await pb
          .collection(tenBang)
          .update(id!, body: json, files: await taoFile(json));
    } else {
      await pb.collection(tenBang).update(id!, body: json);
    }
  }

  Future<List<http.MultipartFile>> taoFile(Map<String, dynamic> json) async {
    final String url = json['hinhAnhSp'];
    Uint8List bytes;
    if (url.startsWith('http')) {
      final response = await http.get(Uri.parse(url));
      bytes = response.bodyBytes;
    } else {
      bytes = await File(url).readAsBytes();
    }

    final type = lookupMimeType('', headerBytes: bytes);
    if (type != 'image/jpeg') {
      final image = img.decodeImage(bytes);
      if (image == null) {
        throw Exception('Không thể giải mã ảnh');
      }
      bytes = img.encodeJpg(image);
    }

    final file = http.MultipartFile.fromBytes(
      'hinhAnh',
      bytes,
      filename: '${DateTime.now().toIso8601String()}.jpg',
      contentType: MediaType('image', 'jpeg'),
    );
    return [file];
  }

  Future<void> themSp(
    Map<String, dynamic> json,
    String tenBang, {
    bool guiFile = true,
  }) async {
    if (guiFile) {
      await pb
          .collection(tenBang)
          .create(
            body: {...json, "userId": userId},
            files: await taoFile(json),
          );
    } else {
      await pb.collection(tenBang).create(body: {...json, "userId": userId});
    }
  }

  String taoUrl(RecordModel record) {
    final fileName = record.getStringValue('hinhAnh');
    return pb.files.getUrl(record, fileName).toString();
  }

  Future<List<Map<String, dynamic>>> nhanSp(String tenBang) async {
    List<Map<String, dynamic>> jsons = [];
    final records = await pb.collection(tenBang).getFullList();
    for (final record in records) {
      final json = record.data;
      final url = taoUrl(record);
      json['hinhAnhSp'] = url;
      jsons.insert(0, Map<String, dynamic>.from(json));
    }
    return jsons;
  }

  Future<void> xoaSp(Map<String, dynamic> json, String tenBang) async {
    final id = await layIdSp(json, tenBang);
    if (id != null) {
      await pb.collection(tenBang).delete(id);
    }
  }

  Future<XFile> taoXFile(Map<String, dynamic> json) async {
    final url = json['hinhAnhSp'];
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Tải ảnh thất bại: ${response.statusCode}');
    }
    final bytes = response.bodyBytes;
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await file.writeAsBytes(bytes);
    return XFile(file.path);
  }

  Future<Map<String, dynamic>?> laySpTheoMaSp(
    String maSp,
    String tenBang,
    bool locTheoId,
  ) async {
    try {
      RecordModel? record;
      if (locTheoId == false) {
        record = await pb.collection(tenBang).getFirstListItem("maSp='$maSp'");
      } else {
        record = await pb
            .collection(tenBang)
            .getFirstListItem("maSp='$maSp' && userId='$userId'");
      }
      final url = taoUrl(record);
      final json = record.data;
      json['hinhAnhSp'] = url;
      return json;
    } catch (e) {
      throw Exception('laySpTheoMaSp thất bại: $e');
    }
  }

  Future<List<Map<String, dynamic>>> nhanHd(String tenBang,{bool loc=true}) async {
    List<Map<String, dynamic>> jsons = [];
    final filter = loc
      ? "userId='$userId'"
      : null;
    final records = await pb
        .collection(tenBang)
        .getFullList(filter: filter);
    for (final record in records) {
      final json = record.data;
      final url = taoUrl(record);
      json['hinhAnhSp'] = url;
      jsons.insert(0, Map<String, dynamic>.from(json));
    }
    return jsons;
  }

  Future<List<Map<String, dynamic>>> nhanChiTiet(
    String tenBang,
    String maHd,
    {bool loc=true}
  ) async {
    List<Map<String, dynamic>> jsons = [];
    final filter = loc
      ? "userId='$userId' && maHd='$maHd'"
      : "maHd='$maHd'";
    final records = await pb
        .collection(tenBang)
        .getFullList(filter: filter);
    for (final record in records) {
      final json = record.data;
      final url = taoUrl(record);
      json['hinhAnhSp'] = url;
      jsons.insert(0, Map<String, dynamic>.from(json));
    }
    return jsons;
  }
}
