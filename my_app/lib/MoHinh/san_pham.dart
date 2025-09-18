class SanPham {
  String? maSp;
  String? tenSp;
  int giaMuaSp = 0;
  int giaBanSp = 0;
  int soLuongSp = 0;
  String? hinhAnhSp;
  SanPham({
    this.maSp,
    this.tenSp,
    this.giaMuaSp = 0,
    this.giaBanSp = 0,
    this.soLuongSp = 0,
    this.hinhAnhSp,
  });
  SanPham copyWith({
    String? maSp,
    String? tenSp,
    int? giaMuaSp,
    int? giaBanSp,
    int? soLuongSp,
    String? hinhAnhSp,
  }) {
    return SanPham(
      maSp: maSp ?? this.maSp,
      tenSp: tenSp ?? this.tenSp,
      giaMuaSp: giaMuaSp ?? this.giaMuaSp,
      giaBanSp: giaBanSp ?? this.giaBanSp,
      soLuongSp: soLuongSp ?? this.soLuongSp,
      hinhAnhSp: hinhAnhSp ?? this.hinhAnhSp,
    );
  }

  Map<String, dynamic> taoJson() {
    return {
      'maSp': maSp,
      'tenSp': tenSp,
      'giaMuaSp': giaMuaSp,
      'giaBanSp': giaBanSp,
      'soLuongSp': soLuongSp,
      'hinhAnhSp': hinhAnhSp,
    };
  }

  static SanPham nhanJSon(Map<String, dynamic> json) {
    return SanPham(
      maSp: json['maSp'].toString(),
      tenSp: json['tenSp'].toString(),
      giaMuaSp: (json['giaMuaSp'] as num).toInt(),
      giaBanSp: (json['giaBanSp'] as num).toInt(),
      soLuongSp: (json['soLuongSp'] as num).toInt(),
      hinhAnhSp: json['hinhAnhSp'].toString(),
    );
  }
}
