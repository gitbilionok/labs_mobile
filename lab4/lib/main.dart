import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StudentsList(),
    );
  }
}

class Student {
  final String name;
  final String surname;
  final double averageGrade;
  final String imageUrl;
  final String description;

  Student({
    required this.name,
    required this.surname,
    required this.averageGrade,
    required this.imageUrl,
    required this.description,
  });
}

class StudentsList extends StatefulWidget {
  @override
  _StudentsListState createState() => _StudentsListState();
}

class _StudentsListState extends State<StudentsList> {
  List<Student> students = [];
  List<Student> filteredStudents = [];
  String surnameFilter = '';
  double? gradeFilter;

  void _addStudent(String name, String surname, double averageGrade, String imageUrl, String description) {
    setState(() {
      students.add(Student(name: name,
          surname: surname,
          averageGrade: averageGrade,
          imageUrl:imageUrl,
          description: description));
      _filterStudents();
    });
  }

  void _removeStudent(int index) {
    setState(() {
      students.removeAt(index);
      _filterStudents();
    });
  }

  void _sortStudents() {
    setState(() {
      students.sort((a, b) => a.name.compareTo(b.name));
      _filterStudents();
    });
  }

  void _resetSort() {
    setState(() {
      students.shuffle();
      _filterStudents();
    });
  }

  void _filterStudents() {
    setState(() {
      filteredStudents = students.where((student) {
        bool surnameMatches = student.surname.toLowerCase().contains(surnameFilter.toLowerCase());
        bool gradeMatches = gradeFilter == null || student.averageGrade >= gradeFilter!;
        return surnameMatches && gradeMatches;
      }).toList();
    });
  }

  void _showAddStudentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String name = '';
        String surname = '';
        String averageGrade = '';
        String imageUrl = '';
        String description = '';
        return AlertDialog(
          title: Text('Add Student'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                onChanged: (value) {
                  name = value;
                },
                decoration: InputDecoration(hintText: 'Name'),
              ),
              TextField(
                onChanged: (value) {
                  surname = value;
                },
                decoration: InputDecoration(hintText: 'Surname'),
              ),
              TextField(
                onChanged: (value) {
                  averageGrade = value;
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: 'Average Grade'),
              ),
              TextField(
                onChanged: (value) {
                  imageUrl = value;
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: 'Image url'),
              ),
              TextField(
                onChanged: (value) {
                  description = value;
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: 'description'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Add'),
              onPressed: () {
                if (name.isNotEmpty && surname.isNotEmpty && averageGrade.isNotEmpty) {
                  _addStudent(name, surname, double.tryParse(averageGrade) ?? 0.0, imageUrl, description);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showGradeFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String inputGrade = '';
        return AlertDialog(
          title: Text('Filter by Grade'),
          content: TextField(
            onChanged: (value) {
              inputGrade = value;
            },
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: 'Enter minimum grade'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Filter'),
              onPressed: () {
                setState(() {
                  gradeFilter = double.tryParse(inputGrade);
                  _filterStudents();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Students List'),
        actions: [
          IconButton(
            icon: Icon(Icons.sort_by_alpha),
            onPressed: _sortStudents,
          ),
          IconButton(
            icon: Icon(Icons.shuffle),
            onPressed: _resetSort,
          ),
          IconButton(
            icon: Icon(Icons.filter_alt),
            onPressed: _showGradeFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  surnameFilter = value;
                  _filterStudents();
                });
              },
              decoration: const InputDecoration(
                labelText: 'Search by Surname',
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredStudents.length,
              itemBuilder: (context, index) {
                final student = filteredStudents[index];
                return Dismissible(
                  key: Key(student.name + student.surname),
                  onDismissed: (direction) {
                    _removeStudent(students.indexOf(student));
                  },
                  background: Container(color: Colors.red),
                  child: ListTile(
                    title: Text('${student.name} ${student.surname}'),
                    subtitle: Text('Average Grade: ${student.averageGrade.toString()}'),
                    trailing: IconButton(
                      icon: Icon(Icons.info_outline),
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => StudentDetailsScreen(student: student),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              var begin = Offset(1.0, 0.0);
                              var end = Offset.zero;
                              var curve = Curves.easeInOut;
                              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                              var offsetAnimation = animation.drive(tween);

                              return SlideTransition(
                                position: offsetAnimation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStudentDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}


class StudentDetailsScreen extends StatelessWidget {
  final Student student;

  StudentDetailsScreen({required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${student.name} ${student.surname}'),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          FadeInImage.assetNetwork(
            placeholder: 'assets/200w.gif',
            image: student.imageUrl,
            height: 200,
            width: 200,
          ),
          SizedBox(height: 20),
          Text(
            student.description,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
