import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:my_shop/DichVu/dich_vu.dart';
import 'package:my_shop/MoHinh/san_pham.dart';
import 'package:my_shop/QuanLy/quan_ly_san_pham.dart';
import 'package:provider/provider.dart';

class ThayDoiSanPham extends StatefulWidget {
  static String duongDan = '/thayDoiSanPham';
  late final SanPham sanPham;
  late final String cheDo;
  late final String maSp;
  ThayDoiSanPham({SanPham? sanPham, super.key, String maSp = ''}) {
    cheDo = sanPham != null ? 'thayDoi' : 'taoMoi';
    this.sanPham =
        sanPham ??
        SanPham(
          maSp: maSp,
          tenSp: '',
          giaBanSp: 0,
          giaMuaSp: 0,
          soLuongSp: 0,
          hinhAnhSp: null,
        );
  }

  @override
  State<ThayDoiSanPham> createState() => _ThayDoiSanPhamState();
}

class _ThayDoiSanPhamState extends State<ThayDoiSanPham> {
  final _guiForm = GlobalKey<FormState>();
  late SanPham _sanPhamMoi;
  late String _cheDo;
  late String _maSpDau;
  late final TextEditingController maSp;
  bool _chonAnh = false;
  @override
  void initState() {
    super.initState();
    _sanPhamMoi = widget.sanPham;
    _maSpDau = _sanPhamMoi.maSp.toString();
    _cheDo = widget.cheDo;
    maSp = TextEditingController(text: _sanPhamMoi.maSp);
  }

  Future<bool> _kiemTra(String maSp) async {
    final quanLySanPham = QuanLySanPham();
    return await quanLySanPham.kiemTra(maSp);
  }

  Future<XFile?> _taoAnh() async {
    if (_sanPhamMoi.hinhAnhSp != null) {
      final dichVu = await DichVu.layUserId();
      final xFile = await dichVu.taoXFile(_sanPhamMoi.taoJson());
      return xFile;
    } else {
      return null;
    }
  }

  Future<void> _luuForm() async {
    final bool kiemTra = _guiForm.currentState!.validate();
    if (!kiemTra) {
      return;
    }
    final bool maSpTrung = await _kiemTra(maSp.text);
    if (!mounted) return;
    if (maSpTrung) {
      if (_cheDo == 'taoMoi' ||
          (_maSpDau != maSp.text && _cheDo == 'thayDoi')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sản phẩm đã tồn tại', textAlign: TextAlign.center),
          ),
        );
        return;
      }
    }
    _guiForm.currentState!.save();
    final quanLySanPham = Provider.of<QuanLySanPham>(context, listen: false);
    await quanLySanPham.thayDoiSp(_sanPhamMoi);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _cheDo == 'thayDoi' ? 'Thay đổi sản phẩm' : 'Thêm mới sản phẩm',
        ),
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.save), onPressed: _luuForm),
        ],
      ),
      body: Form(
        key: _guiForm,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            _nhapMaSp(context),
            _nhapTenSp(),
            _nhapGiaMua(),
            _nhapGiaBan(),
            _nhapSoluong(),
            SizedBox(height: 10),
            _hienThiAnh(),
          ],
        ),
      ),
    );
  }

  TextFormField _nhapMaSp(BuildContext context) {
    return TextFormField(
      controller: maSp,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: 'Mã sản phẩm',
        suffixIcon: IconButton(
          icon: Icon(Icons.qr_code_scanner),
          onPressed: () async {
            final ketQua = await showDialog<String>(
              context: context,
              builder: (context) => QuetMaVach(),
            );
            maSp.text = ketQua ?? maSp.text;
          },
        ),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Không để trống';
        } else {
          maSp.text = value;
          return null;
        }
      },
      onSaved: (value) => _sanPhamMoi = _sanPhamMoi.copyWith(maSp: value),
    );
  }

  TextFormField _nhapTenSp() {
    return TextFormField(
      initialValue: _sanPhamMoi.tenSp,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.text,
      decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Không để trống';
        }
        return null;
      },
      onSaved: (value) => _sanPhamMoi = _sanPhamMoi.copyWith(tenSp: value),
    );
  }

  TextFormField _nhapGiaBan() {
    return TextFormField(
      initialValue: _sanPhamMoi.giaBanSp.toString(),
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        CurrencyInputFormatter(
          thousandSeparator: ThousandSeparator.Comma,
          mantissaLength: 0,
        ),
      ],
      decoration: const InputDecoration(labelText: 'Giá bán'),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Không để trống';
        }
        final giaTri = value.replaceAll(',', '');
        final so = int.tryParse(giaTri);
        if (so == null) {
          return 'Giá trị không hợp lệ';
        } else if (so <= 0) {
          return 'Giá trị phải lớn hơn 0';
        }
        return null;
      },
      onSaved: (value) {
        final giaTriLuu = value!.replaceAll(',', '');
        _sanPhamMoi = _sanPhamMoi.copyWith(giaBanSp: int.tryParse(giaTriLuu));
      },
    );
  }

  TextFormField _nhapGiaMua() {
    return TextFormField(
      initialValue: _sanPhamMoi.giaMuaSp.toString(),
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        CurrencyInputFormatter(
          thousandSeparator: ThousandSeparator.Comma,
          mantissaLength: 0,
        ),
      ],
      decoration: const InputDecoration(labelText: 'Giá mua'),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Không để trống';
        }
        final giaTri = value.replaceAll(',', '');
        final so = int.tryParse(giaTri);
        if (so == null) {
          return 'Giá trị không hợp lệ';
        } else if (so <= 0) {
          return 'Giá trị phải lớn hơn 0';
        }
        return null;
      },
      onSaved: (value) {
        final giaTriLuu = value!.replaceAll(',', '');
        _sanPhamMoi = _sanPhamMoi.copyWith(giaMuaSp: int.tryParse(giaTriLuu));
      },
    );
  }

  TextFormField _nhapSoluong() {
    return TextFormField(
      initialValue: _sanPhamMoi.soLuongSp.toString(),
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        CurrencyInputFormatter(
          thousandSeparator: ThousandSeparator.Comma,
          mantissaLength: 0,
        ),
      ],
      decoration: const InputDecoration(labelText: 'Số lượng'),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Không để trống';
        }
        final giaTri = value.replaceAll(',', '');
        final so = int.tryParse(giaTri);
        if (so == null) {
          return 'Giá trị không hợp lệ';
        }
        return null;
      },
      onSaved: (value) {
        final giaTriLuu = value!.replaceAll(',', '');
        _sanPhamMoi = _sanPhamMoi.copyWith(soLuongSp: int.tryParse(giaTriLuu));
      },
    );
  }

  FutureBuilder<XFile?> _hienThiAnh() {
    return FutureBuilder(
      future: _taoAnh(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final anhKhoiDau = snapshot.data;
        return FormField<XFile>(
          initialValue: anhKhoiDau,
          validator: (value) {
            if (value == null) {
              return 'Vui lòng chọn ảnh';
            }
            return null;
          },
          builder: (FormFieldState state) {
            return Column(
              children: [
                const Text(
                  'Ảnh sản phẩm',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(8),
                        image: state.value == null
                            ? DecorationImage(
                                image: AssetImage('assets/no_image.jpg'),
                              )
                            : DecorationImage(
                                image: FileImage(File(state.value.path)),
                              ),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _chonAnh == false
                              ? TextButton.icon(
                                  icon: const Icon(Icons.image),
                                  label: const Text('Chọn ảnh'),
                                  onPressed: () {
                                    _chonAnh = true;
                                    state.didChange(state.value);
                                  },
                                )
                              : Row(
                                  children: [
                                    TextButton.icon(
                                      icon: const Icon(Icons.camera),
                                      label: const Text('Máy ảnh'),
                                      onPressed: () async {
                                        _chonAnh = false;
                                        final picker = ImagePicker();
                                        final ketQua = await picker.pickImage(
                                          source: ImageSource.camera,
                                        );
                                        _chonAnh = false;
                                        if (ketQua != null) {
                                          state.didChange(ketQua);
                                        }
                                      },
                                    ),
                                    TextButton.icon(
                                      icon: const Icon(Icons.photo_library),
                                      label: const Text('Thư viện'),
                                      onPressed: () async {
                                        _chonAnh = false;
                                        final picker = ImagePicker();
                                        final ketQua = await picker.pickImage(
                                          source: ImageSource.gallery,
                                        );
                                        _chonAnh = false;
                                        if (ketQua != null) {
                                          state.didChange(ketQua);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      state.errorText ?? '',
                      style: TextStyle(
                        color: Theme.of(state.context).colorScheme.error,
                      ),
                    ),
                  ),
              ],
            );
          },
          onSaved: (value) {
            if (value != null) {
              _sanPhamMoi = _sanPhamMoi.copyWith(
                hinhAnhSp: value.path.toString(),
              );
            }
          },
        );
      },
    );
  }
}

class QuetMaVach extends StatelessWidget {
  const QuetMaVach({super.key});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Quét mã sản phẩm', textAlign: TextAlign.center),
      content: SizedBox(
        width: 200,
        height: 200,
        child: MobileScanner(
          controller: MobileScannerController(torchEnabled: true),
          onDetect: (BarcodeCapture capture) {
            final List<Barcode> barcodes = capture.barcodes;
            if (barcodes.isNotEmpty) {
              final code = barcodes.first.rawValue;
              if (code != null) {
                Navigator.of(context).pop(code);
              }
            }
          },
        ),
      ),
    );
  }
}
