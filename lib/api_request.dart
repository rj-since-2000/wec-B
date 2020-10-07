class Event {
  final String venue;
  final String description;
  final String title;
  final DateTime dateTime;

  Event({this.title, this.dateTime, this.venue, this.description});

  factory Event.fromJson(dynamic json) {
    String tempDate = json['date'];
    String tempTime = json['time'];
    String newDate;
    int p, p1, p2;
    int hour;
    String minute;
    String day, month, year;
    String finalDateTime;
    p1 = tempDate.indexOf('/');
    p2 = tempDate.lastIndexOf('/');

    if (p1 == 1)
      month = '0' + tempDate.substring(0, p1);
    else
      month = tempDate.substring(0, p1);

    if (p2 - p1 == 2)
      day = '0' + tempDate.substring(p1 + 1, p2);
    else
      day = tempDate.substring(p1 + 1, p2);

    year = tempDate.substring(p2 + 1);
    newDate = year + '-' + month + '-' + day;

    for (int i = 0; i < tempTime.length; i++) {
      if (tempTime[i] == ':') {
        hour = int.parse(tempTime.substring(0, i));
        p = i + 1;
      }
      if (tempTime[i] == ' ') {
        minute = tempTime.substring(p, i);
        break;
      }
    }
    var ampm = tempTime[tempTime.length - 2];
    if (ampm == 'P') hour = hour + 12;

    if (hour < 10)
      finalDateTime = newDate + " " + "0$hour:$minute:00";
    else
      finalDateTime = newDate + " " + "$hour:$minute:00";

    DateTime datetime = DateTime.parse(finalDateTime);

    return Event(
      title: json['title'],
      dateTime: datetime,
      venue: json['venue'],
      description: json['description'],
    );
  }
}
