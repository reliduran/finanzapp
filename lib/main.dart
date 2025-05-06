import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(FinanzApp());
}

class FinanzApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinanzApp',
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
    );
  }
}

// === MODELOS ===
class User {
  String email;
  String password;
  String name;
  int age;

  User(this.email, this.password, this.name, this.age);

  Map<String, dynamic> toMap() => {
        'email': email,
        'password': password,
        'name': name,
        'age': age,
      };

  factory User.fromMap(Map<String, dynamic> map) =>
      User(map['email'], map['password'], map['name'], map['age']);
}

class Expense {
  String title;
  double amount;

  Expense({required this.title, required this.amount});

  Map<String, dynamic> toMap() => {
        'title': title,
        'amount': amount,
      };

  factory Expense.fromMap(Map<String, dynamic> map) =>
      Expense(title: map['title'], amount: map['amount']);
}

// === BIENVENIDA ===

// === BIENVENIDA ===
class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo centrado en la pantalla con un tamaño proporcional
            Image.asset(
              'assets/logo.png',  // Ruta correcta del logo
              width: 250, // Ancho deseado, puedes ajustarlo
              height: 250, // Alto deseado, puedes ajustarlo
              fit: BoxFit.contain, // Mantener la proporción del logo
            ),
            SizedBox(height: 40),
            Text(
              'Bienvenidos a FinanzApp',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 43, 81, 148),
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              ),
              child: Text('Iniciar Sesión'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RegisterScreen()),
              ),
              child: Text('Registrarse'),
            ),
            SizedBox(height: 40), // Espacio entre los botones y el mensaje
            // Mensaje en la parte inferior de la pantalla
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0), // Espacio inferior
              child: Text(
                "Desarrollado para DAM TSU 2025 por Grupo 13",
                style: TextStyle(
                  fontSize: 12, // Tamaño de fuente discreto
                  color: Colors.grey, // Color suave para discreción
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// === REGISTRO ===
class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _register() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('users') ?? [];

    final users =
        data.map((u) => User.fromMap(json.decode(u))).toList(growable: true);

    final exists =
        users.any((u) => u.email.toLowerCase() == _emailCtrl.text.toLowerCase());

    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El correo ya está registrado')),
      );
      return;
    }

    final newUser = User(
      _emailCtrl.text,
      _passCtrl.text,
      _nameCtrl.text,
      int.tryParse(_ageCtrl.text) ?? 0,
    );
    users.add(newUser);

    prefs.setStringList(
        'users', users.map((u) => json.encode(u.toMap())).toList());

    // Mostrar Snackbar de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Usuario creado con éxito')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Registro')),
        body: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
                key: _formKey,
                child: Column(children: [
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(labelText: 'Nombre'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Ingrese su nombre' : null,
                  ),
                  TextFormField(
                    controller: _ageCtrl,
                    decoration: InputDecoration(labelText: 'Edad'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Ingrese su edad';
                      final age = int.tryParse(v);
                      return (age == null || age < 1 || age > 99)
                          ? 'Edad inválida (1-99)'
                          : null;
                    },
                  ),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: InputDecoration(labelText: 'Correo'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Ingrese un correo' : null,
                  ),
                  TextFormField(
                    controller: _passCtrl,
                    decoration: InputDecoration(labelText: 'Contraseña'),
                    obscureText: true,
                    validator: (v) => v == null || v.isEmpty
                        ? 'Ingrese una contraseña'
                        : null,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) _register();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: Text('Registrarse')),
                ]))));
  }
}

// === LOGIN ===
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _login() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('users') ?? [];

    final users = data.map((u) => User.fromMap(json.decode(u))).toList();
    final user = users.firstWhere(
        (u) =>
            u.email.toLowerCase() == _emailCtrl.text.toLowerCase() &&
            u.password == _passCtrl.text,
        orElse: () => User('', '', '', 0));

    if (user.email.isNotEmpty) {
      await prefs.setString('session', user.email);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ExpenseSummaryScreen()),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Credenciales inválidas')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Iniciar Sesión')),
        body: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
                key: _formKey,
                child: Column(children: [
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: InputDecoration(labelText: 'Correo'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Ingrese su correo' : null,
                  ),
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: true,
                    decoration: InputDecoration(labelText: 'Contraseña'),
                    validator: (v) => v == null || v.isEmpty
                        ? 'Ingrese su contraseña'
                        : null,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) _login();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: Text('Entrar')),
                ]))));
  }
}

// === RESUMEN DE GASTOS ===
// === RESUMEN DE GASTOS ===
class ExpenseSummaryScreen extends StatefulWidget {
  @override
  _ExpenseSummaryScreenState createState() => _ExpenseSummaryScreenState();
}

class _ExpenseSummaryScreenState extends State<ExpenseSummaryScreen> {
  List<Expense> _expenses = [];
  String _userEmail = '';
  String _userName = '';
  double _totalAmount = 0;
  int _totalItems = 0;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    _userEmail = prefs.getString('session') ?? '';
    
    // Cargar los usuarios para obtener el nombre
    final userData = prefs.getStringList('users') ?? [];
    final users = userData
        .map((e) => User.fromMap(json.decode(e)))
        .toList();
    final currentUser = users.firstWhere(
        (u) => u.email == _userEmail,
        orElse: () => User('', '', '', 0));

    setState(() {
      _userName = currentUser.name;
    });

    // Cargar los gastos de este usuario
    final data = prefs.getStringList('expenses_${_userEmail}') ?? [];
    setState(() {
      _expenses = data.map((e) => Expense.fromMap(json.decode(e))).toList();
      _totalItems = _expenses.length;
      _totalAmount = _expenses.fold(0, (sum, e) => sum + e.amount);
    });
  }

  Future<void> _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _expenses.map((e) => json.encode(e.toMap())).toList();
    await prefs.setStringList('expenses_${_userEmail}', data);
  }

  void _editExpense(int index) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => AddExpenseScreen(
                  initial: _expenses[index],
                  onSave: (updated) {
                    setState(() {
                      _expenses[index] = updated;
                    });
                    _saveExpenses();
                  },
                ))).then((_) => _loadExpenses()); // Recargar después de editar
  }

  void _deleteExpense(int index) {
    setState(() {
      _expenses.removeAt(index);
    });
    _saveExpenses();
  }

  void _addExpense() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => AddExpenseScreen(
                  onSave: (newExpense) {
                    setState(() {
                      _expenses.add(newExpense);
                    });
                    _saveExpenses();
                  },
                ))).then((_) => _loadExpenses()); // Recargar después de agregar
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => WelcomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resumen de Gastos'),
        backgroundColor: Colors.blueAccent,  // Asegurando el mismo tono azul que en la bienvenida
        automaticallyImplyLeading: false, // Desactiva la flecha de retroceso
        actions: [
          // Ícono de cerrar sesión
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _logout,
            color: Colors.white,
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mostrar nombre y correo del usuario
            Text(
              'Usuario: $_userName ($_userEmail)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            SizedBox(height: 20),
            // Mostrar total de artículos y la suma total de montos
            Text(
              'Total de Artículos: $_totalItems',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Total Gastado: \$${_totalAmount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            // Listar los gastos
            Expanded(
              child: ListView.builder(
                itemCount: _expenses.length,
                itemBuilder: (_, i) {
                  final e = _expenses[i];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: Text(e.title, style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Monto: \$${e.amount.toStringAsFixed(2)}'),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _editExpense(i)),
                        IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteExpense(i)),
                      ]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExpense,
        child: Icon(Icons.add),
        backgroundColor: Colors.green, // Color coherente con el registro
      ),
    );
  }
}


// === AGREGAR / EDITAR GASTO ===
// === AGREGAR / EDITAR GASTO ===
class AddExpenseScreen extends StatefulWidget {
  final Expense? initial;
  final Function(Expense) onSave;

  AddExpenseScreen({this.initial, required this.onSave});

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _titleCtrl.text = widget.initial!.title;
      _amountCtrl.text = widget.initial!.amount.toString();
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final expense = Expense(
        title: _titleCtrl.text,
        amount: double.parse(_amountCtrl.text),
      );
      widget.onSave(expense);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Agregar / Editar Gasto'),
          backgroundColor: Colors.blueAccent, // Color coherente con la pantalla de bienvenida
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, // Alinear los elementos
                children: [
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Ingrese descripción' : null,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _amountCtrl,
                    decoration: InputDecoration(
                      labelText: 'Monto',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Ingrese el monto';
                      final parsed = double.tryParse(v);
                      return (parsed == null || parsed <= 0)
                          ? 'Monto inválido'
                          : null;
                    },
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Consistente con otros botones
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    child: Text('Guardar', style: TextStyle(fontSize: 18)),
                  ),
                ],
              )),
        ));
  }
}
