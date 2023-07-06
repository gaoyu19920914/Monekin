import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:finlytics/core/database/database_impl.dart';
import 'package:finlytics/core/models/transaction/transaction.dart';
import 'package:finlytics/core/utils/get_download_path.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BackupDatabaseService {
  DatabaseImpl db = DatabaseImpl.instance;

  Future<void> downloadDatabaseFile(BuildContext context) async {
    final messeger = ScaffoldMessenger.of(context);

    List<int> dbFileInBytes = await File(await db.databasePath).readAsBytes();

    String downloadPath = await getDownloadPath();
    downloadPath =
        '${downloadPath}finlytics-${DateFormat('yyyyMMdd-Hms').format(DateTime.now())}.db';

    File downloadFile = File(downloadPath);

    await downloadFile.writeAsBytes(dbFileInBytes);

    messeger.showSnackBar(SnackBar(
      content: Text('Base de datos descargada con exito en $downloadPath'),
    ));
  }

  Future<String> exportSpreadsheet(
    BuildContext context,
    List<MoneyTransaction> data, {
    String format = 'csv',
    String separator = ',',
  }) async {
    var csvData = '';

    var keys = [
      'ID',
      'Amount',
      'Date',
      'Title',
      'Note',
      'Account',
      'Currency',
      'Category',
      'Subcategory',
    ];

    if (data.isNotEmpty) {
      for (final key in keys) {
        csvData += key + separator;
      }
    }

    csvData += '\n';

    final dateFormatter = DateFormat('yyyy-MM-dd H:m:s');

    for (final transaction in data) {
      final toAdd = [
        transaction.id,
        transaction.value.toStringAsFixed(2),
        dateFormatter.format(transaction.date),
        transaction.title ?? '',
        transaction.notes ?? '',
        transaction.account.name,
        transaction.account.currencyId,
        if (transaction.isIncomeOrExpense)
          (transaction.category!.parentCategory != null
              ? transaction.category!.parentCategory!.name
              : transaction.category!.name),
        if (transaction.isTransfer) 'TRANSFER',
        (transaction.category?.parentCategory != null
            ? transaction.category?.name
            : '')
      ];

      csvData += toAdd.join(separator);

      csvData += '\n';

      if (transaction.isTransfer) {
        final toAdd2 = [
          transaction.id,
          (transaction.valueInDestiny ?? transaction.value).toStringAsFixed(2),
          dateFormatter.format(transaction.date),
          transaction.title ?? '',
          transaction.notes ?? '',
          transaction.receivingAccount!.name,
          transaction.receivingAccount!.currencyId,
          'TRANSFER',
          ''
        ];

        csvData += toAdd.join(separator);

        csvData += '\n';
      }
    }

    String downloadPath = await getDownloadPath();
    downloadPath =
        '${downloadPath}Transactions-${DateFormat('yyyyMMdd-Hms').format(DateTime.now())}.csv';

    File downloadFile = File(downloadPath);

    await downloadFile.writeAsString(csvData);

    return downloadPath;
  }

  Future<void> importDatabase() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);

      // Delete the previous database
      String path = await db.databasePath;

      await file.writeAsString('');

      // Load the new database
      await file.copy(path);
    }
  }
}
