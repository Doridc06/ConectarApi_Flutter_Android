import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'character.dart';

// Función principal que inicia la aplicación
void main() {
  runApp(const MyApp());
}

// Clase principal de la aplicación
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rick and Morty Characters', // Título de la aplicación
      theme: ThemeData(
        primarySwatch: Colors.blue, // Tema de la aplicación
      ),
      home: const CharacterListScreen(), // Pantalla principal de la aplicación
    );
  }
}

// Pantalla que muestra la lista de personajes
class CharacterListScreen extends StatefulWidget {
  const CharacterListScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CharacterListScreenState createState() => _CharacterListScreenState();
}

// Estado de la pantalla que maneja la carga y visualización de los personajes
class _CharacterListScreenState extends State<CharacterListScreen> {
  // Método asíncrono para obtener la lista de personajes desde la API
  Future<List<Character>> _fetchCharacters() async {
    // Realiza la solicitud HTTP para obtener los datos de la API
    final response =
        await http.get(Uri.parse('https://rickandmortyapi.com/api/character'));

    if (response.statusCode == 200) {
      // Decodifica la respuesta JSON
      final data = jsonDecode(response.body);
      List<dynamic> results = data['results'];
      // Convierte los datos JSON a una lista de objetos Character
      return results
          .map((characterJson) => Character.fromJson(characterJson))
          .toList();
    } else {
      // Lanza una excepción si la solicitud falla
      throw Exception('Failed to load characters');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Rick and Morty Characters'), // Título de la barra de aplicación
      ),
      body: FutureBuilder<List<Character>>(
        // Utiliza FutureBuilder para gestionar el estado de la solicitud
        future: _fetchCharacters(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Muestra un indicador de carga mientras se espera la respuesta
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Muestra un mensaje de error si la solicitud falla
            return const Center(child: Text('Failed to load characters'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Muestra un mensaje si no se encuentran personajes
            return const Center(child: Text('No characters found'));
          } else {
            // Muestra la lista de personajes si la solicitud es exitosa
            return ListView.builder(
              itemCount:
                  snapshot.data!.length, // Número de elementos en la lista
              itemBuilder: (context, index) {
                // Obtiene el personaje en la posición actual
                Character character = snapshot.data![index];
                return ListTile(
                  leading:
                      Image.network(character.image), // Imagen del personaje
                  title: Text(character.name), // Nombre del personaje
                  subtitle: Text(
                      '${character.species} - ${character.status}'), // Especie y estado del personaje
                );
              },
            );
          }
        },
      ),
    );
  }
}
