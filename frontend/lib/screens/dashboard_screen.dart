import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/models/imovel_model.dart';
import 'package:frontend/services/api_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/screens/cadastro_imovel_screen.dart';
import 'detalhe_imovel_screen.dart';

class DashboardScreen extends StatefulWidget{
  const DashboardScreen({Key? key}) : super (key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}
class _DashboardScreenState extends State<DashboardScreen>{
  final ApiService _apiService = ApiService();
  late Future<List<Imovel>> _imoveisFuture;

  @override
  void initState() {
    super.initState();
    _carregarImoveis();
  }
  void _carregarImoveis() {
    setState(() {
      _imoveisFuture = _apiService.buscarImoveis();
    });
  }

  @override
  Widget build (BuildContext context){
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Meus Imóveis',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _carregarImoveis,
          ),
        ],
      ),
      body: FutureBuilder<List<Imovel>>(
        future: _imoveisFuture,
       builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar imóveis ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhum imóvel cadastrado'));
          }
          final imoveis = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.only(top: 16),
            itemCount: imoveis.length,
            itemBuilder: (context, index) {
              final imovel = imoveis[index];
              return Card(
                margin: EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF00C853).withOpacity(0.1),
                    child: Icon(Icons.business, color: const Color(0xFF00C853)),
                  ),
                  title: Text(imovel.titulo,
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text(imovel.enderecoCompleto,
                        style: GoogleFonts.inter(fontSize: 14),
                      ),
                      SizedBox(height: 4),
                      Text('${imovel.valorCompra?.toStringAsFixed(2) ?? "0.00"}',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetalheImovelScreen(imovel: imovel),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final bool? recarregar = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CadastroImovelScreen()),
          );
          if (recarregar == true) {
            _carregarImoveis();
          }
        },
        backgroundColor: const Color(0xFF00C853),
        icon: Icon(Icons.add, color: Colors.white,),
        label: Text('Novo Imóvel',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}