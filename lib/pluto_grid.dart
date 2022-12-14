import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class Grid extends StatefulWidget {
  const Grid({Key? key}) : super(key: key);
  @override
  State<Grid> createState() => _GridState();
}

class _GridState extends State<Grid> {

  var age;
  var id;
  var name;
  var joinedDate;
  var time;
  var role;
  var colors;
  var newId;
  var  addRowCheck = '';

  //Columns
  final List<PlutoColumn> columns = <PlutoColumn>[
    PlutoColumn(
      title: 'Id',
      field: 'id',
      type: PlutoColumnType.number(),
      // readOnly: true,//make the colum not editable
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
      type: PlutoColumnType.select(<String>['red', 'blue', 'green', 'yellow'], enableColumnFilter: false,),
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
    //Static Data
    // PlutoRow(
    //   cells: {
    //     'id': PlutoCell(value: '0'),
    //     'name': PlutoCell(value: 'Anik'),
    //     'age': PlutoCell(value: 22),
    //     'time': PlutoCell(value: '08:00'),
    //     'role': PlutoCell(value: 'Programmer'),
    //     'joined date': PlutoCell(value: '2021-01-01'),
    //     'colors': PlutoCell(value: 'green'),
    //   },
    // ),
    // PlutoRow(
    //   cells: {
    //     'id': PlutoCell(value: '1'),
    //     'name': PlutoCell(value: 'Rilon'),
    //     'age': PlutoCell(value: 23),
    //     'time': PlutoCell(value: '02:00'),
    //     'role': PlutoCell(value: 'HouseWife'),
    //     'joined date': PlutoCell(value: '2021-01-01'),
    //     'colors': PlutoCell(value: 'blue'),
    //   },
    // ),
  ];

  //ColumnGroups
  final List<PlutoColumnGroup> columnGroups = [
    PlutoColumnGroup(title: 'User information', fields: ['name', 'age', 'joined date']),
    PlutoColumnGroup(title: 'Nested', children: [
      PlutoColumnGroup(title: 'Working hours', fields: ['time']),
      PlutoColumnGroup(title: 'Choice', fields: ['role', 'colors']),
    ]),
  ];

  static late PlutoGridStateManager stateManager;
  @override
  void initState() {
    super.initState();
  }
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
                      int index = 0;
                      setState(() {
                        index= index + 1;
                        newId = rows.length + 1;
                        addRowCheck = 'addedRow';
                      });
                      stateManager.insertRows(index, [
                        PlutoRow(
                        cells: {
                          'id': PlutoCell(value: newId),
                          'name': PlutoCell(value: ''),
                          'age': PlutoCell(value:  null),
                          'time': PlutoCell(value: ''),
                          'role': PlutoCell(value: ''),
                          'joined date': PlutoCell(value: ''),
                          'colors': PlutoCell(value: ''),
                        },
                      ),
                    ]);
                    },
                     child: const Text("Add row")
                  ),

                  //Remove Row
                  ElevatedButton(
                    onPressed: (){
                      stateManager.removeCurrentRow();
                      setState(() {
                        addRowCheck = 'removedRow';
                      });
                    },
                     child: const Text("Remove Row")
                  ),

                  //Clear Button
                  ElevatedButton(
                    onPressed: (){
                      // removeAllData(); //This will Clear all the data in firesotre
                      setState((){
                        rows.clear();
                      });
                    },
                     child: const Text("Clear"),
                  ),
                ],
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
                  } else if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height - kToolbarHeight,
                      child: const Center(child: CircularProgressIndicator(),
                      ),
                    );
                  } else{
                    List<QueryDocumentSnapshot<Object?>> userData = snapshot.data!.docs;
                    for(int i =0; i<userData.length; i++){
                      age = userData[i]['age'];
                      name = userData[i]['name'];
                      time = userData[i]['time'];
                      joinedDate = userData[i]['joined_date'];
                      role = userData[i]['role'];
                      colors = userData[i]['colors'];
                      if(addRowCheck == ''){
                        if(userData.length != rows.length){
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
                      }else if(addRowCheck == 'addedRow'){
                        if(userData.length != rows.length -1){
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
                      } else if(addRowCheck == 'removedRow'){
                        if(userData.length != rows.length){
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
                      }
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
                            //To check which field value is changed
                            if(event.column!.field == 'age'){
                              age = event.value;
                            }else if(event.column!.field == 'name'){
                              name = event.value;
                            }else if(event.column!.field == 'time'){
                              time = event.value;
                            }else if(event.column!.field == 'role'){
                              role = event.value;
                            }else if(event.column!.field == 'joined date'){
                              joinedDate = event.value;
                            } else if(event.column!.field == 'colors'){
                              colors = event.value;
                            }
                            if(checkId(userData, event) == rows[event.rowIdx!].cells['id']!.value){
                              var dataId = checkId(userData, event);
                              update(dataId);
                            }else{
                               setState(() {
                                var data ={
                                  'id':newId,
                                  'name':'',
                                  'age':null,
                                  'joined_date':'',
                                  'time':'',
                                  'role':'',
                                  'colors':''
                                };
                                addData(data);
                              });
                            }
                          });
                          print(event);
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

  addData(data) async{
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(),
      ),
    );
    DocumentReference documentReferencer = FirebaseFirestore.instance.collection("user_data").doc(data['id'].toString());
    await documentReferencer.set(data).then((value) => Navigator.pop(context));      
  }

  update(dataId) async{
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(),
      ),
    );
    rows.clear();
    DocumentReference documentReferencer = FirebaseFirestore.instance.collection("user_data").doc(dataId.toString());
    Map<String, dynamic> data = {
      'id': dataId,
      'name': name,
      'age': age,
      'joined_date': joinedDate,
      'time' : time,
      'role': role,
      'colors': colors,
    };
    await documentReferencer.update(data).then((value){
     data;
      Navigator.pop(context);
    } ); 
  }

  //This function checks is the firebase data id and edited item id is equal or not and return the firebase id
  checkId(fireStoreDataId, event){
    var id;
    for(int i = 0; i< fireStoreDataId.length; i++){
      if(rows[event.rowIdx!].cells['id']!.value == fireStoreDataId[i]['id']){
        setState(() {
          id = fireStoreDataId[i]['id'];
        });
      }
    }
    return id;
  }

  removeAllData() async{
    var snapshots = await FirebaseFirestore.instance.collection('user_data').get();//fetches the collection
    for (DocumentSnapshot ds in snapshots.docs) {
      ds.reference.delete();
      }
      await FirebaseFirestore.instance.batch().commit();
  }
}