import 'package:flutter/material.dart';
import 'package:flutter_lista_compras/banco_de_dados/banco.dart';
import 'package:flutter_lista_compras/telas/MenuApp.dart';
import 'package:flutter_lista_compras/telas/editarProduto.dart';

class ExibirProduto extends StatefulWidget {
  static const routeName = 'ExibirProduto';

  @override
  _ExibirProdutoState createState() => _ExibirProdutoState();
}

class _ExibirProdutoState extends State<ExibirProduto> {
  @override
  Widget build(BuildContext context) {
    final argumentos =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(argumentos['titulo']),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              children: [
                Text(
                  'Quantidade: ' + argumentos['quantidade'].toString(),
                  style: TextStyle(fontSize: 26),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 60,
                ),
                Text(
                  'Descrição do produto: ' + argumentos['descricao'],
                  style: TextStyle(fontSize: 26),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 360,
                ),
                ElevatedButton(
                    onPressed: () => _deletar(context, argumentos),
                    child: Text(
                      'Deletar produto',
                      style: TextStyle(fontSize: 26),
                    )),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _editarProduto(argumentos),
        child: Icon(Icons.edit),
      ),
    );
  }

  _deletar(context, Map<String, dynamic> produto) async {
    await SQLDatabase.delete('conta', produto['id']);

    Navigator.of(context)
        .pushReplacementNamed(MenuApp.routeName, arguments: produto['user_id']);
  }

  _editarProduto(Map<String, dynamic> produto) {
    Navigator.of(context)
        .pushNamed(EditarProduto.routeName, arguments: produto);
  }
}
