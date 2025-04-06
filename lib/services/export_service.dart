import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../models/amortizacion.dart';
import '../models/financial_operation.dart';
import '../controllers/financial_controller.dart';

class ExportService {
  final FinancialController _controller;
  final BuildContext context;

  ExportService(this._controller, this.context);

  // Método para exportar a CSV
  Future<void> exportOperationsToCsv() async {
    final operations = await _controller.getAllOperations();
    final csvData = [
      ['ID', 'Tipo', 'Descripción', 'Monto', 'Tasa', 'Período', 'Fecha', 'Tipo Cálculo'],
      ...operations.map((op) => [
        op.id,
        op.type == 'investment' ? 'Inversión' : 'Préstamo',
        op.description,
        '\$${op.amount.toStringAsFixed(2)}',
        '${op.rate}%',
        '${op.period} años',
        DateFormat('dd/MM/yyyy').format(op.date),
        op.calculationType == 'simple' ? 'Simple' : 'Compuesto',
      ]),
    ];

    final csv = const ListToCsvConverter().convert(csvData);
    await _shareFile(csv, 'operaciones_financieras.csv');
  }

  // Método para exportar a PDF
  Future<void> exportOperationsToPdf() async {
    final operations = await _controller.getAllOperations();
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              _buildHeader('Reporte de Operaciones Financieras'),
              pw.SizedBox(height: 20),
              _buildOperationsTable(operations),
            ],
          );
        },
      ),
    );

    await _sharePdf(pdf, 'reporte_operaciones.pdf');
  }

  // Método para exportar tabla de amortización a PDF
  Future<void> exportAmortizationToPdf(int operationId) async {
    final operation = await _controller.getOperation(operationId);
    if (operation == null || operation.type != 'loan') return;

    final table = _controller.generateAmortizationTable(operation);
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape, // Usar formato horizontal
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildPdfHeader(operation),
              pw.SizedBox(height: 15),
              _buildPdfAmortizationTable(table),
              pw.SizedBox(height: 20),
              _buildPdfSummary(table, operation),
              _buildHeader('Tabla de Amortización: ${operation.description}'),
              pw.SizedBox(height: 20),
              _buildAmortizationTable(table),
            ],
          );
        },
      ),
    );
    //_buildAmortizationTable(table);
    await _saveAndSharePdf(pdf, 'Amortizacion_${operation.description}.pdf');

  }

  // Widgets para construcción del PDF
  pw.Widget _buildHeader(String title) {
    return pw.Header(
      level: 0,
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 18,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _buildPdfHeader(FinancialOperation operation) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Tabla de Amortización',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          'Préstamo: ${operation.description}',
          style: const pw.TextStyle(fontSize: 14),
        ),
        pw.Text(
          'Monto: \$${operation.amount.toStringAsFixed(2)} | '
              'Tasa: ${operation.rate}% anual | '
              'Plazo: ${operation.period} años | '
              'Pago mensual: \$${_controller.calculateLoanPayment(operation).toStringAsFixed(2)}',
          style: const pw.TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  pw.Widget _buildPdfAmortizationTable(List<AmortizationEntry> table) {
    return pw.TableHelper.fromTextArray(
      border: pw.TableBorder(
        left: const pw.BorderSide(width: 0.5),
        top: const pw.BorderSide(width: 0.5),
        right: const pw.BorderSide(width: 0.5),
        bottom: const pw.BorderSide(width: 0.5),
        horizontalInside: const pw.BorderSide(width: 0.3),
        verticalInside: const pw.BorderSide(width: 0.3),
      ),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 10,
        color: PdfColors.white,
      ),
      headerDecoration: pw.BoxDecoration(
        color: PdfColors.blue700,
      ),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellAlignment: pw.Alignment.center,
      columnWidths: {
        0: const pw.FixedColumnWidth(25),  // N°
        1: const pw.FixedColumnWidth(50),  // Fecha
        2: const pw.FixedColumnWidth(50),  // Pago
        3: const pw.FixedColumnWidth(50),  // Principal
        4: const pw.FixedColumnWidth(50),  // Interés
        5: const pw.FixedColumnWidth(60),  // Saldo
      },
      headers: ['N°', 'Fecha', 'Pago', 'Principal', 'Interés', 'Saldo'],
      data: table.map((entry) {
        return [
          entry.paymentNumber.toString(),
          DateFormat('MMM yyyy').format(entry.date), // Formato "Apr 2025"
          _formatCurrency(entry.payment),
          _formatCurrency(entry.principal),
          _formatCurrency(entry.interest),
          _formatCurrency(entry.remainingBalance),
        ];
      }).toList(),
    );
  }

  pw.Widget _buildPdfSummary(List<AmortizationEntry> table, FinancialOperation operation) {
    final totalInterest = table.fold<double>(0, (sum, entry) => sum + entry.interest);
    final totalPayments = table.fold<double>(0, (sum, entry) => sum + entry.payment);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Resumen Total:',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Total de Pagos:', style: const pw.TextStyle(fontSize: 10)),
            pw.Text(table.length.toString(), style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Total de Intereses:', style: const pw.TextStyle(fontSize: 10)),
            pw.Text(_formatCurrency(totalInterest), style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Total Pagado:', style: const pw.TextStyle(fontSize: 10)),
            pw.Text(_formatCurrency(totalPayments), style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Costo Financiero:', style: const pw.TextStyle(fontSize: 10)),
            pw.Text(
              _formatCurrency(totalPayments - operation.amount),
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.TableRow _buildSummaryRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 12),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildOperationsTable(List<FinancialOperation> operations) {
    return pw.Table.fromTextArray(
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: pw.BoxDecoration(color: PdfColors.blue700),
      data: [
        ['Tipo', 'Descripción', 'Monto', 'Tasa', 'Período', 'Fecha'],
        ...operations.map((op) => [
          op.type == 'investment' ? 'Inversión' : 'Préstamo',
          op.description,
          '\$${op.amount.toStringAsFixed(2)}',
          '${op.rate}%',
          '${op.period} años',
          DateFormat('dd/MM/yyyy').format(op.date),
        ]),
      ],
    );
  }

  pw.Widget _buildAmortizationTable(List<AmortizationEntry> table) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: pw.FlexColumnWidth(1),
        1: pw.FlexColumnWidth(2),
        2: pw.FlexColumnWidth(2),
        3: pw.FlexColumnWidth(2),
        4: pw.FlexColumnWidth(2),
        5: pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            'N°', 'Fecha', 'Pago', 'Principal', 'Interés', 'Saldo'
          ].map((text) => pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(text, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          )).toList(),
        ),
        ...table.map((entry) => pw.TableRow(
          children: [
            entry.paymentNumber.toString(),
            DateFormat('MMM yyyy').format(entry.date),
            _formatCurrency(entry.payment),
            _formatCurrency(entry.principal),
            _formatCurrency(entry.interest),
            _formatCurrency(entry.remainingBalance),
          ].map((text) => pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(text),
          )).toList(),
        )),
      ],
    );
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
      locale: 'en_US',
    ).format(value);
  }

  Future<void> _saveAndSharePdf(pw.Document pdf, String fileName) async {
    try {
      if (Platform.isLinux) {
        final dir = await getDownloadsDirectory();
        final file = File('${dir?.path}/$fileName');
        await file.writeAsBytes(await pdf.save());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF guardado en: ${file.path}')),
        );
      } else {
        await Printing.sharePdf(
          bytes: await pdf.save(),
          filename: fileName,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al exportar: ${e.toString()}')),
      );
    }
  }

  // Helpers para compartir archivos
  Future<void> _shareFile(String content, String fileName) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsString(content);

    try {
      if (Platform.isLinux) {
        // Solución alternativa para Linux
        final uri = file.uri.toString();
        await Process.run('xdg-open', [tempDir.path]);
        if (kDebugMode) {
          print('Archivo guardado en: $uri');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Archivo guardado en: ${file.path}')),
        );
      } else {
        // Usar share_plus para otras plataformas
        await Share.shareXFiles([XFile(file.path)]);
      }
    } catch (e) {
      print('Error al compartir: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al exportar: ${e.toString()}')),
      );
    }
  }

  Future<void> _sharePdf(pw.Document pdf, String fileName) async {
    final bytes = await pdf.save();

    if (Platform.isLinux) {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);

      await Process.run('xdg-open', [tempDir.path]);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF guardado en: ${file.path}')),
      );
    } else {
      await Printing.sharePdf(
        bytes: bytes,
        filename: fileName,
      );
    }
  }
}