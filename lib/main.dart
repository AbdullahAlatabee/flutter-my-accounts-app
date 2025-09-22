import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_accounts/pages/add_account.dart';
import 'package:my_accounts/pages/add_payment.dart';
import 'dart:convert';
import 'models/account.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  _loadThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode =
          (prefs.getBool('isDarkMode') ?? false)
              ? ThemeMode.dark
              : ThemeMode.light;
    });
  }

  _toggleThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
      prefs.setBool('isDarkMode', _themeMode == ThemeMode.dark);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'حساباتي',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Cairo',
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
          bodyLarge: TextStyle(fontSize: 18.0, color: Colors.black),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Cairo',
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(fontSize: 18.0, color: Colors.white),
        ),
      ),
      themeMode: _themeMode,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', ''), // English
        Locale('ar', ''), // Arabic
      ],
      locale: Locale('ar', ''), // Set default locale to Arabic
      home: MyHomePage(toggleThemeMode: _toggleThemeMode),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final VoidCallback toggleThemeMode;

  MyHomePage({required this.toggleThemeMode});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Account> accounts = [];

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  _loadAccounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accountsString = prefs.getString('accounts');
    if (accountsString != null) {
      List<dynamic> accountsJson = jsonDecode(accountsString);
      setState(() {
        accounts = accountsJson.map((json) => Account.fromJson(json)).toList();
      });
    }
  }

  _saveAccounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accountsString = jsonEncode(
      accounts.map((account) => account.toJson()).toList(),
    );
    prefs.setString('accounts', accountsString);
  }

  _addAccount(Account account) {
    setState(() {
      accounts.add(account);
      _saveAccounts();
    });
  }

  _addPayment(String clientName, double payment) {
    setState(() {
      accounts =
          accounts.map((account) {
            if (account.clientName == clientName) {
              account.paidAmount += payment;
            }
            return account;
          }).toList();
      _saveAccounts();
    });
  }

  _deleteAccount(String clientName) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد أنك تريد حذف هذا الحساب؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('حذف'),
            ),
          ],
        );
      },
    );
    if (confirm == true) {
      setState(() {
        accounts.removeWhere((account) => account.clientName == clientName);
        _saveAccounts();
      });
    }
  }

  _editAccount(Account account, int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddAccountPage(account: account)),
    );
    if (result != null) {
      setState(() {
        accounts[index] = result;
        _saveAccounts();
      });
    }
  }


  double getTotalDueAmount() {
    return accounts.fold(0.0, (sum, account) => sum + account.dueAmount);
  }

  double getTotalPaidAmount() {
    return accounts.fold(0.0, (sum, account) => sum + account.paidAmount);
  }

  double getTotalRemainingAmount() {
    return getTotalDueAmount() - getTotalPaidAmount();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('الصفحة الرئيسية'),
          actions: [
            IconButton(
              icon: Icon(Icons.brightness_6),
              onPressed: widget.toggleThemeMode,
              tooltip: 'تبديل الوضع',
            ),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {}, // _resetAllDebts,
              tooltip: 'تصفير جميع الديون',
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'ديون مستحقة', icon: Icon(Icons.money_off)),
              Tab(text: 'مدفوعات', icon: Icon(Icons.payment)),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'إجمالي الديون: ${getTotalDueAmount()}',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  Text(
                    'إجمالي المبالغ المسددة: ${getTotalPaidAmount()}',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  Text(
                    'المبلغ المتبقي: ${getTotalRemainingAmount()}',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [_buildDebtsTab(), _buildPaymentsTab()],
              ),
            ),
          ],
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddAccountPage()),
                );
                if (result != null) {
                  _addAccount(result);
                }
              },
              tooltip: 'إضافة حساب',
              child: Icon(Icons.add),
            ),
            SizedBox(height: 10),
            FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddPaymentPage(accounts: accounts),
                  ),
                );
                if (result != null) {
                  _addPayment(result['clientName'], result['payment']);
                }
              },
              tooltip: 'إضافة دفعة',
              child: Icon(Icons.payment),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebtsTab() {
    return ListView.builder(
      itemCount: accounts.length,
      itemBuilder: (context, index) {
        Account account = accounts[index];
        return Card(
          margin: EdgeInsets.all(10.0),
          child: ListTile(
            title: Text(
              account.clientName,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            subtitle: Text(
              'المبلغ المستحق: ${account.dueAmount}, المبلغ المدفوع: ${account.paidAmount}\nتاريخ التسجيل: ${account.registrationDate.toLocal()}\nالتصنيف: ${account.category}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _editAccount(account, index),
                  tooltip: 'تعديل الحساب',
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteAccount(account.clientName),
                  tooltip: 'حذف الحساب',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentsTab() {
    return ListView.builder(
      itemCount: accounts.length,
      itemBuilder: (context, index) {
        Account account = accounts[index];
        return Card(
          margin: EdgeInsets.all(10.0),
          child: ListTile(
            title: Text(
              account.clientName,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            subtitle: Text(
              'المبلغ المدفوع: ${account.paidAmount}\nتاريخ التسجيل: ${account.registrationDate.toLocal()}\nالتصنيف: ${account.category}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        );
      },
    );
  }
}
