import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/imovel_model.dart';
import '../services/api_service.dart';

class CadastroImovelScreen extends StatefulWidget {
  const CadastroImovelScreen({super.key});

  @override
  State<CadastroImovelScreen> createState() => _CadastroImovelScreenState();
}

class _CadastroImovelScreenState extends State<CadastroImovelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _latController = TextEditingController();
  final _lonController = TextEditingController();
  final _valorController = TextEditingController();
  final _areaController = TextEditingController();

  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  Future<void> _salvarImovel() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);


    final novoImovel = Imovel(
      investidorId: 1, 
      titulo: _tituloController.text,
      enderecoCompleto: _enderecoController.text,
      latitude: double.parse(_latController.text.replaceAll(',', '.')),
      longitude: double.parse(_lonController.text.replaceAll(',', '.')),
      valorCompra: double.tryParse(_valorController.text.replaceAll(',', '.')),
      areaM2: double.tryParse(_areaController.text.replaceAll(',', '.')),
    );

    final imovelSalvo = await _apiService.cadastrarImovel(novoImovel);

    setState(() => _isLoading = false);

    if (imovelSalvo != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imóvel salvo com sucesso!'), backgroundColor: Colors.green),
      );
    
      Navigator.pop(context, true); 
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao salvar imóvel.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Novo Imóvel', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _tituloController,
                label: 'Título (Ex: Prédio Av. Paulista)',
                icon: Icons.title,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _enderecoController,
                label: 'Endereço Completo',
                icon: Icons.location_on,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _latController,
                      label: 'Latitude (Ex: -23.55)',
                      icon: Icons.map,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _lonController,
                      label: 'Longitude (Ex: -46.63)',
                      icon: Icons.map,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _valorController,
                      label: 'Valor (R\$)',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _areaController,
                      label: 'Área (m²)',
                      icon: Icons.square_foot,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _salvarImovel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C853),
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('SALVAR IMÓVEL', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Campo obrigatório';
        }
        return null;
      },
    );
  }
}