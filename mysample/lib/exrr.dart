

import 'package:animated_scroll_view/animated_scroll_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AnimatedScrollViewExample(),
    );
  }
}

@immutable
class MyModel {
  const MyModel({
    required this.id,
    required this.color,
  });
  final int id;
  final Color color;

  @override
  String toString() => 'MyModel(id: $id, color: $color)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MyModel && other.id == id && other.color == color;
  }

  @override
  int get hashCode => id.hashCode ^ color.hashCode;
}

class AnimatedScrollViewExample extends StatefulWidget {
  const AnimatedScrollViewExample({Key? key}) : super(key: key);

  @override
  State<AnimatedScrollViewExample> createState() =>
      _AnimatedScrollViewExampleState();
}

class _AnimatedScrollViewExampleState extends State<AnimatedScrollViewExample> {
  final eventController = DefaultEventController<MyModel>();
  late final ItemsNotifier<MyModel> itemsNotifier;
  final selectorNotifier = ValueNotifier<int?>(null);
  int itemsCount = 3;
  late List<MyModel> items;

  @override
  void initState() {
    super.initState();
    itemsNotifier = DefaultItemsNotifier<MyModel>(
      onItemsUpdate: (updatedList) => items = updatedList,
    );
    items = List.generate(
      itemsCount,
          (index) => MyModel(
        id: index,
        color: Colors.primaries[index % Colors.primaries.length],
      ),
    );
  }

  @override
  void dispose() {
    eventController.close();
    itemsNotifier.dispose();
    selectorNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AnimatedList'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.move_down),
            onPressed: () async {
              // Getting the id of item, which should be moved
              final id = selectorNotifier.value;
              // If there is no selected item - do nothing
              if (id == null) return;
              int? newIndex;
              final move = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    //title: const Text(
                    // 'Insert the index, selected item should be moved on',
                    //),
                    //content: Card(

                    //),
                    content: TextField(
                      //onTapOutside: () => newIndex = 2,
                      //keyboardType: TextInputType.number,
                      onTap: () => newIndex = 4,
                      //onChanged: (value) => newIndex = int.tryParse(value),
                    ),
                    actions: [
                      /*  TextButton(
                        onPressed: Navigator.of(context).pop,
                        child: const Text('Cancel'),
                      ),*/
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Move'),
                      ),
                    ],
                  );
                },
              );


              if (newIndex == null);
              if (move == true) {
                eventController.moveById(
                  itemId: id.toString(),
                  newIndex: ArgumentError.checkNotNull(newIndex),
                );
              }
              //},

            },  //tooltip: 'Move the selected item',
          ),
          IconButton(
            icon: const Icon(Icons.add_circle),
            onPressed: () {

              // Determining at which index to insert a new item.
              // If there is a selected item - getting its index by id using
              // ItemsNotifier(). Otherwise - just getting the last index, so
              // the item will be added to the end of the list
              final index = selectorNotifier.value == null
                  ? items.length
                  : itemsNotifier
                  .getIndexById(selectorNotifier.value.toString());
              // Here we're generating a new id for the new item
              final newId = itemsCount++;
              // Sending the insert event, so the item will be added
              // to the list with animation.
              eventController.insert(
                index: index,
                item: MyModel(
                  id: newId,
                  color: Colors.primaries[newId % Colors.primaries.length],
                ),
              );
            },
            tooltip: 'insert a new item',
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle),
            onPressed: () {
              // Getting the id of item, which should be removed
              final id = selectorNotifier.value;
              if (id == null) return;
              // Sending the remove event, so the item will be removed with
              // animation
              eventController.removeById(itemId: id.toString());
            },
            tooltip: 'remove the selected item',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ValueListenableBuilder<int?>(
          valueListenable: selectorNotifier,
          builder: (context, value, child) {
            return AnimatedListView<MyModel>(
              items: items,
              eventController: eventController,
              itemsNotifier: itemsNotifier,
              idMapper: (object) => object.id.toString(),
              itemBuilder: (item) {
                final textColor =
                value == item.id ? Colors.lightGreenAccent[400] : null;
                return Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => selectorNotifier.value = item.id,
                    child: SizedBox(
                      height: 80.0,
                      child: Card(
                        color: item.color,
                        child: Center(
                          child: Text(
                            'Processo ${item.id}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(color: textColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}