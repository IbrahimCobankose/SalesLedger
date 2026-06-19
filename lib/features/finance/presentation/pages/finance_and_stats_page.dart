import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sales_ledger/features/finance/presentation/widgets/summary_card.dart';
import 'package:sales_ledger/features/finance/presentation/widgets/stat_chart.dart';
import 'package:sales_ledger/features/finance/presentation/pages/cash_flow_page.dart';

class FinanceAndStatsPage extends StatefulWidget {
  const FinanceAndStatsPage({super.key});

  @override
  State<FinanceAndStatsPage> createState() => _FinanceAndStatsPageState();
}

class _FinanceAndStatsPageState extends State<FinanceAndStatsPage> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  
  double _totalIncome = 0;
  double _totalExpense = 0;

  @override
  void initState() {
    super.initState();
    _fetchFinancialData();
  }

  Future<void> _fetchFinancialData() async {
    setState(() => _isLoading = true);
    try {
      final userId = _supabase.auth.currentUser!.id;

      // 1. Gelirler: Sadece kargo durumu 'completed' olan satışlar (Gereksinim 51)
      final salesResponse = await _supabase
          .from('sales')
          .select('total_amount')
          .eq('user_id', userId)
          .eq('status', 'completed');

      // 2. Giderler: Tüm alımlar
      final purchasesResponse = await _supabase
          .from('purchases')
          .select('total_amount')
          .eq('user_id', userId);

      double income = 0;
      for (var sale in salesResponse) {
        income += (sale['total_amount'] as num?)?.toDouble() ?? 0.0;
      }

      double expense = 0;
      for (var purchase in purchasesResponse) {
        expense += (purchase['total_amount'] as num?)?.toDouble() ?? 0.0;
      }

      if (mounted) {
        setState(() {
          _totalIncome = income;
          _totalExpense = expense;
        });
      }
    } catch (e) {
      debugPrint('Finans verileri yüklenirken hata: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final netProfit = _totalIncome - _totalExpense;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('Kasa Özeti', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _fetchFinancialData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SummaryCard(
                    title: 'Net Kâr',
                    amount: netProfit,
                    icon: Icons.account_balance_wallet,
                    isPrimary: true,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: SummaryCard(
                          title: 'Toplam Gelir',
                          amount: _totalIncome,
                          icon: Icons.arrow_downward,
                          iconColor: Colors.green.shade700,
                          iconBgColor: Colors.green.shade100,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SummaryCard(
                          title: 'Toplam Gider',
                          amount: _totalExpense,
                          icon: Icons.arrow_upward,
                          iconColor: colorScheme.error,
                          iconBgColor: colorScheme.errorContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Kasa Hareketleri Yönlendirme Butonu
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CashFlowPage()));
                      },
                      icon: const Icon(Icons.list_alt),
                      label: const Text('Kasa Hareketlerini Gör'),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  const StatChart(),
                ],
              ),
            ),
          ),
    );
  }
}