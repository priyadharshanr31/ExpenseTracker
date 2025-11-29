import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../providers/transaction_provider.dart';
import '../providers/card_provider.dart';
import '../models/transaction.dart';
import '../models/card_model.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      
      if (image != null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image picked, processing...')));
        print('Image picked: ${image.path}');
        await _processReceipt(image);
      } else {
        print('Image picker cancelled');
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  Future<void> _processReceipt(XFile image) async {
    print('Starting processing for ${image.path}');
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final inputImage = InputImage.fromFilePath(image.path);
      print('InputImage created');
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      print('TextRecognizer created');
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      print('Text recognized: ${recognizedText.text.length} chars');
      
      Navigator.pop(context); // Hide loading

      if (recognizedText.text.isNotEmpty) {
        print('Recognized Text: ${recognizedText.text}');
        // Parse the text
        final parsedData = _parseReceipt(recognizedText.text);
        print('Parsed Data: $parsedData');
        
        // Get cards for selection
        if (!mounted) return;
        final cardProvider = Provider.of<CardProvider>(context, listen: false);
        final cards = cardProvider.cards;
        String? selectedCardId;
        
        // Show review dialog with Card Selection
        await showDialog(
          context: context,
          builder: (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Review & Save'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Merchant', parsedData['merchant']),
                      _buildInfoRow('Amount', '\$${parsedData['amount']}'),
                      _buildInfoRow('Date', parsedData['date']),
                      const SizedBox(height: 16),
                      const Text('Paid With:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedCardId,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          filled: true,
                          fillColor: Theme.of(context).cardTheme.color,
                        ),
                        hint: const Text('Select Card'),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Cash / Other'),
                          ),
                          ...cards.map((card) => DropdownMenuItem(
                            value: card.id,
                            child: Text('${card.name} (...${card.last4})', overflow: TextOverflow.ellipsis),
                          )),
                        ],
                        onChanged: (val) => setState(() => selectedCardId = val),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () {
                      // Create and Save Transaction
                      final amountVal = double.tryParse(parsedData['amount'].toString()) ?? 0.0;
                      final newTransaction = Transaction(
                        id: const Uuid().v4(),
                        name: parsedData['merchant'] ?? 'Unknown',
                        category: 'Food', // Default, maybe allow change?
                        date: parsedData['date'] ?? DateFormat('MM/dd/yyyy').format(DateTime.now()),
                        amount: -amountVal, // Expense is negative
                        type: 'Expense',
                        cardId: selectedCardId,
                      );

                      Provider.of<TransactionProvider>(context, listen: false).addTransaction(newTransaction);
                      
                      Navigator.pop(context); // Close dialog
                      
                      // Show success and navigate to Dashboard
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction Saved!')));
                      
                      // Navigate to Dashboard (Index 0 of MainLayout)
                      // We need to access the MainLayout state or just pop if we were pushed.
                      // Since AddScreen is a tab, we can't "pop" to dashboard.
                      // We need to switch the MainLayout tab.
                      // Assuming MainLayout is the parent, we can try to find a way.
                      // Or just rely on the user seeing the success.
                      // Actually, the user wants "updated in recent transaction also the graph".
                      // If we stay on Add Screen, they won't see it immediately.
                      // Let's try to switch the tab of the PARENT DefaultTabController or similar?
                      // MainLayout uses a BottomNavigationBar with IndexedStack.
                      // We can't easily switch the parent's index from here without a callback or provider.
                      // BUT, we can just show the success message. The Dashboard WILL update when they go there.
                    },
                    child: const Text('Save Transaction'),
                  ),
                ],
              );
            },
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No text found on receipt.')));
      }
      
      textRecognizer.close();
    } catch (e) {
      Navigator.pop(context); // Hide loading
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error scanning receipt: $e')));
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text('$label:', style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Map<String, dynamic> _parseReceipt(String rawText) {
    final lines = rawText.split('\n');
    String merchant = '';
    String amount = '';
    String date = '';

    // 1. Merchant: Assume first non-empty line that isn't a common header
    for (var line in lines) {
      if (line.trim().isNotEmpty && !line.toLowerCase().contains('receipt')) {
        merchant = line.trim();
        break;
      }
    }

    // 2. Date: Look for MM/DD/YYYY or similar patterns
    final dateRegex = RegExp(r'(\d{1,2}[/-]\d{1,2}[/-]\d{2,4})|(\d{4}[/-]\d{1,2}[/-]\d{1,2})');
    final dateMatch = dateRegex.firstMatch(rawText);
    if (dateMatch != null) date = dateMatch.group(0)!;

    // 3. Amount: Look for the largest number formatted as currency
    final amountRegex = RegExp(r'\$?\s?(\d+\.\d{2})');
    final amountMatches = amountRegex.allMatches(rawText);
    double maxAmount = 0.0;
    for (var match in amountMatches) {
      final val = double.tryParse(match.group(1) ?? '0');
      if (val != null && val > maxAmount) {
        maxAmount = val;
      }
    }
    if (maxAmount > 0) amount = maxAmount.toStringAsFixed(2);

    return {
      'merchant': merchant,
      'amount': amount,
      'date': date,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(text: 'Scan Receipt'),
            Tab(text: 'Manual Entry'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 24),
                Text(
                  'Scan Receipt (OCR)',
                  style: TextStyle(color: Colors.grey[600], fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Extract details using on-device OCR',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton.icon(
                       onPressed: () => _pickImage(ImageSource.camera),
                       icon: const Icon(Icons.camera_alt),
                       label: const Text('Camera'),
                    ),
                    const SizedBox(width: 16),
                    FilledButton.icon(
                       onPressed: () => _pickImage(ImageSource.gallery),
                       icon: const Icon(Icons.image),
                       label: const Text('Gallery'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const _ManualEntryForm(),
        ],
      ),
    );
  }
}

class _ManualEntryForm extends StatefulWidget {
  const _ManualEntryForm({super.key});

  @override
  State<_ManualEntryForm> createState() => _ManualEntryFormState();
}

class _ManualEntryFormState extends State<_ManualEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'Food';
  String _selectedType = 'Expense';
  DateTime _selectedDate = DateTime.now();
  String? _selectedCardId;

  final List<String> _categories = ['Food', 'Transportation', 'Education', 'Health', 'Shopping', 'Income', 'Other'];

  void updateFromParsedData(Map<String, dynamic> data) {
    setState(() {
      if (data['merchant'] != null && data['merchant'].isNotEmpty) {
        _nameController.text = data['merchant'];
      }
      if (data['amount'] != null && data['amount'].isNotEmpty) {
        _amountController.text = data['amount'];
      }
      if (data['date'] != null && data['date'].isNotEmpty) {
        try {
           String d = data['date'];
           if (d.contains('/')) {
             final parts = d.split('/');
             if (parts.length == 3) {
               if (parts[2].length == 2) parts[2] = '20${parts[2]}';
               _selectedDate = DateFormat('MM/dd/yyyy').parse('${parts[0]}/${parts[1]}/${parts[2]}');
             }
           } else if (d.contains('-')) {
             // Try yyyy-MM-dd
             _selectedDate = DateTime.parse(d);
           }
        } catch (_) {}
      }
      _selectedType = 'Expense';
    });
  }

  @override
  Widget build(BuildContext context) {
    final cardProvider = Provider.of<CardProvider>(context);
    final cards = cardProvider.cards;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Amount Input
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: '\$ ',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Theme.of(context).cardTheme.color,
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Required';
                if (double.tryParse(value) == null) return 'Invalid number';
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Name Input
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Theme.of(context).cardTheme.color,
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 20),

            // Type & Category Row
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedType,
                    dropdownColor: Theme.of(context).cardTheme.color,
                    decoration: InputDecoration(
                      labelText: 'Type',
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Theme.of(context).cardTheme.color,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                    items: ['Expense', 'Income'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => setState(() => _selectedType = val!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    dropdownColor: Theme.of(context).cardTheme.color,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Theme.of(context).cardTheme.color,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                    isExpanded: true, // Ensure text doesn't overflow
                    items: _categories.map((e) => DropdownMenuItem(
                      value: e, 
                      child: Text(e, overflow: TextOverflow.ellipsis),
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedCategory = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Date Picker
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Theme.of(context).cardTheme.color,
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                child: Text(DateFormat('MM/dd/yyyy').format(_selectedDate)),
              ),
            ),
            const SizedBox(height: 20),

            // Card Selection (Only for Expenses)
            if (_selectedType == 'Expense') ...[
              DropdownButtonFormField<String>(
                value: _selectedCardId,
                dropdownColor: Theme.of(context).cardTheme.color,
                decoration: InputDecoration(
                  labelText: 'Paid With',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Theme.of(context).cardTheme.color,
                  helperText: 'Select the card used for this transaction',
                  prefixIcon: const Icon(Icons.credit_card),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Cash / Other'),
                  ),
                  ...cards.map((card) => DropdownMenuItem(
                    value: card.id,
                    child: Row(
                      children: [
                        Container(
                          width: 24, height: 16,
                          color: card.color,
                          margin: const EdgeInsets.only(right: 8),
                        ),
                        Expanded(child: Text('${card.name} (...${card.last4})', overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  )),
                ],
                onChanged: (val) => setState(() => _selectedCardId = val),
                validator: (value) {
                   // Optional: Make it required if user wants strict tracking
                   return null; 
                },
              ),
              const SizedBox(height: 32),
            ],

            // Save Button
            FilledButton.icon(
              onPressed: _saveTransaction,
              icon: const Icon(Icons.check),
              label: const Text('Save Transaction'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 56), // Full width
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveTransaction() {
    if (_formKey.currentState?.validate() ?? false) {
      final amount = double.parse(_amountController.text);
      final finalAmount = _selectedType == 'Expense' ? -amount : amount;

      final newTransaction = Transaction(
        id: const Uuid().v4(),
        name: _nameController.text,
        category: _selectedCategory,
        date: DateFormat('MM/dd/yyyy').format(_selectedDate),
        amount: finalAmount,
        type: _selectedType,
        cardId: _selectedType == 'Expense' ? _selectedCardId : null,
      );

      Provider.of<TransactionProvider>(context, listen: false).addTransaction(newTransaction);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction Added!')),
      );

      // Reset form
      _nameController.clear();
      _amountController.clear();
      setState(() {
        _selectedDate = DateTime.now();
        _selectedCardId = null;
      });
    }
  }
}
