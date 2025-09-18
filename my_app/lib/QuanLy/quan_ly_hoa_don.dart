import 'package:flutter/widgets.dart';
import 'package:my_shop/DichVu/dich_vu.dart';
import 'package:my_shop/MoHinh/hoa_don.dart';

class QuanLyHoaDon with ChangeNotifier {
  final List<HoaDon> _danhSachHoaDon = [];
  final String bangHoaDon = 'hoaDon';
  final String bangChiTiet = 'chiTietHd';

  List<HoaDon> get layHd {
    return [..._danhSachHoaDon];
  }

  int get tongHd {
    return _danhSachHoaDon.length;
  }

  DateTime _chuyenNgay(DateTime ngay) {
    return DateTime(ngay.year, ngay.month, ngay.day);
  }

  bool _trongNgay(DateTime ngayTao, DateTime? tuNgay, DateTime? denNgay) {
    bool lonHon, nhoHon;
    if (tuNgay == null) {
      lonHon = true;
    } else {
      lonHon =
          _chuyenNgay(ngayTao).isAfter(_chuyenNgay(tuNgay)) ||
          _chuyenNgay(ngayTao).isAtSameMomentAs(_chuyenNgay(tuNgay));
    }
    if (denNgay == null) {
      nhoHon = true;
    } else {
      nhoHon =
          _chuyenNgay(ngayTao).isBefore(_chuyenNgay(denNgay)) ||
          _chuyenNgay(ngayTao).isAtSameMomentAs(_chuyenNgay(denNgay));
    }
    return lonHon && nhoHon;
  }

  Map<DateTime, int> thongKeNgay(
    DateTime? tuNgay,
    DateTime? denNgay,
    bool nhap,
    bool tien,
  ) {
    final Map<DateTime, int> map = {};
    for (final hd in _danhSachHoaDon) {
      if (_trongNgay(hd.ngayTao!, tuNgay, denNgay) && hd.loaiHd == nhap) {
        final ngay = _chuyenNgay(hd.ngayTao!);
        map[ngay] = (map[ngay] ?? 0) + (tien ? hd.tongTien! : 1);
      }
    }
    return map;
  }

  int tongHdNgay(DateTime ngay, {bool? nhap}) {
    if (nhap != null) {
      return _danhSachHoaDon
          .where((sp) => (sp.loaiHd == nhap && _cungNgay(sp.ngayTao!, ngay)))
          .length;
    } else {
      return _danhSachHoaDon.where((sp) => _cungNgay(sp.ngayTao!, ngay)).length;
    }
  }

  int tongTien(DateTime ngay, {bool nhap = true}) {
    final ds = _danhSachHoaDon.where(
      (sp) => (sp.loaiHd == nhap && _cungNgay(sp.ngayTao!, ngay)),
    );
    return ds.fold<int>(0, (tong, sp) => tong + sp.tongTien!);
  }

  bool _cungNgay(DateTime ngayTao, DateTime ngay) {
    return ngayTao.year == ngay.year &&
        ngayTao.month == ngay.month &&
        ngayTao.day == ngay.day;
  }

  Future<void> themHd(HoaDon hoaDon) async {
    final maHd = hoaDon.maHd;
    // true = nhap, false = xuat
    final bool loaiHd = hoaDon.loaiHd!;
    final json = hoaDon.taoJson();
    final jsonChiTiet = json['listSp'];
    json.remove('listSp');
    final jsonHoaDon = json;
    final dichVu = await DichVu.layUserId();
    await dichVu.themSp(jsonHoaDon, bangHoaDon, guiFile: false);
    for (final jsonSp in jsonChiTiet) {
      jsonSp['maHd'] = maHd;
      jsonSp['loaiHd'] = loaiHd ? true : false;
      await dichVu.themSp(jsonSp, bangChiTiet, guiFile: true);
    }
    await lichSuHd();
    notifyListeners();
  }

  Future<void> lichSuHd({bool loc = true}) async {
    _danhSachHoaDon.clear();
    try {
      final dichVu = await DichVu.layUserId();
      final jsonHoaDons = await dichVu.nhanHd(bangHoaDon, loc: loc);
      for (final jsonHoaDon in jsonHoaDons) {
        final maHd = jsonHoaDon['maHd'];
        final jsonChiTiets = await dichVu.nhanChiTiet(
          bangChiTiet,
          maHd,
          loc: loc,
        );
        _danhSachHoaDon.insert(0, HoaDon.nhanJSon(jsonHoaDon, jsonChiTiets));
      }
    } catch (e) {
      print('Lỗi lichSuHd: $e');
    }
    _danhSachHoaDon.sort((a, b) => b.ngayTao!.compareTo(a.ngayTao!));
    notifyListeners();
  }
}
