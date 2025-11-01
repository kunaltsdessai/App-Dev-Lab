class Task {
  final int? id;
  final String title;
  final int isDone;

  Task({this.id, required this.title, this.isDone = 0});

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'isDone': isDone};
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(id: map['id'], title: map['title'], isDone: map['isDone']);
  }
}
