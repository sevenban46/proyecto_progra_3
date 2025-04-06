import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/financial_controller.dart';
import '../models/financial_operation.dart';

class OperationDetailPage extends StatefulWidget {
  final FinancialOperation? operation;

  const OperationDetailPage({Key? key, this.operation}) : super(key: key);

  @override
  _OperationDetailPageState createState() => _OperationDetailPageState();
}

class _OperationDetailPageState extends State<OperationDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final FinancialController _controller = FinancialController();

  late String _type;
  late String _description;
  late double _amount;
  late double _rate;
  late int _period;
  late DateTime _date;
  late String _calculationType;
  late String _paymentFrequency;
  late int _paymentsPerYear;

  @override
  void initState() {
    super.initState();
    if (widget.operation != null) {
      _type = widget.operation!.type;
      _description = widget.operation!.description;
      _amount = widget.operation!.amount;
      _rate = widget.operation!.rate;
      _period = widget.operation!.period;
      _date = widget.operation!.date;
      _calculationType = widget.operation!.calculationType;
      _paymentFrequency = widget.operation!.paymentFrequency;
      _paymentsPerYear = widget.operation!.paymentsPerYear;
    } else {
      _type = 'investment';
      _description = '';
      _amount = 0;
      _rate = 0;
      _period = 1;
      _date = DateTime.now();
      _calculationType = 'compound';
      _paymentFrequency = 'monthly';
      _paymentsPerYear = 12;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }

  Future<void> _saveOperation() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final operation = FinancialOperation(
        id: widget.operation?.id,
        type: _type,
        description: _description,
        amount: _amount,
        rate: _rate,
        period: _period,
        date: _date,
        calculationType: _calculationType,
        paymentFrequency: _paymentFrequency,
        paymentsPerYear: _paymentsPerYear,
      );

      if (widget.operation == null) {
        await _controller.addOperation(operation);
      } else {
        await _controller.updateOperation(operation);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.operation == null ? 'Nueva Operación' : 'Editar Operación',style: TextStyle(color: Colors.white),),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _paymentFrequency,
                items: const [
                  DropdownMenuItem(value: 'monthly', child: Text('Mensual')),
                  DropdownMenuItem(value: 'quarterly', child: Text('Trimestral')),
                  DropdownMenuItem(value: 'yearly', child: Text('Anual')),
                ],
                decoration: const InputDecoration(labelText: 'Frecuencia de pago'),
                onChanged: (value) {
                  setState(() {
                    _paymentFrequency = value!;
                    _paymentsPerYear = value == 'monthly' ? 12 :
                    value == 'quarterly' ? 4 : 1;
                  });
                  if (kDebugMode) {
                    print('Frecuencia seleccionada: $value');
                  }
                },
                validator: (value) => value == null ? 'Seleccione una frecuencia' : null,
              ),
              DropdownButtonFormField<String>(
                value: _type,
                items: const [
                  DropdownMenuItem(value: 'investment', child: Text('Inversión')),
                  DropdownMenuItem(value: 'loan', child: Text('Préstamo')),
                ],
                decoration: const InputDecoration(labelText: 'Tipo de operación'),
                onChanged: (value) {
                  setState(() {
                    _type = value!;
                  });
                },
                validator: (value) =>
                value == null ? 'Seleccione un tipo de operación' : null,
              ),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (value) =>
                value!.isEmpty ? 'Ingrese una descripción' : null,
                onSaved: (value) => _description = value!,
              ),
              TextFormField(
                initialValue: _amount.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Monto principal'),
                validator: (value) {
                  if (value!.isEmpty) return 'Ingrese un monto';
                  if (double.tryParse(value) == null) return 'Monto inválido';
                  return null;
                },
                onSaved: (value) => _amount = double.parse(value!),
              ),
              TextFormField(
                initialValue: _rate.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Tasa de interés (%)'),
                validator: (value) {
                  if (value!.isEmpty) return 'Ingrese una tasa';
                  if (double.tryParse(value) == null) return 'Tasa inválida';
                  return null;
                },
                onSaved: (value) => _rate = double.parse(value!),
              ),
              TextFormField(
                initialValue: _period.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Período (años)'),
                validator: (value) {
                  if (value!.isEmpty) return 'Ingrese un período';
                  if (int.tryParse(value) == null) return 'Período inválido';
                  return null;
                },
                onSaved: (value) => _period = int.parse(value!),
              ),
              DropdownButtonFormField<String>(
                value: _calculationType,
                items: const [
                  DropdownMenuItem(value: 'simple', child: Text('Interés simple')),
                  DropdownMenuItem(value: 'compound', child: Text('Interés compuesto')),
                ],
                decoration: const InputDecoration(labelText: 'Tipo de cálculo'),
                onChanged: (value) {
                  setState(() {
                    _calculationType = value!;
                  });
                },
                validator: (value) =>
                value == null ? 'Seleccione un tipo de cálculo' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Fecha: '),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: Text(DateFormat('dd/MM/yyyy').format(_date)),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveOperation,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}