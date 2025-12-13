class AppFormatters {
  static String formatCurrency(double? value) {
    if (value == null) return "R\$ 0,00";
    
    String valueStr = value.toStringAsFixed(2);
  
    List<String> parts = valueStr.split('.');
    String wholePart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : '00';
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String formattedWhole = wholePart.replaceAllMapped(reg, (Match match) => '${match[1]}.');
    
    return 'R\$ $formattedWhole,$decimalPart';
  }
  static String formatArea(double? value) {
    if (value == null) return "0 m²";
    
    if (value % 1 == 0) {
      return "${value.toInt()} m²";
    }
    return "${value.toStringAsFixed(1).replaceAll('.', ',')} m²";
  }
}