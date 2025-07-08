import 'package:flutter/material.dart';
import '../models/saving.dart';

class SavingForm extends StatefulWidget {
  final Function(Saving) onSubmit;
  final bool isPlan;
  const SavingForm({required this.onSubmit, this.isPlan = false, Key? key})
      : super(key: key);

  @override
  State<SavingForm> createState() => _SavingFormState();
}

class _SavingFormState extends State<SavingForm> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  double amount = 0;
  DateTime date = DateTime.now();
  DateTime? targetDate;
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
              Text(widget.isPlan ? 'Rencana Tabungan' : 'Tabung Sekarang',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Judul Tabungan'),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                onSaved: (v) => title = v!,
              ),
              SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(labelText: 'Nominal'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                onSaved: (v) => amount = double.tryParse(v ?? '0') ?? 0,
              ),
              SizedBox(height: 12),
              if (widget.isPlan)
                Row(
                  children: [
                    Text(targetDate == null
                        ? 'Target: Belum dipilih'
                        : 'Target: ${targetDate!.day}/${targetDate!.month}/${targetDate!.year}'),
                    Spacer(),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: date,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => targetDate = picked);
                      },
                      child: Text('Pilih Target'),
                    ),
                  ],
                ),
              if (!widget.isPlan)
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
              SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(labelText: 'Deskripsi (opsional)'),
                onSaved: (v) => description = v,
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      widget.onSubmit(
                        Saving(
                          type: widget.isPlan ? 'plan' : 'actual',
                          title: title,
                          amount: amount,
                          date: date,
                          targetDate: widget.isPlan ? targetDate : null,
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
