import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:my_shop/GiaoDien/thay_doi_san_pham.dart';
import 'package:my_shop/MoHinh/hoa_don.dart';
import 'package:my_shop/QuanLy/quan_ly_hoa_don.dart';
import 'package:my_shop/QuanLy/quan_ly_nhap_kho.dart';
import 'package:my_shop/QuanLy/quan_ly_san_pham.dart';
import 'package:provider/provider.dart';

class HienThiNhapKho extends StatefulWidget {
  static const duongDan = '/hienThiNhapKho';
  const HienThiNhapKho({super.key});

  @override
  State<HienThiNhapKho> createState() => _HienThiNhapKhoState();
}

class _HienThiNhapKhoState extends State<HienThiNhapKho> {
  bool _hienQuet = false;
  DateTime? ngayTao;
  final dinhDangSo = NumberFormat('#,###');
  final dinhDangNgay = DateFormat('dd/MM/yyyy');

  void _batQuet() {
    setState(() {
      _hienQuet = true;
    });
  }

  void _tatQuet() {
    setState(() {
      _hienQuet = false;
    });
  }

  Future<void> _chonNgay(BuildContext context) async {
    final DateTime? chonNgay = await showDatePicker(
      context: context,
      initialDate: ngayTao ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (chonNgay != null && chonNgay != ngayTao) {
      setState(() {
        ngayTao = chonNgay;
      });
    }
  }

  Future<void> _luuKho(QuanLyNhapKho quanLyNhapKho) async {
    final quanLySanPham = Provider.of<QuanLySanPham>(context, listen: false);
    for (final sanPhamNhap in quanLyNhapKho.laySp) {
      final sanPhamKho = await quanLySanPham.thongTinSp(sanPhamNhap.maSp!);
      int giaMoi = 0;
      if (sanPhamKho!.soLuongSp == 0) {
        giaMoi = sanPhamNhap.giaMuaSp;
      } else {
        giaMoi =
            sanPhamKho.giaMuaSp +
            ((sanPhamNhap.giaMuaSp - sanPhamKho.giaMuaSp) /
                    (sanPhamKho.soLuongSp + sanPhamNhap.soLuongSp))
                .round();
      }
      final soLuongMoi = sanPhamKho.soLuongSp + sanPhamNhap.soLuongSp;
      final sanPham = sanPhamKho.copyWith(
        giaMuaSp: giaMoi,
        soLuongSp: soLuongMoi,
      );
      await quanLySanPham.thayDoiSp(sanPham, suaAnh: false);
    }
  }

  void _luuHoaDon() async {
    final quanLyHoaDon = Provider.of<QuanLyHoaDon>(context, listen: false);
    final quanLyNhapKho = Provider.of<QuanLyNhapKho>(context, listen: false);
    if (quanLyNhapKho.tongTienMua == 0) return;
    final hoaDon = HoaDon().copyWith(
      id: null,
      maHd: DateTime.now().toIso8601String(),
      loaiHd: true,
      tongTien: quanLyNhapKho.tongTienMua,
      ngayTao: ngayTao,
      listSp: quanLyNhapKho.laySp,
    );
    await _luuKho(quanLyNhapKho);
    await quanLyHoaDon.themHd(hoaDon);
    await quanLyNhapKho.xoaPhieu();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý nhập kho'),
        actions: [
          TextButton.icon(
            onPressed: _luuHoaDon,
            label: Text(
              'Thêm',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Consumer<QuanLyNhapKho>(
        builder: (context, quanLyNhapKho, _) {
          return Column(
            children: [
              SizedBox(height: 10),
              _hienQuet
                  ? QuetMaSp(quanLyNhapKho, _tatQuet)
                  : ElevatedButton(
                      onPressed: _batQuet,
                      child: Text('Quét mã vạch'),
                    ),
              NhapMaVach(quanLyNhapKho),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _chonNgay(context),
                    icon: Icon(Icons.date_range),
                    label: Text(
                      ngayTao == null
                          ? 'chọn ngày'
                          : dinhDangNgay.format(ngayTao!),
                    ),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Text(
                      'TỔNG TIỀN',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    Text(
                      dinhDangSo.format(quanLyNhapKho.tongTienMua),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(child: HienPhieuNhap(quanLyNhapKho)),
            ],
          );
        },
      ),
    );
  }
}

class QuetMaSp extends StatefulWidget {
  const QuetMaSp(this._quanLyNhapKho, this._tatQuet, {super.key});
  final QuanLyNhapKho _quanLyNhapKho;
  final void Function() _tatQuet;

  @override
  State<QuetMaSp> createState() => _QuetMaSpState();
}

class _QuetMaSpState extends State<QuetMaSp> {
  final MobileScannerController controller = MobileScannerController();
  late final QuanLyNhapKho quanLyNhapKho;
  @override
  void initState() {
    super.initState();
    quanLyNhapKho = widget._quanLyNhapKho;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    return SizedBox(
      height: 60,
      width: 200,
      child: MobileScanner(
        controller: controller,
        onDetect: (BarcodeCapture capture) async {
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            final String? maSp = barcodes.first.rawValue;
            if (maSp == null) return;
            await controller.stop();
            try {
              final kiemTra = await quanLyNhapKho.kiemTra(maSp);
              if (!kiemTra) {
                await navigator.push(
                  MaterialPageRoute(
                    builder: (ctx) => ThayDoiSanPham(maSp: maSp),
                  ),
                );
                await quanLyNhapKho.themVaoPhieu(maSp);
              } else {
                final index = quanLyNhapKho.laySp.indexWhere(
                  (sp) => sp.maSp.toString() == maSp.toString(),
                );
                if (index == -1) {
                  await quanLyNhapKho.themVaoPhieu(maSp);
                } else {
                  final sanPhamMoi = quanLyNhapKho.laySp[index].copyWith(
                    soLuongSp: quanLyNhapKho.laySp[index].soLuongSp + 1,
                  );
                  await quanLyNhapKho.suaPhieu(sanPhamMoi);
                }
                await quanLyNhapKho.hienSp(index: index);
              }
            } catch (e) {
              print('Lỗi xử lý mã SP: $e');
            } finally {
              widget._tatQuet();
            }
          }
        },
      ),
    );
  }
}

class NhapMaVach extends StatelessWidget {
  const NhapMaVach(this.quanLyNhapKho, {super.key});
  final QuanLyNhapKho quanLyNhapKho;
  @override
  Widget build(BuildContext context) {
    final TextEditingController textController = TextEditingController();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 70, vertical: 5),
      child: TextFormField(
        controller: textController,
        decoration: InputDecoration(
          labelText: 'Nhập mã sản phẩm',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.arrow_forward_outlined,
              color: Colors.blue,
              size: 30,
            ),
            onPressed: () async {
              final maSp = textController.text;
              final navigator = Navigator.of(context);
              if (maSp.isEmpty) return;
              try {
                final kiemTra = await quanLyNhapKho.kiemTra(maSp);
                if (!kiemTra) {
                  await navigator.push(
                    MaterialPageRoute(
                      builder: (ctx) => ThayDoiSanPham(maSp: maSp),
                    ),
                  );
                  await quanLyNhapKho.themVaoPhieu(maSp);
                } else {
                  final index = quanLyNhapKho.laySp.indexWhere(
                    (sp) => sp.maSp == maSp,
                  );
                  if (index == -1) {
                    await quanLyNhapKho.themVaoPhieu(maSp);
                  } else {
                    final sanPhamMoi = quanLyNhapKho.laySp[index].copyWith(
                      soLuongSp: quanLyNhapKho.laySp[index].soLuongSp + 1,
                    );
                    await quanLyNhapKho.suaPhieu(sanPhamMoi);
                  }
                  await quanLyNhapKho.hienSp(index: index);
                }
              } catch (e) {
                print('Lỗi xử lý mã SP: $e');
              }
              textController.clear();
            },
          ),
        ),
      ),
    );
  }
}

class HienPhieuNhap extends StatefulWidget {
  const HienPhieuNhap(this._quanLyNhapKho, {super.key});
  final QuanLyNhapKho _quanLyNhapKho;

  @override
  State<HienPhieuNhap> createState() => _HienPhieuNhapState();
}

class _HienPhieuNhapState extends State<HienPhieuNhap> {
  late final QuanLyNhapKho quanLyNhapKho;
  Map<String, bool> suaPhieu = {};
  final List<TextEditingController> _giaMuaControllers = [];
  final List<TextEditingController> _soLuongControllers = [];
  final dinhDangSo = NumberFormat('#,###');
  @override
  void initState() {
    super.initState();
    quanLyNhapKho = widget._quanLyNhapKho;
    _khoiTao();
  }

  Future<void> _khoiTao() async {
    await quanLyNhapKho.hienSp();
  }

  @override
  void dispose() {
    for (final controller in _giaMuaControllers) {
      controller.dispose();
    }
    for (final controller in _soLuongControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: quanLyNhapKho.tongSp,
      itemBuilder: (context, index) {
        var sanPham = quanLyNhapKho.laySp[index];
        while (_giaMuaControllers.length <= index) {
          _giaMuaControllers.add(TextEditingController());
        }
        while (_soLuongControllers.length <= index) {
          _soLuongControllers.add(TextEditingController());
        }
        if (_giaMuaControllers[index].text.isEmpty) {
          _giaMuaControllers[index].text = sanPham.giaMuaSp.toString();
        }
        if (_soLuongControllers[index].text.isEmpty) {
          _soLuongControllers[index].text = sanPham.soLuongSp.toString();
        }
        suaPhieu.putIfAbsent(sanPham.maSp.toString(), () => false);
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ClipOval(
                    child: Image.network(
                      sanPham.hinhAnhSp!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                (suaPhieu[sanPham.maSp.toString()] ?? false)
                    ? Expanded(
                        flex: 7,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tên: ${sanPham.tenSp}', softWrap: true),
                            Row(
                              children: [
                                const Text('Giá mua:'),
                                const SizedBox(width: 6),
                                SizedBox(
                                  width: 50,
                                  child: TextField(
                                    controller: _giaMuaControllers[index],
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      CurrencyInputFormatter(
                                        thousandSeparator:
                                            ThousandSeparator.Comma,
                                        mantissaLength: 0,
                                      ),
                                    ],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 10),
                                    decoration: const InputDecoration(
                                      counterText: '',
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 0,
                                        horizontal: 0,
                                      ),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Text('Số lượng:'),
                                const SizedBox(width: 6),
                                SizedBox(
                                  width: 50,
                                  child: TextField(
                                    controller: _soLuongControllers[index],
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      CurrencyInputFormatter(
                                        thousandSeparator:
                                            ThousandSeparator.Comma,
                                        mantissaLength: 0,
                                      ),
                                    ],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 10),
                                    decoration: const InputDecoration(
                                      counterText: '',
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 0,
                                        horizontal: 0,
                                      ),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : Expanded(
                        flex: 7,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tên: ${sanPham.tenSp}'),
                            Text(
                              'Giá mua: ${dinhDangSo.format(sanPham.giaMuaSp)}',
                            ),
                            Text(
                              'Số lượng: ${dinhDangSo.format(sanPham.soLuongSp)}',
                            ),
                            Text(
                              'Tổng: ${dinhDangSo.format(quanLyNhapKho.tienMua(index))}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                Spacer(),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      (suaPhieu[sanPham.maSp.toString()] ?? false)
                          ? IconButton(
                              icon: Icon(Icons.save, color: Colors.blue),
                              onPressed: () async {
                                sanPham = sanPham.copyWith(
                                  giaMuaSp: int.parse(
                                    _giaMuaControllers[index].text.replaceAll(
                                      ',',
                                      '',
                                    ),
                                  ),
                                  soLuongSp: int.parse(
                                    _soLuongControllers[index].text.replaceAll(
                                      ',',
                                      '',
                                    ),
                                  ),
                                );
                                await quanLyNhapKho.suaPhieu(sanPham);
                                await quanLyNhapKho.hienSp(index: index);
                                setState(() {
                                  suaPhieu[sanPham.maSp.toString()] = false;
                                });
                              },
                            )
                          : IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                setState(() {
                                  suaPhieu[sanPham.maSp.toString()] = true;
                                });
                              },
                            ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          _giaMuaControllers.removeAt(index);
                          _soLuongControllers.removeAt(index);
                          suaPhieu.remove(sanPham.maSp.toString());
                          await quanLyNhapKho.xoaSp(index);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
