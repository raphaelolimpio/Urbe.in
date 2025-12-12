import 'package:flutter/material.dart';
import '../models/usuario_model.dart';
import '../services/api_service.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart'; 
import '../components/primary_button.dart';

class CadastroInvestidorScreen extends StatefulWidget {
  const CadastroInvestidorScreen({super.key});

  @override
  State<CadastroInvestidorScreen> createState() => _CadastroInvestidorScreenState();
}

class _CadastroInvestidorScreenState extends State<CadastroInvestidorScreen> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  final _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _cadastrar() async {
    if (_nomeController.text.isEmpty || _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos!')),
      );
      return;
    }
    setState(() => _isLoading = true);

    final novoUsuario = Usuario(
      nome: _nomeController.text,
      email: _emailController.text,
      tipoUsuario: 'investidor',
      senha: _senhaController.text,
    );

    final usuarioCriado = await _apiService.cadastrarUsuario(novoUsuario);
    setState(() => _isLoading = false);

    if (usuarioCriado != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bem-vindo, ${usuarioCriado.nome}!'), backgroundColor: AppColors.primary),
      );
      _nomeController.clear();
      _emailController.clear();
      _senhaController.clear();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao cadastrar.'), backgroundColor: AppColors.riskHigh),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 4,
              color: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Urbe.in',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headingBig,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Crie sua conta de investidor',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 32),
                    
                    _buildTextField(
                      controller: _nomeController,
                      label: 'Nome Completo',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _emailController,
                      label: 'E-mail',
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _senhaController,
                      label: 'Senha',
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    const SizedBox(height: 24),

                    PrimaryButton(
                      text: "CADASTRAR",
                      onPressed: _cadastrar,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.caption.copyWith(fontSize: 14),
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
      ),
    );
  }
}