
List<Map<String, dynamic>> gameRules = [
  {
    'name': 'PAWN',
    "image": "assets/pawn_move.jpg",
    'text': 'PAWNS are unusual because they move and capture in different ways\n',
    "actions":
    "MOVE:\n* If first move: can move forward one or two squares.\n* All other moves: forward one square at a time\n\n ATTACK: diagonally",
  },
  {
    'name': 'KNIGHT',
    "image": "assets/knight_move.jpg",
    'text': 'KNIGHTS are the only pieces that can move over other pieces.\n',
    "actions":
    "MOVE and ATTACK:\n\ngoing two squares in one direction + then one more move at a 90-degree angle.\n\n * just like the shape of an “L”",
  },
  {
    'name': 'KING',
    "image": "assets/king_move.jpg",
    "actions":
    "MOVE and ATTACK:\n\n* ONE square in any direction:\n*up \n*down \n*sideways\n*diagonally",
  },
  {
    'name': 'QUEEN',
    "image": "assets/queen_move.png",
    "actions": "MOVE and ATTACK:\n\n*up\n*down\n*sideways\n*diagonally",
  },
  {
    'name': "BISHOP",
    "image": "assets/bishop_move.png",
    "actions": "MOVE and ATTACK:\n\n *only diagonally",
  },
  {
    'name': "ROOK",
    "image": "assets/rook_move.png",
    "actions": "MOVE and ATTACK:\n\n*up\n*down\n*sideways",
  },
];

String chessHistory =
    'The game of chess is believed to have originated in India, where it was call Chaturange prior to the 6th century AD. The game became popular in India and then spread to Persia, and the Arabs. The Arabs coined the term “Shah Mat”, which translates to “the King is dead”. This is where the word “checkmate” came from.';
