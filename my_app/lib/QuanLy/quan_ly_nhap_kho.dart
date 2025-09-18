import 'package:flutter/widgets.dart';
import 'package:my_shop/DichVu/dich_vu.dart';
import 'package:my_shop/MoHinh/san_pham.dart';

class QuanLyNhapKho with ChangeNotifier {
  final List<SanPham> _phieuNhap = [];
  final tenBang = 'phieuNhap';

  int get tongSp {
    return _phieuNhap.length;
  }

  List<SanPham> get laySp {
    return [..._phieuNhap];
  }

  int tienBan(index) {
    return _phieuNhap[index].giaBanSp * _phieuNhap[index].soLuongSp;
  }

  int tienMua(index) {
    return _phieuNhap[index].giaMuaSp * _phieuNhap[index].soLuongSp;
  }

  int get tongTienBan {
    int tong = 0;
    for (final sp in _phieuNhap) {
      tong += sp.giaBanSp * sp.soLuongSp;
    }
    return tong;
  }

  int get tongTienMua {
    int tong = 0;
    for (final sp in _phieuNhap) {
      tong += sp.giaMuaSp * sp.soLuongSp;
    }
    return tong;
  }

  Future<void> suaPhieu(SanPham sanPham) async {
    try {
      final dichVu = await DichVu.layUserId();
      final id = await dichVu.layIdSp(sanPham.taoJson(), tenBang);
      if (id != null) {
        await dichVu.suaSp(sanPham.taoJson(), tenBang, suaAnh: false);
      }
      await hienSp();
    } on Exception catch (e) {
      print('Lỗi thayDoiSp: $e');
    }
  }

  Future<void> hienSp({int index = -1}) async {
    if (index == -1) {
      _phieuNhap.clear();
      try {
        final dichVu = await DichVu.layUserId();
        final jsons = await dichVu.nhanSp(tenBang);
        for (final json in jsons) {
          _phieuNhap.insert(0, SanPham.nhanJSon(json));
        }
        notifyListeners();
      } catch (e) {
        print('Lỗi hienSp: $e');
      }
    } else {
      try {
        final dichVu = await DichVu.layUserId();
        final maSp = _phieuNhap[index].maSp.toString();
        final json = await dichVu.laySpTheoMaSp(maSp, tenBang, true);
        final sanPham = SanPham.nhanJSon(json!);
        _phieuNhap[index] = sanPham;
        notifyListeners();
      } catch (e) {
        print('Lỗi hienSp (index): $e');
      }
    }
  }

  Future<bool> kiemTra(String maSp) async {
    final dichVu = await DichVu.layUserId();
    final json = {'maSp': maSp};
    return await dichVu.layIdSp(json, 'sanPham') != null;
  }

  Future<void> themVaoPhieu(String maSp) async {
    try {
      final dichVu = await DichVu.layUserId();
      final json = await dichVu.laySpTheoMaSp(maSp, 'sanPham', false);
      if (json != null) {
        json['soLuongSp'] = 1;
        json.remove('id');
        await dichVu.themSp(json, tenBang);
        await hienSp();
      }
    } catch (e) {
      print('Lỗi themVaoPhieu: $e');
    }
  }

  Future<void> xoaSp(int index, {bool layDs = true}) async {
    final dichVu = await DichVu.layUserId();
    final sanPham = _phieuNhap[index];
    await dichVu.xoaSp(sanPham.taoJson(), tenBang);
    _phieuNhap.removeAt(index);
    if (layDs) {
      await hienSp();
    }
  }

  Future<void> xoaPhieu() async {
    try {
      final tongSp = _phieuNhap.length - 1;
      for (int index = tongSp; index >= 0; index--) {
        await xoaSp(index, layDs: false);
      }
      await hienSp();
    } catch (e) {
      print('Lỗi xoá phiếu: $e');
    }
  }
}
