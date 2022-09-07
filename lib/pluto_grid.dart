import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class Grid extends StatefulWidget {
  const Grid({Key? key}) : super(key: key);
  @override
  State<Grid> createState() => _GridState();
}

class _GridState extends State<Grid> {

  //Columns
  final List<PlutoColumn> columns = <PlutoColumn>[
    PlutoColumn(
      title: 'Id',
      field: 'id',
      type: PlutoColumnType.number(),
      readOnly: true,//make the colum not editable
      sort: PlutoColumnSort.ascending,//sort
      enableRowDrag: true,//makes row dragable
      enableRowChecked: true,//checkbox
      backgroundColor: Colors.blue,//background color
      hide: false,//hides the column
      enableFilterMenuItem: false,
      applyFormatterInEditing: false,
    ),
    PlutoColumn(
      title: 'Name',
      field: 'name',
      type: PlutoColumnType.text()
    ),
    PlutoColumn(
      title: 'Age',
      field: 'age',
      type: PlutoColumnType.number(
        negative: false,
        format: '#,###',
        applyFormatOnInit: true,
        allowFirstDot: false,
      ),
    ),
    PlutoColumn(
      title: 'Joined Date',
      field: 'joined date',
      type: PlutoColumnType.date(
        startDate: DateTime(2022, 04, 17),
        endDate: DateTime(2022, 08, 17),
        format: 'yyyy-MM-dd',
        headerFormat: 'yyyy-MM',
        applyFormatOnInit: true,
      ),
    ),
    PlutoColumn(
      title: 'Time',
      field: 'time',
      type: PlutoColumnType.time(),
    ),
    PlutoColumn(
      title: 'Role',
      field: 'role',
      type: PlutoColumnType.select(
        <String>[
          'Programmer',
          'Designer',
          'Manager',
          'Owner',
        ],
    enableColumnFilter: true,
      ),
    ),
    PlutoColumn(
      title: 'Colors',
      field: 'colors',
      type: PlutoColumnType.select(<String>['red', 'blue', 'green'], enableColumnFilter: false,),
      renderer: (rendererContext) {
        Color textColor = Colors.black;
        if (rendererContext.cell.value == 'red') {
          textColor = Colors.red;
          } else if (rendererContext.cell.value == 'blue') {
            textColor = Colors.blue;
            } else if (rendererContext.cell.value == 'yellow') {
            textColor = Colors.yellow;
            } else if (rendererContext.cell.value == 'green') {
              textColor = Colors.green;
              }
              return Text(rendererContext.cell.value.toString(),
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            );
      },
    ),
  ];

  //Rows
  final List<PlutoRow> rows = [
    PlutoRow(
      cells: {
        'id': PlutoCell(value: '0'),
        'name': PlutoCell(value: 'Anik'),
        'age': PlutoCell(value: 22),
        'time': PlutoCell(value: '08:00'),
        'role': PlutoCell(value: 'Programmer'),
        'joined date': PlutoCell(value: '2021-01-01'),
        'colors': PlutoCell(value: 'green'),
      },
    ),
    PlutoRow(
      cells: {
        'id': PlutoCell(value: '1'),
        'name': PlutoCell(value: 'Rilon'),
        'age': PlutoCell(value: 23),
        'time': PlutoCell(value: '02:00'),
        'role': PlutoCell(value: 'HouseWife'),
        'joined date': PlutoCell(value: '2021-01-01'),
        'colors': PlutoCell(value: 'blue'),
      },
    ),
  ];

  //ColumnGroups
  final List<PlutoColumnGroup> columnGroups = [
    PlutoColumnGroup(title: 'User information', fields: ['name', 'age', 'joined date']),
    PlutoColumnGroup(title: 'Nested', children: [
      PlutoColumnGroup(title: 'Working hours', fields: ['time']),
      PlutoColumnGroup(title: 'Choice', fields: ['role', 'colors']),
    ]),
  ];

  late final PlutoGridStateManager stateManager;

  var age;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body:Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: addData,
                     child: const Text("SAVE")
                  ),
                  //Add Column
                  ElevatedButton(
                    onPressed: (){
                      // Be careful not to duplicate field names when adding columns.
                    final int lastIndex = stateManager.refColumns.originalList.length;
                    stateManager.insertColumns(0, [
                      PlutoColumn(
                        title: 'new column $lastIndex',
                        field: 'new_field_$lastIndex',
                        type: PlutoColumnType.text(),
                      )
                    ]);
                    },
                     child: const Text("Add Column")
                  ),

                  //Add Row
                  ElevatedButton(
                    onPressed: (){
                      final int lastIndex = stateManager.refRows.originalList.length;
                      stateManager.insertRows(0, [
                        PlutoRow(
                        cells: {
                          'id': PlutoCell(value: 'id $lastIndex'),
                          'name': PlutoCell(value: 'name $lastIndex'),
                          'age': PlutoCell(value:  lastIndex),
                          'time': PlutoCell(value: 'time $lastIndex'),
                          'role': PlutoCell(value: 'role $lastIndex'),
                          'joined date': PlutoCell(value: 'joined date $lastIndex'),
                          'colors': PlutoCell(value: 'colors $lastIndex'),
                        },
                      ),
                    ]);
                    },
                     child: const Text("Add row")
                  ),
                ],
              ),
            ),
            Expanded(
              child: PlutoGrid(
                columns: columns,
                rows: rows,
                columnGroups: columnGroups,
                onLoaded: (PlutoGridOnLoadedEvent event) {
                  stateManager = event.stateManager;
                },
                onChanged: (PlutoGridOnChangedEvent event) {
                  setState(() {
                    age = event.value;
                  });
                  print(event);
                },
                configuration: const PlutoGridConfiguration(),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection("user_data").snapshots(),
                  builder:((context, snapshot) {
                  if (!snapshot.hasData) {
                    return SizedBox(
                      height:MediaQuery.of(context).size.height - kToolbarHeight,
                      child: const Center( child: CircularProgressIndicator(),),
                    );
                  } else if (snapshot.connectionState ==ConnectionState.waiting) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height - kToolbarHeight,
                      child: const Center(child: CircularProgressIndicator(),
                      ),
                    );
                  } else{
                    List<QueryDocumentSnapshot<Object?>> userData = snapshot.data!.docs;
                  for(int i =0; i<userData.length; i++){
                    rows.add(
                    PlutoRow(
                      cells: {
                        'id': PlutoCell(value: userData[i]['id']),
                        'name': PlutoCell(value: userData[i]['name']),
                        'age': PlutoCell(value: userData[i]['age']),
                        'time': PlutoCell(value: userData[i]['time']),
                        'role': PlutoCell(value: userData[i]['role']),
                        'joined date': PlutoCell(value: userData[i]['joined_date']),
                        'colors': PlutoCell(value: userData[i]['colors']),
                      },
                    ),
                  );
                  }
                    return Container(
                      child: PlutoGrid(
                        columns: columns,
                        rows: rows,
                        columnGroups: columnGroups,
                        onLoaded: (PlutoGridOnLoadedEvent event) {
                          stateManager = event.stateManager;
                        },
                        onChanged: (PlutoGridOnChangedEvent event) {
                          setState(() {
                            age = event.value;
                          });print(event);
                        },
                        configuration: const PlutoGridConfiguration(),
                      ),
                    );
                  }
                })
              ),
            ),
          ],
        ),
      ),
    );
  }

  addData() async{
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(),
      ),
    );
    var docId =FirebaseFirestore.instance.collection("user_data").doc().id;
    DocumentReference documentReferencer = FirebaseFirestore.instance.collection("user_data").doc(docId);
    Map<String, dynamic> data = {
      'id': "91",
      'name': "Super Man",
      'age': age,
      'joined_date':"2052-11-02",
      'time' : '09:00',
      'role':'SuperHuman',
      'colors':'red',
    };
    await documentReferencer.set(data).then((value) => Navigator.pop(context));      
  }

  update() async{
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(),
      ),
    );
    var docId =FirebaseFirestore.instance.collection("user_data").doc().id;
    DocumentReference documentReferencer = FirebaseFirestore.instance.collection("user_data").doc(docId);
    Map<String, dynamic> data = {
      'id': "921",
      'name': "Green Goblin",
      'age': age,
      'joined_date':"2002-11-02",
      'time' : '09:00',
      'role':'Villian',
      'colors':'green',
    };
    await documentReferencer.update(data).then((value) => Navigator.pop(context)); 
  }

  searchIdFromIndex(){

  }
}