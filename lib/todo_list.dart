import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Todolist extends StatefulWidget {
  //final token;
  //const Todolist({@required this.token, super.key});
  const Todolist(
      {super.key,
      //required this.token,
      required this.id,
      required this.task,
      required this.taskcomp,
      //this.onChanged,
      this.deletetask,
      this.update});

  final String id;
  final String task;
  final bool taskcomp;
  //final Function(bool?)? onChanged;
  final Function(BuildContext, String)? deletetask;
  final Function(BuildContext, String, bool)? update;
  @override
  State<Todolist> createState() => _TodolistState();
}

class _TodolistState extends State<Todolist> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: (context) =>
                  widget.deletetask?.call(context, widget.id),
              icon: Icons.delete,
              borderRadius: BorderRadius.circular(15),
              backgroundColor: Colors.red,
            ),
          ],
        ),
        child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                Checkbox(
                  value: widget.taskcomp,
                  onChanged: (bool? newValue) {
                    if (newValue != null) {
                      widget.update?.call(context, widget.id, newValue);
                    }
                  },
                  side: BorderSide(color: Colors.white),
                ),
                Text(widget.task,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        decoration: widget.taskcomp == true
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: Colors.white,
                        decorationThickness: 2)),
              ],
            )),
      ),
    );
  }
}
