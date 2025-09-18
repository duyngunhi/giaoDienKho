import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:my_shop/MoHinh/hoa_don.dart';
import 'package:my_shop/QuanLy/quan_ly_hoa_don.dart';
import 'package:my_shop/QuanLy/quan_ly_san_pham.dart';
import 'package:my_shop/QuanLy/quan_ly_xuat_kho.dart';
import 'package:provider/provider.dart';

class HienThiXuatKho extends StatefulWidget {
  static const duongDan = '/hienThiXuatKho';
  const HienThiXuatKho({super.key});

  @override
  State<HienThiXuatKho> createState() => _HienThiXuatKhoState();
}

class _HienThiXuatKhoState extends State<HienThiXuatKho> {
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

  Future<void> _luuKho(QuanLyXuatKho quanLyXuatKho) async {
    final quanLySanPham = Provider.of<QuanLySanPham>(context, listen: false);
    for (final sanPhamXuat in quanLyXuatKho.laySp) {
      final sanPhamKho = await quanLySanPham.thongTinSp(sanPhamXuat.maSp!);
      final soLuongMoi = sanPhamKho!.soLuongSp - sanPhamXuat.soLuongSp;
      if (sanPhamXuat.soLuongSp > sanPhamKho.soLuongSp) {
        throw Exception('Số lượng xuất vượt quá số lượng trong kho');
      }
      final sanPham = sanPhamKho.copyWith(soLuongSp: soLuongMoi);
      await quanLySanPham.thayDoiSp(sanPham, suaAnh: false);
    }
  }

  void _luuHoaDon() async {
    final quanLyHoaDon = Provider.of<QuanLyHoaDon>(context, listen: false);
    final quanLyXuatKho = Provider.of<QuanLyXuatKho>(context, listen: false);
    if (quanLyXuatKho.tongTienBan == 0) return;
    final hoaDon = HoaDon().copyWith(
      id: null,
      maHd: DateTime.now().toIso8601String(),
      loaiHd: false,
      tongTien: quanLyXuatKho.tongTienBan,
      ngayTao: ngayTao,
      listSp: quanLyXuatKho.laySp,
    );
    await _luuKho(quanLyXuatKho);
    await quanLyHoaDon.themHd(hoaDon);
    await quanLyXuatKho.xoaPhieu();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý xuất kho'),
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
      body: Consumer<QuanLyXuatKho>(
        builder: (context, quanLyXuatKho, _) {
          return Column(
            children: [
              SizedBox(height: 10),
              _hienQuet
                  ? QuetMaSp(quanLyXuatKho, _tatQuet)
                  : ElevatedButton(
                      onPressed: _batQuet,
                      child: Text('Quét mã vạch'),
                    ),
              NhapMaVach(quanLyXuatKho),
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
                      dinhDangSo.format(quanLyXuatKho.tongTienBan),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(child: HienPhieuXuat(quanLyXuatKho)),
            ],
          );
        },
      ),
    );
  }
}

class QuetMaSp extends StatefulWidget {
  const QuetMaSp(this._quanLyXuatKho, this._tatQuet, {super.key});
  final QuanLyXuatKho _quanLyXuatKho;
  final void Function() _tatQuet;

  @override
  State<QuetMaSp> createState() => _QuetMaSpState();
}

class _QuetMaSpState extends State<QuetMaSp> {
  final MobileScannerController controller = MobileScannerController();
  late final QuanLyXuatKho quanLyXuatKho;
  @override
  void initState() {
    super.initState();
    quanLyXuatKho = widget._quanLyXuatKho;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quanLySanPham = Provider.of<QuanLySanPham>(context, listen: false);
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
              final kiemTra = await quanLyXuatKho.kiemTra(maSp);
              final soSpTrongKho = await quanLySanPham.soSpTrongKho(maSp);
              if (!kiemTra) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Không có sản phẩm',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                    backgroundColor: Colors.transparent,
                    duration: Duration(seconds: 2),
                  ),
                );
              } else {
                final index = quanLyXuatKho.laySp.indexWhere(
                  (sp) => sp.maSp.toString() == maSp.toString(),
                );
                if (index == -1) {
                  if (soSpTrongKho == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Hết hàng',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.red),
                        ),
                        backgroundColor: Colors.transparent,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }
                  await quanLyXuatKho.themVaoPhieu(maSp);
                } else {
                  if (soSpTrongKho <= quanLyXuatKho.laySp[index].soLuongSp) {
                    return;
                  }
                  final sanPhamMoi = quanLyXuatKho.laySp[index].copyWith(
                    soLuongSp: quanLyXuatKho.laySp[index].soLuongSp + 1,
                  );
                  await quanLyXuatKho.suaPhieu(sanPhamMoi);
                }
                await quanLyXuatKho.hienSp(index: index);
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
  const NhapMaVach(this.quanLyXuatKho, {super.key});
  final QuanLyXuatKho quanLyXuatKho;
  @override
  Widget build(BuildContext context) {
    final TextEditingController textController = TextEditingController();
    final quanLySanPham = Provider.of<QuanLySanPham>(context, listen: false);
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
              final soSpTrongKho = await quanLySanPham.soSpTrongKho(maSp);
              if (maSp.isEmpty) return;
              try {
                final kiemTra = await quanLyXuatKho.kiemTra(maSp);
                if (!kiemTra) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Không có sản phẩm',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.red),
                      ),
                      backgroundColor: Colors.transparent,
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  final index = quanLyXuatKho.laySp.indexWhere(
                    (sp) => sp.maSp == maSp,
                  );
                  if (index == -1) {
                    if (soSpTrongKho == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Hết hàng',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.red),
                          ),
                          backgroundColor: Colors.transparent,
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }
                    await quanLyXuatKho.themVaoPhieu(maSp);
                  } else {
                    if (soSpTrongKho <= quanLyXuatKho.laySp[index].soLuongSp) {
                      return;
                    }
                    final sanPhamMoi = quanLyXuatKho.laySp[index].copyWith(
                      soLuongSp: quanLyXuatKho.laySp[index].soLuongSp + 1,
                    );
                    await quanLyXuatKho.suaPhieu(sanPhamMoi);
                  }
                  await quanLyXuatKho.hienSp(index: index);
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

class HienPhieuXuat extends StatefulWidget {
  const HienPhieuXuat(this._quanLyXuatKho, {super.key});
  final QuanLyXuatKho _quanLyXuatKho;

  @override
  State<HienPhieuXuat> createState() => _HienPhieuXuatState();
}

class _HienPhieuXuatState extends State<HienPhieuXuat> {
  late final QuanLyXuatKho quanLyXuatKho;
  Map<String, bool> suaPhieu = {};
  Map<String, TextEditingController> soLuongControllers = {};
  final dinhDangSo = NumberFormat('#,###');
  Map<String, int> soSpTrongKho = {};
  bool load = false;

  @override
  void initState() {
    super.initState();
    quanLyXuatKho = widget._quanLyXuatKho;
    _khoiTao();
  }

  Future<void> _khoiTao() async {
    await quanLyXuatKho.hienSp();
    final dsSpKho = quanLyXuatKho.laySp;
    final Map<String, int> tam = {};
    for (final sp in dsSpKho) {
      final sl = await _soSpTrongKho(sp.maSp!);
      tam[sp.maSp!] = sl;
    }
    setState(() {
      soSpTrongKho.addAll(tam);
    });
  }

  Future<int> _soSpTrongKho(String maSp) async {
    final quanLySanPham = QuanLySanPham();
    return await quanLySanPham.soSpTrongKho(maSp);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: quanLyXuatKho.tongSp,
      itemBuilder: (context, index) {
        final sanPham = quanLyXuatKho.laySp[index];
        soLuongControllers.putIfAbsent(
          sanPham.maSp!,
          () => TextEditingController(text: sanPham.soLuongSp.toString()),
        );
        suaPhieu.putIfAbsent(sanPham.maSp.toString(), () => false);
        Future.microtask(() async {
          final sl = await _soSpTrongKho(sanPham.maSp!);
          if (soSpTrongKho[sanPham.maSp] != sl ||
              soSpTrongKho[sanPham.maSp] == null) {
            setState(() {
              soSpTrongKho[sanPham.maSp!] = sl;
            });
          }
        });
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
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
                            Text(
                              'Giá bán: ${dinhDangSo.format(sanPham.giaBanSp)}',
                            ),
                            Row(
                              children: [
                                Text('Số lượng: '),
                                SizedBox(
                                  width: 40,
                                  child: TextField(
                                    controller:
                                        soLuongControllers[sanPham.maSp],
                                    decoration: const InputDecoration(
                                      counterText: '',
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 0,
                                        horizontal: 0,
                                      ),
                                      border: OutlineInputBorder(),
                                    ),
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
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : Expanded(
                        flex: 7,
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(color: Colors.black, fontSize: 16),
                            children: [
                              TextSpan(text: 'Tên: ${sanPham.tenSp}\n'),
                              TextSpan(
                                text:
                                    'Giá bán: ${dinhDangSo.format(sanPham.giaBanSp)}\n',
                              ),
                              TextSpan(
                                text:
                                    'Số lượng: ${dinhDangSo.format(sanPham.soLuongSp)}',
                              ),
                              (soSpTrongKho[sanPham.maSp] ?? 0) <=
                                      sanPham.soLuongSp
                                  ? TextSpan(
                                      text: ' (tối đa)\n',
                                      style: TextStyle(color: Colors.red),
                                    )
                                  : TextSpan(text: '\n'),
                              TextSpan(
                                text:
                                    'Tổng: ${dinhDangSo.format(quanLyXuatKho.tienBan(index))}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      (suaPhieu[sanPham.maSp.toString()] ?? false)
                          ? IconButton(
                              icon: Icon(Icons.save, color: Colors.blue),
                              onPressed: () async {
                                int giaTri = int.parse(
                                  soLuongControllers[sanPham.maSp]!.text
                                      .replaceAll(',', ''),
                                );
                                final sl = soSpTrongKho[sanPham.maSp] ?? 0;
                                sanPham.soLuongSp = giaTri >= sl ? sl : giaTri;
                                await quanLyXuatKho.suaPhieu(sanPham);
                                await quanLyXuatKho.hienSp(index: index);
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
                          soLuongControllers[sanPham.maSp]?.dispose();
                          soLuongControllers.remove(sanPham.maSp);
                          suaPhieu.remove(sanPham.maSp);
                          await quanLyXuatKho.xoaSp(index);
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
