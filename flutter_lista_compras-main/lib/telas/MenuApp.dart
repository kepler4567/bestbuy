import 'package:flutter/material.dart';
import 'package:flutter_lista_compras/banco_de_dados/banco.dart';
import 'package:flutter_lista_compras/telas/NovoProduto.dart';
import 'package:flutter_lista_compras/telas/exibirProduto.dart';

import 'package:shared_preferences/shared_preferences.dart';

class MenuApp extends StatefulWidget {
  static const routeName = 'MenuApp';

  @override
  _MenuAppState createState() => _MenuAppState();
}

class _MenuAppState extends State<MenuApp> {
  @override
  Widget build(BuildContext context) {
    final userID = ModalRoute.of(context)!.settings.arguments as int;

    return Scaffold(
      drawer: Drawer(
        child: buildListView(),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: Text('BESTBUY'),
      ),
      body: FutureBuilder(
          future: _retornarItensUserBD(userID),
          builder:
              (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
            print('userid =  ' + userID.toString());
            print('dados ' + snapshot.data.toString());
            if (snapshot.connectionState == ConnectionState.waiting)
              return Center(
                child: CircularProgressIndicator(),
              );
            else {
              return ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: snapshot.data?.length ?? 0,
                itemBuilder: (context, index) =>
                    ListarContasUsuario(snapshot.data![index]),
              );
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed(NovoProduto.routeName),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.shopping_cart),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _retornarItensUserBD(int id) async {
    return await SQLDatabase.readById('conta', id);
  }

  Future<Map<String, dynamic>> retornarUserBD() async {
    var userData;

    final prefs = await SharedPreferences.getInstance();
    final rows = await SQLDatabase.read('users');

    int id = prefs.getInt('user_id') ?? 0;
    for (int i = 0; i < rows.length; i++)
      if (rows[i]['id'] == id) userData = rows[i];
    print('Data: ' + userData.toString());
    return userData;
  }

  /// Lendo os valores do banco de dados
  Widget buildListView() {
    return FutureBuilder(
        future: retornarUserBD(),
        builder: (context, AsyncSnapshot<Map> userData) =>
            userData.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      UserAccountsDrawerHeader(
                        accountName: Text(userData.data!['nome']),
                        accountEmail: Text(userData.data!['email']),
                        currentAccountPicture: CircleAvatar(
                          child: Text(getInitials(userData.data!['nome'])),
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.logout),
                        title: Text('Sair'),
                        onTap: () => _deslogar(),
                      ),
                    ],
                  ));
  }

  /// Deslogar um usuário
  _deslogar() async {
    await SQLDatabase.insert('ultimo_login', {'esta_logado': 'true'});
    Navigator.pushReplacementNamed(context, 'Menu');
  }

  /// Pegar as iniciais de um nome
  /// Fonte: https://stackoverflow.com/questions/61289182/how-to-get-first-character-from-words-in-flutter-dart
  String getInitials(String name) => name.isNotEmpty
      ? name.trim().split(' ').map((l) => l[0].toUpperCase()).take(2).join()
      : '';
}

class ListarContasUsuario extends StatefulWidget {
  final Map<String, dynamic> produtos;

  ListarContasUsuario(this.produtos);

  @override
  _ListarContasUsuarioState createState() =>
      _ListarContasUsuarioState(this.produtos);
}

class _ListarContasUsuarioState extends State<ListarContasUsuario> {
  final Map<String, dynamic> produtos;
  late bool Validator = false;
  _ListarContasUsuarioState(this.produtos);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context)
          .pushNamed(ExibirProduto.routeName, arguments: produtos),
      child: ListTile(
        leading: CircleAvatar(
          child: FittedBox(child: Text(produtos['quantidade'].toString())),
        ),
        title: titles,
        trailing: Container(
            width: 100,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.block_rounded),
                  onPressed: () => ModificaTitle(Validator = true),
                  color: Colors.red,
                ),
                IconButton(
                  icon: Icon(Icons.block_rounded),
                  onPressed: () => ModificaTitle(Validator = false),
                  color: Colors.green,
                ),
              ],
            )),
      ),
    );
  }

  late Text titles = ModificaTitle(Validator);

  Text ModificaTitle(Validator) {
    if (Validator) {
      setState(() {
        titles = Text(
          produtos['titulo'],
          style: TextStyle(color: Color.fromRGBO(1, 1, 1, 0.4)),
        );
        print(titles);
      });
    } else {
      setState(() {
        titles = Text(
          produtos['titulo'],
        );
        print(titles);
      });
    }
    return titles;
  }
}
