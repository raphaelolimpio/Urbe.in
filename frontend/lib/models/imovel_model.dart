class Imovel {
  final int? id;
  final int investidorId;
  final String titulo;
  final String enderecoCompleto;
  final double latitude;
  final double longitude;
  final double? areaM2;
  final double? valorCompra;

  Imovel({
    this.id,
    required this.investidorId,
    required this.titulo,
    required this.enderecoCompleto,
    required this.latitude,
    required this.longitude,
    this.areaM2,
    this.valorCompra,
  });

  factory Imovel.fromJson(Map<String, dynamic> json) {
    return Imovel(
      id: json['id'],
      investidorId: json['investidor_id'] ?? 0,
      titulo: json['titulo'] ?? '',
      enderecoCompleto: json['endereco_completo'] ?? '',
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
      areaM2: json['area_m2'] != null ? double.tryParse(json['area_m2'].toString()) : null,
      valorCompra: json['valor_compra'] != null ? double.tryParse(json['valor_compra'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'investidor_id': investidorId,
      'titulo': titulo,
      'endereco_completo': enderecoCompleto,
      'latitude': latitude,
      'longitude': longitude,
      'area_m2': areaM2,
      'valor_compra': valorCompra,
    };
  }
}