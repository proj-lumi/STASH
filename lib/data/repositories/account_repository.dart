import 'package:stash/data/models/account.dart';
import 'package:stash/data/models/transaction.dart';
import 'package:isar/isar.dart';

class AccountRepository {
  AccountRepository(this._isar);

  final Isar _isar;

  Stream<List<Account>> watchAccounts() {
    return _isar.accounts.where().watch(fireImmediately: true);
  }

  Future<List<Account>> getAccounts() => _isar.accounts.where().findAll();

  Future<Account?> getAccount(Id id) => _isar.accounts.get(id);

  Future<void> addAccount(Account account) async {
    await _isar.writeTxn(() async {
      await _isar.accounts.put(account);
    });
  }

  Future<void> updateAccount(Account account) async {
    await _isar.writeTxn(() async {
      await _isar.accounts.put(account);
    });
  }

  Future<void> deleteAccount(int accountId) async {
    await _isar.writeTxn(() async {
      // Get all transactions linked to this account
      final transactionsToDelete = await _isar.transactions
          .filter()
          .account((q) => q.idEqualTo(accountId))
          .findAll();
      
      // Also get related account transactions (transfers)
      final relatedTransactions = await _isar.transactions
          .filter()
          .relatedAccount((q) => q.idEqualTo(accountId))
          .findAll();
      
      // Delete all transaction IDs
      final idsToDelete = [
        ...transactionsToDelete.map((t) => t.id),
        ...relatedTransactions.map((t) => t.id),
      ].toSet().toList();
      
      await _isar.transactions.deleteAll(idsToDelete);
      
      // Finally delete the account
      await _isar.accounts.delete(accountId);
    });
  }

  /// Derived balance: initialBalance + sum(deposit + transfers in) - sum(expense + transfers out + transferFee).
  Future<double> getBalanceForAccount(Id accountId) async {
    final account = await _isar.accounts.get(accountId);
    if (account == null) return 0;

    double balance = account.initialBalance;

    final asMain = await _isar.transactions
        .filter()
        .account((q) => q.idEqualTo(accountId))
        .findAll();

    for (final t in asMain) {
      switch (t.type) {
        case TransactionType.deposit:
          balance += t.amount;
          break;
        case TransactionType.expense:
          balance -= t.amount;
          break;
        case TransactionType.transfer:
          balance -= t.amount;
          balance -= t.transferFee ?? 0;
          break;
      }
    }

    final asRelated = await _isar.transactions
        .filter()
        .relatedAccount((q) => q.idEqualTo(accountId))
        .findAll();

    for (final t in asRelated) {
      if (t.type == TransactionType.transfer) {
        balance += t.amount;
      }
    }

    return balance;
  }

  /// Total balance across all accounts (derived).
  Future<double> getTotalBalance() async {
    final accounts = await _isar.accounts.where().findAll();
    double total = 0;
    for (final a in accounts) {
      total += await getBalanceForAccount(a.id);
    }
    return total;
  }

  Future<void> deleteAllAccounts() async {
    await _isar.writeTxn(() async {
      await _isar.accounts.clear();
    });
  }
}
