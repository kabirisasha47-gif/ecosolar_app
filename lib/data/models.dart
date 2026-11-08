class Consent {
  final String partner, scope, validity;
  bool signed;
  DateTime? at;
  Consent(this.partner, this.scope, this.validity, {this.signed = false, this.at});
}

class Rec {
  final String id, title, desc, why;
  final double kwhSaving;
  String state; // new / accepted / rejected / custom
  Rec(this.id, this.title, this.desc, this.why, this.kwhSaving, {this.state = 'new'});
}

class Channel {
  final String id, name, lead, risk;
  final double value; // toman / year
  final bool eligible, recommended;
  final String? reason;
  const Channel(this.id, this.name, this.value, this.lead, this.risk, {this.eligible = true, this.recommended = false, this.reason});
}

class Invoice {
  final String id, period;
  final double kwh, gross, deductions;
  String status; // ISSUED, ADVANCED, SETTLED, OVERDUE
  final int agingDays;
  Invoice(this.id, this.period, this.kwh, this.gross, this.deductions, this.status, {this.agingDays = 0});
  double get net => gross - deductions;
}

class Tx {
  final String title;
  final double amount;
  final DateTime at;
  const Tx(this.title, this.amount, this.at);
}

class WorkOrder {
  final String id, type, installer, date;
  final double cost;
  String status; // scheduled, awaiting, done
  WorkOrder(this.id, this.type, this.installer, this.date, this.cost, this.status);
}

class Notif {
  final String title, body, cat, route;
  final DateTime at;
  bool read;
  Notif(this.title, this.body, this.cat, this.route, this.at, {this.read = false});
}

class Msg {
  final String text;
  final bool mine;
  final DateTime at;
  const Msg(this.text, this.mine, this.at);
}

class Ticket {
  final String id, topic;
  String status;
  final List<Msg> msgs;
  Ticket(this.id, this.topic, this.status, this.msgs);
}

class CoOwner {
  final int unit;
  final String name, mobile;
  bool signed;
  CoOwner(this.unit, this.name, this.mobile, this.signed);
}

class Member {
  final String name, mobile;
  String role;
  final List<String> sites;
  Member(this.name, this.mobile, this.role, this.sites);
}

class Product {
  final String name, cat;
  final double price;
  final bool domestic;
  const Product(this.name, this.cat, this.price, this.domestic);
}

class Bid {
  final String company;
  final double rating, amount;
  final int days, warrantyMonths;
  const Bid(this.company, this.rating, this.amount, this.days, this.warrantyMonths);
}
