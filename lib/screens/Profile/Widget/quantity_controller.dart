import 'package:flutter/material.dart';

class QuantityController extends StatefulWidget {
  final ValueChanged<int>? onChanged;

  const QuantityController({Key? key, this.onChanged}) : super(key: key);

  @override
  State<QuantityController> createState() => _QuantityControllerState();
}

class _QuantityControllerState extends State<QuantityController> {
  int _quantity = 1;

  void _increment() {
    setState(() {
      if (_quantity < 5) {
        _quantity++;
      }
      widget.onChanged?.call(_quantity);
    });
  }

  void _decrement() {
    setState(() {
      if (_quantity > 1) {
        _quantity--;
        widget.onChanged?.call(_quantity);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(onPressed: _decrement, icon: const Icon(Icons.remove)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$_quantity',
            style: const TextStyle(fontSize: 18),
          ),
        ),
        IconButton(onPressed: _increment, icon: const Icon(Icons.add)),
      ],
    );
  }
}
