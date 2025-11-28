import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/image_picker_service.dart';
import '../services/ocr_service.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import 'dashboard_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final ImagePickerService _imagePickerService = ImagePickerService();
  final OCRService _ocrService = OCRService();
  bool _isProcessing = false;

  Future<void> _handleAddReceipt() async {
    setState(() => _isProcessing = true);
    
    try {
      final image = await _imagePickerService.pickImage(ImageSource.gallery);
      
      if (image != null && mounted) {
        // Process OCR
        final extractedText = await _ocrService.extractText(image.path);
        
        if (mounted) {
          // Parse receipt data
          final receiptData = await _ocrService.parseReceiptData(extractedText);
          
          // Show extracted data in a dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Receipt Scanned'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Merchant: ${receiptData['merchant']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Amount: \$${receiptData['amount'].toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    const Text('Raw Text:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(extractedText.isEmpty ? 'No text found' : extractedText, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Add transaction to provider
                    final transaction = Transaction(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: receiptData['merchant'],
                      category: 'Shopping', // Default category
                      date: DateTime.now().toString().substring(0, 10),
                      amount: -receiptData['amount'], // Negative for expense
                      type: 'Expense',
                    );
                    
                    Provider.of<TransactionProvider>(context, listen: false).addTransaction(transaction);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Transaction added successfully!')),
                    );
                  },
                  child: const Text('Add Transaction'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.w400)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // spend.AI branding
            const Text(
              'spend.AI',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 40),

            // Connected Cards Section
            const Text(
              'Connected Cards',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No cards yet. Add one to get started.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            
            // Add New Card Button
            _DashedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Card integration coming soon!')),
                );
              },
              icon: Icons.add,
              label: 'Add New Card',
            ),
            const SizedBox(height: 40),

            // Spending by Date Section
            const Text(
              'Spending by Date',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No receipts yet. Add one to see your spending.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            
            // Add Receipt Button
            _DashedButton(
              onPressed: _isProcessing ? null : _handleAddReceipt,
              icon: Icons.camera_alt,
              label: _isProcessing ? 'Processing...' : 'Add Receipt from Photos',
            ),
            const SizedBox(height: 40),

            // Navigate to Dashboard Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const DashboardScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('View Full Dashboard'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;

  const _DashedButton({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFF2196F3),
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF2196F3), size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF2196F3),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
