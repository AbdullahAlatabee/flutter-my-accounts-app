import 'package:flutter/material.dart';
import '../models/account.dart';

class AddPaymentPage extends StatefulWidget {
  final List<Account> accounts;

  AddPaymentPage({required this.accounts});

  @override
  _AddPaymentPageState createState() => _AddPaymentPageState();
}

class _AddPaymentPageState extends State<AddPaymentPage> {
  final _formKey = GlobalKey<FormState>();
  String _selectedClient = '';
  double _paymentAmount = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إضافة دفعة')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'اسم العميل',
                  border: OutlineInputBorder(),
                ),
                items:
                    widget.accounts.map((account) {
                      return DropdownMenuItem<String>(
                        value: account.clientName,
                        child: Text(account.clientName),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedClient = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى اختيار العميل';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'المبلغ المدفوع',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال المبلغ المدفوع';
                  }
                  return null;
                },
                onSaved: (value) {
                  _paymentAmount = double.parse(value!);
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Navigator.pop(context, {
                      'clientName': _selectedClient,
                      'payment': _paymentAmount,
                    });
                  }
                },
                child: Text('إضافة دفعة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
