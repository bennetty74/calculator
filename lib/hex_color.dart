import 'dart:ui';

/// 十六进制颜色表示，#EEECF9
class HexColor extends Color {

  /// 从十六进制获取颜色int值
  static int getColorFromHex(String hexColor) {
    String color = hexColor.toUpperCase().replaceAll("#", "");
    if (color.length == 6) {
      color = "FF" + color;
    }
    int res = int.parse(color.toUpperCase(), radix: 16);

    return res;
  }

  HexColor(final String hexColor) : super(getColorFromHex(hexColor));
}
