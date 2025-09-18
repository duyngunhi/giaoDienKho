import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_shop/MoHinh/san_pham.dart';
import 'package:my_shop/QuanLy/quan_ly_hoa_don.dart';
import 'package:provider/provider.dart';

class HienThiLichSu extends StatefulWidget {
  static final String duongDan = '/lichSuKho';
  const HienThiLichSu({super.key});

  @override
  State<HienThiLichSu> createState() => _HienThiLichSuState();
}

class _HienThiLichSuState extends State<HienThiLichSu> {
  String xuLy = 'Tất cả';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lịch sử kho')),
      body: Consumer<QuanLyHoaDon>(
        builder: (context, quanLyHoaDon, _) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: BoLocButton('Tất cả', xuLy, (loai) {
                      setState(() {
                        xuLy = loai;
                      });
                    }),
                  ),
                  Expanded(
                    child: BoLocButton('Xuất kho', xuLy, (loai) {
                      setState(() {
                        xuLy = loai;
                      });
                    }),
                  ),
                  Expanded(
                    child: BoLocButton('Nhập kho', xuLy, (loai) {
                      setState(() {
                        xuLy = loai;
                      });
                    }),
                  ),
                ],
              ),
              Expanded(child: DanhSachHoaDon(quanLyHoaDon, xuLy)),
            ],
          );
        },
      ),
    );
  }
}

class DanhSachHoaDon extends StatefulWidget {
  const DanhSachHoaDon(this.quanLyHoaDon, this.xuLy, {super.key});
  final QuanLyHoaDon quanLyHoaDon;
  final String xuLy;

  @override
  State<DanhSachHoaDon> createState() => _DanhSachLichSuState();
}

class _DanhSachLichSuState extends State<DanhSachHoaDon> {
  Map<String, bool> anHd = {};

  @override
  void initState() {
    super.initState();
    _khoiTao();
  }

  void _khoiTao() async {
    await widget.quanLyHoaDon.lichSuHd();
  }

  String dinhDangNgay(DateTime ngayTao) {
    return DateFormat('dd/MM/yyyy').format(ngayTao);
  }

  String dinhDangSo(int so) {
    return NumberFormat("#,###").format(so);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.quanLyHoaDon.tongHd,
      itemBuilder: (context, index) {
        final hoaDon = widget.quanLyHoaDon.layHd[index];
        bool? loaiHD;
        if (widget.xuLy == 'Xuất kho') {
          loaiHD = false;
        }
        if (widget.xuLy == 'Nhập kho') {
          loaiHD = true;
        }
        if (anHd.length < widget.quanLyHoaDon.tongHd) {
          anHd[hoaDon.maHd!] = false;
        }
        return Column(
          children: [
            (loaiHD != hoaDon.loaiHd && loaiHD != null)
                ? SizedBox.shrink()
                : Card(
                    margin: EdgeInsets.all(5),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  children: [
                                    hoaDon.loaiHd==true
                                        ? TextSpan(
                                            text: 'Nhập kho',
                                            style: TextStyle(
                                              color: Colors.green,
                                            ),
                                          )
                                        : TextSpan(
                                            text: 'Xuất kho',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                  ],
                                ),
                              ),
                              Spacer(),
                              Text(dinhDangNgay(hoaDon.ngayTao!)),
                            ],
                          ),
                          const Divider(),
                          Row(
                            children: [
                              Text(
                                'Tổng tiền: ${dinhDangSo(hoaDon.tongTien!)}',
                              ),
                              Spacer(),
                              anHd[hoaDon.maHd!] == true
                                  ? IconButton(
                                      onPressed: () {
                                        setState(() {
                                          anHd[hoaDon.maHd!] = false;
                                        });
                                      },
                                      icon: Icon(Icons.expand_more),
                                    )
                                  : IconButton(
                                      onPressed: () {
                                        setState(() {
                                          anHd[hoaDon.maHd!] = true;
                                        });
                                      },
                                      icon: Icon(Icons.expand_less),
                                    ),
                            ],
                          ),
                          anHd[hoaDon.maHd] == true
                              ? ChiTietHoaDon(hoaDon.listSp!, hoaDon.loaiHd!)
                              : SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ),
          ],
        );
      },
    );
  }
}

class BoLocButton extends StatelessWidget {
  const BoLocButton(this.boLoc, this.xuLy, this.hamChon, {super.key});
  final String boLoc;
  final Function(String) hamChon;
  final String xuLy;

  @override
  Widget build(BuildContext context) {
    final duocChon = boLoc == xuLy ? true : false;
    return TextButton.icon(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(
          duocChon ? Colors.amber : const Color.fromARGB(255, 221, 220, 220),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
      onPressed: () {
        hamChon(boLoc);
      },
      label: Text(
        boLoc,
        style: TextStyle(
          fontWeight: duocChon ? FontWeight.bold : FontWeight.normal,
          color: duocChon ? Colors.blue : Colors.black,
        ),
      ),
    );
  }
}

class ChiTietHoaDon extends StatelessWidget {
  const ChiTietHoaDon(this.listSanPham, this.loaiHd, {super.key});
  final List<SanPham> listSanPham;
  final bool loaiHd;

  @override
  Widget build(BuildContext context) {
    String dinhDangSo(int so) {
      return NumberFormat("#,###").format(so);
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Text('Tên', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'Giá',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'Số lượng',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                'Thành tiền',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        Column(
          children: listSanPham.map((sanPham) {
            final giaSp = loaiHd ? sanPham.giaMuaSp : sanPham.giaBanSp;
            return Row(
              children: [
                Expanded(flex: 3, child: Text('${sanPham.tenSp}')),
                Expanded(
                  flex: 2,
                  child: Text(dinhDangSo(giaSp), textAlign: TextAlign.center),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    dinhDangSo(sanPham.soLuongSp),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    dinhDangSo(sanPham.soLuongSp * giaSp),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
