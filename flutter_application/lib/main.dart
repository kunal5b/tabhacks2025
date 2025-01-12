import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';


void main() {
 runApp(MyApp());
}


class MyApp extends StatelessWidget {
 const MyApp({super.key});


 @override
 Widget build(BuildContext context) {
   return MaterialApp(
     title: 'Flutter SQL App',
     theme: ThemeData(primarySwatch: Colors.blue),
     home: HomePage(),
   );
 }
}


class HomePage extends StatelessWidget {
 final DatabaseHelper _dbHelper = DatabaseHelper.instance;


 HomePage({super.key});


 Future<Map<String, dynamic>?> _getDefaultUser() async {
   final users = await _dbHelper.getAllUsers();
   if (users.isNotEmpty) {
     return users.first; // Return the first user in the list
   }
   return null; // No users found
 }


 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: Text('Home Page'),
     ),
     body: Center(
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           Padding(
             padding: const EdgeInsets.only(bottom: 20.0),
             child: Image.asset(
               '/assets/logo_folder/logo-transparent-png.png', // Path to your logo
               width: 200,
               height: 200,
             ),
           ),
           FutureBuilder<Map<String, dynamic>?>(
             future: _getDefaultUser(),
             builder: (context, snapshot) {
               if (snapshot.connectionState == ConnectionState.waiting) {
                 return CircularProgressIndicator(); // Show loading indicator
               } else if (snapshot.hasError) {
                 return Text('Error loading user data.');
               } else if (snapshot.data == null) {
                 return Text('No user found. Please add a user.');
               } else {
                 final user = snapshot.data!;
                 return Column(
                   children: [
                     Text(
                       'Welcome, ${user['username']}!',
                       style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                     ),
                     Text(
                       'Points: ${user['points']}',
                       style: TextStyle(fontSize: 18),
                     ),
                     SizedBox(height: 20),
                   ],
                 );
               }
             },
           ),
           SizedBox(height: 30),
           SizedBox(
             width: 200,
             height: 50,
             child: ElevatedButton(
               onPressed: () {
                 Navigator.push(
                   context,
                   MaterialPageRoute(builder: (context) => LeaderboardPage()),
                 );
               },
               child: Text('Leaderboard', style: TextStyle(fontSize: 18)),
             ),
           ),
           SizedBox(height: 30),
           SizedBox(
             width: 200,
             height: 50,
             child: ElevatedButton(
               onPressed: () {
                 Navigator.push(
                   context,
                   MaterialPageRoute(builder: (context) => CameraPage()),
                 );
               },
               child: Text('Camera', style: TextStyle(fontSize: 18)),
             ),
           ),
           SizedBox(height: 30),
           SizedBox(
             width: 200,
             height: 50,
             child: ElevatedButton(
               onPressed: () {
                 Navigator.push(
                   context,
                   MaterialPageRoute(builder: (context) => TodoPage()),
                 );
               },
               child: Text('To-Do Activity', style: TextStyle(fontSize: 18)),
             ),
           ),
         ],
       ),
     ),
   );
 }
}


class LeaderboardPage extends StatelessWidget {
 final DatabaseHelper _dbHelper = DatabaseHelper.instance;


 LeaderboardPage({super.key});


 Future<void> _initializeSampleUser() async {
   final users = await _dbHelper.getAllUsers();
   if (users.isEmpty) {
     await _dbHelper.insertUser("Sample User"); // Add sample user if none exists
     print('Sample user added successfully!');
   }
 }


 Future<List<Map<String, dynamic>>> _loadUsers() async {
   await _initializeSampleUser(); // Ensure at least one user exists
   return await _dbHelper.getAllUsers();
 }


 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(title: Text('Leaderboard')),
     body: FutureBuilder<List<Map<String, dynamic>>>(
       future: _loadUsers(),
       builder: (context, snapshot) {
         if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
         final users = snapshot.data!;
         return ListView.builder(
           itemCount: users.length,
           itemBuilder: (context, index) {
             final user = users[index];
             return ListTile(
               leading: Text('${index + 1}'),
               title: Text(user['username']),
               subtitle: Text('Points: ${user['points']}'),
             );
           },
         );
       },
     ),
   );
 }
}


class CameraPage extends StatefulWidget {
 const CameraPage({super.key});


 @override
 _CameraPageState createState() => _CameraPageState();
}


class _CameraPageState extends State<CameraPage> {
 late CameraController _controller;
 late Future<void> _initializeControllerFuture;
 bool _isCameraReady = false;


 @override
 void initState() {
   super.initState();
   _initializeCamera();
 }


 // Initialize camera
 Future<void> _initializeCamera() async {
   // Request camera permission for mobile devices
   PermissionStatus status = await Permission.camera.request();
   if (status.isGranted || status.isLimited) {
     // Get available cameras
     final cameras = await availableCameras();
     final firstCamera = cameras.first;


     // Initialize the camera controller
     _controller = CameraController(
       firstCamera,
       ResolutionPreset.high,
     );


     // Initialize the controller
     _initializeControllerFuture = _controller.initialize();


     setState(() {
       _isCameraReady = true;
     });
   } else {
     print('Camera permission denied or not granted');
   }
 }


 // Dispose the controller when leaving the page
 @override
 void dispose() {
   _controller.dispose();
   super.dispose();
 }


 // Capture image
 void _takePicture() async {
   try {
     await _initializeControllerFuture;
     final image = await _controller.takePicture();
     // You can handle the image (e.g., save or display it)
     print('Picture saved to: ${image.path}');
   } catch (e) {
     print('Error taking picture: $e');
   }
 }


 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(title: Text('Camera')),
     body: _isCameraReady
         ? FutureBuilder<void>(
             future: _initializeControllerFuture,
             builder: (context, snapshot) {
               if (snapshot.connectionState == ConnectionState.done) {
                 return Stack(
                   children: [
                     CameraPreview(_controller),
                     Positioned(
                       bottom: 50,
                       left: 150,
                       child: IconButton(
                         icon: Icon(Icons.camera, color: Colors.white, size: 50),
                         onPressed: _takePicture,
                       ),
                     ),
                   ],
                 );
               } else {
                 return Center(child: CircularProgressIndicator());
               }
             },
           )
         : Center(child: Text('Camera not initialized')),
   );
 }
}


class TodoPage extends StatefulWidget {
 const TodoPage({super.key});


 @override
 _TodoPageState createState() => _TodoPageState();
}


class _TodoPageState extends State<TodoPage> {
 final DatabaseHelper _dbHelper = DatabaseHelper.instance;
 final TextEditingController _titleController = TextEditingController();
 final TextEditingController _descriptionController = TextEditingController();
 List<Map<String, dynamic>> _tasks = [];
 final int _userId = 1; // Example user ID


 @override
 void initState() {
   super.initState();
   _initializeUser();
   _loadTasks();
 }


 Future<void> _initializeUser() async {
   final user = await _dbHelper.getUser(_userId);
   if (user == null) {
     await _dbHelper.insertUser("Ansh");
     print('Default user added!');
   }
 }


 void _loadTasks() async {
   final tasks = await _dbHelper.getTasks();
   setState(() {
     _tasks = tasks;
   });
 }


 void _addTask() async {
   final title = _titleController.text;
   final description = _descriptionController.text;
   if (title.isNotEmpty) {
     await _dbHelper.insertTask(title, description);
     _titleController.clear();
     _descriptionController.clear();
     await _incrementUserPoints(10);
     _loadTasks();
   }
 }
 void main() async {
 // Ensure the Flutter framework is initialized
 WidgetsFlutterBinding.ensureInitialized();


 // Create an instance of the DatabaseHelper
 final DatabaseHelper dbHelper = DatabaseHelper.instance;


 // Fetch the number of users in the database
 final users = await dbHelper.getAllUsers();
 print('Number of users in the database: ${users.length}');


 // Run the app
 runApp(MyApp());
}


 Future<void> _incrementUserPoints(int points) async {
   final user = await _dbHelper.getUser(_userId);
   if (user != null) {
     final newPoints = user['points'] + points;
     await _dbHelper.updatePoints(_userId, newPoints);
   }
 }


 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(title: Text('To-Do Activity')),
     body: Column(
       children: [
         Padding(
           padding: const EdgeInsets.all(8.0),
           child: TextField(
             controller: _titleController,
             decoration: InputDecoration(labelText: 'Title'),
           ),
         ),
         Padding(
           padding: const EdgeInsets.all(8.0),
           child: TextField(
             controller: _descriptionController,
             decoration: InputDecoration(labelText: 'Description'),
           ),
         ),
         ElevatedButton(onPressed: _addTask, child: Text('Add Task (Earn +10 Points)')),
         Expanded(
           child: ListView.builder(
             itemCount: _tasks.length,
             itemBuilder: (context, index) {
               final task = _tasks[index];
               return ListTile(
                 title: Text(task['title']),
                 subtitle: Text(task['description'] ?? 'No Description'),
               );
             },
           ),
         ),
       ],
     ),
   );
 }
}



