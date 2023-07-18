import 'dart:convert';
import 'dart:math';
import 'package:chess_v2/src/components/game_logic.dart';
import 'package:chess_v2/src/services/uuid_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../components/piece.dart';
import '../helper/helper_methods.dart';

Database db = Database();

enum DbGameState { INGAME, WAITING, GAMEOVER }

// Map<String, dynamic> convertChessPiecesToJson(List<List<ChessPiece?>> pieces){
//   List<List<String>> map = [];
//
//   for (final entry in pieces) {
//     map.add(entry.to)
//   }
//
//   return map;
// }

class Database {
  final SupabaseClient client = Supabase.instance.client;

  // late int id = 304;
  late int id;

  late dynamic subscribed;

  get table => client.from('GAMEROOMS');

  // TODO: REFACTOR
  Future<String> createOrJoinGame() async {
    String? myColor = await joinRoom();
    if (myColor != null) return myColor;
    myColor = Random().nextInt(2) == 0 ? 'white' : 'black';
    await createNewGame(myColor);
    return myColor;
  }

  Future<void> createNewGame(String myColor) async {
    printDB("DB: Creating new game");
    String? myUUID = await getUUID();
    List<List<ChessPiece?>> initedGameBoard = initializeBoard();
    String gameboard = jsonEncode(initedGameBoard);
    Map<String, dynamic> params = {myColor: myUUID, "db_game_board": gameboard};

    Map<String, dynamic> data = await table.insert(params).select().single();
    id = data['game_id'];
  }

  Future<String?> joinRoom() async {
    String? myUUID = await getUUID();
    List<dynamic> rooms = await getAvailableRooms();
    if (rooms.isEmpty) return null;
    for (dynamic room in rooms) {
      if (room['white'] != myUUID && room['black'] != myUUID) {
        printDB("DB: Joining game");
        id = rooms.first['game_id'];
        String availableColor = await getAvailableColor();

        Map<String, dynamic> params = {
          availableColor: myUUID,
          "game_state": DbGameState.INGAME.name
        };
        await table.update(params).eq('game_id', id);

        return availableColor;
      }
    }
  }

  Future<void> update(Map<String, dynamic> payload) async {
    await table.update(payload).eq('game_id', id);
  }

  Future<void> leaveRoom(String? myColor) async {
    await table.update({myColor: null, "game_state": DbGameState.GAMEOVER.name}).eq('game_id', id);
  }

  Future<List<dynamic>> getAvailableRooms() async {
    List<dynamic> rooms = await table.select('*').eq('game_state', DbGameState.WAITING.name);

    return rooms;
  }

  Stream createStream() {
    return table.stream(primaryKey: ['game_id']).eq('game_id', id);
  }

  Future<String> getAvailableColor() async {
    Map<String, dynamic> json = await table.select('*').eq('game_id', id).single();
    return json['white'] == null ? 'white' : 'black';
  }
}
