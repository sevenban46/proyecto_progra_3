import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../controllers/financial_controller.dart';
import '../models/financial_operation.dart';
import '../services/export_service.dart';
import 'amortization_table.dart';
import 'operation_detail.dart';

class OperationListPage extends StatefulWidget {
  const OperationListPage({Key? key}) : super(key: key);

  @override
  _OperationListPageState createState() => _OperationListPageState();
}

class _OperationListPageState extends State<OperationListPage> {
  final FinancialController _controller = FinancialController();
  List<FinancialOperation> _operations = [];
  late final ExportService _exportService;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _exportService = ExportService(_controller, context);
    _loadOperations();
  }

  Future<void> _loadOperations() async {
    if (mounted) setState(() => _isLoading = true);
    final operations = await _controller.getAllOperations();
    if (mounted) {
      setState(() {
        _operations = operations;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calculadora Financiera',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          if (_operations.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) async {
                switch (value) {
                  case 'csv':
                    await _exportService.exportOperationsToCsv();
                    break;
                  case 'pdf':
                    await _exportService.exportOperationsToPdf();
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'csv',
                  child: Text('Exportar a CSV'),
                ),
                const PopupMenuItem(
                  value: 'pdf',
                  child: Text('Exportar a PDF'),
                ),
              ],
              icon: const Icon(Icons.import_export, color: Colors.white),
            ),
          IconButton(
            icon: const Icon(Icons.calculate, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OperationDetailPage(),
                ),
              ).then((_) => _loadOperations());
            },
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const OperationDetailPage(),
            ),
          ).then((_) => _loadOperations());
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_operations.isEmpty) {
      return _buildEmptyState();
    }
    return _buildOperationsList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.list_alt, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No hay operaciones registradas',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Presiona el botón + para agregar una nueva',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationsList() {
    return ListView.builder(
      itemCount: _operations.length,
      itemBuilder: (context, index) {
        final operation = _operations[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            title: Text(operation.description),
            subtitle: Text(
              'Monto: \$${operation.amount.toStringAsFixed(2)} - '
                  'Tasa: ${operation.rate}% - '
                  '${operation.period} años',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            OperationDetailPage(operation: operation),
                      ),
                    ).then((_) => _loadOperations());
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await _showDeleteConfirmation(context, operation);
                  },
                ),
              ],
            ),
            onTap: () {
              if (operation.type == 'loan') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AmortizationTablePage(operation: operation),
                  ),
                );
              } else {
                _showCalculationResults(context, operation);
              }
            },
          ),
        );
      },
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, FinancialOperation operation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de eliminar la operación "${operation.description}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _controller.deleteOperation(operation.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Operación eliminada')),
        );
      }
      _loadOperations();
    }
  }

  void _showCalculationResults(BuildContext context, FinancialOperation operation) {
    final simpleInterest = _controller.calculateSimpleInterest(
      operation.amount,
      operation.rate,
      operation.period,
    );
    final compoundInterest = _controller.calculateCompoundInterest(
      operation.amount,
      operation.rate,
      operation.period,
    );
    final futureValue = _controller.calculateFutureValue(
      operation.amount,
      operation.rate,
      operation.period,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Resultados: ${operation.description}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Interés simple: \$${simpleInterest.toStringAsFixed(2)}'),
            Text('Interés compuesto: \$${compoundInterest.toStringAsFixed(2)}'),
            Text('Valor futuro: \$${futureValue.toStringAsFixed(2)}'),
            if (operation.type == 'loan')
              Text(
                'Pago anualidad: \$${_controller.calculateAnnuityPayment(
                  operation.amount,
                  operation.rate,
                  operation.period,
                ).toStringAsFixed(2)}',
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}