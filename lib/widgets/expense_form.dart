import 'package:flutter/material.dart';
import '../models/expense.dart';

class ExpenseForm extends StatefulWidget {
  final Function(Expense) onSubmit;
  const ExpenseForm({required this.onSubmit, Key? key}) : super(key: key);

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  String item = '';
  double price = 0;
  int quantity = 1;
  DateTime date = DateTime.now();
  String category = '';
  String? description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tambah Pengeluaran',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Nama Barang'),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                onSaved: (v) => item = v!,
              ),
              SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                onSaved: (v) => price = double.tryParse(v ?? '0') ?? 0,
              ),
              SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(labelText: 'Jumlah'),
                keyboardType: TextInputType.number,
                initialValue: '1',
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                onSaved: (v) => quantity = int.tryParse(v ?? '1') ?? 1,
              ),
              SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(labelText: 'Kategori'),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                onSaved: (v) => category = v!,
              ),
              SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(labelText: 'Deskripsi (opsional)'),
                onSaved: (v) => description = v,
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Text('Tanggal: ${date.day}/${date.month}/${date.year}'),
                  Spacer(),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setState(() => date = picked);
                    },
                    child: Text('Pilih'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      widget.onSubmit(
                        Expense(
                          item: item,
                          price: price,
                          quantity: quantity,
                          date: date,
                          category: category,
                          description: description,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
