import 'package:gsheets/gsheets.dart';

class GoogleSheetsApi {
  // create credentials
  static const _credentials = {
    "type": "service_account",
    "project_id": "expense-tracker-356804",
    "private_key_id": "dcec08c83b88c6dd85975dc63ac3e12abd92fd16",
    "private_key":
        "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC3SZMwbZD5R2+8\ncfTpt6NAC3qiLTinM5CPAJdFSsh68h6CbX8YsLCPT+hpU70TFU2g61iFmuSefd0V\nfLaPYdFCR7Ofh93o/Z3+Tv2lOIGqab5xgAWK6qFOLksns3CmyVq0smsM+SShJ9s5\nyqOpTb22TQ7v4olIeE4mnS7lEcl8YdFPo+CHkafO+iAvIlJjTIwHIu3RdIblPYYq\nMLVXEcpBTseP/PE9q0m9gz5UB/UGvfzwTOPne9tQNwDDdX2SUJUd24/Je1eYrxvi\nEOdG5JrHrRCp9kwzaAYbHLtwYgWaJPIjF0gDLRY96CJhbG232DpJRCEC+T85aQCe\nGivw37ANAgMBAAECggEAF9KCRPsYqq20QiP1lyL9HuffCpEiGelD0rJa9vCfWgt6\nF62vpT/h0t6p8HanzoEoU9AC82qMaGUnhRFukPg/wIOdPxDjsNK15EXUBdNwVvvj\netEO511TldvCfOh/rc3h8jZ2X3tKXX/WqI5D809dZwJg/KDPAxJP5gjr/W3waC/+\nLiT20kwgE1YvqzL4TVq9WfukSUwLml+oU5EuuP7Nhb05qV1piMfNBJaA98DxjMrg\nHfEJKB7WETVcjUEkULvEWGc4eYvjQaBEu1yZ+BUaxrViTDwp3AEn6HW7u572UBtZ\njhQVkURTh8bYtFbWwqhFeAwj+Em3gcNJjuyE5ur4qQKBgQDiJuwr2SyYGe33NPSu\nbIVglRMgbaJkvK1pZwk3IEBZcoNF5eEkvkeorhFRnKJEoli5i2/lKmL1tSncqwO/\nXBJsfpy0TwNwoJI995CSwNiHwRWX8KxRAbr5Aj471Ueso8hldeP/CcgCyWtsEtey\nMyhU6vn0Wi0tPa0I1Q2w2RGJ0wKBgQDPel63h0vOBnxpXxSXJrZ/oplhpe3/Glbt\nuJcLdm05nMM6x4d8P2TlwIme3mj0rsvmgKibpVrUadcNDjwzIC5B+4Y9QEXeRKUA\nME6FT46aZQQ8oJIbpbbKkbJu+bEpFZFVooMPHBSRQguTDEurEFjbFIyIfdRPq3dY\nT/0olOTSnwKBgFVbm4hxUAOYxdiohDHRhAYQPkffGYwsKse9vByyb5dTQXkAaxoT\nN7jS+nZzSEvfet2NY457kR5sYoCHi8KOXeXVZBAqQoIgGRKKfmblotSabCwNCv0I\nSinyTssGlSb0Ko8hEA0TBAsJOyJvejooVPC4P9+aqbKJtOXAhIpbY+NBAoGAPT7w\nStkDhZPgkfJhT6U75j2HbY3fzZhm5NHCtL2GzKT79JQF6KWGEVRey6j37pLS2f5M\nx3VudJmxw8bZ+nWbchrfq6EXft9gncekxjGP9P+w2nzD5KlsZivQMnY+19PoDRFm\nAsXVRHPsmsHcbGjs8e8E9R2/2KzTFBy4rIwXaB0CgYEAsEQNvEqF9uH4qj5t5z/1\nyRF+CwC2PbjQEsM43rZKvunEJ7HZI+VRbSyMIADo05V1KXUVe7hBl8aDEBOELtbh\nIKR7DJNoG2/sPJfXkuMwl6vQUKj2RMCbfs3Duupt5GVTOexhuITgZe0vDkzFuEUU\nIjWIKoI1obhJ5V3OHNyJtmM=\n-----END PRIVATE KEY-----\n",
    "client_email":
        "expense-tracker@expense-tracker-356804.iam.gserviceaccount.com",
    "client_id": "111310212090982533297",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url":
        "https://www.googleapis.com/robot/v1/metadata/x509/expense-tracker%40expense-tracker-356804.iam.gserviceaccount.com"
  };

  // set up & connect to the spreadsheet
  static final _spreadsheetId = '1lRxRbc2QO1xe2bKcDWBDEReJ7Z21zMPbHsStQQrZ-Lw';
  static final _gsheets = GSheets(_credentials);
  static Worksheet? _worksheet;

  // some variables to keep track of..
  static int numberOfTransactions = 0;
  static List<List<dynamic>> currentTransactions = [];
  static bool loading = true;

  // initialise the spreadsheet!
  Future init() async {
    final ss = await _gsheets.spreadsheet(_spreadsheetId);
    _worksheet = ss.worksheetByTitle('Workbook1');
    countRows();
  }

  // count the number of notes
  static Future countRows() async {
    while ((await _worksheet!.values
            .value(column: 1, row: numberOfTransactions + 1)) !=
        '') {
      numberOfTransactions++;
    }
    // now we know how many notes to load, now let's load them!
    loadTransactions();
  }

  // load existing notes from the spreadsheet
  static Future loadTransactions() async {
    if (_worksheet == null) return;

    for (int i = 1; i < numberOfTransactions; i++) {
      final String transactionName =
          await _worksheet!.values.value(column: 1, row: i + 1);
      final String transactionAmount =
          await _worksheet!.values.value(column: 2, row: i + 1);
      final String transactionType =
          await _worksheet!.values.value(column: 3, row: i + 1);

      if (currentTransactions.length < numberOfTransactions) {
        currentTransactions.add([
          transactionName,
          transactionAmount,
          transactionType,
        ]);
      }
    }
    loading = false;
  }

  // insert a new transaction
  static Future insert(String name, String amount, bool _isIncome) async {
    if (_worksheet == null) return;
    numberOfTransactions++;
    currentTransactions.add([
      name,
      amount,
      _isIncome == true ? 'income' : 'expense',
    ]);
    await _worksheet!.values.appendRow([
      name,
      amount,
      _isIncome == true ? 'income' : 'expense',
    ]);
  }

  // CALCULATE THE TOTAL INCOME!
  static double calculateIncome() {
    double totalIncome = 0;
    for (int i = 0; i < currentTransactions.length; i++) {
      if (currentTransactions[i][2] == 'income') {
        totalIncome += double.parse(currentTransactions[i][1]);
      }
    }
    return totalIncome;
  }

  // CALCULATE THE TOTAL EXPENSE!
  static double calculateExpense() {
    double totalExpense = 0;
    for (int i = 0; i < currentTransactions.length; i++) {
      if (currentTransactions[i][2] == 'expense') {
        totalExpense += double.parse(currentTransactions[i][1]);
      }
    }
    return totalExpense;
  }
}
