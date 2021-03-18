import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transaction.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  final Function _startAddNewTransaction;
  final Function deleteTx;
  final double height;
  final double width;

  TransactionList(this.transactions, this._startAddNewTransaction,
      this.deleteTx, this.height, this.width);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.all(10),
        height: height * 0.645,
        child: transactions.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                    'No transactions added yet!',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  CircleAvatar(
                    backgroundColor: Theme.of(context).accentColor,
                    radius: 30,
                    child: IconButton(
                      iconSize: 40,
                      icon: Icon(Icons.add),
                      color: Colors.white,
                      onPressed: () => _startAddNewTransaction(context),
                    ),
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
                      )),
                ],
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Center(
                      child: Text(
                        "Marzo",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemBuilder: (ctx, index) {
                        return Card(
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
                                    '\$${transactions[index].amount}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              transactions[index].title,
                              style: Theme.of(context).textTheme.title,
                            ),
                            subtitle: Text(
                              DateFormat.yMMMd()
                                  .format(transactions[index].date),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              color: Theme.of(context).errorColor,
                              onPressed: () => deleteTx(transactions[index].id),
                            ),
                          ),
                        );
                      },
                      itemCount: transactions.length,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
