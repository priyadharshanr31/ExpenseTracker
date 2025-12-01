import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../providers/transaction_provider.dart';
import '../providers/card_provider.dart';
import '../providers/auth_provider.dart';
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
        
        // Controllers for editing
        final merchantController = TextEditingController(text: parsedData['merchant']);
        final amountController = TextEditingController(text: parsedData['amount']);
        final dateController = TextEditingController(text: parsedData['date']);
        
        // Default to first card if available
        String? selectedCardId;
        if (cards.isNotEmpty) {
          selectedCardId = cards.first.id;
        }
        
        String selectedCategory = 'Food';
        final List<String> categories = ['Food', 'Transportation', 'Education', 'Health', 'Shopping', 'Income', 'Other'];

        // Show review dialog with Editable Fields
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
                      // Merchant
                      TextFormField(
                        controller: merchantController,
                        decoration: const InputDecoration(labelText: 'Merchant'),
                      ),
                      const SizedBox(height: 12),
                      
                      // Amount
                      TextFormField(
                        controller: amountController,
                        decoration: const InputDecoration(labelText: 'Amount', prefixText: '\$ '),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      const SizedBox(height: 12),
                      
                      // Date
                      TextFormField(
                        controller: dateController,
                        decoration: const InputDecoration(labelText: 'Date'),
                        onTap: () async {
                          // Optional: Add DatePicker here if needed, for now text edit is fine
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      // Category Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: const InputDecoration(labelText: 'Category'),
                        items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (val) => setState(() => selectedCategory = val!),
                      ),
                      const SizedBox(height: 12),

                      // Card Selection
                      DropdownButtonFormField<String>(
                        value: selectedCardId,
                        decoration: const InputDecoration(
                          labelText: 'Paid With (Mandatory)',
                          border: OutlineInputBorder(),
                        ),
                        hint: const Text('Select Card'),
                        items: [
                          // Removed "Cash / Other" to enforce card selection as requested
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
                      // Validation: Check if card is selected
                      if (selectedCardId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select a card to proceed.')),
                        );
                        return;
                      }

                      // Create and Save Transaction
                      final amountVal = double.tryParse(amountController.text) ?? 0.0;
                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                      
                      final newTransaction = Transaction(
                        id: const Uuid().v4(),
                        name: merchantController.text.isNotEmpty ? merchantController.text : 'Unknown',
                        category: selectedCategory,
                        date: dateController.text,
                        amount: -amountVal, // Expense is negative
                        type: 'Expense',
                        cardId: selectedCardId,
                        userId: authProvider.currentUser!.username,
                      );

                      Provider.of<TransactionProvider>(context, listen: false).addTransaction(newTransaction);
                      
                      // Update Card Balance
                      Provider.of<CardProvider>(context, listen: false).updateCardBalance(selectedCardId!, -amountVal);
                      
                      Navigator.pop(context); // Close dialog
                      
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction Saved!')));
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

  Map<String, dynamic> _parseReceipt(String rawText) {
    final lines = rawText.split('\n');
    String merchant = '';
    String amount = '';
    String date = '';

    // 1. Merchant: Assume first non-empty line that isn't a common header
    for (var line in lines) {
      if (line.trim().isNotEmpty && 
          !line.toLowerCase().contains('receipt') && 
          !line.toLowerCase().contains('total')) {
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
    
    // Default date if not found
    if (date.isEmpty) {
      date = DateFormat('MM/dd/yyyy').format(DateTime.now());
    }

    return {
      'merchant': merchant,
      'amount': amount,
      'date': date,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: TabBar(
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
          Expanded(
            child: TabBarView(
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
          ),
        ],
      ),
    );
  }
}

class _ManualEntryForm extends StatefulWidget {
  const _ManualEntryForm();

  @override
  State<_ManualEntryForm> createState() => _ManualEntryFormState();
}

class _ManualEntryFormState extends State<_ManualEntryForm> with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'Food';
  String _selectedType = 'Expense';
  DateTime _selectedDate = DateTime.now();
  String? _selectedCardId;

  final List<String> _categories = ['Food', 'Transportation', 'Education', 'Health', 'Shopping', 'Income', 'Other'];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Default to first card if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cards = Provider.of<CardProvider>(context, listen: false).cards;
      if (cards.isNotEmpty) {
        setState(() {
          _selectedCardId = cards.first.id;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final cardProvider = Provider.of<CardProvider>(context);
    final cards = cardProvider.cards;

    print('Building ManualEntryForm');
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          color: Colors.transparent, // Ensure it takes hits
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
        ),
      ),
    );
  }

  void _saveTransaction() {
    if (_formKey.currentState?.validate() ?? false) {
      final amount = double.parse(_amountController.text);
      final finalAmount = _selectedType == 'Expense' ? -amount : amount;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final newTransaction = Transaction(
        id: const Uuid().v4(),
        name: _nameController.text,
        category: _selectedCategory,
        date: DateFormat('MM/dd/yyyy').format(_selectedDate),
        amount: finalAmount,
        type: _selectedType,
        cardId: _selectedType == 'Expense' ? _selectedCardId : null,
        userId: authProvider.currentUser!.username,
      );

      Provider.of<TransactionProvider>(context, listen: false).addTransaction(newTransaction);

      // Update Card Balance if a card was used
      if (_selectedType == 'Expense' && _selectedCardId != null) {
        Provider.of<CardProvider>(context, listen: false).updateCardBalance(_selectedCardId!, finalAmount);
      }

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
