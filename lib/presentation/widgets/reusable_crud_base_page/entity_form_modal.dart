import 'package:flutter/material.dart';

class EntityFormModal<T> extends StatefulWidget {
  final T? entity;
  final Widget Function(BuildContext, T?, Function(T)) formBuilder;
  final Function(T) onSave;

  const EntityFormModal({
    super.key,
    this.entity,
    required this.formBuilder,
    required this.onSave,
  });

  @override
  State<EntityFormModal<T>> createState() => _EntityFormModalState<T>();
}

class _EntityFormModalState<T> extends State<EntityFormModal<T>> {
  late bool isUpdate;

  @override
  void initState() {
    super.initState();
    isUpdate = widget.entity != null;
  }

  void _handleSave(T entity) {
    widget.onSave(entity);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Get the available height minus the keyboard and status bar
    final availableHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.bottom -
        MediaQuery.of(context).padding.top;

    return Container(
      height: availableHeight * 0.85, // Take up 85% of available height
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isUpdate ? 'Update Customer' : 'Create New',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: widget.formBuilder(context, widget.entity, _handleSave),
          ),
        ],
      ),
    );
  }
}
