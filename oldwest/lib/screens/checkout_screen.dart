import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../services/api_client.dart';
import '../state/cart_controller.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.api, required this.cart});
  final ApiClient api;
  final CartController cart;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  String _orderType = 'pickup';
  String _paymentMethod = 'pix';
  bool _sending = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (widget.cart.isEmpty) {
      Navigator.pop(context);
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);
    try {
      final result = await widget.api.createOrder(
        customerName: _nameController.text,
        customerPhone: _phoneController.text,
        orderType: _orderType,
        address: _orderType == 'delivery' ? _addressController.text : null,
        notes: _notesController.text,
        paymentMethod: _paymentMethod,
        items: widget.cart.lines
            .map((line) => {
                  'product_id': line.product.id,
                  'quantity': line.quantity,
                })
            .toList(growable: false),
      );
      if (!mounted) return;
      final orderId = result['id']?.toString() ?? '—';
      final total = result['total_cents'] is int
          ? result['total_cents'] as int
          : int.tryParse('${result['total_cents']}') ?? widget.cart.subtotalCents;
      widget.cart.clear();
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF438B58), size: 48),
          title: const Text('Pedido confirmado!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Seu pedido #$orderId foi enviado para a cozinha.'),
              const SizedBox(height: 10),
              Text(formatBRL(total), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              const Text('A loja confirmará os próximos detalhes.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.muted, fontSize: 12)),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Voltar ao cardápio'),
            ),
          ],
        ),
      );
    } on ApiException catch (error) {
      if (mounted) _showError(error.message);
    } catch (_) {
      if (mounted) _showError('Não foi possível enviar o pedido. Confira sua conexão e tente novamente.');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Finalizar pedido')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
            children: [
              _sectionHeading(context, 'Como prefere receber?', Icons.near_me_rounded),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'pickup', label: Text('Retirar'), icon: Icon(Icons.storefront_outlined)),
                  ButtonSegment(value: 'delivery', label: Text('Entrega'), icon: Icon(Icons.delivery_dining_rounded)),
                ],
                selected: {_orderType},
                onSelectionChanged: _sending ? null : (selection) => setState(() => _orderType = selection.first),
              ),
              const SizedBox(height: 23),
              _sectionHeading(context, 'Seus dados', Icons.person_outline_rounded),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Seu nome', hintText: 'Como podemos chamar você?'),
                validator: (value) => value == null || value.trim().isEmpty ? 'Informe seu nome.' : null,
              ),
              const SizedBox(height: 11),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Telefone (opcional)', hintText: '(00) 00000-0000'),
              ),
              if (_orderType == 'delivery') ...[
                const SizedBox(height: 11),
                TextFormField(
                  controller: _addressController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Endereço de entrega', hintText: 'Rua, número, bairro e complemento'),
                  validator: (value) => _orderType == 'delivery' && (value == null || value.trim().isEmpty)
                      ? 'Informe o endereço para entrega.'
                      : null,
                ),
              ],
              const SizedBox(height: 23),
              _sectionHeading(context, 'Pagamento', Icons.payments_outlined),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _paymentMethod,
                decoration: const InputDecoration(labelText: 'Forma de pagamento'),
                items: const [
                  DropdownMenuItem(value: 'pix', child: Text('Pix')),
                  DropdownMenuItem(value: 'cash', child: Text('Dinheiro')),
                  DropdownMenuItem(value: 'credit_card', child: Text('Cartão de crédito')),
                  DropdownMenuItem(value: 'debit_card', child: Text('Cartão de débito')),
                ],
                onChanged: _sending ? null : (value) => setState(() => _paymentMethod = value ?? 'pix'),
              ),
              const SizedBox(height: 23),
              _sectionHeading(context, 'Alguma observação?', Icons.notes_rounded),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
                maxLength: 240,
                decoration: const InputDecoration(hintText: 'Ex.: retirar no balcão, sem cebola…'),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    const Expanded(child: Text('Subtotal do pedido', style: TextStyle(color: AppTheme.muted))),
                    Text(formatBRL(widget.cart.subtotalCents), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
              if (_orderType == 'delivery') ...[
                const SizedBox(height: 8),
                const Text('A taxa de entrega é definida pela loja. O total final será exibido após o envio.', style: TextStyle(color: AppTheme.muted, fontSize: 11)),
              ],
              const SizedBox(height: 17),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _sending ? null : _submit,
                  icon: _sending
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.local_fire_department_rounded),
                  label: Text(_sending ? 'Enviando pedido…' : 'Confirmar pedido'),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _sectionHeading(BuildContext context, String title, IconData icon) => Row(
        children: [
          Icon(icon, size: 19, color: AppTheme.ember),
          const SizedBox(width: 8),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
        ],
      );
}
