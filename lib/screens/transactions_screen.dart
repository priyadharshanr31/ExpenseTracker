import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _searchQuery = '';
  String _selectedType = 'All Types';
  String _selectedCategory = 'All Categories';
  
  // Cache filtered transactions to avoid recalculating on every build
  List<dynamic>? _cachedFilteredTransactions;
  String? _lastSearchQuery;
  String? _lastSelectedType;
  String? _lastSelectedCategory;

  List<dynamic> _getFilteredTransactions(List<dynamic> allTransactions) {
    // Return cached results if filters haven't changed
    if (_cachedFilteredTransactions != null &&
        _lastSearchQuery == _searchQuery &&
        _lastSelectedType == _selectedType &&
        _lastSelectedCategory == _selectedCategory) {
      return _cachedFilteredTransactions!;
    }

    // Calculate new filtered results
    final filtered = allTransactions.where((t) {
      final matchesSearch = t.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.category.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesType = _selectedType == 'All Types' || t.type == _selectedType;
      final matchesCategory = _selectedCategory == 'All Categories' || t.category == _selectedCategory;
      return matchesSearch && matchesType && matchesCategory;
    }).toList();

    // Cache the results
    _cachedFilteredTransactions = filtered;
    _lastSearchQuery = _searchQuery;
    _lastSelectedType = _selectedType;
    _lastSelectedCategory = _selectedCategory;

    return filtered;
  }

  void _updateSearch(String value) {
    setState(() {
      _searchQuery = value;
      _cachedFilteredTransactions = null; // Invalidate cache
    });
  }

  void _updateTypeFilter(String? value) {
    setState(() {
      _selectedType = value!;
      _cachedFilteredTransactions = null; // Invalidate cache
    });
  }

  void _updateCategoryFilter(String? value) {
    setState(() {
      _selectedCategory = value!;
      _cachedFilteredTransactions = null; // Invalidate cache
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final allTransactions = provider.transactions;
    
    final filteredTransactions = _getFilteredTransactions(allTransactions);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Search and Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search transactions...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: _updateSearch,
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildDropdown(
                        value: _selectedType,
                        items: const ['All Types', 'Income', 'Expense'],
                        onChanged: _updateTypeFilter,
                      ),
                      const SizedBox(width: 8),
                      _buildDropdown(
                        value: _selectedCategory,
                        items: const ['All Categories', 'Food', 'Transportation', 'Education', 'Health', 'Shopping', 'Income'],
                        onChanged: _updateCategoryFilter,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Transaction List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filteredTransactions.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final t = filteredTransactions[index];
                final isIncome = t.amount > 0;
                return RepaintBoundary(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: index == 0 
                          ? const BorderRadius.vertical(top: Radius.circular(12))
                          : index == filteredTransactions.length - 1
                              ? const BorderRadius.vertical(bottom: Radius.circular(12))
                              : BorderRadius.zero,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(t.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Row(
                        children: [
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(
                              color: isIncome ? Colors.green : Colors.indigo,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(t.category, style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 12),
                          Text(t.date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      trailing: Text(
                        '${isIncome ? '+' : ''}${t.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isIncome ? Colors.green : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({required String value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: value,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
        onChanged: onChanged,
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down, size: 16),
        isDense: true,
        isExpanded: false,
      ),
    );
  }
}
