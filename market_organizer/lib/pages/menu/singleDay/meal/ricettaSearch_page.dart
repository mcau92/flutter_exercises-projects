import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/models/product_model.dart';
import 'package:market_organizer/models/receiptOperationType.dart';
import 'package:market_organizer/models/ricetta.dart';
import 'package:market_organizer/models/userdata_model.dart';
import 'package:market_organizer/pages/menu/singleDay/meal/meal_detail_model.dart';
import 'package:market_organizer/pages/menu/singleDay/meal/ricettaSearch_widget.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/receipt_page.dart';
import 'package:market_organizer/provider/auth_provider.dart';
import 'package:market_organizer/service/navigation_service.dart';
import 'package:provider/provider.dart';

class RicettaSearchPage extends StatefulWidget {
  const RicettaSearchPage({Key? key}) : super(key: key);

  @override
  _RicettaSearchPageState createState() => _RicettaSearchPageState();
}

class _RicettaSearchPageState extends State<RicettaSearchPage> {
  late RicettaManagementInput mealInput;
  late TextEditingController _textController;
  late List<Ricetta> _ricette = []; //lista di ricette trovate

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  void _updateResearch(String string) async {
    UserDataModel _currentUserData =
        Provider.of<AuthProvider>(context, listen: false).userData!;
    if (string != null && string != "") {
      List<Ricetta> _result = await DatabaseService.instance
          .searchRicetteByName(string, _currentUserData.id!);
      setState(() {
        _ricette = _result;
      });
    } else {
      setState(() {
        _ricette = [];
      });
    }
  }

/** metodo che ci porta ad una nuova pagina dove andiamo a gestire l'inserimento, modifica e conferma della ricetta per poi essere salvata */
  void _insertNewRecipt() {
    //pagina di inserimento ricetta generale
    NewSelectedReceiptInput receiptInput = new NewSelectedReceiptInput(
      ReceiptOperationType.INSERT,
      null,
      null,
      mealInput,
      mealInput.pasto!,
    );
    setState(() {
      _textController.text = "";
      _ricette = [];
    });
    NavigationService.instance
        .navigateToWithParameters("receiptPage", receiptInput);
  }

  @override
  Widget build(BuildContext context) {
    mealInput =
        ModalRoute.of(context)!.settings.arguments as RicettaManagementInput;
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
            onPressed: () => NavigationService.instance.goBack()),
        title: Text(
          "Ricetta",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(CupertinoIcons.add, color: Colors.white),
            onPressed: () => _insertNewRecipt(),
          ),
        ],
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

//metodo che ci porta nella pagina di inserimento che è la stessa che si visualizza quando si crea la ricetta da zero solo che in questo caso ci saranno i prodotti della ricetta caricati
  void _showRicettaDetailForInsert(Ricetta _ricetta) async {
    //ricetta può essere nulla se sono in fase di creazione da zero altrimenti è valorizzata con quella selezionata
    Map<Product, bool> prods = await DatabaseService.instance
        .getProductsByReceiptWithDefaultFalseInSpesa(
            _ricetta.menuIdRef!, _ricetta.id!);
    NewSelectedReceiptInput receiptInput = new NewSelectedReceiptInput(
      ReceiptOperationType.SEARCH,
      _ricetta,
      prods,
      mealInput,
      mealInput.pasto!,
    );
    Navigator.pushNamed(context, "receiptPage",
            arguments:
                receiptInput) //cosi facendo quando nelle pagine successivo faccio pop e arrivo a questa fa il refresh
        .then((value) => setState(() {}));
  }

  Widget _ricetteList() {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: _ricette!.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
                child: RicettaSearchWidget(_ricette![index]),
                onTap: () => _showRicettaDetailForInsert(_ricette![index])),
          );
        });
  }
}
