import 'package:flutter/material.dart';
import '../models/imovel_model.dart';
import '../services/api_service.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart'; 
import '../components/primary_button.dart';

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
        const SnackBar(content: Text('Imóvel salvo!'), backgroundColor: AppColors.primary),
      );
      Navigator.pop(context, true); 
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao salvar.'), backgroundColor: AppColors.riskHigh),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Novo Imóvel', style: AppTextStyles.titleList),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
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
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _latController,
                      label: 'Latitude',
                      icon: Icons.map,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _lonController,
                      label: 'Longitude',
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
              
              PrimaryButton(
                text: "Salvar Imóvel",
                onPressed: _salvarImovel,
                isLoading: _isLoading,
                icon: Icons.save_outlined,
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
      style: AppTextStyles.body,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.caption.copyWith(fontSize: 14), 
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Campo obrigatório';
        return null;
      },
    );
  }
}