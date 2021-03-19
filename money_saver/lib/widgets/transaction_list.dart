import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transaction.dart';

class TransactionList extends StatefulWidget {
  final List<Transaction> transactions;
  final Function _startAddNewTransaction;
  final Function deleteTx;
  final double height;
  final double width;

  TransactionList(this.transactions, this._startAddNewTransaction,
      this.deleteTx, this.height, this.width);

  @override
  _TransactionListState createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.all(10),
        height: widget.height * 0.6,
        child: widget.transactions.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                    'No transactions added yet!',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(200),
                    ),
                    height: 300,
                    child: Image.asset(
                      'assets/images/note.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Text(
                    'Start tracking your expenses',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    radius: 30,
                    child: IconButton(
                      iconSize: 40,
                      icon: Icon(Icons.add),
                      color: Colors.white,
                      onPressed: () => widget._startAddNewTransaction(context),
                    ),
                  ),
                ],
              )
            : Container(
                child: ListView.builder(
                  itemBuilder: (ctx, index) {
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 5,
                      margin: EdgeInsets.symmetric(
                        vertical: 11,
                        horizontal: 5,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          radius: 30,
                          child: Padding(
                            padding: EdgeInsets.all(6),
                            child: FittedBox(
                              child: Text(
                                '\€${widget.transactions[index].amount}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          widget.transactions[index].title,
                          style: Theme.of(context).textTheme.headline5,
                        ),
                        subtitle: Text(
                          DateFormat.yMMMd()
                              .format(widget.transactions[index].date),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          color: Theme.of(context).errorColor,
                          onPressed: () =>
                              widget.deleteTx(widget.transactions[index].id),
                        ),
                      ),
                    );
                  },
                  itemCount: widget.transactions.length,
                ),
              ),
      ),
    );
  }
}
