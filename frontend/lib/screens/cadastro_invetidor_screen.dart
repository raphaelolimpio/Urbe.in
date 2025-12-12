import 'package:flutter/material.dart';
import 'package:frontend/models/usuario_model.dart';
import 'package:frontend/services/api_service.dart';
import 'package:google_fonts/google_fonts.dart';

class CadastroInvetidorScreen extends StatefulWidget {
  const CadastroInvetidorScreen({Key? key}) : super(key: key);

  @override
  State<CadastroInvetidorScreen> createState() =>
      _CadastroInvetidorScreenState();
}

class _CadastroInvetidorScreenState extends State<CadastroInvetidorScreen> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  final _apiSeervice = ApiService();
  bool _isLoading = false;

  Future<void> _cadastrar() async {
    if (_nomeController.text.isEmpty || _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos')),
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
    final usuaruioCriado = await _apiSeervice.cadastrarUsuario(novoUsuario);

    setState(() => _isLoading = false);

    if (usuaruioCriado != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Bem-vindo, ${usuaruioCriado.nome}! ID: ${usuaruioCriado.id}',
          ),
          backgroundColor: Colors.green,
        ),
      );
      _nomeController.clear();
      _emailController.clear();
      _senhaController.clear();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Erro ao cadastrar. Verifique o console ou se email ja existe',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Urbe.in',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff00c853),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Crie sua conta de investidor',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        controller: _nomeController,
                        decoration: const InputDecoration(
                          labelText: 'Nome Completo',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline)
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email_outlined)
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _senhaController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Senha',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _cadastrar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff00c853),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  'Cadastrar',
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
