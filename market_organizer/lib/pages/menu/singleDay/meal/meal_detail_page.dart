import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/models/ricetta.dart';
import 'package:market_organizer/models/userdata_model.dart';
import 'package:market_organizer/pages/menu/singleDay/meal/meal_detail_model.dart';
import 'package:market_organizer/pages/menu/singleDay/meal/single_ricetta_search.dart';

class MealDetailPage extends StatefulWidget {
  const MealDetailPage({Key key}) : super(key: key);

  @override
  _MealDetailPageState createState() => _MealDetailPageState();
}

class _MealDetailPageState extends State<MealDetailPage> {
  MealDetailModel mealInput;
  TextEditingController _textController;
  List<Ricetta> _ricette; //lista di ricette trovate

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  void _updateResearch(String string) async {
    if (string != null && string != "") {
      List<Ricetta> _result =
          await DatabaseService.instance.searchRicetteByName(string);
      setState(()  {
        _ricette=_result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    mealInput = ModalRoute.of(context).settings.arguments as MealDetailModel;
    return Scaffold(
      backgroundColor: Color.fromRGBO(43, 43, 43, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(43, 43, 43, 1),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          mealInput.pasto,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    return Column(children: [_searchBar(), _resultRecipts()]);
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CupertinoSearchTextField(
        controller: _textController,
        itemColor: Colors.white38,
        placeholder: "Ricerca una ricetta..",
        style: TextStyle(color: Colors.white),
        onChanged: (string) => _updateResearch(string),
      ),
    );
  }

  Widget _resultRecipts() {
    return _ricette != null ? Expanded(child: _ricetteList()) : Container();
  }

  void _insertRicettaAndPop(Ricetta _ricetta) {
    //aggiorno i dati nella ricetta per poterla duplicare
    _ricetta = _cleanRicettaData(_ricetta);
    DatabaseService.instance
        .insertSearchedRicettaOnMenu(_ricetta, mealInput, null);
    Navigator.pop(context);
  }

  Widget _ricetteList() {
    return ListView.separated(
        shrinkWrap: true,
        separatorBuilder: (context, index) {
          return Divider(
            height: 20,
            thickness: 0,
          );
        },
        itemCount: _ricette.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
                child: SingleRicettaSearch(_ricette[index]),
                onTap: () => _insertRicettaAndPop(_ricette[index])),
          );
        });
  }

  Ricetta _cleanRicettaData(Ricetta ricetta) {
    UserDataModel user = UserDataModel.example;
    ricetta.id = null;
    ricetta.ownerId = user.id;
    ricetta.ownerName = user.name;
  }
}
