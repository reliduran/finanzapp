// version 2.0 
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
  String category;  // Propiedad 'category'
  DateTime date;    // Propiedad 'date'

  Expense({
    required this.title, 
    required this.amount,
    required this.category,
    required this.date,
    });

  Map<String, dynamic> toMap() => {
        'title': title,
        'amount': amount,
        'category': category,
         'date': date.toIso8601String(),  // Convierte la fecha a String
      };

  factory Expense.fromMap(Map<String, dynamic> map) {
      return Expense(
        title: map['title'], 
        amount: map['amount'],
        category: map['category'],
        date: DateTime.parse(map['date']),  // Convierte de String a DateTime
        );
  }
}

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
              width: 180, // Ancho deseado, puedes ajustarlo
              height: 180, // Alto deseado, puedes ajustarlo
              fit: BoxFit.contain, // Mantener la proporción del logo
            ),
            SizedBox(height: 20),
            Text(
              'Bienvenido a FinanzApp',
              style: TextStyle(
                fontSize: 20,
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
                  color: const Color.fromARGB(255, 45, 44, 44), // Color suave para discreción
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
                    validator: (v) {
                      if (v == null || v.isEmpty) { 
                        return 'Ingrese un correo';
                      } 

                      // Expresión regular para validar el formato del correo
                      final emailRegex = RegExp(
                        r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
                      );

                      if (!emailRegex.hasMatch(v)) {
                        return 'Correo inválido';
                      }
                      
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _passCtrl,
                    decoration: InputDecoration(labelText: 'Contraseña'),
                    obscureText: true,
                    validator: (v) { 
                      if (v == null || v.isEmpty) {
                        return 'Ingrese una contraseña';
                      }

                      // Expresión regular para validar contraseña
                      // - Al menos una letra (mayúscula o minúscula)
                      // - Al menos un número
                      final passwordRegex = RegExp(r'^(?=.*[a-zA-Z])(?=.*\d).{8,}$');

                      if (!passwordRegex.hasMatch(v)) {
                        return 'La contraseña debe tener al menos 8 caracteres, y contener letras y números';
                      }

                      return null;
                    },
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

//RESUMEN DE GASTOS
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
        backgroundColor: Colors.blueAccent, // Asegurando el mismo tono azul que en la bienvenida
        automaticallyImplyLeading: false, // Desactiva la flecha de retroceso
        actions: [
          // Agregar los botones "Agregar Gasto" y "Evaluar Gasto" en una fila
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.add),
                onPressed: _addExpense, // Función de agregar gasto
                color: Colors.white,
              ),
              IconButton(
                icon: Icon(Icons.account_balance_wallet),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SalaryInputScreen()), // Navegar a la pantalla de ingreso de salario
                  );
                },
                color: Colors.white,
              ),
              // Ícono de cerrar sesión
              IconButton(
                icon: Icon(Icons.exit_to_app),
                onPressed: _logout,
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,  // Alinea a la izquierda
          children: [
            // Mostrar nombre y correo del usuario
            Text(
              'Bienvenido: $_userName ($_userEmail)',
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
            // Listar los gastos dentro de un contenedor con un ancho limitado al 90% de la pantalla
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.90, // 90% del ancho de la pantalla
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
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Monto: \$${e.amount.toStringAsFixed(2)}'),
                            Text('Categoría: ${e.category}'),  // Mostrar la categoría
                            Text('Fecha: ${e.date.toLocal().toString().split(' ')[0]}'),  // Mostrar la fecha
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => _editExpense(i)),
                            SizedBox(width: 10), // Espacio entre los iconos
                            IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _deleteExpense(i)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// FIN RESUMEN DE GASTOS


// === AGREGAR / EDITAR GNavigator.push(ASTO ===
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
  final _categoryCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _category = "No aplica"; // Default category
  DateTime _selectedDate = DateTime.now(); // Default date is today

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _titleCtrl.text = widget.initial!.title;
      _amountCtrl.text = widget.initial!.amount.toString();
      _category = widget.initial!.category; // Aquí cargamos la categoría del registro
      _selectedDate = widget.initial!.date; // Aquí cargamos la fecha del registro
      _dateCtrl.text = "${_selectedDate.toLocal()}".split(' ')[0]; // Actualiza el campo de fecha con el valor del registro
    }
  }

  // Función para seleccionar la fecha
  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ) ?? _selectedDate;
    
    if (picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
        _dateCtrl.text = "${_selectedDate.toLocal()}".split(' ')[0]; // Formato: yyyy-MM-dd
      });
  }

  // Función para guardar
  void _save() {
    if (_formKey.currentState!.validate()) {
      final expense = Expense(
        title: _titleCtrl.text,
        amount: double.parse(_amountCtrl.text),
        category: _category,  // Se pasa la categoría seleccionada
        date: _selectedDate,  // Se pasa la fecha seleccionada
      );
      widget.onSave(expense);  // Llamada al callback con el objeto 'expense'
      Navigator.pop(context);  // Volver a la pantalla anterior
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Agregar / Editar Gasto'),
          backgroundColor: Colors.blueAccent,
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Descripción
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

                  // Monto
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
                  SizedBox(height: 20),

                  // Categoría (Dropdown)
                  DropdownButtonFormField<String>(
                    value: _category,
                    onChanged: (newValue) {
                      setState(() {
                        _category = newValue!;  // Se actualiza la categoría
                      });
                    },
                    validator: (v) => v == null || v.isEmpty ? 'Seleccione categoría' : null,
                    decoration: InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    ),
                    items: [
                      DropdownMenuItem(value: "Empresarial", child: Text("Empresarial")),
                      DropdownMenuItem(value: "Personal", child: Text("Personal")),
                      DropdownMenuItem(value: "No aplica", child: Text("No aplica")),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Fecha
                  TextFormField(
                    controller: _dateCtrl,
                    decoration: InputDecoration(
                      labelText: 'Fecha',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    ),
                    readOnly: true, // Hacerlo solo lectura
                    onTap: () => _selectDate(context),
                    validator: (v) => v == null || v.isEmpty ? 'Seleccione una fecha' : null,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 30),

                  // Botón Guardar
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
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

// INGRESO DE SUELDO
class SalaryInputScreen extends StatefulWidget {
  @override
  _SalaryInputScreenState createState() => _SalaryInputScreenState();
}

class _SalaryInputScreenState extends State<SalaryInputScreen> {
  final _salaryCtrl = TextEditingController();
  double _salary = 0.0;
  double _totalExpenses = 0.0;

  @override
  void initState() {
    super.initState();
    _loadTotalExpenses();
  }

  Future<void> _loadTotalExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('session') ?? '';
    final data = prefs.getStringList('expenses_${userEmail}') ?? [];

    setState(() {
      _totalExpenses = data
          .map((e) => Expense.fromMap(json.decode(e)))
          .fold(0, (sum, e) => sum + e.amount); // Calcular el total de los gastos
    });
  }

  void _calculateExcess() {
    double excess = _salary - _totalExpenses;

    // Mostrar el resultado
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Resultado"),
          content: Text(
            excess < 0
                ? "¡Excediste tu presupuesto en \$${(-excess).toStringAsFixed(2)}!"
                : "Te sobra \$${excess.toStringAsFixed(2)} del presupuesto mensual.",
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cerrar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _saveSalary() async {
    // Validar si el sueldo ingresado es válido
    if (_salaryCtrl.text.isEmpty || double.tryParse(_salaryCtrl.text) == null) {
      // Mostrar un mensaje de error si el valor es inválido o vacío
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Por favor, ingresa tu sueldo."),
            actions: <Widget>[
              TextButton(
                child: Text("Cerrar"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return; // Detener la ejecución si el sueldo es inválido
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('salary', double.parse(_salaryCtrl.text));
    _calculateExcess();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ingresar tu Sueldo'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _salaryCtrl,
              decoration: InputDecoration(
                labelText: 'Sueldo Mensual',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _salary = double.tryParse(value) ?? 0.0;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveSalary,
              child: Text("Evaluar tu Presupuesto"),
            ),
          ],
        ),
      ),
    );
  }
}
//GRACIAS A DIOS CODIGO FINALIZADO 10.05.2025 03:19 AM
//BENDICIONES A MI HIJO ANTONIO ELI DURAN LAZARO