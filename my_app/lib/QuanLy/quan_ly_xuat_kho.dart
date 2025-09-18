import 'package:flutter/widgets.dart';
import 'package:my_shop/DichVu/dich_vu.dart';
import 'package:my_shop/MoHinh/san_pham.dart';

class QuanLyXuatKho with ChangeNotifier {
  final List<SanPham> _phieuXuat = [];
  final tenBang = 'phieuXuat';

  int get tongSp {
    return _phieuXuat.length;
  }

  List<SanPham> get laySp {
    return [..._phieuXuat];
  }

  int tienBan(index) {
    return _phieuXuat[index].giaBanSp * _phieuXuat[index].soLuongSp;
  }

  int tienMua(index) {
    return _phieuXuat[index].giaMuaSp * _phieuXuat[index].soLuongSp;
  }

  int get tongTienBan {
    int tong = 0;
    for (final sp in _phieuXuat) {
      tong += sp.giaBanSp * sp.soLuongSp;
    }
    return tong;
  }

  int get tongTienMua {
    int tong = 0;
    for (final sp in _phieuXuat) {
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
      _phieuXuat.clear();
      try {
        final dichVu = await DichVu.layUserId();
        final jsons = await dichVu.nhanSp(tenBang);
        for (final json in jsons) {
          _phieuXuat.insert(0, SanPham.nhanJSon(json));
        }
        notifyListeners();
      } catch (e) {
        print('Lỗi hienSp: $e');
      }
    } else {
      try {
        final dichVu = await DichVu.layUserId();
        final maSp = _phieuXuat[index].maSp.toString();
        final json = await dichVu.laySpTheoMaSp(maSp, tenBang, true);
        final sanPham = SanPham.nhanJSon(json!);
        _phieuXuat[index] = sanPham;
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
    final sanPham = _phieuXuat[index];
    await dichVu.xoaSp(sanPham.taoJson(), tenBang);
    _phieuXuat.removeAt(index);
    if (layDs) {
      await hienSp();
    }
  }

  Future<void> xoaPhieu() async {
    try {
      final tongSp = _phieuXuat.length - 1;
      for (int index = tongSp; index >= 0; index--) {
        await xoaSp(index, layDs: false);
      }
      await hienSp();
    } catch (e) {
      print('Lỗi xoá phiếu: $e');
    }
  }
}
