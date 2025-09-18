import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_shop/GiaoDien/thay_doi_san_pham.dart';
import 'package:my_shop/MoHinh/san_pham.dart';
import 'package:my_shop/QuanLy/quan_ly_san_pham.dart';
import 'package:provider/provider.dart';

class HienThiSanPham extends StatefulWidget {
  static const duongDan = '/sanPham';
  const HienThiSanPham({super.key});

  @override
  State<HienThiSanPham> createState() => _HienThiSanPhamState();
}

class _HienThiSanPhamState extends State<HienThiSanPham> {
  String tuKhoa = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý sản phẩm'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(ThayDoiSanPham.duongDan);
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: Consumer<QuanLySanPham>(
        builder: (context, quanLySanPham, _) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 300,
                  child: TextField(
                    autofocus: false,
                    decoration: InputDecoration(
                      labelText: 'Tìm kiếm',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() {
                      tuKhoa = value;
                    }),
                  ),
                ),
              ),
              Expanded(child: DanhSachSanPham(quanLySanPham, tuKhoa: tuKhoa)),
            ],
          );
        },
      ),
    );
  }
}

class DanhSachSanPham extends StatefulWidget {
  const DanhSachSanPham(this._quanLySanPham, {super.key, this.tuKhoa = ''});
  final QuanLySanPham _quanLySanPham;
  final String tuKhoa;

  @override
  State<DanhSachSanPham> createState() => _DanhSachSanPhamState();
}

class _DanhSachSanPhamState extends State<DanhSachSanPham> {
  late final QuanLySanPham quanLySanPham;
  final dinhDangSo = NumberFormat('#,###');
  @override
  void initState() {
    super.initState();
    quanLySanPham = widget._quanLySanPham;
    _khoiTao();
  }

  Future<void> _khoiTao() async {
    await quanLySanPham.hienSp();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: quanLySanPham.tongSp,
      itemBuilder: (context, index) {
        final sanPham = quanLySanPham.laySp[index];
        if (!(widget.tuKhoa.trim().toLowerCase().isEmpty ||
            sanPham.tenSp!.toLowerCase().contains(
              widget.tuKhoa.toLowerCase(),
            ))) {
          return const SizedBox.shrink();
        }
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ClipOval(
                  child: Image.network(
                    sanPham.hinhAnhSp!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: 16),
                      children: [
                        TextSpan(text: 'Tên: ${sanPham.tenSp}\n'),
                        TextSpan(
                          text:
                              'Giá mua: ${dinhDangSo.format(sanPham.giaMuaSp)}\n',
                        ),
                        TextSpan(
                          text:
                              'Giá bán: ${dinhDangSo.format(sanPham.giaBanSp)}\n',
                        ),
                        TextSpan(text: 'Số lượng: '),
                        sanPham.soLuongSp == 0
                            ? TextSpan(
                                text: 'hết hàng',
                                style: TextStyle(color: Colors.red),
                              )
                            : TextSpan(
                                text: dinhDangSo.format(sanPham.soLuongSp),
                              ),
                      ],
                    ),
                  ),
                ),
                MenuSanPham(sanPham),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MenuSanPham extends StatelessWidget {
  final SanPham sanPham;
  const MenuSanPham(this.sanPham, {super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'sua') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => ThayDoiSanPham(sanPham: sanPham),
            ),
          );
        }
        if (value == 'xoa') {
          final quanLySanPham = context.read<QuanLySanPham>();
          quanLySanPham.xoaSp(sanPham);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'sua',
          child: Row(
            children: [
              Icon(Icons.edit, color: Colors.orange),
              SizedBox(width: 8),
              Text('Sửa'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'xoa',
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red),
              SizedBox(width: 8),
              Text('Xóa'),
            ],
          ),
        ),
      ],
    );
  }
}
