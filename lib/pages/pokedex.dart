import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pokedex/widgets/theme_switch.dart';

class PokedexPage extends StatefulWidget {
  const PokedexPage({super.key});

  @override
  State<PokedexPage> createState() => _PokedexPageState();
}

class _PokedexPageState extends State<PokedexPage> {
  List<dynamic> pokemonList = [];
  List<dynamic> filteredPokemonList = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPokemon();
  }

  Future<void> fetchPokemon() async {
    try {
      final response = await http.get(
        Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=150'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          pokemonList = data['results'];
          filteredPokemonList = pokemonList;
          isLoading = false;
        });
      } else {
        throw Exception('Erro ao carregar Pokémon');
      }
    } catch (e) {
      print('Erro na requisição: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterPokemon(String query) {
    setState(() {
      filteredPokemonList = pokemonList
          .where((pokemon) =>
              pokemon['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Image.asset(
            'assets/pokeball.gif',
            height: 40,
            width: 40,
          ),
          const SizedBox(width: 8),
          Text(
            'Pokedex',
            style: GoogleFonts.limelight(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ]),
        actions: const [
          ThemeSwitch(),
          SizedBox(width: 8),
        ],
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Buscar Pokémon...',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
              onChanged: filterPokemon,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : filteredPokemonList.isEmpty
                ? Center(
                    child: Text(
                      'Nenhum Pokémon encontrado',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(8.0),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.5,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: filteredPokemonList.length,
                          itemBuilder: (context, index) {
                            return FutureBuilder<http.Response>(
                              future: http.get(
                                Uri.parse(filteredPokemonList[index]['url']),
                              ),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (snapshot.hasError) {
                                  return Center(
                                    child: Text(
                                      'Erro',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color,
                                      ),
                                    ),
                                  );
                                }
                                final data = jsonDecode(snapshot.data!.body);
                                final String gifUrl = data['sprites']
                                                ['versions']['generation-v']
                                            ['black-white']['animated']
                                        ['front_default'] ??
                                    data['sprites']['front_default'];
                                final String type =
                                    data['types'][0]['type']['name'];
                                final Map<String, Color> typeColors = {
                                  'fire': Colors.red,
                                  'water': Colors.blue,
                                  'grass': Colors.green,
                                  'electric': Colors.yellow,
                                  'bug': Colors.lightGreen,
                                  'normal': Colors.grey,
                                  'poison': Colors.purple,
                                  'ground': Colors.brown,
                                  'fairy': Colors.pink,
                                  'fighting': Colors.orange,
                                  'psychic': Colors.pinkAccent,
                                  'rock': Colors.brown,
                                  'ghost': Colors.deepPurple,
                                  'ice': Colors.lightBlue,
                                  'dragon': Colors.indigo,
                                  'dark': Colors.black,
                                  'steel': Colors.blueGrey,
                                  'flying': Colors.indigoAccent,
                                };
                                final Color color =
                                    typeColors[type] ?? Colors.grey;
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PokemonDetailScreen(
                                          url: filteredPokemonList[index]
                                              ['url'],
                                          typeColor: color,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Card(
                                    color: color.withOpacity(0.8),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.network(gifUrl, height: 70),
                                        const SizedBox(height: 8),
                                        Text(
                                          filteredPokemonList[index]['name']
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class PokemonDetailScreen extends StatelessWidget {
  final String url;
  final Color typeColor;
  const PokemonDetailScreen(
      {super.key, required this.url, required this.typeColor});

  Future<Map<String, dynamic>> fetchPokemonDetails() async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Erro ao carregar dados');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: typeColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: typeColor,
        child: FutureBuilder(
          future: fetchPokemonDetails(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Erro ao carregar detalhes',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              );
            }
            final pokemonData = snapshot.data!;
            final String gifUrl = pokemonData['sprites']['versions']
                        ['generation-v']['black-white']['animated']
                    ['front_default'] ??
                pokemonData['sprites']['front_default'];

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 150,
                      width: 150,
                      child: Image.network(gifUrl, fit: BoxFit.contain),
                    ),
                    Text(
                      pokemonData['name'].toUpperCase(),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    Text(
                      'Altura: ${(pokemonData['height'] / 10).toStringAsFixed(1)} m',
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    Text(
                      'Peso: ${(pokemonData['weight'] / 10).toStringAsFixed(1)} kg',
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    const Text('Tipos:',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    Wrap(
                      spacing: 10,
                      children: (pokemonData['types'] as List)
                          .map((type) => Chip(
                                label: Text(type['type']['name'].toUpperCase()),
                                backgroundColor: Colors.white24,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    const Text('Habilidades:',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    Wrap(
                      spacing: 8,
                      children: (pokemonData['abilities'] as List)
                          .map((ability) => Chip(
                                label: Text(
                                    ability['ability']['name'].toUpperCase()),
                                backgroundColor: Colors.white24,
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
