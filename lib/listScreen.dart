

import 'package:flutter/material.dart';
import 'package:flutter_calender/helpers/database_helpers.dart';
import 'package:flutter_calender/models/task_model.dart';
import 'package:intl/intl.dart';

import 'addTaskScreen.dart';

class ToDoListScreen extends StatefulWidget {
  @override
  _ToDoListScreenState createState() => _ToDoListScreenState();
}

class _ToDoListScreenState extends State<ToDoListScreen> {

  Future<List<Task>> _taskList;
  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');
  @override
  void initState(){
    super.initState();
    _updateTaskList();
  }

  _updateTaskList(){
    setState(() {
      _taskList = DatabaseHelper.instance.getTaskList();
    });
  }


  Widget buildTask(Task task){
   return Padding(
       padding: EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        children: [
          ListTile(
            title: Text(task.title,style: TextStyle(fontSize: 18.0,decoration: task.status == 0 ? TextDecoration.none :TextDecoration.lineThrough),),
            subtitle: Text('${_dateFormatter.format(task.date) }.${task.priority}',style: TextStyle(fontSize: 15.0,decoration: task.status == 0 ? TextDecoration.none :TextDecoration.lineThrough)),
            trailing: Checkbox(onChanged: (value){
             task.status = value ? 1 : 0 ;
             DatabaseHelper.instance.updateTask(task);
             _updateTaskList();

             },
              activeColor: Colors.blue,
              value: task.status == 1 ? true : false,
            ),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_)=>AddTaskScreen(
               updateTaskList: _updateTaskList,
              task : task,

            ))),
          ),
          Divider(),
        ],
      )
   );

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: Icon(Icons.add),
        onPressed: () =>Navigator.push(context, MaterialPageRoute(builder: (_)=> AddTaskScreen(

         updateTaskList: _updateTaskList,

        ))),
      ),
      body:FutureBuilder(
        future: _taskList,
        builder: (context , snapshot){
          if(!snapshot.hasData){
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final int completedTaskCount = snapshot.data.where((Task task) =>task.status == 1).toList().length;
          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 80.0),
            itemCount: 1 + snapshot.data.length,
            itemBuilder: (BuildContext context , int index){

              if(index==0) {
                return  Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.0,vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("My Tasks",style: TextStyle(color: Colors.black,fontSize: 40.0,fontWeight: FontWeight.bold),),
                      SizedBox(height: 10.0,),
                      Text('$completedTaskCount of ${snapshot.data.length}',style: TextStyle(color: Colors.grey,fontSize: 20.0,fontWeight: FontWeight.w600),),
                    ],
                  ),
                );
              }
              return    buildTask( snapshot.data[index-1]);
            },

          );
        }

      )
    );
  }
}
