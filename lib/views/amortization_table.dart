import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/financial_controller.dart';
import '../models/financial_operation.dart';
import '../services/export_service.dart';

class AmortizationTablePage extends StatelessWidget {
  final FinancialOperation operation;
  final FinancialController controller = FinancialController();

  AmortizationTablePage({Key? key, required this.operation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final amortizationTable = controller.generateAmortizationTable(operation);
    final payment = controller.calculateLoanPayment(operation);
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateFormat = DateFormat('MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text('Tabla de Amortización: ${operation.description}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Resumen del Préstamo',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Monto del préstamo:'),
                        Text(currencyFormat.format(operation.amount)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tasa de interés:'),
                        Text('${operation.rate}%'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Plazo:'),
                        Text('${operation.period} años'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Frecuencia de pago:'),
                        Text(operation.paymentFrequency == 'monthly'
                            ? 'Mensual'
                            : operation.paymentFrequency == 'quarterly'
                            ? 'Trimestral'
                            : 'Anual'),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Pago periódico:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(currencyFormat.format(payment),
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 300, // Altura fija para el contenedor
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 20,
                      columns: const [
                        DataColumn(label: SizedBox(width: 50, child: Text('N°'))),
                        DataColumn(label: SizedBox(width: 100, child: Text('Fecha'))),
                        DataColumn(label: SizedBox(width: 100, child: Text('Pago'))),
                        DataColumn(label: SizedBox(width: 100, child: Text('Principal'))),
                        DataColumn(label: SizedBox(width: 100, child: Text('Interés'))),
                        DataColumn(label: SizedBox(width: 100, child: Text('Saldo'))),
                      ],
                      rows: List<DataRow>.generate(
                        amortizationTable.length,
                            (index) {
                          final entry = amortizationTable[index];
                          return DataRow(cells: [
                            DataCell(SizedBox(width: 50, child: Text(entry.paymentNumber.toString()))),
                            DataCell(SizedBox(width: 100, child: Text(dateFormat.format(entry.date)))),
                            DataCell(SizedBox(width: 100, child: Text(currencyFormat.format(entry.payment)))),
                            DataCell(SizedBox(width: 100, child: Text(currencyFormat.format(entry.principal)))),
                            DataCell(SizedBox(width: 100, child: Text(currencyFormat.format(entry.interest)))),
                            DataCell(SizedBox(width: 100, child: Text(currencyFormat.format(entry.remainingBalance)))),
                          ]);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () async {
                // Exportar a PDF o CSV (implementar más adelante)
                final exportService = ExportService(FinancialController(), context);
                await exportService.exportAmortizationToPdf(operation.id!);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min, // Para que no ocupe todo el ancho
                children: const [
                  Icon(Icons.picture_as_pdf), // Icono de PDF
                  SizedBox(width: 8), // Espacio entre icono y texto
                  Text('Exportar Tabla'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}