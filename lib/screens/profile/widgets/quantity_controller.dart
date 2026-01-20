import 'package:mana_mana_app/core/constants/app_dimens.dart';
import 'package:flutter/material.dart';

class QuantityController extends StatefulWidget {
  final ValueChanged<int>? onChanged;
  final int initialValue;

  const QuantityController({
    Key? key,
    this.onChanged,
    this.initialValue = 1,
  }) : super(key: key);

  @override
  State<QuantityController> createState() => _QuantityControllerState();
}

class _QuantityControllerState extends State<QuantityController> {
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialValue;
  }

  @override
  void didUpdateWidget(QuantityController oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _quantity = widget.initialValue;
    }
  }

  void _increment() {
    setState(() {
      if (_quantity < 5) {
        _quantity++;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Maximum quantity reached'),
          ),
        );
      }
      widget.onChanged?.call(_quantity);
    });
  }

  void _decrement() {
    setState(() {
      if (_quantity > 1) {
        _quantity--;
        widget.onChanged?.call(_quantity);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Minimum quantity reached'),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
            onPressed: _decrement,
            icon: const Icon(Icons.arrow_left, size: 30)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$_quantity',
            style: const TextStyle(fontSize: AppDimens.fontSizeBig),
          ),
        ),
        IconButton(
            onPressed: _increment,
            icon: const Icon(
              Icons.arrow_right,
              size: 30,
            )),
      ],
    );
  }
}
