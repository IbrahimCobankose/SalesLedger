import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Verileri tek bir listede birleştirmek için model
class CashTransaction {
  final String title;
  final double amount;
  final DateTime date;
  final bool isIncome;

  CashTransaction({required this.title, required this.amount, required this.date, required this.isIncome});
}

class CashFlowPage extends StatefulWidget {
  const CashFlowPage({super.key});

  @override
  State<CashFlowPage> createState() => _CashFlowPageState();
}

class _CashFlowPageState extends State<CashFlowPage> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<CashTransaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    setState(() => _isLoading = true);
    try {
      final userId = _supabase.auth.currentUser!.id;
      List<CashTransaction> tempTransactions = [];

      // Gelirler (Sadece Teslim Edilen Satışlar)
      final sales = await _supabase
          .from('sales')
          .select()
          .eq('user_id', userId)
          .eq('status', 'completed');

      for (var s in sales) {
        String title = s['description'] ?? 'Satış Geliri';
        if (title.startsWith('Müşteri: ')) title = title.replaceFirst('Müşteri: ', 'Satış - ');
        
        tempTransactions.add(CashTransaction(
          title: title,
          amount: (s['total_amount'] as num?)?.toDouble() ?? 0.0,
          date: DateTime.parse(s['sale_date']).toLocal(),
          isIncome: true,
        ));
      }

      // Giderler (Alımlar)
      final purchases = await _supabase
          .from('purchases')
          .select()
          .eq('user_id', userId);

      for (var p in purchases) {
        String title = p['description'] ?? 'Alım Gideri';
        if (title.startsWith('Tedarikçi: ')) title = title.replaceFirst('Tedarikçi: ', 'Alım - ');

        tempTransactions.add(CashTransaction(
          title: title,
          amount: (p['total_amount'] as num?)?.toDouble() ?? 0.0,
          date: DateTime.parse(p['purchase_date']).toLocal(),
          isIncome: false,
        ));
      }

      // Tarihe göre yeniden eskiye sıralama
      tempTransactions.sort((a, b) => b.date.compareTo(a.date));

      if (mounted) {
        setState(() {
          _transactions = tempTransactions;
        });
      }
    } catch (e) {
      debugPrint('Hareketler yüklenirken hata: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('Kasa Hareketleri', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _transactions.isEmpty
              ? const Center(child: Text('Henüz bir kasa hareketi bulunmuyor.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _transactions.length,
                  separatorBuilder: (context, index) => Divider(height: 1, color: colorScheme.surfaceContainerHighest),
                  itemBuilder: (context, index) {
                    final t = _transactions[index];
                    final isIncome = t.isIncome;
                    
                    final bgColor = isIncome ? Colors.green.shade100 : Colors.red.shade100;
                    final iconColor = isIncome ? Colors.green.shade800 : Colors.red.shade800;
                    final amountColor = isIncome ? Colors.green.shade700 : colorScheme.error;
                    final sign = isIncome ? '+' : '-';
                    final dateStr = '${t.date.day}/${t.date.month}/${t.date.year} ${t.date.hour.toString().padLeft(2,'0')}:${t.date.minute.toString().padLeft(2,'0')}';

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
                            child: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: iconColor),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(t.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: colorScheme.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text(dateStr, style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant)),
                              ],
                            ),
                          ),
                          Text('$sign ₺${t.amount.toStringAsFixed(2)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: amountColor)),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}