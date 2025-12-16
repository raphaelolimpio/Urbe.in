import 'package:flutter/material.dart';
import '../models/imovel_model.dart';
import '../models/dashboard_model.dart';
import '../services/api_service.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/app_formatters.dart';
import '../components/finance_card.dart';
import '../components/imovel_card.dart';
import 'cadastro_imovel_screen.dart';
import 'detalhe_imovel_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();

  late Future<DashboardResumo> _dashboardFuture;
  late Future<List<Imovel>> _imoveisFuture;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  void _carregarDados() {
    setState(() {
      _dashboardFuture = _apiService.getDashboardMetrics();
      _imoveisFuture = _apiService.getImoveis();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Urbe.in Investimentos',
          style: AppTextStyles.titleList.copyWith(
            color: AppColors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _carregarDados,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: FutureBuilder<DashboardResumo>(
              future: _dashboardFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Erro ao carregar métricas",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                final data = snapshot.data!;

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: FinanceCard(
                            label: "Patrimônio Total",
                            value: AppFormatters.formatCurrency(
                              data.valorPatrimonio,
                            ),
                            icon: Icons.account_balance_wallet,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FinanceCard(
                            label: "Receita Mensal (Est.)",
                            value: AppFormatters.formatCurrency(
                              data.receitaMensalEstimada,
                            ),
                            icon: Icons.trending_up,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        "${data.totalImoveis} imóveis sob gestão",
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          Expanded(
            child: FutureBuilder<List<Imovel>>(
              future: _imoveisFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'Nenhum imóvel cadastrado.',
                      style: AppTextStyles.body,
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final imovel = snapshot.data![index];
                    return ImovelCard(
                      imovel: imovel,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DetalheImovelScreen(imovel: imovel),
                          ),
                        );
                        _carregarDados();
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final bool? recarregar = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CadastroImovelScreen(),
            ),
          );
          if (recarregar == true) _carregarDados();
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Novo Imóvel', style: AppTextStyles.buttonText),
      ),
    );
  }
}
