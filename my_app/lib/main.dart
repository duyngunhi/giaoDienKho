import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_shop/DichVu/pocketbase_client.dart';
import 'package:my_shop/GiaoDien/hien_thi_nhap_kho.dart';
import 'package:my_shop/GiaoDien/hien_thi_san_pham.dart';
import 'package:my_shop/GiaoDien/hien_thi_xuat_kho.dart';
import 'package:my_shop/GiaoDien/hien_thi_lich_su.dart';
import 'package:my_shop/GiaoDien/thay_doi_san_pham.dart';
import 'package:my_shop/QuanLy/quan_ly_hoa_don.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:my_shop/QuanLy/quan_ly_nhap_kho.dart';
import 'package:my_shop/QuanLy/quan_ly_xuat_kho.dart';
import 'package:provider/provider.dart';
import 'package:my_shop/QuanLy/quan_ly_san_pham.dart';

Future<void> main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();
  final pb = await getPocketbaseInstance();

  await pb.collection('users').authWithPassword('duy@gmail.com', '12345678');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.purple,
      secondary: Colors.deepOrange,
      surface: Colors.white,
      surfaceTint: Colors.grey[200],
    );
    final themeData = ThemeData(
      fontFamily: 'Lato',
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 4,
        shadowColor: colorScheme.shadow,
      ),
      dialogTheme: DialogThemeData(
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(color: colorScheme.onSurface, fontSize: 20),
      ),
    );
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => QuanLySanPham()),
        ChangeNotifierProvider(create: (ctx) => QuanLyNhapKho()),
        ChangeNotifierProvider(create: (ctx) => QuanLyHoaDon()),
        ChangeNotifierProvider(create: (ctx) => QuanLyXuatKho()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'My Shop',
        theme: themeData,
        routes: {
          HienThiSanPham.duongDan: (ctx) => HienThiSanPham(),
          HienThiNhapKho.duongDan: (ctx) => HienThiNhapKho(),
          HienThiXuatKho.duongDan: (ctx) => HienThiXuatKho(),
          HienThiLichSu.duongDan: (ctx) => HienThiLichSu(),
          ThayDoiSanPham.duongDan: (ctx) => ThayDoiSanPham(),
        },
        home: Builder(
          builder: (ctx) => Scaffold(
            appBar: AppBar(
              title: Row(
                children: [const Text('Trang chủ'), Spacer(), MenuDieuHuong()],
              ),
            ),
            body: Consumer<QuanLyHoaDon>(
              builder: (context, quanLyHoaDon, _) {
                return Column(children: [BoLocThongKe(quanLyHoaDon)]);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class BoLocThongKe extends StatefulWidget {
  const BoLocThongKe(this.quanLyHoaDon, {super.key});
  final QuanLyHoaDon quanLyHoaDon;

  @override
  State<BoLocThongKe> createState() => _BoLocThongKeState();
}

class _BoLocThongKeState extends State<BoLocThongKe> {
  DateTime? tuNgay;
  DateTime? denNgay;
  bool nhap = true;
  bool tien = false;
  final dinhDangNgay = DateFormat('dd/MM/yyyy');
  @override
  void initState() {
    super.initState();
    _khoiTao();
  }

  Future<void> _khoiTao() async {
    await widget.quanLyHoaDon.lichSuHd(loc: false);
  }

  Future<void> _tuNgay(BuildContext context) async {
    final DateTime? chonNgay = await showDatePicker(
      context: context,
      initialDate: tuNgay ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (chonNgay != null && chonNgay != tuNgay) {
      setState(() {
        if (denNgay != null) {
          if (chonNgay.isAfter(tuNgay!)) {
            tuNgay = denNgay;
          } else {
            tuNgay = chonNgay;
          }
        } else {
          tuNgay = chonNgay;
        }
      });
    }
  }

  Future<void> _denNgay(BuildContext context) async {
    final DateTime? chonNgay = await showDatePicker(
      context: context,
      initialDate: denNgay ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (chonNgay != null && chonNgay != denNgay) {
      setState(() {
        if (tuNgay != null) {
          if (chonNgay.isBefore(tuNgay!)) {
            denNgay = tuNgay;
          } else {
            denNgay = chonNgay;
          }
        } else {
          denNgay = chonNgay;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            PopupMenuButton<String>(
              child: IgnorePointer(
                ignoring: true,
                child: ElevatedButton(
                  onPressed: () {},
                  child: SizedBox(
                    width: 97,
                    child: Text(
                      nhap ? 'Nhập kho' : 'Xuất kho',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              onSelected: (value) {
                setState(() {
                  if (value == 'nk') {
                    nhap = true;
                  } else {
                    nhap = false;
                  }
                });
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem(value: 'xk', child: Text('Xuất kho')),
                PopupMenuItem(value: 'nk', child: Text('Nhập kho')),
              ],
            ),
            Spacer(),
            PopupMenuButton<String>(
              child: IgnorePointer(
                ignoring: true,
                child: ElevatedButton(
                  onPressed: () {},
                  child: SizedBox(
                    width: 97,
                    child: Text(
                      tien ? 'Doanh số' : 'Số hoá đơn',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              onSelected: (value) {
                setState(() {
                  if (value == 'ds') {
                    tien = true;
                  } else {
                    tien = false;
                  }
                });
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem(value: 'ds', child: Text('Doanh số')),
                PopupMenuItem(value: 'hd', child: Text('Số hoá đơn')),
              ],
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () => _tuNgay(context),
                icon: Icon(Icons.date_range),
                label: Text(
                  tuNgay == null ? 'chọn ngày' : dinhDangNgay.format(tuNgay!),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(' đến ', textAlign: TextAlign.center),
            ),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () => _denNgay(context),
                icon: Icon(Icons.date_range),
                label: Text(
                  denNgay == null ? 'chọn ngày' : dinhDangNgay.format(denNgay!),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: Text(
                (tien ? 'DOANH SỐ' : 'SỐ HOÁ ĐƠN') +
                    (nhap ? ' NHẬP KHO' : ' XUẤT KHO'),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Row(
          children: [
            SizedBox(width: 8),
            Text(
              tien ? '1,000 đồng' : 'hoá đơn',
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: 350,
            height: 350,
            child: ThongKe(
              widget.quanLyHoaDon,
              nhap: nhap,
              tien: tien,
              tuNgay: tuNgay,
              denNgay: denNgay,
            ),
          ),
        ),
      ],
    );
  }
}

class ThongKe extends StatelessWidget {
  const ThongKe(
    this.quanLyHoaDon, {
    super.key,
    required this.nhap,
    required this.tien,
    this.tuNgay,
    this.denNgay,
  });
  final QuanLyHoaDon quanLyHoaDon;
  final DateTime? tuNgay;
  final DateTime? denNgay;
  final bool nhap;
  final bool tien;

  @override
  Widget build(BuildContext context) {
    final List<FlSpot> dsFlspot = [];
    final mapThongKe = quanLyHoaDon.thongKeNgay(tuNgay, denNgay, nhap, tien);
    if (mapThongKe.isEmpty) {
      return const Center(child: Text('Không có dữ liệu'));
    }
    final dsNgay = mapThongKe.keys.toList()..sort();
    for (int x = 0; x < mapThongKe.length; x++) {
      final ngay = dsNgay[x];
      final y = mapThongKe[ngay]!.toDouble();
      dsFlspot.add(FlSpot(x.toDouble(), y));
    }
    return LineChart(
      LineChartData(
        borderData: FlBorderData(show: true),
        minY: 0,
        lineBarsData: [
          LineChartBarData(
            spots: dsFlspot,
            barWidth: 2,
            color: Colors.red,
            dotData: FlDotData(show: true),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              interval: 1,
              showTitles: true,
              reservedSize: 20,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                String ngay = DateFormat('dd/MM').format(dsNgay[index]);
                return Transform.rotate(
                  angle: -1,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(ngay, style: TextStyle(fontSize: 9)),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              interval: tien ? null : 1,
              showTitles: true,
              reservedSize: 20,
              getTitlesWidget: (value, meta) => Text(
                (value ~/ (tien ? 1000 : 1)).toInt().toString(),
                style: TextStyle(fontSize: 10),
              ),
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
      ),
    );
  }
}

class MenuDieuHuong extends StatelessWidget {
  const MenuDieuHuong({super.key});
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.menu),
      offset: Offset(10, 50),
      onSelected: (value) {
        if (value == 'sp') {
          Navigator.of(context).pushNamed(HienThiSanPham.duongDan);
        }
        if (value == 'nk') {
          Navigator.of(context).pushNamed(HienThiNhapKho.duongDan);
        }
        if (value == 'xk') {
          Navigator.of(context).pushNamed(HienThiXuatKho.duongDan);
        }
        if (value == 'ls') {
          Navigator.of(context).pushNamed(HienThiLichSu.duongDan);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem(
          value: 'sp',
          child: Text(
            'Sản phẩm',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const PopupMenuItem(
          value: 'xk',
          child: Text(
            'Xuất Kho',
            style: TextStyle(
              color: Colors.red,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const PopupMenuItem(
          value: 'nk',
          child: Text(
            'Nhập Kho',
            style: TextStyle(
              color: Colors.green,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const PopupMenuItem(
          value: 'ls',
          child: Text(
            'Lịch Sử',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
