import 'package:flutter/material.dart';
import 'package:my_shop/DichVu/dich_vu.dart';
import 'package:my_shop/MoHinh/san_pham.dart';

class QuanLySanPham with ChangeNotifier {
  final List<SanPham> _danhSachSanPham = [];
  final tenBang = 'sanPham';

  int get tongSp {
    return _danhSachSanPham.length;
  }

  List<SanPham> get laySp {
    return [..._danhSachSanPham];
  }

  Future<SanPham?> thongTinSp(String maSp) async {
    final dichVu = await DichVu.layUserId();
    final json = await dichVu.laySpTheoMaSp(maSp, tenBang, false);
    if (json != null) {
      final sanPham = SanPham.nhanJSon(json);
      return sanPham;
    }
    return null;
  }

  Future<int> soSpTrongKho(String maSp) async {
    await hienSp();
    for (final sanPham in _danhSachSanPham) {
      if (sanPham.maSp.toString() == maSp) return sanPham.soLuongSp;
    }
    return 0;
  }

  Future<void> thayDoiSp(SanPham sanPham, {bool suaAnh = true}) async {
    final dichVu = await DichVu.layUserId();
    final id = await dichVu.layIdSp(sanPham.taoJson(), tenBang);
    if (id != null) {
      await dichVu.suaSp(sanPham.taoJson(), tenBang, suaAnh: suaAnh);
    } else {
      await dichVu.themSp(sanPham.taoJson(), tenBang);
    }
    await hienSp();
    notifyListeners();
  }

  Future<void> hienSp({int index = -1}) async {
    if (index == -1) {
      try {
        _danhSachSanPham.clear();
        final dichVu = await DichVu.layUserId();
        final jsons = await dichVu.nhanSp(tenBang);
        for (final json in jsons) {
          _danhSachSanPham.insert(0, SanPham.nhanJSon(json));
        }
        notifyListeners();
      } catch (e) {
        print('Lỗi hienSp: $e');
      }
    } else {
      try {
        final dichVu = await DichVu.layUserId();
        final maSp = _danhSachSanPham[index].maSp.toString();
        final json = await dichVu.laySpTheoMaSp(maSp, tenBang, false);
        final sanPham = SanPham.nhanJSon(json!);
        _danhSachSanPham[index] = sanPham;
        notifyListeners();
      } catch (e) {
        print('Lỗi hienSp (index): $e');
      }
    }
  }

  Future<void> xoaSp(SanPham sanPham) async {
    final dichVu = await DichVu.layUserId();
    await dichVu.xoaSp(sanPham.taoJson(), tenBang);
    await hienSp();
    notifyListeners();
  }

  Future<bool> kiemTra(String maSp) async {
    final dichVu = await DichVu.layUserId();
    final json = {'maSp': maSp};
    return await dichVu.layIdSp(json, tenBang) != null;
  }
}
