import 'package:flutter/material.dart';
import '../models/account.dart';

class AddAccountPage extends StatefulWidget {
  final Account? account;

  AddAccountPage({this.account});

  @override
  _AddAccountPageState createState() => _AddAccountPageState();
}

class _AddAccountPageState extends State<AddAccountPage> {
  final _formKey = GlobalKey<FormState>();
  late String _clientName;
  late double _dueAmount;
  late String _category;

  @override
  void initState() {
    super.initState();
    _clientName = widget.account?.clientName ?? '';
    _dueAmount = widget.account?.dueAmount ?? 0.0;
    _category = widget.account?.category ?? 'زبون';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.account == null ? 'إضافة حساب' : 'تعديل الحساب'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _clientName,
                decoration: InputDecoration(
                  labelText: 'اسم العميل',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال اسم العميل';
                  }
                  return null;
                },
                onSaved: (value) {
                  _clientName = value!;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                initialValue: _dueAmount.toString(),
                decoration: InputDecoration(
                  labelText: 'المبلغ المستحق',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال المبلغ المستحق';
                  }
                  return null;
                },
                onSaved: (value) {
                  _dueAmount = double.parse(value!);
                },
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: InputDecoration(
                  labelText: 'التصنيف',
                  border: OutlineInputBorder(),
                ),
                items:
                    ['زبون', 'صديق', 'شركة'].map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _category = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى اختيار التصنيف';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Navigator.pop(
                      context,
                      Account(
                        clientName: _clientName,
                        dueAmount: _dueAmount,
                        paidAmount: widget.account?.paidAmount ?? 0.0,
                        registrationDate:
                            widget.account?.registrationDate ?? DateTime.now(),
                        category: _category,
                      ),
                    );
                  }
                },
                child: Text(
                  widget.account == null ? 'إضافة حساب' : 'حفظ التعديلات',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
