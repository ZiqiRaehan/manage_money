import 'package:flutter/material.dart';
import '../models/income.dart';

class IncomeForm extends StatefulWidget {
  final Function(Income) onSubmit;
  const IncomeForm({required this.onSubmit, Key? key}) : super(key: key);

  @override
  State<IncomeForm> createState() => _IncomeFormState();
}

class _IncomeFormState extends State<IncomeForm> {
  final _formKey = GlobalKey<FormState>();
  String source = 'salary';
  double amount = 0;
  DateTime date = DateTime.now();
  String description = '';

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
              Text('Tambah Pendapatan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: source,
                items: [
                  DropdownMenuItem(value: 'salary', child: Text('Gaji')),
                  DropdownMenuItem(
                      value: 'freelance', child: Text('Freelance')),
                  DropdownMenuItem(value: 'found', child: Text('Nemu Uang')),
                  DropdownMenuItem(value: 'other', child: Text('Lainnya')),
                ],
                onChanged: (v) => setState(() => source = v!),
                decoration: InputDecoration(labelText: 'Sumber'),
              ),
              SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(labelText: 'Nominal'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                onSaved: (v) => amount = double.tryParse(v ?? '0') ?? 0,
              ),
              SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(labelText: 'Deskripsi'),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                onSaved: (v) => description = v ?? '',
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
                        Income(
                          source: source,
                          amount: amount,
                          date: date,
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
