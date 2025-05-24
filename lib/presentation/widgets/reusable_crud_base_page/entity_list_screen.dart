import 'package:flutter/material.dart';
import 'package:inner_child_app/presentation/widgets/reusable_crud_base_page/entity_form_modal.dart';

class EntityListScreen <T> extends StatefulWidget {
  final String title;
  final List<T> entities;

  final Function(T?) onCreateEntity;
  final Function(T) onUpdateEntity;
  final Function(T) onDeleteEntity;

  final Widget Function(BuildContext, T, VoidCallback, VoidCallback) itemBuilder;
  final Widget Function(BuildContext, T?, Function(T)) formBuilder;

  // Search function
  final bool Function(T entity, String query) searchFilter;
  const EntityListScreen({super.key, required this.title, required this.entities, required this.onCreateEntity, required this.onUpdateEntity, required this.onDeleteEntity, required this.itemBuilder, required this.formBuilder, required this.searchFilter});

  @override
  State<EntityListScreen<T>> createState() => _EntityListScreenState<T>();
}

class _EntityListScreenState<T> extends State<EntityListScreen<T>> {
  final TextEditingController _searchController = TextEditingController();
  List<T> _filteredEntities = [];

  @override
  void initState() {
    super.initState();
    _filteredEntities = widget.entities;

    _searchController.addListener(() {
      _filterEntities();
    });
  }

  void _filterEntities() {
    final query = _searchController.text.toLowerCase();

    if (query.isEmpty) {
      setState(() {
        _filteredEntities = widget.entities;
      });
      return;
    }

    setState(() {
      // Use the provided search filter function
      _filteredEntities = widget.entities.where(
              (entity) => widget.searchFilter(entity, query)
      ).toList();
    });
  }

  @override
  void didUpdateWidget(EntityListScreen<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entities != widget.entities) {
      setState(() {
        _filteredEntities = widget.entities;
      });
      _filterEntities();
    }
  }

  void _showEntityModal(T? entity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EntityFormModal<T>(
        entity: entity,
        formBuilder: widget.formBuilder,
        onSave: entity == null ? widget.onCreateEntity : widget.onUpdateEntity,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showEntityModal(null),
          child: const Icon(Icons.add),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          prefixIcon: Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: const Text('Last 30 days'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                        )),
                        Expanded(child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.filter_list, size: 16),
                          label: const Text('Filters'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                        )),
                        Expanded(child: ElevatedButton(
                          onPressed: () => _showEntityModal(null),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal[700],
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('+ Add'),
                        )),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _filteredEntities.isEmpty
                          ? const Center(child: Text('No items found'))
                          : ListView.separated(
                        itemCount: _filteredEntities.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final entity = _filteredEntities[index];
                          return widget.itemBuilder(
                            context,
                            entity,
                                () => _showEntityModal(entity),
                                () {
                              widget.onDeleteEntity(entity);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
