import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/imovel_model.dart';
import '../services/api_service.dart';

class DetalheImovelScreen extends StatefulWidget {
  final Imovel imovel;

  const DetalheImovelScreen({super.key, required this.imovel});

  @override
  State<DetalheImovelScreen> createState() => _DetalheImovelScreenState();
}

class _DetalheImovelScreenState extends State<DetalheImovelScreen> {
  final ApiService _apiService = ApiService();
  bool _analisando = false;
  Map<String, dynamic>? _resultadoAnalise;

  Future<void> _rodarAnalise() async {
    setState(() => _analisando = true);

    // Chama o Backend Python
    final resultado = await _apiService.analisarVocacao(widget.imovel.id!);

    setState(() {
      _analisando = false;
      _resultadoAnalise = resultado;
    });

    if (resultado == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao analisar vocação.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.imovel.titulo,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card com dados básicos
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      Icons.location_on,
                      widget.imovel.enderecoCompleto,
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _buildInfoRow(
                            Icons.attach_money,
                            'R\$ ${widget.imovel.valorCompra?.toStringAsFixed(2) ?? '0.00'}',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInfoRow(
                            Icons.square_foot,
                            '${widget.imovel.areaM2?.toStringAsFixed(0) ?? '0'} m²',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Botão de Análise
            if (_resultadoAnalise == null)
              ElevatedButton.icon(
                onPressed: _analisando ? null : _rodarAnalise,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: _analisando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.analytics),
                label: Text(
                  _analisando
                      ? 'ANALISANDO ENTORNO...'
                      : 'ANALISAR VOCAÇÃO COM IA',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),

            // Resultado da Análise (Aparece depois que clica)
            if (_resultadoAnalise != null) ...[
              const SizedBox(height: 24),
              Text(
                'Resultado da Inteligência',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                color: Colors.green[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.green.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        _resultadoAnalise!['setor_sugerido'] ?? 'Indefinido',
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _resultadoAnalise!['nicho_especifico'] ?? '',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.green[900],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Divider(height: 24),
                      Text(
                        "Score de Compatibilidade: ${_resultadoAnalise!['score_compatibilidade']}%",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Dados Brutos do Entorno:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              Text(_resultadoAnalise!['explicacao_ia'] ?? ''),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: GoogleFonts.inter(fontSize: 14))),
      ],
    );
  }
}
