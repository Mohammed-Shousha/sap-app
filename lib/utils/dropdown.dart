import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logger/logger.dart';

class DropdownSelection extends StatefulWidget {
  const DropdownSelection({super.key});

  @override
  State<DropdownSelection> createState() => _DropdownSelectionState();
}

class _DropdownSelectionState extends State<DropdownSelection> {
  List<String> _items = [];
  String? _selectedItem;

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    final QueryResult result = await GraphQLProvider.of(context).value.query(
          QueryOptions(
            document: gql(r'''
              query Medicines{
                medicines {
                  _id
                  name
                }
              }
            '''),
          ),
        );

    if (result.hasException) {
      Logger().e(result.exception.toString());
      return;
    }

    Logger().i(result.data);

    final List<String> items = result.data!['medicines']
        .map<String>((dynamic item) => item['name'])
        .toList();

    setState(() {
      _items = items.map((item) => item).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dropdown Button'),
      ),
      body: Center(
        child: DropdownButtonFormField<String>(
          value: _selectedItem,
          decoration: const InputDecoration(
            labelText: 'Select an item',
            border: OutlineInputBorder(),
          ),
          items: _items
              .map((item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  ))
              .toList(),
          onChanged: (String? value) {
            setState(() {
              _selectedItem = value;
            });
          },
        ),
      ),
    );
  }
}
