import 'package:my_shop/MoHinh/san_pham.dart';

class HoaDon {
  String? maHd;
  bool? loaiHd;
  int? tongTien;
  DateTime? ngayTao;
  List<SanPham>? listSp;

  HoaDon({
    this.maHd,
    this.loaiHd,
    this.tongTien,
    this.ngayTao,
    this.listSp
  });

  HoaDon copyWith({
    String? id,
    String? maHd,
    bool? loaiHd,
    int? tongTien,
    DateTime? ngayTao,
    List<SanPham>? listSp,
  }) {
    return HoaDon(
      maHd: maHd ?? this.maHd,
      loaiHd: loaiHd ?? this.loaiHd,
      tongTien: tongTien ?? this.tongTien,
      ngayTao: ngayTao ?? this.ngayTao,
      listSp: listSp ?? this.listSp,
    );
  }

  Map<String, dynamic> taoJson() {
    return {
      'maHd': maHd,
      'loaiHd': loaiHd,
      'tongTien': tongTien,
      'ngayTao': ngayTao!.toIso8601String(),
      'listSp': listSp?.map((sp) => sp.taoJson()).toList() ?? [],
    };
  }

  static HoaDon nhanJSon(Map<String, dynamic> jsonHoaDon,List<dynamic> jsonChiTiets) {
    final List<SanPham> listSp = [];
    for(final jsonChiTiet in jsonChiTiets){
      final sanPham = SanPham.nhanJSon(jsonChiTiet);
      listSp.insert(0, sanPham);
    }
    return HoaDon(
      maHd: jsonHoaDon['maHd'].toString(),
      loaiHd: jsonHoaDon['loaiHd'],
      tongTien: jsonHoaDon['tongTien'] as int,
      ngayTao: DateTime.parse(jsonHoaDon['ngayTao']),
      listSp: listSp
    );
  }
}