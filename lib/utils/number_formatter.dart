
/// Formats a number into a compact string with suffixes like '千', '万', '亿'.
/// 
/// Rules:
/// < 1,000: '999'
/// < 10,000: '1.2千' (1 decimal)
/// < 100,000,000: '1.2万' (1 decimal)
/// >= 100,000,000: '1.2亿' (1 decimal)
String formatCount(int count) {
  if (count < 1000) {
    return count.toString();
  } else if (count < 10000) {
    // 1.2千
    return '${(count / 1000).toStringAsFixed(1)}千'.replaceAll('.0千', '千');
  } else if (count < 100000000) {
    // 1.2万
    return '${(count / 10000).toStringAsFixed(1)}万'.replaceAll('.0万', '万');
  } else {
    // 1.2亿
    return '${(count / 100000000).toStringAsFixed(1)}亿'.replaceAll('.0亿', '亿');
  }
}
