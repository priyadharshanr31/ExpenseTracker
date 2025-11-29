import '../models/transaction.dart';

class DuplicateTransactionUtils {
  /// Checks if a transaction is a duplicate of any existing transaction.
  ///
  /// A transaction is considered a duplicate if there is an existing transaction
  /// with the same [name], [amount], and [date].
  static bool isDuplicate(Transaction newTx, List<Transaction> existingTxns) {
    for (final tx in existingTxns) {
      if (tx.name == newTx.name &&
          tx.amount == newTx.amount &&
          tx.date == newTx.date) {
        return true;
      }
    }
    return false;
  }
}
