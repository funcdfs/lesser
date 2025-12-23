/// 数字格式化工具类
///
/// 将数字转换为带有“千”、“万”、“亿”后缀的缩写字符串。
///
/// 规则：
/// - 小于 1,000：保持原样，如 "999"
/// - 1,000 ~ 9,999：显示为 "x.x 千"，如 "1.2 千"
/// - 10,000 ~ 99,999,999：显示为 "x.x 万"，如 "1.2 万"
/// - 大于等于 100,000,000：显示为 "x.x 亿"，如 "1.2 亿"
String formatCount(int count) {
  if (count < 1000) {
    return count.toString();
  } else if (count < 10000) {
    // 1.2 千
    return '${(count / 1000).toStringAsFixed(1)} 千'.replaceAll('.0 千', ' 千');
  } else if (count < 100000000) {
    // 1.2 万
    return '${(count / 10000).toStringAsFixed(1)} 万'.replaceAll('.0 万', ' 万');
  } else {
    // 1.2 亿
    return '${(count / 100000000).toStringAsFixed(1)} 亿'.replaceAll(
      '.0 亿',
      ' 亿',
    );
  }
}
